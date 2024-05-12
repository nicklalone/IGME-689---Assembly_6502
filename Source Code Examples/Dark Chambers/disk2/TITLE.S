.INCLUDE "EQUATES.S"
****
*
* TITLE BANK
*
* DUNGEON 2600 PROGRAM
*
* WRITTEN BY ADAM CLAYTON
* DEVELOPED BY SCULPTURED SOFTWARE
* COPYRIGHT 1987 ATARI
* 
****
        .ORG    $F100
****
*
* ENTERING LEVEL GRAPHICS
*
****
BLK24:  
        DC.B    $FF,$7F,$7F,$7C
        DC.B    $78,$78,$78,$78,$78,$78,$78,$78
        DC.B    $78,$78,$78,$78,$78,$79,$7F,$7F
        DC.B    $78,$78,$78,$78,$78,$78,$78,$7C
        DC.B    $7F,$7F,$FF
BLK25:  
        DC.B    $EC,$ED,$ED,$6D
        DC.B    $2D,$2D,$0D,$0D,$0D,$0C,$0C,$0C
        DC.B    $0C,$0C,$84,$8D,$8D,$8D,$8D,$8D
        DC.B    $8D,$0D,$0D,$0F,$0F,$20,$20,$60
        DC.B    $E0,$E0,$E0
BLK26:  
        DC.B    $F3,$F3,$86,$E6
        DC.B    $F6,$B6,$B6,$B6,$F6,$E6,$00,$10
        DC.B    $10,$30,$30,$B3,$B7,$B6,$B7,$B7
        DC.B    $B6,$B6,$B6,$B7,$33,$78,$30,$30
        DC.B    $30,$30,$30
BLK27:  
        DC.B    $8F,$9F,$D8,$DE
        DC.B    $DF,$DB,$DB,$DB,$DF,$CE,$00,$00
        DC.B    $00,$00,$00,$D8,$D8,$18,$98,$D8
        DC.B    $DC,$DE,$DF,$DF,$9B,$00,$00,$00
        DC.B    $00,$00,$00
BLK28:  
        DC.B    $60,$60,$60,$60
        DC.B    $60,$63,$67,$67,$6E,$6C,$6C,$67
        DC.B    $63,$60,$20,$6D,$6D,$6D,$6D,$6D
        DC.B    $6D,$6D,$6D,$6F,$6F,$00,$60,$60
BLK29:  
        DC.B    $00,$00,$00,$00
        DC.B    $E0,$F8,$FC,$FC,$0E,$06,$06,$06
        DC.B    $E6,$06,$06,$9E,$BE,$B6,$B6,$B6
        DC.B    $B6,$B6,$B6,$BE,$1C,$00,$00,$00
        DC.B    $00,$00,$00
LOGO1C:
        DC.B    $0A,$0A,$08,$08,$08,$08,$08,$08,$08,$08,$08,$08,$06,$06,$06,$06
        DC.B    $06,$06,$06,$06,$04,$04,$04,$04,$04,$04,$04,$04,$02,$02,$02,$02
        DC.B    $02,$02,$02
PLAYLEV:
        DC.B    $FF,$02,$06
LOGO8:  DC.B    $00,$00,$55,$57,$56,$54,$54,$54
        DC.B    $54,$56,$F7,$A5,$04,$04,$04,$04
        DC.B    $04,$00,$00,$00,$44,$44,$44,$4C
        DC.B    $78,$70,$58,$4C,$44,$44,$40,$40
        DC.B    $40,$40,$40
        ORG     $F200
****
*
* GAME OVER GRAPHICS
*
****
BLK2B:  
        DC.B    $01,$03,$03,$03
        DC.B    $03,$03,$3B,$7B,$7B,$F9,$F0,$F0
        DC.B    $F0,$F0,$F0,$F0,$F1,$F7,$F7,$F0
        DC.B    $F0,$F0,$F0,$F0,$F0,$F0,$F0,$F8
        DC.B    $7F,$7F,$3F
LOGO2C:
        DC.B    $36,$38,$34,$94,$94,$94,$94,$96,$96,$96,$96,$96,$96,$96,$96,$96
        DC.B    $98,$98,$98,$98,$98,$98,$98,$98,$98,$9C,$96,$96,$96,$96,$96,$46
        DC.B    $46,$46,$46
BLK2D:  
        DC.B    $1E,$3E,$B0,$BC
        DC.B    $BE,$B6,$B6,$B6,$BE,$9C,$00,$6D
        DC.B    $6D,$6D,$6D,$6D,$6D,$6D,$6D,$7F
        DC.B    $3B
BLK2A:  
        DC.B    $00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
BLK2C:  DC.B    $C7,$E7,$6D,$6D
        DC.B    $6D,$6D,$6D,$6D,$ED,$CD,$00,$CD
        DC.B    $DD,$DB,$DB,$DB,$DB,$DB,$DB,$1F
        DC.B    $0F,$00,$00,$00,$00,$40,$40,$C0
        DC.B    $C0,$C0,$C0
BLK2E:  DC.B    $C0,$C0,$C0,$C0
        DC.B    $C0,$E0,$F0,$F8,$F8,$D8,$00,$9E
        DC.B    $BE,$B0,$BC,$BE,$B6,$B6,$B6,$BE
        DC.B    $1C,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
LOGO3C:
        DC.B    $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E
        DC.B    $0E,$0E,$0E,$0E,$0E,$0C,$0C,$0C
        DC.B    $0C,$0C,$0C,$0C,$0C,$0C,$0A,$0A
        DC.B    $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A
        DC.B    $0A,$0A,$0A
LOGOA:  DC.B    $00,$00,$0E,$0F,$01,$01,$03,$06
        DC.B    $0C,$A8,$EF,$47,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
        ORG     $F300
LOGO1:  DC.B    $38,$38,$38,$38,$38,$38,$38,$38
        DC.B    $38,$38,$38,$38,$38,$3F,$3F,$3F
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
LOGO2:  DC.B    $0E,$0E,$0E,$0E,$0E,$1C,$1C,$1C
        DC.B    $1C,$38,$38,$78,$F0,$F0,$E0,$80
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
LOGO3:  DC.B    $FF,$3F,$08,$0F,$0A,$0A,$0F,$08
        DC.B    $08,$0F,$0A,$0A,$0F,$08,$08,$0F
        DC.B    $15,$15,$3F,$2A,$6A,$7F,$55,$55
        DC.B    $7F,$5B,$02,$02,$02,$02,$02,$03
        DC.B    $03,$03,$02
LOGO4:  DC.B    $FC,$F8,$88,$F8,$28,$28,$F8,$88
        DC.B    $88,$F8,$28,$28,$F8,$88,$88,$F8
        DC.B    $54,$54,$FE,$AA,$AB,$FF,$55,$55
        DC.B    $FF,$6D,$00,$00,$00,$00,$00,$00
        DC.B    $80
