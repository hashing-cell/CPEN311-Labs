module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    typedef enum { 
		WAIT_ENABLE,
        PT_ADDR_0_WRITE_AND_INIT,
        CHECK_LOOP_DONE,
        CALC_I,
        S_ADDR_I_READ,
        S_ADDR_I_WAIT,
        CALC_J,
        S_ADDR_J_READ,
        S_ADDR_J_WAIT,
        SWAP_WRITE_SI,
        SWAP_WRITE_SJ,
        S_ADDR_IJ_LOAD,
        S_ADDR_IJ_WAIT,
        PT_ADDR_K_WRITE,
        DONE
	} state_t;

    state_t curr_state;
    state_t next_state;

    logic start;

    logic init;
    
    logic [8:0] i;
    logic [8:0] j;

    logic [7:0] si;
    logic [7:0] sj;

    logic [7:0] s_ij;

    logic [8:0] k; 

    logic update_i;
    logic update_j;
    logic update_si;
    logic update_sj;
    logic update_s_ij;
    logic update_k;

    logic [7:0] message_length;

    logic [7:0] si_sj_mod;

    // STATE MACHINE CLOCK LOGIC BLOCK
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
            if (curr_state == DONE) begin
                start <= 0;
                rdy <= 1;
            end else begin
                rdy <= 0;
            end 
        end
    end

    // i register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            i <= 0;
        else if (update_i)
            i <= (i + 1'd1) % 9'd256;
    end

    // j register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            j <= 0;
        else if (update_j)
            j <= (j + si) % 9'd256;
    end

    // si register logic block
    always_ff @(posedge clk) begin
        if (update_si)
            si <= s_rddata;
    end

    // sj register logic block
    always_ff @(posedge clk) begin
        if (update_sj)
            sj <= s_rddata;
    end

    // s[i+j] register logic block
    always_ff @(posedge clk) begin
        if (update_s_ij)
            s_ij <= s_rddata;
    end

    // k register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            k <= 1;
        else if (update_k)
            k <= k + 9'd1;
    end

    // message length register logic block
    always_ff @(posedge clk) begin
        if (ct_addr == 0)
            message_length <= ct_rddata;
    end

    // State traversal and write enable/read address logic block
    always_comb begin
        case (curr_state)
            WAIT_ENABLE: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, 8'b0, 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                if (start) 
                    next_state = PT_ADDR_0_WRITE_AND_INIT;
                else
                    next_state = WAIT_ENABLE;
            end
            PT_ADDR_0_WRITE_AND_INIT: begin
                init = 1;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b1};
                {s_addr, ct_addr, pt_addr} = {8'b0, 8'b0, 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, message_length};
                next_state = CHECK_LOOP_DONE;
            end
            CHECK_LOOP_DONE: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                if (k < message_length)
                    next_state = CALC_I;
                else
                    next_state = DONE;
            end
            CALC_I: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = S_ADDR_I_READ;
            end
            S_ADDR_I_READ: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {i[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = S_ADDR_I_WAIT;
            end
            S_ADDR_I_WAIT: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {i[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = CALC_J;
            end
            CALC_J: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = S_ADDR_J_READ;
            end
            S_ADDR_J_READ: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {j[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = S_ADDR_J_WAIT;
            end
            S_ADDR_J_WAIT: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {j[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = SWAP_WRITE_SI;
            end
            SWAP_WRITE_SI: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b1, 1'b0};
                {s_addr, ct_addr, pt_addr} = {i[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {sj, 8'd0};
                next_state = SWAP_WRITE_SJ;
            end
            SWAP_WRITE_SJ: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b1, 1'b0};
                {s_addr, ct_addr, pt_addr} = {j[7:0], k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {si, 8'd0};
                next_state = S_ADDR_IJ_LOAD;
            end
            S_ADDR_IJ_LOAD: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {(si + sj), k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = S_ADDR_IJ_WAIT;
            end
            S_ADDR_IJ_WAIT: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {(si + sj), k[7:0], 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'd0};
                next_state = PT_ADDR_K_WRITE;
            end
            PT_ADDR_K_WRITE: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b1};
                {s_addr, ct_addr, pt_addr} = {8'b0, k[7:0], k[7:0]};
                {s_wrdata, pt_wrdata} = {8'd0, s_ij ^ ct_rddata};
                next_state = CHECK_LOOP_DONE;
            end
            DONE: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, 8'b0, 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'b0};
                next_state = WAIT_ENABLE;
            end
            default: begin
                init = 0;
                {update_i, update_j, update_k, update_si, update_sj, update_s_ij} = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
                {s_wren, pt_wren} = {1'b0, 1'b0};
                {s_addr, ct_addr, pt_addr} = {8'b0, 8'b0, 8'b0};
                {s_wrdata, pt_wrdata} = {8'd0, 8'b0};
                next_state = WAIT_ENABLE;
            end
        endcase
    end

endmodule: prga
