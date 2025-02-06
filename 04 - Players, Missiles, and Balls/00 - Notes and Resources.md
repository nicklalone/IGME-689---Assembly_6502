These files are mostly for me as I go around and look for good resources. While a lot of this stuff will be tangential, it's mostly for folks who want a lot more in depth information. 

Warren Robinett - https://gdcvault.com/play/1021860/Classic-Game-Postmortem

Missiles!
Let's explore this: https://forums.atariage.com/topic/139630-moving-a-missile/

```asm6502
; First we have to tell DASM that we're 
; coding to the 6502:

	processor 6502

; Then we have to include the "vcs.h" file
; that includes all the "convenience names"
; for all the special atari memory locations...

	include "vcs.h"

	include "macro.h"

;**************************************************************************

	SEG.U vars; tells dasm that the proceding instructions are variable declarations
			
	ORG $80; tells dasm to start placing our variables in memory location 0080

player0x = $80; player0's x position

player0y = $81; player0's y position

visibleplayer0line = $82; current visible line for player 0

player0buffer = $83; player buffer for holding the line to draw for the player graphic

missile0x = $84; missile 0's x position

missile0y = $85; missile 0's y position

visiblemissile0line = $86; line where missile is drawn

lives = $87; player lives

score = $88; game score

	SEG code

; tell DASM where in the memory to place
; all the code that follows...$F000 is the preferred
; spot where it goes to make an atari program

	ORG $F000

; we'll call the start of our program "Start".
Start

	SEI; Disable Any Interrupts
	CLD	; Clear BCD math bit.
	LDX #$FF; put X to the top...
	TXS; ...and use it reset the stack pointer

; Clear RAM and all TIA registers

	lda #0;Put Zero into A, X is at $FF

Clear		   sta 0,x;Now, this doesn't mean what you think...

	dex;decrement X (decrease X by one)

	bne Clear;if the last command resulted in something 
	;that's "N"ot "Equal" to Zero, branch back
	;to "Clear"

;---------------------
; One Time Initiations

	lda #$FA

	sta COLUBK; set the background color to sandy brown

	lda #$04

	sta COLUP0; set the player color to silver

	lda #$B8

	sta COLUPF; set the playfield color to ooze green

;---------------------
; Start New Game

StartNewGame	lda #105

	sta player0x; player0's initial x position

	lda #40

	sta player0y; player0's initial y position

	lda #0

	sta missile0x; missile 0's initial x position

	lda #0

	sta missile0y; missile 0's initial y position

	lda #3

	sta lives; start the player with 3 lives

	lda #0

	sta score; set high bit of score inital value to 0

	lda #0

	sta score+1; set nibble bit of score inital value to 0

	lda #0

	sta score+2; low bit of score inital value to 0

GameLoop

;*********************** VERTICAL SYNC HANDLER

	lda  #2

	sta VSYNC; Sync it up you damn dirty television!
; and that vsync on needs to be held for three scanlines...
; count with me here,
	sta WSYNC; one... (our program waited for the first scanline to finish...)

	sta WSYNC; two...

	sta WSYNC; three...

	lda  #43;load 43 (decimal) in the accumulator

	sta  TIM64T;and store that in the timer

	lda #0; Zero out the VSYNC
	sta  VSYNC; cause that time is over

;*********************** Joystick Input
; Here we check for left and right
; joystick input

	lda #%01000000; a 0 in bit D6 means the joystick was pushed left

	bit SWCHA; was the joystick moved left?

	bne SkipPlayer0MoveLeft; if bit D6 isn't equal to 0 then jump to SkipPlayer0MoveLeft

	dec player0x; otherwise the player moved the joystick left so deincrement the players position by one

SkipPlayer0MoveLeft

	lda #%10000000; a 0 in bit D7 means the joystick was pushed right

	bit SWCHA; was the joystick moved right?

	bne SkipPlayer0MoveRight;if bit D6 isn't equal to 0 then jump to SkipPlayer0MoveRight

	inc player0x;otherwise the player moved the joystick right so increment the players position by one

SkipPlayer0MoveRight

	lda player0x; load the players position into the accumulator

	ldx #0; set the sprite to be positioned as player 0

	jsr PositionSprite; jump to our Position Sprite Subroutine to position player 0

	sta WSYNC; wait for sync

	lda #0; zero out the buffer

	sta player0buffer; just in case

	lda INPT4; read button input

	bmi ButtonNotPressed; skip if button not pressed

	lda player0x; load player 0's x position

	sta missile0x; and set it to the missile 0's x position

	lda #4; set the acumulator to 4

	clc; clear carry status

	adc missile0x; add 4 to missile 0's x position so it's centered at player 0

	sta missile0x; and set it to missile 0's x position

	lda player0y; load player 0's y position

	sta missile0y; and set it to missile 0's y position

	lda #8; set the acumulator to 8

	clc; clear carry status

	adc missile0y; add 8 to missile 0's y position so it's above player 0

	sta missile0y; and set it to missile 0's y position

	lda missile0x; load missile 0's x position into the accumulator

	ldx #2; set the sprite to be positioned to missile 0

	jsr PositionSprite; jump to our Position Sprite Subroutine to position missile 0


ButtonNotPressed


;*********************** VERTICAL BLANK WAIT-ER
WaitForVblankEnd

	lda INTIM;load timer...

	BNE WaitForVblankEnd;killing time if the timer's not yet zero

	ldy #191;Y is going to hold how many lines we have to do
;...we're going to count scanlines here. theoretically
; since this example is ass simple, we could just repeat
; the timer trick, but often its important to know 
; just what scan line we're at.

	sta WSYNC;We do a WSYNC just before that so we don't turn on

	sta VBLANK;End the VBLANK period with the zero

;*********************** Scan line Loop
ScanLoop

	sta WSYNC;Wait for the previous line to finish

	lda player0buffer;buffer was set during last scanline

	sta GRP0;put it as graphics now

	cpy player0y; compare the player's y position

	bne SkipActivatePlayer0; if it isn't 0 then jump to SkipActivePlayer0

	lda #5; otherwise load our accumulatior with the number of lines to draw

	sta visibleplayer0line; and store it 

SkipActivatePlayer0

;set player buffer to all zeros for this line, and then see if 
;we need to load it with graphic data

	lda #0		

	sta player0buffer;set buffer, not GRP0

;if the VisiblePlayerLine is non zero,
;we're drawing it next line

	ldx visibleplayer0line;check the visible player line...

	beq FinishPlayer;skip the drawing if its zero...

	lda player0-1,X;otherwise, load the correct line from player0
	;section below... it's off by 1 though, since at zero
	;we stop drawing
	sta player0buffer;put that line as player graphic for the next line

	dec visibleplayer0line;and decrement the line count

FinishPlayer

; here the idea is that visiblemissile0line
; is zero if the line isn't being drawn now,
; otherwise it's however many lines we have to go

CheckActivateMissile

	cpy missile0y; is missile 0's y position the same as the current scanline?

	bne SkipActivateMissile; if it isn't then don't set missle 0's visible lines

	lda #8; otherwise set the missiles visible lines to 8

	sta visiblemissile0line; and store it in the visiblemissileline

SkipActivateMissile

;turn missile off then see if it's turned on

	lda #0

	sta ENAM0; disable the missile

;if the visiblemissile0line is non zero,
;we're drawing it

	lda visiblemissile0line; if the visiblemissle line is zero

	beq FinishMissile; don't draw the missile

	lda #2; otherwise set the accumulator to 2		

	sta ENAM0; and draw the missile

	dec visiblemissile0line; and decrement the visiblemissileline by 1

	inc missile0y; increment missle 0's y position by 1

FinishMissile

	dey;subtract one off the line counter thingy

	bne ScanLoop;and repeat if we're not finished with all the scanlines.

	lda #2;#2 for the VBLANK...

	sta WSYNC;Finish this final scanline.

	sta VBLANK; Make TIA output invisible for the overscan, 
; (and keep it that way for the vsync and vblank)

;***************************** OVERSCAN CALCULATIONS
;I'm just gonna count off the 30 lines of the overscan.
;You could do more program code if you wanted to.

	ldx #30;store 30

OverScanWait

	sta WSYNC

	dex

	bne OverScanWait

	jmp  GameLoop;Continue this loop forver! Back to the code for the vsync etc

PositionSprite

sta HMCLR

sec

sta WSYNC
	
PositionSpriteLoop

sbc	#15

bcs	PositionSpriteLoop

eor	#7

asl

asl

asl

asl			  

sta.wx HMP0,X	

sta	RESP0,X  

sta	WSYNC	  

sta	HMOVE	

rts

; here's the actual player0 graphic

player0
		.byte #%00011000
		.byte #%00111100
		.byte #%11111111
		.byte #%00111100
		.byte #%00011000

update_low_score_digits

	sed; set decimal mode

	clc; clear carry status

	adc score; add accumulator to score's low digits w/carry.

	sta score; store the updated low digits.

;NOTE: Here's where a triple-NOP comes into play.  We need
;a seperate entrypoint to this subroutine for cases where the
;low digits are ignored (like adding 100, for example).  But
;carry status and BCD mode need to have been setup.  So,
;place the triple-NOP opcode here to skip over them...
;with A reset at zero so that only carry affects the score:

	lda #0; reset the accumulator...

	.byte $0C; ...and skip over the next 2 bytes

update_middle_score_digits

	sed; set decimal mode

	clc; clear carry status

	adc score+1; add accumulator to score's middle digits w/carry.

	sta score+1; store the updated middle digits

;Here we do the same thing (in case the game needs to add 10,000...
;or 100,000 increments to a score (ignoring all the lower ones)
;Again, A is reset at zero so that only carry affects the score:

	lda #0; reset the accumulator...

	.byte $0C; ...and skip over the next 2 bytes

update_high_score_digits

	sed; set decimal mode

	clc; clear carry status

	adc score+1; add accumulator to score's high digits w/carry.

	sta score+2; store the last 2 digits

;With the score updated, clear BCD mode and exit via RTS:

	cld; clear decimal mode

	rts; and return to the program line that called this routine.

;*************************************************************************
; Interrupt Vectors

	ORG $FFFA

InterruptVectors

	.word Start	; NMI

	.word Start	; RESET

	.word Start	; IRQ

	END
```

