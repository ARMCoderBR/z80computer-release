;--------------------------------------------------------------------------
;  crt0.s - Generic crt0.s for a Z80
;
;  Copyright (C) 2000, Michael Hope
;
;  This library is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by the
;  Free Software Foundation; either version 2, or (at your option) any
;  later version.
;
;  This library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License 
;  along with this library; see the file COPYING. If not, write to the
;  Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston,
;   MA 02110-1301, USA.
;
;  As a special exception, if you link this library with other files,
;  some of which are compiled with SDCC, to produce an executable,
;  this library does not by itself cause the resulting executable to
;  be covered by the GNU General Public License. This exception does
;  not however invalidate any other reasons why the executable file
;  might be covered by the GNU General Public License.
;--------------------------------------------------------------------------

;;;-----------------------------------------------------------------------
;;; INTERRUPT HANDLERS & VECTORS
;;; HARDWARE DRIVERS FOR THE TANG NANO HARDWARE:
;;;    VIDEO, SERIAL, TIMER & PS/2 KEYBOARD
;;;    BY ARMCODER - 2025
;;;-----------------------------------------------------------------------

	.include "defines.s"

;RAMBASE		.equ 0x4000
STACKTOP	.equ RAMBASE+0x100	;0x4100
isr0vector	.equ STACKTOP
isr1vector	.equ STACKTOP+2		;0x4102
isr2vector	.equ STACKTOP+4		;0x4104
isr3vector	.equ STACKTOP+6		;0x4106
isr4vector	.equ STACKTOP+8		;0x4108
isr5vector	.equ STACKTOP+10	;0x410a
isr6vector	.equ STACKTOP+12	;0x410c
isr7vector	.equ STACKTOP+14	;0x410e
BUFRXSIZE	.equ 0x80
bufrx		.equ STACKTOP+16	;0x4110
bufrxins	.equ bufrx+BUFRXSIZE	;0x4190
bufrxget	.equ bufrxins+1		;0x4191
bufrxqty	.equ bufrxget+1		;0x4192

VIDROWS		.equ	48
VIDCOLS		.equ	80
vidrow		.equ bufrxqty+1		;0x4193
vidcol		.equ vidrow+1		;0x4194
vidptr		.equ vidcol+1		;0x4195

scrollcnt	.equ vidptr+2		;0x4197
lastlineptr	.equ scrollcnt+1	;0x4198
bufkey		.equ lastlineptr+2	;0x419a
BUFKEYSIZE	.equ	8
bufkeyqty	.equ bufkey+BUFKEYSIZE	;0x41a2
bufkeyins	.equ bufkeyqty+1	;0x41a3
bufkeyget	.equ bufkeyins+1	;0x41a4
kflags		.equ bufkeyget+1	;0x41a5	;00xxxxxx
						;  |||||`-- LShift
						;  ||||`--- RShift
						;  |||`---- Caps
						;  ||`----- Break Code Indicator
						;  |`------ LCTRL  
						;  `------- RCTRL (reserved)   
lastkey		.equ kflags+1		;0x41a6
sysflag		.equ lastkey+1		;0x41a7
dispcol		.equ sysflag+1		;0x41a8

__varend__	.equ lastkey+1

;RAMTOP		.equ RAMBASE+0x200	;0x4200
;timecount	.equ RAMTOP-2		;0x41fe

PORTLEDS	.equ 0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LEDS & BUTTONS
PORTLEDS	.equ	0x00
PORTBUTTONS	.equ	0x00
PORTDISP	.equ	0x10

; FPGA addr mapping (base 0x50)
; 0000: Video RAM Data (R/W)
; 0001: Video ADDR Low (W)
; 0010: Video ADDR High (W)
; 0011: Video control (W)
; 0100: Timer Status & Control(R/W)
; 0101: PS/2 RX Data (R)
; 0110: Sound REG Index (W)
; 0111: Sound REG Data (W)
; 1000: Serial Status & Control (R/W)
; 1001: Serial Data RX/TX (R/W)
; 1010
; 1011
; 1100
; 1101
; 1110
; 1111: Status Reg (R)

