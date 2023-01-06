module tb_syn_circle();
    logic clk = 0;
    logic rst_n;
    logic start;
    logic [2:0] colour;
    logic [7:0] centre_x;
    logic [6:0] centre_y;
    logic [7:0] radius;
    
    logic done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;

    //module instantiation
    circle dut (.*);

    always #5 clk = ~clk;  // Create clock with period=10

    initial begin
        // Default Case test
        colour = 3'b000;
        centre_x = 80;
        centre_y = 60;
        radius = 40;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing default case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle overlaps with left edge
        colour = 3'b001;
        centre_x = 30;
        centre_y = 60;
        radius = 40;
        start = 0;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing overlap left case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle overlaps with top edge
        colour = 3'b010;
        centre_x = 80;
        centre_y = 20;
        radius = 40;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing overlap top case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle overlaps with right edge
        colour = 3'b011;
        centre_x = 140;
        centre_y = 60;
        radius = 40;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing overlap right case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle overlaps with bottom edge
        colour = 3'b100;
        centre_x = 80;
        centre_y = 100;
        radius = 40;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing overlap bottom case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle overlaps with top-left edge
        colour = 3'b101;
        centre_x = 20;
        centre_y = 20;
        radius = 40;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing overlap top-left case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle is very large and only touches top and bottom edges
        colour = 3'b110;
        centre_x = 140;
        centre_y = 100;
        radius = 60;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing large case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
        
        // Case where circle is too big
        colour = 3'b000;
        centre_x = 80;
        centre_y = 60;
        radius = 120;
        start = 0;
        rst_n = 0; 
        #10;
        $display("Testing oversized case");
        rst_n = 1;
        start = 1;
        wait(done == 1); //I would add a $stop here to inspect waveforms but that messes with the code coverage simulation
    end




endmodule: tb_syn_circle
