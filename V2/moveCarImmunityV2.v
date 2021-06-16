`timescale 1ns / 1ps

module moveCarImmunity (clk, reset, nextRow, headRow, position, attemptMove, moveResult);
	input clk, reset;
	input [5:0] nextRow, headRow;
	input [5:0] position;
	input [1:0] attemptMove;
	
	output reg [1:0] moveResult; // 0 = alive, 1 = dead
	
	reg [1:0] moveInput;
	ref [2:0] state;
	
	reg immunity;
	reg [31:0] immuneCount;
	

	
	parameter immuneCycles = 3;	
	
	
	initial begin
		moveResult <= 0;
		moveInput <= 0;
		state <= 0;
		
		immunity <= 0;
		immuneCount <= 0;
   end
   
   
    always @ (posedge clk) begin
		case (state) 
			0: begin
				if (reset) state <= 1;
				else if (attemptMove && !moveInput) moveInput <= attemptMove;
//				else if (!attemptMove || moveInput) moveInput <= moveInput;
			1: begin
				state <= 2;
				if (immunity) begin
					if ((immuneCount + 1) == immuneCycles) begin	
						immunity <= 0;
						immuneCount <= 0;
					end
					else immuneCount <= immuneCount + 1;

					case (moveInput)
						2'b00: begin // no move
							moveResult <= moveInput;
						end
						2'b10: begin // move left
							if (position != 5) moveResult <= moveInput; 
							else moveResult <= 2'b00; 
						end
						2'b01: begin // move right
							if (position != 0) moveResult <= moveInput; 
							else moveResult <= 2'b00; 
						end		
					endcase
				end // if immunity
				else begin // if no immunity check if head or tail hit an obstacle
					case (moveInput)
						2'b00: begin // no move
							if (nextRow[position]) begin
								moveResult <= 2'b11; 
								immunity <= 1;
							end
							else moveResult <= moveInput;
						end
						2'b10: begin // move left
							if ((position != 5) && (nextRow[position + 1] || headRow[position + 1])) begin
								moveResult <= 2'b11;
								immunity <= 1;
							end
							else if (position != 5) moveResult <= moveInput;
							else if(position == 5 && nextRow[position]) begin
								moveResult <= 2'b11;
								immunity <= 1;
							end
							else moveResult <= 2'b00; 
						end
						2'b01: begin // move right
							if ((position != 0) && (nextRow[position - 1] || headRow[position - 1])) begin
								moveResult <= 2'b11;
								immunity <= 1;
							end
							else if (position != 0) moveResult <= moveInput; 
							else if(position == 0  && nextRow[position]) begin 
								moveResult <= 2'b11;
								immunity <= 1;
							end
							else moveResult <= 2'b00; 
						end		
					endcase
				end
			end // end state 1
			2: begin
				state <= 0;
				moveInput <= 0;

			end
		endcase
	end
endmodule