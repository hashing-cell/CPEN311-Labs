// Lucky you! We are giving you this code for free. There is nothing
// here you need to add or write.

module dealcard(input logic clock, input logic resetb, output logic [3:0] new_card);
		  
logic [3:0] dealer_card;

always_ff @(posedge clock)
  if (resetb == 0)
     dealer_card <= 1;  
  else
     if (dealer_card == 13)
	     dealer_card <= 1;
	  else 
	     dealer_card++;

assign new_card = dealer_card;

endmodule