LOGO7:  DC.B    $00,$00,$95,$BD,$AD,$A5,$B5,$9D
        DC.B    $8D,$A5,$BD,$19,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$A8,$E8,$68,$28
        DC.B    $A8,$E8,$68,$2D,$EF,$CA,$00,$00
        DC.B    $00,$00
ATC:
        DC.B    $00,$22,$24,$24,$26,$26,$28,$28,$2A,$2A,$2C,$2C,$2E,$2E
AT1:    DC.B    $00,$38,$44,$82,$9A,$BA,$A2,$A2
        DC.B    $A2,$BA,$9A,$82,$44,$38
AT2:    DC.B    $00,$EE,$EE,$4A,$42,$42,$42,$4E
        DC.B    $4E,$4A,$4A,$CA,$CE,$4E
AT3:    DC.B    $00,$EE,$EE,$AA,$AA,$AA,$AA,$EE
        DC.B    $EE,$AA,$AA,$AA,$EE,$EE
AT4:    DC.B    $00,$24,$24,$24,$24,$24,$3C,$3C
        DC.B    $24,$24,$24,$24,$3D,$19
AT5:    DC.B    $00,$92,$92,$92,$92,$92,$9E,$9E
        DC.B    $92,$92,$92,$92,$DE,$CC
        ORG     $F400
BLKCLR:
        DC.B    $0E,$0E,$0C,$0C
        DC.B    $0C,$0A,$0A,$0A,$0A,$08,$08,$08
        DC.B    $08,$06,$06,$06,$06,$04,$04,$04
        DC.B    $04,$02,$02
BLK10: 
        DC.B    $00,$81,$C1,$61
        DC.B    $21,$31,$11,$11,$19,$09,$09,$09
        DC.B    $0D,$05,$05,$05,$05,$05,$05,$05
        DC.B    $05,$05,$05
BLK11: 
        DC.B    $00,$02,$06,$0C
        DC.B    $08,$18,$10,$10,$30,$20,$20,$20
        DC.B    $60,$40,$40,$40,$40,$40,$40,$40
        DC.B    $40,$40,$40
BLK12:     
        DC.B    $00,$41,$61,$21
        DC.B    $31,$11,$11,$19,$09,$09,$09,$0D
        DC.B    $05,$05,$05,$05,$05,$05,$05,$05
        DC.B    $05,$05,$05
BLK13: 
        DC.B    $00,$04,$0C,$08
        DC.B    $18,$10,$10,$30,$20,$20,$20,$60
        DC.B    $40,$40,$40,$40,$40,$40,$40,$40
        DC.B    $40,$40,$40
BLK14:  
        DC.B    $00,$21,$31,$11
        DC.B    $11,$11,$19,$09,$09,$09,$0D,$05
        DC.B    $05,$05,$05,$05,$05,$05,$05,$05
        DC.B    $05,$05,$05
BLK15: 
        DC.B    $00,$08,$18,$10
        DC.B    $10,$10,$30,$20,$20,$20,$60,$40
        DC.B    $40,$40,$40,$40,$40,$40,$40,$40
        DC.B    $40,$40,$40
BLK16: 
        DC.B    $00,$10,$19,$09
        DC.B    $09,$0D,$05,$05,$05,$07,$03,$03
        DC.B    $03,$03,$03,$03,$03,$03,$03,$03
        DC.B    $03,$03,$03
BLK17: 
        DC.B    $00,$10,$30,$20
        DC.B    $20,$60,$40,$40,$40,$C0,$80,$80
        DC.B    $80,$80,$80,$80,$80,$80,$80,$80
        DC.B    $80,$80,$80
BLK18: 
        DC.B    $00,$09,$09,$09
        DC.B    $0D,$05,$05,$05,$07,$03,$03,$03
        DC.B    $03,$03,$03,$03,$03,$03,$03,$03
        DC.B    $03,$01,$01
BLK19:
        DC.B    $00,$20,$20,$20
        DC.B    $60,$40,$40,$40,$C0,$80,$80,$80
        DC.B    $80,$80,$80,$80,$80,$80,$80,$80
        DC.B    $80,$00,$00
PLAYERHI:
        DC.B    BLK2A/256,PLAYER2C/256
        ORG     $F500
BLK1A: 
        DC.B    $00,$05,$05,$05
        DC.B    $05,$03,$03,$03,$03,$03,$03,$03
        DC.B    $03,$03,$03,$01,$01,$01,$01,$01
        DC.B    $01,$01,$01
BLK1B: 
        DC.B    $00,$40,$40,$40
        DC.B    $40,$80,$80,$80,$80,$80,$80,$80
        DC.B    $80,$80,$80,$00,$00,$00,$00,$00
        DC.B    $00,$00
SCPF1:
        DC.B    $00,$02,$02,$03,$03,$03,$03,$03,$03
        DC.B    $03,$03,$03,$03,$03,$03,$03,$03,$03
BLK1D:  
        DC.B    $00,$80,$80,$80
        DC.B    $80,$80,$80,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
SCPF2:
        DC.B    $00,$00,$00,$00,$01,$01,$03,$03,$07
        DC.B    $07,$0F,$0F,$1F,$1F,$3F,$3F,$7F,$7F
BLK1C: 
        DC.B    $00,$03,$03,$03
        DC.B    $03,$03,$03,$01,$01,$01,$01,$01
        DC.B    $01,$01,$01,$01,$01,$01,$01,$01
        DC.B    $01,$01,$01
PLAYER1:
        DC.B    $00,$F8,$70,$70,$70,$70,$70,$70,$70,$F8,$D8,$B8,$B8,$B8,$70
        DC.B    $70,$70,$70,$70,$60,$40
PLAYER1C:
        DC.B    $00,$24,$24,$24,$24,$24,$24,$24,$26,$26,$26,$26,$26,$26,$26
        DC.B    $F8,$F8,$F8,$F8,$22,$22
PLAYER2C:
        DC.B    $00,$34,$34,$34,$34,$34,$34,$34,$36,$36,$36,$36,$36,$36,$F8
        DC.B    $F8,$F8,$F8,$32,$32,$32
SELJOY:
        LDA     SKEY+1
        BNE     .6
        LDY     PLAY
        LDA     SWCHA
        ASL
        BCS     .1
        TYA
        CLC
        ADC     #$02
        CMP     #$06
        BCC     .4
        BCS     .5
.1:
        ASL
        BCS     .2
        TYA
        SEC
        SBC     #$02
        BCS     .4
        BCC     .5
.2:
        ASL
        BCS     .3
        TYA
        AND     #$0E
        BPL     .4
