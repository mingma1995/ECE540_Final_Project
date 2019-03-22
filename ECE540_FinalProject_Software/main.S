/*
 * 	main.S for microAptiv_UP MIPS core running on Nexys A7
 * 	FPGA target board
 *
 *
 * 	Created By:		Zhe Lu
 * 	Last Modified:	03-21-2019
 *
 * 	Description:
 *  ============
 *  This program demonstrate world of tank emulator.  It is used to control the rule of this game.
 *  Such as jumping to different screen, decide which tank is win, count how many times each tank has been
 *  hitted and store the value for which is used for history.
 *
 *
 *  This program use keyboard to be input of user to control this game. It reads data from  register
 *
 *  PORT_KEYBOARD
 *
 *  either control the movement of the tank and shot bullets.
 *
 * Keyboard_w          - used to make tank1 go up
 * Keyboard_s          - used to make tank1 go down
 * Keyboard_a          - used to make tank1 go left
 * Keyboard_d          - used to make tank1 go right
 * Keyboard_i          - used to make tank2 go up
 * Keyboard_k          - used to make tank2 go down
 * Keyboard_j          - used to make tank2 go left
 * Keyboard_l          - used to make tank2 go right
 * Keyboard_leftshift  - used to make tank1 shot bullet
 * Keyboard_rightshift - used to make tank2 shot bullet
 *
 * and then give the data back to register
 *
 * PORT_BOTCTRL        - used to control tank1 movement
 * PORT_BOTCTRL_1      - used to control tank1 movement
 * PORT_BULLET         - used to control both tank shotting, 0x01 for tank1, 0x02 for tank2
 *
 * and it is used to control jump to different screen
 * Keyboard_1          - used to jump to play screen
 * Keyboard_2          - used to jump to history screen
 * Keyboard_space      - used to jump to loading screen
 *
 *Moveover, it will read data from register
 *
 *PORT_HIT - used to show which tank is hitted and which tank's base is hitted.
 * 	         PORT_HIT[3] - red tank base is hitted.  PORT_HIT[2] - red tank is hitted.
 *           PORT_HIT[1] - green tank base is hitted.  PORT_HIT[0] - green tank is hitted.
 *
 * to count how may tank is hitted, check base is hitted or not and then detect which tank is win.
 *
 *Also it will give register
 *PORT_FRAME - used to control which screen should be displayed
 *PORT_HISTORY - used to control which tank should be shown in history screen
 * 	         PORT_HISTORY[5:4] - third game history.
 *           PORT_HISTORY[3:2] - second game history.
 *           PORT_HISTORY[1:0] - first game history.
 *
 *by using
 *
 * Screen_loading		- value to display loading screen
 * Screen_play			- value to display play screen
 * Screen_green_win		- value to display green_win screen
 * Screen_red_win		- value to display red_win screen
 * Screen_history		- value to display history screen
 */
# value of each key of the keyboard
Keyboard_w          = 0x1d
Keyboard_s          = 0x1b
Keyboard_a          = 0x1c
Keyboard_d          = 0x23
Keyboard_i          = 0x43
Keyboard_k          = 0x42
Keyboard_j          = 0x3b
Keyboard_l          = 0x4b
Keyboard_leftshift  = 0x12
Keyboard_rightshift = 0x59
Keyboard_1          = 0x16
Keyboard_2          = 0x1e
Keyboard_space      = 0x29
MSKORIENT           = 0x07

# ======================
# === Port Addresses ===
# ======================

# Nexys 4 board base I/O interface ports compatible with the Nexy$4 I/O interface
# Port Addresses
PORT_KEYBOARD 		= 0xbf800008		# (i) pushbuttons inputs

PORT_BOTINFO		= 0xbf80000c		# (i) Bot Info port
PORT_BOTCTRL		= 0xbf800010		# (o) Bot Control port
PORT_BOTUPDT		= 0xbf800014		# (i) Bot Update port (Poll)
PORT_INTACK			= 0xbf800018		# (o) Bot Int Ack

PORT_BOTINFO_1		= 0xbf80001c		# (i) Bot Info port
PORT_BOTCTRL_1		= 0xbf800020		# (o) Bot Control port
PORT_BOTUPDT_1		= 0xbf800024		# (i) Bot Update port (Poll)
PORT_INTACK_1		= 0xbf800028		# (o) Bot Int Ack

