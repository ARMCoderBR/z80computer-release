
		.module		SPI
		.include	"ch376.h"

		.globl	delay
		.globl	cs_on,cs_off
		.globl	spiread
		.globl	spiwrite
		.globl	send_cmd

		.area	_CODE

		;///////////////////////////////////////////////////////////////////////

send_cmd:	call	delay
		call	delay
		ld	a,(hl)
		call	spiwrite
		inc	hl
		djnz	send_cmd

		ret

		;///////////////////////////////////////////////////////////////////////

cs_on:		call	delay
		call	delay
		ld	a,#0x01			; CS ON
		out	(PORTSPICTL),a
		call	delay
		jp	delay

		;///////////////////////////////////////////////////////////////////////

cs_off:		call	delay
		call	delay
		push	af
		xor	a			; CS OFF
		out	(PORTSPICTL),a
		pop	af
		call	delay
		call	delay
		ret

		;///////////////////////////////////////////////////////////////////////

waitspibusy:	in	a,(PORTSPISTATUS)
		bit	0,a
		jr	nz,waitspibusy
		ret

		;///////////////////////////////////////////////////////////////////////

spiwrite:	out	(PORTSPIDATA),a
		jp	waitspibusy

		;///////////////////////////////////////////////////////////////////////

spiread:	ld	a,#0xff
		call	spiwrite
		call	delay
		call	delay
		in	a,(PORTSPIDATA)
		ret

		;///////////////////////////////////////////////////////////////////////

delay:		nop
		nop
		nop
		nop
		ret

