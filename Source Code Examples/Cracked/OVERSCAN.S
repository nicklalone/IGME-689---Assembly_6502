;*******************************************************************************
;
;	CRACKED - Atari 2600 Version
;
;	(c) The Pixel Plant 1987
;
;
;*******************************************************************************


INTITLESCREEN	SET	0
INTREESCREEN	SET	1
INBONUSSCREEN	SET	2

INPIPESCREEN	SET	3
INSELECT	SET	4
INRANCHSCREEN	SET	5
INDEMOTREE	SET	6
INATTRACTSCREEN	SET	7
INENDOFGAME	SET	8
TREEINTRO	set	9
RANCHINTRO	set	10
PIPEINTRO	set	11
PIPEDEMO	set	12


;*****************************************************************
;
;
;	Inter Bank Address of Screen Kernels 
;
SCREENADD:
	.DC.W	SCORE	
	.DC.W	CRACKTREE
	.DC.W	SCORE

	.DC.W	CRACKPIPE	
	.DC.W	SCORE
	.DC.W	RANCHSCREEN	
	.DC.W	CRACKTREE

	.DC.W	SCORE
	.DC.W	SCORE
	.DC.W	SCORE
	.DC.W	SCORE
	.DC.W	SCORE
	.DC.W	CRACKPIPE	

OVERTAB:
	.dc.w	OINTITLESCREEN
	.dc.w	OINTREESCREEN
	.dc.w	OINBONUSSCREEN
	.dc.w	OINPIPESCREEN
	.dc.w	SCREEN_ERROR ; SELECT
	.dc.w	OINRANCHSCREEN
	.dc.w	OINTREESCREEN
	.dc.w	SCREEN_ERROR
	.dc.w	OINENDOFGAME
	.dc.w	OTREEINTRO
	.dc.w	ORANCHINTRO
	.dc.w	OPIPEINTRO
	.dc.w	OINPIPESCREEN

;*******************************************************************************
;
;
;	Master Sequence of Screens
;
;
;
;******************************************************************************

SEQ_OF_SCREENS:
TITLE_LOC:
	.dc.b		INTITLESCREEN
	.dc.b		INDEMOTREE
	.dc.b		INTITLESCREEN
	.dc.b		PIPEDEMO

MINGM:
	.dc.b		TREEINTRO
	.dc.b		INTREESCREEN
	.dc.b		INBONUSSCREEN
	.dc.b		PIPEINTRO
	.dc.b		INPIPESCREEN
	.dc.b		INBONUSSCREEN
	.dc.b		TREEINTRO
	.dc.b		INTREESCREEN
	.dc.b		INBONUSSCREEN
	.dc.b		PIPEINTRO
	.dc.b		INPIPESCREEN
	.dc.b		INBONUSSCREEN
	.dc.b		RANCHINTRO
	.dc.b		INRANCHSCREEN
MG:
EG:	.dc.b		INENDOFGAME



MAX_GAME	set 	MG-SEQ_OF_SCREENS
ENDSTATE	set	EG-SEQ_OF_SCREENS
MIN_GAME	set	MINGM-SEQ_OF_SCREENS
START_TITLE	set	0


TREECTAB:
		.dc.b	$04
		.dc.b	$06
		.dc.b	$08
		.dc.b	$0c

;*******************************************************************************
;
;
;	Master Sequencer
;
;*******************************************************************************

NEXT_STATE:
NXTST:
	ldy	R_STATE			; current state
	lda	SEQ_OF_SCREENS,y	; get new screen
	sta	W_SCREEN		; make current
	INY
	CPY	#MAX_GAME
	BNE	.ns1
	ldy	#MIN_GAME
.ns1:	sty	W_STATE
GO_NEXT:
	STAI	0,ENDROUND
	jsr	NEXT_SCREEN		; setup next screen 
	JMP	OVREND			; enough for this overscan



;************************************************************************
;
;
;	start of overscan
;
;
;*************************************************************************

OVRSCN:
OVERSCAN:
	WSYNC
;	HMCLR
	STAI	OVRTIM,TIM64T	;START UP OVERSCAN TIME
	VBLANKON
	LDX	#$FF
	TXS			;RESET STACK
	LDA	#0		;clear pointers
	STA	PF0
	STA	PF1
	STA	PF2
	STA	GRP0
	STA	GRP1
	lda	ENDROUND
	bne	NEXT_STATE

	lda	R_EGGS
	bne	.play_on
	STAI	ENDSTATE,W_STATE
	STAI	12,W_TIMEVAL
