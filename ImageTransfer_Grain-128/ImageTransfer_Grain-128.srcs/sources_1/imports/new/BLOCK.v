`timescale 1ns / 1ps

module BLOCK
#
(
    parameter IMAGE_WIDTH     = 256,
    parameter IMAGE_HEIGHT    = 256,
    parameter CHANNELS        = 3,
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
    input [$clog2(B_W):0]b_addr_i,
    input [$clog2(B_H):0]b_addr_j,
    input rw,// 0 for read, 1 for write
    input [BLOCK_SIZE*BLOCK_SIZE*CHANNELS*RAM_WIDTH-1:0]in,
    input [CHANNELS*RAM_ADDR_BITS-1:0] disp_addr,
    output [BLOCK_SIZE*BLOCK_SIZE*CHANNELS*RAM_WIDTH-1:0]out,
    output [CHANNELS*RAM_WIDTH-1:0] disp_out,
    output reg done
);

reg [RAM_ADDR_BITS-1:0] addr;
reg [RAM_WIDTH-1:0] b_in;
wire [RAM_WIDTH-1:0] b_out;
reg [2:0] curr_mode = 0;
reg [2:0] next_mode = 0;

wire [RAM_WIDTH-1:0] in_arr [0:BLOCK_SIZE-1][0:BLOCK_SIZE-1][0:CHANNELS-1];
reg [RAM_WIDTH-1:0] out_arr [0:BLOCK_SIZE-1][0:BLOCK_SIZE-1][0:CHANNELS-1]; 
reg r_en,w_en;
reg l; // Added because Xilinx Block Memory Requires 2 clock cycles to read

generate
    genvar x,y,z;
        for(x = 0; x < BLOCK_SIZE; x = x + 1)begin
            for(y = 0; y < BLOCK_SIZE; y = y + 1)begin
                for(z = 0; z < CHANNELS; z = z + 1)begin
                    assign in_arr[x][y][z] = in[(x + y*BLOCK_SIZE + z*BLOCK_SIZE*BLOCK_SIZE+1)* RAM_WIDTH-1:(x + y*BLOCK_SIZE + z*BLOCK_SIZE*BLOCK_SIZE)*RAM_WIDTH];
                    assign out[(x + y*BLOCK_SIZE + z*BLOCK_SIZE*BLOCK_SIZE+1)* RAM_WIDTH-1:(x + y*BLOCK_SIZE + z*BLOCK_SIZE*BLOCK_SIZE)*RAM_WIDTH] = out_arr[x][y][z] ;
                end
            end
        end
endgenerate

// BRAM #(
//     .IMAGE_WIDTH(IMAGE_WIDTH),
//     .IMAGE_HEIGHT(IMAGE_HEIGHT),
//     .CHANNELS(CHANNELS),
//     .RAM_WIDTH(RAM_WIDTH),
//     .RAM_HEIGHT(RAM_HEIGHT),
//     .RAM_ADDR_BITS(RAM_ADDR_BITS),
//     .INIT_START_ADDR(INIT_START_ADDR),
//     .INIT_END_ADDR(INIT_END_ADDR)
// ) B0 (clk,r_en,w_en,addr,disp_addr,b_in,b_out,disp_out);


BRAM B0 (
  .clka(clk),    // input wire clka
  .ena(r_en),      // input wire ena
  .wea(w_en),      // input wire [0 : 0] wea
  .addra(addr),  // input wire [16 : 0] addra
  .dina(b_in),    // input wire [7 : 0] dina
  .douta(b_out),  // output wire [7 : 0] douta
  .clkb(clk),    // input wire clkb
  .enb(1'b1),      // input wire enb
  .web(1'b0),      // input wire [0 : 0] web
  .addrb(disp_addr),  // input wire [16 : 0] addrb
  .dinb(8'b0),    // input wire [7 : 0] dinb
  .doutb(disp_out)  // output wire [7 : 0] doutb
);



localparam IDLE = 3'b000;
localparam INIT = 3'b001;
localparam WAIT = 3'b010;
localparam SAVE = 3'b011;
localparam IDX = 3'b100; 
localparam DONE = 3'b101; 
localparam WAIT1 = 3'b110;

integer i,j,k;

always @(posedge clk) begin
    if(reset)begin
        curr_mode = IDLE;
    end
    else begin
        curr_mode = next_mode;
    end 

    case(curr_mode)
        IDLE: begin
            for(i = 0; i < BLOCK_SIZE ; i = i + 1)begin
                for(j = 0; j < BLOCK_SIZE ; j = j + 1)begin
                    for(k = 0; k < CHANNELS; k = k + 1)begin
                        out_arr[i][j][k] = 0;
                    end
                end
            end
            done = 0;
            r_en = 0;
            w_en = 0;
            i = 0;
            j = 0;
            k = 0;
            l = 0;
            if(start && !reset)begin
                next_mode = INIT;
            end
            else begin
                next_mode = IDLE;    
            end
        end

        INIT: begin
            addr = k*(IMAGE_HEIGHT*IMAGE_WIDTH) + (i*IMAGE_WIDTH + b_addr_i*BLOCK_SIZE) + j + b_addr_j*BLOCK_SIZE*IMAGE_WIDTH;
            r_en = 1;
            b_in = in_arr[i][j][k];
            w_en = rw;
            next_mode = WAIT;
        end 
        
        WAIT: begin
            r_en = 0;
            w_en = 0;
            if(l) begin
                next_mode = SAVE;
            end
            else begin
                next_mode = INIT;
                l = 1;
            end
        end

        SAVE: begin
            out_arr[i][j][k] = b_out;
            next_mode = IDX;
            l = 0;
        end

        IDX : begin
            if(k < CHANNELS-1)begin
                k = k + 1;
                next_mode = INIT;
            end
            else if(j < BLOCK_SIZE-1)begin
                k = 0;
                j = j + 1;
                next_mode = INIT;
            end
            else if(i < BLOCK_SIZE-1)begin
                k = 0;
                j = 0;
                i = i + 1;
                next_mode = INIT;
            end
            else begin
                next_mode = DONE;
            end
        end

        DONE: begin
            done = 1;
        end

    endcase
end
endmodule
