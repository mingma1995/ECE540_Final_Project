`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang.
// 
// Create Date: 03/16/2019 04:39:45 PM
// Design Name: 
// Module Name: Colorizer
// Project Name: ECE 540 Final Project: World of Tank
// Target Devices: 
// Tool Versions: 
// Description: give the pixel color to the every frame
//            
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module Colorizer(
    input [11:0] pixel_column, //pixel_column signal from dtg module
    input [11:0] pixel_row,    //pixel_row signal from dtg module
    input video_on,            //The signal to show video on
    input [1:0] world_pixel,   //World map pixel
    input [1:0] icon,          //Green tank icon flag 
    input [11:0]icon_c,        //12 bit green tank icon color
    input [1:0] icon_1,        // red tank icon flag 
    input [11:0] icon_c_1,     //12 bit red tank icon color
    output reg [3:0]red,         
    output reg [3:0]green,
    output reg [3:0]blue,
    input bul, bul2,            // bullet flag
    input [11:0] bul_color,bul_color2, //bullet color
    input clock,
    input [11:0] brick_color,  //the color of brick
    input enable1,enable2,enable3,enable4,enable5,      // enable to control tranforming of fram
    input [1:0] His1, His2, His3,  // The signal to determine the which tank to be placed in the history list 
    input mon1, mon2, mon3,        // Monstor flag
    input [11:0] mon1_color, mon2_color, mon3_color, // monstor color
    input mon_b1, mon_b2, mon_b3,  //Monstor's bullet flag
    input [11:0] mon1_bcolor, mon2_bcolor, mon3_bcolor // monstor 's bullet color
    );
    reg [16:0]addr;          
    reg [8:0] addr_r,addr_c;
    wire [11:0] Initial;            // The initial picture
    wire [1:0] window,History,tank_w;    
	wire enable_win, enable_tank;
	assign enable_win=enable3|enable4;     // Enable 3 and enable 4 control the winner frame display
	assign enable_tank=enable3|enable4|enable5;        // Enable 345 need to read the tank's shape
    
    Initial_begin Initial_begin ( .clka(clock), .ena(enable1), .addra(addr), .douta(Initial));      //Initial Frame rom
    tank_win tank_win (.clka(clock), .ena(enable_win),.addra(addr),.douta(window));      //The winner Frame
    history history (.clka(clock), .ena(enable5),.addra(addr),.douta(History));     //The History Frame
	tank tankwin ( .clka(clock), .ena(enable_tank), .addra(addr), .douta(tank_w));         //Tank
    
    
always @ (posedge clock)  begin
if (video_on == 1'b0)                   //if the video is off, nothing will be shown
{red, green, blue} <= 12'h000;
else if ((enable2==1'b1)&&(~(mon1||mon2||mon3||mon_b1||mon_b2||mon_b3)))begin       // When enable2 set, the game frame shows up 
case({world_pixel,icon,icon_1,bul,bul2})                //case statement start
8'b00010000: {red, green, blue} <= icon_c;  //When the green tank's flag has been set, give the color of green tank
8'b01010000: {red, green, blue} <= icon_c;
8'b10010000: {red, green, blue} <= icon_c;
8'b11010000: {red, green, blue} <= icon_c;

8'b00000100: {red, green, blue} <= icon_c_1;   //When the red tank's flag has been set, give the color of red tank
8'b01000100: {red, green, blue} <= icon_c_1;
8'b10000100: {red, green, blue} <= icon_c_1;
8'b11000100: {red, green, blue} <= icon_c_1;

8'b00010100: {red, green, blue} <= icon_c;    //When the green tank's flag and red tank's flag have been set, give the color of green tank
8'b01010100: {red, green, blue} <= icon_c;
8'b10010100: {red, green, blue} <= icon_c;
8'b11010100: {red, green, blue} <= icon_c;

8'b00000000: {red, green, blue} <= 12'hFFF;  //Background
8'b01000000: {red, green, blue} <= 12'hF0F;  //Red Base
8'b10000000: {red, green, blue} <= brick_color;  //Give the brick color to the obstacles
8'b11000000: {red, green, blue} <= 12'hF0F;  //Green base

8'b00010010: {red, green, blue} <= bul_color;  //When the green bullet flag has been set, give the color of green bullet
8'b01010010: {red, green, blue} <= bul_color;   
8'b10010010: {red, green, blue} <= bul_color;
8'b11010010: {red, green, blue} <= bul_color;

8'b00000110: {red, green, blue} <= bul_color;  
8'b01000110: {red, green, blue} <= bul_color;
8'b10000110: {red, green, blue} <= bul_color;
8'b11000110: {red, green, blue} <= bul_color;

8'b00000010: {red, green, blue} <= bul_color; 
8'b01000010: {red, green, blue} <= bul_color;  
8'b10000010: {red, green, blue} <= bul_color;  
8'b11000010: {red, green, blue} <= bul_color;  

8'b00010001: {red, green, blue} <= bul_color2;  //When the red bullet flag has been set, give the color of red bullet
8'b01010001: {red, green, blue} <= bul_color2;
8'b10010001: {red, green, blue} <= bul_color2;
8'b11010001: {red, green, blue} <= bul_color2;

8'b00000101: {red, green, blue} <= bul_color2;  
8'b01000101: {red, green, blue} <= bul_color2;
8'b10000101: {red, green, blue} <= bul_color2;
8'b11000101: {red, green, blue} <= bul_color2;

8'b00000001: {red, green, blue} <= bul_color2;  
8'b01000001: {red, green, blue} <= bul_color2; 
8'b10000001: {red, green, blue} <= bul_color2; 
8'b11000001: {red, green, blue} <= bul_color2;  

8'b00010011: {red, green, blue} <= bul_color;   //When the green bullet's flag and red bullet's flag have been set, give the color of green bullet
8'b01010011: {red, green, blue} <= bul_color;
8'b10010011: {red, green, blue} <= bul_color;
8'b11010011: {red, green, blue} <= bul_color;

8'b00000111: {red, green, blue} <= bul_color;  
8'b01000111: {red, green, blue} <= bul_color;
8'b10000111: {red, green, blue} <= bul_color;
8'b11000111: {red, green, blue} <= bul_color;

8'b00000011: {red, green, blue} <= bul_color;  
8'b01000011: {red, green, blue} <= bul_color;  
8'b10000011: {red, green, blue} <= bul_color; 
8'b11000011: {red, green, blue} <= bul_color;  

default: {red, green, blue} <= 12'hFFF; 
endcase
end

else if ((enable2==1'b1)&&((mon1||mon2||mon3||mon_b1||mon_b2||mon_b3)))begin    //when the flag about monster sets, show the color about the monstor
case ({mon1,mon2,mon3,mon_b1,mon_b2,mon_b3})
6'b000000:	{red, green, blue} <= 12'hFFF;
6'b100000:	{red, green, blue} <= mon1_color;
6'b010000:	{red, green, blue} <= mon2_color;
6'b001000:	{red, green, blue} <= mon3_color;
6'b000100:	{red, green, blue} <= mon1_bcolor;
6'b000010:	{red, green, blue} <= mon2_bcolor;
6'b000001:	{red, green, blue} <= mon3_bcolor;
default: {red, green, blue} <= 12'hFFF;
endcase
end

else if ((enable1 == 1'b1))begin        //If the enable has been set, show the initial frame
addr_r <= pixel_row/3'd3;
addr_c <= pixel_column/2'd2;
addr <= {addr_r,addr_c};
{red, green, blue} <= Initial;
end

// When the enable 3 has been set, show the winner frame with green tank
else if ((enable3 == 1'b1)&&(pixel_row>=11'd384)&&(pixel_row<=11'd703)&&(pixel_column>=11'd352)&&(pixel_column<=11'd671))begin      //set tank
addr_r <= (pixel_row-11'd384)/5'd10;
addr_c <= (pixel_column-11'd352)/5'd10;
addr <= (addr_r * 8'd32)+addr_c;
case(tank_w)          //green      
        2'd0: {red, green, blue} <= 12'h005; //blue
        2'd1: {red, green, blue} <= 12'h000; //black
        2'd2: {red, green, blue} <= 12'h0a5; //green
        2'd3: {red, green, blue} <= 12'h025; //gray
default: {red, green, blue} <= 12'h005;  //background
endcase
end

else if (enable3 == 1'b1)begin          // set word picture
addr_r <= pixel_row/3'd6;
addr_c <= pixel_column/4'd8;
addr <= (addr_r * 8'd128)+addr_c;
case(window)                //case statement start
2'b00: {red, green, blue} <= 12'hFFF; 
2'b10: {red, green, blue} <= 12'h005;
2'b01: {red, green, blue} <= 12'h005;
default: {red, green, blue} <= 12'h005;  
endcase
end
// When the enable 4 has been set, show the winner frame with red tank
else if ((enable4 == 1'b1)&&(pixel_row>=11'd384)&&(pixel_row<=11'd703)&&(pixel_column>=11'd352)&&(pixel_column<=11'd671))begin  // set tank
addr_r <= (pixel_row-11'd384)/5'd10;
addr_c <= (pixel_column-11'd352)/5'd10;
addr <= (addr_r * 8'd32)+addr_c;
case(tank_w)           //red     
        2'd0: {red, green, blue} <= 12'h005; // blue
        2'd1: {red, green, blue} <= 12'h000;  //black
        2'd2: {red, green, blue} <= 12'ha13;  // red
        2'd3: {red, green, blue} <= 12'h025; //gray
default: {red, green, blue} <= 12'h005;  //background
endcase
end


else if (enable4 == 1'b1)begin      //set word picture
addr_r <= pixel_row/3'd6;
addr_c <= pixel_column/4'd8;
addr <= (addr_r * 8'd128)+addr_c;
case(window)                //case statement start
2'b00: {red, green, blue} <= 12'hFFF;  
2'b10: {red, green, blue} <= 12'h005;
2'b01: {red, green, blue} <= 12'h005;
default: {red, green, blue} <= 12'h005;  
endcase
end
// When the enable 5 has been set, show the History frame with winner tank
else if ((enable5 == 1'b1)&&(pixel_row>=11'd200)&&(pixel_row<=11'd295)&&(pixel_column>=11'd560)&&(pixel_column<=11'd655))begin  //Set tank
case (His1)     // The new history
2'b00: {red, green, blue} <= 12'h005;       //show the background
2'b01: begin
	addr_r <= (pixel_row-11'd200)/3'd3; 
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //show green tank      
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'h0a5;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end
2'b10: begin
	addr_r <= (pixel_row-11'd200)/3'd3;
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //red tank     
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'ha13;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end	
2'b11: {red, green, blue} <= 12'h005;
endcase
end

else if ((enable5 == 1'b1)&&(pixel_row>=11'd325)&&(pixel_row<=11'd420)&&(pixel_column>=11'd560)&&(pixel_column<=11'd655))begin
case (His2)     //The last history
2'b00: {red, green, blue} <= 12'h005;
2'b01: begin
	addr_r <= (pixel_row-11'd325)/3'd3;
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //green   tank   
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'h0a5;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end
2'b10: begin
	addr_r <= (pixel_row-11'd325)/3'd3;
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //red     tank 
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'ha13;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end	
2'b11: {red, green, blue} <= 12'h005;
endcase
end

else if ((enable5 == 1'b1)&&(pixel_row>=11'd500)&&(pixel_row<=11'd595)&&(pixel_column>=11'd560)&&(pixel_column<=11'd655))begin
case (His3) //show the last last history tank 
2'b00: {red, green, blue} <= 12'h005;
2'b01: begin
	addr_r <= (pixel_row-11'd500)/3'd3;
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //green     tank 
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'h0a5;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end
2'b10: begin
	addr_r <= (pixel_row-11'd500)/3'd3;
	addr_c <= (pixel_column-11'd560)/3'd3;
	addr <= (addr_r * 8'd32)+addr_c;
	case(tank_w)          //red     tank 
        2'd0: {red, green, blue} <= 12'h005;
        2'd1: {red, green, blue} <= 12'h000;
        2'd2: {red, green, blue} <= 12'ha13;
        2'd3: {red, green, blue} <= 12'h025;
	default: {red, green, blue} <= 12'h005; 
	endcase
	end	
2'b11: {red, green, blue} <= 12'h005;
endcase
end
// set word part
else if (enable5 == 1'b1)begin
addr_r <=pixel_row/3'd6;
addr_c <=pixel_column/4'd8;
addr <= (addr_r * 8'd128)+addr_c;
case(History)                //case statement start
2'b00: {red, green, blue} <= 12'hFFF;  //Icon color 1, we change xx into 00,01,10,11
2'b10: {red, green, blue} <= 12'h005;
2'b01: {red, green, blue} <= 12'h005;
default: {red, green, blue} <= 12'h005;  
endcase
end

else begin
{red, green, blue} <= 12'h000; 
end

end
endmodule