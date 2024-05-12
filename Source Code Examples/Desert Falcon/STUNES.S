	.EJECT
;	STUNES.S	07/19/87
*         STUNES.S      by Kevin G. Osborn
*         ADAPTED FOR SPHINX --- A GAME OF SKILL AND CHANCE
*         Contains subroutines
*                 TUNER
*                 SCRAPALL
*                 SCRAPONE
*                 TUNIN

* SIMPSONG VERSION 0.035
*
* THIS SIMPLE SOUND DRIVER HAS, IN SOME WAYS, FEWER FEATURES BUT USES LESS RAM
* AND ROM AND DOES NOT BACK UP SOUNDS FOR LATER (SOMETIMES MUCH LATER)
* CONTINUATION. IT FEATURES 256 NOTE TUNES, SINGLE DURATION PER TUNE, ENDLESS
* TUNES. IF A VALUE IN THE CONTROL OR VOLUME TABLES HAS THE HIGH BIT SET, THAT
* VOLUME OR CONTROL WILL REMAIN IN EFFECT TILL THE END OF THE TUNE.
* AN FF IN THE FREQUENCY TABLE WILL TERMINATE THE TUNE, AN FE WILL CAUSE IT TO
* RESTART.  AN FD WILL DECREMENT TUNREPT.  IF THIS IS NON-ZERO, THE TUNE
* CONTINUES.  IF IT IS ZERO, THE NEXT BYTE IN FREQ. TABLE IS S TUNE WHICH
* SHOULD BE CALLED.  TUNREPT IS SET IN TUNIN.
*
* AS A NEW WHIZZY FEATURE, TUNER ALSO SUPPORTS RESTS. IF BIT 6 IS SET (NOT BIT 7
* ALSO) IN A FREQUENCY TABLE ENTRY, IT SILENCES SOUND IN THAT CHANNEL FOR THE
* NUMBER OF FRAMES INDICATED IN THE REMAINING 5 BITS.
*
* NOTE ALSO THAT IN THIS VERSION A DURATION OF 1 INDICATES CHANGING SOUND EVERY
* FRAME. THIS IS A CHANGE OVER VERSION .03 WHERE 0 INDICATED ONCE PER FRAME
* SAMPLING.
* SUBROUTINES:
*     SCRAPALL -- KILL ALL TUNES. SHOULD BE CALLED AT POWERUP, CHANGING PLAYERS,
*                AND GAME OVER
*
*     SCRAPONE -- KILL A PARTICULAR TUNE. PUT THE NUMBER OF THE TUNE YA WANNA
*                 AXE IN THE ACCUMULATOR.
*
*     TUNIN   --  START THAT TUNE YOU PUT IN ACC.
*
* THE ABOVE ROUTINES PRESERVE THE X AND Y REGS
*
	.EJECT
* TABLES NEEDED ARE:
* RAM:
;
MPTRL     =     WORK0                 ;ZERO PAGE TEMP(NOT GAMEPLAY)
MPTRH     =     WORK1                 ;ZERO PAGE TEMP(NOT GAMEPLAY)
TUNTEMP   =     WORK                  ;ANY GAMEPLAY TEMP
* ROM:
*   DURTABL       ONE DURATION IN FRAMES PER TUNE
*   TBASE         LOW ADDRESS OF THE START OF FREQ DATA BY TUNE NUMBER
*   TBASEH        DITTO FOR HIGH ADDRESS
*   VBASE         LOW ADDRESS OF THE START OF VOL DATA BY TUNE NUMBER
*   VBASEH        DITTO FOR HIGH ADDRESS
*   CBASE         LOW ADDRESS OF THE START OF CTRL DATA BY TUNE NUMBER
*   CBASEH        DITTO FOR HIGH ADDRESS
*   PRYOR         PRIORITY BY TUNE NUMBERS  --  ZERO THE LOWEST
*   VOLTABL       VOLUMES
*   FREQTABL      FREQUENCIES
*   CTLTABL       CONTROLS
	.EJECT
* SCRAPALL
*         KILL ALL TUNES. SHOULD BE CALLED AT POWERUP, CHANGING PLAYERS,
*                AND GAME OVER
*         USES A , DOESN'T USE X OR Y
          ;IF WE CAN USE X HERE, THEN WE CAN SAVE A BYTE
SCRAPALL:
          LDA     #0
          STA     AUDV0                  ;CLEAR SOUND REGISTERS
          STA     AUDV1
          LDA     #$FF
          STA     TUNNUM                 ;FLAG NO TUNES, BOTH CHANNELS
          STA     TUNNUM1
          RTS

; IF YOU WANT, LOOP THIS UP

* SCRAPONE
*         KILL A PARTICULAR TUNE. PUT THE NUMBER OF THE TUNE YA WANNA
*                 AXE IN THE ACCUMULATOR.
          ;CAN WE USE X OR Y HERE??

SCRAPONE: CMP     TUNNUM                 ;ON CHAN 0?
          BNE     CKCH1
          LDA     #0
          STA     AUDV0                  ;CLEAR REGISTER
          LDA     #$FF
          STA     TUNNUM                 ;FLAG NO TUNE, CHANNEL 0
          RTS
CKCH1:    SEC
          SBC     TUNNUM1                ;ON CHAN 1?
          BNE     REETS                  ;IF NON ZERO, RETURN
          STA     AUDV1                  ;CLEAR REGISTER
          LDA     #$FF
          STA     TUNNUM1                ;FLAG NO TUNE, CHAN 1
REETS:    RTS

	.EJECT
* TUNIN
*         START THAT TUNE YOU PUT IN ACC.
TUNIN:
	STA     TUNTEMP
          LDY     #1
