/*
	Authors: Ryan Song, Raymond Hong
	Description: TopModule for Parallel Sorting Algorithm Visualized on Hardware. Numbers are then sorted and drawn on the screen
				 as bars of diferent length.
	
	How to demo:
		-Can take either PS2 Keyboard input for demo. Just uncomment a little 
		bit of the code to switch from keyboard to switches.
		
		-To reset after running the sorting algorithm, press key[1] + enter + key[0]
		***The reset is a little bit awkward. It should be fixed if this project is ever revisited***
*/

module TopModule(
	input CLOCK_50,		// 50 MHz Clock
	input [9:0] SW,		// On Board Switches
	input [3:0] KEY,		// On Board Keys
	output [6:0] HEX0,	// Hex Displays
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [9:0] LEDR,	// On Board LEDs
	inout PS2_CLK,			// PS2 Clock for Keyboard
	inout PS2_DAT,			// PS2 Data from Keyboard
	output VGA_CLK,   	// VGA Outputs			
	output VGA_HS,				
	output VGA_VS,					
	output VGA_BLANK_N,				
	output VGA_SYNC_N,				
	output [7:0]	VGA_R,   				
	output [7:0]	VGA_G,	 				
	output [7:0]	VGA_B   
	);

	/*****************************************************************
	*			Reset and Clock Signals, Internal Registers      	 *		
	*****************************************************************/
	
	wire resetn; 
	wire clear;
	wire clk;
	//wire load_val;
	assign resetn = ~KEY[0];	// Active High Reset
	assign clk = CLOCK_50;		// 50 MHz Clock
	//assign load_val = ~KEY[3];
	assign clear = ~KEY[1];
	
	// Internal Registers for Storing Numbers:
	// S -> Sorted, NS -> Not Sorted
	reg [7:0] NS_0;			reg [7:0] S_0;
	reg [7:0] NS_1;			reg [7:0] S_1;
	reg [7:0] NS_2;			reg [7:0] S_2;
	reg [7:0] NS_3;			reg [7:0] S_3;
	reg [7:0] NS_4;			reg [7:0] S_4;
	reg [7:0] NS_5;			reg [7:0] S_5;
	reg [7:0] NS_6;			reg [7:0] S_6;
	reg [7:0] NS_7;			reg [7:0] S_7;
	reg [7:0] NS_8;			reg [7:0] S_8;
	reg [7:0] NS_9;			reg [7:0] S_9;
	
	/**************************************************************
	*						KeyBoard Handler				      *		
	**************************************************************/
	
	//Instantiating PS2_Controller
	wire [7:0] key_data;
	wire key_data_enable;
	
	PS2_Controller KeyboardController (
		.CLOCK_50(CLOCK_50),
		.reset(resetn),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.received_data(key_data),
		.received_data_en(key_data_enable)
		);
		
	//Instantiating Keyboard Decoder
	wire [7:0] number_out;
	wire number_enable;

	KeyboardDecoder K1(
		.clk(CLOCK_50),
		.resetn(resetn),
		.key_code(key_data),
		.key_enable(key_data_enable),
		.number_out(number_out),
		.number_enable(number_enable)
		);
		
	
	/*************************************************
	*				Storing Input Values 			 *		
	*************************************************/
	
	reg [3:0] load_counter;		// Describes which register value should be stored in
	reg begin_sort;				// Flag for signaling when to start sorting
	
	always@(posedge number_enable /*posedge load_val*/) begin
		if(clear) begin
			load_counter = 4'h0;
			begin_sort = 1'b0;
			NS_0 = 8'h00;		NS_5 = 8'h00;		
			NS_1 = 8'h00;		NS_6 = 8'h00;			
			NS_2 = 8'h00;		NS_7 = 8'h00;
			NS_3 = 8'h00;		NS_8 = 8'h00;	
			NS_4 = 8'h00;		NS_9 = 8'h00;		
		end
		
		else begin
			case(load_counter)
				4'h0: NS_0 = number_out;		4'h5: NS_5 = number_out;		// Keyboard Input
				4'h1: NS_1 = number_out;		4'h6: NS_6 = number_out;
				4'h2: NS_2 = number_out;		4'h7: NS_7 = number_out;
				4'h3: NS_3 = number_out;		4'h8: NS_8 = number_out;
				4'h4: NS_4 = number_out;		4'h9: NS_9 = number_out;
				
