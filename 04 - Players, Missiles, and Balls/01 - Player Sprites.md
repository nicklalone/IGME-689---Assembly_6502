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
# Nick Bensema's Guide to Cycle Counting on the Atari 2600
version 0.5a, 7/17/96

1. INTRODUCTION
Cycle counting is an important aspect of Atari 2600 programming. It makes possible the positioning of sprites, the drawing of six-digit  scores, non-mirrored playfield graphics and many other cool TIA tricks that keep every game from looking like Combat.  In fact, even Combat makes use of some cycle counting to position the tanks and to draw the  scores into the playfield, though its methods aren't quite as precise as  your typical Activision game.

Cycle counting's uses don't end at silly screen hacks.  It is also useful  for optimizing code to fit within a vertical blank, or a scanline, or a horizontal blank.

2. CONCEPTS OF COUNTING
Programming the Atari requires one to modify one's perceptions of space and time, because the Atari observes some sort of Abian physics where space is time.  One frame is 1/60 of a second.  One scanline is 1/20000 of a second.  You get the idea.  It is important to know how much code can
be executed in the amount of time it takes to draw the screen.  The unit of time we use is cycles.

2.1. CPU CYCLES IN RELATION TO SCREEN PIXELS
The CPU clock works at a somewhat slow pace compared to the TIA.  The TIA draws three pixels in the time it takes to execute one CPU cycle.  A `WSYNC` command will halt the processor until the horizontal blank, which lasts about 20 CPU cycles, after which the electron beam turns on and begins to draw the picture once again.  Therefore the X position of the electron beam is determined like this:

  `X = (CYCLES - 20) * 3`

where CYCLES is the number of cycles that have elapsed since the horizontal blank.  But the text I have states that registers are only read every five cycles, so the equation must be adjusted to account for that.  For now, let's just assume that we round up to the next multiple of 15.  The examples we use will involve `RESP0`, because I know the rule applies to that register.

If X is a negative number, a `RESP0` will put player 0 on the left
edge of the screen.

Let's look at a sample nonsense routine.
```asm6502
BEGIN:  
	STA WSYNC   	;I begin counting here.
    NOP             ; 0 +2 = \[2]     (Weenie instruction)
	LDA #0          ; 2 +3 = \[5]     (Fast math, immediate)
	STA $FFFF       ; 5 +4 = \[9]     (Storage, absolute)
	ROL $FFFE,X     ; 9 +7 = \[16]    (Slow math, Absolute,X)
	ROL A           ; 16+2 = \[18]    (Slow math, accumulator)
	STA RESP0       ; 18+3 = \[21]    (Storage, zero page)
	DEY             ; 21+2 = \[23]    (Weenie)
	BNE BEGIN       ; 23+3 = \[26]    (Branch)
```
The number on the left is the number of cycles that have elapsed since `WSYNC` at the beginning of each instruction, it is only there to illustrate the addition of cycles.  The number in brackets is the number of cycles that have elapsed at the end of each instruction.  It is better to keep track of this number because writes to TIA registers occur on this cycle.

Note the number 22 next to `RESP0` is in asterisks, signifying a write to a TIA register. (22-20)*3 == 6, and since it is `RESP0` we round up to 15 and that is where Player 0 goes.

The cycle count is especially important to `RESP0`, but almost all writes to TIA registers are affected in some way by the cycle count.  A player or missile modification too late in the scanline will cause the player to shift up one scanline as it moves away from the left side of the screen.  Writes to the playfield must be timed to occur in the center of the screen if one wishes to produce an asymmetrical playfield.  The number between these asterisks is very important to the program, and you may find yourself spending hours getting that number to be just what you need it to be for  your particular application.

I usually put relevant comment outside the counting column, but this isn't relevant code so I decided to illustrate the mnemonic device I used to determine the cycles for each instruction.

3. HOW TO REMEMBER WHAT TAKES HOW LONG
One cannot be expected to look at a table for every instruction they use, lest they go mad.  Many instructions, however, have similar characteristics, and so general rules can be followed in order to estimate the time of each instruction.

3.1. BRANCHING INSTRUCTIONS
>[!tip] A note about branching instructions to remember.
>Branching instructions like `BNE` and `BCC` are easier than they seem. All branch instructions take two cycles, plus one extra cycle if the branch is taken, plus another extra cycle if said branch crosses the page boundary.

When writing time-sensitive code, I recommend that branch instructions only be used at or near the end of a loop that begins in `STA WSYNC`, or in tight loops that are designed to waste a certain number of cycles. DEY-BNE loops, which are a common way of accomplishing this, will be covered later.

Let's just say for now that the decision of whether to branch should be generally constant throughout at least the time-sensitive portions of your routine.  

