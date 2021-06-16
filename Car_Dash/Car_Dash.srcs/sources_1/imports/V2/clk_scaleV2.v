`timescale 1ns / 1ps

module clk_scale(clk, scale, clk_scaled);
	input clk;
    input [26:0] scale;
	output reg clk_scaled;
	
	reg [31:0] cnt;
	
	initial begin
		cnt <= 0;
		clk_scaled <= 0;
	end
	
	always @ (posedge clk) begin
        if (cnt == (scale/2)) begin
			cnt <= 0;
			clk_scaled = !clk_scaled;
		end
		else cnt <= cnt + 1;
	end
endmodule