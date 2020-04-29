
/*
 * Handles signal timing for 640x480 60Hz vga display. For timing reference, refer to:  http://tinyvga.com/vga-timing/640x480@60Hz
 * VGA signal should be driven by the on board 50 Mhz clock. Data is read from a 2-port RAM block that holds the image to be rendered.
 *	Image stored in RAM buffer is RGB565 but the output of the RGB signal from this driver to the breakout board will be RGB666.
 *	A lot of help from this site: https://timetoexplore.net/blog/arty-fpga-vga-verilog-01
 *	
 *	Written by Ryan Song
 */


module vga_driver(CLOCK_50, rst, vga_hs, vga_vs, red_o, green_o, blue_o, rdaddress, rdclock, q);
	input CLOCK_50;
	input rst;
	output vga_hs;
	output vga_vs;
	output [5:0] red_o;
	output [5:0] green_o;
	output [5:0] blue_o;
	/* Interface with RAM */
	output [18:0] rdaddress;
	output rdclock;
	input [15:0] q;
	
	/* Generate 25 Mhz clock signal */
	wire clk_25;
	clock25 clk_div(
		.clk_50(CLOCK_50), 
		.clk_out(clk_25)
	);
	
	/* VGA timing parameters */
	localparam HS_START = 16;
	localparam HS_END = 16 + 96;
	localparam HA_START = 16 + 96 + 48;
	localparam VS_START = 480 + 10;
	localparam VS_END = 480 + 10 + 2;
	localparam VA_END = 480;
	localparam LINE = 800;
	localparam SCREEN = 525;
	
	/* Keep track of current x and y position */
	reg [9:0] x;
	reg [9:0] y;
	
	/* Set sync signals */
	assign vga_hs = ~((x >= HS_START) & (x < HS_END));
	assign vga_vs = ~((y >= VS_START) & (y < VS_END));
	
	always @(posedge CLOCK_50) begin
		if(rst) begin
			x <= 0;
			y <= 0;
		end
		
		/* Increment counters at 25 Mhz frequency */
		if(clk_25) begin
			if(x == LINE) begin
				x <= 0;
				y <= y + 1;
			end
			else
				x <= x + 1;
				
			if(y == SCREEN)
				y <= 0;			
		end
	end
	
	vga_mem_ctrl mem_controller(
		.CLOCK_50(CLOCK_50),
		.clk_25(clk_25),
		.x(x),
		.y(y),
		.red(red_o),
		.green(green_o),
		.blue(blue_o),
		.rdaddress(rdaddress),
		.rdclock(rdclock),
		.colour(q)
		);
	
	/* Test Signal */
//	testSignal test(
//		.x(x),
//		.y(y),
//		.red(r_o),
//		.green(g_o),
//		.blue(b_o)
//	);	
	
endmodule 


/* 
 * Memory controller. Reads from the 2-PORT RAM block and outputs the color pins accordingly
 * It is important to know that it takes one clock cycle for the RAM block to output data
 * Therefore, while current pixel is being drawn, the next pixel colour is fetched from memory
 */
 
module vga_mem_ctrl(CLOCK_50, clk_25, x, y, red, green, blue, rdaddress, rdclock, colour);
	input CLOCK_50;
	input clk_25;
	input [9:0] x;
	input [9:0] y;
	output [5:0] red;
	output [5:0] green;
	output [5:0] blue;
	/* Interface with RAM block */
	output [18:0] rdaddress;
	output reg rdclock;
	input [15:0] colour;
	
	/* Useful VGA parameters */
	localparam HA_START = 16 + 96 + 48;
	localparam HA_END = 16 + 96 + 48 + 640;
	localparam VA_END = 480;
	
	/* Set the read clock */
	always @(posedge CLOCK_50) begin
		if(clk_25)
			rdclock <= 1;
		else
			rdclock <= 0;
	end
	
	/* Check if it is the correct time to read from memory */
	wire rd_cond;
	assign rdcond = ( ((x+1) >= HA_START) & ((x+1) < HA_END) & (y < VA_END) );
		
	/* Set the read address */
	assign rdaddress = (rdcond) ? ( (x+1 - 160) + 640*y ) : 0;
	
	/* assign colors with RGB565 output from memory */
	wire [4:0] r_mem; wire [5:0] g_mem; wire [4:0] b_mem;
	assign {r_mem, g_mem, b_mem} = (rdcond) ? colour : 0 ;
	
	/* Convert the RGB565 output to RGB666 */
	assign red = r_mem << 1;
	assign green = g_mem;
	assign blue = b_mem << 1;
endmodule 


/* Clock divider that produces a 25 Mhz output clock */
module clock25(clk_50, clk_out);
	input clk_50;
	output reg clk_out;
	
	reg [15:0] cnt;
	
	always @(posedge clk_50) begin
		{clk_out, cnt} <= cnt + 16'h8000;
	end
endmodule 


/* Test vga signal. Should display 3 squares, one red, one green, one blue */
module testSignal(x, y, red, green, blue);
	input [9:0] x;
	input [9:0] y;
	output [5:0] red;
	output [5:0] green;
	output [5:0] blue;
	
	wire sq_a, sq_b, sq_c, sq_d;
	assign sq_a = ((x > 300) & (y >  40) & (x < 440) & (y < 200)) ? 1 : 0;
   assign sq_b = ((x > 360) & (y > 120) & (x < 520) & (y < 280)) ? 1 : 0;
   assign sq_c = ((x > 440) & (y > 200) & (x < 600) & (y < 360)) ? 1 : 0;
	
	assign red[5] = sq_a;
	assign green[5] = sq_b;
	assign blue[5] = sq_c;
endmodule 