---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

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
>Finally, let's set up our registers for player graphics.
>`GRP0` - Graphics Register Player 0
>`GRP1` - Graphics Register Player 1
>`ENAM0` - Graphics Enable Missle 0
>`ENAM1` -  Graphics Enable Missle 1
>`ENABL` - Graphics Enable Ball
#  Let's talk about Sprites
So, we're going to start getting ourselves into creating little graphics for our players. From here, we'll be making it move, adding some enemies, adding an ability to shoot bullets, and more. 

We're going to begin by doing this in the most inefficient way possible and we'll start layering things on so we can figure out everything from Sprites to movement to balls to enemy movement. 

```asm6502
		PROCESSOR 6502
		INCLUDE "vcs.h"
        INCLUDE "macro.h"
        
        SEG Variables
        ORG $80

XPOS	= $0080		; Current X position
XDIR    = $0081         ; Current X direction

;============================
; We're setting up 2 variables first. 
; You can see the intent behind them.
; But constants like this are done before
; we set up the code block declaration.
;============================

    SEG code
	ORG $F000
        
;============================
; I'm going to use CLEAN_START but when you
; make your own games, it may depend on your cycle 
; counting.
;============================
        
START: CLEAN_START

;============================
; Note that we're setting up our variable values.
; 76 is near our center given a max area of 160. 
; 2 fewer pixels on either side will help us with 
; edge cases. We'll talk about 2's compliment soon
; because we're setting a 1 to direction.
;============================

	LDA #76		; Center of screen
	STA XPOS
	LDA #1		; Go to right
	STA XDIR
        
;============================
; Alright, we're now getting into our kernel.
; We will set up the color of the background
; Then the color of player 1
;============================

SHOW_FRAME:
	LDA #$90	; Blue.
	STA COLUBK	; Background color.
	LDA #$FF	; White.
	STA COLUP0	; Player 0 color.
        
;============================
; Next, we're going to make sure we reset the registers for movement.
; It is important to do this because of some of our fine tuning needs constant updating.
; Note the fine tuning all the way in line 193 "fine tuning."
;============================

	STA HMCLR	; Clear horizontal motion registers
        
;============================
; And now we're getting into our VSYNC
;============================

	STA WSYNC
	LDA #2		; We need to get ourselves into VSYNC
	STA VSYNC   ; Then head on down 3 lines.
	STA WSYNC   ; Then head on down 3 lines.
	STA WSYNC   ; Then head on down 3 lines.
	STA WSYNC   ; Then head on down 3 lines.
	LDA #0		; End of vertical retrace.
	STA VSYNC
        
;============================
; We'll reset the player position to basically neutral. 
; Note here that we're basically going to 0 so we can keep the fine tuning going. 
; if you want to watch this variable, look at it in the 0-age.
;============================

	LDA XPOS	; Desired X position
	LDX #0		; Player 0

	STA WSYNC	; Wait for scanline start
	STA HMOVE	; Write HMOVE, only can be done just after STA WSYNC.
                        
;============================
; So note that we're writing HMOVE just after a WSYNC.
; Think of this as telling the TIA to wait til the start of a scanline
; to start fine tuning movement.
;============================

	LDX #34		; Remains 34 scanline of top border
        
TOP:
	STA WSYNC
	DEX
	BNE TOP
	LDA #0		; Disable blanking
	STA VBLANK
        
;============================
; Now we're in visible lines.
;============================

	LDX #183	; 183 scanlines in blue
VISIBLE:
	STA WSYNC
	DEX
	BNE VISIBLE

;============================
; So you may wonder why we're basically going down ONLY 183 lines. 
; The remaining 9 are reserved for the player sprite.
; We will do it this way first and then talk about "sprites" later.
; I'll add the binary values where I can.
;============================

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$3c	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value. 
	STA GRP0.   ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$66	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$ff	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value.
	STA GRP0    ; (What is the hex above as binary?)

	STA WSYNC	; One scanline
	LDA #$00	; And this one is blank.
	STA GRP0	; Change it up and see what happens.

	LDA #2		; Enable blanking
	STA VBLANK	; And so we get ourselves to the bottom.
	LDX #30		; 30 scanlines of bottom border

BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM
	
	JMP SHOW_FRAME

	ORG $FFFC
	.word START
	.word START
```

