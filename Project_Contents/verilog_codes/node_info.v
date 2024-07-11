/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         node_info
# File Description: Gives information related to relative position of a node wrt to other nodes
# Global variables: None
*/
module node_info(
	input clock,
	input [7:0] c_node,p_node,n_node,
	output reg [3:0] dir	//MLA,MRA,MLB,MRB
);
	reg prev_dir = 3'b0;
	parameter LEFT = 3'd0,
				 RIGHT= 3'd1,
				 LINE	= 3'd2,
				 STOP	= 3'd3,
				 REV	= 3'd4,
				 RIGHT1=3'd5,
				 LEFT1= 3'd6,
				 F_RIGHT=3'd7,
				 F_LEFT =4'd8,
				 F_RIGHT1=4'd9;
	initial begin
		prev_dir = LINE;
	end
	
/*
Purpose:
Gives the direction of the next node with respect to the current node based on the previous node which the AB has traversed (to know the orientation of AB at the current node
*/	
	always @(posedge clock)
	begin
		case({p_node,c_node})
//////////////////////////////////////////////////
			{8'd0,8'd0}		:	case(n_node)
								default	:	dir <= prev_dir;
							endcase
			{8'd1,8'd0}		:	case(n_node)
								default	:	dir <= LINE;
							endcase
//////////////////////////////////////////////////
			{8'd29,8'd1}	:	case(n_node)
								2			:	dir <= LINE;
								0			:	dir <= F_LEFT;
								29			:	dir <= F_RIGHT;
								default	: 	dir <= LINE;
							endcase
			{8'd0,8'd1}		:	case(n_node)
								2			:	dir <= LEFT;
								29			:	dir <= RIGHT;
								0			:  dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
/////////////////////////////////////////////////
			{8'd1,8'd2}		:	case(n_node)
								3			:	dir <= LEFT;
								8			:  dir <= RIGHT;
								1			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd3,8'd2}		: case(n_node)
								1			:	dir <= RIGHT;
								8			:	dir <= LEFT;
								3			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd8,8'd2}		: case(n_node)
								1			:	dir <= LEFT;
								3			:	dir <= RIGHT;
								8			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd28,8'd3}	:	case(n_node)
								2			:	dir <= RIGHT;
								4			:	dir <= LEFT;
								28			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd2,8'd3}		:	case(n_node)
								28			:	dir <= LEFT;
								4			:	dir <= RIGHT;
								2			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd4,8'd3}		:	case(n_node)
								2			:	dir <= LEFT;
								28			:	dir <= RIGHT;
								4			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd3,8'd4}		:	case(n_node)
								5			:	dir <= F_RIGHT;
								6			:	dir <= LINE;
								3			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd5,8'd4}		:	case(n_node)
								3			:	dir <= LEFT;
								6			:	dir <= RIGHT;
								5			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd6,8'd4}		:	case(n_node)
								5			:	dir <= F_LEFT;
								3			:	dir <= LINE;
								6			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd4,8'd5}		:	case(n_node)
								4			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd4,8'd6}		:	case(n_node)
								7			:	dir <= LINE;
								4			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
			{8'd7,8'd6}		:	case(n_node)
								4			:	dir <= LINE;
								7			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd6,8'd7}		:	case(n_node)
								8			:	dir <= LEFT;
								6			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
			{8'd8,8'd7}		:	case(n_node)
								6			:	dir <= LEFT;
								8			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd7,8'd8}		:	case(n_node)
								9			:	dir <= LINE;
								2			:	dir <= F_RIGHT;
								12			:	dir <= F_LEFT;
								7			:	dir <= F_RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd2,8'd8}		:	case(n_node)
								7			:	dir <= LEFT;
								12			:	dir <= RIGHT;
								9			:	dir <= RIGHT1;
								2			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd9,8'd8}		:	case(n_node)
								7			:	dir <= LINE;
								2			:	dir <= F_LEFT;
								12			:	dir <= F_RIGHT;
								9			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd12,8'd8}	:	case(n_node)
								2			:	dir <= LEFT;
								7			:	dir <= RIGHT;
								9			:	dir <= LEFT1;//
								12			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd8,8'd9}		:	case(n_node)
								10			:	dir <= RIGHT;
								11			:	dir <= LEFT;
								8			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd10,8'd9}	:	case(n_node)
								8			:	dir <= LEFT;
								11			:	dir <= RIGHT;
								10			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd11,8'd9}	:	case(n_node)
								8			:	dir <= RIGHT;
								10			:	dir <= LEFT;
								11			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd9,8'd10}	:	case(n_node)
								9			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd9,8'd11}	:	case(n_node)
								9			:	dir <= LEFT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd8,8'd12}	:	case(n_node)
								19			:	dir <= RIGHT;
								13			:	dir <= LEFT;
								8			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
			{8'd19,8'd12}	:	case(n_node)
								8			:	dir <= F_LEFT;
								13			:	dir <= LINE;
								19			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
			{8'd13,8'd12}	:	case(n_node)
								19			:	dir <= LINE;
								8			:	dir <= F_RIGHT;
								13			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd12,8'd13}	:	case(n_node)
								14			:	dir <= RIGHT;
								12			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd14,8'd13}	:	case(n_node)
								12			:	dir <= LEFT;
								14			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd13,8'd14}	:	case(n_node)
								15			:	dir <= F_RIGHT;
								16			:	dir <= LINE;
								13			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd15,8'd14}	:	case(n_node)
								13			:	dir <= LEFT;
								16			:	dir <= RIGHT;
								15			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd16,8'd14}	:	case(n_node)
								13			:	dir <= LINE;
								15			:	dir <= F_LEFT;
								16			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd14,8'd15}	:	case(n_node)
								14			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd14,8'd16}	:	case(n_node)
								17			:	dir <= F_RIGHT;
								18			:	dir <= LINE;
								14			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd17,8'd16}	:	case(n_node)
								18			:	dir <= RIGHT;
								14			:	dir <= LEFT	;
								17			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd18,8'd16}	:	case(n_node)
								14			:	dir <= LINE;
								18			:	dir <= F_RIGHT;
								17			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd16,8'd17}	:	case(n_node)
								16			:	dir <= LEFT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd16,8'd18}	:	case(n_node)
								19			:	dir <= RIGHT;
								16			:	dir <= LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd19,8'd18}	:	case(n_node)
								16			:	dir <= LINE;
								19			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd18,8'd19}	:	case(n_node)
								12			:	dir <= LEFT;
								20			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd12,8'd19}	:	case(n_node)
								18			:	dir <= RIGHT;
								20			:	dir <= RIGHT1;
								12			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd20,8'd19}	:	case(n_node)
								18			:	dir <= RIGHT;
								12			:	dir <= LEFT;
								20			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////
			{8'd29,8'd20}	:	case(n_node)
								24			:	dir <= RIGHT;
								19			:	dir <= LEFT;
								21			:	dir <= LEFT1;
								29			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd24,8'd20}	:	case(n_node)
								29			:	dir <= F_LEFT;
								19			:	dir <= F_RIGHT;
								21			:	dir <= LINE;
								24			:	dir <= F_RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd21,8'd20}	:	case(n_node)
								29			:	dir <= F_RIGHT;
								24			:	dir <= LINE;
								21			:	dir <= F_RIGHT1;
								19			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd19,8'd20}	:	case(n_node)
								24			:	dir <= LEFT;
								29			:	dir <= RIGHT;
								21			:	dir <= RIGHT1;
								19			:	dir <= LEFT1;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////							
			{8'd20,8'd21}	:	case(n_node)
								22			:	dir <= LEFT;
								23			: 	dir <= RIGHT;
								20			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd23,8'd21}	:	case(n_node)
								22			: dir <= RIGHT;
								20			: dir <= LEFT;
								23			: dir <= RIGHT1;
								default	: dir <= LINE;
							endcase
			{8'd22,8'd21}	:	case(n_node)
								23			: dir <=	LEFT;
								20			: dir <= RIGHT;
								22			: dir <= RIGHT1;
								default	: dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd21,8'd22}	:	case(n_node)
								21			:	dir <= LEFT;	
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd21,8'd23}	:	case(n_node)
								21			:	dir <= LEFT;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd25,8'd24}	:	case(n_node)
								25			:	dir <= F_RIGHT;
								20			:  dir <= LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd20,8'd24}	:	case(n_node)
								20			:	dir <= F_LEFT;
								25			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////
			{8'd24,8'd25}	:	case(n_node)
								24			:	dir <= F_RIGHT;
								default	:	dir <= LINE;	
							endcase
			{8'd26,8'd25}	:	case(n_node)
								26			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
