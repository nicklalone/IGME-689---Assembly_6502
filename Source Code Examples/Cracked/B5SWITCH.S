;	.ORG	$5000+BANKSWITCHSTART
;
;	INTER-BANK JMP
;
;	usage:
;
;	PTR	DESTINATION,BANKJMP
;	JMP	ROMJMP
;
;
ROMJMP5:	
	JMP	(BANKJMP)
	
	LDA	BANKJMP+1	; get high byte of address
	LSR
	LSR
	LSR
	LSR			; index
	TAX
	lda	LOCATION_TABLE5,x
	tax
	sta	STROBE,x
	JMP	(BANKJMP)
;
;
;	INTER-BANK JSR
;
;	usage:
;		PTR	SUBROUTINE,BANKJMP
;		jsr	ROMJSR
;
;
;
;ROMJSR5:	
	STAI	BANK5_STROBE,W_RETURN_BANK  ; which bank we are in now
	LDA	BANKJMP+1		      ; strobe for bank we wish
	LSR			 	      ; to be in
	LSR
	LSR
	LSR
	TAX				     ; bank index
	lda	LOCATION_TABLE5,x             ; table of strobe address offsets
	tax				     ; strobe and
	STA	STROBE,X		     ; call sub 
	JSR	BANKJSR5			     ; in new bank
	LDX	R_RETURN_BANK		     ; strobe to return to
	STA	STROBE,X		     ; callers bank
	RTS				     ; return to caller

BANKJSR5: JMP	(BANKJMP)	; sub returns to caller of BANKJMP
				; ( this bank )


LOCATION_TABLE5:

	.dc.b	0		; 16 4k blocks
	.dc.b	0
	.dc.b	0
	.dc.b	0
	.dc.b	0
	.dc.b	BANK5_STROBE	;OFFSET FOR $5000
	.dc.b	0
	.dc.b	BANK7_STROBE	;OFFSET FOR $7000
	.dc.b	0
	.dc.b	0
	.dc.b	0	
	.dc.b	0
	.dc.b	0
	.dc.b	BANKD_STROBE	; offset for $D000	etc .....
	.dc.b	0
	.dc.b	BANKF_STROBE	; offset for $F000


;	.org	$FFF8	COMMENTED OUT BUT DAMM WELL BETTER BE RIGHT ANYWAY
;	.DC.W	$F7FF
;	.DC.W	NMI
;	.DC.W	START
;	.DC.W	IRQ