So now we got a sprite on screen, let's think about moving it! How do...we do that?

# Two's Compliment
Two's complement and the way the 2600 affords for its expression is how you represent the numbers  0 to 255 as -128 to +127. We need negative numbers for things like movement schema and for other reasons we'll get to as time allows. 

Now, the numbers 0->127 are represented the same way in binary / hex. So, if you only need to deal with positive numbers then there is not much of a space to get confused. Where problems begin is with negative numbers. This is weird!!! I know I say this a lot in this class. 

In the 2600, the far left or upper bit of the number is the sign and so we have 0xxxxxxx for a positive number and 1xxxxxxx as a negative number. Now, it isn't that easy!!!

A normal person might think that -1 would simply be represented as 10000001. However, this is not correct because we're not in normal spaces. Think of it like this,  there would be two zero values (+0 and -0). 

So what the 2600 wants Instead is when we convert a number into its negative, you invert the bits and add 1, so -1 becomes 11111111, which is 255 normally. 

This scheme is very clever as it does not require any extra hardware to cope with negative numbers, but can be a pain from a programming perspective.

# Rough Positioning
So for the most part, we have to think about how the TIA works in order to really understand what positioning is actually doing. In this case, we're basically doing 2 operations: Rough or Brute Force Positioning and that is quickly followed by a fine positioning on the X-Axis. 

Think about it this way. The TIA has a number of cycles and for every 3 TIA cycles, there is 1 CPU cycle. This works out in very weird and interesting ways. See the timing image below: 

![[tiacpupf-timing.png]]

So, think of it like this: 
	1. We need to tell the TIA to wait for a new scanline with a `WSYNC`
	2. Once that is done, we wait for the new scanline AND THEN have to wait cycles before that object can appear. 
	3. Once we have blown through the desired cycles, we write to `RESP0` (or `RESP1`) for the correct position. 
		* This is basically resetting the P0 register for the current value. 
	4. This can be written: $$CPU Cycles to Wait for XpositionAfterWSYNC = \frac{(X+68)}{3}$$
So, you might wonder why it's `X+68`. Note the image above. This `HBLANK` space is 68 cycles long before the CRT registers the line in visible spaces. It is aligning the system constantly. We divide by 3 because 1 CPU Clock Cycle is = 3 TIA Cycles. And so we're working with CPU cycles and need to accommodate for all the things.

Take the image below. There is a part of our resolution that is the "Horizontal Blank" which requires us to take some time after a WSYNC for the cathode ray tube to get to an area that we can see. So, if we take the below, we need to basically burn 68 cycles on the TIA to get us to the viewable space. However, in order for us to get to 68, we have to think in terms of CPU cycles. For every 3 TIA cycles, we have 1 CPU cycle to think about. 

So the below does 5 CPU cycles, 15 TIA cycles per loop. If we run through it 5 times, we get to 75 TIA Cycles. So, we can't really begin on the far left which is why we tend to originate our movable objects in the middle of the screen and send it in one direction. 

![[Pasted image 20250223114103.png]]
![[Pasted image 20250222163747.png]]
While these images may make intuitive sense, it might not show up for you until it does. However, the opportunity here is to consider that starting with counting cycles and working it into your workflow becomes more and more important. 
### Caveats 
We are stuck with Brute Forcing our Horizontal Register because there is no coordinate system we can rely on. This is by far, the most annoying thing about writing for this console. From the above, most times with movement we will end up with a very awkward number leftover (usually 15) which will then create the very coarse movement structure. However! There are additional pins or things to worry about on the console. This is where we're allowed to do a bit more fine tuning. 
# Fine Positioning
There are 5 objects that the 2600 allows the creator or designer to move around. These are also graphically represented so consider: Player0 / Player1 / Missile0 / Missile1 / Ball. Movement happens relative to their current horizontal position. For each object, there are 4-bit horizontal motion registers to help smooth out movement: `HMP0`, `HMP1`, `HMM0`, `HMM1`, `HMBL`. These values can be set with a value between -8 to 7. Here is where we have to think about two's complement. The actual motion is not executed until we strobe the `HMOVE` register.

