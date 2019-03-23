// mfp_ahb.v
// 
// 2/20/2019
//
// AHB-lite bus module with 3 slaves: boot RAM, program RAM, and
// GPIO (memory-mapped I/O: switches and LEDs from the FPGA board).
// The module includes an address decoder and multiplexer (for 
// selecting which slave module produces HRDATA).

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


module mfp_ahb
(
    input                       HCLK,
    input                       HRESETn,
    input      [ 31         :0] HADDR,
    input      [  2         :0] HBURST,
    input                       HMASTLOCK,
    input      [  3         :0] HPROT,
    input      [  2         :0] HSIZE,
    input      [  1         :0] HTRANS,
    input      [ 31         :0] HWDATA,
    input                       HWRITE,
    output     [ 31         :0] HRDATA,
    output                      HREADY,
    output                      HRESP,
    input                       SI_Endian,

// memory-mapped I/O
    input      [15 :0]           IO_keyb,          //add the port for IO_keyb
    output     [`MFP_N_LED-1:0] IO_LED,
    output     [7:0]            IO_7SEGEN_N,
    output     [7:0]            IO_7SEG_N,
    input      [31:0]            IO_BotInfo,        //add the port for IO_BotInfo
    input                        IO_BotUpdt_Sync,   //add the port for IO_BotUpdt_Sync
    output     [7:0]             IO_BotCtrl,        //add the port for IO_BotCtrl
    output                       IO_INT_ACK,        //add the port for IO_INT_ACK
    input      [31:0]            IO_BotInfo_1,      //add the port for IO_BotInfo
    input                        IO_BotUpdt_Sync_1, //add the port for IO_BotUpdt_Sync
    output     [7:0]             IO_BotCtrl_1,      //add the port for IO_BotCtrl
    output                       IO_INT_ACK_1,      //add the port for IO_INT_ACK
    input       [3:0]            IO_HIT,            //add the port for IO_HIT
    output      [4:0]            IO_FRAME,          //add the port for IO_FRAME
    output      [4:0]            IO_Bullet,         //add the port for IO_Bullet
    output      [5:0]            IO_HISTORY         //add the port for IO_HISTORY 
);


  wire [31:0] HRDATA2, HRDATA1, HRDATA0;
  wire [ 3:0] HSEL;
  reg  [ 3:0] HSEL_d;

  assign HREADY = 1;
  assign HRESP = 0;
	
  // Delay select signal to align for reading data
  always @(posedge HCLK)
    HSEL_d <= HSEL;

  // Module 0 - boot ram
  mfp_ahb_b_ram mfp_ahb_b_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA0, HSEL[0]);
  // Module 1 - program ram
  mfp_ahb_p_ram mfp_ahb_p_ram(HCLK, HRESETn, HADDR, HBURST, HMASTLOCK, HPROT, HSIZE,
                              HTRANS, HWDATA, HWRITE, HRDATA1, HSEL[1]);
  // Module 2 - GPIO. Add IO_keyb, IO_BotInfo, IO_BotUpdt_Sync, IO_BotCtrl, IO_INT_ACK, IO_BotInfo_1, IO_BotUpdt_Sync_1, IO_BotCtrl_1, IO_INT_ACK_1, IO_HIT,IO_FRAME,IO_Bullet and IO_HISTORY to this module.
  mfp_ahb_gpio mfp_ahb_gpio(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[2], 
                            HRDATA2,IO_keyb, IO_LED, IO_BotInfo, IO_BotUpdt_Sync, IO_BotCtrl, IO_INT_ACK, IO_BotInfo_1, IO_BotUpdt_Sync_1, IO_BotCtrl_1, IO_INT_ACK_1,
                            IO_HIT,IO_FRAME,IO_Bullet,IO_HISTORY);
  
 //Module 3 - Seven Seg Display module
 SevenSeg ssg(HCLK, HRESETn, HADDR[5:2], HTRANS, HWDATA, HWRITE, HSEL[3],
                        IO_7SEGEN_N,IO_7SEG_N);
                          
  ahb_decoder ahb_decoder(HADDR, HSEL); 
  ahb_mux ahb_mux(HCLK, HSEL_d, HRDATA2, HRDATA1, HRDATA0, HRDATA);

endmodule


module ahb_decoder
(
    input  [31:0] HADDR,
    output [ 3:0] HSEL
);

  // Decode based on most significant bits of the address
  assign HSEL[0] = (HADDR[28:22] == `H_RAM_RESET_ADDR_Match); // 128 KB RAM  at 0xbfc00000 (physical: 0x1fc00000)
  assign HSEL[1] = (HADDR[28]    == `H_RAM_ADDR_Match);       // 256 KB RAM at 0x80000000 (physical: 0x00000000)
  assign HSEL[2] = (HADDR[28:22] == `H_LED_ADDR_Match);       // GPIO at 0xbf800000 (physical: 0x1f800000)
  assign HSEL[3] = (HADDR[28:22] == `H_7SEG_ADDR_Match);      //7SEG at 0xbf700000 (physical: 0x1f700000)
endmodule


module ahb_mux
(
    input             HCLK,
    input      [ 3:0] HSEL,
    input      [31:0] HRDATA2, HRDATA1, HRDATA0,
    output reg [31:0] HRDATA
);

    always @(*)
      casez (HSEL)
	      4'b???1:    HRDATA = HRDATA0;
	      4'b??10:    HRDATA = HRDATA1;
	      4'b?100:    HRDATA = HRDATA2;
	      default:   HRDATA = HRDATA1;
      endcase
endmodule