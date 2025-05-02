`timescale 1ns / 1ps
module i2c_dri#(
    parameter   CLK_FREQ   = 26'd50_000_000,
    parameter   I2C_FREQ   = 18'd250_000
  )
  (
    input                               clk                        ,
    input                               rst_n                      ,

   (*mark_debug ="true"*)input                               i2c_exec                   ,
   (*mark_debug ="true"*)input                               bit_ctrl                   ,
   (*mark_debug ="true"*)input                               i2c_rh_wl                  ,
   (*mark_debug ="true"*)input              [  15:0]         i2c_addr                   ,
   (*mark_debug ="true"*)input              [   7:0]         i2c_data_wr                ,

                         input               [6:0]           slave_addr                 ,

   (*mark_debug ="true"*)inout                               scl                        ,
   (*mark_debug ="true"*)inout                               sda                        ,
   (*mark_debug ="true"*)output reg                          i2c_done                   ,
   (*mark_debug ="true"*)output reg                          i2c_ack                    ,
   (*mark_debug ="true"*)output reg         [   7:0]         i2c_data_r                 ,
   (*mark_debug ="true"*)output reg                          i2c_clk                    ,
   (*mark_debug ="true"*)output reg         [7:0]            cur_state                ,
                         output reg                          error_wait_flag       


  );


  reg [6:0] slave_addr_r;

  //状态机
  localparam  [8:0]  idle        = 9'b00000_0001;
  localparam  [8:0]  sladdr      = 9'b00000_0010;
  localparam  [8:0]  addr16      = 9'b00000_0100;
  localparam  [8:0]  addr8       = 9'b00000_1000;
  localparam  [8:0]  data_wr     = 9'b00001_0000;
  localparam  [8:0]  addr_rd     = 9'b00010_0000;
  localparam  [8:0]  data_rd     = 9'b00100_0000;
  localparam  [8:0]  stop        = 9'b01000_0000;
// localparam  [7:0]  wait_strech    = 9'b10000_0000;


  //三态门
  (*mark_debug ="true"*)reg  sda_out ;
  (*mark_debug ="true"*)reg  scl_out ;
  (*mark_debug ="true"*)reg  sda_dir ;
  (*mark_debug ="true"*)reg  scl_dir ;
  (*mark_debug ="true"*)wire sda_in  ;
  (*mark_debug ="true"*)wire scl_in  ;
  assign sda = sda_dir ? sda_out : 1'bz;
  assign scl = scl_dir ? scl_out : 1'bz;
  assign sda_in = sda;
  assign scl_in = scl;

  //i2c分频
  reg [9:0] clk_cnt;
  wire [15:0] clk_divide;
  assign clk_divide = (CLK_FREQ/I2C_FREQ);

  always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      clk_cnt <= 0;
      i2c_clk <= 0;
    end
    else if (clk_cnt == clk_divide[8:1] - 1)
    begin
      clk_cnt <= 0;
      i2c_clk <= ~i2c_clk;
    end
    else
      clk_cnt <= clk_cnt + 1;
  end

  //状态机第一段
  (*mark_debug ="true"*)reg [7:0] next_state;
 
  reg st_done;
  (*mark_debug ="true"*)reg wr_flag;
  (*mark_debug ="true"*)reg [6:0] cnt ;
  reg [6:0]  error_wait_cnt;

  reg [15:0] addr_t;
  reg [7:0] data_wr_t;
  (*mark_debug ="true"*)reg [7:0] data_r;


  always @(posedge i2c_clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      cur_state <= idle;
    end
    else
      cur_state <= next_state;
  end

  //状态机第二段
  always @(*)
  begin
    next_state = idle;
    case (cur_state)
      idle:
      begin
        if (i2c_exec)
        begin
          next_state = sladdr;
        end
        else
        begin
          next_state = idle;
        end
      end
      sladdr:
      begin
        if (st_done)
        begin
          if (bit_ctrl == 1)
            next_state = addr16;
          else 
            next_state = addr8;
        end
        else if (error_wait_flag) begin
          next_state = stop;
        end
        else
          next_state = sladdr;
      end
      addr16:
      begin
        if (st_done)
        begin
          next_state = addr8;
        end
        else if (error_wait_flag) begin
          next_state = stop;
        end
        else
          next_state = addr16;
      end
      addr8:
      begin
        if (st_done)
        begin
          if (wr_flag == 0)
          begin
            next_state = data_wr;
          end
          else
            next_state = addr_rd;
        end
        else if (error_wait_flag) begin
          next_state = stop;
        end
        else
          next_state = addr8;
      end
      data_wr:
      begin
        if (st_done)
        begin
          next_state = stop;
        end
        else if (error_wait_flag) begin
          next_state = stop;
        end
        else
          next_state = data_wr;
      end
      addr_rd:
      begin
        if (st_done)
        begin
          next_state = data_rd;
        end
        else if (error_wait_flag) begin
          next_state = stop;
        end
        else
          next_state = addr_rd;
      end
      data_rd:
      begin
        if (st_done)
        begin
          next_state = stop;
        end
        else
          next_state = data_rd;
      end
      stop:
      begin
        if (st_done)
        begin
          next_state = idle;
        end
        else
          next_state = stop;
      end
      default:
        next_state = idle;
    endcase
  end

  //状态机第三段
  always @(posedge i2c_clk or negedge rst_n)
  begin
    if (!rst_n)
    begin
      scl_dir <= 0;
      scl_out <= 1;
      sda_out <= 1;
      sda_dir <= 0;
      i2c_done <= 0;
      st_done <= 0;
      cnt     <= 0;
      i2c_ack <= 0;
      addr_t  <= 0;
      error_wait_flag <= 0;
      error_wait_cnt  <= 0;
      slave_addr_r    <= 0;
    end
    else
    begin
      st_done <= 0;
      error_wait_flag <= 0;
      cnt <= cnt + 1;
      i2c_ack <= 0;
      case (cur_state)
        idle:
        begin
          scl_dir <= 1;
          scl_out <= 1;
          sda_out <= 1;
          sda_dir <= 1;
          i2c_done <= 0;
          cnt      <= 0;
          if (i2c_exec)
          begin
            wr_flag <= i2c_rh_wl;
            addr_t  <= i2c_addr ;
            data_wr_t <= i2c_data_wr ;
            i2c_ack  <= 0;
            slave_addr_r <= slave_addr ;
          end
        end
        sladdr:
        begin
          case (cnt)
            1:
              sda_out <= 0;
            3:
              scl_out     <= 0;
            4:
              sda_out <= slave_addr_r[6];
            5:
              scl_out     <= 1;
            7:
              scl_out     <= 0;
            8:
              sda_out <= slave_addr_r[5];
            9:
              scl_out     <= 1;
            11:
              scl_out    <= 0;
            12:
              sda_out <= slave_addr_r[4];
            13:
              scl_out     <= 1;
            15:
              scl_out     <= 0;
            16:
              sda_out <= slave_addr_r[3];
            17:
              scl_out     <= 1;
            19:
              scl_out     <= 0;
            20:
              sda_out <= slave_addr_r[2];
            21:
              scl_out    <= 1;
            23:
              scl_out    <= 0;
            24:
              sda_out <= slave_addr_r[1];
            25:
              scl_out    <= 1;
            27:
              scl_out    <= 0;
            28:
              sda_out <= slave_addr_r[0];
            29:
              scl_out    <= 1;
            31:
              scl_out    <= 0;
            32:
              sda_out <= 0;//读写位
            33:
              scl_out   <= 1 ;
            35:
              scl_out   <= 0 ;
            36:
            begin
              sda_dir <= 0;
              sda_out <= 1;

              
              
            end
            37:begin 
              scl_dir <= 0;
              scl_out <= 1;
              if (scl_in == 'd0) begin
                cnt <= 'd37 ;
                error_wait_cnt <= error_wait_cnt + 1;
                if (error_wait_cnt == 'd20) begin
                  error_wait_flag <= 1;
                  cnt  <= 0;
                end
              end
              else begin
                error_wait_cnt <= 0;
              end

            end
            38:
            begin
              st_done <= 1;
              scl_dir <= 1;
              if (sda_in == 0)
              begin
                i2c_ack <= 1;
              end
            end
            39:
            begin
              scl_out <= 0;
              cnt <= 0;
            end
            default:  ;
          endcase
        end
        addr16 :
        begin
          case (cnt)
            0:
            begin
              sda_dir <= 1;
              sda_out <= addr_t[15];
            end
            1:
              scl_out <= 1;
            3:
              scl_out <= 0;
            4:
              sda_out <= addr_t[14];
            5:
              scl_out <= 1;
            7:
              scl_out <= 0;
            8:
              sda_out <= addr_t[13];
            9:
              scl_out <= 1;
            11:
              scl_out <= 0;
            12:
              sda_out <= addr_t[12];
            13:
              scl_out <= 1;
            15:
              scl_out <= 0;
            16:
              sda_out <= addr_t[11];
            17:
              scl_out <= 1;
            19:
              scl_out <= 0;
            20:
              sda_out <= addr_t[10];
            21:
              scl_out <= 1;
            23:
              scl_out <= 0;
            24:
              sda_out <= addr_t[9];
            25:
              scl_out <= 1;
            27:
              scl_out <= 0;
            28:
              sda_out <= addr_t[8];
            29:
              scl_out <= 1;
            31:
              scl_out <= 0;
            32:
            begin
              sda_dir <= 0;
              
              sda_out <= 1;
            end
            33:begin
              scl_out <= 1;
              scl_dir <= 0;
            if (scl_in == 'd0) begin
              cnt <= 'd33 ;
              error_wait_cnt <= error_wait_cnt + 1;
            end
            else if (error_wait_cnt == 'd20) begin
              error_wait_flag <= 1;
            end
            end
            34:
            begin
              st_done <= 1;
              scl_dir <= 1;
              if (sda_in == 0)
              begin
                i2c_ack <= 1;
              end
            end
            35:
            begin
              scl_out <= 0;
              cnt <= 0;
            end
            default:
              ;
          endcase
        end
        addr8  :
        begin
          case (cnt)
            0:
            begin
              sda_dir <= 1;
              sda_out <= addr_t[7];
            end
            1:
              scl_out <= 1;
            3:
              scl_out <= 0;
            4:
              sda_out <= addr_t[6];
            5:
              scl_out <= 1;
            7:
              scl_out <= 0;
            8:
              sda_out <= addr_t[5];
            9:
              scl_out <= 1;
            11:
              scl_out <= 0;
            12:
              sda_out <= addr_t[4];
            13:
              scl_out <= 1;
            15:
              scl_out <= 0;
            16:
              sda_out <= addr_t[3];
            17:
              scl_out <= 1;
            19:
              scl_out <= 0;
            20:
              sda_out <= addr_t[2];
            21:
              scl_out <= 1;
            23:
              scl_out <= 0;
            24:
              sda_out <= addr_t[1];
            25:
              scl_out <= 1;
            27:
              scl_out <= 0;
            28:
              sda_out <= addr_t[0];
            29:
              scl_out <= 1;
            31:
              scl_out <= 0;
            32:
            begin
              sda_dir <= 0;
              
              sda_out <= 0;

            end
            33:begin
              scl_out <= 1;
              scl_dir <= 0;
            if (scl_in == 'd0) begin
              cnt <= 'd33 ;
              error_wait_cnt <= error_wait_cnt + 1;
            end
            else if (error_wait_cnt == 'd20) begin
              error_wait_flag <= 1;
            end
            end
            34:
            begin
              st_done <= 1;
              scl_dir <= 1;
              if (sda_in == 0)
              begin
                i2c_ack <= 1;
              end
            end
            35:
            begin
              scl_out <= 0;
              cnt <= 0;
            end
            default:
              ;
          endcase
        end
        data_wr:
        begin
          case (cnt)
            0:
            begin
              sda_dir <= 1;
              sda_out <= data_wr_t[7];
            end
            1:
              scl_out <= 1;
            3:
              scl_out <= 0;
            4:
              sda_out <= data_wr_t[6];
            5:
              scl_out <= 1;
            7:
              scl_out <= 0;
            8:
              sda_out <= data_wr_t[5];
            9:
              scl_out <= 1;
            11:
              scl_out <= 0;
            12:
              sda_out <= data_wr_t[4];
            13:
              scl_out <= 1;
            15:
              scl_out <= 0;
            16:
              sda_out <= data_wr_t[3];
            17:
              scl_out <= 1;
            19:
              scl_out <= 0;
            20:
              sda_out <= data_wr_t[2];
            21:
              scl_out <= 1;
            23:
              scl_out <= 0;
            24:
              sda_out <= data_wr_t[1];
            25:
              scl_out <= 1;
            27:
              scl_out <= 0;
            28:
              sda_out <= data_wr_t[0];
            29:
              scl_out <= 1;
            31:
              scl_out <= 0;
            32:
            begin
              sda_dir <= 0;
              
              sda_out <= 1;
            end
            33:begin
              scl_dir <= 0;
              scl_out <= 1;
            if (scl_in == 'd0) begin
              cnt <= 'd33;
              error_wait_cnt <= error_wait_cnt + 1;
            end
            else if (error_wait_cnt == 'd20) begin
              error_wait_flag <= 1;
            end
            end
            34:
            begin
              st_done <= 1;
              scl_dir <= 1;
              if (sda_in == 0)
              begin
                i2c_ack <= 1;
              end
            end
            35:
            begin
              scl_out <= 0;
              cnt <= 0;
            end
            default:
              ;
          endcase
        end
        addr_rd:
        begin
          case (cnt)
            0:
            begin
              sda_dir <= 1;
              sda_out <= 0;
            end
            1:
            scl_out <= 1;
            2:
              sda_out <= 1;
            14:
              sda_out <= 0;
            15:
            scl_out <= 0;
            16:
              sda_out <= slave_addr_r[6];
            17:
            scl_out <= 1;
            19:
            scl_out <= 0;
            20:
              sda_out <= slave_addr_r[5];
            21:
            scl_out <= 1;
            23:
            scl_out <= 0;
            24:
              sda_out <= slave_addr_r[4];
            25:
            scl_out <= 1;
            27:
            scl_out <= 0;
            28:
              sda_out <= slave_addr_r[3];
            29:
            scl_out <= 1;
            31:
            scl_out <= 0;
            32:
              sda_out <= slave_addr_r[2];
            33:
            scl_out <= 1;
            35:
            scl_out <= 0;
            36:
              sda_out <= slave_addr_r[1];
            37:
            scl_out <= 1;
            39:
            scl_out <= 0;
            40:
              sda_out <= slave_addr_r[0];
            41:
            scl_out <= 1;
            43:
            scl_out <= 0;
            44:
              sda_out <= 1;//读
            45:
            scl_out <= 1;
            47:
            scl_out <= 0;
            48:
            begin
                sda_dir <= 0;
                
                sda_out <= 1;
            end
            49:begin
              scl_dir <= 0;
              scl_out <= 1;
            if (scl_in == 0) begin
              cnt <= 'd49;
              error_wait_cnt <= error_wait_cnt + 1;
            end
            else if (error_wait_cnt == 'd20) begin
              error_wait_flag <= 1;
            end
            end
            50:
            begin
              st_done <= 1;
              scl_dir <= 1;
              if (sda_in == 0)
              begin
                i2c_ack <= 1;
              end
            end
            51:
            begin
              scl_out <= 0;
              cnt <= 0;
            end
            default:;
            endcase
        end
        data_rd:begin
            case (cnt)
            0:
              sda_dir <= 0;
              //sda_dir   <= 1;//test
            1:begin
              scl_out <= 1;
                data_r[7] <= sda_in;
                //data_r[7] <= 1;//test
            end
            3:
              scl_out <= 0;
            5:
            begin
              scl_out <= 1;
                data_r[6] <= sda_in;
                //data_r[6] <= 1;//test
            end
            7:
              scl_out <= 0;
            9:
            begin
              scl_out <= 1;
                data_r[5] <= sda_in;
                //data_r[5] <= 0;//test
            end
            11:
              scl_out <= 0;
            13:
            begin
              scl_out <= 1;
                data_r[4] <= sda_in;
                //data_r[4] <= 0;//test
            end
            15:
              scl_out <= 0;
            17:
            begin
              scl_out <= 1;
                data_r[3] <= sda_in;
                //data_r[3] <= 1;//test
            end
            19:
              scl_out <= 0;
            21:
            begin
              scl_out <= 1;
                data_r[2] <= sda_in;
                //data_r[2] <= 1;//test
            end
            23:
              scl_out <= 0;
            25:
            begin
              scl_out <= 1;
                data_r[1] <= sda_in;
                //data_r[1] <= 0;//test
            end
            27:
                scl_out <= 0;
            29:
            begin
                scl_out <= 1;
                data_r[0] <= sda_in;
                //data_r[0] <= 0;//test
            end
            31:
              scl_out <= 0;
            32:
            begin
              sda_dir <= 1;
              sda_out <= 1;
            end
            33:
              scl_out <= 1;
            34:
              st_done <= 1;
            35:
            begin
              scl_out <= 0;
              cnt <= 0;
              i2c_data_r <= data_r;
            end
            default: ;
            endcase
        end
          stop:begin
            case (cnt)
                0:begin
                    sda_dir <= 1;
                    sda_out <= 0;
                end 
                1:scl_dir <= 0;
                3:sda_dir <= 0;
                15:st_done <= 1;
                16:begin
                    cnt <= 0;
                    i2c_done <= 1;
                end
                default: ;
            endcase
          end
            default:;
        endcase
    end

  end
endmodule