The sort of path we need to worry about here is basically, 
1. Get ourselves into our 15-pixel brute force movement. 
2. Mathematically get ourselves to a situation where we can convert numbers to +7 > -8 dynamically.

What this does or how this can be done is generally like this: 
1. Wait for a new scanline or `WSYNC`
2. Get yourself into a space where you can use the brute force or coarse movement to feed into the fine tuning. 
3. Send that data to `RESP0` through the `HMP0` register.

In the items here, we're doing it one way. But there are others.
## Caveat
Not all objects position exactly the same. Recently, the community has had some interesting discoveries with regard to the ways that the TIA warps those movable objects in different ways. We'll get into that soon but basically we ahve double-wide and quad-wide player sprites. What the community discovered is that it tends to shift the processor +1 color clock. This is in juxtaposition to missiles and the ball shift -1 color clock.

The example the community tends to use to describe this is the game River Raid. The designer compensate for this by taking things like a quad-wide bridge sprite and setting it to an x-position of 63 (instead of 64) before its fine-positioning subroutine is called. This quirk will shift the bridge +1 color clock and draw it at the intended x-position of 64.

So now let's talk about Fine Positioning.

![[Pasted image 20250222164220.png]]

![[Pasted image 20250222164630.png]]

# Exercise - Movement Objects

