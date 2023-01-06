`timescale 1ps/1ps
`define W_ADDR {8'h00, 8'h00, 8'h00, 8'h64}
`define A_ADDR {8'h00, 8'h00, 8'h0F, 8'hA0}
`define MEM_MAP_ADDR 32'd000

module tb_rtl_dot();
  logic clk; 
  logic rst_n;
  // slave (CPU-facing)
  logic slave_waitrequest;
  logic [3:0] slave_address;
  logic slave_read;
  logic [31:0] slave_readdata;
  logic slave_write;
  logic [31:0] slave_writedata;
           // master (memory-facing)
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

  dot dot(.*);

  logic [7:0] ram [0:30000];

  logic [31:0] a_addr = `A_ADDR;
  logic [31:0] w_addr  = `W_ADDR;
  logic [31:0] N         = 32'd784;

  logic [31:0] vec0_w_array [0:783];
  logic [31:0] vec0_ifmap_array [0:783];


  // initialize simulated ram
  task initialize_ram();
    integer i;
    integer j;
    
    $readmemh("/home/jefferson/school/cpen311/2022w1-lab4-l1a-lab4-group03/task6/vec0_w.memh", vec0_w_array);
    $readmemh("/home/jefferson/school/cpen311/2022w1-lab4-l1a-lab4-group03/task6/vec0_ifmap.memh", vec0_ifmap_array);

    for (i = 0; i < 30000; i++) begin
      ram[i] = 32'h00;
    end

    // Load W from mem.h file into ram
    j = 0;
    for (i = 0; i < 784; i += 1) begin
      {ram[100 + j], ram[100 + j + 1], ram[100 + j + 2], ram[100 + j + 3]} = vec0_w_array[i];
      j += 4;
    end

    // Load ifmap from mem.h into ram
    j = 0;
    for (i = 0; i < 784; i += 1) begin
      {ram[4000 + j], ram[4000 + j + 1], ram[4000 + j + 2], ram[4000 + j + 3]} = vec0_ifmap_array[i];
      j += 4;
    end

    // checking [1 2 3 4] * [5 6 7 8] = 70 = 0x46

    // W
    // ram[100:103] = {8'h00, 8'h01, 8'h00, 8'h00}; // Q16.16
    // ram[104:107] = {8'h00, 8'h02, 8'h00, 8'h00}; // Q16.16
    // ram[108:111] = {8'h00, 8'h03, 8'h00, 8'h00}; // Q16.16
    // ram[112:115] = {8'h00, 8'h04, 8'h00, 8'h00}; // Q16.16

    // A
    // ram[200:203] = {8'h00, 8'h05, 8'h00, 8'h00}; // Q16.16
    // ram[204:207] = {8'h00, 8'h06, 8'h00, 8'h00}; // Q16.16
    // ram[208:211] = {8'h00, 8'h07, 8'h00, 8'h00}; // Q16.16
    // ram[212:215] = {8'h00, 8'h08, 8'h00, 8'h00}; // Q16.16

    ram[8:11] = `A_ADDR;
    ram[12:15] = `W_ADDR;
    ram[20:23] = {8'h00, 8'h00, 8'h03, 8'h10};
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
    slave_address <= 4'd3;
    slave_write <= 1'b1;
    slave_writedata <= a_addr;

    @(posedge clk);
    slave_address <= 4'd2;
    slave_write <= 1'b1;
    slave_writedata <= w_addr;

    @(posedge clk);
    slave_address <= 4'd5;
    slave_write <= 1'b1;
    slave_writedata <= N;

    @(posedge clk);
    slave_address <= 4'd0;
    slave_write <= 1'b1;
    slave_writedata <= '1;

    @(posedge clk);
    slave_write <= 1'b0;
    slave_read  <= 1'b1;
    slave_address <= '0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    wait(dot.curr_state == '0);
    $display("sum: %x", slave_readdata);
    @(posedge clk);
    slave_read <= 1'b0;

    @(posedge clk);

  end


endmodule: tb_rtl_dot
