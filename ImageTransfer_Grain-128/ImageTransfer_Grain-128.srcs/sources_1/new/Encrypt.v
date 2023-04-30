`timescale 1ns / 1ps

module Encrypt
# (
    parameter N = 8
)
(
    input clk,
    input reset,
    input [N-1:0] in,
    output reg [N-1:0] out,
    output reg done
);

localparam IDLE = 3'b000;
localparam INIT = 3'b001;
localparam GEN = 3'b010;
localparam DONE = 3'b011; 

reg [2:0] mode = 0;


reg [127:0] key = 0;
reg [95:0] iv = 0;
reg gen = 0;
reg [N-1:0] key_stream = 0;
reg [$clog2(N):0] i = 0;

wire z,rdy;

grain128 G0 (clk,reset,key,iv,gen,rdy,z);

always @(posedge clk) begin
    if(reset) begin
        done <= 1'b0;
        mode <= IDLE;
    end
    case(mode) 
        IDLE: begin     
            done <= 1'b0;
            i <= 0;
            key_stream <= 0;
            if(!reset) begin
                mode <= INIT;
            end
        end
        INIT: begin
            if(rdy) begin
                mode <= GEN;
                gen <= 1;
            end
        end
        GEN: begin
            key_stream <= {key_stream[N-2:0] ,z};
            i <= i + 1;
            if(i == N ) begin
                mode <= DONE;
                gen <= 0;
                out <= in ^ key_stream;
            end
        end
        DONE: begin
            done <= 1'b1;
        end 
    endcase
end

endmodule
