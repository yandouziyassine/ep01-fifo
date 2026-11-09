# Chronological engineering log

## 2026-11-04 — Preflight and source recovery

- Expected: existing ep01_fifo source tree to review before changes.
- Actual: workspace had only an empty Git repository; named source files were absent from searched Windows and accessible Ubuntu home locations.
- Evidence: `../../logs/milestone1_preflight.md`.
- User clarified that the source was in a missing ChatGPT chat and then explicitly authorized “start fresh.”
- Decision: create a new synchronous baseline; preserve the specified contract and acknowledge provenance.

## 2026-11-04 — Milestone 1 implementation

Files created: `rtl/sync_fifo.sv`, `tb/tb_sync_fifo.sv`,
`scripts/regress.py`, `scripts/run_iverilog.sh`, `.gitignore`, `README.md`,
`docs/report.md`, this log, and actual logs in `logs/`.

Decisions: power-of-two depth >= 2; occupancy counter; registered read;
pre-edge boundary acceptance; no array reset; asynchronous control reset
with synchronous release required at integration. The independent reference
queue shifts and appends instead of duplicating DUT circular pointers.

Environment commands (PowerShell):

```powershell
wsl --list --verbose
wsl -d Ubuntu -- bash -lc 'id; command -v g++; command -v make; command -v verilator; apt-cache policy verilator iverilog'
wsl -d Ubuntu -u root -- bash -lc 'apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y verilator iverilog'
```

Actual: installed Verilator 5.020-1 and Icarus 12.0-2build2 plus dependencies
successfully (exit 0). Initial sandbox WSL denial was resolved by approved
execution outside the sandbox. No hardware or paid tools were introduced.
The package installation transcript was observed in the tool session; unlike
the regression output it was not retained as a complete separate raw log.

Initial lint command, from ep01_fifo inside Ubuntu:

```bash
verilator --lint-only --Wall --top-module sync_fifo rtl/sync_fifo.sv
```

Expected: no diagnostics. Actual: lint stopped on SYNCASYNCNET for rst_n.
Raw output: `logs/development/initial_lint.log`; tool versions in
`logs/development/tools.txt`. An ad hoc shell wrapper accidentally reported
exit 0 by mishandling a shell variable; the tool output clearly identifies
the lint failure. Corrective actions: signal-scoped waiver with hardware
rationale, followed by Python subprocess return-code checking.

Regression command (PowerShell):

```powershell
wsl -d Ubuntu -- python3 /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/regress.py
```

Equivalent Ubuntu command: `python3 scripts/regress.py`.
Expected: four clean lint runs, four clean compiles, twelve passing behavioral
simulations, and three explicit invalid-parameter rejections. Actual: all
29 tool commands met expectations. Each simulation ran 10,000 randomized
steps with its recorded seed, plus directed checks and drain steps.
Commands, full output, statuses, source SHA-256 hashes, and PASS counters
are saved in `logs/milestone1/`. Numerical results are in the academic report.

No functional mismatch was observed. The warning waiver changes tool checking
scope only; it changes neither the hardware nor the contract. The final
sources were re-linted and simulated after adding it.

Next: review and derive the asynchronous FIFO architecture, including the
extra binary/Gray pointer bit, full/empty comparisons, synchronizer latency,
reset coordination, and Gray-bus constraints. Formal, cocotb, and synthesis
remain unexecuted. Suggested first commit message:
`feat: add verified synchronous FIFO baseline for EP01`.

## 2026-11-04 — Entry-point and evidence checks

Executed the documented Bash wrapper through WSL:

```powershell
wsl -d Ubuntu -- bash /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/run_iverilog.sh --cycles 1 --seeds 1 --log-dir logs/entrypoint_smoke
```

Actual: all 21 commands met expectations; four short simulations passed.
This separate smoke run verifies wrapper path handling and does not replace
the 120,000-step randomized matrix. Its raw outputs and summary are retained
in `logs/entrypoint_smoke/`.

