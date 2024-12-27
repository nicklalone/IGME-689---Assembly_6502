---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

# <a id = "day1"></a>Day 1

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

First, let's mess a bit with some background colors. 

```asm6502
	processor 6502
	include "vcs.h"
    include "macro.h"
    include "xmacro.h"
START: CLEAN_START

lda #$1E
sta COLUBK

jmp START

org $FFFC
.word START
.word START

```

We're going to take a piece of a tutorial from a youtuber named 8blit and work on it a bit. 

```asm6502
	processor 6502		; We need to call into being the 6502 on our IDE.
	include	 "vcs.h"	

; For this task, we're going to actually use some memory to mess around with the TIA PF0, PF1, PF2, and CTLRPF Registers. Along the way, we'll explore the issues of overscanning and safe areas to draw in the safe visual area of the screen with the the recommended number of VBLANK's

PFCOLOR equ #$F9 

; --------------- Start of main segment ------------------

				seg	main
				org 	$F000

; -------------- Start of program execution -------------

reset: 	ldx #0 		; Clear RAM and all TIA registers
	lda #0 
  
clear:	sta 0,x 	; $0 to $7F (0-127) reserved OS page zero, $80 to $FF (128-255) user zero page ram.
	inx 
	bne 	clear

	lda #%00000001	; Set D0 to reflect the playfield
	sta CTRLPF	; Apply to the CTRLPF register

	lda #PFCOLOR			
	sta COLUPF	; Set the PF color

; --------------------------- Begin main loop -------------------------------------

startframe: 			; ------- 76543210 ---------- Bit order
	lda 	#%00000010	; Writing a bit into the D1 vsync latch
	sta 	VSYNC 

; --------------------------- 3 scanlines of VSYNC signal
	sta 	WSYNC
	sta 	WSYNC
	sta 	WSYNC  

; --------------------------- Turn off VSYNC         	 
	lda 	#0
	sta	 	VSYNC

; -------------------------- Additional 37 scanlines of vertical blank ------------
	ldx 	#0 					
lvblank:sta 	WSYNC
	inx
	cpx 	#37	; 37 scanlines of vertical blank
	bne 	lvblank
				
; --------------------------- 192 lines of drawfield ------------------------------

	ldx #0 					
drawfield: 
	lda #%11111111 ; Solid row of pixels for all PF# registers
	sta 	PF0
	sta	PF1
	sta	PF2				

	sta 	WSYNC
	inx  
	cpx 	#192
	bne 	drawfield

; -------------------------- 30 scanlines of overscan -----------------------------
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

; --------------------------- End of overscan -------------------------------------

	jmp 	startframe	; jump back up to start the next frame

; --------------------------- Pad until end of main segment -----------------------

	org 	$FFFA
	
irqvectors:
	.word reset         	; NMI
	.word reset         	; RESET
	.word reset         	; IRQ

; -------------------------- End of main segment ----------------------------------
```

# <a id = "day2"></a>Day 2
