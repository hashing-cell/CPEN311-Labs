module card7seg(input logic [3:0] card, output logic [6:0] seg7);
   //Combinational logic to handle every case
   always_comb begin
      case (card) 
         4'b0001: seg7 = 7'b0001000;
         4'b0010: seg7 = 7'b0100100;
         4'b0011: seg7 = 7'b0110000;
         4'b0100: seg7 = 7'b0011001;
         4'b0101: seg7 = 7'b0010010;
         4'b0110: seg7 = 7'b0000010;
         4'b0111: seg7 = 7'b1111000;
         4'b1000: seg7 = 7'b0000000;
         4'b1001: seg7 = 7'b0010000;
         4'b1010: seg7 = 7'b1000000;
         4'b1011: seg7 = 7'b1100001;
         4'b1100: seg7 = 7'b0011000;
         4'b1101: seg7 = 7'b0001001;
         //Default input is no display, for when SW = 0, 14, and 15
         default: seg7 = 7'b1111111;
      endcase
	end
endmodule

