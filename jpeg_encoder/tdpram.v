`timescale 1ns / 1ps
//带有两个写端口的双端块RAM
module tdpram #(
	parameter AW = 10,
	parameter DW = 8 
)
(
    input 					clka	,
	input 					clkb	,
	input 					wea		,
	input 					web		,
    input 		[AW-1:0] 	addra	,
	input 		[AW-1:0]	addrb	,
    input 		[DW-1:0]	dina	,
	input 		[DW-1:0]	dinb	,
    output reg  [DW-1:0] 	douta	,
	output reg  [DW-1:0] 	doutb
);

reg [DW-1:0] ram [(2**AW)-1:0];

integer i;
initial for (i=0; i < (2**AW); i=i+1) ram[i] = 0;

//port 1
always@(posedge clka)      
    if (wea) 
		ram[addra] <= dina;
		
always@(posedge clka)
    douta <= ram[addra];
	
//port 2
always@(posedge clkb)
    if (web) 
		ram[addrb] <= dinb;
		
		
always@(posedge clkb)		
	doutb <= ram[addrb];	
		

endmodule


