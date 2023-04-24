`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 20:29:47 
// Module Name: feedback_non_linear
// Project Name: Grain - 128
//////////////////////////////////////////////////////////////////////////////////


module feedback_non_linear
(
    input b0,
    input b26,
    input b56,
    input b91,
    input b96,
    input b3,
    input b67,
    input b11,
    input b13,
    input b17,
    input b18,
    input b27,
    input b59,
    input b40,
    input b48,
    input b61,
    input b65,
    input b68,
    input b84,
    output nfb
);

assign nfb = b0 ^ b26 ^ b56 ^ b91 ^ b96 ^ (b3 & b67) ^ (b11 & b13) ^ (b17 & b18) ^ (b27 & b59) ^ (b40 & b68) ^ (b61 & b65) ^ (b68 & b84); 

endmodule
