We have been working almost exclusively on little bibs and bobs in an effort to get you to this point. All of the eccentricities of how the 2600 works are now mostly manifest save the contents of this specific lesson: movement and input.

Much like last time, we'll be working primarily with the same OpCodes for movement but will be using them for player input as well. Also note here that the method of fine movement that doesn't require you to calculate things down to a specific degree are used. Also used are ways to display sprites and ways to position sprites.

You'll see first a lesson from Oscar Toledo's textbook. We'll follow that up with a simple movement schema that is super well commented. We'll then finish up with an example from your textbook.

>[!tip] OpCodes and Registers of Note for this section.
>So, we'll highlight some OpCodes and Registers here. If you want to read more about them, check out the VCS.h documentation on 8BitWorkshop or this brief webpage: https://problemkaputt.de/2k6specs.htm
>
>First, we will have Horizontal Motion
>`HMCLR` - All registers related to movement are cleared. These are the ones with the `HMXXX` moniker.
>`HMM0` - Horizontal Motion Missile 1
>`HMM1` - Horizontal Motion Missile 2
>`HMP0` - Horizontal Motion Player 1
>`HMP1` - Horizontal Motion Player 2 
>`HMBL` - Horizontal Motion for the Ball
>`HMOVE` - Apply Horizontal Motion
>
>Next, we get into some super important registers for resetting players. You'll need these.
>`RESP0` - Reset Position Player 1
>`RESP1` - Reset Position Player 2
>`RESM0` - Reset Position Missile 1
>`RESM1` - Reset Position Missile 2
>`RESBL` - Reset Position of the Ball
>
>Third, let's set up our registers for player graphics.
>`GRP0` - Graphics Register Player 0
>`GRP1` - Graphics Register Player 1
>`ENAM0` - Graphics Enable Missle 0
>`ENAM1` -  Graphics Enable Missile 1
>`ENABL` - Graphics Enable Ball
>
>Finally, let's learn about a few registers that allow us to use the controller.
>`SWCHA` - Joysticks / Controllers
>`SWCHB` - Front Switches (A/B Difficulty, BW/Color, Game Select, Game Reset)
>`INPT4` - Player 0 Button Pressed
>`INPT5` - Player 1 Button Pressed

I wanted to note here about `SWCHB` that it is set up in the 00000000 set as well. However, these are a little different. It goes: 
	0 = Reset
	1 = Game Select
	2 = Nothing
	3 = TV Color / BW
	4 = Nothing
	5 = Nothing
	6 = P0 Difficulty
	7 = P1 Difficulty
There is an example of how to use these in the Combat source code if you look for `DIFSWCH` as well as `SWCHB`, `SelDown`, `LDcolor`, and other labels in and around those.  Many of you are interested in using these switches in-game and so this will require you to dig in a lot more robustly as COMBAT really uses all the things. 
# Let's make More Things Move

