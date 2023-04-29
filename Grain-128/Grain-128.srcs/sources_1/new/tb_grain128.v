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

// reg [127:0] key = 128'h0fedcba987654321fedcba9876543210;
// reg [95:0] iv = 96'h87654321fedcba9876543210;

// reg [127:0] key = 128'h1032547698badcfe21436587a9cbed0f;
// reg [95:0] iv = 96'h1032547698badcfe21436587;

// reg [127:0] key = 128'hf0debc9a78563412efcdab8967452301;
// reg [95:0] iv   =  96'h78563412efcdab8967452301;


reg [127:0] key = 128'h0123456789abcdef123456789abcdef0;
reg [95:0] iv   =  96'h0123456789abcdef12345678;


// reg [127:0] key = 128'h0;
// reg [95:0] iv = 96'h0;


reg [127:0] keystream = 0;
reg [7:0] len = 0;
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
    #10 rst = 1;
    #10 rst = 0;
end

initial begin 
    forever begin
        #5 clk = ~clk;
    end
end

always @(posedge clk ) begin
    if (rdy == 1) begin
        if (len > 128) begin
            gen = 0;
        end
        else begin
            gen = 1;
            // keystream = {z,keystream[127:1]};
            keystream = {keystream[126:0],z};
            len = len + 1;
        end
    end
    
end
endmodule
