
	;SOUND DRIVER ROUTINE

playit:	;ldx	#1

play:	lda 	x,r_timer
	beq	exit
	sec
	sbc	#1
	sta	x,w_timer
	bne	exit	

NEWTUNE:lda	x,r_tunenum
	tay
	lda	musictab,y

	tay
	lda	ZTIMEORG,y	
	bne	.play1
	sta	x,w_timer
	jmp	exit

.play1:	sta	x,w_timer	
	lda	ZVOLUMEORG,y
	sta	x,AUDV0
	STA	x,AUDVTEMP
	lda 	ZFREQORG,y
	sta	x,AUDF0
	lda	ZCONTROLORG,y
	sta	x,AUDC0			

	lda	x,r_tunenum
	clc
	adc	#1
	sta	x,w_tunenum
exit:	lda	FRMCNT
	and	#$1
	beq	.EXIT1
	LDA	x,AUDVTEMP
	STA	X,AUDV0
	BEQ	.EXIT1
	LDA	x,AUDVTEMP
	sec
	sbc	#1
	STA	x,AUDVTEMP
.EXIT1:	dex
	bpl	play
	rts

