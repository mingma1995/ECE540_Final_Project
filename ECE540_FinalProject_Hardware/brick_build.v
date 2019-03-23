`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang.
// 
// Create Date: 03/18/2019 09:05:02 PM
// Design Name: 
// Module Name: brick
// Project Name: ECE 540 Final Project: World of Tank
// Target Devices: 
// Tool Versions: 
// Description: 
//              This module sets the brick picture to the obstruction of the world map
//              the unit brick picture is 32 * 32
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module brick_build(
input [11:0] pixel_column,  //pixel_column signal from dtg module
input [11:0] pixel_row,     //pixel_row signal from dtg module
input clock,
input reset,
output [11:0] brick_color   //12-bit brick color (RGB CODE)
);
reg [11:0] bri [0:1023];     //rom used to store the pixel data of brick
wire [4:0]  addr_r, addr_c, addr_i,addr_j; //0-31
wire [9:0] addr;
brick brick(.clka(clock), .ena(1), .addra(addr), .douta (brick_color));
//For 1024 * 768 world, every row could put 32 brick; every col could put 24 brick
assign addr_i = pixel_column /6'd32;            // the number of brick in the row          
assign addr_c = pixel_column-(addr_i * 6'd32);
assign addr_j = pixel_row /6'd32;               //the number of brick in the column
assign addr_r = pixel_row- (addr_i * 6'd32);
assign addr = {addr_r,addr_c}; 
endmodule
