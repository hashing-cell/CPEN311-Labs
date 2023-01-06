module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);
    logic pt_wren;
    logic [7:0] pt_addr;
    logic [7:0] pt_wrdata;
    logic [7:0] pt_rddata;

    logic rdy_c1, rdy_c2, en1, en2, ct1_wren, ct2_wren, key_valid_c1, key_valid_c2, en_arc4, rdy_arc4;
    logic [23:0] key_c1, key_c2;

    logic [7:0] ct1_addr, ct2_addr, ct1_rddata, ct2_rddata, c1_ct1_addr, c2_ct2_addr, c1_ct1_rddata, c2_ct2_rddata, ct_addr_arc4;

    logic ct_sel_top;

    logic [8:0] ct_addr_for_fill;
    logic ct_wren_for_fill;
    logic update_ct_addr;
    enum {CT_FILL, CT_CRACK} ct_sel;

    logic start;
    logic init;

    logic [23:0] answer_key;
    logic answer_key_valid;

    enum {C1_ANS, C2_ANS, C_NO_ANS, C_NO_CHANGE} key_ans_sel;

    // this memory must have the length-prefixed plaintext if key_valid
    pt_mem pt(pt_addr, clk, pt_wrdata, pt_wren, pt_rddata);

    // Doublecrack has its own ct_mem instiantiation to prevent address conflicts from 2 crack modules
    ct_mem ct1(ct1_addr, clk, ct_rddata, ct1_wren, ct1_rddata);
    ct_mem ct2(ct2_addr, clk, ct_rddata, ct2_wren, ct2_rddata);


    // for this task only, you may ADD ports to crack
    crack c1(clk, rst_n, en1, rdy_c1, key_c1, key_valid_c1, c1_ct1_addr, c1_ct1_rddata, 24'd0);
    crack c2(clk, rst_n, en2, rdy_c2, key_c2, key_valid_c2, c2_ct2_addr, c2_ct2_rddata, 24'd1);

    // arc4 instantiation for valid key compute
    arc4 a4_key_valid(clk, rst_n, en_arc4, rdy_arc4, answer_key, ct_addr_arc4, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);

    /* List of all states use in the computation */
    typedef enum {
        WAIT_ENABLE,
        INIT,
        FILL_INTERNAL_CT_MEM_READ,
        FILL_INTERNAL_CT_MEM_WAIT,
        FILL_INTERNAL_CT_MEM_WRITE,
        CT_MEM_INCREMENT,
        START_CRACKS,
        WAIT_CRACKS_START,
        WAIT_CRACK_DONE,
        CRACKS_CHECK_VALID,
        ARC4_FILL_PT_MEM,
        ARC4_WAIT_START,
        ARC4_WAIT_DONE,
        CRACK_SUCCESSFUL,
        CRACK_UNSUCCESSFUL
    } state_t;

    state_t curr_state;
    state_t next_state;

    /* Updates on the current states on each clk cycle */
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

    // internal ct mem multiplexer control block
    always_comb begin
        c1_ct1_rddata = ct1_rddata;
        c2_ct2_rddata = ct2_rddata;
        if (ct_sel == CT_FILL) begin
            ct1_addr = ct_addr_for_fill[7:0];
            ct2_addr = ct_addr_for_fill[7:0];
            ct1_wren = ct_wren_for_fill;
            ct2_wren = ct_wren_for_fill;
        end else if (ct_sel == CT_CRACK) begin
            ct1_addr = c1_ct1_addr;
            ct2_addr = c2_ct2_addr;
            ct1_wren = 1'b0;
            ct2_wren = 1'b0;
        end else begin
            //panic
            ct1_addr = ct_addr_for_fill[7:0];
            ct2_addr = ct_addr_for_fill[7:0];
            ct1_wren = 1'b0;
            ct2_wren = 1'b0;
        end
    end

    always_comb begin
        if (ct_sel_top)
            ct_addr = ct_addr_for_fill[7:0];
        else
            ct_addr = ct_addr_arc4;
    end

    // internal pt mem control block
    always_ff @(posedge clk) begin
        if (key_ans_sel == C1_ANS) begin
            answer_key <= key_c1;
            answer_key_valid <= key_valid_c1;
        end else if (key_ans_sel == C2_ANS) begin
            answer_key <= key_c2;
            answer_key_valid <= key_valid_c2;
        end else if (key_ans_sel == C_NO_ANS) begin
            answer_key <= 24'hFFFFFF;
            answer_key_valid <= 1'b0;
        end
    end

    // ct filling addr increment register
    always_ff @(posedge clk) begin
        if (!rst_n || init) begin
            ct_addr_for_fill <= 9'd0;
        end else if (update_ct_addr) begin
            ct_addr_for_fill <= ct_addr_for_fill + 9'd1;
        end
    end 

    /* Combinational clock */
    always_comb begin
        case (curr_state)
            /* WAIT_ENABLE state: wait for enable to turn on */
            WAIT_ENABLE: begin
                init = 1'b1;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                if (start) 
                    next_state = INIT;
                else
                    next_state = WAIT_ENABLE;
            end

            /* INIT state: initialize all variables */
            INIT: begin
                init = 1'b1;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_ANS;
                en_arc4 = 1'b0;
                next_state = FILL_INTERNAL_CT_MEM_READ;
            end

            /* FILL_INTERNAL_CT_MEM_READ state: read CT mem */
            FILL_INTERNAL_CT_MEM_READ: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                if (ct_addr_for_fill <= 9'd255)
                    next_state = FILL_INTERNAL_CT_MEM_WAIT;
                else
                    next_state = START_CRACKS;
            end

            /* FILL_INTERNAL_CT_MEM_WAIT state: wait for CT mem data */
            FILL_INTERNAL_CT_MEM_WAIT: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                next_state = FILL_INTERNAL_CT_MEM_WRITE;
            end

            /* FILL_INTERNAL_CT_MEM_WRITE state: write CT data to both CT mem use for each crack module */
            FILL_INTERNAL_CT_MEM_WRITE: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b1;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                next_state = CT_MEM_INCREMENT;
            end

            /*CT_MEM_INCREMENT state: increment reading register by 1 */
            CT_MEM_INCREMENT: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_FILL;
                update_ct_addr = 1'b1;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                next_state = FILL_INTERNAL_CT_MEM_READ;
            end

            /* START_CRACKS state: copy is done and ready to run crack module */
            START_CRACKS: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b1, 1'b1, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                next_state = WAIT_CRACKS_START;
            end

            /*WAIT_CRACKS_START state: wait for crack modules to start */
            WAIT_CRACKS_START: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                if (!rdy_c1 && !rdy_c2)
                    next_state = WAIT_CRACK_DONE;
                else
                    next_state = WAIT_CRACKS_START;
            end

            /* WAIT_CRACK_DONE state: crack modules complete the process */
            WAIT_CRACK_DONE: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                key_ans_sel = C_NO_CHANGE;
                en_arc4 = 1'b0;
                if (rdy_c1 || rdy_c2)
                    next_state = CRACKS_CHECK_VALID;
                else
                    next_state = WAIT_CRACK_DONE;
            end

            /* CRACKS_CHECK_VALID state: checking if the key is correct */
            CRACKS_CHECK_VALID: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                en_arc4 = 1'b0;
                if (key_valid_c1 == 1'b1) begin
                    next_state = ARC4_FILL_PT_MEM;
                    key_ans_sel = C1_ANS;
                end else if (key_valid_c2 == 1'b1) begin
                    next_state = ARC4_FILL_PT_MEM;
                    key_ans_sel = C2_ANS;
                end else begin
                    next_state = CRACK_UNSUCCESSFUL; //no solution found
                    key_ans_sel = C_NO_ANS;
                end
            end

            /*ARC4_FILL_PT_MEM state: start filling all the pt mem from crack */
            ARC4_FILL_PT_MEM: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b0};
                en_arc4 = 1'b1;
                key_ans_sel = C_NO_CHANGE;
                next_state = ARC4_WAIT_START;
            end

            /* ARC4_WAIT_START state: wait for reading is ready */
            ARC4_WAIT_START: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b0};
                en_arc4 = 1'b0;
                key_ans_sel = C_NO_CHANGE;
                if (!rdy_arc4)
                    next_state = ARC4_WAIT_DONE;
                else
                    next_state = ARC4_WAIT_START;
            end

            /* ARC4_WAIT_DONE state: completed reading and write current pt memory */
            ARC4_WAIT_DONE: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b0};
                en_arc4 = 1'b0;
                key_ans_sel = C_NO_CHANGE;
                if (rdy_arc4)
                    next_state = CRACK_SUCCESSFUL;
                else
                    next_state = ARC4_WAIT_DONE;
            end

            /* CRACK_SUCCESSFUL state: completed this computation on cracking and it success */
            CRACK_SUCCESSFUL: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                en_arc4 = 1'b0;
                key_ans_sel = C_NO_CHANGE;
                next_state = WAIT_ENABLE;
            end

            /* CRACK_UNSUCCESSFUL state: completed this computation on cracking and it fails */
            CRACK_UNSUCCESSFUL: begin
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b1};
                en_arc4 = 1'b0;
                key_ans_sel = C_NO_ANS;
                next_state = WAIT_ENABLE;
            end

            /* Unknown state */
            default: begin
                //panic
                init = 1'b0;
                ct_wren_for_fill = 1'b0;
                ct_sel = CT_CRACK;
                update_ct_addr = 1'b0;
                {en1, en2, ct_sel_top} = {1'b0, 1'b0, 1'b0};
                en_arc4 = 1'b0;
                key_ans_sel = C_NO_ANS;
                next_state = WAIT_ENABLE;
            end
        endcase

        /* Setting key and key status */
        key = answer_key;
        key_valid = answer_key_valid;
    end
    
endmodule: doublecrack
