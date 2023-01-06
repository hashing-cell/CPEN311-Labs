//CORRECT TEST OUTPUTS
`define SW0000_ANS 0'b1111111
`define SW0001_ANS 0'b0001000
`define SW0010_ANS 0'b0100100
`define SW0011_ANS 0'b0110000
`define SW0100_ANS 0'b0011001
`define SW0101_ANS 0'b0010010
`define SW0110_ANS 0'b0000010
`define SW0111_ANS 0'b1111000
`define SW1000_ANS 0'b0000000
`define SW1001_ANS 0'b0010000
`define SW1010_ANS 0'b1000000
`define SW1011_ANS 0'b1100001
`define SW1100_ANS 0'b0011000
`define SW1101_ANS 0'b0001001
`define SW1110_ANS 0'b1111111
`define SW1111_ANS 0'b1111111


module tb_card7seg();
    logic [3:0] SW;
    wire [6:0] HEX0;
    logic err;
    card7seg DUT(SW, HEX0);

    //Function to test an expected output with the actual output of the instantiation
    task test(input logic [6:0] exp_HEX0);
		begin
			if(tb_card7seg.DUT.HEX0 !== exp_HEX0) begin
				$display("ERROR for input %b: ** output is %b, expected %b",
                    tb_card7seg.DUT.SW, tb_card7seg.DUT.HEX0, exp_HEX0);
				err = 1'b1;
			end
		end
	endtask
    
    initial begin
        err = 1'b0;
        #10;
        
        //Test 1
        SW = 0'b0000;
        #5;
        test(`SW0000_ANS);
        //Test 2
        SW = 0'b0001;
        #5;
        test(`SW0001_ANS);
        //Test 3
        SW = 0'b0010;
        #5;
        test(`SW0010_ANS);
        //Test 4
        SW = 0'b0011;
        #5;
        test(`SW0011_ANS);
        //Test 5
        SW = 0'b0100;
        #5;
        test(`SW0100_ANS);
        //Test 6
        SW = 0'b0101;
        #5;
        test(`SW0101_ANS);
        //Test 7
        SW = 0'b0110;
        #5;
        test(`SW0110_ANS);
        //Test 8
        SW = 0'b0111;
        #5;
        test(`SW0111_ANS);
        //Test 9
        SW = 0'b1000;
        #5;
        test(`SW1000_ANS);
        //Test 10
        SW = 0'b1001;
        #5;
        test(`SW1001_ANS);
        //Test 11
        SW = 0'b1010;
        #5;
        test(`SW1010_ANS);
        //Test 12
        SW = 0'b1011;
        #5;
        test(`SW1011_ANS);
        //Test 13
        SW = 0'b1100;
        #5;
        test(`SW1100_ANS);
        //Test 14
        SW = 0'b1101;
        #5;
        test(`SW1101_ANS);
        //Test 15
        SW = 0'b1110;
        #5;
        test(`SW1110_ANS);
        //Test 16
        SW = 0'b1111;
        #5;
        test(`SW1111_ANS);
        
        
        #10;
        //if there is an error, fail the test
		if(~err) 
			$display("Test Passed");
		else
			$display("Test Failed");
    end

    
endmodule