; FPGA
;   VIDEO
PORTDATA	.equ	0x50	; Video ports
PORTADDRL	.equ	0x51
PORTADDRH	.equ	0x52
PORTMODE	.equ	0x53

; TIMER STATUS/CONTROL
PORTTIMER	.equ	0x54

;   PS2 KEYBOARD
PORTKEY		.equ	0x55

; AUDIO
PORTAYADDR	.equ	0x56
PORTAYDATA	.equ	0x57

; SERIAL
PORTSERSTATUS	.equ	0x58
PORTSERCTL	.equ	0x58
	PORTSER_EN	.equ	2
	PORTSER_RTSON	.equ	1
	PORTSER_DIS	.equ	0
	PORTSER_RTSOFF	.equ	0

PORTSERDATA	.equ	0x59

;   FPGA STATUS
PORTFPGASTATUS	.equ	0x5F

	.module crt0

	.globl	prints

	.area	_HEADER (ABS)
	;; Reset vector
	.org 	0
	jp	init

	.org	0x08
	jp	mon_putchar

	.org	0x10
	jp	mon_getchar

	.org	0x18
	jp	mon_haskey
	
	.org	0x20
	jp	user_fns
	.org	0x28
	reti
	.org	0x30
	reti

	;///////////////////////////////////////////////////////////////////////
	;//////////////////////////   ISR DISPATCH   ///////////////////////////
	;///////////////////////////////////////////////////////////////////////
	.org	0x38
	jp	fpga_isr

	;;;; END OF HEADER SECTION

	.area	CODE

signon:
	.ascii	'\r\nKraft 80 - Z80 Computer - BIOS v'
	.ascii	'1.0.2'
	.ascii	'\r\n\0'

msgk1:	.ascii	'Kraft 80\0'
msgk2:	.ascii	'BIOS v'
	.ascii	'1.0.2'
	.ascii	'\0'

fpga_isr:
	push	af
	push	hl

fpga_isrloop:
	in	a,(PORTFPGASTATUS)
	and	#0x07
	jr	z,fpga_isrend

	bit	0,a			; Has PS/2 interrupt?
	jr	z,fpga_isr1		; No

	ld	hl,#fpga_isr1
	push	hl
	ld	hl,(isr1vector)
	jp	(hl)

fpga_isr1:
	in	a,(PORTFPGASTATUS)	; Has timer interrupt?
	bit	1,a			; No
	jr	z,fpga_isr2

	in	a,(PORTTIMER)		; Timer EOI
	ld	hl,#fpga_isr2
	push	hl
	ld	hl,(isr2vector)
	jp	(hl)

fpga_isr2:	
	in	a,(PORTFPGASTATUS)	; Has Serial RX interrupt?
	bit	2,a			; No
	jr	z,fpga_isrloop

	ld	hl,#fpga_isrloop
	push	hl
	ld	hl,(isr0vector)
	jp	(hl)

fpga_isrend:	
	pop	hl
	pop	af
	ei
	reti

	;///////////////////////////////////////////////////////////////////////


timer_isr:
	ld	a,(timecount)
	inc	a
	ld	(timecount),a
	;out	(PORTLEDS),a
	ret


ps2_isr:
	ld	a,(bufkeyqty)
	cp	#BUFKEYSIZE
	jr	nz,key_isr1
	in	a,(PORTKEY)
	ret

key_isr1:	
	inc	a
	ld	(bufkeyqty),a

	ld	a,(bufkeyins)
	push	bc
	ld	c,a
	ld	b,#0
	push	hl
	ld	hl,#bufkey
	add	hl,bc
	in	a,(PORTKEY)	; Read key -> PS/2 EOI
	ld	(hl),a
	pop	hl
	ld	a,c
	pop	bc
	inc	a
	cp	#BUFKEYSIZE
	jr	c,key_isr2
	xor	a
