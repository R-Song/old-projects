/*
 * Uses the SCCB interface to configure the registers found in the OV7670. 
 * Toggling the registers allows for access to a lot of image processing functionality.
 * Refer to the OV7670 and SCCB documentation for more information on the registers as well as the
 * communication protocol. 
 *
 *	Written by Ryan Song
 */
 
 /* Highest level module that sets the correct register values into the OV7670 */
 module ov7670_config(clk50, sdio_c, sdio_d, start, done);
	/* Module starts programming registers when start is asserted. Once complete, done is asserted. */
	input clk50;
	input start;
	output done;
	output sdio_c;
	output sdio_d;
	
	/* Loop through the config_list and use the sccb_interface to program the register values one at a time */
	
 
 endmodule 
 
 
 /* 
  * Holds the list of addresses and the corresponding data to be programmed onto the camera. Read through this list by incrementing config_addr.
  * The last element will be signified with a dout value of 0xFFFF 	
  */
 module config_list(clk50, clk1, config_addr, dout);
	input clk50;
	input clk1;
	input [7:0] config_addr;
	output reg [7:0] addr;
	output reg [7:0] data;
	
	always @ (posedge clk50) begin
		if(clk1) begin
			case (config_addr)
				8'h00: {addr, data} <= 8'h00;	// just examples
				8'h00: {addr, data} <= 8'h00;
			endcase
		end
	end
 endmodule 
 
 
 /*
  * Given an addr and data, the sccb interface will communicate with the ov7670 through the sdio pins
  * To launch a SCCB write, done must be set to 1 while start is driven high. This launches the FSM
  */
 module sccb_interface(clk50, resetn, addr, data, sdio_c, sdio_d, start, done);
	input clk50;
	input resetn;
	input [7:0] addr;
	input [7:0] data;
	input start;
	output reg done;
	output sdio_c;
	output sdio_d;
	
	/* Produce 1 Mhz Clock */
	wire clk1;
	clock1 clock_divider(
		.clk50(clk50),
		.clk_out(clk1)
	);
	
	/* Slave address for write operations */
	wire [7:0] SLAVE_ADDR;
	assign SLAVE_ADDR = 8'h42;
	
	/* State table and flags */
	reg [3:0] fsm_state;
	localparam IDLE = 4'h0;
	localparam START_COND = 4'h1;				localparam START_COND_WAIT = 4'h2;
	localparam SEND_SLAVE_ADDR = 4'h3;		localparam SEND_SLAVE_ADDR_WAIT = 4'h4;
	localparam SEND_REG_ADDR = 4'h5; 		localparam SEND_REG_ADDR_WAIT = 4'h6;
	localparam SEND_DATA = 4'h7;				localparam SEND_DATA_WAIT = 4'h8;
	localparam STOP_COND = 4'h9;				localparam STOP_COND_WAIT = 4'hA;
	localparam FINISHED_SCCB = 4'hB;

	/* State transitions */
	always @ (posedge clk50) begin
		if(!resetn) begin
			fsm_state <= IDLE;
		end
		else if(clk1) begin
			case (fsm_state) 
				IDLE: fsm_state <= (start == 1'b1) ? START_COND : IDLE;
				
				START_COND: fsm_state <= START_COND_WAIT;
				START_COND_WAIT: fsm_state <= (done_sccb == 1'b1) ? SEND_SLAVE_ADDR : START_COND_WAIT;
				
				SEND_SLAVE_ADDR: fsm_state <= SEND_SLAVE_ADDR_WAIT;
				SEND_SLAVE_ADDR_WAIT: fsm_state <= (done_sccb == 1'b1) ? SEND_REG_ADDR : SEND_SLAVE_ADDR_WAIT;
				
				SEND_REG_ADDR: fsm_state <= SEND_REG_ADDR_WAIT;
				SEND_REG_ADDR_WAIT: fsm_state <= (done_sccb == 1'b1) ? SEND_DATA : SEND_REG_ADDR_WAIT;
				
				SEND_DATA: fsm_state <= SEND_DATA_WAIT;
				SEND_DATA_WAIT: fsm_state <= (done_sccb == 1'b1) ? STOP_COND : SEND_DATA_WAIT; 
				
				STOP_COND: fsm_state <= STOP_COND_WAIT;
				STOP_COND_WAIT: fsm_state <= (done_sccb == 1'b1) ? FINISHED_SCCB : STOP_COND_WAIT;
				
				FINISHED_SCCB: fsm_state <= IDLE;
				default: fsm_state <= IDLE;
			endcase 
		end
	end
	
	/* Output logic, instantiate send_sccb module */
	reg [3:0] op_code;
	reg [7:0] byte;
	reg start_sccb;
	wire done_sccb;
	
	/* Op codes for the sccb module */
	localparam OP_CODE_SEND_START_COND = 4'h1;
	localparam OP_CODE_SEND_BYTE = 4'h2;
	localparam OP_CODE_SEND_STOP_COND = 4'h3;
	
	send_sccb sccb(
		.clk50(clk50),
		.clk1(clk1),
		.op_code(op_code),
		.byte(byte),
		.start(start_sccb),
		.done(done_sccb),
		.sdio_c(sdio_c),
		.sdio_d(sdio_d)
	);
	
	always @ (posedge clk50) begin
		if(clk1) begin
			case (fsm_state)
				IDLE: begin
					start_sccb <= 1'b0;
					byte <= 8'h00;
					op_code <= 4'h0;
					done <= 1'b0;
				end
				
				START_COND: begin
					/* Assert start_segment and set value of op_code */
					op_code <= OP_CODE_SEND_START_COND;
					start_sccb <= 1'b1;
				end
				START_COND_WAIT: 
				
				SEND_SLAVE_ADDR: begin
					op_code <= OP_CODE_SEND_BYTE;
					byte <= SLAVE_ADDR;
				end
				SEND_SLAVE_ADDR_WAIT:
				
				SEND_REG_ADDR: begin
					op_code <= OP_CODE_SEND_BYTE;
					byte <= addr;
				end
				SEND_REG_ADDR_WAIT:
				
				SEND_DATA: begin
					op_code <= OP_CODE_SEND_BYTE;
					byte <= data;
				end
				SEND_DATA_WAIT:
				
				STOP_COND: begin
					op_code <= OP_CODE_SEND_STOP_COND;
				end
				STOP_COND_WAIT:
				
				FINISHED_SCCB: begin
					start_sccb <= 1'b0;
					done <= 1'b1;
				end
				
				default:	;
			endcase 
		end
	end
 endmodule 
 
 
 /* 
  * Module that sends a byte plus the ack bit via sdio_c and sdio_d 
  * Done signal asserts one clock cycle before the last bit is sent, 
  * giving the module above in heirarchy time to load in new opcode/data
  */
 module send_sccb( clk50, clk1, op_code, byte, start, done, sdio_c, sdio_d );
	input clk50;
	input clk1;
	input [3:0] op_code;
	input [0:7] byte;
	input start;
	output reg done;
	output reg sdio_c;
	output reg sdio_d;
	
	reg [3:0] bit_counter;
	reg [3:0] clk_counter;
	
	localparam START_COND = 4'h1;
	localparam SEND = 4'h2;
	localparam STOP_COND = 4'h3;
	
	always @ (posedge clk50) begin
		if(clk1 && start) begin
			case (op_code)		
				START_COND: begin 
					case (clk_counter)
						4'h0: begin
							sdio_d <= 1'b1;
							clk_counter <= clk_counter + 1'b1;
						end
						4'h1: begin
							sdio_c <= 1'b1;
							clk_counter <= clk_counter + 1'b1;
						end
						4'h2: begin
							sdio_d <= 1'b0;
							clk_counter <= clk_counter + 1'b1;
							done <= 1'b1;
						end
						4'h3: begin
							sdio_c <= 1'b0;
							clk_counter <= 4'h0;
							done <= 1'b0;
						end
						default: ;
					endcase
				end
				SEND: begin
					case (clk_counter)
						4'h0: begin
							/* 8th bit should be the ack bit, which is just 0 */
							sdio_d <= (bit_counter < 4'h8) ? byte[bit_counter] : 1'b0;
							clk_counter <= clk_counter + 1'b1;
						end
						4'h1: begin
							sdio_c <= 1'b1;
							clk_counter <= clk_counter + 1'b1;
							if(bit_counter == 4'h8)
								done <= 1'b1;
						end
						4'h2: begin
							sdio_c <= 1'b0;
							clk_counter <= 4'h0;
							if(bit_counter == 4'h8) begin
								bit_counter = 4'h0;
								done <= 1'b0;
							end
						end
						default: ;
					endcase
				end
				STOP_COND: begin
					case (clk_counter)
						4'h0: begin
							sdio_c <= 1'b1;
							clk_counter <= clk_counter + 1'b1;
						end
						4'h1: begin
							sdio_d <= 1'b1;
							clk_counter <= clk_counter + 1'b1;
						end
						4'h2: begin
							sdio_c <= 1'b0;
							clk_counter <= clk_counter + 1'b1;
							done <= 1'b1;
						end
						4'h3: begin
							sdio_d <= 1'b0;
							clk_counter <= 4'h0;
							done <= 1'b0;
						end
						default:	;					
					endcase	
				end
				default: ;
			endcase 
		end
		else begin
			sdio_c <= 1'b0;
			sdio_d <= 1'b0;
			clk_counter <= 4'h0;
			bit_counter <= 4'h0;
			done <= 1'b0;
		end
	end
 endmodule 
 
 
 /* Clock divider that produces roughly a 1 Mhz clock */
 module clock1(clk_50, clk_out);
	input clk_50;
	output reg clk_out;
	
	reg [15:0] cnt;
	
	always @(posedge clk_50) begin
		{clk_out, cnt} <= cnt + 16'h051F;
	end
 endmodule 