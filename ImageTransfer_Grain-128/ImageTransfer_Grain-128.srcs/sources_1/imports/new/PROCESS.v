`timescale 1ns / 1ps


module PROCESS
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
(
    input clk,
    input start,
    input reset,
    input [CHANNELS*RAM_ADDR_BITS-1:0] tx_addr,
    output [CHANNELS*RAM_WIDTH-1:0] tx_out,
    output reg done
);

localparam IDLE =3'b000;
localparam INIT = 3'b001;
localparam READ = 3'b010;
localparam WAIT = 3'b011;
localparam SAVE = 3'b100;
localparam IDX = 3'b101; 
localparam DONE = 3'b110;

reg [2:0] curr_mode = 0;
reg [2:0] next_mode = 0;
reg [$clog2(B_W):0] b_addr_i;
reg [$clog2(B_H):0] b_addr_j;
reg rw;
reg b_rst,p_rst;
reg b_start;
reg [BLOCK_SIZE*BLOCK_SIZE*CHANNELS*RAM_WIDTH-1:0] p_in,b_in;
wire [BLOCK_SIZE*BLOCK_SIZE*CHANNELS*RAM_WIDTH-1:0] p_out,b_out;
wire p_done,b_done;

BLOCK #(
    .BLOCK_SIZE(BLOCK_SIZE),
    .IMAGE_WIDTH(IMAGE_WIDTH),
    .IMAGE_HEIGHT(IMAGE_HEIGHT),
    .CHANNELS(CHANNELS),
    .RAM_WIDTH(RAM_WIDTH),
    .RAM_HEIGHT(RAM_HEIGHT),
    .RAM_ADDR_BITS(RAM_ADDR_BITS),
    .INIT_START_ADDR(INIT_START_ADDR),
    .INIT_END_ADDR(INIT_END_ADDR),
    .B_W(B_W),
    .B_H(B_H)
) B0 (clk,b_start,b_rst,b_addr_i,b_addr_j,rw,b_in,tx_addr,b_out,tx_out,b_done);

Encrypt #(.N(BLOCK_SIZE*BLOCK_SIZE*CHANNELS*RAM_WIDTH)) E0 (clk,p_rst,p_in,p_out,p_done);


always @(posedge clk) begin
    if(reset)begin
        curr_mode = IDLE;
    end 
    else begin
        curr_mode = next_mode;
    end

    case (curr_mode)
        IDLE: begin
            b_addr_i = 0;
            b_addr_j = 0;
            rw = 0;
            done = 0;
            b_rst = 1;
            b_start = 0;
            p_rst = 1;
            if(start && !reset)begin
                next_mode = INIT;
            end
            else begin
                next_mode = IDLE;    
            end
        end 
        INIT: begin
            b_rst = 0;
            b_start = 1;
            rw = 0;
            next_mode = READ;
        end
        READ: begin
            if(b_done)begin
                next_mode = WAIT;
                b_rst = 1;
                b_start = 0;
                p_in = b_out;
                p_rst = 0;
            end
            else begin
                next_mode = INIT;
            end
        end
        WAIT: begin
            if(p_done)begin
                next_mode = SAVE;
                p_rst = 1;
                b_rst = 0;
                b_start = 1;
                rw = 1;
                b_in = p_out;
            end
            else begin
                next_mode = WAIT;
            end
        end
        SAVE: begin
            if(b_done)begin
                next_mode = IDX;
                b_rst = 1;
                b_start = 0;
            end
            else begin
                next_mode = SAVE;
            end
        end
        IDX: begin
            if(b_addr_i == B_W-1)begin
                b_addr_i = 0;
                if(b_addr_j == B_H-1)begin
                    next_mode = DONE;
                end
                else begin
                    b_addr_j = b_addr_j + 1;
                    next_mode = INIT;
                end
            end
            else begin
                b_addr_i = b_addr_i + 1;
                next_mode = INIT;
            end
        end
        DONE: begin
            done = 1;
        end
    endcase
end
endmodule
