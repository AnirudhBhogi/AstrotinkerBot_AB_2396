/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         cpu_controller
# File Description: External module to form final message from rx and to communiacte with riscv cpu
# Global variables: None
*/

module cpu_controller(
	input clock,
	input [3:0] f_cdc_code,
	input rx_complete,
	input [7:0] c_node,
	input f_found,
	input [31:0] ReadData,
	input [31:0] DataAdr,
	input [31:0] WriteData,
	input MemWrite,
	output reg [3:0] unit,
	output reg [7:0] n_risc_node,
	output reg enable,
	output reg [31:0] Ext_DataAdr,
	output reg [31:0] Ext_WriteData,	
	output reg Ext_MemWrite,
	output reg rst,
	input req,
	output reg ack,
	output ifm_eu, ifm_ru, ifm_cu,
	input bdm
);
// enable 						: Signifies whtger AB is in motion or not
// unit							: Unit/Column due to which AB is currently traversing 
// n_risc_node 				: The next node as per the path formed by the riscv cpu
// req, ack 					: Signals for CDC
// ifm_eu, ifm_ru, ifm_cu 	: Led signals that the IFM messsage for that unit has been received

	parameter SU = 3'b001,
				 B1 = 3'b011,
				 B3 = 3'b100,
				 AU = 3'b101,
				 E_U = 3'b110,
				 R_U = 3'b111,
				 C_U = 4'b1000,
				 B2  = 4'b1001,
				 B4  = 4'b1010;
// E_U, R_U, C_U				: Core units decided based on IFM message
// B1, B2, B3, B4				: Blocks going to be / to be picked acc. to PBM message

	reg [1:0] S0 = 2'b01,
				 S1 = 2'b10,
			  init = 2'b00;
// S0, S1, init				: States designed for CDC
				 
	parameter start_addr = 32'h02000000,
				 end_addr 	= 32'h02000004, 
				 node_addr 	= 32'h02000008,
				 cpu_addr 	= 32'h0200000c,
				 clear_start= 4'b0111,
				 clear_end	= 4'b1000,
				 clear_node	= 4'b1001,
				 clear_cpu	= 4'b1010,
				 init_cpu	= 4'b1011,
				 init_node	= 4'b1100,
				 start_point= 4'b0001,
				 end_point	= 4'b0010,
				 cpu_process= 4'b0011,
				 path_form	= 4'b0100,
				 path_share	= 4'b0101,
				 IFM			= 4'b0000,
				 delay		= 4'b1101,
				 PBM			= 4'b1110;
	
