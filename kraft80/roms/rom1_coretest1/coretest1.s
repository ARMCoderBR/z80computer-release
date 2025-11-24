; =============================================================================
;
;   KRAFT 80 Z80 Computer
;   Core Test 1 Program for the Kraft 80 computer
;   2025-Jul-09
;   Milton Maldonado Jr. (ARMCoder)
;
; =============================================================================


; =============================================================================
; --- Hardware Mapping ---
PORTBUTTONS     .equ 0x00 ;PORTX address (Read) 
PORTLEDS        .equ 0x00 ;PORTA address (Write)

ROMBASE         .equ 0
ROMSZ           .equ 0x2000

; =============================================================================
; --- Reset Vector ---

	.area	_HEADER (ABS)

	.org	0x0000			;origem no endereço 00h de memória

; =============================================================================
; --- Main Program ---

	ld	hl,#0xc000
	ld	d,#1

loop:	inc	hl
	ld	a,h
	or	l
	jr	nz,loop

	ld	hl,#0xc000

	in	a,(PORTBUTTONS)
	cpl
	ld	c,a
	ld	a,d
	or	c

	out	(PORTLEDS),a

	rrc	d
	jr	loop

;=======================================================
; --- Final do Programa ---
	.area _DATA

