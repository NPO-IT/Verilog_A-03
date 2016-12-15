`timescale 10 ps/10 ps

module Astra_tb();

//outer connections
reg clk80, clk100;
wire DAC1_CLK, DAC1_DB0, DAC1_DB1, DAC1_DB2, DAC1_DB3, DAC1_DB4, DAC1_DB5, DAC1_DB6, DAC1_DB7;
wire DAC2_CLK, DAC2_DB0, DAC2_DB1, DAC2_DB2, DAC2_DB3, DAC2_DB4, DAC2_DB5, DAC2_DB6, DAC2_DB7; 
wire DAC_MODE;
wire SKUT_MBR, SKUT_VI;

reg UART0_RX;
wire UART0_TX, UART0_dTX, UART0_dRX;

//inner variables
reg clk5;
reg [2:0]cntBit = 0;
reg [3:0]cntByte = 0;
reg [7:0]answer[0:14];
reg [7:0]fastCntr[0:63];
reg [5:0]cntFast = 0;

initial begin
	fastCntr[0] = 0;
	fastCntr[1] = 1;
	fastCntr[2] = 2;
	fastCntr[3] = 3;
	fastCntr[4] = 4;
	fastCntr[5] = 5;
	fastCntr[6] = 6;
	fastCntr[7] = 7;
	fastCntr[8] = 8;
	fastCntr[9] = 9;
	fastCntr[10] = 10;
	fastCntr[11] = 11;
	fastCntr[12] = 12;
	fastCntr[13] = 13;
	fastCntr[14] = 14;
	fastCntr[15] = 15;
	fastCntr[16] = 16;
	fastCntr[17] = 17;
	fastCntr[18] = 18;
	fastCntr[19] = 19;
	fastCntr[20] = 20;
	fastCntr[21] = 21;
	fastCntr[22] = 22;
	fastCntr[23] = 23;
	fastCntr[24] = 24;
	fastCntr[25] = 25;
	fastCntr[26] = 26;
	fastCntr[27] = 27;
	fastCntr[28] = 28;
	fastCntr[29] = 29;
	fastCntr[30] = 30;
	fastCntr[31] = 31;
	fastCntr[32] = 32;
	fastCntr[33] = 33;
	fastCntr[34] = 34;
	fastCntr[35] = 35;
	fastCntr[36] = 36;
	fastCntr[37] = 37;
	fastCntr[38] = 38;
	fastCntr[39] = 39;
	fastCntr[40] = 40;
	fastCntr[41] = 41;
	fastCntr[42] = 42;
	fastCntr[43] = 43;
	fastCntr[44] = 44;
	fastCntr[45] = 45;
	fastCntr[46] = 46;
	fastCntr[47] = 47;
	fastCntr[48] = 48;
	fastCntr[49] = 49;
	fastCntr[50] = 50;
	fastCntr[51] = 51;
	fastCntr[52] = 52;
	fastCntr[53] = 53;
	fastCntr[54] = 54;
	fastCntr[55] = 55;
	fastCntr[56] = 56;
	fastCntr[57] = 57;
	fastCntr[58] = 58;
	fastCntr[59] = 59;
	fastCntr[60] = 60;
	fastCntr[61] = 61;
	fastCntr[62] = 62;
	fastCntr[63] = 63;
end

initial begin
	answer[0]=0;
	answer[1]=5;
	answer[2]=10;
	answer[3]=15;
	answer[4]=20;
	answer[5]=25;
	answer[6]=30;
	answer[7]=35;
	answer[8]=40;
	answer[9]=45;
	answer[10]=50;
	answer[11]=55;
	answer[12]=60;
	answer[13]=201;
	answer[14]=956;
end

Astra Astra_tb(
	.clk80(clk80), 
	.clk100(clk100),			//80.64; 100.66
	
	.DAC_MODE(DAC_MODE),
	.DAC1_CLK(DAC1_CLK), 
	.DAC1_DB0(DAC1_DB0), 
	.DAC1_DB1(DAC1_DB1), 
	.DAC1_DB2(DAC1_DB2),
	.DAC1_DB3(DAC1_DB3),
	.DAC1_DB4(DAC1_DB4),
	.DAC1_DB5(DAC1_DB5),
	.DAC1_DB6(DAC1_DB6),
	.DAC1_DB7(DAC1_DB7),
	.DAC2_CLK(DAC2_CLK),
	.DAC2_DB0(DAC2_DB0),
	.DAC2_DB1(DAC2_DB1),
	.DAC2_DB2(DAC2_DB2),
	.DAC2_DB3(DAC2_DB3),
	.DAC2_DB4(DAC2_DB4),
	.DAC2_DB5(DAC2_DB5),
	.DAC2_DB6(DAC2_DB6),
	.DAC2_DB7(DAC2_DB7),
	
	.SKUT_MBR(SKUT_MBR),
	.SKUT_VI(SKUT_VI),

	.UART0_RX(UART0_RX),
	.UART0_TX(UART0_TX),
	.UART0_dTX(UART0_dTX),
	.UART0_dRX(UART0_dRX)
);

initial begin						// clk ~80.64MHz
	clk80 = 0;
	forever #620 clk80 = ~clk80;
end
initial begin						// clk 4.8MHz
	clk5=0;
	forever #10417 clk5 = ~clk5;
end
initial begin						// clk ~100.6MHz
	clk100=0;
	forever #497 clk100 = ~clk100;		
end

initial begin
	UART0_RX = 1;
	repeat(320) begin
		wait(UART0_dRX == 1);
		cntByte = 0;
		cntBit = 0;
		wait(UART0_dRX == 0);
		repeat (14) begin				
			@(posedge clk5)
			UART0_RX = 0;
			if (cntByte == 0) begin
				repeat (8)					// 8 bit
				begin
					@(posedge clk5)
					UART0_RX = fastCntr[cntFast][cntBit];
					cntBit = cntBit + 1;
				end
				cntFast = cntFast + 1;
			end else begin
				repeat (8)					// 8 bit
				begin
					@(posedge clk5)
					UART0_RX = answer[cntByte][cntBit];
					cntBit = cntBit + 1;
				end
			end
			@(posedge clk5);
			UART0_RX = 1;
			cntByte = cntByte + 1;
			
		end
	end
	$stop;
end

endmodule
