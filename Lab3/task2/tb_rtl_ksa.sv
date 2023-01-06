`timescale 1ps / 1ps
`define MAX_LENG 9'd255

module tb_rtl_ksa();
    /* Registers */
    logic clk, rst_n, en, rdy, wren;
    logic [23:0] key;
    logic [7:0] addr, rddata, wrdata;
    integer i; 

    /* Module Instantiation */
    ksa DUT(.*);

    typedef enum {
        INIT, 
        CHECK_LOOP, 
        LOAD_SI, 
        COMP_J,  
        LOAD_SJ, 
        WRITE_SI, 
        WRITE_SJ, 
        DONE
    } state_t;

    always #5 clk = ~clk;  // Create clock with period=10

    // Here we will initalize arrays to act as "memories" for this testbench
    logic [7:0] s_mem_array [0:255];
    // Mimic top level module and memory connections
    initial begin
        #5;
        forever begin
            if (wren) begin
                s_mem_array[addr] = wrdata;
            end else begin
                rddata = s_mem_array[addr];
            end
            #10;
        end
    end

    //Using the pseudocode directly from task1 and task2 we initalize the s_array using key = 0x00033C
    logic [7:0] s_array [0:255];
    logic [7:0] s_key[3];
    logic [7:0] temp;
    integer x;
    integer y;
    initial begin
        #1;
        s_key[0] = 8'h00;
        s_key[1] = 8'h03;
        s_key[2] = 8'h3C;
        y = 0;
        for (x = 0; x < 256; x++) begin
            s_array[x] = x;
        end
        s_mem_array[0:255] = s_array;
        for (x = 0; x < 256; x++) begin
            y = (y + s_array[x] + s_key[x % 3]) % 256;
            temp = s_array[x];
            s_array[x] = s_array[y];
            s_array[y] = temp;
        end
    end

    integer idx;
    logic err;
    task verify_plaintext_output();
        for (idx = 0; idx < 256; idx += 1) begin
            if (s_mem_array[idx] != s_array[idx]) begin
                $display("Discrepancy found at idx %d, expected %d, actual is %d", idx, s_array[idx], s_mem_array[idx]);
                err = 1;
            end
        end
    endtask


    /* Running Testbenches */
    initial begin
        err = 0;
        clk = 0;
        rst_n = 0;
        en = 0;
        key = 24'h00033C;

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

        // Wait for it to finish
        wait(rdy == 1);
        $display("Comparing output pt_mem_array to expected pt_array from pseudocode...");
        verify_plaintext_output();
        if (err)
            $display("Tests failed");
        else
            $display("Tests passed");
    end

endmodule: tb_rtl_ksa
