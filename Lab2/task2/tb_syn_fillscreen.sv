`timescale 1ps/1ps
module tb_syn_fillscreen();

    logic clk = 0;
    logic rst_n;
    logic [2:0] colour;
    logic start; 
    logic done;
    logic [7:0] vga_x; 
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;
    
    fillscreen dut (.*);

    always #5 clk = ~clk;  // Create clock with period=10

    initial begin

        //Testing the full screen being filled
        rst_n = 0;
        start = 0;
        #20;
        rst_n = 1;
        start = 1;

        wait(done == 1);

        //Testing what happens if the start button is desserted half way througj
        rst_n = 0;
        start = 0;
        #5;
        rst_n = 1;
        start = 1;

        //Approximately have the time for the design to be half filled
        #100320

        start = 0;

        $display("Pixel x = %d, Pixel y = %d \n", vga_x , vga_y);
        #200;
        $display("After 20 clock cycles\n");
        $display("Pixel x = %d, Pixel y = %d \n", vga_x , vga_y);

        //Lets ressert start
        start = 1;

        wait(done == 1);


        $stop;
    
endmodule: tb_syn_fillscreen
