`default_nettype none
module async_fifo_formal #(parameter int DEPTH = 2);
    // Free digital waveforms: no clock ratio, phase, or fairness assumptions.
    (* anyseq *) reg wr_clk, rd_clk, rst_n, wr_en, rd_en;
    (* anyseq *) reg [1:0] wr_data;
    wire [1:0] rd_data;
    wire wr_full, rd_empty, wr_ready, rd_ready;
    async_fifo #(.DATA_WIDTH(2), .DEPTH(DEPTH)) dut (.*);

    reg initialized = 1'b0;
    always @($global_clock) begin
        initialized <= 1'b1;
        if (!initialized) assume(!rst_n);
    end
    // Reset is otherwise unconstrained, including common reassertions.
endmodule
`default_nettype wire
