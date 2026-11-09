// Included inside async_fifo only when read with -formal.
// History valid bits clear asynchronously at each local reset epoch.
reg f_write_history = 1'b0;
reg f_read_history = 1'b0;
always @(posedge wr_clk or negedge wr_rst_n)
    if (!wr_rst_n) f_write_history <= 1'b0;
    else f_write_history <= 1'b1;
always @(posedge rd_clk or negedge rd_rst_n)
    if (!rd_rst_n) f_read_history <= 1'b0;
    else f_read_history <= 1'b1;

always @(posedge wr_clk) begin
    if (wr_rst_n && f_write_history) begin
        // Pointer advances exactly on an accepted operation, otherwise holds.
        assert(wr_binary == $past(wr_binary) + PTR_WIDTH'($past(wr_accept)));
        if ($past(wr_full) || !$past(wr_en))
            assert(wr_binary == $past(wr_binary));
        assert(wr_gray == (wr_binary ^ (wr_binary >> 1)));
        assert($onehot0(wr_gray ^ $past(wr_gray)));
        // Check the registered flag against the prior edge's comparison.
        assert(wr_full == $past(wr_gray_next == (rd_gray_sync ^ FULL_MASK)));
        assert(rd_gray_sync == $past(rd_gray_meta));
    end
    if (!wr_rst_n) begin
        assert(wr_binary == 0 && wr_gray == 0 && !wr_full);
        assert(rd_gray_meta == 0 && rd_gray_sync == 0);
    end
    assert(!(wr_accept && (wr_full || !wr_ready)));
    cover(wr_rst_n && wr_accept);
    cover(wr_rst_n && wr_en && wr_full);
    cover(wr_rst_n && wr_accept && wr_binary == PTR_WIDTH'(2*DEPTH-1));
end

always @(posedge rd_clk) begin
    if (rd_rst_n && f_read_history) begin
        assert(rd_binary == $past(rd_binary) + PTR_WIDTH'($past(rd_accept)));
        if ($past(rd_empty) || !$past(rd_en))
            assert(rd_binary == $past(rd_binary));
        assert(rd_gray == (rd_binary ^ (rd_binary >> 1)));
        assert($onehot0(rd_gray ^ $past(rd_gray)));
        assert(rd_empty == $past(rd_gray_next == wr_gray_sync));
        assert(wr_gray_sync == $past(wr_gray_meta));
        if (!$past(rd_accept)) assert(rd_data == $past(rd_data));
    end
    if (!rd_rst_n) begin
        assert(rd_binary == 0 && rd_gray == 0 && rd_empty && rd_data == 0);
        assert(wr_gray_meta == 0 && wr_gray_sync == 0);
    end
    assert(!(rd_accept && (rd_empty || !rd_ready)));
    cover(rd_rst_n && rd_accept);
    cover(rd_rst_n && rd_en && rd_empty);
    cover(rd_rst_n && rd_accept && rd_binary == PTR_WIDTH'(2*DEPTH-1));
end

// Cross-domain safety is assessed separately from local induction.
`ifndef LOCAL_ONLY
wire [PTR_WIDTH-1:0] f_distance = wr_binary - rd_binary;
reg f_started = 1'b0;
always @($global_clock) f_started <= 1'b1;
always @* if (f_started) begin
    assert(f_distance <= PTR_WIDTH'(DEPTH));
    if (!wr_rst_n) assert(wr_binary == 0 && wr_gray == 0 && !wr_full);
    if (!rd_rst_n) assert(rd_binary == 0 && rd_gray == 0 && rd_empty && rd_data == 0);
end
always @(posedge wr_clk)
    if (f_started && wr_accept) assert(f_distance < PTR_WIDTH'(DEPTH));
always @(posedge rd_clk)
    if (f_started && rd_accept) assert(f_distance > 0);
`endif
