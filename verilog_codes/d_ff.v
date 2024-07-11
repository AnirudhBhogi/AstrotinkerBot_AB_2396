/*
# Team ID:          2396
# Theme:            AstroTinker Bot 
# Author List:      Anirudh Bhogi
# Filename:         d_ff
# File Description: Simple D flip flop without reset
# Global variables: None
*/
module d_ff(
	input clock, 
	input d,
	output reg q
);
/*
Purpose:
Makes the output as the input at every positive edge of the clock
*/

	always @(posedge clock)
	begin
		q <= d;
	end
endmodule