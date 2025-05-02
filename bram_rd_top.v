`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module ddr_design_bram_rd_0_1 (
  clk,
  rst_n,
  start_rd,
  dataout1,
  ram_clk,
  ram_rd_data,
  ram_en,
  ram_addr,
  ram_we,
  ram_wr_data,
  ram_rst
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_BUSIF clk, ASSOCIATED_RESET rst_n, FREQ_HZ 150000000, PHASE 0.000, CLK_DOMAIN ddr_design_processing_system7_0_0_FCLK_CLK0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst_n, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst_n RST" *)
input wire rst_n;
input wire start_rd;
output wire [15 : 0] dataout1;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ram_clk, ASSOCIATED_RESET ram_rst, ASSOCIATED_BUSIF BRAM_PORT, FREQ_HZ 100000000, PHASE 0.000" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 ram_clk CLK, xilinx.com:interface:bram:1.0 BRAM_PORT CLK" *)
output wire ram_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT DOUT" *)
input wire [31 : 0] ram_rd_data;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT EN" *)
output wire ram_en;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *)
output wire [31 : 0] ram_addr;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT WE" *)
output wire [3 : 0] ram_we;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT DIN" *)
output wire [31 : 0] ram_wr_data;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME ram_rst, POLARITY ACTIVE_LOW, XIL_INTERFACENAME BRAM_PORT, MASTER_TYPE BRAM_CTRL, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, READ_WRITE_MODE READ_WRITE" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 ram_rst RST, xilinx.com:interface:bram:1.0 BRAM_PORT RST" *)
output wire ram_rst;

  bram_rd inst (
    .clk(clk),
    .rst_n(rst_n),
    .start_rd(start_rd),
    .dataout1(dataout1),
    .ram_clk(ram_clk),
    .ram_rd_data(ram_rd_data),
    .ram_en(ram_en),
    .ram_addr(ram_addr),
    .ram_we(ram_we),
    .ram_wr_data(ram_wr_data),
    .ram_rst(ram_rst)
  );
endmodule