/*
	Author: Ryan Song
	Date: November 26th
	Description: 2 Parallel Numerically Controlled Oscilator
		-output the next two samples every clock cycle
*/

module p2_NCO(
	input clk,			// Input clock signal
	input out_en,			// NCO generates signal if out_en is high
	input ld_freq,			// NCO loads new frequency when set high
	input resetn,			// Active low reset
	input [15:0] freq,		// New frequency to load measured in KHz
	output [7:0] out_val_0,	// Output samples. Output value between -128 and 128 expressed in signed binary number
	output [7:0] out_val_1	// Out_val_0 leads out_val_1
	);

	parameter		SAMPLE_RATE = 100000,		// Equivalent to Clock Frequency. Used 100 000 KHz as default. Sample rate must be less than 
												// than clock speed. Output frequency must be less than or equal to half the sample rate.
					WORD_SIZE = 32;				// determines the precision that we can calculate our values to

	reg [31:0] phase_step;	 			// maximum phase step is 2^31 which occurs when output frequency is half of sample rate
	initial phase_step = 32'h00000000;

	reg parallel_en;

	always@(posedge clk)
		if(ld_freq == 1'b1) begin
			phase_step <= ({32'b0 ,freq} << WORD_SIZE)/(SAMPLE_RATE);	// Determines how much to increment phase
																		// This divider ciruit is most likely quite costly. Should remove if possible
			parallel_en = 1'b0;
		end

	reg [31:0] phase_accumulator_0;				// phase accumulator naturally resets to 0 after one cycle of 2^32
	initial phase_accumulator_0 = 32'h00000000;

	reg [31:0] phase_accumulator_1;				// phase accumulator naturally resets to 0 after one cycle of 2^32
	initial phase_accumulator_1 = 32'h00000000;

	always@(posedge clk)
		if(!resetn) begin 
			phase_accumulator_0 = 32'h00000000;
			phase_accumulator_1 = 32'h00000000;
			parallel_en = 1'b0;
		end
		else if(out_en && ld_freq == 1'b0) begin
			if(parallel_en == 1'b1)											// Have PA1 lag behind PA0 by one clock cycle
				phase_accumulator_1 <= phase_accumulator_1 + phase_step; 	// Increment phase
			else
				parallel_en <= 1'b1;										//After one clock cycle, set this to high.

			phase_accumulator_0 <= phase_accumulator_0 + phase_step;		// Increment phase
		end

	signal_table st0(.clk(clk), .phase(phase_accumulator_0[31:24]), .out_val(out_val_0)); // sends outputs according to the signal table
	signal_table st1(.clk(clk), .phase(phase_accumulator_1[31:24]), .out_val(out_val_1));
endmodule // p2_NCO


module signal_table(
	input clk,
	input [7:0] phase,
	output reg [7:0] out_val
	);

	always@(posedge clk) begin
		case(phase) 						// lookup table for computing the values of sin. This was not written by hand (thank god)
											// Instead I wrote a short C++ program that wrote a little bit of this repetitive verilog :)
			8'd0: out_val <= {0, 7'd0};
			8'd1: out_val <= {0, 7'd3};
			8'd2: out_val <= {0, 7'd6};
			8'd3: out_val <= {0, 7'd9};
			8'd4: out_val <= {0, 7'd12};
			8'd5: out_val <= {0, 7'd15};
			8'd6: out_val <= {0, 7'd18};
			8'd7: out_val <= {0, 7'd21};
			8'd8: out_val <= {0, 7'd24};
			8'd9: out_val <= {0, 7'd28};
			8'd10: out_val <= {0, 7'd31};
			8'd11: out_val <= {0, 7'd34};
			8'd12: out_val <= {0, 7'd37};
			8'd13: out_val <= {0, 7'd40};
			8'd14: out_val <= {0, 7'd43};
			8'd15: out_val <= {0, 7'd46};
			8'd16: out_val <= {0, 7'd48};
			8'd17: out_val <= {0, 7'd51};
			8'd18: out_val <= {0, 7'd54};
			8'd19: out_val <= {0, 7'd57};
			8'd20: out_val <= {0, 7'd60};
			8'd21: out_val <= {0, 7'd63};
			8'd22: out_val <= {0, 7'd65};
			8'd23: out_val <= {0, 7'd68};
			8'd24: out_val <= {0, 7'd71};
			8'd25: out_val <= {0, 7'd73};
			8'd26: out_val <= {0, 7'd76};
			8'd27: out_val <= {0, 7'd78};
			8'd28: out_val <= {0, 7'd81};
			8'd29: out_val <= {0, 7'd83};
			8'd30: out_val <= {0, 7'd85};
			8'd31: out_val <= {0, 7'd88};
			8'd32: out_val <= {0, 7'd90};
			8'd33: out_val <= {0, 7'd92};
			8'd34: out_val <= {0, 7'd94};
			8'd35: out_val <= {0, 7'd96};
			8'd36: out_val <= {0, 7'd98};
			8'd37: out_val <= {0, 7'd100};
			8'd38: out_val <= {0, 7'd102};
			8'd39: out_val <= {0, 7'd104};
			8'd40: out_val <= {0, 7'd106};
			8'd41: out_val <= {0, 7'd108};
			8'd42: out_val <= {0, 7'd109};
			8'd43: out_val <= {0, 7'd111};
			8'd44: out_val <= {0, 7'd112};
			8'd45: out_val <= {0, 7'd114};
			8'd46: out_val <= {0, 7'd115};
			8'd47: out_val <= {0, 7'd117};
			8'd48: out_val <= {0, 7'd118};
			8'd49: out_val <= {0, 7'd119};
			8'd50: out_val <= {0, 7'd120};
			8'd51: out_val <= {0, 7'd121};
			8'd52: out_val <= {0, 7'd122};
			8'd53: out_val <= {0, 7'd123};
			8'd54: out_val <= {0, 7'd124};
			8'd55: out_val <= {0, 7'd124};
			8'd56: out_val <= {0, 7'd125};
			8'd57: out_val <= {0, 7'd126};
			8'd58: out_val <= {0, 7'd126};
			8'd59: out_val <= {0, 7'd127};
			8'd60: out_val <= {0, 7'd127};
			8'd61: out_val <= {0, 7'd127};
			8'd62: out_val <= {0, 7'd127};
			8'd63: out_val <= {0, 7'd127};
			8'd64: out_val <= {0, 7'd128};
			8'd65: out_val <= {0, 7'd127};
			8'd66: out_val <= {0, 7'd127};
			8'd67: out_val <= {0, 7'd127};
			8'd68: out_val <= {0, 7'd127};
			8'd69: out_val <= {0, 7'd127};
			8'd70: out_val <= {0, 7'd126};
			8'd71: out_val <= {0, 7'd126};
			8'd72: out_val <= {0, 7'd125};
			8'd73: out_val <= {0, 7'd124};
			8'd74: out_val <= {0, 7'd124};
			8'd75: out_val <= {0, 7'd123};
			8'd76: out_val <= {0, 7'd122};
			8'd77: out_val <= {0, 7'd121};
			8'd78: out_val <= {0, 7'd120};
			8'd79: out_val <= {0, 7'd119};
			8'd80: out_val <= {0, 7'd118};
			8'd81: out_val <= {0, 7'd117};
			8'd82: out_val <= {0, 7'd115};
			8'd83: out_val <= {0, 7'd114};
			8'd84: out_val <= {0, 7'd112};
			8'd85: out_val <= {0, 7'd111};
			8'd86: out_val <= {0, 7'd109};
			8'd87: out_val <= {0, 7'd108};
			8'd88: out_val <= {0, 7'd106};
			8'd89: out_val <= {0, 7'd104};
			8'd90: out_val <= {0, 7'd102};
			8'd91: out_val <= {0, 7'd100};
			8'd92: out_val <= {0, 7'd98};
			8'd93: out_val <= {0, 7'd96};
			8'd94: out_val <= {0, 7'd94};
			8'd95: out_val <= {0, 7'd92};
			8'd96: out_val <= {0, 7'd90};
			8'd97: out_val <= {0, 7'd88};
			8'd98: out_val <= {0, 7'd85};
			8'd99: out_val <= {0, 7'd83};
			8'd100: out_val <= {0, 7'd81};
			8'd101: out_val <= {0, 7'd78};
			8'd102: out_val <= {0, 7'd76};
			8'd103: out_val <= {0, 7'd73};
			8'd104: out_val <= {0, 7'd71};
			8'd105: out_val <= {0, 7'd68};
			8'd106: out_val <= {0, 7'd65};
			8'd107: out_val <= {0, 7'd63};
			8'd108: out_val <= {0, 7'd60};
			8'd109: out_val <= {0, 7'd57};
			8'd110: out_val <= {0, 7'd54};
			8'd111: out_val <= {0, 7'd51};
			8'd112: out_val <= {0, 7'd48};
			8'd113: out_val <= {0, 7'd46};
			8'd114: out_val <= {0, 7'd43};
			8'd115: out_val <= {0, 7'd40};
			8'd116: out_val <= {0, 7'd37};
			8'd117: out_val <= {0, 7'd34};
			8'd118: out_val <= {0, 7'd31};
			8'd119: out_val <= {0, 7'd28};
			8'd120: out_val <= {0, 7'd24};
			8'd121: out_val <= {0, 7'd21};
			8'd122: out_val <= {0, 7'd18};
			8'd123: out_val <= {0, 7'd15};
			8'd124: out_val <= {0, 7'd12};
			8'd125: out_val <= {0, 7'd9};
			8'd126: out_val <= {0, 7'd6};
			8'd127: out_val <= {0, 7'd3};
			8'd128: out_val <= {1, 7'd0};
			8'd129: out_val <= {1, 7'd3};
			8'd130: out_val <= {1, 7'd6};
			8'd131: out_val <= {1, 7'd9};
			8'd132: out_val <= {1, 7'd12};
			8'd133: out_val <= {1, 7'd15};
			8'd134: out_val <= {1, 7'd18};
			8'd135: out_val <= {1, 7'd21};
			8'd136: out_val <= {1, 7'd24};
			8'd137: out_val <= {1, 7'd28};
			8'd138: out_val <= {1, 7'd31};
			8'd139: out_val <= {1, 7'd34};
			8'd140: out_val <= {1, 7'd37};
			8'd141: out_val <= {1, 7'd40};
			8'd142: out_val <= {1, 7'd43};
			8'd143: out_val <= {1, 7'd46};
			8'd144: out_val <= {1, 7'd48};
			8'd145: out_val <= {1, 7'd51};
			8'd146: out_val <= {1, 7'd54};
			8'd147: out_val <= {1, 7'd57};
			8'd148: out_val <= {1, 7'd60};
			8'd149: out_val <= {1, 7'd63};
			8'd150: out_val <= {1, 7'd65};
			8'd151: out_val <= {1, 7'd68};
			8'd152: out_val <= {1, 7'd71};
			8'd153: out_val <= {1, 7'd73};
			8'd154: out_val <= {1, 7'd76};
			8'd155: out_val <= {1, 7'd78};
			8'd156: out_val <= {1, 7'd81};
			8'd157: out_val <= {1, 7'd83};
			8'd158: out_val <= {1, 7'd85};
			8'd159: out_val <= {1, 7'd88};
			8'd160: out_val <= {1, 7'd90};
			8'd161: out_val <= {1, 7'd92};
			8'd162: out_val <= {1, 7'd94};
			8'd163: out_val <= {1, 7'd96};
			8'd164: out_val <= {1, 7'd98};
			8'd165: out_val <= {1, 7'd100};
			8'd166: out_val <= {1, 7'd102};
			8'd167: out_val <= {1, 7'd104};
			8'd168: out_val <= {1, 7'd106};
			8'd169: out_val <= {1, 7'd108};
			8'd170: out_val <= {1, 7'd109};
			8'd171: out_val <= {1, 7'd111};
			8'd172: out_val <= {1, 7'd112};
			8'd173: out_val <= {1, 7'd114};
			8'd174: out_val <= {1, 7'd115};
			8'd175: out_val <= {1, 7'd117};
			8'd176: out_val <= {1, 7'd118};
			8'd177: out_val <= {1, 7'd119};
			8'd178: out_val <= {1, 7'd120};
			8'd179: out_val <= {1, 7'd121};
			8'd180: out_val <= {1, 7'd122};
			8'd181: out_val <= {1, 7'd123};
			8'd182: out_val <= {1, 7'd124};
			8'd183: out_val <= {1, 7'd124};
			8'd184: out_val <= {1, 7'd125};
			8'd185: out_val <= {1, 7'd126};
			8'd186: out_val <= {1, 7'd126};
			8'd187: out_val <= {1, 7'd127};
			8'd188: out_val <= {1, 7'd127};
			8'd189: out_val <= {1, 7'd127};
			8'd190: out_val <= {1, 7'd127};
			8'd191: out_val <= {1, 7'd127};
			8'd192: out_val <= {1, 7'd128};
			8'd193: out_val <= {1, 7'd127};
			8'd194: out_val <= {1, 7'd127};
			8'd195: out_val <= {1, 7'd127};
			8'd196: out_val <= {1, 7'd127};
			8'd197: out_val <= {1, 7'd127};
			8'd198: out_val <= {1, 7'd126};
			8'd199: out_val <= {1, 7'd126};
			8'd200: out_val <= {1, 7'd125};
			8'd201: out_val <= {1, 7'd124};
			8'd202: out_val <= {1, 7'd124};
			8'd203: out_val <= {1, 7'd123};
			8'd204: out_val <= {1, 7'd122};
			8'd205: out_val <= {1, 7'd121};
			8'd206: out_val <= {1, 7'd120};
			8'd207: out_val <= {1, 7'd119};
			8'd208: out_val <= {1, 7'd118};
			8'd209: out_val <= {1, 7'd117};
			8'd210: out_val <= {1, 7'd115};
			8'd211: out_val <= {1, 7'd114};
			8'd212: out_val <= {1, 7'd112};
			8'd213: out_val <= {1, 7'd111};
			8'd214: out_val <= {1, 7'd109};
			8'd215: out_val <= {1, 7'd108};
			8'd216: out_val <= {1, 7'd106};
			8'd217: out_val <= {1, 7'd104};
			8'd218: out_val <= {1, 7'd102};
			8'd219: out_val <= {1, 7'd100};
			8'd220: out_val <= {1, 7'd98};
			8'd221: out_val <= {1, 7'd96};
			8'd222: out_val <= {1, 7'd94};
			8'd223: out_val <= {1, 7'd92};
			8'd224: out_val <= {1, 7'd90};
			8'd225: out_val <= {1, 7'd88};
			8'd226: out_val <= {1, 7'd85};
			8'd227: out_val <= {1, 7'd83};
			8'd228: out_val <= {1, 7'd81};
			8'd229: out_val <= {1, 7'd78};
			8'd230: out_val <= {1, 7'd76};
			8'd231: out_val <= {1, 7'd73};
			8'd232: out_val <= {1, 7'd71};
			8'd233: out_val <= {1, 7'd68};
			8'd234: out_val <= {1, 7'd65};
			8'd235: out_val <= {1, 7'd63};
			8'd236: out_val <= {1, 7'd60};
			8'd237: out_val <= {1, 7'd57};
			8'd238: out_val <= {1, 7'd54};
			8'd239: out_val <= {1, 7'd51};
			8'd240: out_val <= {1, 7'd48};
			8'd241: out_val <= {1, 7'd46};
			8'd242: out_val <= {1, 7'd43};
			8'd243: out_val <= {1, 7'd40};
			8'd244: out_val <= {1, 7'd37};
			8'd245: out_val <= {1, 7'd34};
			8'd246: out_val <= {1, 7'd31};
			8'd247: out_val <= {1, 7'd28};
			8'd248: out_val <= {1, 7'd24};
			8'd249: out_val <= {1, 7'd21};
			8'd250: out_val <= {1, 7'd18};
			8'd251: out_val <= {1, 7'd15};
			8'd252: out_val <= {1, 7'd12};
			8'd253: out_val <= {1, 7'd9};
			8'd254: out_val <= {1, 7'd6};
			8'd255: out_val <= {1, 7'd3};
		endcase 
	end
endmodule // signal_table