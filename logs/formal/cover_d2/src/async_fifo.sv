`timescale 1ns/1ps
`default_nettype none

// Synchronized-pointer asynchronous FIFO, registered read, common flush reset.
module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16,
    localparam int ADDR_WIDTH = (DEPTH < 2) ? 1 : $clog2(DEPTH),
    localparam int PTR_WIDTH = ADDR_WIDTH + 1
) (
    input  wire wr_clk, rd_clk,
    input  wire rst_n,
    input  wire wr_en, rd_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic wr_full, rd_empty,
    output wire wr_ready, rd_ready
);
    // Common asynchronous assertion, independent two-edge synchronized release.
    (* ASYNC_REG = "TRUE" *) logic [1:0] wr_reset_pipe, rd_reset_pipe;
    always_ff @(posedge wr_clk or negedge rst_n)
        if (!rst_n) wr_reset_pipe <= '0;
        else wr_reset_pipe <= {wr_reset_pipe[0], 1'b1};
    always_ff @(posedge rd_clk or negedge rst_n)
        if (!rst_n) rd_reset_pipe <= '0;
        else rd_reset_pipe <= {rd_reset_pipe[0], 1'b1};

    // Local reset intentionally also inhibits writes to unreset memory.
    /* verilator lint_off SYNCASYNCNET */
    wire wr_rst_n = wr_reset_pipe[1];
    /* verilator lint_on SYNCASYNCNET */
    wire rd_rst_n = rd_reset_pipe[1];
    assign wr_ready = wr_rst_n;
    assign rd_ready = rd_rst_n;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0] wr_binary, rd_binary, wr_gray, rd_gray;
    (* ASYNC_REG = "TRUE" *) logic [PTR_WIDTH-1:0] rd_gray_meta, rd_gray_sync;
    (* ASYNC_REG = "TRUE" *) logic [PTR_WIDTH-1:0] wr_gray_meta, wr_gray_sync;
    wire wr_accept = wr_ready && wr_en && !wr_full;
    wire rd_accept = rd_ready && rd_en && !rd_empty;
    wire [PTR_WIDTH-1:0] wr_binary_next = wr_binary + PTR_WIDTH'(wr_accept);
    wire [PTR_WIDTH-1:0] rd_binary_next = rd_binary + PTR_WIDTH'(rd_accept);
    wire [PTR_WIDTH-1:0] wr_gray_next = wr_binary_next ^ (wr_binary_next >> 1);
    wire [PTR_WIDTH-1:0] rd_gray_next = rd_binary_next ^ (rd_binary_next >> 1);
    // Invert the two most significant Gray bits. Also works for DEPTH=2.
    localparam logic [PTR_WIDTH-1:0] FULL_MASK = PTR_WIDTH'(3) << (ADDR_WIDTH-1);

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_gray_meta <= '0;
            rd_gray_sync <= '0;
        end else begin
            rd_gray_meta <= rd_gray;
            rd_gray_sync <= rd_gray_meta;
        end
    end
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_gray_meta <= '0;
            wr_gray_sync <= '0;
        end else begin
            wr_gray_meta <= wr_gray;
            wr_gray_sync <= wr_gray_meta;
        end
    end

    always_ff @(posedge wr_clk)
        if (wr_accept) mem[wr_binary[ADDR_WIDTH-1:0]] <= wr_data;

    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_binary <= '0;
            wr_gray <= '0;
            wr_full <= 1'b0;
        end else begin
            wr_binary <= wr_binary_next;
            wr_gray <= wr_gray_next;
            wr_full <= (wr_gray_next == (rd_gray_sync ^ FULL_MASK));
        end
    end
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_binary <= '0;
            rd_gray <= '0;
            rd_empty <= 1'b1;
            rd_data <= '0;
        end else begin
            rd_binary <= rd_binary_next;
            rd_gray <= rd_gray_next;
            rd_empty <= (rd_gray_next == wr_gray_sync);
            if (rd_accept) rd_data <= mem[rd_binary[ADDR_WIDTH-1:0]];
        end
    end

    // Formal-only instrumentation; no functional logic or ports changed.
`ifdef FORMAL
    `include "async_fifo_properties.svh"
`endif

    // synthesis translate_off
    initial begin
        if (DATA_WIDTH < 1) $fatal(1, "DATA_WIDTH must be positive");
        if (DEPTH < 2 || (DEPTH & (DEPTH-1)) != 0)
            $fatal(1, "DEPTH must be a power of two >= 2");
    end
    // synthesis translate_on
endmodule
`default_nettype wire
