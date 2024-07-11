/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         Black_Line_Following
# File Description: Consists of the driving strategy of the AB on the black line
# Global variables: None
*/
module Black_Line_Following(
	input [11:0] left_value, center_value, right_value,
	input clock, push_button, reset,
	input [7:0] n_node,
	input [3:0] dir,
	input f_found,
	output reg [3:0] MLA, MLB, MRA, MRB,
	output reg green, blue_off, 
	output reg stop, // To signify that AB has properly repositioned itself once a fault has been identified in order to go to vertical column
	output reg [7:0] c_node,
	output reg [7:0] p_node,
	input enable,
	input bdm_convey,
	output reg paused,
	input [3:0] unit
);
	wire lv,cv,rv;
	wire [3:0] var;
	integer nodes  = 0, counter = 0, counter2 = 60000000, force_out = 12000000;
	parameter NODE = 3'b000,
				 LT	= 3'b001,
				 RT	= 3'b010,
				 LINE = 3'b011,
				 STOP = 3'b100,
				 START= 3'b101,
				 OFF  = 3'b110,
				 DELAY= 3'b111,
			  BROKEN = 4'b1000,
			  CONTROL= 4'b1001,
			  RIGHT1 = 4'b1010,
			  EMPTY	= 4'b1011,
			  LEFT1  = 4'b1100,
			  F_RIGHT= 4'b1101,
			  END		= 4'b1110,
			  F_LEFT = 4'b1111,
			  F_RIGHT1=5'b10000,
			  PAUSE	= 5'b10001,
			  LITTLE_MOVE = 5'b10010,
			  LITTLE_LEFT = 5'b10011;
	
	parameter SU = 3'b001,
				 CPU= 3'b010,
				 B1 = 3'b011,
				 B3 = 3'b100,
				 AU = 3'b101,
				 E_U = 3'b110,
				 R_U = 3'b111,
				 C_U = 4'b1000,
				 B2  = 4'b1001,
				 B4  = 4'b1010;
		  
	reg [4:0] state = OFF, pstate = OFF, nstate = OFF;
	initial begin
	MLA = 1'b0;
	MLB = 1'b0;
	MRA = 1'b0;
	MRB = 1'b0;
	stop = 1'b0;
	blue_off = 1'b0;
	c_node = 1'b0;
	p_node = 1'b0;
	paused = 1'b0;
	end
				 
	assign lv  = (left_value > 250)   ? 1 : 0;
	assign cv  = (center_value > 250) ? 1 : 0;
	assign rv  = (right_value > 250)  ? 1 : 0;
	assign var = ((left_value > 950)||(center_value > 950)||(right_value > 950)) ? {1'b1,1'b1,1'b1,1'b1} : {1'b0,lv,cv,rv};

/*
Purpose:
FSM implementation of line following algorithm followed by AB which directs the AB on the black line betwwen any two nodes and at every node 
takes a new decision based on the iformation received from node_info module
*/		
	always @(posedge clock)
	begin
		if(counter2 >= 100000)
		begin
			if((left_value >= 950) && (center_value >= 950) && (right_value >= 950) && ((state == NODE) || (state == LINE)))
			begin
				nodes <= nodes + 1'b1;
				blue_off <= 1'b1;
				counter2 <= 1'b0;
			end
		end
		else
			counter2 <= counter2 + 1'b1;
		if(!reset)
			state <= OFF;
		else 
		begin
				begin
					case(state)
						OFF  : begin 
//										if(!push_button)
//											state <= START;
//										 else
//											state <= OFF;
									if(enable)
										state <= START;
									else
										state <= OFF;
									pstate <= OFF;
								 end
						START: begin case(var)
											3'b010 : nstate <= LINE;
											3'b000 : nstate <= START;
											3'b111 : nstate <= NODE;
											3'b100 : nstate <= LT;
											3'b110 : nstate <= LT;
											3'b001 : nstate <= RT;
											3'b011 : nstate <= RT;
											default: nstate <= STOP;
								
										 endcase
											pstate <= START;
										 if(state != nstate)
											state <= DELAY;
										else
											state <= START;
								 end
						LINE: begin 
											case(var)
												4'b0100 : nstate <= LT;
												4'b0110 : nstate <= LT;
												4'b0001 : nstate <= RT;
												4'b0011 : nstate <= RT;
												4'b1111 : begin nstate <= NODE; end
												4'b0000 : nstate <= BROKEN;
//												4'b1xxx : nstate <= IMM_REV;
												default: nstate <= LINE;
											 endcase
											 
											 pstate <= LINE;
										 
											if(!enable)
												state <= END;
											else if(bdm_convey)
												state <= LITTLE_MOVE;
											else if(state != nstate)
												state <= DELAY;
											else
												state <= LINE;
										blue_off <= 1'b0;
										green <= 1'b0;
								 end
//						IMM_REV: begin
//										if( counter <= 1000000 )
//										begin
//											state <= IMM_REV;
//											counter <= counter + 1'b1;
//										end
//										else
//										begin
//											if(var == 3'b010)
//											begin
//												state <= LINE;
//												pstate<= IMM_REV;
//											end
//										end
//									end
						RT: begin 	
								case(var)
									3'b010 : nstate <= LINE;
									3'b100 : nstate <= LT;
									3'b110 : nstate <= LT;
									4'b1111 : nstate <= NODE;
									//3'b101 : state <= STOP;
									default: nstate <= RT;
								 endcase
								 pstate <= RT;
								if(state != nstate)
									state <= DELAY;
								else
									state <= RT;
							 end
						F_RIGHT: begin
										if(force_out >= 14125000)
										begin
											case(var)
												3'b010 : nstate <= LINE;
												3'b011 : nstate <= LINE;
												default: nstate <= F_RIGHT;
											 endcase
											 pstate <= F_RIGHT;
											 if(state != nstate)
												state <= DELAY;
											else
												state <= F_RIGHT;
										end
										else
										begin
											if(!enable)
												state <= END;
											else
												state <= F_RIGHT;
											force_out <= force_out + 1'b1;
										end
									end
						RIGHT1:begin
									case(var)
										3'b100 : begin nstate <= F_RIGHT; force_out <= 0; end
										default: nstate <= RIGHT1;
									 endcase
									 pstate <= RIGHT1;
									 if(state != nstate)
										state <= DELAY;
									else
										state <= RIGHT1;
								 end
						F_RIGHT1:begin
										if(force_out >= 14125000)
										begin
											case(var)
												3'b010 : begin nstate <= F_RIGHT; force_out <= 0; end
												default: nstate <= F_RIGHT1;
											 endcase
											 pstate <= F_RIGHT1;
											 if(state != nstate)
												state <= DELAY;
											else
												state <= F_RIGHT1;
										end
										else
										begin
											if(!enable)
												state <= END;
											else
												state <= F_RIGHT1;
											force_out <= force_out + 1'b1;
										end
									end
						LT: begin 
									case(var)
										3'b001 : nstate <= RT;
										3'b011 : nstate <= RT;
										3'b010 : nstate <= LINE;
										4'b1111 : begin nstate <= NODE; end
										default: nstate <= LT;
									 endcase
									 pstate <= LT;
									if(state!=nstate)
										state <= DELAY;
									else
										state <= LT;
								 end	
						F_LEFT:begin
									if(force_out >= 14125000)
									begin
										case(var)
//											3'b001 : nstate <= RT;
//											3'b011 : nstate <= RT;
											3'b010 : nstate <= LINE;
											3'b110 : nstate <= LINE;
											3'b100 : nstate <= LINE;
											default: nstate <= F_LEFT;
										 endcase
										 pstate <= F_LEFT;
										 if(state!=nstate)
											state <= DELAY;
										else
											state <= F_LEFT;
									end
									else
									begin
										if(!enable)
											state <= END;
										else
											state <= F_LEFT;
										force_out <= force_out + 1'b1;
									end
								 end
						LEFT1:begin
									case(var)
//										3'b001 : nstate <= RT;
//										3'b011 : nstate <= RT;
										3'b001 : begin nstate <= F_LEFT; force_out <= 0; end
										default: nstate <= LEFT1;
									 endcase
									 pstate <= LEFT1;
									 if(state!=nstate)
										state <= DELAY;
									else
										state <= LEFT1;
								end
						NODE: begin
											case(var)
													3'b000 : begin nstate <= CONTROL; end
													3'b010 : begin nstate <= CONTROL; end
												default: begin nstate <= NODE; end
											 endcase
//										 end
										 pstate <= NODE;
										if(state != nstate)
										begin
											state <= DELAY;
											p_node <= c_node;
											c_node <= n_node;
										end
										else
											state <= NODE;
										green <= 1'b1;
								 end 
					CONTROL : begin
									case(dir)
										4'b0000 : begin state <= LT; end
										4'b0001 : begin state <= RT; end
										4'b0010 : begin state <= LINE; end
										4'b0011 : begin state <= STOP; end
//										3'b100 : begin
//														if(pstate == EMPTY)
//															state <= UTURN;
//														else
//															state <= REVERSE; 
//													end
										4'b0101 : begin state <= RIGHT1; end
										4'b0110 : begin state <= LEFT1;  end
										4'b0111 : begin state <= F_RIGHT;end
										4'b1000 : begin state <= F_LEFT; end
										4'b1001 : begin state <= F_RIGHT1;end
										default: begin state <= LINE; end
									endcase
									force_out <= 0;
								end
//					REVERSE : begin
//									if( counter >= 1000000 )
//									begin
//										if(var == 3'b010)
//										begin
//											state <= UTURN;
//											counter <= 1'b0;
//										end
//										else
//											state <= REVERSE;
//									end
//									else
//									begin
//										counter <= counter + 1'b1;
//										state <= REVERSE;
//									end
//								end
//					UTURN : begin
//										case(var)
//											3'b010 : nstate <= LINE;
//											default : nstate <= UTURN;
//										endcase
//										if(state != nstate)
//											state <= DELAY;
//										else
//											state <= UTURN;
//										pstate <= UTURN;
//								end
					DELAY: begin
										case(unit)
											B1, B2, B3, B4:	if( counter >= 3000000 )
																	begin
																		state <= nstate;
																		counter <= 1'b0;
																	end
																	else
																	begin
																		counter <= counter + 1'b1;
																		state <= DELAY;
																	end
											default			:	if( counter >= 2000000 )
																	begin
																		state <= nstate;
																		counter <= 1'b0;
																	end
																	else
																	begin
																		counter <= counter + 1'b1;
																		state <= DELAY;
																	end
										endcase
										pstate <= DELAY;
								end
					LITTLE_MOVE : begin
										if(counter >= 1125000)
										begin
											state <= LITTLE_LEFT;
											counter <= 0;
										end
										else
											counter <= counter + 1;										
									  end
//					LITTLE_LEFT	: begin
//										case(var)
//											3'b000 : state <= PAUSE;
//											default : state <= LITTLE_LEFT;
//										endcase
//									  end
					LITTLE_LEFT : begin
										if(counter >= 7225000)
										begin
											state <= PAUSE;
											counter <= 0;
										end
										else
											counter <= counter + 1;										
									  end
					PAUSE : begin
									if(counter >= 15125000)
									begin
										counter <= 0;
										state <= RT;
										paused <= 1'b0;
									end
									else
									begin
										counter <= counter + 1'b1;
										paused <= 1'b1;
									end
								end
					BROKEN: begin
										if( counter >= 10000000 )
										begin
											case(var)
												3'b000,3'b111 : nstate <= RT;
												3'b100 : nstate <= LT;
												3'b110 : nstate <= LT;
												3'b010 : nstate <= LINE;
												3'b011 : nstate <= RT;
												3'b001 : nstate <= RT;
												default : nstate <= BROKEN;
											endcase
											counter <= 1'b0;
										end
										else
										begin
											counter <= counter + 1'b1;
										end
										if(state != nstate)
											state <= DELAY;
										else
											state <= BROKEN;
										pstate <= BROKEN;
								end
					END : begin
								case(var)
									3'b010 : begin state <= STOP; end
									default: state <= END;
								endcase
								stop <= 1'b1;
							end
					STOP: begin
										state <= STOP;
										nodes <= 1'b0;
										if(counter >= 6250000)
										begin
											green <= ~green;
											counter <= 0;
										end
										else
											counter <= counter + 1;
										
							end
						default: state <= pstate;
					endcase
					end
		end
	end

/*
Purpose:
Defines speed and motion of motor based on different states of the AB during line following and also the unit in which the AB is present
*/		
	always @(state)
	begin
		case(state)
	OFF,STOP,PAUSE	: begin 
								MLA <= 1'b0; MRA <= 1'b0; MLB <= 1'b0; MRB <= 1'b0;
						   end
	LITTLE_MOVE,LINE,START: begin
								case(unit)
									B1, B2, B3, B4 : begin MLA <= 4'b0101; MRA <= 4'b0101; MLB <= 1'b0; MRB <= 1'b0; end
									default: begin MLA <= 4'b0111; MRA <= 4'b0111; MLB <= 1'b0; MRB <= 1'b0; end
								endcase
							end
LITTLE_LEFT,LT,F_LEFT,LEFT1: begin 
								case(unit)
									B1, B2, B3 ,B4 : begin MLA <= 1'b0; MRA <= 4'b0110; MLB <= 4'b0110; MRB <= 1'b0; end
									default			: begin MLA <= 1'b0; MRA <= 4'b0110; MLB <= 4'b0110; MRB <= 1'b0; end
								endcase
							end
RT,END,F_RIGHT,RIGHT1,F_RIGHT1: 
							begin 
							case(unit)
									B1, B2, B3, B4	:	begin MLA <= 4'b0110; MRA <= 1'b0; MLB <= 1'b0; MRB <= 4'b0110; end
									default			:	begin MLA <= 4'b0110; MRA <= 1'b0; MLB <= 1'b0; MRB <= 4'b0110; end
							endcase
							end
NODE,CONTROL		: begin 
								MLA <= 4'b0100; MRA <= 4'b0100; MLB <= 1'b0; MRB <= 1'b0;
							end
			DELAY		: begin 
								MLA <= 1'b0; MRA <= 1'b0; MLB <= 1'b0; MRB <= 1'b0;
							end
			BROKEN	: begin 
								MLA <= 1'b0; MRA <= 4'b0110; MLB <= 4'b0110; MRB <= 1'b0;
							end
			default	: begin 
								MLA <= 1'b0; MRA <= 1'b0; MLB <= 1'b0; MRB <= 1'b0; 

							end
		endcase
	end
	
endmodule 