.play_on:
;***************************************************************************
;
;
;	Console Switch 
;
;

CONSOLE_CHK:   ;

;****************************************************************************
;
;
;	reset switch logic
;
;
CK_RESET:
	LDA	SWCHB
	ROR
	BCS	.NO_RESET
	DEC	CONCNT
	bpl	.NO_RESET
	STAI	30,CONCNT
	JMP	NXTST

.NO_RESET:


;****************************************************************************
;
;
;	Select Switch Logic
;
CK_SELECT:
	LDA	SWCHB
	AND	#SELECTBIT
	BNE	.NO_SELECT
	STAI	1,CONSTAT
	JMP	OVREND		; select = HALT 
	
.NO_SELECT:
	STAI	0,CONSTAT

;****************************************************************************
;
;	end of Console logic
;
NO_CONSOLE:

;****************************************************************************
;
;	Game Timer - next state logic
;
;
TICKTOCK:
	dec	TIMER
	bpl	.NOTICK
	LDA	R_TIMEVAL	; this games rate
	STA	TIMER		; reset timer
	jsr	score_timer
	LDA	TIMER		; zero = timed out
	bne	.NOTICK
	lda	#1
	sta	ENDROUND
	jmp	OVREND
.NOTICK:


;*****************************************************************
;
;	Increment Fram ecounter until ATTRACT
;
;
;
INC_FRMCNT:
	INC	FRMCNT		;INCREMENT	FRAME COUNT		
	bne	.exit
	INC 	FRMCNTH
	bne	.exit
	jmp 	START
.exit:

;****************************************************************************
;
;
;	random number ( and are you looking for
;			a good used bridge ... ? )
;
RANDOM:
	lda	R_RANDOM
	tay
	asl
	ADC	FRMCNT
	ADC	$80,y
	ADC	R_RANDOM
	STA	W_RANDOM

;**************************************************************************
;
;
;	Music Driver 
;
;
	ldx	#0
	JSR	playit
	ldx	#1
	jsr	playit
;**************************************************************************
;
;
;	Set Fire Button Trigger
;
;**************************************************************************


CKFIRE:
	jsr	FIRE?		; cpy 13 ?

;************************************************************************
;
;
;	OVERSCAN SCREEN SPECIFIC CODE
;
;	DISPATCH 
;
;	(or the beginning of another mess...)
;
;***************************************************************************
	LDA	R_SCREEN
	CMP	#INTREESCREEN
	BEQ	.DOCUSOR
	CMP	#INPIPESCREEN
	BEQ	.DOCUSOR
	CMP	#INRANCHSCREEN
	BEQ	.DOCUSOR
	CMP	#INDEMOTREE
	BEQ	.DOCUSOR
	CMP	#INBONUSSCREEN
	BEQ	OVREND
	CMP	#INTITLESCREEN
	bne	OVREND
	JSR	joystick		;PROCESS JOYSTICK
	JMP	OVREND

	
;*****************************************************************************
;
;	Check Fire Button  & joystick
;
.DOCUSOR:		; does every label have to be local ? 
;
;	joystick code 
;
;

	JSR	joystick		;PROCESS JOYSTICK

;
;
;	Ranch Screen Different
;
	LDA	R_SCREEN
	cmp	#INRANCHSCREEN
	bne	TREE_PIPE_CURSOR
	PTR	SPLATHMOVETAB,SPLATHMOVE
	PTR	SPLATSIZETAB,SPLATSIZE
;***************************************************************************
;
;	docursor logic ... of ranch
;
;
DORANCHCUR:
	LDA	VOFFSET
	sta	W_VPOS
	LDA	#SPLAT_SIZE
	JSR	docursor
	jmp	OVREND

;****************************************************************************
;	OVERSCAN LOGIC FOR TREE AND PIPE SCREEN
;
;	DOCURSOR FOR TREE AND PIPE SCREEN CURSORS
;
TREE_PIPE_CURSOR:
;
;
;
;	Dennis you hid this......#@$%^&!
;
;
;
.ckshot:
	LDA	FIRE_VAL
	CMP	#13
	BNE	.NOSHOT
	JSR	EGG_AND_CUR
;	JSR	PLAY_SHOT
	JSR	HITDET
	jmp	.DOEGG

.NOSHOT:
	lda	FRMCNT
	and	#1
	beq	.DOEGG
	jsr	CLEAR_CURSOR		; clear cursor data
	LDA	VOFFSET
	STA	W_VPOS			;SET VPOS TO CURSOR VPOS
	LDA	#CURSIZE		;TELL DOCURSOR THIS IS THE
					;CURSOR AND SET CURSIZE
	JSR	docursor		; set cursor data
	jmp	.exit


