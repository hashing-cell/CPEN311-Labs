module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic pt_wren;
    logic [7:0] pt_addr;
    logic [7:0] pt_wrdata;
    logic [7:0] pt_rddata;

    logic pt_wren_arc4;
    logic pt_wren_crack;
    logic [7:0] pt_addr_arc4;
    logic [8:0] pt_addr_crack;

    logic pt_addr_crack_reset;

    assign pt_wren_crack = 1'b0; // We will always read in the crack module

    enum {S_ARC4, S_CRACK_ZERO, S_CRACK_NUM} pt_addr_select;

    logic en_arc4;
    logic rdy_arc4;

    logic [24:0] test_key;
    logic [7:0] pt_length;

    assign key = test_key[23:0];

    logic update_test_key;
    logic update_pt_length;
    logic pt_addr_increment;

    typedef enum {
        WAIT_ENABLE,
        INIT,
        CHECK_TESTKEY,
        EXECUTE_ARC4,
        WAIT_ARC4_START,
        WAIT_ARC4_DONE,
        GET_PT_LENGTH,
        WAIT_PT_LENGTH,
        CHECK_PT_LENGTH,
        TEST_HUMAN_READABLE,
        PT_INCREMENT,
        TESTKEY_INCREMENT,
        CRACK_SUCCESSFUL,
        CRACK_UNSUCCESSFUL
    } state_t;

    state_t curr_state;
    state_t next_state;

    logic start;

    logic init;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);

    arc4 a4(clk, rst_n, en_arc4, rdy_arc4, test_key[23:0], ct_addr, ct_rddata, pt_addr_arc4, pt_rddata, pt_wrdata, pt_wren_arc4);

    // test_key register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            test_key <= 25'h000000;
        else if (update_test_key)
            test_key <= test_key + 25'd1;
    end

     // pt_length register logic block
    always_ff @(posedge clk) begin
        if (update_pt_length)
            pt_length <= pt_rddata;
    end

    // pt_addr_crack register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init || pt_addr_crack_reset)
            pt_addr_crack <= 1;
        else if (pt_addr_increment)
            pt_addr_crack <= pt_addr_crack + 9'd1;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            curr_state <= WAIT_ENABLE;
            rdy <= 1;
            start <= 0;
        end 
        else if (en) begin
            start <= 1;
        end
        else if (start) begin
			curr_state <= next_state;
            if (curr_state == CRACK_SUCCESSFUL || curr_state == CRACK_UNSUCCESSFUL) begin
                start <= 0;
                rdy <= 1;
            end else begin
                rdy <= 0;
            end 
        end
    end

    // Multiplexer for which module's pt_addr to use for the pt_mem
    always_comb begin
        case (pt_addr_select)
            S_ARC4: begin
                pt_addr = pt_addr_arc4;
                pt_wren = pt_wren_arc4;
            end
            S_CRACK_ZERO: begin
                pt_addr = 8'b00000000;
                pt_wren = pt_wren_crack;
            end
            S_CRACK_NUM: begin
                pt_addr = pt_addr_crack[7:0];
                pt_wren = pt_wren_crack;
            end
            default: begin
                //panic
                pt_addr = 8'b11111111;
                pt_wren = 1'b0;
            end
        endcase
    end

    // key valid logic block
    always_ff @(posedge clk) begin
        if (next_state == CRACK_SUCCESSFUL)
            key_valid <= 1'b1;
        if (next_state == CRACK_UNSUCCESSFUL)
            key_valid <= 1'b0;
        if (next_state == INIT)
            key_valid <= 1'b0;
    end

    // State traversal and write enable/read address logic block
    always_comb begin
        case (curr_state)
            WAIT_ENABLE: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_crack_reset = 1'b0;
                pt_addr_select = S_ARC4;
                if (start) 
                    next_state = INIT;
                else
                    next_state = WAIT_ENABLE;
            end
            INIT: begin
                init = 1'b1;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                next_state = CHECK_TESTKEY;
            end
            CHECK_TESTKEY: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                if (test_key <= 25'hFFFFFF) //0xFFFFFF is the maximum 3 byte number
                    next_state = EXECUTE_ARC4;
                else
                    next_state = CRACK_UNSUCCESSFUL;
            end
            EXECUTE_ARC4: begin
                init = 1'b0;
                en_arc4 = 1'b1;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                next_state = WAIT_ARC4_START;
            end
            WAIT_ARC4_START: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                if (!rdy_arc4) 
                    next_state = WAIT_ARC4_DONE;
                else
                    next_state = WAIT_ARC4_START;
            end
            WAIT_ARC4_DONE: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                if (rdy_arc4) 
                    next_state = GET_PT_LENGTH;
                else
                    next_state = WAIT_ARC4_DONE;
            end
            GET_PT_LENGTH: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b1;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_ZERO;
                pt_addr_crack_reset = 1'b0;
                next_state = WAIT_PT_LENGTH;
            end
            WAIT_PT_LENGTH: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b1;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_ZERO;
                pt_addr_crack_reset = 1'b1;
                next_state = CHECK_PT_LENGTH;
            end
            CHECK_PT_LENGTH: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_NUM;
                pt_addr_crack_reset = 1'b0;
                if (pt_addr_crack < {1'b0, pt_length}) 
                    next_state = TEST_HUMAN_READABLE;
                else
                    next_state = CRACK_SUCCESSFUL;
            end
            TEST_HUMAN_READABLE: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_NUM;
                pt_addr_crack_reset = 1'b0;
                if (pt_rddata < 8'h20 || pt_rddata > 8'h7E)
                    next_state = TESTKEY_INCREMENT; //not human readable
                else
                    next_state = PT_INCREMENT; //current character is human readable
            end
            PT_INCREMENT: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b1;
                pt_addr_select = S_CRACK_NUM;
                pt_addr_crack_reset = 1'b0;
                next_state = CHECK_PT_LENGTH;
            end
            TESTKEY_INCREMENT: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b1;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_ARC4;
                pt_addr_crack_reset = 1'b0;
                next_state = CHECK_TESTKEY;
            end
            CRACK_SUCCESSFUL: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_NUM;
                pt_addr_crack_reset = 1'b0;
                next_state = WAIT_ENABLE;
            end
            CRACK_UNSUCCESSFUL: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                update_test_key = 1'b0;
                update_pt_length = 1'b0;
                pt_addr_increment = 1'b0;
                pt_addr_select = S_CRACK_NUM;
                pt_addr_crack_reset = 1'b0;
                next_state = WAIT_ENABLE;
            end
            default: begin
                init = 1'b0;
                en_arc4 = 1'b0;
                next_state = WAIT_ENABLE;
            end
        endcase
    end

endmodule: crack