TROIKA:   LDA     TUNNUM,Y               ;FIRST CHECK FOR AN EMPTY CHANNEL
          CMP     #$FF
          BEQ     DO
TRKNX:    DEY
          BPL     TROIKA

          LDA     TUNNUM1                ;THIS IS DONE TO PREVENT GLITCHINESS
          AND     #$7F
          TAY
          LDA     TUNNUM
          AND     #$7F
          TAX
          LDA     PRYOR,Y
          LDY     #1
          CMP     PRYOR,X
          BCC     REPTUN1
          LDY     #0
REPTUN1:
          LDA     TUNNUM,Y
          AND     #$7F
          TAX
          LDA     PRYOR,X
          LDX     TUNTEMP
          CMP     PRYOR,X
          BCS     ROOTS

DO:       LDX     TUNTEMP
          TXA                            ;PLAY TUNE X ON CHANNEL Y
          ORA     #$80                   ;SET HIGH BIT
          STA     TUNNUM,Y

          LDA     #BACKGR0               ;PUNT BOTH CHANNELS OF BACKGROUND
          JSR     SCRAPONE
          LDA     #BACKGR1
          JSR     SCRAPONE

ROOTS:
OUTTNN:
REETS2:
	   RTS

	.EJECT
*TUNER SHOULD BE CALLED ONCE PER FRAME, NO INPUTS, AND IT OPERATES WITH
*A TOTAL DISREGARD FOR REGISTER SANCTITY. EACH TUNE CAN BE 256 NOTES LONG
*IF YOUR TUNES ARE VERY SMALL, YOU COULD DO AWAY WITH ALL THE INDIRECT STUFF
;
TUNER:
* PLAY CHANNELS 0 AND 1 *
NOREETS:
	LDA	TUNNUM
	CMP	#$FF
	BNE	NOREET
	CMP	TUNNUM+1
	BEQ	REETS2
NOREET: 
	 LDX     #1
TUNLOP:
	   LDY     TUNNUM,X
          INY
          BNE     NETN                   ;TUNNUM=FF DO NEXT CHANNEL
JNXTCH:   JMP     NXTCH
NETN:     DEY
          BPL     BOOGIE

* INITIALIZE A NEW TUNE (HIGH BIT ON Y IS SET) *
          TYA
          AND     #$7F
          STA     TUNNUM,X
          TAY
	LDA	#1
	STA	DCH0,X
          LDA     #$FF                   ; INCREMENTS ON THE FIRST CALL
          STA     TINDEX0,X              ;AND INDEXES WILL BE ZEROED.
          STA     CINDEX0,X
          STA     VINDEX0,X
          LDA     #0
          STA     VRUN,X

BOOGIE:   LDA     TBASE,Y
          STA     MPTRL
          LDA     TBASEH,Y
          STA     MPTRH                  ;MPTR = FREQUENCY BASE ADDRESS
;
	  DEC	DCH0,X
          BNE     JNXTCH
;
	  LDA	DURTABL,Y
	  STA	DCH0,X
	  LDY     TINDEX0,X              ;FREQUENCY INDEX (OFF OF BASE)
          INC     CINDEX0,X
          INC     VINDEX0,X
          INY
          LDA     (MPTRL),Y              ;FETCH FREQUENCY

          CMP     #$FF                   ;IS IT OVER?
          BNE     CKENL
          STA     TUNNUM,X               ;END THIS FUNKY TUNE
          LDA     #0
          STA     AUDV0,X
          BEQ     JNXTCH                 ;JMP NEXT CHANNEL
SKIPTWO:
          INY
          JMP     PSTFREQ                ;Y BETTER NOT BE ZERO HERE

CKENL:    CMP     #$FE                   ;CODE FOR PLAYING TUNE AGAIN
          BEQ     FOOBEQ
	  BNE	SKIP
* CODE $FE --> PLAY THE TUNE AGAIN *
FOOBEQ:   LDY     #0
          TYA
          STA     CINDEX0,X              ;RESET CONTROL, VOLUME INDEXES
          STA     VINDEX0,X
          STA     VRUN,X
;
PSTFREQ:
	LDA	(MPTRL),Y
;
SKIP:     ASL     
          BPL     STIT                   ;STORE FREQ IF BIT 6 CLEAR
          LSR     
          AND     #$BF                   ;RESET BIT 6
	STA	DCH0,X
          TYA                            ;A DURATION OF SILENCE
          STA     TINDEX0,X
          DEC     VINDEX0,X
          DEC     CINDEX0,X              ;HOLD CONTROL AND VOLUME INDEXES

          LDA     #0                     ;SILENCE
          STA     AUDV0,X
          BEQ     NXTCH                  ;JMP NEXT CHANNEL

* STORE OUT THE FREQUENCY *
STIT :    LSR     
STIT0 :   STA     AUDF0,X                ;STORE AUDIO FREQUENCY
          TYA
          STA     TINDEX0,X              ;TINDEX = Y

* LOOK UP VOLUME *
          DEC     VRUN,X
          BPL     CTRLOAD

          LDY     TUNNUM,X
          LDA     VBASE,Y
          STA     MPTRL
          LDA     VBASEH,Y
          STA     MPTRH                  ;MPTR = VOLUME BASE
          LDY     VINDEX0,X              ;Y = VINDEX
;
          LDA     (MPTRL),Y
          TAY
          AND     #$0F
;
          STA     AUDV0,X                ;STORE AUDIO VOLUME
          TYA
          BMI     CTRLOAD                ;HIGH BIT SET

          LSR     
          LSR     
          LSR     
          LSR     
          STA     VRUN,X
          INC     VINDEX0,X

