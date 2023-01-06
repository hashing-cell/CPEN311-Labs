`define MAX_LENG 8'd255
`define MAX_LENG_ALL 9'd256
`define KEY_LENG 8'd3


module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);
    
    /* Register Delearation */ 
    typedef enum {
        INIT, 
        CHECK_LOOP, 
        LOAD_SI,
        WAIT_SI,
        COMP_J,  
        LOAD_SJ,
        WAIT_SJ, 
        WRITE_SI, 
        WRITE_SJ, 
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

    logic update_i;
    logic update_j;
    logic update_si;
    logic update_sj;

    logic [7:0] key_index;

    // i register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            i <= 0;
        else if (update_i)
            i <= (i + 9'd1);
    end
    // j register logic block
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            j <= 0;
        else if (update_j)
            j <= (j + si + key_index) % 9'd256;
    end
    
    // To select Key index
    always_comb begin
        if (i % 3 == 0)
            key_index = key[23:16];
        else if (i % 3 == 1)
            key_index = key[15:8];
        else if (i % 3 == 2)
            key_index = key[7:0];
        else
            key_index = 8'dx;
    end

    // si register logic block
    always_ff @(posedge clk) begin
        if (update_si)
            si <= rddata;
    end

    // sj register logic block
    always_ff @(posedge clk) begin
        if (update_sj)
            sj <= rddata;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            curr_state <= INIT;
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
            INIT: begin
                init = 1'b1;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b0};
                wren = 1'b0;
                addr = 8'd0;
                wrdata = 8'd0;
                if (start) 
                    next_state = CHECK_LOOP;
                else
                    next_state = INIT;
            end
            CHECK_LOOP: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b0};
                wren = 1'b0;
                addr = 8'd0;
                wrdata = 8'd0;
                if (i < 256) 
                    next_state = LOAD_SI;
                else
                    next_state = DONE;
            end
            LOAD_SI: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b1, 1'b0};
                wren = 1'b0;
                addr = i[7:0];
                wrdata = 8'd0;
                next_state = WAIT_SI;
            end
            WAIT_SI: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b1, 1'b0};
                wren = 1'b0;
                addr = i[7:0];
                wrdata = 8'd0;
                next_state = COMP_J;
            end
            COMP_J: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b1, 1'b0, 1'b0};
                wren = 1'b0;
                addr = 8'd0;
                wrdata = 8'd0;
                next_state = LOAD_SJ;
            end
            LOAD_SJ: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b1};
                wren = 1'b0;
                addr = j[7:0];
                wrdata = 8'd0;
                next_state = WAIT_SJ;
            end
            WAIT_SJ: begin
                init = 1'b0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b1};
                wren = 1'b0;
                addr = j[7:0];
                wrdata = 8'd0;
                next_state = WRITE_SI;
            end
            WRITE_SI: begin
                init = 0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b0};
                wren = 1'b1;
                addr = j[7:0];
                wrdata = si;
                next_state = WRITE_SJ;
            end
            WRITE_SJ: begin
                init = 0;
                {update_i, update_j, update_si, update_sj} = {1'b1, 1'b0, 1'b0, 1'b0}; //update i before going into CHECK_LOOP
                wren = 1'b1;
                addr = i[7:0];
                wrdata = sj;
                next_state = CHECK_LOOP;
            end
            DONE: begin
                init = 0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b0};
                wren = 1'b0;
                addr = 8'd0;
                wrdata = 8'd0;
                next_state = INIT;
            end
            default: begin
                init = 0;
                {update_i, update_j, update_si, update_sj} = {1'b0, 1'b0, 1'b0, 1'b0};
                wren = 1'b0;
                addr = 8'd0;
                wrdata = 8'd0;
                next_state = INIT;
            end
        endcase
    end
    
endmodule: ksa