PORT_BULLET			= 0xbf800038		#(o) Shot bullet Control port
PORT_HIT			= 0xbf80002c		#(i) Detecting which tank or base is hitted port
PORT_FRAME 			= 0xbf800030		#(o) Screen Control port
PORT_HISTORY		= 0xbf800034 		#(o) Tank display control port for histroy screen
# Value to screen control port to display each screen
Screen_loading		= 0x01
Screen_play			= 0x02
Screen_green_win	= 0x04
Screen_red_win		= 0x08
Screen_history		= 0x10
.data
.align 2    # Put next label on a word boundary


# stack for scrren control to store which screen should be displayed
SP_SCREEN:	.byte   0
# stack for stroing how many times the tank has been hitted
SP_GREEN_HITTED: .byte  0
SP_RED_HITTED: .byte 0
# stack for storing flag of each time the tank has been hitted
SP_GREEN_HITTED_TIME: .byte 0
SP_RED_HITTED_TIME: .byte 0
# stack for storing the which tank is win in history
SP_GAME_1: .byte 0
SP_GAME_2: .byte 0
SP_GAME_3: .byte 0


.text
.globl main
main:

				li	  $5, Screen_loading   			#first give the screen stroge stack value for loading scrren
			    sb    $5,  SP_SCREEN				#store the value to stack
main_1:
				lb    $5,  SP_SCREEN				#at the beginning of loop, load the value from stack to tell which screen it should be
				jal   Screen						#call function to store the value to register to control screen
				li    $4, Screen_loading
				beq   $5, $4, check_tab_1			#if it is in loading screen, go to check_tab_1 to read value from keyboard
				li    $4, Screen_play
				beq   $5, $4, play_screen			#if it is in play screen, go to play screen to read value from user to control tank
				li    $4, Screen_green_win
				beq   $5, $4, check_tab_2			#if it is in green win screen, go to check_tab_2 to read value from keyboard
				li    $4, Screen_red_win
				beq   $5, $4, check_tab_2			#if it is in red win screen, go to check_tab_2 to read value from keyboard
				li    $4, Screen_history
				beq   $5, $4, check_tab_3			#if it is in history screen, go to check_tab_3 to read value from keyboard
				j     loop
				nop
check_tab_1:
				jal   Keyboard						#call function to read value from keyboard
				li	  $23, 0x00ff					#mask lowest two bits
				and   $6, $4, $23					#just show lowest two bits for using
				li    $5, Keyboard_1				#if the input value is key 1
				beq   $6, $5, j_screen_2			#go to play screen
				li    $5, Keyboard_2				#if the input value is key 2
				beq   $6, $5, j_screen_5			#go to history screen
				j  	  loop							#if no any input, stay loading screen
				nop
check_tab_2:
				jal   Keyboard						#call function to read value from keyboard
				li	  $23, 0x00ff					#mask lowest two bits
				and   $6, $4, $23					#just show lowest two bits for using
				li    $5, Keyboard_space			#if the input value is key space
				beq   $6, $5, main					#go to loading screen
				j  	  loop							#if no any input, stay either tank win screen
				nop
check_tab_3:
				jal   Keyboard						#call function to read value from keyboard
				li	  $23, 0x00ff					#mask lowest two bits
				and   $6, $4, $23					#just show lowest two bits for using
				li    $5, Keyboard_space			#if the input value is key space
				beq   $6, $5, main					#go to loading screen
				j  	  loop							#if no any input, stay history screen
				nop
j_screen_1:
				li    $8, Screen_loading			#give the value for going to loading screen
				sb    $8, SP_SCREEN					#give this value to register to enable this screen
				j     loop
				nop
j_screen_2:
				li    $8, Screen_play				#give the value for going to play screen
				sb    $8, SP_SCREEN					#give this value to register to enable this screen
				j     loop
				nop
j_screen_5:
				li    $8, Screen_history			#give the value for going to history screen
				sb    $8, SP_SCREEN					#give this value to register to enable this screen
				lb    $5, SP_GAME_1					#load value from fisrt game history stack
				lb    $6, SP_GAME_2					#load value from second game history stack
				lb    $7, SP_GAME_3					#load value from third game history stack
				sll   $6, $6, 2
				or    $5, $5, $6
				sll   $7, $7, 4
				or    $5, $5, $7					#or this three value and shift them to correct bits
				li    $25, PORT_HISTORY				#load the PORT_HISTORY
				sw    $5, 0($25)					#store the value to this register to enable which tank should be display
				j     loop
				nop
