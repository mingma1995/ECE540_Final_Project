`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma and Zhe Lu.
// 
// Create Date: 02/14/2019 02:58:39 PM
// Design Name: 
// Module Name: scale
// Project Name: ECE540 Project2 
// Target Devices: 
// Tool Versions: 
// Description: This module will scale the pixel_column and pixel_row from 1024*768 world to 128*128.
// The pixel_column is divided by 8 and pixel_row is divided by 6. Then, combine the scaled pixel_row and pixel_column to generate vid_addr.
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module scale(
input [11:0] pixel_column,
input [11:0] pixel_row,
output [13:0] vid_addr
    );

wire [6:0] pixel_column_scale;
wire [6:0] pixel_row_scale;

assign pixel_column_scale = pixel_column >> 3; //divided by 8
assign pixel_row_scale = pixel_row/6; //divided by 6
assign vid_addr = {pixel_row_scale,pixel_column_scale};
    
endmodule
