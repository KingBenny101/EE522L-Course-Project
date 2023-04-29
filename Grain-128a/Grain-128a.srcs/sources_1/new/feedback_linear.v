`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051 
// Create Date: 23.04.2023 20:26:31
// Module Name: feedback_linear
// Project Name: Grain-128
//////////////////////////////////////////////////////////////////////////////////


module feedback_linear
(
    input s0,
    input s7,
    input s38,
    input s70,
    input s81,
    input s96,
    output lfb
);

assign lfb = s0 ^ s7 ^ s38 ^ s70 ^ s81 ^ s96;

endmodule