.DOEGG:
	LDA	R_EGGY	;process falling, splating, nest catching, of egg
	Beq	.exit
	STA	W_VPOS	
	LDA	#4
	JSR	docursor		; reset missle
	JSR	NESTCATCH
.exit:

;***************************************************************************
;
;
;
;
;	END OF OVERSCAN
;
;
;


OVREND:
;	LDA	INTIM
;	STA	TEMP0
;OVR:	lda	TEMP0
OVR1:	LDA	INTIM
	BNE	OVR1
	WSYNC
	STAI	VRTTIM,TIM64T	;SET UP TIMER FOR 37 LINES /2360 CYCLES
	LDA	#2
	WSYNC
	STA	VSYNC
	WSYNC
	WSYNC
	WSYNC
	STAI	0,VSYNC

;**************************************************************************
;
;
;
;	 START OF VERTICAL
;
;
;
;

DISPATCH:

	lda	ENDROUND
	bne	.dsp1
	lda	CONSTAT
	beq	DO_LOGIC
.dsp1:	jmp	VRT_OVER



DO_LOGIC:

	lda	R_SCREEN
	asl
	tay
	lda	OVERTAB,y
	sta	TEMP0
	lda	OVERTAB+1,y
	sta	TEMP1
	jmp	(TEMP0)



OINSELECT:
OINBONUSSCREEN:

	ldx	r_frame_hold
	bne	.hold_count
	jsr	PLAY_DING
	jsr	INC_SCORE
	jsr	SET_SCORE	
	ldy	STEMP
	lda	y,table101
	tax
	lda	#(EGG1 & $FF)
	sta	SIXCHAR1,x
	dec	STEMP
	bpl	.set_hold
	STAI	1,ENDROUND
	jmp	LOGIC_END
.set_hold:
	ldx	#75
.hold_count:
	dex
	stx	w_frame_hold
	jmp	LOGIC_END


table101:
	.dc.b	0
	.DC.B	21+6
	.dc.b	15+6
	.dc.b	9+6 
	.dc.b	3+6 
	.dc.b	20+6
	.dc.b	14+6
	.dc.b	8+6
	.dc.b	2+6
	.dc.b	19+6
	.dc.b	13+6
	.dc.b	7+6
	.dc.b	1+6
	.dc.b	18+6
	.dc.b	12+6
	.dc.b	6+6
	.dc.b	0+6


;****************************************************************************
;
;
;	RANCH Screen Logic 
;	
;
;

OINRANCHSCREEN:
OINR:
	STAI	0,COLUBK
	STAI	4,TIMER
	LDA	r_splat_hold
	bpl	.noclear
	jsr	clearranch
.noclear:
	SEC	
	SBC	#1
	STA	w_splat_hold
.gogogo:	
	lda	FIRE_VAL
	CMP	#13
	bne	.skip
	jsr	clearranch
	jsr	PLAY_SHOT
;
;
;	code from rscan
;
;
;

.skip:
	LDA	r_splat_hpos
	CMP	#135  ;MAKE CURSOR STAY ON BARN
	BCC	.OK3
	LDA	#136
.OK3:	CLC
	ADC	#5	;3+(1 FROM RESOBJ)
.OK:
	TAY		;2;2
	LDA	Y,HMTAB	;4;4
	AND	#$0F	;2;10
	TAY		;2;12
	WSYNC
	LDX	TEMP0
	LDX	TEMP0
	LDX	TEMP0
	LDX	R_BRD1HMOVE	;4;8
.LOP2:	DEY		;2;14	
	BNE .LOP2	;2;16
	STA	HMM0	;4;8
	STA	RESM0	;4;23
;*****************************************************************************
;
;
;	Group 2 snarfed code
;
;
;******************************************************************************

	LDY	r_rooster_hold
	beq	.CHOOSE
	dey
	sty	w_rooster_hold
	JMP	.QWERT

.CHOOSE:
	PTR	ROOSTER1,CHICKEN2DATA
	PTR	ROOSTER0,CHICKEN1DATA
	PTR	CHICKCOLOR,CHICKENCOLOR


	LDA	R_RANDOM
	AND	#7
	STA	w_rooster_hold
	AND	 #$03
	STA	TEMP5
	
	bit	r_got_egg
	bvs	.scroll

	lda	R_RANDOM	;WINDOW SELECT LOGIC
	AND	#$1F
	CMP	#17
	BCC	.PICK
	AND	#$0F
