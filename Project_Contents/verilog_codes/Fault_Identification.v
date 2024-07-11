
/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         Fault-Identification
# File Description: Detects the presence of a fault or block depending on the unit in which AB is present in
# Global variables: None
*/
module Fault_Identification (
    input reset, 
	 input clock, 
	 input echo_rx,
	 input [7:0] c_node, n_node,
    output reg trigger, out,
	 output reg [4:0] fault_or_col_cdc,
	 output reg blue_on,
	 output reg ema,
	 output reg f_found,
	 output reg emb,
	 output reg bdm_convey,
	 input paused,
	 output fim_eu,
	 output fim_ru,
	 output fim_cu,
	 output reg bdm,
	 output reg req,
	 input ack
);
reg [21:0] pulses;
reg [2:0] state;
reg [1:0] forc_detect [0:15];
reg [2:0] fim;
integer i = 0;
reg [4:0] fault_or_col;
reg flag=0;
reg cdc_state;
integer counter = 0;
assign fim_eu = fim[0];
assign fim_ru = fim[1];
assign fim_cu = fim[2];

initial begin
	 trigger = 0; out = 0; pulses = 0; state = 0; blue_on = 0; fault_or_col = 5'd0;
	 fault_or_col_cdc = 5'd0;
	f_found = 1'b0;
	ema = 1'b0;
	emb = 1'b0;
	fim[0] = 1'b0; fim[1] = 1'b0; fim [2] = 1'b0;
	bdm = 1'b0;
	bdm_convey = 1'b0;
	cdc_state = S0;
	req = 1'b0;
	forc_detect[1] = 2'b0; forc_detect[2] = 2'b0; forc_detect[3] = 2'b0; forc_detect[4] = 2'b0; forc_detect[5] = 2'b0; forc_detect[6] = 2'b0; forc_detect[7] = 2'b0; forc_detect[8] = 2'b0; forc_detect[9] = 2'b0; forc_detect[10] = 2'b0; forc_detect[11] = 2'b0; forc_detect[12] = 2'b0; forc_detect[13] = 2'b0; forc_detect[14] = 2'b0; forc_detect[15] = 2'b0;
end
parameter S0=0,S1=1,S2=2,S3=3,S4=4,hold=5;
parameter   NONE = 5'd0,
				ESU1 = 5'd1,
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
			

//FSM implementation of ultrasonic sensor which detects a pillar or a fault and give sinformation regrading it based on the exact location in the unit where it is found
always @(posedge clock or negedge reset)
begin
	if(!reset)
	begin
		state<=S0;
		out<=0;
		pulses<=0;
		trigger<=0;
		flag<=1;
	end
	
	else
	begin
		case(state)
		S0: begin if(pulses>=1000) begin state<=S1; trigger<=1;pulses<=20; end else pulses<=(pulses+20); fault_or_col <= NONE; end
		S1: begin if(pulses>=10000) begin state<=hold; trigger<=0;pulses<=20;blue_on <= 1'b0; end else pulses<=(pulses+20); end
	 hold: begin if(echo_rx==1) begin state <= S2; pulses <= 20; end else if(pulses>=1000000) begin state <= S0;pulses <= 20; end else pulses<=(pulses+20); end
		S2: begin  
