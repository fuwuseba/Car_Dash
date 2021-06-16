`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2019 06:58:49 PM
// Design Name: 
// Module Name: formatting_buttons
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


module formatting_buttons(
    input clk,
    input [1:0] Buttons,
    output reg [1:0] OUT
    );
    
    initial begin
        OUT = 0;
    end
    
    always @ (posedge clk) begin
        if (Buttons == 2) begin
            OUT <= 1;
        end
        else if (Buttons == 1) begin
            OUT <= 2;
        end
        else OUT <= 0;
    end
    
endmodule
