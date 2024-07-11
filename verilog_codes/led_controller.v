/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         led_controller
# File Description: Takes care of turning on the correct colour led depending on the event that occurs
# Global variables: None
*/
module led_controller(
	input blue_on,
	input clock,
	input fim_eu, fim_ru, fim_cu,
	input bdm,
	input stop,
	input ifm_eu, ifm_ru, ifm_cu,
	output reg G_EU, B_EU, R_EU, G_RU, B_RU, R_RU, G_CU, B_CU, R_CU,
	output node
	);
	reg [2:0] NULL= 3'd1,
				 IFM = 3'd2,
				 FIM = 3'd3,
				 BDM = 3'd4,
				 END = 3'd5;
	reg [2:0] eu_state, ru_state, cu_state;
	wire ifm [2:0], fim [2:0];
	integer counter = 0;
	
	assign ifm[0] = ifm_eu;
	assign fim[0] = fim_eu;
	assign ifm[1] = ifm_ru;
	assign fim[1] = fim_ru;
	assign ifm[2] = ifm_cu;
	assign fim[2] = fim_cu;
	
	initial begin
		eu_state = NULL;
		ru_state = NULL;
		cu_state = NULL;
		G_EU		= 1'b0;
		B_EU		= 1'b0;
		R_EU		= 1'b0;
		G_RU		= 1'b0;
		B_RU		= 1'b0;
		R_RU		= 1'b0;
		G_CU		= 1'b0;
		B_CU		= 1'b0;
		R_CU		= 1'b0;
	end
	assign node = blue_on;
	
/*
Purpose:
FSM implementation of EU's led colour based on messages sent and received by AB
*/	
	always @(posedge clock)
	begin
		case(eu_state)
			NULL : begin 
						G_EU	<= 1'b0; B_EU <= 1'b0; R_EU <= 1'b0; 
						if(ifm[0])
							eu_state <= IFM;
						else if(stop)
						begin
							eu_state <= END;
						end
					end
			IFM  : begin
						R_EU <= 1'b1; B_EU <= 1'b0; G_EU <= 1'b0;
						if(fim[0])
						begin
							eu_state <= FIM;
						end
					end
			FIM  : begin
						B_EU <= 1'b1; R_EU <= 1'b0; G_EU <= 1'b0;
						if(bdm)
						begin
							eu_state <= BDM;
						end
					end
			BDM  : begin
						if(fim[0])
						begin
							eu_state <= FIM;
						end
						else if(stop)
						begin
							eu_state <= END;
						end
						else
						begin
							G_EU <= 1'b1; B_EU <= 1'b0; R_EU <= 1'b0;
						end
					end
			END : begin
						if(counter >= 3125000)
						begin
							G_EU <= ~G_EU;
							counter <= 0;
						end
						else
							counter <= counter + 1'b1;
					end
			default : eu_state <= NULL;
		endcase
	end

/*
Purpose:
FSM implementation of RU's led colour based on messages sent and received by AB
*/	
	always @(posedge clock)
	begin
		case(ru_state)
			NULL : begin 
						G_RU	<= 1'b0; B_RU <= 1'b0; R_RU <= 1'b0; 
						if(ifm[1])
							ru_state <= IFM;
						else if(stop)
						begin
							ru_state <= END;
						end
					end
			IFM  : begin
						R_RU <= 1'b1; B_RU <= 1'b0; G_RU <= 1'b0;
						if(fim[1])
						begin
							ru_state <= FIM;
						end
					end
			FIM  : begin
						R_RU <= 1'b0; B_RU <= 1'b1; G_RU <= 1'b0;
						if(bdm)
						begin
							ru_state <= BDM;
						end
					end
			BDM  : begin
						if(fim[1])
						begin
							ru_state <= FIM;
						end
						else if(stop)
						begin
							ru_state <= END;
						end
						else
						begin
							R_RU <= 1'b0; B_RU <= 1'b0; G_RU <= 1'b1;
						end
					end
			END  : begin
						G_RU <= G_EU;
					end
			default : ru_state <= NULL;
		endcase
	end

/*
Purpose:
FSM implementation of CU's led colour based on messages sent and received by AB
*/	
	always @(posedge clock)
	begin
		case(cu_state)
			NULL : begin 
						G_CU	<= 1'b0; B_CU <= 1'b0; R_CU <= 1'b0; 
						if(ifm[2])
							cu_state <= IFM;
						else if(stop)
						begin
							cu_state <= END;
						end
					end
			IFM  : begin
						R_CU <= 1'b1; B_CU <= 1'b0; G_CU <= 1'b0;
						if(fim[2])
						begin
							cu_state <= FIM;
						end
					end
			FIM  : begin
						R_CU <= 1'b0; B_CU <= 1'b1; G_CU <= 1'b0;
						if(bdm)
						begin
							cu_state <= BDM;
						end
					end
			BDM  : begin
						if(fim[2])
						begin
							cu_state <= FIM;
						end
						else if(stop)
						begin
							cu_state <= END;
						end
						else
						begin
							R_CU <= 1'b0; B_CU <= 1'b0; G_CU <= 1'b1;
						end
					end
			END : begin 
						G_CU <= G_EU;
					end
			default : cu_state <= NULL;
		endcase
	end
endmodule