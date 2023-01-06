module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    /* Register Declearation */
    logic [7:0] addr;
    logic [7:0] wrdata;
    logic rdy;
    logic en;
    logic wren;

    /* Type declearation for all the states */
    typedef enum { 
		RESET,
        ASSERT_EN,
        DEASSERT_EN
	} state_t;

    state_t curr_state;
    state_t next_state;

    // mainly for testing, this value can show output of s_mem
    logic [7:0] q;
    assign LEDR[7:0] = q;
    assign LEDR[9:8] = 2'b00;

    // STATE MACHINE CLOCK LOGIC BLOCK
    always_ff @(posedge CLOCK_50) begin
        /* Synchronous reset */
        if (!KEY[3])
            curr_state <= RESET;
        else
            curr_state <= next_state;   // Changes state every clock cycle after reset
    end
    
    // COMBINATIONAL LOGIC
    always_comb begin
        case (curr_state)
            /* RESET state: set en to 0 */
            RESET: begin
                en = 0;
                next_state = ASSERT_EN;     // Move to ASSERT_EN
            end

            /* ASSERT_EN state: en high to activate init */
            ASSERT_EN: begin
                en = 1;
                next_state = DEASSERT_EN;   // Move to DEASSERT_EN state 
            end

            /* DEASSERT_EN state: drop en to 0 */
            DEASSERT_EN: begin
                en = 0;
                next_state = DEASSERT_EN; //stay in this state forever
            end

            /*Uknow state */
            default: begin
                //panic
                en = 0;
                next_state = RESET;
            end
        endcase
    end

    s_mem s(addr, CLOCK_50, wrdata, wren, q);

    init i(CLOCK_50, KEY[3], en, rdy, addr, wrdata, wren);
endmodule: task1
