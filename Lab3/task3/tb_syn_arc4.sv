module tb_syn_arc4();
    logic clk; 
    logic rst_n;
    logic en; 
    logic rdy;
    logic [23:0] key;
    logic [7:0] s_addr;
    logic [7:0] s_rddata; 
    logic [7:0] s_wrdata; 
    logic s_wren;
    logic [7:0] ct_addr; 
    logic [7:0] ct_rddata;
    logic [7:0] pt_addr; 
    logic [7:0] pt_rddata;
    logic [7:0] pt_wrdata; 
    logic pt_wren;

    prga DUT(.*);

    logic [7:0] dump [0:255];
    logic [7:0] memory_len [0:0];
    logic [7:0] memory_array [0:254];
    assign memory_array[0:254] = dump[1:255];

    always #5 clk = ~clk;  // Create clock with period=10

    initial begin
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", memory_len, 0, 0);
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", dump, 0, 256);
        clk = 0;
        rst_n = 0;
        en = 0;
        key = 24'h000018;

        #10;
        rst_n = 1;
        // Check if resetting gets us the right outputs
        if (rdy != 1) begin
            $display("ERROR: Ready signal is not asserted upon reset");
            $stop;
        end

        #10;

        //start the initialiation
        #5;
        en = 1;
        #5;
        en = 0;
        #10;
        if (rdy != 0) begin
            $display("ERROR: Ready signal is not deasserted when enable is deasserted");
            $stop;
        end

        #10; //WRITE state
        #10; //INCREMENT state
        #10; //CHECK_DONE state

        #10000; //After this amount of time the DUT should be finished

        //$display("Tests passed");

    end


endmodule: tb_syn_arc4
