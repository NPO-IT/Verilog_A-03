module MBR
(
	input clk,
	input i320,
	input rst,
	output reg oMBR,
	output reg skut40
);
`define SWITCH 0
`define CALC 1

reg state;
reg tmp;
reg cnt;
reg [6:0]count; 

always@(posedge clk)
begin
if (~rst) begin
	state <= 0;
	tmp <= 0;
	count <= 0;
end else begin
	if (tmp != i320) cnt <= 1;
	tmp <= i320;
	if (cnt == 1) begin
		skut40 <= 0;
		if (i320 == 1) count <= count + 1'b1;
		if (count == 39) oMBR <= 0;
		else if (count ==40) begin
			skut40 <= 1;
			count <= 0;
			oMBR <= 1;
		end else oMBR <= 1;	
		cnt <= 0;
	end	
end
end
endmodule
