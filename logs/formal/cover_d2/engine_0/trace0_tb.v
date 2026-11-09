`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  async_fifo_formal UUT (

  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$formal$async_fifo_formal.\sv:13$1_EN  = 1'b0;
    UUT._witness_.anyinit_procdff_702 = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:160:execute$mem#0#past_clk#/wr_clk$716  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:176:execute$mem#0#en_q$720  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:179:execute$mem#0#addr_q$722  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:182:execute$mem#0#data_q$724  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:62:sample_control$$auto$rtlil .\cc:2401:Not$1109#sampled$1110  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:62:sample_control$$auto$rtlil .\cc:2401:Not$1127#sampled$1128  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:62:sample_control$$auto$rtlil .\cc:2401:Not$739#sampled$740  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:74:sample_control_edge$/rd_clk#sampled$1052  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:12$40_CHECK[0:0]$117#sampled$1030  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:12$40_EN[0:0]$118#sampled$1020  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:14$41_CHECK[0:0]$119#sampled$1010  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:14$41_EN[0:0]$120#sampled$1000  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:17$42_CHECK[0:0]$127#sampled$1080  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:17$42_EN[0:0]$128#sampled$1070  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:19$43_CHECK[0:0]$129#sampled$1060  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:32$44_CHECK[0:0]$149#sampled$1296  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:32$44_EN[0:0]$150#sampled$1286  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:35$45_CHECK[0:0]$151#sampled$1276  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:35$45_EN[0:0]$152#sampled$1266  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:36$46_CHECK[0:0]$153#sampled$1256  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:37$47_CHECK[0:0]$155#sampled$1246  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:38$48_CHECK[0:0]$157#sampled$1236  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:40$49_CHECK[0:0]$159#sampled$1226  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:41$50_CHECK[0:0]$161#sampled$1216  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:44$51_CHECK[0:0]$163#sampled$1206  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:44$51_EN[0:0]$164#sampled$1196  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:45$52_CHECK[0:0]$165#sampled$1186  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:47$53_CHECK[0:0]$167#sampled$1176  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:48$54_CHECK[0:0]$169#sampled$1156  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:49$55_CHECK[0:0]$171#sampled$1146  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:50$56_CHECK[0:0]$173#sampled$1136  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:55$57_CHECK[0:0]$231#sampled$1576  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:55$57_EN[0:0]$232#sampled$1566  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:57$58_CHECK[0:0]$233#sampled$1556  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:57$58_EN[0:0]$234#sampled$1546  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:58$59_CHECK[0:0]$235#sampled$1536  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:59$60_CHECK[0:0]$237#sampled$1526  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:60$61_CHECK[0:0]$239#sampled$1516  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:61$62_CHECK[0:0]$241#sampled$1506  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:62$63_CHECK[0:0]$243#sampled$1496  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:64$64_CHECK[0:0]$245#sampled$1486  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:64$64_EN[0:0]$246#sampled$1476  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:66$65_CHECK[0:0]$247#sampled$1466  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:66$65_EN[0:0]$248#sampled$1456  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:67$66_CHECK[0:0]$249#sampled$1446  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:69$67_CHECK[0:0]$251#sampled$1436  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:70$68_CHECK[0:0]$253#sampled$1416  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:71$69_CHECK[0:0]$255#sampled$1406  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:72$70_CHECK[0:0]$257#sampled$1396  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:87$74_CHECK[0:0]$329#sampled$1706  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:87$74_EN[0:0]$330#sampled$1696  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:89$75_CHECK[0:0]$334#sampled$1726  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$formal$async_fifo_properties .\svh:89$75_EN[0:0]$335#sampled$1716  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$past$async_fifo_properties .\svh:40$25$0[0:0]$146#sampled$1326  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0$past$async_fifo_properties .\svh:61$34$0[0:0]$226#sampled$1626  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$0/rd_data[1:0]#sampled$946  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:12$40_CHECK#sampled$1028  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:12$40_EN#sampled$1018  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:14$41_CHECK#sampled$1008  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:14$41_EN#sampled$998  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:17$42_CHECK#sampled$1078  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:17$42_EN#sampled$1068  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:19$43_CHECK#sampled$1058  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:19$43_EN#sampled$1048  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:32$44_CHECK#sampled$1294  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:32$44_EN#sampled$1284  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:35$45_CHECK#sampled$1274  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:35$45_EN#sampled$1264  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:36$46_CHECK#sampled$1254  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:37$47_CHECK#sampled$1244  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:38$48_CHECK#sampled$1234  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:40$49_CHECK#sampled$1224  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:41$50_CHECK#sampled$1214  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:44$51_CHECK#sampled$1204  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:44$51_EN#sampled$1194  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:45$52_CHECK#sampled$1184  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:47$53_CHECK#sampled$1174  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:47$53_EN#sampled$1164  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:48$54_CHECK#sampled$1154  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:49$55_CHECK#sampled$1144  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:50$56_CHECK#sampled$1134  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:55$57_CHECK#sampled$1574  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:55$57_EN#sampled$1564  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:57$58_CHECK#sampled$1554  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:57$58_EN#sampled$1544  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:58$59_CHECK#sampled$1534  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:59$60_CHECK#sampled$1524  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:60$61_CHECK#sampled$1514  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:61$62_CHECK#sampled$1504  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:62$63_CHECK#sampled$1494  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:64$64_CHECK#sampled$1484  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:64$64_EN#sampled$1474  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:66$65_CHECK#sampled$1464  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:66$65_EN#sampled$1454  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:67$66_CHECK#sampled$1444  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:69$67_CHECK#sampled$1434  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:69$67_EN#sampled$1424  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:70$68_CHECK#sampled$1414  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:71$69_CHECK#sampled$1404  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:72$70_CHECK#sampled$1394  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:87$74_CHECK#sampled$1704  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:87$74_EN#sampled$1694  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:89$75_CHECK#sampled$1724  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$formal$async_fifo_properties .\svh:89$75_EN#sampled$1714  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:13$17$0#sampled$1038  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:18$18$0#sampled$1088  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:34$19$0#sampled$1384  = 2'b11;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:34$20$0#sampled$1374  = 1'b1;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:35$21$0#sampled$1364  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:35$22$0#sampled$1354  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:36$23$0#sampled$1344  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:38$24$0#sampled$1334  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:40$25$0#sampled$1324  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:41$26$0#sampled$1314  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:42$27$0#sampled$1304  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:56$28$0#sampled$1684  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:56$29$0#sampled$1674  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:57$30$0#sampled$1664  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:57$31$0#sampled$1654  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:58$32$0#sampled$1644  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:60$33$0#sampled$1634  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:61$34$0#sampled$1624  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:62$35$0#sampled$1614  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:63$36$0#sampled$1604  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:64$37$0#sampled$1594  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$$past$async_fifo_properties .\svh:64$38$0#sampled$1584  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/f_rd_reset_history#sampled$980  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/f_read_history#sampled$1116  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/f_wr_reset_history#sampled$962  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/f_write_history#sampled$1098  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_accept#sampled$1596  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_binary#sampled$1646  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_binary#sampled$908  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_binary_next#sampled$910  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_data#sampled$1586  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_data#sampled$944  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_empty#sampled$1666  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_empty#sampled$926  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_en#sampled$1656  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray#sampled$1306  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray#sampled$890  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray_meta#sampled$1316  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray_meta#sampled$782  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray_next#sampled$892  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_gray_sync#sampled$764  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_reset_pipe#sampled$746  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/rd_reset_pipe[0]#sampled$1090  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_accept#sampled$1376  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_binary#sampled$1346  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_binary#sampled$854  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_binary_next#sampled$856  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_en#sampled$1356  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_full#sampled$1366  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_full#sampled$872  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray#sampled$1336  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray#sampled$836  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray_meta#sampled$1616  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray_meta#sampled$818  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray_next#sampled$838  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_gray_sync#sampled$800  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_reset_pipe#sampled$728  = 2'b01;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data$/wr_reset_pipe[0]#sampled$1040  = 1'b0;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data${/rd_reset_pipe[0]1'1}#sampled$748  = 2'b00;
    // UUT.dut.$auto$clk2fflogic.\cc:88:sample_data${/wr_reset_pipe[0]1'1}#sampled$730  = 2'b00;
    UUT.dut.f_started = 1'b0;
    UUT.initialized = 1'b0;
    UUT.dut.mem[1'b0] = 2'b01;

    // state 0
    UUT.rd_clk = 1'b0;
    UUT.wr_en = 1'b0;
    UUT.wr_data = 2'b00;
    UUT.wr_clk = 1'b1;
    UUT.rst_n = 1'b0;
    UUT.rd_en = 1'b0;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      UUT.rd_clk <= 1'b0;
      UUT.wr_en <= 1'b0;
      UUT.wr_data <= 2'b00;
      UUT.wr_clk <= 1'b1;
      UUT.rst_n <= 1'b1;
      UUT.rd_en <= 1'b1;
    end

    // state 2
    if (cycle == 1) begin
      UUT.rd_clk <= 1'b1;
      UUT.wr_en <= 1'b0;
      UUT.wr_data <= 2'b01;
      UUT.wr_clk <= 1'b1;
      UUT.rst_n <= 1'b1;
      UUT.rd_en <= 1'b0;
    end

    // state 3
    if (cycle == 2) begin
      UUT.rd_clk <= 1'b0;
      UUT.wr_en <= 1'b0;
      UUT.wr_data <= 2'b10;
      UUT.wr_clk <= 1'b0;
      UUT.rst_n <= 1'b1;
      UUT.rd_en <= 1'b0;
    end

    // state 4
    if (cycle == 3) begin
      UUT.rd_clk <= 1'b1;
      UUT.wr_en <= 1'b0;
      UUT.wr_data <= 2'b01;
      UUT.wr_clk <= 1'b1;
      UUT.rst_n <= 1'b1;
      UUT.rd_en <= 1'b1;
    end

    // state 5
    if (cycle == 4) begin
      UUT.rd_clk <= 1'b0;
      UUT.wr_en <= 1'b0;
      UUT.wr_data <= 2'b01;
      UUT.wr_clk <= 1'b1;
      UUT.rst_n <= 1'b1;
      UUT.rd_en <= 1'b1;
    end

    // state 6
    if (cycle == 5) begin
      UUT.rd_clk <= 1'b1;
      UUT.wr_en <= 1'b1;
      UUT.wr_data <= 2'b00;
      UUT.wr_clk <= 1'b0;
      UUT.rst_n <= 1'b0;
      UUT.rd_en <= 1'b1;
    end

    genclock <= cycle < 6;
    cycle <= cycle + 1;
  end
endmodule