3.2. FAST MATH INSTRUCTIONS
The 6502 has a family of "fast math" opcodes that have similar characteristics, and consequently they have the same cycle counts.  These fast math opcodes do little more than alter registers or flags using bits from memory.  This family consists of `ADC`, `AND`, `BIT`, `CMP`, `CPX, CPY`, `EOR`, `LDA`, `LDX`, `LDY`, `ORA`, and `SBC`.  Not all of these instructions have all of the following address modes, but these rules apply to whichever modes are available.  I will use `ADC` as an example.

        ADC #$01        ; +2    Immediate
        ADC $99         ; +3    Zero Page
        ADC $99,X       ; +4    Zero Page,X  (or ,Y)
        ADC $1234       ; +4    Absolute
        ADC $1234,X     ; +4*   Absolute,X  (or ,Y)
        ADC ($AA,X)     ; +6    (Indirect,X)
        ADC ($CC),Y     ; +5*   (Indirect),Y

The asterisk \(\*) signifies that if the instruction indexes across a page boundary, add one cycle.  In some cases, just one cycle might not matter.  

Also note that Zero Page,Y addressing is only available for `LDX` and `STX`.

3.3. STORAGE INSTRUCTIONS
The instructions STA, STX, and STY have the same timing as fast math instructions, but in the case of Absolute,XY and (Indirect),Y addressing, the extra cycle is always added.

3.4. WEENIE INSTRUCTIONS
These weenie instructions don't even alter memory, only registers and flags. They are `CLC`, `CLD`, `CLI`, `CLV`, `DEX`, `DEY`, `INX`, `INY`, `NOP`, `SEC`, `SED`, `SEI`, `TAX`, `TAY`, `TSX`, `TXA`, `TXS`, and `TYA`.  They take two cycles.  

3.5. SLOW MATH INSTRUCTIONS
There are certain instructions that take more clock cycles than simple math instructions.  Some of these instructions can work with the accumulator, but when given an address to work with, they modify memory directly.  The slow 
math instructions are `ASL`, `DEC`, `INC`, `LSR`, `ROL`, and `ROR`.

        ROR A           ; +2  Accumulator
        ROR $99         ; +5  Zero Page
        ROR $99,X       ; +6  Zero Page,X
        ROR $1234       ; +6  Absolute
        ROR $1234,X     ; +7  Absolute,X

Note that when these instructions work with the accumulator, they shrink down to two cycles and become Weenie Instructions.

3.6. STACK INSTRUCTIONS
The two push instructions, `PHA` and `PHP`, each take three cycles. The two pull instructions, `PLA` and `PLP`, each take four cycles.

3.7. OTHER INSTRUCTIONS
a.k.a INSTRUCTIONS YOU HAVE NO BUSINESS USING IN TIME-SENSITIVE CODE

`JSR` takes 6 cycles.  `JMP` takes 3 cycles in absolute mode, and 5 cycles in absolute indirect mode, but absolute indirect mode is for machines that have a kernel.  `RTI` and `RTS` take 6 cycles each.  But with only a few dozen instructions available per scanline, you don't have time to bounce all over the cartridge executing subroutines.

4. CYCLE COUNTING IN PRACTICE

4.1. MULTIPLE POSSIBILITIES

This is how I would handle wishy-washy code that uses a branch.
```asm6502
BEGIN   STA WSYNC       ;CYCLES...
        NOP             ; [0]   +2
        BIT $CC         ; [2]   +3
        BMI STUPID      ; [5]   +2 if not taken...
        NOP             ; [7]   +2   Pretend everything's
        NOP             ; [9]   +2   just smurfy, until...
        NOP             ; [11]  +2
	NOP             ; [13]
	NOP             ; [15]
	NOP		; [17]
        NOP             ; [19]  +2  IF BRANCHED
STUPID  LDA $F0         ; [21]  +3   [8]  (BMI takes +3 now)
        STA GRP0        ; *24*  +3   *11*
        LDA $F1         ; [27]  +3   [14]
        STA ENAM0       ; *30*  +3   *17*
        STA RESP0       ; *33*  +3   *20*
        STA WSYNC```

I have to count both possibilities, side by side.  Perhaps there is a shorter way to do this, but this way if I have to keep track of a long list, I won't have to page up in the code to figure out what the difference is.
 
If you can guess what this code does, congratulations.  If you can't, I'll tell you.  This code checks bit 8 of location $CC.  If it is set, it goes immediately to set player 0's registers, setting its position at cycle 20.  If it is clear, then the branch isn't taken so that saves us one cycle, but fourteen more cycles are taken by NOPs, making a net gain of 13 cycles.  Now it takes 33 cycles to reset player 0.

4.2. HOW TO TAME THE MIGHTY (INDIRECT),Y
Recall that if an (Indirect),Y instruction indexes across a page boundary, the CPU takes an extra cycle. This means that depending on the value of Y, the instruction might take four or five cycles.

