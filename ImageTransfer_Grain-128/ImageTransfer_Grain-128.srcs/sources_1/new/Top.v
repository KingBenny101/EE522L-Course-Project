`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 30.04.2023 23:27:34
// Module Name: Top
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module Top
(
    input clk,
    input start,
    input rst,
    output reg done,
    output tx_out
);


localparam IDLE = 3'b000;
localparam PROCESS = 3'b001;
localparam TRANSFER = 3'b010;
localparam DONE = 3'b011;


reg [2:0] curr_state = 0,next_state = 0;


reg process_start = 0;
reg transfer_start = 0;
wire process_done;
wire transfer_done;

wire [16:0] bram_addr;
wire [7:0] bram_data;

Transfer T0 (clk,transfer_start,rst,bram_data,transfer_done,bram_addr,tx_out);
PROCESS E0 (clk,process_start,rst,bram_addr,bram_data,process_done);

always @(posedge clk ) begin

if(rst) begin
    curr_state <= IDLE;
end
else begin
    curr_state <= next_state;
end

case (curr_state)
    IDLE : begin
        process_start <= 0;
        transfer_start <= 0;
        done <= 0;
        if(!rst && start) begin
            next_state <= PROCESS;
        end
    end
    PROCESS : begin
        if(process_done) begin
            next_state <= TRANSFER;
            process_start <= 0;
            transfer_start <= 1;
        end
        else begin
            process_start <= 1;
            transfer_start <= 0;
            next_state <= PROCESS;
        end
    end
    TRANSFER : begin
        if(transfer_done) begin
            next_state <= DONE;
        end
        else begin
            next_state <= TRANSFER;
        end
    end
    DONE : begin
        done <= 1;
        next_state <= DONE;
    end
endcase
    
end

endmodule