key_isr2:	
	ld	(bufkeyins),a
	ret

rx_isr:		
	ld	a,(bufrxqty)
	cp	#BUFRXSIZE
	jr	nz,rx_isr1
	in	a,(PORTSERDATA)
	ret
	
rx_isr1:	
	inc	a
	cp	#(BUFRXSIZE-16)
	jr	nz,rx_isr1a
	
	push	af
	ld	a,#(PORTSER_EN|PORTSER_RTSOFF)
	out	(PORTSERCTL),a
	pop	af

rx_isr1a:	
	ld	(bufrxqty),a
	ld	a,(bufrxins)
	push	bc
	ld	c,a
	ld	b,#0
	push	hl
	ld	hl,#bufrx
	add	hl,bc
	in	a,(PORTSERDATA)
	ld	(hl),a
	pop	hl
	ld	a,c
	pop	bc

	inc	a
	cp	#BUFRXSIZE
	jr	c,rx_isr2
	xor	a

rx_isr2:	
	ld	(bufrxins),a
	ret

	;///////////////////////////////////////////////////////////////////////
mon_putchar:
	push	hl
	ld	hl,#sysflag
	bit	0,(hl)
	pop	hl
	jp	nz,tx_char	; Serial
	jp	putchar		; VGA out

mon_getchar:
	push	hl
	ld	hl,#sysflag
	bit	0,(hl)
	pop	hl
	jp	nz,rx_char	; Serial
	jp	readkey		; PS/2 keyboard
	
mon_haskey:
	push	hl
	ld	hl,#sysflag
	bit	0,(hl)
	pop	hl
	jp	nz,has_rxchar	; Serial
	jp	keypressed	; PS/2 keyboard

	;///////////////////////////////////////////////////////////////////////
	;////////////////////////   INITIALIZATION   ///////////////////////////
	;///////////////////////////////////////////////////////////////////////

init:
	;; Stack at the top of memory.
	ld	sp,#STACKTOP

	ld	hl,#rx_isr
	ld	(isr0vector),hl
	ld	hl,#ps2_isr
	ld	(isr1vector),hl
	ld	hl,#timer_isr
	ld	(isr2vector),hl

	ld	a,#0xf0
	ld	(timecount),a

	xor	a
	ld	(bufrxins),a
	ld	(bufrxget),a
	ld	(bufrxqty),a

	ld	(bufkeyqty),a
	ld	(bufkeyins),a
	ld	(bufkeyget),a
	ld	(kflags),a
	ld	(lastkey),a
	ld	(sysflag),a

	in	a,(PORTBUTTONS)
	bit	7,a
	jr	nz,init1

	ld	a,#1
	ld	(sysflag),a
init1:
	ld	a,#1
	out	(PORTTIMER),a
	ld	a,#(PORTSER_EN|PORTSER_RTSON)
	out	(PORTSERCTL),a	; Enable RTS & INT RX

        ;; Initialise global variables
        call    gsinit

	xor 	a
	out	(PORTMODE),a
	
	ld	hl,#0
wait1:	dec	hl
	ld	a,h
	or	l
	jr	nz,wait1
	
	; Init CRT Video
	ld	a,#0x10		;Reset scroller
	out	(PORTMODE),a
	ld	a,#0x20
	out	(PORTMODE),a
	xor 	a
	out	(PORTADDRL),a
	out	(PORTADDRH),a
	ld	(vidrow),a
	ld	(vidcol),a
	ld	(vidptr),a
	ld	(vidptr+1),a
	ld	(scrollcnt),a
	ld	hl,#((VIDROWS-1)*VIDCOLS)
	ld	(lastlineptr),hl

	ld	hl,#signon
	call	prints

	;in	a,(PORTBUTTONS)
	;bit	6,a
	;jp	nz,0x2000		; ROM Basic

	in	a,(PORTSERDATA)
	in	a,(PORTKEY)
	in	a,(PORTTIMER)

	call	lcd_init

	ld	hl,#msgk1
	call	lcd_wmsg

	call	lcd_home2
	ld	hl,#msgk2
	call	lcd_wmsg

	im	1
	ei

	jp	kraftmon

	;///////////////////////////////////////////////////////////////////////
