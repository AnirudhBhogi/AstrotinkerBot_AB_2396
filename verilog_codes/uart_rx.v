/*
# Team ID:          2396
# Theme:            AstroTinker Bot
# Author List:      Anirudh bhogi
# Filename:         uart_rx
# File Description: Receives data from the bluetooth module
# Global variables: None
*/

// module declaration
module uart_rx (
  input clk_50M, rx,
  output reg [7:0] rx_msg,
  output reg rx_complete,
  output reg [3:0] f_cdc_code,
  output reg req,
  input ack,
  output reg clk_115200
);


integer count=0;
integer j=0;
parameter S0=0,S1=1,S2=2,S3=3,S4=4,S5=5,S6=6,S7=7,S8=8,S9=9,S10=10,idle=11;
reg [3:0] state, cdc_state;
reg [3:0] prev;
reg [7:0] temp=8'b0;
integer counter=216;
integer index=0;
reg flag=0;
reg [87:0] data = 0;
reg [3:0] f_code;

initial begin

	rx_msg = 0; rx_complete = 0;state=S0;
	temp=32'b0;clk_115200=0;temp=8'b0;prev=S0;
	data = 88'd0;
	f_code = 4'b0;
	f_cdc_code = 4'b0;
	cdc_state = S0;
	req = 1'b0;
end

/*
Purpose:
Generation of 115200Hz clock for data for getting 115200 baud rate used for bluetooth transmission
*/	
always @(posedge clk_50M)
begin
	if(counter>=216)
	begin
		clk_115200<=~clk_115200;
		counter<=0;

		if(count>=10 && temp!=0 && rx==1'b0)
			rx_complete<=1;
	end
	
	else
	begin
		counter<=counter+1;
		rx_complete<=0;
	end

end 

/*
Purpose:
FSM implemnetation of receiver part of uart
*/	
always @(posedge clk_115200)
begin
	case(state)
		S0: begin if(rx===1'b0) begin state<=S1;end 
					 else if(^rx===1'bx) begin state<=idle;end 
				    else begin state<=S0; end 
					 prev<=S0;
					 casex(data)
{{24{1'bx}},"IFM-EU-#"},{{8{1'bx}},"IFM-E",{24{1'bx}},"-#"}	: begin f_code <= 4'b0001; data <= 0; end
			"PBM-SU-B1-#"	: begin f_code <= 4'b0010; data <= 0; end
			"PBM-SU-B3-#"	: begin f_code <= 4'b0011; data <= 0; end
{{24{1'bx}},"IFM-RU-#"},{{8{1'bx}},"IFM-R",{24{1'bx}},"-#"}	: begin f_code <= 4'b0100; data <= 0; end
{{24{1'bx}},"IFM-CU-#"},{{8{1'bx}},"IFM-C",{24{1'bx}},"-#"}	: begin f_code <= 4'b0101; data <= 0; end
			"PBM-SU-B2-#"	: begin f_code <= 4'b0110; data <= 0; end
			"PBM-SU-B4-#"	: begin f_code <= 4'b0111; data <= 0; end
					88'd0		: begin f_code <= 4'b0000; end
					 default : begin 
									f_code <= 4'b0;
								  end 
					 endcase
			 end
		S1: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S2;temp[0]<=rx;
					 end
					 prev<=S1;
			 end
		S2: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S3;temp[1]<=rx; end
					 prev<=S2;
			 end
		S3: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S4;temp[2]<=rx; end
					 prev<=S3;
			 end
		S4: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S5;temp[3]<=rx; end
					 prev<=S4;
			 end
		S5: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S6;temp[4]<=rx; end
					 prev<=S5;
			 end
		S6: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S7;temp[5]<=rx; end
					 prev<=S6;
			 end
		S7: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S8;temp[6]<=rx; end
					 prev<=S7;
			 end
		S8: begin if(^rx===1'bx)
					 begin state<=idle; end
					 else
					 begin state<=S9;temp[7]<=rx; end 
					 prev<=S8;
			 end
		S9: begin if(rx===1'b1) state<=S0; 
					 else if(^rx===1'bx) begin state<=idle; end 
					 else begin state<=S1; end 
					 prev<=S9;
					if(data[7:0] != temp)
						data <= {data[79:0],temp}; 
			 end
		idle:begin if(rx===1'b0) begin state<=S1; end 
					  else if(rx===1'b1) begin state<=S0; end 
					  prev<=idle;
					 casex(data)
{{24{1'bx}},"IFM-EU-#"},{{8{1'bx}},"IFM-E",{24{1'bx}},"-#"}	: begin f_code <= 4'b0001; data <= 0; end
			"PBM-SU-B1-#"	: begin f_code <= 4'b0010; data <= 0; end
			"PBM-SU-B3-#"	: begin f_code <= 4'b0011; data <= 0; end
{{24{1'bx}},"IFM-RU-#"},{{8{1'bx}},"IFM-R",{24{1'bx}},"-#"}	: begin f_code <= 4'b0100; data <= 0; end
{{24{1'bx}},"IFM-CU-#"},{{8{1'bx}},"IFM-C",{24{1'bx}},"-#"}	: begin f_code <= 4'b0101; data <= 0; end
			"PBM-SU-B2-#"	: begin f_code <= 4'b0110; data <= 0; end
			"PBM-SU-B4-#"	: begin f_code <= 4'b0111; data <= 0; end
					88'd0		: begin f_code <= 4'b0000; end
					 default : begin 
									f_code <= 4'b0;
								  end 
					 endcase
			  end
		default: state<=S0;
	endcase
end

/*
Purpose:
To transmit an 8 bit word which is formed adter every 10 cycles( Start bit + word + Stop bit)
*/	
always @(posedge clk_115200)
begin
	if(count>=10)
	begin
		rx_msg<=temp;
		count<=1;
	end
	else
		count<=count+1;
end

/*
Purpose:
CDC implementation for communication with cpu controller in order to receive informtion regarding the fault or block detected by ultrasonic sesnor*/	
always @(negedge clk_115200)
begin
	case(cdc_state)
		S0: begin if(f_code != 4'b0) begin f_cdc_code <= f_code; req <= 1'b1; cdc_state <= S1; end end
		S1: begin if(ack) begin cdc_state <= S0; f_cdc_code <= 4'b0; req <= 1'b0;  end end
		default : begin cdc_state <= S0;	end
	endcase
end
endmodule