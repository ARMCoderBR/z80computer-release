;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  Rev 1.0
;  14-Oct-2025 - ARMCoder
;  Main module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.area	CODE

		.globl	invader_matrix, col_start, col_end, row_end
		.globl	cannon_hpos_px
		.globl	cannondie_state

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

invaders:
		call	set_screen

		ld	hl,#timer_service
		call	init_timer

		call	init_inputs

		ld	hl,#150
		ld	(timer_invaders),hl
wait_init:	ld	hl,(timer_invaders)
		ld	a,h
		or	l
		jr	nz,wait_init

		call	clrscr
		call	drawbaseline

		call	init_vars1
		call	init_vars2

		call	print_cannon
		call	print_invaders

		ld	hl,#0
		ld	(score),hl

		call	print_score

loop_invaders:
		call	update_inputs
		ld	(inputs_state),a

		call	move_cannon
		call	move_invaders
		call	move_missile
		call	newbomb
		call	move_bombs
		call	lfsr_update
		jr	loop_invaders

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

init_vars1:
		ld	a,#(PLAYFIELD_WIDTH/2) - 8
		ld	(cannon_hpos_px),a

		xor	a
		ld	(missile_act),a
		ld	(timer_missile),a

		ld	b,#NUM_BOMBS
		ld	ix,#bomb_basedata
init_vars1a:	ld	_BOMB_ACT(ix),a
		inc	ix
		djnz	init_vars1a

		ld	(timer_bombs),a
		ld	(timer_newbomb),a

		ld	hl,#0x51af
		ld	(lfsr_data),hl

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

init_vars2:
		call	print_bunkers

		ld	hl,#invader_matrix
		ld	a,#1
		ld	b,#INVADER_NUM
init_var1:	ld	(hl),a
		inc	hl
		djnz	init_var1

		ld	a,#INVADER_NUM
		ld	(invader_count),a

		xor	a
		ld	(col_start),a
		ld	(stepping),a
		ld	(hdir_invaders),a
		ld	(refsh_cannon),a

		ld	a,#INVADER_COLS-1
		ld	(col_end),a
		ld	a,#INVADER_ROWS-1
		ld	(row_end),a

		ld	hl,#INV_DIVIDER_INI
		ld	(invaders_divider),hl
		ld	(timer_div),hl

		ld	a,#24
		ld	(row_invaders),a
		ld	a,#32
		ld	(col_invaders_px),a

		ld	hl,#0
		ld	(timer_invaders),hl
		ld	(cannondie_state),hl

		call	update_scrpos

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

check_hit:	ld	b,#INVADER_ROWS		

		ld	hl,#invader_matrix
		ld	a,(col_start)
		ld	e,a
		ld	d,#0
		add	hl,de

		ld	a,(row_invaders)
		ld	d,a
		add	a,#8
		ld	e,a

scan_invrows:	ld	a,(missile_vpos)
		cp	d
		jr	c,invr_nf
		cp	e
		jr	nc,invr_nf

		jr	invr_foundrow

invr_nf:	ld	a,d
		add	#(8+INVADERS_VSPACING)
		ld	d,a
		
		ld	a,e
		add	#(8+INVADERS_VSPACING)
		ld	e,a

		push	de
		ld	de,#INVADER_COLS
		add	hl,de
		pop	de

		djnz	scan_invrows
		ret

invr_foundrow:	ld	a,#30
		ld	(scrinc),a
		ld	a,b	; Check the row for scoring (top row:30 pts  mid rows:20 pts  lower rows: 10 pts)
		cp	#INVADER_ROWS
		jr	z,invr_foundrow2
		ld	a,#20
		ld	(scrinc),a
		ld	a,b
		cp	#INVADER_ROWS-1
		jr	z,invr_foundrow2
		cp	#INVADER_ROWS-2
		jr	z,invr_foundrow2
		ld	a,#10
		ld	(scrinc),a
		
