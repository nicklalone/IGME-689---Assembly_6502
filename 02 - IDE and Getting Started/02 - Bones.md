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
So, there are a bunch of things we need to do when we are starting a project. Since the console itself has no firmware, we have to take care of that stuff as we begin. 

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

And I should probably mention here that you're going to need some way to shift between binary, hexadecimal, literal values. We're going to use a converter to keep track unless you want me to drill this knowledge into you.




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

# Terms
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