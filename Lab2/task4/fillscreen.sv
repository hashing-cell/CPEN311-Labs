module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen
	 logic [7:0] count_x;
	 logic [6:0] count_y;
	 
	 assign vga_x = count_x;
	 assign vga_y = count_y;
	 
	 always @(posedge clk)begin
		if(!rst_n)
			begin
				count_x <= 8'b11111111;
				count_y <= 7'd0;
				done <= 1'b0;
				vga_colour <= colour;
			end
		else if( count_x == 8'd159 && count_y == 7'd119 )
			done <= 1'b1;
			
		else if( start == 1'b1 && done == 1'b0)
			begin
				count_x <= count_x + 1'b1;
				if (count_x == 8'd159) begin
					count_x <= 0;
					count_y <= count_y + 3'b001;
				end
				vga_plot <= 1'b1;
			end		
	 end
	 
endmodule

