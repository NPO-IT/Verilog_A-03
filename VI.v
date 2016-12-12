module VI
(
	input clk,
	input i320,
	input rst,
	output reg oVI
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
			if (i320 == 0) count <= count + 1'b1;
			if (count == 39) 
				oVI <= 0;
			else if (count ==40) 
			begin
				count <= 0;
				oVI <= i320;
			end else 
				oVI <= i320;
			
			cnt <= 0;
		end	
	end
end
endmodule
