`timescale 1ns / 1ps


module TB_PROCESS
#
(
    parameter IMAGE_WIDTH     = 300,
    parameter IMAGE_HEIGHT    = 300,
    parameter CHANNELS        = 1,
    parameter RAM_WIDTH 		= 8,
    parameter RAM_HEIGHT        = IMAGE_WIDTH * IMAGE_HEIGHT*CHANNELS,
    parameter RAM_ADDR_BITS 	= $clog2(RAM_HEIGHT),
    parameter INIT_START_ADDR 	= 0,
    parameter INIT_END_ADDR		= RAM_HEIGHT - 1,
    parameter BLOCK_SIZE = 10,
    parameter B_W = IMAGE_WIDTH/BLOCK_SIZE,
    parameter B_H = IMAGE_HEIGHT/BLOCK_SIZE
)
();

reg clk;
reg start;
reg reset;
reg [RAM_ADDR_BITS-1:0] disp_addr;
wire [RAM_WIDTH-1:0] disp_out;
wire done;

PROCESS #(.IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .CHANNELS(CHANNELS),
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_HEIGHT(RAM_HEIGHT),
    .RAM_ADDR_BITS(RAM_ADDR_BITS),
    .INIT_START_ADDR(INIT_START_ADDR),
    .INIT_END_ADDR(INIT_END_ADDR),
    .BLOCK_SIZE(BLOCK_SIZE),
    .B_W(B_W),
    .B_H(B_H)) DUT (clk,start,reset,disp_addr,disp_out,done);


initial begin
    clk = 0;
    reset = 0;
    start = 1;
    disp_addr = 0;

    forever begin
        #5 clk = ~clk;
    end
end

endmodule
