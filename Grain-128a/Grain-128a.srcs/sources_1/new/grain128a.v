`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: EE20B007 EE20B032 EE20B051
// Create Date: 23.04.2023 20:52:53
// Module Name: grain128
// Project Name: Grain - 128
//////////////////////////////////////////////////////////////////////////////////


module grain128a 
(
    input clk,
    input rst,
    input msg,
    input [127:0] key,
    input [95:0] iv,
    input gen,
    output reg rdy,
    output reg z,
    output [31:0] tag
);

localparam INIT = 0;
localparam AUTH_INIT = 1;
localparam RDY  = 2;
localparam RDY_AUTH = 3;

reg [127:0] s;            //LFSR
reg [127:0] b;            //NFSR
reg [1:0]curr_state = INIT;
reg [1:0]next_state = INIT;
reg [7:0] cnt  = 0;              //Counter
reg m          = 1;              //Mode
wire f0,g0,h0;
wire f1,g1,h1;
wire nfb0, lfb0;
wire nfb1, lfb1;
wire mo;                        //MUX out
wire y0,y1;                         //y
reg [31:0] a = 0;
reg [31:0] r = 0;

feedback_linear FB_L0 (s[0], s[7], s[38], s[70], s[81], s[96], f0);
feedback_non_linear FB_N0 (b[0], b[26], b[56], b[91], b[96], b[3], b[67], b[11], b[13], b[17], b[18], b[27], b[59], b[40], b[48], b[61], b[65], b[68], b[84],b[88],b[92],b[93],b[95],b[22],b[24],b[25],b[70],b[78],b[82],g0);
h_x HX0 (s[8], s[13], s[20], s[42], s[60], s[79], s[94], b[12], b[95], h0);

assign mo  = m & y0;
assign lfb0 = f0 ^ mo;
assign nfb0 = g0 ^ mo ^ s[0];
assign y0   = h0 ^ s[93] ^ b[2] ^ b[15] ^ b[36] ^ b[45] ^ b[64] ^ b[73] ^ b[89];



feedback_linear FB_L1 (s[1], s[8], s[39], s[71], s[82], s[97], f1);
feedback_non_linear FB_N1 (b[1], b[27], b[57], b[92], b[97], b[4], b[68], b[12], b[14], b[18], b[19], b[28], b[60], b[41], b[49], b[62], b[66], b[69], b[85],b[89],b[93],b[94],b[96],b[23],b[25],b[26],b[71],b[79],b[83], g1);
h_x HX1 (s[9], s[14], s[21], s[43], s[61], s[80], s[95], b[13], b[96], h1);

assign lfb1 = f1;
assign nfb1 = g1 ^ s[1];
assign y1   = h1 ^ s[94] ^ b[3] ^ b[16] ^ b[37] ^ b[46] ^ b[65] ^ b[74] ^ b[90];





assign tag = a;




always @(posedge clk) begin
    if (rst) begin
        curr_state <= INIT;
        s          <= {{32{1'b1}},iv};
        b          <= key;
        cnt        <= 0;
        z          <= 0;
    end
    else begin
        curr_state <= next_state;
    end
    
    case (curr_state)
        INIT : begin
            m   <= 1;
            rdy <= 0;
            if (cnt == 255) begin
                next_state <= AUTH_INIT;
            end
            else begin
                next_state <= INIT;
                cnt        <= cnt + 1;
            end
            s = {lfb0, s[127:1]};
            b = {nfb0, b[127:1]};
        end 
        AUTH_INIT: begin
            cnt = 0;
            m   <= 0;
            if (iv[0]) begin
                if (cnt<64) begin
                    if (cnt<32)
                        a[cnt] <= y0;

                    else if (cnt<64)
                        r[cnt-32] <= y0;
                    
                    cnt <= cnt+1;
                    end
                else begin   
                    next_state <= RDY_AUTH;
                end
                s = {lfb0, s[127:1]};
                b = {nfb0, b[127:1]};
            end
            else begin
                next_state <= RDY;
            end
        end
        RDY : begin
            rdy <= 1;                
            if (gen) begin
                z <= y0;
                s = {lfb0, s[127:1]};
                b = {nfb0, b[127:1]};   
            end
            next_state <= RDY;
        end
        RDY_AUTH : begin
            rdy <= 1;
            if (gen) begin
                z <= y0;
                a <= a ^ ({32{msg}}&r);
                r <= {y1,r[31:1]};
                s = {lfb1,lfb0, s[127:2]};
                b = {lfb1,nfb0, b[127:2]};
            end
            next_state <= RDY_AUTH;
        end   
    endcase
end
endmodule
