
`timescale 1 ns / 1 ps

	module read_full_outstanding_v1_0_M00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h20000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 2,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Users to add ports here
        (*mark_debug ="true"*)output reg data_valid,//��дfifo��д����
        input ddr_wr_bank,//����ַ
       (*mark_debug ="true"*) output reg rd_over,
       input wr_over,
      // (*mark_debug ="true"*) output reg rd_over,
        input stop_wr,
       (*mark_debug ="true"*)input frame_complete,
       (*mark_debug ="true"*)output reg [31:0]hdmi_data,//д��ȥ������
        (*mark_debug ="true"*)input rd_start,
        input change_complete,
        (*mark_debug ="true"*)output  reg last_data,
       (*mark_debug ="true"*) input [8:0]angle_test,//_test,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		(*mark_debug ="true"*)output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output wire  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		(*mark_debug ="true"*)input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		 (*mark_debug ="true"*)input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output wire  M_AXI_RREADY
	);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	 localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
    wire [31:0]  TARGET_SLAVE_BASE_ADDR	=(ddr_wr_bank == 0)? 32'h20000000:32'h30000000;//����a,b������ѡ����ʼ��ַ
	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	 localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	 localparam integer C_NO_BURSTS_REQ =C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.
	parameter [1:0] IDLE = 2'b00, // This state initiates AXI4Lite transaction 
            // after the state machine changes state to INIT_WRITE   
            // when there is 0 to 1 transition on INIT_AXI_TXN
            // changes state to INIT_READ 
        INIT_READ = 2'b01, // This state initializes read transaction
            // once reads are done, the state machine 
            // changes state to INIT_COMPARE 
        INIT_CHCEK = 2'b10, // This state issues the status of comparison 
            // of the written data with the read data    
        NEED_RD=2'b11;

	 reg [1:0] mst_exec_state;

	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	 (*mark_debug ="true"*)reg  	axi_arvalid;
	 (*mark_debug ="true"*)reg  	axi_rready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	//read beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	read_index;
	//size of C_M_AXI_BURST_LEN length burst in bytes
	wire [C_TRANSACTIONS_NUM+2 : 0] 	burst_size_bytes;
	//The burst counters are used to track the number of burst transfers of C_M_AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
	reg [C_NO_BURSTS_REQ : 0] 	write_burst_counter;
	reg [C_NO_BURSTS_REQ : 0] 	read_burst_counter;
	reg  	start_single_burst_write;
	reg  	start_single_burst_read;
	reg  	writes_done;
	reg  	reads_done;
	reg  	error_reg;
	reg  	compare_done;
	reg  	burst_write_active;
	reg  	burst_read_active;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
   (*mark_debug ="true"*)reg     rd_ddr_rotate;
     (*mark_debug ="true"*)reg signed [10:0]  h_cnt,v_cnt;
     (*mark_debug ="true"*)wire signed [10:0]  x_cnt,y_cnt;
     (*mark_debug ="true"*)wire signed [10:0]  x_out,y_out;
     wire [22:0] rd_addr;
     (*mark_debug ="true"*)reg axis_change;
     (*mark_debug ="true"*)wire [23:0] axis_vaild;
     (*mark_debug ="true"*)wire [23:0] addr_din;
     reg wr_fifo;
     (*mark_debug ="true"*)wire [8:0] wr_data_count;
     (*mark_debug ="true"*)reg hdmi_rd_en;
     (*mark_debug ="true"*)wire axis_right;
     (*mark_debug ="true"*)reg one_frame;
     reg [9:0] delay;
     (*mark_debug ="true"*)reg reset_delay;
 //(*mark_debug ="true"*)reg rd_over;
     (*mark_debug ="true"*)wire wr_fifo_valid;
     (*mark_debug ="true"*)reg [8:0] angle;
     (*mark_debug ="true"*)reg [11:0] angle_in;
     reg angle_access;
     reg  wr_ddr_valid_you;   
     reg first_frame;
     reg rd_init_done;
    // (*mark_debug ="true"*)reg [23:0] numofread;
     //(*mark_debug ="true"*)reg [23:0] numofwrfifo;
    // (*mark_debug ="true"*)reg data_right;
     (*mark_debug ="true"*)wire [23:0]data_test;
     reg ddr_wr_bank1;
     reg reset_to_zero;
     (*mark_debug ="true"*)reg [23:0] processing_time;
     (*mark_debug ="true"*)reg [23:0] erreo_test;
    reg send_stop;

	//I/O Connections. Write Address (AW)
         assign M_AXI_AWID    = 'b0;
         //The AXI address is a concatenation of the target base address + active offset range
         assign M_AXI_AWADDR    = C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
         //Burst LENgth is number of transaction beats, minus 1
         assign M_AXI_AWLEN    = C_M_AXI_BURST_LEN - 1;
         //Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
         assign M_AXI_AWSIZE    = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
         //INCR burst type is usually used, except for keyhole bursts
         assign M_AXI_AWBURST    = 2'b01;
         assign M_AXI_AWLOCK    = 1'b0;
         //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
         assign M_AXI_AWCACHE    = 4'b0011;
         assign M_AXI_AWPROT    = 3'h0;
         assign M_AXI_AWQOS    = 4'h0;
         assign M_AXI_AWUSER    = 'b1;
         assign M_AXI_AWVALID    = axi_awvalid;
         //Write Data(W)
         assign M_AXI_WDATA    = axi_wdata;
         //All bursts are complete and aligned in this example
         assign M_AXI_WSTRB    = {(C_M_AXI_DATA_WIDTH/8){1'b1}};
         assign M_AXI_WLAST    = axi_wlast;
         assign M_AXI_WUSER    = 'b0;
         assign M_AXI_WVALID    = axi_wvalid;
         //Write Response (B)
         assign M_AXI_BREADY    = axi_bready;
         //Read Address (AR)
         assign M_AXI_ARID    = 'b0;
         assign M_AXI_ARADDR    = TARGET_SLAVE_BASE_ADDR + axi_araddr;
         //Burst LENgth is number of transaction beats, minus 1
         assign M_AXI_ARLEN    = C_M_AXI_BURST_LEN - 1;
         //Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
         assign M_AXI_ARSIZE    = clogb2((C_M_AXI_DATA_WIDTH/8)-1);
         //INCR burst type is usually used, except for keyhole bursts
         assign M_AXI_ARBURST    = 2'b01;
         assign M_AXI_ARLOCK    = 1'b0;
         //Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
         assign M_AXI_ARCACHE    = 4'b0010;
         assign M_AXI_ARPROT    = 3'h0;
         assign M_AXI_ARQOS    = 4'h0;
         assign M_AXI_ARUSER    = 'b1;
         assign M_AXI_ARVALID    = axi_arvalid;
         //Read and Read Response (R)
         assign M_AXI_RREADY    = axi_rready;
         //Example design I/O
         assign rd_addr=(x_out+y_out*640)*4;//(h_cnt+v_cnt*640)*4;
         assign data_test=(h_cnt+v_cnt*640);//(h_cnt+v_cnt*640)*4;
         assign addr_din= axis_right ? rd_addr-rd_addr[2]*4 : 24'h7ff_fff;
         assign x_cnt=h_cnt-320;
         assign y_cnt=v_cnt-240;
         //Burst size in bytes
         assign burst_size_bytes    = C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
     
     
         //----------------------------
         //Read Address Channel
         //----------------------------
     
         //The Read Address Channel (AW) provides a similar function to the
         //Write Address channel- to provide the tranfer qualifiers for the burst.
     
         //In this example, the read address increments in the same
         //manner as the write address channel.
     
           always @(posedge M_AXI_ACLK)                                 
           begin                                                              
                                                                              
             if (M_AXI_ARESETN == 0  )                                         
               begin                                                          
                 axi_arvalid <= 1'b0;                                         
               end                                                            
             // If previously not valid , start next transaction              
             else if (~axi_arvalid && mst_exec_state == INIT_READ && M_AXI_ARREADY)//start_single_burst_read)                
               begin                                                          
                 axi_arvalid <= 1'b1;                                         
               end                                                            
             else if (M_AXI_ARREADY && axi_arvalid)                           
               begin                                                          
                 axi_arvalid <= 1'b0;                                         
               end                                                            
             else                                                             
               axi_arvalid <= axi_arvalid;                                    
           end                                                                
                                                                              
                                                                              
           always @(posedge M_AXI_ACLK)                                  
               begin                                                     
                 if (M_AXI_ARESETN == 0||change_complete)                                
                   begin                                                 
                     axi_araddr <= 0;                                    
                   end                                                   
                   // Signals a new write address/ write data is         
                   // available by user logic                            
                 else if (M_AXI_ARREADY && axi_arvalid)                  
                   begin                                                 
                     axi_araddr <= axis_vaild[22:0];//axis_vaild[22:0];//axi_araddr + 32'h00000004;            
                   end                                                   
               end                                                              
     
     
         //--------------------------------
         //Read Data (and Response) Channel
         //--------------------------------
     
          // Forward movement occurs when the channel is valid and ready   
           assign rnext = M_AXI_RVALID && axi_rready;                            
                                                                                 
                                                                                 
         // Burst length counter. Uses extra counter register bit to indicate    
         // terminal count to reduce decode logic                                
           always @(posedge M_AXI_ACLK)                                          
           begin                                                                 
             if (M_AXI_ARESETN == 0 || start_single_burst_read)                  
               begin                                                             
                 read_index <= 0;                                                
               end                                                               
             else if (rnext && (read_index != C_M_AXI_BURST_LEN-1))              
               begin                                                             
                 read_index <= read_index + 1;                                   
               end 
              else if(mst_exec_state!=INIT_READ) 
                   read_index <= 1'b0;                                                                       
             else                                                                
               read_index <= read_index;                                         
           end                                                                   
                                                                                 
                                                                                 
         /*                                                                      
          The Read Data channel returns the results of the read request          
                                                                                 
          In this example the data checker is always able to accept              
          more data, so no need to throttle the RREADY signal                    
          */                                                                     
           always @(posedge M_AXI_ACLK)                                          
           begin                                                                 
             if (M_AXI_ARESETN == 0 )                  
               begin                                                             
                 axi_rready <= 1'b0;                                             
               end                                                               
             // accept/acknowledge rdata/rresp with axi_rready by the master     
             // when M_AXI_RVALID is asserted by slave                           
             else if (M_AXI_RVALID)                       
               begin                                      
                  if (M_AXI_RLAST && axi_rready)          
                   begin                                  
                     axi_rready <= 1'b0;                  
                   end                                    
                  else                                    
                    begin                                 
                      axi_rready <= 1'b1;                 
                    end                                   
               end                                        
             // retain the previous value                 
           end                                            
                                                                                                                                              
                                                                                 
         //Flag any read response errors                                         
           assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];                                                                                                   
     
                                                                                                          
          // read_burst_counter counter keeps track with the number of burst transaction initiated                   
          // against the number of burst transactions the master needs to initiate                                   
           always @(posedge M_AXI_ACLK)                                                                              
           begin                                                                                                     
             if (M_AXI_ARESETN == 0 || mst_exec_state!=INIT_READ)                                                                                 
               begin                                                                                                 
                 read_burst_counter <= 'b0;                                                                          
               end                                                                                                   
             else if (M_AXI_ARREADY && axi_arvalid)                                                                  
               begin                                                                                                 
                 if (read_burst_counter[C_NO_BURSTS_REQ] == 1'b0)                                                    
                   begin                                                                                             
                     read_burst_counter <= read_burst_counter + 1'b1;                                                
                     //read_burst_counter[C_NO_BURSTS_REQ] <= 1'b1;                                                  
                   end                                                                                               
               end                                                                                                   
             else                                                                                                    
               read_burst_counter <= read_burst_counter;                                                             
           end                                                                                                       
                                                                                                                     
                                                                                                                     
           //implement master command interface state machine                                                        
          always @ ( posedge M_AXI_ACLK)                                                    
                begin                                                                             
                  if (M_AXI_ARESETN == 1'b0)                                                     
                    begin                                                                         
                    // reset condition                                                            
                    // All the signals are assigned default values under reset condition          
                      mst_exec_state  <= IDLE;                                                                                              
                      start_single_burst_read  <= 1'b0;                                                 
                 //     read_issued   <= 1'b0; 
                       wr_ddr_valid_you<=1'b0;
                       hdmi_rd_en<=0;                                                        
                    end                                                                           
                  else                                                                            
                    begin                                                                         
                     // state transition                                                          
                      case (mst_exec_state)                                                       
                                                                                                  
                        IDLE:                                                             
                        // This state is responsible to initiate 
                        // AXI transaction when init_txn_pulse is asserted 
                               mst_exec_state  <= INIT_CHCEK;                                                                                                                                  
                        INIT_READ:                                                                
                          // This state is responsible to issue start_single_read pulse to        
                          // initiate a read transaction. Read transactions will be               
                          // issued until last_read signal is asserted.                           
                           // read controller                                                     
                           if (reads_done)                                                        
                             begin                                                                
                               mst_exec_state <= INIT_CHCEK;                                    
                             end                                                                  
                           else                                                                   
                             begin                                                                
                               mst_exec_state  <= INIT_READ;                                      
                                                                                                  
                               if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read)
                                 begin                                                            
                                   start_single_burst_read <= 1'b1;                                     
                                 //  read_issued  <= 1'b1;                                          
                                 end                                                              
                                                                 
                               else                                                               
                                 begin                                                            
                                   start_single_burst_read <= 1'b0; //Negate to generate a pulse        
                                 end                                                              
                             end                                                                  
                                                                                                  
                         INIT_CHCEK:                                                            
                           begin
                               // This state is responsible to issue the state of comparison          
                               // of written data with the read data. If no error flags are set,      
                               // compare_done signal will be asseted to indicate success.            
                               wr_ddr_valid_you<=1'b0;
                               if(rd_ddr_rotate)
                               begin
                                  mst_exec_state  <= NEED_RD; 
                                  hdmi_rd_en<=1;
                               end
                               else
                                  mst_exec_state  <= INIT_CHCEK;                                                 
                           end
                        NEED_RD:
                              begin
                               //   if(axis_vaild[23])
                                  begin
                                      mst_exec_state  <= INIT_READ; 
                                      hdmi_rd_en<=0;
                                  end
                              //   else
                             //    begin
                             //        mst_exec_state  <= INIT_CHCEK;
                              //       wr_ddr_valid_you<=1;
                              //       hdmi_rd_en<=0;
                             //     end
                              end                                                                   
                         default :                                                                
                           begin                                                                  
                             mst_exec_state  <= IDLE;                                     
                           end                                                                    
                      endcase                                                                     
                  end                                                                             
                end //MASTER_EXECUTION_PROC                                                                              
                                                                                                                     
                                                                                                      
                                                                                                                     
                                                                                                     
                                                                                                                     
           // burst_read_active signal is asserted when there is a burst write transaction                           
           // is initiated by the assertion of start_single_burst_write. start_single_burst_read                     
           // signal remains asserted until the burst read is accepted by the master                                 
           always @(posedge M_AXI_ACLK)                                                                              
           begin                                                                                                     
             if (M_AXI_ARESETN == 0 )                                                                                 
               burst_read_active <= 1'b0;                                                                            
                                                                                                                     
             //The burst_write_active is asserted when a write burst transaction is initiated                        
             else if (start_single_burst_read)                                                                       
               burst_read_active <= 1'b1;                                                                            
             else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)                                                     
               burst_read_active <= 0;                                                                               
             end                                                                                                     
                                                                                                                     
                                                                                                                     
          // Check for last read completion.                                                                         
                                                                                                                     
          // This logic is to qualify the last read count with the final read                                        
          // response. This demonstrates how to confirm that a read has been                                         
          // committed.                                                                                              
                                                                                                                     
           always @(posedge M_AXI_ACLK)                                                                              
           begin                                                                                                     
             if (M_AXI_ARESETN == 0 )                                                                                 
               reads_done <= 1'b0;                                                                                   
                                                                                                                     
             //The reads_done should be associated with a rready response                                            
             //else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
             else if (M_AXI_RVALID && axi_rready && (read_index == C_M_AXI_BURST_LEN-1) && (read_burst_counter[C_NO_BURSTS_REQ]))
               reads_done <= 1'b1;          
             else if(mst_exec_state!=INIT_READ) 
                       reads_done <= 1'b0;                                                                               
             else                                                                                                    
               reads_done <= reads_done;                                                                             
             end                                                                                                     
     
         always@(posedge M_AXI_ACLK )
            begin
                if(!M_AXI_ARESETN||frame_complete==0)//rd_start)//(frame_complete==0&&  )
                    rd_over<=0;
                else if(wr_data_count==0)//(v_cnt == 479&&h_cnt == 639)//horizontal counter maximum value
                    rd_over<=1;
            end
            /*
            always@(posedge M_AXI_ACLK )
            begin
                if(!M_AXI_ARESETN)//rd_start)//(frame_complete==0&&  )
                    data_right<=0;
                else if(numofwrfifo==data_test)//(v_cnt == 479&&h_cnt == 639)//horizontal counter maximum value
                    data_right<=1;
                else
                    data_right<=0; 
            end
            */
            always@(posedge M_AXI_ACLK )
            begin
                if(!M_AXI_ARESETN||rd_over==0)//rd_start)//(frame_complete==0&&  )
                    last_data<=0;
                else if(rd_over)//(v_cnt == 479&&h_cnt == 639)//horizontal counter maximum value
                    last_data<=1;//1;
            end
            
         always @(posedge M_AXI_ACLK)                                                      
           begin                                                                             
             if (M_AXI_ARESETN == 0 )                                                         
               rd_ddr_rotate <= 1'b0;                                                          
             else if(rd_over||stop_wr)
               rd_ddr_rotate <= 1'b0;                                                                                   
               //The writes_done should be associated with a bready response                 
             else if (rd_start&&rd_init_done)//&&data_right)    //clear_ok)//&&axis_vaild)                              
               rd_ddr_rotate <= 1'b1;                                                          
     
             else                                                                    
               rd_ddr_rotate <= rd_ddr_rotate;//rd_ddr_rotate;                                                   
           end
       wr_ddr_fifo ddr2hdmi//��ddr��ȡ
                               (
                                   .srst(~M_AXI_ARESETN),//||change_complete),//change_complete5.18
                                   .clk(M_AXI_ACLK),
                                  // .wr_clk(M_AXI_ACLK),
                                  // .rd_clk(M_AXI_ACLK),
                                  // .wr_data_count(wr_data_count),
                                     .data_count(wr_data_count),
                                   .wr_en(wr_fifo_valid),//(axis_change),//axis_right(��������ת������Ҫ�ӳ��ĸ���)
                                   .rd_en(axi_arvalid),//(start_single_burst_read),//(hdmi_rd_en),//hdmi_rd_en
                                   .din(addr_din),
                                   .dout(axis_vaild),
                                   .full(),
                                   .empty()
                               );      
           cordic cordic_test_inst
           (
               .clk(M_AXI_ACLK),
               .rst_n(M_AXI_ARESETN),
               .x_in(x_cnt),
               .y_in(y_cnt),
               .angle(angle_in),
               .axis_change(axis_change),
               .x_output(x_out),
               .y_output(y_out),
               .wr_fifo_valid(wr_fifo_valid),
               .axis_right(axis_right)
           );
           /*
             always @(posedge M_AXI_ACLK)                                                      
            begin                                                                             
            if (M_AXI_ARESETN == 0)                                                         
                numofwrfifo <= 1'b0;
              
            else if(axis_change)//&&rd_load_flag)&&vs
                numofwrfifo <= numofwrfifo+1'b1;
            else if(change_complete)
                numofwrfifo<=0;
            else
                numofwrfifo <= numofwrfifo;
                
            // User logic ends
            end  */     
              always@(posedge M_AXI_ACLK )
                begin
                    if(!M_AXI_ARESETN)//||change_complete)//change_complete 5.18
                    begin
                        angle_access<=0;
                         rd_init_done<=0;
                    end
                    else 
                    begin
                      if(delay==600)
                        begin
                            angle_access<=1;
                        end
                      else if(delay==700)
                      begin
                             rd_init_done<=1;
                      end
                        delay<=delay+1;
                    end
                 //   else if(bank_change)//axis_changeһ�ζ�֮ǰ�仯һ�Ρ���ѡ��״̬�����һ��״̬���ڶ��źű仯ͬʱ�仯���ټ�һ���źű�֤һ�ζ�ֻ��һ��
                     //   wr_over<=0;
                end 
              always@(posedge M_AXI_ACLK )
              begin
                  if(!M_AXI_ARESETN||change_complete)//frame_complete==0)//10.17//change_complete)//||frame_complete==0)
                      one_frame<=1;
                  else if(v_cnt == 479&&h_cnt == 639)//0613  639//639)//640)//horizontal counter maximum value
                      one_frame<=0;
               //   else if(bank_change)//axis_changeһ�ζ�֮ǰ�仯һ�Ρ���ѡ��״̬�����һ��״̬���ڶ��źű仯ͬʱ�仯���ټ�һ���źű�֤һ�ζ�ֻ��һ��
                   //   wr_over<=0;
              end
           
             always @(posedge M_AXI_ACLK)                                                      
              begin                                                                             
              if (M_AXI_ARESETN == 0)                                                         
                  wr_fifo <= 1'b0;
                
              else if(wr_data_count <= 182)//&&rd_load_flag)&&vs
                  wr_fifo <= 1'b1;
              else
                  wr_fifo <= 1'b0;
              // User logic ends
              end 
              
             always@(posedge M_AXI_ACLK )
            begin
            if(!M_AXI_ARESETN)//10.17||(v_cnt == 479&&h_cnt == 639))
                axis_change <= 12'd0;
            else if(wr_fifo&&one_frame&&angle_access)//reset_delay)//need_clear==0&&//&wr_over==0//(mst_exec_state  <= ADDR_CHANGE)//( M_AXI_ARREADY && axi_arvalid)//horizontal counter maximum value
                axis_change <= 12'd1;
            else// if(mst_exec_state  <= INIT_READ) //axis_changeһ�ζ�֮ǰ�仯һ�Ρ���ѡ��״̬�����һ��״̬���ڶ��źű仯ͬʱ�仯���ټ�һ���źű�֤һ�ζ�ֻ��һ��
                axis_change <= 12'd0;
            end   
       
             always @(posedge M_AXI_ACLK)                                                     
            begin                                                                                                                                                   
                  ddr_wr_bank1 <= ddr_wr_bank;                                                                                                                                            
            end 
                 
             always@(posedge M_AXI_ACLK )
           begin
           if(!M_AXI_ARESETN)
               reset_to_zero <= 12'd0;
           else if( ddr_wr_bank1!= ddr_wr_bank)//reset_delay)//need_clear==0&&//&wr_over==0//(mst_exec_state  <= ADDR_CHANGE)//( M_AXI_ARREADY && axi_arvalid)//horizontal counter maximum value
               reset_to_zero <= 12'd1;
           else// if(mst_exec_state  <= INIT_READ) //axis_changeһ�ζ�֮ǰ�仯һ�Ρ���ѡ��״̬�����һ��״̬���ڶ��źű仯ͬʱ�仯���ټ�һ���źű�֤һ�ζ�ֻ��һ��
               reset_to_zero <= 12'd0;
           end           
               always@(posedge M_AXI_ACLK )
               begin
                   if(!M_AXI_ARESETN||reset_to_zero)//0613 ||(v_cnt == 479&&h_cnt == 636)ԭ��ֻ��M_AXI_ARESETN//||reset_to_zero)//||change_complete)
                   begin
                       h_cnt <= 11'd1;
                       v_cnt <= 11'd0;
                   end
                   else if(axis_change)//axis_changeһ�ζ�֮ǰ�仯һ�Ρ���ѡ��״̬�����һ��״̬���ڶ��źű仯ͬʱ�仯���ټ�һ���źű�֤һ�ζ�ֻ��һ��
                   begin  
                     if(h_cnt ==639)//||change_complete)//horizontal counter maximum value  5.18
                     begin
                         h_cnt <= 12'd0;
                         if(v_cnt == 10'd479)//vertical counter maximum value
                         begin
                             v_cnt <= 12'd0;//0;
                         //    h_cnt <= 640;                    
                         end
                         else 
                         begin
                             v_cnt <= v_cnt + 12'd1;
                            
                         end
                     end
                     else
                         h_cnt <= h_cnt + 12'd1;
                   end
                   else if(v_cnt == 479&&h_cnt == 640)//(frame_complete==0)//0613(v_cnt == 479&&h_cnt == 640)
                   begin
                         h_cnt <= 12'd0;
                         v_cnt <= 12'd0;
                   end
                   else
                   begin
                       h_cnt <= h_cnt;
                       v_cnt <= v_cnt;
                   end
               end
             /*  
               always@(posedge M_AXI_ACLK)
               begin
                   if(!M_AXI_ARESETN)//||change_complete)//5.18
                   begin
                       v_cnt <= 12'd0;
                       
                   end
                   else if(h_cnt == 10'd639)//horizontal sync time H_FP
                       if(v_cnt == 10'd479)//vertical counter maximum value
                       begin
                           v_cnt <= 12'd0;//0;                    
                       end
                       else 
                           v_cnt <= v_cnt + 12'd1;
                   else
                       v_cnt <= v_cnt;
               end */
           always @ (posedge M_AXI_ACLK )
           begin
               if(angle <= 9'd45)
                   angle_in = {3'b000,angle};
               else if(angle > 9'd45 && angle <= 9'd90)
                   angle_in = {3'b001,9'd90 - angle};
               else if(angle > 9'd90 && angle <= 9'd135)
                   angle_in = {3'b010,angle - 9'd90};
               else if(angle > 9'd135 && angle <=9'd180)
                   angle_in = {3'b011,9'd180 - angle};
               else if(angle > 9'd180 && angle <= 9'd225)
                   angle_in = {3'b100,angle - 9'd180};
               else if(angle > 9'd225 && angle <= 9'd270)
                   angle_in = {3'b101,9'd270 - angle};
               else if(angle > 9'd270 && angle <= 9'd315)
                   angle_in = {3'b110,angle - 9'd270};
               else if(angle > 9'd315 && angle <= 9'd360)
                   angle_in = {3'b111, 9'd360 - angle};
               else
                   angle_in = {3'b000,angle};
           end
           
           always@(posedge M_AXI_ACLK)//��ɫ���õ�
           begin
               if(!M_AXI_ARESETN)
               begin
                   angle <= 0;
               end
               else 
                   angle <= angle_test<<1;        
           end
                 
           always@(posedge M_AXI_ACLK )
           begin
               if(!M_AXI_ARESETN||(rd_start&&rd_ddr_rotate==0))
                   processing_time <= 1'd0;
               else if(rd_ddr_rotate)//horizontal sync time H_FP
                   processing_time <=processing_time+ 1'd1;
               else if(rd_over)
                   processing_time <= processing_time;
           end 
           
          always@(posedge M_AXI_ACLK )
           begin
               if(!M_AXI_ARESETN)
                   send_stop <= 1'd0;
               else if(wr_over)//horizontal sync time H_FP
                   send_stop <= 1'd1;
               else if(rd_over)
                   send_stop <= 1'd0;
           end 
           
           /*
           always@(posedge M_AXI_ACLK )
           begin
               if(!M_AXI_ARESETN)
                   hdmi_rd_en <= 1'd0;
               else if(mst_exec_state==NEED_RD)//horizontal sync time H_FP
                   hdmi_rd_en <= 1'd1;
               else
                   hdmi_rd_en <= 0;
           end  
           */
            always @(posedge M_AXI_ACLK)                                    
           begin                                                                 
             if (M_AXI_ARESETN == 0)                                            
               begin                                                             
                 data_valid <= 1'b0;
                 hdmi_data <= 32'b0; 
             //    numofread<=0;                                            
               end                                                                                    
             else if ((wr_ddr_valid_you||(M_AXI_RLAST && axi_rready))&&send_stop == 1'd0)//0613&&send_stop == 1'd0)//(axi_rready&&read_index != C_M_AXI_BURST_LEN-1))                               
               begin                                                             
                 data_valid <= 1'b1;
               //  numofread<=numofread+1;
              //   if (mst_exec_state==INIT_READ)//(axis_vaild[23])//(mst_exec_state==INIT_READ)                               
                 begin                                                             
                     hdmi_data <= M_AXI_RDATA;                                             
                 end   
                 /*                                                                                          
                 else                                             
                 begin                                                             
                     hdmi_data <= 32'b0;                                             
                 end  
                    */                                                     
               end                                                                                             
             else                                              
               begin                                                             
                 data_valid <= 1'b0;                                             
               end                                                               
             // retain the previous value                                        
           end  
              
	// User logic ends


	endmodule
