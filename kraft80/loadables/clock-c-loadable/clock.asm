;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module clock
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _printlcddec
	.globl _main
	.globl _lcd_home
	.globl _readbuttons
	.globl _setleds
	.globl _lcd_begin
	.globl _putchar_lcd
	.globl _secs_a
	.globl _secs
	.globl _mins
	.globl _hours
	.globl _presc
	.globl _isr2vector_copy
	.globl _isr2vector
	.globl _di
	.globl _ei
	.globl _printtime
	.globl _new_isr2
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_isr2vector::
	.ds 2
_isr2vector_copy::
	.ds 2
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
_presc::
	.ds 2
_hours::
	.ds 1
_mins::
	.ds 1
_secs::
	.ds 1
_secs_a::
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
;clock.c:27: void main (void){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;clock.c:37: isr2vector = (int*)0x4104;
	ld	hl, #0x4104
	ld	(_isr2vector), hl
;clock.c:41: setleds(0x55);
	ld	a, #0x55
	call	_setleds
;clock.c:42: lcd_begin();
	call	_lcd_begin
;clock.c:44: isr2vector_copy = *isr2vector;
	ld	hl, (_isr2vector)
	ld	a, (hl)
	inc	hl
	ld	(_isr2vector_copy+0), a
	ld	a, (hl)
	ld	(_isr2vector_copy+1), a
;clock.c:46: di();
	call	_di
;clock.c:48: *isr2vector = (int)new_isr2;
	ld	hl, (_isr2vector)
	ld	bc, #_new_isr2
	ld	(hl), c
	inc	hl
	ld	(hl), b
;clock.c:50: ei();
	call	_ei
;clock.c:52: printtime();
	call	_printtime
;clock.c:54: buttons = buttons_a = readbuttons();
	call	_readbuttons
	ld	c, a
00131$:
;clock.c:58: buttons = readbuttons();
	push	bc
	call	_readbuttons
	pop	bc
;clock.c:59: delta = buttons ^ buttons_a;
	ld	-7 (ix), a
	xor	a, c
;clock.c:61: if (delta & 0x01 & buttons_a){
	ld	-6 (ix), a
	ld	-5 (ix), #0x00
	ld	a, -6 (ix)
	and	a, #0x01
	ld	b, #0x00
	ld	-4 (ix), c
	ld	-3 (ix), #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00104$
;clock.c:62: di();
	call	_di
;clock.c:63: hours++;
	ld	iy, #_hours
	inc	0 (iy)
;clock.c:64: if (hours == 24) hours = 0;
	ld	a, (_hours+0)
	sub	a, #0x18
	jr	NZ, 00102$
	ld	0 (iy), #0x00
00102$:
;clock.c:65: ei();
	call	_ei
;clock.c:66: printtime();
	call	_printtime
00104$:
;clock.c:69: if (delta & 0x02 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x02
	ld	c, #0x00
	and	a, -4 (ix)
	ld	-2 (ix), a
	ld	a, c
	and	a, -3 (ix)
	ld	-1 (ix), a
	or	a, -2 (ix)
	jr	Z, 00108$
;clock.c:70: di();
	call	_di
;clock.c:71: mins++;
	ld	iy, #_mins
	inc	0 (iy)
;clock.c:72: if (mins == 60) mins = 0;
	ld	a, (_mins+0)
	sub	a, #0x3c
	jr	NZ, 00106$
	ld	0 (iy), #0x00
00106$:
;clock.c:73: ei();
	call	_ei
;clock.c:74: printtime();
	call	_printtime
00108$:
;clock.c:77: if (delta & 0x04 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x04
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00112$
;clock.c:78: di();
	call	_di
;clock.c:79: secs++;
	ld	iy, #_secs
	inc	0 (iy)
;clock.c:80: if (secs == 60) secs = 0;
	ld	a, (_secs+0)
	sub	a, #0x3c
	jr	NZ, 00110$
	ld	0 (iy), #0x00
00110$:
;clock.c:81: ei();
	call	_ei
;clock.c:82: printtime();
	call	_printtime
00112$:
;clock.c:85: if (delta & 0x08 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x08
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00117$
;clock.c:86: di();
	call	_di
;clock.c:87: if (hours)
	ld	a, (_hours+0)
	or	a, a
	jr	Z, 00114$
;clock.c:88: hours--;
	ld	hl, #_hours
	dec	(hl)
	jr	00115$
00114$:
;clock.c:90: hours = 23;
	ld	hl, #_hours
	ld	(hl), #0x17
00115$:
;clock.c:91: ei();
	call	_ei
;clock.c:92: printtime();
	call	_printtime
00117$:
;clock.c:95: if (delta & 0x10 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x10
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00122$
;clock.c:96: di();
	call	_di
;clock.c:97: if (mins)
	ld	a, (_mins+0)
	or	a, a
	jr	Z, 00119$
;clock.c:98: mins--;
	ld	hl, #_mins
	dec	(hl)
	jr	00120$
00119$:
;clock.c:100: mins = 59;
	ld	hl, #_mins
	ld	(hl), #0x3b
00120$:
;clock.c:101: ei();
	call	_ei
;clock.c:102: printtime();
	call	_printtime
00122$:
;clock.c:105: if (delta & 0x20 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x20
	ld	c, #0x00
	and	a, -4 (ix)
	ld	b, a
	ld	a, c
	and	a, -3 (ix)
	or	a, b
	jr	Z, 00127$
;clock.c:106: di();
	call	_di
;clock.c:107: if (secs)
	ld	a, (_secs+0)
	or	a, a
	jr	Z, 00124$
;clock.c:108: secs--;
	ld	hl, #_secs
	dec	(hl)
	jr	00125$
00124$:
;clock.c:110: secs = 59;
	ld	hl, #_secs
	ld	(hl), #0x3b
00125$:
;clock.c:111: ei();
	call	_ei
;clock.c:112: printtime();
	call	_printtime
00127$:
;clock.c:115: buttons_a = buttons;
	ld	c, -7 (ix)
;clock.c:117: setleds(*p & buttons);
	ld	a, (#0x41fe)
	and	a, -7 (ix)
	ld	b, a
	push	bc
	ld	a, b
	call	_setleds
	pop	bc
;clock.c:118: if (secs != secs_a){
	ld	a, (_secs+0)
	ld	hl, #_secs_a
	sub	a, (hl)
	jp	Z,00131$
;clock.c:119: secs_a = secs;
	ld	a, (_secs+0)
	ld	(_secs_a+0), a
;clock.c:120: printtime();
	push	bc
	call	_printtime
	pop	bc
;clock.c:123: }
	jp	00131$
;clock.c:126: void di() __naked{
;	---------------------------------
; Function di
; ---------------------------------
_di::
;clock.c:131: __endasm;
	di
	ret
;clock.c:132: }
;clock.c:135: void ei() __naked{
;	---------------------------------
; Function ei
; ---------------------------------
_ei::
;clock.c:140: __endasm;
	ei
	ret
;clock.c:141: }
;clock.c:144: void printlcddec(int d){
;	---------------------------------
; Function printlcddec
; ---------------------------------
_printlcddec::
;clock.c:146: putchar_lcd('0' + (d / 10));
	push	hl
	ld	de, #0x000a
	call	__divsint
	pop	hl
	ld	a, e
	add	a, #0x30
	ld	c, a
	push	hl
	ld	a, c
	call	_putchar_lcd
	pop	hl
;clock.c:147: putchar_lcd('0' + (d % 10));
	ld	de, #0x000a
	call	__modsint
	ld	a, e
	add	a, #0x30
	ld	c, a
;clock.c:148: }
	jp	_putchar_lcd
;clock.c:151: void printtime(void){
;	---------------------------------
; Function printtime
; ---------------------------------
_printtime::
;clock.c:153: lcd_home();
	call	_lcd_home
;clock.c:154: printlcddec(hours);
	ld	a, (_hours+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	call	_printlcddec
;clock.c:155: putchar_lcd(':');
	ld	a, #0x3a
	call	_putchar_lcd
;clock.c:156: printlcddec(mins);
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	call	_printlcddec
;clock.c:157: putchar_lcd(':');
	ld	a, #0x3a
	call	_putchar_lcd
;clock.c:158: printlcddec(secs);
	ld	a, (_secs+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
;clock.c:159: }
	jp	_printlcddec
;clock.c:162: void new_isr2(void) __interrupt {
;	---------------------------------
; Function new_isr2
; ---------------------------------
_new_isr2::
	ei
	push	af
	push	bc
	push	de
	push	hl
	push	iy
;clock.c:164: presc++;
	ld	hl, (_presc)
	inc	hl
	ld	(_presc), hl
;clock.c:165: if (presc == 300){
	ld	a, (_presc+0)
	sub	a, #0x2c
	jr	NZ, 00108$
	ld	a, (_presc+1)
	dec	a
	jr	NZ, 00108$
;clock.c:166: presc = 0;
	ld	hl, #0x0000
	ld	(_presc), hl
;clock.c:167: secs++;
	ld	iy, #_secs
	inc	0 (iy)
;clock.c:168: if (secs == 60){
	ld	a, (_secs+0)
	sub	a, #0x3c
	jr	NZ, 00108$
;clock.c:169: secs = 0;
	ld	0 (iy), #0x00
;clock.c:170: ++mins;
	ld	iy, #_mins
	inc	0 (iy)
;clock.c:171: if (mins == 60){
	ld	a, (_mins+0)
	sub	a, #0x3c
	jr	NZ, 00108$
;clock.c:172: mins = 0;
	ld	0 (iy), #0x00
;clock.c:173: ++hours;
	ld	iy, #_hours
	inc	0 (iy)
;clock.c:174: if (hours == 24){
	ld	a, (_hours+0)
	sub	a, #0x18
	jr	NZ, 00108$
;clock.c:175: hours = 0;
	ld	0 (iy), #0x00
00108$:
;clock.c:189: __endasm;
	ld	hl,#ret_isr2
	push	hl
	ld	hl,(_isr2vector_copy)
	jp	(hl)
	ret_isr2:
;clock.c:190: }
	pop	iy
	pop	hl
	pop	de
	pop	bc
	pop	af
	reti
	.area _CODE
	.area _INITIALIZER
__xinit__presc:
	.dw #0x0000
__xinit__hours:
	.db #0x00	; 0
__xinit__mins:
	.db #0x00	; 0
__xinit__secs:
	.db #0x00	; 0
__xinit__secs_a:
	.db #0x00	; 0
	.area _CABS (ABS)
