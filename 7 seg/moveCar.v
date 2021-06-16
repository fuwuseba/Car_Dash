`timescale 1ns / 1ps

module moveCar(clk, nextRow, headRow, position, attemptMove, positionResult);
	input clk;
	input [5:0] nextRow, headRow;
	input [2:0] position;
	input [1:0] attemptMove;
	
	output reg [2:0] positionResult ; // 0 = alive, 1 = dead
	
	
	always @ (posedge clk) begin
		case (attemptMove)
			2'b00: begin // move up
				if (nextRow[position]) positionResult <= 3'b111; // die if position in next row same column blocked
				else positionResult <= position; // return same position as next position
			end
			2'b10: begin // move left
				if ((position != 5) && (nextRow[position + 1] || headRow[position + 1])) positionResult <= 3'b111; // if not on edge of board die if position in (next row OR head row) in column to left blocked (i.e. head or tail collide)
				else if (position != 5) positionResult <= (position + 1); // if not on edge of board return position to left
				else if(position == 5 && nextRow[position]) positionResult <= 3'b111;// if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
				else positionResult <= position; // if on edge of board and not blocked, return same position as next position
			end
			2'b01: begin // move right
				if ((position != 0) && (nextRow[position - 1] || headRow[position - 1])) positionResult <= 3'b111; // if not on edge of board die if position in (next row OR head row) in column to right blocked (i.e. head or tail collide)
				else if (position != 0) positionResult <= (position - 1); // if not on edge of board return position to right
				else if(position == 0  && nextRow[position]) positionResult <= 3'b111; // if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
				else positionResult <= position; // if on edge of board and not blocked, return same position as next position
			end		
		endcase
		
	end
	
endmodule
