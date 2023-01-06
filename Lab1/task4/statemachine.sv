`define STATE_DEAL_PCARD1 3'b000
`define STATE_DEAL_DCARD1 3'b001
`define STATE_DEAL_PCARD2 3'b010
`define STATE_DEAL_DCARD2 3'b011

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

    logic [2:0] curr_state;
    logic [2:0] next_state;
    
    // STATE MACHINE CLOCK LOGIC BLOCK
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            curr_state <= `STATE_DEAL_PCARD1;
        else
            curr_state <= next_state;
    end

    // STATE MACHINE OUTPUT LOGIC BLOCK
    always_comb begin
        case (curr_state)
            `STATE_DEAL_PCARD1: begin
                load_pcard1 = 1;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_DEAL_DCARD1;
            end
            `STATE_DEAL_DCARD1: begin
                load_pcard1 = 0;
                load_dcard1 = 1;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_DEAL_PCARD2;
            end
            `STATE_DEAL_PCARD2: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 1;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_DEAL_DCARD2;
            end
            `STATE_DEAL_DCARD2: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 1;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_DEAL_DCARD2; //in task 4 we stop after 4 cards are dealt, so stay in current state
            end
            default: begin
                //should not happen, but if in an unknown state we just handle it similar to a reset
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_DEAL_PCARD1;
            end
        endcase
    end

endmodule

