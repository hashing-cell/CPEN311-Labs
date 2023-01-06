`timescale 1ps/1ps
`define SRC_ADDR {8'h00, 8'h00, 8'h00, 8'h64}
`define DEST_ADDR {8'h00, 8'h00, 8'h00, 8'hC8}
`define MEM_MAP_ADDR 32'd000

module tb_rtl_wordcopy();
  logic clk; 
  logic rst_n;
  // slave (CPU-facing)
  logic slave_waitrequest;
  logic [3:0] slave_address;
  logic slave_read; 
  logic [31:0] slave_readdata;
  logic slave_write; 
  logic [31:0] slave_writedata;
  // master (SDRAM-facing)
  logic master_waitrequest;
  logic [31:0] master_address;
  logic master_read; 
  logic [31:0] master_readdata; 
  logic master_readdatavalid;
  logic master_write; 
  logic [31:0] master_writedata;

  initial begin
    clk = 1'b0;
    forever begin
      #5 clk = ~clk;
    end
  end

  wordcopy wordcopy(.*);


  logic [7:0] ram [0:1024];

  logic [31:0] dest_addr = `DEST_ADDR;
  logic [31:0] src_addr  = `SRC_ADDR;
  logic [31:0] N         = 32'd3;

  // initialize simulated ram
  task initialize_ram();
    integer i;

    for (i = 0; i < 1024; i++) begin
      ram[i] = 32'h00;
    end

    ram[100:103] = {8'hDE, 8'hAD, 8'hBE, 8'hEF};
    ram[104:107] = {8'hFE, 8'hED, 8'hFA, 8'hCE};
    ram[108:111] = {8'hDE, 8'hAD, 8'hBE, 8'hEF};
    ram[112:115] = {8'hFE, 8'hED, 8'hFA, 8'hCE};

    ram[4:7] = `DEST_ADDR;
    ram[8:11] = `SRC_ADDR;
    ram[12:15] = {8'h03, 8'h00, 8'h00, 8'h00};
  endtask

  // Similate writing to ram whenever master_write = 1;
  initial begin
    forever begin
      @(posedge master_write);
      master_waitrequest = 1'b1;
      @(posedge clk);
      @(posedge clk);
      master_waitrequest = 1'b0;
      ram[master_address] = master_writedata[31:24];
      ram[master_address + 1] = master_writedata[23:16];
      ram[master_address + 2] = master_writedata[15:8];
      ram[master_address + 3] = master_writedata[7:0];
      @(posedge clk);
    end
  end

  // Simulate reading from ram whenvever master_read = 1;
  initial begin
    forever begin
      @(posedge master_read);
      master_waitrequest = 1'b1;
      @(posedge clk);
      @(posedge clk);
      master_waitrequest = 1'b0;
      master_readdata = {ram[master_address], ram[master_address + 1], ram[master_address + 2], ram[master_address + 3]};
      master_readdatavalid = 1'b1;
      @(posedge clk);
    end
  end

  initial begin
    initialize_ram();
    rst_n <= 1'b0;
    master_waitrequest <= '0;
    slave_address <= '0;
    slave_write <= '0;
    slave_writedata <= '0;
    slave_read <= '0;

    @(posedge clk);
    @(posedge clk);
    rst_n <= 1'b1;

    @(posedge clk);
    slave_address <= 4'd1;
    slave_write <= 1'b1;
    slave_writedata <= dest_addr;

    @(posedge clk);
    slave_address <= 4'd2;
    slave_write <= 1'b1;
    slave_writedata <= src_addr;

    @(posedge clk);
    slave_address <= 4'd3;
    slave_write <= 1'b1;
    slave_writedata <= N;

    @(posedge clk);
    slave_address <= 4'd0;
    slave_write <= 1'b1;
    slave_writedata <= '1;

    @(posedge clk);
    slave_write <= 1'b0;

  end


endmodule: tb_rtl_wordcopy