prints:
	ld	a,(hl)
	or	a
	ret	z
	push	hl
	rst	#0x08
	pop	hl
	inc	hl
	jr	prints

	;///////////////////////////////////////////////////////////////////////
	;/////////////////////////   USER FUNCTIONS   //////////////////////////
	;///////////////////////////////////////////////////////////////////////

user_fns:
	dec	c
	jr	z,tx_char	;c = 1: TX CHAR (input in A)

	dec	c
	jr	z,has_rxchar	;c = 2: HAS RXCHAR (output Z flag)

	dec	c
	jr	z,rx_char	;c = 3: RX CHAR (outputs Z flag & A)

	dec	c		;c = 4
	dec	c		;c = 5
	dec	c		;c = 6
	dec	c		;c = 7

	dec	c		;c = 8
	jp	z,lcd_init

	dec	c		;c = 9
	jp	z,lcd_clear

	dec	c		;c = 10
	jp	z,lcd_home

	dec	c		;c = 11
	jp	z,lcd_home2

	dec	c		;c = 12
	jp	z,lcd_write

	dec	c		;c = 13
	jp	z,lcd_wmsg

	ret

	;///////////////////////////////////////////////////////////////////////
	;////////////////////   SERIAL (UART) FUNCTIONS   //////////////////////
	;///////////////////////////////////////////////////////////////////////

	;///////////////////////////////////////////////////////////////////////
tx_char:
        ;di
	out	(PORTSERDATA),a
wait_tx:
	in	a,(PORTSERSTATUS)
	bit	1,a
	jr	nz,wait_tx
	;ei
	ret

	;///////////////////////////////////////////////////////////////////////
has_rxchar:
	ld	a,(bufrxqty)
	or	a
	ret

	;///////////////////////////////////////////////////////////////////////
rx_char:
	ld	a,(bufrxqty)
	or	a
	jr	nz,rx_char0
	ret		;; No char available, return Z

rx_char0:
	di
	ld	a,(bufrxqty)
	dec	a
	ld	(bufrxqty),a
	cp	#8
	jr	nz,rx_char2

	ld	a,#(PORTSER_EN|PORTSER_RTSON)
	out	(PORTSERCTL),a	; Enable RTS & INT RX

rx_char2:
	push	hl

	push	bc
	ld	a,(bufrxget)
	ld	c,a
	ld	b,#0
	ld	hl,#bufrx
	add	hl,bc
	pop	bc

	inc	a
	cp	#BUFRXSIZE
	jr	nz,rx_char1	;; Condition NZ

	xor	a
	cp	#1		;; Force condition NZ

rx_char1:
	ld	(bufrxget),a
	ld	a,(hl)
	pop	hl
	ei
	ret			;; Always return NZ

	;///////////////////////////////////////////////////////////////////////
	;//////////////////////   CRT (VGA) FUNCTIONS   ////////////////////////
	;///////////////////////////////////////////////////////////////////////

putbs:	ld	a,(vidcol)
	or	a
	ret	z
	dec	a
	ld	(vidcol),a
	ld	hl,(vidptr)
	dec	hl
	jr	putlf2

putchar:
	push	af
	push	hl
	call	_putchar
	pop	hl
	pop	af
	ret

_putchar:
	cp	#13
	jr	z,putcr
	cp	#10
	jr	z,putlf
	cp	#12
	jr	z,putclr
	cp	#8
	jr	z,putbs
	
	out	(PORTDATA),a
	ld	hl,(vidptr)
	inc	hl
	ld	(vidptr),hl

	ld	a,(vidcol)
	cp	#(VIDCOLS-1)
	jr	z,putcnextrow
	inc	a
	ld	(vidcol),a
	ret

