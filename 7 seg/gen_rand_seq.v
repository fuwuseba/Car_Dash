//Generate Random Sequence
module gen_rand_seq(clk, clk_scaled, seq);
	input clk, clk_scaled;
	output reg [0:15] seq;
	reg [3:0] rand1;
	reg [3:0] rand2;
	reg [3:0] rand3;
	reg [3:0] rand4;
	reg [3:0] rand5;
	reg [3:0] rand6;
	reg [31:0] cnt;
	reg [31:0] pi;
	reg [5:0] mod;
	reg [31:0] temp;
	reg [31:0] var;
	
	initial begin
		seq <= 16'b1000000110000001;
		pi <= 314159265;
	    mod <= 3;
		cnt <= 0;
		var <= 1;
	end
	
	always @ (posedge clk) begin
        if (cnt > 100000000) cnt = 0;
		//if (cnt > 1000) cnt = 0;
			else cnt = cnt + var;
	end
	
	always @ (posedge clk_scaled) begin
	    seq = 16'b1000000110000001;
        temp = cnt;
        
		rand1 = temp % 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		rand2 = temp % 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		rand3 = temp % 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		rand4 = (temp % 8) + 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		rand5 = (temp % 8) + 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		rand6 = (temp % 8) + 8;
		temp = temp + (pi % mod);
		pi = pi/10;
		mod = mod + 1;
		
		seq[rand1] = 1;
		seq[rand2] = 1;
		seq[rand3] = 1;
		seq[rand4] = 1;
		seq[rand5] = 1;
		seq[rand6] = 1;
		pi = 314159265;
		mod = 3;
		if (var > 100000000) var = 0;
		//if (var > 1000) var = 0;
			else var = var + 1;
	end	
endmodule