//				4'h0: NS_0 = SW[7:0];		4'h5: NS_5 = SW[7:0];				// SW Input
//				4'h1: NS_1 = SW[7:0];		4'h6: NS_6 = SW[7:0];
//				4'h2: NS_2 = SW[7:0];		4'h7: NS_7 = SW[7:0];
//				4'h3: NS_3 = SW[7:0];		4'h8: NS_8 = SW[7:0];
//				4'h4: NS_4 = SW[7:0];		4'h9: NS_9 = SW[7:0];
			endcase
			
			if(load_counter == 4'h9) begin
				load_counter <= 4'hA;
				begin_sort <= 1'b1;
			end
			else if(load_counter < 4'h9)
				load_counter <= load_counter + 1;
		end
	end
	
	
	/*************************************************
	*			  	Parallel Sorting Cells			 *		
	*************************************************/	
	
	reg [7:0] sort_counter;		// keeps track of the sorting process
	reg [7:0] new_element_data;		// new element data input for parallel sorting cells
	reg new_element_enable;
	reg begin_load_sort;			// Flag that tells machine when to start loading the sorted data
	
	always@(posedge clk) begin
		if(resetn) begin
			sort_counter = 4'h0;
			new_element_data = 4'h0;
			new_element_enable = 1'b0;								
			begin_load_sort = 1'b0;
		end
		
		if(begin_sort == 1'b1) begin
			case(sort_counter)
				8'd00: new_element_data = NS_0;					// skipped some values in the counter to give a few clock cycles of time for values to be sorted
				8'd02: new_element_enable = 1'b1;				
				8'd03: new_element_enable = 1'b0;				
				
				8'd05: new_element_data = NS_1;
				8'd07: new_element_enable = 1'b1;
				8'd08: new_element_enable = 1'b0;
				
				8'd10: new_element_data = NS_2;
				8'd12: new_element_enable = 1'b1;
				8'd13: new_element_enable = 1'b0;
				
				8'd15: new_element_data = NS_3;
				8'd17: new_element_enable = 1'b1;
				8'd18: new_element_enable = 1'b0;
				
				8'd20: new_element_data = NS_4;
				8'd22: new_element_enable = 1'b1;
				8'd23: new_element_enable = 1'b0;
				
				8'd25: new_element_data = NS_5;
				8'd27: new_element_enable = 1'b1;
				8'd28: new_element_enable = 1'b0;
				
				8'd30: new_element_data = NS_6;
				8'd32: new_element_enable = 1'b1;
				8'd33: new_element_enable = 1'b0;
				
				8'd35: new_element_data = NS_7;
				8'd37: new_element_enable = 1'b1;
				8'd38: new_element_enable = 1'b0;
				
				8'd40: new_element_data = NS_8;
				8'd42: new_element_enable = 1'b1;
				8'd43: new_element_enable = 1'b0;
				
				8'd45: new_element_data = NS_9;
				8'd47: new_element_enable = 1'b1;
				8'd48: new_element_enable = 1'b0;
			endcase 
			if(sort_counter == 8'd49) begin
				sort_counter <= 8'd50;
				begin_load_sort <= 1'b1;
			end
			else if(sort_counter < 8'd49)
				sort_counter <= sort_counter + 1;
		end
	end
	
	
	//Instantiate sort cells as well as the wires that connect them
	wire [7:0] p0_data;
	wire p0_push_enable;
	wire p0_cell_state;
	
	ParallelSortCell p0(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(8'b00000000),
		.previous_cell_state(1'b1),
		.previous_push(1'b0),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p0_data[7:0]),
		.push_enable(p0_push_enable),
		.current_cell_state(p0_cell_state)
		);
	
	wire [7:0] p1_data;
	wire p1_push_enable;
	wire p1_cell_state;
	
	ParallelSortCell p1(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p0_data[7:0]),
		.previous_cell_state(p0_cell_state),
		.previous_push(p0_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p1_data[7:0]),
		.push_enable(p1_push_enable),
		.current_cell_state(p1_cell_state)
		);
		
	wire [7:0] p2_data;
	wire p2_push_enable;
	wire p2_cell_state;
	
	ParallelSortCell p2(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p1_data[7:0]),
		.previous_cell_state(p1_cell_state),
		.previous_push(p1_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p2_data[7:0]),
		.push_enable(p2_push_enable),
		.current_cell_state(p2_cell_state)
		);
		
	wire [7:0] p3_data;
	wire p3_push_enable;
	wire p3_cell_state;
	
	ParallelSortCell p3(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p2_data[7:0]),
		.previous_cell_state(p2_cell_state),
		.previous_push(p2_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p3_data[7:0]),
		.push_enable(p3_push_enable),
		.current_cell_state(p3_cell_state)
		);
		
	wire [7:0] p4_data;
	wire p4_push_enable;
	wire p4_cell_state;
	
	ParallelSortCell p4(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p3_data[7:0]),
		.previous_cell_state(p3_cell_state),
		.previous_push(p3_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p4_data[7:0]),
		.push_enable(p4_push_enable),
		.current_cell_state(p4_cell_state)
		);
		
	wire [7:0] p5_data;
	wire p5_push_enable;
	wire p5_cell_state;
	
	ParallelSortCell p5(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p4_data[7:0]),
		.previous_cell_state(p4_cell_state),
		.previous_push(p4_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p5_data[7:0]),
		.push_enable(p5_push_enable),
		.current_cell_state(p5_cell_state)
		);

	wire [7:0] p6_data;
	wire p6_push_enable;
	wire p6_cell_state;
	
	ParallelSortCell p6(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p5_data[7:0]),
		.previous_cell_state(p5_cell_state),
		.previous_push(p5_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p6_data[7:0]),
		.push_enable(p6_push_enable),
		.current_cell_state(p6_cell_state)
		);

	wire [7:0] p7_data;
	wire p7_push_enable;
	wire p7_cell_state;
	
	ParallelSortCell p7(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p6_data[7:0]),
		.previous_cell_state(p6_cell_state),
		.previous_push(p6_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p7_data[7:0]),
		.push_enable(p7_push_enable),
		.current_cell_state(p7_cell_state)
		);
	
	wire [7:0] p8_data;
	wire p8_push_enable;
	wire p8_cell_state;
	
	ParallelSortCell p8(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p7_data[7:0]),
		.previous_cell_state(p7_cell_state),
		.previous_push(p7_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p8_data[7:0]),
		.push_enable(p8_push_enable),
		.current_cell_state(p8_cell_state)
		);
	
	wire [7:0] p9_data;
	wire p9_push_enable;
	wire p9_cell_state;
	
	ParallelSortCell p9(
		//inputs
		.clk(clk),
		.resetn(resetn),
		.previous_cell_data(p8_data[7:0]),
		.previous_cell_state(p8_cell_state),
		.previous_push(p8_push_enable),
		.new_element_data(new_element_data),
		.new_element_enable(new_element_enable),
		//outputs
		.cell_data(p9_data[7:0]),
		.push_enable(p9_push_enable),
		.current_cell_state(p9_cell_state)
		);
	

	
	/*************************************************
	*			  	Storing Sorted Values 			 *		
	*************************************************/	
	
	reg [3:0] store_sorted_counter;
	reg sorted_done;
	
	always@(posedge clk) begin
		if(resetn) begin
			store_sorted_counter = 4'h0;
			sorted_done = 1'b0;
			S_0 = 8'h00;		S_5 = 8'h00;
			S_1 = 8'h00;		S_6 = 8'h00;
			S_2 = 8'h00;		S_7 = 8'h00;
			S_3 = 8'h00;		S_8 = 8'h00;
			S_4 = 8'h00;		S_9 = 8'h00;
		end
		else if(begin_load_sort == 1'b1) begin
			S_0 = p0_data;		S_5 = p5_data;
			S_1 = p1_data;		S_6 = p6_data;
			S_2 = p2_data;		S_7 = p7_data;		
			S_3 = p3_data;		S_8 = p8_data;
			S_4 = p4_data;		S_9 = p9_data;
			sorted_done = 1'b1;
		end
	end
	
	/*************************************************
	*			  	HEX and VGA Outputs 			 *		
	*************************************************/	
	
	hex_decoder h0(S_4[3:0], HEX5);
	hex_decoder h1(S_5[3:0], HEX4);
	hex_decoder h2(S_6[3:0], HEX3);
	hex_decoder h3(S_7[3:0], HEX2);
	hex_decoder h4(S_8[3:0], HEX1);
	hex_decoder h5(S_9[3:0], HEX0);
	
	//input wires into VGA Controller 
	wire [2:0] color;
	wire [2:0] color_input;
	wire [2:0] color_sort;
	wire [7:0] x;
	wire [6:0] y;
	wire [7:0] x_sort;
	wire [6:0] y_sort;
	wire [7:0] x_input;
	wire [6:0] y_input;
	wire writeEn;
	wire writeEn_sort;
	wire writeEn_input;
	wire finish;
	
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";		

	// prints the unsorted input numbers to vga	
	vga_input v1(
		//inputs
		.clk(CLOCK_50),
		.KEY0(KEY[0]),
		.KEY1(KEY[2]),
		.enter(KEY[3]),
		.value0(NS_0),
		.value1(NS_1),
		.value2(NS_2),
		.value3(NS_3),
		.value4(NS_4),
		.value5(NS_5),
		.value6(NS_6),
		.value7(NS_7),
		.value8(NS_8),
		.value9(NS_9),
		//outputs 
		.X(x_input),
		.Y(y_input),
		.color(color_input),
		.writeEn(writeEn_input),
		.finish(finish));
	
	// prints the sorted numbers to vga
	vga_sorted b1_sort(
		//inputs
		.finish(finish),
		.clk(CLOCK_50),
		.sw0(SW[8]),
		.sw1(SW[9]),
		.enter(KEY[3]),
		.value0(S_0),
		.value1(S_1),
		.value2(S_2),
		.value3(S_3),
		.value4(S_4),
		.value5(S_5),
		.value6(S_6),
		.value7(S_7),
		.value8(S_8),
		.value9(S_9),
		//outputs
		.X(x_sort),
		.Y(y_sort),
		.color(color_sort),
		.writeEn_sort(writeEn_sort)
	);
	
endmodule 

/*
	Description: Simple 7_segment hex decoder
*/

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule


/*
	Author: Ryan Song
	Date: November 11th, 2018
	
	Module Description: Parallel Sorting Cell. 
		-Building blocks of a greater array for quick O(N) sorting on FPGA
	
	Block Diagram:
	
	
		clk------------------------>|-----------------|
								    |	              |
		reset---------------------->|	              |----------> Cell_Data
								    |	              |
		enable--------------------->|	              |
								    |	              |
		previous_cell_data--------->|	Sorting Cell  |----------> Push_enable
								    |		          |
		new_element_data----------->|	              |
								    |	              |
		previous_push-------------->|	              |----------> State_of_Cell
								    |		          |
		previous_cell_state-------->|-----------------|
	
		
	Description of I/O:
		-clk: 50 MHz clock generated by DE1-SOC
		-reset: clears all cell data and resets cell state to empty
		-enable: time to make decision on whether to take new value or to take previous cell value
		-previous_cell_data: data field in previous cell in sorting array
		-new_element_data: data field from new element coming in
		-previous_push: whether or not to replace current data field with data from previous cell
		-previous_cell_state: whether previous cell is empty of filled
		
		-Cell_Data: data currently stored in cell
		-Push_enable: describes whether or not data from this cell should be pushed to the one below
		-State_of_cell: describes whether current of cell is empty of filled
		
	***All cells are initialized to 00000000. A cell is considered empty if its contents is 0000000***
	
	**NOTE:
		-There will always be a delay between updating the states of push_enable, state_of_cell, cell_data etc. Give ample for info to propogate
*/



module ParallelSortCell(
	input clk,
	input resetn,
	input new_element_enable,
	input [7:0] previous_cell_data,
	input [7:0] new_element_data,
	input previous_push,
	input previous_cell_state,
	output reg [7:0] cell_data,
	output reg push_enable,
	output current_cell_state
	);
	
	//Declaring local parameters
	
	localparam full = 1'b1,
				  empty = 1'b0;
	
	//current state of cell
	wire cell_state;
	assign current_cell_state = cell_state;
	
	StateFSM fsm(clk, resetn, cell_data, cell_state);
	
	//push_enable, want to be independant of clock
	always@(*) begin	
		//reset
		if(resetn)
			push_enable = 0;
		//push if last cell pushes and cell is full
		if(previous_push == 1'b1)
			push_enable = (cell_state == full) ? 1'b1 : 1'b0;	
		//if incoming value is smaller than current value and larger than the previous value,
		//take in the new element value and push
		else if(
				(previous_cell_state == full) &&
				(cell_state == full) &&
				(new_element_data <= cell_data) &&
				(new_element_data > previous_cell_data) &&
				(new_element_enable == 1'b1)
			)
				push_enable <= 1'b1;
		else
			push_enable = 1'b0;
	end
	
	always@(posedge clk) begin
		//resetting
		if(resetn) begin
			cell_data <= 8'b00000000;
		end
		//if previous cell pushes, this cell must take up that value. 
		//Reset value of cell if resetn
		if((previous_push == 1'b1) && (new_element_enable == 1'b1)) begin
			cell_data <= previous_cell_data;	
		end
		//if current cell is empty, previous cell does not push and is full, load in the new element
		else if(
				(cell_state == empty) && 
				(previous_cell_state == full) && 
				(previous_push == 1'b0) &&
				(new_element_enable == 1'b1)
			)
			begin
				cell_data <= new_element_data;
			end 	
		//if incoming value is smaller than current value and larger than the previous value,
		//take in the new element value and push
		else if(
				(previous_cell_state == full) &&
				(cell_state == full) &&
				(new_element_data <= cell_data) &&
				(new_element_data > previous_cell_data) &&
				(new_element_enable == 1'b1)
			)
			begin
				cell_data <= new_element_data;
			end
	end
	
endmodule 


module StateFSM(
	input clk,
	input resetn,
	input [7:0] cell_data,
	output cell_state
	);
	
	wire is_cell_filled;
	assign is_cell_filled = (cell_data == 8'b00000000) ? 1'b0 : 1'b1;
	
	//state registers
	reg current_state, next_state;
	
	//defining states
	localparam empty = 1'b0,
				  full = 1'b1;
	
	always@(*) begin
		case(current_state)
			empty: next_state = (is_cell_filled) ? full : empty;
			full: next_state = full;
			default next_state = empty;
		endcase 
	end
	
	always@(posedge clk) begin
		if(resetn)
			current_state <= empty;
		else
			current_state = next_state;
	end
	
	assign cell_state = current_state ? 1'b1 : 1'b0;
	
endmodule 


/*
	Author: Ryan Song
	Date: November 19th
	Description:
		***Part of ECE241 Final Project***
		
		-module contains the finite state machine tasked with recieving integer digits from the
		keyboard and converting them to 8-bit binary numbers.
		
		EX: User enters: 1, 4, 5, enter
		Result: module outputs 1001001 (145 in binary)
		
		Module I/O:
			
							  |--------------------------|
				CLOCK_50----->|							 |
							  |							 |---------> 8 bit binary output
				resetn------->|							 |
							  |		KeyBoard Decoder   	 |
				key_code----->|							 |
							  |							 |---------> New number enable
				key_enable--->|							 |
							  |--------------------------|
		
			CLOCK_50: 50 MHz clock signal
			resetn: active high reset
			key_code: 8 bit binary code sent by Ps2 Keyboard
			key_enable: high for one clock cycle when a new element comes in from keyboard
			
			8 bit binary output: the decimal keyboard input translated to binary
			New number enable: goes high for one clock cycle when a new number is outputed
*/

module KeyboardDecoder(
	input clk,
	input resetn,
	input [7:0] key_code,
	input key_enable,
	output [7:0] number_out,
	output reg number_enable
	);
	
	/**********************************************************
	*					Decoding Keyboard Codes			  	  *		
	**********************************************************/
	parameter key_1 = 8'h16;
	parameter key_2 = 8'h1E;
	parameter key_3 = 8'h26;
	parameter key_4 = 8'h25;
	parameter key_5 = 8'h2E;
	parameter key_6 = 8'h36;
	parameter key_7 = 8'h3D;
	parameter key_8 = 8'h3E;
	parameter key_9 = 8'h46;
	parameter key_0 = 8'h45;
	parameter key_en = 8'h5A;
	
	reg [7:0] keyboard_input;
	
	always@(*)
		case(key_code)
			key_1: keyboard_input = 8'h01;
			key_2: keyboard_input = 8'h02;
			key_3: keyboard_input = 8'h03;
			key_4: keyboard_input = 8'h04;
			key_5: keyboard_input = 8'h05;
			key_6: keyboard_input = 8'h06;
			key_7: keyboard_input = 8'h07;
			key_8: keyboard_input = 8'h08;
			key_9: keyboard_input = 8'h09;
			key_0: keyboard_input = 8'h00;
			key_en: keyboard_input = 8'h0A;
			default: keyboard_input = 8'h0E; //E for error!
		endcase 
	
	/****************************************************************
	*					SHIFT REGISTER FOR NUMBER INPUTS		    *		
	****************************************************************/
	
	//Internal Register
	reg [47:0] number_list;
	reg [1:0] kb_counter;
	
	//Shift register for keeping track of numbers
	always@(posedge clk) begin
		
		if(resetn) begin
			number_list = 48'h000000000000;
			number_enable = 1'b0;
			kb_counter = 2'b00;
		end
		else if(key_enable) begin
			if((keyboard_input != 8'h0A) && (keyboard_input != 8'h0E)) begin
				number_list = number_list << 8;
				number_list[7:0] = keyboard_input;
			end
			else if(keyboard_input == 8'h0A) begin
				kb_counter = kb_counter + 1;
			end
		end
		
		if(kb_counter == 2'b10) begin
			number_enable = 1'b1;
			kb_counter = kb_counter + 1;
		end
		else if(kb_counter == 2'b11) begin
			kb_counter = 2'b00;
			number_list = 48'h000000000000;
		end
		else begin
			number_enable = 1'b0;
		end
	end
	
	assign number_out = ((number_list[39:32] << 6) + (number_list[39:32] << 5) + (number_list[39:32] << 2)) + ((number_list[23:16] << 3) + (number_list[23:16] << 1)) + number_list[7:0];
	
endmodule 