.PICK:
	sta	w_rooster_window

;	lda	#27
	lda	#36
;	lda	#34
	sta	w_rooster_scroll

	LDA	r_got_egg
	LDA	#$40
	sta	w_got_egg


.scroll:
	lda	r_got_egg
	bmi	.going_down
	lda	r_rooster_scroll
	sec
	sbc	#1
;	sbc	TEMP5
	sta	w_rooster_scroll
	bpl	.fdsa
.asdf:	lda	r_got_egg
	ora	#$80
	sta	w_got_egg
	STAI	0,w_rooster_scroll
	jmp	.fdsa

.going_down:
	lda	r_rooster_scroll
	CLC
	adc	#1
;	adc	TEMP5
	sta	w_rooster_scroll
;	cmp	#28
	cmp	#32
	bcc	.fdsa
.sdfa:
	lda	#0		;reset rooster
	sta	w_got_egg	;increment score
.fdsa:	lda	CHICKEN2DATA
	clc
	adc	r_rooster_scroll
	sta	CHICKEN2DATA

	LDA	CHICKEN1DATA
	clc
	adc	r_rooster_scroll
	sta	CHICKEN1DATA

	LDA	CHICKENCOLOR
	clc
	adc	r_rooster_scroll
	sta	CHICKENCOLOR

;*************************

.QWERT:	


;***************
; still more ROOSTER code .... not quite good w/ above...

	LDA	GFLG1		;WAIT 2 FRAMES AFTER FIRE FOR COLLISION DET
	BPL	.NO_FIRE_LAST	;NOTHING FIRED SKIP
	AND	#SHOTNLAST
	BEQ	.OKNOW		;2 FRAMES ELASPED SO CHECK COLLISION
	STAI	$80,GFLG1
	JMP	.NO_FIRE_LAST
.OKNOW:
	STAI	0,GFLG1
	LDA	CXM0P
	BEQ	.NORHIT

	STAI	WHITE,COLUBK
;	IF YOU ARE HERE THE ROOSTER HAS BEEN HIT

	jsr	PLAY_DING
	jsr	INC_SCORE
	jmp	.NO_FIRE_LAST

.NORHIT:
	JSR	PLAY_SCOFF


.NO_FIRE_LAST:
	LDA	FIRE_VAL
	CMP	#13
	BNE	.nohit
	STAI	0,FRMCNTH
	LDA	GFLG1
	ORA	#SHOTNLAST |SHOTLAST	;#$C0  FIRE BUTTON PRESSED START
					;DELAY
	STA	GFLG1
	LDA	#20
	STA	w_splat_hold
	lda	VOFFSET
	STA	w_splat_vpos
	lda	HOFFSET
	CMP	#145  ;MAKE CURSOR STAY ON BARN
	BCC	.OK2
	LDA	#146
.OK2:
	CMP	#13
	BCS	.OK1
	LDA	#13
.OK1:	sta	w_splat_hpos

;
;
;	end-of-screen = no eggs left
;
;
	DEC	REGGCOUNT
	BPL	.nohit
.next_screen:
	STAI	1,ENDROUND
	JMP	VRT_OVER

.nohit: ldy	r_rooster_window
	LDA	#5
	CPY	#7
	BCC	RRESET
	LDA	#3
	cpy	#12
	BCC	RRESET
	LDA	#1
RRESET:
	STA	w_da_one	
	ldy	r_rooster_window
	lda	window_x,y
	ldx	#0
	JSR	RESPLOOP
	ldy	r_rooster_window
	lda	window_x,y
	clc
	adc	#5
	ldx	#1
	JSR	RESPLOOP
	STA	CXCLR

;
;	LDA	Y,ROSTHM
;	sec
;	sbc	#$40
;	STA	W_RRHMOV1
;
;	LDY	R_RRESET0	;4;4
;	WSYNC
;	WASTE3			;3;3
;	NOP			;2;5
;
;	LDA	R_RRHMOV1	;4;9
;	LDX	R_RRHMOV0	;4;13
;.LOP:	DEY			;2;15
;	BNE .LOP		;2;17
;	WASTE3			;3;20
;	RESP0			;3;23
;	STA	HMP0		;3;20
;	LDY	R_RRESET1	;4;7
;	WSYNC
;	STA	CXCLR
;	WASTE3			;3;3
;	NOP			;2;5
;	LDA	R_RRHMOV1	;4;9
;	LDX	R_RRHMOV0	;4;13
;.LOP1:	DEY			;2;15
;	BNE .LOP1		;2;17
;	STA	HMP1		;3;20
;	RESP1			;3;23
;	STX	HMP0	;3;3
;	

