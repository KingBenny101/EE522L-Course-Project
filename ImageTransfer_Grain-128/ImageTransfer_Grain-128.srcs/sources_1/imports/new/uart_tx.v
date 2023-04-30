`timescale 1ns / 1ps

module uart_tx
(
    input reset,
    input txclk,
    input ld_tx_data,
    input [7:0]tx_data,
    input tx_enable,
    output reg tx_out,
    output reg tx_empty
);

reg [7:0]tx_data_reg;
reg [1:0]tx_mode = 0;
reg [2:0]tx_bit_count = 0;

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA = 2'b10;
parameter STOP = 2'b11;

always @(posedge txclk) begin
    if (reset) begin
        tx_mode <= IDLE;
        tx_data_reg <= 8'b00000000;
        tx_empty <= 1'b1;
    end
    else begin
        if (ld_tx_data) begin
            tx_data_reg <= tx_data;
            tx_empty <= 1'b0;
        end
    end
    case (tx_mode)
        IDLE: begin
            tx_out <= 1'b1;
            tx_empty <= 1'b1;
            if (tx_enable && tx_empty) begin
                tx_mode <= START;
            end
        end
        START: begin
            tx_out <= 1'b0;
            tx_mode <= DATA;
        end
        DATA: begin
            tx_out <= tx_data_reg[0];
            tx_data_reg <= tx_data_reg >>> 1; 
            tx_bit_count <= tx_bit_count + 1;
            if (tx_bit_count == 7) begin
                tx_mode <= STOP;
            end
        end
        STOP: begin
            tx_out <= 1'b1;
            tx_empty <= 1'b1;
            tx_mode <= IDLE;
        end 
    endcase
end
endmodule