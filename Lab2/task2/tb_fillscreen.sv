module tb_fillscreen();
	// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
	
	logic clk;
	logic rst_n; 
	logic [2:0] colour;
	logic start;
	logic done;
    logic [7:0] vga_x; 
	logic [6:0] vga_y;
    logic [2:0] vga_colour; 
	logic vga_plot;
	
	localparam period = 20;
	
	fillscreen dut( .* );
	
	initial begin
		forever begin
			clk = 1'b1;
			#period;
			clk = 1'b0;
			#period;
		end
	end
	
	initial begin
		rst_n = 1'b0;
		#100
		
		start = 1'b1;
		rst_n = 1'b1;
		
		wait(vga_y == 7'd119);
		wait(vga_x == 8'd159);
		wait(done == 1'b1);
		
		$stop;
	end
	
endmodule: tb_fillscreen
