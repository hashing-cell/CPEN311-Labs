`timescale 1ps/1ps
module tb_task4();

    logic CLOCK_50 = 0; 
    logic [3:0] KEY;
    logic [9:0] SW; 
    logic [9:0] LEDR;
    logic [6:0] HEX0; 
    logic [6:0] HEX1; 
    logic [6:0] HEX2;
    logic [6:0] HEX3; 
    logic [6:0] HEX4; 
    logic [6:0] HEX5;
    logic [7:0] VGA_R; 
    logic [7:0] VGA_G; 
    logic [7:0] VGA_B;
    logic VGA_HS; 
    logic VGA_VS; 
    logic VGA_CLK;
    logic [7:0] VGA_X; 
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR; 
    logic VGA_PLOT;


    task4 dut (.*);
    always #5 CLOCK_50 = ~CLOCK_50;  // Create clock with period=10

    // Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    initial begin
        KEY[3] = 0;
        KEY[0] = 1;
        #10;
        KEY[3] = 1;
        KEY[0] = 0;

        //Done signal for reuleaux
        wait(LEDR[0] == 1);
        //Finished
        $stop;

    end
endmodule: tb_task4
// C:/Users/amran/OneDrive\ -\ UBC/Documents/UBC/School\ Work/2022W1/CPEN\ 311/2022w1-lab2-l1a-lab2-group1/vga-core/de1_vga_gui.tcl

