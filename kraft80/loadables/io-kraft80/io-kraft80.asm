;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module io_kraft80
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _lcd_clear
	.globl _pos
	.globl _lgets_noecho
	.globl _lgets
	.globl _putstr
	.globl _putstr_lcd
	.globl _getchar
	.globl _putchar
	.globl _setleds
	.globl _readbuttons
	.globl _putchar_lcd
	.globl _lcd_home
	.globl _lcd_home2
	.globl _lcd_begin
	.globl _video_setpos
	.globl _video_out
	.globl _video_in
	.globl _video_begin
	.globl _serial_getchar
	.globl _serial_kbhit
	.globl _serial_putchar
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_pos::
	.ds 2
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
;io-kraft80.c:14: char *lgets_noecho(char *buf, int bufsize){
;	---------------------------------
; Function lgets_noecho
; ---------------------------------
_lgets_noecho::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-8
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
;io-kraft80.c:16: int i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
	ld	a, e
	add	a, #0xff
	ld	-8 (ix), a
	ld	a, d
	adc	a, #0xff
	ld	-7 (ix), a
00111$:
;io-kraft80.c:20: a = getchar();
	call	_getchar
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	a, -6 (ix)
	ld	-5 (ix), a
;io-kraft80.c:23: buf[i] = 0;
	ld	a, -2 (ix)
	add	a, -4 (ix)
	ld	c, a
	ld	a, -1 (ix)
	adc	a, -3 (ix)
	ld	b, a
;io-kraft80.c:22: if (a == 0x0d){
	ld	a, -5 (ix)
	sub	a, #0x0d
	jr	NZ, 00102$
;io-kraft80.c:23: buf[i] = 0;
	xor	a, a
	ld	(bc), a
;io-kraft80.c:24: return buf;
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	jr	00112$
00102$:
;io-kraft80.c:27: if (a == 0x08){
	ld	a, -5 (ix)
	sub	a, #0x08
	jr	NZ, 00106$
;io-kraft80.c:28: if (i) --i;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	Z, 00111$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;io-kraft80.c:29: continue;
	jr	00111$
00106$:
;io-kraft80.c:33: buf[i] = a;
	ld	a, -5 (ix)
	ld	(bc), a
;io-kraft80.c:34: if (i < (bufsize-1))
	ld	a, -2 (ix)
	sub	a, -8 (ix)
	ld	a, -1 (ix)
	sbc	a, -7 (ix)
	jp	PO, 00143$
	xor	a, #0x80
00143$:
	jp	P, 00111$
;io-kraft80.c:35: ++i;
	inc	-2 (ix)
	jr	NZ, 00111$
	inc	-1 (ix)
	jr	00111$
00112$:
;io-kraft80.c:38: }
	ld	sp, ix
	pop	ix
	ret
;io-kraft80.c:41: char *lgets(char *buf, int bufsize){
;	---------------------------------
; Function lgets
; ---------------------------------
_lgets::
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	iy, #-9
	add	iy, sp
	ld	sp, iy
	ld	-4 (ix), l
	ld	-3 (ix), h
;io-kraft80.c:43: int i = 0;
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
	ld	a, e
	add	a, #0xff
	ld	-9 (ix), a
	ld	a, d
	adc	a, #0xff
	ld	-8 (ix), a
00111$:
;io-kraft80.c:47: a = getchar();
	call	_getchar
	ld	-6 (ix), e
	ld	-5 (ix), d
	ld	a, -6 (ix)
;io-kraft80.c:48: putchar(a);
	ld	-7 (ix), a
;	spillPairReg hl
;	spillPairReg hl
	ld	-6 (ix), a
	ld	-5 (ix), #0x00
	ld	l, a
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	call	_putchar
;io-kraft80.c:50: buf[i] = 0;
	ld	a, -2 (ix)
	add	a, -4 (ix)
	ld	c, a
	ld	a, -1 (ix)
	adc	a, -3 (ix)
	ld	b, a
;io-kraft80.c:49: if (a == 0x0d){
	ld	a, -7 (ix)
	sub	a, #0x0d
	jr	NZ, 00102$
;io-kraft80.c:50: buf[i] = 0;
	xor	a, a
	ld	(bc), a
;io-kraft80.c:51: return buf;
	ld	e, -4 (ix)
	ld	d, -3 (ix)
	jr	00112$
00102$:
;io-kraft80.c:53: if (a == 0x08){
	ld	a, -7 (ix)
	sub	a, #0x08
	jr	NZ, 00106$
;io-kraft80.c:54: if (i) --i;
	ld	a, -1 (ix)
	or	a, -2 (ix)
	jr	Z, 00111$
	ld	l, -2 (ix)
	ld	h, -1 (ix)
	dec	hl
	ld	-2 (ix), l
	ld	-1 (ix), h
;io-kraft80.c:55: continue;
	jr	00111$
00106$:
;io-kraft80.c:57: buf[i] = a;
	ld	a, -7 (ix)
	ld	(bc), a
;io-kraft80.c:58: if (i < (bufsize-1))
	ld	a, -2 (ix)
	sub	a, -9 (ix)
	ld	a, -1 (ix)
	sbc	a, -8 (ix)
	jp	PO, 00143$
	xor	a, #0x80
00143$:
	jp	P, 00111$
;io-kraft80.c:59: ++i;
	inc	-2 (ix)
	jr	NZ, 00111$
	inc	-1 (ix)
	jr	00111$
00112$:
;io-kraft80.c:61: }
	ld	sp, ix
	pop	ix
	ret
;io-kraft80.c:64: void putstr(char *s){
;	---------------------------------
; Function putstr
; ---------------------------------
_putstr::
	ex	de, hl
;io-kraft80.c:66: while(*s){
00101$:
	ld	a, (de)
	or	a, a
	ret	Z
;io-kraft80.c:67: putchar(*(s++));
	inc	de
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	push	de
	call	_putchar
	pop	de
;io-kraft80.c:69: }
	jr	00101$
;io-kraft80.c:72: void putstr_lcd(char *s){
;	---------------------------------
; Function putstr_lcd
; ---------------------------------
_putstr_lcd::
;io-kraft80.c:74: while(*s){
00101$:
	ld	a, (hl)
	or	a, a
	ret	Z
;io-kraft80.c:75: putchar_lcd(*(s++));
	inc	hl
	ld	c, a
	push	hl
	ld	a, c
	call	_putchar_lcd
	pop	hl
;io-kraft80.c:77: }
	jr	00101$
;io-kraft80.c:81: int getchar() __naked{
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;io-kraft80.c:91: __endasm;
	rst	#0x10
	jr	z,_getchar
	ld	e,a
	ld	d,#0
	ret
;io-kraft80.c:92: }
;io-kraft80.c:96: int putchar (int a) __naked{
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
;io-kraft80.c:105: __endasm;
	ld	a,l
	rst	#0x08
	ld	l,#0
	ret
;io-kraft80.c:106: }
;io-kraft80.c:109: void setleds(char leds) __naked{
;	---------------------------------
; Function setleds
; ---------------------------------
_setleds::
;io-kraft80.c:118: __endasm;
	PORTA	.equ 0x00
	out(PORTA),a
	ret
;io-kraft80.c:119: }
;io-kraft80.c:122: unsigned char readbuttons() __naked{
;	---------------------------------
; Function readbuttons
; ---------------------------------
_readbuttons::
;io-kraft80.c:131: __endasm;
	PORTX	.equ 0x00
	in	a,(PORTX)
	ld	l,a
	ret
;io-kraft80.c:132: }
;io-kraft80.c:135: int putchar_lcd (char a) __naked{
;	---------------------------------
; Function putchar_lcd
; ---------------------------------
_putchar_lcd::
;io-kraft80.c:145: __endasm;
	push	bc
	ld	c,#12
	rst	#0x20
	ld	l,#0
	pop	bc
	ret
;io-kraft80.c:146: }
;io-kraft80.c:149: void lcd_home() __naked{
;	---------------------------------
; Function lcd_home
; ---------------------------------
_lcd_home::
;io-kraft80.c:159: __endasm;
	push	bc
	ld	c,#10
	rst	#0x20
	pop	bc
	ret
;io-kraft80.c:160: }
;io-kraft80.c:163: void lcd_home2() __naked{
;	---------------------------------
; Function lcd_home2
; ---------------------------------
_lcd_home2::
;io-kraft80.c:173: __endasm;
	push	bc
	ld	c,#11
	rst	#0x20
	pop	bc
	ret
;io-kraft80.c:174: }
;io-kraft80.c:177: void lcd_clear() __naked{
;	---------------------------------
; Function lcd_clear
; ---------------------------------
_lcd_clear::
;io-kraft80.c:187: __endasm;
	push	bc
	ld	c,#9
	rst	#0x20
	pop	bc
	ret
;io-kraft80.c:188: }
;io-kraft80.c:191: void lcd_begin() __naked{
;	---------------------------------
; Function lcd_begin
; ---------------------------------
_lcd_begin::
;io-kraft80.c:201: __endasm;
	push	bc
	ld	c,#8
	rst	#0x20
	pop	bc
	ret
;io-kraft80.c:202: }
;io-kraft80.c:207: void video_setpos(int row, int col){
;	---------------------------------
; Function video_setpos
; ---------------------------------
_video_setpos::
;io-kraft80.c:212: pos = 160*row + col;
	ld	c, l
	ld	b, h
	add	hl, hl
	add	hl, hl
	add	hl, bc
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	c, l
	ld	b, h
	ld	a, c
	ld	hl, #_pos
	add	a, e
	ld	(hl), a
	inc	hl
	ld	a, b
	adc	a, d
	ld	(hl), a
;io-kraft80.c:224: __endasm;
	di
	ld	hl,(_pos)
	ld	a,l
	out	(0x51),a
	ld	a,h
	out	(0x52),a
	ei
;io-kraft80.c:225: }
	ret
;io-kraft80.c:228: void video_out(unsigned char b){
;	---------------------------------
; Function video_out
; ---------------------------------
_video_out::
;io-kraft80.c:237: __endasm;
	out	(0x50),a
;io-kraft80.c:238: }
	ret
;io-kraft80.c:241: int video_in(void){
;	---------------------------------
; Function video_in
; ---------------------------------
_video_in::
;io-kraft80.c:253: __endasm;
	in	a,(0x50)
	ld	e,a
	ld	d,#0
	ret
;io-kraft80.c:254: }
	ret
;io-kraft80.c:257: void video_begin(int mode){
;	---------------------------------
; Function video_begin
; ---------------------------------
_video_begin::
;io-kraft80.c:269: __endasm;
	ld	(_pos), hl
	ld	a,l
	out	(0x53),a
;io-kraft80.c:271: video_setpos(row,0);
	ld	de, #0x0000
	ld	hl, #0x0000
	call	_video_setpos
;io-kraft80.c:273: for (row = 0; row < 240; row++){
	ld	bc, #0x0000
;io-kraft80.c:275: for (col = 0; col < 160; col++) video_out(0x00);
00109$:
	ld	de, #0x0000
00103$:
	push	bc
	push	de
	xor	a, a
	call	_video_out
	pop	de
	pop	bc
	inc	de
	ld	a, e
	sub	a, #0xa0
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00103$
;io-kraft80.c:273: for (row = 0; row < 240; row++){
	inc	bc
	ld	a, c
	sub	a, #0xf0
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00109$
;io-kraft80.c:277: }
	ret
;io-kraft80.c:280: int serial_getchar() __naked{
;	---------------------------------
; Function serial_getchar
; ---------------------------------
_serial_getchar::
;io-kraft80.c:291: __endasm;
	ld	c,#3
	rst	#0x20
	jr	z,_serial_getchar
	ld	e,a
	ld	d,#0
	ret
;io-kraft80.c:292: }
;io-kraft80.c:295: int serial_kbhit() __naked{
;	---------------------------------
; Function serial_kbhit
; ---------------------------------
_serial_kbhit::
;io-kraft80.c:307: __endasm;
	ld	c,#2
	rst	#0x20
	ld	d,#0
	ld	e,#0
	ret	z
	inc	e
	ret
;io-kraft80.c:308: }
;io-kraft80.c:311: int serial_putchar (int a) __naked{
;	---------------------------------
; Function serial_putchar
; ---------------------------------
_serial_putchar::
;io-kraft80.c:321: __endasm;
	ld	a,l
	ld	c,#1
	rst	#0x20
	ld	l,#0
	ret
;io-kraft80.c:322: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
