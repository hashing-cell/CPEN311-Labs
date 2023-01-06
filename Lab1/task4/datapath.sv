module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);
						
    logic [3:0] pcard1;
    logic [3:0] pcard2;
    logic [3:0] pcard3;
    logic [3:0] dcard1;
    logic [3:0] dcard2;
    logic [3:0] dcard3;

    wire [3:0] next_card;

    //dealdcard module instantiation for dealing a random card
    dealcard RNG(fast_clock, resetb, next_card);

    //Block for the PCard1 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            pcard1 <= 4'b0000;
        else if (load_pcard1)
            pcard1 <= next_card;
    end
    //Block for the PCard2 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            pcard2 <= 4'b0000;
        else if (load_pcard2)
            pcard2 <= next_card;
    end
    //Block for the PCard3 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            pcard3 <= 4'b0000;
        else if (load_pcard3) begin
            pcard3 <= next_card;
            //We also need to assign it to the output for the state machine
            pcard3_out <= next_card;
        end
    end
    //Block for the DCard1 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            dcard1 <= 4'b0000;
        else if (load_dcard1)
            dcard1 <= next_card;
    end
    //Block for the DCard2 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            dcard2 <= 4'b0000;
        else if (load_dcard2)
            dcard2 <= next_card;
    end
    //Block for the DCard3 Register
    always_ff @(posedge slow_clock) begin
        if (resetb == 0) 
            dcard3 <= 4'b0000;
        else if (load_dcard3)
            dcard3 <= next_card;
    end

    //scorehand module instantiation for the player's score
    scorehand player_score(pcard1, pcard2, pcard3, pscore_out);
    //scorehand module instantiation for the dealer's score
    scorehand dealer_score(dcard1, dcard2, dcard3, dscore_out);

    //card7seg module instantiation to display the cards on each corresponding 7-segment display
    card7seg hex0_display(pcard1, HEX0);
    card7seg hex1_display(pcard2, HEX1);
    card7seg hex2_display(pcard3, HEX2);
    card7seg hex3_display(dcard1, HEX3);
    card7seg hex4_display(dcard2, HEX4);
    card7seg hex5_display(dcard3, HEX5);
endmodule

