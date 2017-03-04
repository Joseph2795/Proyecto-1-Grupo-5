`timescale  1 ns / 1 ps

module Control_VGA(clk, reset, h_sync, v_sync, video_on_out, swcolors, colors_out, clk_out);

input clk, reset, swcolors;
output h_sync, v_sync, video_on_out, colors_out, clk_out;

reg [1:0] r_reg;
wire [1:0] r_nxt;
reg clk_track;
wire [8:0] pixel_y;
wire [9:0] pixel_x;
reg [9:0] counter_x;
reg [8:0] counter_y;
wire clk_out;
reg [9:0] counter_x_sync;
reg [9:0] counter_y_sync;
reg v_sync_buff, h_sync_buff, video_on_buff, video_on;
wire v_sync, h_sync, video_on_out;
wire [2:0] swcolors;
wire clk_cnt;
wire [2:0] colors_out;
reg [6:0] char_addr;
wire [3:0] row_addr;
wire [10:0] rom_addr;
wire [2:0] bit_addr;
wire [7:0] font_word;
reg font_bit;
reg [2:0] colors;
wire [9:0] a;
wire [9:0] b;
reg comp;

always @(posedge clk or posedge reset)
 
begin
  if (reset)
     begin
        r_reg <= 2'b0;
	    clk_track <= 1'b0;  
     end
  else
  begin 
      if (r_nxt == 2'b10)
           begin
             r_reg <= 0;
             clk_track <= ~clk_track;
             comp <= ~clk_track;
           end
      else
      begin 
          r_reg <= r_nxt;
          comp <= 0;
      end
    end
end

assign r_nxt = r_reg+1;   	      
assign clk_out = clk_track;
assign clk_cnt = comp;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        counter_x_sync <= 10'b0;
        counter_y_sync <= 10'b0; 
        video_on <= 1'b0;
        h_sync_buff <= 1'b1;
        v_sync_buff <= 1'b1;   	      
    end
    else
    begin
        if (clk_out && clk_cnt)	
        begin
            counter_x_sync <= counter_x_sync + 1;
            if (counter_x_sync == 799)
            begin
                if (counter_y_sync == 524)
                begin
                    counter_y_sync <= 10'b0;
                    counter_x_sync <= 10'b0;
                end
                else
                begin
                    counter_y_sync <= counter_y_sync + 1;
                    counter_x_sync <= 10'b0;   
                end         
            end     
        end
        
    end
end
 
assign a = counter_x_sync;
assign b = counter_y_sync;
assign h_sync = ~(counter_x_sync >= 703 && counter_x_sync <= 799);
assign v_sync = ~(counter_y_sync > 522 && counter_y_sync <= 524);  
assign video_on_out = ((counter_y_sync >= 33 && counter_y_sync <= 512)&&(counter_x_sync >= 48 && counter_x_sync <= 687)); 

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        counter_x <= 10'b0;
        counter_y <= 9'b0;   
    end
    else 
    begin
        if (clk_out && video_on_out && clk_cnt)
        begin
            counter_x = counter_x + 1;
            if (counter_x == 640)
            begin
                if (counter_y== 479)
                begin
                    counter_y <= 10'b0;
                    counter_x <= 10'b0;
                end
                else
                begin
                    counter_y <= counter_y+ 1;
                    counter_x <= 10'b0;   
                end 
            end               
        end
    end 
end

assign pixel_x = counter_x;
assign pixel_y = counter_y;

//always @(posedge reset or posedge clk)
//begin
//if (reset)
//begin
//    cnt1 <= 0;
//end
//else
//begin
//    cnt1 <= ~cnt1;
//end
//end

ROM font_unit(
.clk(clk), 
.addr(rom_addr), 
.data(font_word)
);

assign row_addr=pixel_y[3:0];
assign rom_addr={char_addr,row_addr};
assign bit_addr=pixel_x[2:0];

always @(pixel_x or pixel_y)
begin
    if (pixel_x[9:3] == 7'b0000101 && pixel_y[8:4] == 5'b00011)
    begin
        char_addr = 7'h4a;//J
    end
    else if (pixel_x[9:3] == 7'b0000101 && pixel_y[8:4] == 5'b00101)
    begin
        char_addr = 7'h45;//E
    end
    else if (pixel_x[9:3] == 7'b0000101 && pixel_y[8:4] == 5'b00111)
    begin
        char_addr = 7'h45;//E
    end
    else
    begin
        char_addr=7'd00;    
    end
end
always @(pixel_x or bit_addr or font_bit or font_word)
begin
    case (bit_addr)
    3'b000: font_bit <= font_word[7];
    3'b001: font_bit <= font_word[6];
    3'b010: font_bit <= font_word[5];
    3'b011: font_bit <= font_word[4];
    3'b100: font_bit <= font_word[3];
    3'b101: font_bit <= font_word[2];
    3'b110: font_bit <= font_word[1];
    3'b111: font_bit <= font_word[0];
    endcase  
end
always @(pixel_x or video_on_out or font_bit or swcolors)
if (video_on_out == 0)
begin
    colors <= 3'b000;
end
else
begin
if (font_bit==0)
begin
    colors <= 3'b000;
end
else
begin
    colors <= swcolors;
end
end

assign colors_out = colors;

endmodule 
