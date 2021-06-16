`timescale 1ns / 1ps

module clk_scale(clk, clk_scaled);
	input clk;
	output reg clk_scaled;
	reg [31:0] cnt;
	
	initial begin
		cnt <= 0;
		clk_scaled <= 0;
	end
	
	always @ (posedge clk) begin
        if (cnt == (100000000/2)-1) begin
			cnt <= 0;
			clk_scaled = !clk_scaled;
		end
		else cnt <= cnt + 1;
	end
endmodule