And it's fix: 

```asm6502
        processor 6502

    ; Then we have to include the "vcs.h" file
    ; that includes all the "convenience names"
    ; for all the special atari memory locations...

        include "vcs.h"

        include "macro.h"

    ;**************************************************************************

        SEG.U vars; tells dasm that the proceding instructions are variable declarations
                
        ORG $80; tells dasm to start placing our variables in memory location 0080

player0x = $80; player0's x position

player0y = $81; player0's y position

visibleplayer0line = $82; current visible line for player 0

player0buffer = $83; player buffer for holding the line to draw for the player graphic

missile0x = $84; missile 0's x position

missile0y = $85; missile 0's y position

visiblemissile0line = $86; line where missile is drawn

lives = $87; player lives

score = $88; game score

        SEG code

    ; tell DASM where in the memory to place
    ; all the code that follows...$F000 is the preferred
    ; spot where it goes to make an atari program

        ORG $F000

    ; we'll call the start of our program "Start".
Start

        SEI    ; Disable Any Interrupts
        CLD      ; Clear BCD math bit.
        LDX #$FF; put X to the top...
        TXS    ; ...and use it reset the stack pointer

    ; Clear RAM and all TIA registers

        lda #0    ;Put Zero into A, X is at $FF

Clear           sta 0,x    ;Now, this doesn't mean what you think...

        dex    ;decrement X (decrease X by one)

        bne Clear;if the last command resulted in something
             ;that's "N"ot "Equal" to Zero, branch back
             ;to "Clear"

    ;---------------------
    ; One Time Initiations

        lda #$FA

        sta COLUBK; set the background color to sandy brown

        lda #$04

        sta COLUP0; set the player color to silver

        lda #$B8

        sta COLUPF; set the playfield color to ooze green

    ;---------------------
    ; Start New Game

StartNewGame    lda #105

        sta player0x; player0's initial x position

        lda #40

        sta player0y; player0's initial y position

        lda #0

        sta missile0x; missile 0's initial x position

        lda #0

        sta missile0y; missile 0's initial y position

        lda #3

        sta lives; start the player with 3 lives

        lda #0

        sta score; set high bit of score inital value to 0

        lda #0

        sta score+1; set nibble bit of score inital value to 0

        lda #0

        sta score+2; low bit of score inital value to 0

GameLoop

    ;*********************** VERTICAL SYNC HANDLER

        lda  #2

        sta VSYNC; Sync it up you damn dirty television!
            ; and that vsync on needs to be held for three scanlines...
            ; count with me here,
        sta WSYNC; one... (our program waited for the first scanline to finish...)

        sta WSYNC; two...

        sta WSYNC; three...

        lda  #43;load 43 (decimal) in the accumulator

        sta  TIM64T;and store that in the timer

        lda #0    ; Zero out the VSYNC
        sta  VSYNC ; cause that time is over

    ;*********************** Joystick Input
    ; Here we check for left and right
    ; joystick input

        lda #%01000000; a 0 in bit D6 means the joystick was pushed left

        bit SWCHA; was the joystick moved left?

        bne SkipPlayer0MoveLeft; if bit D6 isn't equal to 0 then jump to SkipPlayer0MoveLeft

        dec player0x; otherwise the player moved the joystick left so deincrement the players position by one

SkipPlayer0MoveLeft
    
        lda #%10000000; a 0 in bit D7 means the joystick was pushed right

        bit SWCHA ; was the joystick moved right?

        bne SkipPlayer0MoveRight;if bit D6 isn't equal to 0 then jump to SkipPlayer0MoveRight

        inc player0x;otherwise the player moved the joystick right so increment the players position by one

SkipPlayer0MoveRight

        lda player0x; load the players position into the accumulator

        ldx #0    ; set the sprite to be positioned as player 0

        jsr PositionSprite; jump to our Position Sprite Subroutine to position player 0

        sta WSYNC; wait for sync

        lda #0        ; zero out the buffer

        sta player0buffer; just in case

        lda INPT4; read button input

        bmi ButtonNotPressed; skip if button not pressed

        lda player0x; load player 0's x position

        sta missile0x; and set it to the missile 0's x position

        lda #4    ; set the acumulator to 4

        clc    ; clear carry status

        adc missile0x; add 4 to missile 0's x position so it's centered at player 0

        sta missile0x; and set it to missile 0's x position

        lda player0y; load player 0's y position

        sta missile0y; and set it to missile 0's y position

        lda #8    ; set the acumulator to 8

        clc    ; clear carry status

        adc missile0y; add 8 to missile 0's y position so it's above player 0

        sta missile0y; and set it to missile 0's y position

        lda missile0x; load missile 0's x position into the accumulator

        ldx #2    ; set the sprite to be positioned to missile 0

        jsr PositionSprite; jump to our Position Sprite Subroutine to position missile 0


ButtonNotPressed


    ;*********************** VERTICAL BLANK WAIT-ER
WaitForVblankEnd
    
        lda INTIM;load timer...

        BNE WaitForVblankEnd;killing time if the timer's not yet zero

        ldy #191 ;Y is going to hold how many lines we have to do
            ;...we're going to count scanlines here. theoretically
            ; since this example is ass simple, we could just repeat
            ; the timer trick, but often its important to know
            ; just what scan line we're at.

        sta WSYNC;We do a WSYNC just before that so we don't turn on

        sta VBLANK;End the VBLANK period with the zero

    ;*********************** Scan line Loop
ScanLoop

        sta WSYNC ;Wait for the previous line to finish
	
        cpy missile0y; is missile 0's y position the same as the current scanline?

        bne SkipActivateMissile; if it isn't then don't set missle 0's visible lines

        lda #8        ; otherwise set the missiles visible lines to 8

        sta visiblemissile0line; and store it in the visiblemissileline

SkipActivateMissile

    ;turn missile off then see if it's turned on

        lda #0

        sta ENAM0; disable the missile

    ;if the visiblemissile0line is non zero,
    ;we're drawing it

        lda visiblemissile0line; if the visiblemissle line is zero

        beq FinishMissile; don't draw the missile
    
        lda #2        ; otherwise set the accumulator to 2        

        sta ENAM0    ; and draw the missile

        dec visiblemissile0line; and decrement the visiblemissileline by 1

        inc missile0y    ; increment missle 0's y position by 1

FinishMissile

        lda player0buffer;buffer was set during last scanline

        sta GRP0        ;put it as graphics now

        cpy player0y; compare the player's y position

        bne SkipActivatePlayer0; if it isn't 0 then jump to SkipActivePlayer0

        lda #5    ; otherwise load our accumulatior with the number of lines to draw

        sta visibleplayer0line; and store it

SkipActivatePlayer0

    ;set player buffer to all zeros for this line, and then see if
    ;we need to load it with graphic data

        lda #0        

        sta player0buffer  ;set buffer, not GRP0

    ;if the VisiblePlayerLine is non zero,
    ;we're drawing it next line

        ldx visibleplayer0line;check the visible player line...

        beq FinishPlayer;skip the drawing if its zero...

        lda player0-1,X    ;otherwise, load the correct line from player0
                ;section below... it's off by 1 though, since at zero
                ;we stop drawing
        sta player0buffer;put that line as player graphic for the next line

        dec visibleplayer0line;and decrement the line count

FinishPlayer

    ; here the idea is that visiblemissile0line
    ; is zero if the line isn't being drawn now,
    ; otherwise it's however many lines we have to go

CheckActivateMissile



        dey    ;subtract one off the line counter thingy

        bne ScanLoop;and repeat if we're not finished with all the scanlines.

        lda #2    ;#2 for the VBLANK...

        sta WSYNC  ;Finish this final scanline.

        sta VBLANK ; Make TIA output invisible for the overscan,
            ; (and keep it that way for the vsync and vblank)

    ;***************************** OVERSCAN CALCULATIONS
    ;I'm just gonna count off the 30 lines of the overscan.
    ;You could do more program code if you wanted to.

        ldx #30    ;store 30

OverScanWait

        sta WSYNC

        dex

        bne OverScanWait

        jmp  GameLoop     ;Continue this loop forver! Back to the code for the vsync etc

PositionSprite

    sta HMCLR

    sec

    sta WSYNC
        
PositionSpriteLoop

    sbc    #15

    bcs    PositionSpriteLoop

    eor    #7

    asl

    asl

    asl

    asl              

    sta.wx HMP0,X    

    sta    RESP0,X  

    sta    WSYNC      

    sta    HMOVE    

    rts

        ; here's the actual player0 graphic

player0
            .byte #%00011000
            .byte #%00111100
            .byte #%11111111
            .byte #%00111100
            .byte #%00011000

update_low_score_digits

        sed     ; set decimal mode

        clc     ; clear carry status

        adc score ; add accumulator to score's low digits w/carry.

        sta score; store the updated low digits.

    ;NOTE: Here's where a triple-NOP comes into play.  We need
    ;a seperate entrypoint to this subroutine for cases where the
    ;low digits are ignored (like adding 100, for example).  But
    ;carry status and BCD mode need to have been setup.  So,
    ;place the triple-NOP opcode here to skip over them...
    ;with A reset at zero so that only carry affects the score:

        lda #0     ; reset the accumulator...

        .byte $0C ; ...and skip over the next 2 bytes

update_middle_score_digits

        sed     ; set decimal mode

        clc; clear carry status

        adc score+1 ; add accumulator to score's middle digits w/carry.

        sta score+1 ; store the updated middle digits

    ;Here we do the same thing (in case the game needs to add 10,000...
    ;or 100,000 increments to a score (ignoring all the lower ones)
    ;Again, A is reset at zero so that only carry affects the score:

        lda #0    ; reset the accumulator...

        .byte $0C; ...and skip over the next 2 bytes

update_high_score_digits

        sed    ; set decimal mode

        clc    ; clear carry status

        adc score+1; add accumulator to score's high digits w/carry.

        sta score+2; store the last 2 digits

    ;With the score updated, clear BCD mode and exit via RTS:

        cld    ; clear decimal mode

        rts    ; and return to the program line that called this routine.

    ;*************************************************************************
    ; Interrupt Vectors

        ORG $FFFA

InterruptVectors

        .word Start         ; NMI

        .word Start         ; RESET

        .word Start         ; IRQ

```

