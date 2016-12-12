module toDAC
(
	input reset,
	input clk,
	input i640,
	input skut40,
	output reg [6:0]ADR,
	output reg SEL,
	output reg test
);

reg [2:0]state;

always@(posedge clk) begin
if (~reset) begin
	state <= 0;
	ADR <= 0;
	SEL <= 0;
end else
case (state)
	0: begin
		if (~i640) state <= 1;
		test <= 0;
	end
	1: begin
		ADR <= ADR + 1'b1;
		if (skut40 == 1'b1) begin ADR <= 0; end		
		state <= 2;
	end
	2: begin
		if (i640) begin 
			state <= 3;
		end
	end
	3: begin
		if (ADR == 0) begin SEL <= ~SEL; end
		test <= 0;
		state <= 0;
	end
endcase
end
endmodule
