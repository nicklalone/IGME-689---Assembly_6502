---------------- Table of Contents ---------------- 

1. [Admin](#admin)
2. [Getting Started](#getstart)
3. [Hello World](#helloworld)
4. [Hell World](#hellworld)

---------------- Table of Contents ---------------- 
as
# <a id = "Admin"></a>Admin
Hello World and the Playfield
# <a id='getstart'></a>Getting Started
![](/images/timing.png)
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
