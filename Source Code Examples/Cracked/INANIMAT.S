;***************************************************************************
;1955 Stevens Creek left - 3blks before wolf portal 
;	for now.....
;
;***************************************************************************

upvalue 	set	0
downvalue	set	1

	
;*******************************************************
;
;
;	animator 
;
;

animator:

	lda	INTIM
	cmp	#07
	bcs	DOIT
	jmp	NEXT
;
;	test for active bird first
;
DOIT:
	lda	BIRDCHAR,x
	bne	not_score
	inc	BIRDCOLOR,x
not_score:
	ldy	r_hold,x
	dey
	tya
	sta	w_hold,x
	beq	new_frame
	jmp	NEXT

;************************************************************************
;
;
;      New Frame of Current Sequence
;
;
NF:
new_frame:
	LDA	r_got_egg,X	
	beq	no_color
	lda	BIRDCOLOR,x
	eor	#$08
	ora	#$07
	sta	BIRDCOLOR,x
no_color:

;
;
;	dead bird ?
;

	lda	BIRDCHAR,x
	and	#$FE
	bne	set_seq
	jmp	new_bird

set_seq:
	ldy	r_seq,x
	lda	framepage,y
	bne	nextani
	jsr	RNDSEQ
nextani:
	STA	TEMP1
	tya
	clc
	adc	#3
	sta	w_seq,x
	sty	TEMP0		; sequence point
	txa
	asl
	sta	TEMP2		; X * 2

;
;
;	Get Hold/Direction Value
;
;
	LDA	TEMP1
	and	#$30
	lsr
	lsr
	lsr
	lsr
	tay
	beq	ckturn
	LDA	r_got_egg,X	
	bne	ckturn
	dey
ckturn:
	lda	HOLD_TAB,y
	sec
	sbc	LEVEL
	sta	w_hold,x

	lda	r_xpos,x
	cmp	#10
	bcc	no_turn

	lda	TEMP1
	bpl	no_turn
	LDA	r_got_egg,X	
	bne	no_turn

	lda	BIRDCHAR,x
	tay
	lda	CHAR_SOUNDS,y
	jsr	PLAY_SND1	

	lda	R_BRD1REF,x
	EOR	#$FF
	sta	W_BRD1REF,x

no_turn:
	lda	TEMP1
	and	#$0F
	lsr
	lsr
	tay
set_level:
;
;	move in x 
;
.move_x:
	lda	R_BRD1REF,x
	cmp	#REFRIGHT
	beq	go_right
go_left:
	lda	r_xpos,x
	bmi	rside
	sec
	sbc	MVTAB,y
	bpl	go_on
	jmp	egg_new_bird

rside:	sec
	sbc	MVTAB,y
	jmp	go_on
;
;	right
;
go_right:
	lda	r_xpos,x
	clc
	adc	MVTAB,y
ltest:	cmp	#RIGHTEDGE
	bcc	go_on
	jmp	egg_new_bird

go_on:
	sta	w_xpos,x
;
;	move in y
;
;
move_y:
	lda	TEMP1
	and	#3
	tay

	lda	TEMP1
	and	#MVUP
	bne	goup

	lda	r_ypos,x
	sec
	sbc	MVTAB,y
	jmp	end_move

goup:
	lda	MVTAB,y
	clc
	adc	r_ypos,x
end_move:
	sta	w_ypos,x

;****************************************
;
; code to avoid horizonal edges of kernel
;
;

ck_y:

	ldy	BIRDCHAR,x
	lda	CHARSIZE,y
	sta	TEMP5
	txa
	tay
ck_lo:
	lda	r_ypos,x
	bpl	ck_hi
	lda	#0
	sta	w_ypos,x
ck_hi:
	lda	@TOP(y)
	sec
	sbc	TEMP5
	cmp	r_ypos,x
	bcs	ck_egg
	sta	w_ypos,x
;
;
;	Check for egg scarf
;
;
ck_egg:
	LDA	r_got_egg,X	
	bne	no_egg		;2 dont already have an egg

	txa
	tay
	lda	@xposd(y)	;snarff egg if
	cmp	r_xpos,x	;1 above nest
	bcs	no_egg
	adc	#8
	cmp	r_xpos,x	;1 above nest
	bcc	no_egg
	lda	r_ypos,x
	cmp	#4      ;5		;3 low enough  down
	bcs	no_egg
	LDA	X,NEST1
	BEQ	no_egg		;4 and the nest must have an egg to snarff
	CMP	#IMG3EGG
	BNE	JK
	LDA	#IMG2EGG
	STA	X,NEST1
	JMP	NESTOK
