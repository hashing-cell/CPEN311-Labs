module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);
    
    /* Type declearation for all the states */
	typedef enum { 
		WAIT_ENABLE,
        WRITE,
        INCREMENT,
        WRITE_CHECK_DONE,
        HALT
	} state_t;

    /* Registers Declearation */
    state_t curr_state;
    state_t next_state;

    logic [8:0] next_num;

    logic update_num;

    logic start;

    // STATE MACHINE CLOCK LOGIC BLOCK
    always_ff @(posedge clk) begin
        /* Synchronous reset */
        if (!rst_n) begin
            curr_state <= WAIT_ENABLE;      // Move to wait enable state
            rdy <= 1;
            start <= 0;
        end 
        else if (en) begin
            start <= 1;                     // Making start 1 and hold until process ends
        end
        else if (start) begin               // Changes state every clock cycle
			curr_state <= next_state;
            if (curr_state == HALT)         // Stop going to next stage at HALT
                rdy <= 1;
            else
                rdy <= 0;
        end
    end

    // NEXT NUM REGISTER LOGIC BLOCK
    always_ff @(posedge clk) begin
        if (!rst_n)
            next_num <= 0;
        else if (update_num)
            next_num <= next_num + 1;       // Increment address and value every clk
    end

    always_comb begin
        case (curr_state)
            /* Wait enable state: waiting for the enable signal to call */
            WAIT_ENABLE: begin
                update_num = 0;
                wren = 0;
                if (start) 
                    next_state = WRITE;         // Move to write state
                else
                    next_state = WAIT_ENABLE;   // Stay until en high
            end

            /*Write state: write value to memory */
            WRITE: begin
                update_num = 0;
                wren = 1;
                next_state = INCREMENT;         // Move to increment state
            end

            /* Increment state: let register store increment */
            INCREMENT: begin
                update_num = 1;
                wren = 0;
                next_state = WRITE_CHECK_DONE;  // Move to write check state
            end

            /* WRITE_CHECK_DONE state: decide to loop back or halt */
            WRITE_CHECK_DONE: begin
                update_num = 0;
                wren = 0;
                if (next_num > 255) 
                    next_state = HALT;          // Move to HALT state
                else    
                    next_state = WRITE;         // Move to write state
            end

            /* HALT: stop accepting any en signal */
            HALT: begin
                update_num = 0;
                wren = 0;
                // We stay in halt state forever since we only init once
                next_state = HALT;
            end

            /* Unknow state: reset to write enable state */
            default: begin
                //panic
                update_num = 0;
                wren = 0;
                next_state = WAIT_ENABLE;
            end
        endcase

        /* Update write signals */
        wrdata = next_num;
        addr = next_num;
    end

endmodule: init