* LOOK UP CONTROL *
CTRLOAD:
          DEC     VINDEX0,X
          LDY     TUNNUM,X
          LDA     CBASE,Y
          STA     MPTRL
          LDA     CBASEH,Y
          STA     MPTRH
          LDY     CINDEX0,X              ;Y = CINDEX
          LDA     (MPTRL),Y
          BPL     STCTRL
          DEY                            ;REPEAT FOREVER
          AND     #$7F
STCTRL:   STA     AUDC0,X                ;STORE AUDIO CONTROL
          TYA
          STA     CINDEX0,X              ;CINDEX = Y

NXTCH:    DEX                            ;X = 0 (NEXT CHANNEL)
          BMI     ROTS
          JMP     TUNLOP                 ;DO CHANNEL 0
ROTS:     RTS

RUNBACK:
* PLAY CHANNELS 0 AND 1 *
NORTSBK:  LDX     #1

BAKLOP:
	  LDY     BACKNUM,X
          LDA     TBASE,Y
          STA     MPTRL
          LDA     TBASEH,Y
          STA     MPTRH                  ;MPTR = FREQUENCY BASE ADDRESS
;
	DEC	DCH0,X
          BNE     JNEXBK
	LDA	DURTABL,Y
	STA	DCH0,X
          LDY     TINDEX0,X              ;FREQUENCY INDEX (OFF OF BASE)
          INC     CINDEX0,X
          INC     VINDEX0,X
          INY
          LDA     (MPTRL),Y              ;FETCH FREQUENCY

          CMP     #$FE                   ;CODE FOR PLAYING TUNE AGAIN
          BNE     STITBK

* CODE $FE --> PLAY THE TUNE AGAIN *
REPEATER: LDY     #0
          TYA
          STA     CINDEX0,X              ;RESET CONTROL, VOLUME INDEXES
          STA     VINDEX0,X
          STA     VRUN,X
PLOKRST:  LDA     (MPTRL),Y

; LOOKRST   BPL     SKIPBK                 ;IF BIT 7 CLR, DO A REST

SKIPBK:   ASL     
          BPL     STITBK                 ;STORE FREQ IF BIT 6 CLEAR
          LSR     
	AND	#$BF
          TYA                            ;A DURATION OF SILENCE
          STA     TINDEX0,X
          DEC     VINDEX0,X
          DEC     CINDEX0,X              ;HOLD CONTROL AND VOLUME INDEXES
JNEXBK:   JMP     NEXBK

* STORE OUT THE FREQUENCY *
STITBK:
          TYA
          STA     TINDEX0,X              ;TINDEX = Y

* LOOK UP VOLUME *
          DEC     VRUN,X
          BPL     CBLOAD
          LDY     BACKNUM,X
          LDA     VBASE,Y
          STA     MPTRL
          LDA     VBASEH,Y
          STA     MPTRH                  ;MPTR = VOLUME BASE
          LDY     VINDEX0,X              ;Y = VINDEX
          LDA     (MPTRL),Y
          BMI     CBLOAD                 ;HIGH BIT SET
;
          LSR     
          LSR     
          LSR     
          LSR     
          STA     VRUN,X
          INC     VINDEX0,X

* LOOK UP CONTROL *
CBLOAD:
          DEC     VINDEX0,X
          LDY     BACKNUM,X
          LDA     CBASE,Y
          STA     MPTRL
          LDA     CBASEH,Y
          STA     MPTRH
          LDY     CINDEX0,X              ;Y = CINDEX
          LDA     (MPTRL),Y
          BPL     STCBX
          DEY                            ;REPEAT FOREVER
STCBX:
          TYA
          STA     CINDEX0,X              ;CINDEX = Y

NEXBK:    DEX                            ;X = 0 (NEXT CHANNEL)
          BMI     ROTSBK
          JMP     BAKLOP                 ;DO CHANNEL 0
ROTSBK:   RTS
;
	.EJECT
;
BRDSHOT   =     0                      ;TUNE NUMBERS
RICCHET   =     1
UWERUN    =     2
ALADIN0   =     3
ALADIN1   =     4
UWEEXP    =     5
SCBEXPL   =     6
GLDEXPL   =     7
SWIM      =     8
ENDGAM0   =     9
ENDGAM1   =     10
MINISHOT  =     11
VHDEATH   =     12
CUCKOO1   =     13
CUCKOO2   =     14
NHIERO1   =     15
NHIERO2   =     16
NHIERO3   =     17
HMISS3    =     18
SPTUNE    =     19                     ;SPAWN
RUNNING   =     20
JWTUNE    =     21                     ;JEWEL
SFINKS    =     22
XLPOWER   =     23
POWRUSE   =     24
SPHXBM0   =     25
SPHXBM1   =     26
MINIBM    =     27
HISCOR0   =     28
HISCOR1   =     29
LOSCOR0   =     30
LOSCOR1   =     31
HISEND0   =     32
HISEND1   =     33
LOSEND0   =     34
LOSEND1   =     35
BACKGR0   =     36
BACKGR1   =     37
FLASHT0   =     38
FLASHT1   =     39

