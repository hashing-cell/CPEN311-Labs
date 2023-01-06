`timescale 1ps / 1ps

module tb_syn_crack();

    logic clk;
    logic rst_n;
    logic en; 
    logic rdy;
    logic [23:0] key; 
    logic key_valid;
    logic [7:0] ct_addr; 
    logic [7:0] ct_rddata;

    doublecrack DUT(.*);

    always #5 clk = ~clk;  // Create clock with period=10

    // Here we will initalize arrays to act as "memories" for this testbench
    logic [7:0] ct_mem_array [0:255];

    // Mimic top level module and memory connections
    initial begin
        #5;
        forever begin
            ct_rddata = ct_mem_array[ct_addr];
            #10;
        end
    end

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

    logic [23:0] answer_key, startsAddr; // startsAddr - start address for the crack module [0,1]
    logic [7:0] ans_pt_array [0:255];
    logic valid_answer;

    task pseudocode_crack();
        logic readable_text;
        logic [7:0] pt_array[0:255];
        logic [8:0] idx;
        logic [7:0] char;
        logic [23:0] s_key_packed;
        logic [7:0] pt_length;

        answer_key = 24'hDEDEDE;

        for (s_key_packed = startsAddr; s_key_packed <= 24'hFFFFFF; s_key_packed = s_key_packed + 24'd2) begin
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

    endtask


    integer idx;
    logic err;
    task verify_plaintext_output();
        if (key != answer_key) begin
            err = 1;
            $display("Error with computed key, expected %d, actual is %d", answer_key, key);
        end

        for (idx = 0; idx < ans_pt_array[0]; idx += 1) begin
            if (DUT.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[idx] != ans_pt_array[idx]) begin
                $display("Discrepancy found at idx %d, expected %d, actual is %d", idx, ans_pt_array[idx], DUT.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[idx]);
                err = 1;
            end
        end
    endtask
    // END OF VERIFICATION CODE

    initial begin
        // TEST for start at 0
        clk = 0;
        rst_n = 0;
        en = 0;
        startsAddr = 24'd0;
        $display("Testing for start = 0 ");
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task4/cracktest1.memh", ct_mem_array);
        #1;

        pseudocode_crack();

        #9;
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
        $display("Comparing computed key and output in pt memory module to expected answers from pseudocode...");
        verify_plaintext_output();

        if (err)
            $display("Tests failed");
        else
            $display("Tests passed");


        // TEST for start at 1
        #10;
        rst_n = 0;
        en = 0;
        startsAddr = 24'd1;
        $display("Testing for start = 1 ");
        $readmemh("../../2022w1-lab3-l1a-lab3-group09/task4/cracktest1.memh", ct_mem_array);
        #1;

        pseudocode_crack();

        #9;
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
        $display("Comparing computed key and output in pt memory module to expected answers from pseudocode...");
        verify_plaintext_output();

        if (err)
            $display("Tests failed");
        else
            $display("Tests passed");
    end
    
endmodule: tb_syn_crack