.3:
        ASL
        BCS     .6
        TYA
        ORA     #$01
.4:
        STA     PLAY
.5:
        LDA     #$01
        STA     SKEY+1
        LDA     #$00
        STA     SCORLO+2
        STA     SCORHI+2
        STA     LEVEL
.6:
        RTS
        ORG     $F600
EBEAR:
        DC.B    $00,$00,$00,$7C,$FE,$FE,$C6,$C6,$BA,$FE,$D6,$D6,$7C,$FE,$EE
        DC.B    $EE,$44,$00
MBEAR:
        DC.B    $00,$00,$00,$7C,$FE,$FE,$C6,$FE,$92,$92,$00,$92,$7C,$FE,$EE
        DC.B    $EE,$44,$00
HBEAR:
        DC.B    $00,$00,$00,$7C,$FE,$BA,$C6,$FE,$9E,$96,$00,$9E,$7C,$FE,$EE
        DC.B    $EE,$44,$00,$00,$00,$00
AT1LO:
        DC.B    BLK10&$FF,BLK10&$FF,BLK10&$FF,BLK12&$FF,BLK14&$FF,BLK16&$FF,BLK18&$FF
        DC.B    BLK1A&$FF,BLK1C&$FF,BLK1E&$FF
        DC.B    BLK1C&$FF,BLK1A&$FF,BLK18&$FF,BLK16&$FF,BLK14&$FF,BLK12&$FF
AT2LO:
        DC.B    BLK11&$FF,BLK11&$FF,BLK11&$FF,BLK13&$FF,BLK15&$FF,BLK17&$FF,BLK19&$FF
        DC.B    BLK1B&$FF,BLK1D&$FF,BLK2A&$FF,BLK1D&$FF
        DC.B    BLK1B&$FF,BLK19&$FF,BLK17&$FF,BLK15&$FF,BLK13&$FF
AT1HI:
        DC.B    BLK10/256,BLK10/256,BLK10/256,BLK12/256,BLK14/256,BLK16/256,BLK18/256
        DC.B    BLK1A/256,BLK1C/256,BLK1E/256
        DC.B    BLK1C/256,BLK1A/256,BLK18/256,BLK16/256,BLK14/256,BLK12/256
AT2HI:
        DC.B    BLK11/256,BLK11/256,BLK11/256,BLK13/256,BLK15/256,BLK17/256,BLK19/256
        DC.B    BLK1B/256,BLK1D/256,BLK2A/256,BLK1D/256
        DC.B    BLK1B/256,BLK19/256,BLK17/256,BLK15/256,BLK13/256
****
*
* SCORE TABLES
*
****
DIG7:
        DC.B    $30,$30,$18,$0C,$06
DIG1:
        DC.B    $7E,$18,$18,$18,$38,$18
DIG6:
        DC.B    $3C,$66,$66,$7C,$60
DIG5:
        DC.B    $3C,$66,$06,$7C,$60
DIG2:
        DC.B    $7E,$30,$18,$0C,$66
DIG3:
        DC.B    $3C,$66,$0C,$18
DIG4:
        DC.B    $0C,$7E,$6C,$3C,$1C,$0C
DIG9:
        DC.B    $38,$0C,$06,$3E,$66
DIG0:
        DC.B    $3C,$66,$66,$66,$66
DIG8:
        DC.B    $3C,$66,$66,$3C,$66,$3C
KEY0:
        DC.B    $C0,$80,$C0,$80,$C0,$C0
KEY1:
        DC.B    $0E,$1F,$1F,$0E,$04,$02
KEY2:
        DC.B    $CE,$9F,$DF,$8E,$C4,$C2
HISC:
        DC.B    $00,$97,$92,$F2,$92,$97
LOGO9:  DC.B    $00,$00,$19,$BD,$A5,$A1,$BD,$BD
        DC.B    $A5,$A5,$BD,$19,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00,$00,$00,$00,$00,$00
        DC.B    $00,$00,$00
SPACE:
        DC.B    $00,$00,$00,$00,$00,$00
AT6:    DC.B    $00,$97,$97,$92,$92,$92,$E2,$E2
        DC.B    $92,$92,$92,$92,$F7,$E7
OPTIONLO:
        DC.B    EBEAR&$FF,MBEAR&$FF,HBEAR&$FF
        ORG     $F700
****
*
* LEVEL LETTER GRAPHICS
*
****
BLK30: 
        DC.B    $63
        DC.B    $63,$63,$7F,$7F,$63,$63,$63,$63
        DC.B    $63,$7F,$3E
BLK31: 
        DC.B    $7E
        DC.B    $7F,$63,$63,$63,$7F,$7E,$63,$63
        DC.B    $63,$7F,$7E
BLK32: 
        DC.B    $3E
        DC.B    $7F,$63,$60,$60,$60,$60,$60,$60
        DC.B    $63,$7F,$3E
BLK33: 
        DC.B    $7E
        DC.B    $7F,$63,$63,$63,$63,$63,$63,$63
        DC.B    $63,$7F,$7E
BLK34: 
        DC.B    $3F
        DC.B    $7F,$60,$60,$60,$7C,$7C,$60,$60
        DC.B    $60,$7F,$3F
BLK35: 
        DC.B    $60
        DC.B    $60,$60,$60,$60,$7C,$7C,$60,$60
        DC.B    $60,$7F,$3F
BLK36:
        DC.B    $3F
        DC.B    $7F,$63,$63,$63,$6F,$6F,$60,$60
        DC.B    $63,$7F,$3E
BLK37: 
        DC.B    $63
        DC.B    $63,$63,$63,$63,$7F,$7F,$63,$63
        DC.B    $63,$63,$63
BLK38:
        DC.B    $3F
        DC.B    $3F,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        DC.B    $0C,$3F,$3F
BLK39:
        DC.B    $3E
        DC.B    $7F,$63,$03,$03,$03,$03,$03,$03
        DC.B    $03,$03,$03
BLK3A: 
        DC.B    $C3
        DC.B    $C7,$CE,$DC,$F8,$F0,$F0,$F8,$DC
        DC.B    $CE,$C7,$C3
BLK3B:
        DC.B    $3F
        DC.B    $7F,$60,$60,$60,$60,$60,$60,$60
        DC.B    $60,$60,$60
BLK3C: 
        DC.B    $DB
        DC.B    $DB,$DB,$DB,$DB,$DB,$DB,$DB,$DB
        DC.B    $FF,$FF,$7E
BLK3D: 
        DC.B    $63
        DC.B    $63,$67,$67,$6F,$6B,$6B,$7B,$73
        DC.B    $73,$63,$63
BLK3E:
        DC.B    $3E
        DC.B    $7F,$63,$63,$63,$63,$63,$63,$63
        DC.B    $63,$7F,$3E