BACKNUM:  DC.B      BACKGR0,BACKGR1
*         pointer tables.
TBASE:
	  DC.B      F00&$FF,F01&$FF,F02&$FF,F03&$FF,F04&$FF
          DC.B      F05&$FF,F06&$FF,F07&$FF
          DC.B      F08&$FF,F09&$FF,F10&$FF
          DC.B      F11&$FF
          DC.B      F12&$FF,F13&$FF,F14&$FF
          DC.B      F15&$FF,F16&$FF,F17&$FF,F18&$FF
          DC.B      F19&$FF,F20&$FF
          DC.B      F21&$FF,F22&$FF,F23&$FF
          DC.B      F24&$FF,F25&$FF,F26&$FF,F27&$FF
          DC.B      F28&$FF,F29&$FF,F30&$FF,F31&$FF
          DC.B      F32&$FF,F33&$FF,F34&$FF,F35&$FF
          DC.B      F36&$FF,F37&$FF,F38&$FF,F39&$FF
TBASEH:
	  DC.B      F00&$FF00/256,F01&$FF00/256,F02&$FF00/256,F03&$FF00/256
	  DC.B	    F04&$FF00/256
          DC.B      F05&$FF00/256,F06&$FF00/256,F07&$FF00/256
          DC.B      F08&$FF00/256,F09&$FF00/256,F10&$FF00/256
          DC.B      F11&$FF00/256
          DC.B      F12&$FF00/256,F13&$FF00/256,F14&$FF00/256
          DC.B      F15&$FF00/256,F16&$FF00/256,F17&$FF00/256,F18&$FF00/256
          DC.B      F19&$FF00/256,F20&$FF00/256
          DC.B      F21&$FF00/256,F22&$FF00/256,F23&$FF00/256
          DC.B      F24&$FF00/256,F25&$FF00/256,F26&$FF00/256,F27&$FF00/256
          DC.B      F28&$FF00/256,F29&$FF00/256,F30&$FF00/256,F31&$FF00/256
          DC.B      F32&$FF00/256,F33&$FF00/256,F34&$FF00/256,F35&$FF00/256
          DC.B      F36&$FF00/256,F37&$FF00/256,F38&$FF00/256,F39&$FF00/256
;
VBASE  :
	  DC.B      V00&$FF,V01&$FF,V02&$FF,V03&$FF,V04&$FF
          DC.B      V05&$FF,V06&$FF,V07&$FF
          DC.B      V08&$FF,V09&$FF,V10&$FF
          DC.B      V11&$FF
          DC.B      V12&$FF,V13&$FF,V14&$FF
          DC.B      V15&$FF,V16&$FF,V17&$FF,V18&$FF
          DC.B      V19&$FF,V20&$FF
          DC.B      V21&$FF,V22&$FF,V23&$FF
          DC.B      V24&$FF,V25&$FF,V26&$FF,V27&$FF
          DC.B      V28&$FF,V29&$FF,V30&$FF,V31&$FF
          DC.B      V32&$FF,V33&$FF,V34&$FF,V35&$FF
          DC.B      V36&$FF,V37&$FF,V38&$FF,V39&$FF

VBASEH  :
	  DC.B      V00&$FF00/256,V01&$FF00/256,V02&$FF00/256,V03&$FF00/256
	  DC.B	    V04&$FF00/256
          DC.B      V05&$FF00/256,V06&$FF00/256,V07&$FF00/256
          DC.B      V08&$FF00/256,V09&$FF00/256,V10&$FF00/256
          DC.B      V11&$FF00/256
          DC.B      V12&$FF00/256,V13&$FF00/256,V14&$FF00/256
          DC.B      V15&$FF00/256,V16&$FF00/256,V17&$FF00/256,V18&$FF00/256
          DC.B      V19&$FF00/256,V20&$FF00/256
          DC.B      V21&$FF00/256,V22&$FF00/256,V23&$FF00/256
          DC.B      V24&$FF00/256,V25&$FF00/256,V26&$FF00/256,V27&$FF00/256
          DC.B      V28&$FF00/256,V29&$FF00/256,V30&$FF00/256,V31&$FF00/256
          DC.B      V32&$FF00/256,V33&$FF00/256,V34&$FF00/256,V35&$FF00/256
          DC.B      V36&$FF00/256,V37&$FF00/256,V38&$FF00/256,V39&$FF00/256

CBASE:
	  DC.B      C00&$FF,C01&$FF,C02&$FF,C03&$FF,C04&$FF
          DC.B      C05&$FF,C06&$FF,C07&$FF
          DC.B      C08&$FF,C09&$FF,C10&$FF
          DC.B      C11&$FF
          DC.B      C12&$FF,C13&$FF,C14&$FF
          DC.B      C15&$FF,C16&$FF,C17&$FF,C18&$FF
          DC.B      C19&$FF,C20&$FF
          DC.B      C21&$FF,C22&$FF,C23&$FF
          DC.B      C24&$FF,C25&$FF,C26&$FF,C27&$FF
          DC.B      C28&$FF,C29&$FF,C30&$FF,C31&$FF
          DC.B      C32&$FF,C33&$FF,C34&$FF,C35&$FF
          DC.B      C36&$FF,C37&$FF,C38&$FF,C39&$FF

CBASEH:
	  DC.B      C00&$FF00/256,C01&$FF00/256,C02&$FF00/256,C03&$FF00/256
	  DC.B	    C04&$FF00/256
          DC.B      C05&$FF00/256,C06&$FF00/256,C07&$FF00/256
          DC.B      C08&$FF00/256,C09&$FF00/256,C10&$FF00/256
          DC.B      C11&$FF00/256
          DC.B      C12&$FF00/256,C13&$FF00/256,C14&$FF00/256
          DC.B      C15&$FF00/256,C16&$FF00/256,C17&$FF00/256,C18&$FF00/256
          DC.B      C19&$FF00/256,C20&$FF00/256
          DC.B      C21&$FF00/256,C22&$FF00/256,C23&$FF00/256
          DC.B      C24&$FF00/256,C25&$FF00/256,C26&$FF00/256,C27&$FF00/256
          DC.B      C28&$FF00/256,C29&$FF00/256,C30&$FF00/256,C31&$FF00/256
          DC.B      C32&$FF00/256,C33&$FF00/256,C34&$FF00/256,C35&$FF00/256
          DC.B      C36&$FF00/256,C37&$FF00/256,C38&$FF00/256,C39&$FF00/256
