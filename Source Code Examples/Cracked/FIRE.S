		
	;FIRE BUTTON ROUTINE

FIRE?:	LDY	#0
	LDA	R_SCREEN
	cmp	#INDEMOTREE
	beq	AFIRE
	LDA	INPT4		;assume inpt4 set OFF if fire button pressed
	bmi	.no_fire		;bit 7 is 1 -- fire button not pressed
	ldy	#13
	lda	FIRE_VAL
	beq	.no_fire
	LDY	#77
.no_fire:
	STY	FIRE_VAL	
.exit:	rts

AFIRE:	lda	R_RANDOM
	cmp	#7
	bcs	.no_fire
	ldy	#13
.no_fire:
	STY	FIRE_VAL	
.exit:	rts