And now Missiles: https://forums.atariage.com/topic/198465-i-want-to-keep-learning-a2600-programming-but-im-stuck/#comment-2529970 

See more here: https://forums.atariage.com/topic/47639-session-24-some-nice-code/#comment-576137

```asm6502

; ********************************************************************
;
;  Ball Demo
;
; ********************************************************************

                PROCESSOR 6502

; --------------------------------------------------------------------        
;       Includes
; --------------------------------------------------------------------        
                
                INCLUDE vcs.h
                INCLUDE macro.h

;---------------------------------------------------------------------
;       Constants
;---------------------------------------------------------------------

ROMStart = $F000
ROMSize  = $0800

BALL_HEIGHT = 8 ; height of ball object
        
;---------------------------------------------------------------------
;       Variables
;---------------------------------------------------------------------

FrameCtr = $80  ; frame counter

BallHPos = $81  ; ball horizontal position
BallVPos = $82  ; ball vertical position
BallHDir = $83  ; ball horizontal direction (-1, +1)
BallVDir = $84  ; ball vertical direction (-1, +1)


; ********************************************************************
;
;       Code Section
;
; ********************************************************************        

                ORG ROMStart

BallDemo:       CLEAN_START

                ; setup initial ball direction
        
                lda     #1
                sta     BallHDir
                sta     BallVDir

                ; start with ball in the middle of the scrren
        
                lda     #80
                sta     BallHPos
                lda     #92
                sta     BallVPos
        
; --------------------------------------------------------------------        
;       VSync
; --------------------------------------------------------------------

VSync:          SUBROUTINE

                ; VSYNC on

                lda     #%00000010
                sta     WSYNC
                sta     VSYNC
                sta     WSYNC
                sta     WSYNC

                ; set timer to skip VBLANK

                lda     #44
                sta     TIM64T

                ; VSYNC off

                sta     WSYNC
                sta     VSYNC
 
; --------------------------------------------------------------------        
;       VBlank
; --------------------------------------------------------------------

VBlank:         SUBROUTINE

                ; move ball vertically
        
.vmove          clc
                lda     BallVPos
                adc     BallVDir
                sta     BallVPos

                ; bounce ball on bottom

.bottom         cmp     #0
                bne     .top
                lda     #1
                sta     BallVDir
                jmp     .hmove

                ; bounce ball on top
        
.top            cmp     #186
                bne     .hmove
                lda     #-1
                sta     BallVDir

                ; move ball horizontally
        
.hmove          clc
                lda     BallHPos
                adc     BallHDir
                sta     BallHPos

                ; bounce ball on left side
        
.left           cmp     #1
                bne     .right
                lda     #1
                sta     BallHDir
                jmp     .pos

                ; bounce ball on right side

.right          cmp     #157
                bne     .pos
                lda     #-1
                sta     BallHDir

                ; position ball horizontally

.pos            ldx     #4
                lda     BallHPos
                jsr     HPosNoHMOVE
                sta     WSYNC
                sta     HMOVE

VBlankEnd:      lda     INTIM
                bne     VBlankEnd

; --------------------------------------------------------------------        
;       Kernel
; --------------------------------------------------------------------

Kernel:         SUBROUTINE

                ; VBLANK off
        
                sta     WSYNC
                sta     VBLANK

                lda     #$88            ; background color
                sta     COLUBK
                lda     #$9E            ; ball and playfield color
                sta     COLUPF
                lda     #%00100000      ; ball size 4 pixels
                sta     CTRLPF

                ; draw ball

                ldy     #193
.loop           sta     WSYNC
                ldx     #%00000010      ; set ball enable bit
                tya                     ; move line number to A
                sec                     ; set carry before subtracting
                sbc     BallVPos        ; subtract ball start line
                cmp     #BALL_HEIGHT    ; test if line is in [0, BALL_HEIGHT-1]
                bcc     .write          ; yes -> enable ball
                ldx     #%00000000      ; no -> clear ball enable bit
.write          stx     ENABL
        
                dey
                bne     .loop

; --------------------------------------------------------------------        
;       Overscan
; --------------------------------------------------------------------

Overscan:       SUBROUTINE

                ; VBLANK on

                lda     #%00000010
                sta     WSYNC
                sta     VBLANK

                ; set timer to skip OVERSCAN

                lda     #35
                sta     TIM64T

                ; clear ball

                lda     #0
                sta     ENABL

                ; advance counters

                inc     FrameCtr

OverscanEnd:    lda     INTIM
                bne     OverscanEnd
                jmp     VSync


; ********************************************************************
;
;       Subroutines
;
; ********************************************************************        

HPosNoHMOVE:    SUBROUTINE
                sec
                sta     WSYNC
.loop           sbc     #15
                bcs     .loop
                eor     #7
                asl
                asl
                asl
                asl
                sta.wx  HMP0,x
                sta     RESP0,x
                rts

; ********************************************************************

                ORG ROMStart + ROMSize - 3*2
        
NMI:            WORD    ROMStart
Reset:          WORD    ROMStart
IRQ:            WORD    ROMStart


```

