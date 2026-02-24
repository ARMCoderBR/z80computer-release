;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  14-Oct-2025 - ARMCoder
;  Graphics module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.globl	set_screen
		.globl	drawbaseline, clear_lines, clrscr
		.globl	print_cannon, print_invaders, print_sprite, print_bunkers
		.globl	scrpos_invaders, stepping
		.globl	print_cannon_die
		.globl	print_ufo, print_ufo_r, print_ufo_l, clr_ufo
		.globl	mainmenu, menu_update, print_lives

		.module graphics

		.area	CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

set_screen:
		ld	a,#1
		out	(PORTMODE),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawbaseline:
		ld	hl,#BLINE_SCR_OFS
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	b,#PLAY_WIDTH_BYTES
		ld	a,#0xcc		;lightred
bline:		out	(PORTDATA),a
		djnz	bline
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clear_lines:	ld	hl,(scrpos_invaders)

		ld	a,(row_end)
		inc	a
		ld	b,a
		ld	c,#VSTEP
cleanln00:	push	hl
		push	bc

		ld	b,c
		ld	de,#BYTES_PER_LINE

clearln0:	push	bc
		xor	a
		sbc	hl,de

		;;;;;;;;;;;;;;;;;;;;; 1 pixel line

		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		ld	a,(col_start)
		ld	b,a
		ld	a,(col_end)
		sub	b
		inc	a
		add	a,a
		add	a,a
		add	a,a
		ld	b,a
		
		xor	a	;ld	a,#0x44
clearln1:	out	(PORTDATA),a
		djnz	clearln1
		pop	bc
		
		djnz	clearln0

		pop	bc
		pop	hl
		ld	de,#BYTES_PER_LINE*INVADERS_VSPACING
		add	hl,de
		ld	c,#LINESTOCLEAR
		djnz	cleanln00
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clrscr:		xor	a
		out	(PORTADDRL),a
		out	(PORTADDRH),a
		ld	c,#240
clrscr1:	ld	b,#BYTES_PER_LINE
clrscr2:	out	(PORTDATA),a
		djnz	clrscr2
		dec	c
		jr	nz,clrscr1
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_cannon:	ld	hl,#CANNON_SCR_OFS
		ld	a,(cannon_hpos_px)
		bit	0,a
		jr	z,pcan_coleven
		ld	bc,#cannon_odd
		srl	a
		ld	e,a
		ld	d,#0
		add	hl,de		; hl = screen mem pos
		jp	print_sprite

pcan_coleven:	ld	bc,#cannon_even
		srl	a
		ld	e,a
		ld	d,#0
		add	hl,de		; hl = screen mem pos
		dec	hl
		jp	print_sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_cannon_die:
		ld	hl,#CANNON_SCR_OFS
		ld	a,(cannon_hpos_px)
		bit	0,a
		jr	z,pcan_dieeven
		srl	a
		ld	e,a
		ld	d,#0
		add	hl,de		; hl = screen mem pos
		ld	bc,#cannondie1odd
		ld	a,(playerdie_state)
		bit	4,a
		jp	z,print_sprite
		ld	bc,#cannondie2odd
		jp	print_sprite

pcan_dieeven:	srl	a
		ld	e,a
		ld	d,#0
		add	hl,de		; hl = screen mem pos
		dec	hl
		ld	bc,#cannondie1even
		ld	a,(playerdie_state)
		bit	4,a
		jp	z,print_sprite
		ld	bc,#cannondie2even
		jp	print_sprite

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_invaders:	ld	hl,(scrpos_invaders)
		ld	(spritepos),hl

		ld	hl,#invader_matrix
		ld	a,(col_start)
		ld	e,a
		ld	d,#0
		add	hl,de
		ld	(invader_matnow),hl
		ld	(invader_matnow2),hl
		
		xor	a		; Row

print_inv1:	ld	(row_now),a

		ld	hl,(spritepos)
		ld	(spritenow),hl
		
		ld	a,(col_start)

print_inv1a:	ld	(col_now),a	; Invader row
		
		ld	hl,(invader_matnow2)
		ld	a,(hl)
		inc	hl
		ld	(invader_matnow2),hl
		or	a
		jr	z,blk		; No invader here, blank
		
		ld	a,(row_now)	; Invader type here
		add	a,a
		ld	b,a
		ld	a,(stepping)
		add	a,b
		or	a
		jr	z,sq1a
		dec	a
		jr	z,sq1b
		dec	a
		jr	z,cr1a
		dec	a
		jr	z,cr1b
		dec	a
		jr	z,cr2a
		dec	a
		jr	z,cr2b
		dec	a
		jr	z,oc1a
		dec	a
		jr	z,oc1b
		dec	a
		jr	z,oc2a
		dec	a
		jr	z,oc2b
		
blk:		ld	bc,#blank
		jr	sprok
sq1a:		ld	bc,#squid1a
		jr	sprok
sq1b:		ld	bc,#squid1b
		jr	sprok
cr1a:		ld	bc,#crab1a
		jr	sprok
cr1b:		ld	bc,#crab1b
		jr	sprok
cr2a:		ld	bc,#crab2a
		jr	sprok
cr2b:		ld	bc,#crab2b
		jr	sprok
oc1a:		ld	bc,#octo1a
		jr	sprok
		
