`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/14 17:22:42
// Design Name: 
// Module Name: reg_config_des
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


module reg_config_des(
    input                               clk                        ,
    input                               rst_n                      ,

    output reg                          init_done                  ,
    output             [   7:0]         i2c_data_r                 ,
    (*mark_debug ="true"*)input                               reg_config_strat           ,

    inout                               scl                        ,
    inout                               sda                         
   
     );
     reg i2c_exec;
     reg i2c_rh_wl;
     (*mark_debug ="true"*)reg [12:0] init_reg_cnt;
     (*mark_debug ="true"*)reg [23:0]    i2c_data;
     (*mark_debug ="true"*)wire  i2c_done;
     reg [1:0] i2c_done_reg;
     reg i2c_done_posedge;
     wire [7:0] cur_state;
//i2c_done信号上升沿抓取
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_done_reg <= 0;
    end
    else begin
        i2c_done_reg <= {i2c_done_reg[0], i2c_done};
    end
end   

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i2c_done_posedge <= 0;
    end
    else if (~i2c_done_reg[1] && i2c_done_reg[0]) begin
        i2c_done_posedge <= 1;
    end
    else 
        i2c_done_posedge <= 0;
end

(*mark_debug ="true"*)reg [6:0]  slave_addr;
(*mark_debug ="true"*)reg bit_ctrl;

(*mark_debug ="true"*)wire error_wait_flag;

    i2c_dri#(
       
       .CLK_FREQ  (26'd50_000_000),
       .I2C_FREQ  (18'd100_000)
      )
       u1(
       /*input                          */  .clk             (clk)    ,
       /*input                          */  .rst_n           (rst_n)  ,
    
       /*input                          */  .i2c_exec        (i2c_exec)           ,
       /*input                          */  .bit_ctrl        (bit_ctrl)           ,
       /*input                          */  .i2c_rh_wl       (i2c_rh_wl)           ,
       /*input              [  15:0]    */  .i2c_addr        (i2c_data[23:8])           ,
       /*input              [   7:0]    */  .i2c_data_wr     (i2c_data[7:0])           ,
                                            .slave_addr      (slave_addr),//7位从机地址   //des addr 0x60
       /*output reg                     */  .scl             (scl)           ,
       /*inout                          */  .sda             (sda)           ,
       /*output reg                     */  .i2c_done        (i2c_done)           ,
       /*output reg                     */  .i2c_ack         ()           ,
       /*output reg         [   7:0]    */  .i2c_data_r      (i2c_data_r)           ,
       /*output reg                     */  .i2c_clk         ()     ,
                                            .cur_state (cur_state)      ,
                                            .error_wait_flag (error_wait_flag)
    
    
    
    
      ); 
      
localparam REG_NUM = 269;

(*mark_debug ="true"*)reg [12:0] start_init_cnt;
//reg [12:0] init_reg_cnt;


always @(posedge clk or negedge rst_n) begin  //上电等待20ms
    if (!rst_n || error_wait_flag) begin
        start_init_cnt <= 0;
    end
    else if (start_init_cnt < 13'd5000) begin
        start_init_cnt <= start_init_cnt + 1;
    end
end



always @(posedge clk or negedge rst_n) begin//i2c启动信号
    if (!rst_n || error_wait_flag) begin
        i2c_exec <= 0;
    end
    /*
    else if (init_done == 1) begin
        i2c_exec <= 0;
    end
        */
    else if ((start_init_cnt == 13'd5000) && (cur_state == 1)  && (init_reg_cnt <= REG_NUM) && reg_config_strat == 1) begin
        i2c_exec <= 1;
    end
    else begin
        i2c_exec <= 0;
    end
end



always @(posedge clk or negedge rst_n) begin//配置寄存器计数
    if (!rst_n || error_wait_flag) begin
        init_reg_cnt <= 0;
    end
        
    else if (i2c_done_posedge) begin
        init_reg_cnt <= init_reg_cnt + 1;
    end
end



always @(posedge clk or negedge rst_n) begin//i2c读写信号配置
    if (!rst_n || error_wait_flag) begin
        i2c_rh_wl <= 0;
    end

    else if ((init_reg_cnt == 8'd0) || (init_reg_cnt == 8'd9) || (init_reg_cnt == 8'd13) ) begin
        i2c_rh_wl <= 1;
    end
    else if (init_reg_cnt == 8'd5 || init_reg_cnt == 8'd19) begin
        i2c_rh_wl <= 0;
    end
end


always @(posedge clk or negedge rst_n) begin//i2c从机地址更新
    if (!rst_n || error_wait_flag) begin
        slave_addr <= 0;
        bit_ctrl   <= 0;
    end
    else if ((init_reg_cnt == 8'd0)) begin
        slave_addr <= 7'b1100_000;//des 地址
        bit_ctrl   <= 0; //8位寄存器
    end
    else if (init_reg_cnt == 8'd14 ) begin
        slave_addr <= 7'b1011_001;//ser alias地址
        bit_ctrl   <= 0; //8位寄存器地址
    end
    else if (init_reg_cnt == 8'd20 ) begin
        slave_addr <= 7'b0111_101;//OV5640 地址
        bit_ctrl   <= 1; //16位寄存器地址
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n ) begin
        init_done <= 0;
    end
    else if (i2c_done && (init_reg_cnt == REG_NUM)) begin
        init_done <= 1;
    end
end



always @(posedge clk or negedge rst_n) begin
    if (!rst_n || error_wait_flag) begin
        i2c_data <= 0;
    end
    else begin
        case (init_reg_cnt)
         
        //des_reg
            //读寄存器
            000:i2c_data <= {16'h00,8'h00}; //device id           'hC0
            001:i2c_data <= {16'h06,8'h00}; //ser id              'h00
            002:i2c_data <= {16'h07,8'h00}; //ser alias id        
            003:i2c_data <= {16'h08,8'h00};//slave id //ov5640 
            004:i2c_data <= {16'h10,8'h00};//slave alias id

            //写寄存器
            005:i2c_data <= {16'h07,8'hb2}; //ser alias id
            006:i2c_data <= {16'h08,8'h78}; //slave id //ov5640 
            007:i2c_data <= {16'h10,8'h7A}; //slave alias id  ov5640
            008:i2c_data <= {16'h05,8'hC0}; //short cable

            //读寄存器
            009:i2c_data <= {16'h00,8'h00}; //device id     'hC0
            010:i2c_data <= {16'h06,8'h00}; //ser id 
            011:i2c_data <= {16'h07,8'h00}; //ser alias id
            012:i2c_data <= {16'h08,8'h00};//slave id //ov5640 
            013:i2c_data <= {16'h10,8'h00};//slave alias id

        //ser_reg
            //读寄存器
            014:i2c_data <= {16'h00,8'h00};// ser device id   'hb0
            015:i2c_data <= {16'h03,8'h00};//  [4] : auto ack    'hc5
            016:i2c_data <= {16'h05,8'h00};//  mode select
            017:i2c_data <= {16'h06,8'h00};// des id
            018:i2c_data <= {16'h07,8'h00};// des alias id
            //写寄存器
            019:i2c_data <= {16'h0D,8'h5D};//gpo 输出1，控制ov5640 camera_rst_n


        //ov5640
            020: i2c_data <= {16'h300a,8'h00}; 
            021: i2c_data <= {16'h300b,8'h00}; 
            022: i2c_data <= {16'h3008,8'h82}; 
            023: i2c_data <= {16'h3008,8'h02}; 
            024: i2c_data <= {16'h3103,8'h02}; 
            025: i2c_data <= {16'h3017,8'hff};
            026: i2c_data <= {16'h3018,8'hff};
            027: i2c_data <= {16'h3037,8'h13}; //
            028: i2c_data <= {16'h3108,8'h01}; //
            029: i2c_data <= {16'h3630,8'h36};
            030: i2c_data <= {16'h3631,8'h0e};
            031: i2c_data <= {16'h3632,8'he2};
            032: i2c_data <= {16'h3633,8'h12};
            033: i2c_data <= {16'h3621,8'he0};
            034: i2c_data <= {16'h3704,8'ha0};
            035: i2c_data <= {16'h3703,8'h5a};
            036: i2c_data <= {16'h3715,8'h78};
            037: i2c_data <= {16'h3717,8'h01};
            038: i2c_data <= {16'h370b,8'h60};
            039: i2c_data <= {16'h3705,8'h1a};
            040: i2c_data <= {16'h3905,8'h02};
            041: i2c_data <= {16'h3906,8'h10};
            042: i2c_data <= {16'h3901,8'h0a};
            043: i2c_data <= {16'h3731,8'h12};
            044: i2c_data <= {16'h3600,8'h08}; 
            045: i2c_data <= {16'h3601,8'h33}; 
            046: i2c_data <= {16'h302d,8'h60}; 
            047: i2c_data <= {16'h3620,8'h52};
            048: i2c_data <= {16'h371b,8'h20};
            049: i2c_data <= {16'h471c,8'h50};
            050: i2c_data <= {16'h3a13,8'h43}; 
            051: i2c_data <= {16'h3a18,8'h00}; 
            052: i2c_data <= {16'h3a19,8'hf8}; 
            053: i2c_data <= {16'h3635,8'h13};
            054: i2c_data <= {16'h3636,8'h03};
            055: i2c_data <= {16'h3634,8'h40};
            056: i2c_data <= {16'h3622,8'h01};
            057: i2c_data <= {16'h3c01,8'h34};
            058: i2c_data <= {16'h3c04,8'h28};
            059: i2c_data <= {16'h3c05,8'h98};
            060: i2c_data <= {16'h3c06,8'h00}; 
            061: i2c_data <= {16'h3c07,8'h08}; 
            062: i2c_data <= {16'h3c08,8'h00}; 
            063: i2c_data <= {16'h3c09,8'h1c}; 
            064: i2c_data <= {16'h3c0a,8'h9c}; 
            065: i2c_data <= {16'h3c0b,8'h40}; 
            066: i2c_data <= {16'h3810,8'h00}; 
            067: i2c_data <= {16'h3811,8'h10}; 
            068: i2c_data <= {16'h3812,8'h00}; 
            069: i2c_data <= {16'h3708,8'h64};
            070: i2c_data <= {16'h4001,8'h02}; 
            071: i2c_data <= {16'h4005,8'h1a}; 
            072: i2c_data <= {16'h3000,8'h00}; 
            073: i2c_data <= {16'h3004,8'hff}; 
            074: i2c_data <= {16'h4300,8'h60}; // 数据格式，rgb顺序
            075: i2c_data <= {16'h501f,8'h01}; 
            076: i2c_data <= {16'h440e,8'h00};
            077: i2c_data <= {16'h5000,8'ha7}; 
            078: i2c_data <= {16'h3a0f,8'h30}; 
            079: i2c_data <= {16'h3a10,8'h28}; 
            080: i2c_data <= {16'h3a1b,8'h30}; 
            081: i2c_data <= {16'h3a1e,8'h26}; 
            082: i2c_data <= {16'h3a11,8'h60}; 
            083: i2c_data <= {16'h3a1f,8'h14}; 
            084: i2c_data <= {16'h5800,8'h23};
            085: i2c_data <= {16'h5801,8'h14};
            086: i2c_data <= {16'h5802,8'h0f};
            087: i2c_data <= {16'h5803,8'h0f};
            088: i2c_data <= {16'h5804,8'h12};
            089: i2c_data <= {16'h5805,8'h26};
            090: i2c_data <= {16'h5806,8'h0c};
            091: i2c_data <= {16'h5807,8'h08};
            092: i2c_data <= {16'h5808,8'h05};
            093: i2c_data <= {16'h5809,8'h05};
            094: i2c_data <= {16'h580a,8'h08};
            095: i2c_data <= {16'h580b,8'h0d};
            096: i2c_data <= {16'h580c,8'h08};
            097: i2c_data <= {16'h580d,8'h03};
            098: i2c_data <= {16'h580e,8'h00};
            099: i2c_data <= {16'h580f,8'h00};
            100: i2c_data <= {16'h5810,8'h03};
            101: i2c_data <= {16'h5811,8'h09};
            102: i2c_data <= {16'h5812,8'h07};
            103: i2c_data <= {16'h5813,8'h03};
            104: i2c_data <= {16'h5814,8'h00};
            105: i2c_data <= {16'h5815,8'h01};
            106: i2c_data <= {16'h5816,8'h03};
            107: i2c_data <= {16'h5817,8'h08};
            108: i2c_data <= {16'h5818,8'h0d};
            109: i2c_data <= {16'h5819,8'h08};
            110: i2c_data <= {16'h581a,8'h05};
            111: i2c_data <= {16'h581b,8'h06};
            112: i2c_data <= {16'h581c,8'h08};
            113: i2c_data <= {16'h581d,8'h0e};
            114: i2c_data <= {16'h581e,8'h29};
            115: i2c_data <= {16'h581f,8'h17};
            116: i2c_data <= {16'h5820,8'h11};
            117: i2c_data <= {16'h5821,8'h11};
            118: i2c_data <= {16'h5822,8'h15};
            119: i2c_data <= {16'h5823,8'h28};
            120: i2c_data <= {16'h5824,8'h46};
            121: i2c_data <= {16'h5825,8'h26};
            122: i2c_data <= {16'h5826,8'h08};
            123: i2c_data <= {16'h5827,8'h26};
            124: i2c_data <= {16'h5828,8'h64};
            125: i2c_data <= {16'h5829,8'h26};
            126: i2c_data <= {16'h582a,8'h24};
            127: i2c_data <= {16'h582b,8'h22};
            128: i2c_data <= {16'h582c,8'h24};
            129: i2c_data <= {16'h582d,8'h24};
            130: i2c_data <= {16'h582e,8'h06};
            131: i2c_data <= {16'h582f,8'h22};
            132: i2c_data <= {16'h5830,8'h40};
            133: i2c_data <= {16'h5831,8'h42};
            134: i2c_data <= {16'h5832,8'h24};
            135: i2c_data <= {16'h5833,8'h26};
            136: i2c_data <= {16'h5834,8'h24};
            137: i2c_data <= {16'h5835,8'h22};
            138: i2c_data <= {16'h5836,8'h22};
            139: i2c_data <= {16'h5837,8'h26};
            140: i2c_data <= {16'h5838,8'h44};
            141: i2c_data <= {16'h5839,8'h24};
            142: i2c_data <= {16'h583a,8'h26};
            143: i2c_data <= {16'h583b,8'h28};
            144: i2c_data <= {16'h583c,8'h42};
            145: i2c_data <= {16'h583d,8'hce};
            146: i2c_data <= {16'h5180,8'hff};
            147: i2c_data <= {16'h5181,8'hf2};
            148: i2c_data <= {16'h5182,8'h00};
            149: i2c_data <= {16'h5183,8'h14};
            150: i2c_data <= {16'h5184,8'h25};
            151: i2c_data <= {16'h5185,8'h24};
            152: i2c_data <= {16'h5186,8'h09};
            153: i2c_data <= {16'h5187,8'h09};
            154: i2c_data <= {16'h5188,8'h09};
            155: i2c_data <= {16'h5189,8'h75};
            156: i2c_data <= {16'h518a,8'h54};
            157: i2c_data <= {16'h518b,8'he0};
            158: i2c_data <= {16'h518c,8'hb2};
            159: i2c_data <= {16'h518d,8'h42};
            160: i2c_data <= {16'h518e,8'h3d};
            161: i2c_data <= {16'h518f,8'h56};
            162: i2c_data <= {16'h5190,8'h46};
            163: i2c_data <= {16'h5191,8'hf8};
            164: i2c_data <= {16'h5192,8'h04};
            165: i2c_data <= {16'h5193,8'h70};
            166: i2c_data <= {16'h5194,8'hf0};
            167: i2c_data <= {16'h5195,8'hf0};
            168: i2c_data <= {16'h5196,8'h03};
            169: i2c_data <= {16'h5197,8'h01};
            170: i2c_data <= {16'h5198,8'h04};
            171: i2c_data <= {16'h5199,8'h12};
            172: i2c_data <= {16'h519a,8'h04};
            173: i2c_data <= {16'h519b,8'h00};
            174: i2c_data <= {16'h519c,8'h06};
            175: i2c_data <= {16'h519d,8'h82};
            176: i2c_data <= {16'h519e,8'h38};
            177: i2c_data <= {16'h5480,8'h01}; 
            178: i2c_data <= {16'h5481,8'h08};
            179: i2c_data <= {16'h5482,8'h14};
            180: i2c_data <= {16'h5483,8'h28};
            181: i2c_data <= {16'h5484,8'h51};
            182: i2c_data <= {16'h5485,8'h65};
            183: i2c_data <= {16'h5486,8'h71};
            184: i2c_data <= {16'h5487,8'h7d};
            185: i2c_data <= {16'h5488,8'h87};
            186: i2c_data <= {16'h5489,8'h91};
            187: i2c_data <= {16'h548a,8'h9a};
            188: i2c_data <= {16'h548b,8'haa};
            189: i2c_data <= {16'h548c,8'hb8};
            190: i2c_data <= {16'h548d,8'hcd};
            191: i2c_data <= {16'h548e,8'hdd};
            192: i2c_data <= {16'h548f,8'hea};
            193: i2c_data <= {16'h5490,8'h1d};
            194: i2c_data <= {16'h5381,8'h1e};
            195: i2c_data <= {16'h5382,8'h5b};
            196: i2c_data <= {16'h5383,8'h08};
            197: i2c_data <= {16'h5384,8'h0a};
            198: i2c_data <= {16'h5385,8'h7e};
            199: i2c_data <= {16'h5386,8'h88};
            200: i2c_data <= {16'h5387,8'h7c};
            201: i2c_data <= {16'h5388,8'h6c};
            202: i2c_data <= {16'h5389,8'h10};
            203: i2c_data <= {16'h538a,8'h01};
            204: i2c_data <= {16'h538b,8'h98};
            205: i2c_data <= {16'h5580,8'h06};
            206: i2c_data <= {16'h5583,8'h40};
            207: i2c_data <= {16'h5584,8'h10};
            208: i2c_data <= {16'h5589,8'h10};
            209: i2c_data <= {16'h558a,8'h00};
            210: i2c_data <= {16'h558b,8'hf8};
            211: i2c_data <= {16'h501d,8'h40}; 
            212: i2c_data <= {16'h5300,8'h08};
            213: i2c_data <= {16'h5301,8'h30};
            214: i2c_data <= {16'h5302,8'h10};
            215: i2c_data <= {16'h5303,8'h00};
            216: i2c_data <= {16'h5304,8'h08};
            217: i2c_data <= {16'h5305,8'h30};
            218: i2c_data <= {16'h5306,8'h08};
            219: i2c_data <= {16'h5307,8'h16};
            220: i2c_data <= {16'h5309,8'h08};
            221: i2c_data <= {16'h530a,8'h30};
            222: i2c_data <= {16'h530b,8'h04};
            223: i2c_data <= {16'h530c,8'h06};
            224: i2c_data <= {16'h5025,8'h00};
            225: i2c_data <= {16'h3035,8'h10}; //
            226: i2c_data <= {16'h3036,8'h3c}; //
            227: i2c_data <= {16'h3c07,8'h08};
            228: i2c_data <= {16'h3820,8'h46};
            229: i2c_data <= {16'h3821,8'h01};
            230: i2c_data <= {16'h3814,8'h31};
            231: i2c_data <= {16'h3815,8'h31};
            232: i2c_data <= {16'h3800,8'h00};
            233: i2c_data <= {16'h3801,8'h00};
            234: i2c_data <= {16'h3802,8'h00};
            235: i2c_data <= {16'h3803,8'h04};
            236: i2c_data <= {16'h3804,8'h0a};
            237: i2c_data <= {16'h3805,8'h3f};
            238: i2c_data <= {16'h3806,8'h07};
            239: i2c_data <= {16'h3807,8'h9b};
            240: i2c_data <= {16'h3808,8'h02};
            241: i2c_data <= {16'h3809,8'h80};
            242: i2c_data <= {16'h380a,8'h01};
            243: i2c_data <= {16'h380b,8'he0};
            244: i2c_data <= {16'h380c,8'h07};
            245: i2c_data <= {16'h380d,8'h68};
            246: i2c_data <= {16'h380e,8'h03};
            247: i2c_data <= {16'h380f,8'hd8};
            248: i2c_data <= {16'h3813,8'h06};
            249: i2c_data <= {16'h3618,8'h00};
            250: i2c_data <= {16'h3612,8'h29};
            251: i2c_data <= {16'h3709,8'h52};
            252: i2c_data <= {16'h370c,8'h03};
            253: i2c_data <= {16'h3a02,8'h17}; 
            254: i2c_data <= {16'h3a03,8'h10}; 
            255: i2c_data <= {16'h3a14,8'h17}; 
            256: i2c_data <= {16'h3a15,8'h10}; 
            257: i2c_data <= {16'h4004,8'h02}; 
            258: i2c_data <= {16'h4713,8'h03}; 
            259: i2c_data <= {16'h4407,8'h04}; 
            260: i2c_data <= {16'h460c,8'h22};     
            261: i2c_data <= {16'h4837,8'h22}; 
            262: i2c_data <= {16'h3824,8'h01}; //
            263: i2c_data <= {16'h5001,8'ha3}; 
            264: i2c_data <= {16'h3b07,8'h0a}; 
            265: i2c_data <= {16'h503d,8'h00}; 
            266: i2c_data <= {16'h3016,8'h02};
            267: i2c_data <= {16'h301c,8'h02};
            268: i2c_data <= {16'h3019,8'h02}; 
            269: i2c_data <= {16'h3019,8'h00}; 
            /*
            020:i2c_data<=24'h310311;// system clock from pad, bit[1]
            021:i2c_data<=24'h300882;// software reset, bit[7]// delay 5ms 
            022:i2c_data<=24'h300842;// software power down, bit[6]
            023:i2c_data<=24'h310303;// system clock from PLL, bit[1]
            024:i2c_data<=24'h3017ff;// FREX, Vsync, HREF, PCLK, D[9:6] output enable
            025:i2c_data<=24'h3018ff;// D[5:0], GPIO[1:0] output enable
            026:i2c_data<=24'h30341A;// MIPI 10-bit
            027:i2c_data<=24'h303712;// PLL root divider, bit[4], PLL pre-divider, bit[3:0]
            028:i2c_data<=24'h310800;// PCLK root divider, bit[5:4], SCLK2x root divider, bit[3:2] // SCLK root divider, bit[1:0] 
            029:i2c_data<=24'h363036;
            030:i2c_data<=24'h36310e;
            031:i2c_data<=24'h3632e2;
            032:i2c_data<=24'h363312;
            033:i2c_data<=24'h3621e0;
            034:i2c_data<=24'h3704a0;
            035:i2c_data<=24'h37035a;
            036:i2c_data<=24'h371578;
            037:i2c_data<=24'h371701;
            038:i2c_data<=24'h370b60;
            039:i2c_data<=24'h37051a;
            040:i2c_data<=24'h390502;
            041:i2c_data<=24'h390610;
            042:i2c_data<=24'h39010a;
            043:i2c_data<=24'h373112;
            044:i2c_data<=24'h360008;// VCM control
            045:i2c_data<=24'h360133;// VCM control
            046:i2c_data<=24'h302d60;// system control
            047:i2c_data<=24'h362052;
            048:i2c_data<=24'h371b20;
            049:i2c_data<=24'h471c50;
            050:i2c_data<=24'h3a1343;// pre-gain = 1.047x
            051:i2c_data<=24'h3a1800;// gain ceiling
            052:i2c_data<=24'h3a19f8;// gain ceiling = 15.5x
            053:i2c_data<=24'h363513;
            054:i2c_data<=24'h363603;
            055:i2c_data<=24'h363440;
            056:i2c_data<=24'h362201; // 50/60Hz detection     50/60Hz 灯光条纹过滤
            057:i2c_data<=24'h3c0134;// Band auto, bit[7]
            058:i2c_data<=24'h3c0428;// threshold low sum	 
            059:i2c_data<=24'h3c0598;// threshold high sum
            060:i2c_data<=24'h3c0600;// light meter 1 threshold[15:8]
            061:i2c_data<=24'h3c0708;// light meter 1 threshold[7:0]
            062:i2c_data<=24'h3c0800;// light meter 2 threshold[15:8]
            063:i2c_data<=24'h3c091c;// light meter 2 threshold[7:0]
            064:i2c_data<=24'h3c0a9c;// sample number[15:8]
            065:i2c_data<=24'h3c0b40;// sample number[7:0]
            066:i2c_data<=24'h381000;// Timing Hoffset[11:8]
            067:i2c_data<=24'h381110;// Timing Hoffset[7:0]
            068:i2c_data<=24'h381200;// Timing Voffset[10:8] 
            069:i2c_data<=24'h370864;
            070:i2c_data<=24'h400102;// BLC start from line 2
            071:i2c_data<=24'h40051a;// BLC always update
            072:i2c_data<=24'h300000;// enable blocks
            073:i2c_data<=24'h3004ff;// enable clocks 
            074:i2c_data<=24'h300e00;// MIPI power down, DVP enable
            075:i2c_data<=24'h302e00;
            076:i2c_data<=24'h430060;// RGB565
            077:i2c_data<=24'h501f01;// ISP RGB 
            078:i2c_data<=24'h440e00;
            079:i2c_data<=24'h5000a7; // Lenc on, raw gamma on, BPC on, WPC on, CIP on // AEC target    自动曝光控制
            080:i2c_data<=24'h3a0f30;// stable range in high
            081:i2c_data<=24'h3a1028;// stable range in low
            082:i2c_data<=24'h3a1b30;// stable range out high
            083:i2c_data<=24'h3a1e26;// stable range out low
            084:i2c_data<=24'h3a1160;// fast zone high
            085:i2c_data<=24'h3a1f14;// fast zone low// Lens correction for ?   镜头补偿
            086:i2c_data<=24'h580023;
            087:i2c_data<=24'h580114;
            088:i2c_data<=24'h58020f;
            089:i2c_data<=24'h58030f;
            090:i2c_data<=24'h580412;
            091:i2c_data<=24'h580526;
            092:i2c_data<=24'h58060c;
            093:i2c_data<=24'h580708;
            094:i2c_data<=24'h580805;
            095:i2c_data<=24'h580905;
            096:i2c_data<=24'h580a08;
            097:i2c_data<=24'h580b0d;
            098:i2c_data<=24'h580c08;
            099:i2c_data<=24'h580d03;
            100:i2c_data<=24'h580e00;
            101:i2c_data<=24'h580f00;
            102:i2c_data<=24'h581003;
            103:i2c_data<=24'h581109;
            104:i2c_data<=24'h581207;
            105:i2c_data<=24'h581303;
            106:i2c_data<=24'h581400;
            107:i2c_data<=24'h581501;
            108:i2c_data<=24'h581603;
            109:i2c_data<=24'h581708;
            110:i2c_data<=24'h58180d;
            111:i2c_data<=24'h581908;
            112:i2c_data<=24'h581a05;
            113:i2c_data<=24'h581b06;
            114:i2c_data<=24'h581c08;
            115:i2c_data<=24'h581d0e;
            116:i2c_data<=24'h581e29;
            117:i2c_data<=24'h581f17;
            118:i2c_data<=24'h582011;
            119:i2c_data<=24'h582111;
            120:i2c_data<=24'h582215;
            121:i2c_data<=24'h582328;
            122:i2c_data<=24'h582446;
            123:i2c_data<=24'h582526;
            124:i2c_data<=24'h582608;
            125:i2c_data<=24'h582726;
            126:i2c_data<=24'h582864;
            127:i2c_data<=24'h582926;
            128:i2c_data<=24'h582a24;
            129:i2c_data<=24'h582b22;
            130:i2c_data<=24'h582c24;
            131:i2c_data<=24'h582d24;
            132:i2c_data<=24'h582e06;
            133:i2c_data<=24'h582f22;
            134:i2c_data<=24'h583040;
            135:i2c_data<=24'h583142;
            136:i2c_data<=24'h583224;
            137:i2c_data<=24'h583326;
            138:i2c_data<=24'h583424;
            139:i2c_data<=24'h583522;
            140:i2c_data<=24'h583622;
            141:i2c_data<=24'h583726;
            142:i2c_data<=24'h583844;
            143:i2c_data<=24'h583924;
            144:i2c_data<=24'h583a26;
            145:i2c_data<=24'h583b28;
            146:i2c_data<=24'h583c42;
            147:i2c_data<=24'h583dce;// lenc BR offset // AWB   自动白平�
            148:i2c_data<=24'h5180ff;// AWB B block
            149:i2c_data<=24'h5181f2;// AWB control 
            150:i2c_data<=24'h518200;// [7:4] max local counter, [3:0] max fast counter
            151:i2c_data<=24'h518314;// AWB advanced 
            152:i2c_data<=24'h518425;
            153:i2c_data<=24'h518524;
            154:i2c_data<=24'h518609;
            155:i2c_data<=24'h518709;
            156:i2c_data<=24'h518809;
            157:i2c_data<=24'h518975;
            158:i2c_data<=24'h518a54;
            159:i2c_data<=24'h518be0;
            160:i2c_data<=24'h518cb2;
            161:i2c_data<=24'h518d42;
            162:i2c_data<=24'h518e3d;
            163:i2c_data<=24'h518f56;
            164:i2c_data<=24'h519046;
            165:i2c_data<=24'h5191f8;// AWB top limit
            166:i2c_data<=24'h519204;// AWB bottom limit
            167:i2c_data<=24'h519370;// red limit
            168:i2c_data<=24'h5194f0;// green limit
            169:i2c_data<=24'h5195f0;// blue limit
            170:i2c_data<=24'h519603;// AWB control
            171:i2c_data<=24'h519701;// local limit 
            172:i2c_data<=24'h519804;
            173:i2c_data<=24'h519912;
            174:i2c_data<=24'h519a04;
            175:i2c_data<=24'h519b00;
            176:i2c_data<=24'h519c06;
            177:i2c_data<=24'h519d82;
            178:i2c_data<=24'h519e38;// AWB control // Gamma    伽玛曲线
            179:i2c_data<=24'h548001;// Gamma bias plus on, bit[0] 
            180:i2c_data<=24'h548108;
            181:i2c_data<=24'h548214;
            182:i2c_data<=24'h548328;
            183:i2c_data<=24'h548451;
            184:i2c_data<=24'h548565;
            185:i2c_data<=24'h548671;
            186:i2c_data<=24'h54877d;
            187:i2c_data<=24'h548887;
            188:i2c_data<=24'h548991;
            189:i2c_data<=24'h548a9a;
            190:i2c_data<=24'h548baa;
            191:i2c_data<=24'h548cb8;
            192:i2c_data<=24'h548dcd;
            193:i2c_data<=24'h548edd;
            194:i2c_data<=24'h548fea;
            195:i2c_data<=24'h54901d;// color matrix   色彩矩阵
            196:i2c_data<=24'h53811e;// CMX1 for Y
            197:i2c_data<=24'h53825b;// CMX2 for Y
            198:i2c_data<=24'h538308;// CMX3 for Y
            199:i2c_data<=24'h53840a;// CMX4 for U
            200:i2c_data<=24'h53857e;// CMX5 for U
            201:i2c_data<=24'h538688;// CMX6 for U
            202:i2c_data<=24'h53877c;// CMX7 for V
            203:i2c_data<=24'h53886c;// CMX8 for V
            204:i2c_data<=24'h538910;// CMX9 for V
            205:i2c_data<=24'h538a01;// sign[9]
            206:i2c_data<=24'h538b98; // sign[8:1] // UV adjust   UV色彩饱和度调�
            207:i2c_data<=24'h558006;// saturation on, bit[1]
            208:i2c_data<=24'h558340;
            209:i2c_data<=24'h558410;
            210:i2c_data<=24'h558910;
            211:i2c_data<=24'h558a00;
            212:i2c_data<=24'h558bf8;
            213:i2c_data<=24'h501d40;// enable manual offset of contrast// CIP  锐化和降�
            214:i2c_data<=24'h530008;// CIP sharpen MT threshold 1
            215:i2c_data<=24'h530130;// CIP sharpen MT threshold 2
            216:i2c_data<=24'h530210;// CIP sharpen MT offset 1
            217:i2c_data<=24'h530300;// CIP sharpen MT offset 2
            218:i2c_data<=24'h530408;// CIP DNS threshold 1
            219:i2c_data<=24'h530530;// CIP DNS threshold 2
            220:i2c_data<=24'h530608;// CIP DNS offset 1
            221:i2c_data<=24'h530716;// CIP DNS offset 2 
            222:i2c_data<=24'h530908;// CIP sharpen TH threshold 1
            223:i2c_data<=24'h530a30;// CIP sharpen TH threshold 2
            224:i2c_data<=24'h530b04;// CIP sharpen TH offset 1
            225:i2c_data<=24'h530c06;// CIP sharpen TH offset 2
            226:i2c_data<=24'h502500;
            227:i2c_data<=24'h300802; // wake up from standby, bit[6] //640x480 30�� night mode 5fps, input clock =24Mhz, PCLK =56Mhz
            228:i2c_data<=24'h303511;// PLL
            229:i2c_data<=24'h303628;// PLL         
            230:i2c_data<=24'h3c0708;// light meter 1 threshold [7:0]
            231:i2c_data<=24'h382047;// Sensor flip off, ISP flip on
            232:i2c_data<=24'h382100;// Sensor mirror on, ISP mirror on, H binning on
            233:i2c_data<=24'h381431;// X INC 
            234:i2c_data<=24'h381531;// Y INC
            235:i2c_data<=24'h380000;// HS: X address start high byte
            236:i2c_data<=24'h380100;// HS: X address start low byte
            237:i2c_data<=24'h380200;// VS: Y address start high byte
            238:i2c_data<=24'h380304;// VS: Y address start high byte 
            239:i2c_data<=24'h38040a;// HW (HE)         
            240:i2c_data<=24'h38053f;// HW (HE)
            241:i2c_data<=24'h380607;// VH (VE)         
            242:i2c_data<=24'h38079b;// VH (VE)      
            243:i2c_data<=24'h380802;// DVPHO  
            244:i2c_data<=24'h380980;// DVPHO
            245:i2c_data<=24'h380a01;// DVPVO
            246:i2c_data<=24'h380be0;// DVPVO
            247:i2c_data<=24'h380c07;// HTS            //Total horizontal size 1896
            248:i2c_data<=24'h380d68;// HTS
            249:i2c_data<=24'h380e03;// VTS            //total vertical size 984
            250:i2c_data<=24'h380fd8;// VTS 
            251:i2c_data<=24'h381306;// Timing Voffset 
            252:i2c_data<=24'h361800;
            253:i2c_data<=24'h361229;
            254:i2c_data<=24'h370952;
            255:i2c_data<=24'h370c03; 
            256:i2c_data<=24'h3a0217;// 60Hz max exposure, night mode 5fps
            257:i2c_data<=24'h3a0310;// 60Hz max exposure // banding filters are calculated automatically in camera driver
            258:i2c_data<=24'h3a1417;// 50Hz max exposure, night mode 5fps
            259:i2c_data<=24'h3a1510;// 50Hz max exposure     
            260:i2c_data<=24'h400402;// BLC 2 lines 
            261:i2c_data<=24'h30021c;// reset JFIFO, SFIFO, JPEG
            262:i2c_data<=24'h3006c3;// disable clock of JPEG2x, JPEG
            263:i2c_data<=24'h471303;// JPEG mode 3
            264:i2c_data<=24'h440704;// Quantization scale 
            265:i2c_data<=24'h460b35;//f9
            266:i2c_data<=24'h460c22;
            267:i2c_data<=24'h483722; // DVP CLK divider
            268:i2c_data<=24'h382401; // DVP CLK divider 
            269:i2c_data<=24'h5001a3; // SDE on, scale on, UV average off, color matrix on, AWB on
            270:i2c_data<=24'h350300; // AEC/AGC on 	 
            271:i2c_data<=24'h503d00;

*/
            default: ;
        endcase
    end
end         

          
  endmodule
