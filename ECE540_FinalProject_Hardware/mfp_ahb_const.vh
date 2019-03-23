// 
// mfp_ahb_const.vh
// 2/20/2019
// Verilog include file with AHB definitions
// 

//---------------------------------------------------
// Physical bit-width of memory-mapped I/O interfaces
//---------------------------------------------------
`define MFP_N_LED             16
`define MFP_N_SW              16
`define MFP_N_PB              5


//---------------------------------------------------
// Memory-mapped I/O addresses
//---------------------------------------------------
`define H_LED_ADDR    			(32'h1f800000)
`define H_KEYB_ADDR   			(32'h1f800008)

`define PORT_SEVENSEG_EN            (32'h1f700000)
`define PORT_SEVENSEG_HGH           (32'h1f700004)
`define PORT_SEVENSEG_LOW           (32'h1f700008)
`define PORT_SEVENSEG_DP            (32'h1f70000c)

//Add the address for IO_BotInfo, IO_BotCtrl, IO_BotUpdt_Sync and IO_INT_ACK.
`define PORT_BOTINFO           (32'h1f80000c)
`define PORT_BOTCTRL           (32'h1f800010)
`define PORT_BOTUPDT           (32'h1f800014)
`define PORT_INTACK            (32'h1f800018)

//Add the address for IO_BotInfo_1, IO_BotCtrl_1, IO_BotUpdt_Sync_1 and IO_INT_ACK_1.
`define PORT_BOTINFO_1           (32'h1f80001c)
`define PORT_BOTCTRL_1           (32'h1f800020)
`define PORT_BOTUPDT_1           (32'h1f800024)
`define PORT_INTACK_1            (32'h1f800028)

//Add the address for PORT_HIT, PORT_FRAME, PORT_HISTORY and PORT_BULLET.
`define PORT_HIT                 (32'h1f80002c)
`define PORT_FRAME               (32'h1f800030)
`define PORT_HISTORY             (32'h1f800034)
`define PORT_BULLET   	         (32'h1f800038)



`define H_LED_IONUM   			(4'h0)
`define H_KEYB_IONUM  			(4'h2)
`define H_BotInfo_IONUM         (4'h3)
`define H_BotUpdt_IONUM         (4'h5)
`define H_BotCtrl_IONUM         (4'h4)
`define H_IntAck_IONUM          (4'h6)
`define H_BotInfo_IONUM_1         (4'h7)
`define H_BotUpdt_IONUM_1         (4'h9)
`define H_BotCtrl_IONUM_1         (4'h8)
`define H_IntAck_IONUM_1          (4'ha)

`define H_Hit_IONUM                 (4'hb)
`define H_Frame_IONUM               (4'hc)
`define H_History_IONUM             (4'hd)
`define H_Bullet_IONUM  	    (4'he)

`define H_SSEGEN_IONUM			(4'd0)
`define H_SSEGHI_IONUM			(4'd1)
`define H_SSEGLO_IONUM          (4'd2)
`define H_SSEGDP_IONUM          (4'd3)

//---------------------------------------------------
// RAM addresses
//---------------------------------------------------
`define H_RAM_RESET_ADDR 		(32'h1fc?????)
`define H_RAM_ADDR	 		    (32'h0???????)
`define H_RAM_RESET_ADDR_WIDTH  (8) 
`define H_RAM_ADDR_WIDTH		(16) 

`define H_RAM_RESET_ADDR_Match  (7'h7f)
`define H_RAM_ADDR_Match 		(1'b0)
`define H_LED_ADDR_Match		(7'h7e)
`define H_7SEG_ADDR_Match		(7'h7d)


//---------------------------------------------------
// AHB-Lite values used by MIPSfpga core
//---------------------------------------------------

`define HTRANS_IDLE    2'b00
`define HTRANS_NONSEQ  2'b10
`define HTRANS_SEQ     2'b11

`define HBURST_SINGLE  3'b000
`define HBURST_WRAP4   3'b010

`define HSIZE_1        3'b000
`define HSIZE_2        3'b001
`define HSIZE_4        3'b010