JK:	CMP	#IMG2EGG
	BNE	JK1
	LDA	#IMG1EGG
	STA	X,NEST1
	JMP	NESTOK
JK1:	LDA	#0
	STA	X,NEST1

NESTOK:
	lda	#$FF
	STA	X,r_got_egg
	jsr	PLAY_CHARGE

no_egg:

;
;
;
;
SET_IMAGE:
	ldy	TEMP0
	lda	framepage+1,y
	sec
	sbc	r_ypos,x
	ldy	TEMP2
	sta	BIRDDATA,y

	ldy	TEMP0
	lda	framepage+2,y
	ldy	TEMP2
	sta	BIRDDATA+1,y
;
;	common loop end 
;
;
NEXT:
	ldy	r_xpos,x
	JSR	HMLOOK	
	sta	W_BRD1HMOVE,x
	AND	#$0F
	STA	W_BRD1DELPTR,X
	rts
;
;
;	pick a random sequence
;
;
RNDSEQ:
	lda	BIRDCHAR,x
	asl
	asl
	asl
	STA	TEMP4		; *8
	lda	R_RANDOM
	and	#07
	clc
	adc	TEMP4
	tay
	lda	SEQS,y
	tay
	sta	w_seq,x
	adc	R_RANDOM
	sta	W_RANDOM
	lda	framepage,y
	rts


;******************************************************************************
;
;	Create a new bird,etc
;
;
egg_new_bird:
	lda	x,r_got_egg
	beq	new_bird
	lda	R_EGGS
	beq	new_bird
	LDY	R_EGGS
	DEY
	STY	W_EGGS
new_bird:
	lda	#0
	sta	x,w_got_egg
	txa
	asl
	tay
	sty	TEMP4
;
;
;	 SCREEN SELECT
;
;
;	LDA	#BLANKSC2 & $FF
	lda	R_SCREEN
	cmp	#INPIPESCREEN
	beq	pipe
	LDA	#TBLANK & $FF
	STA	BIRDDATA,Y			; !!! blank is not the 
	LDA	#(TBLANK & $FF00)/$0100	        ;   same in each bank....
	STA	BIRDDATA+1,Y
	jmp	rest

pipe:	LDA	#PBLANK & $FF
	STA	BIRDDATA,Y			; !!! blank is not the 
	LDA	#(PBLANK & $FF00)/$0100	        ; same in each bank....
	STA	BIRDDATA+1,Y
	jmp	rest

;
;	Random Rest....
;
rest:
	lda	FRMCNT
	and	#$7F
	tay
	lda	$80,y
	lsr
	adc	R_RANDOM
	adc	#53
	sta	W_RANDOM
	and	#$37
	sta	w_hold,x
	and	#$07
	STA	TEMP1
	and	#1
	tay
	lda	DIRVAL,y
	sta	R_BRD1REF,x
	lda	STARTPOS,y		; 0  or RIGHTEDGE-1
	sta	w_xpos,x
	lda	#1
	sta	w_ypos,x
	lda	R_RANDOM
	and	#1
	clc
	adc	TEMP4
	ldy	R_SCREEN
	cpy	#INPIPESCREEN
	bne	in_tree
	tay
	lda	PIPE_CHARS,y
	jmp	do_colorz
in_tree:
	tay
	lda	TREE_CHARS,y
do_colorz:
	sta	BIRDCHAR,x
	tay
	lda	COLORS,y
	clc
	adc	TEMP1
	tay
	lda	COLOR_TAB,y
	STA	BIRDCOLOR,x
	jmp	RNDSEQ



CHAR_SOUNDS:
	.dc.b	CHARGE
	.dc.b	CHARGE
	.dc.b	SWOOSH
	.dc.b	SWOOSH
	.dc.b	SWOOSH
	.dc.b	SWOOSH
	.dc.b	SWOOSH
	.dc.b	SWOOSH


DEAD_CHAR 	set 	0
SCORE_CHAR 	set	1
BIRD_CHAR	set	2
SNAKE_CHAR	set	3
MOUSE_CHAR	set	4
OWL_CHAR	set	5
MONKEY_CHAR	SET	6
DRAGONFLY_CHAR	SET	7