;****************************************
;

END_RANCH_LOGIC:


	STAI	BARNCOLOR,COLUPF
	jmp	LOGIC_END

;**************************************************************************
;
;
;	Tree Logic
;
;
;
;***************************************************************************


OINTREESCREEN:
	lda	FRMCNT
	and	#1
	bne	.TOPKERS

	ldx	#5
	JSR	animator	;5
	ldx	#4
	JSR	animator	;4
	ldx	#3
	JSR	animator	;3
	jmp	.exit

.TOPKERS:
	ldx	#2
	JSR	animator	;2
	ldx	#1
	JSR	animator	;1
	ldx	#0
	JSR	animator	;0

.exit:
	STAI	TREECOLOR,COLUPF
	jsr	reset_bird1_TREE
	jmp	LOGIC_END

;*************************************************************************
;
;
;	pipe
;
;
OINPIPESCREEN:
	lda	FRMCNT
	and	#1
	bne	.top
	ldx	#5
	JSR	animator	;5
	ldx	#4
	JSR	animator	;4
	ldx	#3
	JSR	animator	;3
	jmp	.pipe_exit

.top:
	ldx	#2
	JSR	animator	;2
	ldx	#1
	JSR	animator	;1

;
;
;	check edge for short 1st pipe
;
	ldx	#0
.ok_r:	lda	r_xpos,x
	bpl	.okl
	lda	#REFRIGHT
	jmp	.not_ok	
.okl:	cmp	#30
	bcc	.ok_top
	lda	#REFLEFT
.not_ok:
	sta	W_BRD1REF
.ok_top:	
;	PTR	GSEQS,SEQ
	JSR	animator	;0
.pipe_exit:
	jsr	reset_bird1_PIPE
	JMP	LOGIC_END


;*******************************************************************
;
;
;
;
;


OINENDOFGAME:
	STAI	0,W_STATE
	jmp	LOGIC_END

;do_ranch_intro_logic:
;	lda	FRMCNTH
;	beq	.exit
;	lda	FRMCNT
;	and	#$07
;	bne	.exit
;	ldy	R_SCREEN_INDEX
;	cpy	#RANCH_IMAGE
;	beq	.exit
;	iny
;	iny
;	sty	W_SCREEN_INDEX
;	cpy	#RANCH_IMAGE
;	bne	.exit
;	STAI	8,TIMER
;	sta	W_TIMEVAL
;.exit:	STAI	YELLOWBIRD,tcolor0
;	jmp	LOGIC_END

;do_tree_intro_logic:
;	ldy	STEMP
;	beq	.exit
;	lda	FRMCNT
;	and	#$07
;	bne	.exit
;	dey
;	lda	FADE,y
;	clc
;	ADC	#TREE_INTRO_COLOR
;	sty	STEMP
;	sta	tcolor0
;	sta	tcolor1
;.exit:	jmp	LOGIC_END

;*******************************************************************
;
;
;
;
;


;*************************************************************
;
;
;	do_subway_intro_logic
;
;
;*************************************************************


;OPIPEINTRO:
;	lda	FRMCNT
;	and	#$1f
;	cmp	#$0f
;	bcc	.sb1
;	STAI	$04,TEMP0
;	jmp	.sb2
;	
;.sb1:	STAI	$0A,TEMP0
;.sb2:	lda	tcolor0
;	and	#$f0
;	ora	TEMP0
;	sta	tcolor0
;.exit:	jmp	LOGIC_END


OPIPEINTRO:
	lda	FRMCNT
	and	#$10
	bne	.PIPE1
	lda	tcolor0
	and	#$F0
	ora	#$0A
	JMP	.PIPE2

.PIPE1:
	lda	tcolor0
	and	#$F0
	ora	#$04
.PIPE2:	sta	tcolor0
	jmp	LOGIC_END

EGTB:	.dc.b	SIXCHAR1+1 -$80
	.dc.b	SIXCHAR2+1 -$80
	.dc.b	SIXCHAR3+1 -$80
	.dc.b	SIXCHAR4+1 -$80
	.dc.b	SIXCHAR5+1-$80
	.dc.b	SIXCHAR6+1-$80

OINTITLESCREEN:

