
.NLIST
.INCLUDE	"HEADER.VCS"
.INCLUDE	"TIAPIA.EQU"
.INCLUDE	"GENERAL.EQU"
.INCLUDE	"MACROS.VCS"
.INCLUDE 	"SMACROS.VCS"

.INCLUDE	"ZERORAM.EQU"

ROMUSED	equ	0
BANKOFF equ 	$100

.list
;**************************************************************
;
;
;	BANK  - 5000   - Ranch and Subroutines
;
;
;***************************************************************
	.org	$5000
.nlist

.INCLUDE	"RSARAM.EQU"
.INCLUDE	"WSARAM.EQU"

.list
	.ORG	$5000 + BANKOFF
;
;	sounds,ranch,payoff
;
.nlist

.INCLUDE 	"RDATA.TXT"
.INCLUDE	"newranch.ker"			; ranch data
.include	"timer.ker"
.INCLUDE	"PROCFALL.S"
.INCLUDE 	"SNDRVR.S"			; SOUND DRIVER
.INCLUDE 	"DOCUR.S"
.INCLUDE	"JOYSTICK.S"
.include	"scoretime.s"
.include	"fire.s"
.INCLUDE	"RSCAN.S"
.include	"hitdet.s"	;move back tp f bank
.include	"initdrop.s"	;move back tp f bank
.INCLUDE	"B5SWITCH.S"

.list
END5000:	NOP
BANKUSED SET  END5000 - $5000
.assert  BANKUSED < $0FFF
ROMUSED SET	ROMUSED + BANKUSED

;**************************************************************
;
;
;	BANK  - 7000  - TREE SCREEN
;
;
;***************************************************************
.ORG	$7000 + BANKOFF
;
;	tree
;
.nlist


.include	"temp.dat"
.INCLUDE	"orfnani.txt"
.include	"TREEKER.KER"
.INCLUDE	"B7SWITCH.S"

.list
END7000:	NOP
BANKUSED SET  END7000 - $7000
.assert  BANKUSED < $0FFF
ROMUSED SET	ROMUSED + BANKUSED
;**************************************************************
;
;
;	BANK  - D000 -Pipe and Bonus
;
;
;***************************************************************
	.ORG $D000 + BANKOFF
;
;	pipe ...
;


.nlist

.include	"bigd.txt"
.include	"PIPEKER.KER"
.INCLUDE	"BONUS.KER"
.INCLUDE	"BDSWITCH.S"
.list
ENDD000:	NOP
BANKUSED SET  ENDD000 - $D000
.assert  BANKUSED < $0FFF
ROMUSED SET	ROMUSED + BANKUSED
;**************************************************************
;
;
;	BANK  - 9000 - Overscan
;
;
;***************************************************************
.ORG   $9000 + BANKOFF
.nlist

.include	"liz.txt"
.INCLUDE	"INANIMAT.S"
.INCLUDE 	"STARTUP.S"
.include	"overscan.s"
NMI:	
IRQ:		RTI
.INCLUDE	"BFSWITCH.S"
.list


END9000:	NOP
BANKUSED SET  END9000 - $9000
.assert  BANKUSED < $0FF0
ROMUSED SET	ROMUSED + BANKUSED

SOUNDS_USED	set	CURRENT
ROMUSED  	set 	ROMUSED
SOMEWASTE 	set 	PAGEWASTE
TOTAL 		SET 	ROMUSED-PAGEWASTE
ZRAM 		SET 	ZEROUSED
SRAM 		SET sarasize
.nlist

tf set TREE_SIZE

;RESTART VECTORS MOVED TO BANK SWITCH LOGIC 
	.org	$FFF8
	.DC.W	$F7FF
	.DC.W	NMI
	.DC.W	START
	.DC.W	IRQ

;******************************************************************************
;
;
;	end - of - file
;
;
;******************************************************************************
.END
