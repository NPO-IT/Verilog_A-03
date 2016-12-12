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

wire reset;
wire clk640k, clk320k, clk8k;
wire skut_sync;

// Common reset and dividers
globalReset aClr ( .clk(clk80), .rst(reset) );
defparam 	aClr.clockFreq 	=	32'd10;			//32'd80640000;
defparam 	aClr.delayInSec	=	1;

clkDividers clkDivs ( .reset(reset), .clk80(clk80), .clk640k(clk640k), .clk320k(clk320k), .clk8k(clk8k) );

VI skut_vi ( .clk(clk80), .i320(clk320k), .rst(reset), .oVI(SKUT_VI) );
MBR skut_mbr ( .clk(clk80), .i320(clk320k), .rst(reset), .oMBR(SKUT_MBR), .skut40(skut_sync) );



endmodule
