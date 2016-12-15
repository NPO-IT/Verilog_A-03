module Astra (
	input	clk80, clk100,						//80.64; 100.66
	
						//DAC outs
	output	DAC_MODE,
	output	DAC1_CLK, DAC1_DB0, DAC1_DB1, DAC1_DB2, DAC1_DB3, DAC1_DB4, DAC1_DB5, DAC1_DB6, DAC1_DB7,
	output	DAC2_CLK, DAC2_DB0, DAC2_DB1, DAC2_DB2, DAC2_DB3, DAC2_DB4, DAC2_DB5, DAC2_DB6, DAC2_DB7, 

						// Frame bases
	output	SKUT_MBR, SKUT_VI,

						// UART inouts
	input	UART0_RX,
	output	UART0_TX,
	output	UART0_dTX,
	output	UART0_dRX
);
//Common
wire			reset;
wire			clk4_8m, clk640k, clk320k, clk320s, clk8k;
wire			skut_sync;

//SKUT former and buffer
wire	[7:0]	BUF_IDATA;
wire	[6:0]	BUF_IADDR;
wire			BUF_IWREN;
reg				BUF0_WREN, BUF1_WREN;
wire	[6:0]	BUF_OADDR;
wire			BUF_OSWCH;
reg				BUF0_RDEN, BUF1_RDEN;
wire	[7:0]	BUF0_DATA, BUF1_DATA;
reg		[7:0]	DAC_OUT;

// DAC outputs
assign DAC_MODE = 0;
assign DAC1_CLK = clk320k;
assign DAC2_CLK = ~clk320k;
assign DAC1_DB0 = DAC_OUT[0];
assign DAC2_DB0 = DAC_OUT[0];
assign DAC1_DB1 = DAC_OUT[1];
assign DAC2_DB1 = DAC_OUT[1];
assign DAC1_DB2 = DAC_OUT[2];
assign DAC2_DB2 = DAC_OUT[2];
assign DAC1_DB3 = DAC_OUT[3];
assign DAC2_DB3 = DAC_OUT[3];
assign DAC1_DB4 = DAC_OUT[4];
assign DAC2_DB4 = DAC_OUT[4];
assign DAC1_DB5 = DAC_OUT[5];
assign DAC2_DB5 = DAC_OUT[5];
assign DAC1_DB6 = DAC_OUT[6];
assign DAC2_DB6 = DAC_OUT[6];
assign DAC1_DB7 = DAC_OUT[7];
assign DAC2_DB7 = DAC_OUT[7];

// Common reset and dividers
globalReset aClr ( .clk(clk80), .rst(reset) );
defparam 	aClr.clockFreq 	=	32'd10;			//32'd80640000;
defparam 	aClr.delayInSec	=	1;
clkDividers clkDivs ( .reset(reset), .clk80(clk80), .clk100(clk100), .clk4_8m(clk4_8m), .clk640k(clk640k), .clk320k(clk320k), .clk320s(clk320s), .clk8k(clk8k) );
VI skut_vi ( .clk(clk80), .i320(clk320s), .rst(reset), .oVI(SKUT_VI) );
MBR skut_mbr ( .clk(clk80), .i320(clk320s), .rst(reset), .oMBR(SKUT_MBR), .skut40(skut_sync) );

always@(*)begin
	case(BUF_OSWCH)
		0: begin
			DAC_OUT = BUF1_DATA;
			BUF1_RDEN = ~BUF_OSWCH;
			BUF0_RDEN = 0;
			BUF0_WREN = BUF_IWREN;
			BUF1_WREN = 0;
		end
		1: begin
			DAC_OUT = BUF0_DATA;
			BUF0_RDEN = BUF_OSWCH;
			BUF1_RDEN = 0;
			BUF1_WREN = BUF_IWREN;
			BUF0_WREN = 0;
		end
	endcase
end

//LCC requests
wire	[9:0]	LCC_RQADR;
wire	[7:0]	LCC_RQDAT;
wire	[7:0]	LCC_RXDAT;
wire			LCC_RXVAL;
wire	[7:0]	LCC_RQNUM;
wire			LCC_RQSNL;

SKUT_former skut_frame( .reset(reset), .iClk(clk80), .i8KHz(clk8k),
	//to memory
	.oData(BUF_IDATA), .oAddr(BUF_IADDR), .oWrEn(BUF_IWREN),
	// for LCC
	.oLCCnumber(LCC_RQNUM),
	.oLCCrq(LCC_RQSNL),
	//for DDC
	//.oDDCBReq, .oDDCAddr, //[6:0] //.i100Hz, 
	.iDDCS1(0), //[15:0] 
	.iDDCS2(0), //[15:0] 
	.iLKF1(0) //[3:0]
	//LCF
	//.o19ch,
);

toDAC dac_distributor( .reset(reset), .clk(clk80), .i640(clk640k), .skut40(skut_sync), .ADR(BUF_OADDR), .SEL(BUF_OSWCH) );
SKUT_buffer skut_buf0 ( .clock(clk80), .data(BUF_IDATA), .rdaddress(BUF_OADDR), .rden(BUF0_RDEN), .wraddress(BUF_IADDR), .wren(BUF0_WREN), .q(BUF0_DATA));
SKUT_buffer skut_buf1 ( .clock(clk80), .data(BUF_IDATA), .rdaddress(BUF_OADDR), .rden(BUF1_RDEN), .wraddress(BUF_IADDR), .wren(BUF1_WREN), .q(BUF1_DATA));

LCCrq lcc_rq_rom ( .address(LCC_RQADR), .inclock(clk80), .outclock(clk80), .q(LCC_RQDAT) );
UARTTXBIG lcc_rq_uart ( .reset(reset), .clk(clk4_8m), .RQ(LCC_RQSNL), .cycle(LCC_RQNUM), .data(LCC_RQDAT), .addr(LCC_RQADR), .tx(UART0_TX), .dirTX(UART0_dTX), .dirRX(UART0_dRX) );
defparam lcc_rq_uart.BYTES = 3'd4;
UARTRX lcc_rx ( .clk(clk80), .reset(reset), .RX(UART0_RX), .oData(LCC_RXDAT), .oValid(LCC_RXVAL) );
defparam lcc_rx.DIVIDER = 17;

endmodule
