`timescale 1ns/1ps
`default_nettype none

// Single-clock, registered-read FIFO. Acceptance uses flags BEFORE the edge.
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH = 16,
    localparam int ADDR_WIDTH = (DEPTH < 2) ? 1 : $clog2(DEPTH)
) (
    input  wire                  clk,
    // Intentional: async control reset also gates writes to unreset memory.
    // Integration must release rst_n synchronously to clk.
    /* verilator lint_off SYNCASYNCNET */
    input  wire                  rst_n,
    /* verilator lint_on SYNCASYNCNET */
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0]  wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,
    output wire                  full,
    output wire                  empty
);
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH-1:0] wr_ptr, rd_ptr;
    logic [ADDR_WIDTH:0] count;
    wire write_accept = wr_en && !full;
    wire read_accept  = rd_en && !empty;

    assign full  = (count == (ADDR_WIDTH+1)'(DEPTH));
    assign empty = (count == '0);

    // No reset on the storage array: suitable for memory inference.
    always_ff @(posedge clk) begin
        if (rst_n && write_accept)
            mem[wr_ptr] <= wr_data;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr  <= '0;
            rd_ptr  <= '0;
            count   <= '0;
            rd_data <= '0;
        end else begin
            if (write_accept)
                wr_ptr <= wr_ptr + 1'b1;
            if (read_accept) begin
                rd_ptr  <= rd_ptr + 1'b1;
                rd_data <= mem[rd_ptr];
            end
            case ({write_accept, read_accept})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: ; // Both accepted or neither accepted: hold count.
            endcase
        end
    end

    // synthesis translate_off
    initial begin
        if (DATA_WIDTH < 1)
            $fatal(1, "DATA_WIDTH must be positive");
        if (DEPTH < 2 || (DEPTH & (DEPTH-1)) != 0)
            $fatal(1, "DEPTH must be a power of two >= 2");
    end
    // synthesis translate_on
endmodule
`default_nettype wire