play_screen:
				li    $5,  0x1c						#give value for monsters shoting
				li 	  $25, PORT_BULLET				#load value for PORT_BULLET register
				sw	  $5, 0($25)					#give value to this regiser make monsters shotting automatically
				beq   $0, $0, Players_control		#check user input to control tank movement and shotting
Check_Hitted:
				beq   $0, $0, GREEN_HITTED			#check either tank or base is hitted
loop:
				beq   $0,$0,main_1					#	} end of the loop


#==================================================================================
Players_control:
				jal	  Keyboard						#call function to read value from keyboard
				li	  $23, 0x00ff					#mask lowest two bits
				and   $6, $4, $23					#just show lowest eight bits for using
				li 	  $23, Keyboard_w
				beq   $6, $23, Player_1				#if the player input is key w,go to check orientation
				li 	  $23, Keyboard_s
				beq	  $6, $23, Player_1				#if the player input is key s,go to check orientation
				li 	  $23, Keyboard_a
				beq	  $6, $23, Player_1				#if the player input is key a,go to check orientation
				li 	  $23, Keyboard_d
				beq	  $6, $23, Player_1				#if the player input is key d,go to check orientation
				li    $3, 0x00						#rather than, let tank stop
				beq   $0, $0, Player_1_next
Player_1:
				jal   expect_orient_1				#call function to generate which orientation user want tank to move
				jal   check_orient_1				#compare with current orientation, ture - go forward, false - turn left until they are same
Player_1_next:
				li 		$25, 	PORT_BOTCTRL		#give value to register to make tank move
				sw		$3,		0($25)

				li      $23, Keyboard_leftshift		#check key left shift is pressed or not
				beq     $6, $23, shot_1				#if ture, shot bullet
				li      $5, 0x00					#if false, don't shot
				beq     $0, $0,   shot_1_next
shot_1:			li		$5, 0x01
shot_1_next:
				li 		$25, 	PORT_BULLET			#store value to register to FPGA
				sw		$5,		0($25)
				nop
#=============================================================================================
				jal	    Keyboard					#call function to read value from keyboard
				srl	    $4, $4, 8					#right shift highest eight bits to lowest
				li 	   $23, Keyboard_i				#if the player input is key i,go to check orientation
				beq    $4, $23, Player_2
				li 	   $23, Keyboard_k				#if the player input is key k,go to check orientation
				beq	   $4, $23, Player_2
				li 	   $23, Keyboard_j				#if the player input is key j,go to check orientation
				beq	   $4, $23, Player_2
				li 	   $23, Keyboard_l				#if the player input is key l,go to check orientation
				beq	   $4, $23, Player_2
				li     $3, 0x00						#rather than, let tank stop
				beq    $0, $0, Player_2_next
				nop
Player_2:
				jal     expect_orient_2				#if the player input is key d,go to check orientation
				jal     check_orient_2				#compare with current orientation, ture - go forward, false - turn left until they are same
				nop
Player_2_next:
				li 		$25, 	PORT_BOTCTRL_1		#give value to register to make tank move
				sw		$3,		0($25)

				li      $23, Keyboard_rightshift	#check key right shift is pressed or not
				beq     $4, $23, shot_2				#if ture, shot bullet
				li      $5, 0x00					#if false, don't shot
				beq     $0, $0,   shot_2_next
shot_2:			li		$5, 0x02
shot_2_next:
				li 		$25, 	PORT_BULLET			#store value to register to FPGA
				sw		$5,		0($25)

				beq     $0, $0,   Check_Hitted		#go to check hit label to check either tank or base is hitted
				nop
# ==============================================================================================
# function used to load value from keyboard
# =================================================================================================
Keyboard:
				li		$25,		PORT_KEYBOARD
				lw		$4, 	0($25)
				jr 		$ra
				nop
#===================================================================================================
# function usd to give value to screen control port
#===================================================================================================
Screen:
				li	  	$25, PORT_FRAME
				sw    	$5, 0($25)
				jr 		$ra
				nop
#=-=============================================================================================
# function used to load value from hit port register to indicate which tank or base is hitted
#=-=============================================================================================
HITTED:
				li    	$25, PORT_HIT
				lw    	$4, 0($25)
				jr 		$ra
				nop
