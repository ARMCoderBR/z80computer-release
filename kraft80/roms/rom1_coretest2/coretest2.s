; =============================================================================
;
;   KRAFT 80 Z80 Computer
;   Core Test 1 Program for the Kraft 80 computer
;   2025-Jul-09
;   Milton Maldonado Jr. (ARMCoder)
;
;   LCD Controller functions (lcd_begin >> end):
;     Author: Dr. Eng. Wagner Rambo
;     Date:   2025, January       
;
; =============================================================================


; =============================================================================
; --- Hardware Mapping ---
PORTBUTTONS     .equ 0x00 ;PORTX address (Read) 
PORTLEDS        .equ 0x00 ;PORTA address (Write)
PORTDISP        .equ 0x10 ;PORTB address (Write)


ROMBASE         .equ 0
ROMSZ           .equ 0x2000
RAMBASE         .equ 0x2000
RAMSZ           .equ 0x6000

RAMHBASE	.equ 0x8000
RAMHSZ		.equ 0x8000

STACKTOP .equ	(RAMBASE+RAMSZ)

; =============================================================================
; --- Reset Vector ---

	.area	_HEADER (ABS)

	.org	0x0000			;origem no endereço 00h de memória

; =============================================================================
; --- Main Program ---

	ld	sp,#STACKTOP
	call	lcd_init

	call	msg_init
	ld	b,#66
wait1s:	push	bc
	call	delay_15ms
	pop	bc
	djnz	wait1s

	call	lcd_clear

	call	test_rams

	ld	hl,#0xc000
	ld	d,#1

loop:	inc	hl
	ld	a,h
	or	l
	jr	nz,loop

	ld	hl,#0xc000

	in	a,(PORTBUTTONS)
	cpl
	ld	c,a
	ld	a,d
	or	c

	out	(PORTLEDS),a

	rrc	d
	jr	loop

; =============================================================================
test_rams:

	ld	hl,#RAMBASE
	ld	b,#(RAMSZ-0x100) / 0x100  ;Protects the top to not trample the stack
	ld	de,#0x100
	ld	a,#1
testra1:
	ld	(hl),a
	inc	a
	add	hl,de
	djnz	testra1
	
	ld	hl,#RAMHBASE
	ld	b,#RAMHSZ / 0x100
	ld	a,#3
testra2:
	ld	(hl),a
	inc	a
	add	hl,de
	djnz	testra2

	ld	ix,#0

	ld	hl,#RAMBASE
	ld	b,#(RAMSZ-0x100) / 0x100  ;Protects the top to not trample the stack
	ld	de,#0x100
	ld	c,#1
testra3:
	ld	a,(hl)
	cp	c
	jr	nz,ramloerr
	inc	c
	add	hl,de
	djnz	testra3
	jr	testra4ini

ramloerr:
	inc	ix
	
testra4ini:
	ld	hl,#RAMHBASE
	ld	b,#RAMHSZ / 0x100
	ld	c,#3
testra4:
	ld	a,(hl)
	cp	c
	jr	nz,ramhierr
	inc	c
	add	hl,de
	djnz	testra4
	jr	testra5
	
ramhierr:
	inc	ix
	inc	ix

testra5:
	ld	a,#'R'
	call 	lcd_write 
	ld	a,#'A'
	call 	lcd_write 
	ld	a,#'M'
	call 	lcd_write 
	ld	a,#'0'
	call 	lcd_write 
	ld	a,#':'
	call 	lcd_write 

	push	ix
	pop	hl
	bit	0,l
	jr	nz,err_raml

	ld	a,#'O'
	call 	lcd_write 
	ld	a,#'K'
	call 	lcd_write 
	jr	ramh

err_raml:
	ld	a,#'E'
	call 	lcd_write 
	ld	a,#'R'
	call 	lcd_write 

ramh:
	ld	a,#' '
	call 	lcd_write 
	ld	a,#' '
	call 	lcd_write 
	ld	a,#'R'
	call 	lcd_write 
	ld	a,#'A'
	call 	lcd_write 
	ld	a,#'M'
	call 	lcd_write 
	ld	a,#'1'
	call 	lcd_write 
	ld	a,#':'
	call 	lcd_write 

	push	ix
	pop	hl
	bit	1,l
	jr	nz,err_ramh

	ld	a,#'O'
	call 	lcd_write 
	ld	a,#'K'
	call 	lcd_write 
	ret

err_ramh:
	ld	a,#'E'
	call 	lcd_write 
	ld	a,#'R'
	jp 	lcd_write 

	ret

msg_init:
	ld	hl,#msgtitle
	jp	lcd_wmsg

msgtitle:
	.ascii	"Coretest2\0"

	;///////////////////////////////////////////////////////////////////////
	;//////////////////////   LCD DISPLAY FUNCTIONS   //////////////////////
	;///////////////////////////////////////////////////////////////////////

lcd_write:
	;RS R/W DB7 DB6 DB5 DB4
	;1   0   D7  D6  D5  D4
	push	bc

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

;=======================================================
; --- Final do Programa ---
	.area _DATA

