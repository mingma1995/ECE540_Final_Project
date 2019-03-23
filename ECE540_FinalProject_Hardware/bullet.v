`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang.
// 
// Create Date: 03/16/2019 04:39:45 PM
// Design Name: 
// Module Name: bullet
// Project Name: ECE 540 Final Project: World of Tank
// Target Devices: 
// Tool Versions: 
// Description: This module is used to determine where or when to display bullet icon on the monitor.
//              The bullet is 20*20
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bullet(              //shot bullet
    input [11:0]pixel_row,          //pixel_column signal from dtg module
    input [11:0]pixel_column,       //pixel_row signal from dtg module
    output reg bullet,              //bullet flag
    output reg [11:0]bul_color,     //12-bit bullet color (RGB code)
    output reg burst,               //the opponent tank is hit
    output reg burst_base_g,        //the green base is destroyed
    output reg burst_base_r,        // the red base is destroyed
    input [7:0]LocX_reg,             //LocX_reg signal from IO_BotInfo
    input [7:0]LocY_reg,             //LocY_reg signal from IO_BotInfo
    input [7:0]BotInfo_reg,          //This signal will tell us what the orientation of rojobot.
    input clock,    
    input biu,                       //The biu signal shows the tank shots
    input reset,
    input [1:0]icon_op,              //The opponent tank icon flag
    input [1:0]world_pixel           //the world map pixel
    );
    
reg [11:0] pixelr_bul, pixelc_bul;    //to record the starting coordinates of bullet
reg [11:0] row, col;                  //to record the coordinates of the shot time (first start time)
reg [31:0] counter;                   //counter for delay
reg [31:0] count_g;                   //counter for green base destroy
reg [31:0] count_r;                   //counter for red base destroy
reg [31:0]times;                      //record the times of bullent movement
reg stop;                             //the stop flag is determine when the bullet stops to display
reg [2:0] ori;                        //record the orientation of bullet (the orientation of tank at the shooting time)

// Get stop and burst signal 
always @(posedge clock) begin          
if (!reset)begin
stop <= 1'b1;                          //At beginning, the stop flag is 1
burst <= 1'b0;                         //At beginning, the hit signal is 0
end
else if (biu==1'b1) begin              //When the tank shoot
stop <= 1'b0;                          //When the stop flag is 0
end 
else if ((bullet == 2'b1) && (world_pixel == 2'b10)) begin  //When the stop keeps being 0 until the bullet meet the wall
stop <= 1'b1;
end
else if ((bullet == 2'b1) && (world_pixel == 2'b11))begin   //When the stop keeps being 0 until the bullet meet the red base
stop <= 1'b1;
end
else if ((bullet == 2'b1) && (world_pixel == 2'b01))begin   //When the stop keeps being 0 until the bullet meet the green base
stop <= 1'b1;
end
else if ((bullet == 2'b1) && (icon_op == 2'b01))begin       //When the stop keeps being 0 until the bullet meet the opponemt tank
stop <= 1'b1;
burst <= 1'b1;                                              //When bullet meets the oppoment tank, set the burst signal to show the opponemt is hit
end
else begin
stop <= stop;
burst <= 1'b0;
end
end

// get the green base destroy signal with delay
always @(posedge clock) begin
if (!reset)begin
burst_base_g <= 1'b0;
count_g <= 1'b0;
end
else if ((bullet == 2'b1) && (world_pixel == 2'b11)) begin          //When the bullet meets the green base
burst_base_g <= 1'b1;
count_g <= 1'b0;
end
else if ((count_g == 32'h2FFFFFF)&&(burst_base_g == 1'b1))begin
count_g <= 1'b0;
burst_base_g <= 1'b0;
end
else begin
count_g <= count_g+1'b1;
burst_base_g <= burst_base_g;
end
end

// get the red base destroy signal with delay
always @(posedge clock) begin
if (!reset)begin
burst_base_r <= 1'b0;
count_r <= 1'b0;
end
else if ((bullet == 2'b1) && (world_pixel == 2'b01))begin          //When the bullet meets the red base
burst_base_r <= 1'b1;
count_r <= 1'b0;
end
else if ((count_r == 32'h2FFFFFF)&&(burst_base_r == 1'b1))begin
count_r <= 1'b0;
burst_base_r <= 1'b0;
end
else begin
count_r <= count_r+1'b1;
burst_base_r <= burst_base_r;
end
end

// Change the starting coordinates to achive the movement of bullet
always@ (posedge clock) begin
if ((biu==1'b1)&&(stop==1'b1))begin         //At the shooting time 
ori <= BotInfo_reg[2:0];                    //recore the orientation of the tank
case (BotInfo_reg[2:0])                     //according the orientation of the tank, set the first starting coordinates for bullet. The bullet should show up in the front of tank
	    3'b000:  begin //North
	    pixelr_bul<=(LocY_reg * 6)-24 ;
	    pixelc_bul<=(LocX_reg << 3) +6 ;
		row <= (LocY_reg * 6)-24 ;
        col <= (LocX_reg << 3) +6 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
        3'b010:  begin//East
        pixelr_bul <= (LocY_reg * 6)+6 ;
        pixelc_bul <= (LocX_reg << 3) +36 ;
	    row <= (LocY_reg * 6)+6 ;
        col <= (LocX_reg << 3) +36 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
        3'b100:   begin//South
        pixelr_bul <= (LocY_reg * 6)+36 ;
        pixelc_bul <= (LocX_reg << 3) +6 ;
		row <= (LocY_reg * 6)+36 ;
        col <= (LocX_reg << 3) +6 ;
        times <= 1'b0;
        counter <= 1'b0;
		end		       
        3'b110:   begin//West
		pixelr_bul <= (LocY_reg * 6)+6 ;
        pixelc_bul <= (LocX_reg << 3) -24 ;
		row <= (LocY_reg * 6)+6 ;
        col <= (LocX_reg << 3) -24 ;
        times <= 1'b0;
        counter <= 1'b0;
		end
endcase
end
else if ((counter==32'h1EFFFF) && (stop==1'b0) )begin //After delay, make the bullet move automatically
case (ori)
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
ori <= ori ;
row <= row;
col <= col;
end
end


 
reg [4:0] addr_r;             // address of row 0-31
reg [4:0] addr_c;             // address of col 0-31
wire [11:0] bullet_rom ;      //12-bit rom used to store the pixel data of bullet icon

reg [8:0] addr = 11'd0;       //address for read rom

//Instantiate bullet icon rom and  read out the 12-bit burst icon color (RGB CODE); The rom store the orientation of bullet is north
bullet_up    bullet_up ( .clka(clock), .ena(~stop), .addra(addr), .douta (bullet_rom));  

 //to get the bullet flag and bullet color according to the recored orientation
always @(posedge clock) begin
if((stop == 1'b0) &&(pixel_column >= pixelc_bul) && (pixel_column <= pixelc_bul + 6'd19) && (pixel_row >= pixelr_bul) && (pixel_row <= pixelr_bul + 6'd19))
    begin
    case(ori)
    3'b000: begin  //North
            addr_r <= pixel_row-pixelr_bul;             //Row address = current dgt row coordinate - starting row coordinate
            addr_c <= pixel_column-pixelc_bul;          //Column address = current dgt col coordinate - starting col coordinate
            addr <= addr_r * 5'd20+addr_c;              //combine the row address and column address
            bul_color <= bullet_rom;                    //bullet color is read from the bullet color rom
            bullet <= (bullet_rom==12'hfff)?1'b0:1'b1;  //If the icon color is white, icon flag is 0, if not, the icon flag is 1
            end

    3'b010: begin  //East
            addr_r <= pixel_row-pixelr_bul;
            addr_c <= 5'd19-(pixel_column-pixelc_bul);
            addr <= addr_c * 5'd20+addr_r;
            bul_color <= bullet_rom;
            bullet <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end

    3'b100: begin  //South
            addr_r <= 5'd19-(pixel_row-pixelr_bul);
            addr_c <= 5'd19-(pixel_column-pixelc_bul);
            addr <= addr_r * 5'd20+addr_c;
            bul_color <= bullet_rom;
            bullet <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end

    3'b110: begin  //West
            addr_r <= 5'd19-(pixel_row-pixelr_bul);
            addr_c <= pixel_column-pixelc_bul;
            addr <= addr_c * 5'd20+addr_r;
            bul_color <= bullet_rom;
            bullet <= (bullet_rom==12'hfff)?1'b0:1'b1;
            end
    endcase
    end
else 
    bullet <= 1'b0; //icon is transparent if icon is out of specific range.
end 


endmodule