```asm6502
; I am adjusting Oscar Toledo's work in positioning here. You can find it at: https://github.com/nanochess/book-Atari and around the chapter 3 exercises. 

	PROCESSOR 6502
	INCLUDE "vcs.h"

XPOS	= $0080		; Current X position
XDIR    = $0081         ; Current X direction
XPOS2   = $0082		; Current X position (2)
YPOS2	= $0083		; Current Y position (2)

	ORG $F000
	
START:
	SEI		; Disable interrupts.
	CLD		; Clear decimal mode.
	LDX #$FF	; X = $ff
	TXS		; S = $ff
	LDA #$00	; A = $00
CLEAR:
	STA 0,X		; Clear memory.
	DEX		; Decrement X.
	BNE CLEAR	; Branch if not zero.

	LDA #76		; Center of screen
	STA XPOS
	LDA #1		; Go to right
	STA XDIR
	LDA #1
	STA XPOS2
	LDA #20
	STA YPOS2

SHOW_FRAME:
	LDA #$88	; Blue.
	STA COLUBK	; Background color.
	LDA #$0F	; White.
	STA COLUP0	; Player 0 color.
	LDA #$cF	; Green.
	STA COLUP1	; Player 1 color.

	STA HMCLR	; Clear horizontal motion registers

	STA WSYNC
	LDA #2		; Start of vertical retrace.
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #42		; Time for NTSC top border
	STA TIM64T
	LDA #0		; End of vertical retrace.
	STA VSYNC

	LDA XPOS	; Desired X position
	LDX #0		; Player 0
	JSR x_position

	LDA XPOS2	; Desired X position
	LDX #1		; Player 1
	JSR x_position

	STA WSYNC	; Wait for scanline start
	STA HMOVE	; Write HMOVE, only can be done
			; just after STA WSYNC.

WAIT_FOR_TOP:
	LDA INTIM	; Read timer
	BNE WAIT_FOR_TOP	; Branch if not zero.
	STA WSYNC	; Resynchronize on last border scanline

	STA WSYNC
	LDA #0		; Disable blanking
	STA VBLANK

	LDX #183	; 183 scanlines in blue.
	LDY YPOS2	; Y position of fly.
SPRITE1:
	STA WSYNC	; Synchronize with scanline.
	LDA #0		; A = $00 no graphic.
	DEY		; Decrement Y.
	CPY #$F8	; Y >= $f8? (carry = 1)
	BCC L3		; No, jump if carry clear.
	LDA FLY_BITMAP-$F8,Y	; Load byte of graphic.
L3:	STA GRP1	; Update GRP1.
	DEX		; Decrease X.
	BNE SPRITE1	; Repeat until zero.

	LDX #9
	LDY #0
SPRITE0:
	STA WSYNC	; Synchronize with scanline.
	LDA #0		; A = $00 no graphic.
	DEY		; Decrement Y.
	CPY #$F8	; Y >= $f8? (carry = 1)
	BCC L4		; No, jump if carry clear.
	LDA SHIP_BITMAP-$F8,Y	; Load byte of graphic.
L4:	STA GRP0	; Update GRP0.
	DEX		; Decrease X.
	BNE SPRITE0	; Repeat until zero.

	LDA #2		; Enable blanking
	STA VBLANK
	LDX #30		; 30 scanlines of bottom border
BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM

	; Move the ship
	LDA XPOS	; A = XPOS
	CLC		; Clear carry (becomes zero)
	ADC XDIR	; A = A + XDIR + Carry
	STA XPOS	; XPOS = A
	CMP #1		; Reached minimum X-position 1?
	BEQ L1		; Branch if EQual
	CMP #153	; Reached maximum X-position 153?
	BNE L2		; Branch if Not Equal
L1:
	LDA #0		; A = 0
	SEC		; Set carry (it means no borrow for subtraction)
	SBC XDIR	; A = 0 - XDIR (reverses direction)
	STA XDIR	; XDIR = A
L2:

	; Move the fly
	LDA XPOS2	; A = XPOS2
	CLC		; Clear carry (becomes zero)
	ADC #1		; A = A + 1 + Carry
	CMP #153	; Reached X-position 153?
	BNE L5		; Branch if Not Equal
	LDA #0		; If equal, reset to zero
L5:	STA XPOS2	; XPOS2 = A

	AND #3		; Get modulo 4 of XPOS2
	ADC #20		; Add base Y-coordinate
	STA YPOS2	; YPOS2 = A

	JMP SHOW_FRAME

	;
	; Position an item in X
	; Input:
	;   A = X position (1-159)
	;   X = Object to position (0=P0, 1=P1, 2=M0, 3=M1, 4=BALL)
	;
	; The internal loop should fit a 256-byte page.
	;
x_position:		; Start cycle
	sta WSYNC	; 3: Start scanline synchro
	sec		; 5: Set carry (so SBC doesn't subtract extra)
	ldy $80		; 7: Eat 3 cycles
x_p1:
	sbc #15		; 10: Divide X by 15
	bcs x_p1	; 12: If the loop goes on, add 5 cycles each time
x_p2:
	tay		; 14:
	lda fine_adjust-$f1,y	; 18:
	sta HMP0,x	; 22: Fine position
	sta RESP0,x	; 26: Time of setup for coarse position.
	rts

x_position_end:

	; Detect code divided between two pages
	; Cannot afford it because it takes one cycle more
	if (x_p1 & $ff00) != (x_p2 & $ff00)
		echo "Error: Page crossing"
		err	; Force assembler error
        endif
	
	org $fef1	; Table at last page of ROM
			; Shouldn't cross page
fine_adjust:
	.byte $70	; 7px to left.
	.byte $60	; 6px to left.
	.byte $50	; 5px to left.
	.byte $40	; 4px to left.
	.byte $30	; 3px to left.
	.byte $20	; 2px to left.
	.byte $10	; 1px to left.
	.byte $00	; No adjustment.
	.byte $f0	; 1px to right.
	.byte $e0	; 2px to right.
	.byte $d0	; 3px to right.
	.byte $c0	; 4px to right.
	.byte $b0	; 5px to right.
	.byte $a0	; 6px to right.
	.byte $90	; 7px to right.

FLY_BITMAP:
	.byte %00000000
	.byte %01100000
	.byte %11100100
	.byte %01101000
	.byte %00010000
	.byte %00101100
	.byte %00101110
	.byte %00000100

SHIP_BITMAP:
	.byte %00100100
	.byte %11111111
	.byte %01100110
	.byte %00100100
	.byte %00111100
	.byte %00011000
	.byte %00011000
	.byte %00011000

	ORG $FFFC
	.word START
	.word START
```


