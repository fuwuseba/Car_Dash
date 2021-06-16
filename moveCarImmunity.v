`timescale 1ns / 1ps

module moveCarImmunity (clk, nextRow, headRow, position, attemptMove, positionResult);
	input clk;
	input [5:0] nextRow, headRow;
	input [2:0] position;
	input [1:0] attemptMove;
	
	output reg [2:0] positionResult ; // 0 = alive, 1 = dead
	
	reg [31:0] clkCnt;
	
	reg immunity;
	reg [31:0] immuneCount;
	reg [2:0] moveAttempted;
	
	parameter immuneCycles = 3;	
	
	
	initial begin
	   clkCnt <= 0;
	   positionResult <= 0;
	   immunity <= 0;
	   immuneCount <= 0;
	   moveAttempted <= 0;
   end
   
   always @ (posedge clk) begin
        if (clkCnt != (100000000/2)) begin
            if (attemptMove && !moveAttempted) moveAttempted <= attemptMove;
            clkCnt <= clkCnt + 1;
        end
        else if (clkCnt == (100000000/2)) begin
            if (immunity && (immuneCount < immuneCycles)) begin // does not die, case only corrects movement
               if ((immuneCount + 1) == immuneCycles) begin
                   immunity <= 0;
                   immuneCount<= 0;
               end
               else immuneCount <= immuneCount + 1;
               
               case (moveAttempted)
                    2'b00: begin // move up
                        positionResult <= position; // return same position as next position
                    end
                    2'b10: begin // move left
                        if (position != 5) positionResult <= (position + 1); // if not on edge of board return position to left
                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
                    end
                    2'b01: begin // move right
                        if (position != 0) positionResult <= (position - 1); // if not on edge of board return position to right
                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
                    end		
                endcase
            end
           
            else begin // else check for death as well as movements, if dies change immunity
                case (moveAttempted)
                    2'b00: begin // move up
                        if (nextRow[position])begin
                            positionResult <= 3'b111; // die if position in next row same column blocked
                            immunity <= 1;
                        end
                        else positionResult <= position; // return same position as next position
                    end
                    2'b10: begin // move left
                        if ((position != 5) && (nextRow[position + 1] || headRow[position + 1])) begin // if not on edge of board die if position in (next row OR head row) in column to left blocked (i.e. head or tail collide)
                            positionResult <= 3'b111;
                            immunity <= 1;
                        end
                        else if (position != 5) positionResult <= (position + 1); // if not on edge of board return position to left
                        else if(position == 5 && nextRow[position]) begin // if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
                            positionResult <= 3'b111;
                            immunity <= 1;
                        end
                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
                    end
                    2'b01: begin // move right
                        if ((position != 0) && (nextRow[position - 1] || headRow[position - 1])) begin // if not on edge of board die if position in (next row OR head row) in column to right blocked (i.e. head or tail collide)
                            positionResult <= 3'b111;
                            immunity <= 1;
                        end
                        else if (position != 0) positionResult <= (position - 1); // if not on edge of board return position to right
                        else if(position == 0  && nextRow[position]) begin // if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
                            positionResult <= 3'b111;
                            immunity <= 1;
                        end
                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
                    end		
                endcase
            end
        end
    end
    
//	always @ (posedge clk) begin
//	   if (positionResult) begin
//           if (clkCnt == 100000000/2) begin
//               positionResult <= 0;
//           end
//       end
//       else begin
//           if (immunity && (immuneCount < immuneCycles)) begin // does not die, case only corrects movement
//               if ((immuneCount + 1) == (immuneCycles *(100000000/2))) begin
//                   immunity <= 0;
//                   immuneCount<= 0;
//               end
//               else immuneCount <= immuneCount + 1;
               
//               case (attemptMove)
//                    2'b00: begin // move up
//                        positionResult <= position; // return same position as next position
//                    end
//                    2'b10: begin // move left
//                        if (position != 5) positionResult <= (position + 1); // if not on edge of board return position to left
//                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
//                    end
//                    2'b01: begin // move right
//                        if (position != 0) positionResult <= (position - 1); // if not on edge of board return position to right
//                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
//                    end		
//                endcase
//           end
           
//           else begin // else check for death as well as movements, if dies change immunity
//                case (attemptMove)
//                    2'b00: begin // move up
//                        if (nextRow[position])begin
//                            positionResult <= 3'b111; // die if position in next row same column blocked
//                            immunity <= 1;
//                        end
//                        else positionResult <= position; // return same position as next position
//                    end
//                    2'b10: begin // move left
//                        if ((position != 5) && (nextRow[position + 1] || headRow[position + 1])) begin // if not on edge of board die if position in (next row OR head row) in column to left blocked (i.e. head or tail collide)
//                            positionResult <= 3'b111;
//                            immunity <= 1;
//                        end
//                        else if (position != 5) positionResult <= (position + 1); // if not on edge of board return position to left
//                        else if(position == 5 && nextRow[position]) begin // if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
//                            positionResult <= 3'b111;
//                            immunity <= 1;
//                        end
//                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
//                    end
//                    2'b01: begin // move right
//                        if ((position != 0) && (nextRow[position - 1] || headRow[position - 1])) begin // if not on edge of board die if position in (next row OR head row) in column to right blocked (i.e. head or tail collide)
//                            positionResult <= 3'b111;
//                            immunity <= 1;
//                        end
//                        else if (position != 0) positionResult <= (position - 1); // if not on edge of board return position to right
//                        else if(position == 0  && nextRow[position]) begin // if on edge of board die if position in (next row OR head row) in column in same position blocked (i.e. head or tail collide)
//                            positionResult <= 3'b111;
//                            immunity <= 1;
//                        end
//                        else positionResult <= position; // if on edge of board and not blocked, return same position as next position
//                    end		
//                endcase
//            end
//        end
//	end
	
endmodule
