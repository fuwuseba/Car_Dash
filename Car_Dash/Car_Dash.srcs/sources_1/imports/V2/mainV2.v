`timescale 1ns / 1ps

module main(clk, cs, write, data, debug, Buttons, RST, MISO, SS, MOSI, SCLK, anode, segment, SW);
// =============================================================================
//                              Port Declaration
//==============================================================================
    input clk;
    input [1:0] Buttons;    
    input [15:0] SW;
    
    input RST;					// Button D
    input MISO;					// Master In Slave Out, Pin 3, Port JA

    output cs, write, data, debug;
    
    output SS;					// Slave Select, Pin 1, Port JA
    output MOSI;				// Master Out Slave In, Pin 2, Port JA
    output SCLK;				// Serial Clock, Pin 4, Port JA

    output [7:0] anode;
    output [6:0] segment;

// =============================================================================
//                        Parameters, Registers, Wires
//==============================================================================
	parameter SCALE = 100000000;
	reg [3:0] state;
	reg [5:0] wins1;
	reg [5:0] wins2;
	
// clock values
    wire clk_scaled;
    wire [31:0] cnt_100M; // equivalent to negedge

// random obstacle generator
    wire [0:15] rand_seq;                                                                                         
    reg [1:0] get_rand;

// rows that car "moves in," later concatenated with assign
	reg moveReset;
	wire [5:0] headRow1; 
	wire [5:0] nextRow1; 
	wire [5:0] headRow2;
	wire [5:0] nextRow2;
    
// head values for moving car
    reg [3:0] headpos1;
	reg [3:0] headpos2;
	wire [2:0] headIn1, headIn2;
	
	wire [2:0] nextMove1;
	wire [2:0] nextMove2;
    
    parameter headStart1 = 12;
    parameter headStart2 = 4;
    
    parameter nextPlace = 15;
    parameter headPlace = 16;
    parameter tailPlace = 17;
    
// Joystick values
    wire SS;						// Active low
    wire MOSI;					// Data transfer from master to slave
    wire SCLK;					// Serial clock that controls communication
    
    wire [1:0] Joystick;				// Formatted joystick data
    wire [7:0] sndData;
    wire sndRec;
    wire [39:0] jstkData;

//    // Signal carrying output data that user selected
//    wire [9:0] posData;

// 7 Seg display values here



// game matrix values
	reg [393:0] seq;
	reg [31:0] seq_nbits;
	
	integer game_matrix [15:0][23:0];
	integer matrix_to_send [15:0][23:0];    

	parameter ROWS = 16;
	parameter COLS = 24;
	parameter MATRIX_TOTAL = ROWS * COLS; //384
	integer i, j, k;
	
	
// =============================================================================
//                              Assign Wires 
//==============================================================================
    
    assign headIn1 = ((headpos1-3)%6);
    assign headIn2 = ((headpos2 - 1)% 6);

    wire po5, po4, po3, po2, po1, po0, pt5, pt4, pt3, pt2, pt1, pt0;
    wire pon5, pon4, pon3, pon2, pon1, pon0, ptn5, ptn4, ptn3, ptn2, ptn1, ptn0;
    
    assign pt5 = ((game_matrix[6][headPlace] == 100) ? 0 : game_matrix[6][headPlace]);
    assign pt4 = ((game_matrix[5][headPlace] == 100) ? 0 : game_matrix[5][headPlace]);
    assign pt3 = ((game_matrix[4][headPlace] == 100) ? 0 : game_matrix[4][headPlace]);
    assign pt2 = ((game_matrix[3][headPlace] == 100) ? 0 : game_matrix[3][headPlace]);
    assign pt1 = ((game_matrix[2][headPlace] == 100) ? 0 : game_matrix[2][headPlace]);
    assign pt0 = ((game_matrix[1][headPlace] == 100) ? 0 : game_matrix[1][headPlace]);
    
    assign headRow2 = {pt5, pt4, pt3, pt2, pt1, pt0};
    
    assign ptn5 = game_matrix[6][nextPlace];
    assign ptn4 = game_matrix[5][nextPlace];
    assign ptn3 = game_matrix[4][nextPlace];
    assign ptn2 = game_matrix[3][nextPlace];
    assign ptn1 = game_matrix[2][nextPlace];
    assign ptn0 = game_matrix[1][nextPlace];
    
    assign nextRow2 = {ptn5, ptn4, ptn3, ptn2, ptn1, ptn0}; 
         
    assign po5 = ((game_matrix[14][headPlace] == 100) ? 0 : game_matrix[14][headPlace]);
    assign po4 = ((game_matrix[13][headPlace] == 100) ? 0 : game_matrix[13][headPlace]);
    assign po3 = ((game_matrix[12][headPlace] == 100) ? 0 : game_matrix[12][headPlace]);
    assign po2 = ((game_matrix[11][headPlace] == 100) ? 0 : game_matrix[11][headPlace]);
    assign po1 = ((game_matrix[10][headPlace] == 100) ? 0 : game_matrix[10][headPlace]);
    assign po0 = ((game_matrix[9][headPlace] == 100) ? 0 : game_matrix[9][headPlace]);
    
    assign headRow1 = {po5, po4, po3, po2, po1, po0};
    
    assign pon5 = game_matrix[14][nextPlace];
    assign pon4 = game_matrix[13][nextPlace];
    assign pon3 = game_matrix[12][nextPlace];
    assign pon2 = game_matrix[11][nextPlace];
    assign pon1 = game_matrix[10][nextPlace];
    assign pon0 = game_matrix[9][nextPlace];
    
    assign nextRow1 = {pon5, pon4, pon3, pon2, pon1, pon0};
        



// =============================================================================
//                              Instantiation
//==============================================================================

// clock related
    clk_scale clk_scl(
        clk,
        SCALE,
        clk_scaled
    );
    
    ClkDiv_5Hz genSndRec(
        clk,
        RST,
        sndRec
    );
    
	counter_100M counter(
		clk,
		SCALE,
		cnt_100M
    );

//random sequence/obstacle generator
    gen_rand_seq rand(
        clk,
        cnt_100M,
        SCALE,
        rand_seq
    );
    
 // Car movement
    moveCarImmunity player1(
        clk,
        moveReset,
        nextRow1,
        headRow1,
        headIn1,
        Buttons,
        nextMove1
    );
    
    moveCarImmunity player2(
        clk, 
        moveReset,
        nextRow2,
        headRow2,
        headIn2,
        Joystick,
        nextMove2
    );

// Joystick
    PmodJSTK PmodJSTK_Int(
        .CLK(clk),
        .RST(RST),
        .sndRec(sndRec),
        .DIN(sndData),
        .MISO(MISO),
        .SS(SS),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .DOUT(jstkData)
    );
    
// formatted joystick data
    format my_format(
       .jstkData(jstkData),
       .clk(clk),
       .OUT(Joystick)
       );
			   
// LED Matrix
	LED_matrix mat(
		.clk(clk),
		.cnt_100M(cnt_100M),
		.wr_seq(seq),
		.wr_seq_nbits(seq_nbits),
		.cs(cs),
		.write(write),
		.data(data),
		.debug(debug)
    );


// =============================================================================
//                              Tasks
//==============================================================================

    //transfer 8 slots to where they map on board    
    task transfer_line;
        input integer to_row, to_col, from_row, from_col;
        begin
            for( i=0; i<8; i = i + 1 ) begin
                matrix_to_send[to_row][to_col + i] = game_matrix[from_row][from_col + i];
            end        
        end
	endtask

    //how to transfer each line
    task transform_mat_for_board;
        begin
            transfer_line(0,0,0,0);
            transfer_line(0,8,8,0);
            transfer_line(0,16,1,0);
            
            transfer_line(1,0,9,0);
            transfer_line(1,8,2,0);
            transfer_line(1,16,10,0);
            
            transfer_line(2,0,3,0);
            transfer_line(2,8,11,0);
            transfer_line(2,16,4,0);
            
            transfer_line(3,0,12,0);
            transfer_line(3,8,5,0);
            transfer_line(3,16,13,0);
            
            transfer_line(4,0,6,0);
            transfer_line(4,8,14,0);
            transfer_line(4,16,7,0);
            
            transfer_line(5,0,15,0);
            transfer_line(5,8,0,8);
            transfer_line(5,16,8,8);
            
            transfer_line(6,0,1,8);
            transfer_line(6,8,9,8);
            transfer_line(6,16,2,8);
            
            transfer_line(7,0,10,8);
            transfer_line(7,8,3,8);
            transfer_line(7,16,11,8);
            
            transfer_line(8,0,4,8);
            transfer_line(8,8,12,8);
            transfer_line(8,16,5,8);
            
            transfer_line(9,0,13,8);
            transfer_line(9,8,6,8);
            transfer_line(9,16,14,8);
            
            transfer_line(10,0,7,8);
            transfer_line(10,8,15,8);
            transfer_line(10,16,0,16);
                
            transfer_line(11,0,8,16);
            transfer_line(11,8,1,16);
            transfer_line(11,16,9,16);
            
            transfer_line(12,0,2,16);
            transfer_line(12,8,10,16);
            transfer_line(12,16,3,16);
            
            transfer_line(13,0,11,16);
            transfer_line(13,8,4,16);
            transfer_line(13,16,12,16);
            
            transfer_line(14,0,5,16);
            transfer_line(14,8,13,16);
            transfer_line(14,16,6,16);
            
            transfer_line(15,0,14,16);
            transfer_line(15,8,7,16);
            transfer_line(15,16,15,16);
            
        end
    endtask
    
    task gen_seq_to_send;
        begin
            seq = 5 << 7;
            k = 0;
            for( i=0; i<ROWS; i = i + 1 ) begin
                for( j=0; j<COLS; j = j + 1 ) begin
                    if(matrix_to_send[i][j] == 0)	seq = seq << 1;
                    else    seq = (seq << 1) + 1;
                    k = k + 1;
                end
            end
        end
	endtask
	

// =============================================================================
//                              Initial
//==============================================================================

//=============== 7 seg ===============
	reg [3:0] digit;
	reg [3:0] pos;

    //counter for the 7-seg clock scaling
    reg cnt;
	reg clk_for_7seg;
	integer state_seg;
	integer num;
			
	initial begin
	
	cnt <= 0;
	num <= 0;
	state_seg <= 0;
	pos <= 1;
	digit <= 0;
	//========================================
	//             Matrix
	//=======================================
		seq_nbits <= 394;
		get_rand <= 0;
	
		//init matrices
		for( i=0; i<ROWS; i = i + 1 ) begin
			for( j=0; j<COLS; j = j + 1 ) begin
				game_matrix[i][j] = 0;
				matrix_to_send[i][j] = 0;
			end
		end		
		
	   for( j=0; j<COLS; j = j + 1 ) begin
				game_matrix[0][j] = 2;
				game_matrix[7][j] = 2;
				game_matrix[8][j] = 2;
				game_matrix[15][j] = 2;
	   end	
	
	   	
		transform_mat_for_board();
		gen_seq_to_send();
		
//      vertical display
//	   	$display("\nTo Send matrix: in initial after transform");
//        for (i = 0; i < COLS; i = i + 1) begin
//            for (j = 0; j < ROWS; j = j + 1) begin
//                $write("%D", game_matrix[j][i]);
//            end
//            $write("\n");
//        end  
		   
       //===============================================
       //                    Game data
       //===============================================
	    
	    //player 1
		game_matrix[headStart1][headPlace] = 100;
		game_matrix[headStart1][tailPlace] = 100;
		headpos1 = headStart1;
		
	    //player 2
	    game_matrix[headStart2][headPlace] = 100;
	    game_matrix[headStart2][tailPlace] = 100;
	    headpos2 = headStart2;

		state <= 0;
		moveReset <= 0;
		wins1 = 00;
		wins2 = 00;
	end


// =============================================================================
//                              Implementation
//==============================================================================

//// ============================================
////                7Seg Clock
////===========================================    

    wire [7:0] anode;
    wire [6:0] segment;

    segmain main_for_7_seg(
        .anode(anode), 
        .segment(segment), 
        .clk_100MHz(clk),
        .wins1(wins1),
        .wins2(wins2)
    );

    
//    always @(posedge clk) begin
//	   if( cnt == 100000)	begin
//			cnt <= 0;
//			clk_for_7seg <= !clk_for_7seg;
//		end
//		else begin
//		  cnt <= cnt + 1;
//	    end
	   
//	end
	
//	seven_seg seven_seg( 
//		.scaled_clk(clk_for_7seg), 
//		.digit(digit), 
//		.pos(pos),
//		.anode(anode), 
//		.segment(segment)
//	);
	
//	always @ (posedge clk_for_7seg) begin
//	       case(state_seg)
//	       0: begin
//	           pos = 2;
//	          if (pos == 2)begin
//	              num = wins1;
//	          end
//	           digit = num%10;
//	           num = num/10;
//	           state_seg = state_seg + 1;
//	        end
//	        1: begin
//	           pos = 1;
//	           digit = num%10;
//	           num = num/10;
//	           state_seg = state_seg + 1;
//	        end
//	        2: begin
//	           pos = 6;
//	           if(num == 0) begin
//	               num = wins2;
//	           end
//	           digit = num%10;
//	           num = num/10;
//	           state_seg = state_seg + 1; 
//	        end
//	        3: begin
//	           pos = 5;
//	           digit = num%10;
//	           num = num/10;
//	           state_seg = 0;
//	        end
	           
//	      endcase
//	 end

// ===============================================


	always @ (posedge clk) begin
		case (state) 
			0: begin	
				if (cnt_100M == ((SCALE/2)-6)) begin // begin processing data n clock cycles before posedge (n == number of states)
					state <= 1;
					moveReset <= 1;
				end
                //else if (moveReset) moveReset <= 0;

				else if ((cnt_100M == ((SCALE/2)+(SCALE/10))) /*&& moveReset*/) moveReset <= 0;
			end
			1: begin
				state <= 2;
				//turn off car position
				game_matrix[headpos1][headPlace] <= 0;
				game_matrix[headpos1][tailPlace] <= 0;
				game_matrix[headpos2][headPlace] <= 0;
				game_matrix[headpos2][tailPlace] <= 0;
			end
			2: begin
				state <= 3;
			   //move down LEDs
				for( j=COLS-1; j > 0; j = j - 1 ) begin
				   for( i=0; i < ROWS; i = i + 1 ) begin
						 game_matrix[i][j] = game_matrix[i][j-1];
				   end
				end		
			end
			3: begin
				state <= 4;
				for( i=0; i < ROWS; i = i + 1 ) begin
					if (i == 0 || i == 7 || i == 8 || i == 15) game_matrix[i][0] = 2;
					else begin
						if (get_rand == 3) begin
						game_matrix[i][0] = rand_seq[i];
						if (SW[i]) game_matrix[i][0] = 1;
						end
						else game_matrix[i][0] = 0;
					end
				end
			end
			4: begin
				state <= 5;
				//change headrows/move car
				if (nextMove1[2])  wins2 <= wins2 + 1;
				case (nextMove1[1:0])
					2'b00: headpos1 <= headpos1;
					2'b01: headpos1 <= headpos1 - 1;
					2'b10: headpos1 <= headpos1 + 1;
				endcase
				
				if (nextMove2[2]) wins1 <= wins1 + 1;
				case (nextMove2[1:0]) 
					2'b00: headpos2 <= headpos2;
					2'b01: headpos2 <= headpos2 - 1;
					2'b10: headpos2 <= headpos2 + 1;
				endcase
			end
			5: begin
				state <= 6;
				//put car on matrix
				game_matrix[headpos1][headPlace] <= 100;
				game_matrix[headpos1][tailPlace] <= 100;
				game_matrix[headpos2][headPlace] <= 100;
				game_matrix[headpos2][tailPlace] <= 100;
			end
			6: begin
				if (cnt_100M == (SCALE/2)) begin
					state <= 0;
					transform_mat_for_board();
					gen_seq_to_send();
					if (get_rand == 3) get_rand <= 0;
					else get_rand <= get_rand + 1;
                    //moveReset <= 0; //nextMove should not change until reset is enabled again

//					for (i = 0; i < COLS; i = i + 1) begin
//                         for (j = ROWS-1; j > -1 ; j = j - 1) begin
//                             $write("%D", game_matrix[j][i]);
//                         end
//                        $write("\n");
//                     end
//                     $write("\n");
//                     $write("%b ",  rand_seq);
//                     $write("\n");

				end
			end
        endcase
	end

endmodule