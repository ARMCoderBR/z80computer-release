;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  15-Oct-2025 - ARMCoder
;  Fonts module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.area	CODE

		.globl	print_string
		.globl	print_number
		.globl	pos_char
		.globl	print_char

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

divnum:		push	de	; Divided HL by BC, ASCII digit result in B
		ld	e,#'0'

divnum1:	scf
		ccf
		sbc	hl,bc
		jr	c,divnum2
		inc	e
		jr	divnum1

divnum2:	add	hl,bc
		ld	b,e
		pop	de
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

procdigit:
		call	divnum

		ld	a,b
		push	hl
		call	print_char2
		pop	hl

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_string:		; HL = string ptr  DE = screen addr  C = color

		ld	(scraddr),de
		call	gen_colors

prints1:	ld	a,(hl)
		or	a
		ret	z

		push	hl
		call	print_char2
		pop	hl
		inc	hl
		jr	prints1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_number:		; HL = value  DE = screen addr  C = color

		ld	(scraddr),de

		call	gen_colors

		ld	bc,#10000
		call	procdigit

		ld	bc,#1000
		call	procdigit

		ld	bc,#100
		call	procdigit

		ld	bc,#10
		call	procdigit

		ld	bc,#1
		call	procdigit

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

pos_char:		; DE = screen addr

		ld	(scraddr),de
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gen_colors:	ld	a,c
		ld	(colortmp1),a	;A7A4=BG A3A0=FG
		rlca
		rlca
		rlca
		rlca
		ld	(colortmp2),a	;A7A4=FG A3A0=BG
		ld	d,a

		and	#0x0f
		ld	e,a
		ld	a,c
		and	#0xf0
		or	e
		ld	(colortmp0),a	;A7A4=BG A3A0=BG

		ld	a,d
		and	#0xf0
		ld	e,a
		ld	a,c
		and	#0x0f
		or	e
		ld	(colortmp3),a	;A7A4=FG A3A0=FG
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_char:		; a = char index   c = color: C7C4=BG C3C0=FG

		ld	l,a
		call	gen_colors
		ld	a,l

print_char2:	ld	de,#font_start
		ld	l,a
		ld	h,#0
		add	hl,hl
		add	hl,hl
		add	hl,hl
		add	hl,de
		ld	d,h
		ld	e,l

		ld	hl,(scraddr)
		ld	b,#8

printlb1:	push	bc
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		push	hl

		ld	hl,#colortmp3
		ld	a,(de)
		ld	b,a
		and	#0xc0
		cp	#0xc0
		jr	z,printlb2
		dec	hl
		cp	#0x80
		jr	z,printlb2
		dec	hl
		cp	#0x40
		jr	z,printlb2
		dec	hl

printlb2:	ld	a,(hl)
		out	(PORTDATA),a

		ld	hl,#colortmp3
		ld	a,b
		and	#0x30
		cp	#0x30
		jr	z,printlb2a
		dec	hl
		cp	#0x20
		jr	z,printlb2a
		dec	hl
		cp	#0x10
		jr	z,printlb2a
		dec	hl

printlb2a:	ld	a,(hl)
		out	(PORTDATA),a

		ld	hl,#colortmp3
		ld	a,b
		and	#0x0c
		cp	#0x0c
		jr	z,printlb2b
		dec	hl
		cp	#0x08
		jr	z,printlb2b
		dec	hl
		cp	#0x04
		jr	z,printlb2b
		dec	hl

printlb2b:	ld	a,(hl)
		out	(PORTDATA),a

		ld	hl,#colortmp3
		ld	a,b
		and	#0x03
		cp	#0x03
		jr	z,printlb2c
		dec	hl
		cp	#0x02
		jr	z,printlb2c
		dec	hl
		cp	#0x01
		jr	z,printlb2c
		dec	hl

printlb2c:	ld	a,(hl)
		out	(PORTDATA),a

		pop	hl

		inc	de
		ld	a,l
		add	a,#BYTES_PER_LINE
		ld	l,a
		jr	nc,printlb3
		inc	h

