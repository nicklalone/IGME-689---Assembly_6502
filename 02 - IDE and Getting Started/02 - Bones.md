---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [Bones](#bones)
	1. [An Error?](#anerr)
4. [More Bones](#morebones)
5. [Even MORE Bones](#evenmore)
6. [Terms](#terms)

---------------- Table of Contents ---------------- 
# <a id = "welcoime"></a>Welcome

Today is when we start coding. We'll take it slowly as I wanted to make sure folks who aren't used to this type of programming can actually start digging in. 

The point of today is to give you everything you need to start painting. It might be a bit boring but it's important to get this level of finicky out of the way but also as an important part of what you'll be doing. It is finicky, it's weird! It's...maybe fun?

But in any case, if you're ahead of this, go to town. You can start making your game now and all of the assignments can be done without coming to class. Learning is varied and none of us learn the same way. If you dislike my approach, find your own. 

It is why i've arranged for the assignments and things to be unrelated to prototyping and coding but centered on what has been made.
# <a id="logistics"></a>Logistics and End of Semester Thoughts
So, we're going to be busy for around 11 weeks in talking about games, playing them, doing some coding exercises, and just sort of thinking about how the game world of atari works. 

In no way are you banned or barred from working on your game now. Just know that the last 5ish weeks are devoted to letting you work on your game. I will be available via Discord for debugging and error testing, so will all of you.

The big project at the end of class is relatively straight forward: 
1. Make a Game, 
2. Make a Sticker, 
3. Make a Box, and 
4. Make an Instruction Manual. 

The game will be a ROM and is the central part of the class. The rest is going to be based on your, or your friend's talent...or at the various least how good you can type on a black background or use photoshop. 

I'll provide templates and files to edit for proper sizing.
# <a id="bones"></a>Bones
So, there are a bunch of things we need to do when we are starting a project. Since the console itself has no firmware, we have to take care of that stuff as we begin. I have taken most of this from the Pikuma course as well as your textbook. That it replicates the same error is not a mistake, we need to make errors to discuss parts that won't be able to be noticed unless the mistake is made. In fact, i'd guess the order of operations will come up and you won't know why despite telling you this. 

If you want to play around with op-codes and what they do, you can use: https://skilldrick.github.io/easy6502/ to muck about.

First, we need to take into account our IDE and this will be a part of just about everythiing we do. We have to call into being our processor and assemblers.
```asm6502
    processor 6502
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"
```
If you're curious abbout these, go to: https://github.com/munsie/dasm/tree/master and start reading. This is the DASM community's repo with DASM. If you want a bit less of a burden to read, try this: https://forums.atariage.com/topic/27221-session-9-6502-and-dasm-assembling-the-basics/

Next up, we have to tell the hardware where our memory addresses begin. This is important because we basically have to tell the hardware where to point its initial register. Basically, we're saying to the Assembler (DASM) that we are actually beginning our code now and that the memory unit
```asm6502
    seg code
    org $F000       ; Define the code origin at $F000
```
In this case, we're pointing to the very bottom of the stack. I found this useful slide that gives us the range of the memory: https://www.slideshare.net/slideshow/atari-2600programming/23550414

![](/images/memorymap.png)
Or, we can see this mapped out for us in 8bitworkshop's memory map: 
![](/images/memmap.png)

And I should probably mention here that you're going to need some way to shift between binary, hexadecimal, literal values. We're going to use a converter to keep track unless you want me to drill this knowledge into you and I don't honestly know if we have time. 
```asm6502
Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer
```
Next, we have to really get started. We've disabled interrupts (because the 6507 doesn't have that pin but we still have to account for it in 6502.) We're also disabling Binary Coded Decimals so we can write numbers without having to worry about them being used as numbers: http://www.6502.org/tutorials/decimal_mode.html you can read more about it here.

The easiest description is probably from that page: 

	A byte has 256 possible values, ranging, in hex, from $00 to $FF. These values may represent numbers, characters, or other data. The most common way of representing numbers is as a binary number (or more specifically, an unsigned binary integer), where $00 to $FF represents 0 to 255. In BCD, a byte represents a number from 0 to 99, where $00 to $09 represents 0 to 9, $10 to $19 represents 10 to 19, and so on, all the way up to $90 to $99, which represents 90 to 99. In other words, the upper digit (0 to 9) of the BCD number is stored in the upper 4 bits of the byte, and the lower digit is stored in the lower 4 bits. These 100 values are called valid BCD numbers. The other 156 possible values of a byte (i.e. where either or both hex digits are A to F) are called invalid BCD numbers. By contrast, all 256 possible values of a byte are valid binary numbers.

There will be times when we need to do math, and that's fine. We will do that when we get there in a couple weeks. For now, we'll mostly just work with `BNE` or `Branch if Not Equal` and `DEC` or `Decrement`. You may find this a weird concept given this particular code but accumulators are inherently numeric entities.

So we've now gotten all our ducks in a row. Let's start thinking about some things. We need to start pushing information through the hardware. We will do something simple to begin like call into being a couple of registers (x and a). So, we'll first load something into a with `lda #0` or, "Load into A the number 0." Next, we have to do something with X since we did `ldx #$FF`. This is the X register's maximum value. And so, we want to start to lower it, why?

Well, the model for this is relatively simple. I'll call it out in a list: 
1. Load 0 into A
2. Load #$FF into X.
3. Create a loop called `MemLoop`
4. Inside that memloop, store 0 and add to it, the current value of X. 
5. then decrement X by 1 and restart the loop.

For X, then, it would look like `#$FF` and then after decrementing, `#$FE` and then after decrementing `#$FD` and so on and so forth until it gets to the lowest value. 
```asm6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0          ; A = 0
    ldx #$FF        ; X = #$FF
MemLoop:            ; 
    sta $0,X        ; Store the value of A inside memory address $0 + X
    dex             ; X--
    bne MemLoop     ; Loop until X is equal to zero (z-flag is set)
```

We then make sure to tell the assembler to make the space for our code exactly 4k and stop operations. 

```asm6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
```
So, it does...stuff? I guess? If we look at the 8bit workshop, we can see it is basically filling a single scanline with nothing. 

All together, it looks like this and you can copy and paste this into 8bitworkshop and click around. 
```asm6502
    processor 6502
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"
    

    seg code
    org $F000       ; Define the code origin at $F000

Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0          ; A = 0
    ldx #$FF        ; X = #$FF
MemLoop:            ; 
    sta $0,X        ; Store the value of A inside memory address $0 + X
    dex             ; X--
    bne MemLoop     ; Loop until X is equal to zero (z-flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
```
But all this does is create a silly black screen. Or does it?

If we look at the memory browser, it does seem like something is happening but ....what? It's just a black screen?

So is it working right? Let's take a look at it in process. Instead of `#$FF` let's set X to `08`.

It seems like it is kind of, but it could be better because essentially we're not counting down from FF but from FE. What does that mean? 
## <a id="anerr"></a>An Error?
```asm6502
    processor 6502
    include "vcs.h"
    include "macro.h"
    include "xmacro.h"
    
    seg code
    org $F000       ; Define the code origin at $F000

Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0          ; A = 0
    ldx #$FF        ; X = #$FF
    sta $FF         ; Store $FF is zeroed before the loop starts.
    
MemLoop:            ; Why is this wrong? 
    dex             ; X--
    sta $0,X        ; Store the value of A inside memory address $0 + current value of X
    bne MemLoop     ; Loop until X is equal to zero (z-flag is set)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
```

So essentially, we didn't actually load the EXACT memory position that we wanted and this resulted in being slightly off by 1. As a result, we have a potentially life threatening bug that is creeping into our code at the start. What this code does is highlight some of the finickyness of Assembly but also tells us that folks have been fighting over if programming languages should begin with 0 or 1 for ages. 

But it's still a black screen!

What would it look like to use this a bit more? And what exactly is that macro.h? Well, it may surprise you but our START code could actually be a bit cleaner. We can use some super in-depth knowledge of how Assembly works in order to lower the total space required by the commands and we can do this during compiling. This is what MACRO.H does, it helps us squeeze more space out of the ROMs. So, let's take a look and get some more bones together.
# <a id="morebones"></a>More Bones
So, we have a script that's kinda boring, hurray? I guess? No, it's boring. Let's DO something more. This is a script from your textbook from Hugg (page 35 is where this starts). 

Let's do some work with it. In particular, I want to point out something from the intro. 
```asm6502
; Assembler should use basic 6502 instructions
	processor 6502
	
; Include files for Atari 2600 constants and handy macro routines
	include "vcs.h"
	include "macro.h"
	
; Here we're going to introduce the 6502 (the CPU) and the TIA (the chip that generates the video signal). There's no frame buffer. In fact, we actually have to build it. To do this, we have have to program the TIA before (or during) each scanline. (This is the "Racing the Beam" we keep talking about." To start, we're just going to initialize the system and put some color on the TV.

; 4K Atari 2600 ROMs usually start at address $F000
	org  $f000

; Let's define a variable to hold the starting color
; at memory address $81
BGColor	equ $81

; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START
```
So, we've basically done with `clean_start` what we've written for the basic code block from the first example; however, `CLEAN_START` does a bit more than what we've previously done. Last time, we did: 
```asm6502
Start:
    sei             ; Disable interrupts
    cld             ; Disable the BCD decimal math mode
    ldx #$FF        ; Loads the X register with #$FF
    txs             ; Transfer the X register to the (S)tack pointer
```
This is where `macro.h` comes in! If we head over to the `macro.h` webpage at: https://github.com/munsie/dasm/blob/master/machines/atari2600/macro.h we can see that `CLEAN_START` is meant to `set machine to known state on startup`. But what does that mean?

`CLEAN_START` looks like this:
```asm6502
; CLEAN_START
; Original author: Andrew Davie
; Standardised start-up code, clears stack, all TIA registers and RAM to 0
; Sets stack pointer to $FF, and all registers to 0
; Sets decimal mode off, sets interrupt flag (kind of un-necessary)
; Use as very first section of code on boot (ie: at reset)
; Code written to minimise total ROM usage - uses weird 6502 knowledge :)

            MAC CLEAN_START
                sei
                cld
            
                ldx #0
                txa
                tay
.CLEAR_STACK    dex
                txs
                pha
                bne .CLEAR_STACK     ; SP=$FF, X = A = Y = 0

            ENDM
```
So, `CLEAN_START` essentially does what we need to to clear everything out and reset the machine to a new state. Note also that it clears everything, gets us ready to start counting, and essentially clears up that example from earlier. We won't dig too much into it and you can begin either way. 

We're going to set up 2 ways of thinking about this. First, we'll simply subtract from BG Colors and make a rainbow. Then we're going to load `COLUBK` into the accumulator and have some fun.
```asm6502
	PROCESSOR 6502
        INCLUDE "vcs.h"
        INCLUDE "macro.h"
        INCLUDE "xmacro.h"
        
        seg code
        org $F000
        
Start	CLEAN_START

;```````````````````````````````
;	Start new Frame
;```````````````````````````````

NextFrame: 
	lda %00000010	; We need to load something in our accumulator and this bit is what activates it.
        sta VBLANK	; Turn on VBLANK
        sta VSYNC	; Turn on VSYNC
        
;```````````````````````````````
;	We need 3 lines of VSYNC to start our frame.
;```````````````````````````````

	sta WSYNC
        sta WSYNC
        sta WSYNC
        
        lda #0		; Deactivate the accumulator and in doing that, we now have the ability to turn off VSYNC
        sta VSYNC	; Turn off VSYNC
        
        ldx #$0E
        stx COLUBK 
        
;```````````````````````````````
;	We need to now output 37 Scanlines to get to the drawable part of the screen.
;```````````````````````````````

	ldx #37		; Literally the number 37

LoopVBlank:
	sta WSYNC	; hit Wsync and wait for the next scanline.
        dex
        bne LoopVBlank

	lda #0
        sta VBLANK

;```````````````````````````````
;	Will now start doing stuff with the visible screen. We have 192 scanlines. This is sometimes called our kernal.
;```````````````````````````````
        ldx #192	; counter for 192 scanlines

LoopVis: 		; We will keep drawing 192 colors so we need to loop and decrement
	stx COLUBK	; Set the background color
        sta WSYNC	; wait for the next scanline
        dex 		; x--
        bne LoopVis	;  Loop while X!=0
        

;```````````````````````````````
;	Output 30 more lines for our Overscan period.
;```````````````````````````````

	lda #2		; hit and turn on VBLANK again
        sta VBLANK
        
        ldx #30		; Counter for 30 scanlines
LoOver: 
	sta WSYNC	; Wait for next Scanline
        dex
        bne LoOver	; Loop while X!=0

	jmp NextFrame
        
;```````````````````````````````
;	Complete ROM size to 4k
;`````````

	org $FFFC
        .word Start
        .word Start

        
```
Now let's see about loading it into the accumulator.
```asm6502
; Assembler should use basic 6502 instructions
	processor 6502
	
; Include files for Atari 2600 constants and handy macro routines
	include "vcs.h"
	include "macro.h"
	
; Here we're going to introduce the 6502 (the CPU) and the TIA (the chip that generates the video signal).
; There's no frame buffer, so you have to program the TIA before (or during) each scanline. 
; What we'll do here is create a rainbow pattern by having the machine draw a color for about 3 lines.

; 4K Atari 2600 ROMs usually start at address $F000
	org  $f000

; Let's define a variable to hold the starting color
; at memory address $81
BGColor	equ $81 ; this is our first variable!

; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START ; check out macro.h for this. 

NextFrame ; here we're defining a loop that is essentially creating a frame. 
; Enable VBLANK (disable output)
	lda #2
        sta VBLANK ; VBLANK basically says that we need to reset the scanline
        
; At the beginning of the frame we set the VSYNC bit...
	lda #2
	sta VSYNC
        
; And hold it on for 3 scanlines...
	sta WSYNC	;wait for the next scanline
	sta WSYNC	;wait for the next scanline
	sta WSYNC	;wait for the next scanline
        
; Now we turn VSYNC off.
	lda #0
	sta VSYNC

; Now we need 37 lines of VBLANK...
	ldx #37
LVBlank	sta WSYNC	; accessing WSYNC stops the CPU until next scanline
	dex		; decrement X
	bne LVBlank	; loop until X == 0

; Re-enable output (disable VBLANK)
	lda #0
	sta VBLANK
        
; 192 scanlines are visible
; We'll draw some rainbows
	ldx #192
	lda BGColor	; load the BGColor into the accumulator.
ScanLoop
	adc #1		; add 1 to BGColor in A
	sta COLUBK	; set the background color as the current value of A
	sta WSYNC	; wait for the next scanline
	dex		; move down 1 scanline
	bne ScanLoop	; Continue looping until x == 0 or while x != 0

; Enable VBLANK again
	lda #2		; Remember, we're turning on the accumulator again
        sta VBLANK	; And turning on VBlank

; 30 lines of overscan to complete the frame
	ldx #30		; Then we have to load 30 into x to accompodate overscan.
LVOver	sta WSYNC
	dex
	bne LVOver
	
; The next frame will start with current color value - 1
; to get a downwards scrolling effect
	dec BGColor ; dec basically means, "Decrease by 1" and so and with the next frame, we begin again.

; Go back and do another frame. If we don't do this, we will just keep overlaying the same frame again and again.
	jmp NextFrame        


;  And we finish up by making sure our file is exactly 4k.
	org $fffc
	.word Start
	.word Start
```
# <a id="evenmore"></a>Even MORE Bones
I saw this here: https://www.atariage.com/2600/programming/2600_101/03first.html and thought it was super interesting in how he walked through it.

```asm6502
; thin red line by Kirk Israel
	processor 6502
	include vcs.h

;	now tell DASM where in the memory to place all the code that follows...$F000 is the preferred spot where it goes to make an atari program (so "org" isn't a 6502 or atari specific command...it's an "assembler directive" that's giving directions to the program that's going to turn our code into binary bits)

	org $F000

;Anything that's not indented, DASM treats as a "label". We would call these variable names now though that is inaccurate. By using label names, we can give commands lke "JMP labelname" rather than "JMP $F012" or what not.

Start CLEAN_START

ClearMem 
	STA 0,X		;Now, this doesn't mean what you think...
	DEX		;decrement X (decrease X by one)
	BNE ClearMem	;if the last command resulted in something 
			;that's "N"ot "Equal" to Zero, branch back
			;to "ClearMem"
;
;	Ok...a word of explanation about "STA 0,X"
;	You might assume that that said "store zero into the memory
;	location pointed to by X..." but rather, it's saying
;	"store whatever's in the accumulator at the location pointed
;	to by (X plus zero)"
;
;	So why does the command do that?  Why isn't there just a 
;	"STA X" command? (Go ahead and make the change if you want,
;	DASM will give you an unhelpful error message when you go
;	to assemble.) Here's one explanation, and it has to do with
;	some handwaving I've been doing...memory goes from $0000-$FFFF
;	but those first two hex digits represent the "page" you're dealing
;	with.  $0000-$00FF is the "zero page", $0100-$01FF is the first
;	page, etc.  A lot of the 6502 commands take up less memory
;	when you use the special mode that deals with the zero page,
;	where a lot of the action in atari land takes place.
;	...sooooo, STA $#nnnn would tell it to grab the next two bytes
;	for a full 4 byte address, but this mode only grabs the one 
;	value from the zero page
;
;	Now we can finally get into some more interesting
;	stuff.  First lets make the background black
;	(Technically we don't have to do this, since $00=black,
;	and we've already set all that memory to zero.
;	But one easy experiment might be to try different two
;	digit hex values here, and see some different colors
;
       LDA #$00		;load value into A ("it's a black thing")
       STA COLUBK	;put the value of A into the background color register

;	Do the same basic thing for missile zero...
;	(except missiles are the same color as their associated
;	player, so we're setting the player's color instead

       LDA #33
       STA COLUP0

;	Now we start our main loop
;	like most Atari programs, we'll have distinct
;	times of Vertical Sync, Vertical Blank,
;	Horizontal blank/screen draw, and then Overscan
;
;	So every time we return control to Mainloop.
;	we're doing another television frame of our humble demo
;	And inside mainloop, we'll keep looping through the 
;	section labeled Scanloop...once for each scanline
;

MainLoop
;*********************** VERTICAL SYNC HANDLER
;
;	If you read your Stella Programmer's Guide,
;	you'll learn that bit "D1" of VSYNC needs to be
;	set to 1 to turn on the VSYNC, and then later 
;	you set the same bit to zero to turn it off.
;	bits are numbered from right to left, starting
;	with zero...that means VSYNC needs to be set with something
;	like 0010 , or any other pattern where "D1" (i.e. second
;	bit from the right) is set to 1.  0010 in binary 
;	is two in decimal, so let's just do that:
;
	LDA  #2
	STA  VSYNC	; Sync it up you damn dirty television!
			; and that vsync on needs to be held for three scanlines...
			; count with me here, 
	STA  WSYNC	; one... (our program waited for the first scanline to finish...)
	STA  WSYNC 	; two... (btw, it doesn't matter what we put in WSYNC, it could be anything)
	STA  WSYNC	; three...

;	We blew off that time of those three scanlines, though we could have 
;	done some logic there...but most programs will definately want the vertical blank time that follows...you might want to do a lot of things in those 37 lines...so many things that you might become like Dirty Harry: "Did I use up 36 scanlines, or 37? Well, to tell you the truth, in all this excitement, I've kinda lost track myself."  So here's what we do...The Atari has some Timers built in.  You set these with a value, and it counts down...then when you're done thinking, you kill time until that timer has clicked to zero, and then you move on.
;	So how much time will those 37 scan lines take?
;	Each scanline takes 76 cycles (which are the same thing our clock is geared to) 37*76 = 2812 (no matter what Nick Bensema tries to tell us...his "How to Draw A Playfield" is good in a lot of other ways though..to quote the comments from that:

;		 We must also subtract the five cycles it will take to set the timer, and the three cycles it will take to STA WSYNC to the next line.  Plus the checking loop is only accurate to six cycles, making a total of fourteen cycles we have to waste.  

;	So, we need to burn 2812-14=2798 cycles.  Now, there are a couple of different timers we can use, and Nick says the one we usually use to make it work out right is TIM64T, which ticks down one every 64 cycles.  2798 / 64 = 43.something, but we have to play conservative and round down.

	LDA  #43	; load 43 (decimal) in the accumulator
	STA  TIM64T	; and store that in the timer

	LDA #0		; Zero out the VSYNC
	STA  VSYNC 	; 'cause that time is over

;	So here we can do a ton of game logic, and we don't have to worry too much about how many instructions we're doing, as long as it's less than 37 scanlines worth (if it's not less, your program is screwed with a capital screw)

WaitForVblankEnd
	LDA INTIM	;load timer...
	BNE WaitForVblankEnd	;killing time if the timer's not yet zero

	LDY #191 	;Y is going to hold how many lines we have to do
			;...we're going to count scanlines here. theoretically
			; since this example is ass simple, we could just repeat
			; the timer trick, but often its important to know 
			; just what scan line we're at.
	STA WSYNC	
	STA VBLANK  	
	
			;End the VBLANK period with the zero			
			;(since we already have a zero in "A"...or else
			;the BNE wouldn't have let us get here! Atari 
			;is full of double use crap like that, and you
			;should comment when you do those tricks)
			;We do a WSYNC just before that so we don't turn on
			;the image in the middle of a line...an error that
			;would be visible if the background color wasn't black.

	;HMM0 is the "horizontal movement register" for Missile 0 we're gonna put in a -1 in the left 4 bits ("left nibble", use the geeky term for it)...it's important to note that it's the left 4 bits that metters, what's in the right just doesn't matter, hence the number is #$X0, where X is a digit from 0-F.  In two's complement notation, -1 is F if we're only dealing with a single byte.

	LDA #$F0	; -1 in the left nibble, who cares in the right
	STA HMM0	; stick that in the missile mover

	STA WSYNC	;wait for one more line, so we know things line up
	STA HMOVE 	;and activate that movement
	
			;note...for godawful reasons, you must do HMOVE
			;right after a damn WSYNC. I might be wasting a scanline
			;with this, come to think of it

;*********************** Scan line Loop
ScanLoop 

	STA WSYNC 	;Wait for the previous line to finish
	LDA #2		;now sticking a 2 in ENAM0 (i.e. bit D1) will enable Missile 0
	STA ENAM0	;we could've done this just once for the whole program
			;since we never turn it off, but i decided to do it again and again, since usually we'd have to put smarter logic in  each horizontal blank
			;
			;so at some point in here, after 68 clock cycles to be exact, TIA will start drawing the line...all the missiles and players and what not better be ready...unless we *really* know what we're doing.

	DEY		;subtract one off the line counter thingy
	BNE ScanLoop	;and repeat if we're not finished with all the scanlines.

	LDA #2		;#2 for the VBLANK...
	STA WSYNC  	;Finish this final scanline.
	STA VBLANK 	; Make TIA output invisible for the overscan, 
			; (and keep it that way for the vsync and vblank)
;***************************** OVERSCAN CALCULATIONS
;
;I'm just gonna count off the 30 lines of the overscan. You could do more program code if you wanted to.

	LDX #30		;store 30
OverScanWait
	 STA WSYNC
	 DEX
	 BNE OverScanWait

	JMP  MainLoop      ;Continue this loop forver! Back to the code for the vsync etc


; OK, last little bit of crap to take care of.
; there are two special memory locations, $FFFC and $FFFE
; When the atari starts up, a "reset" is done (which has nothing to do with
; the reset switch on the console!) When this happens, the 6502 looks at
; memory location $FFFC (and by extension its neighbor $FFFD, since it's 
; seaching for both bytes of a full memory address)  and then goes to the 
; location pointed to by $FFFC/$FFFD...so our first .word Start tells DASM
; to put the binary data that we labeled "Start" at the location we established
; with org.  And then we do it again for $FFFE/$FFFF, which is for a special
; event called a BRK which you don't have to worry about now.
 
	org $FFFC
	.word Start
	.word Start
```

I like this bit because the author comments everything to a ridiculous degree. From this point, we have a basic idea of just how *weird* it is to write code for this thing. We are literally fighting with an electron beam (even if that beam is now software driven rather than hardware). Timing everything is a LOT easier than it was with the help of Stella and the like. 

And there we go, our first day coding!
# Terms
- Registers - X, and Y. A is commonly used for arithmetic, whereas X and Y is used for counting.
- Directives
- Labels
- OpCodes
	- Many of these will be covered here: 
		- http://www.6502.org/tutorials/6502opcodes.html#WRAP
	- In this lesson: 
		- SEG - Pseudo op-code that designates the start of ROM
		- ORG - Using this, we set the origin of code in memory.
		- SEI - Interrupt code is disabled. We don't have the ability to interrupt because it's not a pin on the 6507 but we do it anyway.
		- CLD - Using this, we shut off decimal mode.
		- LDX - We use this to store things in the X-register.
		- TXS
		- LDA
		- STA
		- DEX
		- BNE
		- .word
- Operands
- Comments
- Interrupt Vectors
- Accumulator Commands: 
	- Immediate Mode
	- Absolute Mode (Zero Page)
	- Literal Hexadecimal


