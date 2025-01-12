These files are mostly for me as I go around and look for good resources. While a lot of this stuff will be tangential, it's mostly for folks who want a lot more in depth information. 

For this week, I was mostly concerned with learn how and why the machine works the way it works. I also wanted to begin to set up a variety of arguments related to having to adjust how the code you are writing is interacting with the hardware since you're essentially doing this directly. 

Note about commands: 
* JMP is like Goto command in basic
* JSR is like to Gosub command in basic
* RTS is like Return command in basic.

I also wanted to find a few small things that would be mentioned now and come up later. For example, the Registers, the RIOT chip, and tiny bits.

First, let's note some important files for where you'll type up your code. Here's some syntax highlighting for a variety of text.

- Syntax highlight package for Visual Studio Code: [https://marketplace.visualstudio.com/items?itemName=chunkypixel.atari-dev-studio](https://marketplace.visualstudio.com/items?itemName=chunkypixel.atari-dev-studio)
- Syntax highlight package for Notepad++: [https://github.com/tragicmuffin/6502-npp-syntax](https://github.com/tragicmuffin/6502-npp-syntax)
- Syntax highlight package for Atom: [https://atom.io/packages/language-65asm](https://atom.io/packages/language-65asm)
- Syntax highlight file for Vim: [https://www.vim.org/scripts/script.php?script_id=1314](https://www.vim.org/scripts/script.php?script_id=1314)
- Syntax highlight package for Emacs: [http://www.tomseddon.plus.com/beeb/6502-mode.html](http://www.tomseddon.plus.com/beeb/6502-mode.html)

[[Registers]] and [[Process Flags]]

https://www.masswerk.at/rc2018/04/ - This blog chronicles someone's working on a game for a contest.
## The Registers

The 6502 has only a small number of registers compared to other processor of the same era. This makes it especially challenging to program as algorithms must make efficient use of both registers and memory.
### Program Counter
The program counter is a 16 bit register which points to the next instruction to be executed. The value of program counter is modified automatically as instructions are executed.

The value of the program counter can be modified by executing a jump, a relative branch or a subroutine call to another memory address or by returning from a subroutine or interrupt.
### Stack Pointer
The processor supports a 256 byte stack located between $0100 and $01FF. The stack pointer is an 8 bit register and holds the low 8 bits of the next free location on the stack. The location of the stack is fixed and cannot be moved.

Pushing bytes to the stack causes the stack pointer to be decremented. Conversely pulling bytes causes it to be incremented.

The CPU does not detect if the stack is overflowed by excessive pushing or pulling operations and will most likely result in the program crashing.

### Accumulator
The 8 bit accumulator is used all arithmetic and logical operations (with the exception of increments and decrements). The contents of the accumulator can be stored and retrieved either from memory or the stack.

Most complex operations will need to use the accumulator for arithmetic and efficient optimisation of its use is a key feature of time critical routines.

### Index Register X
The 8 bit index register is most commonly used to hold counters or offsets for accessing memory. The value of the X register can be loaded and saved in memory, compared with values held in memory or incremented and decremented.

The X register has one special function. It can be used to get a copy of the stack pointer or change its value.

### Index Register Y
The Y register is similar to the X register in that it is available for holding counter or offsets memory access and supports the same set of memory load, save and compare operations as wells as increments and decrements. It has no special functions.

### Processor Status
As instructions are executed a set of processor flags are set or clear to record the results of the operation. This flags and some additional control flags are held in a special status register. Each flag has a single bit within the register.

Instructions exist to test the values of the various bits, to set or clear some of them and to push or pull the entire set to or from the stack.
- Carry Flag
> The carry flag is set if the last operation caused an overflow from bit 7 of the result or an underflow from bit 0. This condition is set during arithmetic, comparison and during logical shifts. It can be explicitly set using the 'Set Carry Flag' ([SEC](http://www.6502.org/users/obelisk/6502/reference.html#SEC)) instruction and cleared with 'Clear Carry Flag' ([CLC](http://www.6502.org/users/obelisk/6502/reference.html#CLC)).

- Zero Flag
> The zero flag is set if the result of the last operation as was zero.

- Interrupt Disable
> The interrupt disable flag is set if the program has executed a 'Set Interrupt Disable' ([SEI](http://www.6502.org/users/obelisk/6502/reference.html#SEI)) instruction. While this flag is set the processor will not respond to interrupts from devices until it is cleared by a 'Clear Interrupt Disable' ([CLI](http://www.6502.org/users/obelisk/6502/reference.html#CLI)) instruction.

- Decimal Mode
> While the decimal mode flag is set the processor will obey the rules of Binary Coded Decimal (BCD) arithmetic during addition and subtraction. The flag can be explicitly set using 'Set Decimal Flag' ([SED](http://www.6502.org/users/obelisk/6502/reference.html#SED)) and cleared with 'Clear Decimal Flag' ([CLD](http://www.6502.org/users/obelisk/6502/reference.html#CLD)).

- Break Command
> The break command bit is set when a [BRK](http://www.6502.org/users/obelisk/6502/reference.html#BRK) instruction has been executed and an interrupt has been generated to process it.

- Overflow Flag
> The overflow flag is set during arithmetic operations if the result has yielded an invalid 2's complement result (e.g. adding to positive numbers and ending up with a negative result: 64 + 64 => -128). It is determined by looking at the carry between bits 6 and 7 and between bit 7 and the carry flag.

- Negative Flag
> The negative flag is set if the result of the last operation had bit 7 set to a one.

# Side Note for Lecture
We are starting to write our first lines of code in _6502 assembly language_, therefore I think it is important that we speak a little bit about some important code terminology and code layout.

**Directives**
_Directives_ are commands that we can send to the _assembler_ to do things like locating code in memory or inserting raw bytes into the ROM. Directives should be always indented to the right, and some programmers also like to add a "**.**" at the beginning of these directives. Some programmers use _tabs_, other _spaces_; I personally like to use 4 spaces as you just saw in the previous lectures. One example of a directive is the .org ("origin"), that we used to tell the assembler to put the code starting at memory location $F000, which is the start of the VCS ROM cartridge area:     

```
    .org $F000
```

**Labels**
_Labels_ are aligned to the far left of the code, and usually have a "**:**" at the end. The label is just something you use to organize your code and make it easier to read. The assembler will translate the label _into an address_. For example, the example below is a label that is basically just an alias to a memory address in ROM:

```
MemLoop:
```  

**OpCodes**
_Opcodes_ are the instructions that the processor will run, and they are indented like the directives. In this example, _JMP_ is the opcode that tells the processor to jump to the _MemLoop_ label:

```
    jmp MemLoop
```

**Operands**
_Operands_ are additional information for the opcode. 6502 opcodes can have between one and three operands. In this example the _#$80_ is the operand:

```
    lda #$80
```

  
  **Comments**
_Comments_ can be added to your code to help you understand what the code is doing. We do not need a comment on every line, but since this is a course for beginners, I will go out of my way to try adding comments to every line (at least in the beginning lectures). Comments start with a "**;**" and are completely ignored by the assembler. They can be put anywhere horizontally and will persist until the end of the line.

```
    lda #$80 ; load the value $80 into the accumulator
```

I will probably use these names a lot in the following lectures, so I thought it was important to stop and make sure we all know what I mean when I start saying things like "opcodes", "labels", or "directives."

And just before we resume our course, let me also clarify one common point of confusion for many students, which are the _interrupt vectors_ at the end of our ROM.

**Interrupt Vectors**
The addresses we added in ROM position $FFFC and $FFFE are called “_Interrupt Vectors_”, and they instruct the 6502 CPU where to jump to when certain events happen. For example, the 6502 processor was designed to always look at position $FFFC when it is **reset**.
![](/images/6507-reset.jpg)
When we power-up or reset the Atari 2600, it sets the **RESET pin** on the 6507 processor. The 6507 processor is designed to always initialize and load the **PC** register (program counter) with the address that is in inside memory positions $FFFC and $FFFD (two bytes).

That makes sense, right? Since the **PC** register is what dictates what is the next 16-bit ROM address to be executed by the CPU, loading the PC register with the value that is in $FFFC/$FFFD is all that is needed for the 6502 processor to load its _reset address_.

Keep in mind that this is not something we can change! This is how the 6502 and 6507 processors were designed and manufactured. They will always look at the reset interrupt vector at memory positions $FFFC and $FFFD.

And that was the main reason we manually went to ROM address $FFFC and loaded two bytes there. Those are the two bytes that tell the processor what is the address that we should execute when the Atari 2600 starts (or resets). In our case, we are using the label **Start**, which is just an alias to ROM address $F000 at the start of our ROM. And that is all it takes for the Atari 2600 to know where to begin its execution. The Atari 2600 will power up and poke the reset pin of the 6507 processor; the CPU will read from memory position $FFFC and $FFFD and set the Program Counter register to **Start** (same as $F000). And the 6502 is now ready to begin executing our code!

And just as a final note, the 6507 CPU of the Atari VCS has **no** IRQ pin and cannot perform interrupt requests. Therefore, the IRQ interrupt vector at $FFFE will never be used by the VCS.

![[literal.png]]

Just to put things into context and give you an example, if we are _reading_ the instructions from the cartridge ROM, the R/W pin of the processor will be set to "reading" from the address. On the other hand, if we are performing an STA (store accumulator) to a RAM memory address, then the R/W pin will be set to "writing" to that address.

https://www.rapidtables.com/convert/number/decimal-to-hex.html?x=82

https://www.atarimax.com/freenet/freenet_material/12.AtariLibrary/2.MiscellaneousTextFiles/showarticle.php?129

https://problemkaputt.de/2k6specs.htm

We are starting to write our first lines of code in _6502 assembly language_, therefore I think it is important that we speak a little bit about some important code terminology and code layout.