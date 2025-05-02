`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/29 16:06:59
// Design Name: 
// Module Name: power_on_delay
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
module power_on_delay(
input       clk_25M,          
input       reset_n ,            
output     camera1_rstn,

output     camera1_pwnd ,

output    reg initial_done  
 );

reg [17:0]cnt_1;
reg [15:0]cnt_2;
reg [19:0]cnt_3;
reg camera_rstn_reg;
reg camera_pwnd_reg;

assign camera1_rstn=camera_rstn_reg;
assign camera1_pwnd=camera_pwnd_reg;

//delay for 5ms,����ϵͳ�ϵ��ʼ��
always@(posedge clk_25M)
begin
    if(reset_n==1'b0)
    begin
        cnt_1 <= 0;
        camera_pwnd_reg <= 1'b1;	
    end
    else  if(cnt_1<18'h40000)
    begin
        cnt_1 <= cnt_1 + 1'b1;
        camera_pwnd_reg <= 1'b1;	
    end		
    else
        camera_pwnd_reg <= 1'b0;
end

//1.3ms, delay from pwdn low to resetb pull up
always@(posedge clk_25M)
begin
    if(camera_pwnd_reg==1)  
    begin
        cnt_2<=0;
        camera_rstn_reg<=1'b0;  
    end
    else if(cnt_2<16'hffff) 
    begin
        cnt_2<=cnt_2+1'b1;
        camera_rstn_reg<=1'b0;
    end
    else
        camera_rstn_reg<=1'b1;         
end

//21ms, delay from resetb pul high to SCCB initialization
always@(posedge clk_25M)
begin
    if(camera_rstn_reg==0) 
    begin
        cnt_3<=0;
        initial_done<=1'b0;
    end
    else if( cnt_3==20'hfffff) 
    begin
        initial_done<=1'b1; 
       // cnt_3<= cnt_3+1'b1;2023.7.12
       // initial_done<=1'b0;
    end
    else
    begin
        cnt_3<= cnt_3+1'b1;
        initial_done<=1'b0;//initial_done<=1'b1;  
    end  
end

endmodule
