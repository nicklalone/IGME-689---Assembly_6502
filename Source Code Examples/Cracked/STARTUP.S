
;*****************************************************************************
;
;	screen values
;
;
;*****************************************************************************

;*****************************************************************************
;
;SHOTLAST	SET	$80	;USED IN 2 FRAME DELAY FOR COLLISION DET
;SHOTNLAST	SET	$40	;USED IN 2 FRAME DELAY FOR COLLISION DET
;                        :07 & :06 =RSCAN FIRE STATUS 0= NOSHOT LASTFRAME
;
;INTITLESCREEN	SET	0
;INTREESCREEN	SET	1
;INBONUSSCREEN	SET	2	;ANY TIME BIT ONE IS SET IT IS A BONUS SCREEN 
;INPIPESCREEN	SET	3
;INSECONDBONUS	SET	4
;INRANCHSCREEN	SET	5
;INDEMOTREE	SET	6
;INATTRACTSCREEN	SET	7
;INENDOFGAME	SET	8
;
;	POWER-UP RESET INIT
;;
;*******************************************************************************
START:	SEI			;SET UP INTERUPT FLAG
	CLD			;BINARY ARITHMETIC
	LDA	#$FD
	STA	8
	LDA	#0		;CLEAR TIA AND ALL OF RAM
	TAX
	ldy	$87
.LOOP:	tya
	adc	0,x
	tay
	lda	#0
	STA	X,0
	DEX
	BNE	.LOOP
	DEX
.LOOP2:
	tya
	adc	$7000,x
	tay
	lda	#0
	STA	$7000,x
	DEX
	BPL	.LOOP2
	DEX			;X NOW EQUALS FF
	STX	CTLSWA		;INIT PIA PORT AS OUTPUT
	STY	W_RANDOM	; random number seed
;******************************************************************************
;
;	Setup New Game
;	

NEW_GAME:
	ldx	#$FF
	txs	
	INX
	STX	W_STATE
	cli
	LDY	#0
	STY	HOFFSET
	iny
	STY	SELECTH
	STY	LEVEL
	JMP	NEXT_STATE


;*******************************************************************************
;
;
;	Reset Switch RESET   - not now used .. 
;
;RESTART:
;	STAI	2,W_STATE
;	jmp	NEW_GAME


;**************************************************************************
;
;
;	INIT GAME SCREENS
;
;
					
NEXT_SCREEN:

	STAI	0,FRMCNTH
	STA	GFLG1
	STA	W_EGGY	;SET TO NO FALLING EGG
	LDA	#$FF
	STA	W_SHOWTIM0	;4;12	
	STA	W_SHOWTIM1	;4;12	
	STA	W_SHOWTIM2	;4;12	
	STA	W_SHOWTIM3	;4;12	
	STA	W_SHOWTIM4	;4;12	
	STA	W_SHOWTIM5	;4;12	
	lda	R_SCREEN
	asl
	tay
	lda	INITAB,y
	sta	TEMP0
	lda	INITAB+1,y
	sta	TEMP1
	jmp	(TEMP0)

;***********************************************************************
;
;
;	Tree Screen Statup
;
;
;
;	Game Tree init
;
TREE:
tree_init:
	lda	#SCREEN_TIME_GAME
	jmp	set_tree

;
;	demo Tree init
;
tree_demo:
	ldy	#1
	sty	jvalue
	lda	#SCREEN_TIME_TITLE_TREE
set_tree:
	sta	W_TIMEVAL
	sta	TIMER
	PTR	birdksize,TOP		; bird kernel size
;	PTR	birdnxposu,xposu
	PTR	birdnxposd,xposd
	PTR	TREETOPKER,TOPKER
;	PTR	tframepage,image_data
;	PTR	BSEQS,SEQ
;	PTR	TSEQTAB,SEQTAB


	ldy	#0
	lda	@TOPKER(y)
	jmp	PIPE_TREE_INIT


PIPE:
	lda	#SCREEN_TIME_GAME
	jmp	INPIPE
;
;	demo Tree init
;
pipe_demo:
	ldy	#0
	sty	W_STATE
	iny
	sty	jvalue
	lda	#SCREEN_TIME_TITLE_TREE

