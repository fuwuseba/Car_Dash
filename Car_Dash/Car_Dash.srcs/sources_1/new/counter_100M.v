`timescale 1ns / 1ps

/*
A counter that counts up to 100,000,000 - 1, at chich point it resets itself to 0
*/
module counter_100M(clk, scale, cnt);
	input clk; //the 100MHz clk from the board
	input [26:0] scale;
	output reg [31:0] cnt; //max value will be 100M, 32 bits for the size is more than enough
	
	initial begin
		cnt <= 0;
	end
	
	always @(posedge clk) begin
        if( cnt == scale - 1 )	cnt <= 0;
		//if( cnt == 1000-1)	cnt <= 0;
		else cnt <= cnt + 1;
	end
	
endmodule