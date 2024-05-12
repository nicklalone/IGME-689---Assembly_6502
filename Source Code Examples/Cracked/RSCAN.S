

;
;
;	HMOVE table lookup
;
;
HMLOOK:
;	tya
;	lsr
;	tay
	lda	HMTAB,y
	rts
	

