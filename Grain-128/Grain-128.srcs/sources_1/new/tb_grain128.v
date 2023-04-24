`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 23:53:16
// Module Name: tb_grain128
// Project Name: Grain - 128
//////////////////////////////////////////////////////////////////////////////////


module tb_grain128
();

reg clk = 0;
reg rst = 0;
reg gen = 0;
reg [127:0] key = 0;
reg [95:0] iv = 0;
reg [127:0] keystream = 0;
reg [6:0] len = 0;

wire rdy,z;
wire [31:0] tag;

grain128 DUT (
    .clk(clk),
    .rst(rst),
    .key(key),
    .iv(iv),
    .gen(gen),
    .rdy(rdy),
    .z(z),
    .tag(tag)
);

initial begin
    forever begin
        #5 clk = ~clk;
    end
end


initial begin
    #10 rst = 1;
    #10 rst = 0;
end

always @(posedge clk ) begin
    if (rdy == 1) begin
        if (len == 127) begin
            gen = 0;
        end
        else begin
            gen = 1;
            keystream = {z,keystream[127:1]};
            len = len + 1;
        end
    end
    
end
endmodule
