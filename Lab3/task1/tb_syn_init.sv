`timescale 1ps / 1ps

module tb_syn_init();

    logic clk; 
    logic rst_n;
    logic en; 
    logic rdy;
    logic [7:0] addr; 
    logic [7:0] wrdata; 
    logic wren;

    init DUT(.*);

    integer check_array[0:255];
    integer check_array_idx;

    integer wren_count;

    // Fill the array which will be used to check against the results of the DUT
    // This represents the pseudo-code of the given assignment
    initial begin
        for (check_array_idx = 0; check_array_idx < 256; check_array_idx += 1) begin
            check_array[check_array_idx] = check_array_idx;
        end
    end

    // Store all wrdata and addr results in an array, and then check them
    initial begin
        wren_count = 0;
        forever begin
            wait(wren == 1);
            if (addr != wren_count) begin
                $display("ERROR: At Wren = 1, Address is %d, expected address %d", addr, wren_count);
                $display("Error occured at simulation time ", $time);
                $stop;
            end
            if (wrdata != check_array[wren_count]) begin
                $display("ERROR: At Wren = 1, Wrdata is %d, expected wrdata %d", wrdata, check_array[wren_count]);
                $display("Error occured at simulation time ", $time);
                $stop;
            end
            wren_count += 1;
            #20;
        end
    end

    always #5 clk = ~clk;  // Create clock with period=10

    initial begin
        clk = 0;
        rst_n = 0;
        en = 0;

        #10;
        rst_n = 1;
        // Check if resetting gets us the right outputs
        if (rdy != 1) begin
            $display("ERROR: Ready signal is not asserted upon reset");
            $stop;
        end
        // Check that wren is deasserted at rest
        if (wren != 0) begin
            $display("ERROR: Wren signal should not be asserted");
            $stop;
        end

        #10;

        //start the initialiation
        #5;
        en = 1;
        #15;
        en = 0;
        #10;
        if (rdy != 0) begin
            $display("ERROR: Ready signal is not deasserted when enable is deasserted");
            $stop;
        end

        #10; //WRITE state
        #10; //INCREMENT state
        #10; //CHECK_DONE state

        #7800; //After this amount of time the DUT should be finished

        $display("Tests passed");

    end

endmodule: tb_syn_init
