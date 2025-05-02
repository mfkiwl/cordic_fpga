
`timescale 1 ns / 1 ps

	module rd_data_v1_0_M00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h20000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 16,
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
        (*mark_debug ="true"*)output  reg [2:0] mst_exec_state,
        output reg ddr_rd_bank,
        //(*mark_debug ="true"*)output reg [C_M_AXI_ADDR_WIDTH-1 : 0]     axi_araddr,
      //  (*mark_debug ="true"*)input frame_complete,
        input ddr_wr_bank,
        input vs,
        input video_clk,
        (*mark_debug ="true"*)output [31:0]hdmi_data,
        (*mark_debug ="true"*)input hdmi_rd_en,
        (*mark_debug ="true"*)output reg rd_over,
       // output reg [6:0] addr_test=0,
        (*mark_debug ="true"*)output reg hdmi_start,
      //  (*mark_debug ="true"*)output reg [31:0] rd_addr_last,
        input tozero,
        input bank_change,
        input wr_over,
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
		input wire  M_AXI_RVALID,
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

	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	 localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	 localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
	 wire [31:0]  TARGET_SLAVE_BASE_ADDR	=(ddr_wr_bank == 0)? 32'h30200000:32'h20200000;
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
		INIT_CHECK = 2'b10; // This state issues the status of comparison 
			// of the written data with the read data	


	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	(*mark_debug ="true"*)reg [C_M_AXI_ADDR_WIDTH-1 : 0]     axi_araddr;
	reg  	axi_arvalid;
	reg  	axi_rready;
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
	reg  	read_mismatch;
	reg  	burst_write_active;
	reg  	burst_read_active;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
    (*mark_debug ="true"*)reg     ddr_rd_en;
    (*mark_debug ="true"*)wire [10:0] wr_data_count;
    reg rd_ddr_en;
    
    (*mark_debug ="true"*)wire rd_fifo_en;
    (*mark_debug ="true"*) reg first_frame;
  /*  һЩ�����ź�
   wire      my_axi_arvalid;
   wire [C_TRANSACTIONS_NUM : 0]     my_read_index;
   wire      my_rnext;
    (*mark_debug ="true"*)wire      my_start_single_burst_read;
    (*mark_debug ="true"*)wire    my_burst_read_active;
    (*keep ="true"*)wire    my_read_burst_counter;
    assign my_axi_arvalid=axi_arvalid;
    assign my_read_index=read_index;
    assign my_rnext=rnext;
    assign my_start_single_burst_read=start_single_burst_read;
    assign my_burst_read_active=burst_read_active;
    assign my_read_burst_counter=read_burst_counter;
*/

	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= TARGET_SLAVE_BASE_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Burst size in bytes
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH/8;
   
	//----------------------------
	//Read Address Channel
	//----------------------------

	//The Read Address Channel (AW) provides a similar function to the
	//Write Address channel- to provide the tranfer qualifiers for the burst.

	//In this example, the read address increments in the same
	//manner as the write address channel.

	  always @(posedge M_AXI_ACLK)                                 
	  begin                                                              
	                                                                     
	    if (M_AXI_ARESETN == 0)                                         
	      begin                                                          
	        axi_arvalid <= 1'b0;                                         
	      end                                                            
	    // If previously not valid , start next transaction              
	    else if(~axi_arvalid && start_single_burst_read)// (~axi_arvalid && M_AXI_ARREADY && mst_exec_state == INIT_READ)//(~axi_arvalid && start_single_burst_read)                
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
	 /*                                                                    
	 	  always @(posedge M_AXI_ACLK)                                 
      begin                                                              
                                                                         
        if (M_AXI_ARESETN == 0)                                         
          begin                                                          
            axi_arvalid <= 1'b0;                                         
          end                                                            
        // If previously not valid , start next transaction              
        else if (~axi_arvalid && start_single_burst_read)                
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
      */                                                                   
	// Next address after ARREADY indicates previous address acceptance  
	  always @(posedge M_AXI_ACLK)                                       
	  begin                                                              
	    if (M_AXI_ARESETN == 0 ||( vs==0) )   //|| vs                                       
	      begin
	  //     rd_addr_last<=  axi_araddr;                                                           
	        axi_araddr <= 0; 
	      //  rd_ddr_en<=1;
	                                              
	      end                                                            
	    else if (M_AXI_ARREADY && axi_arvalid)                           
	      begin 
	                                                                   
              if (axi_araddr==21'h12c000)//12c000)  // write_index == C_M_TRANSACTIONS_NUM
              begin
                 axi_araddr <= axi_araddr;
               //  rd_ddr_en<=0;
       //          addr_test=addr_test+1;
                // rd_over<=1;                     
              end
              else                                                                
                axi_araddr <= axi_araddr + burst_size_bytes;//60;//60;//burst_size_bytes;                             
          end                 
	                                                                  
	    else                                                             
	      axi_araddr <= axi_araddr;                                      
	  end                                                                

	// ��ddr���� 
	  always @(posedge M_AXI_ACLK)                                       
	  begin                                                              
	    if (M_AXI_ARESETN == 0||vs==0)                                          
	      begin                                                          
	       rd_over<=0;                                   
	      end                                                                                      	                                                        
	    else if (axi_araddr==21'h12c000)//12c000)  // write_index == C_M_TRANSACTIONS_NUM
          begin 
            rd_over<=1;          
          end                                                                                                    
	  end
	     
	 always @(posedge M_AXI_ACLK)                                       
      begin                                                              
        if (M_AXI_ARESETN == 0||vs==0)                                          
          begin                                                          
           rd_ddr_en<=1;                                   
          end                                                                                                                                                  
        else if (axi_araddr==21'h12b040)//12c000)  // write_index == C_M_TRANSACTIONS_NUM
          begin 
            rd_ddr_en<=0;          
          end                                                                                                    
      end
	//******************* ��ddr��bank�л� ���û����******************//
  /*      always @(posedge M_AXI_ACLK)                                       
        begin                                                              
          if (M_AXI_ARESETN == 0)                                          
            begin                                                          
              ddr_rd_bank<=1'b1;                                   
            end                                                                                                                                                  
          else if (bank_change&&rd_over&&(ddr_rd_bank == ddr_wr_bank))//(axi_araddr==21'h12c000&&(ddr_rd_bank == ddr_wr_bank))//12c000)  // write_index == C_M_TRANSACTIONS_NUM
            begin 
              ddr_rd_bank = ~ddr_rd_bank;          
            end                                                                                                    
        end */
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
	    if (M_AXI_ARESETN == 0)                  
	      begin                                                             
	        axi_rready <= 1'b0;                                             
	      end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when M_AXI_RVALID is asserted by slave                           
	    else if (M_AXI_RVALID && (mst_exec_state==INIT_READ))     //2023.2.7                  
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
	                                                                        	                                                                                                            
	 // read_burst_counter counter keeps track with the number of burst transaction initiated                   
	 // against the number of burst transactions the master needs to initiate                                   
	  always @(posedge M_AXI_ACLK)                                                                              
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 0)                                                                                 
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
	     else if(mst_exec_state!=INIT_READ) 
                 read_burst_counter <= 1'b0;                                                                                                                                                                                                       
	    else                                                                                                    
	      read_burst_counter <= read_burst_counter;                                                             
	  end                                                                                                       
	                                                                                                            
	                                                                                                            
	  //implement master command interface state machine                                                        
	                                                                                                            
	  always @ ( posedge M_AXI_ACLK)                                                                            
	  begin                                                                                                     
	    if (M_AXI_ARESETN == 1'b0 )                                                                             
	      begin                                                                                                 
	        // reset condition                                                                                  
	        // All the signals are assigned default values under reset condition                                
	        mst_exec_state      <= IDLE;                                                                
	        start_single_burst_write <= 1'b0;                                                                   
	        start_single_burst_read  <= 1'b0;                                                                   
	      end                                                                                                   
	    else                                                                                                    
	      begin                                                                                                 
	                                                                                                            
	        // state transition                                                                                 
	        case (mst_exec_state)                                                                               
	                                                                                                            
	          IDLE:                                                                                     
	            // This state is responsible to wait for user defined C_M_START_COUNT                           
	            // number of clock cycles.                                                                      
                                                                                       
	            begin  
	            if(tozero==1)                                                                                       
                  mst_exec_state  <= INIT_CHECK;                                                              
                end                                                                                                                                                         
                                                                                        
	                                                                                                            
	          INIT_READ:                                                                                        
	            // This state is responsible to issue start_single_read pulse to                                
	            // initiate a read transaction. Read transactions will be                                       
	            // issued until burst_read_active signal is asserted.                                           
	            // read controller                                                                              
	            if (reads_done)                                                                                 
	              begin                                                                                         
	                mst_exec_state <= INIT_CHECK;                                                             
	              end                                                                                           
	            else                                                                                            
	              begin                                                                                         
	                mst_exec_state  <= INIT_READ;                                                               
	                                                                                                            
	                if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read)                         
	                  begin                                                                                     
	                    start_single_burst_read <= 1'b1;                                                        
	                  end                                                                                       
	               else                                                                                         
	                 begin                                                                                      
	                   start_single_burst_read <= 1'b0; //Negate to generate a pulse                            
	                 end                                                                                        
	              end                                                                                           
	                                                                                                            
	          INIT_CHECK:                                                                                     
                    // This state is responsible to issue the state of comparison                                   
                    // of written data with the read data. If no error flags are set,                               
                    // compare_done signal will be asseted to indicate success.                                     
                    //if (~error_reg)                                                                               
                    if (tozero==0)
                     mst_exec_state  <= IDLE;                                                               
                    else  if(ddr_rd_en) 
                    begin
                     mst_exec_state  <= INIT_READ;                                                                 
                    end
                    else                                                               
                      mst_exec_state  <= INIT_CHECK;                                    
                                                                                                                
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
	    if (M_AXI_ARESETN == 0)                                                                                 
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

assign rd_fifo_en=rnext && (read_index != C_M_AXI_BURST_LEN);//-1
	// Add user logic here
ddr2hdmi ddr2hdmi//��ddr��ȡ
                (
                    .rst(~M_AXI_ARESETN),
                    .wr_clk(M_AXI_ACLK),
                    .rd_clk(video_clk),
                    .wr_data_count(wr_data_count),
                    .wr_en(rd_fifo_en),///(rnext && (read_index != C_M_AXI_BURST_LEN)),//axis_right(��һ���ж������Ƿ��ڷ�Χ�ڣ����ڷ�Χ�ں�ɫ)//(M_AXI_ARREADY && axi_arvalid),//(ddr_rd_en),//2022.01.05
                    .rd_en(hdmi_rd_en),//hdmi_rd_en
                    .din(M_AXI_RDATA),
                    .dout(hdmi_data),
                    .full(),
                    .empty()
                );
    //FIFO�������������800��ʱ��ʼ��
    always @(posedge M_AXI_ACLK)                                                      
    begin                                                                             
        if (M_AXI_ARESETN == 0)                                                         
            ddr_rd_en <= 1'b0;
          
        else if(wr_data_count <= 800 && rd_ddr_en && first_frame)//&&rd_load_flag)&&vs
            ddr_rd_en <= 1'b1;
        else
            ddr_rd_en <= 1'b0;
        // User logic ends
        end
   /*     
         always @(posedge M_AXI_ACLK)                                                      
        begin                                                                             
            if (M_AXI_ARESETN == 0)                                                         
                 hdmi_start<=1'b0;
            else if(wr_data_count >16)//&&rd_load_flag)
                hdmi_start<=1;
            // User logic ends
            end
         */   
 //�ж�����ϵͳ�ϵ��ĵ�һ֡�ı�־
    always @(posedge M_AXI_ACLK)                                                      
    begin                                                                             
        if (M_AXI_ARESETN == 0) 
        begin                                                        
            first_frame <= 1'b0;
            hdmi_start<=1'b0;
        end
        else if(wr_over)//(x�������б�ı�־)//&&rd_load_flag)
        begin
            first_frame <= 1'b1;
            hdmi_start<=1'b1;
        end
    end
	// User logic ends

	endmodule
