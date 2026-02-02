;--------------------------------------------------------------------------
;  kraftmon.s - Simple monior for the Kraft 80
;
;  Copyright (C) 2025, ARMCoder
;
;--------------------------------------------------------------------------

	.include "defines.s"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; LEDS & BUTTONS
PORTLEDS	.equ	0x00
PORTBUTTONS	.equ	0x00
PORTDISP	.equ	0x10

;RAMBASE	.equ	0x4000
SYSM_BUFSZ	.equ	128
SYSM_BUF	.equ	RAMBASE
SYSM_BUFPTR	.equ	SYSM_BUF+SYSM_BUFSZ
SYSM_LASTDM 	.equ	SYSM_BUFPTR+1
SYSM_LASTED 	.equ	SYSM_LASTDM+2
SYSM_FLAGS	.equ	SYSM_LASTED+2

SOH 		.equ	1
EOT		.equ	4
ACK		.equ	6
CR		.equ	13
NAK		.equ	21
ESC		.equ	27

	;///////////////////////////////////////////////////////////////////////
	;/////////////////////////   KRAFTMON MONITOR   ////////////////////////
	;///////////////////////////////////////////////////////////////////////

	.module kraftmon

	.globl kraftmon

	.area	CODE


signon_kraftmon:
	.ascii	'\r\nKraftmon by ARMCoder\r\n\n\0'

kraftmon:
	ld	hl,#signon_kraftmon
	call	prints

	ld	hl,#RAMTOP
	ld	(SYSM_LASTDM),hl
	ld	(SYSM_LASTED),hl

	xor	a
	ld	(SYSM_FLAGS),a
	in	a,(PORTBUTTONS)
	bit	6,a
	jr	nz,kraftmon_loop

	ld	a,#1
	ld	(SYSM_FLAGS),a
	
	ld	c,#9
	rst	0x20
	ld	c,#13
	ld	hl,#msg_ld_xmodem
	rst	0x20
	jp	load_xmodem
	
msg_ld_xmodem:
	.ascii	"Loading XMODEM.\0"

kraftmon_loop:
	xor	a
	ld	(SYSM_BUFPTR),a

	call sysm_prompt

	jr	kraftmon_loop

	;///////////////////////////////////////////////////////////////////////
str_basic:
	.ascii	'basic'
	.byte	0

str_loadx:
	.ascii	'loadx'
	.byte	0

sysm_prompt:
	ld	a,#':'
	rst	0x08
	call	sysm_readline
	call	sysm_crlf

	ld	hl,#SYSM_BUF
	ld	de,#str_basic
	call	strcompare
	jp	z,#0x2000	; Jump to BASIC

	ld	hl,#SYSM_BUF
	ld	de,#str_loadx
	call	strcompare
	jp	z,load_xmodem

	ld	a,(SYSM_BUF)	; Check 'd' command
	cp	#'d'
	jp	z,sysm_dump

	cp	#'e'		; Check 'e' command
	jr	z,sysm_edit

	cp	#'g'		; Check 'g' command
	jr	z,sysm_go

	ret

	;///////////////////////////////////////////////////////////////////////
str_go:	.ascii	'Go!'
	.byte	13,10,0

sysm_go:
	ld	hl,#str_go
	call	prints
	ld	hl,#sysm_goret
	push	hl
	ld	hl,#SYSM_BUF+1
	call	skip_spc
	call	parsehex16
	ld	hl,#RAMTOP
	jr	z,sysm_go2
	ld	h,d
	ld	l,e
sysm_go2:
	jp	(hl)

sysm_goret:
	ld	a,#13
	rst	0x08
	ld	a,#10
	rst	0x08
	ret

	;///////////////////////////////////////////////////////////////////////
sysm_edit:
	ld	hl,#SYSM_BUF+1
	call	skip_spc
	call	parsehex16
	jr	z,sysm_editloop
	ld	h,d
	ld	l,e
	ld	(SYSM_LASTED),hl

sysm_editloop:

	ld	hl,(SYSM_LASTED)
	ld	a,h
	call	sysm_printh8	
	ld	a,l
	call	sysm_printh8	
	ld	a,#':'
	rst	0x08

	ld	c,#0

	push	bc
	call	sysm_readline
	call	sysm_crlf
	pop	bc

	ld	hl,#SYSM_BUF

