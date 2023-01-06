`timescale 1ps/1ps
module tb_reuleaux();


logic clk = 0;
logic rst_n; 
logic [2:0] colour;
logic [7:0] centre_x; 
logic [6:0] centre_y; 
logic [7:0] diameter;
logic start;
logic done;
logic [7:0] vga_x; 
logic [6:0] vga_y;
logic [2:0] vga_colour; 
logic vga_plot;

reuleaux dut(.*);
always #5 clk = ~clk;  // Create clock with period=10

initial begin
    rst_n = 0;
    start = 0;
    #10;
    rst_n = 1;

    #10;

    //Normal usecase for circle
    centre_x = 40;
    centre_y = 30;
    diameter = 38;
    start = 1;

    wait(done == 1);

    rst_n = 0;
    start = 0;
    #10;
    rst_n = 1;

    //Test drawing a circle that is as wide as the screen
    centre_x = 80;
    centre_y = 60;
    diameter = 120;
    start = 1;

    wait(done == 1);

    rst_n = 0;
    start = 0;
    #10;
    rst_n = 1;

    //Test Drawing a circle on the edge
    centre_x = 0;
    centre_y = 0;
    diameter = 100;
    start = 1;

    wait(done == 1);

    //To test state machine staying in done state
    #100;
    //Confirm done is still high
    wait(done == 1);

    $stop;
end

endmodule: tb_reuleaux

