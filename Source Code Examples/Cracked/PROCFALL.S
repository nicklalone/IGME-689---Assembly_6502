;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NESTCATCH:			;check for nest catch
	lda	R_BKER	   	; kernel egg is in ?
	lsr
	bcc	.dropping
	tay			; PAUL - is this ok?


	lda	@xposd(y)
;	SEC
;	SBC	#10
	cmp	R_EGGX		; left of nest ?
	bcs	.dropping	; yep - forget it

	lda	@xposd(y)
	clc
	adc	#8
	cmp	R_EGGX
	bcc	.dropping

	lda	y,NESTIMAGES
	bne	.egg1

	lda	#IMG1EGG
	sta	y,NESTIMAGES	; no eggs in nest, soon one
	jmp	.GOTEGG	

.egg1:	cmp	#IMG1EGG
	bne	.egg2

	lda	#IMG2EGG	; one egg in nest, soon two 
	sta	y,NESTIMAGES
	jmp	.GOTEGG		; clear egg drop

.egg2:	cmp	#IMG2EGG
	bne	.egg3
	lda	#IMG3EGG
	sta	y,NESTIMAGES 	; two eggs in nest, soon three

.GOTEGG:clc
	sed			;decimal addition for score

	lda	r_old_score	;lo byte
	adc	#3		;300 pts for nest catch
	sta	w_old_score
	bcc	.bbbc

	lda	r_old_score+1	;hi byte
	adc	#1
	sta	w_old_score+1
	
.bbbc:	cld			;clear decimal mode when done with such vice

	LDX	#0
	stx	W_EGGY

	jsr	PLAY_DING
;	LDA	#DING
;	STA	w_tunenum
;	lda	#1
;	sta	w_timer
;	jmp	DOPLAY
;	jsr 	playit

	jmp	NOSPLAT
.egg3:				; three eggs in nest, so 
.dropping:
	LDA	R_EGGY
	SEC
	SBC	#1
	STA	W_EGGY
	lda	R_RANDOM
	CLC
	ADC	FRMCNT
	STA	W_RANDOM
	AND	#7
	ADC	#4
	CMP	R_EGGY
	BCC	NOSPLAT

.SPLATER:
	lda	R_EGGS
	beq	.noegg
	tax
	dex
	stx	W_EGGS

.noegg:
	lda	#SCOFF		;NAME OF DESIRED SOUND HERE
	sta	w_tunenum		;FROM CRKSNDS.TXT
	lda	#1
	sta	w_timer		; save bytes x=0  timer = x,timer

NOEGG:	ldx	#0		; no egg in play 
	STX	W_EGGY		;CHANNEL 0 MEANS EGG SPLAY PRE-EMPTS SHOT	

NOSPLAT:
	RTS