#===============================================================================================
# function used to check which orientation user want the tank1 to be
#===============================================================================================
expect_orient_1:
				li 	   	$23, Keyboard_w				#if the player input is key w,go change expect orientation to north
				beq    	$6, $23, Up_1
				li 	   	$23, Keyboard_s				#if the player input is key s,go change expect orientation to south
				beq	   	$6, $23, Down_1
				li 	   	$23, Keyboard_a				#if the player input is key a,go change expect orientation to west
				beq	   	$6, $23, Left_1
				li 	   	$23, Keyboard_d				#if the player input is key d,go change expect orientation to east
				beq	   	$6, $23, Right_1
				jr 		$ra
Up_1:
				li 	   	$2, 0x00					#value for orientation north
				jr 		$ra
Down_1:
				li 	   	$2, 0x04					#value for orientation south
				jr 		$ra
Left_1:
				li 	   	$2, 0x06					#value for orientation west
				jr 		$ra
Right_1:
				li 	  	$2, 0x02					#value for orientation east
				jr 		$ra
#===============================================================================================
# function used to check current orientation is same as expect orientation or not for tank 1
# ture, go forward
# false, turn left until it be ture
#===============================================================================================
check_orient_1:
				li    	$13, PORT_BOTINFO			#Load the BotInfo port address
				lw 	  	$21, 0($13)					#Read the BotInfo Register
				and	  	$21,	$21, MSKORIENT		#mask of the unused bits
				beq   	$2, $21, go_forward_1		#if the current orientation is same as expect orientation, tank go forward
				li 	   	$3, 0x45					#otherwise turn left 90 degree until they are same
				jr 		$ra
go_forward_1:
				li 	   	$3, 0xff					#value for moving forward
				jr 		$ra
#===============================================================================================
# function used to check which orientation user want the tank2 to be
#===============================================================================================
expect_orient_2:
				li 	   	$23, Keyboard_i				#if the player input is key i,go change expect orientation to north
				beq    	$4, $23, Up_2
				li 	   	$23, Keyboard_k				#if the player input is key k,go change expect orientation to south
				beq	   	$4, $23, Down_2
				li 	   	$23, Keyboard_j				#if the player input is key j,go change expect orientation to west
				beq	   	$4, $23, Left_2
				li 	   	$23, Keyboard_l				#if the player input is key l,go change expect orientation to east
				beq	   	$4, $23, Right_2
				jr 		$ra
Up_2:
				li 	    $2, 0x00					#value for orientation north
				jr 		$ra
Down_2:
				li 	   	$2, 0x04					#value for orientation south
				jr 		$ra
Left_2:
				li 	   	$2, 0x06					#value for orientation west
				jr 		$ra
Right_2:
				li 	   	$2, 0x02					#value for orientation east
				jr 		$ra
#===============================================================================================
# function used to check current orientation is same as expect orientation or not for tank 2
# ture, go forward
# false, turn left until it be ture
#===============================================================================================
check_orient_2:
				li    	$13, PORT_BOTINFO_1			#Load the BotInfo port address
				lw 	  	$21, 0($13)					#Read the BotInfo Register
				and	  	$21,	$21, MSKORIENT		#mask of the unused bits
				beq   	$2, $21, go_forward_2		#if the current orientation is same as expect orientation, tank go forward
				li 	   	$3, 0x45					#otherwise turn left 90 degree until they are same
				jr 		$ra
go_forward_2:
				li 	   	$3, 0xff					#value for moving forward
				jr 		$ra
#==================================================================================================
GREEN_HITTED:
				li    	$23, PORT_HIT
				lw    	$8, 0($23)					#load value from register hit port to check tank 1 is hitted
				li	  	$9, 0x01
				and   	$8, $9, $8
				beq   	$8, $0, ADD_GREEN_TIME		#if tank 1 is not hitted, go and add tank 1 hitted time
				li   	$4, 0x01
				sb   	$4, SP_GREEN_HITTED_TIME	#if tank 1 is hitted, store true to hitted flag
				beq  	$0, $0, GREEN_BASE_HITTED	#and add hitted time until the hitted signal to low
