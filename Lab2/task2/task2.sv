`timescale 1ps/1ps
module task2(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module'
	
	vga_adapter VGA(
				.resetn (KEY[3]), 
				.clock (CLOCK_50), 
				.colour (VGA_COLOUR),
				.x (VGA_X), 
				.y (VGA_Y), 
				.plot (VGA_PLOT),
				.VGA_R ( VGA_R ), 
				.VGA_G ( VGA_B ), 
				.VGA_B ( VGA_G ),
				.*);
	logic VGA_SYNC;
	logic VGA_BLANK;
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	

	fillscreen FSDUT(.clk (CLOCK_50), 
					.rst_n (KEY[3]), 
					.colour (VGA_COLOUR),
                  	.start (~KEY[0]), 
					.done  (LEDR[0]),
                    .vga_x (VGA_X), 
					.vga_y (VGA_Y), 
                    .vga_colour (VGA_COLOUR), 
					.vga_plot (VGA_PLOT)
					);
endmodule: task2