```asm
;============================
; This will demonstrate how to get things moving.
; Over time, we'll mix and match with this to allow
; Player input as well.
;============================

;============================
;Checklist
;1. Sprites
;2. Movement
;3. Fine Tuning
;4. Player Input
;============================

	PROCESSOR 6502
	INCLUDE "vcs.h"
        INCLUDE "macro.h"
        
        SEG Variables
        ORG $80

XPOS	= $0080		; Current X position
XDIR    = $0081     ; Current X direction

;============================
; We're setting up 2 variables first. 
; You can see the intent behind them.
; But constants like this are done before
; we set up the code block declaration.
;============================

    SEG code
	ORG $F000
        
;============================
; I'm going to use CLEAN_START but when you
; make your own games, it may depend on your cycle 
; counting.
;============================
        
START: CLEAN_START

;============================
; Note that we're setting up our variable values.
; 76 is near our center given a max area of 160. 
; 2 fewer pixels on either side will help us with 
; edge cases. 
; We'll talk about 2's compliment soon because we're setting a 1 to direction.
; And by soon, I mean in this program as we flesh it out.
;============================

	LDA #76		; Center of screen
	STA XPOS
	LDA #1		; Go to right
	STA XDIR
        
;============================
; Alright, we're now getting into our kernel.
; We will set up the color of the background
; Then the color of player 1
;============================

SHOW_FRAME:
	LDA #$90	; Blue.
	STA COLUBK	; Background color.
	LDA #$FF	; White.
	STA COLUP0	; Player 0 color.
        
;============================
; Next, we're going to make sure we reset the registers for movement.
; It is important to do this because of some of our fine tuning needs constant updating.
; Note the fine tuning all the way in line 193 "fine tuning."
;============================

	STA HMCLR	; Clear horizontal motion registers
        
;============================
; And now we're getting into our VSYNC
;============================

	STA WSYNC
	LDA #2		; We need to get our Vsync active. 
	STA VSYNC   ; Then we move things down 3 WSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #0		; And turn it off!
	STA VSYNC
        
;============================
; We'll reset the player position to basically neutral. 
; Note here that we're basically going to 0 so we can keep the fine tuning going. 
; if you want to watch this variable, look at it in the 0-age.
;============================

	LDA XPOS	; Desired X position
	LDX #0		; Player 0
	JSR x_position

	STA WSYNC	; Wait for scanline start
	STA HMOVE	; Write HMOVE, only can be done
			    ; just after STA WSYNC.
                        
;============================
; So note that we're writing HMOVE just after a WSYNC.
; Think of this as telling the TIA to wait til the start of a scanline
; to start fine tuning movement.
;============================

	LDX #34		; Remains 34 scanline of top border
        
TOP:
	STA WSYNC
	DEX
	BNE TOP
	LDA #0		; Disable blanking
	STA VBLANK
        
;============================
; Now we're in visible lines.
;============================

	LDX #183	; 183 scanlines in blue

VISIBLE:
	STA WSYNC
	DEX
	BNE VISIBLE

;============================
; So you may wonder why we're basically going down ONLY 183 lines. 
; The remaining 9 are reserved for the player sprite.
; We will do it this way first and then talk about "sprites" later.
; I'll add the binary values where I can.
;============================

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0	; You'll see that this is the top. 

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$3c	; Play around with this value. 00111100
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$66	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$ff	; Play around with this value. #%11111111
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$00	; And this one is blank.
	STA GRP0	; Change it up and see what happens.

	LDA #2		; Enable blanking
	STA VBLANK	; And so we get ourselves to the bottom.
	LDX #30		; 30 scanlines of bottom border

;============================
; We have a kernel, we have a sprite. Now we're doing our overscan.
; But notice here that we're actually doing some calculations here in order to get our min and max x values in order.
;============================

BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM

	LDA XPOS	; A = XPOS
	CLC		; Clear carry (C flag in P register becomes zero)
	ADC XDIR	; A = A + XDIR + Carry
	STA XPOS	; XPOS = A
	CMP #1		; Reached minimum X-position 1?
	BEQ L1		; Branch if EQual
	CMP #153	; Reached maximum X-position 153?
	BNE L2		; Branch if Not Equal

;============================
; Here, we might talk about how he's doing some work in and around negative or signed numbers.
;============================

L1:
	LDA #0		; A = 0
	SEC		; Set carry (it means no borrow for subtraction)
	SBC XDIR	; A = 0 - XDIR (reverses direction)
	STA XDIR	; XDIR = A

L2:
	JMP SHOW_FRAME

;============================
; Position an item in X
; Input:
;   A = X position (1-159)
;   X = Object to position (0=P0, 1=P1, 2=M0, 3=M1, 4=BALL)
;
; The internal loop should fit a 256-byte page.
;============================		

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
        
;============================
; We need to arrange this fine adjustment in an effort to keep the memory in place.
; We do this by declaring where this table exists and we learn how to start it by counting bytes and then getting our memory in place.
; At the moment, this is here to help us out for future work. 
; You can remove it entirely and it don't do nothing, for example.
;============================	

x_position_end:

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

	ORG $FFFC
	.word START
	.word START
```

# Movement in the new style
We'll have to do some more adjusting; specificially, for things getting us toward the other direction. How would you do it? 

Also note, what if you `INC XPOS` more than once?

