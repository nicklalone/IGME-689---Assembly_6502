---------------- Table of Contents ---------------- 

1. [Admin](#admin)
2. [Assignment](#assignment)
3. [Getting Started](#getstart)
4. [OpCodes of Interest](#opcodes)
5. [Class Example](#classexp)
6. [Other Examples](#otherexp)

---------------- Table of Contents ---------------- 
# <a id="admin"></a>Admin
I have gone through most of the reading assignments. We are starting coding this week, let's take an inventory of coding capacity in class and who might be more helpful. 
# <a id='assignment'></a>Assignment
This week, we're doing Source Code reading. This will probably be a bit difficult at first but I just want you to try your best. As we move forward, it will get easier as you'll be exposed to more stuff. The point of assignments like these is to get you used to looking through source files for inspiration and fixes for things. 

The first assignment is simple, I want the labels that check for missile collision with walls and the playfield and I want you to tell me how they work and what the logic is. I want you to speculate a little as this is the first time so you probably won't exactly know but this source is VERY well commented and is the prototype of everything for the console.
# <a id = "getstart"></a>Getting Started
# <a id='opcodes'></a>Opcodes of Interest
Again, these can all be found: 
* https://www.masswerk.at/nowgobang/2021/6502-illegal-opcodes
* https://www.masswerk.at/6502/6502_instruction_set.html
* **OpCodes**:
	* `GRP0 or GRP1` - 8 bit pattern. Graphics of Player 0 or 1
	* `COLUP0 or COLUP1` - 8-bit pattern. Color Luminescence Player 0 or 1
	* `NUSIZ0 or NUSIZ1` - Controls the number and size of player 0,1 and missile 0,1.
		* Has a number of bits that indicate duplication, stretch, and other things.
	* `REFP0, REFP1` - Reflect Player 0 or 1. 
		* Basically, which way do you want the player to face?
	* `M0 or M1` - Missile 0 or Missile 1. Just 1 pixel but can be stretched 2/4/8 times.
	* `BL` - Ball and it uses the Playfield Foreground color.

The basic idea of making an Atari game is that for each scanline from the top left to bottom right, we have to configure the Television Interface Adaptor or TIA registers for each object JUST before the beam reaches its intended position.
# <a id='classexp'></a>Class Example
```asm6502
    processor 6502

;=============================================================
; Include required files with register mapping and macros
;=============================================================

    include "vcs.h"
    include "macro.h"

;=============================================================
;; Start an uninitialized segment at $80 for var declaration.
;=============================================================

    seg.u Variables
    org $80
P0Height .byte     ; defines one byte for player 0 height
P1Height .byte     ; defines one byte for player 1 height

;=============================================================
; Start our ROM code segment starting at $F000.
;=============================================================
    seg Code
    org $F000

Reset:
    CLEAN_START    ; macro to clean memory and TIA

    ldx #$80       ; blue background color
    stx COLUBK

    lda #%1111     ; white playfield color
    sta COLUPF

;=============================================================
; Initialize P0Height and P1Height with the value 10.
;=============================================================
    lda #10        ; A = 10
    sta P0Height   ; P0Height = A
    sta P1Height   ; P1Height = A

;=============================================================
; We set the TIA registers for the colors of P0 and P1.
;=============================================================
    lda #$48       ; player 0 color light red
    sta COLUP0

    lda #$C6       ; player 1 color light green
    sta COLUP1

    ldy #%00000010 ; CTRLPF D1 set to 1 means (score)
    sty CTRLPF

;=============================================================
; Start a new frame by configuring VBLANK and VSYNC
;=============================================================
StartFrame:
    lda #2
    sta VBLANK     ; turn VBLANK on
    sta VSYNC      ; turn VSYNC on

;=============================================================

    REPEAT 3
        sta WSYNC  ; first three VSYNC scanlines
    REPEND

    lda #0
    sta VSYNC      ; turn VSYNC off

;=============================================================
; Let the TIA output the 37 recommended lines of VBLANK
;=============================================================
    REPEAT 37
        sta WSYNC
    REPEND

    lda #0
    sta VBLANK     ; turn VBLANK off

;=============================================================
; Draw the 192 visible scanlines
;=============================================================

VisibleScanlines:

    ; Draw 10 empty scanlines at the top of the frame
    REPEAT 10
        sta WSYNC
    REPEND

;=============================================================
; Displays 10 scanlines for the scoreboard number.
; Pulls data from an array of bytes defined at NumberBitmap.
;=============================================================

    ldy #0
ScoreboardLoop:
    lda NumberBitmap,Y
    sta PF1
    sta WSYNC
    iny
    cpy #10
    bne ScoreboardLoop

    lda #0
    sta PF1        ; disable playfield

    ; Draw 50 empty scanlines between scoreboard and and player
    REPEAT 50
        sta WSYNC
    REPEND

;=============================================================
; Displays 10 scanlines for the Player 0 graphics.
; Pulls data from an array of bytes defined at PlayerBitmap.
;=============================================================

    ldy #0
Player0Loop:
    lda PlayerBitmap,Y
    sta GRP0
    sta WSYNC
    iny
    cpy P0Height
    bne Player0Loop

    lda #0
    sta GRP0       ; disable player 0 graphics

;=============================================================
; Displays 10 scanlines for the player 1 graphics.
; Pulls data from an array of bytes defined at PlayerBitmap.
;=============================================================

    ldy #0
Player1Loop:
    lda PlayerBitmap,Y
    sta GRP1
    sta WSYNC
    iny
    cpy P1Height
    bne Player1Loop

    lda #0
    sta GRP1       ; disable player 1 graphics

;=============================================================
; Draw the remaining 102 scanlines (192-90), since we already
; used 10+10+50+10+10=80 scanlines in the current frame.
;=============================================================

    REPEAT 102
        sta WSYNC
    REPEND

;=============================================================
; Output 30 more VBLANK overscan lines to complete our frame
;=============================================================

    REPEAT 30
        sta WSYNC
    REPEND

;=============================================================
; Loop to next frame
;=============================================================

    jmp StartFrame

;=============================================================
; Defines an array of bytes to draw the scoreboard number.
; We add these bytes in the last ROM addresses.
;=============================================================

    org $FFE8
PlayerBitmap:
    .byte #%01111110   ;  ######
    .byte #%11111111   ; ########
    .byte #%10011001   ; #  ##  #
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%11111111   ; ########
    .byte #%10111101   ; # #### #
    .byte #%11000011   ; ##    ##
    .byte #%11111111   ; ########
    .byte #%01111110   ;  ######

;=============================================================
; Defines an array of bytes to draw the scoreboard number.
; We add these bytes in the final ROM addresses.
;=============================================================

    org $FFF2
NumberBitmap:
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00000010   ;      ###
    .byte #%00000010   ;      ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########
    .byte #%00001000   ; ###
    .byte #%00001000   ; ###
    .byte #%00001110   ; ########
    .byte #%00001110   ; ########

;=============================================================
; Complete ROM size
;=============================================================

    org $FFFC
    .word Reset
    .word Reset

```
# <a id='otherexp'></a>Other Examples
* This discussion is good for Input, Missiles, and Collisions: https://bumbershootsoft.wordpress.com/2024/09/07/atari-2600-input-missiles-and-collisions/