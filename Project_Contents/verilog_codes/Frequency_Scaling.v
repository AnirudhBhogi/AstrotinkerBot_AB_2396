/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Tanishka 
# Filename:         Frequency_Scaling
# File Description: Used to scale down frequency of main clock source for the ADC being used
# Global variables: None
*/

// Module Declaration
module Frequency_Scaling(
    input clk_50M,
    output reg adc_clk_out
);

// Declaring registers
reg [2:0] s_clk_counter = 0;

/*
Purpose:
For ADC Module 50Mhz to 3.125Mhz
*/	
always @(negedge clk_50M) begin
    if (s_clk_counter < 8) adc_clk_out = ~adc_clk_out;
    s_clk_counter = s_clk_counter + 1'b1;
end

endmodule
