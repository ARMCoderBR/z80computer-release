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
	.globl _video_border
	.globl _video_printtime
	.globl _video_begin
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
;clock.c:28: void main (void){
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	ld	hl, #-7
	add	hl, sp
	ld	sp, hl
;clock.c:38: isr2vector = (int*)0x4104;
	ld	hl, #0x4104
	ld	(_isr2vector), hl
;clock.c:42: setleds(0x55);
	ld	a, #0x55
	call	_setleds
;clock.c:43: lcd_begin();
	call	_lcd_begin
;clock.c:45: video_begin(1);
	ld	hl, #0x0001
	call	_video_begin
;clock.c:46: video_border();
	call	_video_border
;clock.c:48: isr2vector_copy = *isr2vector;
	ld	hl, (_isr2vector)
	ld	a, (hl)
	inc	hl
	ld	(_isr2vector_copy+0), a
	ld	a, (hl)
	ld	(_isr2vector_copy+1), a
;clock.c:50: di();
	call	_di
;clock.c:52: *isr2vector = (int)new_isr2;
	ld	hl, (_isr2vector)
	ld	bc, #_new_isr2
	ld	(hl), c
	inc	hl
	ld	(hl), b
;clock.c:54: ei();
	call	_ei
;clock.c:56: printtime();
	call	_printtime
;clock.c:58: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
;clock.c:60: buttons = buttons_a = readbuttons();
	call	_readbuttons
	ld	c, a
00131$:
;clock.c:64: buttons = readbuttons();
	push	bc
	call	_readbuttons
	pop	bc
;clock.c:65: delta = buttons ^ buttons_a;
	ld	-7 (ix), a
	xor	a, c
;clock.c:67: if (delta & 0x01 & buttons_a){
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
;clock.c:68: di();
	call	_di
;clock.c:69: hours++;
	ld	iy, #_hours
	inc	0 (iy)
;clock.c:70: if (hours == 24) hours = 0;
	ld	a, (_hours+0)
	sub	a, #0x18
	jr	NZ, 00102$
	ld	0 (iy), #0x00
00102$:
;clock.c:71: ei();
	call	_ei
;clock.c:72: printtime();
	call	_printtime
;clock.c:73: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00104$:
;clock.c:76: if (delta & 0x02 & buttons_a){
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
;clock.c:77: di();
	call	_di
;clock.c:78: mins++;
	ld	iy, #_mins
	inc	0 (iy)
;clock.c:79: if (mins == 60) mins = 0;
	ld	a, (_mins+0)
	sub	a, #0x3c
	jr	NZ, 00106$
	ld	0 (iy), #0x00
00106$:
;clock.c:80: ei();
	call	_ei
;clock.c:81: printtime();
	call	_printtime
;clock.c:82: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00108$:
;clock.c:85: if (delta & 0x04 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x04
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00112$
;clock.c:86: di();
	call	_di
;clock.c:87: secs++;
	ld	iy, #_secs
	inc	0 (iy)
;clock.c:88: if (secs == 60) secs = 0;
	ld	a, (_secs+0)
	sub	a, #0x3c
	jr	NZ, 00110$
	ld	0 (iy), #0x00
00110$:
;clock.c:89: ei();
	call	_ei
;clock.c:90: printtime();
	call	_printtime
;clock.c:91: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00112$:
;clock.c:94: if (delta & 0x08 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x08
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00117$
;clock.c:95: di();
	call	_di
;clock.c:96: if (hours)
	ld	a, (_hours+0)
	or	a, a
	jr	Z, 00114$
;clock.c:97: hours--;
	ld	hl, #_hours
	dec	(hl)
	jr	00115$
00114$:
;clock.c:99: hours = 23;
	ld	hl, #_hours
	ld	(hl), #0x17
00115$:
;clock.c:100: ei();
	call	_ei
;clock.c:101: printtime();
	call	_printtime
;clock.c:102: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00117$:
;clock.c:105: if (delta & 0x10 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x10
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00122$
;clock.c:106: di();
	call	_di
;clock.c:107: if (mins)
	ld	a, (_mins+0)
	or	a, a
	jr	Z, 00119$
;clock.c:108: mins--;
	ld	hl, #_mins
	dec	(hl)
	jr	00120$
00119$:
;clock.c:110: mins = 59;
	ld	hl, #_mins
	ld	(hl), #0x3b
00120$:
;clock.c:111: ei();
	call	_ei
;clock.c:112: printtime();
	call	_printtime
;clock.c:113: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00122$:
;clock.c:116: if (delta & 0x20 & buttons_a){
	ld	a, -6 (ix)
	and	a, #0x20
	ld	c, #0x00
	and	a, -4 (ix)
	ld	b, a
	ld	a, c
	and	a, -3 (ix)
	or	a, b
	jr	Z, 00127$
;clock.c:117: di();
	call	_di
;clock.c:118: if (secs)
	ld	a, (_secs+0)
	or	a, a
	jr	Z, 00124$
;clock.c:119: secs--;
	ld	hl, #_secs
	dec	(hl)
	jr	00125$
00124$:
;clock.c:121: secs = 59;
	ld	hl, #_secs
	ld	(hl), #0x3b
00125$:
;clock.c:122: ei();
	call	_ei
;clock.c:123: printtime();
	call	_printtime
;clock.c:124: video_printtime(hours, mins, secs);
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
00127$:
;clock.c:127: buttons_a = buttons;
	ld	c, -7 (ix)
;clock.c:129: setleds(*p & buttons);
	ld	a, (#0x41fe)
	and	a, -7 (ix)
	ld	b, a
	push	bc
	ld	a, b
	call	_setleds
	pop	bc
;clock.c:130: if (secs != secs_a){
	ld	a, (_secs+0)
	ld	hl, #_secs_a
	sub	a, (hl)
	jp	Z,00131$
;clock.c:131: secs_a = secs;
	ld	a, (_secs+0)
	ld	(_secs_a+0), a
;clock.c:132: printtime();
	push	bc
	call	_printtime
	ld	a, (_secs+0)
	push	af
	inc	sp
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, (_hours+0)
	call	_video_printtime
	pop	bc
;clock.c:136: }
	jp	00131$
;clock.c:139: void di() __naked{
;	---------------------------------
; Function di
; ---------------------------------
_di::
;clock.c:144: __endasm;
	di
	ret
;clock.c:145: }
;clock.c:148: void ei() __naked{
;	---------------------------------
; Function ei
; ---------------------------------
_ei::
;clock.c:153: __endasm;
	ei
	ret
;clock.c:154: }
;clock.c:157: void printlcddec(int d){
;	---------------------------------
; Function printlcddec
; ---------------------------------
_printlcddec::
;clock.c:159: putchar_lcd('0' + (d / 10));
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
;clock.c:160: putchar_lcd('0' + (d % 10));
	ld	de, #0x000a
	call	__modsint
	ld	a, e
	add	a, #0x30
	ld	c, a
;clock.c:161: }
	jp	_putchar_lcd
;clock.c:164: void printtime(void){
;	---------------------------------
; Function printtime
; ---------------------------------
_printtime::
;clock.c:166: lcd_home();
	call	_lcd_home
;clock.c:167: printlcddec(hours);
	ld	a, (_hours+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	call	_printlcddec
;clock.c:168: putchar_lcd(':');
	ld	a, #0x3a
	call	_putchar_lcd
;clock.c:169: printlcddec(mins);
	ld	a, (_mins+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	call	_printlcddec
;clock.c:170: putchar_lcd(':');
	ld	a, #0x3a
	call	_putchar_lcd
;clock.c:171: printlcddec(secs);
	ld	a, (_secs+0)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
;clock.c:172: }
	jp	_printlcddec
;clock.c:175: void new_isr2(void) __interrupt {
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
;clock.c:177: presc++;
	ld	hl, (_presc)
	inc	hl
	ld	(_presc), hl
;clock.c:178: if (presc == 300){
	ld	a, (_presc+0)
	sub	a, #0x2c
	jr	NZ, 00108$
	ld	a, (_presc+1)
	dec	a
	jr	NZ, 00108$
;clock.c:179: presc = 0;
	ld	hl, #0x0000
	ld	(_presc), hl
;clock.c:180: secs++;
	ld	iy, #_secs
	inc	0 (iy)
;clock.c:181: if (secs == 60){
	ld	a, (_secs+0)
	sub	a, #0x3c
	jr	NZ, 00108$
;clock.c:182: secs = 0;
	ld	0 (iy), #0x00
;clock.c:183: ++mins;
	ld	iy, #_mins
	inc	0 (iy)
;clock.c:184: if (mins == 60){
	ld	a, (_mins+0)
	sub	a, #0x3c
	jr	NZ, 00108$
;clock.c:185: mins = 0;
	ld	0 (iy), #0x00
;clock.c:186: ++hours;
	ld	iy, #_hours
	inc	0 (iy)
;clock.c:187: if (hours == 24){
	ld	a, (_hours+0)
	sub	a, #0x18
	jr	NZ, 00108$
;clock.c:188: hours = 0;
	ld	0 (iy), #0x00
00108$:
;clock.c:202: __endasm;
	ld	hl,#ret_isr2
	push	hl
	ld	hl,(_isr2vector_copy)
	jp	(hl)
	ret_isr2:
;clock.c:203: }
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
