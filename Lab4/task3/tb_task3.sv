`timescale 1 ps / 1 ps

module tb_task3();
logic CLOCK_50;
logic [3:0] KEY;
logic [9:0] SW;
logic [9:0] LEDR;
logic DRAM_CLK;
logic DRAM_CKE;
logic DRAM_CAS_N;
logic DRAM_RAS_N;
logic DRAM_WE_N;
logic [12:0] DRAM_ADDR;
logic [1:0] DRAM_BA;
logic DRAM_CS_N;
// logic [15:0] DRAM_DQ;
wire [15:0] DRAM_DQ;
logic DRAM_UDQM;
logic DRAM_LDQM;
logic [6:0] HEX0;
logic [6:0] HEX1;
logic [6:0] HEX2;
logic [6:0] HEX3;
logic [6:0] HEX4;
logic [6:0] HEX5;

task3 dut (.*);

initial begin
  CLOCK_50 = 1'b0;
  forever #5 CLOCK_50 = ~CLOCK_50;
end

initial begin
  KEY[3] <= 1'b0;
  #20;
  KEY[3] <= 1'b1;

  #10000;
end

endmodule