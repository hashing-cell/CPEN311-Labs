`timescale 1ps / 1ps

module tb_syn_task5();

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

    task5 DUT(.*);

    always #5 CLOCK_50 = ~CLOCK_50;  // Create clock with period=10

    //"Known Good" pseudocode solution that can crack ciphertexts and give a sample plaintext solution
    // BEGIN OF VERIFICATION CODE
    task pseudocode_arc(input logic [23:0] s_key_packed, output logic [7:0] pt_array[0:255]);
        logic [7:0] s_array [0:255];
        integer x;
        integer y;
        integer z;
        logic [7:0] temp;
        logic [7:0] message_length;
        logic [7:0] pad;

        logic [7:0] s_key[3];
        s_key[0] = s_key_packed[23:16];
        s_key[1] = s_key_packed[15:8];
        s_key[2] = s_key_packed[7:0];
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
        message_length = DUT.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[0];

            
        for (z = 1; z < message_length; z++) begin
            x = (x+1) % 256;
            y = (y+s_array[x]) % 256;
            temp = s_array[x];
            s_array[x] = s_array[y];
            s_array[y] = temp;
            pad = s_array[(s_array[x] + s_array[y]) % 256];
            pt_array[z] = pad ^ DUT.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[z];
            
        end

        pt_array[0] = message_length;
    endtask

    logic [23:0] answer_key;
    logic [7:0] ans_pt_array [0:255];
    logic valid_answer;
    logic [6:0] answer_HEX0;
    logic [6:0] answer_HEX1;
    logic [6:0] answer_HEX2;
    logic [6:0] answer_HEX3;
    logic [6:0] answer_HEX4;
    logic [6:0] answer_HEX5;
    task pseudocode_crack();
        logic readable_text;
        logic [7:0] pt_array[0:255];
        logic [8:0] idx;
        logic [7:0] char;
        logic [23:0] s_key_packed;
        logic [7:0] pt_length;

        answer_key = 24'hDEDEDE;

        for (s_key_packed = 24'h00; s_key_packed <= 24'hFFFFFF; s_key_packed++) begin
            pseudocode_arc(s_key_packed, pt_array);
            readable_text = 1'b1;
            pt_length = pt_array[0];
            for (idx = 1; idx < pt_length; idx++) begin
                char = pt_array[idx];
                if (char < 8'h20 || char > 8'h7E) begin
                    readable_text = 1'b0;
                    break;
                end
            end

            if (readable_text) begin
                answer_key = s_key_packed;
                ans_pt_array = pt_array;
                valid_answer = 1'b1;
                break;
            end
        end

        answer_HEX0 = ans_display (s_key_packed[3:0]);
        answer_HEX1 = ans_display (s_key_packed[7:4]);
        answer_HEX2 = ans_display (s_key_packed[11:8]);
        answer_HEX3 = ans_display (s_key_packed[15:12]);
        answer_HEX4 = ans_display (s_key_packed[19:16]);
        answer_HEX5 = ans_display (s_key_packed[23:20]);

    endtask

    function [6:0] ans_display;
        input [3:0] key_digit;
        if (valid_answer) begin
            case (key_digit)
                4'b0000: ans_display = 7'b1000000;
                4'b0001: ans_display = 7'b1111001;
                4'b0010: ans_display = 7'b0100100;
                4'b0011: ans_display = 7'b0110000;
                4'b0100: ans_display = 7'b0011001;
                4'b0101: ans_display = 7'b0010010;
                4'b0110: ans_display = 7'b0000010;
                4'b0111: ans_display = 7'b1111000;
                4'b1000: ans_display = 7'b0000000;
                4'b1001: ans_display = 7'b0010000;
                4'b1010: ans_display = 7'b0001000;
                4'b1011: ans_display = 7'b0000011;
                4'b1100: ans_display = 7'b0100001;
                4'b1101: ans_display = 7'b0000110;
                4'b1110: ans_display = 7'b0000110;
                4'b1111: ans_display = 7'b0001110;
                default: ans_display = 7'b0101010; //panic, should never get here
            endcase
        end else begin
            ans_display = 7'b0111111; // No valid key display
        end
    endfunction

    integer idx;
    logic err;
    task verify_hex_display_output();
        if (HEX0 != answer_HEX0) begin
            err = 1;
            $display("Error with key digit at HEX0, expected %d, actual is %d", answer_HEX0, HEX0);
        end
        if (HEX1 != answer_HEX1) begin
            err = 1;
            $display("Error with key digit at HEX1, expected %d, actual is %d", answer_HEX1, HEX1);
        end
        if (HEX2 != answer_HEX2) begin
            err = 1;
            $display("Error with key digit at HEX2, expected %d, actual is %d", answer_HEX2, HEX2);
        end
        if (HEX3 != answer_HEX3) begin
            err = 1;
            $display("Error with key digit at HEX3, expected %d, actual is %d", answer_HEX3, HEX3);
        end
        if (HEX4 != answer_HEX4) begin
            err = 1;
            $display("Error with key digit at HEX4, expected %d, actual is %d", answer_HEX4, HEX4);
        end
        if (HEX5 != answer_HEX5) begin
            err = 1;
            $display("Error with key digit at HEX5, expected %d, actual is %d", answer_HEX5, HEX5);
        end
    endtask

    task check_internal_memory();
        for (idx = 0; idx < ans_pt_array[0]; idx += 1) begin
            if (DUT.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[idx] != ans_pt_array[idx]) begin
                $display("Discrepancy found at idx %d, expected %d, actual is %d", idx, ans_pt_array[idx], DUT.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[idx]);
                err = 1;
            end
        end
    endtask
    // END OF VERIFICATION CODE

    initial begin
        CLOCK_50 = 0;

        // TEST 1
        err = 0;
        KEY[3:0] = 0;
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task4/cracktest1.memh", DUT.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem); 
        #1;

        pseudocode_crack();
        #9;
        //Deassert reset and it should start initialization automatically
        KEY[3] = 1;

        #10;
        
        // Wait for it to finish
        wait(LEDR[9] == 0);
        $display("Checking against expected output...");
        #1;
        verify_hex_display_output();
        check_internal_memory();
        if (err) begin
            $display("TEST1 failed");
            //$stop;
        end
        else
            $display("TEST1 passed");

        #9;

        // TEST 2
        err = 0;
        KEY[3:0] = 0;
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task4/cracktest2.memh", DUT.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);
        #1;

        pseudocode_crack();
        #9;
        //Deassert reset and it should start initialization automatically
        KEY[3] = 1;

        #10;
        
        // Wait for it to finish
        wait(LEDR[9] == 0);
        $display("Checking against expected output...");
        #1;
        verify_hex_display_output();
        check_internal_memory();
        if (err) begin
            $display("TEST2 failed");
            //$stop;
        end
        else
            $display("TEST2 passed");
    end

endmodule: tb_syn_task5
