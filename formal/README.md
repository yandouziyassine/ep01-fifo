# Milestone 4 — Executed assertions and formal safety verification

2026-11-05. **PASS:** unrestricted-clock safety proofs for DATA_WIDTH=2,
DEPTH=2 and DEPTH=4. This is not a proof of every parameter configuration or
of complete FIFO data ordering. The cocotb scoreboard remains the independent
functional ordering evidence.

## Reproduce in WSL Ubuntu

From ep01_fifo:

```bash
sudo apt-get install -y yosys z3 git
mkdir -p build
# This official SBY tag matches Ubuntu's Yosys 0.33:
git clone --depth 1 --branch yosys-0.33 https://github.com/YosysHQ/sby.git build/sby
git -C build/sby rev-parse HEAD
python3 scripts/run_formal.py --log-dir logs/formal_reproduction
```

Executed SBY revision: `85dd50b92a3acf170954a06f20f49e2162ce5273`.
Executed tools: Yosys 0.33 (`2584903a060`), its bundled ABC PDR engine, and
Z3 4.8.12. SBY is run from the ignored build checkout; no system installation
is needed. Existing task directories are preserved: choose a new log directory
for every repeated run. The runner records command lines, output, exit status,
SBY status tokens, and input hashes. A timeout or UNKNOWN does not count as PASS.

## Clock and reset model

- Both clock levels are independent anyseq values at each formal global step.
  They may stall, change phase or frequency, and have coincident rising edges.
  No ratio, periodicity, fairness, or guaranteed progress is assumed.
- Both requests and the 2-bit payload are unconstrained. Requests at full,
  empty, and during reset are included.
- Common rst_n is assumed low in the first global observation, establishing
  a reset baseline. After that it is unconstrained, including reassertions.
  There is one common reset, matching the interface; unilateral reset is not
  modeled as a supported operation.
- SBY `multiclock on` models edge-triggered and asynchronous digital state.
  A global step is a formal sampling point, not a nanosecond or a local cycle.
- The real two-stage synchronizer logic is retained as ideal digital flops.
  There is no nondeterministic analog metastability or routing-skew model.
  Setup/hold, minimum reset pulse width, reset recovery/removal, and the
  documented physical Gray-bus constraints remain integration obligations.

## Properties and scope

`async_fifo_properties.svh` is included inside the RTL only under FORMAL,
which Yosys enables with `read -formal`. This avoids requiring a commercial
bind/SVA front end. It uses immediate SystemVerilog assertions and `$past`,
with asynchronous reset-aware history-valid registers to exclude invalid
cross-reset comparisons. No functional logic or port was changed.

| Property family | What is checked |
|---|---|
| Pointer movement | Exactly one step after an accepted request; hold after blocked or absent request |
| Source Gray encoding | Registered Gray equals binary XOR shifted binary |
| Source Gray transition | Zero or one bit changes between local source samples, excluding reset epochs |
| Local flags | Registered comparison matches the previous edge's next-pointer comparison |
| Synchronizers | First stage samples source Gray; second stage samples the first stage |
| Reset release | Each reset pipeline shifts ones while released and clears under assertion |
| Reset state | Zero pointers/Gray/synchronizer state, full=0, empty=1, read output zero |
| Read output hold | Data does not change after a rejected/absent read |
| Local acceptance gates | No acceptance while the corresponding flag blocks or local ready is low |
| Cross-domain capacity | Modular binary-pointer distance stays in 0..DEPTH |
| Accepted operations at bounds | Write requires distance<DEPTH; read requires distance>0 |

The acceptance-gate assertions alone restate combinational definitions. The
pointer-step, pointer-hold, and independent capacity assertions make the
safety checks substantive. Distance uses the extended pointers modulo 2D;
the proof checks that the accepted transitions never leave the valid interval.
It does not check actual memory payloads or ordered data delivery.

## Actual results