invr_foundrow2:
		ld	b,#INVADER_COLS

		ld	a,(col_invaders_px)
		ld	d,a
		add	a,#16
		ld	e,a

scan_invcols:	ld	a,(missile_hpos_px)
		cp	d
		jr	c,invr_nf2
		cp	e
		jr	nc,invr_nf2

		jr	invr_foundcol

invr_nf2:	ld	a,d
		add	#16
		ld	d,a
		
		ld	a,e
		add	#16
		ld	e,a

		inc	hl
		djnz	scan_invcols
		ret

invr_foundcol:	ld	a,(hl)
		or	a
		ret	z

		ld	(hl),#0

		ld	hl,(score)
		ld	a,(scrinc)
		ld	e,a
		ld	d,#0
		add	hl,de
		ld	(score),hl
		call	print_score

		call	print_invaders

		ld	hl,(invaders_divider)
		ld	de,#-INV_DIVIDER_DROP
		add	hl,de
		ld	(invaders_divider),hl

		ld	a,(invader_count)
		dec	a
		ld	(invader_count),a
		jr	nz,check_cols_r

		call	init_vars2
		call	print_invaders
		ret

check_cols_r:	ld	a,(col_end)
		ld	e,a
		ld	d,#0
		ld	hl,#invader_matrix
		add	hl,de
		ld	b,#INVADER_ROWS
		ld	e,#INVADER_COLS
check_cols_r2:	ld	a,(hl)
		or	a
		jr	nz,check_cols_l
		add	hl,de
		djnz	check_cols_r2
		ld	a,(col_end)
		dec	a
		ld	(col_end),a
		jr	check_cols_r
		
check_cols_l:	ld	a,(col_start)
		ld	e,a
		ld	hl,#invader_matrix
		add	hl,de
		ld	b,#INVADER_ROWS
		ld	e,#INVADER_COLS
check_cols_l2:	ld	a,(hl)
		or	a
		jr	nz,check_rows

		add	hl,de
		djnz	check_cols_l2
		ld	a,(col_start)
		inc	a
		ld	(col_start),a
		
		ld	a,(col_invaders_px)
		add	a,#16
		ld	(col_invaders_px),a
		call	update_scrpos
		
		jr	check_cols_l

check_rows:	ld	a,(row_end)
		or	a
		ret	z

		ld	b,a
		ld	hl,#invader_matrix+(INVADER_ROWS-1)*(INVADER_COLS)
		ld	de,#-INVADER_COLS
chkrow0:	add	hl,de
		djnz	chkrow0
		
		ld	a,(row_end)
		ld	c,a		

chkrow2:	ld	(invader_matnow),hl
		ld	b,#INVADER_COLS

chkrow1:	ld	a,(hl)
		or	a
		ret	nz

		inc	hl
		djnz	chkrow1

		ld	a,(row_end)
		dec	a
		ld	(row_end),a

		ld	hl,(invader_matnow)
		ld	de,#-INVADER_COLS
		add	hl,de

		dec	c
		jr	nz,chkrow2
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

update_scrpos:	ld	a,(row_invaders)	; Pixel line
		ld	hl,#0
		or	a
		jr	z,update1a
		ld	de,#BYTES_PER_LINE
update1:	add	hl,de
		dec	a
		jr	nz,update1
	
update1a:	ld	d,h
		ld	e,l
		ld	a,(col_invaders_px)
		srl	a
		ld	l,a
		ld	h,#0
		add	hl,de
		ld	de,#LEFT_OFFSET_BYTES
		add	hl,de
		ld	(scrpos_invaders),hl

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

move_missile:	ld	a,(timer_missile)
		or	a
		ret	nz
		ld	a,#3
		ld	(timer_missile),a

		ld	a,(missile_act)
		cp	#1
		ret	nz

		ld	a,(missile_vpos)
		cp	#8
		jr	nc,movem1

		ld	a,#2
		ld	(missile_act),a
		ld	hl,(missile_scrpos)
		ld	c,#0
		jr	movem2

