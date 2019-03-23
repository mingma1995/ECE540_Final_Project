// mfp_nexys4_ddr.v
// 3/21/2019
// Company: Portland State University
// Engineer: Ming Ma, Zhe Lu, Xiaoqiao Mu and Ting Wang.
//
// The topmodule of the world of tank game
// All needed signals are integrated in the this module 
// Instantiate the mipsfpga system and rename signals to
// match the GPIO, LEDs, switches, keyboard(USB), dgt and audio on Digilent's (Xilinx)
// Nexys4 DDR board

// Outputs:
// 16 LEDs (IO_LED)
// 12-bit RGB
// horiz_sync, vert_sync(output of dgt)
// Audio output (AUD_PWM, AUD_SD) 
// Inputs:
// 16 Slide switches (IO_Switch),
// 5 Pushbuttons (IO_PB): {BTNU, BTND, BTNL, BTNC, BTNR},
// keyboard input (PS2_CLK,PS2_DATA)
//

`include "mfp_ahb_const.vh"

module mfp_nexys4_ddr( 
                        input                   CLK100MHZ,
                        input                   CPU_RESETN,
                        input  [`MFP_N_SW-1 :0] SW,
                        output [`MFP_N_LED-1:0] LED,
                        inout  [ 8          :1] JB,
                        input                   UART_TXD_IN,
	                    output [7 : 0]          AN,
                        output                  CA,CB,CC,CD,CE,CF,CG,DP,
                        output [3:0]            red,
                        output [3:0]            green,
                        output [3:0]            blue,
                        output                  horiz_sync, //This is the horizontal sync that is connected to constraint file.
                        output                  vert_sync, //This is the vertical sync that is connected to constraint file.
                   
                        input                   PS2_CLK,  //keyboard clock
                        input                   PS2_DATA, // keyboard input data (signal)
                        output                  UART_TXD,
                        output                  AUD_PWM,
                        output                  AUD_SD
                        );

  // Press btnCpuReset to reset the processor. 
        
  wire clk_out50; 
  wire clk_out75; 
  wire tck_in, tck;
  wire [7:0]  IO_7SEGEN_N;      //seven segment enable
  wire [7:0]  IO_7SEG_N;        //seven segment
  wire [31:0] IO_BotInfo;       //The IO_BotInfo signal of the rojobot of the green tank 
  reg        IO_BotUpdt_Sync;   //The IO_BotUpdt_Sync signal of the rojobot of the green tank 
  wire [7:0]  IO_BotCtrl;       //The IO_BotCtrl signal of the rojobot of the green tank 
  wire        IO_INT_ACK;       //The IO_INT_ACK signal of the rojobot of the green tank 
  wire        IO_BotUpdt;       //The IO_BotUpdt signal of the rojobot of the green tank
  wire [31:0] IO_BotInfo_1;     //The IO_BotInfo signal of the rojobot of the red tank 
  reg        IO_BotUpdt_Sync_1; //The IO_BotUpdt_Sync signal of the rojobot of the red tank 
  wire [7:0]  IO_BotCtrl_1;     //The IO_BotCtrl signal of the rojobot of the red tank 
  wire        IO_INT_ACK_1;     //The IO_INT_ACK signal of the rojobot of the red tank 
  wire        IO_BotUpdt_1;     //The IO_BotUpdt signal of the rojobot of the red tank
  
  
  wire [13 : 0] addra;          
  wire [1 : 0] douta;
  wire [13 : 0] addra_1;
  wire [1 : 0] douta_1;
  wire [13 : 0] addrb;
  wire [1 : 0] doutb;
  wire [13:0] vid_addr;
  wire [13:0] vid_addr_1;
  wire [1:0] icon;              //green tank icon flag
  wire [1:0] icon2;             //red tank icon flag
  
 wire [3:0] IO_HIT;             // 4-bit IO_HIT signal to show the beening hit condition of the tanks and bases 
 wire [4:0] IO_FRAME;           // 5-bit IO_FRAME signal to control which frame should be displayed
 wire [4:0] IO_Bullet;          // 5-bit IO_Bullet signal to control two player tanks and three monster tanks shot bullet 
 wire [5:0] IO_HISTORY;         // 6-bit IO_HISTORY signal to control the history frame display the provious winner tank 
  
  //Instantiate clock ip to generate 50Mhz and 75Mhz output clock.
  clk_wiz_0 clk_wiz_0(.clk_in1(CLK100MHZ), .clk_50M(clk_out50), .clk_75M(clk_out75));
  IBUF IBUF1(.O(tck_in),.I(JB[4]));
  BUFG BUFG1(.O(tck), .I(tck_in));
  
  assign AN = IO_7SEGEN_N;
  assign {DP,CA,CB,CC,CD,CE,CF,CG} = IO_7SEG_N; //port connection for seven segment diaply.

wire [31:0] keycode;
// Instantiate the keyboard interface
PS2Receiver keyboard ( 
.clk(clk_out50),
.kclk(PS2_CLK),
.kdata(PS2_DATA),
.keycodeout(keycode[31:0])
);

// Instantiate the mfp_sys module, convert the needed signal to AHB-bus
  mfp_sys mfp_sys(
			        .SI_Reset_N(CPU_RESETN),
                    .SI_ClkIn(clk_out50),
                    .HADDR(),
                    .HRDATA(),
                    .HWDATA(),
                    .HWRITE(),
					.HSIZE(),
                    .EJ_TRST_N_probe(JB[7]),
                    .EJ_TDI(JB[2]),
                    .EJ_TDO(JB[3]),
                    .EJ_TMS(JB[1]),
                    .EJ_TCK(tck),
                    .SI_ColdReset_N(JB[8]),
                    .EJ_DINT(1'b0),
                    .IO_keyb(keycode[15:0]),
                    .IO_LED(LED),
                    .IO_7SEGEN_N(IO_7SEGEN_N),
                    .IO_7SEG_N(IO_7SEG_N),
                    .UART_RX(UART_TXD_IN),
                    .IO_BotInfo(IO_BotInfo),                //add the port for IO_BotInfo
                    .IO_BotUpdt_Sync(IO_BotUpdt_Sync),      //add the port for IO_BotUpdt_Sync
                    .IO_BotCtrl(IO_BotCtrl),                //add the port for IO_BotCtrl
                    .IO_INT_ACK(IO_INT_ACK),                //add the port for IO_INT_ACK
                    .IO_BotInfo_1(IO_BotInfo_1),            //add the port for IO_BotInfo
                    .IO_BotUpdt_Sync_1(IO_BotUpdt_Sync_1),  //add the port for IO_BotUpdt_Sync
                    .IO_BotCtrl_1(IO_BotCtrl_1),            //add the port for IO_BotCtrl
                    .IO_INT_ACK_1(IO_INT_ACK_1),            //add the port for IO_INT_ACK
                    .IO_HIT                 (IO_HIT),       //add the port for IO_HIT
                    .IO_FRAME               (IO_FRAME),     //add the port for IO_FRAME
                    .IO_Bullet              (IO_Bullet),    //add the port for IO_Bullet
                    .IO_HISTORY             (IO_HISTORY)    //add the port for IO_HISTORY
                    );

//Instantiate rojobot ip. This ip uses 75Mhz clock. The reset of rojobot is active high. 
wire green_reset_hit, red_reset_hit,green_reset,red_reset; 
//The green tank reset (back to the initialization position) when the green tank is hit or the transform of frame or the CPU reset button is pressed
assign   green_reset = (green_reset_hit)| (~CPU_RESETN) | (IO_FRAME[0])|(IO_FRAME[2])|(IO_FRAME[3])|(IO_FRAME[4]);
//The red tank reset (back to the initialization position) when the red tank is hit or the transform of frame or the CPU reset button is pressed  
assign   red_reset = (red_reset_hit)| (~CPU_RESETN) | (IO_FRAME[0])|(IO_FRAME[2])|(IO_FRAME[3])|(IO_FRAME[4]);      
// Instantiate the first rojobot for green tank 
  rojobot31_GreenTank_0 robot1 (
                      .MotCtl_in(IO_BotCtrl),                    // input wire [7 : 0] MotCtl_in
                      .LocX_reg(IO_BotInfo[31:24]),              // output wire [7 : 0] LocX_reg
                      .LocY_reg(IO_BotInfo[23:16]),              // output wire [7 : 0] LocY_reg
                      .Sensors_reg(IO_BotInfo[15:8]),            // output wire [7 : 0] Sensors_reg
                      .BotInfo_reg(IO_BotInfo[7:0]),             // output wire [7 : 0] BotInfo_reg
                      .worldmap_addr(addra),                     // output wire [13 : 0] worldmap_addr
                      .worldmap_data(douta),                     // input wire [1 : 0] worldmap_data
                      .clk_in(clk_out75),                        // input wire clk_in
                      .reset(green_reset),                       // input wire reset
                      .upd_sysregs(IO_BotUpdt),                  // output wire upd_sysregs
                      .Bot_Config_reg(8'b00001011)               // input wire [7 : 0] Bot_Config_reg (control the speed of rojobot motion, get faster)
                    );
                    
 // Instantiate the second rojobot for red tank                    
   rojobot31_RedTank_0 robot2 (
                                        .MotCtl_in(IO_BotCtrl_1),                   // input wire [7 : 0] MotCtl_in
                                        .LocX_reg(IO_BotInfo_1[31:24]),             // output wire [7 : 0] LocX_reg
                                        .LocY_reg(IO_BotInfo_1[23:16]),             // output wire [7 : 0] LocY_reg
                                        .Sensors_reg(IO_BotInfo_1[15:8]),           // output wire [7 : 0] Sensors_reg
                                        .BotInfo_reg(IO_BotInfo_1[7:0]),            // output wire [7 : 0] BotInfo_reg
                                        .worldmap_addr(addra_1),                    // output wire [13 : 0] worldmap_addr
                                        .worldmap_data(douta_1),                    // input wire [1 : 0] worldmap_data
                                        .clk_in(clk_out75),                         // input wire clk_in
                                        .reset(red_reset),                          // input wire reset
                                        .upd_sysregs(IO_BotUpdt_1),                 // output wire upd_sysregs
                                        .Bot_Config_reg(8'b00001011)                // input wire [7 : 0] Bot_Config_reg (control the speed of rojobot motion, get faster)
                                      );

//Instantiate the world map ip. This ip uses 75Mhz clock.                    
   world_map mapfor1(
                      .clka(clk_out75),
                      .addra(addra),
                      .douta(douta),
                      .clkb(clk_out75),
                      .addrb(vid_addr),
                      .doutb(doutb)
                    );
                    
   world_map mapfor2(
                      .clka(clk_out75),
                      .addra(addra_1),
                      .douta(douta_1),
                      .clkb(clk_out75),
                      .addrb(vid_addr),
                      .doutb()
                     );
                    
   wire video_on;
   wire [11:0] pixel_row, pixel_column;
   wire [11:0] icon_c, icon_c_1;            // two 12-bit player tanks color (RGB code) 
    

//Instantiate the dtg module. The reset of dtg module is active high.
   dtg dtg(
                    .clock(clk_out75), 
                    .rst(~CPU_RESETN),
                    .horiz_sync(horiz_sync),
                    .vert_sync(vert_sync), 
                    .video_on(video_on),        
                    .pixel_row(pixel_row), 
                    .pixel_column(pixel_column)
                    );

//Instantiate scale module.                    
   scale scale(
                    .pixel_column(pixel_column),
                    .pixel_row(pixel_row),
                    .vid_addr(vid_addr)
    );
  

  wire bul,bul2;
  wire [11:0] bul_color,bul_color2;
  wire [11:0] brick_color; 
  
  wire mon1,mon2,mon3;                                  //three monster flags
  wire [11:0] mon1_color, mon2_color, mon3_color;       //three 12-bit monster color (RGB code)
  wire mon_b1, mon_b2, mon_b3;                          //three monster's bullet flags
  wire [11:0] mon1_bcolor, mon2_bcolor, mon3_bcolor ;   //three 12-bit monster bullet color (RGB code)
  wire burst_g1, burst_g2, burst_g3;                    //the signals shows the green tank is hit by monsters         
  wire burst_r1, burst_r2, burst_r3;                    //the signals shows the red tank is hit by monsters 
  wire burst_tg, burst_tr;                              // burst_tg shows the green tank is hit by the opponent tank; burst_tr shows the red tank is hit by the opponent tank.  
  wire hit, hit2;                                       //hit: the green tank is hit; hit2: the red tank is hit 
  
  //the green tank is hit when the green tank is hit by any monster or opponent tank
  assign hit=burst_tg|burst_g1|burst_g2|burst_g3;
  //the red tank is hit when the red tank is hit by any monster or opponent tank
  assign hit2=burst_tr|burst_r1|burst_r2|burst_r3;
 
 //Instantiate colorizer module   
Colorizer Colorizer(
                      .pixel_column(pixel_column),
                      .pixel_row(pixel_row),
                      .video_on(video_on),
                      .world_pixel(doutb),
                      .icon(icon),
                      .icon_c(icon_c),
                      .icon_1(icon2),
                      .icon_c_1(icon_c_1),
                      .red(red),
                      .green(green),
                      .blue(blue),
                      .bul(bul), 
                      .bul2(bul2),
                      .bul_color(bul_color),
                      .bul_color2(bul_color2),
                      .clock(clk_out75),
                      .brick_color(brick_color),
                      .enable1(IO_FRAME[0]),            //IO_FRAME controls the frame transform
                      .enable2(IO_FRAME[1]),
                      .enable3(IO_FRAME[2]),
                      .enable4(IO_FRAME[3]),
                      .enable5(IO_FRAME[4]),
                      .His1(IO_HISTORY[1:0]),
                      .His2(IO_HISTORY[3:2]),
                      .His3(IO_HISTORY[5:4]),
                      .mon1(mon1),
                      .mon2(mon2),
                      .mon3(mon3),
                      .mon1_color(mon1_color),
                      .mon2_color(mon2_color),
                      .mon3_color(mon3_color),
                      .mon_b1(mon_b1),
                      .mon_b2(mon_b2),
                      .mon_b3(mon_b3),
                      .mon1_bcolor(mon1_bcolor),
                      .mon2_bcolor(mon2_bcolor),
                      .mon3_bcolor(mon3_bcolor)     
        );
    
 
//Instantiate Icon module
Icon Icon1(         // green tank icon
            .pixel_column(pixel_column),
            .pixel_row(pixel_row),
            .LocX_reg(IO_BotInfo[31:24]),
            .LocY_reg(IO_BotInfo[23:16]),
            .BotInfo_reg(IO_BotInfo[7:0]),
            .clock(clk_out75),
            .reset(CPU_RESETN),
            .hit (hit),                     // the green tank is hit 
            .icon(icon),
            .icon_c(icon_c),
            .burst(IO_HIT[0]),              // the burst signal which is the hit signal with delay; make it easy to catched by MIPS
            .green_reset(green_reset_hit)   // After being hit, the rojobot should be reset
);
Icon2 Icon2(        //red tank icon
            .pixel_column(pixel_column),
            .pixel_row(pixel_row),        
            .LocX_reg(IO_BotInfo_1[31:24]),
            .LocY_reg(IO_BotInfo_1[23:16]),
            .BotInfo_reg(IO_BotInfo_1[7:0]),
            .clock(clk_out75),
            .reset(CPU_RESETN),
            .hit (hit2),                     // the red tank is hit
            .icon(icon2),
            .icon_c(icon_c_1),
            .burst(IO_HIT[2]),              // the burst signal which is the hit signal with delay
            .red_reset(red_reset_hit)       // After being hit, the rojobot should be reset
); 

//Handshake module to sync 75Mhz clock and 50Mhz clock. 
   always @(posedge clk_out50) begin
     if (IO_INT_ACK == 1'b1) begin
        IO_BotUpdt_Sync <= 1'b0; 
   end
   else if (IO_BotUpdt == 1'b1) begin
        IO_BotUpdt_Sync <= 1'b1;
   end else begin
        IO_BotUpdt_Sync <= IO_BotUpdt_Sync;
   end
   end
  
  //Handshake module to sync 75Mhz clock and 50Mhz clock. 
      always @(posedge clk_out50) begin
        if (IO_INT_ACK_1 == 1'b1) begin
           IO_BotUpdt_Sync_1 <= 1'b0; 
      end
      else if (IO_BotUpdt_1 == 1'b1) begin
           IO_BotUpdt_Sync_1 <= 1'b1;
      end else begin
           IO_BotUpdt_Sync_1 <= IO_BotUpdt_Sync_1;
      end
      end 
    
    wire green_green_base; //green base is destroyed by green tank
    wire green_red_base;   //red base is destroyed by green tank
    wire red_green_base;   //green base is destroyed by red tank
    wire red_red_base;     //red base is destoryed by red tannk
   //IO_HIT[1] shows the green base is destoryed
    assign IO_HIT[1] = green_green_base |red_green_base;
    //IO_HIT[3] shows the red base is destoryed
    assign IO_HIT[3] = green_red_base |red_red_base;
    //Instantiate bullet module
      bullet bullet1(       //the bullet module of green tank
                .pixel_row(pixel_row),
                .pixel_column(pixel_column),
                .bullet(bul),                       //bullet flag         
                .bul_color(bul_color),              //12-bit bullet color (RGB code)
                .burst(burst_tr),                   //green tank hits red tank
                .burst_base_g(green_green_base),    //green tank hits green base
                .burst_base_r(green_red_base),      //green tank hits red base
                .LocX_reg(IO_BotInfo[31:24]),       
                .LocY_reg(IO_BotInfo[23:16]),
                .BotInfo_reg(IO_BotInfo[7:0]),
                .clock(clk_out75),
                .reset(CPU_RESETN),
                .biu(IO_Bullet[0]),                 //input signal to make the green tank shot
                .icon_op(icon2),                    //opponent tank icon flag(red tank)
                .world_pixel(doutb)
          );
      bullet bullet2(       //the bullet module of red tank
              .pixel_row(pixel_row),
              .pixel_column(pixel_column),
              .bullet(bul2),                        //bullet flag
              .bul_color(bul_color2),               //12-bit bullet color (RGB code)
              .burst(burst_tg),                     //red tank hits green tank
              .burst_base_g(red_green_base),        //red tank hits green base       
              .burst_base_r(red_red_base),          //red tank hits red base  
              .LocX_reg(IO_BotInfo_1[31:24]),
              .LocY_reg(IO_BotInfo_1[23:16]),
              .BotInfo_reg(IO_BotInfo_1[7:0]),
              .clock(clk_out75),
              .reset(CPU_RESETN),
              .biu(IO_Bullet[1]),                   //input signal to make the green tank shot
              .icon_op(icon),                       //opponent tank icon flag(green tank)
              .world_pixel(doutb)
              );
      //Instantiate brick_build module  
      brick_build brick_build(
                      .pixel_row(pixel_row),
                      .pixel_column(pixel_column),
                      .clock(clk_out75),
                      .reset(CPU_RESETN),
                      .brick_color(brick_color)
                      );
              
       //Instantiate Audio_PWM module     
      Audio_PWM BGM(
                           .clk(CLK100MHZ),
                           .reset(CPU_RESETN),
                           .enable1(IO_FRAME[0]),
                           .enable2(IO_FRAME[1]),
                           .AUD_PWM(AUD_PWM),
                           .AUD_SD(AUD_SD)
                          );
    //Instantiate monister module
    monister monister1(
                       .pixel_row(pixel_row), 
                       .pixel_column(pixel_column),
                       .mon_addr_r(11'd24),               //monster has the fix position, give the constant location
                       .mon_addr_c(11'd408),              
                       .mon_ori(3'b100),                  // Orientation of this monster is south 
                       .clock(clk_out75),
                       .reset(CPU_RESETN),
                       .biu(IO_Bullet[2]),                //IO_Bullet[2] controls first monster shot
                       .mon(mon1),                          
                       .mon_c(mon1_color),
                       .icon_green(icon), 
                       .icon_red(icon2),
                       .world_pixel(doutb),
                       .mon_b(mon_b1),
                       .mon_b_c(mon1_bcolor),                    
                       .burst_g(burst_g1),
                       .burst_r(burst_r1)      
                       );   
  monister monister2(
                        .pixel_row(pixel_row),
                        .pixel_column(pixel_column),
                        .mon_addr_r(11'd438),
                        .mon_addr_c(11'd976),
                        .mon_ori(3'b110),                   // Orientation of this monster is west
                        .clock(clk_out75),
                        .reset(CPU_RESETN),
                        .biu(IO_Bullet[3]),                 //IO_Bullet[3] controls second monster shot
                        .mon(mon2), 
                        .mon_c(mon2_color),
                        .icon_green(icon), 
                        .icon_red(icon2),
                        .world_pixel(doutb),
                        .mon_b(mon_b2),
                        .mon_b_c(mon2_bcolor),                    
                        .burst_g(burst_g2),
                        .burst_r(burst_r2)       
                         ); 
  monister monister3(
                        .pixel_row(pixel_row),
                        .pixel_column(pixel_column),
                        .mon_addr_r(11'd720),
                        .mon_addr_c(11'd248),
                        .mon_ori(3'b000),                   // Orientation of this monster is north
                        .clock(clk_out75),
                        .reset(CPU_RESETN),
                        .biu(IO_Bullet[4]),                 //IO_Bullet[4] controls third monster shot
                        .mon(mon3), 
                        .mon_c(mon3_color),
                        .icon_green(icon), 
                        .icon_red(icon2),
                        .world_pixel(doutb),
                        .mon_b(mon_b3),
                        .mon_b_c(mon3_bcolor),                    
                        .burst_g(burst_g3),
                        .burst_r(burst_r3)       
                         );
                
endmodule