sysm_editloop2:
	call	skip_spc
	call	parsehex8
	jr	z,sysm_edit2

	push	hl
	ld	hl,(SYSM_LASTED)
	ld	(hl),e
	inc	hl
	ld	(SYSM_LASTED),hl
	pop	hl
	inc	c
	jr	sysm_editloop2

sysm_edit2:
	ld	a,c
	or	a
	jr	nz,sysm_editloop
	ret
	
	;///////////////////////////////////////////////////////////////////////
dumphdr:
	.ascii	'      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F'
	.byte 13,10,0

sysm_dump:
	ld	hl,#SYSM_BUF+1
	call	skip_spc
	call	parsehex16
	jr	z,sysm_dump0
	ld	h,d
	ld	l,e
	ld	(SYSM_LASTDM),hl

sysm_dump0:
	ld	hl,#dumphdr
	call	prints
	ld	b,#8

sysm_dump1:
	ld	hl,(SYSM_LASTDM)
	ld	a,h
	call	sysm_printh8	
	ld	a,l
	call	sysm_printh8	
	ld	a,#':'
	rst	0x08

	ld	c,#16

sysm_dump2:
	ld	a,(hl)
	call	sysm_printh8	
	ld	a,#' '
	rst	0x08
	inc	hl
	dec	c
	jr	nz,sysm_dump2

	call	sysm_crlf

	ld	hl,(SYSM_LASTDM)
	ld	de,#16
	add	hl,de
	ld	(SYSM_LASTDM),hl
	
	djnz	sysm_dump1
	
	ret

	;///////////////////////////////////////////////////////////////////////
skip_spc:
	ld	a,(hl)
	cp	#' '
	ret	nz
	inc	hl
	jr	skip_spc

	;///////////////////////////////////////////////////////////////////////
parsehex8:	; Buffer in HL
		; returns result in E and flag NZ if valid, or flag Z if not valid
	ld	a,(hl)
	call	parsehexdigit
	ret	z
	ld	e,a

	inc	hl
	ld	a,(hl)
	call	parsehexdigit
	jr	z,parsehex8_1
	inc	hl
	sla	e
	sla	e
	sla	e
	sla	e
	or	e
	ld	e,a

parsehex8_1:
	xor	a
	cp	#0xff
	ret

	;///////////////////////////////////////////////////////////////////////
parsehex16:	; Buffer in HL
		; returns result in DE and flag NZ if valid, or flag Z if not valid
	ld	de,#0
	ld	a,(hl)
	call	parsehexdigit
	ret	z
	ld	e,a

	ld	b,#3

parsehex16_2:
	inc	hl
	ld	a,(hl)
	call	parsehexdigit
	jr	z,parsehex16_1
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	sla	e
	rl	d
	or	e
	ld	e,a
	djnz	parsehex16_2

parsehex16_1:
	xor	a
	cp	#0xff
	ret

	;///////////////////////////////////////////////////////////////////////
parsehexdigit:	; Digit in A
		; returns nibble in A and flag NZ if valid, or flag Z if not valid
	cp	#'0'
	jr	c,parsehexdigit1

	cp	#'9'+1
	jr	c,parsehexdigit2

	res	5,a
	cp	#'F'+1
	jr	nc,parsehexdigit1

	cp	#'A'
	jr	nc,parsehexdigit3

parsehexdigit1:
	xor	a
	ret

parsehexdigit2:
	sub	#'0'
	cp	#0xff
	ret

parsehexdigit3:
	sub	#('A' - 10)
	cp	#0xff
	ret

	;///////////////////////////////////////////////////////////////////////
strcompare:	; STR1 in HL, STR2 in DE
		; Returns Z if equal, NZ and C if STR1<STR2, NZ and NC if STR1>STR2
	ld	a,(de)
	ld	c,a
	ld	a,(hl)
	cp	c
	jr	z,strcomp1
	ret	

strcomp1:
	or	a
	ret	z

	inc	hl
	inc	de
	jr	strcompare

	;///////////////////////////////////////////////////////////////////////
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

	;///////////////////////////////////////////////////////////////////////
