module tb_syn_task3();

`timescale 1ps / 1ps

module tb_rtl_task3();

    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4; 
    logic [6:0] HEX5;
    logic [9:0] LEDR;

    task3 DUT(.*);
    always #5 CLOCK_50 = ~CLOCK_50;  // Create clock with period=10
    enum {
        PRE_RUN,
        WAIT_RDY,
        RUNNING,
        DONE} s;
    
    initial begin
        /* Overrite memory */
        $readmemh("../../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", DUT.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        CLOCK_50 = 0;   KEY[3:0] = 0;  SW = 10'h000018;  #10;
        $display("Test: checking rest");

        //Deassert reset and it should start initialization automatically
        KEY[3] = 1;
        #40000;

        // wait(DUT.state == DONE); #20;
        $stop();
    end


endmodule: tb_rtl_task3


endmodule: tb_syn_task3
