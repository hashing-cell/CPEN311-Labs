`timescale 1ps/1ps
`define W_ADDR {8'h00, 8'h00, 8'h00, 8'h64}
`define A_ADDR {8'h00, 8'h00, 8'h0F, 8'hA0}
`define MEM_MAP_ADDR 32'd000

module tb_rtl_dotopt();
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

  logic master2_waitrequest;
  logic [31:0] master2_address;
  logic master2_read; 
  logic [31:0] master2_readdata; 
  logic master2_readdatavalid;
  logic master2_write; 
  logic [31:0] master2_writedata;

  initial begin
    clk = 1'b0;
    forever begin
      #5 clk = ~clk;
    end
  end

  dotopt dotopt(.*);

  logic [7:0] ram [0:30000];

  logic [31:0] a_addr = `A_ADDR;
  logic [31:0] w_addr  = `W_ADDR;
  logic [31:0] N         = 32'd784;

  logic [31:0] vec0_w_array [0:783];
  logic [31:0] vec0_ifmap_array [0:783];

  logic [7:0] bank0 [0:4095];
  logic [7:0] bank1 [0:4095];

  // initialize simulated ram
  task initialize_ram();
    integer i;
    integer j;
    
    $readmemh("../../2022w1-lab4-l1a-lab4-group03/task6/vec0_w.memh", vec0_w_array);
    $readmemh("../../2022w1-lab4-l1a-lab4-group03/task6/vec0_ifmap.memh", vec0_ifmap_array);

    for (i = 0; i < 30000; i++) begin
      ram[i] = 32'h00;
    end

    // Load W from mem.h file into bank0
    j = 0;
    for (i = 0; i < 784; i += 1) begin
      {bank0[j], bank0[j + 1], bank0[j + 2], bank0[j + 3]} = vec0_w_array[i];
      j += 4;
    end

    // Load ifmap from mem.h into bank1
    j = 0;
    for (i = 0; i < 784; i += 1) begin
      {bank1[j], bank1[j + 1], bank1[j + 2], bank1[j + 3]} = vec0_ifmap_array[i];
      j += 4;
    end

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

  // Similate writing to ram whenever master2_write = 1;
  initial begin
    forever begin
      @(posedge master2_write);
      master2_waitrequest = 1'b1;
      @(posedge clk);
      @(posedge clk);
      master2_waitrequest = 1'b0;
      ram[master2_address] = master2_writedata[31:24];
      ram[master2_address + 1] = master2_writedata[23:16];
      ram[master2_address + 2] = master2_writedata[15:8];
      ram[master2_address + 3] = master2_writedata[7:0];
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
      master_readdata = {bank0[master_address], bank0[master_address + 1], bank0[master_address + 2], bank0[master_address + 3]};
      master_readdatavalid = 1'b1;
      @(posedge clk);
    end
  end

  // Simulate reading from ram whenvever master2_read = 1;
  initial begin
    forever begin
      @(posedge master2_read);
      master2_waitrequest = 1'b1;
      @(posedge clk);
      @(posedge clk);
      master2_waitrequest = 1'b0;
      master2_readdata = {bank1[master2_address], bank1[master2_address + 1], bank1[master2_address + 2], bank1[master2_address + 3]};
      master2_readdatavalid = 1'b1;
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
    slave_writedata <= '0;

    @(posedge clk);
    slave_address <= 4'd2;
    slave_write <= 1'b1;
    slave_writedata <= '0;

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
    wait(dotopt.curr_state == '0);
    $display("sum: %x", slave_readdata);
    @(posedge clk);
    slave_read <= 1'b0;

    @(posedge clk);

  end
endmodule: tb_rtl_dotopt