sysm_crlf:
	ld	a,#0x0d
	rst	0x08
	ld	a,#0x0a
	rst	0x08
	ret

	;///////////////////////////////////////////////////////////////////////
sysm_readline:

	rst	0x18
	jr	z,sysm_readline

	rst	0x10
	cp	#0x0d
	jr	z,sysm_rdl_cr
	cp	#0x08
	jr	z,sysm_rdl_bs

	ld	b,a
	ld	a,(SYSM_BUFPTR)
	cp	#SYSM_BUFSZ
	jr	z,sysm_readline

	ld	c,a
	ld	a,b
	ld	b,#0
	ld	hl,#SYSM_BUF
	add	hl,bc
	ld	(hl),a

	rst	0x08
	inc	c
	ld	a,c
	ld	(SYSM_BUFPTR),a
	jr	sysm_readline

sysm_rdl_cr:
	ld	a,(SYSM_BUFPTR)
	ld	c,a
	ld	b,#0
	ld	hl,#SYSM_BUF
	add	hl,bc
	xor	a
	ld	(hl),a
	ld	(SYSM_BUFPTR),a
	ret

sysm_rdl_bs:

	ld	a,(SYSM_BUFPTR)
	or	a
	jr	z,sysm_readline
	dec	a
	ld	(SYSM_BUFPTR),a

	ld	a,#8
	rst	0x08
	ld	a,#' '
	rst	0x08
	ld	a,#8
	rst	0x08
	jr	sysm_readline

	;///////////////////////////////////////////////////////////////////////
str_load_xmodem:
	.ascii '\r\nSend the binary via XMODEM, [ENTER] to abort\r\n'
	.byte 0

load_xmodem:
	ld	hl,#str_load_xmodem
	call	prints
	ld	d,#1	;lastseq
	ld	hl,#RAMTOP
	ld	(SYSM_LASTED),hl
	ld	bc,#30000

loop_xmodem:
	push	bc
	ld	c,#2	; Test Char
	rst	0x20
	pop	bc
	jr	z,load_xmodem_nochar

	call	serial_getchar

	cp	#EOT
	jr	nz,load_xmodem1

	ld	a,#ACK
	ld	c,#1	; TX Char
	rst	0x20

	ld	a,(SYSM_FLAGS)
	bit	0,a
	ret	z

	ld	c,#9
	rst	0x20
	ld	c,#13
	ld	hl,#msg_run
	rst	0x20
	jp	RAMTOP

msg_run:
	.ascii	"Run...\0"

load_xmodem1:
	cp	#ESC
	ret	z
	cp	#CR
	ret	z

	cp	#SOH
	jr	nz,loop_xmodem

	call	serial_getchar
	cp	d	;lastseq
	jr	nz,loop_xmodem

	call	serial_getchar
	cpl
	cp	d	;~lastseq
	jr	nz,loop_xmodem

	ld	b,#128
	ld	c,#0	;chksum
	ld	hl,(SYSM_LASTED)

loop_xmodem2:
	call	serial_getchar
	ld	e,a
	add	a,c
	ld	c,a
	ld	(hl),e
	inc	hl
	djnz	loop_xmodem2

	ld	(SYSM_LASTED),hl
	call	serial_getchar
	cp	c
	jr	nz,load_xm_ckerr	

	inc	d
	ld	a,#ACK
	ld	c,#1	; TX Char
	rst	0x20
	jr	endloop_xmodem

load_xm_ckerr:
	ld	a,#NAK
	ld	c,#1	; TX Char
	rst	0x20
	jr	endloop_xmodem	

load_xmodem_nochar:
	dec	bc
	ld	a,b
	or	c
	jr	nz,loop_xmodem

	ld	a,#NAK
	ld	c,#1	; TX Char
	rst	0x20

endloop_xmodem:
	ld	bc,#30000
	jr	loop_xmodem

serial_getchar:
	push	bc

serial_getchar1:
	ld	c,#3
	rst	0x20
	jr	z,serial_getchar1

	pop	bc
	ret

	;///////////////////////////////////////////////////////////////////////
	;///////////////////////////   KRAFTMON END   //////////////////////////
	;///////////////////////////////////////////////////////////////////////