#==================================================================================================
ADD_GREEN_TIME:
				lb   	$11, SP_GREEN_HITTED_TIME	#load value from hitted flag
				beq  	$11, $0, GREEN_BASE_HITTED	#if the flag is flase, go check base is hitted
				lb   	$9, SP_GREEN_HITTED			#if the flag is true, load from from tank 1 hitted time stack
				addi 	$9, $9, 0x01				#add 1 more time
				sb   	$9, SP_GREEN_HITTED			#store the time number back to stack
				sb   	$0, SP_GREEN_HITTED_TIME	#clean up the flag stack
				li   	$10, 0x03					#if the hitted time is equal to 3, say tank 2 is win
				beq  	$9, $10, win_red			#go to tank 2 win screen
				beq  	$0, $0, GREEN_BASE_HITTED	#if not, go check tank 1 base is hitted or not
#==================================================================================================
GREEN_BASE_HITTED:
				li    	$23, PORT_HIT				#load value from register hit port to check tank 1 base is hitted
				lw    	$8, 0($23)
				li	  	$9, 0x02
				and   	$8, $9, $8
				beq   	$8, $9, win_red				#if it is hitted, go to red win screen
				beq  	$0, $0,RED_HITTED			#if not, go check tank 2 is hitted or not
#==================================================================================================
RED_HITTED:
				li    	$23, PORT_HIT				#load value from register hit port to check tank 2 is hitted
				lw    	$8, 0($23)
				li	  	$9, 0x04
				and   	$8, $9, $8
				beq   	$8, $0, ADD_RED_TIME		#if tank 2 is not hitted, go and add tank 2 hitted time
				li   	$4, 0x01
				sb   	$4, SP_RED_HITTED_TIME		#if tank 2 is hitted, store true to hitted flag
				beq  	$0, $0, RED_BASE_HITTED		#and add hitted time until the hitted signal to low
ADD_RED_TIME:
				lb   	$11, SP_RED_HITTED_TIME		#load value from hitted flag
				beq  	$11, $0, RED_BASE_HITTED	#if the flag is flase, go check base is hitted
				lb   	$9, SP_RED_HITTED			#if the flag is true, load from from tank 2 hitted time stack
				addi 	$9, $9, 0x01				#add 1 more time
				sb   	$9, SP_RED_HITTED			#store the time number back to stack
				sb   	$0, SP_RED_HITTED_TIME		#clean up the flag stack
				li   	$10, 0x03					#if the hitted time is equal to 3, say tank 1 is win
				beq  	$9, $10, win_green			#go to tank 1 win screen
				beq  	$0, $0, RED_BASE_HITTED		#if not, go check tank 2 base is hitted or not
#==================================================================================================
RED_BASE_HITTED:
				li    	$23, PORT_HIT				#load value from register hit port to check tank 2 base is hitted
				lw    	$8, 0($23)
				li	  	$9, 0x08
				and   	$8, $9, $8
				beq   	$8, $9, win_green			#if it is hitted, go to green win screen
				beq  	$0, $0,loop					#if not, go back to loop to wait either one is hitted
#==================================================================================================
win_red:
				li    	$5, Screen_red_win			#give value to register to go to red win screen
				sb    	$5, SP_SCREEN
				lb    	$6, SP_GAME_1				#load value from first game results stack
				lb    	$7, SP_GAME_2				#load value from second game results stack
				sb 	  	$6, SP_GAME_2				#store value from first game results stack to second game results stack
				sb 	  	$7, SP_GAME_3				#store value from second game results stack to third game results stack
				li    	$6, 0x02					#give the value to show red tank is win
				sb    	$6, SP_GAME_1				#store value to first game results stack
				sb    	$0, SP_RED_HITTED			#clean up red tank hitted time stack
				sb    	$0, SP_GREEN_HITTED			#clean up green tank hitted time stack
			    beq  	$0, $0, loop
#==================================================================================================
win_green:
				li    	$5, Screen_green_win		#give value to register to go to red win screen
				sb    	$5, SP_SCREEN
				lb    	$6, SP_GAME_1				#load value from first game results stack
				lb    	$7, SP_GAME_2				#load value from second game results stack
				sb 	  	$6, SP_GAME_2				#store value from first game results stack to second game results stack
				sb 	  	$7, SP_GAME_3				#store value from second game results stack to third game results stack
				li    	$6, 0x01					#give the value to show green tank is win
				sb    	$6, SP_GAME_1				#store value to first game results stack
				sb    	$0, SP_RED_HITTED			#clean up red tank hitted time stack
				sb    	$0, SP_GREEN_HITTED			#clean up green tank hitted time stack
			    beq 	$0, $0, loop
#==================================================================================================