putcnextrow:
	xor	a
	ld	(vidcol),a
	ld	a,(vidrow)
	cp	#(VIDROWS-1)
	jr	z,nextrow1
	inc	a
	ld	(vidrow),a
	ret

nextrow1:
	ld	hl,(vidptr)
	push	de
	ld	de,#-VIDCOLS
	add	hl,de
	pop	de
	ld	(vidptr),hl
	jp	scroll_crt

putcr:	ld	a,(vidcol)
	or	a
	ret	z
	push	de
	ld	e,a
	ld	d,#0
	ld	hl,(vidptr)
	xor	a
	ld	(vidcol),a
	sbc	hl,de
	pop	de
	ld	(vidptr),hl
	ld	a,l
	out	(PORTADDRL),a
	ld	a,h
	out	(PORTADDRH),a
	ret
	
putlf:	ld	a,(vidrow)
	cp	#(VIDROWS-1)
	jr	z,putlf1
	
	inc	a
	ld	(vidrow),a
	ld	hl,(vidptr)
	push	de
	ld	de,#VIDCOLS
	add	hl,de
	pop	de

putlf2:	ld	(vidptr),hl
	ld	a,l
	out	(PORTADDRL),a
	ld	a,h
	out	(PORTADDRH),a
	ret
	
putlf1:	jp	scroll_crt

putclr:
	ld	a,#0x10		;Reset scroller
	out	(PORTMODE),a
	ld	a,#0x20
	out	(PORTMODE),a

	xor	a
	ld	(scrollcnt),a
	ld	(vidrow),a
	ld	(vidcol),a
	ld	(vidptr),a
	ld	(vidptr+1),a
	out	(PORTADDRL),a
	out	(PORTADDRH),a
	ld	hl,#((VIDROWS-1)*VIDCOLS)
	ld	(lastlineptr),hl

	ld	hl,#(VIDCOLS*VIDROWS)
putclr1:xor	a
	out	(PORTDATA),a
	dec	hl
	ld	a,h
	or	l
	jr	nz,putclr1
	xor	a
	out	(PORTADDRL),a
	out	(PORTADDRH),a
	ret

	;///////////////////////////////////////////////////////////////////////
scroll_crt:
	push	bc
	push	de
	push	hl

	ld	a,(scrollcnt)
	inc	a
	cp	#VIDROWS
	jr	c,scroll_crt0a

	xor	a

scroll_crt0a:
	ld	(scrollcnt),a
	ld	b,a
	and	#0x0f
	or	#0x10
	out	(PORTMODE),a
	ld	a,b
	srl	a
	srl	a
	srl	a
	srl	a
	or	#0x20
	out	(PORTMODE),a

	ld	hl,(lastlineptr)
	ld	de,#((VIDROWS-1)*VIDCOLS)
	scf
	ccf
	sbc	hl,de
	ld	a,h
	or	l
	jr	z,scroll_crt0b
	ld	hl,(lastlineptr)
	ld	de,#VIDCOLS
	add	hl,de

scroll_crt0b:
	ld	(lastlineptr),hl
	;ld	hl,(lastlineptr)
	ld	a,l
	out	(PORTADDRL),a
	ld	a,h
	out	(PORTADDRH),a
	xor	a
	ld	b,#VIDCOLS
scroll3:
	out	(PORTDATA),a
	djnz	scroll3

	ld	a,(vidcol)
	ld	e,a
	ld	d,#0
	ld	hl,(lastlineptr)
	add	hl,de

	ld	(vidptr),hl
	ld	a,l
	out	(PORTADDRL),a
	ld	a,h
	out	(PORTADDRH),a

	pop	hl
	pop	de
	pop	bc
	ret

	;///////////////////////////////////////////////////////////////////////
	;////////////////////   PS/2 KEYBOARD FUNCTIONS   //////////////////////
	;///////////////////////////////////////////////////////////////////////

keypressed:
	ld	a,(lastkey)
	or	a
	ret	nz
	call	_readkey
	ret	z
	ld	(lastkey),a
	or	a
	ret