movem1:		dec	a
		dec	a
		ld	(missile_vpos),a
		
		ld	hl,(missile_scrpos)
		ld	de,#-(2*BYTES_PER_LINE)
		add	hl,de
		ld	(missile_scrpos),hl

		ld	a,(missile_pixmask)
		and	#0xee
		ld	c,a
		
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		ld	a,(missile_pixmask)
		ld	d,a
		in	a,(PORTDATA)
		and	d
		jr	z,movem2

		push	hl
		call	check_hit		; Missile hit something
		pop	hl
		
		ld	a,#2	
		ld 	(missile_act),a
		ld	c,#0
		
movem2:		ld	b,#5
		ld	de,#BYTES_PER_LINE

movem3:		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		push	bc
		in	a,(PORTDATA)
		ld	b,a
		ld	a,(missile_pixmask)
		cpl
		and	b
		or	c
		pop	bc
		out	(PORTDATA),a
		add	hl,de
		djnz	movem3

		ld	b,#2
		ld	a,(missile_pixmask)
		cpl
		ld	c,a
movem4:		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		in	a,(PORTDATA)
		and	c
		out	(PORTDATA),a
		add	hl,de
		djnz	movem4
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

move_invaders:	ld	hl,(timer_invaders)
		ld	a,h
		or	l
		ret	nz
		ld	hl,(invaders_divider)
		ld	(timer_invaders),hl
		
		ld	a,(stepping)
		ld	b,#1
		xor	b
		ld	(stepping),a

		ld	a,(hdir_invaders)
		or	a
		jr	z,moveright

		ld	a,(col_invaders_px)	; Moving left
		or	a
		jr	z,revdir
		
		dec	a
		dec	a
		ld	(col_invaders_px),a
		jr	movupd
		
moveright:
		ld	a,(col_start)
		ld	b,a
		ld	a,(col_end)
		sub	b
		inc	a
		add	a,a
		add	a,a
		add	a,a
		add	a,a
		ld	b,a
		ld	a,#PLAYFIELD_WIDTH
		sub	b
		ld	b,a
		ld	a,(col_invaders_px)
		cp	b
		jr	z,revdir

		inc	a
		inc	a
		ld	(col_invaders_px),a

movupd:		call	update_scrpos
		jp	print_invaders

revdir:		ld	a,(hdir_invaders)
		xor	#1
		ld	(hdir_invaders),a
		ld	a,(row_invaders)
		add	a,#VSTEP
		ld	(row_invaders),a
		call	update_scrpos
		call	print_invaders
		jp	clear_lines

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

move_cannon:
		ld	a,(timer_cannon)
		or	a
		ret	nz
		
		ld	a,#4
		ld	(timer_cannon),a

		ld	hl,(cannondie_state)
		ld	a,h
		or	l
		jr	z,movecan00
		ld	a,#1
		ld	(refsh_cannon),a
		jp	print_cannon_die

movecan00:
		ld	a,(refsh_cannon)
		or	a
		jr	z,movecan001
		call	print_cannon
		xor	a
		ld	(refsh_cannon),a

movecan001:
		ld	a,(inputs_state)
		ld	c,a
		bit	0,a			;FIRE
		jr	nz,newmis1		;Pressed

		ld	a,(missile_act)		;Not pressed
		cp	#2
		ld	a,c
		jr	nz,movec0
		xor	a
		ld	(missile_act),a
		ld	a,c
		jr	movec0
		
newmis1:	ld	a,(missile_act)
		or	a
		ld	a,c
		jr	nz,movec0

		ld	a,#1
		ld	(missile_act),a
		
		ld	a,#CANNON_VPOS
		sub	a,#5
		ld	(missile_vpos),a
		ld	a,(cannon_hpos_px)
		add	a,#7
		ld	(missile_hpos_px),a
		
		ld	b,#0x0f
		bit	0,a
		jr	z,newmis2
		ld	b,#0xf0