A separate Python inspection verified that all source hashes still match the
full regression, all 29 recorded results passed, all retained text files lack
trailing whitespace, and local Markdown links resolve. No source changes
were made after the passing regression. Git lists the new project and
preflight logs as untracked; no commit or remote publication was performed.


## 2026-11-05 — Milestone 2 architecture and implementation

Reviewed the existing RTL, testbench, runners, README, engineering log, report,
and evidence layout before implementing the next milestone. No applicable
AGENTS.md was found. The user instructed “keep going.” Existing Milestone 1
RTL/testbench/runner hashes were checked against their passing summary and
still match; new asynchronous sources are separate.

Files added: `rtl/async_fifo.sv`, `docs/async_architecture.md`,
`tb/cocotb/test_async_fifo.py`, `tb/cocotb/Makefile`,
`scripts/regress_async.py`, and `requirements.txt`. README and report updated.

Decision: synchronized Gray-pointer architecture, local registered flags,
registered read output, unreset storage, common asynchronous flush reset,
and separate two-edge local reset-release pipelines with ready outputs.
Explained conservative flag semantics and reset limitations before coding.
Derived the top-two-Gray-bit full comparison, including depth 2 support.
Documented physical delay/skew requirements without inventing a target SDC.

## 2026-11-05 — Cocotb setup and smoke verification

Environment setup commands from PowerShell:

```powershell
wsl -d Ubuntu -u root -- bash -lc 'apt-get install -y python3-venv > /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/logs/development/python_venv_setup.log 2>&1'
wsl -d Ubuntu -- python3 -m venv /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/build/venv
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo && build/venv/bin/python -m pip install -r requirements.txt > logs/development/cocotb_setup.log 2>&1'
```

Actual: package installation and venv setup exited 0. cocotb 2.0.1 and
find_libpython 0.5.1 were installed inside ignored build/venv.

The first smoke launch occurred while installation was still running.
Expected: simulator launch. Actual: cocotb-config was absent; make exited 2.
The summary writer additionally raised PackageNotFoundError for cocotb.
Root cause: dependency readiness sequencing and an unguarded metadata lookup.
Correction: wait for successful installation completion, guard metadata
lookup, retain failure output, then rerun. No FIFO functional defect was
established by the failed setup attempt. Evidence: `logs/async_initial/`.

Passing smoke command:

```powershell
wsl -d Ubuntu -- /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/build/venv/bin/python /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/regress_async.py --smoke --log-dir logs/async_smoke
```

Actual: all 13 commands met expectations. Three lint configurations had no
unwaived warnings; one cocotb case passed directed tests plus 400 random
scheduler events; three invalid parameter cases failed as expected.
Evidence: `logs/async_smoke/` command logs, coverage JSON, JUnit, and summary.

## 2026-11-05 — Full Milestone 3 regression

Command:

```powershell
wsl -d Ubuntu -- /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/build/venv/bin/python /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/regress_async.py
```

Expected: 36 matrix simulations (3 parameter sets x 4 clock/phase
relationships x 3 seeds), one 100,000-event longer simulation, three RTL lint
runs, version queries, and invalid-parameter rejection. Each simulation
must pass its independent queue assertions and produce JUnit/coverage files.

Actual: all 49 commands met expectations, including 37 passing cocotb
simulations, three clean RTL lint configurations with the documented waiver,
and three expected invalid-parameter rejections. Random scheduler events
totaled 316,000; total directed/random events were 379,055.
Recorded seeds are 1, 42, and 2027. Every case reached capacity and verified
reset recovery; all per-case assertions and JUnit checks passed.

Results and source hashes are in `logs/async_regression/summary.json`; each
simulation also has complete output, coverage JSON, and a JUnit file.
Source hashes for both the previous synchronous baseline and the asynchronous
run were checked and matched. No RTL functional mismatch was observed.
The runner reports Python 3.12.3 while the embedded cocotb banner reports
3.12.4; the unedited logs preserve both observations.