printlb3:	pop	bc
		djnz	printlb1

		ld	hl,(scraddr)
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		ld	(scraddr),hl

		ret

font_start:	.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b01111110
		.byte	0b10000001
		.byte	0b10100101
		.byte	0b10000001
		.byte	0b10111101
		.byte	0b10011001
		.byte	0b10000001
		.byte	0b01111110

		.byte	0b01111110
		.byte	0b11111111
		.byte	0b11011011
		.byte	0b11111111
		.byte	0b11000011
		.byte	0b11100111
		.byte	0b11111111
		.byte	0b01111110

		.byte	0b01101100
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b01111100
		.byte	0b00111000
		.byte	0b00010000
		.byte	0b00000000

		.byte	0b00010000
		.byte	0b00111000
		.byte	0b01111100
		.byte	0b11111110
		.byte	0b01111100
		.byte	0b00111000
		.byte	0b00010000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01111100
		.byte	0b00111000
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b01111100
		.byte	0b00111000
		.byte	0b01111100

		.byte	0b00010000
		.byte	0b00010000
		.byte	0b00111000
		.byte	0b01111100
		.byte	0b11111110
		.byte	0b01111100
		.byte	0b00111000
		.byte	0b01111100

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11100111
		.byte	0b11000011
		.byte	0b11000011
		.byte	0b11100111
		.byte	0b11111111
		.byte	0b11111111

		.byte	0b00000000
		.byte	0b00111100
		.byte	0b01100110
		.byte	0b01000010
		.byte	0b01000010
		.byte	0b01100110
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11111111
		.byte	0b11000011
		.byte	0b10011001
		.byte	0b10111101
		.byte	0b10111101
		.byte	0b10011001
		.byte	0b11000011
		.byte	0b11111111

		.byte	0b00001111
		.byte	0b00000111
		.byte	0b00001111
		.byte	0b01111101
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000

		.byte	0b00111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b01111110
		.byte	0b00011000

		.byte	0b00111111
		.byte	0b00110011
		.byte	0b00111111
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01110000
		.byte	0b11110000
		.byte	0b11100000

		.byte	0b01111111
		.byte	0b01100011
		.byte	0b01111111
		.byte	0b01100011
		.byte	0b01100011
		.byte	0b01100111
		.byte	0b11100110
		.byte	0b11000000

		.byte	0b10011001
		.byte	0b01011010
		.byte	0b00111100
		.byte	0b11100111
		.byte	0b11100111
		.byte	0b00111100
		.byte	0b01011010
		.byte	0b10011001

		.byte	0b10000000
		.byte	0b11100000
		.byte	0b11111000
		.byte	0b11111110
		.byte	0b11111000
		.byte	0b11100000
		.byte	0b10000000
		.byte	0b00000000

		.byte	0b00000010
		.byte	0b00001110
		.byte	0b00111110
		.byte	0b11111110
		.byte	0b00111110
		.byte	0b00001110
		.byte	0b00000010
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00111100
		.byte	0b01111110
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b01111110
		.byte	0b00111100
		.byte	0b00011000

		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b00000000
		.byte	0b01100110
		.byte	0b00000000

		.byte	0b01111111
		.byte	0b11011011
		.byte	0b11011011
		.byte	0b01111011
		.byte	0b00011011
		.byte	0b00011011
		.byte	0b00011011
		.byte	0b00000000

		.byte	0b00111110
		.byte	0b01100011
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b11001100
		.byte	0b01111000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111110
		.byte	0b01111110
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00111100
		.byte	0b01111110
		.byte	0b00011000
		.byte	0b01111110
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b11111111

		.byte	0b00011000
		.byte	0b00111100
		.byte	0b01111110
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b01111110
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00001100
		.byte	0b11111110
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b11111110
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11111110
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00100100
		.byte	0b01100110
		.byte	0b11111111
		.byte	0b01100110
		.byte	0b00100100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b01111110
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b01111110
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b01111000
		.byte	0b01111000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b01101100
		.byte	0b01101100
		.byte	0b11111110
		.byte	0b01101100
		.byte	0b11111110
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b01111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b11111000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11000110
		.byte	0b11001100
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b01110110
		.byte	0b11011100
		.byte	0b11001100
		.byte	0b01110110
		.byte	0b00000000

		.byte	0b01100000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b01100110
		.byte	0b00111100
		.byte	0b11111111
		.byte	0b00111100
		.byte	0b01100110
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b11111100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01100000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b00000110
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b10000000
		.byte	0b00000000

		.byte	0b01111100
		.byte	0b11000110
		.byte	0b11001110
		.byte	0b11011110
		.byte	0b11110110
		.byte	0b11100110
		.byte	0b01111100
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b00001100
		.byte	0b00111000
		.byte	0b01100000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b00001100
		.byte	0b00111000
		.byte	0b00001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00011100
		.byte	0b00111100
		.byte	0b01101100
		.byte	0b11001100
		.byte	0b11111110
		.byte	0b00001100
		.byte	0b00011110
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b11000000
		.byte	0b11111000
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b11111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b11001100
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111100
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b01110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01100000

		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b00001100
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b01111100
		.byte	0b11000110
		.byte	0b11011110
		.byte	0b11011110
		.byte	0b11011110
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00111100
		.byte	0b01100110
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b01100110
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11111000
		.byte	0b01101100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01101100
		.byte	0b11111000
		.byte	0b00000000

		.byte	0b11111110
		.byte	0b01100010
		.byte	0b01101000
		.byte	0b01111000
		.byte	0b01101000
		.byte	0b01100010
		.byte	0b11111110
		.byte	0b00000000

		.byte	0b11111110
		.byte	0b01100010
		.byte	0b01101000
		.byte	0b01111000
		.byte	0b01101000
		.byte	0b01100000
		.byte	0b11110000
		.byte	0b00000000

		.byte	0b00111100
		.byte	0b01100110
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11001110
		.byte	0b01100110
		.byte	0b00111110
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00011110
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11100110
		.byte	0b01100110
		.byte	0b01101100
		.byte	0b01111000
		.byte	0b01101100
		.byte	0b01100110
		.byte	0b11100110
		.byte	0b00000000

		.byte	0b11110000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100010
		.byte	0b01100110
		.byte	0b11111110
		.byte	0b00000000

		.byte	0b11000110
		.byte	0b11101110
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b11010110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b11000110
		.byte	0b11100110
		.byte	0b11110110
		.byte	0b11011110
		.byte	0b11001110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01111100
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b11110000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11011100
		.byte	0b01111000
		.byte	0b00011100
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01111100
		.byte	0b01101100
		.byte	0b01100110
		.byte	0b11100110
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11100000
		.byte	0b01110000
		.byte	0b00011100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b10110100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b11000110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b11010110
		.byte	0b11111110
		.byte	0b11101110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b11000110
		.byte	0b11000110
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11111110
		.byte	0b11000110
		.byte	0b10001100
		.byte	0b00011000
		.byte	0b00110010
		.byte	0b01100110
		.byte	0b11111110
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11000000
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00001100
		.byte	0b00000110
		.byte	0b00000010
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00010000
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111

		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01110110
		.byte	0b00000000

		.byte	0b11100000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b01111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b11011100
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11000000
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00011100
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01110110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b01100000
		.byte	0b11110000
		.byte	0b01100000
		.byte	0b01100000
		.byte	0b11110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111100
		.byte	0b00001100
		.byte	0b11111000

		.byte	0b11100000
		.byte	0b01100000
		.byte	0b01101100
		.byte	0b01110110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b11100110
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00001100
		.byte	0b00000000
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000

		.byte	0b11100000
		.byte	0b01100000
		.byte	0b01100110
		.byte	0b01101100
		.byte	0b01111000
		.byte	0b01101100
		.byte	0b11100110
		.byte	0b00000000

		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b11010110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11011100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01111100
		.byte	0b01100000
		.byte	0b11110000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111100
		.byte	0b00001100
		.byte	0b00011110

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11011100
		.byte	0b01110110
		.byte	0b01100110
		.byte	0b01100000
		.byte	0b11110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b11111000
		.byte	0b00000000

		.byte	0b00010000
		.byte	0b00110000
		.byte	0b01111100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110100
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01110110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11000110
		.byte	0b11010110
		.byte	0b11111110
		.byte	0b11111110
		.byte	0b01101100
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11000110
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111100
		.byte	0b00001100
		.byte	0b11111000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b10011000
		.byte	0b00110000
		.byte	0b01100100
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00011100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b11100000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00011100
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b11100000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00011100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b11100000
		.byte	0b00000000

		.byte	0b01110110
		.byte	0b11011100
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00010000
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b11111110
		.byte	0b00000000

		.byte	0b01111000	;0x80
		.byte	0b11001100
		.byte	0b11000000
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00011000
		.byte	0b00001100
		.byte	0b01111000

		.byte	0b00000000	;0x81
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00011100	;0x82
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111110	;0x83
		.byte	0b11000011
		.byte	0b00111100
		.byte	0b00000110
		.byte	0b00111110
		.byte	0b01100110
		.byte	0b00111111
		.byte	0b00000000

		.byte	0b11001100	;0x84
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b11100000	;0x85
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00110000	;0x86
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00000000	;0x87
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b00111000

		.byte	0b01111110	;0x88
		.byte	0b11000011
		.byte	0b00111100
		.byte	0b01100110
		.byte	0b01111110
		.byte	0b01100000
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11001100	;0x89
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11100000	;0x8A
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11001100	;0x8B
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111100	;0x8C
		.byte	0b11000110
		.byte	0b00111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11100000	;0x8D
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11000110	;0x8E
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11111110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00110000	;0x8F
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b00011100	;0x90
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b01100000
		.byte	0b01111000
		.byte	0b01100000
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111111
		.byte	0b00001100
		.byte	0b01111111
		.byte	0b11001100
		.byte	0b01111111
		.byte	0b00000000

		.byte	0b00111110
		.byte	0b01101100
		.byte	0b11001100
		.byte	0b11111110
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001110
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11100000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11100000
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111100
		.byte	0b00001100
		.byte	0b11111000

		.byte	0b11000011
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b01111110
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b01111110
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b01100100
		.byte	0b11110000
		.byte	0b01100000
		.byte	0b11100110
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b11111100
		.byte	0b00110000
		.byte	0b11111100
		.byte	0b00110000
		.byte	0b00110000

		.byte	0b11111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11111010
		.byte	0b11000110
		.byte	0b11001111
		.byte	0b11000110
		.byte	0b11000111

		.byte	0b00001110
		.byte	0b00011011
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11011000
		.byte	0b01110000

		.byte	0b00011100	;0xA0
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00011100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00011100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11111000
		.byte	0b00000000
		.byte	0b11111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11101100
		.byte	0b11111100
		.byte	0b11011100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b00111100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00111110
		.byte	0b00000000
		.byte	0b01111110
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b00000000
		.byte	0b01111100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b11000011
		.byte	0b11000110
		.byte	0b11001100
		.byte	0b11011110
		.byte	0b00110011
		.byte	0b01100110
		.byte	0b11001100
		.byte	0b00001111

		.byte	0b11000011
		.byte	0b11000110
		.byte	0b11001100
		.byte	0b11011011
		.byte	0b00110111
		.byte	0b01101111
		.byte	0b11001111
		.byte	0b00000011

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00110011
		.byte	0b01100110
		.byte	0b11001100
		.byte	0b01100110
		.byte	0b00110011
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11001100
		.byte	0b01100110
		.byte	0b00110011
		.byte	0b01100110
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00100010	;0xB0
		.byte	0b10001000
		.byte	0b00100010
		.byte	0b10001000
		.byte	0b00100010
		.byte	0b10001000
		.byte	0b00100010
		.byte	0b10001000

		.byte	0b01010101
		.byte	0b10101010
		.byte	0b01010101
		.byte	0b10101010
		.byte	0b01010101
		.byte	0b10101010
		.byte	0b01010101
		.byte	0b10101010

		.byte	0b11011011
		.byte	0b01110111
		.byte	0b11011011
		.byte	0b11101110
		.byte	0b11011011
		.byte	0b01110111
		.byte	0b11011011
		.byte	0b11101110

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11110110
		.byte	0b00000110
		.byte	0b11110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111110
		.byte	0b00000110
		.byte	0b11110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11110110
		.byte	0b00000110
		.byte	0b11111110
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11111110
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000	;0xC0
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110111
		.byte	0b00110000
		.byte	0b00111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00111111
		.byte	0b00110000
		.byte	0b00110111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11110111
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b11110111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110111
		.byte	0b00110000
		.byte	0b00110111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11110111
		.byte	0b00000000
		.byte	0b11110111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110110	;0xD0
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00111111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b11111111
		.byte	0b00110110
		.byte	0b00110110
		.byte	0b00110110

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111111
		.byte	0b00011000
		.byte	0b11111111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11111000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00011111
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111

		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000
		.byte	0b11110000

		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111
		.byte	0b00001111

		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b11111111
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000	;0xE0
		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11011100
		.byte	0b11001000
		.byte	0b11011100
		.byte	0b01110110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111000
		.byte	0b11001100
		.byte	0b11111000
		.byte	0b11000000
		.byte	0b11000000

		.byte	0b00000000
		.byte	0b11111100
		.byte	0b11001100
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b11111110
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b11001100
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111110
		.byte	0b11011000
		.byte	0b11011000
		.byte	0b11011000
		.byte	0b01110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01100110
		.byte	0b01111100
		.byte	0b01100000
		.byte	0b11000000

		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11011100
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000

		.byte	0b11111100
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00110000
		.byte	0b11111100

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11111110
		.byte	0b11000110
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b11101110
		.byte	0b00000000

		.byte	0b00011100
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111110
		.byte	0b11011011
		.byte	0b11011011
		.byte	0b01111110
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000110
		.byte	0b00001100
		.byte	0b01111110
		.byte	0b11011011
		.byte	0b11011011
		.byte	0b01111110
		.byte	0b01100000
		.byte	0b11000000

		.byte	0b00111000
		.byte	0b01100000
		.byte	0b11000000
		.byte	0b11111000
		.byte	0b11000000
		.byte	0b01100000
		.byte	0b00111000
		.byte	0b00000000

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b00000000	;0xF0
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b00110000
		.byte	0b11111100
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b00110000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000

		.byte	0b00001110
		.byte	0b00011011
		.byte	0b00011011
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000

		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b11011000
		.byte	0b11011000
		.byte	0b01110000

		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b11111100
		.byte	0b00000000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11011100
		.byte	0b00000000
		.byte	0b01110110
		.byte	0b11011100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00111000
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00111000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00011000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00001111
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b00001100
		.byte	0b11101100
		.byte	0b01101100
		.byte	0b00111100
		.byte	0b00011100

		.byte	0b01111000
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b01101100
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b01110000
		.byte	0b00011000
		.byte	0b00110000
		.byte	0b01100000
		.byte	0b01111000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00111100
		.byte	0b00111100
		.byte	0b00111100
		.byte	0b00111100
		.byte	0b00000000
		.byte	0b00000000

		.byte	0b00000000	;0xFF
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.area	DATA

colortmp0:	.ds	1
colortmp1:	.ds	1
colortmp2:	.ds	1
colortmp3:	.ds	1

scraddr:	.ds	2

