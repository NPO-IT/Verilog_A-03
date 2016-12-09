module SKUT_former
(
	input reset,
	input iClk,
	input i8KHz,
	input i100Hz,
	input [15:0] iDDCS1,
	input [15:0] iDDCS2,
	input [3:0] iLKF1,
	output reg [7:0] oData,
	output reg [6:0] oAddr,
	output reg oWrEn,
	output reg o19ch,
	output reg oDDCBReq,
	output reg [6:0] oDDCAddr,
	output reg oTest	
);

`define WAIT 0
`define MEGAWAIT 1
`define RX 2
`define SET 3
`define BDDCRQ 4

parameter [7:0]SKUT_Middle = 8'd124;
parameter [7:0]SIN_LOW = 8'd28;
parameter [7:0]SIN_MLOW = 8'd92;
parameter [7:0]SIN_MHI = 8'd156;
parameter [7:0]SIN_HIGH = 8'd220;

reg [1:0]S8K;
reg [2:0]SKUTState;
reg [3:0]SKUTOutByte;
reg [6:0]SKUTCntChan;
reg [2:0]SKUTCntSin;
reg [9:0]SKUTCntLKF;
reg [7:0]SKUT_Sinus[0:7];


reg [3:0]cntRQ;
reg [1:0]S100H;
reg [1:0]DDCBState;
reg [9:0]DDCBCntRQ;
reg [6:0]DDCAddress;
reg [5:0]LKF1Address;

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
	S100H <= { S100H[0],  i100Hz };
end

/*Çàïðîñ íà ÁÓÑ*/
always@(posedge iClk) begin
if (~reset) begin
	DDCBState <= 2'b0;
	DDCBCntRQ <= 9'b0;
end else begin
case (DDCBState)
	`WAIT: begin
		if (S100H[1]) DDCBState <= `RX;
	end
	`MEGAWAIT: begin
		DDCBCntRQ <= 0;
		if (~S100H[1]) DDCBState <= `WAIT;
	end
	`RX: begin
		DDCBCntRQ <= DDCBCntRQ + 1'b1;	
		//DDCBState <= `MEGAWAIT;
		//if (DDCBCntRQ == 80) begin DDCBCntRQ <= 0; oDDCBReq <= 1; end else oDDCBReq <= 0;
		
		case (DDCBCntRQ)
			509: oDDCBReq <= 0;
			510: DDCBState <= `MEGAWAIT;
			default: oDDCBReq <= 1;
		endcase
	end
endcase
end
end

/*Îòäà÷à íà ÂÛÕÎÄ*/
always@(posedge iClk)begin
if (~reset) begin
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
	`WAIT: begin
		if (S8K[1] == 1) begin
			SKUTState <= `RX;
			if (SKUTCntLKF == 640) SKUTCntLKF <= 0;		//lkf 12,5Hz
		end
	end
	`MEGAWAIT: begin
		if (DDCAddress == 80) DDCAddress <= 0;
		cntRQ <= 0;
		if (S8K[1] == 0) begin 
			SKUTState <= `WAIT;
			SKUTOutByte <= 0;
			SKUTCntChan <= 0;
			SKUTCntLKF <= SKUTCntLKF + 1'b1;
			SKUTCntSin <= SKUTCntSin + 1'b1;
		end
	end
	`RX: begin
		SKUTOutByte <= SKUTOutByte + 1'b1;
		case (SKUTOutByte)
			0: SKUTState <= `SET;
			1,2,3,4,5,6,7,8: oWrEn <= 1;
			9,10,11,12,13: oWrEn <= 0;
			14: begin 
				SKUTCntChan <= SKUTCntChan + 1'b1; 
				oTest <= 0; 
			end
		endcase
		if (SKUTOutByte == 15) begin
			SKUTOutByte <= 0;
		end
		if (SKUTCntChan == 80) begin
			SKUTState <= `BDDCRQ;
		end;
	end
	`SET: begin
	oTest <= 1;
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
/* ÁÓÑ öèôðà */			
			13: oData <= {iDDCS1[13:12], 6'b011100};
			33:	oData <= {iDDCS1[15:14], 6'b011100};
			3:	oData <= {iDDCS1[9:8], 6'b011100};
			23:	oData <= {iDDCS1[11:10], 6'b011100};
			11:	oData <= {iDDCS1[5:4], 6'b011100};
			31:	oData <= {iDDCS1[7:6], 6'b011100};
			8:	oData <= {iDDCS1[1:0], 6'b011100};
			28: oData <= {iDDCS1[3:2], 6'b011100};
			12: oData <= {iDDCS2[13:12], 6'b011100};
			32: oData <= {iDDCS2[15:14], 6'b011100};
			2:	oData <= {iDDCS2[9:8], 6'b011100};
			22: oData <= {iDDCS2[11:10], 6'b011100};
			1:	oData <= {iDDCS2[5:4], 6'b011100};
			21: oData <= {iDDCS2[7:6], 6'b011100};
			14: oData <= {iDDCS2[1:0], 6'b011100};
			34: oData <= {iDDCS2[3:2], 6'b011100};
/*ÁÓÑ àíàëîãîâûé*/
			4:	oData <= {iLKF1[3:2], 6'b011100};
			24: oData <= {iLKF1[1:0], 6'b011100};
			
			default: oData <= 8'd0;
		endcase

		if (SKUTCntChan < 6'd40) oAddr <= SKUTCntChan << 1'b1;
		else oAddr <= (((SKUTCntChan - 6'd40) << 1'b1) + 1'b1);
		
		
		SKUTState <= `RX;
	end
	
	`BDDCRQ: begin
		case (cntRQ)
			1: 	begin
				oDDCAddr <= DDCAddress;
			end
			3: begin
				DDCAddress <= DDCAddress + 1'b1;
			end
			4: SKUTState <= `MEGAWAIT;
		endcase
		cntRQ = cntRQ + 1'b1;
	end
	

endcase


end
end
endmodule
