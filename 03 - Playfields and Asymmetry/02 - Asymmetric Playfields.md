---------------- Table of Contents ---------------- 

1. [Admin](#admin)
2. [Getting Started](#getstart)
3. [Hello World](#helloworld)
4. [Hell World](#hellworld)

---------------- Table of Contents ---------------- 
This week we're mostly going to play a selection of games that are asymmetric. We'll see if we can find the source code as COMBAT is not. 
# <a id = "Admin"></a>Admin
Hello World and the Playfield
# <a id='getstart'></a>Getting Started
![](/images/timing.png)

Or another version of this from 8blit: 
![asym-cycles.png](/images/asym-cycles.png)

# <a id='classexp'></a>Class Example
We'll be going through this in class. My hope here is to show you how the above examples work and in doing so, prepare you for your time if you want asymmetry in your life. Note here that it is not easy. I'll come up with some interesting examples for you at some point in the semester: 
```asm6502
; A Simple Asymmetrical Title Screen Playfield
;
; this is a simple kernal meant to be usable for a title screen.
; can be adapted to put playfield text at an arbitrary height on the screen
;
; it owes a great debt to Glenn Saunders Thu, 20 Sep 2001 Stella post
; " Asymmetrical Reflected Playfield" (who in turn took from Roger Williams,
; who in turn took from Nick Bensema--yeesh!)
;
; it's meant to be a tightish, welll-commented, flexible kernal,
; that displays a title (or other playfield graphic) once, 
; instead of repeating it - also it's a steady 60 FPS, 262 scanlines,
; unlike some of its predecessors
;
; also, it's non-reflected, so you can easily use a tool like my
; online javascript tool at http://alienbill.com/vgames/playerpal/
; to draw the playfield
;
; It uses no RAM, but all Registers when it's drawing the title 


	processor 6502
	include vcs.h
	include macro.h
	org $F000
Start
	CLEAN_START

	lda #00
	sta COLUBK  ;black background 	
	lda #33    
	sta COLUPF  ;colored playfield

;MainLoop starts with usual VBLANK code,
;and the usual timer seeding
MainLoop
	VERTICAL_SYNC
	lda #43	
	sta TIM64T
;
; lots of logic can go here, obviously,
; and then we'll get to the point where we're waiting
; for the timer to run out

WaitForVblankEnd
	lda INTIM	
	bne WaitForVblankEnd	
	sta VBLANK  	


;so, scanlines. We have three loops; 
;TitlePreLoop , TitleShowLoop, TitlePostLoop
;
; I found that if the 3 add up to 174 WSYNCS,
; you should get the desired 262 lines per frame
;
; The trick is, the middle loop is 
; how many pixels are in the playfield,
; times how many scanlines you want per "big" letter pixel 

pixelHeightOfTitle = #6
scanlinesPerTitlePixel = #6

; ok, that's a weird place to define constants, but whatever

;just burning scanlines....you could do something else
	ldy #20
TitlePreLoop
	sta WSYNC	
	dey
	bne TitlePreLoop

	ldx #pixelHeightOfTitle ; X will hold what letter pixel we're on
	ldy #scanlinesPerTitlePixel ; Y will hold which scan line we're on for each pixel

;
;the next part is careful cycle counting from those 
;who have gone before me....

TitleShowLoop
	sta WSYNC 	
	lda PFData0Left-1,X           ;[0]+4
	sta PF0                 ;[4]+3 = *7*   < 23	;PF0 visible
	lda PFData1Left-1,X           ;[7]+4
	sta PF1                 ;[11]+3 = *14*  < 29	;PF1 visible
	lda PFData2Left-1,X           ;[14]+4
	sta PF2                 ;[18]+3 = *21*  < 40	;PF2 visible
	nop			;[21]+2
	nop			;[23]+2
	nop			;[25]+2
	;six cycles available  Might be able to do something here
	lda PFData0Right-1,X          ;[27]+4
	;PF0 no longer visible, safe to rewrite
	sta PF0                 ;[31]+3 = *34* 
	lda PFData1Right-1,X		;[34]+4
	;PF1 no longer visible, safe to rewrite
	sta PF1			;[38]+3 = *41*  
	lda PFData2Right-1,X		;[41]+4
	;PF2 rewrite must begin at exactly cycle 45!!, no more, no less
	sta PF2			;[45]+2 = *47*  ; >



	dey ;ok, we've drawn one more scaneline for this 'pixel'
	bne NotChangingWhatTitlePixel ;go to not changing if we still have more to do for this pixel
	dex ; we *are* changing what title pixel we're on...

	beq DoneWithTitle ; ...unless we're done, of course
	
	ldy #scanlinesPerTitlePixel ;...so load up Y with the count of how many scanlines for THIS pixel...
NotChangingWhatTitlePixel
	
	jmp TitleShowLoop

DoneWithTitle	

	;clear out the playfield registers for obvious reasons	
	lda #0
	sta PF2 ;clear out PF2 first, I found out through experience
	sta PF0
	sta PF1
;just burning scanlines....you could do something else
	ldy #137
TitlePostLoop
	sta WSYNC
	dey
	bne TitlePostLoop

; usual vblank
	lda #2		
	sta VBLANK 	
	ldx #30		
OverScanWait
	sta WSYNC
	dex
	bne OverScanWait
	jmp  MainLoop      
;
; the graphics!
; I suggest my online javascript tool, 
;PlayfieldPal at http://alienbill.com/vgames/playerpal/
;to draw these things. Just rename 'em left and right

PFData0Left
        .byte #%00000000
        .byte #%00000000
        .byte #%10000000
        .byte #%01000000
        .byte #%00000000
        .byte #%00000000

PFData1Left
        .byte #%00000000
        .byte #%00000000
        .byte #%00010011
        .byte #%10101010
        .byte #%10010010
        .byte #%10000000

PFData2Left
        .byte #%00000000
        .byte #%00000000
        .byte #%10001101
        .byte #%10001001
        .byte #%11011001
        .byte #%10000000



PFData0Right
        .byte #%00000000
        .byte #%00000000
        .byte #%01000000
        .byte #%11000000
        .byte #%01010000
        .byte #%11000000

PFData1Right
        .byte #%00000000
        .byte #%00000000
        .byte #%00010010
        .byte #%00101010
        .byte #%10010011
        .byte #%00000000

PFData2Right
        .byte #%00001100
        .byte #%00010000
        .byte #%00011001
        .byte #%00010101
        .byte #%00011000
        .byte #%00000000
	org $FFFC
	.word Start
	.word Start
```

# <a id = "helloworld"></a>Hello, World
```asm6502
;
; hello.asm
;
; A "Hello, World!" which illustrates an Atari 2600 programming
; introduction talk (slides at http://slideshare.net/chesterbr).
;
; This is free software (see license below). Build it with DASM
; (http://dasm-dillon.sourceforge.net/), by running:
;
;   dasm hello.asm -ohello.bin -f3
;

    PROCESSOR 6502
    INCLUDE "vcs.h"

    ORG $F000       ; Start of "cart area" (see Atari memory map)

;=============================================================
; Alright, let's do our normal thing. We have to get our kernel in order.
;=============================================================

StartFrame:
    lda #%00000010  ; Vertical sync is signaled by VSYNC's bit 1...
    sta VSYNC
    REPEAT 3        ; ...and lasts 3 scanlines
    sta WSYNC   ; (WSYNC write => wait for end of scanline)
    REPEND
    lda #0
    sta VSYNC       ; Signal vertical sync by clearing the bit

PreparePlayfield:   ; We'll use the first VBLANK scanline for setup
    lda #$00        ; (could have done it before, just once)
    sta ENABL       ; Turn off ball, missiles and players
    sta ENAM0
    sta ENAM1
    sta GRP0
    sta GRP1
    sta COLUBK      ; Background color (black)
    sta PF0         ; PF0 and PF2 will be "off" (we'll focus on PF1)...
    sta PF2
    lda #35        ; Playfield collor (yellow-ish)
    sta COLUPF
    lda #$00        ; Ensure we will duplicate (and not reflect) PF
    sta CTRLPF
    ldx #0          ; X will count visible scanlines, let's reset it
    REPEAT 37       ; Wait until this (and the other 36) vertical blank
        sta WSYNC   ; scanlines are finished
    REPEND
    lda #0          ; Vertical blank is done, we can "turn on" the beam
    sta VBLANK

Scanline:
    cpx #174        ; "HELLO WORLD" = (11 chars x 8 lines - 1) x 2 scanlines =
    bcs ScanlineEnd ;   174 (0 to 173). After that, skip drawing code
    txa             ; We want each byte of the hello world phrase on 2 scanlines,
    lsr             ;   which means Y (bitmap counter) = X (scanline counter) / 2.
    tay             ;   For division by two we use (A-only) right-shift
    lda Phrase,y    ; "Phrase,Y" = mem(Phrase+Y) (Y-th address after Phrase)
    sta PF1         ; Put the value on PF bits 4-11 (0-3 is PF0, 12-15 is PF2)
    
ScanlineEnd:
    sta WSYNC       ; Wait for scanline end
    inx             ; Increase counter; repeat untill we got all kernel scanlines
    cpx #191
    bne Scanline

Overscan:
    lda #%01000010  ; "turn off" the beam again...
    sta VBLANK      ;
    REPEAT 30       ; ...for 30 overscan scanlines...
        sta WSYNC
    REPEND
    jmp StartFrame  ; ...and start it over!

Phrase:
    .BYTE %00000000 ; H
    .BYTE %01000010
    .BYTE %01111110
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %00000000
    .BYTE %00000000 ; E
    .BYTE %01111110
    .BYTE %01000000
    .BYTE %01111100
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111110
    .BYTE %00000000
    .BYTE %00000000 ; L
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111110
    .BYTE %00000000
    .BYTE %00000000 ; L
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111110
    .BYTE %00000000 ; O
    .BYTE %00000000
    .BYTE %00111100
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %00111100
    .BYTE %00000000
    .BYTE %00000000 ; white space
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000
    .BYTE %00000000 ; W
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01011010
    .BYTE %00100100
    .BYTE %00000000
    .BYTE %00000000 ; O
    .BYTE %00111100
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %00111100
    .BYTE %00000000
    .BYTE %00000000 ; R
    .BYTE %01111100
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01111100
    .BYTE %01000100
    .BYTE %01000010
    .BYTE %00000000
    .BYTE %00000000 ; L
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01000000
    .BYTE %01111110
    .BYTE %00000000
    .BYTE %00000000 ; D
    .BYTE %01111000
    .BYTE %01000100
    .BYTE %01000010
    .BYTE %01000010
    .BYTE %01000100
    .BYTE %01111000
    .BYTE %00000000 ; Last byte written to PF1 (important, ensures lower tip
                    ;                           of letter "D" won't "bleeed")

    ORG $FFFA             ; Cart config (so 6507 can start it up).
                          ;
                          ; This address will make DASM build a 4K cart image.
                          ; Since the code actually takes < 300 bytes, you can
                          ; replace with ORG $F7FA to build a 2K image. Such
                          ; carts are wired to mirror their contents, so the
                          ; CPU will pick up the config at the same address.
                          ; 
                          ; You can even make it 1K with ORG $F3FA, but I'm
                          ; not sure 1K carts were ever manufactured. Stella
                          ; plays them fine, but YMMV on Supercharger and
                          ; other hardware/emulators.

    .WORD StartFrame      ;     NMI
    .WORD StartFrame      ;     RESET
    .WORD StartFrame      ;     IRQ
```

# <a id="hellworld"></a>Hell World
So, I wanted to make a game which basically resulted in this course. But all that prompt was, was, "I want to make a game."

And so...what?

Well, one of the biggest hurdles for me is that I've been in and around video games for a number of years but I've never had a game ship. 