readkey:ld	a,(lastkey)
	or	a
	jr	z,readk1
	push	af
	xor	a
	ld	(lastkey),a
	pop	af
	or	a
	ret

readk1:	call	_readkey
	jr	z,readk1
	ret

_readkey:
	di
	ld	a,(bufkeyqty)
	or	a
	jr	nz,keyt1
	ei
	ret

keyt1:
	dec	a
	ld	(bufkeyqty),a

	push	hl
	push	bc
	ld	a,(bufkeyget)
	ld	c,a
	ld	b,#0
	ld	hl,#bufkey
	add	hl,bc
	pop	bc

	inc	a
	cp	#BUFKEYSIZE
	jr	nz,keyt2

	xor	a

keyt2:
	ld	(bufkeyget),a
	ld	a,(hl)			; scan code here
	pop	hl
	ei

	cp	#0xf0
	jr	nz,keyt6

	push	hl
	ld	hl,#kflags
	set	3,(hl)
	pop	hl
	xor	a
	ret

keyt6:
	push	bc
	push	hl
	
	ld	hl,#kflags
	bit	3,(hl)
	jr	z,keyt3a		; No previous BREAK Code
	
	res	3,(hl)			; Clear Break code flag
	
	cp	#0x12			; LShift	
	jr	nz,keyt6a
	res	0,(hl)
	jr	keyt6c

keyt6a:
	cp	#0x59			; RShift	
	jr	nz,keyt6b
	res	1,(hl)
	jr	keyt6c

keyt6b:
	cp	#0x14			; LCTRL	
	jr	nz,keyt6c
	res	4,(hl)

keyt6c:
	xor	a
	jr	keyt4

keyt3a:
	cp	#0x12			; LShift	
	jr	nz,keyt3b
	set	0,(hl)
	jr	keyt4

keyt3b:
	cp	#0x59			; RShift	
	jr	nz,keyt3c
	set	1,(hl)
	jr	keyt4

keyt3c:
	cp	#0x58			; Caps	
	jr	nz,keyt3d
	ld	a,(hl)
	xor	#0x04
	ld	(hl),a
	xor	a
	jr	keyt4

keyt3d:
	cp 	#0x14			; LCTRL
	jr	nz,keyt3e
	set	4,(HL)
	jr	keyt4

keyt3e:
	ld	hl,#tab_xlat
	ld	c,a

keyt3:
	ld	a,(hl)
	or	a
	jr	z,keyt4			; end of table
	cp	c
	jr	z,keyt5			; found
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	jr	keyt3

keyt5:
	inc	hl
	ld	bc,#kflags
	ld	a,(bc)
	ld	c,a
	and	#0x03			; LShift | RShift
	ld	a,c
	jr	z,keyt5a
	inc	hl
	jr	keyt5b

keyt5a:
	ld	a,c
	and	#0x04			; Caps
	jr	z,keyt5b
	inc	hl
	inc	hl

keyt5b:
	bit	4,c			; LCTRL
	ld	a,(hl)
	jr	z,keyt4a

	res	5,a
	cp	#'A'
	jr	c,keyt4b
	cp	#'Z'+1
	jr	nc,keyt4b
	sub	#0x40
	jr	keyt4a

keyt4b:	
	xor	a

keyt4a:
	or	a			; not 0 when there's a valid symbol

keyt4:
	pop	hl
	pop	bc
	ret		

	;///////////////////////////////////////////////////////////////////////

