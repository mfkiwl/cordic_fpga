`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/31 09:42:07
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input rst_n,
    inout [14:0]DDR_addr,
    inout [2:0]DDR_ba,
    inout DDR_cas_n,
    inout DDR_ck_n,
    inout DDR_ck_p,
    inout DDR_cke,
    inout DDR_cs_n,
    inout [3:0]DDR_dm,
    inout [31:0]DDR_dq,
    inout [3:0]DDR_dqs_n,
    inout [3:0]DDR_dqs_p,
    inout DDR_odt,
    inout DDR_ras_n,
    inout DDR_reset_n,
    inout DDR_we_n,
    inout FIXED_IO_ddr_vrn,
    inout FIXED_IO_ddr_vrp,
    inout [53:0]FIXED_IO_mio,
    inout FIXED_IO_ps_clk,
    inout FIXED_IO_ps_porb,
    inout FIXED_IO_ps_srstb,
    input sys_clk_0,
    output hdmi_oen,
    output TMDS_clk_n,
    output TMDS_clk_p,
    //input rst_n,
    output [2:0]TMDS_data_n,
    output [2:0]TMDS_data_p,

    //cmos1 
    inout                                        cmos1_scl,         //cmos3 i2c clock
    inout                                        cmos1_sda,         //cmos3 i2c data
    (*mark_debug ="true"*)input                 cmos1_vsync,       //cmos3 vsync
    input                                        cmos1_href,        //cmos3 hsync refrence
    input                                        cmos1_pclk,        //cmos3 pxiel clock
    
    input   [7:0]                                cmos1_d,          //cmos3 data
    output         reg                              cmos1_pwnd ,      //cmos3 pwnd
    output         reg                              cmos1_reset,    //cmos3 reset

    (*mark_debug ="true"*) output               camera_xclk


    );

    (*mark_debug ="true"*)reg [15:0] cnt;
    reg reg_config_strat;

    //ov5640 rst_n pwdn 上电时序控制
    always @(posedge sys_clk_0 or negedge rst_n) begin 
      if (!rst_n) begin
        cnt  <= 0;
      end
      else if (cnt < 'd5000)
        cnt <= cnt + 1;
    end
    
    
    always @(posedge sys_clk_0 or negedge rst_n) begin 
      if (!rst_n) begin
        cmos1_reset  <= 0;
        cmos1_pwnd  <= 1;
        reg_config_strat <= 0;
      end
      else if (cnt == 'd300) begin
        cmos1_pwnd  <= 0;
      end
      else if (cnt == 'd500) begin
        cmos1_reset  <= 1;
      end
      else if (cnt == 'd1500) begin 
        reg_config_strat <= 1;
      end
    end













    //********HDMI��ʾ�ӿ�**********//
    wire [7:0]video_b_0;
    wire FCLK_CLK0;
    wire video_de_0;
    wire [7:0]video_g_0;
    wire video_hs_0;
    wire [7:0]video_r_0;
    wire sys_clk_out;
    wire [31:0]hdmi_data_0;
    wire video_clk;
    wire video_clk_5x;
    wire video_hs;
    wire video_vs;
    wire video_de;
    wire[7:0] video_r;
    wire[7:0] video_g;
    wire[7:0] video_b;
    wire hdmi_start_0;
    wire hdmi_start_1;
    wire video_de_chn1_0;
    wire video_de_chn2_0;
    //*******end**********//
    wire [31:0]ddr_rd_addr,ddr_wr_addr;
    wire [8:0]rd_data_count;
    wire rd_load_flag;
    wire wr_ddr_en;
    wire ila_clk;
    wire [1:0] mst_exec_state_0;
    wire [6:0]addr_test_0;
    wire [6:0]framenum_0;
    wire first_frame_0;

//    wire hdmi_rd_ddr;
    wire rd_addr_last_0;
    wire [1:0]mst_exec_state_1;
    wire [6:0]addr_test_1;
    wire [31:0]hdmi_data_1;
  

    wire tozero;
    wire [15:0] ch0_sys_data_in;
    wire        ch0_sys_we;
    wire fifo_ready;
    wire frame_complete;
    wire camera_clk;
    wire change_complete;
   // wire camera_clk;
    //wire sys_clk_out;
ddr_design_wrapper ddr_design_wrapper_inst
(
    .DDR_addr(DDR_addr),
    .DDR_ba(DDR_ba),
    .DDR_cas_n(DDR_cas_n),
    .DDR_ck_n(DDR_ck_n),
    .DDR_ck_p(DDR_ck_p),
    .DDR_cke(DDR_cke),
    .DDR_cs_n(DDR_cs_n),
    .DDR_dm(DDR_dm),
    .DDR_dq(DDR_dq),
    .DDR_dqs_n(DDR_dqs_n),
    .DDR_dqs_p(DDR_dqs_p),
    .DDR_odt(DDR_odt),
    .DDR_ras_n(DDR_ras_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_we_n(DDR_we_n),
    .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
    .FIXED_IO_mio(FIXED_IO_mio),
    .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
    .FCLK_CLK0_0(FCLK_CLK0),
    .sys_clk_0(sys_clk_out),//(sys_clk_0),
    .video_de_0(video_de),
    .video_vs_0(video_vs),
    .hdmi_data_0(hdmi_data_0),
    .mst_exec_state_0(mst_exec_state_0),
    .hdmi_start_0(hdmi_start_0),
    .frame_complete_0(frame_complete),
    .change_complete_0(change_complete),
    .camera_clk_0(cmos1_pclk),//(camera_clk),
    .cmos_data_0(ch0_sys_data_in),
    .data_valid_0(ch0_sys_we),
    .tozero_0(tozero),
    .video_clk_0(video_clk),
    .fifo_ok_0(fifo_ready),
    .start_rd_0(1'b1)
);

clk_wiz_1 video_clock_m0
(
     // Clock in ports
    .clk_in1(sys_clk_0),
      // Clock out ports
    .clk_out1(ila_clk),
    .clk_out2(sys_clk_out),
    .clk_out3(video_clk),//HDMI��ʾʱ�� 640*480
    .clk_out4(video_clk_5x),
    .clk_out5(camera_clk),
    .clk_out6(camera_xclk),//����ͷ����ʱ��
      // Status and control signals
    .reset(1'b0),//1'b0
    .locked()
 );
/*
 debug_ila ila_test
 (   .clk(FCLK_CLK0),//(ila_clk),
     .probe0(tozero)


 );
 */
 rgb2dvi_3 rgb2dvi_m0 (
         // DVI 1.0 TMDS video interface
         .TMDS_Clk_p(TMDS_clk_p),
         .TMDS_Clk_n(TMDS_clk_n),
         .TMDS_Data_p(TMDS_data_p),
         .TMDS_Data_n(TMDS_data_n),
         .oen(hdmi_oen),
         //Auxiliary signals 
         .aRst_n(1'b1), //1'b1  -asynchronous reset; must be reset when RefClk is not within spec
         
         // Video in
         .vid_pData({video_r,video_g,video_b}),
         .vid_pVDE(video_de),
         .vid_pHSync(video_hs),
         .vid_pVSync(video_vs),
         .PixelClk(video_clk),
         .SerialClk(video_clk_5x)// 5x PixelClk
     );
     hdmi hdmi_color_bar(
           .clk(video_clk),
           .rst(1'b0),//1'b0
           .rst_n(1'b1),
           .hs(video_hs),
           .vs(video_vs),
           .de(video_de),
           .rgb_r(video_r),
           .rgb_g(video_g),
           .rgb_b(video_b),
      //     .hdmi_rd(hdmi_rd_ddr),
           .first_frame(hdmi_start_0),
           .hdmi_data(hdmi_data_0),//(m00_axi_rdata)
           .tozero(tozero)
       );
       
     wire initial_done;                       //OV5640 register configure enable

     /*
        power_on_delay    power_on_delay_inst(
            .clk_25M                 (camera_clk),
            .reset_n                 (rst_n),    
            .camera1_rstn            (cmos1_reset),
            .camera1_pwnd             (cmos1_pwnd ),
            .initial_done              (initial_done)        
        );
    */

         wire Cmos1_Config_Done;
        wire [7:0] i2c_data_r;
        /* 
      reg_config    reg_config_inst1(
          .clk_25M                 (camera_clk),
          .camera_rstn             (cmos1_reset),
          .initial_done              (initial_done),        
          .i2c_sclk                (cmos1_scl),
          .i2c_sdat                (cmos1_sda),
          .reg_conf_done           (Cmos1_Config_Done),
          .reg_index               ()
        //  .clock_20k               ()
      
      );
      */
      reg_config_des u1(
   /*input                            */   .clk            (sys_clk_0)            ,
   /*input                            */   .rst_n          (rst_n)            ,

   /*output reg                       */   .init_done      (init_done)            ,
   /*output             [   7:0]      */   .i2c_data_r     (i2c_data_r)            ,
                                           .reg_config_strat(reg_config_strat),
   /*inout                            */   .scl            (cmos1_scl)            ,
   /*inout                            */   .sda            (cmos1_sda)             
   
     );
              
      wire        init_calib_complete;               //ddr init done
             
            
      camera_capture    camera_capture_inst1(
         .rst_n                   (rst_n),             //external reset  
         .init_done               (init_calib_complete & Cmos1_Config_Done),       // init done
         .camera_pclk             (cmos1_pclk),          //cmos pxiel clock
         .camera_href             (cmos1_href),          //cmos hsync refrence
         .camera_vsync            (cmos1_vsync),      //cmos vsync
         .camera_data             (cmos1_d),          //cmos data
         .ddr_wren                (ch0_sys_we),       //ddr write enable
         .frame_complete(frame_complete),
         .change_complete(change_complete),
         .ddr_data_camera         (ch0_sys_data_in),   //ddr write data
         .fifo_ready(fifo_ready)
     );
endmodule
