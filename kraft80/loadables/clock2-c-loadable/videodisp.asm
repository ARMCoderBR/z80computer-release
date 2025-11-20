;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 4.2.0 #13081 (Linux)
;--------------------------------------------------------
	.module videodisp
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _rasterdec
	.globl _rasterchar
	.globl _video_out
	.globl _video_setpos
	.globl _base
	.globl _d10
	.globl _d9
	.globl _d8
	.globl _d7
	.globl _d6
	.globl _d5
	.globl _d4
	.globl _d3
	.globl _d2
	.globl _d1
	.globl _d0
	.globl _video_printtime
	.globl _video_border
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
_base::
	.ds 22
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
;videodisp.c:130: void rasterchar(char d, int line){
;	---------------------------------
; Function rasterchar
; ---------------------------------
_rasterchar::
	call	___sdcc_enter_ix
	ld	hl, #-6
	add	hl, sp
	ld	sp, hl
;videodisp.c:132: char *base1 = base[d];
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	add	hl, hl
	ld	bc, #_base
	add	hl, bc
	ld	a, (hl)
	inc	hl
	ld	l, (hl)
;	spillPairReg hl
;videodisp.c:134: int mask=128;
	ld	-4 (ix), #0x80
	ld	-3 (ix), #0x00
;videodisp.c:136: for (i = 0; i < 8; i++){
	add	a, e
	ld	-6 (ix), a
	ld	a, l
	adc	a, d
	ld	-5 (ix), a
	xor	a, a
	ld	-2 (ix), a
	ld	-1 (ix), a
00105$:
;videodisp.c:137: if (base1[line] & mask)
	pop	hl
	push	hl
	ld	a, (hl)
	ld	b, #0x00
	and	a, -4 (ix)
	ld	c, a
	ld	a, b
	and	a, -3 (ix)
	or	a, c
	jr	Z, 00102$
;videodisp.c:138: video_out(0x22);
	ld	a, #0x22
	call	_video_out
	jr	00103$
00102$:
;videodisp.c:140: video_out(0);
	xor	a, a
	call	_video_out
00103$:
;videodisp.c:141: mask >>= 1;
	sra	-3 (ix)
	rr	-4 (ix)
;videodisp.c:136: for (i = 0; i < 8; i++){
	inc	-2 (ix)
	jr	NZ, 00120$
	inc	-1 (ix)
00120$:
	ld	a, -2 (ix)
	sub	a, #0x08
	ld	a, -1 (ix)
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00105$
;videodisp.c:143: }
	ld	sp, ix
	pop	ix
	ret
_d0:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x00	; 0
_d1:
	.db #0x00	; 0
	.db #0x10	; 16
	.db #0x30	; 48	'0'
	.db #0x50	; 80	'P'
	.db #0x10	; 16
	.db #0x10	; 16
	.db #0x78	; 120	'x'
	.db #0x00	; 0
_d2:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x1c	; 28
	.db #0x60	; 96
	.db #0x80	; 128
	.db #0xfe	; 254
	.db #0x00	; 0
_d3:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x1c	; 28
	.db #0x02	; 2
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x00	; 0
_d4:
	.db #0x00	; 0
	.db #0x18	; 24
	.db #0x28	; 40
	.db #0x48	; 72	'H'
	.db #0xfe	; 254
	.db #0x08	; 8
	.db #0x08	; 8
	.db #0x00	; 0
_d5:
	.db #0x00	; 0
	.db #0xfc	; 252
	.db #0x80	; 128
	.db #0xfc	; 252
	.db #0x02	; 2
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x00	; 0
_d6:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x80	; 128
	.db #0xfc	; 252
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x00	; 0
_d7:
	.db #0x00	; 0
	.db #0xfe	; 254
	.db #0x04	; 4
	.db #0x08	; 8
	.db #0x10	; 16
	.db #0x20	; 32
	.db #0x40	; 64
	.db #0x00	; 0
_d8:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x7c	; 124
	.db #0x00	; 0
_d9:
	.db #0x00	; 0
	.db #0x7c	; 124
	.db #0x82	; 130
	.db #0x82	; 130
	.db #0x7e	; 126
	.db #0x02	; 2
	.db #0x7c	; 124
	.db #0x00	; 0
_d10:
	.db #0x00	; 0
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
	.db #0x30	; 48	'0'
	.db #0x30	; 48	'0'
	.db #0x00	; 0
;videodisp.c:146: void rasterdec(char d, int line){
;	---------------------------------
; Function rasterdec
; ---------------------------------
_rasterdec::
	call	___sdcc_enter_ix
	ld	hl, #-9
	add	hl, sp
	ld	sp, hl
	ld	-3 (ix), a
	ld	c, e
	ld	b, d
;videodisp.c:148: char *base1 = base[d / 10];
	ld	a, -3 (ix)
	ld	-2 (ix), a
	ld	-1 (ix), #0x00
	push	bc
	ld	de, #0x000a
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	__divsint
	ex	de, hl
	pop	bc
	add	hl, hl
	ld	de, #_base
	add	hl, de
	ld	a, (hl)
	ld	-9 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-8 (ix), a
;videodisp.c:149: char *base2 = base[d % 10];
	push	bc
	ld	de, #0x000a
	ld	l, -2 (ix)
;	spillPairReg hl
;	spillPairReg hl
	ld	h, -1 (ix)
;	spillPairReg hl
;	spillPairReg hl
	call	__modsint
	ex	de, hl
	pop	bc
	add	hl, hl
	ld	de, #_base
	add	hl, de
	ld	a, (hl)
	ld	-7 (ix), a
	inc	hl
	ld	a, (hl)
	ld	-6 (ix), a
;videodisp.c:151: int mask=128;
	ld	-2 (ix), #0x80
	ld	-1 (ix), #0
;videodisp.c:153: for (i = 0; i < 8; i++){
	ld	a, -9 (ix)
	add	a, c
	ld	-5 (ix), a
	ld	a, -8 (ix)
	adc	a, b
	ld	-4 (ix), a
	ld	de, #0x0000
00109$:
;videodisp.c:154: if (base1[line] & mask)
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	a, (hl)
	ld	h, #0x00
;	spillPairReg hl
;	spillPairReg hl
	and	a, -2 (ix)
	ld	l, a
;	spillPairReg hl
;	spillPairReg hl
	ld	a, h
	and	a, -1 (ix)
	or	a, l
	jr	Z, 00102$
;videodisp.c:155: video_out(0x44);
	push	bc
	push	de
	ld	a, #0x44
	call	_video_out
	pop	de
	pop	bc
	jr	00103$
00102$:
;videodisp.c:157: video_out(0);
	push	bc
	push	de
	xor	a, a
	call	_video_out
	pop	de
	pop	bc
00103$:
;videodisp.c:158: mask >>= 1;
	sra	-1 (ix)
	rr	-2 (ix)
;videodisp.c:153: for (i = 0; i < 8; i++){
	inc	de
	ld	a, e
	sub	a, #0x08
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00109$
;videodisp.c:161: mask=128;
	ld	-2 (ix), #0x80
	ld	-1 (ix), #0
;videodisp.c:162: for (i = 0; i < 8; i++){
	ld	a, c
	add	a, -7 (ix)
	ld	-5 (ix), a
	ld	a, b
	adc	a, -6 (ix)
	ld	-4 (ix), a
	ld	de, #0x0000
00111$:
;videodisp.c:163: if (base2[line] & mask)
	ld	l, -5 (ix)
	ld	h, -4 (ix)
	ld	a, (hl)
	ld	b, #0x00
	and	a, -2 (ix)
	ld	c, a
	ld	a, b
	and	a, -1 (ix)
	or	a, c
	jr	Z, 00106$
;videodisp.c:164: video_out(0x44);
	push	de
	ld	a, #0x44
	call	_video_out
	pop	de
	jr	00107$
00106$:
;videodisp.c:166: video_out(0);
	push	de
	xor	a, a
	call	_video_out
	pop	de
00107$:
;videodisp.c:167: mask >>= 1;
	sra	-1 (ix)
	rr	-2 (ix)
;videodisp.c:162: for (i = 0; i < 8; i++){
	inc	de
	ld	a, e
	sub	a, #0x08
	ld	a, d
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00111$
;videodisp.c:169: }
	ld	sp, ix
	pop	ix
	ret
;videodisp.c:172: void video_printtime(char h, char m, char s){
;	---------------------------------
; Function video_printtime
; ---------------------------------
_video_printtime::
	push	ix
	ld	ix,#0
	add	ix,sp
	push	af
	ld	-1 (ix), a
	ld	-2 (ix), l
;videodisp.c:176: for (i = 0; i < 16; i+=2){
	ld	bc, #0x0000
00102$:
;videodisp.c:178: video_setpos(i + 110, 48);
	ld	hl, #0x006e
	add	hl, bc
	push	bc
	ld	de, #0x0030
	call	_video_setpos
	pop	bc
;videodisp.c:180: rasterdec(h,i>>1);
	ld	l, c
	ld	h, b
	sra	h
	rr	l
	push	hl
	push	bc
	ex	de,hl
	ld	a, -1 (ix)
	call	_rasterdec
	pop	bc
	pop	hl
;videodisp.c:181: rasterchar(10,i>>1);
	push	hl
	push	bc
	ex	de,hl
	ld	a, #0x0a
	call	_rasterchar
	pop	bc
	pop	hl
;videodisp.c:182: rasterdec(m,i>>1);
	push	hl
	push	bc
	ex	de,hl
	ld	a, -2 (ix)
	call	_rasterdec
	pop	bc
	pop	hl
;videodisp.c:183: rasterchar(10,i>>1);
	push	hl
	push	bc
	ex	de,hl
	ld	a, #0x0a
	call	_rasterchar
	pop	bc
	pop	hl
;videodisp.c:184: rasterdec(s,i>>1);
	push	bc
	ex	de, hl
	ld	a, 4 (ix)
	call	_rasterdec
	pop	bc
;videodisp.c:176: for (i = 0; i < 16; i+=2){
	inc	bc
	inc	bc
	ld	a, c
	sub	a, #0x10
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00102$
;videodisp.c:186: }
	pop	af
	pop	ix
	pop	hl
	inc	sp
	jp	(hl)
;videodisp.c:189: void video_border(){
;	---------------------------------
; Function video_border
; ---------------------------------
_video_border::
;videodisp.c:194: for (row = 1; row < 239; row++){
	ld	hl, #0x0001
00104$:
;videodisp.c:195: video_setpos(row,0); 
	push	hl
	ld	de, #0x0000
	call	_video_setpos
	ld	a, #0x60
	call	_video_out
	pop	hl
;videodisp.c:197: video_setpos(row,159); 
	push	hl
	ld	de, #0x009f
	call	_video_setpos
	ld	a, #0x06
	call	_video_out
	pop	hl
;videodisp.c:194: for (row = 1; row < 239; row++){
	inc	hl
	ld	a, l
	sub	a, #0xef
	ld	a, h
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00104$
;videodisp.c:201: video_setpos(0,0); 
	ld	de, #0x0000
	ld	hl, #0x0000
	call	_video_setpos
;videodisp.c:202: for (col = 0; col < 160; col++)
	ld	bc, #0x0000
00106$:
;videodisp.c:203: video_out(0x66);
	push	bc
	ld	a, #0x66
	call	_video_out
	pop	bc
;videodisp.c:202: for (col = 0; col < 160; col++)
	inc	bc
	ld	a, c
	sub	a, #0xa0
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00106$
;videodisp.c:213: video_setpos(239,0); 
	ld	de, #0x0000
	ld	hl, #0x00ef
	call	_video_setpos
;videodisp.c:214: for (col = 0; col < 160; col++)
	ld	bc, #0x0000
00108$:
;videodisp.c:215: video_out(0x66);
	push	bc
	ld	a, #0x66
	call	_video_out
	pop	bc
;videodisp.c:214: for (col = 0; col < 160; col++)
	inc	bc
	ld	a, c
	sub	a, #0xa0
	ld	a, b
	rla
	ccf
	rra
	sbc	a, #0x80
	jr	C, 00108$
;videodisp.c:216: }
	ret
	.area _CODE
	.area _INITIALIZER
__xinit__base:
	.dw _d0
	.dw _d1
	.dw _d2
	.dw _d3
	.dw _d4
	.dw _d5
	.dw _d6
	.dw _d7
	.dw _d8
	.dw _d9
	.dw _d10
	.area _CABS (ABS)