tab_xlat:
	; US QWERTY compatible symbols
	;	SCAN NORM SHIFT CAPS
	.byte	0x1c, 'a', 'A', 'A'
	.byte	0x32, 'b', 'B', 'B'
	.byte	0x21, 'c', 'C', 'C'
	.byte	0x23, 'd', 'D', 'D'
	.byte	0x24, 'e', 'E', 'E'
	.byte	0x2b, 'f', 'F', 'F'
	.byte	0x34, 'g', 'G', 'G'
	.byte	0x33, 'h', 'H', 'H'
	.byte	0x43, 'i', 'I', 'I'
	.byte	0x3b, 'j', 'J', 'J'
	.byte	0x42, 'k', 'K', 'K'
	.byte	0x4b, 'l', 'L', 'L'
	.byte	0x3a, 'm', 'M', 'M'
	.byte	0x31, 'n', 'N', 'N'
	.byte	0x44, 'o', 'O', 'O'
	.byte	0x4D, 'p', 'P', 'P'
	.byte	0x15, 'q', 'Q', 'Q'
	.byte	0x2d, 'r', 'R', 'R'
	.byte	0x1b, 's', 'S', 'S'
	.byte	0x2c, 't', 'T', 'T'
	.byte	0x3c, 'u', 'U', 'U'
	.byte	0x2a, 'v', 'V', 'V'
	.byte	0x1d, 'w', 'W', 'W'
	.byte	0x22, 'x', 'X', 'X'
	.byte	0x35, 'y', 'Y', 'Y'
	.byte	0x1a, 'z', 'Z', 'Z'
	.byte	0x45, '0', ')', '0'
	.byte	0x16, '1', '!', '1'
	.byte	0x1e, '2', '@', '2'
	.byte	0x26, '3', '#', '3'
	.byte	0x25, '4', '$', '4'
	.byte	0x2e, '5', '%', '5'
	.byte	0x3d, '7', '&', '7'
	.byte	0x3e, '8', '*', '8'
	.byte	0x3e, '8', '*', '8'
	.byte	0x46, '9', '(', '9'
	.byte	0x4e, '-', '_', '-'
	.byte	0x55, '=', '+', '='
	.byte	0x66, 0x08,0x08,0x08
	.byte	0x29, ' ', ' ', ' '
	.byte	0x0d, 0x09,0x09,0x09
	.byte	0x5a, 0x0d,0x0d,0x0d
	.byte	0x76, 0x1b,0x1b,0x1b
	.byte	0x0e, 0x27,'"', 0x27
	; Brazilian ABNT2 codes
	;	SCAN NORM SHIFT CAPS
	.byte	0x36, '6', '"', '6'
	.byte	0x61, '\', '|', '\'
	.byte	0x41, ',', '<', ','
	.byte	0x49, '.', '>', '.'
	.byte	0x54, 0x27, '`', 0x27 
	.byte	0x5b, '[', '{', '['
	.byte	0x52, '~', '^', '~'
	.byte	0x5d, ']', '}', ']'
	.byte	0x4a, ';', ':', ';'
	.byte	0x51, '/', '?', '/'
	.byte	0x00

	;///////////////////////////////////////////////////////////////////////
	;//////////////////////   LCD DISPLAY FUNCTIONS   //////////////////////
	;///////////////////////////////////////////////////////////////////////

lcd_write:
	;RS R/W DB7 DB6 DB5 DB4
	;1   0   D7  D6  D5  D4
	push	bc

	push	af
	ld	a,(dispcol)
	cp	#16
	jr	nz,lcd_w1
	call	lcd_home2
	jr	lcd_w2
lcd_w1:
	cp	#32
	jr	nz,lcd_w2
	call	lcd_home
lcd_w2:
	ld	a,(dispcol)
	inc	a
	ld	(dispcol),a
	pop	af
	
	ld	c,a
	and	#0xf0
	or	#0x01
	call	lcd_out

	;RS R/W DB7 DB6 DB5 DB4
	;1   0   D3  D2  D1  D0
	ld	a,c		
	sla	a
	sla	a
	sla	a
	sla	a
	or	#0x01
	call	lcd_out

	call	delay_5ms

	pop	bc

	ret

;///////////////////////////////////////////////////////////////////////////////
lcd_wmsg:
	ld	a,(hl)
	or	a
	ret	z
	call	lcd_write
	inc	hl
	jr	lcd_wmsg

