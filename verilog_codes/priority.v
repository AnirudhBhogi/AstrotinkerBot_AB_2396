/*
# Team ID:          2396
# Theme:            AstroTinker Bot 
# Author List:      Anirudh Bhogi
# Filename:         priority
# File Description: Helps in uart_tx module to send end og run message
# Global variables: None
*/ 
module priority(
	input [4:0] in,
	input stop,
	output [4:0] out
);
// stop : stop signal which is sent by the cpu controller
// in	  : fault or column's encoded number
// out  : code being sent to uart_tx for data transmission
	assign out = (stop) ? 5'b11111 : in;
endmodule