SEQS:
	.dc.b	0,0,0,0  ; dead
	.dc.b	0,0,0,0  ; dead

	.dc.b	0,0,0,0  ; score
	.dc.b	0,0,0,0  ; score

	FRAMELOC	FSTR
	FRAMELOC	FSTR
	FRAMELOC	FSTR
	FRAMELOC	FDN
	FRAMELOC	FUP
	FRAMELOC	FSTR
	FRAMELOC	FTN		; bird
	FRAMELOC	FSTR


	FRAMELOC	SNRT
	FRAMELOC	FSNRT		; snake
	FRAMELOC	SNRT
	FRAMELOC	SNRT
	FRAMELOC	SNRT
	FRAMELOC	SNRT
	FRAMELOC	SNRT
	FRAMELOC	SNRT


	FRAMELOC	MRHOP
	FRAMELOC	MRTN		; mouse
	FRAMELOC	MRST
	FRAMELOC	MRST
	FRAMELOC	MRFST
	FRAMELOC	MRFST		; mouse
	FRAMELOC	MRST
	FRAMELOC	MRST

;	.dc.b	0,0,0,0  ; owl
;	.dc.b	0,0,0,0  ; owl

	FRAMELOC	OWLANI
	FRAMELOC	TOWLANI
	FRAMELOC	OWLUP
	FRAMELOC	OWLUP

	FRAMELOC	OWLDN
	FRAMELOC	OWLDN
	FRAMELOC	TOWLANI
	FRAMELOC	OWLANI

	FRAMELOC	GLST1
	FRAMELOC	GLST1		; monkey
	FRAMELOC	GLTN1
	FRAMELOC	GLST1

	FRAMELOC	GLST1
	FRAMELOC	GLST1		; monkey
	FRAMELOC	GLST1
	FRAMELOC	GLST1


	FRAMELOC	DGFLUP1
	FRAMELOC	DGFLST
	FRAMELOC	DGFLTN1		; dfly
	FRAMELOC	DGFLST
	FRAMELOC	DGFLTN1
	FRAMELOC	DGFLUP1
	FRAMELOC	DGFLDN1
	FRAMELOC	DGFLDN1		; dfly

COLORS:
	.dc.b	0 ;DEAD_COLOR
	.dc.b	0 ;SCORE_COLOR
	.dc.b	BIRD_COLOR
	.dc.b	SNAKE_COLOR
	.dc.b	MOUSE_COLOR
	.dc.b	OWL_COLOR	;OWL_COLOR
	.dc.b	MONKEY_COLOR
	.dc.b	DRAGONFLY_COLOR


	
TREE_CHARS:
	.dc.b	BIRD_CHAR
	.dc.b	BIRD_CHAR

	.dc.b	BIRD_CHAR
	.dc.b	BIRD_CHAR

	.dc.b	BIRD_CHAR
	.dc.b	BIRD_CHAR

	.dc.b	BIRD_CHAR
	.dc.b	OWL_CHAR

	.dc.b	SNAKE_CHAR
	.dc.b	SNAKE_CHAR

	.dc.b	SNAKE_CHAR
	.dc.b	SNAKE_CHAR

PIPE_CHARS:
	.dc.b	MOUSE_CHAR
	.dc.b	MOUSE_CHAR

	.dc.b	MONKEY_CHAR
	.dc.b	DRAGONFLY_CHAR

	.dc.b	MONKEY_CHAR
	.dc.b	DRAGONFLY_CHAR

	.dc.b	MONKEY_CHAR
	.dc.b	DRAGONFLY_CHAR

	.dc.b	MOUSE_CHAR
	.dc.b	MOUSE_CHAR

	.dc.b	MOUSE_CHAR
	.dc.b	MOUSE_CHAR


;***********************************
CHARSIZE:
DEAD_SIZE:	.DC.B	0
SCORE_SIZE:	.DC.B	0
BIRD_SIZE:	.DC.B	($10)
SNAKESIZE:	.DC.B	($A)
MOUSE_SIZE:	.DC.B	(7)
OWL_SIZE:	.DC.B	($14)
MONKEY_SIZE:	.DC.B	(10)
GORILLA_SIZE:	.DC.B	(10)
DRAGONFLY_SIZE:	.DC.B	(8)


;*******************************************************
;
;
;	animator data
;
;


;
;	initial x_pos
;
STARTPOS:
	.DC.B	0
	.DC.B	RIGHTEDGE

DIRVAL:
	.dc.b	REFRIGHT
	.dc.b	REFLEFT

	


EGGL = $C0
EGGM = $18
EGGR = $03
 
IMG1EGG = EGGM
IMG2EGG = EGGL + EGGR
IMG3EGG = EGGL + EGGR + EGGM



;*** COLOR EQUATES

