"""Port-only scoreboard; one event scheduler handles coincident clock edges."""
import json
import os
from collections import deque
from pathlib import Path
import random

import cocotb
from cocotb.triggers import Timer


class Bench:
    def __init__(self, dut):
        self.d = dut
        self.depth = int(os.environ['FIFO_DEPTH'])
        self.width = len(dut.wr_data)
        self.seed = int(os.environ['FIFO_SEED'])
        self.rng = random.Random(self.seed)
        self.wh = int(os.environ['WR_PERIOD_PS']) // 2
        self.rh = int(os.environ['RD_PERIOD_PS']) // 2
        self.phase = int(os.environ['RD_PHASE_PS'])
        self.now = 0
        self.nw, self.nr = self.wh, self.rh + self.phase
        self.wclock = self.rclock = 0
        self.wp = self.rp = 0.0
        self.pause_w = self.pause_r = False
        self.queue = deque()
        self.expected = 0
        self.stats = dict(events=0, write_edges=0, read_edges=0, writes=0, reads=0,
                          rejected_writes=0, rejected_reads=0, collisions=0,
                          concurrent_accepts=0, resets=0, peak=0)
        self.recent = deque(maxlen=12)
        dut.wr_clk.value = dut.rd_clk.value = 0
        dut.wr_en.value = dut.rd_en.value = 0
        dut.wr_data.value = 0
        dut.rst_n.value = 1

    def check(self, condition, message):
        assert condition, (f'{message}; seed={self.seed} t_ps={self.now} '
                           f'occupancy={len(self.queue)} recent={list(self.recent)}')

    async def event(self):
        target = min(self.nw, self.nr)
        await Timer(target - self.now, unit='ps')
        self.now = target
        wevent, revent = target == self.nw, target == self.nr
        wrise = wevent and not self.pause_w and not self.wclock
        rrise = revent and not self.pause_r and not self.rclock
        active = int(self.d.rst_n.value)
        write = read = False
        if wrise:
            self.stats['write_edges'] += 1
            write = bool(active and int(self.d.wr_ready.value) and
                         int(self.d.wr_en.value) and not int(self.d.wr_full.value))
            if active and int(self.d.wr_ready.value) and int(self.d.wr_en.value) and not write:
                self.stats['rejected_writes'] += 1
        if rrise:
            self.stats['read_edges'] += 1
            read = bool(active and int(self.d.rd_ready.value) and
                        int(self.d.rd_en.value) and not int(self.d.rd_empty.value))
            if active and int(self.d.rd_ready.value) and int(self.d.rd_en.value) and not read:
                self.stats['rejected_reads'] += 1
        # Check actual occupancy independently of the DUT's conservative flags.
        if read:
            self.check(bool(self.queue), 'accepted read while abstract queue empty')
        if write:
            self.check(len(self.queue) < self.depth, 'accepted write while abstract queue full')
        # Read old queue first: a same-timestamp write cannot bypass an empty FIFO.
        if read:
            self.expected = self.queue.popleft()
            self.stats['reads'] += 1
        if write:
            self.queue.append(int(self.d.wr_data.value))
            self.stats['writes'] += 1
        if wrise and rrise:
            self.stats['collisions'] += 1
        if write and read:
            self.stats['concurrent_accepts'] += 1
        self.stats['peak'] = max(self.stats['peak'], len(self.queue))
        self.recent.append((target, int(wrise), int(rrise), int(write), int(read),len(self.queue)))
        if wevent:
            self.nw += self.wh
            if not self.pause_w:
                self.wclock ^= 1
                self.d.wr_clk.value = self.wclock
                if not self.wclock:
                    self.d.wr_en.value = int(self.rng.random() < self.wp)
                    self.d.wr_data.value = self.rng.getrandbits(self.width)
        if revent:
            self.nr += self.rh
            if not self.pause_r:
                self.rclock ^= 1
                self.d.rd_clk.value = self.rclock
                if not self.rclock:
                    self.d.rd_en.value = int(self.rng.random() < self.rp)
        await Timer(1, unit='ps')
        self.now += 1
        self.stats['events'] += 1
        self.check(int(self.d.rd_data.value) == self.expected,
                   f'registered data expected={self.expected:x} actual={self.d.rd_data.value}')
        if not active:
            self.check(int(self.d.wr_full.value) == 0 and int(self.d.rd_empty.value) == 1,
                       'reset flags')
            self.check(int(self.d.wr_ready.value) == 0 and int(self.d.rd_ready.value) == 0,
                       'reset ready')

    async def run(self, events):
        for _ in range(events):
            await self.event()

    async def until(self, predicate, label):
        for _ in range(40 * (self.depth + 10)):
            if predicate():
                return
            await self.event()
        self.check(False, f'bounded progress failed: {label}')

    async def reset(self, stopped_read=False):
        self.wp = self.rp = 1.0  # Exercise requests during asserted reset.
        self.d.wr_en.value = self.d.rd_en.value = 1
        self.d.rst_n.value = 0
        self.queue.clear()
        self.expected = 0
        self.stats['resets'] += 1
        self.pause_r = stopped_read
        await Timer(1, unit='ps')
        self.now += 1
        await self.run(20)
        self.wp = self.rp = 0.0
        self.d.wr_en.value = self.d.rd_en.value = 0
        self.d.rst_n.value = 1
        if stopped_read:
            await self.run(20)
            self.check(int(self.d.wr_ready.value) == 1 and int(self.d.rd_ready.value) == 0,
                       'stopped read clock must remain locally reset')
            self.pause_r = False
        await self.until(lambda: int(self.d.wr_ready.value) and int(self.d.rd_ready.value),
                         'reset release')
        await self.run(12)
        self.check(int(self.d.rd_empty.value) == 1 and int(self.d.wr_full.value) == 0,
                   'empty after reset release')

    async def fill(self):
        self.wp, self.rp = 1.0, 0.0
        await self.until(lambda: len(self.queue) == self.depth and int(self.d.wr_full.value), 'fill')
        await self.run(20)  # Overflow attempts with known full occupancy.
        self.check(len(self.queue) == self.depth, 'full writes must be rejected')
        self.wp = 0.0
        await self.run(12)

    async def drain(self):
        self.wp, self.rp = 0.0, 1.0
        await self.until(lambda: not self.queue and int(self.d.rd_empty.value), 'drain')
        await self.run(20)  # Underflow attempts and held output.
        self.check(not self.queue, 'empty reads must be rejected')
        self.rp = 0.0
        await self.run(12)


