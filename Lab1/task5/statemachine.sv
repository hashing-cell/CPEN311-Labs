`define STATE_DEAL_PCARD1 4'b0000
`define STATE_DEAL_DCARD1 4'b0001
`define STATE_DEAL_PCARD2 4'b0010
`define STATE_DEAL_DCARD2 4'b0011
`define STATE_THIRDCARD_DECISION 4'b0100
`define STATE_DEAL_PCARD3 4'b0101
`define STATE_THIRDCARD_DECISION2 4'b0110
`define STATE_DEAL_DCARD3 4'b0111
`define STATE_WINNER_DECISION 4'b1000

module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

    logic [3:0] curr_state;
    logic [3:0] next_state;
    
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
                next_state = `STATE_THIRDCARD_DECISION;
            end
            `STATE_THIRDCARD_DECISION: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state, the following logic determines whether to continue drawing cards

                if( (pscore >= 4'd8) || (dscore >= 4'd8))
                    next_state = `STATE_WINNER_DECISION;
                //Player gets a third card since player score was 0-5
                else if (pscore <= 4'd5)
                    next_state = `STATE_DEAL_PCARD3;
                //Player does not get a third card if score was 6-7, but dealer does get a third card if dealer score is 0-5
                else if ((pscore == 4'd6 || pscore == 4'd7) && dscore <= 4'd5)
                    next_state = `STATE_DEAL_DCARD3;
                //In all other cases, neither the player nor dealer will draw another card, so game ends
                else
                    next_state = `STATE_WINNER_DECISION;
            end
            `STATE_DEAL_PCARD3: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 1;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_THIRDCARD_DECISION2;
            end
            `STATE_THIRDCARD_DECISION2: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state, the following cases determines whether the dealer draws a third card

                //If dealer's score was 6, then draw card if player's third card is a 6-7
                if (dscore == 4'd6 && (pcard3 == 4'd6 || pcard3 == 4'd7))
                    next_state = `STATE_DEAL_DCARD3;
                //If dealer's score was 5, then draw card if player's third card is 4-7
                else if (dscore == 4'd5 && (pcard3 >= 4'd4 && pcard3 <= 4'd7))
                    next_state = `STATE_DEAL_DCARD3;
                //If dealer's score was 4, then draw card if player's third card is 2-7
                else if (dscore == 4'd4 && (pcard3 >= 4'd2 && pcard3 <= 4'd7))
                    next_state = `STATE_DEAL_DCARD3;
                //If dealer's score was 3, then draw card if player's third card is not 8
                else if (dscore == 4'd3 && pcard3 != 4'd8)
                    next_state = `STATE_DEAL_DCARD3;
                //If dealer's score was 0-2, then draw card no matter player's third card
                else if (dscore <= 4'd2)
                    next_state = `STATE_DEAL_DCARD3;
                //In all other cases, the dealer does not draw a third card, so game ends
                else
                    next_state = `STATE_WINNER_DECISION;
            end
            `STATE_DEAL_DCARD3: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 1;
                player_win_light = 0;
                dealer_win_light = 0;
                //set next state
                next_state = `STATE_WINNER_DECISION;
            end
            `STATE_WINNER_DECISION: begin
                load_pcard1 = 0;
                load_dcard1 = 0;
                load_pcard2 = 0;
                load_dcard2 = 0;
                load_pcard3 = 0;
                load_dcard3 = 0;
                //Player wins
                if (pscore > dscore) begin
                    player_win_light = 1;
                    dealer_win_light = 0;
                end
                //Dealer wins  
                else if (pscore < dscore) begin
                    player_win_light = 0;
                    dealer_win_light = 1;
                end
                //Draw
                else begin
                    player_win_light = 1;
                    dealer_win_light = 1;
                end

                //set next state
                next_state = `STATE_WINNER_DECISION; //we stay in this state indefinitely unless reset happens
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