;///////////////////////////////////////////////////////////////////////////////
lcd_home:
	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   0   0
	ld	a,#0b00000000
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   0   0   1   0
	ld	a,#0b00100000
	call	lcd_out

	call	delay_5ms
	xor a
	ld (dispcol),a
	ret

;///////////////////////////////////////////////////////////////////////////////
lcd_home2:
	;RS R/W DB7 DB6 DB5 DB4
	;0   0   1   1   0   0
	ld	a,#0b11000000
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   0   0   0   0
	ld	a,#0b00000000
	call	lcd_out

	call	delay_5ms
	ld a,#16
	ld (dispcol),a
	ret

;///////////////////////////////////////////////////////////////////////////////
lcd_clear:
	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   0   0
	ld	a,#0b00000000
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   0   0   0   1
	ld	a,#0b00010000
	call	lcd_out

	call	delay_5ms
	xor a
	ld (dispcol),a
	ret

;///////////////////////////////////////////////////////////////////////////////
lcd_init:
	call	delay_15ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   1   1
	ld	a,#0b00110000
	call	lcd_out
	call	delay_5ms
	ld	a,#0b00110000
	call	lcd_out
	call	delay_5ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   1   0
	ld	a,#0b00100000		; Set 4 bit mode
	call	lcd_out

	call	delay_5ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   1   0
	ld	a,#0b00100000		; Will set N F
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   N   F   x   x  N=1 F=1
	ld	a,#0b11000000
	call	lcd_out

	call	delay_5ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   0   0
	ld	a,#0b00000000		; Will turn display on
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   1   1   0   0
	ld	a,#0b11000000
	call	lcd_out

	call	delay_5ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   0   0
	ld	a,#0b00000000		; Will clear display
	call	lcd_out
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   0   0   0   1
	ld	a,#0b00010000
	call	lcd_out

	call	delay_5ms

	;RS R/W DB7 DB6 DB5 DB4
	;0   0   0   0   0   0
	ld	a,#0b00000000		; Will set Increment mode
	call	lcd_out		; No shift
	;RS R/W DB3 DB2 DB1 DB0
	;0   0   0   1   1   0
	ld	a,#0b01100000
	call	lcd_out

	call	delay_5ms

	call	lcd_home
	ret

;///////////////////////////////////////////////////////////////////////////////
lcd_out:
	out	(PORTDISP),a
	nop
	nop
	set	1,a
	out	(PORTDISP),a
	nop
	nop
	res	1,a
	out	(PORTDISP),a
	ret

;///////////////////////////////////////////////////////////////////////////////
delay_5ms:
	ld	bc,#768		; 2.5us
delay_5ms_a:	
	dec	bc		; 1.5 us
	ld	a,b		; 1 us
	or	c		; 1 us
	jr	nz,delay_5ms_a	; 3 us
	ret			; 2.5 us

;///////////////////////////////////////////////////////////////////////////////
delay_15ms:	
	ld	bc,#2307	; 2.5us
delay_15ms_a:	
	dec	bc		; 1.5 us
	ld	a,b		; 1 us
	or	c		; 1 us
	jr	nz,delay_15ms_a	; 3 us
	ret			; 2.5 us

	;///////////////////////////////////////////////////////////////////////
	;///////////////////////////// END OF CODE  ////////////////////////////
	;///////////////////////////////////////////////////////////////////////

gsinit:
	ld	bc, #l__INITIALIZER
	ld	a, b
	or	a, c
	jr	Z, gsinit_next
	ld	de, #s__INITIALIZED
	ld	hl, #s__INITIALIZER
	ldir
gsinit_next:
        ret

	;; Ordering of segments for the linker.
	.area	_HOME
	.area	_CODE
	.area	_INITIALIZER
	.area   _GSINIT
	.area   _GSFINAL
        .area   _MAIN
	.area	_DATA
	.area	_INITIALIZED
	.area	_BSEG
	.area   _BSS
	.area   _HEAP

	;.area   _CODE

	;.area   _GSFINAL