TITL:
	STAI	EGG1/$100,SIXPAGE+1
	LDY	R_TIMEZ
	dey
	sty	W_TIMEZ
	BNE	.ok
	STAI	20,W_TIMEZ
	ldy	R_EGGNUM
	bne	.doit
	lda	#BLANK&$FF
	sta	SIXCHAR1+1
	sta	SIXCHAR2+1
	sta	SIXCHAR3+1
	sta	SIXCHAR4+1
	sta	SIXCHAR5+1
	sta	SIXCHAR6+1
	STAI	60,W_TIMEZ
	STAI	6,W_EGGNUM
	jmp	.ok

.doit:	dey
	sty	W_EGGNUM
	lda	EGTB,y
	tay
	lda	#EGG1&$FF
	sta	$80,y
	jsr	PLAY_SHOT
.ok:
count:
	dec	jcount
	bne	easy
	STAI	25,jcount
	lda	HOFFSET
	cmp	SELECTH
	beq	easy
	STAI	200,TIMER
	jsr	PLAY_DING
	inc	LEVEL
	lda	LEVEL
	and	#3
	bne	easy
	lda	#1
	sta	LEVEL
easy:	lda	LEVEL
	cmp	#1
	bne	normal
	STAI	WHITE,tcolor1

	STAI	(P13/256)&$FF,SIXPAGE+0
	STAI	P13 & $FF,SIXCHAR6+0
	STAI	P23 & $FF,SIXCHAR5+0
	STAI	P33 & $FF,SIXCHAR4+0
	STAI	P43 & $FF,SIXCHAR3+0
	STAI	P53 & $FF,SIXCHAR2+0
	STAI	TITBLK&$ff,SIXCHAR1+0
;	STAI	P63 & $FF,SIXCHAR1+0

	jmp	ALTCPY



normal:	cmp	#2
	bne	insane
	STAI	RED,tcolor1
	STAI	(P11/256)&$FF,SIXPAGE+0
	STAI	P11 & $FF,SIXCHAR6+0
	STAI	P21 & $FF,SIXCHAR5+0
	STAI	P31 & $FF,SIXCHAR4+0
	STAI	P41 & $FF,SIXCHAR3+0
	STAI	P51 & $FF,SIXCHAR2+0
	STAI	P61 & $FF,SIXCHAR1+0
	jmp	ALTCPY

insane:
	STAI	REDORG,tcolor1
	STAI	(P12/256)&$FF,SIXPAGE+0
	STAI	P12 & $FF,SIXCHAR6+0
	STAI	P22 & $FF,SIXCHAR5+0
	STAI	P32 & $FF,SIXCHAR4+0
	STAI	P42 & $FF,SIXCHAR3+0
	STAI	P52 & $FF,SIXCHAR2+0
	STAI	P62 & $FF,SIXCHAR1+0

ALTCPY:
	LDA	tcolor1
	and	#$F0
	cmp	#$30
	bne	NOTCRZY
	LDY	#$38
	LDA	FRMCNT
	and	#$10
	beq	CRZY
	LDY	#$3F
CRZY:	sty	tcolor1
NOTCRZY:
	lda	FRMCNT
	bpl	.neve
	STAI	(TITLE1/256)&$FF,SIXPAGE+4
	STAI	t2p0 & $FF,SIXCHAR6+4
	STAI	t2p1 & $FF,SIXCHAR5+4
	STAI	t2p2 & $FF,SIXCHAR4+4
	STAI	t2p3 & $FF,SIXCHAR3+4
	STAI	t2p4 & $FF,SIXCHAR2+4
	STAI	t2p5 & $FF,SIXCHAR1+4
	jmp	.logic

.neve:
	STAI	(t3p0/256)&$FF,SIXPAGE+4
	STAI	t3p0 & $FF,SIXCHAR6+4
	STAI	t3p1 & $FF,SIXCHAR5+4
	STAI	t3p2 & $FF,SIXCHAR4+4
	STAI	t3p3 & $FF,SIXCHAR3+4
	STAI	t3p4 & $FF,SIXCHAR2+4
	STAI	t3p5 & $FF,SIXCHAR1+4


.logic:
	lda	HOFFSET
	sta	SELECTH
	lda	FIRE_VAL
	cmp	#13
	bne	.exit
	ldy	#MIN_GAME
	sty	W_STATE
	STAI	1,ENDROUND

.exit:


ORANCHINTRO:
OTREEINTRO:
DOFADE:
	ldy	STEMP
	beq	.nofade
	lda	FRMCNT
	and	#$07
	bne	.nofade
	lda	tcolor0
	and	#$F0
	ora	FADE,y
	sta	tcolor0
	dey
	sty	STEMP

.nofade:

;**************************************************************************
;
;
;		end of vertical logic
;
;