In six-column or other high resolution display routines, as many as six (Indirect),Y instructions appear in one scanline.  This adds up to six extra cycles that may or may not be taken. This could throw off your timing unless your data is properly arranged.

Make sure when putting graphics into your program, to arrange the data so that they either NEVER cross page boundaries, or ALWAYS cross page boundaries.  As long as you can predict when that extra cycle is going to pop up, you'll be OK.  You might need to play around with the assembler and the source code to make sure all the bytes in each graphics table are in the same page of memory.

In contrast, one could conceivably use either (Indirect),Y 
or Absolute,XY addressing as part of some sick, twisted timing loop with single-cycle precision, but most TIA applications only have a need for three-cycle precision.

4.3. THE DEY-BNE LOOP AND ITS APPLICATIONS
The DEY-BNE loop is a useful delay loop.  How useful, I won't know until I see it applied where Y equals a variable.  I did see it applied to a constant in this code from Defender:

```asm6502
       STA    WSYNC   ;               Cycle count:
       STA    PF2     ;Clear PF2       [0]  +3
       LDA    $EA     ;                [3]  +3
       STA    COLUP0  ;                [6]  +3
       STA    COLUP1  ;                [9]  +3
       LDY    #$08    ;                [12] +2   Y is set here
       STA    RESP0   ;                *14* +3
LF867: DEY            ;When 8 (17), when 0 (52)  }
       BNE    LF867   ;At end of loop, (54)      } +39
       STA    RESP1   ;                *56* +3
        ; End result: players are 42 CPU cycles apart.
```

`RESP0` occurs at 14 cycles, which is still within the horizontal blank, so player 0 appears at the left side of the screen.  RESP1 occurs at 56 cycles, and (56-20)\*3 = 108 pixels.  Stella.txt says I'm supposed to round that up to a multiple of 15, so that's.... 120.  If player 1 is in triple repeat mode, that would put it on the right edge of the screen.

And since this is the routine that sets the `TIA` up to display the number of  remaining lives and smart bombs in Defender, that's a distinct possibility.

You can see how I came to the above conclusion if we unroll the loop.

```asm6502
LF867: DEY           ; Y becomes 7          +2 }
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 6          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 5          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 4          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 3          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 2          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 1          +2
       BNE    LF867  ; Branch is taken.     +3 } 5
LF867: DEY           ; Y becomes 0          +2
       BNE    LF867  ; Branch is NOT taken. +2 } 4
```

Each time through the loop where Y>0, `DEY` takes two cycles and `BNE` takes three cycles (due to the branch).  The last time through the loop, when Y=0, the branch is not taken so the `BNE` only takes two cycles.

From this, we can build a model for the DEY-BNE loop.
```asm6502
       LDY #NUM ; +2
    ; extra code possible here
DEYBNE DEY        ; }
       BNE DEYBNE ; } + NUM*5-1
```

Note that each iteration takes 5 CPU cycles, or 15 pixels.  This is as close as it gets to perfect for our needs, since the TIA will only let you set up a player with RESP0 on a multiple of 15.  

The X register can also be used to this end, but hey, it needs a name, doesn't it?

CONCLUSION
Keep your code clean and tight.  Make sure your display kernel routines use the same number of scanlines no matter what happens.
# Player Sprite Makers and Sample Code


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
# <a id='classexp'></a>Playfield, Sprite, and Score Example
```asm6502
    processor 6502

;=============================================================
; Include required files with register mapping and macros
;=============================================================

    include "vcs.h"
    include "macro.h"

;=============================================================
;; Here, we can define a few different dependencies / variables.
;; In this case, we're basically defining where some variables can live.
;; in memory. Here, we're basically making a 1-byte variable for player height.
;; You can use ds or .byte.
;=============================================================

    seg.u Variables
    org $80
P0Height ds 1     ; defines one byte for player 0 height
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

;=============================================================
; We've rendered our number and so we need to disable the loop and the playfield.
; In this way, we'll finish it. Try commenting the below out to see what happens.
;=============================================================

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
# Example from the Community

```asm6502
	processor 6502
	include "vcs.h"
    include "macro.h"
	
	SEG Code
	org $F000

	SEG.u Variables
	org $80

YPosFromBot = $80;
VisiblePlayerLine = $81;

;generic start up stuff...
Start CLEAN_START
	
	LDA #$00   ;start with a black background
	STA COLUBK	
	LDA #$1C   ;lets go for bright yellow, the traditional color for happyfaces
	STA COLUP0
;Setting some variables...
	LDA #80
	STA YPosFromBot	;Initial Y Position

