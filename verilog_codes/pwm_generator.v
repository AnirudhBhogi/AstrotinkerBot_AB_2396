/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         pwm_generator
# File Description: Generates PWM of varying dity cycle in order to control speed of motor
# Global variables: None
*/

module pwm_generator(
    input clk_3125KHz,
    input [3:0] duty_cycle,
    output reg clk_195KHz, pwm_signal
);

initial begin
    clk_195KHz = 0; pwm_signal = 1;
end

reg [6:0] counter=0;

/*
Purpose:
195kHz clock generation and PWM generation based on duty cycle told by Black Line Follwing module for driving the motor*/	
always @(posedge clk_3125KHz)
begin
if(counter==0||counter==8) begin clk_195KHz= ~clk_195KHz; end
if(counter>=duty_cycle) pwm_signal= 0;
else pwm_signal=1;

counter <= counter + 1'b1;
end
endmodule
