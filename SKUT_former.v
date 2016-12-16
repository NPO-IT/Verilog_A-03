module SKUT_former
(
	input				reset,
	input				iClk,
	input				i8KHz,
	output	reg	[7:0]	oData,
	output	reg	[6:0]	oAddr,
	output	reg 		oWrEn,
	output	reg 		o19ch,
	output	reg	[7:0]	oLCCnumber,
	output	reg 		oLCCrq,
	input		[5:0]	iLCC1_FDAT,
	input				iLCC1_FVAL
);

parameter	[7:0]	SKUT_Middle = 8'd124;
parameter	[7:0]	SIN_LOW = 8'd28;
parameter	[7:0]	SIN_MLOW = 8'd92;
parameter	[7:0]	SIN_MHI = 8'd156;
parameter	[7:0]	SIN_HIGH = 8'd220;

reg		[1:0]	S8K;
reg		[2:0]	SKUTState;
reg		[3:0]	SKUTOutByte;
reg		[6:0]	SKUTCntChan;
reg		[2:0]	SKUTCntSin;
reg		[9:0]	SKUTCntLKF;
reg		[7:0]	SKUT_Sinus[0:7];

reg		[3:0]	cntRQ;
reg		[1:0]	S100H;
reg		[1:0]	DDCBState;
reg		[9:0]	DDCBCntRQ;
reg		[6:0]	DDCAddress;
reg		[5:0]	LKF1Address;

initial begin
	SKUT_Sinus[0] = SIN_LOW;
	SKUT_Sinus[1] = SIN_MLOW;
	SKUT_Sinus[2] = SIN_MHI;
	SKUT_Sinus[3] = SIN_HIGH;
	SKUT_Sinus[4] = SIN_HIGH;
	SKUT_Sinus[5] = SIN_MHI;
	SKUT_Sinus[6] = SIN_MLOW;
	SKUT_Sinus[7] = SIN_LOW;
end

always@(posedge iClk) begin
	S8K <= { S8K[0],  i8KHz };
//	S100H <= { S100H[0],  i100Hz };
end

reg		[1:0]	LCCstate;

always@(posedge iClk) begin
	if(~reset) begin
		oLCCnumber <= 8'b0;
		LCCstate <= 2'b0;
		oLCCrq <= 1'b0;
	end else begin
		case(LCCstate)
			0: begin
				if(S8K[1] == 1) begin
					LCCstate <= 2'd1;
					oLCCrq <= 1'b1;
				end
			end
			1: begin
				if(S8K[1] == 0) begin
					LCCstate <= 2'd2;
					oLCCrq <= 1'b0;
				end
			end
			2: begin
				oLCCnumber <= oLCCnumber + 1'b1;
				LCCstate <= 2'd0;
				if (oLCCnumber == 8'd159)
					oLCCnumber <= 8'd0;
			end
		endcase
	end
end

/*Îòäà÷à íà ÂÛÕÎÄ*/
always@(posedge iClk)begin
if (~reset) begin
	oData <= 8'b0;
	oAddr <= 7'b0;
	oWrEn <= 1'b0;
	o19ch <= 1'b0;
	SKUTState <= 3'b0;
	SKUTOutByte <= 4'b0;
	SKUTCntChan <= 7'b0;
	SKUTCntSin <= 3'b0;
	SKUTCntLKF <= 10'b0;
	cntRQ <= 4'b0;
	DDCAddress <= 7'd1;
	LKF1Address <= 1'b1;
end else begin
case (SKUTState)
	0: begin
		if (S8K[1] == 1) begin
			SKUTState <= 2;
			if (SKUTCntLKF == 640) SKUTCntLKF <= 0;		//lkf 12,5Hz
		end
	end
	1: begin
		if (DDCAddress == 80) DDCAddress <= 0;
		cntRQ <= 0;
		if (S8K[1] == 0) begin 
			SKUTState <= 0;
			SKUTOutByte <= 0;
			SKUTCntChan <= 0;
			SKUTCntLKF <= SKUTCntLKF + 1'b1;
			SKUTCntSin <= SKUTCntSin + 1'b1;
		end
	end
	2: begin
		SKUTOutByte <= SKUTOutByte + 1'b1;
		case (SKUTOutByte)
			0: SKUTState <= 3;
			1,2,3,4,5,6,7,8: oWrEn <= 1;
			9,10,11,12,13: oWrEn <= 0;
			14: begin 
				SKUTCntChan <= SKUTCntChan + 1'b1; 
			end
		endcase
		if (SKUTOutByte == 15) begin
			SKUTOutByte <= 0;
		end
		if (SKUTCntChan == 80) begin
			SKUTState <= 4;
		end
	end
	3: begin
		case (SKUTCntChan) 
			38,39,78,79: oData <= SKUT_Middle;
			29,69: oData <= SKUT_Sinus[SKUTCntSin]; 
			18: begin
				if (SKUTCntLKF == 0) begin
					o19ch <= 1'b1;
					oData <=  8'd220; 
					end else begin 
					oData <= 8'd0;
					o19ch <= 1'b0;
				end
			end
			default: oData <= 8'd0;
		endcase

		if (SKUTCntChan < 6'd40) oAddr <= SKUTCntChan << 1'b1;
		else oAddr <= (((SKUTCntChan - 6'd40) << 1'b1) + 1'b1);
		
		
		SKUTState <= 2;
	end
	
	4: begin
		/*case (cntRQ)
			1: 	begin
				oDDCAddr <= DDCAddress;
			end
			3: begin
				DDCAddress <= DDCAddress + 1'b1;
			end
			4: SKUTState <= 1;
		endcase
		cntRQ = cntRQ + 1'b1;*/
	end
	

endcase


end
end
endmodule