;; Let's set up the sweeping line. as Missile 1
	
	LDA #2
	STA ENAM1  ;enable it
	LDA #33
	STA COLUP1 ;color it

	LDA #$20	
	STA NUSIZ1	;make it quadwidth (not so thin, that)

	
	LDA #$F0	; -1 in the left nibble
	STA HMM1	; of HMM1 sets it to moving


;VSYNC time
MainLoop
	LDA #2
	STA VSYNC	
	STA WSYNC	
	STA WSYNC 	
	STA WSYNC	
	LDA #43	
	STA TIM64T	
	LDA #0
	STA VSYNC 	


;Main Computations; check down, up, left, right
;general idea is to do a BIT compare to see if 
;a certain direction is pressed, and skip the value
;change if so

;
;Not the most effecient code, but gets the job done,
;including diagonal movement
;

; for up and down, we INC or DEC
; the Y Position

	LDA #%00010000	;Down?
	BIT SWCHA 
	BNE SkipMoveDown
	INC YPosFromBot
        
SkipMoveDown
	LDA #%00100000	;Up?
	BIT SWCHA 
	BNE SkipMoveUp
	DEC YPosFromBot
        
SkipMoveUp

; for left and right, we're gonna 
; set the horizontal speed, and then do
; a single HMOVE.  We'll use X to hold the
; horizontal speed, then store it in the 
; appropriate register


;assum horiz speed will be zero
	LDX #0	

	LDA #%01000000	;Left?
	BIT SWCHA 
	BNE SkipMoveLeft
	LDX #$10	;a 1 in the left nibble means go left

;; moving left, so we need the mirror image
	LDA #%00001000   ;a 1 in D3 of REFP0 says make it mirror
	STA REFP0

SkipMoveLeft
	LDA #%10000000	;Right?
	BIT SWCHA 
	BNE SkipMoveRight
	LDX #$F0	;a -1 in the left nibble means go right...

;; moving right, cancel any mirrorimage
	LDA #%00000000
	STA REFP0

SkipMoveRight


	STX HMP0	;set the move for player 0, not the missile like last time...



; see if player and missile collide, and change the background color if so

	;just a review...comparisons of numbers always seem a little backwards to me,
	;since it's easier to load up the accumulator with the test value, and then
	;compare that value to what's in the register we're interested.
	;in this case, we want to see if D7 of CXM1P (meaning Player 0 hit
	; missile 1) is on. So we put 10000000 into the Accumulator,
	;then use BIT to compare it to the value in CXM1P

	LDA #%10000000
	BIT CXM1P		
	BEQ NoCollision	;skip if not hitting...
	LDA YPosFromBot	;must be a hit! load in the YPos...
	STA COLUBK	;and store as the bgcolor
NoCollision
	STA CXCLR	;reset the collision detection for next time




WaitForVblankEnd
	LDA INTIM	
	BNE WaitForVblankEnd	
	LDY #191 	


	STA WSYNC	
	STA HMOVE 	
	
	STA VBLANK  	


;main scanline loop...


ScanLoop 
	STA WSYNC 	

; here the idea is that VisiblePlayerLine
; is zero if the line isn't being drawn now,
; otherwise it's however many lines we have to go

CheckActivatePlayer
	CPY YPosFromBot
	BNE SkipActivatePlayer
	LDA #8
	STA VisiblePlayerLine 
SkipActivatePlayer

;set player graphic to all zeros for this line, and then see if 
;we need to load it with graphic data
	LDA #0		
	STA GRP0  

;
;if the VisiblePlayerLine is non zero,
;we're drawing it now!
;
	LDX VisiblePlayerLine	;check the visible player line...
	BEQ FinishPlayer		;skip the drawing if its zero...
IsPlayerOn	
	LDA BigHeadGraphic-1,X	;otherwise, load the correct line from BigHeadGraphic
				;section below... it's off by 1 though, since at zero
				;we stop drawing
	STA GRP0		;put that line as player graphic
	DEC VisiblePlayerLine 	;and decrement the line count
FinishPlayer


	DEY		
	BNE ScanLoop	

	LDA #2		
	STA WSYNC  	
	STA VBLANK 	
	LDX #30		
OverScanWait
	STA WSYNC
	DEX
	BNE OverScanWait
	JMP  MainLoop      


; here's the actual graphic! If you squint you can see its
; upsidedown smiling self
BigHeadGraphic
	.byte #%00111100
	.byte #%01111110
	.byte #%11000001
	.byte #%10111111
	.byte #%11111111
	.byte #%11101011
	.byte #%01111110
	.byte #%00111100

	org $FFFC
	.word Start
	.word Start
```
# <a id='otherexp'></a>Other Examples
* This discussion is good for Input, Missiles, and Collisions: https://bumbershootsoft.wordpress.com/2024/09/07/atari-2600-input-missiles-and-collisions/