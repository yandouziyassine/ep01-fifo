"""Reproducible generic Yosys synthesis reports; no ASIC PPA claims."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shlex
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CASES = [
    ("sync_w1_d2", "sync_fifo", 1, 2),
    ("sync_w8_d16", "sync_fifo", 8, 16),
    ("sync_w32_d64", "sync_fifo", 32, 64),
    ("async_w1_d2", "async_fifo", 1, 2),
    ("async_w8_d16", "async_fifo", 8, 16),
    ("async_w32_d64", "async_fifo", 32, 64),
]


def parse_stats(output):
    """Extract the final human-readable Yosys stat block from one command."""
    blocks = re.findall(
        r"=== .*? ===\s*(.*?)(?=\n\d+\.\d+\.|\nWarning:|\nEnd of script.)",
        output,
        re.DOTALL,
    )
    if not blocks:
        return None
    block = blocks[-1]
    names = {
        "wires": "Number of wires",
        "wire_bits": "Number of wire bits",
        "public_wires": "Number of public wires",
        "public_wire_bits": "Number of public wire bits",
        "memories": "Number of memories",
        "memory_bits": "Number of memory bits",
        "processes": "Number of processes",
        "cells": "Number of cells",
    }
    stats = {}
    for key, label in names.items():
        match = re.search(rf"{re.escape(label)}:\s+(\d+)", block)
        if match:
            stats[key] = int(match.group(1))
    cell_types = {}
    cells_match = re.search(r"Number of cells:\s+\d+\s*(.*)", block, re.DOTALL)
    if cells_match:
        for cell, count in re.findall(r"^\s+(\S+)\s+(\d+)\s*$",
                                      cells_match.group(1), re.MULTILINE):
            cell_types[cell] = int(count)
    stats["cell_types"] = cell_types
    return stats


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--log-dir", default="logs/synthesis")
    args = parser.parse_args()
    logs = (ROOT / args.log_dir).resolve()
    if not logs.is_relative_to(ROOT):
        parser.error("log directory must be inside the project")
    logs.mkdir(parents=True, exist_ok=True)
    records = []

    def run(name, command):
        print(f"{name}: {shlex.join(command)}", flush=True)
        try:
            result = subprocess.run(command, cwd=ROOT, text=True,
                                    stdout=subprocess.PIPE,
                                    stderr=subprocess.STDOUT, timeout=120)
            output, status = result.stdout, result.returncode
        except subprocess.TimeoutExpired as error:
            output, status = (error.stdout or "") + "\nHOST TIMEOUT\n", 124
        except OSError as error:
            output, status = str(error), 127
        (logs / f"{name}.log").write_text(
            f"$ {shlex.join(command)}\n{output}\nEXIT_STATUS={status}\n",
            encoding="utf-8",
        )
        record = {"name": name, "command": command, "exit_status": status}
        stats = parse_stats(output)
        if stats is not None:
            record["statistics"] = stats
        records.append(record)
        if status:
            raise RuntimeError(f"{name} failed; see {logs / (name + '.log')}")
        return record

    passed = False
    try:
        run("yosys_version", ["yosys", "-V"])
        for tag, top, width, depth in CASES:
            source = f"rtl/{top}.sv"
            inspect_script = (
                f"read_verilog -sv {source}; "
                f"chparam -set DATA_WIDTH {width} -set DEPTH {depth} {top}; "
                f"hierarchy -top {top}; proc; memory_collect; opt; stat"
            )
            mapped_script = (
                f"read_verilog -sv {source}; "
                f"chparam -set DATA_WIDTH {width} -set DEPTH {depth} {top}; "
                f"hierarchy -top {top}; synth -top {top}; stat"
            )
            inspect = run(f"inspect_{tag}", ["yosys", "-Q", "-p", inspect_script])
            run(f"synth_{tag}", ["yosys", "-Q", "-p", mapped_script])
            record = records[-1]
            record.update({"tag": tag, "top": top, "data_width": width,
                           "depth": depth,
                           "pre_mapping_memory_statistics": inspect.get("statistics")})
        passed = True
    except RuntimeError as error:
        print(error, file=sys.stderr)
    finally:
        files = [ROOT / "rtl/sync_fifo.sv", ROOT / "rtl/async_fifo.sv",
                 ROOT / "scripts/synthesize.py"]
        hashes = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                  for path in files}
        (logs / "summary.json").write_text(json.dumps({
            "passed": passed, "records": records, "source_sha256": hashes,
            "note": "Generic Yosys mapping only; no ASIC timing, area, power, or memory-macro claim.",
        }, indent=2) + "\n", encoding="utf-8")
    print(f"{'PASS' if passed else 'FAIL'}: {len(records)} commands; logs={logs}")
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
