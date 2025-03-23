

>[!Tip] OpCodes We Need to be mindful of.
>What it is. 
# What does it mean to have an opponent?


# Code Example for this week

## Getting Started with a place to run around
```asm6502

		processor 6502
        include "vcs.h"
        include "macro.h"
        include "xmacro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; We're going to set the player's coarse and fine position
; at the same time using a clever method.
; We divide the X coordinate by 15, in a loop that itself
; is 15 cycles long. When the loop exits, we are at
; the correct coarse position, and we set RESP0.
; The accumulator holds the remainder, which we convert
; into the fine position for the HMP0 register.
; This logic is in a subroutine called SetHorizPos.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpriteHeight = 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Variables segment

        seg.u Variables
	org $80

XPos		.byte
YPos		.byte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code segment

	seg Code
        org $f000

Start
	CLEAN_START
        
        lda #80
        sta YPos
        sta XPos
        ldx #$00       		; Set the background to a color you like
    	stx COLUBK		; Background

NextFrame
	VERTICAL_SYNC
        lda #2
        sta VBLANK
	TIMER_SETUP 37

				; move X and Y coordinates w/ joystick
	jsr MoveJoystick

                                ; the next two scanlines
                                ; position the player horizontally

	lda XPos		; get X coordinate
        ldx #0			; player 0
        jsr SetHorizPos		; set coarse offset
        sta WSYNC		; sync w/ scanline
        sta HMOVE		; apply fine offsets

                                ; it's ok if we took an extra scanline because
                                ; the PIA timer will always count 37 lines
                                ; wait for end of underscan

        TIMER_WAIT
        lda #0
        sta VBLANK
        
; 192 lines of frame
	ldx #192		; X = 192 scanlines
LVScan
	txa			; X -> A
        sec			; set carry for subtract
        sbc YPos		; local coordinate
        cmp #SpriteHeight 	; in sprite?
        bcc facesmile		; yes, skip over next
        lda #0			; not in sprite, load 0

facesmile
	tay			; local coord -> Y
        lda smile,y		; lookup color
        sta WSYNC		; sync w/ scanline
        sta GRP0		; store bitmap
        lda smilecolor,y 	; lookup color
        sta COLUP0		; store color
        dex			; decrement X
        bne LVScan		; repeat until 192 lines

				; 29 lines of overscan
	TIMER_SETUP 29
        TIMER_WAIT
				; total = 262 lines, go to next frame
        jmp NextFrame

                                ; SetHorizPos routine
                                ; A = X coordinate
                                ; X = player number (0 or 1)
SetHorizPos
	sta WSYNC		; start a new line
	sec			; set carry flag
DivideLoop
	sbc #15			; subtract 15
	bcs DivideLoop		; branch until negative
	eor #7			; calculate fine offset
	asl
	asl
	asl
	asl
	sta RESP0		; fix coarse position
	sta HMP0		; set fine offset

				; Read joystick movement and apply to object 0
MoveJoystick
                                ; Move vertically
                                ; (up and down are actually reversed since ypos starts at bottom)
	ldx YPos
	lda #%00100000		;Up?
	bit SWCHA
	bne SkipMoveUp
        cpx #1
        bcc SkipMoveUp
        dex
SkipMoveUp
	lda #%00010000		;Down?
	bit SWCHA 
	bne SkipMoveDown
        cpx #180
        bcs SkipMoveDown
        inx
SkipMoveDown
	stx YPos
				; Move horizontally
        ldx XPos
	lda #%01000000		;Left?
	bit SWCHA
	bne SkipMoveLeft
        cpx #5
        bcc SkipMoveLeft
        dex
SkipMoveLeft
	lda #%10000000		;Right?
	bit SWCHA 
	bne SkipMoveRight
        cpx #163
        bcs SkipMoveRight
        inx
SkipMoveRight
	stx XPos
	rts

smile
	.byte
        .byte
        .byte #%00111100;$1A
        .byte #%01000010;$1A
        .byte #%01111110;$1A
        .byte #%01011010;$1A
        .byte #%01011010;$1A
        .byte #%01111110;$1A
        .byte #%01111110;$32
        .byte #%00111100;$20

smilecolor
        .byte #$1A;
        .byte #$1A;
        .byte #$1A;
        .byte #$1A;
        .byte #$1A;
        .byte #$1A;
        .byte #$32;
        .byte #$20;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Epilogue

	org $fffc
        .word Start	; reset vector
        .word Start	; BRK vector

```
## Adding Some Enemies to Chase You