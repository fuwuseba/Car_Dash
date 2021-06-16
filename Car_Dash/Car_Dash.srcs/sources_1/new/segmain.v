`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 06:45:52 PM
// Design Name: 
// Module Name: main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module segmain(anode, segment, clk_100MHz, wins1, wins2);
    
	output [7:0] anode;
	output [6:0] segment;
	input clk_100MHz;
    reg clk_for_7seg;
	reg [3:0] pos;
	reg [3:0] digit;
	reg [31:0] cnt;
	reg [31:0] cnt1;
	reg [31:0] num;
	input [5:0] wins1;
	input [5:0] wins2;
	//reg [16:0] new_num;
	//reg [1:0] check_num;
	
	
	integer state;
	
	wire [5:0] wins1;
	wire [5:0] wins2;
	
	wire [7:0] anode;
    wire [6:0] segment;

	
	seven_seg seven_seg( 
		.scaled_clk(clk_for_7seg), 
		.digit(digit), 
		.pos(pos),
		.anode(anode), 
		.segment(segment)
	);
	
	initial begin
	   digit = 0;
	   pos = 1;
	   cnt = 0;
	   cnt1 = 0;
	   clk_for_7seg = 0;
	   //new_num = 0;
	   num = 0;
	   //check_num = 0;
	   state = 0;
	end
	
	always @(posedge clk_100MHz) begin
	   if( cnt == 100000)	begin
			cnt <= 0;
			clk_for_7seg <= !clk_for_7seg;
		end
		else begin
		  cnt <= cnt + 1;
	    end
	   
	end

	always @ (posedge clk_for_7seg) begin
	       case(state)
	       0: begin
	           pos = 1;
	          if (pos == 1)begin
	              num = wins2;
	          end
	           digit = num%10;
	           num = num/10;
	           state = state + 1;
	        end
	        1: begin
	           pos = 2;
	           digit = num%10;
	           num = num/10;
	           state = state + 1;
	        end
	        2: begin
	           pos = 5;
	           if(num == 0) begin
	               num = wins1;
	           end
	           digit = num%10;
	           num = num/10;
	           state = state + 1; 
	        end
	        3: begin
	           pos = 6;
	           digit = num%10;
	           num = num/10;
	           state = 0;
	        end
	           
	      endcase
	 end
	
endmodule
