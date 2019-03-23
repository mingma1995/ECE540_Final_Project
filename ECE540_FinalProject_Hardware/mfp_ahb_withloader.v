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

module mfp_ahb_withloader (
    input         HCLK,
    input         HRESETn,
    input  [31:0] HADDR,
    input  [ 2:0] HBURST,
    input         HMASTLOCK,
    input  [ 3:0] HPROT,
    input  [ 2:0] HSIZE,
    input  [ 1:0] HTRANS,
    input  [31:0] HWDATA,
    input         HWRITE,
    output [31:0] HRDATA,
    output        HREADY,
    output        HRESP,
    input         SI_Endian,

	// memory-mapped I/O
    input      [15 : 0]          IO_keyb,           //add the port for IO_keyb
    output     [`MFP_N_LED-1: 0] IO_LED,
    output     [7 : 0]			 IO_7SEGEN_N,
    output     [7 : 0]           IO_7SEG_N,
    
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
    output      [5:0]            IO_HISTORY,        //add the port for IO_HISTORY
	// for serial loading of memory using uart
    input                        UART_RX,

	// reset system due to serial load
    output        MFP_Reset_serialload
);

    wire [7:0] char_data;
    wire       char_ready;

    mfp_uart_receiver mfp_uart_receiver
    (
        .clock      ( HCLK       ),
        .reset_n    ( HRESETn    ),
        .rx         ( UART_RX    ),
        .byte_data  ( char_data  ),
        .byte_ready ( char_ready )
    );                     

    wire        in_progress;
    wire        format_error;
    wire        checksum_error;
    wire [ 7:0] error_location;

    wire [31:0] write_address;
    wire [ 7:0] write_byte;
    wire        write_enable;

//    assign IO_RedLEDs = { in_progress, format_error, checksum_error, write_enable, write_address [31:0] };

    mfp_srec_parser mfp_srec_parser
    (
        .clock           ( HCLK           ),
        .reset_n         ( HRESETn        ),

        .char_data       ( char_data      ),
        .char_ready      ( char_ready     ), 

        .in_progress     ( in_progress    ),
        .format_error    ( format_error   ),
        .checksum_error  ( checksum_error ),
        .error_location  ( error_location ),

        .write_address   ( write_address  ),
        .write_byte      ( write_byte     ),
        .write_enable    ( write_enable   )
    );

    assign MFP_Reset_serialload = in_progress;

    wire [31:0] loader_HADDR;
    wire [ 2:0] loader_HBURST;
    wire        loader_HMASTLOCK;
    wire [ 3:0] loader_HPROT;
    wire [ 2:0] loader_HSIZE;
    wire [ 1:0] loader_HTRANS;
    wire [31:0] loader_HWDATA;
    wire        loader_HWRITE;

    mfp_srec_parser_to_ahb_lite_bridge mfp_srec_parser_to_ahb_lite_bridge
    (
        .clock          ( HCLK             ),
        .reset_n        ( HRESETn          ),
        .big_endian     ( SI_Endian        ),
    
        .write_address  ( write_address    ),
        .write_byte     ( write_byte       ),
        .write_enable   ( write_enable     ), 
    
        .HADDR          ( loader_HADDR     ),
        .HBURST         ( loader_HBURST    ),
        .HMASTLOCK      ( loader_HMASTLOCK ),
        .HPROT          ( loader_HPROT     ),
        .HSIZE          ( loader_HSIZE     ),
        .HTRANS         ( loader_HTRANS    ),
        .HWDATA         ( loader_HWDATA    ),
        .HWRITE         ( loader_HWRITE    )
    );

    mfp_ahb mfp_ahb
    (
        .HCLK             ( HCLK            ),
        .HRESETn          ( HRESETn         ),
                         
        .HADDR            ( in_progress ? loader_HADDR     : HADDR     ),
        .HBURST           ( in_progress ? loader_HBURST    : HBURST    ),
        .HMASTLOCK        ( in_progress ? loader_HMASTLOCK : HMASTLOCK ),
        .HPROT            ( in_progress ? loader_HPROT     : HPROT     ),
        .HSIZE            ( in_progress ? loader_HSIZE     : HSIZE     ),
        .HTRANS           ( in_progress ? loader_HTRANS    : HTRANS    ),
        .HWDATA           ( in_progress ? loader_HWDATA    : HWDATA    ),
        .HWRITE           ( in_progress ? loader_HWRITE    : HWRITE    ),
                         
        .HRDATA           ( HRDATA          ),
        .HREADY           ( HREADY          ),
        .HRESP            ( HRESP           ),
        .SI_Endian        ( SI_Endian       ),
                                             

        .IO_keyb            ( IO_keyb           ),  //add the port for IO_keyb
        .IO_LED           ( IO_LED          ),
        .IO_7SEGEN_N(IO_7SEGEN_N),
        .IO_7SEG_N(IO_7SEG_N),
        .IO_BotInfo             (IO_BotInfo),        //add the port for IO_BotInfo
        .IO_BotUpdt_Sync        (IO_BotUpdt_Sync),   //add the port for IO_BotUpdt_Sync
        .IO_BotCtrl             (IO_BotCtrl),        //add the port for IO_BotCtrl 
        .IO_INT_ACK             (IO_INT_ACK),        //add the port for IO_INT_ACK
        .IO_BotInfo_1           (IO_BotInfo_1),      //add the port for IO_BotInfo
        .IO_BotUpdt_Sync_1      (IO_BotUpdt_Sync_1), //add the port for IO_BotUpdt_Sync
        .IO_BotCtrl_1           (IO_BotCtrl_1),      //add the port for IO_BotCtrl 
        .IO_INT_ACK_1           (IO_INT_ACK_1),      //add the port for IO_INT_ACK
        .IO_HIT                 (IO_HIT),            //add the port for IO_HIT
        .IO_FRAME               (IO_FRAME),          //add the port for IO_FRAME
        .IO_Bullet              (IO_Bullet),         //add the port for IO_Bullet
        .IO_HISTORY             (IO_HISTORY)         //add the port for IO_HISTORY
    );

endmodule