# And Now, Player Movement (Single variable, vertical positioning)

```asm6502
    processor 6502

;=========================================================
; For this file, we're going to use the CLEAN_START macro.
; So remember to add the macro.h and vcs.h so you're ready.
;=========================================================
    include "vcs.h"
    include "macro.h"

;=========================================================
; We'll use an uninitialized segment at memory slot $80 
; for var declaration. We have memory for variables $80 to $FF 
; to work with, minus a few at the end if we use the stack.
;=========================================================

    seg.u Variables
    org $80
P0XPos byte        ; This will primarily be used for sprite manipulation.
; You might wonder about the "byte" there. Just imagine it's saying, "put this where it can go."
; It may become a problem if you start declaring tons of variables.

;=========================================================
; Start our ROM code segment starting at $F000 as always.
;=========================================================
    seg Code
    org $F000

Reset:
    CLEAN_START    ; Clear everything out. 

    ldx #$88       ; Set the background to a light blue 
    stx COLUBK

    ldx #$D0       ; and we need some grass.
    stx COLUPF

;=========================================================
; Here, we'll start setting up values for our variables
;=========================================================
    lda #10
    sta P0XPos     ; initialize player X coordinate

;=========================================================
; YAY! It's making our kernal happen.
;=========================================================
StartFrame:
    lda #2
    sta VBLANK     ; turn VBLANK on
    sta VSYNC      ; turn VSYNC on

;=========================================================
; 3 vertical lines of VSYNC (Can also use bne method)
;=========================================================
    REPEAT 3
        sta WSYNC  ; first three VSYNC scanlines
    REPEND
    lda #0
    sta VSYNC      ; turn VSYNC off

;=========================================================
; We're in VSYNC and can burn some cpu cycles. 
; So let's go with setting up our register for player movement.
; Note here that we're basically setting up initial position.
; We can also set up brute force and fine movement. 
;=========================================================
    lda P0XPos     ; load register A with desired X position
    and #$7F       ; AND position with $7F to fix range
    sta WSYNC      ; wait for next scanline
    sta HMCLR      ; clear old horizontal position values

    sec            ; set carry flag before subtraction
DivideLoop:
    sbc #15        ; subtract 15 from the accumulator
    bcs DivideLoop ; loop while carry flag is still set

    eor #7         ; adjust the remainder in A between -8 and 7
    asl            ; shift left by 4, as HMP0 uses only 4 bits
    asl
    asl
    asl
    sta HMP0       ; set fine position
    sta RESP0      ; reset 15-step brute position
    sta WSYNC      ; wait for next scanline
    sta HMOVE      ; apply the fine position offset

;=========================================================
; Let the TIA output the remaining 35 lines of VBLANK (37 - 2)
; You may wonder why -2 but check the two WSYNCs above.
;=========================================================
    REPEAT 35
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK     ; turn VBLANK off

;=========================================================
; Draw the 192 visible scanlines.
; We have to adjust here for our sky and our grass. 
; You can adjust if you want. This will adjust where 
; the player sprite is given the initial declaration 
; of how many scanlines we tell it to wait for.
;=========================================================
    REPEAT 160
        sta WSYNC  ; wait for 160 empty scanlines
    REPEND

    ldy #17         ; counter to draw 17 rows of player0 bitmap
DrawBitmap:
    lda P0Bitmap,Y ; load player bitmap slice of data
    sta GRP0       ; set graphics for player 0 slice

    lda P0Color,Y  ; load player color from lookup table
    sta COLUP0     ; set color for player 0 slice

    sta WSYNC      ; wait for next scanline

    dey
    bne DrawBitmap ; repeat next scanline until finished

    lda #0
    sta GRP0       ; disable P0 bitmap graphics

    lda #$FF       ; enable grass playfield
    sta PF0
    sta PF1
    sta PF2

    REPEAT 15
        sta WSYNC  ; wait for remaining 15 empty scanlines
    REPEND

    lda #0         ; disable grass playfield
    sta PF0
    sta PF1
    sta PF2

;=========================================================
; Output 30 more VBLANK overscan lines to complete our kernal
;=========================================================
Overscan:
    lda #2
    sta VBLANK     ; turn VBLANK on again for overscan
    REPEAT 30
        sta WSYNC
    REPEND

;=========================================================
; Joystick input test for P0 up/down/left/right.
; Remember here that this 8 bits is: 
; 0000 < P0 || 0000 < P1. 
; So look at this. Here, we're INCREMENTING when going
; in a positive direction. We're DECREMENTING when going
; in a negative direction. We're also only using bits 0-3 
; so this is p0 only.
;=========================================================
CheckP0Up:
    lda #%00010000	; right > left > down > up (p0). Repeat for p1.
    bit SWCHA		; So we send this to the PIA (Peripheral Interface Adaptor) register.
    bne CheckP0Down	
    inc P0XPos
    
; BIT here is interesting. It basically tests the bits of SWCHA with the bits of the A register.
; It's like doing an AND operation which is: AND (AND Accumulator with Memory). 
; AND performs a bitwise AND operation on the accumulator register (A) and an operand. 
; What does this mean? Well, if we look at SWCHA, we can see that it expects 11111111 as it's 
; Mode of knowing what direction it is going on. What BIT does then is basically set: 
; 11111111 against 00100000 resulting in >> 00100000 or MOVE UP. The reason we use BIT over AND
; is because we want to set the flags that AND does: N/Z without storing the value.

CheckP0Down:
    lda #%00100000      ; Note that this is inverse to how it is expected. This is mostly the AND thing. 
    bit SWCHA
    bne CheckP0Left
    dec P0XPos

CheckP0Left:
    lda #%01000000
    bit SWCHA
    bne CheckP0Right
    dec P0XPos

CheckP0Right:
    lda #%10000000
    bit SWCHA
    bne NoInput
    inc P0XPos
    
; So we basically constantly checking to see if something is different.
; At some point a player will move the stick and if so, what is happening?

NoInput:
    ; fallback when no input was performed

;=========================================================
; Loop to next frame
;=========================================================
    jmp StartFrame

;=========================================================
; Here are the graphic tables for our sprites. 
; These are usually separated, pixels vs sprites.
;=========================================================
P0Bitmap:
    byte #%00000000
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00010100
    byte #%00011100
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01011101
    byte #%01111111
    byte #%00111110
    byte #%00010000
    byte #%00011100
    byte #%00011100
    byte #%00011100

;=========================================================
; Lookup table for the player colors
;=========================================================
P0Color:
    byte #$00
    byte #$F6
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$F2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$C2
    byte #$3E
    byte #$3E
    byte #$3E
    byte #$24

;=========================================================
; Complete ROM size
;=========================================================
    org $FFFC
    word Reset
    word Reset
```

