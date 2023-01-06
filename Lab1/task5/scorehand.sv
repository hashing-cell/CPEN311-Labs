module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);
    //we use 5 bit to prevent accidental truncation
    wire [4:0] card1_value = (card1 < 4'd10) ? card1 : 0;
    wire [4:0] card2_value = (card2 < 4'd10) ? card2 : 0;
    wire [4:0] card3_value = (card3 < 4'd10) ? card3 : 0;

    assign total = (card1_value + card2_value + card3_value) % 4'd10;
endmodule