BLK3F: 
        DC.B    $60
        DC.B    $60,$60,$60,$7E,$7F,$63,$63,$63
        DC.B    $63,$7F,$3E
BLK40:
        DC.B    $3D
        DC.B    $7A,$65,$6B,$63,$63,$63,$63,$63
        DC.B    $63,$7F,$3E
BLK41: 
        DC.B    $63
        DC.B    $63,$63,$63,$7F,$7E,$63,$63,$63
        DC.B    $63,$7F,$3E
BLK42:
        DC.B    $3E
        DC.B    $7F,$63,$03,$03,$3F,$7E,$60,$60
        DC.B    $63,$7F,$3E
BLK43: 
        DC.B    $0C
        DC.B    $0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
        DC.B    $0C,$3F,$3F
BLK44: 
        DC.B    $3E
        DC.B    $7F,$63,$63,$63,$63,$63,$63,$63
        DC.B    $63,$63,$63
OPTIONHI:
        DC.B    EBEAR/256,MBEAR/256,HBEAR/256
        ORG     $F800
BLK45:
        DC.B    $1C
        DC.B    $3E,$3E,$36,$77,$63,$63,$63,$63
        DC.B    $63,$63,$63
BLK46:
        DC.B    $7E
        DC.B    $FF,$FF,$DB,$DB,$DB,$DB,$DB,$DB
        DC.B    $DB,$DB,$DB
BLK47: 
        DC.B    $C3
        DC.B    $C3,$C3,$E7,$66,$3C,$18,$3C,$66
        DC.B    $C3,$C3,$C3
BLK48: 
        DC.B    $18
        DC.B    $18,$18,$18,$18,$18,$18,$3C,$66
        DC.B    $C3,$C3,$C3
BLK49: 
        DC.B    $7F
        DC.B    $7F,$60,$60,$30,$18,$0C,$06,$03
        DC.B    $03,$7F,$7F
LETTLO:
        DC.B    BLK30&$FF,BLK31&$FF,BLK32&$FF,BLK33&$FF 
        DC.B    BLK34&$FF,BLK35&$FF,BLK36&$FF,BLK37&$FF 
        DC.B    BLK38&$FF,BLK39&$FF,BLK3A&$FF,BLK3B&$FF 
        DC.B    BLK3C&$FF,BLK3D&$FF,BLK3E&$FF,BLK3F&$FF 
        DC.B    BLK40&$FF,BLK41&$FF,BLK42&$FF,BLK43&$FF 
        DC.B    BLK44&$FF,BLK45&$FF,BLK46&$FF,BLK47&$FF 
        DC.B    BLK48&$FF,BLK49&$FF
****
*
* PROGRAM INITIALIZATION PROGRAM
*
* CLEARS RAM, SET UP STACK, TURNS OFF INTERRUPTS, AND CLEARS DECIMAL MODE
*
* THIS PROGRAM IS RAN FIRST.
*
****
SETUP:
        SEI
        CLD
        LDX     #$00
        TXA
.1:
        STA     $00,X
        STA     $EF7F,X
        INX
        BNE     .1
        LDA     #$02
        STA     SKEY
        STA     PLAY            ;SETUP INITIAL GAME NUMBER
        LDA     #$30
        STA     FCOUNT          ;INIT FRAME COUNT 
****
*
* TITLE PROGRAM 
*
* THIS PROGRAM IS CALLED FROM STARTUP, GAME OVER, AND BUTTON HIT
*
* STARTS WITH CURRENT GAME AND INITIALIZES TIMER STUFF
*
****
TITLE:
        JSR     UPJKEY
        LDX     #$FF
        LDA     #$00
        STA     TEMP+3
        STA     AUDV0
        STA     AUDV0+1
        TXS
        LDA     #$54            ;INITIALIZE TIMER FOR ANIMATION
        STA     TEMP+1
        LDA     #$05
        STA     TEMP+2
        
TITLE1:
        LDA     #02
        LDY     #0
        STA     WSYNC           ;TURN ON SYNC AT BEGINNING OF LINE
        STA     VSYNC           ;START VERTICAL SYNC
        STA     WSYNC
        STA     HMCLR
        STA     WSYNC           ;WAIT 3 LINES
        STA     WSYNC
        STY     VSYNC           ;TURN OFF VERTICAL SYNC
        STA     VBLANK          ;TURN ON VERTICAL BLANK
        LDA     #76
        STA     TIM64T          ;START TIMER
        DEC     FCOUNT
        STA     WSYNC
        LDA     #$02            ;2 RESET PLAYERS FOR DUNGEON
        STA     NUSIZ0
        STA     NUSIZ1
        LDA     #$21
        STA     COUNTER         ;13
        LDA     #$00
        STA     COLUBK
        STA     COLUPF
        STA     GRP0
        STA     GRP1
        LDA     #$10            ;29
        STA     HMP1
        NOP
        NOP
        NOP
        STA     RESP0           ;41
        STA     RESP1
        LDA     #$01            ;TURN ON VERTICAL DELAYS
        STA     VDELP0
        STA     VDELP1
        STA     WSYNC
        STA     HMOVE           ;MOVE PLAYER 1 

.1:     LDA     INTIM           ;WAIT TILL TIMER DONE
        BNE     .1
        STA     WSYNC
        LDA     #$00
        STA     VBLANK          ;TURN OFF VERTICAL BLANK
        LDX     #18             ;GO DOWN 30 LINES
.2:
        STA     WSYNC
        DEX
        BNE     .2
        LDX     #$22
        JMP     DUNGEON
BLK1E: 
        DC.B    $00,$01,$01,$01
        DC.B    $01,$01,$01,$01,$01,$01,$01,$01
        DC.B    $01,$01,$01,$01,$01,$01,$01,$01
        DC.B    $01,$01,$01
ATRIBUTE:
        DC.B    $00,$08,$20,$28,$80,$88,$A0,$A8
        ORG     $F900