sprok:		ld	hl,(spritenow)
		push	hl
		call	print_sprite
		pop	hl
		ld	de,#8
		add	hl,de
		ld	(spritenow),hl
		
		ld	a,(col_now)
		ld	b,a
		ld	a,(col_end)
		cp	b
		jr	z,print_inv2

		inc	b
		ld	a,b
		jr	print_inv1a	; End invader row

oc1b:		ld	bc,#octo1b
		jr	sprok
oc2a:		ld	bc,#octo2a
		jr	sprok
oc2b:		ld	bc,#octo2b
		jr	sprok
		
print_inv2:	ld	hl,(spritepos)
		ld	de,#BYTES_PER_LINE*INVADERS_VSPACING
		add	hl,de
		ld	(spritepos),hl

		ld	hl,(invader_matnow)
		ld	de,#INVADER_COLS
		add	hl,de
		ld	(invader_matnow),hl
		ld	(invader_matnow2),hl

		ld	a,(row_now)
		ld	b,a
		ld	a,(row_end)
		cp	b
		ret	z
		inc	b
		ld	a,b

		jp	print_inv1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_sprite:	ld	d,b		; bc = sprite  hl = scrpos
		ld	e,c
		ld	c,#8
printlb1:	ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		ld	b,#8
printlb2:	ld	a,(de)
		out	(PORTDATA),a
		inc	de
		djnz	printlb2

		ld	a,l
		add	a,#BYTES_PER_LINE
		ld	l,a
		jr	nc,printlb3
		inc	h

printlb3:	dec	c
		jr	nz,printlb1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_bunkers:	ld	hl,#BUNKER1_SCR_OFS
		call	print_bunker
		ld	hl,#BUNKER2_SCR_OFS
		call	print_bunker
		ld	hl,#BUNKER3_SCR_OFS
		call	print_bunker
		ld	hl,#BUNKER4_SCR_OFS
		call	print_bunker
		ret
		
print_bunker:	; HL = screen position
		
		; Row 1
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		xor	a
		out	(PORTDATA),a
		out	(PORTDATA),a
		ld	b,#7
		call	print_bunkline

		ld	de,#BYTES_PER_LINE

		; Row 2
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		xor	a
		out	(PORTDATA),a
		ld	a,#0x0c
		out	(PORTDATA),a
		ld	b,#7
		call	print_bunkline
		ld	a,#0xc0
		out	(PORTDATA),a

		; Row 3
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		xor	a
		out	(PORTDATA),a
		ld	b,#9
		call	print_bunkline

		; Row 4
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	a,#0x0c
		out	(PORTDATA),a
		ld	b,#9
		call	print_bunkline
		ld	a,#0xc0
		out	(PORTDATA),a

		; Rows 5-12
		ld	b,#8
pbunk5:		push	bc
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	b,#11
		call	print_bunkline
		pop	bc
		djnz	pbunk5

		; Row 13
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	b,#4
		call	print_bunkline
		xor	a
		out	(PORTDATA),a
		out	(PORTDATA),a
		out	(PORTDATA),a
		ld	b,#4
		call	print_bunkline

		; Row 14
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	b,#3
		call	print_bunkline
		ld	a,#0xc0
		out	(PORTDATA),a
		xor	a
		out	(PORTDATA),a
		out	(PORTDATA),a
		out	(PORTDATA),a
		ld	a,#0x0c
		out	(PORTDATA),a
		ld	b,#3
		call	print_bunkline

		; Rows 15-16
		ld	b,#2
pbunk15:	push	bc
		add	hl,de
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		ld	b,#3
		call	print_bunkline
		xor	a
		out	(PORTDATA),a
		out	(PORTDATA),a
		out	(PORTDATA),a
		out	(PORTDATA),a
		out	(PORTDATA),a
		ld	b,#3
		call	print_bunkline
		pop	bc
		djnz	pbunk15

		ret

print_bunkline:	ld	a,#0xcc

pbunkl:		out	(PORTDATA),a
		djnz	pbunkl
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_lives:
		push	af

		ld	d,#6
		ld	hl,#LIVES_SCR_OFS
printlv1:	push	de
		ld	bc,#blank
		push	hl
		call	print_sprite
		pop	hl
		ld	de,#8
		add	hl,de
		pop	de
		dec	d
		jr	nz,printlv1

		pop	af

		or	a
		ret	z

		ld	d,a
		ld	hl,#LIVES_SCR_OFS
