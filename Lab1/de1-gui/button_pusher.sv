`timescale 1ps / 1ps

module button_pusher(input logic CLK, input logic [9:0] SW, input logic [3:0] KEY, output logic [9:0] LEDR, output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3, output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);
    assign LEDR = SW;
    logic RST_N;
    assign RST_N = KEY[0];
    logic [2:0] hex0_bars;
    assign HEX0 = { hex0_bars[1], KEY[3], KEY[2], hex0_bars[2], KEY[0], KEY[1], hex0_bars[0] };
    logic [34:0] upper_hexs;
    assign HEX1 = upper_hexs[6:0];
    assign HEX2 = upper_hexs[13:7];
    assign HEX3 = upper_hexs[20:14];
    assign HEX4 = upper_hexs[27:21];
    assign HEX5 = upper_hexs[34:28];
    logic [3:0] last_KEY;

    always_ff @(posedge CLK) begin
        if (~RST_N) begin
            upper_hexs <= 35'b1000110_0001100_0000110_1001000_1111111;
            hex0_bars <= 3'b110;
        end else begin
            last_KEY <= KEY;
            if (~KEY[3] && last_KEY[3]) begin
                upper_hexs <= { upper_hexs[27:0], upper_hexs[34:28] };
                hex0_bars <= { hex0_bars[1:0], hex0_bars[2] };
            end else if (~KEY[2] && last_KEY[2]) begin
                upper_hexs <= { upper_hexs[30:0], upper_hexs[34:31] };
                hex0_bars <= { hex0_bars[1:0], hex0_bars[2] };
            end else if (~KEY[1] && last_KEY[1]) begin
                upper_hexs <= { upper_hexs[33:0], upper_hexs[34] };
                hex0_bars <= { hex0_bars[1:0], hex0_bars[2] };
            end
        end
    end
endmodule: button_pusher