****
*
*  PROGRAM TO DISPLAY THE DUNGEON LOGO
*
*  PLAYERS USED AS FOLLOWS  P0P1XXXXP0P1 FOR THE FIRST SECTION
*  KERNAL PROGRAM DOES THE MIDDLE LINE AND CHANGING THE BACKGROUND COLOR
*  PLAYERS USED AS FOLLOWS  P0P1P0P1P0P1 FOR THE LAST SECTION
* FIRST SECTION CHANGES THE COLORS DURING THE TWO SETS OF PLAYERS
* LAST SECTION JUST UPDATES MANY PLAYERS ON LINE 
*
****
DUNGEON:
        STA     WSYNC
        LDA     COUNTER
        LDA     LOGO1C,X        ;TOP PORTION OF DUNGEON
        STA     COLUP0
        STA     COLUP1
        LDA     LOGO1,X
        STA     GRP0
        LDA     LOGO2,X
        STA     GRP1
        LDA     LOGO3,X
        STA     GRP0
        LDA     LOGO2C,X
        LDY     LOGO4,X
        STY     GRP1
        STY     GRP0
        STA     COLUP0
        STA     COLUP1
        DEX
        BPL     DUNGEON
        STA     WSYNC
        LDA     #$38
        STA     GRP0
        LDA     #$0E
        STA     GRP1
        LDA     #$03
        STA     GRP0
        STA     NUSIZ0
        STA     NUSIZ1
        LDA     #$0A
        STA     COLUP0
        STA     COLUP1
        LDX     #$00
        LDA     #$22
        STA     COUNTER
        LDA     #$32
        STA     COLUBK
        LDY     #$34
        STY     COLUP0
        STY     COLUP1
        STY     COLUBK
        STY     GRP1
        STA     COLUP1
        STX     COLUBK
.1:
        LDX     COUNTER
        LDA     LOGO3C,X
        STA     COLUP0
        STA     WSYNC
        STA     COLUP1
        LDA     LOGO5,X
        STA     GRP0
        LDA     LOGO6,X
        STA     GRP1
        LDA     LOGO7,X
        STA     GRP0
        LDA     LOGO8,X
        STA     TEMP
        LDY     LOGO9,X
        LDA     LOGOA,X
        LDX     TEMP
        STX     GRP1
        STY     GRP0
        STA     GRP1
        STA     GRP0
        DEC     COUNTER
        BPL     .1
        LDA     #$00
        STA     COLUP0
        STA     COLUP1
        INC     RANDOM
        LDX     #15
.2:
        STA     WSYNC
        DEX
        BNE     .2
        LDA     #13
        STA     COUNTER
****
*
* PROGRAM TO DISPLAY COPYRIGHT 1988 ATARI LOGO
*
* USES SAME DISPLAY AS LAST PART OF DUNGEON LOGO 
*
****
ATARI:
        LDX     COUNTER
        LDA     ATC,X
        STA     COLUP0
        STA     WSYNC
        STA     COLUP1
        LDA     AT1,X
        STA     GRP0
        LDA     AT2,X
        STA     GRP1
        LDA     AT3,X
        STA     GRP0
        LDA     AT4,X
        STA     TEMP
        LDY     AT5,X
        LDA     AT6,X
        LDX     TEMP
        STX     GRP1
        STY     GRP0
        STA     GRP1
        STA     GRP0
        DEC     COUNTER
        BPL     ATARI
****
*
* PROGRAM TO ANIMATE ATARI SYMBOL
*
****
        STA     WSYNC
        LDA     TEMP+1          ;ANIMATE BLOCK #
        AND     #$0F
        TAX
        LDA     AT1LO,X         ;UPDATE INDIRECT LOCATION OF GRAPHICS
        STA     TEMP+4
        LDA     AT1HI,X
        STA     TEMP+5
        LDA     AT2LO,X
        STA     TEMP+6
        LDA     AT2HI,X
        STA     TEMP+7
        LDY     #23
        JMP     ATARI1
NUMLO:
        DC.B    DIG0&$FF,DIG1&$FF,DIG2&$FF,DIG3&$FF,DIG4&$FF,DIG5&$FF
        DC.B    DIG6&$FF,DIG7&$FF,DIG8&$FF,DIG9&$FF
PLAYERLO:
        DC.B    BLK2A&$FF,PLAYER2C&$FF
        ORG     $FA00
ATARI1:
        STA     WSYNC
        LDA     TEMP+1
        AND     #$F0
        ORA     BLKCLR,Y        ;9
        STA     COLUP1
        STA     COLUP0
        LDX     #$00
        STX     GRP0
        STX     GRP1            ;23
        LDA     (TEMP+4),Y
        STA     GRP0
        LDA     (TEMP+6),Y      ;36
        NOP
        NOP
        NOP
        STA     GRP1
        STX     GRP0
        STX     GRP1
        STX     GRP0
        DEY
        BPL     ATARI1
****
*
* PROGRAM TO DISPLAY THE GAME SELECTION
*
* USES DISPLAY AS FOLLOWS P0          P1  P1
* P0 DISPLAYS THE BEAR  P1 DISPLAYS THE PLAYERS
* BEAR COLOR REMAINS THE SAME BUT P1 COLORS CHANGE BETWEEN THEM
* 
*
****
SELECT:
        STA     WSYNC
        LDA     PLAY
        LSR
        TAX
        LDA     OPTIONLO,X
        STA     BEAR
        LDA     OPTIONHI,X
        STA     BEAR+1
        LDA     #$00
        STA     NUSIZ0
        STA     RESP0
        STA     VDELP0
        STA     VDELP1
        ROL
        TAX
        LDA     PLAYERLO,X
        STA     PLAYER
        LDA     PLAYERHI,X
        STA     PLAYER+1
        LDA     #$01
        STA     NUSIZ1
        LDY     #20
        STA     RESP1
        STA     WSYNC
        LDA     #$24
        STA     COLUP0
.1:
        LDA     (BEAR),Y
        STA     GRP0
        LDA     PLAYER1,Y
        STA     GRP1
        LDA     PLAYER1C,Y
        STA     COLUP1
        LDA     (PLAYER),Y
        LDX     #5
.2:
        DEX
        BPL     .2
        NOP
        STA     COLUP1
        STA     WSYNC
        DEY
        BPL     .1
        LDA     #$FF
        STA     TEMP+5
        JSR     SCORE
OVERSCAN:
        LDX     #75
        STX     $296
        DEC     TEMP+2          ;LOW TIMER
        BNE     .4
        DEC     TEMP+1
        LDA     #$05
        STA     TEMP+2
.4:
KEY:
        JSR     SELJOY
        JSR     UPJKEY
        LDA     $282
        AND     #$02            ;CHECK IF BUTTON PRESSED
        BNE     .2
        LDA     SKEY
        BMI     .6
        BNE     .3
        LDA     FCOUNT
        BNE     .4
        LDA     PLAY
        CLC
        ADC     #$01
        CMP     #$06
        BNE     .1
        LDA     #$00
.1:
        STA     PLAY
        LDA     #$00
        STA     SCORLO+2
        STA     SCORHI+2        ;IF SELECT KEY HIT THEN CLEAR HIGH SCORE
        STA     LEVEL           ;ALSO START GAME AT SET LEVEL
        LDA     #80
        STA     FCOUNT
        BNE     .4
.2:
        LDA     #$02
        STA     SKEY
        BNE     .4
.3:
        LDA     #$00
        STA     SKEY
        LDA     #3
        STA     FCOUNT
.4:
        LDA     $282
        AND     #$01
        BNE     .5
        LDA     #$00
        STA     LEVEL           ;IF RESET BUTTON HIT THEN START AT SET LEVEL 