;************************************************************************
;
;	Pipe Screen Init
;
;
INPIPE:
	sta	W_TIMEVAL
	sta	TIMER
	PTR	pipeksize,TOP		; pipe kernel size
	PTR	pipenxposd,xposd
	PTR	PIPETOPKER,TOPKER
	STAI	$FC,PIPEWALLFIX
;
;
;	Common Init Code of TREE and Pipe Game screens.
;
;

PIPE_TREE_INIT:
	STAI	0,W_EGG_IN_CUR
	STA	W_EGGY		; clear egg drop

	lda     #192/2		;center cursor on screen at screen start
	STA	VOFFSET         ;FOR VERTICAL TEST
	lda	#160/2
	STA	HOFFSET
	STAI	WHITE,COLUP0
;
;
;	distribute eggs 
;
;
	LDX	#4
	LDA	#0
.DFG:	STA	X,NEST1
	DEX
	BPL	.DFG

DEGGS:

	LDY	R_EGGS
.MOREGGS:
	INC	NEST1
	DEY
	BEQ	.EX
	INC	NEST5
	DEY	
	BEQ	.EX
	INC	NEST3
	DEY
	BEQ	.EX
	INC	NEST4
	DEY
	BEQ	.EX
	INC	NEST2
	DEY
	BNE	.MOREGGS
	
.EX:	LDX	#4
.BEX:	LDY	X,NEST1
	LDA	NESTDAT,Y
	STA	X,NEST1
	DEX
	BPL	.BEX
;
;
;	INIT new characters
;
;
new_chars:
	ldx	#5
more_birds:
	jsr	new_bird
	lda	#0
	sta	x,w_got_egg
	lda	R_RANDOM
	asl
	adc	$88,x
	sta	W_RANDOM
	and	#$2f
	sta	w_hold,x
	dex
	bpl	more_birds

CLEARSIXCHAR:
	VDELOFFP0
	VDELOFFP1
	STAI	0,NUSIZ0
	STA	NUSIZ1
	RTS

;*****************************************************************************
;
;
;	Ranch Screen Init
;
;
RANCH:
	;NEED TO CLEAR ROOSTER AND EGG SPLAT
	STA	CXCLR
	WSYNC
	HMOVE		;3;3
	STAI	0,ENAM1 ;5;8
	DEC	TEMP0	;5;13
	DEC	TEMP0	;5;18		is this needed ?
	DEC	TEMP0	;5;23
	STA	RESBL	;3;26
	STAI	0,ENAM1 ;5;8
	STA	COLUBK
	sta	w_rooster_hold

	STAI	9,REGGCOUNT
	PTR	RANCHTOPKER,TOPKER
	PTR	SIDECURTAB,SIDECURSOR
	LDA	#$30
	STA	HMBL
;	STAI	BARNCOLOR,PFCOLOR
;	STAI	WHITE,COLUP0
;	sta	COLUP1

.exit:	
	jmp	CLEARSIXCHAR

;******************************************************************************
;
;
;
;	score init
;
;
;*****************************************************************************

init_select:
BONUS:
	lda	#(BLUE1 & $F2)
	sta	COLUBK
	STAI	SCREEN_TIME_SCORE,W_TIMEVAL
	STAI	EGGSIZ,W_KERSIZ
	STAI	(GOLD & $FA),tcolor0
	LDY	R_EGGS
	sty	STEMP
	LDY	#SCOREKERSIZE
	STY	SCOREK

;*********************************************************************
;
;
;	SHARED BONUS SCREEN CODE FOR 
;	BONUS,ATTRACT,TITLE,ENDGAME SCREENS
;
;
SHAREDBONUS:

SHAREDINTRO:
SET_BLANK:

	ldx	#3
.set_blank:
	LDA	#(BLANK &$FF)
	STA	SIXCHAR1,x
	STA	SIXCHAR2,x
	STA	SIXCHAR3,x
	STA	SIXCHAR4,x
	STA	SIXCHAR5,x
	STA	SIXCHAR6,x
	LDA	#(BLANK &$FF00/$0100)
	STA	SIXPAGE,x
	dex
	bpl	.set_blank
	jsr	SET_SCORE
	STAI	$0,REFP0	;5;69
	STA	REFP1
	VDELONP0
	VDELONP1
	STAI	3,NUSIZ0
	STA	NUSIZ1
	LDY	#7		;2;2
	WSYNC	;LINE2