;
DURTABL:  DC.B      $01                    ;BRDSHOT
          DC.B      $01                    ;RICCHET
          DC.B      $02                    ;UWERUN
          DC.B      $04                    ;ALADIN0
          DC.B      $04                    ;ALADIN1
          DC.B      $01                    ;UWEEXP
          DC.B      $01                    ;SCBEXPL
          DC.B      $01                    ;GLDEXPL
          DC.B      $03                    ;SWIM
          DC.B      $04                    ;ENDGAM0
          DC.B      $04                    ;ENDGAM1
          DC.B      $02                    ;MINISHOT
          DC.B      $02                    ;VHDEATH
          DC.B      $01                    ;CUCKOO1
          DC.B      $01                    ;CUCKOO2
          DC.B      $05                    ;NHIERO1
          DC.B      $05                    ;NHIERO2
          DC.B      $05                    ;NHIERO3
          DC.B      $02                    ;HMISS3
          DC.B      $02                    ;SPAWN
          DC.B      $03                    ;RUNNING
          DC.B      $02                    ;JEWEL
          DC.B      $02                    ;SFINKS
          DC.B      $03                    ;XLPOWER
          DC.B      $04                    ;POWRUSE
          DC.B      $02                    ;SPHXBM0
          DC.B      $02                    ;SPHXBM1
          DC.B      $03                    ;MINIBM
          DC.B      $08                    ;HISCOR0
          DC.B      $08                    ;HISCOR1
          DC.B      $08                    ;LOSCOR0
          DC.B      $08                    ;LOSCOR1
          DC.B      $08                    ;HISEND0
          DC.B      $08                    ;HISEND1
          DC.B      $08                    ;LOSEND0
          DC.B      $08                    ;LOSEND1
          DC.B      $02                    ;BACKGR0
          DC.B      $02                    ;BACKGR1
          DC.B      $06                    ;FLASHT0
          DC.B      $06                    ;FLASHT1

PRYOR:    DC.B      $01                    ;BRDSHOT        OR THESE EVEN??
          DC.B      $02                    ;RICCHET
          DC.B      $02                    ;UWERUN
          DC.B      $05                    ;ALADIN0
          DC.B      $05                    ;ALADIN1
          DC.B      $03                    ;UWEEXP
          DC.B      $03                    ;SCBEXPL
          DC.B      $03                    ;GLDEXPL
          DC.B      $03                    ;SWIM
          DC.B      $09                    ;ENDGAM0
          DC.B      $09                    ;ENDGAM1
          DC.B      $04                    ;ANY MINISPHINX OR SPHINX SHOT
          DC.B      $06                    ;VHDEATH
          DC.B      $07                    ;CUCKOO1
          DC.B      $07                    ;CUCKOO2
          DC.B      $04                    ;NHIERO1
          DC.B      $04                    ;NHIERO2
          DC.B      $04                    ;NHIERO3
          DC.B      $04                    ;HMISS3
          DC.B      $03                    ;SPAWN
          DC.B      $02                    ;RUNNING
          DC.B      $04                    ;JEWEL
          DC.B      $03                    ;SFINKS
          DC.B      $04                    ;XLPOWER
          DC.B      $04                    ;POWRUSE
          DC.B      $05                    ;SPHXBM0
          DC.B      $05                    ;SPHXBM1
          DC.B      $04                    ;MINIBM
          DC.B      $0A                    ;HISCOR0
          DC.B      $0B                    ;HISCOR1
          DC.B      $0A                    ;LOSCOR0
          DC.B      $0B                    ;LOSCOR1
          DC.B      $0C                    ;HISEND0
          DC.B      $0D                    ;HISEND1
          DC.B      $0C                    ;LOSEND0
          DC.B      $0D                    ;LOSEND1
          DC.B      $00                    ;BACKGR0
          DC.B      $00                    ;BACKGR1
          DC.B      $08                    ;FLASHT0
          DC.B      $08                    ;FLASHT1

* FREQTABL
;RICHEFF
F01: DC.B      $44,$07,$07,$03,$06,$03,$06,$03,$06,$FF

;BRDSHOTF
F00: DC.B      $00,$01,$02,$03,$04,$05,$07,$09,$0B,$0D,$0F,$12,$14,$16
          DC.B      $18,$1C,$1B,$1A,$1C,$1B,$1A,$1C,$FF

;ALADIN0F
F03: DC.B      $1F,$1F,$48,$14,$44,$14,$44
          DC.B      $15,$15,$48,$14,$14,$48

          DC.B      $14,$14,$48,$13,$13,$48
          DC.B      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

          DC.B      $1F,$1F,$48,$14,$14,$15,$15
          DC.B      $14,$14,$15,$15,$14,$14,$15,$15

          DC.B      $14,$14,$48,$13,$13,$48
          DC.B      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

          DC.B      $1F,$1F,$48,$14,$44,$14,$44
          DC.B      $15,$15,$48,$14,$14,$48

          DC.B      $14,$14,$48,$13,$13,$48
          DC.B      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

          DC.B      $1F,$1F,$48,$14,$14,$15,$15
          DC.B      $14,$14,$15,$15,$14,$14,$15,$15

          DC.B      $14,$14,$48,$13,$13,$48
          DC.B      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

          DC.B      $1F,$1F,$48,$14,$44,$14,$44
          DC.B      $15,$15,$48,$14,$14,$48

          DC.B      $14,$14,$48,$13,$13,$48
          DC.B      $1D,$1D,$1D,$1D,$1D,$1D,$1D,$1D

          DC.B      $1F,$1F,$48,$14,$14,$15,$15
          DC.B      $14,$14,$15,$15,$14,$14,$15,$15

          DC.B      $1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F
          DC.B      $FF

