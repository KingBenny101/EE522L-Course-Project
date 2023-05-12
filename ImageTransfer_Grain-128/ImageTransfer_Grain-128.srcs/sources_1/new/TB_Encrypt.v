`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.04.2023 22:36:47
// Design Name: 
// Module Name: TB_Encrypt
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


module TB_Encrypt();

parameter N = 800;

reg clk = 0;
reg reset = 0;
reg [N-1:0] in;
wire [N-1:0] out;
wire done;


Encrypt #(.N(N)) E0 (clk,reset,in,out,done);

initial begin
    forever begin
        #5 clk = ~clk;
    end    
end

initial begin
    reset = 1;
    in = 0;
    #10 reset = 0;
end
endmodule
