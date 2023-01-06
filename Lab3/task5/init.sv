module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);
    
	typedef enum { 
		WAIT_ENABLE,
        WRITE,
        INCREMENT,
        WRITE_CHECK_DONE,
        DONE
	} state_t;

    state_t curr_state;
    state_t next_state;

    logic [8:0] next_num;

    logic update_num;

    logic start;

    logic init;

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

    // NEXT NUM REGISTER LOGIC BLOCK
    always_ff @(posedge clk) begin
        if (!rst_n || init)
            next_num <= 0;
        else if (update_num)
            next_num <= next_num + 9'd1;
    end

    always_comb begin
        case (curr_state)
            WAIT_ENABLE: begin
                init = 1;
                update_num = 0;
                wren = 0;
                if (start) 
                    next_state = WRITE;
                else
                    next_state = WAIT_ENABLE;
            end
            WRITE: begin
                init = 0;
                update_num = 0;
                wren = 1;
                next_state = INCREMENT;
            end
            INCREMENT: begin
                init = 0;
                update_num = 1;
                wren = 0;
                next_state = WRITE_CHECK_DONE;
            end
            WRITE_CHECK_DONE: begin
                init = 0;
                update_num = 0;
                wren = 0;
                if (next_num > 255) 
                    next_state = DONE;
                else
                    next_state = WRITE;
            end
            DONE: begin
                init = 0;
                update_num = 0;
                wren = 0;
                next_state = WAIT_ENABLE;
            end
            default: begin
                //panic
                init = 0;
                update_num = 0;
                wren = 0;
                next_state = WAIT_ENABLE;
            end
        endcase
        wrdata = next_num[7:0];
        addr = next_num[7:0];
    end

endmodule: init