@cocotb.test(timeout_time=50, timeout_unit='ms')
async def fifo_integrity(dut):
    b = Bench(dut)
    await b.reset()
    await b.drain()
    for _ in range(4):
        await b.fill()
        await b.drain()
    await b.fill()
    await b.reset(stopped_read=True)  # Common reset from full with stopped domain.
    # Reset from a partially occupied FIFO as well.
    b.wp, b.rp = 1.0, 0.0
    await b.until(lambda: len(b.queue) >= max(1, b.depth // 2), 'partial fill')
    await b.reset()
    # Stop the read clock during normal operation and fill safely to capacity.
    b.pause_r = True
    await b.fill()
    b.pause_r = False
    await b.drain()
    events = int(os.environ['FIFO_EVENTS'])
    for index in range(4):
        b.wp, b.rp = [(0.9, 0.1), (0.1, 0.9), (0.65, 0.65), (0.5, 0.5)][index]
        await b.run(events // 4)
        if index == 1:
            await b.reset()
    await b.drain()
    b.check(b.stats['writes'] >= 4 * b.depth and b.stats['reads'] >= 4 * b.depth, 'wrap coverage')
    b.check(b.stats['rejected_writes'] > 0 and b.stats['rejected_reads'] > 0, 'rejection coverage')
    b.check(b.stats['peak'] == b.depth and b.stats['resets'] == 4, 'full and reset coverage')
    result = dict(seed=b.seed, width=b.width, depth=b.depth,
                  wr_period_ps=b.wh*2, rd_period_ps=b.rh*2, phase_ps=b.phase,
                  random_events=(events//4)*4, **b.stats)
    Path(os.environ['FIFO_COVERAGE_FILE']).write_text(json.dumps(result, indent=2)+'\n')
    dut._log.info('PASS_ASYNC %s', json.dumps(result, sort_keys=True))