.41:
        JMP     UPLEVEL         ;START GAME 
.5:
        LDX     #$FF            ;IF BUTTON HIT THEN START AT LAST LEVEL
        LDA     $C
        BPL     .41
        LDA     $D
        BPL     .41
.6:
        LDA     $284
        BNE     .6
        JMP     TITLE1
UPJKEY:
        LDX     #$00
        LDA     SWCHA
        CMP     #$F0
        BCS     .1
        LDX     #$01
.1:
        STX     SKEY+1
        RTS
****
*
* PROGRAM TO DISPLAY GRAPHICS IN P0P1P0P1P0P1 FORMAT USING INDIRECT
* WITH NO COLOR CHANGES
*
* ON ENTRY X=COUNTER A=COLOR FOR PLAYERS
*
****
SIXWIDE:
        STX     COUNTER
        STA     COLUP0
        STA     COLUP1
.1:
        LDY     COUNTER         ;65
        LDA     (ADIG5),Y
        STA     WSYNC           ;73
        STA     TEMP            ;3
        LDA     (ADIG4),Y
        TAX
        LDA     (ADIG1),Y       ;15
        STA     GRP0
        LDA     (ADIG2),Y       ;23
        STA     GRP1
        LDA     (ADIG3),Y
        STA     GRP0 
        LDA     (ADIG6),Y       ;39           
        LDY     TEMP
        STX     GRP1            ;45
        STY     GRP0
        STA     GRP1            ;51
        STA     GRP0            ;54
        DEC     COUNTER         ;59
        BPL     .1
        LDA     #$00
        STA     GRP0
        STA     GRP1
        STA     GRP0
        RTS
****
*
* PROGRAM TO DISPLAY GAME OVER ON SCREEN
*
****
GAMEOVER:
        JSR     DOVB0
        STA     WSYNC
        LDA     #BLK2A/256
        STA     ADIG1+1
        STA     ADIG2+1
        STA     ADIG3+1
        STA     ADIG4+1
        STA     ADIG5+1
        STA     ADIG6+1
        LDA     #BLK2A&$FF
        STA     ADIG1
        LDA     #BLK2B&$FF
        STA     ADIG2
        LDA     #BLK2C&$FF
        STA     ADIG3
        STA     ADIG3
        STA     RESP0
        STA     RESP1
        LDA     #BLK2D&$FF
        STA     ADIG4
        LDA     #BLK2E&$FF
        STA     ADIG5
        LDA     #BLK2A&$FF
        STA     ADIG6
        JSR     DOVB
.1:
        JSR     DOVB1
        LDX     #96
.3:
        STA     WSYNC
        DEX
        BNE     .3
        LDX     #30
        LDA     TEMP+4
        JSR     SIXWIDE
        LDX     #82
.4:
        STA     WSYNC
        DEX
        BNE     .4
        
        LDA     #61
        STA     TIM64T
        LDA     TEMP+5
        BNE     .7
        DEC     FRMCNT
        BNE     .1
        LDA     #$03
        STA     FRMCNT
        LDX     TEMP+4
        INX
        CPX     #$0E
        BNE     .5
        LDX     #$0C
        LDA     $C
        BPL     .5
        LDA     $D
        BPL     .5
        LDA     #$D4
        STA     TEMP+5
        STA     FRMCNT
        LDX     #$0C
.5:
        STX     TEMP+4
        JMP     .1
.7:
        DEC     FRMCNT
        BNE     .1
        LDA     #$03
        STA     FRMCNT
        LDX     TEMP+4
        DEX
        BMI     .8
        STX     TEMP+4
        JMP     .1
.8:
        LDA     $284
        BNE     .8
        JMP     TITLE
****
*
* PROGRAM TO DISPLAY ENTERING LEVEL ON SCREEN
*
****
ENTLEVEL:
        JSR     DOVB0
.1:
        STA     WSYNC
        LDA     #BLK24/256
        STA     ADIG1+1
        STA     ADIG2+1
        STA     ADIG3+1
        STA     ADIG4+1
        STA     ADIG5+1
        STA     ADIG6+1
        LDA     #BLK24&$FF
        STA     ADIG1
        LDA     #BLK25&$FF
        STA     ADIG2
        LDA     #BLK26&$FF
        STA     ADIG3
        STA     ADIG3
        STA     RESP0
        STA     RESP1
        LDA     #BLK27&$FF
        STA     ADIG4
        LDA     #BLK28&$FF
        STA     ADIG5
        LDA     #BLK29&$FF
        STA     ADIG6
        JSR     DOVB
.2:
        JSR     DOVB1
        LDX     #81
.4:
        STA     WSYNC
        DEX
        BNE     .4
        LDX     #30
        LDA     TEMP+4
        JSR     SIXWIDE
        LDA     #$00
        STA     NUSIZ1
        STA     VDELP1
        STA     HMCLR
        LDA     #$A0
        STA     HMP1
        STA     WSYNC
        STA     HMOVE
        LDX     LEVEL
        LDA     LETTLO,X
        STA     ADIG1
        LDA     #BLK30/256
        CPX     #$15
        BCC     .5
        LDA     #BLK45/256
.5:
        STA     ADIG1+1
        STA     WSYNC
        STA     HMOVE
        LDY     #$0B
.6:
        LDA     (ADIG1),Y
        STA     WSYNC
        STA     GRP1
        DEY
        BPL     .6 
        LDA     #$00
        STA     WSYNC
        STA     GRP1   
        LDX     #97
.7:
        STA     WSYNC
        DEX
        BNE     .7
        
        LDA     #62
        STA     TIM64T
        LDA     TEMP+5
        BNE     .10
        DEC     FRMCNT
        BEQ     .8
        JMP     .1
.8:
        LDA     #$03
        STA     FRMCNT
        LDX     TEMP+4
        INX
        CPX     #$0E
        BNE     .9
        LDX     #$0C
        LDA     $C
        BPL     .9
        LDA     $D
        BPL     .9
        LDA     #$D4
        STA     TEMP+5
        STA     FRMCNT
        LDX     #$0C
.9:
        STX     TEMP+4
        JMP     .1
.10:
        DEC     FRMCNT
        BEQ     .11
        JMP     .1
.11:
        LDA     #$03
        STA     FRMCNT
        LDX     TEMP+4
        DEX
        BMI     .12
        STX     TEMP+4
        JMP     .1
.12:
        LDA     CONTRL
        AND     #$F0
        ORA     #$05
        STA     CONTRL
        JMP     LBANK
DOVB0:
        LDA     #$00
        STA     TEMP+4
        STA     TEMP+5
        LDA     #$03
        STA     FRMCNT
        RTS
