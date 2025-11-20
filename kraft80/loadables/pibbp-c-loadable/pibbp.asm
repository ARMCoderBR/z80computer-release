;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module pibbp
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _readbuttons
	.globl _setleds
	.globl _lcd_begin
	.globl _putchar_lcd
	.globl _putstr_lcd
	.globl _putstr
	.globl _putchar
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
;pibbp.c:15: void main (void){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-10
	add	hl, sp
	ld	sp, hl
;pibbp.c:17: setleds(0x55);
	ld	a, #0x55
	call	_setleds
;pibbp.c:18: lcd_begin();
	call	_lcd_begin
;pibbp.c:20: putstr ("PI CALC BBP\r\n");
	ld	hl, #___str_0
	call	_putstr
;pibbp.c:21: putstr_lcd("PI CALC BBP     ");
	ld	hl, #___str_1
	call	_putstr_lcd
;pibbp.c:27: pi = 0;
	ld	de, #0x0000
	ld	bc, #0x0000
;pibbp.c:30: for (k = 0; k < 10; k++){
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00108$:
;pibbp.c:32: oitok = 8*k;
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	add	hl, hl
	add	hl, hl
	add	hl, hl
	push	bc
	push	de
	call	___sint2fs
	push	de
	pop	iy
	pop	de
	pop	bc
	inc	sp
	inc	sp
	push	iy
	ld	-8 (ix), l
	ld	-7 (ix), h
;pibbp.c:33: sum = (4/(oitok+1) - 2/(oitok+4) - 1/(oitok+5) - 1/(oitok+6));
	push	bc
	push	de
	ld	hl, #0x3f80
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	de
	pop	iy
	push	hl
	push	iy
	ld	de, #0x0000
	ld	hl, #0x4080
	call	___fsdiv
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	hl, #0x4080
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	de
	pop	iy
	push	hl
	push	iy
	ld	de, #0x0000
	ld	hl, #0x4000
	call	___fsdiv
	push	de
	pop	iy
	push	hl
	push	iy
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	hl, #0x40a0
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	de
	pop	iy
	push	hl
	push	iy
	ld	de, #0x0000
	ld	hl, #0x3f80
	call	___fsdiv
	push	de
	pop	iy
	push	hl
	push	iy
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
	ld	hl, #0x40c0
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	e, -10 (ix)
	ld	d, -9 (ix)
	ld	l, -8 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -7 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	push	de
	pop	iy
	push	hl
	push	iy
	ld	de, #0x0000
	ld	hl, #0x3f80
	call	___fsdiv
	push	de
	pop	iy
	push	hl
	push	iy
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
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
;pibbp.c:34: for (int l = 0; l < k; l++)
	ld	hl, #0x0000
00106$:
	ld	a, l
	sub	a, -2 (ix)
	ld	a, h
	sbc	a, -1 (ix)
	jp	PO, 00162$
	xor	a, #0x80
00162$:
	jp	P, 00101$
;pibbp.c:35: sum /= 16;
	push	hl
	push	bc
	push	de
	ld	hl, #0x4180
	push	hl
	ld	hl, #0x0000
	push	hl
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fsdiv
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
	pop	de
	pop	bc
	pop	hl
;pibbp.c:34: for (int l = 0; l < k; l++)
	inc	hl
	jr	00106$
00101$:
;pibbp.c:36: pi += sum;
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, -6 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -5 (ix)
;	spillPairReg hl
;	spillPairReg hl
	push	hl
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___fsadd
	ld	c, l
	ld	b, h
;pibbp.c:30: for (k = 0; k < 10; k++){
	inc	-2 (ix)
	jr	NZ, 00163$
	inc	-1 (ix)
00163$:
	ld	a, -2 (ix)
	sub	a, #0x0a
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jp	C, 00108$
;pibbp.c:39: putstr("PI:3.");
	push	bc
	push	de
	ld	hl, #___str_2
	call	_putstr
	ld	hl, #___str_2
	call	_putstr_lcd
	pop	de
	pop	bc
;pibbp.c:42: pi -= (int)pi;
	push	bc
	push	de
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___fs2sint
	ex	de, hl
	call	___sint2fs
	push	de
	pop	iy
	pop	de
	pop	bc
	push	hl
	push	iy
	ld	l, c
;	spillPairReg hl
;	spillPairReg hl
	ld	h, b
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
;pibbp.c:43: pi *= 10;
	push	hl
	push	de
	ld	de, #0x0000
	ld	hl, #0x4120
	call	___fsmul
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
;pibbp.c:45: for (int i = 0; i < 7; i++){
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00111$:
	ld	a, -2 (ix)
	sub	a, #0x07
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	NC, 00103$
;pibbp.c:42: pi -= (int)pi;
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fs2sint
;pibbp.c:46: putchar ('0'+(int)pi);
	ld	hl, #0x0030
	add	hl, de
	push	de
	call	_putchar
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fs2sint
	ld	a, e
	pop	de
	add	a, #0x30
	ld	c, a
	push	de
	ld	a, c
	call	_putchar_lcd
	pop	de
;pibbp.c:48: pi -= (int)pi;
	ex	de, hl
	call	___sint2fs
	push	hl
	push	de
	ld	e, -6 (ix)
	ld	d, -5 (ix)
	ld	l, -4 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -3 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	___fssub
;pibbp.c:49: pi *= 10;
	push	hl
	push	de
	ld	de, #0x0000
	ld	hl, #0x4120
	call	___fsmul
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	-4 (ix), l
	ld	-3 (ix), h
;pibbp.c:45: for (int i = 0; i < 7; i++){
	inc	-2 (ix)
	jr	NZ, 00111$
	inc	-1 (ix)
	jr	00111$
00103$:
;pibbp.c:52: putstr("\r\n");
	ld	hl, #___str_3
	call	_putstr
;pibbp.c:54: char *p = 0xfffe;
00113$:
;pibbp.c:57: setleds(*p & readbuttons());
	ld	hl, #0xfffe
	ld	c, (hl)
	push	bc
	call	_readbuttons
	pop	bc
	and	a, c
	call	_setleds
;pibbp.c:59: }
	jr	00113$
___str_0:
	.ascii "PI CALC BBP"
	.db 0x0d
	.db 0x0a
	.db 0x00
___str_1:
	.ascii "PI CALC BBP     "
	.db 0x00
___str_2:
	.ascii "PI:3."
	.db 0x00
___str_3:
	.db 0x0d
	.db 0x0a
	.db 0x00
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