// clear_start				: Resets the signals after writing start point to the data memory
// clear_end				: Resets the signals after writing end point to the data memory
// clear_cpu				: Resets the signals after writing  cpu done as 0 to the data memory
// clear_node  			: Resets the signals after writing node point to the data memory
// init_cpu					: Initializes cpu done memory loaction to zero
// init_node				: Initializes node point memory location to zero
// path_form				: Formation of path occurs
// path_share				: Path extraction pf the path array occurs here
// delay						: To ensure proper synchorization of events
// IFM						: Extracts the next encoded IFM message once one fault is solved


	reg [239:0] path = 0;
	reg [7:0] START_POINT, END_POINT;
	reg [3:0] state = IFM, nstate;
	reg [1:0] cdc_state;
	reg [7:0] p_node = 8'd1;
	reg ask_ifm=1'b0, given_ifm=1'b0;
	reg [19:0] messages_ifm, messages_pbm;
	reg [3:0] message_ifm, message_pbm;
	reg [7:0] f_node;
	reg [7:0] f_prev_node;
	reg [3:0] f_unit;
	reg [5:0] index;
	reg [55:0] ESU = {8'd20, 8'd24, 8'd25, 8'd26, 8'd27, 8'd26, 8'd28};
	reg [71:0] RSU = {8'd12, 8'd13, 8'd14, 8'd15, 8'd14, 8'd16, 8'd17, 8'd16, 8'd18};
	reg [55:0] CSU = {8'd2, 8'd3, 8'd4, 8'd5, 8'd4, 8'd6, 8'd7};
	reg [7:0] EU_SP = 8'd29, E_U_EP = 8'd20, START = 8'd0, B1_P = 8'd22, B3_P = 8'd23, RU_SP = 8'd19, CU_SP = 8'd8, B2_P = 8'd10, B4_P = 8'd11;
	integer counter = 0;
	reg ifm [2:0];
	reg bdm_reg = 1'b0, reset_bdm = 1'b0;

// path					: To store path to be followed
// START_POINT			: To store the start point that is to written in the start point memory location of dmem
// END_POINT			: To store the end point that is to written in the end point memory location of dmem
// state					: State variable of the main FSM of cpu_controller module
// n_state				: State to be executed after the delay is done
// cdc_state			: State variable of CDC's FSM
// p_node				: To prevent extraction of next node from path array until next node is reached
// ask, given			: Signals to ensure proper extraction of next ifm/pbm message to be exectuted from messgaes array
// messages				: Array to store the encoded ifm and pbm messages
// f_node 				: Node closest to the FI
// f_unit 				: Faulty unit
// index					: The position where next ifm is to be stored in the queue which has lesser priority as compared to pbm message
// RSU, CSU, ESU		: Hardcoded Node values for entire unit traversal
// EU_SP,RU_SP,CU_SP : Node points from which unit traversal begins
//B1_P,B2_P,B3_P,B4_P: Node points closest to correspondig blocks
// counter				: To generate delay
// ifm					: Array to integrate ifm related led signals

	assign ifm_eu = ifm[0];
	assign ifm_ru = ifm[1];
	assign ifm_cu = ifm[2];
	
	initial begin
		rst = 1'b1; 
		END_POINT = 8'd0;
		START_POINT = 8'd0;
		Ext_MemWrite = 0;
		Ext_WriteData = 32'h0;
		Ext_DataAdr = 32'h0;
		p_node = 1;
		messages_ifm = 20'b0;
		message_ifm = 4'b0;
		messages_pbm = 20'b0;
		message_pbm = 4'b0;
		n_risc_node = 8'd0;
		enable = 1'b0;
		index = 5'b0;
		cdc_state = init;
		ack = 1'b0;
		ifm[0] = 1'b0; ifm[1] = 1'b0; ifm[2] = 0;
		f_prev_node = 8'b0;
	end

	always @(posedge bdm or posedge reset_bdm)
	begin
		if(reset_bdm)
			bdm_reg <= 1'b0;
		else
			bdm_reg <= 1'b1;
	end
/*
Purpose:
Implementation of CDC and also a linear priority queue data structure that dequeues a PBM before a IFM so that the AB can start traversal as soon as the first IFM is received
*/	
	always @(negedge clock)
	begin
		case(cdc_state)
		 init : begin 
						if(req && !ack) 
						begin 
							message_ifm <= f_cdc_code; given_ifm <= 1'b1; ack <= 1'b1;
							case(f_cdc_code)
								4'b0001 : ifm[0] <= 1'b1;
								4'b0100 : ifm[1] <= 1'b1;
								4'b0101 : ifm[2] <= 1'b1;
							endcase
						end
						if(!req && ack) begin cdc_state <= S0; ack <= 1'b0; end
				  end
			S0	: begin
						if(req && !ack) 
						begin 
							if(f_cdc_code == 4'b0001 || f_cdc_code == 4'b0100 || f_cdc_code == 4'b0101) 
							begin
								messages_ifm <= messages_ifm | (f_cdc_code << index);
								case(f_cdc_code)
									4'b0001 : ifm[0] <= 1'b1;
									4'b0100 : ifm[1] <= 1'b1;
									4'b0101 : ifm[2] <= 1'b1;
								endcase
							end // If IFM
							else
							begin 
								message_pbm <= f_cdc_code; 
							end // If not IFM
							ack <= 1'b1;
//							index <= index + 5'd4;
						end
						else
						begin
							if(ask_ifm && !given_ifm)
							begin
								message_ifm <= messages_ifm[3:0];
								index <= index - 5'd4;
								given_ifm <= 1'b1;
								messages_ifm <= {4'b0, messages_ifm[19:4]};
								case(messages_ifm[3:0])
									4'b0001 : ifm[0] <= 1'b1;
									4'b0100 : ifm[1] <= 1'b1;
									4'b0101 : ifm[2] <= 1'b1;
								endcase								
							end
							if(!ask_ifm)
							begin
								given_ifm <= 1'b0;
							end
							
//							if(ask_pbm && !given_pbm)
//							begin
//								message_pbm <= messages_pbm[3:0];
//								index <= index - 5'd4;
//								given_pbm <= 1'b1;
//								messages_pbm <= {4'b0, messages_pbm[19:4]};
//							end
//							if(!ask_pbm)
//							begin
//								given_pbm <= 1'b0;
//							end
						end
						if(!req && ack) begin cdc_state <= S0; ack <= 1'b0; end
			     end
			default : begin cdc_state <= S0; end
		endcase
	end

	//FSM for giving and receiving data from RISCV CPU
/*
Purpose:
FSM implementation of path formation and path planning based on IFM and PBM messages and also intgrates the path planned by RISCV and also hardcoded core unit traversal path according to need 
*/	
	always @(posedge clock)
	begin
		case(state)
			IFM			: 	begin
									reset_bdm <= 1'b0;
									if(!given_ifm)
										ask_ifm <= 1'b1;
									else
									begin
										ask_ifm <= 1'b0;
										case(message_ifm)
											4'b0001 : begin
															unit <= E_U;
															f_unit <= E_U;
															END_POINT <= EU_SP;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															path <= {path[239:72], ESU};
															end
											4'b0100	: begin
															unit <= R_U;
															f_unit <= R_U;
															END_POINT <= RU_SP;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															path <= {path[239:72], RSU};
															end
											4'b0101	: begin
															unit <= C_U;
															f_unit <= C_U;
															END_POINT <= CU_SP;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															path <= {path[239:72], CSU};
															end
											default : begin if(enable && ((unit != E_U)))// && (unit != R_U) && (unit != C_U)) && (n_risc_node == c_node))
																	begin
																		enable <= 1'b0;
																	end
															end 
										endcase
									end
								end
			PBM			: begin
//									if(!given_pbm)
//										ask_pbm <= 1'b1;
//									else
//									begin
//										ask_pbm <= 1'b0;
										case(message_pbm)				
											4'b0010 : begin
															unit <= B1;
															END_POINT <= B1_P;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															f_node <= n_risc_node;
															f_prev_node <= c_node;
														end
											4'b0011 : begin
															unit <= B3;
															END_POINT <= B3_P;
															START_POINT <= n_risc_node;
															state <= start_point;
															f_node <= n_risc_node;
															rst <= 1'b1;
															f_prev_node <= c_node;
														end
											4'b0110  : begin
															unit <= B2;
															END_POINT <= B2_P;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															f_node <= n_risc_node;
															f_prev_node <= c_node;
														end
											4'b0111  : begin
															unit <= B4;
															END_POINT <= B4_P;
															START_POINT <= n_risc_node;
															state <= start_point;
															rst <= 1'b1;
															f_node <= n_risc_node;
															f_prev_node <= c_node;
														end
											default : begin if(enable && ((unit != E_U) && (unit != R_U) && (unit != C_U)) && (n_risc_node == c_node))
																	begin
																		enable <= 1'b0;
																	end
															end 
										endcase
//									end	
								end
			start_point	: begin
										enable <= 1'b1;
										Ext_MemWrite <= 1'b1; Ext_DataAdr <= start_addr; Ext_WriteData <= {{24{1'b0}},END_POINT}; 
										if((DataAdr == start_addr) && (WriteData[7:0] == END_POINT))
											state <= clear_start;
							  end
			clear_start	: begin Ext_MemWrite <= 1'b0; Ext_DataAdr <= 32'h0; Ext_WriteData <= 32'h0; state <= end_point; end
			end_point	: begin
									   Ext_MemWrite <= 1'b1; Ext_DataAdr <= end_addr; Ext_WriteData <= {{24{1'b0}},START_POINT};

										if((DataAdr == end_addr) && (WriteData[7:0] == START_POINT))
											state <= clear_end;
							  end
			clear_end	: begin Ext_MemWrite <= 1'b0; Ext_DataAdr <= 32'h0; 		Ext_WriteData <= 32'h0; state <= init_node; end
			init_node	: begin Ext_MemWrite <= 1'b1; Ext_DataAdr <= node_addr; Ext_WriteData <= 32'b0; 
									  if((DataAdr == node_addr) && (WriteData[7:0] == 8'b0))
										state <= clear_node; 
								end
			clear_node	: begin Ext_MemWrite <= 1'b0; Ext_DataAdr <= 32'h0; 		Ext_WriteData <= 32'h0; state <= init_cpu; end
			init_cpu		: begin Ext_MemWrite <= 1'b1; Ext_DataAdr <= cpu_addr;  Ext_WriteData <= 32'b0; 
									  if((DataAdr == cpu_addr) && (WriteData[7:0] == 8'b0))
										state <= clear_cpu; 
							  end
			clear_cpu	: begin Ext_MemWrite <= 1'b0; Ext_DataAdr <= 32'h0; Ext_WriteData <= 32'h0; state <= path_form;	end
			path_form	: begin
									 if(MemWrite && (DataAdr === cpu_addr) && WriteData[0]) 
										begin state <= path_share; rst <= 1'b1; path <= {8'b0, path[239:8]};  end
									 else
									  begin rst <= 1'b0; end
									  if((DataAdr === node_addr) && MemWrite) 
									  begin path <= {path[231:0], WriteData[7:0]}; end
								end
		   path_share	: begin
									if(c_node != p_node)
									begin
										n_risc_node <= path[7:0];
										p_node <= c_node;
										path <= {8'b0, path[239:8]};
									end
									
//									//As once block is dropped we can proceed to next fault message 
									if((unit == B1) || (unit == B3) || (unit ==B2) || (unit == B4))
									begin
										if((n_risc_node == f_node) && (f_unit == 0) && bdm_reg)
										begin
											nstate <= IFM;
											state <= delay;
											path <= 0;
											reset_bdm <= 1'b1;
											unit <= 0;
											if(messages_ifm == 0)
											begin
												enable <= 1'b0;
											end
										end
									end
									
									if(f_found)
									begin
										case(unit)
										E_U : begin
													nstate <= PBM;
													state <= delay;
													path <= 0;
												end
										R_U : begin
													nstate <= PBM;
													state <= delay;
													path <= 0;
												end
										C_U : begin
													nstate <= PBM;
													state <= delay;
													path <= 0;
												end
										endcase
									end
									
									if(path==0)
									begin
										if((unit == B1 || unit == B3 || unit == B2 || unit == B4) && f_unit != 0)
										begin
											nstate <= start_point;
											state <= delay;
											path <= 0;
											START_POINT <= n_risc_node;
											f_unit <= 0;// As fault is going to be solved so it not faulty anymore
//											if(f_unit == E_U)
//											begin
//												END_POINT <= EU_SP;
//												path <= {path[183:0], ESU};
//											end
//											else if(f_unit == R_U)
//											begin
//												END_POINT <= RU_SP;
//												path <= {path[167:0], RSU};
//											end
//											else if(f_unit == C_U)
//											begin
//												END_POINT <= CU_SP;
//												path <= {path[183:0], CSU};
//											end
											END_POINT <= f_node;
											path <= {path[223:0], f_node, f_prev_node};
										end
//										else
//										begin
//											nstate <= IFM;// //As once block is dropped we can proceed to next fault message
//											state <= delay;
//										end
									end
								end
			delay			: begin
									if(counter >= 15000000)
									begin
										state <= nstate;
										counter <= 0;
									end
									else
									begin
										counter <= counter + 1;
									end
								end
			default		: state <= IFM;
		endcase
	end
endmodule