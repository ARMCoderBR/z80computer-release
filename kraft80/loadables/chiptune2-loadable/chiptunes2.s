;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  CHIPTUNES FOR KRAFT 80
;  A chiptune player for the onboard FPGA AY-3-8910 emulation
;  Rev 1.0
;  25-Jul-2025 - ARMCoder
;  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PORTBUTTONS	.equ	0x00	
; VIDEO
PORTDATA	.equ	0x50
PORTADDRL	.equ	0x51
PORTADDRH	.equ	0x52
PORTMODE	.equ	0x53

; AUDIO
PORTAYADDR	.equ	0x56
PORTAYDATA	.equ	0x57

isr2vector	.equ	0x4104	;STACKTOP+4

		.area	CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

chiptunes:	ld	hl,#song_msg
		call	prints

		ld	hl,(isr2vector)
		ld	(isr2vector_copy),hl
		di
		ld	hl,#timer_isr
		ld	(isr2vector),hl

		xor	a
		ld	(delay_cnt),a
		ld	(delay_presc),a
		ei

		call	playtune

		di
		ld	hl,(isr2vector_copy)
		ld	(isr2vector),hl
		ei

		ret

playtune:	ld	hl,#tune_table

playt1:		ld	a,(hl)
		cp	#0xff
		ret	z
		ld	b,a		;B = PSG Reg#
		inc	hl
		ld	c,(hl)		;C = PSG Data
		inc	hl
		cp	#16		;Special "reg" ID, C has delay in 1/60 s ticks
		jr	nz,setreg
		call	delay
		jr	playt1
setreg:		ld	a,b
		out	(PORTAYADDR),a
		ld	a,c	
		out	(PORTAYDATA),a

		jr	playt1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

delay:		di
		xor	a
		ld	(delay_presc),a
		ld	a,c
		ld	(delay_cnt),a
		ei
		
delay1:		ld	a,(delay_cnt)
		or	a
		jr	nz,delay1
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

timer_isr:	ld	a,(delay_presc)
		cp	#4
		jr	nz,timer_isr1
		
		ld	a,(delay_cnt)
		or	a
		jr	z,timer_isr2a
		dec	a
		ld	(delay_cnt),a
		
timer_isr2:	xor	a
timer_isr2a:	ld	(delay_presc),a
		jr	timer_isr3

timer_isr1:	inc	a		
		ld	(delay_presc),a

timer_isr3:	ld	hl,(isr2vector_copy)
		jp	(hl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

prints:		ld	a,(hl)
		or	a
		ret	z
		rst	0x08
		inc	hl
		jr	prints

song_msg:	.ascii "Playing Challenger_1985 (Nemesis / Gradius) - Konami"
		.byte	13,10,0

tune_table:
		.include "challenger.s"

		.area _DATA

isr2vector_copy:.ds	2
delay_cnt:	.ds	1
delay_presc:	.ds	1

