"""Reproducible Milestone 1 checks; standard-library Python only."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cycles", type=int, default=10000)
    parser.add_argument("--seeds", type=int, nargs="+", default=[1, 42, 2027])
    parser.add_argument("--log-dir", default="logs/milestone1")
    args = parser.parse_args()
    if args.cycles < 1 or any(seed < 1 or seed > 0xFFFFFFFF for seed in args.seeds):
        parser.error("cycles must be positive; seeds must be in 1..2^32-1")
    logs = ROOT / args.log_dir
    logs.mkdir(parents=True, exist_ok=True)
    build = ROOT / "build"
    build.mkdir(exist_ok=True)
    results = []

    def run(name, command, expected_failure=False):
        print(f"{name}: {shlex.join(command)}", flush=True)
        result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, text=True, timeout=120)
        text = result.stdout
        (logs / f"{name}.log").write_text(
            f"$ {shlex.join(command)}\n{text}\nEXIT_STATUS={result.returncode}\n",
            encoding="utf-8")
        okay = result.returncode != 0 if expected_failure else result.returncode == 0
        if expected_failure:
            okay = okay and "must be" in text
        if name.startswith("sim_"):
            okay = okay and "PASS width=" in text
        results.append(dict(name=name, command=command, exit_status=result.returncode,
                            expected_failure=expected_failure, passed=okay))
        if not okay:
            raise RuntimeError(f"{name} failed; see {logs / (name + '.log')}")
        return text

    status = 1
    try:
        for name, cmd in [("verilator_version", ["verilator", "--version"]),
                          ("iverilog_version", ["iverilog", "-V"]),
                          ("vvp_version", ["vvp", "-V"])]:
            run(name, cmd)
        for width, depth in [(1, 2), (8, 4), (16, 16), (32, 256)]:
            tag = f"w{width}_d{depth}"
            run(f"lint_{tag}", ["verilator", "--lint-only", "--Wall",
                "--top-module", "sync_fifo", f"-GDATA_WIDTH={width}",
                f"-GDEPTH={depth}", "rtl/sync_fifo.sv"])
            binary = f"build/{tag}.vvp"
            run(f"compile_{tag}", ["iverilog", "-g2012", "-Wall", "-s", "tb_sync_fifo",
                f"-Ptb_sync_fifo.DATA_WIDTH={width}", f"-Ptb_sync_fifo.DEPTH={depth}",
                "-o", binary, "rtl/sync_fifo.sv", "tb/tb_sync_fifo.sv"])
            for seed in args.seeds:
                run(f"sim_{tag}_seed{seed}", ["vvp", binary,
                    f"+SEED={seed}", f"+CYCLES={args.cycles}"])
        for parameter, value in [("DEPTH", 1), ("DEPTH", 3), ("DATA_WIDTH", 0)]:
            tag = f"invalid_{parameter}_{value}"
            binary = f"build/{tag}.vvp"
            run(f"compile_{tag}", ["iverilog", "-g2012", "-s", "sync_fifo",
                f"-Psync_fifo.{parameter}={value}", "-o", binary, "rtl/sync_fifo.sv"])
            run(tag, ["vvp", binary], expected_failure=True)
        status = 0
    except (OSError, RuntimeError, subprocess.TimeoutExpired) as error:
        print(str(error), file=sys.stderr)
    finally:
        hashes = {str(path.relative_to(ROOT)): hashlib.sha256(path.read_bytes()).hexdigest()
                  for folder in ["rtl", "tb", "scripts"]
                  for path in sorted((ROOT / folder).glob("*")) if path.is_file()}
        (logs / "summary.json").write_text(json.dumps(dict(
            passed=(status == 0), cycles_per_seed=args.cycles, seeds=args.seeds,
            source_sha256=hashes, results=results), indent=2) + "\n", encoding="utf-8")
    print(f"{'PASS' if status == 0 else 'FAIL'}: {len(results)} commands; logs={logs}")
    return status


if __name__ == "__main__":
    sys.exit(main())
