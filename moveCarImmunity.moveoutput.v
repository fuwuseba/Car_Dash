`timescale 1ns / 1ps

module moveCarImmunity (clk, clkCnt, nextRow, headRow, position, attemptMove, moveResult);
	input clk;
    input [31:0] clkCnt;
	input [5:0] nextRow, headRow;
	input [5:0] position;
	input [1:0] attemptMove;
	
	output reg [1:0] moveResult; // 0 = alive, 1 = dead
	
	
	reg immunity;
	reg [31:0] immuneCount;
	reg [1:0] moveInput;
	
	parameter immuneCycles = 3;	
	
	
	initial begin
	   moveResult <= 0;
	   immunity <= 0;
	   immuneCount <= 0;
	   moveInput <= 0;
   end
   
   
    always @ (posedge clk) begin
        if (clkCnt != ((100000000/2))) begin
            if (clkCnt == 501) begin
				//moveResult <= 0;
				if (!attemptMove) moveInput <= 0;
				else moveInput <= attemptMove;
            end
            else begin
                if (attemptMove && !moveInput) moveInput <= attemptMove;
            end
        end
        else begin
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
            end
            else /* if (!immunity) */ begin 
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
        end
    end
    
//        if (clkCnt != 1000) begin
//			if (!clkCnt) begin
//				moveResult <= 0;
//				if (!attemptMove) moveInput <= 0;
//				else moveInput <= attemptMove;
//				clkCnt <= 1;
//			end
//			else begin 
//				if (attemptMove && !moveInput) moveInput <= attemptMove;
//				clkCnt <= clkCnt + 1;
//			end
//		end
//		else /*if (clkCnt == 100000000/2)*/ begin
//			clkCnt <= 0;
			
//		end

endmodule
