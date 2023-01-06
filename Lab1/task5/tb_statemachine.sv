`define STATE_DEAL_PCARD1 4'b0000
`define STATE_DEAL_DCARD1 4'b0001
`define STATE_DEAL_PCARD2 4'b0010
`define STATE_DEAL_DCARD2 4'b0011
`define STATE_THIRDCARD_DECISION 4'b0100
`define STATE_DEAL_PCARD3 4'b0101
`define STATE_THIRDCARD_DECISION2 4'b0110
`define STATE_DEAL_DCARD3 4'b0111
`define STATE_WINNER_DECISION 4'b1000

`define GAME_IN_PROGRESS 2'b00
`define PLAYER_WINNER 2'b10
`define DEALER_WINNER 2'b01
`define DRAW 2'b11

module tb_statemachine();
    logic slow_clock;
    logic resetb;
    logic [3:0] dscore;
    logic [3:0] pscore; 
    logic [3:0] pcard3;
    wire load_pcard1;
    wire load_pcard2;
    wire load_pcard3;
    wire load_dcard1;
    wire load_dcard2;
    wire load_dcard3;
    wire player_win_light;
    wire dealer_win_light;

    logic err;

    statemachine DUT(slow_clock, resetb, dscore, pscore, pcard3, 
        load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3,
        player_win_light, dealer_win_light);

    //Function to test whether the current state in the instantiation matches the expected state
    task test_state(input logic [3:0] exp_state);
        begin
            if (tb_statemachine.DUT.curr_state != exp_state) begin
                $display("ERROR ** current state is %d, expected state is %d",
								tb_statemachine.DUT.curr_state, exp_state);
				err = 1'b1;
                $stop;
            end
        end
    endtask

    //Function to the expected winner compared to the output of the instantiation
    task test_winner(input logic [1:0] exp_win_light);
        begin
            if (tb_statemachine.DUT.player_win_light != exp_win_light[1]) begin
                $display("ERROR ** current player win light is %d, expected is %d",
								tb_statemachine.DUT.player_win_light, exp_win_light[1]);
				err = 1'b1;
                $stop;
            end
            if (tb_statemachine.DUT.dealer_win_light != exp_win_light[0]) begin
                $display("ERROR ** current dealer win light is %d, expected is %d",
								tb_statemachine.DUT.dealer_win_light, exp_win_light[0]);
				err = 1'b1;
                $stop;
            end
        end
    endtask 
    
    //alternating clk value
	initial begin
		slow_clock = 0;
		forever begin
            #10;
			slow_clock = 1; 
			#10;
			slow_clock = 0;
		end
	end


    //In this testbench we will look at the algorithm for bacarrat and test every "type" of baccarrat
    //according to the written description in task 2
    initial begin
        err = 0;
        pcard3 = 0;

        //Test natural game where player wins
        dscore = 2; 
        pscore = 8;
        pcard3 = 0;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`PLAYER_WINNER);
        #9;

        //Test natural game where it is a draw
        dscore = 9; 
        pscore = 9;
        pcard3 = 0;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DRAW);
        #9;

        //Test game where only dealer draws an extra card, and dealer wins
        dscore = 4; 
        pscore = 6;
        pcard3 = 0;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        dscore = 7; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DEALER_WINNER);
        #9;

        //Test game where neither draws a card, and is not a natural game, and ends in draw
        dscore = 7; 
        pscore = 7;
        pcard3 = 0;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;
        
        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DRAW);
        #9;
        
        //Test game where player draws an extra card, dealer does because their score is 7 from first 2 cards, and player wins
        dscore = 7; 
        pscore = 4;
        pcard3 = 4;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 8; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`PLAYER_WINNER);
        #9;
        
        //Test game where player draws an extra card, dealer does not when their score is 4, and player wins
        dscore = 5; 
        pscore = 4;
        pcard3 = 3;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 7; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`PLAYER_WINNER);
        #9;


        //Test game where player draws an extra card, and dealer score from first 2 cards is 3, and dealer wins
        dscore = 3; 
        pscore = 4;
        pcard3 = 6;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 0; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        dscore = 5; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DEALER_WINNER);
        #9;

        //Test game where player draws an extra card, and dealer score from first 2 cards is 6 and draws card, and dealer wins
        dscore = 6; 
        pscore = 3;
        pcard3 = 7;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 0; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        dscore = 7; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DEALER_WINNER);
        #9;

        //Test game where player draws an extra card, and dealer score from first 2 cards is 5 and draws card, and draws
        dscore = 5; 
        pscore = 3;
        pcard3 = 4;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 7; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        dscore = 7; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`DRAW);
        #9;
        
        //Test game where player draws an extra card, and dealer score from first 2 cards is 4 and draws card, and player wins
        dscore = 4; 
        pscore = 1;
        pcard3 = 5;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 9; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        dscore = 4; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`PLAYER_WINNER);
        #9;

        //Test game where player draws an extra card, and dealer score from first 2 cards is 2 and draws card, and player wins
        dscore = 2; 
        pscore = 3;
        pcard3 = 4;
        resetb = 0;
        #11;
        test_state(`STATE_DEAL_PCARD1);
        test_winner(`GAME_IN_PROGRESS);
        resetb = 1;
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD1);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_PCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_DEAL_DCARD2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_THIRDCARD_DECISION);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        pscore = 7; //updated score after player draws card
        test_state(`STATE_DEAL_PCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        test_state(`STATE_THIRDCARD_DECISION2);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11; 
        dscore = 2; //updated score after dealer draws card
        test_state(`STATE_DEAL_DCARD3);
        test_winner(`GAME_IN_PROGRESS);
        #9;

        #11;
        test_state(`STATE_WINNER_DECISION);
        test_winner(`PLAYER_WINNER);
        #9;
        //if there is an error, fail the test
		if(~err) 
			$display("Test Passed");
		else
			$display("Test Failed");

    end

endmodule