newmis2:	ld	d,a
		ld	a,b
		ld	(missile_pixmask),a

		ld	a,d
		srl	a
		ld	e,a
		ld	d,#0
		ld	hl,#CANNON_SCR_OFS-(5*BYTES_PER_LINE)
		add	hl,de

		ld	(missile_scrpos),hl
		ld	a,c
		
movec0:		bit	5,a			;LEFT
		jr	z,movec1		;Not pressed
		bit	7,a			;RIGHT pressed
		ret	nz
		
		ld	a,(cannon_hpos_px)	;decrement
		or	a
		ret	z

		dec	a
		ld	(cannon_hpos_px),a
		jp	print_cannon
		
movec1:		bit	7,a			;RIGHT
		ret	z			;NOT PRESSED

		ld	a,(cannon_hpos_px)
		cp	#(PLAYFIELD_WIDTH - 16)
		ret	nc
		inc	a
		ld	(cannon_hpos_px),a
		jp	print_cannon

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

timer_service:	ld	hl,(timer_invaders)
		ld	a,h
		or	l
		jr	z,timer_isr2
		dec	hl
		ld	(timer_invaders),hl
		
timer_isr2:	ld	a,(timer_cannon)
		or	a
		jr	z,timer_isr3

		dec	a
		ld	(timer_cannon),a

timer_isr3:	ld	a,(timer_missile)
		or	a
		jr	z,timer_isr4
		dec	a
		ld	(timer_missile),a
	
timer_isr4:	ld	a,(timer_bombs)
		or	a
		jr	z,timer_isr5
		dec	a
		ld	(timer_bombs),a

timer_isr5:	ld	a,(timer_newbomb)
		or	a
		jr	z,timer_isr6
		dec	a
		ld	(timer_newbomb),a

timer_isr6:	ld	hl,(cannondie_state)
		ld	a,h
		or	l
		ret	z
		dec	hl
		ld	(cannondie_state),hl

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

; Fibonacci LFSR
; New bit[0] = bit[10] ^ bit[12] ^ bit[13] ^ bit[15]

lfsr_update:	ld	hl,(lfsr_data)

		scf
		ccf
		
		bit	7,h
		jr	z,lfsr1
		ccf
lfsr1:		bit	5,h
		jr	z,lfsr2
		ccf
lfsr2:		bit	4,h
		jr	z,lfsr3
		ccf
lfsr3:		bit	2,h
		jr	z,lfsr4
		ccf
lfsr4:		rl	l
		rl	h
		ld	(lfsr_data),hl
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

newbomb:
		ld	hl,(cannondie_state)	;If dying, stop launching new bombs
		ld	a,h
		or	l
		ret	nz

		ld	ix,#bomb_basedata
		ld	b,#NUM_BOMBS

newbomb1:	push	bc
		call	 newbomb_ix
		inc	ix
		pop	bc
		djnz	newbomb1

		ret

newbomb_ix:
		ld	a,(timer_newbomb)
		or	a
		ret	nz
		ld	a,#50
		ld	(timer_newbomb),a

		ld	a,_BOMB_ACT(ix)
		or	a
		ret	nz

		;ld	a,(col_start)
		ld	a,(lfsr_data)
newbomb0:	cp	#INVADER_COLS
		jr	c,newbomb1a
		sub	#INVADER_COLS
		jr	newbomb0

newbomb1a:
		ld	(col_now),a

		call	nb_testcol

		ld	a,d
		or	a
		ret	z

		ld	a,(row_invaders)
		add	a,#0x0c
		ld	_BOMB_VPOS(ix),a

		ld	a,e
		or	a
		jr	z,newbomb2
		ld	b,e
		ld	a,_BOMB_VPOS(ix)
		
newbomb1b:	add	#(8+INVADERS_VSPACING)
		djnz	newbomb1b

		ld	_BOMB_VPOS(ix),a

