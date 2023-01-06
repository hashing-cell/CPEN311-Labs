module tb_scorehand();
    logic [3:0] card1; 
    logic [3:0] card2;
    logic [3:0] card3;

    logic [4:0] scoretest;

    wire [3:0] total;

    logic err;
    scorehand DUT(card1, card2, card3, total);

    //Function to test an expected output with the actual output of the instantiation 
    task test(input logic [3:0] exp_total);
		begin
			if(tb_scorehand.DUT.total !== exp_total) begin
				$display("ERROR for input %d, %d, %d: ** output is %d, expected %d",
                    tb_scorehand.DUT.card1, tb_scorehand.DUT.card2, tb_scorehand.DUT.card3, tb_scorehand.DUT.total, exp_total);
				err = 1'b1;
			end
		end
	endtask
    
    initial begin
        err = 1'b0;
        #10;

        //Tens should have a card value of 0
        card1 = 4'd10;
        card2 = 4'd10;
        card3 = 4'd10;
        #10;
        if(DUT.card1_value != 0 || DUT.card2_value != 0 || DUT.card3_value != 0) begin
            $display("ERROR: Ten card value is not 0");
            $stop;
        end

        //Jacks should have a card value of 0
        card1 = 4'd11;
        card2 = 4'd11;
        card3 = 4'd11;
        #10;
        if(DUT.card1_value != 0 || DUT.card2_value != 0 || DUT.card3_value != 0) begin
            $display("ERROR: Jack card value is not 0");
            $stop;
        end

        #10;
        
        //Queens should have a card value of 0
        card1 = 4'd12;
        card2 = 4'd12;
        card3 = 4'd12;
        #10;
        if(DUT.card1_value != 0 || DUT.card2_value != 0 || DUT.card3_value != 0) begin
            $display("ERROR: Queen card value is not 0");
            $stop;
        end

        #10;

        //Queens should have a card value of 0
        card1 = 4'd13;
        card2 = 4'd13;
        card3 = 4'd13;

        #10;
        if(DUT.card1_value != 0 || DUT.card2_value != 0 || DUT.card3_value != 0) begin
            $display("ERROR: King card value is not 0");
            $stop;
        end

        #10;
        //check every single score combination for card combinations that are all 9 or less
        for (card1 = 0; card1 < 4'd10; card1 += 1) begin
            #10;
            for(card2 = 0; card2 < 4'd10; card2 += 1) begin
                #10;
                for (card3 = 0; card3 < 4'd10; card3 += 1) begin
                    #10;
                    scoretest = (card1 + card2 + card3) % 4'd10;

                    test(scoretest);
                end
            end
        end




        #10;
        //if there is an error, fail the test
		if(~err) 
			$display("Test Passed");
		else
			$display("Test Failed");
    end

endmodule
