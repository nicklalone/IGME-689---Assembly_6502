;JOY_DIR_TAB:
;	.dc.b	UP
;	.dc.b	DOWN
;	.dc.b	LEFT
;	.dc.b	RIGHT

;
;
;	joystick handler
;
;	Art 565-2128 
;	469-4220 x4220
;

AUTO_JOY:	
	dec	jcount
	bne	MVHOR
	lda	R_RANDOM
	and	#$0F
	sta	jcount
	and	#3
	tay
	sty	jvalue
MVHOR:	ldy	#2
	ldx	HOFFSET
	lda	r_xpos,y
	sbc	HOFFSET
	bmi	.01
	inx
	jmp	.02
.01:	dex
.02:	stx	HOFFSET
	
MVVRT:
	ldx	VOFFSET
	lda	r_ypos,y
	clc	
	adc	#ERNEST2START
	sbc	VOFFSET
	bmi	.01
	inx
	jmp	.02
.01:	dex
.02:	stx	VOFFSET
	jmp	SET_CUR

;**********************************************************************
;
;
;			Normal Joystick
;
;
;**********************************************************************
joystick:
	lda	R_SCREEN
	cmp	#INDEMOTREE
	beq	AUTO_JOY
	cmp	#PIPEDEMO
	beq	AUTO_JOY
	STAI	0,CTLSWA	;SWITCHES TO INPUT

	lda	SWCHA
	rol
	bcs	notrit
	inc	HOFFSET
	inc	HOFFSET
notrit: rol
	bcs	notleft
	dec	HOFFSET	
	dec	HOFFSET	
notleft: rol
	bcs	notdwn
	dec	VOFFSET
	dec	VOFFSET
notdwn: rol
	bcs	notup
	inc 	VOFFSET
	inc 	VOFFSET
notup:	

SET_CUR:
.OK:	LDA	#190-CURSIZE
	CMP	VOFFSET
	BCS	.in_screen
	STA	VOFFSET 
.in_screen:
	LDA	#ESCORESTART
	CMP	VOFFSET
	BCC	.IN2
	STA	VOFFSET	
.IN2:	LDA	#151
	cmp	HOFFSET
	BCS	.set1
	STA	HOFFSET
.set1:	lda	#2
	cmp	HOFFSET
	bcc	.set
	sta	HOFFSET
.set:	LDY	HOFFSET
	LDA	R_SCREEN
	CMP	#INRANCHSCREEN
	BNE	.NOTRS
;
;
;
;	Ranch Screen Stuff
;
;
;
	LDA	HOFFSET
	CMP	#135  ;MAKE CURSOR STAY ON BARN
	BCC	.OK2
	LDA	#136
.OK2:
	CMP	#12
	BCS	.OK1
	LDA	#12
.OK1:	TAY	
	LDA	Y,HMTAB
	STA	W_BRD1HMOVE
	AND	#$0F
	STA	W_BRD1DELPTR
	RTS
;
;
;	RESET PLAYER 0
;
;
.NOTRS:
	lda	R_SCREEN
	cmp	#INPIPESCREEN
	beq	.ok
	cmp	#INTREESCREEN
	beq	.ok
	cmp	#INDEMOTREE
	bne	.exitz
	
.ok:
;	NOP			;2;2
	LDA	Y,HMTAB		;4;6
	STA	TEMP
	AND	#$0F		;2;11
	TAY			;2;13
	WSYNC
	LDA	TEMP
	STA	R_MTIME
	LDA	TEMP
	LDA	TEMP	
		
;	NOP			;2;2
;	LDA	Y,HMTAB		;4;6
;	STA	HMP0		;3;9
;	AND	#$0F		;2;11
;	TAY			;2;13
.DELAYLOP:	
	DEY			;2;15
	BNE	.DELAYLOP	;2/3;17
	STA	HMP0
	STA	RESP0		;3;23	
.exitz:	rts


