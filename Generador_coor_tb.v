`timescale  1 ns / 1 ps
module Control_VGA_tb();

reg clk, reset;
wire h_sync, v_sync, video_on_out;
wire [9:0] pixel_x;
wire [8:0] pixel_y;
reg [2:0] swcolors;
wire [2:0] colors_out;
wire [9:0] a;
wire [9:0] b;

Control_VGA test (.clk(clk),.reset(reset),.h_sync(h_sync),.v_sync(v_sync),.video_on_out(video_on_out),.swcolors(swcolors),.colors_out(colors_out),.clk_out(clk_out));

initial 
    begin
    clk = 0;
    swcolors = 3'b101;
    #5 reset = 1;
    #5 reset = 0;    
    end
always
    begin
        #5 clk = ~clk;
    end
endmodule   