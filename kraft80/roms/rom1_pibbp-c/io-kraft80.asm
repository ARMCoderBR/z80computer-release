;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module io_kraft80
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _lcd_beg2
	.globl _lcd_clear
	.globl _lcd_cmd
	.globl _send_nibble
	.globl _dx100ms
	.globl _dx1ms
	.globl _d1ms
	.globl _dispcol
	.globl _lgets_noecho
	.globl _lgets
	.globl _putstr
	.globl _putchar_lcd
	.globl _putstr_lcd
	.globl _getchar
	.globl _putchar
	.globl _setleds
	.globl _readbuttons
	.globl _d100ms
	.globl _lcd_home
	.globl _lcd_home2
	.globl _lcd_begin
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
_dispcol::
	.ds 1
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
;io-kraft80.c:72: int putchar_lcd (char a) __naked{
;	---------------------------------
; Function putchar_lcd
; ---------------------------------
_putchar_lcd::
;io-kraft80.c:80: __endasm;
	ld	b,a
	call	lcd_write
	ld	l,#0
	ret
;io-kraft80.c:81: }
;io-kraft80.c:84: void putstr_lcd(char *s){
;	---------------------------------
; Function putstr_lcd
; ---------------------------------
_putstr_lcd::
;io-kraft80.c:86: while(*s){
00101$:
	ld	a, (hl)
	or	a, a
	ret	Z
;io-kraft80.c:87: putchar_lcd(*(s++));
	inc	hl
	ld	c, a
	push	hl
	ld	a, c
	call	_putchar_lcd
	pop	hl
;io-kraft80.c:89: }
	jr	00101$
;io-kraft80.c:93: int getchar() __naked{
;	---------------------------------
; Function getchar
; ---------------------------------
_getchar::
;io-kraft80.c:103: __endasm;
	rst	#0x10
	jr	z,_getchar
	ld	e,a
	ld	d,#0
	ret
;io-kraft80.c:104: }
;io-kraft80.c:108: int putchar (int a) __naked{
;	---------------------------------
; Function putchar
; ---------------------------------
_putchar::
;io-kraft80.c:117: __endasm;
	ld	a,l
	rst	#0x08
	ld	l,#0
	ret
;io-kraft80.c:118: }
;io-kraft80.c:121: void setleds(char leds) __naked{
;	---------------------------------
; Function setleds
; ---------------------------------
_setleds::
;io-kraft80.c:130: __endasm;
	PORTA	.equ 0x00
	out(PORTA),a
	ret
;io-kraft80.c:131: }
;io-kraft80.c:134: unsigned char readbuttons() __naked{
;	---------------------------------
; Function readbuttons
; ---------------------------------
_readbuttons::
;io-kraft80.c:143: __endasm;
	PORTX	.equ 0x00
	in	a,(PORTX)
	ld	l,a
	ret
;io-kraft80.c:144: }
;io-kraft80.c:147: void d1ms() __naked{
;	---------------------------------
; Function d1ms
; ---------------------------------
_d1ms::
;io-kraft80.c:161: __endasm;
;d1ms:	; 4.25µs 17 T States (call)
	push	bc ; 2.75µs 11 T States
	ld	b,#0xDB ; 1.75 µs 7 T States
	dloop:
	dec	b ; 1.0µs 4 T States
	nop	; 1.0µs 4 T States
	jp	nz,dloop ; 2.5µs 10 T States
	pop	bc ; 2.5µs 10 T States
	ret	; 2.5µs 10 T States
;io-kraft80.c:162: }
;io-kraft80.c:165: void dx1ms() __naked{
;	---------------------------------
; Function dx1ms
; ---------------------------------
_dx1ms::
;io-kraft80.c:174: __endasm;
	call	_d1ms ; 1ms (delay time)
	dec	d ; 1.0µs 4 T States
	jp	nz,_dx1ms ; 2.5µs 10 T States
	ret	; 2.5µs 10 T States
;io-kraft80.c:175: }
;io-kraft80.c:179: void d100ms() __naked{
;	---------------------------------
; Function d100ms
; ---------------------------------
_d100ms::
;io-kraft80.c:196: __endasm;
;d100ms:	; 4.25µs 17 T States
	push	bc ; 2.75µs 11 T States
	ld	b,#0x97 ; 1.75µs 7 T States
	aux1:
	ld	c,#0xBD ; 1.75µs 7 T States
	aux2:
	dec	c ; 1.0µs 4 T States
	jp	nz,aux2 ; 2.5µs 10 T States
	dec	b ; 1.0µs 4 T States
	jp	nz,aux1 ; 2.5µs 10 T States
	pop	bc ; 2.5µs 10 T States
	ret	; 2.5µs 10 T States
;io-kraft80.c:197: }
;io-kraft80.c:200: void dx100ms() __naked{
;	---------------------------------
; Function dx100ms
; ---------------------------------
_dx100ms::
;io-kraft80.c:210: __endasm;
;dx100ms:
	call	_d100ms ; 1ms (delay time)
	dec	d ; 1.0µs 4 T States
	jp	nz,_dx100ms ; 2.5µs 10 T States
	ret	; 2.5µs 10 T States
;io-kraft80.c:211: }
;io-kraft80.c:214: void send_nibble() __naked{
;	---------------------------------
; Function send_nibble
; ---------------------------------
_send_nibble::
;io-kraft80.c:254: __endasm;
	RS	.equ 0x01
	EN	.equ 0x01
	PORTB	.equ 0x10
;send_nibble:
	ld	a,#0x00 ;zera conteúdo de ACC
	bit	0,c ;bit 0 de c em LOW?
	jp	z,rs_clr ;sim, desvia para manter RS limpo
	ld	a,#0x00|RS ;não, seta bit RS
	rs_clr:
	bit	7,b ;bit7 de B em LOW?
	jp	z,b6aval ;sim, desvia para avaliar bit6
	set	7,a ;não, seta bit 7 de acc
	b6aval:
	bit	6,b ;bit6 de B em LOW?
	jp	z,b5aval ;sim, desvia para avaliar bit5
	set	6,a ;não, seta bit 6 de acc
	b5aval:
	bit	5,b ;bit5 de B em LOW?
	jp	z,b4aval ;sim, desvia para avaliar bit4
	set	5,a ;não, seta bit 5 de acc
	b4aval:
	bit	4,b ;bit4 de B em LOW?
	jp	z,lcd_en ;sim, desvia para pulso de enable
	set	4,a ;não, set bit 4 de acc
	lcd_en:
	set	EN,a ;pino enable em HIGH
	out	(PORTB),a ;escreve no PORTB
	ld	d,#2 ;carrega 2d em d
	call	_dx1ms ;aguarda 2ms
	res	EN,a ;pino enable em LOW
	out	(PORTB),a ;escreve no PORTB
	ld	d,#2 ;carrega 2d em d
	call	_dx1ms ;aguarda 2ms
	ret	;retorno da sub-rotina
;io-kraft80.c:255: }
;io-kraft80.c:258: void lcd_cmd() __naked{
;	---------------------------------
; Function lcd_cmd
; ---------------------------------
_lcd_cmd::
;io-kraft80.c:293: __endasm;
;lcd_cmd:
	ld	c,#0x00
	jr	send_byte
	lcd_write:
	ld	a,(_dispcol)
	cp	#16
	jr	nz,lcd_w1
	call	_lcd_home2
	jr	lcd_w2
	lcd_w1:
	cp	#32
	jr	nz,lcd_w2
	call	_lcd_home
	lcd_w2:
	ld	a,(_dispcol)
	inc	a
	ld	(_dispcol),a
	ld	c,#0x01 ;01h para envio de caracteres
	send_byte:
	call	_send_nibble ;envia nibble mais significativo
	ld	a,b ;carrega conteúdo de b em acc
	rla	;rotaciona acc para esquerda 4x
	rla	;
	rla	;
	rla	;
	and	#0xF0 ;máscara para preservar nibble mais significativo
	ld	b,a ;atualiza b
	call	_send_nibble ;envia nibble menos significativo
	ret	;retorno da sub-rotina
;io-kraft80.c:294: }
;io-kraft80.c:297: void lcd_home() __naked{
;	---------------------------------
; Function lcd_home
; ---------------------------------
_lcd_home::
;io-kraft80.c:312: __endasm;
;lcd_home:
	push	bc
	ld	b,#0x02 ;return home
	call	_lcd_cmd ;envia 02h para o LCD
	push	af
	xor	a
	ld	(_dispcol),a
	pop	af
	pop	bc
	ret
;io-kraft80.c:313: }
;io-kraft80.c:316: void lcd_home2() __naked{
;	---------------------------------
; Function lcd_home2
; ---------------------------------
_lcd_home2::
;io-kraft80.c:331: __endasm;
;lcd_home2:
	push	bc
	ld	b,#0xC0 ;posiciona cursor na linha 1, coluna 0
	call	_lcd_cmd ;envia comando
	push	af
	ld	a,#16
	ld	(_dispcol),a
	pop	af
	pop	bc
	ret
;io-kraft80.c:332: }
;io-kraft80.c:335: void lcd_clear() __naked{
;	---------------------------------
; Function lcd_clear
; ---------------------------------
_lcd_clear::
;io-kraft80.c:349: __endasm;
;lcd_clear:
;ld	b,#0x02 ;return home
;call	_lcd_cmd ;envia 02h para o LCD
	call	_lcd_home
	ld	b,#0x01 ;limpa o display
	call	_lcd_cmd ;envia 01h para o LCD
	xor	a
	ld	(_dispcol),a
	ret	;retorno da sub-rotina
;io-kraft80.c:350: }
;io-kraft80.c:353: void lcd_beg2() __naked{
;	---------------------------------
; Function lcd_beg2
; ---------------------------------
_lcd_beg2::
;io-kraft80.c:363: __endasm;
	ld	d,#2 ;carrega 2d em d
	call	_dx100ms ;aguarda 500ms
	ld	b,#0x0C ;desliga cursor e blink
	call	_lcd_cmd ;envia comando
	ret
;io-kraft80.c:364: }
;io-kraft80.c:367: void lcd_begin() __naked{
;	---------------------------------
; Function lcd_begin
; ---------------------------------
_lcd_begin::
;io-kraft80.c:400: __endasm;
	ld	d,#50 ;carrega 50d em d
	call	_dx1ms ;tempo para estabilização (50ms)
	ld	b,#0x30 ;protocolo de inicialização
	ld	c,#0x00 ;envio de comando
	call	_send_nibble ;envia 30h para o LCD
	ld	d,#5 ;carrega 5d em d
	call	_dx1ms ;aguarda 5ms (tempo superior ao datasheet)
	ld	b,#0x30 ;protocolo de inicialização
	ld	c,#0x00 ;envio de comando
	call	_send_nibble ;envia 30h para o LCD
	call	_d1ms ;aguarda 1ms (tempo superior ao datasheet)
	ld	b,#0x30 ;protocolo de inicialização
	ld	c,#0x00 ;envio de comando
	call	_send_nibble ;envia 30h para o LCD
	ld	b,#0x20 ;LCD no modo 4 bits
	ld	c,#0x00 ;envio de comando
	call	_send_nibble ;envia 30h para o LCD
	ld	b,#0x28 ;5x8 pontos por caractere, duas linhas
	call	_lcd_cmd ;envia comando 28h
	ld	b,#0x0F ;liga display, cursor e blink
	call	_lcd_cmd ;envia comando 0Fh
	ld	b,#0x01 ;limpa LCD
	call	_lcd_cmd ;envia comando 01h
	ld	b,#0x06 ;modo de incremento de endereço para direita, movendo apenas o cursor
	call	_lcd_cmd ;envia comando 06h
	call	_lcd_clear ;limpa o display
	call	_lcd_beg2
	ret	;retorno da sub-rotina
;io-kraft80.c:401: }
	.area _CODE
	.area _INITIALIZER
__xinit__dispcol:
	.db #0x00	; 0
	.area _CABS (ABS)