DOVB:
        LDA     #$03
        STA     VDELP0
        STA     VDELP1
        STA     NUSIZ0
        STA     NUSIZ1
        STA     HMCLR
        LDA     #$10
        STA     HMP1
        STA     WSYNC
        STA     HMOVE
        RTS
DOVB1:
.2:
        LDA     INTIM
        BNE     .2
        LDA     #$02
        LDY     #$00
        STA     WSYNC
        STA     VSYNC
        LDA     #$FF
        STA     PF0
        STA     PF1
        STA     PF2
        STA     WSYNC
        LDA     #$00
        ASL
        ASL
        ASL
        ASL
        STA     COLUPF
        STY     REFP0
        STY     REFP1
        STA     WSYNC
        LDA     #$02
        STA     WSYNC
        STY     VSYNC
        STA     VBLANK
        LDA     #40
        STA     TIM64T
.3:
        LDA     INTIM
        BNE     .3
        LDA     #$00
        STA     VBLANK
        RTS
****
*
* SUBROUTINE TO DO SCORE  
*
* WHERE Y=PLAYER INDEX 0-1
* A= PLAYER SCORE COLOR
*
****
SCORESUB:
        STA     COLUP0         
        STA     COLUP1
        STA     WSYNC
        LDA     #$00
        STA     TEMP            ;11 STORE FLAG OF LEADING ZERO
        LDA     SCORHI,Y
        LSR
        LSR
        LSR
        LSR                    
        TAX                     ;25
        BEQ     .8              ;IF DIGIT = 0 THEN USE SPACE
        STA     TEMP            ;MAKE FLAG <> 0 (NO MORE SPACES)
        LDA     NUMLO,X
.1:
        STA     LOW+$E          ;37       
        LDA     SCORHI,Y
        AND     #$0F
        TAX                     ;45
        BNE     .2              ;IF DIGIT <>0 THEN SKIP
        LDA     TEMP
        BEQ     .9              ;IF FLAG = 0 THEN USE SPACE
.2:
        STA     TEMP 
        LDA     NUMLO,X
.3:
        STA     LOW+$13         ;62
        LDA     SCORLO,Y
        LSR
        LSR
        LSR
        LSR
        TAX                     ;76
        BNE     .4
        LDA     TEMP
        BEQ     .10
.4:
        STA     TEMP
        LDA     NUMLO,X
.5:
        STA     LOW+$18         ;17
        LDA     SCORLO,Y
        AND     #$0F
        TAX                     ;25
        BNE     .6
        LDA     TEMP
        BEQ     .11
.6:
        STA     TEMP
        LDA     NUMLO,X
.7:
        STA     WSYNC
        STA     LOW+$1D         ;42
        CPY     #$02
        BEQ     .13             ;IF Y=HIGHSCORE NO KEYS OR HEALTH
        LDA     KEYS,Y
        BNE     .71
        LDX     #SPACE&$FF      ;IF BOTH=0 THEN NOTHING
        BNE     .75
.71:
        LDX     #KEY0&$FF
        CMP     #$10
        BCC     .75             ;IF KEYS ONLY EXIT JUST DO KEYS
        LDX     #KEY1&$FF       ;JUST BOMBS
        AND     #$0F
        BEQ     .75
        LDX     #KEY2&$FF       ;BOTH
.75:
        STX     LOW+$9
        JMP     .12
.8:
        LDA     #SPACE&$FF
        BNE     .1
.9:
        LDA     #SPACE&$FF
        BNE     .3
.10:
        LDA     #SPACE&$FF
        BNE     .5
.11:
        LDA     #SPACE&$FF
        BNE     .7
.12:
        LDA     HEALTH,Y        ;57
        LSR
        AND     #$0F
        TAX
        LDA     SCPF2,X         ;61
        STA     PF2
        LDA     SCPF1,X
        STA     TEMP
        LDA     HEALTH,Y
        ROL
        ROL
        ROL
        ROL
        AND     #$07
        TAX
        LDA     ATRIBUTE,X
        ORA     TEMP
        STA     PF1
.13:
        JMP     LOW
****
*
* PROGRAM TO START GAME BY RESETTING THE LEVEL, SCORE, AND HEALTH
*
****
UPLEVEL:
        LDA     #$00
        STA     SCORLO
        STA     SCORLO+1
        STA     SCORHI
        STA     SCORHI+1
        STA     KEYS
        STA     KEYS+1
        STA     ADIR
        STA     ADIR+1
        LDA     #$12
        STA     HEALTH
        STA     HEALTH+1
        JMP     UPL
****
*
* SCORE PROGRAM
*
* THIS IS A TRICKY PROGRAM!!  IT FIRST MOVES THE KERNAL PORTION INTO ZERO
* PAGE AND RUNS IT THERE.  THIS PROGRAM HAD TO TURN ON AND OFF THE PF COLOR,
* LOAD SIX LOCATIONS AND STORE THEM AT THE APPROPRIATE TIMES.  IT IS MADE
* TO BE SELF MODIFYING AND IT IS THE ONLY WAY IT WOULD WORK.
*
* DISPLAY IS AS FOLLOWS:
*
* HEALTH IS USED THE 16 BITS OF PF1 AND PF2 TURNS COLOR OFF ON RIGHT SIDE
* SCORE IS SIX DIGITS WITH THE FIRST DIGIT AS KEYS AND FIVE FOR SCORE NUMBER
*
****
START:
        STA     WSYNC
        LDA     CONTRL
        AND     #$0F
        CMP     #$04
        BNE     .1
        LDA     #102
        STA     TIM64T
        JMP     ENTLEVEL
.1:
        CMP     #$07
        BNE     .2
        LDA     #102
        STA     TIM64T
        JMP     GAMEOVER
.2:
        LDA     #$00
        STA     TEMP+5
        JSR     SCORE
        JMP     STLEVEL
SCORE:
        STA     WSYNC
        LDA     #$00
        STA     COLUPF
        STA     COLUBK
        STA     ENABL           ;TURN OFF PLAYERS AND BALL
        STA     GRP0
        STA     GRP1
        STA     GRP0            ;17
        STA     REFP0
        STA     REFP1
        STA     CTRLPF
        LDA     #$03            ;P0P1P0P1P0P1 DISPLAY
        STA     NUSIZ0          ;34
        STA     NUSIZ1
        STA     VDELP0          ;VERTCAL DELAY ON OF COURSE
        STA     VDELP1
        STA     HMCLR
        LDA     #$FF            ;48
        STA     HMP0
        STA     RESP0           ;54
        STA     RESP1           ;57
        LDA     #$85
        STA     LOW
        STA     LOW+4
        STA     LOW+11  
        STA     LOW+16
        STA     WSYNC
        STA     HMOVE