# .byte DS and other things.
So, it gets kind of confusing here because the way atari games are made now is a combination of DASM codes, Assembly, and these sort of faux tricks. I will need to deal with these at some point. And so I think here, with the example from below from Pikuma, there's a good chance here to deal with a lot of it. 

	One of the first things we are doing is to start an _uninitialized segment_ called _“Variables”_ and proceed to _define spaces_ in RAM for our variables. We know we are in RAM because we changed the origin to point to $80, and we are using **DS** to **define a space** of 1 byte for each RAM position.
	
	**DS** is used to define an uninitialized chunk of space. So, we are basically saying we want one space of 1 byte at position $80, and another space of 1 byte at position $81. Since **.ds** does not initialize those space, I took the liberty of declaring our _Variables_ segment as uninitialized (using **seg.u**).
	
	**.BYTE** is used to put data into memory. We can use either **byte** or **.byte**, as they are equivalent. This will add 1 byte of data at a certain address in memory. Therefore, if we want to declare and initialize a variable with some value, we can use .**byte** to instruct our assembler to put 1 byte of data at that memory position.
	
	We have been using **.byte** to define bitmap data and graphics. You'll also see that instead of writing multiple lines with **.byte** statements, it is very common to see **.byte** listing several values one after the other with commas. For example, our smiley face bitmap could be defined in one line.
	
	    _.byte #$7E,#$FF,#$99,#$FF,#$FF,#$FF,#$BD,#$C3,#$FF,#$7E_
	
	**.WORD** is also used for data, and it can be used to directly initialize 16 bits (2 bytes) of data in memory. Again, **word** and **.word** are equivalent for the assembler and can be used interchangeably.
	
	One very common use of **.word** is when we are dealing with a value of a _memory address_. Since addresses are 16 bits long for the 6502, we can take advantage of using **.word** to add 2 bytes into memory directly. This is the case of those two lines that contain “**.word Start**” at the end of our code. Since _Start_ is a label representing the memory address $F000, we simply used **.word** twice to put 4 bytes of data (two address values) at the end of our ROM.
	
	And that’s pretty much what we need to know for now! I hope this clarifies when we should use **.BYTE**, **.WORD**, and **DS** in our 6502 code. There are some other declaration options that we can use with DASM (for example using **.long** to put 4 bytes of data in memory), but the ones I covered here will be the most useful ones for us.

