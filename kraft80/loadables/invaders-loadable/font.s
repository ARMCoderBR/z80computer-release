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

		ld	a,(color)
		ld	c,a
		push	hl
		call	print_char
		pop	hl

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

print_string:		; HL = string ptr  DE = screen addr  C = color

		ld	(scraddr),de

		ld	a,c
		ld	(color),a

prints1:
		ld	a,(color)
		ld	c,a
		ld	a,(hl)
		or	a
		ret	z

		ld	b,a
		push	hl
		call	print_char
		pop	hl
		inc	hl
		jr	prints1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

print_number:		; HL = value  DE = screen addr  C = color

		ld	(scraddr),de

		ld	a,c
		ld	(color),a

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

print_char:		; b = char index  c = color

		ld	hl,#font_start
		ld	e,b
		ld	d,#0
		sla	e
		rl	d
		sla	e
		rl	d
		sla	e
		rl	d
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
		ld	b,#4
		ld	h,#128
		
printlb2:	
		ld	a,(de)
		
		ld	l,#0
		and	h
		jr	z,printlb2a
		ld	l,c
		sla	l
		sla	l
		sla	l
		sla	l

printlb2a:	srl	h
		ld	a,(de)
		and	h
		jr	z,printlb2b

		ld	a,c
		or	l
		ld	l,a

printlb2b:	srl	h
		ld	a,l
		out	(PORTDATA),a
		djnz	printlb2		

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

font_start:
		.byte	0b00000000
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

		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11000000
		.byte	0b11001100
		.byte	0b01111000
		.byte	0b00011000
		.byte	0b00001100
		.byte	0b01111000

		.byte	0b00000000
		.byte	0b11001100
		.byte	0b00000000
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00011100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111110
		.byte	0b11000011
		.byte	0b00111100
		.byte	0b00000110
		.byte	0b00111110
		.byte	0b01100110
		.byte	0b00111111
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b11100000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b01111100
		.byte	0b11001100
		.byte	0b01111110
		.byte	0b00000000

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11000000
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00001100
		.byte	0b00111000

		.byte	0b01111110
		.byte	0b11000011
		.byte	0b00111100
		.byte	0b01100110
		.byte	0b01111110
		.byte	0b01100000
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11100000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11000000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11001100
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b01111100
		.byte	0b11000110
		.byte	0b00111000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00011000
		.byte	0b00111100
		.byte	0b00000000

		.byte	0b11100000
		.byte	0b00000000
		.byte	0b01110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00110000
		.byte	0b01111000
		.byte	0b00000000

		.byte	0b11000110
		.byte	0b00111000
		.byte	0b01101100
		.byte	0b11000110
		.byte	0b11111110
		.byte	0b11000110
		.byte	0b11000110
		.byte	0b00000000

		.byte	0b00110000
		.byte	0b00110000
		.byte	0b00000000
		.byte	0b01111000
		.byte	0b11001100
		.byte	0b11111100
		.byte	0b11001100
		.byte	0b00000000

		.byte	0b00011100
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

		.byte	0b00011100
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

		.byte	0b00100010
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

		.byte	0b00011000
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

		.byte	0b00110110
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

		.byte	0b00000000
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

		.byte	0b00000000
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

		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000
		.byte	0b00000000

		.area	DATA

color:		.ds	1
scraddr:	.ds	2