;ALADIN1F
F04: DC.B      $5F                    ;31
          DC.B      $5F                    ;62

          DC.B      $5F                    ;93
          DC.B      $5F                    ;124

          DC.B      $5F                    ;155
          DC.B      $5F                    ;186

          DC.B      $5F                    ;217
          DC.B      $5F,$48                ;248+8=256 FRAMES OF SILENCE

          DC.B      $13,$13,$12,$12,$0F,$0F,$0E,$0E
          DC.B      $0C,$0C,$48,$0F,$0F,$0E,$0E

          DC.B      $0C,$0C,$48,$0F,$0F,$0E,$0E
          DC.B      $0C,$0C,$0B,$0B,$0C,$0C,$0E,$0E

          DC.B      $0F,$0F,$48,$13,$13,$14,$14
          DC.B      $13,$13,$12,$12,$0F,$0F,$0E,$0E

          DC.B      $0F,$0F,$0F,$0F,$0F,$0F,$0F,$0F
          DC.B      $0F,$0F,$0F,$0F,$12,$12,$12,$12

          DC.B      $13,$13,$48,$13,$13,$14,$14
          DC.B      $18,$18,$18,$18,$14,$14,$14,$14

          DC.B      $13,$13,$14,$14,$13,$13,$12,$12
          DC.B      $0F,$0F,$0F,$0F,$0F,$0F,$0E,$0E

          DC.B      $0F,$0F,$48,$0C,$0C,$0E,$0E
          DC.B      $0F,$0F,$12,$12,$13,$13,$16,$16

          DC.B      $13,$13,$13,$13,$13,$13,$13,$13
          DC.B      $FF


;UWEEXPF
F05:  DC.B      $16,$15,$14,$13,$12,$11,$41,$0F
          DC.B      $00,$0C,$01,$00,$0C,$00,$FF

;GLDEXPLF
F07: DC.B      $17,$17,$06,$06,$05,$04,$04,$04,$FF


;ENDGAM0F
F09: DC.B      $1F,$1F,$48,$14,$44,$14,$44,$15,$15,$48,$14,$14
          DC.B      $48,$14,$14,$48,$13,$13,$48,$1D,$1D,$1D,$1D
          DC.B      $1D,$1D,$1D,$1D,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$1F,$FF

;ENDGAM1F
F10: DC.B      $13,$13,$12,$12,$0F,$0F,$0E,$0E,$0C,$0C,$48,$0F,$0F
          DC.B      $0E,$0E,$0C,$0C,$48,$0F,$0F,$0E,$0E,$0C,$0C,$0B,$0B
          DC.B      $0C,$0C,$0E,$0E,$09,$09,$09,$09,$09,$09,$09,$09,$FF

;MINISHTF
F11: DC.B      $03,$00,$07,$07,$05,$1F,$1F,$1F,$FF


;VHDEATHF
F12: DC.B      $19,$1A,$1B,$1C,$1D,$1E,$1F,$1A
          DC.B      $04,$05,$06
          DC.B      $07,$08,$09,$0A,$0B,$0C,$0D,$0E
          DC.B      $0F,$10,$11,$12,$13,$14,$15,$16
          DC.B      $17,$18,$19,$1A,$1B,$1C,$1D,$1E,$FF

;CUCKOO1F
F13: DC.B      $1E,$1D,$1F,$1A,$1E,$1C,$1F,$1A
          DC.B      $0C,$0C,$0C,$06,$05,$06,$0F,$0F
          DC.B      $0F,$0F,$0F,$0F,$03,$06,$04,$03
          DC.B      $06,$04,$0C,$0C,$0C,$03,$05,$04
          DC.B      $0F,$0F,$0F,$0F,$0F,$0F,$03,$04
          DC.B      $06,$04,$06,$04,$0C,$0C,$0C,$03
          DC.B      $06,$05,$0F,$0F,$0F,$0F,$0F,$0F,$FF

;CUCKOO2F
F14: DC.B      $00,$00,$00,$00,$00,$00,$00,$00
          DC.B      $03,$04,$05,$03,$04,$05,$03,$04
          DC.B      $05,$03,$04,$05,$03,$04,$05,$03
          DC.B      $04,$05,$03,$04,$05,$03,$04,$05
          DC.B      $03,$04,$05,$03,$04,$05,$03,$04
          DC.B      $05,$03,$04,$05,$03,$04,$05,$03
          DC.B      $04,$05,$03,$04,$05,$03,$04,$05,$FF

;NHIERO1F
F15: DC.B      $17,$16,$12,$11,$0F,$FF

;NHIERO2F
F16: DC.B      $45,$12,$11,$0F,$45,$12,$FF

;NHIERO3F
F17: DC.B      $11,$0F,$0E,$0F,$45,$0B,$0B,$0B,$FF

;HMISS3F
F18:  DC.B      $45,$13,$15,$17,$18,$19,$1A,$1C,$15
          DC.B      $1F,$1D,$1F,$1D,$1F,$1D,$1F,$1D,$FF

