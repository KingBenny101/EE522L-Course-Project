`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 23:53:16
// Module Name: tb_grain128
// Project Name: Grain - 128
//////////////////////////////////////////////////////////////////////////////////


module tb_grain128a ();
    
    reg clk      = 0;
    reg rst      = 0;
    reg gen      = 0;
    reg [1:0]msg = 2'b10;
    
    // reg [127:0] key = 128'h0fedcba987654321fedcba9876543210;
    // reg [95:0] iv   = 96'h87654321fedcba9876543210;
    
    // reg [127:0] key = 128'h1032547698badcfe21436587a9cbed0f;
    // reg [95:0] iv   = 96'h1032547698badcfe21436587;
    
    // reg [127:0] key = 128'hf0debc9a78563412efcdab8967452301;
    // reg [95:0] iv   = 96'h78563412efcdab8967452301;
    
    
    //reg [127:0] key = 128'h0123456789abcdef123456789abcdef0;
    ///reg [95:0] iv  = 96'h0123456789abcdef12345678;
    
    
    reg [127:0] key = 128'h0;
    reg [95:0] iv   = 96'h0;
    
    
    localparam N = 320;
    reg [N-1:0] keystream = 0;
    integer len         = 0;
    
    reg [127:0] key_in;
    reg [95:0] iv_in;
    

    reg m;
    wire rdy,z;
    wire [31:0] tag;
    
    grain128a DUT (
    .clk(clk),
    .rst(rst),
    .key(key_in),
    .iv(iv_in),
    .msg(m),
    .gen(gen),
    .rdy(rdy),
    .z(z),
    .tag(tag)
    );
    
    integer i = 0;
    
    initial begin
        for(i = 0;i<128;i = i+1) begin
            key_in[i] = key[127-i];
        end
        for(i = 0;i<96;i = i+1) begin
            iv_in[i] = iv[95-i];
        end
        forever begin
            #5 clk = ~clk;
        end
    end
    
    
    initial begin
        #10 rst = 1;
        #10 rst = 0;
        iv[95]   = 0;
        m = 0;
    end
    
    always @(posedge clk) begin
        if (rdy == 1) begin
            if (len > N) begin
                gen = 0;
            end
            else begin
                gen          = 1;
                keystream    = {keystream[N-1:0],z};
                len          = len + 1;
            end
        end      
    end
endmodule
