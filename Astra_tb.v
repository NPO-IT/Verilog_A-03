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
initial begin						// clk 5MHz
	clk5=0;
	forever #10000 clk5 = ~clk5;
end
initial begin						// clk ~100.6MHz
	clk100=0;
	forever #497 clk100 = ~clk100;		
end



initial begin
	repeat(32768)@(posedge clk5);
	$stop;
end

endmodule
