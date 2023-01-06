`define TOP_CORNER 2'b11
`define BL_CORNER 2'b01
`define BR_CORNER 2'b10

module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
			  input logic [8:0] bounds_x, input logic [8:0] bounds_y, 
			  input logic [8:0] bounds2_x, input logic [8:0] bounds2_y, 
			  input logic [1:0] which_corner,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
	
	//enumeration for all possible states
	typedef enum { 
		CIRCLE_WAIT, 
		CIRCLE_CHECK_LOOP, 
		CIRCLE_DRAW_PIXEL1,
		CIRCLE_DRAW_PIXEL2,
		CIRCLE_DRAW_PIXEL3,
		CIRCLE_DRAW_PIXEL4, 
		CIRCLE_DRAW_PIXEL5,
		CIRCLE_DRAW_PIXEL6,
		CIRCLE_DRAW_PIXEL7,
		CIRCLE_DRAW_PIXEL8,
		CIRCLE_CRIT_CHECK,
		CIRCLE_CRIT_LE_ZERO,
		CIRCLE_CRIT_GT_ZERO,
		CIRCLE_DRAW_DONE
	} state_t;

	state_t curr_state;
	state_t next_state;

	logic [7:0] offset_x;
	logic [6:0] offset_y;
	logic signed [32:0] crit;
	logic signed [32:0] next_crit;

    logic [8:0] vga_x_logic;
    logic [7:0] vga_y_logic;

	logic update_offset_x;
	logic update_offset_y;
	logic update_crit;
	logic which_crit;

    // STATE MACHINE CLOCK LOGIC BLOCK
	always @(posedge clk) begin
		if(!rst_n) begin
			curr_state <= CIRCLE_WAIT;
		end	else begin
			curr_state <= next_state;
		end
	end

	// offset_x register logic block
	always @(posedge clk) begin
		if (!rst_n) begin
            offset_x <= radius;
        end
        else if (update_offset_x) begin
            offset_x <= offset_x - 1;
		end
	end

	// offset_y register logic block
	always @(posedge clk) begin
		if (!rst_n) begin
            offset_y <= 0;
        end
        else if (update_offset_y) begin
            offset_y <= offset_y + 1;
		end
	end

	// crit register logic block
	always @(posedge clk) begin
		if (!rst_n) begin
            crit <= 1 - radius;
        end else if (update_crit) begin
            crit <= next_crit;
		end
	end

    // STATE MACHINE OUTPUT LOGIC BLOCK
	always_comb begin
		case (curr_state)
			CIRCLE_WAIT: begin
				done = 0;
				vga_plot = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				if (start) begin
					next_state = CIRCLE_CHECK_LOOP;
				end else begin
					next_state = CIRCLE_WAIT;
				end
			end
			CIRCLE_CHECK_LOOP: begin
				done = 0;
				vga_plot = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				if (offset_y <= offset_x) begin
					next_state = CIRCLE_DRAW_PIXEL1;
				end else begin
					next_state = CIRCLE_DRAW_DONE;
				end
			end
			CIRCLE_DRAW_PIXEL1: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;

				vga_x_logic = centre_x + offset_x;
				vga_y_logic = centre_y + offset_y;
				next_state = CIRCLE_DRAW_PIXEL2;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL2: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;

				vga_x_logic = centre_x + offset_y;
				vga_y_logic = centre_y + offset_x;
				next_state = CIRCLE_DRAW_PIXEL3;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL3: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;

				vga_x_logic = centre_x - offset_x;
				vga_y_logic = centre_y + offset_y;
				next_state = CIRCLE_DRAW_PIXEL4;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL4: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				
				vga_x_logic = centre_x - offset_y;
				vga_y_logic = centre_y + offset_x;
				next_state = CIRCLE_DRAW_PIXEL5;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL5: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				
				vga_x_logic = centre_x - offset_x;
				vga_y_logic = centre_y - offset_y;
				next_state = CIRCLE_DRAW_PIXEL6;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL6: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				
				vga_x_logic = centre_x - offset_y;
				vga_y_logic = centre_y - offset_x;
				next_state = CIRCLE_DRAW_PIXEL7;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL7: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				
				vga_x_logic = centre_x + offset_x;
				vga_y_logic = centre_y - offset_y;
				next_state = CIRCLE_DRAW_PIXEL8;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_DRAW_PIXEL8: begin
				done = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				
				vga_x_logic = centre_x + offset_y;
				vga_y_logic = centre_y - offset_x;
				next_state = CIRCLE_CRIT_CHECK;

				// plot only if it is within bounds, edited for reuleaux
				if (vga_x_logic <= 9'd159 && vga_y_logic <= 8'd119) begin
					if (which_corner == `TOP_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_x_logic <= bounds2_x && vga_y_logic >= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BL_CORNER) begin
						if (vga_x_logic >= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else if (which_corner == `BR_CORNER) begin
						if (vga_x_logic <= bounds_x && vga_y_logic <= bounds2_y) begin
							vga_plot = 1;
						end else begin
							vga_plot = 0;
						end
					end else begin
						vga_plot = 0;
					end
				end else begin
					vga_plot = 0;
				end
			end
			CIRCLE_CRIT_CHECK: begin
				vga_plot = 0;
				done = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 0;
				update_offset_y = 1;
				update_crit = 0;
				which_crit = 0;

				if (crit <= 0) begin
					next_state = CIRCLE_CRIT_LE_ZERO;
				end else begin
            		next_state = CIRCLE_CRIT_GT_ZERO;
				end
			end
			CIRCLE_CRIT_LE_ZERO: begin
				vga_plot = 0;
				done = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 1;
				which_crit = 0;

				next_state <= CIRCLE_CHECK_LOOP;
			end
			CIRCLE_CRIT_GT_ZERO: begin
				vga_plot = 0;
				done = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 1;
				update_offset_y = 0;
				update_crit = 1;
				which_crit = 1;
				next_state <= CIRCLE_CHECK_LOOP;
			end
			CIRCLE_DRAW_DONE: begin
				done = 1;
				vga_plot = 0;
				vga_x_logic = 0;
				vga_y_logic = 0;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				if (start) begin
					next_state = CIRCLE_DRAW_DONE;
				end else begin
					next_state = CIRCLE_WAIT;
				end
			end
			default begin
				//panic
				done = 0;
				vga_plot = 0;
				vga_x_logic = 119;
				vga_y_logic = 159;
				update_offset_x = 0;
				update_offset_y = 0;
				update_crit = 0;
				which_crit = 0;
				next_state = CIRCLE_WAIT;
			end
		endcase

		vga_colour = colour;
		vga_x = vga_x_logic[7:0];
        vga_y = vga_y_logic[6:0];
		next_crit = which_crit ? crit + (2 * (offset_y - offset_x)) + 1 : crit + (2 * offset_y) + 1;
	end
	 
endmodule