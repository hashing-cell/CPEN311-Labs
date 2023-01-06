`timescale 1ps / 1ps

module tb_de1_gui();
    logic CLK;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;

    de1_gui gui(.SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    button_pusher dut(.CLK, .SW, .KEY, .LEDR, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK;
    end
endmodule