| Task | Configuration | Engine | Result and bound |
|---|---|---|---|
| local_d2 | 2 bits, depth 2; local checks only | ABC PDR | PASS, unbounded safety |
| prove_d2 | 2 bits, depth 2; all 30 assertions | ABC PDR | PASS, unbounded safety |
| prove_d4 | 2 bits, depth 4; all 30 assertions | ABC PDR | PASS, unbounded safety |
| cover_d2 | 2 bits, depth 2; six cover statements | Z3, explicit unrolling | PASS; depth limit 64, all reached by step 29 |

Unbounded means all reachable digital states under this harness, with no
finite temporal horizon. It does not mean all widths/depths, liveness, physical
correctness, or complete data integrity. PDR does not use the k-induction
depth option. `bmc_d2` and `bmc_d4` are optional final-config tasks at depth 20;
they were not executed in that final configuration. Earlier 40-step attempts
with a different encoding timed out and must not be described as passing.

All six covers used the same unrestricted clock/reset assumptions as the
safety tasks; no special clock constraints were added:

| Cover | Reached global step | Witness |
|---|---|---|
| Ready read attempt while empty | 6 | trace0 |
| Accepted write | 6 | trace1 |
| Ready write attempt while full | 10 | trace2 |
| Accepted read | 13 | trace3 |
| Accepted write crossing full extended-pointer wrap | 22 | trace4 |
| Accepted read crossing full extended-pointer wrap | 29 | trace5 |

Witnesses are in `logs/formal/cover_d2/engine_0/` as VCD, Yosys witness (.yw),
constraint (.smtc), and generated Verilog files. VCD remains covered by the
project-wide generated-waveform ignore rule; the other witness formats and
logs can be version controlled. Cover witnesses are existential reachability
examples, not universal progress claims or substitutes for assertion proofs.

## Debugging and remaining work

The original non-unrolled Z3 configuration timed out on all four initial
tasks at 90 seconds. A cvc5 diagnostic passed eight bounded steps but did
not establish the final claims. Explicit Z3 unrolling passed twelve diagnostic
steps; a 40-step diagnostic was terminated at 60 seconds without completing.
A separate 16-step k-induction attempt failed to establish an invariant;
its induction trace is not a reset-reachable functional counterexample.
ABC PDR proved the same local subset and subsequently the expanded complete
suite from reset. Source snapshots and logs for the unsuccessful attempts
were retained in `logs/formal_initial/`, `logs/development/`, and the PDR
probe directories. They were not relabeled as successful proofs.

The final run passed all four tasks and all seven runner commands. An ordinary
Verilator/Icarus/cocotb smoke regression also passed after adding the inactive
formal include; see `logs/formal_integration_smoke/`. Removing that include
restores the exact pre-Milestone-4 RTL SHA-256, confirming the instrumentation
introduced no functional source changes.

Unproven: other widths/depths, actual memory data ordering, eventual delivery,
bounded physical synchronization latency, metastability/MTBF, physical timing
constraints, and target-memory behavior. Reset covers do not replace analog
reset validation. Synthesis resource analysis remains Milestone 5.

## Learning notes

An assertion says every allowed execution must satisfy a condition. An
assumption removes executions from consideration and must match the system
contract. A cover asks for one execution reaching a state. A bounded pass
only excludes violations within its horizon; PDR proves an inductive reachable
state invariant without a finite horizon. A failed k-induction attempt can
start from unreachable states, so it is not by itself a reachable design bug.

Typical interview questions: Why guard `$past` after reset? Why can successive
destination Gray samples differ in multiple bits? Why is checking an acceptance
gate alone weak? Why do safety proofs not establish liveness without progress
assumptions? Why does a small-instance proof not establish parameterized correctness?

References: [SBY formal Verilog extensions](https://symbiyosys.readthedocs.io/en/latest/verilog.html)
and [SBY task/engine reference](https://symbiyosys.readthedocs.io/en/latest/reference.html).
These describe supported workflows; project logs establish the actual results.
