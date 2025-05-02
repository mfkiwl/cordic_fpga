`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/01 20:33:37
// Design Name: 
// Module Name: camera_capture
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
module camera_capture
(
    input  rst_n,                                           
   // input FCLK_CLK0,
    input  init_done,            	               
    input  camera_pclk,                           
    (*mark_debug ="true"*)input  camera_href,                          //camera�ṩ����ͬ��
    (*mark_debug ="true"*)input  camera_vsync,                       //camera�ṩ��֡ͬ��
    input  [7:0]camera_data,             //camera���ݣ�һ�δ���8λ
    output  ddr_wren,                      //�������Ϻ��Ժ��͵�������Ч��־
    output reg frame_complete,
    (*mark_debug ="true"*)output  reg [15:0]ddr_data_camera ,            //
   // output reg addr_tozero,
    input fifo_ready,
    input change_complete
);
	(*mark_debug ="true"*)wire test_valid;
                  //行计数器
 (*mark_debug ="true"*) reg   [3:0] data_cnt;
 (*mark_debug ="true"*) reg  [10:0]camera_h_cnt;                  //�м���
(*mark_debug ="true"*)reg   [10:0] camera_v_cnt;                 //�м���
                        //

reg  cmos_wr_req;
reg [63:0] reg_ddr_data_camera;
reg data_valid;
reg [15:0]data_test;
assign ddr_wren=cmos_wr_req;
assign test_valid=(camera_href==1'b1)&&(camera_vsync==1'b0)&&data_valid&&~frame_complete;//��ʼ���м�����־


//��֤����һ��ͼ��ʱ�Ǵ�ͷ��ʼ����ģ���������в��ٽ����µ�һ֡����
always@(posedge camera_pclk)
begin
if(!rst_n)
         data_valid <= 0;
else if(camera_h_cnt == 0&&camera_v_cnt == 0&&fifo_ready)             
         data_valid<=1;
     //   else
     //   camera_h_cnt <= 1;
end	

always@(posedge camera_pclk)
begin
if(!rst_n||camera_vsync)
         camera_h_cnt <= 0;
else if(test_valid)//((camera_href==1)&&(camera_vsync==0)&&~frame_complete&&data_valid)             
         camera_h_cnt <= camera_h_cnt +1'b1;
         if (camera_h_cnt==1279)
         camera_h_cnt<=0;
end		
//�м�����
always@(posedge camera_pclk )
begin
if(!rst_n||camera_vsync)// 
begin
    camera_v_cnt <= 0;
end
else if (test_valid)
begin		  //11'd1280
    if (camera_h_cnt==1279 )
    begin
        camera_v_cnt <= camera_v_cnt + 1'b1;
        if(camera_v_cnt==479)
        begin
            camera_v_cnt<=0;//479;//camera_v_cnt;//0;
        end
    end
end
else if(camera_vsync&&camera_v_cnt==479)
begin
        camera_v_cnt<=0;
end
else
	camera_v_cnt <= camera_v_cnt;	 
end	
//֡����źţ���ʾһ֡����ͷͼ��ȫ������DDR3�С����յ���������ź��Լ������֡ͬ���źź�λ
always@(posedge camera_pclk)
begin
if(!rst_n)
         frame_complete<=0;
else if((camera_v_cnt==479)&&(camera_h_cnt==1279))             
        frame_complete<=1;
else if (camera_vsync&&change_complete)
         frame_complete<=0;
end	

//��������ͷ���ݣ�����8λ���һ��RGB565����
always@(posedge camera_pclk)
begin
    if(!rst_n)
    begin
        data_cnt <= 0;
        cmos_wr_req <= 1'b0;
        reg_ddr_data_camera <= 0;
    end
    else if(test_valid)//((camera_href==1'b1)&&(camera_vsync==1'b0)&&data_valid&&~frame_complete)//
    begin
        if(data_cnt <1)                    //读取�个camera数据
        begin
            data_cnt <= data_cnt +1'b1;
            reg_ddr_data_camera <= {reg_ddr_data_camera[7:0],camera_data};
            cmos_wr_req <= 1'b0;
        end
        else  
        begin
                   //读取�个camera数据
            ddr_data_camera <= {reg_ddr_data_camera[7:0],camera_data};
            reg_ddr_data_camera <= 0;
            //ddr_data_camera <= {reg_ddr_data_camera[7:0],camera_data};
          //   ddr_data_camera <= data_test;

                        
            data_cnt <= 0;
            cmos_wr_req <= 1'b1;                             //读取�个bytes，产生ddr写信�
        end
    end
    else 
    begin
        data_cnt <= 0;
        cmos_wr_req <= 1'b0;
        reg_ddr_data_camera <= 0;
    end 						   
end
//���Ʋ������ݣ���Ҫ�̶����ݲ���ʱʹ��,������
always@(posedge camera_pclk)
begin
   if(camera_v_cnt>=0&&camera_v_cnt<2)////x_jieguo  160  data_cnt y_cnt[1]==0
            begin
                data_test<=16'h001f;
            end
            else if(camera_v_cnt>=2&&camera_v_cnt<240)//160  320  y_cnt[1]==1
            begin
                data_test<=16'h07e0;
            end
            else if(camera_v_cnt>=240&&camera_v_cnt<478)//160  320  y_cnt[1]==1
            begin
                data_test<=16'hffff;
            end
            else if(camera_v_cnt>=478&&camera_v_cnt<480)//160  320  y_cnt[1]==1
            begin
                data_test<=16'hf800;
            end
             else
            begin
                data_test<=16'hf00f;
            end
end
/* ������
always@(posedge camera_pclk)
begin
     if(camera_h_cnt>=0&&camera_h_cnt<160)////x_jieguo  160  data_cnt y_cnt[1]==0
              begin
                  data_test<=16'h001f;
              end
              else if(camera_h_cnt>=160&&camera_h_cnt<480)//160  320  y_cnt[1]==1
              begin
                  data_test<=16'h07e0;
              end
              else if(camera_h_cnt>=480&&camera_h_cnt<800)//160  320  y_cnt[1]==1
              begin
                  data_test<=16'hffff;
              end
              else if(camera_h_cnt>=800&&camera_h_cnt<1120)//160  320  y_cnt[1]==1
              begin
                  data_test<=16'hf800;
              end
              else if(camera_h_cnt>=1120&&camera_h_cnt<1280)//160  320  y_cnt[1]==1
              begin
                  data_test<=16'h0ff0;
              end
               else
              begin
                  data_test<=16'hf00f;
              end
end  
*/
	/*
always@(posedge camera_pclk)
begin
    ddr_wren <= cmos_wr_req;
end
*/
endmodule