# Oscar Toledo's Input based on the previous

```asm6502
	;
	; Horizontal/vertical positioning demo (Chapter 3 section 5)
	;
	; by Oscar Toledo G.
	; https://nanochess.org/
	;
	; Creation date: Jun/04/2022.
	;

	PROCESSOR 6502
	INCLUDE "vcs.h"

XPOS	= $0080		; Current X position
XDIR    = $0081         ; Current X direction 
XPOS2   = $0082		; Current X position (fly)
YPOS2	= $0083		; Current Y position (fly)
XPOS3   = $0084		; Current X position (bullet)
YPOS3	= $0085		; Current Y position (bullet)
TEMP	= $0086		; Temporary variable

	ORG $F000
START:
	SEI		; Disable interrupts.
	CLD		; Clear decimal mode.
	LDX #$FF	; X = $ff
	TXS		; S = $ff
	LDA #$00	; A = $00
CLEAR:
	STA 0,X		; Clear memory.
	DEX		; Decrement X.
	BNE CLEAR	; Branch if not zero.

	LDA #76		; Center of screen
	STA XPOS
	LDA #1		; Go to right
	STA XDIR
	LDA #1
	STA XPOS2
	LDA #20
	STA YPOS2
	LDA #$ff	; Bullet hidden
	STA YPOS3

	LDA #$00	; Configure SWCHA as input
	STA SWACNT

SHOW_FRAME:
	LDA #$88	; Blue.
	STA COLUBK	; Background color.
	LDA #$0F	; White.
	STA COLUP0	; Player 0 color.
	LDA #$cF	; Green.
	STA COLUP1	; Player 1 color.

	STA HMCLR	; Clear horizontal motion registers

	STA WSYNC
	LDA #2		; Start of vertical retrace.
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #42		; Time for NTSC top border
	STA TIM64T
	LDA #0		; End of vertical retrace.
	STA VSYNC

	LDA XPOS	; Desired X position
	LDX #0		; Player 0
	JSR x_position

	LDA XPOS2	; Desired X position
	LDX #1		; Player 1
	JSR x_position

	LDA XPOS3	; Desired X position
	LDX #2		; Missile 0
	JSR x_position

	STA WSYNC	; Wait for scanline start
	STA HMOVE	; Write HMOVE, only can be done
			; just after STA WSYNC.

WAIT_FOR_TOP:
	LDA INTIM	; Read timer
	BNE WAIT_FOR_TOP	; Branch if not zero.
	STA WSYNC	; Resynchronize on last border scanline

	STA WSYNC
	LDA #0		; Disable blanking
	STA VBLANK

	LDA YPOS3
	STA TEMP

	LDX #183	; 183 scanlines in blue.
	LDY YPOS2	; Y position of fly.
SPRITE1:
	STA WSYNC	; Synchronize with scanline.
	LDA #0		; A = $00 no graphic.
	DEY		; Decrement Y.
	CPY #$F8	; Y >= $f8? (carry = 1)
	BCC L3		; No, jump if carry clear.
	LDA FLY_BITMAP-$F8,Y	; Load byte of graphic.
L3:	STA GRP1	; Update GRP1.

	DEC TEMP	; Decrement Y for missile.
	PHP		; Save processor status
	PLA		; Restore in accumulator
	STA ENAM0	; Enable/disable missile 0

	DEX		; Decrease X.
	BNE SPRITE1	; Repeat until zero.

	LDX #9
	LDY #0
SPRITE0:
	STA WSYNC	; Synchronize with scanline.
	LDA #0		; A = $00 no graphic.
	DEY		; Decrement Y.
	CPY #$F8	; Y >= $f8? (carry = 1)
	BCC L4		; No, jump if carry clear.
	LDA SHIP_BITMAP-$F8,Y	; Load byte of graphic.
L4:	STA GRP0	; Update GRP0.
	DEX		; Decrease X.
	BNE SPRITE0	; Repeat until zero.

	LDA #2		; Enable blanking
	STA VBLANK
	LDX #30		; 30 scanlines of bottom border
BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM

	; Move the ship
	LDX XPOS	; Reg. X = XPOS

	LDA SWCHA	; Read joystick.
	AND #$40	; Test left movement.
	BNE L6		; Jump if not moved.
	DEX		; If moved, decrement X.

L6:	LDA SWCHA	; Read joystick.
	AND #$80	; Test right movement.
	BNE L7		; Jump if not moved.
	INX		; If moved, increment X.
L7:
	CPX #1		; X < 1?
	BCS L8		; No, jump.
	LDX #1		; X = 1
L8:
	CPX #153	; X >= 153?
	BCC L9		; No, jump.
	LDX #152	; X = 152
L9:
	STX XPOS	; XPOS = Reg. X

	; Move and activate bullet
	LDA YPOS3	; Read current bullet Y
	CMP #$FF	; Is it active?
	BNE L10		; Yes, jump.
	LDA INPT4	; Read joystick 1 button
	BMI L11		; Jump if not pressed
	LDA #181	; Setup bullet Y
	STA YPOS3
	LDA XPOS	; Get X of spaceship
	CLC
	ADC #3		; Center bullet
	STA XPOS3	; Setup bullet X
	JMP L11

L10:	DEC YPOS3	; Decrease bullet Y
	DEC YPOS3	; Decrease bullet Y
L11:

	; Move the fly
	LDA XPOS2	; A = XPOS2
	CLC		; Clear carry (becomes zero)
	ADC #1		; A = A + 1 + Carry
	CMP #153	; Reached X-position 153?
	BNE L5		; Branch if Not Equal
	LDA #0		; If equal, reset to zero
L5:	STA XPOS2	; XPOS2 = A

	AND #3		; Get modulo 4 of XPOS2
	ADC #20		; Add base Y-coordinate
	STA YPOS2	; YPOS2 = A

	JMP SHOW_FRAME

	;
	; Position an item in X
	; Input:
	;   A = X position (1-159)
	;   X = Object to position (0=P0, 1=P1, 2=M0, 3=M1, 4=BALL)
	;
	; The internal loop should fit a 256-byte page.
	;
x_position:		; Start cycle
	sta WSYNC	; 3: Start scanline synchro
	sec		; 5: Set carry (so SBC doesn't subtract extra)
	ldy $80		; 7: Eat 3 cycles
x_p1:
	sbc #15		; 10: Divide X by 15
	bcs x_p1	; 12: If the loop goes on, add 5 cycles each time
x_p2:
	tay		; 14:
	lda fine_adjust-$f1,y	; 18:
	sta HMP0,x	; 22: Fine position
	sta RESP0,x	; 26: Time of setup for coarse position.
	rts

x_position_end:

	; Detect code divided between two pages
	; Cannot afford it because it takes one cycle more
	if (x_p1 & $ff00) != (x_p2 & $ff00)
		echo "Error: Page crossing"
		err	; Force assembler error
        endif
	
	org $fef1	; Table at last page of ROM
			; Shouldn't cross page
fine_adjust:
	.byte $70	; 7px to left.
	.byte $60	; 6px to left.
	.byte $50	; 5px to left.
	.byte $40	; 4px to left.
	.byte $30	; 3px to left.
	.byte $20	; 2px to left.
	.byte $10	; 1px to left.
	.byte $00	; No adjustment.
	.byte $f0	; 1px to right.
	.byte $e0	; 2px to right.
	.byte $d0	; 3px to right.
	.byte $c0	; 4px to right.
	.byte $b0	; 5px to right.
	.byte $a0	; 6px to right.
	.byte $90	; 7px to right.

FLY_BITMAP:
	.byte %00000000
	.byte %01100000
	.byte %11100100
	.byte %01101000
	.byte %00010000
	.byte %00101100
	.byte %00101110
	.byte %00000100

SHIP_BITMAP:
	.byte %00100100
	.byte %11111111
	.byte %01100110
	.byte %00100100
	.byte %00111100
	.byte %00011000
	.byte %00011000
	.byte %00011000

	ORG $FFFC
	.word START
	.word START
```
# Textbook Example of Movement
So for this, I'd recommend taking a look at item 14 and 15 in the 8bitworkshop IDE. These will give you a ton of examples. I'll paste in 15 here as it's got a ton of fun.

