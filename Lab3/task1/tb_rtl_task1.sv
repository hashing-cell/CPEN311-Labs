`timescale 1ps / 1ps

module tb_rtl_task1();
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

    task1 DUT(.*);

    always #5 CLOCK_50 = ~CLOCK_50;  // Create clock with period=10

    integer check_array[0:255];
    integer check_array_idx;

    integer idx;

    logic err;

    // Fill the array which will be used to check against the results of the DUT
    // This represents the pseudo-code of the given assignment
    initial begin
        for (check_array_idx = 0; check_array_idx < 256; check_array_idx += 1) begin
            check_array[check_array_idx] = check_array_idx;
        end
    end

    // This task will compare the data in the actual memory with the check_array
    task verify_memory_data();
        for (idx = 0; idx < 256; idx += 1) begin
            if (check_array[idx] != DUT.s.altsyncram_component.m_default.altsyncram_inst.mem_data[idx]) begin
                $display("Discrepancy found at idx %d, expected %d, actual is %d", idx, check_array[idx], 
                    DUT.s.altsyncram_component.m_default.altsyncram_inst.mem_data[idx]);
                err = 1;
            end
        end
    endtask

    initial begin
        CLOCK_50 = 0;
        KEY[3:0] = 0;
        err = 0;

        #10;

        //Deassert reset and it should start initialization automatically
        KEY[3] = 1;

        #8000; //After this amount of time the DUT should be finished

        // Check if memory holds expected values
        verify_memory_data();

        if (err)
            $display("Tests failed");
        else
            $display("Tests passed");

    end

endmodule: tb_rtl_task1