;SPAWNF
F19:   DC.B      $17,$17,$18,$18,$19,$19,$FF

;RUNNINGF
F20: DC.B      $1F,$1F,$1F,$49,$14,$12,$10,$0F,$FE     ;REPEATS

;JEWELF
F21:   DC.B      $8,$7,$6,$5,$4,$3,$4,$4
          DC.B      $4,$4,$4,$4,$4,$4,$4,$4
          DC.B      $4,$4,$4,$4,$4,$4,$4,$4,$4,$4,$FF

;SFINKSF
F22:  DC.B      $5,$4,$3,$2,$1,$8,$7,$6
          DC.B      $5,$4,$3,$3,$4,$3,$2,$FE      ;REPEATS

;XLPOWERF
F23: DC.B      $13,$43,$11,$43,$E,$43,$9,$9,$9,$9,$FF

;UWERUNF
F02:  DC.B      9,$42,8,$42,4,$42,8,$42
          DC.B      7,$42,4,$42,6,$42,5,$42,6,$FF
;SWIMF
F08:    DC.B      $8,$F,$8,$F,$8,$F,$8,$F
          DC.B      $8,$F,$8,$F,$8,$F,$8,$F,$FE        ;REPEATS
;SCBEXPLF
F06: DC.B      $06,$07,$0C,$10,$12,$15,$15,$00
          DC.B      $14,$18,$14,$12,$0E,$08,$07,$00,$FF

;SPHXBM0F
F25: DC.B      $08,$08,$03,$03,$04,$04,$06,$06
          DC.B      $08,$08,$03,$03,$04,$04,$06,$06
          DC.B      $08,$08,$03,$03,$04,$04,$06,$06
          DC.B      $08,$08,$03,$03,$04,$04,$06,$06,$FF

;SPHXBM1F
F26: DC.B      $0A,$0A,$0A,$0A,$0B,$0B,$0C,$0C
          DC.B      $0D,$0D,$0A,$0E,$0F,$0F,$10,$10
          DC.B      $11,$11,$12,$12,$13,$0C,$14,$14
          DC.B      $15,$0A,$16,$16,$17,$09,$18,$18,$FF

;MINIBMF
F27:  DC.B      $12,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$FF

;POWRUSEF
F24: DC.B      $07,$0B,$08,$0B,$07,$0B,$08,$0B,$07,$0B,$FF

;HISCOR0F
F28:

;HISEND0F
F32:
; DC.B      $0D,$11,$11,$11,$11,$FF

;HISCOR1F
F29:

;HISEND1F
F33:

;LOSCOR0F
F30:

;LOSEND0F
F34:

;LOSCOR1F
F31:

;LOSEND1F
F35:

BACKGR1F:
F37:
BACKGR0F:
F36: DC.B      $B,$B,$B,$B,$B,$B,$B,$B
          DC.B      $B,$B,$B,$B,$B,$B,$B,$B
          DC.B      $C,$C,$C,$C,$C,$C,$C,$C
          DC.B      $C,$C,$C,$C,$C,$C,$C,$C,$FE

FLASHT0F:
F38: DC.B      $0D,$0E,$10,$11,$0D,$0E,$12,$13
          DC.B      $0D,$0E,$10,$11,$0D,$0E,$12,$13,$FF

FLASHT1F:
F39: DC.B      $09,$08,$06,$13,$09,$08,$13,$05
          DC.B      $09,$08,$06,$13,$08,$08,$13,$05,$FF

* VOLTABL

RICCHETV:
V01:	 DC.B      $1F,$08,$07,$06,$05,$04,$02

BRDSHOTV:
V00: DC.B      $09,$18,$17,$16,$25,$24,$23,$22,$21


ALADIN0V:
V03: DC.B      $14,$04,$04
          DC.B      $14,$14

          DC.B      $14,$14
          DC.B      $75

          DC.B      $14,$34
          DC.B      $75

          DC.B      $14,$14
          DC.B      $75

          DC.B      $14,$04,$04
          DC.B      $14,$14

          DC.B      $14,$14
          DC.B      $75

          DC.B      $14,$34
          DC.B      $75

          DC.B      $14,$14
          DC.B      $75

          DC.B      $14,$04,$04
          DC.B      $14,$14

          DC.B      $14,$14
          DC.B      $75

          DC.B      $14,$34
          DC.B      $56

          DC.B      $32,$13,$12,$11

ALADIN1V:
V04:
          DC.B      $15,$16,$17,$18
          DC.B      $19,$17,$18

          DC.B      $19,$17,$18
          DC.B      $19,$1A,$19,$18

          DC.B      $17,$17,$16
          DC.B      $17,$18,$19,$1A

          DC.B      $B9,$3A

          DC.B      $1A,$19,$18
          DC.B      $37,$38

          DC.B      $19,$18,$19,$1A
          DC.B      $3B,$3C

          DC.B      $1C,$1D,$1C
          DC.B      $1B,$1A,$19,$18

          DC.B      $39,$08,$07,$06,$05


UWEEXPV:
V05:  DC.B      $04,$05,$06,$07,$08,$09,$0F
          DC.B      $0E,$0C,$09,$08,$06,$04

GLDEXPLV:
V07: DC.B      $18,$07,$06,$05,$04,$03,$02


ENDGAM0V:
V09: DC.B      $14,$04,$04,$14,$14
          DC.B      $14,$14,$75,$74

ENDGAM1V:
V10: DC.B      $15,$16,$17,$18,$19,$17,$18
          DC.B      $19,$17,$18,$19,$1A,$19
          DC.B      $18,$17,$06,$05,$04,$03,$02,$01

