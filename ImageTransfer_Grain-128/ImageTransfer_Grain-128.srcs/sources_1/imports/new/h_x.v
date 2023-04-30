`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 20:41:49
// Module Name: h_x
// Project Name: Grain - 128 
//////////////////////////////////////////////////////////////////////////////////


module h_x
(
    input s8,
    input s13,
    input s20,
    input s42,
    input s60,
    input s79,
    input s95,
    input b12,
    input b95,
    output ho
);

assign ho = (b12 & s8) ^ (s13 & s20) ^ (b95 & s42) ^ (s60 & s79) ^ (b12 & s95 & b95);

endmodule