Milestones 2 and 3 are now complete under the documented finite test scope.
No formal proof, synthesis, physical constraints signoff, or PPA claims were
added. Next: Milestone 4 assertion/formal harness and explicit clock/reset
assumptions, then Milestone 5 Yosys synthesis. Suggested commit message:
`feat: add Gray-pointer async FIFO with independent cocotb regression`.



## 2026-11-05 — Milestone 4 formal instrumentation

Reviewed the existing asynchronous RTL, architecture, test runner, report,
and tool availability. Installed free Yosys 0.33 and Z3 4.8.12 in Ubuntu;
setup output is in `logs/development/formal_tool_setup.log`. Cloned official
SBY tag yosys-0.33 into ignored build/sby; setup output is in
`logs/development/sby_setup.log`; exact revision is in final version logs.

Setup commands from PowerShell:

```powershell
wsl -d Ubuntu -u root -- bash -lc 'apt-get install -y yosys z3 > /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/logs/development/formal_tool_setup.log 2>&1'
wsl -d Ubuntu -- bash -lc 'cd /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo && git clone --depth 1 --branch yosys-0.33 https://github.com/YosysHQ/sby.git build/sby > logs/development/sby_setup.log 2>&1'
```

Files added: `formal/async_fifo_properties.svh`,
`formal/async_fifo_formal.sv`, `formal/async_fifo.sby`,
`formal/README.md`, and `scripts/run_formal.py`.
Files changed: `rtl/async_fifo.sv` (inactive FORMAL-only include), README,
academic report, this log. No functional RTL or interface changes.

Decisions: immediate assertions supported by open-source Yosys; reset-aware
history; actual synchronizer flops retained; first-step common reset assumed;
no subsequent clock, traffic, ratio, phase, fairness, or reset restrictions.
Cross-domain safety uses extended-pointer distance and is separate from the
independent cocotb payload queue. No physical metastability model is claimed.

## 2026-11-05 — Formal debugging and tool assessment

Initial command:

```powershell
wsl -d Ubuntu -- python3 /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/run_formal.py --log-dir logs/formal_initial
```

Expected: local induction, two bounded safety checks at depth 40, and covers.
Actual: all four non-unrolled Z3 tasks timed out at 90 seconds. No pass was
claimed; `logs/formal_initial/summary.json` records failure/incompleteness.
Each task's copied configuration and sources preserve that attempt. The
initial summary's completion-time hashes can include later instrumentation;
use copied per-task inputs for exact historical reconstruction.

Installed optional free cvc5 for a diagnostic; its setup output is in
`logs/development/cvc5_setup.log`. Eight cvc5 bounded steps passed on the
existing local model. Explicit unrolling with Z3 passed twelve steps; a
40-step attempt ended at its 60-second host limit. A 16-step local k-induction
check failed to establish an invariant. This is not a reachable functional
RTL counterexample. ABC PDR probes proved the same local properties and
cross-domain safety at both depth 2 and depth 4 without constraining clocks.
Raw outputs remain in development logs and formal_pdr* probe directories.

The diagnostic commands executed inside ep01_fifo in Ubuntu were:

```bash
timeout 30 yosys-smtbmc -s cvc5 -t 8 --noprogress logs/formal_initial/local_d2/model/design_smt2.smt2
timeout 30 yosys-smtbmc -s z3 --unroll -t 12 --noprogress logs/formal_initial/local_d2/model/design_smt2.smt2
timeout 30 yosys-smtbmc -s z3 --unroll -i -t 16 --noprogress --dump-vcd logs/development/induction_probe.vcd logs/formal_initial/local_d2/model/design_smt2.smt2
timeout 60 yosys-smtbmc -s z3 --unroll -t 40 --noprogress --dump-vcd logs/development/safety_probe.vcd logs/formal_initial/bmc_d2/model/design_smt2.smt2
python3 build/sby/sbysrc/sby.py -d logs/formal_pdr_probe build/pdr_probe.sby
python3 build/sby/sbysrc/sby.py -d logs/formal_pdr_safety_probe build/pdr_safety_probe.sby
python3 build/sby/sbysrc/sby.py -d logs/formal_pdr_d4_probe build/pdr_safety_d4_probe.sby
```

