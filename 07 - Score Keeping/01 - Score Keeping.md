---------------- Table of Contents ---------------- 

1. [Welcome](#welcome)
2. [Logistics](#logistics)
3. [TLDR](#tldr)
4. [Day 1](#day1)
5. [Day 2](#day2)

---------------- Table of Contents ---------------- 

```asm
ORG $80             
 
    ; Holds 2 digit score, stored as BCD (Binary Coded Decimal)
Score:          ds 1    ; stored in $80
 
    ; Holds 2 digit timer, stored as BCD
Timer:          ds 1    ; stored in $81
 
    ; Offsets into digit graphic data
DigitOnes:      ds 2    ; stored in $82-$83, DigitOnes = Score, DigitOnes+1 = Timer
DigitTens:      ds 2    ; stored in $84-$85, DigitTens = Score, DigitTens+1 = Timer
 
    ; graphic data ready to put into PF1
ScoreGfx:       ds 1    ; stored in $86
TimerGfx:       ds 1    ; stored in $87
 
    ; scratch variable
Temp:           ds 1    ; stored in $88

VerticalBlank:    
        jsr SetObjectColors
        jsr PrepScoreForDisplay
        rts ; ReTurn from Subroutine
```