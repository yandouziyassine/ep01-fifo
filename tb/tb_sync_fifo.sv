`timescale 1ns/1ps
`default_nettype none
module tb_sync_fifo;
    parameter int DATA_WIDTH = 8;
    parameter int DEPTH = 16;
    logic clk = 0;
    always #5 clk = ~clk;
    logic rst_n = 1, wr_en = 0, rd_en = 0;
    logic [DATA_WIDTH-1:0] wr_data = '0;
    wire [DATA_WIDTH-1:0] rd_data;
    wire full, empty;
    sync_fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) dut (.*);

    // Abstract queue: shift on pop, append on push. No DUT pointers or count.
    logic [DATA_WIDTH-1:0] model [0:DEPTH-1];
    logic [DATA_WIDTH-1:0] expected_data = '0;
    int occupancy = 0;
    int cycles = 0, writes = 0, reads = 0, overflow_attempts = 0;
    int underflow_attempts = 0, both_full = 0, both_empty = 0;
    int both_middle = 0, resets = 0;
    int unsigned seed = 1, rng;
    int random_cycles = 10000;
    logic [31:0] random_word;

    function automatic logic [31:0] next_random(input logic [31:0] state);
        logic [31:0] value;
        begin
            value = state ^ (state << 13);
            value = value ^ (value >> 17);
            next_random = value ^ (value << 5);
        end
    endfunction

    task automatic check_outputs;
        begin
            if (full !== (occupancy == DEPTH) || empty !== (occupancy == 0))
                $fatal(1, "FLAGS seed=%0d cycle=%0d occupancy=%0d full=%b empty=%b",
                       seed, cycles, occupancy, full, empty);
            if (rd_data !== expected_data)
                $fatal(1, "DATA seed=%0d cycle=%0d expected=%h actual=%h occupancy=%0d",
                       seed, cycles, expected_data, rd_data, occupancy);
        end
    endtask

    task automatic step(input bit push, input bit pop,
                        input logic [DATA_WIDTH-1:0] value);
        bit take_write, take_read;
        begin
            @(negedge clk);
            check_outputs();
            wr_en = push;
            rd_en = pop;
            wr_data = value;
            take_write = push && occupancy < DEPTH;
            take_read = pop && occupancy > 0;
            if (push && occupancy == DEPTH) overflow_attempts++;
            if (pop && occupancy == 0) underflow_attempts++;
            if (push && pop) begin
                if (occupancy == 0) both_empty++;
                else if (occupancy == DEPTH) both_full++;
                else both_middle++;
            end
            // Check registered output cannot change in response to inputs alone.
            #1;
            check_outputs();
            @(posedge clk);
            if (take_read) begin
                expected_data = model[0];
                for (int j = 0; j < occupancy-1; j++) model[j] = model[j+1];
                occupancy--;
                reads++;
            end
            if (take_write) begin
                model[occupancy] = value;
                occupancy++;
                writes++;
            end
            cycles++;
            #1;
            check_outputs();
        end
    endtask

    task automatic reset_fifo;
        begin
            @(negedge clk);
            // Reset has priority even with requests asserted.
            wr_en = 1;
            rd_en = 1;
            rst_n = 0;
            occupancy = 0;
            expected_data = '0;
            resets++;
            #1;
            check_outputs();
            repeat (2) @(posedge clk);
            #1;
            check_outputs();
            @(negedge clk);
            wr_en = 0;
            rd_en = 0;
            rst_n = 1;
            #1;
            check_outputs();
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("CYCLES=%d", random_cycles)) begin end
        if (seed == 0 || random_cycles < 1) $fatal(1, "Require SEED>0 and CYCLES>0");
        rng = seed;
        if ($test$plusargs("VCD")) begin
            $dumpfile("sync_fifo.vcd");
            $dumpvars(0, tb_sync_fifo);
        end
        $display("START width=%0d depth=%0d seed=%0d random_cycles=%0d", DATA_WIDTH, DEPTH, seed, random_cycles);
        reset_fifo();
        step(0, 1, '0); // Underflow; output holds.
        step(1, 1, DATA_WIDTH'('hA5)); // Empty: write only, no bypass.
        step(1, 1, DATA_WIDTH'('h5A)); // Interior: both accepted.
        step(0, 1, '0);
        step(0, 0, '0);
        for (int i = 0; i < DEPTH; i++) step(1, 0, DATA_WIDTH'(i));
        step(1, 0, '1); // Rejected overflow must not corrupt stored data.
        step(1, 1, '1); // Full: read only.
        step(1, 0, '1);
        for (int i = 0; i < DEPTH; i++) step(0, 1, '0);
        // Complete fill/drain rotations guarantee pointer wraparound.
        repeat (3) begin
            for (int i = 0; i < DEPTH; i++) step(1, 0, DATA_WIDTH'(i ^ 'h69));
            for (int i = 0; i < DEPTH; i++) step(0, 1, '0);
        end
        // Reset from occupied and full states, then exercise recovery.
        step(1, 0, '1);
        reset_fifo();
        for (int i = 0; i < DEPTH; i++) step(1, 0, DATA_WIDTH'(i));
        reset_fifo();
        for (int i = 0; i < random_cycles; i++) begin
            rng = next_random(rng);
            random_word = rng;
            rng = next_random(rng);
            step(random_word[0], random_word[1], DATA_WIDTH'(rng));
            if (i % 997 == 996) reset_fifo();
        end
        while (occupancy > 0) step(0, 1, '0);
        step(0, 1, '0);
        if (writes < 4*DEPTH || reads < 4*DEPTH || overflow_attempts == 0 ||
            underflow_attempts == 0 || both_full == 0 || both_empty == 0 ||
            both_middle == 0 || resets < 3)
            $fatal(1, "Required directed coverage missing");
        $display("PASS width=%0d depth=%0d seed=%0d cycles=%0d writes=%0d reads=%0d overflow=%0d underflow=%0d both_full=%0d both_empty=%0d both_middle=%0d resets=%0d",
                 DATA_WIDTH, DEPTH, seed, cycles, writes, reads, overflow_attempts,
                 underflow_attempts, both_full, both_empty, both_middle, resets);
        $finish;
    end
    initial begin
        #100000000;
        $fatal(1, "Watchdog timeout seed=%0d cycle=%0d", seed, cycles);
    end
endmodule
`default_nettype wire
