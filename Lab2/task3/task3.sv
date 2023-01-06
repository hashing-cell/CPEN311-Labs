`timescale 1ps/1ps
module task3(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);
    typedef enum {START_FILLSCREEN, WAIT_FILLSCREEN, START_CIRCLE, WAIT_CIRCLE, DONE} state_t;

    state_t curr_state;
    state_t next_state;

    logic start_fillscreen, start_circle;
    logic [2:0] vga_colour_fillscreen, vga_colour_circle;
    logic done_fillscreen, done_circle;
    logic plot_fillscreen, plot_circle;
    logic [7:0] vga_x_fillscreen, vga_x_circle;
    logic [6:0] vga_y_fillscreen, vga_y_circle;


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
	

	fillscreen FS_BLACK(.clk (CLOCK_50), 
					.rst_n (KEY[3]), 
					.colour (3'b000), //colour does not matter here, module will fill it with all black no matter what
                  	.start (start_fillscreen), 
					.done  (done_fillscreen),
                    .vga_x (vga_x_fillscreen), 
					.vga_y (vga_y_fillscreen), 
                    .vga_colour (vga_colour_fillscreen), 
					.vga_plot (plot_fillscreen)
					);

    //Draw green circle at x=80 y=60 with radius of 40
    circle CIRCLE_INSTANCE(.clk(CLOCK_50), .rst_n(KEY[3]), .colour(3'b010),
             .centre_x(8'd30), .centre_y(7'd60), .radius(8'd40),
             .start(start_circle), .done(done_circle),
             .vga_x(vga_x_circle), .vga_y(vga_y_circle),
             .vga_colour(vga_colour_circle), .vga_plot(plot_circle));

    always @(posedge CLOCK_50) begin
		if(!KEY[3]) begin
			curr_state <= START_FILLSCREEN;
		end	else begin
			curr_state <= next_state;
		end
	end

    always_comb begin
        case (curr_state)
            START_FILLSCREEN: begin
                {start_fillscreen, start_circle} = 2'b10;
                VGA_COLOUR = vga_colour_fillscreen;
                VGA_PLOT = plot_fillscreen;
                VGA_X = vga_x_fillscreen;
                VGA_Y = vga_y_fillscreen;
                next_state = WAIT_FILLSCREEN;
            end
            WAIT_FILLSCREEN: begin
                {start_fillscreen, start_circle} = 2'b10;
                VGA_COLOUR = vga_colour_fillscreen;
                VGA_PLOT = plot_fillscreen;
                VGA_X = vga_x_fillscreen;
                VGA_Y = vga_y_fillscreen;
                if (done_fillscreen) begin
                    next_state = START_CIRCLE;
                end else begin
                    next_state = WAIT_FILLSCREEN;
                end
            end
            START_CIRCLE: begin
                {start_fillscreen, start_circle} = 2'b01;
                VGA_COLOUR = vga_colour_circle;
                VGA_PLOT = plot_circle;
                VGA_X = vga_x_circle;
                VGA_Y = vga_y_circle;
                next_state = WAIT_CIRCLE;
            end
            WAIT_CIRCLE: begin
                {start_fillscreen, start_circle} = 2'b01;
                VGA_COLOUR = vga_colour_circle;
                VGA_PLOT = plot_circle;
                VGA_X = vga_x_circle;
                VGA_Y = vga_y_circle;
                if (done_circle) begin
                    next_state = DONE;
                end else begin
                    next_state = WAIT_CIRCLE;
                end
            end
            DONE: begin
                VGA_PLOT = plot_circle;
                VGA_COLOUR = vga_colour_circle;
                VGA_X = vga_x_circle;
                VGA_Y = vga_y_circle;
                {start_fillscreen, start_circle} = 2'b00;
                next_state = DONE;
            end

            default: begin
                //panic, should not happen, we just deassert both starts and loop in DONE
                VGA_PLOT = plot_circle;
                VGA_COLOUR = vga_colour_circle;
                VGA_X = vga_x_circle;
                VGA_Y = vga_y_circle;
                {start_fillscreen, start_circle} = 2'b00;
                next_state = DONE;
            end

        endcase

    end

endmodule: task3