;**************************************************************************
;
;
;	Setup JMP pointer for current screen
;
LOGIC_END:

;	lda	BKCOLOR
;	sta	COLUBK

VRT_OVER:
	LDA	R_SCREEN
	ASL
	TAX
	LDA	X,SCREENADD
	STA	BANKJMP
	LDA	X,SCREENADD+1
	STA	BANKJMP+1
;
;
;	Verticals ONLY HMOVE & CLEAR
;
;
;
	WSYNC
	HMOVE		;3;3
	WSYNC
	HMCLR
;***************************************************************************
;
;
;	end of vertical
;
VRTEND:
;	LDA	INTIM
;VRT1:	nop
VRT2:	LDA	INTIM		
	BNE	VRT2
	WSYNC
	VBLANKOFF	;5;8
	JMP	ROMJMPF

;****************************************************************
;
;
;	Subroutines
;
;
;****************************************************************


;******************************************************************************
;
;
;	Clear The Cursor address array
;
;
CLEAR_CURSOR:


;NULLOBJ set BLANKSC2	; set for particular blank

	lda	R_SCREEN
	cmp	#INPIPESCREEN
	beq	.cp
	LDA	#TBLANK & $FF
	LDY	#(TBLANK & $FF00)/$0100
	jmp	.clr
	
.cp:	LDA	#BLANK & $FF
	LDY	#(BLANK & $FF00)/$0100
.clr:	ldx	#42
.clearm:
	STA	x,CURSOR1		;SET CURSOR POINTERS TO BLANKS
	pha
	tya
	STA	x,CURSOR1+1	
	pla
	dex
	dex
	bpl	.clearm
	rts


;****************************************************************************
;
;
;	Increment Score
;
;
INC_SCORE:
	sed	
	LDA	r_old_score
	CLC
	ADC	#1
	STA	w_old_score
	BCC	.exit
;	jsr	PLAY_CHARGE
	LDA	r_old_score+1
	CLC
	ADC	#1
	sta	w_old_score+1
.exit:	CLD
	rts


;***************************************************************
;
;
;	as-is bird 1 reset code
;
;
reset_bird1_PIPE:
reset_bird1_TREE:
reset_bird1:
	LDX	R_BRD1REF	;
	LDY	R_BRD1DELPTR  	;4;4
	WSYNC
	STX	REFP1		;3;11
	STX	REFP1		;3;11
	STX	REFP1		;3;11
	LDA	R_BRD1HMOVE	;4;8
.DELAYLOP:	
	DEY		;2;15
	BNE	.DELAYLOP	;3/2;17
	STA	HMP1	;3;20
	STA	RESP1	;3;23
	rts




;************************************************************************
;
;
;
;	Sounds Setup
;
;
PLAY_SCOFF:	
	lda	#SCOFF
	jmp	PLAY_SND0
PLAY_CHARGE:
	lda	#CHARGE
	jmp	PLAY_SND0

PLAY_SHOT:
	LDA	#SHOT		;"SHOT" SOUND -- HONEST		
PLAY_SND0:
	sta	w_tunenum	;CHANNEL 1 FOR FIRE BUTTON
	LDA	#1
	STA	w_timer
	RTS


PLAY_DING:
	lda	#DING		;NAME OF DESIRED SOUND HERE
PLAY_SND1:
	sta	w_tunenum+1
	LDA	#1
	STA	w_timer+1
	RTS

;
;
;	Get image offsets for BCD byte
;
;   Returns:
;
;	<A>	10's 
;	<X>	1's
;
GET_DIGIT:
	sta	TEMP2
	and	#$0f
	tay
	lda	y,ONESADD
	tax
	lda	TEMP2
	lsr
	lsr
	lsr
	lsr
	tay
	LDA	Y,ONESADD	
	rts



EGG_AND_CUR:
	LDA	R_EGG_IN_CUR	;IF WE GOT EGG DROPIT 
	BPL	CATCHCHECK
	STAI	0,R_EGG_IN_CUR
	JMP	INITDROP	; INIT DROP RTS TO CALLER A SET TO 0 ABOVE

CATCHCHECK:
	LDA	R_EGGY
	BEQ	.exit
	CMP	VOFFSET	;A=R_EGGY FROM ABOVE
	BCC	.exit
	SEC
	SBC	#CURSIZE
	CMP	VOFFSET
	BCS	.exit
	LDA	HOFFSET
	CMP	R_EGGX
	BCS	.exit
	ADC	#8	;PLAYER WIDTH
	CMP	R_EGGX
	BCC	.exit
	STAI	$80,W_EGG_IN_CUR
	STAI	0,W_EGGY	
