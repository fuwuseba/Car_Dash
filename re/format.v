`timescale 1ns / 1ps

module format(
    output reg [1:0] OUT,
    input clk,
    wire [39:0] jstkData
    );

    initial begin
        OUT <= 0;
    end
    
    always @ (posedge clk) begin
        if ({jstkData[9:8], jstkData[23:16]} < 9'd400) begin
            OUT <= 2;
        end
        else if ({jstkData[9:8], jstkData[23:16]} > 10'd600) begin
            OUT <= 1;
        end
        else OUT <= 0;
    end
endmodule
