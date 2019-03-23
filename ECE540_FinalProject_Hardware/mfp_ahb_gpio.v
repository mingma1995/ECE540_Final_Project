// mfp_ahb_gpio.v
//2/20/2019
//
// General-purpose I/O module for Altera's DE2-115 and 
// Digilent's (Xilinx) Nexys4-DDR board
//
// Modified date: 3/21/2019
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang. 
// Added input:
// Two rojobot: IO_BotInfo, IO_BotUpdt_Sync, IO_BotInfo_1, IO_BotUpdt_Sync_1
// IO_HIT[3:0]: 
//              IO_HIT[0]: the green tank is hit 
//              IO_HIT[1]: the green base is destroyed 
//              IO_HIT[2]: the red tank is hit 
//              IO_HIT[3]: the red base is destoryed
// IO_keyb[15:0]:
//              IO_keyb[7:0]: control the motion of green tank
//              IO_keyb[15:8]: control the motion of red tank
//
// Added output:
// Two rojobot: IO_BotCtrl, IO_INT_ACK, IO_BotCtrl_1, IO_INT_ACK_1
// IO_FRAME[4:0]:
//              IO_FRAME[0]: enable introduction frame
//              IO_FRAME[1]: enable game frame
//              IO_FRAME[2]: enable green-tank-win frame
//              IO_FRAME[3]: enable red-tank-win frame
//              IO_FRAME[4]: enable history frame
//IO_Bullet[4:0]:
//              IO_Bullet[0]: make green tank shot
//              IO_Bullet[1]: make red tank shot
//              IO_Bullet[2]: make first monster shot
//              IO_Bullet[3]: make second monster shot
//              IO_Bullet[4]: make third monster shot
//IO_HISTORY[5:0]:
//              IO_HISTORY[1:0]: recode winner of the new history 
//              IO_HISTORY[3:2]: recode winner of the last time history 
//              IO_HISTORY[5:4]: recode winner of the last-last time history


`include "mfp_ahb_const.vh"

module mfp_ahb_gpio(
    input                        HCLK,
    input                        HRESETn,
    input      [  3          :0] HADDR,
    input      [  1          :0] HTRANS,
    input      [ 31          :0] HWDATA,
    input                        HWRITE,
    input                        HSEL,
    output reg [ 31          :0] HRDATA,

// memory-mapped I/O

    input      [15  :0]          IO_keyb,           //add port for IO_keyb
    output reg [`MFP_N_LED-1 :0] IO_LED,
    input      [31:0]            IO_BotInfo,        //add port for IO_BotInfo
    input                        IO_BotUpdt_Sync,   //add port for IO_BotUpdt_Sync
    output reg [7:0]             IO_BotCtrl,        //add port for IO_BotCtrl
    output reg                   IO_INT_ACK,        //add port for IO_INT_ACK
    
    input      [31:0]            IO_BotInfo_1,      //add port for IO_BotInfo
    input                        IO_BotUpdt_Sync_1, //add port for IO_BotUpdt_Sync
    output reg [7:0]             IO_BotCtrl_1,      //add port for IO_BotCtrl
    output reg                   IO_INT_ACK_1,      //add port for IO_INT_ACK
    
    input       [3:0]            IO_HIT,            //add port for IO_HIT
    output reg  [4:0]            IO_FRAME,          //add port for IO_FRAME
    output reg  [4:0]            IO_Bullet,         //add port for IO_Bullet
    output reg  [5:0]            IO_HISTORY         //add port for IO_HISTORY  
);

  reg  [3:0]  HADDR_d;
  reg         HWRITE_d;
  reg         HSEL_d;
  reg  [1:0]  HTRANS_d;
  wire        we;            // write enable

 	wire	[5 : 0] 			db_btns;
	wire	[`MFP_N_SW-1 :0]	db_sw;
  // delay HADDR, HWRITE, HSEL, and HTRANS to align with HWDATA for writing
  always @ (posedge HCLK) 
  begin
    HADDR_d  <= HADDR;
	HWRITE_d <= HWRITE;
	HSEL_d   <= HSEL;
	HTRANS_d <= HTRANS;
  end
  
  // overall write enable signal
  assign we = (HTRANS_d != `HTRANS_IDLE) & HSEL_d & HWRITE_d;

    always @(posedge HCLK or negedge HRESETn)
       if (~HRESETn) begin
         IO_LED <= `MFP_N_LED'b0;  
       end else if (we)
         case (HADDR_d)
           `H_LED_IONUM: IO_LED <= HWDATA[`MFP_N_LED-1:0];
           `H_BotCtrl_IONUM: IO_BotCtrl <= HWDATA[7:0];     //address[5:2] of IO_BotCtrl = 4'h4 because the address of IO_BotCtrl   = 0x1f800010.
           `H_IntAck_IONUM: IO_INT_ACK <= HWDATA[0];        //address[5:2] of IO_INT_ACK = 4'h6 because the address of IO_INT_ACK   = 0x1f800018.         
           `H_BotCtrl_IONUM_1: IO_BotCtrl_1 <= HWDATA[7:0]; //address[5:2] of IO_BotCtrl = 4'h8 because the address of IO_BotCtrl_1 = 0x1f800020.
           `H_IntAck_IONUM_1: IO_INT_ACK_1 <= HWDATA[0];    //address[5:2] of IO_INT_ACK = 4'ha because the address of IO_INT_ACK_1 = 0x1f800028.
           `H_Bullet_IONUM: IO_Bullet <= HWDATA[4:0];       //address[5:2] of IO_Bullet  = 4'he because the address of IO_Bullet    = 0x1f800038.
           `H_Frame_IONUM: IO_FRAME <= HWDATA[4:0];         //address[5:2] of IO_FRAME   = 4'hc because the address of IO_FRAME     = 0x1f800030.
           `H_History_IONUM: IO_HISTORY <= HWDATA[5:0];     //address[5:2] of IO_HISTORY = 4'hd because the address of IO_HISTORY   = 0x1f800034.
         endcase
    
	always @(posedge HCLK or negedge HRESETn)
       if (~HRESETn)
         HRDATA <= 32'h0;
       else
	     case (HADDR)
           `H_KEYB_IONUM: HRDATA <= { {16 {1'b0}}, IO_keyb };               //address[5:2] of IO_keyb = 4'h2 because the address of IO_keyb   = 0x1f800008.
           `H_BotInfo_IONUM: HRDATA <= IO_BotInfo;                          //address[5:2] of IO_BotInfo = 4'h3 because the address of IO_BotInfo = 0x1f80000c.
           `H_BotUpdt_IONUM: HRDATA <= { {31{1'b0}}, IO_BotUpdt_Sync };     //address[5:2] of IO_BotUpdt_Sync = 4'h5 because the address of IO_BotUpdt_Sync = 0x1f800014.        
           `H_BotInfo_IONUM_1: HRDATA <= IO_BotInfo_1;                      //address[5:2] of IO_BotInfo = 4'h7 because the address of IO_BotInfo_1 = 0x1f80001c.
           `H_BotUpdt_IONUM_1: HRDATA <= { {31{1'b0}}, IO_BotUpdt_Sync_1 }; //address[5:2] of IO_BotUpdt_Sync = 4'h9 because the address of IO_BotUpdt_Sync = 0x1f800024.
           `H_Hit_IONUM: HRDATA <= { {28{1'b0}}, IO_HIT };                  //address[5:2] of IO_HIT = 4'hd because the address of IO_HIT   = 0x1f80002c.

            default:    HRDATA <= 32'h00000000;
         endcase
          
endmodule