.exit:	RTS

;*********************************************************************
;
;
;		setup current score 
;
;	

SET_SCORE:
	lda	r_old_score+1
	jsr	GET_DIGIT
	STX	SIXCHAR5+4	;3;43	
	STA	SIXCHAR6+4
	lda	r_old_score
	jsr	GET_DIGIT
	STX	SIXCHAR3+4	;3;43	
	STA	SIXCHAR4+4
	LDY	#0		;2;45	;points are multiples of 100
	LDA	Y,ONESADD	;4;49	;so the last 2 digits are 0
	STA	SIXCHAR1+4	;3;52
	STA	SIXCHAR2+4	;3;55
	STAI	NUM0/$100,SIXPAGE+4
	rts

ONESADD:
	.DC.B	NUM0&$00FF
	.DC.B	NUM1&$00FF
	.DC.B	NUM2&$00FF
	.DC.B	NUM3&$00FF
	.DC.B	NUM4&$00FF
	.DC.B	NUM5&$00FF
	.DC.B	NUM6&$00FF
	.DC.B	NUM7&$00FF
	.DC.B	NUM8&$00FF
	.DC.B	NUM9&$00FF


FADE:
	.dc.b	$0D
	.dc.b	$0D
	.dc.b	$0D

	.dc.b	$0D
	.dc.b	$0C
	.dc.b	$0A

	.dc.b	$0A
	.dc.b	$08
	.dc.b	$08

	.dc.b	$08
	.dc.b	$06
	.dc.b	$06

	.dc.b	$04
	.dc.b	$02
	


;RESTAB:	
;	.DC.B	2	;DUMMY
;	.DC.B	2
;	.DC.B	4
;	.DC.B	5
;	.DC.B	6
;	.DC.B	8	
;	.DC.B	9
;	
;	.DC.B	3
;	.DC.B	4
;	.DC.B	6
;	.DC.B	7
;	.DC.B	9
;	
;	.DC.B	2
;	.DC.B	4
;	.DC.B	5
;	.DC.B	7
;	.DC.B	8	
;	.DC.B	9


;ROSTHM:
;	.DC.B	$B0	;DUMMY
;	.DC.B	$B0
;	.DC.B	$50
;	.DC.B	$10
;	.DC.B	$90
;	.DC.B	$10
;	.DC.B	$C0
;
;	.DC.B	$70
;	.DC.B	$D0
;	.DC.B	$40
;	.DC.B	$B0
;	.DC.B	$10
;
;	.DC.B	$B0
;	.DC.B	$50
;	.DC.B	$10
;	.DC.B	$70
;	.DC.B	$10
;	.DC.B	$C0


window_x:
;	.DC.B	0+8
	.dc.b	28+8
	.dc.b	48+8
	.dc.b	68+8
	.dc.b	92+8
	.dc.b	112+8
	.dc.b	132+8

	.dc.b	32+8
	.dc.b	56+8
	.dc.b	80+8
	.dc.b	104+8
	.dc.b	128+8

	.dc.b	28+8
	.dc.b	48+8
	.dc.b	68+8
	.dc.b	92+8
	.dc.b	112+8
	.dc.b	132+8

window_y:
;	.DC.B	0
	.dc.b	135
	.dc.b	135
	.dc.b	135
	.dc.b	135
	.dc.b	135
	.dc.b	135

	.dc.b	80
	.dc.b	80
	.dc.b	80
	.dc.b	80
	.dc.b	80

	.dc.b	25
	.dc.b	25
	.dc.b	25
	.dc.b	25
	.dc.b	25
	.dc.b	25
	.DC.B	18


RESPLOOP:
	tay
	JSR	HMLOOK	
	STA	TEMP
	and	#$0f
	tay	
	WSYNC
	LDA	TEMP	
	LDA	TEMP	
	LDA	TEMP
.DELAYLOP:	
	DEY		;2;15
	BNE	.DELAYLOP	;3/2;17
	STA	RESP0,x	;3;23
	STA	HMP0,x	;3;20
	rts


clearranch:
;	PTR	SPLATHMOVETAB,SPLATHMOVE
;	PTR	SPLATSIZETAB,SPLATSIZE

	LDX	#6
.FSGO1:	lda	#(SPLATHMOVETAB & $FF)
	STA	X,SPLATHMOVE1
	lda	#(SPLATSIZETAB & $FF)
	STA	X,SPLATSIZE1
	DEX
	BPL	.FSGO1
	rts

