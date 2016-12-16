module fastExtract(
	input				clk80, 
	input				reset,
	input		[7:0]	iData,
	input				iVal,
	output	reg	[5:0]	oData,
	output	reg			oVal
);

reg		[2:0]	state;
reg		[3:0]	numByte;
reg		[5:0]	additionalData;
reg		[3:0]	cntDelay;

always@(posedge clk80 or negedge reset) begin
	if(~reset) begin
		oData <= 6'b0;
		oVal <= 1'b0;
		state <= 3'b0;
		numByte <= 4'b0;
		additionalData <= 6'd0;
		cntDelay <= 4'd0;
	end else begin
		case (state)
			0: begin
				if(iVal == 1) begin
					state <= 3'b1;
					numByte <= numByte + 1'b1;
				end
			end
			1: begin
				case (numByte)
					1, 4, 7, 10: begin
						additionalData[1:0] <= iData[7:6];
						oData <= iData[5:0];
						state <= 3'd2;
					end
					2, 5, 8, 11: begin
						additionalData[3:2] <= iData[7:6];
						oData <= iData[5:0];
						state <= 3'd2;
					end
					3, 6, 9, 12: begin
						additionalData[5:4] <= iData[7:6];
						oData <= iData[5:0];
						state <= 3'd3;
					end
					13, 14: state <= 3'd4;
				endcase
			end
			2: begin
				cntDelay <= cntDelay + 1'b1;
				case (cntDelay)
					0: oVal <= 1'b1;
					3: begin
						oVal <= 1'b0;
						cntDelay <= 4'd0;
						state <= 3'd4;
					end
				endcase
			end
			3: begin
				cntDelay <= cntDelay + 1'b1;
				case (cntDelay)
					0: oVal <= 1'b1;
					4: oVal <= 1'b0;
					5: oData <= additionalData;
					6: oVal <= 1'b1;
					10: begin
						oVal <= 1'b0;
						cntDelay <= 4'd0;
						additionalData <= 6'd0;
						state <= 3'd4;
					end
				endcase
			end
			4: begin
				if (numByte == 4'd14) numByte <= 4'd0;
				if (~iVal)
					state <= 3'd0;
			end
		endcase
	end
end
endmodule
