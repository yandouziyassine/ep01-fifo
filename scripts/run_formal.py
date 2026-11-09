"""Execute small-parameter formal tasks and retain exact outcomes."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--log-dir',default='logs/formal')
    parser.add_argument('--tasks',nargs='+',default=['local_d2','prove_d2','prove_d4','cover_d2'])
    args=parser.parse_args()
    if any(t not in ['local_d2','prove_d2','prove_d4','bmc_d2','bmc_d4','cover_d2'] for t in args.tasks):
        parser.error('unknown task')
    logs=(ROOT/args.log_dir).resolve()
    if not logs.is_relative_to(ROOT): parser.error('log directory must be inside project')
    logs.mkdir(parents=True,exist_ok=True)
    for task in args.tasks:
        if (logs/task).exists(): parser.error('task directory exists; choose a new --log-dir to preserve evidence')
    records=[]

    def run(name,cmd,timeout=120):
        print(f'{name}: {shlex.join(cmd)}',flush=True)
        try:
            p=subprocess.run(cmd,cwd=ROOT,text=True,stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT,timeout=timeout)
            output,code=p.stdout,p.returncode
        except subprocess.TimeoutExpired as exc:
            output=(exc.stdout.decode() if isinstance(exc.stdout,bytes) else exc.stdout or '')+'\nHOST TIMEOUT\n'
            code=124
        except OSError as exc:
            output,code=str(exc),127
        (logs/f'{name}.log').write_text(f'$ {shlex.join(cmd)}\n{output}\nEXIT_STATUS={code}\n')
        record=dict(name=name,command=cmd,exit_status=code)
        records.append(record)
        return record

    run('yosys_version',['yosys','-V'])
    run('z3_version',['z3','--version'])
    run('sby_revision',['git','-C','build/sby','rev-parse','HEAD'])
    sby=ROOT/'build/sby/sbysrc/sby.py'
    for task in args.tasks:
        r=run(task,[sys.executable,str(sby),'-d',str(logs/task),'formal/async_fifo.sby',task])
        statusfile=logs/task/'status'
        r['formal_status']=statusfile.read_text().strip() if statusfile.exists() else 'NO_STATUS'
        r['passed']=r['exit_status']==0 and r['formal_status'].split()[0]=='PASS'
    passed=all(r['exit_status']==0 and r.get('passed',True) for r in records)
    sources=[ROOT/'rtl/async_fifo.sv',ROOT/'scripts/run_formal.py',*sorted((ROOT/'formal').glob('*'))]
    hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sources if p.is_file()}
    (logs/'summary.json').write_text(json.dumps(dict(passed=passed,results=records,source_sha256=hashes),indent=2)+'\n')
    print(f'{"PASS" if passed else "INCOMPLETE/FAIL"}: see {logs}/summary.json')
    return 0 if passed else 1


if __name__=='__main__':
    sys.exit(main())