;;; --------------------------------------------------------------------------
;;; *  LIGHTS OUT for the Atari 2600
;;; *
;;; *  Bumbershoot Software, 2018.
;;; --------------------------------------------------------------------------

        processor 6502
        include "vcs.h"
        include "macro.h"
;;; --------------------------------------------------------------------------
;;; * SYMBOLIC NAMES FOR REGISTERS
;;; * Taken from the Stella Programmer's Guide
;;; --------------------------------------------------------------------------


        .org    $0080
        ;; No variables yet!

;;; --------------------------------------------------------------------------
;;; * PROGRAM TEXT
;;; --------------------------------------------------------------------------
        .org    $F800           ; 2KB cartridge image
        ;; RESET vector.
reset:
        sei
        cld
        ;; Zero out registers.
        ldx     #$00
        txa
        tay
        ;; Cycle through all possible stack pointers and push zeroes
        ;; into it to clear out all of RAM. Does 2x as much work as
        ;; needed, but the loop is smaller this way. This particular
        ;; trick was taken from an old "macro.h" file for DASM that
        ;; had this routine credited to one "Andrew Davie."
a       dex
        txs
        pha
        bne a
        ;; The "bne" is testing the value of .X. When it's zero again,
        ;; that will mean all our registers are zero again, and
        ;; furthermore, we pushed a 0 into $100 (which is $80) which
        ;; wrapped around the stack pointer to $FF, which is just
        ;; where we want it.

        ;; Initial setup code

        ;; None yet!

