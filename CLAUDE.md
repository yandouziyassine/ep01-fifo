# EP01 context for Claude

You are continuing EP01, a software-only ASIC portfolio project for a
parameterized dual-clock asynchronous FIFO. Read `README.md`,
`docs/report.md`, `docs/async_architecture.md`, `formal/README.md`, and
`docs/engineering_log.md` before changing RTL.

The production RTL is `rtl/async_fifo.sv`. It has separate write/read clocks,
binary and registered Gray pointers, two-flop pointer synchronizers,
conservative local `wr_full`/`rd_empty` flags, registered read data, and a
common flush reset with independently synchronized release. Do not change the
interface contract without documenting the CDC and verification trade-off.

Current evidence: Milestones 1-4 are complete. The cocotb queue-based
regression passed 37 asynchronous simulations with 316,000 randomized
scheduler events. Formal safety proofs passed for DATA_WIDTH=2 at DEPTH=2 and
4; those proofs do not establish physical metastability, liveness, formal
payload ordering, or all parameter values. Logs are evidence: preserve them
and never call an unexecuted check a pass.

Use free tools only: Verilator, Icarus, cocotb, Yosys, SymbiYosys, and SMT
solvers. Keep `build/` generated and ignored. Retain reproducible commands,
record seeds/tool versions/results, run relevant tests after RTL changes, and
update the report and chronological engineering log for every substantive
milestone. The next planned work is Milestone 5: Yosys synthesis/resource
analysis, without inventing ASIC timing, area, power, or CDC signoff results.
