/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         uart_tx
# File Description: Used to transmit appropriate messages from AB to CH
# Global variables: None
*/
module uart_tx(
    input  clk_50M,
	 input out,
	 input  [4:0] forc_detect_cdc,
    output reg tx,
	 input req,
	 output reg ack,
	 output reg clk_115200
);
integer count=0;
integer j=0;//Index of 10 bits(inlcuding start and stop bits) of the 8 bit word that is being transmitted
parameter S0=0,S1=1,S2=2,S3=3,S4=4,S5=5,S6=6,S7=7,S8=8,S9=9,S10=10,idle =11;
reg [3:0] state=idle;
reg [4:0] prev_forc;
integer counter=216;
integer index=0;
reg [103:0] memory;
reg [7:0] data;
reg [4:0] forc_detect;
integer base;
reg cdc_state;
reg flag = 0;
reg [4:0]   ESU1 = 5'd1,
				ESU2 = 5'd2,
				ESU3 = 5'd3,
				CSU1 = 5'd4,
				CSU2 = 5'd5,
				CSU3 = 5'd6,
				RSU1 = 5'd7,
				RSU2 = 5'd8,
				RSU3 = 5'd9,
				RSU4 = 5'd10,
				B1	  = 5'd11,
				B2	  = 5'd12,
				B3   = 5'd13,
				B4   = 5'd14,
				BDM  = 5'd15,
				STOP = 5'd31;
reg [31:0] unit_name;
reg [15:0] block_name;
initial begin
	tx = 1; clk_115200 = 0; memory = 0; data = 0; flag = 0; unit_name = 0; block_name = 0; prev_forc = 5'b0; forc_detect = 5'b0; ack = 1'b0; cdc_state = S0;
end

/*
Purpose:
Generation of 115200 Hz clock to achieve data transmission at the standard 115200 baud rate */	
always @(posedge clk_50M)
begin
	if(counter>=216)
	begin
		clk_115200<=~clk_115200;
		counter<=0;
	end
	
	else
	begin
		counter<=counter+1;
	end
end

/*
Purpose:
FSM implementation of tramitter part of uart
*/	
always @(posedge clk_115200)
begin
	case(state)
	 idle: begin 
					if(data!=0) 
					 begin state<=S1;tx<=0; end
					 else
					 begin tx<=1;
							 if(prev_forc!=forc_detect)
						    begin 
								begin
									case(forc_detect)
										ESU1 : begin memory <= "#-1USE-MI"; data <= "F";  unit_name <= "1USE"; end
										ESU2 : begin memory <= "#-2USE-MI"; data <= "F";  unit_name <= "2USE"; end
										ESU3 : begin memory <= "#-3USE-MI"; data <= "F";  unit_name <= "3USE"; end
										CSU1 : begin memory <= "#-1USC-MI"; data <= "F";  unit_name <= "1USC"; end
										CSU2 : begin memory <= "#-2USC-MI"; data <= "F";  unit_name <= "2USC"; end
										CSU3 : begin memory <= "#-3USC-MI"; data <= "F";  unit_name <= "3USC"; end
										RSU1 : begin memory <= "#-1USR-MI"; data <= "F";  unit_name <= "1USR"; end
										RSU2 : begin memory <= "#-2USR-MI"; data <= "F";  unit_name <= "2USR"; end
										RSU3 : begin memory <= "#-3USR-MI"; data <= "F";  unit_name <= "3USR"; end
										RSU4 : begin memory <= "#-4USR-MI"; data <= "F";  unit_name <= "4USR"; end
										B1	  : begin memory <= "#-1B-US-MP";data <= "B";  block_name <= "1B"; end
										B2	  : begin memory <= "#-2B-US-MP";data <= "B";  block_name <= "2B"; end
										B3	  : begin memory <= "#-3B-US-MP";data <= "B";  block_name <= "3B"; end
										B4	  : begin memory <= "#-4B-US-MP";data <= "B";  block_name <= "4B"; end
										BDM  : begin memory <= {"#-",block_name,"-",unit_name,"-MD"}; data <= "B"; end
										STOP : begin memory <= "#-DN"; data <= "E"; end
										default : begin data <= 0; end
									 endcase
								 end
								flag <= 0;
								prev_forc <= forc_detect;
							 end
							 else
								data <= 0;
					 end
			 end
		//S0: begin tx<=0;state<=S1; end
		S1: begin state<=S2;tx<=data[state-1]; end
		S2: begin state<=S3;tx<=data[state-1]; end
		S3: begin state<=S4;tx<=data[state-1]; end
		S4: begin state<=S5;tx<=data[state-1]; end
		S5: begin state<=S6;tx<=data[state-1]; end
		S6: begin state<=S7;tx<=data[state-1]; end
		S7: begin state<=S8;tx<=data[state-1]; end
		S8: begin state<=S9;tx<=data[state-1]; end
		S9: begin tx<=1;state<=idle;data<=memory[7:0];memory <= {8'b0,memory[103:8]}; end
		default: state<=idle;
	endcase
end

/*
Purpose:
CDC implementation for communication with Fault Identification module for it to sedn message regarding the fault or pilllar detected
*/	
	always @(negedge clk_115200)
	begin
		case(cdc_state)
			S0 : begin 
						if(req && !ack) begin forc_detect <= forc_detect_cdc; ack <= 1'b1;end
						if(!req && ack) begin cdc_state <= S1; ack <= 1'b0; end
				  end
			S1	: begin
						if(req && !ack) 
						begin 
							forc_detect <= forc_detect_cdc;
							ack <= 1'b1;
						end
						if(!req && ack) begin cdc_state <= S1; ack <= 1'b0; end
			     end
			default : begin cdc_state <= S1; end
		endcase
	end
endmodule