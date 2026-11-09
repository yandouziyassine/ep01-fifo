# Milestone 5 — Generic Yosys synthesis results

Executed on 2026-11-08 with Yosys 0.33 (git SHA
`2584903a060`). The complete commands, source hashes, stdout/stderr, and
parsed statistics are in `logs/synthesis/`. Run them again from WSL Ubuntu:

```bash
python3 scripts/synthesize.py --log-dir logs/synthesis_reproduction
```

This is a generic technology-independent mapping. It does not use an ASIC
standard-cell library or memory macro, so it must not be interpreted as ASIC
area, timing, power, or a final implementation estimate.

## Results

| Module | Width/depth | Generic cells | Storage flip-flops | Multiplexers |
|---|---:|---:|---:|---:|
| sync_fifo | 1/2 | 22 | 7 | 1 |
| sync_fifo | 8/16 | 353 | 149 | 120 |
| sync_fifo | 32/64 | 4,340 | 2,099 | 2,016 |
| async_fifo | 1/2 | 43 | 23 | 1 |
| async_fifo | 8/16 | 403 | 180 | 120 |
| async_fifo | 32/64 | 4,406 | 2,140 | 2,016 |

“Storage flip-flops” is the sum of the generic mapped cell types beginning
with `$_DFF` or `$_DFFE`; it includes control, synchronizer, output, and
mapped memory state. It is not a separately synthesized SRAM count.

Before generic mapping, each configuration contains one `$mem_v2` cell after
`proc; memory_collect`, showing that Yosys recognizes the RTL storage array.
The `synth` command has no target memory mapping rule and therefore lowers
that storage into ordinary flip-flops and read-data multiplexers. For example,
the 32-bit × 64-entry array has 2,048 data bits and produces 2,048 enabled
flip-flops plus 2,016 multiplexers in both FIFO variants.

The asynchronous versions add pointer, Gray-state, synchronizer, reset-release,
flag, and output control logic. At 32/64 it adds 66 generic cells compared
with the synchronous baseline under this mapping. That number is specific to
this Yosys version and generic cell basis; it is not an ASIC area delta.

Every one of the 13 synthesis commands returned zero. Yosys's `check` pass
reported zero structural problems per mapped module. The logs contain one
legacy `translate_off` comment warning during parsing. The guards are
simulation-only parameter checks; this warning did not indicate a synthesized
logic failure. Replacing it with a portable conditional guard can be considered
later, but no production RTL behavior was changed in this milestone.

The first report-writing implementation mistakenly used `stat -json` as if
it accepted an output filename. Yosys treated that filename as a selection,
leaving an empty report while returning zero. A second attempt used the wrong
relative report location. Both local attempts are ignored by Git and retained
only in the working tree. The final runner parses the emitted `stat` data
directly into `logs/synthesis/summary.json`; it was rerun successfully after
the correction.

## Engineering interpretation

The generic mapping confirms that both RTL modules elaborate and synthesize,
and that their arrays are represented as memories before technology mapping.
It does not validate a true dual-port ASIC memory macro, physical CDC
constraints, reset recovery/removal, static timing, power, or area. A target
ASIC flow should map the array to an approved memory macro and separately
constrain the dual-clock and Gray-pointer paths described in
`async_architecture.md`.
