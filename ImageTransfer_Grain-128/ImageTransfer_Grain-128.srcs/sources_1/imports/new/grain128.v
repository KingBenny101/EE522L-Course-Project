`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 20:52:53
// Module Name: grain128
// Project Name: Grain - 128
//////////////////////////////////////////////////////////////////////////////////


module grain128 
(
    input clk,
    input rst,
    input [127:0] key,
    input [95:0] iv,
    input gen,
    output reg rdy,
    output z
);

localparam INIT = 0;
localparam RDY  = 1;

reg [127:0] s;            //LFSR
reg [127:0] b;            //NFSR
reg curr_state = INIT;
reg next_state = INIT;
reg [7:0] cnt  = 0;       //Counter
reg m          = 1;       //Mode

wire f,g,h;
wire nfb, lfb;
wire mo;                  //MUX out
wire y;                   //y
wire [127:0] key_in;      //Flipped key
wire [95:0] iv_in;        //Flipped iv

feedback_linear FB_L (s[0], s[7], s[38], s[70], s[81], s[96], f);
feedback_non_linear FB_N (b[0], b[26], b[56], b[91], b[96], b[3], b[67], b[11], b[13], b[17], b[18], b[27], b[59], b[40], b[48], b[61], b[65], b[68], b[84], g);
h_x HX (s[8], s[13], s[20], s[42], s[60], s[79], s[95], b[12], b[95], h);

assign mo  = m & y;
assign lfb = f ^ mo;
assign nfb = g ^ mo ^ s[0];
assign y   = h ^ s[93] ^ b[2] ^ b[15] ^ b[36] ^ b[45] ^ b[64] ^ b[73] ^ b[89];
assign z   = y;


generate
    genvar i;
    for (i = 0; i < 96; i = i + 1) begin
        assign iv_in[i] = iv[95-i];
    end
endgenerate

generate
    genvar j;
    for(j = 0; j < 128; j = j + 1) begin
        assign key_in[j] = key[127-j];
    end
endgenerate

always @(posedge clk) begin
    if (rst) begin
        curr_state <= INIT;
        s          <= {{32{1'b1}},iv_in};
        b          <= key_in;
        cnt        <= 0;
    end
    else begin
        curr_state <= next_state;
    end
    
    case (curr_state)
        INIT : begin
            m   <= 1;
            rdy <= 0;
            if (cnt == 255) begin
                next_state <= RDY;
            end
            else begin
                next_state <= INIT;
                cnt        <= cnt + 1;
            end
            s = {lfb, s[127:1]};
            b = {nfb, b[127:1]};
        end
        RDY : begin
            rdy <= 1;
            m   <= 0;

            if (gen && rdy) begin
                s = {lfb, s[127:1]};
                b = {nfb, b[127:1]};
            end
            next_state <= RDY;
        end
    endcase
end
endmodule
