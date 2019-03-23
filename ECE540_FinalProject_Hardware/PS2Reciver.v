`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma
// 
// Create Date: 03/03/2015 09:33:36 PM
// Design Name: 
// Module Name: PS2Receiver
// Project Name: ECE 540 Final Project
// Target Devices: Nexys 4 DDR
// Tool Versions: 
// Description: PS2 Receiver module used to receive the scan code from PS/2 type keyboard. Store player 1 relative key to keycodeout[7:0]
// and store player 2 relative key to keycodeout[15:8].
// 
// Dependencies: Nexys 4 DDR keyboard demo project.
// Reference: https://reference.digilentinc.com/learn/programmable-logic/tutorials/nexys-4-ddr-keyboard-demo/start
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk, //50 Mhz clock
    input kclk, //system clock 100Mhz
    input kdata, //scan code from PS/2 type keyboard
    output [31:0] keycodeout //valid serials of 8-bits valid data to help us to distinguish which key is pressed. Player 1: keycodeout[7:0]. Player 2: keycodeout[15:8].
    );
    
    
    wire kclkf, kdataf;
    reg [7:0]datacur; //register to store the current valid 8-bit scan code.
    reg [7:0]dataprev; //register to store the previous valid 8-bit scan code.
    reg [3:0]cnt; //counter for 11-bit scan code from PS/2 keyboard.
    reg [31:0]keycode;
    reg flag; //flag used to distinguish the valid 8-bit scan data.

//Assign initial values    
    initial begin
        keycode[31:0]<=32'h0;
        cnt<=4'b0000;
        flag<=1'b0;
    end

//debounce module to make the input from keyboard more stable.	
debouncer debounce(
    .clk(clk),
    .I0(kclk),
    .I1(kdata),
    .O0(kclkf),
    .O1(kdataf)
);

//Store the 11-bit scan data from keyboard into register.    
always@(negedge(kclkf))begin
    case(cnt)
    0:;//Start bit
    1:datacur[0]<=kdataf;
    2:datacur[1]<=kdataf;
    3:datacur[2]<=kdataf;
    4:datacur[3]<=kdataf;
    5:datacur[4]<=kdataf;
    6:datacur[5]<=kdataf;
    7:datacur[6]<=kdataf;
    8:datacur[7]<=kdataf;
    9:flag<=1'b1; //valid 8-bit scan data is ready.
    10:flag<=1'b0;
    endcase
    if(cnt<=9) cnt<=cnt+1;
    else if(cnt==10) cnt<=0;    
end


always @(posedge flag)begin
          dataprev <= datacur; //save previous 8-bit scan data.
          //Player 1: W, S, A, D, left shift, number 1, number 2 and space.
          if(datacur == 8'b00011101 || datacur == 8'b00011100 || datacur == 8'b00011011 || datacur == 8'b00100011 || datacur == 8'b00010010 || datacur == 8'b00010110 || datacur == 8'b00011110 || datacur == 8'b00101001) begin
                    if(dataprev == 8'b11110000 && datacur != dataprev) //see if the player 1 releases one key.
                        keycode[7:0] <= 8'b0;
                    else 
                        keycode[7:0] <= datacur;
          end
          //Player 2: I, J, K, L, right shift.
          else if(datacur == 8'b01000011 || datacur == 8'b00111011 || datacur == 8'b01000010 || datacur == 8'b01001011 || datacur == 8'b01011001) begin
                    if(dataprev == 8'b11110000 && datacur != dataprev) //see if the player 2 releases on key.
                        keycode[15:8] <= 8'b0;
                    else 
                        keycode[15:8] <= datacur;
        
          end  
end
          
assign keycodeout=keycode;
    
endmodule