```asm
;============================
; This will demonstrate how to get things moving.
; Over time, we'll mix and match with this to allow
; Player input as well.
;============================

	PROCESSOR 6502
	INCLUDE "vcs.h"
        INCLUDE "macro.h"
        
        SEG Variables
        ORG $80

XPOS	= $0080		; Current X position
XDIR    = $0081     	; Current X direction

;============================
; We're setting up 2 variables first. 
; You can see the intent behind them.
; But constants like this are done before
; we set up the code block declaration.
;============================

    	SEG code
	ORG $F000
        
;============================
; I'm going to use CLEAN_START but when you
; make your own games, it may depend on your cycle 
; counting.
;============================
        
START: CLEAN_START

;============================
; Note that we're setting up our variable values.
; 76 is near our center given a max area of 160. 
; 2 fewer pixels on either side will help us with 
; edge cases. 
; We'll talk about 2's compliment soon because we're setting a 1 to direction.
; And by soon, I mean in this program as we flesh it out.
;============================

	LDA #80		; Center of screen
	STA XPOS
	LDA #1		; Go to right
	STA XDIR
        
;============================
; Alright, we're now getting into our kernel.
; We will set up the color of the background
; Then the color of player 1
;============================

SHOW_FRAME:

	LDA #$FF	; White.
	STA COLUP0	; Player 0 color.
	LDA #$88	; Blue.
	STA COLUBK	; Background color.

   
;============================
; Next, we're going to make sure we reset the registers for movement.
; It is important to do this because of some of our fine tuning needs constant updating.
; Note the fine tuning all the way in line 193 "fine tuning."
;============================

	STA HMCLR	; Clear horizontal motion registers
        
;============================
; And now we're getting into our VSYNC
;============================
	
        STA WSYNC
	LDA #2		; We need to get our Vsync active. 
	STA VSYNC   ; Then we move things down 3 WSYNC
        
	REPEAT 3
	STA WSYNC
	REPEND
	
        LDA #0		; And turn it off!
	STA VSYNC
        
;============================
; We'll reset the player position to basically neutral. 
; Note here that we're basically going to 0 so we can keep the fine tuning going. 
; if you want to watch this variable, look at it in the 0-age.
;============================

	LDA XPOS       ; Desired X position
	AND #$7F       ; same as AND 01111111, forces bit 7 to zero
	               ; keeping the result positive
        SEC            ; set carry flag before subtraction
        STA WSYNC      ; wait for next scanline
        STA HMCLR      ; clear old horizontal position values
        
DivideLoop:
        SBC #15        ; Subtract 15 from A
        BCS DivideLoop ; loop while carry flag is still set
        EOR #7         ; adjust the remainder in A between -8 and 7
        ASL            ; shift left by 4, as HMP0 uses only 4 bits
        ASL
        ASL
        ASL
        STA HMP0       ; set player0 smooth position value
        STA RESP0      ; fix player0 rough position
        STA WSYNC      ; wait for next scanline
        STA HMOVE      ; apply fine position offset to all objects
                        
;============================
; So note that we're writing HMOVE just after a WSYNC.
; Think of this as telling the TIA to wait til the start of a scanline
; to start fine tuning movement.
;============================
        
BLANK:
        REPEAT 37
        STA WSYNC
        REPEND

	LDA #0		; Disable blanking
	STA VBLANK
        
;============================
; Now we're in visible lines.
;============================

VISIBLE:
	REPEAT 183
        STA WSYNC
        REPEND

;============================
; So you may wonder why we're basically going down ONLY 183 lines. 
; The remaining 9 are reserved for the player sprite.
; We will do it this way first and then talk about "sprites" later.
; I'll add the binary values where I can.
;============================

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0	; You'll see that this is the top. 

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$18	; Play around with this value.00011000
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$3c	; Play around with this value. 00111100
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$66	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$ff	; Play around with this value. #%11111111
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$24	; Play around with this value.
	STA GRP0

	STA WSYNC	; One scanline
	LDA #$00	; And this one is blank.
	STA GRP0	; Change it up and see what happens.

;============================
; We have a kernel, we have a sprite. Now we're doing our overscan.
; But notice here that we're actually doing some calculations here in order to get our min and max x values in order.
;============================

BOTTOM:
	REPEAT 29
        STA WSYNC
	REPEND

	LDA XPOS	; A = XPOS
	CLC		; Clear carry (C flag in P register becomes zero)
	ADC XDIR	; A = A + XDIR + Carry
	STA XPOS	; XPOS = A
	CMP #1		; Reached minimum X-position 1?
	BEQ L1		; Branch if EQual
	CMP #153	; Reached maximum X-position 153?
	BNE JUMP	; Branch if Not Equal
	
;============================
; Here, we might talk about how he's doing some work in and around negative or signed numbers.
;============================

L1:
	LDA #0		; A = 0
	SEC		; Set carry (it means no borrow for subtraction)
	SBC XDIR	; A = 0 - XDIR (reverses direction)
	STA XDIR	; XDIR = A
                
JUMP        
        JMP SHOW_FRAME

	ORG $FFFC
	.word START
	.word START
```
