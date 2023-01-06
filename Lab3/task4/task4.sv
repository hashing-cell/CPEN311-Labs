module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);
    logic [7:0] ct_addr;
    logic [7:0] ct_rddata;

    logic rdy;
    logic en;

    logic key_valid;
    logic [23:0] key;

    logic onoff;

    typedef enum { 
		RESET,
        ASSERT_EN,
        DEASSERT_EN,
        WAIT_CRACK_START,
        WAIT_CRACK_END,
        DONE
	} state_t;

    state_t curr_state;
    state_t next_state;

    // we hardwire write and wren to 0 since we will only read from ct memory
    ct_mem ct(ct_addr, CLOCK_50, 8'd0, 1'b0, ct_rddata);
    // crack module
    crack c(CLOCK_50, KEY[3], en, rdy, key, key_valid, ct_addr, ct_rddata);
    
    //Instantiate 6 sseg modules for each display
    sseg key_digit_5(onoff, key[3:0], key_valid, HEX0);
    sseg key_digit_4(onoff, key[7:4], key_valid, HEX1);
    sseg key_digit_3(onoff, key[11:8], key_valid, HEX2);
    sseg key_digit_2(onoff, key[15:12], key_valid, HEX3);
    sseg key_digit_1(onoff, key[19:16], key_valid, HEX4);
    sseg key_digit_0(onoff, key[23:20], key_valid, HEX5);


    always_ff @(posedge CLOCK_50) begin
        if (!KEY[3])
            curr_state <= RESET;
        else
            curr_state <= next_state;
    end

    always_comb begin
        case (curr_state)
            RESET: begin
                en = 0;
                onoff = 0;
                LEDR[9] = 1'b1; //just to get an idea of the current state
                next_state = ASSERT_EN;
            end
            ASSERT_EN: begin
                en = 1;
                onoff = 0;
                LEDR[9] = 1'b1; //just to get an idea of the current state
                next_state = DEASSERT_EN;
            end
            DEASSERT_EN: begin
                en = 0;
                onoff = 0;
                LEDR[9] = 1'b1; //just to get an idea of the current state
                next_state = WAIT_CRACK_START; 
            end
            WAIT_CRACK_START: begin
                en = 0;
                onoff = 0;
                LEDR[9] = 1'b1; //just to get an idea of the current state
                if (!rdy)
                    next_state = WAIT_CRACK_END;
                else
                    next_state = WAIT_CRACK_START;
            end
            WAIT_CRACK_END: begin
                en = 0;
                onoff = 0;
                LEDR[9] = 1'b1; //just to get an idea of the current state
                if (rdy)
                    next_state = DONE;
                else
                    next_state = WAIT_CRACK_END;
            end
            DONE: begin
                en = 0;
                onoff = 1;
                LEDR[9] = 1'b0; //just to get an idea of the current state
                next_state = DONE; //stay in this state forever until reset
            end
            default: begin
                //panic
                en = 0;
                next_state = RESET;
            end
        endcase
    end

endmodule: task4


module sseg(input logic onoff, input logic [3:0] key_digit, input logic key_valid, output logic [6:0] hex);
   //Combinational logic to handle every case
   always_comb begin
        if (!onoff) begin
            hex = 7'b1111111; // Empty display
        end
        else begin
            if (key_valid) begin
                case (key_digit)
                    4'b0000: hex = 7'b1000000;
                    4'b0001: hex = 7'b1111001;
                    4'b0010: hex = 7'b0100100;
                    4'b0011: hex = 7'b0110000;
                    4'b0100: hex = 7'b0011001;
                    4'b0101: hex = 7'b0010010;
                    4'b0110: hex = 7'b0000010;
                    4'b0111: hex = 7'b1111000;
                    4'b1000: hex = 7'b0000000;
                    4'b1001: hex = 7'b0010000;
                    4'b1010: hex = 7'b0001000;
                    4'b1011: hex = 7'b0000011;
                    4'b1100: hex = 7'b0100001;
                    4'b1101: hex = 7'b0000110;
                    4'b1110: hex = 7'b0000110;
                    4'b1111: hex = 7'b0001110;
                    default: hex = 7'b0101010; //panic, should never get here
                endcase
            end else begin
                hex = 7'b0111111; // No valid key display
            end
        end
   end
endmodule
