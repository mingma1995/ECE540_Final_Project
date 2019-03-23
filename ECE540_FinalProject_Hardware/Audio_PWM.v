`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Portland State University
// Engineer: Ming Ma
// 
// Create Date: 03/15/2019 02:31:28 PM
// Design Name: 
// Module Name: Audio_PWM
// Project Name: ECE 540 Final Project
// Target Devices: Nexys 4 DDR
// Tool Versions: 
// Description: This module will control the FPGA to play some sounds by controlling AUD_PWM and AUD_SD. If audio_data > audio_counter, set AUD_PWM = 1
// Otherwise, set AUD_PWM = 0. The AUD_SD means shutdown and we just assign this port to value 1. 
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Audio_PWM(
    input clk, //100Mhz system clock
    input reset, //system reset
    input enable1, //Enable signal to play the sound for the initial page
    input enable2, //Enable signal to play the sound for the fight page
    output AUD_PWM, //Port to control the amplifier to play sound
    output AUD_SD //Shutdown signal. Assign this port to 1
    );
    
    wire [7:0] audio_data1; //audio data read from distribute memory for initial BGM
    wire [7:0] audio_data2; //audio data read from distribute memory for fight BGM
    reg [7:0] audio_counter1 = 8'b0; //audio counter for the initial BGM
    reg [7:0] audio_counter2 = 8'b0; //audio counter for the fight BGM
    reg AUD_PWM_I = 1'b0;
    reg [14:0] S1_counter = 15'b0; //Address counter to control the read data from memory for initial BGM
    reg [14:0] S2_counter = 15'b0; //Address counter to control the read data from memory for fight BGM
    parameter integer CLK_FREQUENCY_HZ = 100000000; //100Mhz
    parameter integer UPDATE_FREQUENCY_8KHZ  = 8000; //Value used to calculate the counter number for 8K frequency
    reg            [14:0]    clk_cnt_8Khz; //Counter for generating 8K frequency
    wire           [14:0]    top_cnt_8Khz = ((CLK_FREQUENCY_HZ / UPDATE_FREQUENCY_8KHZ) - 1); // max value of counter for 8Khz clock 
    reg            clock8Khz;                // update 8Khz clock enable
    
    
    
    //Generate 8K clock frequency from 100M clock.
    always @(posedge clk or negedge reset) begin
     if (!reset) begin
            clk_cnt_8Khz <= {15{1'b0}};
     end
        
     else if (clk_cnt_8Khz == top_cnt_8Khz) begin
            clock8Khz     <= 1'b1;
            clk_cnt_8Khz <= {15{1'b0}};
     end
        
     else begin
            clock8Khz     <= 1'b0;
            clk_cnt_8Khz <= clk_cnt_8Khz + 1'b1;
     end
    end
    
    //Generate Audio_PWM signal for initial BGM and fight BGM.
    always @(posedge clk or negedge reset) begin
     if(!reset) begin
        AUD_PWM_I <= 1'b0;
        audio_counter1 <= 8'b0;
        audio_counter2 <= 8'b0;
     end
     else if(enable1) begin
        audio_counter2 <= 8'b0;
        audio_counter1 <= audio_counter1 + 1'b1;
        if(audio_counter1 >= audio_data1) //Compare the audio data of initial BGM with its audio counter
            AUD_PWM_I <= 1'b0;
        else
            AUD_PWM_I <= 1'b1;
     end
     else if(enable2) begin
        audio_counter1 <= 8'b0;
        audio_counter2 <= audio_counter2 + 1'b1;
        if(audio_counter2 >= audio_data2) //Compare the audio data of fight BGM with its audio counter.
            AUD_PWM_I <= 1'b0;
        else
            AUD_PWM_I <= 1'b1;
     end   
    end
    
	//Control the address counters for reading audio data from memory.
    always @(posedge clock8Khz or negedge reset) begin
     if(!reset) begin
		S1_counter <= 15'b0;
		S2_counter <= 15'b0;
     end
     else if(enable1) 
        begin
        if(S1_counter == 15'd22399)
            S1_counter <= 15'd0;
        else
            S1_counter <= S1_counter + 1'b1;
        end   
     else if(enable2)
       begin
       if(S2_counter == 15'd22399)
            S2_counter <= 15'd0;
       else
            S2_counter <= S2_counter + 1'b1;
     end  
    end
    
 //Read initial audio data from distribute memory.
Initial_BGM Initial_BGM (
   .a(S1_counter),              // input wire [14 : 0] a
   .qspo_ce(enable1),  // input wire qspo_ce
   .spo(audio_data1)          // output wire [7 : 0] spo
 );
 
//Read fight BGM audio data from distribute memory.  
BGM BGM (
    .a(S2_counter),              // input wire [14 : 0] a
    .qspo_ce(enable2),  // input wire qspo_ce
    .spo(audio_data2)          // output wire [7 : 0] spo
  );
  
   
    assign AUD_PWM = AUD_PWM_I;
    assign AUD_SD = 1'b1; //Assign this port to 1 to enable shutdown music.
    
endmodule
