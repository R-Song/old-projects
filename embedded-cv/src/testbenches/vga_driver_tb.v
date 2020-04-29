
/*
 * Testbench for the vga driver module. DUT is not connected to memory so make sure to comment out the vgaMemCtrl module in 
 * vga_driver.v. Instead, instantiate the test signal.
 *	
 *	Written by Ryan Song
 */
 
 `timescale 1 ns / 100 ps
 
 module vga_driver_tb();
	/* DUT inputs */
	reg clk_50;
	reg rst;
	reg [15:0] colour;
	
	/* DUT outputs */
	wire vga_hs;
	wire vga_vs;
	wire [5:0] red;
	wire [5:0] green;
	wire [5:0] blue;
	wire [18:0] rdaddress;
	wire rdclock;
 
	/* Instantiate the DUT */
	vga_driver DUT(
		.CLOCK_50(clk_50),
		.rst(rst),
		.vga_hs(vga_hs),
		.vga_vs(vga_vs),
		.red_o(red),
		.green_o(green),
		.blue_o(blue),
		.raddress(rdaddress),
		.rdclock(rdclock),
		.q(colour)
	);
 
	/* Create 50 Mhz clock */
	always 
		begin: CLOCK_GENERATOR
			#10 clk_50 = ~clk_50;
		end
	
	/* Change value of colour at a freq of 25 Mhz */
	always
		begin: COLOUR_GENERATOR
			#20 colour = ~colour;
		end
	
	/* Initial block */
	initial 
		begin
			$display($time, "<<-----Starting Simulation-0----->>");
			clk_50 = 1'b0;
			rst = 1'b1;
			colour = 16'h7E0
			#20 rst = 1'b0;
		end
		
 endmodule 