Their redirected output is retained in the corresponding development logs.
Probe configurations were copied into their SBY output directories. Corrective
action: use ABC PDR for unbounded safety and explicitly unrolled Z3 for cover.
Expanded checks to include reset-release and first synchronizer stages, then
froze inputs for the final run. Fixed SBY status parsing to use its first
token because status files contain additional fields.

## 2026-11-05 — Milestone 4 final results

Executed:

```powershell
wsl -d Ubuntu -- python3 /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/run_formal.py
wsl -d Ubuntu -- /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/build/venv/bin/python /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/regress_async.py --smoke --log-dir logs/formal_integration_smoke
```

Expected: three PDR safety tasks, six reachable covers, ordinary integration
checks, no functional changes. Actual: all four final formal tasks passed;
all seven runner commands returned 0. All 30 assertions were proved unbounded
for DATA_WIDTH=2 at depths 2 and 4. The local-only depth-2 task also passed.
All six covers reached by global step 29 within a limit of 64. The smoke
regression passed all 13 commands. Evidence is in `logs/formal/` and
`logs/formal_integration_smoke/`. The cover witnesses are retained as VCD,
Yosys witness, constraints, and generated Verilog files.

Final formal source hashes were checked. Removing only the FORMAL include
restores the exact Milestone 3 RTL hash. No functional code change required
rerunning the entire prior 37-case simulation matrix. No new defect in the
FIFO hardware was demonstrated. No paid tools or physical hardware used.

Milestone 4 is complete for its stated instances and property scope.
Unproven: other parameters, payload ordering, liveness, and physical CDC/reset
behavior. Next: Milestone 5 Yosys synthesis, storage mapping, resource counts,
warnings, and trade-offs. Suggested commit message:
`test: prove async FIFO safety with multiclock formal harness`.

## 2026-11-08 — Milestone 5 generic synthesis

Created `scripts/synthesize.py` to execute a reproducible Yosys matrix for
sync_fifo and async_fifo at width/depth 1/2, 8/16, and 32/64. The script runs
an inspection flow through `memory_collect` and a generic `synth` flow,
captures output/status, parses the resulting statistics, and writes source
SHA-256 hashes to `logs/synthesis/summary.json`.

Executed from PowerShell:

```powershell
wsl -d Ubuntu -- python3 /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo/scripts/synthesize.py
```

Expected: six memory inspections, six generic synthesis runs, and one version
query. Actual: all 13 commands returned zero with Yosys 0.33. Each pre-mapping
design included one `$mem_v2` cell. Generic mapping lowered storage to
flip-flops/multiplexers because no ASIC technology memory macro was supplied.
Mapped cell counts were sync 22/353/4,340 and async 43/403/4,406 for the
three configurations. Yosys found zero structural problems in every mapped
module. See `docs/synthesis.md` for the full counts and limitations.

The first runner attempt used `stat -json` as though it wrote to a named
file. Yosys interpreted the path as a selection, producing empty statistics
reports while still exiting zero. A second attempt used an incorrect relative
path. Root cause: incorrect interpretation of the Yosys `stat` interface.
Corrective action: parse the standard `stat` output directly into the runner
summary, preserve the erroneous local logs outside Git, then rerun the full
matrix. No RTL defect was observed or changed.

No ASIC timing, power, area, physical CDC, library mapping, or memory-macro
claim was made. Milestone 5 is complete for generic open-source synthesis.
Suggested commit message:
`feat: add reproducible Yosys synthesis evidence`.
