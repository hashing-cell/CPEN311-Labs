module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic rdy_init;
    logic rdy_ksa;
    logic rdy_prga;
    logic en_init;
    logic en_ksa;
    logic en_prga;
    
    logic s_wren;
    logic [7:0] s_addr;
    logic [7:0] s_wrdata;
    logic [7:0] s_rddata;

    enum {S_INIT, S_KSA, S_PRGA} s_mem_select;

    logic s_wren_init;
    logic [7:0] s_addr_init;
    logic [7:0] s_wrdata_init;

    logic s_wren_ksa;
    logic [7:0] s_addr_ksa;
    logic [7:0] s_wrdata_ksa;

    logic s_wren_prga;
    logic [7:0] s_addr_prga;
    logic [7:0] s_wrdata_prga;

    logic start;

    typedef enum {
        WAIT_ENABLE,
        EXECUTE_INIT,
        WAIT_INIT_START,
        WAIT_INIT_DONE,
        EXECUTE_KSA,
        WAIT_KSA_START,
        WAIT_KSA_DONE,
        EXECUTE_PRGA,
        WAIT_PRGA_START,
        WAIT_PRGA_DONE,
        DONE
    } state_t;

    state_t curr_state;
    state_t next_state;

    // Multiplexer for which module to access to S mem. Only one circuit is allowed to write to memory at a time
    always_comb begin
        case (s_mem_select)
            S_INIT: begin
                s_wren = s_wren_init;
                s_addr = s_addr_init;
                s_wrdata = s_wrdata_init;
            end
            S_KSA: begin
                s_wren = s_wren_ksa;
                s_addr = s_addr_ksa;
                s_wrdata = s_wrdata_ksa;
            end
            S_PRGA: begin
                s_wren = s_wren_prga;
                s_addr = s_addr_prga;
                s_wrdata = s_wrdata_prga;
            end
            default: begin
                //panic
                s_wren = 1'b0;
                s_addr = 8'b11111111;
                s_wrdata = 8'b11111111;
            end
        endcase
    end

    s_mem s(s_addr, clk, s_wrdata, s_wren, s_rddata);

    init i(clk, rst_n, en_init, rdy_init, s_addr_init, s_wrdata_init, s_wren_init);

    ksa k(clk, rst_n, en_ksa, rdy_ksa, key, s_addr_ksa, s_rddata, s_wrdata_ksa, s_wren_ksa);
    
    prga p(clk, rst_n, en_prga, rdy_prga, key, s_addr_prga, s_rddata, s_wrdata_prga, s_wren_prga,
        ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata, pt_wren);

    
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

    always_comb begin
        case (curr_state)
            WAIT_ENABLE: begin
                s_mem_select = S_INIT;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (start) 
                    next_state = EXECUTE_INIT;
                else
                    next_state = WAIT_ENABLE;
            end
            EXECUTE_INIT: begin
                s_mem_select = S_INIT;
                {en_init, en_ksa, en_prga} = {1'b1, 1'b0, 1'b0};
                next_state = WAIT_INIT_START;
            end
            WAIT_INIT_START: begin
                s_mem_select = S_INIT;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (!rdy)
                    next_state = WAIT_INIT_DONE;
                else
                    next_state = WAIT_INIT_START;
            end
            WAIT_INIT_DONE: begin
                s_mem_select = S_INIT;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (rdy_init) 
                    next_state = EXECUTE_KSA;
                else
                    next_state = WAIT_INIT_DONE;
            end
            EXECUTE_KSA: begin
                s_mem_select = S_KSA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b1, 1'b0};
                next_state = WAIT_KSA_START;
            end
            WAIT_KSA_START: begin
                s_mem_select = S_KSA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (!rdy)
                    next_state = WAIT_KSA_DONE;
                else
                    next_state = WAIT_KSA_START;
            end
            WAIT_KSA_DONE: begin
                s_mem_select = S_KSA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (rdy_ksa) 
                    next_state = EXECUTE_PRGA;
                else
                    next_state = WAIT_KSA_DONE;
            end
            EXECUTE_PRGA: begin
                s_mem_select = S_PRGA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b1};
                next_state = WAIT_PRGA_START;
            end
            WAIT_PRGA_START: begin
                s_mem_select = S_PRGA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (!rdy)
                    next_state = WAIT_PRGA_DONE;
                else
                    next_state = WAIT_PRGA_START;
            end
            WAIT_PRGA_DONE: begin
                s_mem_select = S_PRGA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                if (rdy_prga) 
                    next_state = DONE;
                else
                    next_state = WAIT_PRGA_DONE;
            end
            DONE: begin
                s_mem_select = S_PRGA;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                next_state = WAIT_ENABLE;
            end
            default: begin
                s_mem_select = S_INIT;
                {en_init, en_ksa, en_prga} = {1'b0, 1'b0, 1'b0};
                next_state = WAIT_ENABLE;
            end
        endcase
    end


endmodule: arc4