MINISHTV:
V11: DC.B      $0F,$07,$08,$06,$04,$03,$02,$01


VHDEATHV:
V12: DC.B      $18,$17,$16,$15
          DC.B      $E8
          DC.B      $37
          DC.B      $36,$35

CUCKOO1V:
V13: DC.B      $08,$07,$06,$05,$04,$05,$06,$07
          DC.B      $F5,$F5,$F5

CUCKOO2V:
V14: DC.B      $73,$F3,$F3,$F3

NHIERO1V:
V15: DC.B      $88

NHIERO2V:
V16: DC.B      $28,$8

NHIERO3V:
V17: DC.B      $38,$28

HMISS3V:
V18:  DC.B      $1A,$1B,$1C,$1D
          DC.B      $1E,$1D,$1C,$1B

SPAWNV: 
V19:  DC.B      $8A
RUNNINGV:
V20: DC.B      $23,$33

JEWELV: 
V21:  DC.B      $3,$14,$15,$6,$19
          DC.B      $7,$8,$9,$A,$19,$18
          DC.B      $17,$16,$15,$4,$3,$2,$1
SFINKSV:
V22:  DC.B      $47,$8,$19
          DC.B      $1A,$B,$1E,$C,$D
XLPOWERV:
V23: DC.B      $A,$A,$A,$1A,$9,$8

UWERUNV:
V02:  DC.B      3,6,5,4
          DC.B      3,3,3,3,6
SWIMV:
V08:    DC.B      2,3,4,5,4,3,$22
          DC.B      3,4,5,4,3,$22
SCBEXPLV:
V06: DC.B      $15,$16,$17,$18
          DC.B      $19,$18,$17,$16

SPHXBM0V:
V25: DC.B      $0D,$0E,$2F,$0E,$0D,$0C
          DC.B      $0B,$0A,$09,$08,$07,$06,$05,$04
          DC.B      $1A,$19,$18,$17
          DC.B      $16,$15,$14,$13

SPHXBM1V:
V26: DC.B      $7F
          DC.B      $7E
          DC.B      $7D
          DC.B      $1C,$19,$17,$15

MINIBMV:
V27:  DC.B      $1F,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05

POWRUSEV:
V24: DC.B      $08,$07,$06,$05,$04,$03,$02,$02,$01,$01

LOSCOR0V:
V30:
LOSEND0V:
V34:
HISCOR0V:
V28:
HISEND0V:
V32: DC.B      $88

HISCOR1V:
V29:
HISEND1V:
V33:

LOSCOR1V:
V31:
; DC.B      $08,$05,$02,$90,$F0,$08,$05,$02,$00
LOSEND1V:
V35:
; DC.B      $08,$05,$03,$02

BACKGR1V:
V37:
BACKGR0V:
V36: DC.B      6,6,4,2,1,$61,$31
          DC.B      6,6,4,2,1,$61,$31

FLASHT0V:
V38:
FLASHT1V:
V39: DC.B      $78,8,7,6,5,4,3,2,1

* CTLTABL


MINISHTC:
C11: DC.B      $83

RICCHETC:
C01: DC.B      $08,$08,$8F

ALADIN0C:
C03:
HMISS3C:
C18:
ENDGAM0C:
C09: DC.B      $81

HISEND0C:
C32:
HISCOR0C:
C28:
BACKGR0C:
C36:
BACKGR1C:
C37:
LOSCOR1C:
C31:
LOSEND1C:
C35:
HISEND1C:
C33:
HISCOR1C:
C29:
          DC.B      $8A

LOSEND0C:
C34:
LOSCOR0C:
C30:

FLASHT0C:
C38:
POWRUSEC:
C24:
ALADIN1C:
C04:
ENDGAM1C:
C10:
RUNNINGC:
C20: DC.B      $8D

BRDSHOTC:
C00:
UWEEXPC:
C05:
UWERUNC:
C02:
SWIMC:
C08:
MINIBMC:
C27:
GLDEXPLC:
C07: DC.B      $88

JEWELC:
C21:   DC.B      $08,$08,$08,$08,$08,$08,$84
XLPOWERC:
C23:
CUCKOO2C:
C14:
NHIERO1C:
C15:
NHIERO2C:
C16:
NHIERO3C:
C17: DC.B      $84


VHDEATHC:
C12: DC.B      $03,$07,$0F,$08,$08,$08,$08,$08
          DC.B      $84

CUCKOO1C:
C13: DC.B      $08,$08,$08,$08,$08,$08,$08,$08
          DC.B      $84



SPAWNC:
C19:   DC.B      $D,$1,$D,$1,$D,$1


SFINKSC:
C22:  DC.B      $8F

SCBEXPLC:
C06: DC.B      $D,$D,7,7,4,4,$F,$F
          DC.B      $84

SPHXBM0C:
C25: DC.B      $08,$03,$08,$03,$08,$03,$08,$08
          DC.B      $08,$03,$08,$03,$08,$03,$08,$08
          DC.B      $08,$03,$08,$03,$08,$03,$08,$08
          DC.B      $08,$03,$08,$03,$08,$03,$08,$08

SPHXBM1C:
C26: DC.B      $08,$08,$03,$08,$08,$03,$08,$08
          DC.B      $03,$08,$08,$03,$08,$08,$03,$08
          DC.B      $08,$03,$08,$04,$03,$08,$08,$03
          DC.B      $08,$08,$03,$08,$08,$03,$08,$08

FLASHT1C:
C39: DC.B      $0D,$0D,$0D,$04,$0D,$0D,$04,$0D
          DC.B      $0D,$0D,$0D,$04,$0D,$0D,$04,$0D

