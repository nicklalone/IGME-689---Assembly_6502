---------------- Table of Contents ---------------- 

1. [Admin](#admin)
2. [Assignments](#assignment)
3. [Getting Started](#getstart)
4. [Backgrounds](#background)
	1. [Background Code Example](#backcode)
5. [Playfields](#playfields)
	1. [Playfield Code Example](#playfield)
6. [Combined](#combo)

---------------- Table of Contents ---------------- 
# <a id='admin'></a>Admin
I have gone through most of the reading assignments. We are starting coding this week, let's take an inventory of coding capacity in class and who might be more helpful.
# <a id='assignment'></a>Assignment
This week, we're doing Source Code reading. This will probably be insanely difficult at first but I just want you to try your best. As we move forward, it will get easier as you'll be exposed to more stuff. 

The assignment is simple, I want the labels that check for missile collision with walls and the playfield and I want you to tell me how they work, what the logic is, and why. 
# <a id = "getstart"></a>Getting Started and Admin

The Atari 2600 has a chip that processes game logic and a Television Interface Adapter that sends that logic to the television screen. It literally paints the screen in real time as the processor goes through the logic. This is why we tie everything to our frame as we count the various scanlines. 

There are a variety of things we need to keep track of here. First, let's think about this: 

The background dictates the color of certain things. For example. Consider how colors in the 2600 work. We know that it can display a total of 128 colors and they can be displayed at the same time but below each other or in each individual scanline. 

This allows for our rainbow to appear though we were not going with all 128! Next, each scanline can only have 4 colors displayed at any given time. 

Finally, it is important to remember that some stuff shares colors. So, these share colors: 
* Playfield and Ball 
* Player0 and missile0 
* Player1 and missile1 

And to that end, we have 7 distinct game elements. Those elements are: 
1. Background 
2. Playfield 
3. Player 1 
4. Player 2 
5. Missile 1 
6. Missile 2 
7. Ball

So let's think about this image again: 

![](/images/resolution.png)

We messed with this a little because of last week where we literally set up our frame and started making 3 scanlines and made a gentle rainbow. This is all background and so we will be moving from background to playfield in this lesson. 
# <a id="background"></a>Background
The background dictates the color of certain things. For example. Consider how colors in the 2600 work. We know that it can display a total of 128 colors and they can be displayed at the same time but below each other or in each individual scanline. 

This allows for our rainbow to appear though we were not going with all 128! Next, each scanline can only have 4 colors displayed at any given time. 

Finally, it is important to remember that some stuff shares colors. So: 
* Playfield and Ball 
* Player0 and missile0 
* Player1 and missile1 

This leaves us with 7 distinct game elements. Those elements are: 
1. Background 
2. Playfield 
3. Player 1 
4. Player 2 
5. Missile 1 
6. Missile 2 
7. Ball

While this doesn't seem like a lot, we got to keep all of this in mind while we work on our games. For example, while the playfield and ball have the same color, we need to be mindful of player0 and player1's color difference, especially as it relates to both the background and playfield. Should these things match, you may have some issues! 

First, let's mess a bit with some background colors. Let's go ahead and set up our basic shell.

```asm6502
	processor 6502
	include "vcs.h"
    include "macro.h"
    include "xmacro.h"
        
	seg	main
	org 	$F000

    
START: CLEAN_START

	org $FFFC
	.word START
	.word START
```

# <a id='playfield'></a>Playfield

We're going to take a piece of a tutorial from a youtuber named 8blit and work on it a bit. 

```asm6502
	processor 6502		; We need to call into being the 6502 on our IDE.
	include	 "vcs.h"	

; For this task, we're going to actually use some memory to mess around with the TIA PF0, PF1, PF2, and CTLRPF Registers. Along the way, we'll explore the issues of overscanning and safe areas to draw in the safe visual area of the screen with the the recommended number of VBLANK's

PFCOLOR equ #$F9 

; ----- Start of main segment -----

	seg	main
	org 	$F000

; ----- Start of program execution -----

reset: 	ldx 	#0 		; Clear RAM and all TIA registers
	lda 	#0 
  
clear:	sta 	0,x 	; $0 to $7F (0-127) reserved OS page zero, $80 to $FF (128-255) user zero page ram.
	inx 
	bne 	clear

	lda 	#%00000001	; Set D0 to reflect the playfield
	sta 	CTRLPF	; Apply to the CTRLPF register

	lda 	#PFCOLOR			
	sta 	COLUPF	; Set the PF color

; ----- Begin main loop -----

startframe: 			
						
; ------- 76543210 ---------- Bit order
	lda 	#%00000010	; Writing a bit into the D1 vsync latch
	sta 	VSYNC 

; ----- 3 scanlines of VSYNC signal
	sta 	WSYNC
	sta 	WSYNC
	sta 	WSYNC  

; ----- Turn off VSYNC         	 
	lda 	#0
	sta	 	VSYNC

; ----- Additional 37 scanlines of vertical blank -----
	ldx 	#0 					
lvblank:
	sta 	WSYNC
	inx
	cpx 	#37	; 37 scanlines of vertical blank
	bne 	lvblank
				
; ----- 192 lines of drawfield -----

	ldx 	#0 					
drawfield: 
	lda 	#%11111111 ; Solid row of pixels for all PF# registers
	sta 	PF0
	sta	PF1
	sta	PF2				

	sta 	WSYNC
	inx  
	cpx 	#192
	bne 	drawfield

; ----- 30 scanlines of overscan -----
	lda     #%00000000
	sta     PF0
	sta     PF1
	sta     PF2

	ldx 	#0					
overscan:
	sta 	WSYNC
	inx
	cpx 	#30
	bne 	overscan

; ----- End of overscan -----
	jmp 	startframe	; jump back up to start the next frame

; ----- Pad until end of main segment -----

	org 	$FFFA
	
irqvectors:
	.word 	reset         	; NMI
	.word 	reset         	; RESET
	.word 	reset         	; IRQ

; ----- End of main segment -----
```

We can also try and do some stuff.

```asm6502
	PROCESSOR 6502
	INCLUDE "vcs.h"

	ORG $F000
START:
	SEI
	CLD
	LDX #$FF
	TXS
	LDA #$00
CLEAR:
	STA 0,X
	DEX
	BNE CLEAR

SHOW_FRAME:
	LDA #$88
	STA COLUBK

	STA WSYNC
	LDA #2
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #0
	STA VSYNC

	LDX #36
TOP:
	STA WSYNC
	DEX
	BNE TOP
	LDA #0
	STA VBLANK

	LDX #192
VISIBLE:
	STA WSYNC
	DEX
	BNE VISIBLE

	LDA #2
	STA VBLANK
	LDX #30
BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM

	JMP SHOW_FRAME

	ORG $FFFC
	.word START
	.word START

```

and we can augment this a bit. 

```asm6502
	PROCESSOR 6502
	INCLUDE "vcs.h"

	ORG $F000
START:
	SEI
	CLD
	LDX #$FF
	TXS
	LDA #$00
CLEAR:
	STA 0,X
	DEX
	BNE CLEAR

SHOW_FRAME:
	LDA #$88
	STA COLUBK

	STA WSYNC
	LDA #2
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #0
	STA VSYNC

	LDX #36
TOP:
	STA WSYNC
	DEX
	BNE TOP
	LDA #0
	STA VBLANK

	LDX #96
VISIBLE:
	STA WSYNC
	DEX
	BNE VISIBLE

	LDA #$F8
	STA COLUBK

	LDX #96
VISIBLE2:
	STA WSYNC
	DEX
	BNE VISIBLE2

	LDA #2
	STA VBLANK
	LDX #30
BOTTOM:
	STA WSYNC
	DEX
	BNE BOTTOM

	JMP SHOW_FRAME

	ORG $FFFC
	.word START
	.word START
```

But this is just the background.

```ASM6502
	;
	; Playfield demo.
	;
	; by Oscar Toledo G.
	; https://nanochess.org/
	;
	; Creation date: Jun/02/2022.
	;

	PROCESSOR 6502
	INCLUDE "vcs.h"

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

SHOW_FRAME:
	LDA #$88	; Blue.
	STA COLUBK	; Background color.
	LDA #$28	; White.
	STA COLUPF	; Playfield color.
	LDA #$40	; Red
	STA COLUP0	; Player 0 color.
	LDA #$c0	; Green
	STA COLUP1	; Player 1 color.
	LDA #$01	; Right side of playfield is reflected.
	STA CTRLPF	

	STA WSYNC
	LDA #2		; Start of vertical retrace.
	STA VSYNC
	STA WSYNC
	STA WSYNC
	STA WSYNC
	LDA #0		; End of vertical retrace.
	STA VSYNC

	LDX #36		; Remains 36 scanlines of top border

TOP:
	STA WSYNC
        DEX
        BNE TOP
        LDA #0
        STA VBLANK
        
	LDX #8

PART1:
	STA WSYNC
        LDA #$F0
        STA PF0
        STA PF1
        LDA #$FF
        STA PF2
        
        DEX
        BNE PART1

	LDX #176

PART2: 
	STA WSYNC
        LDA #$10
        STA PF0
        LDA #$00
        STA PF1
        LDA #$00
        STA PF2
        
        DEX
        BNE PART2
        
        LDX #8
PART3:
	STA WSYNC
        LDA #$F0
	STA PF0
        LDA #$FF
        STA PF1
        LDA #$3F
        STA PF2
        
        DEX
        BNE PART3
        
	LDA #2
        STA VBLANK
        LDX #30

BOTTOM:
	STA WSYNC
        LDA #0
        STA PF0
        STA PF1
        STA PF2
        
        DEX
        BNE BOTTOM
        
	JMP SHOW_FRAME

	ORG $FFFC
	.word START
	.word START

```