;WHITE	=	$0F
;BLACK	=	$0
;GREY	=	$0F
;GOLD	=	$1F
;ORANGE	=	$2F
;REDORG	=	$3F
;PINK	=	$4F
;PURPLE	=	$5F
;PURPBLUE =	$6F
;BLUE1	=	$7F
;BLUE2	=	$8F
;LTBLUE	=	$9F
;TURQUOISE = 	$AF
;GREENBLUE =	$BF
;GREEN	=	$CF
;YELLOWGREEN =	$DF
;ORANGEGREEN =	$EF
;LIGHTORG =	$FF



;	6 entry bird tables

;birdnxposu:		; bird nest x position up
;	.DC.B	XENEST1END-1
;	.DC.B 	XENEST2END-1
;	.DC.B	XENEST3END-1
;	.DC.B	XENEST4END-1
;	.DC.B	XENEST5END-1

;birdnxposd:		; bird nest x position down
;	.DC.B	XENEST1START
;	.DC.B	XENEST2START
;	.DC.B	XENEST3START
;	.DC.B	XENEST4START
;	.DC.B	XENEST5START
;	.dc.b	$FF
birdnxposd:		; bird nest x position down
	.DC.B	XENEST1START 
	.DC.B	XENEST2START
	.DC.B	XENEST3START
	.DC.B	XENEST4START
	.DC.B	XENEST5START

	.DC.B	$FF

;pipenxposu:		; bird nest x position up
;	.DC.B	XPENEST1END-1
;	.DC.B 	XPENEST2END-1
;	.DC.B	XPENEST3END-1
;	.DC.B	XPENEST4END-1
;	.DC.B	XPENEST5END-1
pipenxposd:		; pipe nest x position down
	.DC.B	XPENEST1START
	.DC.B	XPENEST2START
	.DC.B	XPENEST3START
	.DC.B	XPENEST4START
	.DC.B	XPENEST5START

	.DC.B	$FF


;	DOCURSOR DATA DEFINITIONS
TREETOPKER:	.DC.B	12		;NUMBER OF KERNALS + 1	
	.DC.B	ETRESCRNSTART	;START OF EACH KERNAL
	.DC.B	ENEST1START
	.DC.B	ENEST1END-1
	.DC.B	ENEST2START
	.DC.B 	ENEST2END-1
	.DC.B	ENEST3START
	.DC.B	ENEST3END-1
	.DC.B	ENEST4START
	.DC.B	ENEST4END-1
	.DC.B	ENEST5START
	.DC.B	ENEST5END-1
	.DC.B	0

;KERSIZETBL:
	.DC.B	K1SIZE		;SIZE OF EACH KERNAL
	.DC.B	K2SIZE+1
	.DC.B	K3SIZE-1
	.DC.B	K4SIZE+1
	.DC.B	K5SIZE-1
	.DC.B	K6SIZE+1
	.DC.B	K7SIZE-1
	.DC.B	K8SIZE+1
	.DC.B	K9SIZE-1
	.DC.B	K10SIZE+1
	.DC.B	K11SIZE-1

PIPETOPKER:	.DC.B	12		;NUMBER OF KERNALS + 1	
	.DC.B	ETRESCRNSTART	;START OF EACH KERNAL
	.DC.B	EPNEST1START
	.DC.B	EPNEST1END-1
	.DC.B	EPNEST2START
	.DC.B 	EPNEST2END-1
	.DC.B	EPNEST3START
	.DC.B	EPNEST3END-1
	.DC.B	EPNEST4START
	.DC.B	EPNEST4END-1
	.DC.B	EPNEST5START
	.DC.B	EPNEST5END-1
	.DC.B	0

PIPEKERSIZETBL:
	.DC.B	PK1SIZE		;SIZE OF EACH KERNAL
	.DC.B	PK2SIZE+1
	.DC.B	PK3SIZE-1
	.DC.B	PK4SIZE+1
	.DC.B	PK5SIZE-1
	.DC.B	PK6SIZE+1
	.DC.B	PK7SIZE-1
	.DC.B	PK8SIZE+1
	.DC.B	PK9SIZE-1
	.DC.B	PK10SIZE+1
	.DC.B	PK11SIZE-1


birdksize:		; bird kernel size
	.DC.B	K1SIZE		;SIZE OF EACH KERNAL
	.DC.B	K3SIZE-1
	.DC.B	K5SIZE-1
	.DC.B	K7SIZE-1
	.DC.B	K9SIZE-1
	.DC.B	K11SIZE-1

pipeksize:		; pipe kernel size
	.DC.B	PK1SIZE		;SIZE OF EACH KERNAL
	.DC.B	PK3SIZE-1
	.DC.B	PK5SIZE-1
	.DC.B	PK7SIZE-1
	.DC.B	PK9SIZE-1
	.DC.B	PK11SIZE-1


