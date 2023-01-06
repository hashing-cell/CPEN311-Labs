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
    
    // Here we will initalize arrays to act as "memories" for this testbench
    logic [7:0] ct_mem_array [0:255];
    logic [7:0] pt_mem_array [0:255];

    // Using the pseudocode directly from the instructions
    // Before calling this task, set s_key to the inputted key and set ct_mem_array to the cyphertext to solve
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
        /* Overrite memory */
        $readmemh("../../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", DUT.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
        $readmemh("../../../2022w1-lab3-l1a-lab3-group09/task3/test2.memh", ct_mem_array);
        CLOCK_50 = 0;   KEY[3:0] = 0;  SW = 10'h000018;  err = 0; #10; 
        pseudocode_calc_answer();
        $display("Test: checking rest");

        //Deassert reset and it should start initialization automatically
        KEY[3] = 1;

        wait(DUT.state == DONE); #20;
        assert(DUT.rdy == 1);
        pt_mem_array = DUT.ct.altsyncram_component.m_default.altsyncram_inst.mem_data;
        verify_plaintext_output();


        // /* Overrite memory */
        // $readmemh("../../../2022w1-lab3-l1a-lab3-group09/task3/cracktest4.memh", DUT.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);
        // $readmemh("../../../2022w1-lab3-l1a-lab3-group09/task3/cracktest4.memh", ct_mem_array);
        // CLOCK_50 = 0;   KEY[3:0] = 0;  SW = 10'b1000000000; err = 0; #10; 
        // pseudocode_calc_answer();
        // $display("Test: checking rest");

        // //Deassert reset and it should start initialization automatically
        // KEY[3] = 1;

        // wait(DUT.state == DONE); #20;
        // assert(DUT.rdy == 1);
        // pt_mem_array = DUT.ct.altsyncram_component.m_default.altsyncram_inst.mem_data;
        // verify_plaintext_output(); #10;

        if (err)
            $display("Tests failed");
        else
            $display("Tests passed");

        $stop();
    end


endmodule: tb_rtl_task3
