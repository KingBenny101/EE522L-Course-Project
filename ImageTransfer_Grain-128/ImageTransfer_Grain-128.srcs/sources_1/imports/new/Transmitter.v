`timescale 1ns / 1ps

module Transmitter 
(
    input clk,        //Connect this to System Clock
    input tx_enable,  //It will transmit the data when tx_enable is 1
    input reset,      //It will reset when posetive edge of reset is triggered
    input ld_tx_data, //Positive edge of ld_tx_data will load tx_data to the transmitter
    input [7:0] tx_data,
    output tx_empty,  //It is high when there is no data to send in the UART
    output tx_out     //This is TX of sender and connect this to RX of receiver
);  


//wire [7:0]tx_data = 8'b01101100; //This data wil be send from UART

//--------------------- Uart TX ----------------------------------
uart_tx tx(reset,txclk,ld_tx_data,tx_data,tx_enable,tx_out,tx_empty);
uart_clk clk_tx(clk,txclk);

endmodule
