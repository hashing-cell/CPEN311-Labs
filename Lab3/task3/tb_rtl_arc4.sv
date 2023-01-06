`timescale 1ps / 1ps

module tb_rtl_arc4();
    logic clk; 
    logic rst_n;
    logic en; 
    logic rdy;
    logic [23:0] key;
    logic [7:0] ct_addr; 
    logic [7:0] ct_rddata;
    logic [7:0] pt_addr; 
    logic [7:0] pt_rddata; 
    logic [7:0] pt_wrdata; 
    logic pt_wren;

    arc4 DUT(.*);

    always #5 clk = ~clk;  // Create clock with period=10

     // Here we will initalize arrays to act as "memories" for this testbench
    logic [7:0] ct_mem_array [0:255];
    logic [7:0] pt_mem_array [0:255];

    // Mimic top level module and memory connections
    initial begin
        #5;
        forever begin
            if (pt_wren) begin
                pt_mem_array[pt_addr] = pt_wrdata;
            end else begin
                pt_rddata = pt_mem_array[pt_addr];
            end

            ct_rddata = ct_mem_array[ct_addr];
            #10;
        end
    end

    //Using the pseudocode directly from the instructions
    //Before calling this task, set s_key to the inputted key and set ct_mem_array to the cyphertext to solve
    logic [7:0] s_array [0:255];
    logic [7:0] s_key[3];
    logic [7:0] temp;
    integer x;
    integer y;
    integer z;
    logic [7:0] message_length;
    logic [7:0] pt_array [0:255];
    logic [7:0] pad;
    task pseudocode_calc_answer();
        for (x = 0; x < 256; x++) begin
            s_array[x] = x;
        end

        y = 0;
        for (x = 0; x < 256; x++) begin
            y = (y + s_array[x] + s_key[x % 3]) % 256;
            temp = s_array[x];
            s_array[x] = s_array[y];
            s_array[y] = temp;
        end

        x = 0;
        y = 0;
        message_length = ct_mem_array[0];
        for (z = 1; z < message_length; z++) begin
            x = (x+1) % 256;
            y = (y+s_array[x]) % 256;
            temp = s_array[x];
            s_array[x] = s_array[y];
            s_array[y] = temp;
            pad = s_array[(s_array[x] + s_array[y]) % 256];
            pt_array[z] = pad ^ ct_mem_array[z];
        end

        pt_array[0] = message_length;
    endtask

    integer idx;
    logic err;
    task verify_plaintext_output();
        for (idx = 0; idx < message_length; idx += 1) begin
            if (pt_mem_array[idx] != pt_array[idx]) begin
                $display("Discrepancy found at idx %d, expected %d, actual is %d", idx, pt_array[idx], pt_mem_array[idx]);
                err = 1;
            end
        end
    endtask

    initial begin
        err = 0;
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

        #10;

        //TEST1: TRY CRACKING cyphertext test2.memh, with key 0x000018
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", ct_mem_array); 
        #1;
        s_key[0] = 0;
        s_key[1] = 0;
        s_key[2] = 8'h18;
        {key[23:16], key[15:8], key[7:0]} = {8'h00, 8'h00, 8'h18};
        pseudocode_calc_answer();

        #9;

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

        // Wait for TEST1 to finish
        wait(rdy == 1);
        $display("TEST1: Comparing output pt_mem_array to expected pt_array from pseudocode...");
        verify_plaintext_output();
        if (err)
            $display("Test1 failed");
        else
            $display("Test1 passed");
        #5;
        
        //TEST2: TRY CRACKING cyphertext test1.memh, with key 0x1E4600
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task3/test1.memh", ct_mem_array); 
        #1;
        s_key[0] = 8'h1E;
        s_key[1] = 8'h46;
        s_key[2] = 8'h00;
        {key[23:16], key[15:8], key[7:0]} = {8'h1E, 8'h46, 8'h00};
        pseudocode_calc_answer();

        #9;
        //start the initialiation
        #5;
        en = 1;
        #5;
        en = 0;
        #10;
        if (rdy != 0) begin
            $display("ERROR: Ready signal is not deasserted when enable is deasserted");
            //$stop;
        end

        // Wait for TEST2 to finish
        wait(rdy == 1);
        $display("TEST2: Comparing output pt_mem_array to expected pt_array from pseudocode...");
        verify_plaintext_output();
        if (err)
            $display("Test2 failed");
        else
            $display("Test2 passed");

    end

endmodule: tb_rtl_arc4
