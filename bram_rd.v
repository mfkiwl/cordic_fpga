`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/17 01:24:31
// Design Name: 
// Module Name: bram_rd
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
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/05/09 09:22:26
// Design Name: 
// Module Name: bram_rd
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

  module bram_rd(
    input                clk        , //??????
    input                rst_n      , //??¦Ë???
   input                start_rd   , //????????
    // input [31:0] read_addr,
   (*mark_debug ="true"*)output      [15:0]         dataout1,
  // input [31:0] processing_time,
    //input processing_input,
    //RAM???
    output               ram_clk    , //RAM???
    input        [31:0]  ram_rd_data, //RAM?§Ø?????????
   output  reg          ram_en     , //RAM??????
   output  reg  [31:0]  ram_addr   , //RAM???
  output  reg  [3:0]   ram_we     , //RAM??§Õ???????
   output  reg  [31:0]  ram_wr_data, //RAM§Õ????
  output               ram_rst      //RAM??¦Ë???,??????§¹
 // output [7:0] dataout1
);

//reg define
reg  [1:0]   flow_cnt;
reg          start_rd_d0;
reg          start_rd_d1;

//wire define
wire         pos_start_rd;

//*****************************************************
//**                  main code
//*****************************************************

assign  ram_rst = 1'b0;
assign  ram_clk = clk ;
assign pos_start_rd = ~start_rd_d1 & start_rd_d0;
assign dataout1=ram_rd_data;
//??????????start_rd??????????
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
      start_rd_d0 <= 1'b0;   
     start_rd_d1 <= 1'b0; 
   end
   else begin
      start_rd_d0 <= start_rd;   
      start_rd_d1 <= start_rd_d0;     
  end
end

//???????????,??RAM?§Ø???????
always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin
       flow_cnt <= 2'd0;
      ram_en <= 1'b0;
       ram_addr <= 32'd0;
       ram_we <= 4'd0;
   end
  else begin
       case(flow_cnt)
           2'd0 : begin
              if(pos_start_rd) begin
                   ram_en <= 1'b1;
                   ram_addr <= 0;//32'h40000000;//start_addr;
                  flow_cnt <= flow_cnt + 2'd1;
               end
               /*
               else if(processing_input)
               begin
                     ram_we <= 4'd1;
                   ram_en <= 1'b1;
                   ram_addr <= 1;
                   ram_wr_data<=processing_time;
                   flow_cnt <= flow_cnt + 2'd1; 
               end
               */
           end
           2'd1 : begin
           //    if(ram_addr - start_addr == rd_len - 4) begin  //???????
                   ram_en <= 1'b0;
                   flow_cnt <= flow_cnt + 2'd1;
                //   ram_we <= 4'd0;
             // end
            //   else
              //    ram_addr <= ram_addr + 32'd4;              //??????4
           end
           2'd2 : begin
               ram_addr <= 32'd0; 
               flow_cnt <= 2'd0;
          end
      endcase    
  end
end

endmodule
