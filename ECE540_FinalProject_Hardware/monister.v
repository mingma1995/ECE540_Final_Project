`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang.
// 
// Create Date: 03/20/2019 01:16:54 AM
// Design Name: 
// Module Name: monsitor
// Project Name: ECE 540 Final Project: World of Tank
// Target Devices: 
// Tool Versions: 
// Description: The module is to set monster with the fixed position and could shoot bullet
// The module uses the same mothod with icon module and bullet module, just give the constant number to the starting coordinate
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module monister(     
	input [11:0] pixel_column,     //pixel_column signal from dtg module
    input [11:0] pixel_row,        //pixel_row signal from dtg module
	input [11:0] mon_addr_r,       //the row address of monster location      
	input [11:0] mon_addr_c,       //the col address of monster location
	input [2:0]	 mon_ori,          //the orientation of the monster 
    input clock,
    input reset,
    input biu,                      // shoot bullent shoot signal
    output reg [1:0] mon,           // the monster icon flag
    output reg [11:0]mon_c,         // 12-bit the monster icon color (RGB  CODE) 
	input [1:0]icon_green, icon_red,// green tank icon flag and red tank icon
	input [1:0] world_pixel,        //world map pixel color
	output reg mon_b,               //monster's bullet flag
    output reg [11:0]mon_b_c,       //12-bit monster's bullet color code (RGB CODE)
    output reg burst_g,burst_r      //brust_g is to show the green tank is hit by the monster; brust_r is to show the red tank is hit by the monster	
);
 wire [1:0] image_rom ;
 reg [4:0] addr_r;
 reg [4:0] addr_c;
 reg [9:0] addr;
 
 reg [11:0] image_color_rom ;
 tank mon_tank ( .clka(clock), .ena(1), .addra(addr), .douta(image_rom));
    always @ (*) begin
    case (image_rom)
        2'd0: image_color_rom = 12'hFFF;
        2'd1: image_color_rom = 12'h000;
        2'd2: image_color_rom = 12'h72D;    //purple
        2'd3: image_color_rom = 12'h025;
    endcase
    end
 
 always @(posedge clock) begin
    if((pixel_column >= mon_addr_c) && (pixel_column <= (mon_addr_c + 6'd31)) && (pixel_row >= mon_addr_r) && (pixel_row <= (mon_addr_r + 6'd31)))
        begin
        case(mon_ori)
      3'b000: begin  //North
                addr_r <= pixel_row-mon_addr_r;
                addr_c <= pixel_column-mon_addr_c;
                addr <= {addr_r,addr_c};
                mon_c <= image_color_rom;
                mon <= (mon_c==12'hfff)?1'b0:1'b1;
                end
    
        3'b010: begin  //East
                addr_r <= pixel_row-mon_addr_r;
                addr_c <= 5'd31-(pixel_column-mon_addr_c);
                addr <= {addr_c,addr_r};
                mon_c <= image_color_rom;
                mon <= (mon_c==12'hfff)?1'b0:1'b1;
                end
    
        3'b100: begin  //South
                addr_r <= 5'd31-(pixel_row-mon_addr_r);
                addr_c <= 5'd31-(pixel_column-mon_addr_c);
                addr <= {addr_r,addr_c};
                mon_c <= image_color_rom;
                mon <= (mon_c==12'hfff)?1'b0:1'b1;
                end
    
        3'b110: begin  //West
                addr_r <= 5'd31-(pixel_row-mon_addr_r);
                addr_c <= pixel_column-mon_addr_c;
                addr <= {addr_c,addr_r};
                mon_c <= image_color_rom;
                mon <= (mon_c==12'hfff)?1'b0:1'b1;
                end
        endcase
        end
    else 
        mon <= 1'b0; //icon is transparent if icon is out of specific range.
    end
	

reg [11:0] pixelr_bul, pixelc_bul;
reg [31:0] counter;
reg [31:0]times;
reg [11:0] row, col;
reg stop;


always @(posedge clock) begin
if (!reset)begin
stop <= 1'b1;
burst_g <= 1'b0;
burst_r <= 1'b0;
end
else if (biu==1'b1) begin
stop <= 1'b0;
end 
else if ((mon_b == 2'b1) && (world_pixel == 2'b10)) begin
stop <= 1'b1;
end
else if ((mon_b == 2'b1) && (world_pixel == 2'b11))begin
stop <= 1'b1;
end
else if ((mon_b == 2'b1) && (icon_green == 2'b01))begin
burst_g <= 1'b1;
stop <= 1'b1;
end
else if ((mon_b == 2'b1) && (icon_red == 2'b01))begin
stop <= 1'b1;
burst_r <= 1'b1;
end
else begin
stop <= stop;
burst_g <= 1'b0;
burst_r <= 1'b0;
end
end


always@ (posedge clock) begin
if ((biu==1'b1)&&(stop==1'b1))begin
case (mon_ori)
	    3'b000:  begin //North
	    pixelr_bul<=mon_addr_r-24 ;
	    pixelc_bul<=mon_addr_c +6 ;
		row <= mon_addr_r-24 ;
        col <= mon_addr_c +6 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
        3'b010:  begin//East
        pixelr_bul <= mon_addr_r+6 ;
        pixelc_bul <= mon_addr_c +36 ;
	    row <= mon_addr_r+6 ;
        col <= mon_addr_c +36 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
        3'b100:   begin//South
        pixelr_bul <= mon_addr_r+36 ;
        pixelc_bul <= mon_addr_c +6 ;
		row <= mon_addr_r+36 ;
        col <= mon_addr_c +6 ;
        times <= 1'b0;
        counter <= 1'b0;
		end		       
        3'b110:   begin//West
		pixelr_bul <= mon_addr_r+6 ;
        pixelc_bul <= mon_addr_c -24 ;
		row <= mon_addr_r+6 ;
        col <= mon_addr_c -24 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
endcase
end
else if ((counter==32'h1FFFFF) && (stop==1'b0) )begin
case (mon_ori)
	    3'b000:  begin //North
		pixelr_bul <= row-(6'd10*times);
		pixelc_bul <= col;
		counter <= 1'b0;
		times <= times+1'b1;
		end
        3'b010:  begin//East
		pixelc_bul <= col+(6'd10*times);
		pixelr_bul <= row;
		counter <= 1'b0;
		times <= times+1'b1;
		end
        3'b100:   begin//South
		pixelr_bul <= row+(6'd10*times);
		pixelc_bul <= col;
		counter <= 1'b0;
		times <= times+1'b1;
		end		       
        3'b110:   begin//West
		pixelc_bul <= col-(6'd10*times);
		pixelr_bul <= row;
		counter <= 1'b0;
		times <= times+1'b1;
		end
	    default: begin
        pixelr_bul <= pixelr_bul;
        pixelc_bul <= pixelc_bul;
        counter <= 1'b0;
        times <= times+1'b1;
	    end
endcase
end
else begin
pixelr_bul <= pixelr_bul;
pixelc_bul <= pixelc_bul;
counter <= counter+1'b1;
times <= times;
row <= row;
col <= col;
end
end


 

wire [11:0] mon_b_rom ; //rom used to store the pixel data of icon which has the east orientation
reg [11:0] addr_b;
reg [5:0] addr_rb,addr_cb;
  
bullet_up    mon_b_up1 ( .clka(clock), .ena(~stop), .addra(addr_b), .douta (mon_b_rom));  


always @(posedge clock) begin
if((stop == 1'b0) &&(pixel_column >= pixelc_bul) && (pixel_column <= pixelc_bul + 6'd19) && (pixel_row >= pixelr_bul) && (pixel_row <= pixelr_bul + 6'd19))
    begin
    case(mon_ori)
    3'b000: begin  //North
            addr_rb <= pixel_row-pixelr_bul;
            addr_cb <= pixel_column-pixelc_bul;
            addr_b <= addr_rb * 5'd20+addr_cb;
            mon_b_c <= mon_b_rom;
            mon_b <= (mon_b_rom==12'hfff)?1'b0:1'b1;
            end

    3'b010: begin  //East
            addr_rb <= pixel_row-pixelr_bul;
            addr_cb <= 5'd19-(pixel_column-pixelc_bul);
            addr_b <= addr_cb * 5'd20+addr_rb;
            mon_b_c <= mon_b_rom;
            mon_b <= (mon_b_rom==12'hfff)?1'b0:1'b1;
            end

    3'b100: begin  //South
            addr_rb <= 5'd19-(pixel_row-pixelr_bul);
            addr_cb <= 5'd19-(pixel_column-pixelc_bul);
            addr_b <= addr_rb * 5'd20+addr_cb;
            mon_b_c <= mon_b_rom;
            mon_b <= (mon_b_rom==12'hfff)?1'b0:1'b1;
            end

    3'b110: begin  //West
            addr_rb <= 5'd19-(pixel_row-pixelr_bul);
            addr_cb <= pixel_column-pixelc_bul;
            addr_b <= addr_cb * 5'd20+addr_rb;
            mon_b_c <= mon_b_rom;
            mon_b <= (mon_b_rom==12'hfff)?1'b0:1'b1;
            end
    endcase
    end
else 
    mon_b <= 1'b0; //icon is transparent if icon is out of specific range.
end 

       
    endmodule