.LOP:	DEY			;2;4
	BNE	.LOP		;2/3;6
  	WASTE3			;3;37
	sta	RESP0		;3;40
	sta	RESP1		;3;43
	STAI	$40,HMP1
	STAI	$30,HMP0
	RTS





;**************************************************************************
;
;	error exit
;
;**************************************************************************


SCREEN_ERROR:
	VBLANKOFF	
ERROR_LOOP:
	WSYNC
	DEY
	STY	COLUBK
	LDA	SWCHB
	AND	#SELECTBIT
	BNE	ERROR_LOOP
	JMP	START


;************************************************************************
;
;
;	Intro Screens
;
;


DOGAMEOVER:
	STAI	20,TIMER
	sta	W_TIMEVAL
	STAI	SOLIDGAME_IMAGE,W_SCREEN_INDEX
	STAI	SOLIDGAME_SIZE,W_KERSIZ
	STAI	BLACK,COLUBK

	LDA	#DEATH_MARCH
	jsr	PLAY_SND1
	lda	#GOLD
	jmp	common_intro


do_ranch_intro:
	STAI	5,TIMER
	sta	W_TIMEVAL
	STAI	RANCH_SIZE,W_KERSIZ
	STAI	RANCH_IMAGE,W_SCREEN_INDEX
	STAI	REDBIRD & $F3,COLUBK
	lda	#YELLOWGREEN
	jmp     common_intro



do_tree_intro:
	STAI	5,TIMER
	sta	W_TIMEVAL
	STAI	TREE_SIZE,W_KERSIZ
	STAI	TREE_IMAGE,W_SCREEN_INDEX
	STAI	TREECOLOR,COLUBK
	lda	#YELLOWBIRD
	jmp common_intro


do_title_intro:
	STAI	20,TIMER
	sta	W_TIMEVAL
	STAI	1,W_TIMEZ
	sta	jcount
	STAI	COPYSIZ,SCOREK
	STAI	TITLE_SIZE,W_KERSIZ
 	STAI	TITLE_IMAGE,W_SCREEN_INDEX
	STAI	BLUE1 & $F3,COLUBK
	STAI	15,W_EGGS  ;15
	STAI	0,w_new_score
	sta	w_new_score+1
	sta	w_old_score
	sta	w_old_score+1
	sta	FIRE_VAL
	sta	W_EGGNUM
	LDA	#GOLD	
	jmp	xcom

do_subway_intro:
	STAI	5,TIMER
	sta	W_TIMEVAL
	STAI	SUBWAY_SIZE,W_KERSIZ
	STAI	SUBWAY_IMAGE,W_SCREEN_INDEX
	STAI	GREY,COLUBK
	LDA	#REDORG

common_intro:

	LDY	#SCOREKERSIZE
	STY	SCOREK
	LDY	#13
	STY	STEMP
xcom:
	sta	tcolor0
	jmp	SHAREDBONUS


;SETSIXCHAR:
;	STAI	$0,REFP0	;5;69
;	STA	REFP1
;	VDELONP0
;	VDELONP1
;	STAI	3,NUSIZ0
;	STA	NUSIZ1
;	RTS


NESTDAT:
	.DC.B	$00
	.DC.B	$18
	.DC.B	$C3
	.DC.B	$DB





;PIPE
;RANCH
;BONUS
;DOGAMEOVER
;INTROS:
;
;
;

INITAB:
	.dc.w	do_title_intro		;0
	.dc.w	tree_init		;1
	.dc.w	BONUS			;2	
	.dc.w	PIPE			;3
	.dc.w	init_select		;4
	.dc.w	RANCH
	.dc.w	tree_demo
	.dc.w	SCREEN_ERROR
	.dc.w	DOGAMEOVER
	.dc.w	do_tree_intro
	.dc.w	do_ranch_intro
	.dc.w	do_subway_intro
	.dc.w	pipe_demo
