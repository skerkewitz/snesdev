;
; Ullrich von Bassewitz, 10.08.1998
;
; unsigned DbgSetBreakVec (unsigned Addr);
;

    	.export		_DbgSetBreakVec
	.import		popax, utstax
	
	.include	"../cbm/cbm.inc"

_DbgSetBreakVec:
	jsr	popax		; Get the new address
	ldy	BRKVec
	sta	BRKVec
	lda	BRKVec+1
	stx	BRKVec+1
	tax
	tya
	jmp	utstax