* PUT PROGRAM INTO ZERO PAGE TO BE RUN FROM THERE
        STA     LOW+21
        STA     LOW+26
        STA     LOW+47
        STA     LOW+49
        STA     LOW+53
        STA     LOW+57
        STA     LOW+59
        STA     LOW+61
        LDA     #$A9
        STA     LOW+2
        STA     LOW+55
        LDA     #$B9
        STA     LOW+8
        STA     LOW+13
        STA     LOW+18
        STA     LOW+23
        STA     LOW+28
        STA     LOW+32
        LDA     #DIG0/256       ;HIGH PAGE OF GRAPHICS DATA
        STA     LOW+10
        STA     LOW+15
        STA     LOW+20
        STA     LOW+25
        STA     LOW+30
        STA     LOW+34
        LDA     #$A0
        STA     LOW+6
        STA     LOW+35
        STA     LOW+39
        LDA     #$1B
        STA     LOW+12
        STA     LOW+22
        STA     LOW+46
        STA     LOW+50
        STA     LOW+58
        STA     LOW+62
        LDA     #$1C
        STA     LOW+17
        STA     LOW+44
        STA     LOW+48
        STA     LOW+60
        LDA     #$02
        STA     LOW+1
        STA     LOW+54
        LDA     #$00
        STA     LOW+36
        STA     LOW+56
        STA     PF0
        LDA     #$08
        STA     LOW+5
        STA     LOW+38
        LDA     #$AA
        STA     LOW+31
        LDA     #$84
        STA     LOW+37
        STA     LOW+43
        LDA     #$A8
        STA     LOW+27
        LDA     #$C6
        STA     LOW+41
        LDA     #$87
        STA     LOW+42
        LDA     #$10
        STA     LOW+51
        LDA     #$CB
        STA     LOW+52
        LDA     #$86
        STA     LOW+45
        LDA     #$60
        STA     LOW+63
        LDA     #DIG0&$FF
        STA     LOW+33          ;LOW BYTE OF ZERO
        LDA     #$26            ;PUT IN PF COLOR FOR FIRST PLAYER
        STA     LOW+3
        LDA     #$05            ;SET COUNTER
        STA     LOW+7
        LDA     TEMP+5
        BNE     .5
        LDY     #$00            ;INDEX FOR FIRST PLAYER
        LDA     #$24            ;COLOR FOR FIRST PLAYER
        JSR     SCORESUB
* CHECK IF OTHER PLAYER EXISTS
        LDA     PLAY
        LSR
        BCS     .3
        LDX     #$07
.2:
        STA     WSYNC           ;IF NOT JUST WAIT OVER IT
        DEX
        BPL     .2
        BMI     .4
.3:
        LDA     #$05
        STA     LOW+7           ;CHANGE COUNTER BACK AND PFCOLOR
        LDA     #$36
        STA     LOW+3
        LDA     #$34            ;COLOR FOR SECOND PLAYER
        LDY     #$01            ;INDEX FOR SECOND PLAYER
        JSR     SCORESUB
.4:
        RTS
.5:
        LDA     #HISC&$FF       ;PUT IN HI ICON
        STA     LOW+9
        LDA     #$00
        STA     PF2
        STA     PF1
        LDA     #$76
        STA     LOW+3
        LDY     #$02
        LDA     #$94
        JMP     SCORESUB
****
*
* PROGRAM TO CHECK IF PLAYER GOING TO NEXT LEVEL, GAME OVER, DEMO TIMER DONE
*
****
STLEVEL:
        LDA     #83             ;SET TIMER
        STA     TIM64T
        LDA     SWCHB
        ASL
        ASL
        ASL
        EOR     CONTRL
        AND     #$40
        BEQ     .01
        LDA     CONTRL
        ORA     #$80
        STA     CONTRL
        BNE     .02
.01:
        LDA     CONTRL
        AND     #$7F
        STA     CONTRL
.02:
        LDA     SWCHB
        AND     #$03
        EOR     #$03
        BNE     .1
        LDA     CONTRL
        AND     #$DF
        STA     CONTRL
        JMP     .3
.1:
        TAX
        LDA     CONTRL
        AND     #$20
        BNE     .3
        LDA     CONTRL
        ORA     #$20
        STA     CONTRL
        CPX     #$01 
        BNE     .2
        JMP     UPLEVEL
.2:
        LDA     INTIM           ;WAIT FOR END OF TIMER
        BNE     .2
        LDA     #$FF
        STA     SKEY
        JMP     TITLE
.3:    
        JMP     LBANK
UPL:
        LDA     LEVEL
        BNE     .3   
        LDA     PLAY
        LSR
        TAX
        LDA     PLAYLEV,X       ;GET STARTING LEVEL NUMBER
        STA     LEVEL           ;SET FOR NEXT LEVEL STUFF
.0:
        LDA     #$FF
        STA     PLHOR
        STA     ROOM
        STA     OBSTAT          ;SETUP FOR PLAYER ERASE
        LDA     SWCHB           ;SET PAUSE STATUS
        AND     #$08
        BNE     .1
        LDA     #$22
        BNE     .2
.1:
        LDA     #$62
.2:
        STA     CONTRL
        JMP     LBANK
.3:
        DEC     LEVEL
        JMP     .0
LOGO5:  DC.B    $07,$1F,$3F,$7C,$78,$78,$F0,$F0
        DC.B    $E0,$E0,$E0,$E0,$E0,$E0,$E0,$E0
        DC.B    $E0,$F0,$F0,$78,$78,$7C,$3E,$1F
        DC.B    $2F,$33,$38,$38,$38,$38,$38,$38
        DC.B    $38,$38,$38
LOGO6:  DC.B    $80,$E0,$E4,$74,$34,$34,$04,$04
        DC.B    $04,$06,$07,$05,$04,$04,$04,$04
        DC.B    $04,$00,$00,$00,$30,$31,$71,$E1
        DC.B    $E1,$D0,$38,$39,$39,$1C,$1C,$1C
        DC.B    $0C,$0E,$0E
****
*
* BANK SWITCHING PORTION
*
****
        ORG     $FFE8
LBANK:
        LDA     $FFF8           ;JUMP TO BANK 2 (LOGIC BANK)
****
*
* ENTRY POINT TO BANK FROM BANK 0 (KERNAL PROGRAM)
*
****
        JMP     START           ;JUMP TO SCORE PROGRAM
****
*
* ENTRY POINT FOR OTHER BANKS TO COME IN
*
****
        ORG     $FFF0
TFIX:
        LDA     $FFF9
        JMP     SETUP           ;JUMP TO SETUP PROGRAM
****
*
* RESET VECTORS
*
****
        ORG     $FFF8
        DC.B    $00,$00
        DC.W    SETUP         
        DC.W    SETUP
        DC.W    SETUP
 