newbomb2:
		ld	a,(col_start)
		ld	b,a
		ld	a,(col_now)
		sub	b
		ld	b,a
		sla	b
		sla	b	;x16 (invader width)
		sla	b
		sla	b
		ld	a,(col_invaders_px)
		add	a,b
		add	a,#7
		ld	_BOMB_HPOS_PX(ix),a

		ld	b,#0x0f
		bit	0,a
		jr	z,newbomb3
		ld	b,#0xf0

newbomb3:	ld	a,b
		ld	_BOMB_PIXMASK(ix),a

		ld	a,_BOMB_VPOS(ix)	; Pixel line
		ld	hl,#0
		or	a
		jr	z,nbupd1a
		ld	de,#BYTES_PER_LINE
nbupd1:		add	hl,de
		dec	a
		jr	nz,nbupd1
	
nbupd1a:	ld	d,h
		ld	e,l
		ld	a,_BOMB_HPOS_PX(ix)
		srl	a
		ld	l,a
		ld	h,#0
		add	hl,de
		ld	de,#LEFT_OFFSET_BYTES
		add	hl,de
		ld	_BOMB_SCRPOS_L(ix),l
		ld	_BOMB_SCRPOS_H(ix),h

		ld	a,#1
		ld	_BOMB_ACT(ix),a

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

nb_testcol:		
		; will test a column to launch a bomb
		; return  # if invaders in col in D, Lowest row w/ invader in col in E

		ld	hl,#invader_matrix	; top of scanned column
		ld	b,#0
		ld	a,(col_now)
		ld	c,a
		add	hl,bc			; H offset
		ld	de,#0			;
		ld	c,#0
		ld	b,#INVADER_ROWS
nbcc1:		ld	a,(hl)
		or	a
		jr	z,nbcc2
		ld	e,c
		inc	d		
nbcc2:		ld	a,l
		add	a,#INVADER_COLS
		ld	l,a
		jr	nc,nbcc3
		inc	h
nbcc3:		inc	c
		djnz	nbcc1

		ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

move_bombs:
		ld	a,(timer_bombs)
		or	a
		ret	nz
		ld	a,#4
		ld	(timer_bombs),a

		ld	ix,#bomb_basedata

		ld	b,#NUM_BOMBS
move_bombs1:
		push	bc
		call	move_bombs_ix
		inc	ix
		pop	bc
		djnz	move_bombs1

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

move_bombs_ix:
		ld	a,_BOMB_ACT(ix)
		or	a
		ret	z

		ld	a,_BOMB_VPOS(ix)
		cp	#(CANNON_VPOS+8)
		jr	c,moveb1

		; Bomb reached bottom of screen.
		xor	a
		ld	_BOMB_ACT(ix),a
		ld	l,_BOMB_SCRPOS_L(ix)
		ld	h,_BOMB_SCRPOS_H(ix)
		ld	c,#0
		jr	moveb2

moveb1:		inc	a
		inc	a
		ld	_BOMB_VPOS(ix),a
		
		ld	l,_BOMB_SCRPOS_L(ix)
		ld	h,_BOMB_SCRPOS_H(ix)
		ld	de,#(2*BYTES_PER_LINE)
		add	hl,de
		ld	_BOMB_SCRPOS_L(ix),l
		ld	_BOMB_SCRPOS_H(ix),h

		ld	a,_BOMB_PIXMASK(ix)
		and	#0xee
		ld	c,a
		
		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a

		ld	a,_BOMB_PIXMASK(ix)
		ld	d,a
		in	a,(PORTDATA)
		and	d
		jr	z,moveb2

		; Bomb hit something.

		ld	a,_BOMB_VPOS(ix)
		cp	#CANNON_VPOS
		jr	c,moveb1a	;Not the cannon

		ld	a,(cannon_hpos_px)
		inc	a		;Actual cannon graphics start at next column
		ld	c,a
		ld	a,_BOMB_HPOS_PX(ix)
		cp	c
		jr	c,moveb1a	;Was at left of cannon

		ld	a,(cannon_hpos_px)
		add	a,#13		;Cannon graphics end 13 columns after
		ld	c,a
		ld	a,_BOMB_HPOS_PX(ix)
		cp	c
		jr	nc,moveb1a	;Was at right of cannon

		push	hl
		ld	hl,#600
		ld	(cannondie_state),hl
		pop	hl
		
