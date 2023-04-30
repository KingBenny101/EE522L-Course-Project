`timescale 1ns / 1ps

module uart_clk 
(
    input clk,
    output reg txclk
);
    
parameter CYCLES_PER_BIT = 5208;

reg [11:0] counter = 0;
initial begin
    txclk = 0;
end

always @(posedge clk) begin
    counter <= counter + 1;
    if (counter == (CYCLES_PER_BIT/2) + 1) begin
        counter <= 0;
        txclk <= ~txclk;
    end
end
    
endmodule
