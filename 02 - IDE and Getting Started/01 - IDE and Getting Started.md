---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

# <a id = "day1"></a>Day 1

Getting Started
IDEs and Ways to Code
## Stella
Stella Debugger - https://stella-emu.github.io/docs/debugger.html
![](/images/StellaUI.png)
**Upper Right** = RAM + location of the scan line and what cycle it's on. This is important as all your registers are there (PC, SP, A, X, Y, PS) and what is currently in them. We'll talk more about them when we get into [[Process Flags]] and [[Registers]]. In the case of the PS line, this is [Processor Status](http://www.6502.org/users/obelisk/6502/registers.html). We'll get into those soon but know CAPS = Negative, lower case = Positive.
PC = Program Counter
SP = Stack Pointer or the thing that points to the memory positions. 
A = Accumulator
X/Y = Registers

**Upper Left** = Current position of the scanline.

**Lower Right** = Disassembly or what is being stored everywhere. Not that at the start, we disable interrupts (sei) and then define the code origin, followed by then disabling the HCD decimal math mode, load X with a register, then send it to the stack pointer. You can walk through this with the "STEP" on the upper right. 

**Lower left** = your log but also you can  look at the TIA chip as well as the RIOT and Audio portions of your machine.

Red also means something changed whereas remaining white means it did not.

The more important thing, or perhaps the thing that is often missing in literally all CS stuff. In the lower right, we see a solid line followed by 78, d8, a2 ff. This is the "Op Code" or actual machine language.

One thing to note about how this debugger works. Mostly, we'll work backward as we begin at 0 and work up to maximum. So, look at the RAM and how the lower right is FF whereas the upper left is 08. 

Original Guide is at: https://atarihq.com/danb/files/stella.pdf

## 8 Bit Workshop

### Github Integration
### Disassembly
### Memory Browser
### Memory Map
### Memory Probe
### CRT Probe
### Probe Log
### Scanline I/O
### Symbol Profiler
### Call Stack
### Debug Tree
### Asset Editor

# Terms

