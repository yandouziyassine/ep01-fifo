# EP01 — Parameterized FIFO RTL and Verification

Software-only ASIC portfolio project for a May–December 2027 internship.
**Milestones 1–5 complete:** synchronous baseline, dual-clock FIFO, cocotb
verification, formal safety proofs for selected small instances, and generic
Yosys synthesis/resource analysis.
Created fresh with user authorization because the original files were unavailable.

## Synchronous baseline contract

- DATA_WIDTH >= 1; power-of-two DEPTH >= 2. Defaults: 8 bits, 16 entries.
- One clock, active-low asynchronous control reset; release reset synchronously in hardware.
- Registered read output: changes only after an accepted read or reset.
- Full rejects writes; empty rejects reads, using state before the edge.
- At full, simultaneous requests accept only the read; at empty, only the write.
- Interior simultaneous requests accept both and preserve occupancy.
- Reset discards queued data and clears output/control state; memory is unreset.

## Setup and run (WSL2 Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y verilator iverilog python3
cd /mnt/c/Users/yando/Documents/ChatGPT/ASIC/ep01_fifo
bash scripts/run_iverilog.sh
```

No board, paid EDA tools, or FPGA flow is needed. This synchronous script
uses Python's standard library. It returns nonzero on failed checks. Verified
locally with Ubuntu 24.04.4 LTS, Verilator 5.020, and Icarus/vvp 12.0.

The default matrix is width/depth 1/2, 8/4, 16/16, 32/256, each with seeds
1, 42, and 2027 and 10,000 random traffic steps. Directed tests run first.
All 12 simulations passed, covering 120,000 random steps plus directed traffic.
Four RTL lint runs passed with one documented, signal-scoped reset waiver.
Depths 1 and 3 and width 0 were rejected by expected-failure tests.

```bash
# Save a separate, longer regression without overwriting the recorded evidence:
python3 scripts/regress.py --cycles 100000 --seeds 123 456 --log-dir logs/custom
# Reproduce an individual executed case after a default regression:
vvp build/w16_d16.vvp +SEED=42 +CYCLES=10000
# Optional waveform, viewed with a separately installed GTKWave:
vvp build/w16_d16.vvp +SEED=42 +CYCLES=10000 +VCD
gtkwave sync_fifo.vcd
```

The longer and waveform commands above are examples, not claimed executed runs.
The complete runner requires WSL/Linux tool names on PATH. Windows Icarus 11.0
was detected during preflight but was not used for the recorded regression.

## Files and evidence

- `rtl/sync_fifo.sv`: synthesizable control/storage description; no memory reset.
- `tb/tb_sync_fifo.sv`: independent abstract queue, directed tests, deterministic traffic.
- `scripts/regress.py`: versions, lint, compilation, seeded simulations, parameter rejection.
- `scripts/run_iverilog.sh`: stable Bash entry point for the full regression.
- `logs/milestone1/`: actual commands, complete tool output, exit statuses, and source hashes.
- [Academic report](docs/report.md): architecture, equations, results, trade-offs, interview questions, limitations.
- [Engineering log](docs/engineering_log.md): chronological decisions and debugging.

Generated executables and VCD files are ignored. Logs are retained for review.
Use a new `--log-dir` to preserve an existing run. Formal safety results for
selected instances are described below; synthesis, physical CDC signoff, and
ASIC timing/power/area measurements remain pending.

## Roadmap

1. Completed: synchronous baseline and reproducible verification.
2. Completed: dual-clock FIFO architecture and reset/CDC assumptions.
3. Completed: independent cocotb verification with unrelated clocks and phase variation.
4. Completed: 30 safety assertions proved for 2-bit data at depths 2 and 4, with explicit clock/reset assumptions.
5. Completed: generic Yosys synthesis/resource analysis; no ASIC PPA claims.


## Asynchronous FIFO and cocotb verification

`rtl/async_fifo.sv` has independent wr_clk and rd_clk, binary/registered Gray
pointers, two-flop pointer synchronizers, and registered local flags.
`wr_full` and `rd_empty` are conservative views with synchronization latency;
they are not instantaneous global occupancy. Each domain uses its local flag.

A common active-low rst_n flushes both domains. Reset asserts asynchronously
and releases through a two-flop pipeline per clock. Ignore requests while the
corresponding wr_ready or rd_ready is low. These ready outputs mean reset
release completed; they do not replace full/empty. Data output remains
registered, and memory contents are not reset. One-sided reset is unsupported.
See the [architecture and equations](docs/async_architecture.md) for the
full derivation and physical CDC assumptions.

From ep01_fifo inside WSL Ubuntu:

```bash
sudo apt-get install -y python3-venv make
python3 -m venv build/venv
build/venv/bin/python -m pip install -r requirements.txt
# Quick integration test:
build/venv/bin/python scripts/regress_async.py --smoke --log-dir logs/async_smoke
# Full matrix plus a longer case:
build/venv/bin/python scripts/regress_async.py
```

The cocotb dependency is pinned at 2.0.1. The runner invokes Icarus through
cocotb's Makefile flow, checks JUnit XML and coverage JSON as well as exit
status, and saves commands/environment, tool output, and source hashes.
The scoreboard uses only public ports, a Python deque, and actual accepted
transactions. It separately checks capacity, order, registered output,
bounded progress, reset flushing, and rejection attempts. A single event
scheduler drives both clocks so coincident edges have deterministic handling.

The full matrix uses widths/depths 1/2, 8/16, 32/64; seeds 1, 42, 2027;
write/read periods 10/14 ns, 14/10 ns, and 10/10 ns; and startup phase offsets
0, 2.5, or 3 ns as applicable. A separate longer case uses 100,000 random
scheduler events. Each matrix case also performs directed wraparound,
full/empty, reset from full/partial occupancy, and stopped-read-clock tests.
**All 37 asynchronous simulations passed**, including 316,000 random
scheduler events plus directed tests. All 49 runner commands met expectations.
See the [report](docs/report.md) for the full counts and limitations.
Random scheduler events are not identical to clock cycles: events can be
rising or falling edges, and coincident edges share one event.

Raw evidence: `logs/async_smoke/` and `logs/async_regression/`. Initial setup
failure is retained in `logs/async_initial/`; it occurred before cocotb
installation completed, not in FIFO simulation. Package setup output is in
`logs/development/`. No physical metastability, ASIC memory mapping, formal
proof, or PPA result is established by these simulations alone.


## Formal safety verification

[Formal guide and setup](formal/README.md) documents every assumption,
property family, actual result, diagnostic failure, and remaining proof gap.
The production RTL has a FORMAL-only assertion include; no functional logic
or port changed. Thirty immediate assertions were proved with ABC PDR for
DATA_WIDTH=2 and DEPTH=2/4, with independent unrestricted digital clocks,
requests, and reset reassertions after an initially asserted common reset.
These are unbounded safety proofs for those instances, not a proof of all
parameter choices or of ordered memory payload delivery.

All six reachability goals passed at depth 2, including full extended-pointer
wraps, with the last reached at global step 29 (search limit 64). Four final
formal tasks and all seven runner commands passed. Raw logs, copied sources,
SMT/AIG models, and witness traces are retained in `logs/formal/`.

After the guide's one-time Yosys/Z3/SBY setup, run:

```bash
python3 scripts/run_formal.py --log-dir logs/formal_reproduction
```

The runner preserves existing task directories, so use a fresh output path.
Earlier Z3 timeouts and incomplete induction checks are retained separately;
they are not passing evidence. No physical metastability or timing guarantee
follows from RTL formal verification. Eventual-delivery liveness and formal
payload ordering remain unproven. Milestone 5 synthesis analysis is complete;
the generic results are described below.

## Generic synthesis

Milestone 5 ran a 13-command Yosys 0.33 matrix for both FIFO modules at
width/depth 1/2, 8/16, and 32/64. Every command completed successfully.
The full results, exact commands, warnings, source hashes, and engineering
interpretation are in [the synthesis report](docs/synthesis.md).

```bash
python3 scripts/synthesize.py --log-dir logs/synthesis_reproduction
```

The flow recognizes each storage array as one `$mem_v2` cell before generic
mapping, then lowers it to flip-flops and multiplexers because no ASIC memory
macro or standard-cell library is provided. The results are useful RTL
resource comparisons, but they are not physical ASIC area, timing, power, or
memory-macro results.
