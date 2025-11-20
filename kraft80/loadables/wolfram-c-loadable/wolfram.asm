;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module wolfram
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _wolfram
	.globl _putstr
	.globl _lgets
	.globl _atoi
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
;wolfram.c:17: int wolfram(int width, int height, int rulenum) {
;	---------------------------------
; Function wolfram
; ---------------------------------
_wolfram::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-342
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	-6 (ix), e
	ld	-5 (ix), d
;wolfram.c:22: memset(cells, 0, width);
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	de, #0x0000
	ld	hl, #2
	add	hl, sp
	call	_memset
;wolfram.c:23: memset(nextcells, 0, width);
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	de, #0x0000
	ld	hl, #162
	add	hl, sp
	call	_memset
;wolfram.c:25: cells[width / 2] = 1;
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	bit	7, -3 (ix)
	jr	Z, 00136$
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	inc	bc
00136$:
	sra	b
	rr	c
	ld	hl, #0
	add	hl, sp
	add	hl, bc
	ld	(hl), #0x01
;wolfram.c:29: int mask = 1;
	ld	-8 (ix), #0x01
	ld	-7 (ix), #0
;wolfram.c:35: for (i = 0; i < 8; i++) {
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00117$:
;wolfram.c:37: if (rulenum & mask)
	ld	a, 4 (ix)
	and	a, -8 (ix)
	ld	c, a
	ld	a, 5 (ix)
	and	a, -7 (ix)
	or	a, c
	jr	Z, 00102$
;wolfram.c:38: rule[i] = 1;
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #320
	add	hl, sp
	add	hl, de
	ld	(hl), #0x01
	jr	00103$
00102$:
;wolfram.c:40: rule[i] = 0;
	ld	e, -2 (ix)
	ld	d, -1 (ix)
	ld	hl, #320
	add	hl, sp
	add	hl, de
	ld	-10 (ix), l
	ld	-9 (ix), h
	ld	(hl), #0x00
00103$:
;wolfram.c:42: mask <<= 1;
	sla	-8 (ix)
	rl	-7 (ix)
;wolfram.c:35: for (i = 0; i < 8; i++) {
	inc	-2 (ix)
	jr	NZ, 00229$
	inc	-1 (ix)
00229$:
	ld	a, -2 (ix)
	sub	a, #0x08
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00117$
;wolfram.c:47: putstr("\r\n.");
	ld	hl, #___str_0
	call	_putstr
;wolfram.c:48: for (i = 0; i < width; i++)
	ld	bc, #0x0000
00120$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jp	PO, 00230$
	xor	a, #0x80
00230$:
	jp	P, 00105$
;wolfram.c:49: putstr("=");
	push	bc
	ld	hl, #___str_1
	call	_putstr
	pop	bc
;wolfram.c:48: for (i = 0; i < width; i++)
	inc	bc
	jr	00120$
00105$:
;wolfram.c:50: putstr(".\r\n.");
	ld	hl, #___str_2
	call	_putstr
;wolfram.c:53: for (it = 0; it < height; it++) {
	ld	a, -4 (ix)
	add	a, #0xff
	ld	-14 (ix), a
	ld	a, -3 (ix)
	adc	a, #0xff
	ld	-13 (ix), a
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00129$:
	ld	a, -2 (ix)
	sub	a, -6 (ix)
	ld	a, -1 (ix)
	sbc	a, -5 (ix)
	jp	PO, 00231$
	xor	a, #0x80
00231$:
	jp	P, 00115$
;wolfram.c:55: for (i = 0; i < width; i++) {
	xor	a, a
	ld	-8 (ix), a
	ld	-7 (ix), a
00123$:
	ld	a, -8 (ix)
	sub	a, -4 (ix)
	ld	a, -7 (ix)
	sbc	a, -3 (ix)
	jp	PO, 00232$
	xor	a, #0x80
00232$:
	jp	P, 00109$
;wolfram.c:57: if (cells[i])
	ld	e, -8 (ix)
	ld	d, -7 (ix)
	ld	hl, #0
	add	hl, sp
	add	hl, de
	ld	a, (hl)
	or	a, a
	jr	Z, 00107$
;wolfram.c:58: putstr("#");
	ld	hl, #___str_3
	call	_putstr
	jr	00124$
00107$:
;wolfram.c:60: putstr(" ");
	ld	hl, #___str_4
	call	_putstr
00124$:
;wolfram.c:55: for (i = 0; i < width; i++) {
	inc	-8 (ix)
	jr	NZ, 00123$
	inc	-7 (ix)
	jr	00123$
00109$:
;wolfram.c:63: putstr(".\r\n.");
	ld	hl, #___str_2
	call	_putstr
;wolfram.c:65: for (i = 0; i < width; i++) {
	ld	bc, #0x0000
00126$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jp	PO, 00234$
	xor	a, #0x80
00234$:
	jp	P, 00114$
;wolfram.c:67: int il = i - 1;
	ld	e, c
	ld	d, b
	dec	de
;wolfram.c:68: if (il < 0)
	bit	7, d
	jr	Z, 00111$
;wolfram.c:69: il = width - 1;
	ld	e, -14 (ix)
	ld	d, -13 (ix)
00111$:
;wolfram.c:71: int ir = i + 1;
	ld	l, c
	ld	h, b
	inc	hl
	ld	-12 (ix), l
	ld	-11 (ix), h
	ld	a, -12 (ix)
	ld	-10 (ix), a
	ld	a, -11 (ix)
	ld	-9 (ix), a
;wolfram.c:72: if (ir == width)
	ld	a, -4 (ix)
	sub	a, -10 (ix)
	jr	NZ, 00113$
	ld	a, -3 (ix)
	sub	a, -9 (ix)
	jr	NZ, 00113$
;wolfram.c:73: ir = 0;
	xor	a, a
	ld	-10 (ix), a
	ld	-9 (ix), a
00113$:
;wolfram.c:75: int idx = 4 * cells[il] + 2 * cells[i] + cells[ir];
	ld	hl, #0
	add	hl, sp
	add	hl, de
	ld	e, (hl)
	ld	d, #0x00
	ex	de, hl
	add	hl, hl
	add	hl, hl
	ex	de, hl
	ld	hl, #0
	add	hl, sp
	add	hl, bc
	ld	l, (hl)
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	add	hl, de
	ld	-8 (ix), l
	ld	-7 (ix), h
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	hl, #0
	add	hl, sp
	add	hl, de
	ld	a, (hl)
	ld	d, #0x00
	add	a, -8 (ix)
	ld	e, a
	ld	a, d
	adc	a, -7 (ix)
	ld	d, a
;wolfram.c:77: nextcells[i] = rule[idx];
	ld	hl, #160
	add	hl, sp
	add	hl, bc
	ld	c, l
	ld	b, h
	ld	hl, #320
	add	hl, sp
	add	hl, de
	ld	a, (hl)
	ld	(bc), a
;wolfram.c:65: for (i = 0; i < width; i++) {
	ld	c, -12 (ix)
	ld	b, -11 (ix)
	jp	00126$
00114$:
;wolfram.c:80: memcpy(cells, nextcells, width);
	ld	hl, #0
	add	hl, sp
	ex	de, hl
	ld	hl, #160
	add	hl, sp
	ld	c, -4 (ix)
	ld	b, -3 (ix)
	ld	a, b
	or	a, c
	jr	Z, 00237$
	ldir
00237$:
;wolfram.c:53: for (it = 0; it < height; it++) {
	inc	-2 (ix)
	jp	NZ,00129$
	inc	-1 (ix)
	jp	00129$
00115$:
;wolfram.c:83: for (i = 0; i < width; i++)
	ld	bc, #0x0000
00132$:
	ld	a, c
	sub	a, -4 (ix)
	ld	a, b
	sbc	a, -3 (ix)
	jp	PO, 00239$
	xor	a, #0x80
00239$:
	jp	P, 00116$
;wolfram.c:84: putstr("=");
	push	bc
	ld	hl, #___str_1
	call	_putstr
	pop	bc
;wolfram.c:83: for (i = 0; i < width; i++)
	inc	bc
	jr	00132$
00116$:
;wolfram.c:86: putstr(".\r\n");
	ld	hl, #___str_5
	call	_putstr
;wolfram.c:88: return 0;
	ld	de, #0x0000
;wolfram.c:89: }
	ld	sp, ix
	pop	ix
	pop	hl
	pop	af
	jp	(hl)
___str_0:
	.db 0x0d
	.db 0x0a
	.ascii "."
	.db 0x00
___str_1:
	.ascii "="
	.db 0x00
___str_2:
	.ascii "."
	.db 0x0d
	.db 0x0a
	.ascii "."
	.db 0x00
___str_3:
	.ascii "#"
	.db 0x00
___str_4:
	.ascii " "
	.db 0x00
___str_5:
	.ascii "."
	.db 0x0d
	.db 0x0a
	.db 0x00
;wolfram.c:92: void main (void){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	ld	hl, #-16
	add	hl, sp
	ld	sp, hl
;wolfram.c:96: putstr("\r\nWolfram Cell Automaton 1.0 by ARMCoder - 2025\r\n");
	ld	hl, #___str_6
	call	_putstr
00102$:
;wolfram.c:100: putstr("\r\nEnter rule (0-255):");
	ld	hl, #___str_7
	call	_putstr
;wolfram.c:101: lgets(buf, sizeof(buf));
	ld	de, #0x0010
	ld	hl, #0
	add	hl, sp
	call	_lgets
;wolfram.c:102: int rule = atoi(buf);
	ld	hl, #0
	add	hl, sp
	call	_atoi
;wolfram.c:104: wolfram(50, 20, rule);
	push	de
	ld	de, #0x0014
	ld	hl, #0x0032
	call	_wolfram
	jr	00102$
;wolfram.c:106: }
	ld	hl, #16
	add	hl, sp
	ld	sp, hl
	ret
___str_6:
	.db 0x0d
	.db 0x0a
	.ascii "Wolfram Cell Automaton 1.0 by ARMCoder - 2025"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_7:
	.db 0x0d
	.db 0x0a
	.ascii "Enter rule (0-255):"
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
