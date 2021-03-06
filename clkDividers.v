module clkDividers(
	input	reset,			// aclr
	input	clk80,			// 80.640.000	---
	input	clk100, 		// ~100.660.000	---
	output	reg	clk4_8m,	// ~4.790.000	50%
	output	reg	clk640k,	// 640.000		50%
	output	reg	clk320k,	// 320.000		50%
	output	reg	clk320s,	// 320.000		50%
	output	reg	clk8k		// 8.000		50%
);

reg	[4:0]	cnt4_8;			// 21
reg	[6:0]	cnt640;			// 126
reg	[7:0]	cnt320;			// 252
reg	[8:0]	cnt320s;		// 252
reg	[14:0]	cnt8;			// 10080

always@(posedge clk100 or negedge reset) begin
	if (~reset) begin
		cnt4_8 <= 5'b0;
		clk4_8m <= 1'b0;
	end else begin
		cnt4_8 <= cnt4_8 + 1'b1;
		if (cnt4_8 > 9) begin
			clk4_8m <= 1'b1;
		end
		if (cnt4_8 == 20) begin
			cnt4_8 <= 5'b0;
			clk4_8m <= 1'b0;
		end
	end
end

always@(posedge clk80 or negedge reset) begin
	if(~reset)begin
		clk640k	<=	1'b0;
		clk320k	<=	1'b0;
		clk320s	<=	1'b0;
		clk8k	<=	1'b0;
		cnt640	<=	7'b0;
		cnt320	<=	8'b0;
		cnt320s	<=	9'b0;
		cnt8	<=	14'b0; 
	end else begin
		// 640KHz clock
		cnt640 <= cnt640 + 1'b1;
		if (cnt640 > 63) begin
			clk640k <= 1'b1; 
		end 
		if (cnt640 == 125) begin
			cnt640 <= 7'b0; 
			clk640k <= 1'b0;
		end
		
		// 320KHz shifted clock
		cnt320s <= cnt320s + 1'b1;
		if (cnt320s > 63) begin
			clk320s <= 1'b1; 
		end 
		if (cnt320s > 189) begin
			clk320s <= 1'b0; 
		end 
		if (cnt320s == 251) begin
			cnt320s <= 8'b0; 
		end

		// 320KHz clock
		cnt320 <= cnt320 + 1'b1;
		if (cnt320 > 124) begin
			clk320k <= 1'b1; 
		end 
		if (cnt320 == 251) begin
			cnt320 <= 8'b0; 
			clk320k <= 1'b0;
		end
		
		// 8KHz clock
		cnt8 <= cnt8 + 1'b1;
		if (cnt8 > 5040) begin
			clk8k <= 1'b1; 
		end 
		if (cnt8 == 10079) begin
			cnt8 <= 14'b0; 
			clk8k <= 1'b0;
		end
		
	end
end
endmodule