moveb1a:	ld	a,#0
		ld 	_BOMB_ACT(ix),a
		ld	c,#0
		
moveb2:		; Redrawing the bomb
		ld	b,#5
		ld	de,#-BYTES_PER_LINE

moveb3:		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		push	bc
		in	a,(PORTDATA)
		ld	b,a
		ld	a,_BOMB_PIXMASK(ix)
		cpl
		and	b
		or	c
		pop	bc
		out	(PORTDATA),a
		add	hl,de
		djnz	moveb3

		ld	b,#2
		ld	a,_BOMB_PIXMASK(ix)
		cpl
		ld	c,a
moveb4:		ld	a,l
		out	(PORTADDRL),a
		ld	a,h
		out	(PORTADDRH),a
		in	a,(PORTDATA)
		and	c
		out	(PORTDATA),a
		add	hl,de
		djnz	moveb4
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

print_score:	ld	hl,#strscore
		ld	de,#0
		ld	c,#12	;Light red
		call	print_string
		ld	hl,(score)
		ld	de,#24
		ld	c,#9	;Light blue
		jp	print_number

strscore:	.ascii	'SCORE:\0'

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sysm_printh8:	; Value in ACC

		push	bc
		ld	b,a
		srl	a
		srl	a
		srl	a
		srl	a
		cp	#10
		jr	nc,sysm_ph8a
		add	a,#'0'
		jr	sysm_ph8b
sysm_ph8a:
		add	a,#'A'-10
sysm_ph8b:
		rst	0x08

		ld	a,b
		and	#0x0f
		cp	#10
		jr	nc,sysm_ph8c
		add	a,#'0'
		jr	sysm_ph8d
sysm_ph8c:
		add	a,#'A'-10
sysm_ph8d:
		rst	0x08
		pop	bc
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

		.area _DATA

inputs_state: 	.ds	1

cannon_hpos_px:	.ds	1
missile_hpos_px:.ds	1
missile_pixmask:.ds	1
missile_vpos:	.ds	1
missile_act:	.ds	1
missile_scrpos:	.ds	2

row_invaders:	.ds	1
col_invaders_px:.ds	1
hdir_invaders:	.ds	1

invader_matrix:	.ds	INVADER_NUM
invader_count:	.ds	1
invader_matnow:	.ds	2
col_start:	.ds	1
col_end:	.ds	1
col_now:	.ds	1
row_end:	.ds	1
timer_div:	.ds	2
timer_invaders:	.ds	2
invaders_divider:.ds	2
timer_cannon:	.ds	1
timer_missile:	.ds	1
cannondie_state:.ds	2
refsh_cannon:	.ds	1
score:		.ds	2
scrinc:		.ds	1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bomb_basedata:
bomb_hpos_px:	.ds	NUM_BOMBS
bomb_pixmask:	.ds	NUM_BOMBS
bomb_vpos:	.ds	NUM_BOMBS
bomb_act:	.ds	NUM_BOMBS
bomb_scrpos_l:	.ds	NUM_BOMBS
bomb_scrpos_h:	.ds	NUM_BOMBS

_BOMB_HPOS_PX	.equ	(bomb_hpos_px - bomb_basedata)
_BOMB_PIXMASK	.equ	(bomb_pixmask - bomb_basedata)
_BOMB_VPOS	.equ	(bomb_vpos - bomb_basedata)
_BOMB_ACT	.equ	(bomb_act - bomb_basedata)
_BOMB_SCRPOS_L	.equ	(bomb_scrpos_l - bomb_basedata)
_BOMB_SCRPOS_H	.equ	(bomb_scrpos_h - bomb_basedata)

timer_bombs:	.ds	1
timer_newbomb:	.ds	1

lfsr_data:	.ds	2

