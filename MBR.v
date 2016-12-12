module MBR
(
	input clk,
	input i320,
	input rst,
	output reg oMBR,
	output reg skut40
);

reg tmp;
reg cnt;
reg [6:0]count; 

always@(posedge clk)
begin
if (~rst) begin
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