////////////////////////////////////////////////		
			{8'd25,8'd26}	:	case(n_node)
								27			:	dir <= F_RIGHT;
								28			:  dir <= LINE;
								25			:	dir <= F_LEFT;
								default	:	dir <= LINE;
							endcase
			{8'd27,8'd26}	:	case(n_node)
								25			:	dir <= LEFT;
								28			:  dir <= RIGHT;
								27			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd28,8'd26}	:	case(n_node)
								25			:	dir <= LINE;
								27			:  dir <= F_LEFT;
								28			:	dir <= F_RIGHT;
								default	:	dir <= LINE;
							endcase
//////////////////////////////////////////////////							
			{8'd26,8'd27}	:	case(n_node)
								26			:	dir <= RIGHT;
								default	:	dir <= LINE;
							endcase
///////////////////////////////////////////////////
			{8'd26,8'd28}	:	case(n_node)
								29			:	dir <= RIGHT;
								3			:	dir <= LEFT;
								26			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd29,8'd28}	:	case(n_node)
								26			:	dir <= LEFT;
								3			:	dir <= RIGHT;
								29			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd3,8'd28}	:	case(n_node)
								29			:	dir <= LEFT;
								26			:	dir <= RIGHT;
								3			:	dir <= LINE;
								default	:	dir <= LINE;
							endcase
/////////////////////////////////////////////////
			{8'd1,8'd29}	:	case(n_node)
								20			:	dir <= LEFT;
								28			:	dir <= RIGHT;
								1			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd28,8'd29}	:	case(n_node)
								20			:	dir <= RIGHT;
								1			:	dir <= LEFT;
								28			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			{8'd20,8'd29}	:	case(n_node)
								28			:	dir <= LEFT;
								1			:	dir <= RIGHT;
								20			:	dir <= RIGHT1;
								default	:	dir <= LINE;
							endcase
			default	:	dir <= LINE;
		endcase
		prev_dir <= dir;
	end
endmodule
