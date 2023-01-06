`timescale 1ps/1ps

module tb_vga_avalon();
    logic clk; 
    logic reset_n;
    logic [3:0] address;
    logic read; 
    logic [31:0] readdata;
    logic write; 
    logic [31:0] writedata;
    logic [7:0] vga_red; 
    logic [7:0] vga_grn; 
    logic [7:0] vga_blu;
    logic vga_hsync; 
    logic vga_vsync; 
    logic vga_clk;

    vga_avalon vga_avalon(.*);

    initial begin
        clk = 1'b0;
        forever begin
        #5 clk = ~clk;
        end
    end

    initial begin
        address = '0;
        // We test values from pixels.tx
        #1;
        // First pixel
        write <= 1'b1;
        writedata <= {1'b0, 7'd1, 8'd83, 8'd0, 8'd255};
        #1;
        assert (vga_avalon.writedata[23:16] == 8'd83);
        assert (vga_avalon.writedata[30:24] == 7'd1);
        assert (vga_avalon.writedata[7:0] == 8'd255);
        #1;
        write <= 1'b1;
        writedata <= {1'b0, 7'd5, 8'd25, 8'd0, 8'd255};
        #1;
        assert (vga_avalon.writedata[23:16] == 8'd25);
        assert (vga_avalon.writedata[30:24] == 7'd5);
        assert (vga_avalon.writedata[7:0] == 8'd255);
        #1;
        write <= 1'b1;
        writedata <= {1'b0, 7'd123, 8'd89, 8'd0, 8'd122};
        #1;
        assert (vga_avalon.writedata[23:16] == 8'd89);
        assert (vga_avalon.writedata[30:24] == 7'd123);
        assert (vga_avalon.writedata[7:0] == 8'd122);
        #1;
        write <= 1'b1;
        writedata <= {1'b0, 7'd34, 8'd11, 8'd0, 8'd0};
        #1;
        assert (vga_avalon.writedata[23:16] == 8'd11);
        assert (vga_avalon.writedata[30:24] == 7'd34);
        assert (vga_avalon.writedata[7:0] == 8'd0);
        #1;
    end



endmodule: tb_vga_avalon
