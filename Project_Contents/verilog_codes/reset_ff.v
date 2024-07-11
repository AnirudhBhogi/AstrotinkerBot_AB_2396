
// reset_ff.v - 8-bit resettable D flip-flop

module reset_ff #(parameter WIDTH = 32) (
    input       clk, rst,
    input       [WIDTH-1:0] d,
    output reg  [WIDTH-1:0] q
);
reg flag = 1'b0;
initial begin
	flag = 1'b0;
end
always @(posedge clk or posedge rst) begin
    if ((^rst===1'bz) || (^rst===1'b1) || (^rst===1'bx)) begin q <= 0; flag <= 1'b1; end
	 else if(!flag) begin q <= 0; end
    else begin    q <= d; flag <= 1'b1; end
end

endmodule