printlv2:	push	de
		ld	bc,#cannon_odd
		push	hl
		call	print_sprite
		pop	hl
		ld	de,#8
		add	hl,de
		pop	de
		dec	d
		jr	nz,printlv2

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; CGA Colors
;; 0 BLACK      8 DARKGRAY
;; 1 BLUE       9 LIGHTBLUE
;; 2 GREEN     10 LIGHTGREEN
;; 3 CYAN      11 LIGHTCYAN
;; 4 RED       12 LIGHTRED
;; 5 MAGENTA   13 LIGHTMAGENTA
;; 6 BROWN     14 YELLOW
;; 7 GRAY      15 WHITE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; BLANK (NO COLOR) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ........ ........
;; ........ ........
;; ........ ........
;; ........ ........
;; ........ ........
;; ........ ........
;; ........ ........
;; ........ ........
blank:		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SQUID1 (LIGHTGREEN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......# #.......
;; ......## ##......
;; .....### ###.....
;; ....##.# #.##....
;; ....#### ####....
;; ......#. .#......
;; .....#.# #.#.....
;; ....#.#. .#.#....
squid1a:	.byte	0x00,0x00,0x00,0x0a, 0xa0,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0xaa, 0xaa,0x00,0x00,0x00
		.byte	0x00,0x00,0x0a,0xaa, 0xaa,0xa0,0x00,0x00
		.byte	0x00,0x00,0xaa,0x0a, 0xa0,0xaa,0x00,0x00
		.byte	0x00,0x00,0xaa,0xaa, 0xaa,0xaa,0x00,0x00
		.byte	0x00,0x00,0x00,0xa0, 0x0a,0x00,0x00,0x00
		.byte	0x00,0x00,0x0a,0x0a, 0xa0,0xa0,0x00,0x00
		.byte	0x00,0x00,0xa0,0xa0, 0x0a,0x0a,0x00,0x00

;; .......# #.......
;; ......## ##......
;; .....### ###.....
;; ....##.# #.##....
;; ....#### ####....
;; .....#.# #.#.....
;; ....#... ...#....
;; .....#.. ..#.....
squid1b:	.byte	0x00,0x00,0x00,0x0a, 0xa0,0x00,0x00,0x00
		.byte	0x00,0x00,0x00,0xaa, 0xaa,0x00,0x00,0x00
		.byte	0x00,0x00,0x0a,0xaa, 0xaa,0xa0,0x00,0x00
		.byte	0x00,0x00,0xaa,0x0a, 0xa0,0xaa,0x00,0x00
		.byte	0x00,0x00,0xaa,0xaa, 0xaa,0xaa,0x00,0x00
		.byte	0x00,0x00,0x0a,0x0a, 0xa0,0xa0,0x00,0x00
		.byte	0x00,0x00,0xa0,0x00, 0x00,0x0a,0x00,0x00
		.byte	0x00,0x00,0x0a,0x00, 0x00,0xa0,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CRAB1 (LIGHTGREEN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ....#... ..#.....
;; ..#..#.. .#..#...
;; ..#.#### ###.#...
;; ..###.## #.###...
;; ..###### #####...
;; ...##### ####....
;; ....#... ..#.....
;; ...#.... ...#....
crab1a:		.byte	0x00,0x00,0xa0,0x00, 0x00,0xa0,0x00,0x00
		.byte	0x00,0xa0,0x0a,0x00, 0x0a,0x00,0xa0,0x00
		.byte	0x00,0xa0,0xaa,0xaa, 0xaa,0xa0,0xa0,0x00
		.byte	0x00,0xaa,0xa0,0xaa, 0xa0,0xaa,0xa0,0x00
		.byte	0x00,0xaa,0xaa,0xaa, 0xaa,0xaa,0xa0,0x00
		.byte	0x00,0x0a,0xaa,0xaa, 0xaa,0xaa,0x00,0x00
		.byte	0x00,0x00,0xa0,0x00, 0x00,0xa0,0x00,0x00
		.byte	0x00,0x0a,0x00,0x00, 0x00,0x0a,0x00,0x00

;; ....#... ..#.....
;; .....#.. .#......
;; ....#### ### ....
;; ...##.## #.##....
;; ..###### #####...
;; ..#.#### ###.#...
;; ..#.#... ..#.#...
;; .....##. ##......
crab1b:		.byte	0x00,0x00,0xa0,0x00, 0x00,0xa0,0x00,0x00
		.byte	0x00,0x00,0x0a,0x00, 0x0a,0x00,0x00,0x00
		.byte	0x00,0x00,0xaa,0xaa, 0xaa,0xa0,0x00,0x00
		.byte	0x00,0x0a,0xa0,0xaa, 0xa0,0xaa,0x00,0x00
		.byte	0x00,0xaa,0xaa,0xaa, 0xaa,0xaa,0xa0,0x00
		.byte	0x00,0xa0,0xaa,0xaa, 0xaa,0xa0,0xa0,0x00
		.byte	0x00,0xa0,0xa0,0x00, 0x00,0xa0,0xa0,0x00
		.byte	0x00,0x00,0x0a,0xa0, 0xaa,0x00,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CRAB2 (LIGHTCYAN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ....#... ..#.....
;; ..#..#.. .#..#...
;; ..#.#### ###.#...
;; ..###.## #.###...
;; ..###### #####...
;; ...##### ####....
;; ....#... ..#.....
;; ...#.... ...#....
crab2a:		.byte	0x00,0x00,0xb0,0x00, 0x00,0xb0,0x00,0x00
		.byte	0x00,0xb0,0x0b,0x00, 0x0b,0x00,0xb0,0x00
		.byte	0x00,0xb0,0xbb,0xbb, 0xbb,0xb0,0xb0,0x00
		.byte	0x00,0xbb,0xb0,0xbb, 0xb0,0xbb,0xb0,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xb0,0x00
		.byte	0x00,0x0b,0xbb,0xbb, 0xbb,0xbb,0x00,0x00
		.byte	0x00,0x00,0xb0,0x00, 0x00,0xb0,0x00,0x00
		.byte	0x00,0x0b,0x00,0x00, 0x00,0x0b,0x00,0x00

;; ....#... ..#.....
;; .....#.. .#......
;; ....#### ### ....
;; ...##.## #.##....
;; ..###### #####...
;; ..#.#### ###.#...
;; ..#.#... ..#.#...
;; .....##. ##......
crab2b:		.byte	0x00,0x00,0xb0,0x00, 0x00,0xb0,0x00,0x00
		.byte	0x00,0x00,0x0b,0x00, 0x0b,0x00,0x00,0x00
		.byte	0x00,0x00,0xbb,0xbb, 0xbb,0xb0,0x00,0x00
		.byte	0x00,0x0b,0xb0,0xbb, 0xb0,0xbb,0x00,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xb0,0x00
		.byte	0x00,0xb0,0xbb,0xbb, 0xbb,0xb0,0xb0,0x00
		.byte	0x00,0xb0,0xb0,0x00, 0x00,0xb0,0xb0,0x00
		.byte	0x00,0x00,0x0b,0xb0, 0xbb,0x00,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; OCTO1 (LIGHTCYAN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ......## ##......
;; ...##### #####...
;; ..###### ######..
;; ..###..# #..###..
;; ..###### ######..
;; .....##. .##.....
;; ....##.# #.##....
;; ..##.... ....##..
octo1a:		.byte	0x00,0x00,0x00,0xbb, 0xbb,0x00,0x00,0x00
		.byte	0x00,0x0b,0xbb,0xbb, 0xbb,0xbb,0xb0,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x00,0xbb,0xb0,0x0b, 0xb0,0x0b,0xbb,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x00,0x00,0x0b,0xb0, 0x0b,0xb0,0x00,0x00
		.byte	0x00,0x00,0xbb,0x0b, 0xb0,0xbb,0x00,0x00
		.byte	0x00,0xbb,0x00,0x00, 0x00,0x00,0xbb,0x00

;; ......## ##......
;; ...##### #####...
;; ..###### ######..
;; ..###..# #..###..
;; ..###### ######..
;; ....###. .###....
;; ...##..# #..##...
;; ....##.. ..##....
octo1b:		.byte	0x00,0x00,0x00,0xbb, 0xbb,0x00,0x00,0x00
		.byte	0x00,0x0b,0xbb,0xbb, 0xbb,0xbb,0xb0,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x00,0xbb,0xb0,0x0b, 0xb0,0x0b,0xbb,0x00
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x00,0x00,0xbb,0xb0, 0x0b,0xbb,0x00,0x00
		.byte	0x00,0x0b,0xb0,0x0b, 0xb0,0x0b,0xb0,0x00
		.byte	0x00,0x00,0xbb,0x00, 0x00,0xbb,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;; OCTO2 (LIGHTMAGENTA) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ......## ##......
;; ...##### #####...
;; ..###### ######..
;; ..###..# #..###..
;; ..###### ######..
;; .....##. .##.....
;; ....##.# #.##....
;; ..##.... ....##..
octo2a:		.byte	0x00,0x00,0x00,0xdd, 0xdd,0x00,0x00,0x00
		.byte	0x00,0x0d,0xdd,0xdd, 0xdd,0xdd,0xd0,0x00
		.byte	0x00,0xdd,0xdd,0xdd, 0xdd,0xdd,0xdd,0x00
		.byte	0x00,0xdd,0xd0,0x0d, 0xd0,0x0d,0xdd,0x00
		.byte	0x00,0xdd,0xdd,0xdd, 0xdd,0xdd,0xdd,0x00
		.byte	0x00,0x00,0x0d,0xd0, 0x0d,0xd0,0x00,0x00
		.byte	0x00,0x00,0xdd,0x0d, 0xd0,0xdd,0x00,0x00
		.byte	0x00,0xdd,0x00,0x00, 0x00,0x00,0xdd,0x00

;; ......## ##......
;; ...##### #####...
;; ..###### ######..
;; ..###..# #..###..
;; ..###### ######..
;; ....###. .###....
;; ...##..# #..##...
;; ....##.. ..##....
octo2b:		.byte	0x00,0x00,0x00,0xdd, 0xdd,0x00,0x00,0x00
		.byte	0x00,0x0d,0xdd,0xdd, 0xdd,0xdd,0xd0,0x00
		.byte	0x00,0xdd,0xdd,0xdd, 0xdd,0xdd,0xdd,0x00
		.byte	0x00,0xdd,0xd0,0x0d, 0xd0,0x0d,0xdd,0x00
		.byte	0x00,0xdd,0xdd,0xdd, 0xdd,0xdd,0xdd,0x00
		.byte	0x00,0x00,0xdd,0xd0, 0x0d,0xdd,0x00,0x00
		.byte	0x00,0x0d,0xd0,0x0d, 0xd0,0x0d,0xd0,0x00
		.byte	0x00,0x00,0xdd,0x00, 0x00,0xdd,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;; LASER BASE (LIGHTCYAN) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; .......# ........
;; ......## #.......
;; ......## #.......
;; ..###### #####...
;; .####### ######..
;; .####### ######..
;; .####### ######..
;; .####### ######..
cannon_odd:	.byte	0x00,0x00,0x00,0x0b, 0x00,0x00,0x00,0x00
  		.byte	0x00,0x00,0x00,0xbb, 0xb0,0x00,0x00,0x00
  		.byte	0x00,0x00,0x00,0xbb, 0xb0,0x00,0x00,0x00
  		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xb0,0x00
  		.byte	0x0b,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
  		.byte	0x0b,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
  		.byte	0x0b,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
  		.byte	0x0b,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00

;; ........ #.......
;; .......# ##......
;; .......# ##......
;; ...##### ######..
;; ..###### #######.
;; ..###### #######.
;; ..###### #######.
;; ..###### #######.
cannon_even:	.byte	0x00,0x00,0x00,0x00, 0xb0,0x00,0x00,0x00
  		.byte	0x00,0x00,0x00,0x0b, 0xbb,0x00,0x00,0x00
  		.byte	0x00,0x00,0x00,0x0b, 0xbb,0x00,0x00,0x00
  		.byte	0x00,0x0b,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
  		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0
  		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0
  		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0
  		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0

;; ........ ........
;; ...#..## ...#....
;; ........ #.#.....
;; ..#.#.## ####.#..
;; .##.###. .####...
;; .#.##### ######..
;; ..###.## ######..
;; .####### ######..
cannondie1odd:	.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x0b,0x00,0xbb, 0x00,0x0b,0x00,0x00
		.byte	0x00,0x00,0x00,0x00, 0xb0,0xb0,0x00,0x00
		.byte	0x00,0xb0,0xb0,0xbb, 0xbb,0xbb,0x0b,0x00
		.byte	0x0b,0xb0,0xbb,0xb0, 0x0b,0xbb,0xb0,0x00
		.byte	0x0b,0x0b,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x00,0xbb,0xb0,0xbb, 0xbb,0xbb,0xbb,0x00
		.byte	0x0b,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0x00

;; ........ ........
;; .#.#..#. .###....
;; ....#... #.#.....
;; .##.#.## ####....
;; ..###.## .####...
;; .#.##### ###.##..
;; ..##..## .#####..
;; .#.##### .#####..
cannondie2odd:	.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x0b,0x0b,0x00,0xb0, 0x0b,0xbb,0x00,0x00
		.byte	0x00,0x00,0xb0,0x00, 0xb0,0xb0,0x00,0x00
		.byte	0x0b,0xb0,0xb0,0xbb, 0xbb,0xbb,0x00,0x00
		.byte	0x00,0xbb,0xb0,0xbb, 0x0b,0xbb,0xb0,0x00
		.byte	0x0b,0x0b,0xbb,0xbb, 0xbb,0xb0,0xbb,0x00
		.byte	0x00,0xbb,0x00,0xbb, 0x0b,0xbb,0xbb,0x00
		.byte	0x0b,0x0b,0xbb,0xbb, 0x0b,0xbb,0xbb,0x00

;; ........ ........
;; ....#..# #...#...
;; ........ .#.#....
;; ...#.#.# #####.#.
;; ..##.### ..####..
;; ..#.#### #######.
;; ...###.# #######.
;; ..###### #######.
cannondie1even:	.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0xb0,0x0b, 0xb0,0x00,0xb0,0x00
		.byte	0x00,0x00,0x00,0x00, 0x0b,0x0b,0x00,0x00
		.byte	0x00,0x0b,0x0b,0x0b, 0xbb,0xbb,0xb0,0xb0
		.byte	0x00,0xbb,0x0b,0xbb, 0x00,0xbb,0xbb,0x00
		.byte	0x00,0x0b,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0
		.byte	0x00,0x0b,0xbb,0x0b, 0xbb,0xbb,0xbb,0xb0
		.byte	0x00,0xbb,0xbb,0xbb, 0xbb,0xbb,0xbb,0xb0

;; ........ ........
;; ..#.#..# ..###...
;; .....#.. .#.#....
;; ..##.#.# #####...
;; ...###.# #.####..
;; ..#.#### ####.##.
;; ...##..# #.#####.
;; ..#.#### #.#####.
cannondie2even:	.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0xb0,0xb0,0x0b, 0x00,0xbb,0xb0,0x00
		.byte	0x00,0x00,0x0b,0x00, 0x0b,0x0b,0x00,0x00
		.byte	0x00,0xbb,0x0b,0x0b, 0xbb,0xbb,0xb0,0x00
		.byte	0x00,0x0b,0xbb,0x0b, 0xb0,0xbb,0xbb,0x00
		.byte	0x00,0xb0,0xbb,0xbb, 0xbb,0xbb,0x0b,0xb0
		.byte	0x00,0x0b,0xb0,0x0b, 0xb0,0xbb,0xbb,0xb0
		.byte	0x00,0xb0,0xbb,0xbb, 0xb0,0xbb,0xbb,0xb0

;; ........ ........
;; .....### ###.....
;; ...##### #####...
;; ..###### ######..
;; .##.##.# #.##.##.
;; #######. .#######
;; ..###..# #..###..
;; ...#.... ....#...
ufo:		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x00,0x0c,0xcc, 0xcc,0xc0,0x00,0x00
		.byte	0x00,0x0c,0xcc,0xcc, 0xcc,0xcc,0xc0,0x00
		.byte	0x00,0xcc,0xcc,0xcc, 0xcc,0xcc,0xcc,0x00
		.byte	0x0c,0xc0,0xcc,0x0c, 0xc0,0xcc,0x0c,0xc0
		.byte	0xcc,0xcc,0xcc,0xc0, 0x0c,0xcc,0xcc,0xcc
		.byte	0x00,0xcc,0xc0,0x0c, 0xc0,0x0c,0xcc,0x00
		.byte	0x00,0x0c,0x00,0x00, 0x00,0x00,0xc0,0x00

;; ........ ........
;; ...#...# #...##..
;; ..##..#. .#.#..#.
;; ...#..#. .#.#..#.
;; ...#..#. .#.#..#.
;; ...#..#. .#.#..#.
;; ..###..# #...##..
;; ........ ........
ufo100:		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x0a,0x00,0x0a, 0xa0,0x00,0xaa,0x00
		.byte	0x00,0xaa,0x00,0xa0, 0x0a,0x0a,0x00,0xa0
		.byte	0x00,0x0a,0x00,0xa0, 0x0a,0x0a,0x00,0xa0
		.byte	0x00,0x0a,0x00,0xa0, 0x0a,0x0a,0x00,0xa0
		.byte	0x00,0x0a,0x00,0xa0, 0x0a,0x0a,0x00,0xa0
		.byte	0x00,0xaa,0xa0,0x0a, 0xa0,0x00,0xaa,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00

;; ........ ........
;; ..##...# #...##..
;; .#..#.#. .#.#..#.
;; ....#.#. .#.#..#.
;; ..##..#. .#.#..#.
;; .#....#. .#.#..#.
;; .####..# #...##..
;; ........ ........
ufo200:		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0xdd,0x00,0x0d, 0xd0,0x00,0xdd,0x00
		.byte	0x0d,0x00,0xd0,0xd0, 0x0d,0x0d,0x00,0xd0
		.byte	0x00,0x00,0xd0,0xd0, 0x0d,0x0d,0x00,0xd0
		.byte	0x00,0xdd,0x00,0xd0, 0x0d,0x0d,0x00,0xd0
		.byte	0x0d,0x00,0x00,0xd0, 0x0d,0x0d,0x00,0xd0
		.byte	0x0d,0xdd,0xd0,0x0d, 0xd0,0x00,0xdd,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00

;; ........ ........
;; ...#...# #...##..
;; ..##..#. .#.#..#.
;; .#.#..#. .#.#..#.
;; .####.#. .#.#..#.
;; ...#..#. .#.#..#.
;; ...#...# #...##..
;; ........ ........
ufo400:		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00
		.byte	0x00,0x0e,0x00,0x0e, 0xe0,0x00,0xee,0x00
		.byte	0x00,0xee,0x00,0xe0, 0x0e,0x0e,0x00,0xe0
		.byte	0x0e,0x0e,0x00,0xe0, 0x0e,0x0e,0x00,0xe0
		.byte	0x0e,0xee,0xe0,0xe0, 0x0e,0x0e,0x00,0xe0
		.byte	0x00,0x0e,0x00,0xe0, 0x0e,0x0e,0x00,0xe0
		.byte	0x00,0x0e,0x00,0x0e, 0xe0,0x00,0xee,0x00
		.byte	0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_ufo:				; a = pos X	;b = sprite 0=UFO, 1=UFO100, 2=UFO200, 3=UFO400
		ld	hl,#(BYTES_PER_LINE*8 + LEFT_OFFSET_BYTES)

		cp	#8
		jr	nc,print_ufo2

		; ufo_x < 8

		sub	#7
		neg
		jp	print_ufo_r

print_ufo2:
		cp	#(PLAY_WIDTH_BYTES-1)
		jr	c,print_ufo3

		; 111 <= ufo_x <= 118

		ld	hl,#(BYTES_PER_LINE*8 + LEFT_OFFSET_BYTES + PLAY_WIDTH_BYTES-9)
		sub	#(PLAY_WIDTH_BYTES-1)
		ld	e,a
		ld	d,#0
		add	hl,de
		neg
		dec	a
		and	#7
		jp	print_ufo_l

print_ufo3:	; 8 <= ufo_x <= 110

		sub	#8
		ld	hl,#(BYTES_PER_LINE*8 + LEFT_OFFSET_BYTES)
		ld	e,a
		ld	d,#0
		add	hl,de
		jr	print_ufo_lr

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_ufo_lr:	ld	de,#ufo100
		dec	b
		jr	z,ufolr1
		ld	de,#ufo200
		dec	b
		jr	z,ufolr1
		ld	de,#ufo400
		dec	b
		jr	z,ufolr1

		ld	de,#ufo		; hl = scrpos

ufolr1:		ld	c,#8
print_ufo_lr1:	ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		xor	a		; blank left
		out	(PORTDATA),a
		ld	b,#8
print_ufo_lr2:	ld	a,(de)
		out	(PORTDATA),a
		inc	de
		djnz	print_ufo_lr2
		xor	a		; blank right
		out	(PORTDATA),a

		ld	a,l
		add	a,#BYTES_PER_LINE
		ld	l,a
		jr	nc,print_ufo_lr3
		inc	h

print_ufo_lr3:	dec	c
		jr	nz,print_ufo_lr1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_ufo_r:	ld	de,#ufo100
		dec	b
		jr	z,ufor1
		ld	de,#ufo200
		dec	b
		jr	z,ufor1
		ld	de,#ufo400
		dec	b
		jr	z,ufor1

		ld	de,#ufo		; hl = scrpos, a = start col (0..7)

ufor1:		push	af
		add	a,e
		ld	e,a
		jr	nc,print_ufo_r1
		inc	d
print_ufo_r1:	pop	af

		xor	#7
		ld	b,a
		inc	b		; B = number of cols

		ld	c,#8		; number of rows

print_ufo_r2:	; Print row
		push	hl

		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		push	bc
print_ufo_r3:
		ld	a,(de)
		out	(PORTDATA),a
		inc	de
		djnz	print_ufo_r3
		xor	a		; blank right
		out	(PORTDATA),a
		
		pop	bc

		pop	hl
		push	de
		ld	de,#BYTES_PER_LINE
		add	hl,de
		pop	de

		ld	a,b
		and	#7
		xor	#7
		inc	a
		and	#7
		add	a,e
		ld	e,a
		jr	nc,print_ufo_r4
		inc	d
print_ufo_r4:
		dec	c
		jr	nz,print_ufo_r2

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print_ufo_l:	ld	de,#ufo100
		dec	b
		jr	z,ufol1
		ld	de,#ufo200
		dec	b
		jr	z,ufol1
		ld	de,#ufo400
		dec	b
		jr	z,ufol1

		ld	de,#ufo		; hl = scrpos, a = end col (0..7)

ufol1:		inc	a
		ld	b,a
		ld	c,#8		; number of rows

print_ufo_l1:	; Print row
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		xor	a		; blank left
		out	(PORTDATA),a
		push	bc
print_ufo_l2:
		ld	a,(de)
		out	(PORTDATA),a
		inc	de
		djnz	print_ufo_l2
		pop	bc

		push	de
		ld	de,#BYTES_PER_LINE
		add	hl,de
		pop	de

		ld	a,b
		sub	#8
		neg
		add	a,e
		ld	e,a
		jr	nc,print_ufo_l3
		inc	d
print_ufo_l3:
		dec	c
		jr	nz,print_ufo_l1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

clr_ufo:	ld	hl,#(BYTES_PER_LINE*8 + LEFT_OFFSET_BYTES)
		ld	de,#BYTES_PER_LINE

		ld	c,#8
clr_ufo1:	ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		xor	a
		ld	b,#PLAY_WIDTH_BYTES

clr_ufo2:	out	(PORTDATA),a
		djnz	clr_ufo2

		add	hl,de
		dec	c
		jr	nz,clr_ufo1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menuborder:	ld	de,#0
		call	pos_char
		ld	b,#20

menub1:		push	bc
		ld	a,#0xb1
		ld	c,#0x9f
		call	print_char
		ld	a,#0x20
		ld	c,#0x9f
		call	print_char
		pop	bc
		djnz	menub1
		ld	b,#14
		ld	hl,#(8*BYTES_PER_LINE)

menub2:		ld	d,h
		ld	e,l
		call	pos_char
		push	bc
		ld	a,#0x20
		ld	c,#0x9f
		push	hl
		call	print_char
		pop	hl
		ld	de,#(8*BYTES_PER_LINE)
		add	hl,de
		ld	d,h
		ld	e,l
		call	pos_char
		ld	a,#0xb1
		ld	c,#0x9f
		push	hl
		call	print_char
		pop	hl
		pop	bc
		ld	de,#(8*BYTES_PER_LINE)
		add	hl,de
		djnz	menub2
		ld	de,#(232*BYTES_PER_LINE)
		call	pos_char
		ld	b,#20
menub3:		push	bc
		ld	a,#0x20
		ld	c,#0x9f
		call	print_char
		ld	a,#0xb1
		ld	c,#0x9f
		call	print_char
		pop	bc
		djnz	menub3
		ld	b,#14
		ld	hl,#(8*BYTES_PER_LINE)+BYTES_PER_CHAR_W*39
menub4:		ld	d,h
		ld	e,l
		call	pos_char
		push	bc
		ld	a,#0xb1
		ld	c,#0x9f
		push	hl
		call	print_char
		pop	hl
		ld	de,#(8*BYTES_PER_LINE)
		add	hl,de
		ld	d,h
		ld	e,l
		call	pos_char
		ld	a,#0x20
		ld	c,#0x9f
		push	hl
		call	print_char
		pop	hl
		pop	bc
		ld	de,#(8*BYTES_PER_LINE)
		add	hl,de
		djnz	menub4
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mainmenu:	call	menuborder

		ld	hl,#titlestr
		ld	de,#(24*BYTES_PER_LINE)+BYTES_PER_CHAR_W*6
		ld	c,#0x06
		call	print_string

		ld	hl,#titlestr1
		ld	de,#(38*BYTES_PER_LINE)+BYTES_PER_CHAR_W*5
		ld	c,#0x08
		call	print_string

		ld	hl,#titlestr2
		ld	de,#(52*BYTES_PER_LINE)+BYTES_PER_CHAR_W*4
		ld	c,#0x08
		call	print_string

		ld	hl,#titlestr3
		ld	de,#(80*BYTES_PER_LINE)+BYTES_PER_CHAR_W*15
		ld	c,#0x07
		call	print_string

		call	menu1a

		ld	hl,#titlestr8
		ld	de,#(176*BYTES_PER_LINE)+BYTES_PER_CHAR_W*3
		ld	c,#0x07
		call	print_string

		ld	hl,#titlestr9
		ld	de,#(184*BYTES_PER_LINE)+BYTES_PER_CHAR_W*3
		ld	c,#0x07
		call	print_string

		ld	hl,#titlestr10
		ld	de,#(192*BYTES_PER_LINE)+BYTES_PER_CHAR_W*3
		ld	c,#0x07
		call	print_string

		ld	hl,#TIME_MENU1
		ld	(timer_invaders),hl
		xor	a
		ld	(stepping),a

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu1a:		ld	bc,#octo1a
		ld	hl,#(96*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		call	print_sprite
		ld	bc,#octo2a
		ld	hl,#(96*BYTES_PER_LINE)+BYTES_PER_CHAR_W*12
		call	print_sprite
		ld	hl,#titlestr4
		ld	de,#(96*BYTES_PER_LINE)+BYTES_PER_CHAR_W*14
		ld	c,#0x07
		call	print_string

		ld	bc,#crab2a
		ld	hl,#(112*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		call	print_sprite
		ld	bc,#crab1a
		ld	hl,#(112*BYTES_PER_LINE)+BYTES_PER_CHAR_W*12
		call	print_sprite
		ld	hl,#titlestr5
		ld	de,#(112*BYTES_PER_LINE)+BYTES_PER_CHAR_W*14
		ld	c,#0x07
		call	print_string

		ld	bc,#squid1a
		ld	hl,#(128*BYTES_PER_LINE)+BYTES_PER_CHAR_W*11
		call	print_sprite
		ld	bc,#blank
		ld	hl,#(128*BYTES_PER_LINE)+BYTES_PER_CHAR_W*13
		call	print_sprite

		ld	hl,#titlestr6
		ld	de,#(128*BYTES_PER_LINE)+BYTES_PER_CHAR_W*14
		ld	c,#0x07
		call	print_string

		ld	bc,#ufo
		ld	hl,#(144*BYTES_PER_LINE)+BYTES_PER_CHAR_W*11
		call	print_sprite
		ld	hl,#titlestr7
		ld	de,#(144*BYTES_PER_LINE)+BYTES_PER_CHAR_W*14
		ld	c,#0x07
		call	print_string

		ld	hl,#titlestrxl
		ld	de,#(160*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x07
		call	print_string

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu1b:		ld	hl,#strblanks
		ld	de,#(96*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x07
		call	print_string

		ld	hl,#strlastscore
		ld	de,#(112*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x0f
		call	print_string

		; HL = value  DE = screen addr  C = color
		ld	hl,(score)
		ld	de,#(112*BYTES_PER_LINE)+BYTES_PER_CHAR_W*24
		ld	c,#0x0e
		call	print_number

		ld	hl,#strtopscore
		ld	de,#(128*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x0f
		call	print_string

		; HL = value  DE = screen addr  C = color
		ld	hl,(topscore)
		ld	de,#(128*BYTES_PER_LINE)+BYTES_PER_CHAR_W*24
		ld	c,#0x0c
		call	print_number

		ld	hl,#strblanks
		ld	de,#(144*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x07
		call	print_string

		ld	hl,#strblanks
		ld	de,#(160*BYTES_PER_LINE)+BYTES_PER_CHAR_W*10
		ld	c,#0x07
		call	print_string

		ret

strlastscore:	.ascii	' LAST SCORE:  \0'
strtopscore:	.ascii	' TOP  SCORE:  \0'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

titlestr:	.ascii	'---=== KRAFT INVADERS ===---\0'
titlestr1:	.ascii	'-- V1.0.0 - 2026 ARMCoderBR --\0'
titlestr2:	.ascii	'Based on Space Invaders (Taito)\0'
titlestr3:	.ascii	'Scoring:\0'
titlestr4:	.ascii	'   ...   10 PTS\0'
titlestr5:	.ascii	'   ...   20 PTS\0'
titlestr6:	.ascii	'   ...   30 PTS\0'
titlestr7:	.ascii	'   ...   MYSTERY\0'
titlestrxl:	.ascii	'+1 life at 2500 pts\0'

titlestr8:	.byte	0xb3
		.ascii	'    Buttons     '
		.byte	0xb3
		.ascii	'     Keys      '
		.byte	0xb3,0x00

titlestr9:	.byte	0xb3
		.ascii	' SW1 & SW2:Move '
		.byte	0xb3
		.ascii	'  Arrows:Move  '
		.byte	0xb3,0x00

titlestr10:	.byte	0xb3
		.ascii	'    SW8:Fire    '
		.byte	0xb3
		.ascii	'  Space:Fire   '
		.byte	0xb3,0x00

titlestr11:	.ascii	'** PRESS FIRE TO PLAY **\0'
strblanks:	.ascii	'                        \0'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

menu_update:	ld	hl,(timer_invaders)
		ld	a,h
		or	l
		ret	nz

		ld	hl,#TIME_MENU1
		ld	(timer_invaders),hl

		ld	hl,#strblanks

		ld	a,(stepping)
		and	#0x01
		jr	nz,menuup1
		ld	hl,#titlestr11

menuup1:	ld	de,#(212*BYTES_PER_LINE)+BYTES_PER_CHAR_W*8
		ld	c,#0x0e
		call	print_string

		ld	a,(stepping)
		and	#0x08
		jr	nz,menuup3

		call	menu1a
		jr	menuup2

menuup3:	call	menu1b

menuup2:	ld	a,(stepping)
		inc	a
		ld	(stepping),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.area	DATA

spritepos:	.ds	2
spritenow:	.ds	2
col_now:	.ds	1
scrpos_invaders:.ds	2
row_now:	.ds	1
invader_matnow:	.ds	2
invader_matnow2:.ds	2
stepping:	.ds	1