;;; --------------------------------------------------------------------------
;;; * MAIN FRAME LOOP
;;; --------------------------------------------------------------------------
frame:
        ;; 3 lines of VSYNC
        lda     #$02
        sta     WSYNC
        sta     VSYNC
        sta     WSYNC
        sta     WSYNC
        lsr
        sta     WSYNC
        sta     VSYNC

        ;; Set timer for the remaining VBLANK period (37 lines).
        ;; 37 lines * 76 cycles/line = 2,812 cycles
        ;; $2B ticks * $40 cycles/tick = 2,752 cycles
        lda     #$2b
        sta     TIM64T

        ;; Our actual frame-update logic

        lda     #$40            ; Red background
        sta     COLUBK
        lda     #$00
        sta     GRP0            ; Invisible Players
        sta     GRP1
        sta     ENAM0           ; Disable Missiles and Ball
        sta     ENAM1           ; (TODO: GRP0-ENABL are contiguous)
        sta     ENABL
        sta     PF0             ; Invisible Playfield
        sta     PF1
        sta     PF2


        ;; Wait for VBLANK to finish
b       lda     INTIM
        bne     b
        ;; We're on the final VBLANK line now. Wait for it to finish,
        ;; then turn it off. (.A is already zero from the branch.)
        sta     WSYNC
        sta     VBLANK

;;; --------------------------------------------------------------------------
;;; * DISPLAY KERNEL
;;; --------------------------------------------------------------------------

        ;; 192 lines of main display
        ldy     #$c0
c       sta     WSYNC
        dey
        bne     c

        ;; Turn on VBLANK, do 30 lines of overscan
        lda     #$02
        sta     VBLANK
        ldy     #$1e
d       sta     WSYNC
        dey
        bne     d
        ;; Now back to the frame loop
        jmp frame

;;; --------------------------------------------------------------------------
;;; * SUPPORT ROUTINES
;;; --------------------------------------------------------------------------

        ;; None yet!

;;; --------------------------------------------------------------------------
;;; * INTERRUPT VECTORS
;;; --------------------------------------------------------------------------
        .ORG $FFFC
        .word frame
        .word frame

