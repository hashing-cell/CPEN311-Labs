`define LOOP_END 14

module tb_datapath();
    logic slow_clock;
    logic fast_clock;
    logic resetb;
    logic load_pcard1;
    logic load_pcard2; 
    logic load_pcard3;
    logic load_dcard1;
    logic load_dcard2; 
    logic load_dcard3;
    wire [3:0] pcard3_out;
    wire [3:0] pscore_out; 
    wire [3:0] dscore_out;
    wire [6:0] HEX5; 
    wire [6:0] HEX4; 
    wire [6:0] HEX3;
    wire [6:0] HEX2; 
    wire [6:0] HEX1; 
    wire [6:0] HEX0;

    logic err;

    datapath DUT(slow_clock, fast_clock, resetb,
        load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3,
        pcard3_out, pscore_out, dscore_out,
        HEX5,  HEX4,  HEX3, HEX2,  HEX1,  HEX0);

    //alternating slow clk value
	initial begin
		slow_clock = 0;
		forever begin
			#10;
			slow_clock = 1;
            test_invariants();
			#10;
			slow_clock = 0;
		end
	end

    //The datapath contains some invariants that should hold every clock cycle
    task test_invariants();
        //Third card output should always be consistent with third card register
        if(pcard3_out != tb_datapath.DUT.pcard3) begin
            $display("INVARIANT ERROR");
            $stop;
        end
        //Score should always be consistent with the scorehand module output
        if(pscore_out != tb_datapath.DUT.player_score.total) begin
            $display("INVARIANT ERROR");
            $stop;
        end
        if(dscore_out != tb_datapath.DUT.dealer_score.total) begin
            $display("INVARIANT ERROR");
            $stop;
        end
    endtask

    //The following functions checks whether registers are loaded to their correct value
    task test_register_pcard1(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.pcard1 != exp_value) begin
                $display("ERROR pcard1 ** output is %d, expected %d",
								tb_datapath.DUT.pcard1, exp_value);
				err = 1'b1;
            end
        end
    endtask
    task test_register_pcard2(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.pcard2 != exp_value) begin
                $display("ERROR pcard2 ** output is %d, expected %d",
								tb_datapath.DUT.pcard2, exp_value);
				err = 1'b1;
            end
        end
    endtask
    task test_register_pcard3(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.pcard3 != exp_value) begin
                $display("ERROR pcard3 ** output is %d, expected %d",
								tb_datapath.DUT.pcard3, exp_value);
				err = 1'b1;
            end
        end
    endtask
    task test_register_dcard1(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.dcard1 != exp_value) begin
                $display("ERROR dcard1 ** output is %d, expected %d",
								tb_datapath.DUT.dcard1, exp_value);
				err = 1'b1;
            end
        end
    endtask
    task test_register_dcard2(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.dcard2 != exp_value) begin
                $display("ERROR dcard2 ** output is %d, expected %d",
								tb_datapath.DUT.dcard2, exp_value);
				err = 1'b1;
            end
        end
    endtask
    task test_register_dcard3(input logic [3:0] exp_value);
        begin
            if (tb_datapath.DUT.dcard3 != exp_value) begin
                $display("ERROR dcard3 ** output is %d, expected %d",
								tb_datapath.DUT.dcard3, exp_value);
				err = 1'b1;
            end
        end
    endtask

    task set_all_load_to_zero();
        begin
            load_pcard1 = 0;
            load_pcard2 = 0; 
            load_pcard3 = 0;
            load_dcard1 = 0;
            load_dcard2 = 0; 
            load_dcard3 = 0;
        end
    endtask

    //Task to cycle the card output from the dealcard module. 
    task cycle_card();
        begin
            #1;
            fast_clock = 1;
            #1;
            fast_clock = 0;
            #1;
        end
    endtask

    logic [4:0] loop;
    initial begin
        //Test Reset
        resetb = 1'b0;
        fast_clock = 0;
        set_all_load_to_zero();
        err = 0;
        #10;
        //check registers after reset is asserted
        if(tb_datapath.DUT.pcard1 != 4'd0) begin
            err = 1;
        end
        if(tb_datapath.DUT.pcard2 != 4'd0) begin
            err = 1;
        end
        if(tb_datapath.DUT.pcard3 != 4'd0) begin
            err = 1;
        end
        if(tb_datapath.DUT.dcard1 != 4'd0) begin
            err = 1;
        end
        if(tb_datapath.DUT.dcard2 != 4'd0) begin
            err = 1;
        end
        if(tb_datapath.DUT.dcard3 != 4'd0) begin
            err = 1;
        end
        if(err == 1) begin
            $display("Error with reset");
        end
        #10;
        cycle_card();
        
        //de-assert reset before proceeding
        resetb = 1'b1;

        #7;
        cycle_card();
        #7;
        #10;

        //We use a loop and test multiple times to "simulate" randomness from 
        //the dealcard module to achieve better toggle bin coverage 
        for (loop = 0; loop < `LOOP_END; loop += 1) begin
            //Test load_pcard1;
            set_all_load_to_zero();
            load_pcard1 = 1;
            #7;
            test_register_pcard1(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
            //Test load_pcard2;
            set_all_load_to_zero();
            load_pcard2 = 1;
            #7;
            test_register_pcard2(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
            //Test load_pcard3;
            set_all_load_to_zero();
            load_pcard3 = 1;
            #7;
            test_register_pcard3(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
            //Test load_dcard1;
            set_all_load_to_zero();
            load_dcard1 = 1;
            #7;
            test_register_dcard1(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
            //Test load_dcard2;
            set_all_load_to_zero();
            load_dcard2 = 1;
            #7;
            test_register_dcard2(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
            //Test load_dcard3;
            set_all_load_to_zero();
            load_dcard3 = 1;
            #7;
            test_register_dcard3(tb_datapath.DUT.next_card);
            cycle_card();
            #10;
        end

        set_all_load_to_zero();
        #10;
        //if there is an error, fail the test
		if(~err) 
			$display("Test Passed");
		else
			$display("Test Failed");

    end


endmodule
