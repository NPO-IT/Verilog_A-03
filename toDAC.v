module toDAC
(
	input reset,
	input clk,
	input i640,
	input skut40,
	output reg [6:0]ADR,	
//	output reg RDN,
	output reg SEL,
	output reg test
);
`define WAITNEG 0
`define ACT 1
`define WAITPOS 2
`define COUNT 3

reg [2:0]state;
reg aim;

always@(posedge clk) begin
if (~reset) begin
	state <= 0;
	ADR <= 0;
end else
case (state)
	`WAITNEG: begin
		if (~i640) state <= `ACT;
		test <= 0;
	end
	`ACT: begin
		ADR <= ADR + 1'b1;
		if (skut40 == 1'b1) begin test <= 1'b1; ADR <= 80; end		
		state <= `WAITPOS;
	end
	`WAITPOS: begin
		if (i640) begin 
			state <= `COUNT;
		end
	end
	`COUNT: begin
		if (ADR == 80) begin ADR <= 0; SEL <= ~SEL; end
		test <= 0;
		state <= `WAITNEG;
	end
endcase
end
endmodule
