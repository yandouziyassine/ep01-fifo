"""Lint and independent cocotb regression. Run with build/venv/bin/python."""
import argparse
import hashlib
import importlib.metadata
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--smoke', action='store_true')
    parser.add_argument('--log-dir', default='logs/async_regression')
    args = parser.parse_args()
    logs = (ROOT / args.log_dir).resolve()
    logs.mkdir(parents=True, exist_ok=True)
    (ROOT / 'build').mkdir(exist_ok=True)
    env = os.environ.copy()
    env['PATH'] = str(Path(sys.executable).parent) + os.pathsep + env['PATH']
    results = []

    def run(name, command, extra=None, reject=False):
        print(f'{name}: {shlex.join(command)}', flush=True)
        config = env | (extra or {})
        try:
            proc = subprocess.run(command, cwd=ROOT, env=config, text=True,
                                  stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=180)
            output, status = proc.stdout, proc.returncode
        except subprocess.TimeoutExpired as exc:
            output = str(exc.stdout or '') + '\nTIMEOUT after 180 seconds\n'
            status = 124
        except OSError as exc:
            output, status = str(exc), 127
        (logs / f'{name}.log').write_text(
            f'$ {shlex.join(command)}\nENV={json.dumps(extra or {},sort_keys=True)}\n'
            f'{output}\nEXIT_STATUS={status}\n', encoding='utf-8')
        good = status != 0 and 'must be' in output if reject else status == 0
        result = dict(name=name, command=command, environment=extra or {}, exit_status=status,
                      expected_rejection=reject, passed=good)
        results.append(result)
        if not good:
            raise RuntimeError(f'{name}: check {logs / (name+".log")}')
        return result

    good = False
    try:
        run('verilator_version', ['verilator', '--version'])
        run('iverilog_version', ['iverilog', '-V'])
        run('python_version', [sys.executable, '--version'])
        for width, depth in [(1, 2), (8, 16), (32, 64)]:
            run(f'lint_w{width}_d{depth}', ['verilator', '--lint-only', '--Wall',
                '--top-module', 'async_fifo', f'-GDATA_WIDTH={width}', f'-GDEPTH={depth}',
                'rtl/async_fifo.sv'])
        timings = [(10000,14000,0), (14000,10000,3000),
                   (10000,10000,0), (10000,10000,2500)]
        cases = [(w,d,wp,rp,phase,seed,6000)
                 for w,d in [(1,2),(8,16),(32,64)]
                 for wp,rp,phase in timings for seed in [1,42,2027]]
        cases += [(8,16,10000,14000,1000,2027,100000)]
        if args.smoke:
            cases = [(8,16,10000,14000,0,1,400)]
        for width,depth,wp,rp,phase,seed,events in cases:
            name = f'sim_w{width}_d{depth}_wp{wp}_rp{rp}_p{phase}_s{seed}_n{events}'
            junit = logs / f'{name}.xml'
            coverage = logs / f'{name}.json'
            for old in [junit, coverage]:
                if old.exists(): old.unlink()
            extra = dict(FIFO_DEPTH=str(depth), FIFO_SEED=str(seed), FIFO_EVENTS=str(events),
                         WR_PERIOD_PS=str(wp), RD_PERIOD_PS=str(rp), RD_PHASE_PS=str(phase),
                         FIFO_COVERAGE_FILE=str(coverage), COCOTB_RANDOM_SEED=str(seed))
            result = run(name, ['make', '-s', '-f', 'tb/cocotb/Makefile',
                         f'DATA_WIDTH={width}', f'DEPTH={depth}',
                         f'SIM_BUILD=build/async_w{width}_d{depth}',
                         f'COCOTB_RESULTS_FILE={junit}'], extra)
            tree = ET.parse(junit)
            tests = tree.findall('.//testcase')
            okay = len(tests) == 1 and not tree.findall('.//failure') and not tree.findall('.//error')
            result['passed'] = okay and coverage.exists()
            if not result['passed']: raise RuntimeError(f'{name}: missing or failing test evidence')
            result['coverage'] = json.loads(coverage.read_text())
        for param,value in [('DEPTH',1),('DEPTH',3),('DATA_WIDTH',0)]:
            name = f'invalid_{param}_{value}'
            binary = f'build/async_{name}.vvp'
            run('compile_'+name,['iverilog','-g2012','-s','async_fifo',
                 f'-Pasync_fifo.{param}={value}','-o',binary,'rtl/async_fifo.sv'])
            run(name,['vvp',binary],reject=True)
        good = True
    except (RuntimeError, OSError, ET.ParseError) as exc:
        print(str(exc), file=sys.stderr)
    finally:
        paths = [ROOT/'rtl/async_fifo.sv',ROOT/'scripts/regress_async.py',ROOT/'requirements.txt']
        paths += sorted((ROOT/'tb/cocotb').glob('*'))
        hashes = {str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in paths if p.is_file()}
        try:
            version = importlib.metadata.version('cocotb')
        except importlib.metadata.PackageNotFoundError:
            version = 'not installed'
        (logs/'summary.json').write_text(json.dumps(dict(passed=good,results=results,
            cocotb_version=version,source_sha256=hashes),indent=2)+'\n')
    print(f'{"PASS" if good else "FAIL"}: {len(results)} commands; logs={logs}')
    return 0 if good else 1


if __name__ == '__main__':
    sys.exit(main())
