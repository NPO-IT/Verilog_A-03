module clkDividers(
	input	reset,			// aclr
	input	clk80,			// 80.640.000	---
	output	reg	clk640k,	// 640.000		50%
	output	reg	clk320k,	// 320.000		50%
	output	reg	clk8k		// 8.000		50%
);

reg	[6:0]	cnt640;			// 126
reg	[7:0]	cnt320;			// 252
reg	[13:0]	cnt8;			// 10080

always@(posedge clk or negedge reset) begin
	if(~reset)begin
		clk640k	<=	1'b0;
		clk320k	<=	1'b0;
		clk8k	<=	1'b0;
		cnt640	<=	7'b0;
		cnt320	<= 8'b0; 
		cnt8	<= 14'b0; 
	end else begin
		// 640KHz clock
		cnt640 <= cnt640 + 1'b1;
		if (cnt640 > 63) begin
			clk640k <= 1'b1; 
		end else 
		if (cnt640 == 125) begin
			cnt640 <= 7'b0; 
			clk640k <= 1'b0;
		end
		
		// 320KHz clock
		cnt320 <= cnt320 + 1'b1;
		if (cnt320 > 125) begin
			clk320k <= 1'b1; 
		end else 
		if (cnt320 == 251) begin
			cnt320 <= 8'b0; 
			clk320k <= 1'b0;
		end
		
		// 8KHz clock
		cnt8 <= cnt8 + 1'b1;
		if (cnt8 > 5040) begin
			clk8k <= 1'b1; 
		end else 
		if (cnt8 == 10079) begin
			cnt8 <= 14'b0; 
			clk8k <= 1'b0;
		end
	end
end
endmodule
