module vga_avalon(input logic clk, input logic reset_n,
                  input logic [3:0] address,
                  input logic read, output logic [31:0] readdata,
                  input logic write, input logic [31:0] writedata,
                  output logic [7:0] vga_red, output logic [7:0] vga_grn, output logic [7:0] vga_blu,
                  output logic vga_hsync, output logic vga_vsync, output logic vga_clk);

    // dangling wires to ignore the SYNC and BLANK signals.
    logic vga_blank;
    logic vga_sync;
    
    // VGA_{R,G,B} should be the upper 8 bits of the VGA module outputs.
    logic [9:0] vga_vga_red;
    logic [9:0] vga_vga_grn;
    logic [9:0] vga_vga_blu;

    assign vga_red = vga_vga_red[9:2];
    assign vga_grn = vga_vga_grn[9:2];
    assign vga_blu = vga_vga_blu[9:2];

    // your Avalon slave implementation goes here
    logic x_in_range;
    logic y_in_range;
    logic plot;

    assign x_in_range = (writedata[23:16] < 8'd160) ? 1'b1 : 1'b0;
    assign y_in_range = (writedata[30:24] < 7'd120) ? 1'b1 : 1'b0;

    // plot if address offset 0 is written and coordinates are within screen boundaries
    assign plot = write & x_in_range & y_in_range & (address == '0); 

    // logic [W-1:0] mem [N-1:0];
    logic [31:0] mem;

    ///////////////////////////////////////////////////////////////////////////////
    // Inferred synchronous single-port RAM with common read and write addresses //
    ///////////////////////////////////////////////////////////////////////////////
    always @(posedge clk)
    begin
        if (write)
        mem <= writedata;
        readdata <= mem;
    end



    vga_adapter #( .RESOLUTION("160x120"), .MONOCHROME("TRUE"), .BITS_PER_COLOUR_CHANNEL(8) )
	vga(
        .resetn(reset_n),
		.clock(clk),
		.colour(writedata[7:0]),
		.x(writedata[23:16]), 
        .y(writedata[30:24]), 
        .plot(plot),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(vga_vga_red),
		.VGA_G(vga_vga_grn),
		.VGA_B(vga_vga_blu),
		.VGA_HS(vga_hsync),
		.VGA_VS(vga_vsync),
		.VGA_BLANK(vga_blank),
		.VGA_SYNC(vga_sync),
		.VGA_CLK(vga_clk)
    );

    // NOTE: We will ignore the VGA_SYNC and VGA_BLANK signals.
    //       Either don't connect them or connect them to dangling wires.
    //       In addition, the VGA_{R,G,B} should be the upper 8 bits of the VGA module outputs.

endmodule: vga_avalon