```asm6502
	    processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This example demonstrates a scene with a full-screen
; playfield, and a single sprite overlapping it.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        seg.u Variables
	org $80

PFPtr	word	; pointer to playfield data
PFIndex	byte	; offset into playfield array
PFCount byte	; lines left in this playfield segment
Temp	byte	; temporary
YPos	byte	; Y position of player sprite
XPos	byte	; X position of player sprite
SpritePtr word  ; pointer to sprite bitmap table
ColorPtr  word  ; pointer to sprite color table

; Temporary slots used during kernel
Bit2p0	byte
Colp0	byte
YP0	byte

; Height of sprite in scanlines
SpriteHeight	equ 9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	seg Code
        org $f000

Start
	CLEAN_START
; Set up initial pointers and player position        
        lda #<PlayfieldData
        sta PFPtr
        lda #>PlayfieldData
        sta PFPtr+1
        lda #<Frame0
        sta SpritePtr
        lda #>Frame0
        sta SpritePtr+1
        lda #<ColorFrame0
        sta ColorPtr
        lda #>ColorFrame0
        sta ColorPtr+1
        lda #242
        sta YPos
        lda #38
        sta XPos

NextFrame
	VERTICAL_SYNC

; Set up VBLANK timer
	TIMER_SETUP 37
        lda #$88
        sta COLUBK	; bg color
        lda #$5b
        sta COLUPF	; fg color
        lda #$68
        sta COLUP0	; player color
        lda #1
        sta CTRLPF	; symmetry
        lda #0
        sta PFIndex	; reset playfield offset
; Set temporary Y counter and set horizontal position
        lda YPos
        sta YP0		; yp0 = temporary counter
        lda XPos
        ldx #0
        jsr SetHorizPos
        sta WSYNC
        sta HMOVE	; gotta apply HMOVE
; Wait for end of VBLANK
	TIMER_WAIT
        lda #0
        sta VBLANK

; Set up timer (in case of bugs where we don't hit exactly)
	TIMER_SETUP 192
        SLEEP 10 ; to make timing analysis work out

NewPFSegment
; Load a new playfield segment.
; Defined by length and then the 3 PF registers.
; Length = 0 means stop
        ldy PFIndex	; load index into PF array
        lda (PFPtr),y	; load length of next segment
        beq NoMoreSegs	; == 0, we're done
        sta PFCount	; save for later
; Preload the PF0/PF1/PF2 registers for after WSYNC
        iny
        lda (PFPtr),y	; load PF0
        tax		; PF0 -> X
        iny
        lda (PFPtr),y	; load PF1
        sta Temp	; PF1 -> Temp
        iny
        lda (PFPtr),y	; load PF2
        iny
        sty PFIndex
        tay		; PF2 -> Y
; WSYNC, then store playfield registers
; and also the player 0 bitmap for line 2
        sta WSYNC
        stx PF0		; X -> PF0
        lda Temp
        sta PF1		; Temp -> PF1
        lda Bit2p0	; player bitmap
        sta GRP0	; Bit2p0 -> GRP0
        sty PF2		; Y -> PF2
; Load playfield length, we'll keep this in X for the loop
        ldx PFCount
KernelLoop
; Does this scanline intersect our sprite?
        lda #SpriteHeight	; height in 2xlines
        isb YP0			; INC yp0, then SBC yp0
        bcs .DoDraw		; inside bounds?
        lda #0			; no, load the padding offset (0)
.DoDraw
; Load color value for both lines, store in temp var
	pha			; save original offset
        tay			; -> Y
        lda (ColorPtr),y	; color for both lines
        sta Colp0		; -> colp0
; Load bitmap value for each line, store in temp var
	pla
	asl			; offset * 2
	tay			; -> Y
	lda (SpritePtr),y	; bitmap for first line
        sta Bit2p0		; -> bit2p0
        iny
	lda (SpritePtr),y	; bitmap for second line
; WSYNC and store values for first line
        sta WSYNC
        sta GRP0	; Bit1p0 -> GRP0
        lda Colp0
        sta COLUP0	; Colp0 -> COLUP0
        dex
        beq NewPFSegment	; end of this playfield segment?
; WSYNC and store values for second line
        sta WSYNC
        lda Bit2p0
        sta GRP0	; Bit2p0 -> GRP0
        jmp KernelLoop
NoMoreSegs
; Change colors so we can see when our loop ends
	lda #0
        sta COLUBK
; Wait for timer to finish
        TIMER_WAIT

; Set up overscan timer
	TIMER_SETUP 29
	lda #2
        sta VBLANK
        jsr MoveJoystick
        TIMER_WAIT
        jmp NextFrame

SetHorizPos
	sta WSYNC	; start a new line
        bit 0		; waste 3 cycles
	sec		; set carry flag
DivideLoop
	sbc #15		; subtract 15
	bcs DivideLoop	; branch until negative
	eor #7		; calculate fine offset
	asl
	asl
	asl
	asl
	sta RESP0,x	; fix coarse position
	sta HMP0,x	; set fine offset
	rts		; return to caller

; Read joystick movement and apply to object 0
MoveJoystick
; Move vertically
; (up and down are actually reversed since ypos starts at bottom)
	ldx YPos
	lda #%00100000	;Up?
	bit SWCHA
	bne SkipMoveUp
        cpx #175
        bcc SkipMoveUp
        dex
SkipMoveUp
	lda #%00010000	;Down?
	bit SWCHA 
	bne SkipMoveDown
        cpx #254
        bcs SkipMoveDown
        inx
SkipMoveDown
	stx YPos
; Move horizontally
        ldx XPos
	lda #%01000000	;Left?
	bit SWCHA
	bne SkipMoveLeft
        cpx #1
        bcc SkipMoveLeft
        dex
SkipMoveLeft
	lda #%10000000	;Right?
	bit SWCHA 
	bne SkipMoveRight
        cpx #153
        bcs SkipMoveRight
        inx
SkipMoveRight
	stx XPos
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        align $100; make sure data doesn't cross page boundary
PlayfieldData
	.byte  4,#%00000000,#%11111110,#%00110000
	.byte  8,#%11000000,#%00000001,#%01001000
	.byte 15,#%00100000,#%01111110,#%10000100
	.byte 20,#%00010000,#%10000000,#%00010000
	.byte 20,#%00010000,#%01100011,#%10011000
	.byte 15,#%00100000,#%00001100,#%01000100
	.byte  8,#%11000000,#%00110000,#%00110010
	.byte  4,#%00000000,#%11000000,#%00001100
	.byte 0

;; Bitmap data "standing" position
Frame0
	.byte #0
	.byte #0
;;{w:8,h:16,brev:1,flip:1};;
        .byte #%01101100;$F6
        .byte #%00101000;$86
        .byte #%00101000;$86
        .byte #%00111000;$86
        .byte #%10111010;$C2
        .byte #%10111010;$C2
        .byte #%01111100;$C2
        .byte #%00111000;$C2
        .byte #%00111000;$16
        .byte #%01000100;$16
        .byte #%01111100;$16
        .byte #%01111100;$18
        .byte #%01010100;$18
        .byte #%01111100;$18
        .byte #%11111110;$F2
        .byte #%00111000;$F4
;; Color data for each line of sprite
;;{pal:"vcs"};;
ColorFrame0
	.byte #$FF;
	.byte #$86;
	.byte #$86;
	.byte #$C2;
	.byte #$C2;
	.byte #$16;
	.byte #$16;
	.byte #$18;
	.byte #$F4;
;;
; Epilogue
	org $fffc
        .word Start
        .word Start

```