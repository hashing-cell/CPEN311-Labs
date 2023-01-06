module lights(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR);

	niossystem sys(
		.clk_clk(CLOCK_50),
		.reset_reset_n(KEY[0]),
		.switches_export(SW),
		.leds_export(LEDR)
	);

endmodule: lights