//				if((echo_rx==1 && pulses>588200) || (echo_rx==0 && pulses<588200))
				if((echo_rx==1 && pulses>470600))
					begin flag<=0;pulses<=(pulses+20); end
				else if(pulses>=1000000)
					begin pulses<=0;
							if(flag==1) 
							begin 
								out<=1; blue_on <= 1'b1; 
								case({c_node, n_node})
									{8'd29, 8'd28} : begin if(fault_or_col == ESU3 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	case(forc_detect[ESU3]) 
																		2'b00 : begin fim[0] <= 1'b1; fault_or_col <= ESU3; f_found <= 1'b1; forc_detect[ESU3] <= 1'b1; ema <= 1'b1; state <= S4; end 
																		2'b01 : begin  if(paused) begin state <= S4; bdm <= 1'b1; fim[0] <= 1'b0; forc_detect[ESU3] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end
																		default: begin fault_or_col <= NONE; state <= S3; end
																	endcase
															end
									{8'd26, 8'd27} : begin if(fault_or_col == ESU2 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																  case(forc_detect[ESU2]) 
																		2'b00 : begin state <= S4; fim[0] <= 1'b1; fault_or_col <= ESU2; f_found <= 1'b1; forc_detect[ESU2] <= 2'b01; ema <= 1'b1; end
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[0] <= 1'b0; forc_detect[ESU2] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																  endcase
															end
									{8'd25, 8'd24}	: begin  if(fault_or_col == ESU1 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[ESU1]) 
																		2'b00 : begin state <= S4; fim[0] <= 1'b1; fault_or_col <= ESU1; f_found <= 1'b1; forc_detect[ESU1] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[0] <= 1'b0; forc_detect[ESU1] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd7	, 8'd6 } : begin if(fault_or_col == CSU3 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[CSU3]) 
																		2'b00 : begin state <= S4; fim[2] <= 1'b1; fault_or_col <= CSU3; f_found <= 1'b1; forc_detect[CSU3] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[2] <= 1'b0; forc_detect[CSU3] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd5 , 8'd4 } : begin if(fault_or_col == CSU2 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[CSU2]) 
																		2'b00 : begin state <= S4; fim[2] <= 1'b1; fault_or_col <= CSU2; f_found <= 1'b1; forc_detect[CSU2] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[2] <= 1'b0; forc_detect[CSU2] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd3 , 8'd2 } : begin if(fault_or_col == CSU1 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[CSU1]) 
																		2'b00 : begin state <= S4; fim[2] <= 1'b1; fault_or_col <= CSU1; f_found <= 1'b1; forc_detect[CSU1] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[2] <= 1'b0; forc_detect[CSU1] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd19, 8'd18} : begin if(fault_or_col == RSU1 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[RSU1]) 
																		2'b00 : begin state <= S4; fim[1] <= 1'b1; fault_or_col <= RSU1; f_found <= 1'b1; forc_detect[RSU1] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[1] <= 1'b0; forc_detect[RSU1] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd17, 8'd16} : begin if(fault_or_col == RSU2 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[RSU2]) 
																		2'b00 : begin state <= S4; fim[1] <= 1'b1; fault_or_col <= RSU2; f_found <= 1'b1; forc_detect[RSU2] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[1] <= 1'b0; forc_detect[RSU2] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd14, 8'd15} : begin if(fault_or_col == RSU3 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[RSU3]) 
																		2'b00 : begin state <= S4; fim[1] <= 1'b1; fault_or_col <= RSU1; f_found <= 1'b1; forc_detect[RSU3] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[1] <= 1'b0; forc_detect[RSU3] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd13, 8'd12} : begin if(fault_or_col == RSU4 || fault_or_col == NONE)// || fault_or_col == B1 || fault_or_col == B2 || fault_or_col == B3 || fault_or_col == B4)
																	 case(forc_detect[RSU4]) 
																		2'b00 : begin state <= S4; fim[1] <= 1'b1; fault_or_col <= RSU4; f_found <= 1'b1; forc_detect[RSU4] <= 2'b01; ema <= 1'b1; end 
																		2'b01 : begin if(paused) begin state <= S4; bdm <= 1'b1; fim[1] <= 1'b0; forc_detect[RSU4] <= 2'b10; fault_or_col <= BDM; ema <= 1'b0; bdm_convey <= 1'b0; end else begin bdm_convey <= 1'b1; state <= S3; end end	
																		default: begin fault_or_col <= NONE; state <= S3; end
																	 endcase
															end
									{8'd21, 8'd22} : begin if(!forc_detect[B1]) 
																	begin fault_or_col <= B1; ema <= 1'b1;   end
																	else fault_or_col <= NONE; forc_detect[B1] <= 1'b1; 
															end
									{8'd21, 8'd23} : begin if(!forc_detect[B3]) 
																	begin fault_or_col <= B3; ema <= 1'b1;   end
																	else fault_or_col <= NONE; forc_detect[B3] <= 1'b1; 
															end
									{8'd9, 8'd10 } : begin if(!forc_detect[B2]) 
																	begin fault_or_col <= B2; ema <= 1'b1;   end
																	else fault_or_col <= NONE; forc_detect[B2] <= 1'b1; 
															end
									{8'd9, 8'd11 } : begin if(!forc_detect[B4]) 
																	begin fault_or_col <= B4; ema <= 1'b1;   end
																	else fault_or_col <= NONE; forc_detect[B4] <= 1'b1; 
															end
									default			: begin fault_or_col <= NONE; state <= S3; end
								endcase
							end
							else
							begin 
								state <= S3;
								fault_or_col <= NONE;
							end 
					end
				else
					pulses<=(pulses+20);
				end
		S3: begin flag<=1; state<=S0; pulses<=(pulses+20); end
		S4: begin if(counter >= 110000000) 
					 begin 
						state <= S0; counter <= 0; flag <= 1;out <= 0; pulses <= pulses + 20; f_found <= 1'b0;
						blue_on <= 1'b0;
					 end 
					 else 
					 begin 
						 counter <= counter + 1; 
						 if(counter == 50) begin f_found <= 1'b0; end
					 end 
			end
		default: state<=S0;
		endcase
	end
		
end

/*
Purpose:
CDC implementation for communication with uart transmitter to give information regarding the fault or column detected
*/	
always @(negedge clock)
begin
	case(cdc_state)
		S0: begin fault_or_col_cdc <= fault_or_col; req <= 1'b1; cdc_state <= S1; end
		S1: begin if(ack) begin cdc_state <= S0; req <= 1'b0;  end end
		default : begin cdc_state <= S0;	end
	endcase
end

endmodule
