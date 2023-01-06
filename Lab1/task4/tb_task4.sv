`define LOOP_END 360

module tb_task4();
    logic err;

    logic CLOCK_50; //fast clock
    logic [3:0] KEY; //slow clock 
    wire[9:0] LEDR;
    wire[6:0] HEX5; 
    wire[6:0] HEX4; 
    wire[6:0] HEX3;
    wire[6:0] HEX2; 
    wire[6:0] HEX1; 
    wire[6:0] HEX0;

    logic [31:0] count;
    logic [31:0] randloop;
    task4 DUT(CLOCK_50, KEY, LEDR, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

    
    //Task to cycle the fast clock. 
    initial begin
        CLOCK_50 = 0;
        count = 1;
        forever begin
            for (randloop = 0; randloop < count; randloop += 1) begin
                #1;
            end
            CLOCK_50 = 1;
            for (randloop = 0; randloop < count; randloop += 1) begin
                #1;
            end
            CLOCK_50 = 0;
            for (randloop = 0; randloop < count; randloop += 1) begin
                #1;
            end
            count += 1;
            if (count >= 9) 
                count = 1;
        end
    end

    //alternating slow clk value
	initial begin
		KEY[0] = 0;
		forever begin
			#10;
			KEY[0] = 1;
			#10;
            test_score();
			KEY[0] = 0;
		end
	end

    //Function to test an expected output with the actual output of the instantiation
    task test_HEX(input logic [6:0] actual_HEX, input logic [6:0] exp_HEX);
        if(actual_HEX !== exp_HEX) begin
            $display("ERROR ** output is %b, expected %b",
                actual_HEX, exp_HEX);
            err = 1'b1;
        end
	endtask

    //Function to test whether the LED lights correctly correspond to current score
    task test_score();
        if (tb_task4.DUT.dp.pscore_out != tb_task4.DUT.LEDR[3:0]) begin
            $display("ERROR ** Player score does not correlate with LED");
            err = 1'b1;
        end
        if (tb_task4.DUT.dp.dscore_out != tb_task4.DUT.LEDR[7:4]) begin
            $display("ERROR ** Dealer score does not correlate with LED");
            err = 1'b1;
        end
    endtask


    logic [31:0] loop;

    //We just play a few games up to DCARD2 state, and observe the waveforms. 
    //Unit tests are in other testbenches
    initial begin
        err = 0;
        CLOCK_50 = 0;
        KEY[3] = 0; //reset
        KEY[2] = 1;
        KEY[1] = 1;
        #10;
        //Test that the 7 segment displays are initialized correctly
        test_HEX(HEX0, 7'b1111111);
        test_HEX(HEX1, 7'b1111111);
        test_HEX(HEX2, 7'b1111111);
        test_HEX(HEX3, 7'b1111111);
        test_HEX(HEX4, 7'b1111111);
        test_HEX(HEX5, 7'b1111111);
        

        //We use a loop and test multiple times to "simulate" randomness from 
        //the dealcard module to achieve better toggle bin coverage 
        for (loop = 0; loop < `LOOP_END; loop += 1) begin
            
            #10;
            //Cycle 0;
            //de-assert reset before proceeding
            KEY[3] = 1;
            #10;
            //Cycle 1;
            #10;
            #10;
            //Cycle 2;
            #10;
            #10;
            //Cycle 3;
            #10;
            #10;
            //Cycle 4;
            #10;
            #10;
            KEY[3] = 0; //reset
        end


        #10;
        //if there is an error, fail the test
		if(~err) 
			$display("Test Passed");
		else
			$display("Test Failed");


    end


endmodule
