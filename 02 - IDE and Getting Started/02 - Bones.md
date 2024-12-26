---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [Bones](#bones)
4. [Terms](#terms)

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

Next, we have to really get started. We've disabled interrupts (because the 6507 doesn't have that pin but we still have to account for it in 6502.) We're also disabling Binary Coded Decimals so we can write numbers without having to worry about them being used as numbbers: http://www.6502.org/tutorials/decimal_mode.html you can read more about it here.

The easiest description is probably from that page: 

	A byte has 256 possible values, ranging, in hex, from $00 to $FF. These values may represent numbers, characters, or other data. The most common way of representing numbers is as a binary number (or more specifically, an unsigned binary integer), where $00 to $FF represents 0 to 255. In BCD, a byte represents a number from 0 to 99, where $00 to $09 represents 0 to 9, $10 to $19 represents 10 to 19, and so on, all the way up to $90 to $99, which represents 90 to 99. In other words, the upper digit (0 to 9) of the BCD number is stored in the upper 4 bits of the byte, and the lower digit is stored in the lower 4 bits. These 100 values are called valid BCD numbers. The other 156 possible values of a byte (i.e. where either or both hex digits are A to F) are called invalid BCD numbers. By contrast, all 256 possible values of a byte are valid binary numbers.

So we've now gotten all our ducks in a row. Let's start thinking about some things. We need to start pushing information through the hardware. We will do something simple to begin like call into being a couple of  : 

```asm6502

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region ($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #0          ; A = 0
    ldx #$FF        ; X = #$FF
MemLoop:            ; Why is this wrong? 
    sta $0,X        ; Store the value of A inside memory address $0 + X
    dex             ; X--
    bne MemLoop     ; Loop until X is equal to zero (z-flag is set)
```



```asm6502
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interrupt vector at $FFFE (unused in the VCS)
```

All together, it looks like this: 
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
MemLoop:            ; Why is this wrong? 
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

But all this does is create a silly black screen. What would it look like to use this a bit more? And what exactly is that macro.h? Well, it may surprise you but our START code could actually be a bit cleaner. We can use some super in-depth knowledge of how Assembly works in order to lower the total space required by the commands and we can do this during compiling. This is what MACRO.H does, it helps us squeeze more space out of the ROMs. So, let's take a look. 

```asm6502

; Assembler should use basic 6502 instructions
	processor 6502
	
; Include files for Atari 2600 constants and handy macro routines
	include "vcs.h"
	include "macro.h"
	
; Here we're going to introduce the 6502 (the CPU) and
; the TIA (the chip that generates the video signal).
; There's no frame buffer, so you have to program the TIA
; before (or during) each scanline.
; We're just going to initialize the system and put some
; color on the TV.

; 4K Atari 2600 ROMs usually start at address $F000
	org  $f000

; Let's define a variable to hold the starting color
; at memory address $81
BGColor	equ $81

; The CLEAN_START macro zeroes RAM and registers
Start	CLEAN_START

NextFrame
; Enable VBLANK (disable output)
	lda #2
        sta VBLANK
; At the beginning of the frame we set the VSYNC bit...
	lda #2
	sta VSYNC
; And hold it on for 3 scanlines...
	sta WSYNC
	sta WSYNC
	sta WSYNC
        
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
	lda BGColor	; load the background color out of RAM
ScanLoop
	adc #1		; add 1 to the current background color in A
	sta COLUBK	; set the background color
	sta WSYNC	; WSYNC doesn't care what value is stored
	dex
	bne ScanLoop

; Enable VBLANK again
	lda #2
        sta VBLANK
; 30 lines of overscan to complete the frame
	ldx #30
LVOver	sta WSYNC
	dex
	bne LVOver
	
; The next frame will start with current color value - 1
; to get a downwards scrolling effect
	dec BGColor

; Go back and do another frame
	jmp NextFrame
	
	org $fffc
	.word Start
	.word Start
```

# Terms
- Registers
- Directives
- Labels
- OpCodes
- Operands
- Comments
- Interrupt Vectors
- Accumulator Commands: 
	- Immediate Mode
	- Absolute Mode (Zero Page)
	- Literal Hexadecimal

Let's talk about HEX


![[Pasted image 20241114160946.png]]