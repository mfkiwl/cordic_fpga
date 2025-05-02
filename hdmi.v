`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/02/02 13:25:43
// Design Name: 
// Module Name: hdmi
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

module hdmi(
    input                 clk,           //pixel clock
    input                 rst,           //reset signal high active
    input                 rst_n,
    (*mark_debug ="true"*)output                hs,            //horizontal synchronization
    (*mark_debug ="true"*)output                vs,            //vertical synchronization
    (*mark_debug ="true"*)output                de,            //video valid
    output[7:0]           rgb_r,         //video red data
    output[7:0]           rgb_g,         //video green data
    output[7:0]           rgb_b,          //video blue data
    input first_frame,
    (*mark_debug ="true"*)input [31:0] hdmi_data,
    output  reg tozero

    );
    reg hs_reg;                      //horizontal sync register
    reg vs_reg;                      //vertical sync register
    reg hs_reg_d0;                   //delay 1 clock of 'hs_reg'
    reg vs_reg_d0;                   //delay 1 clock of 'vs_reg'
   (*mark_debug ="true"*) reg[11:0] h_cnt;                 //horizontal counter
   (*mark_debug ="true"*) reg[11:0] v_cnt;                 //vertical counter
    reg[11:0] active_x;              //video x position 
    reg[11:0] active_y;              //video y position 
    reg[7:0] rgb_r_reg;              //video red data register
    reg[7:0] rgb_g_reg;              //video green data register
    reg[7:0] rgb_b_reg;              //video blue data register
    reg h_active;                    //horizontal video active
    reg v_active;                    //vertical video active
    wire video_active;               //video active(horizontal active and vertical active)
    reg video_active_d0;             //delay 1 clock of video_active
    reg hdmi_active;
    /*******************************hdmi  640*480********************************/
    parameter H_ACTIVE = 16'd640; 
    parameter H_FP = 16'd16;      
    parameter H_SYNC = 16'd96;    
    parameter H_BP = 16'd48;      
    parameter V_ACTIVE = 16'd480; 
    parameter V_FP  = 16'd10;    
    parameter V_SYNC  = 16'd2;    
    parameter V_BP  = 16'd33;    
    parameter HS_POL = 1'b0;
    parameter VS_POL = 1'b0;
    
    parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
    parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)
    /*******************************end*********************************/

    
    assign hs = hs_reg_d0;
    assign vs = vs_reg_d0;
    assign video_active = h_active & v_active;
    assign de = video_active_d0;
    assign rgb_r = rgb_r_reg;
    assign rgb_g = rgb_g_reg;
    assign rgb_b = rgb_b_reg;
    always@(posedge clk or negedge rst_n)//
    begin
        if(!rst_n)
            begin
                hs_reg_d0 <= 1'b0;
                vs_reg_d0 <= 1'b0;
                video_active_d0 <= 1'b0;
            end
        else
            begin
                hs_reg_d0 <= hs_reg;
                vs_reg_d0 <= vs_reg;
                video_active_d0 <= video_active;
            end
    end
    //ͼ�񻺴�ģ���ddr��ַ����
     always@(posedge clk or negedge rst_n)
     begin
         if(!rst_n||~first_frame)
         begin
   
             tozero <= 0;
             end
         else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP + H_SYNC- 1))
         begin
             tozero <= 1;
           
         end    
         else if((v_cnt == V_FP - 2) && (h_cnt == H_FP + H_SYNC- 1))
             tozero <= 0;
         else
             tozero <= tozero;
     end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n||~first_frame)
            h_cnt <= 12'd0;
        else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
            h_cnt <= 12'd0;
        else if(first_frame==1)
            h_cnt <= h_cnt + 12'd1;
        else
            h_cnt <= h_cnt;
    end   

    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n||~first_frame)
            v_cnt <= 12'd0;
        else if(h_cnt == H_TOTAL  - 1)//horizontal sync time H_FP
            if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
                v_cnt <= 12'd0;
            else
                v_cnt <= v_cnt + 12'd1;
        else
            v_cnt <= v_cnt;
    end

    always@(posedge clk or negedge rst_n)//hs
    begin
        if(!rst_n||~first_frame)
            hs_reg <= 1'b0;
        else if(h_cnt == H_FP - 1)//2)//horizontal sync begin2022.1.4
            hs_reg <= HS_POL;
        else if(h_cnt == H_FP + H_SYNC - 1)//2)//horizontal sync end2022.1.4
            hs_reg <= ~hs_reg;
        else
            hs_reg <= hs_reg;
    end
    
    always@(posedge clk or negedge rst_n)//�п�ʼ
    begin
        if(!rst_n||~first_frame)
            h_active <= 1'b0;
        else if(h_cnt == H_FP + H_SYNC + H_BP - 1)//2)//horizontal active begin2022.1.4
            h_active <= 1'b1;
        else if(h_cnt == H_TOTAL - 1)//2)//horizontal active end2022.1.4
            h_active <= 1'b0;
        else
            h_active <= h_active;
    end

    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n||~first_frame)
        begin
            vs_reg <= 1'd0;
            
        end
        else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))//2))//vertical sync begin2022.1.4
            vs_reg <= HS_POL;
        else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))//2))//vertical sync end2022.1.4
        begin
            vs_reg <= ~vs_reg;  
        end
        else
            vs_reg <= vs_reg;
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n||~first_frame)
            v_active <= 1'd0;
        else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))//2))//vertical active begin2022.1.4
            v_active <= 1'b1;
        else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1))//2)) //vertical active end2022.1.4
            v_active <= 1'b0;   
        else
            v_active <= v_active;
    end
    
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                rgb_r_reg <= 8'h00;
                rgb_g_reg <= 8'h00;
                rgb_b_reg <= 8'h00;
            end
        else if(video_active )//video_active &&            axis_right
        begin
        rgb_r_reg <= hdmi_data[7:0];
        rgb_g_reg <= hdmi_data[15:8];
        rgb_b_reg <= hdmi_data[23:16];
        end   
        else
            begin
                rgb_r_reg <= 8'h00;
                rgb_g_reg <= 8'h00;
                rgb_b_reg <= 8'h00;
            end
end

endmodule



