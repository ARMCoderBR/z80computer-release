;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module mandel
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _plot2asm
	.globl _plot2
	.globl _plotasm
	.globl _plot
	.globl _video_begin
	.globl _video_in
	.globl _video_out
	.globl _video_setpos
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;mandel.c:20: void plot (int x, int y, char color){
;	---------------------------------
; Function plot
; ---------------------------------
_plot::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	c, l
	ld	b, h
	ex	de, hl
;mandel.c:22: video_setpos(y, x >> 1);
	ld	e, c
	ld	d, b
	sra	d
	rr	e
	push	bc
	call	_video_setpos
	call	_video_in
	pop	bc
;mandel.c:27: b |= (color & 0x0f);
	ld	l, 4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
;mandel.c:25: if (x & 1){
	bit	0, c
	jr	Z, 00102$
;mandel.c:26: b &= 0xf0;
	ld	a, e
	and	a, #0xf0
	ld	c, a
;mandel.c:27: b |= (color & 0x0f);
	ld	a, l
	and	a, #0x0f
	or	a,c
	ld	c, a
	jr	00103$
00102$:
;mandel.c:30: b &= 0x0f;
	ld	a, e
	and	a, #0x0f
	ld	e, a
;mandel.c:31: b |= (color << 4);
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c, l
	ld	a, e
	or	a, c
	ld	c, a
00103$:
;mandel.c:34: video_out(b);
	ld	a, c
	call	_video_out
;mandel.c:35: }
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;mandel.c:38: void plotasm (int x, int y, char color) __naked __sdcccall(0) {
;	---------------------------------
; Function plotasm
; ---------------------------------
_plotasm::
;mandel.c:103: __endasm;
	ld	iy,#2
	add	iy,sp
	ld	l,2(iy) ;y
	ld	h,3(iy)
	sla	l ;160 = 128+32
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	ld	c,l ;BC stores the origind hl * 32
	ld	b,h
	sla	l
	rl	h
	sla	l
	rl	h
	add	hl,bc ;HL is multiplied by 160
	ld	c,(iy) ;x
	ld	b,1(iy)
	srl	b ;halves BC
	rr	c
	add	hl,bc
	ld	a,l
	out	(0x51),a
	ld	a,h
	out	(0x52),a
	in	a,(0x50)
	bit	0,(iy)
	jr	z,plotasm_coleven
;column	is odd here
	and	#0xf0
	ld	b,a
	ld	a,4(iy)
	and	#0x0f
	or	b
	out	(0x50),a
	ret
	plotasm_coleven:
	and	#0x0f
	ld	b,a
	ld	a,4(iy)
	sla	a
	sla	a
	sla	a
	sla	a
	or	b
	out	(0x50),a
	ret
;mandel.c:104: }
;mandel.c:107: void plot2 (int x, int y, char color){
;	---------------------------------
; Function plot2
; ---------------------------------
_plot2::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	dec	sp
	ld	c, l
	ld	b, h
	ld	-2 (ix), e
	ld	-1 (ix), d
;mandel.c:109: int b = color << 4; b |= (color & 0x0f);
	ld	a, 4 (ix)
	ld	d, #0x00
	ld	l, a
	ld	h, d
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	and	a, #0x0f
	ld	e, a
	ld	d, #0x00
	ld	a, l
	or	a, e
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	or	a, d
	ld	h, a
;	spillPairReg hl
;	spillPairReg hl
;mandel.c:111: video_setpos(y, x >> 1);
	sra	b
	rr	c
	push	hl
	push	bc
	ld	e, c
	ld	d, b
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	_video_setpos
	pop	bc
	pop	hl
;mandel.c:112: video_out(b);
	ld	-3 (ix), l
	push	bc
	ld	a, -3 (ix)
	call	_video_out
	pop	bc
;mandel.c:113: video_setpos(y+1, x >> 1);
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	inc	hl
	ld	e, c
	ld	d, b
	call	_video_setpos
;mandel.c:114: video_out(b);
	ld	a, -3 (ix)
	call	_video_out
;mandel.c:115: }
	ld	sp, ix
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;mandel.c:118: void plot2asm (int x, int y, char color) __naked __sdcccall(0) {
;	---------------------------------
; Function plot2asm
; ---------------------------------
_plot2asm::
;mandel.c:180: __endasm;
	ld	iy,#2
	add	iy,sp
	ld	l,2(iy) ;y
	ld	h,3(iy)
	sla	l ;160 = 128+32
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	ld	c,l ;BC stores the origind hl * 32
	ld	b,h
	sla	l
	rl	h
	sla	l
	rl	h
	add	hl,bc ;HL is multiplied by 160
	ld	c,(iy) ;x
	ld	b,1(iy)
	srl	b ;halves BC
	rr	c
	add	hl,bc
	ld	a,l
	out	(0x51),a
	ld	a,h
	out	(0x52),a
	ld	a,4(iy)
	and	#0x0f
	ld	e,a
	sla	a
	sla	a
	sla	a
	sla	a
	or	e
	ld	e,a ;E = new color
	out	(0x50),a
	ld	bc,#160
	add	hl,bc
	ld	a,l
	out	(0x51),a
	ld	a,h
	out	(0x52),a
	ld	a,e
	out	(0x50),a
	ret
;mandel.c:181: }
;mandel.c:184: void main (void){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-26
	add	hl, sp
	ld	sp, hl
;mandel.c:186: video_begin(1);
	ld	hl, #0x0001
	call	_video_begin
;mandel.c:199: for (iy = 0; iy < 240; iy+=step){
	ld	bc, #0x0000
;mandel.c:201: for (ix = 0; ix < 320; ix+=step){
00136$:
	ld	de, #0x0000
00120$:
;mandel.c:203: x0 = ((float)ix - X0)/SCALE;
	push	bc
;	spillPairReg hl
;	spillPairReg hl
	ex	de, hl
	push	hl
;	spillPairReg hl
;	spillPairReg hl
	call	___sint2fs
	push	de
	pop	iy
	push	hl
	ld	hl, #0x4320
	ex	(sp), hl
	push	hl
	ld	hl, #0x0000
	ex	(sp), hl
	push	iy
	pop	de
	call	___fssub
	push	de
	pop	iy
	push	hl
	ld	hl, #0x42a0
	ex	(sp), hl
	push	hl
	ld	hl, #0x0000
	ex	(sp), hl
	push	iy
	pop	de
	call	___fsdiv
	push	de
	pop	iy
	pop	de
	pop	bc
	inc	sp
	inc	sp
	push	iy
	ld	-24 (ix), l
	ld	-23 (ix), h
;mandel.c:204: y0 = ((float)iy - Y0)/SCALE;
	push	bc
	push	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___sint2fs
	push	de
	pop	iy
	push	hl
	ld	hl, #0x42f0
	ex	(sp), hl
	push	hl
	ld	hl, #0x0000
	ex	(sp), hl
	push	iy
	pop	de
	call	___fssub
	push	de
	pop	iy
	push	hl
	ld	hl, #0x42a0
	ex	(sp), hl
	push	hl
	ld	hl, #0x0000
	ex	(sp), hl
	push	iy
	pop	de
	call	___fsdiv
	push	de
	pop	iy
	pop	de
	pop	bc
	push	iy
	ex	(sp), hl
	ld	-22 (ix), l
	ex	(sp), hl
	ex	(sp), hl
	ld	-21 (ix), h
	ex	(sp), hl
	pop	iy
	ld	-20 (ix), l
	ld	-19 (ix), h
;mandel.c:205: x = 0.0;
	xor	a, a
	ld	-18 (ix), a
	ld	-17 (ix), a
	ld	-16 (ix), a
	ld	-15 (ix), a
;mandel.c:206: y = 0.0;
	xor	a, a
	ld	-14 (ix), a
	ld	-13 (ix), a
	ld	-12 (ix), a
	ld	-11 (ix), a
;mandel.c:209: while (itcount < ITMAX) {
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00103$:
	ld	a, -2 (ix)
	sub	a, #0x0f
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	NC, 00105$
;mandel.c:211: xx = x*x;
	push	bc
	push	de
	ld	l, -16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -18 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -17 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -18 (ix)
	ld	d, -17 (ix)
	ld	l, -16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsmul
	push	de
	pop	iy
	pop	de
	pop	bc
	push	iy
	ex	(sp), hl
	ld	-10 (ix), l
	ex	(sp), hl
	ex	(sp), hl
	ld	-9 (ix), h
	ex	(sp), hl
	pop	iy
	ld	-8 (ix), l
	ld	-7 (ix), h
;mandel.c:212: yy = y*y;
	push	bc
	push	de
	ld	l, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	e, -14 (ix)
	ld	d, -13 (ix)
	ld	l, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsmul
	push	de
	pop	iy
	pop	de
	pop	bc
;mandel.c:214: if (xx + yy > 4.0)
	push	hl
	push	bc
	push	de
	push	iy
	push	hl
	push	iy
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
	pop	iy
	pop	de
	pop	bc
	pop	hl
	push	hl
	push	bc
	push	de
	push	iy
	push	hl
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	ld	de, #0x0000
	ld	hl, #0x4080
	call	___fslt
	pop	iy
	pop	de
	pop	bc
	pop	hl
	or	a, a
	jp	NZ, 00105$
;mandel.c:217: xtemp = xx-yy+x0;
	push	bc
	push	de
	push	hl
	push	iy
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
	push	de
	pop	iy
	push	hl
	ld	l, -24 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -23 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -26 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -25 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	iy
	pop	de
	call	___fsadd
	push	de
	pop	iy
	pop	de
	pop	bc
	push	iy
	ex	(sp), hl
	ld	-6 (ix), l
	ex	(sp), hl
	ex	(sp), hl
	ld	-5 (ix), h
	ex	(sp), hl
	pop	iy
	ld	-4 (ix), l
	ld	-3 (ix), h
;mandel.c:218: y = 2 * x*y + y0;
	push	bc
	push	de
	ld	l, -16 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -15 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -18 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -17 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	de, #0x0000
	ld	hl, #0x4000
	call	___fsmul
	push	de
	pop	iy
	push	hl
	ld	l, -12 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -11 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -14 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -13 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	iy
	pop	de
	call	___fsmul
	push	de
	pop	iy
	push	hl
	ld	l, -20 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -19 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	hl
	ld	l, -22 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -21 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ex	(sp), hl
	push	iy
	pop	de
	call	___fsadd
	push	de
	pop	iy
	pop	de
	pop	bc
	push	iy
	ex	(sp), hl
	ld	-14 (ix), l
	ex	(sp), hl
	ex	(sp), hl
	ld	-13 (ix), h
	ex	(sp), hl
	pop	iy
	ld	-12 (ix), l
	ld	-11 (ix), h
;mandel.c:219: x = xtemp;
	push	de
	push	bc
	ld	hl, #12
	add	hl, sp
	ex	de, hl
	ld	hl, #24
	add	hl, sp
	ld	bc, #4
	ldir
	pop	bc
	pop	de
;mandel.c:220: itcount++;
	inc	-2 (ix)
	jp	NZ,00103$
	inc	-1 (ix)
	jp	00103$
00105$:
;mandel.c:224: plotasm (ix, iy, itcount);
	ld	a, -2 (ix)
	push	bc
	push	de
	push	af
	inc	sp
	push	bc
	push	de
	call	_plotasm
	pop	af
	pop	af
	inc	sp
	pop	de
	pop	bc
;mandel.c:201: for (ix = 0; ix < 320; ix+=step){
	inc	de
	ld	a, e
	sub	a, #0x40
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x81
	jp	C, 00120$
;mandel.c:199: for (iy = 0; iy < 240; iy+=step){
	inc	bc
	ld	a, c
	sub	a, #0xf0
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C, 00136$
00125$:
;mandel.c:234: }
	jr	00125$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
