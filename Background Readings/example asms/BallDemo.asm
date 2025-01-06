
; ********************************************************************
;
;  Ball Demo
;
; ********************************************************************

                PROCESSOR 6502

; --------------------------------------------------------------------        
;       Includes
; --------------------------------------------------------------------        
                
                INCLUDE vcs.h
                INCLUDE macro.h

;---------------------------------------------------------------------
;       Constants
;---------------------------------------------------------------------

ROMStart = $F000
ROMSize  = $0800

BALL_HEIGHT = 8 ; height of ball object
        
;---------------------------------------------------------------------
;       Variables
;---------------------------------------------------------------------

FrameCtr = $80  ; frame counter

BallHPos = $81  ; ball horizontal position
BallVPos = $82  ; ball vertical position
BallHDir = $83  ; ball horizontal direction (-1, +1)
BallVDir = $84  ; ball vertical direction (-1, +1)


; ********************************************************************
;
;       Code Section
;
; ********************************************************************        

                ORG ROMStart

BallDemo:       CLEAN_START

                ; setup initial ball direction
        
                lda     #1
                sta     BallHDir
                sta     BallVDir

                ; start with ball in the middle of the scrren
        
                lda     #80
                sta     BallHPos
                lda     #92
                sta     BallVPos
        
; --------------------------------------------------------------------        
;       VSync
; --------------------------------------------------------------------

VSync:          SUBROUTINE

                ; VSYNC on

                lda     #%00000010
                sta     WSYNC
                sta     VSYNC
                sta     WSYNC
                sta     WSYNC

                ; set timer to skip VBLANK

                lda     #44
                sta     TIM64T

                ; VSYNC off

                sta     WSYNC
                sta     VSYNC
 
; --------------------------------------------------------------------        
;       VBlank
; --------------------------------------------------------------------

VBlank:         SUBROUTINE

                ; move ball vertically
        
.vmove          clc
                lda     BallVPos
                adc     BallVDir
                sta     BallVPos

                ; bounce ball on bottom

.bottom         cmp     #0
                bne     .top
                lda     #1
                sta     BallVDir
                jmp     .hmove

                ; bounce ball on top
        
.top            cmp     #186
                bne     .hmove
                lda     #-1
                sta     BallVDir

                ; move ball horizontally
        
.hmove          clc
                lda     BallHPos
                adc     BallHDir
                sta     BallHPos

                ; bounce ball on left side
        
.left           cmp     #1
                bne     .right
                lda     #1
                sta     BallHDir
                jmp     .pos

                ; bounce ball on right side

.right          cmp     #157
                bne     .pos
                lda     #-1
                sta     BallHDir

                ; position ball horizontally

.pos            ldx     #4
                lda     BallHPos
                jsr     HPosNoHMOVE
                sta     WSYNC
                sta     HMOVE

VBlankEnd:      lda     INTIM
                bne     VBlankEnd

; --------------------------------------------------------------------        
;       Kernel
; --------------------------------------------------------------------

Kernel:         SUBROUTINE

                ; VBLANK off
        
                sta     WSYNC
                sta     VBLANK

                lda     #$88            ; background color
                sta     COLUBK
                lda     #$9E            ; ball and playfield color
                sta     COLUPF
                lda     #%00100000      ; ball size 4 pixels
                sta     CTRLPF

                ; draw ball

                ldy     #193
.loop           sta     WSYNC
                ldx     #%00000010      ; set ball enable bit
                tya                     ; move line number to A
                sec                     ; set carry before subtracting
                sbc     BallVPos        ; subtract ball start line
                cmp     #BALL_HEIGHT    ; test if line is in [0, BALL_HEIGHT-1]
                bcc     .write          ; yes -> enable ball
                ldx     #%00000000      ; no -> clear ball enable bit
.write          stx     ENABL
        
                dey
                bne     .loop

; --------------------------------------------------------------------        
;       Overscan
; --------------------------------------------------------------------

Overscan:       SUBROUTINE

                ; VBLANK on

                lda     #%00000010
                sta     WSYNC
                sta     VBLANK

                ; set timer to skip OVERSCAN

                lda     #35
                sta     TIM64T

                ; clear ball

                lda     #0
                sta     ENABL

                ; advance counters

                inc     FrameCtr

OverscanEnd:    lda     INTIM
                bne     OverscanEnd
                jmp     VSync


; ********************************************************************
;
;       Subroutines
;
; ********************************************************************        

HPosNoHMOVE:    SUBROUTINE
                sec
                sta     WSYNC
.loop           sbc     #15
                bcs     .loop
                eor     #7
                asl
                asl
                asl
                asl
                sta.wx  HMP0,x
                sta     RESP0,x
                rts

; ********************************************************************

                ORG ROMStart + ROMSize - 3*2
        
NMI:            WORD    ROMStart
Reset:          WORD    ROMStart
IRQ:            WORD    ROMStart

