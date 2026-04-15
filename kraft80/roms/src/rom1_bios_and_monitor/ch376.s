		.module		CH376
		.include	"ch376.h"
		
		.area	_CODE

		.globl	ch376_init
		.globl	ch376_run
		.globl	ch376_init_system
		.globl	ch376_timer_cb
		.globl	_ch376_read_sector
		.globl	_ch376_secnum, _ch376_nextread, _ch376_result

		;///////////////////////////////////////////////////////////////////////

ch376_run:	ld	a,(run_state)
		cp	#99
		jp	z,abortstate
		ld	c,a
		ld	b,#0
		ld	hl,#tabstates
		add	hl,bc
		add	hl,bc
		ld	c,(hl)
		inc	hl
		ld	b,(hl)
		ld	h,b
		ld	l,c
		jp	(hl)

	;	ret

		;///////////////////////////////////////////////////////////////////////

tabstates:	.word	state_null		;State 0
		.word	state_reset_hw
		.word	state_init_ch376
		.word	state_set_usb_h0	;State 3
		.word	state_wait_intr_connect
		.word	state_set_usb_h1
		.word	state_set_usb_h2
		.word	state_mount
		.word	state_wait_mount
		.word	state_mount_end		;State 9
		.word	state_read_sector1	;State 10
		.word	state_read_sector2	;State 11
		.word	state_read_sector3

		.word	abortstate		;State 99

ST_SET_USBH0	.equ	3
ST_MOUNTEND	.equ	9
ST_READ_SEC	.equ	10
ST_WT_NEXTSEC	.equ	11

		;///////////////////////////////////////////////////////////////////////

shortdelay:	ld	a,#64
shrt1:		dec	a
		jr	nz,shrt1
		ret

		;///////////////////////////////////////////////////////////////////////

longdelay:	ld	hl,#0x8000
longd1:		dec	hl
		ld	a,h
		or	l
		jr	nz,longd1
		ret

		;///////////////////////////////////////////////////////////////////////

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_wait_delay:
		ld	a,(timer10hz)
		or	a
		ret	nz
		jp	nextstate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_reset_hw:	call	ch376_reset
		jr	nextstate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_init_ch376:
		xor	a
		ld	(mountok),a
		ld	hl,#_ch376_secnum
		ld	b,#4
inich376_1:	ld	(hl),a
		inc	hl
		djnz	inich376_1
		call	ch376_init
		ld	a,(ch376_found)
		or	a
		jr	nz,nextstate
		jp	abortstate
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_set_usb_h0:
		call	ch376_iniusbh0
		ld	a,(cmd_res)
		cp	#ANSW_RET_SUCCESS
		jr	z,nextstate
		call	longdelay
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_wait_intr_connect:
		call	check_int_message
		cp	#ANSW_USB_INT_CONNECT
		jr	z,nextstate
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_set_usb_h1:
		call	ch376_iniusbh1
		ld	a,(cmd_res)
		cp	#ANSW_RET_SUCCESS
		jr	z,nextstate
		call	longdelay
		ret

nextstate:	ld	a,(run_state)
		inc	a
		ld	(run_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_set_usb_h2:
		ld	a,#5
		ld	(timer10hz),a
		call	ch376_iniusbh2
		ld	a,(cmd_res)
		cp	#ANSW_RET_SUCCESS
		jr	z,nextstate
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_mount:
		call	longdelay
		call	longdelay

		call	ch376_mount
		ld	a,#50
		ld	(timer10hz),a
		jr	nextstate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_wait_mount:
		call	check_int_message
		cp	#ANSW_USB_INT_SUCCESS
		jr	z,got_mount_ok

		cp	#ANSW_ERR_DISK_DISCON
		jr	nz,wmount1

		ld	hl,#msgunmounted
		call	prints

		ld	a,#ST_SET_USBH0
		ld	(run_state),a
		ret

wmount1:	or	a
		jp	nz,abortstate
		ld	a,(timer10hz)
		or	a
		jr	nz,state_wait_mount
		jr	state_mount_end

got_mount_ok:	ld	a,#1
		ld	(mountok),a

		ld	hl,#mountdata
		call	ch376_rdata0
	;	call	data0_dump
		ld	hl,#msgmounted
		call	prints

		call	_startfatfs

		jp	nextstate

msgmounted:	.ascii	"READY\r\n\0"
msgunmounted:	.ascii	"NOT READY\r\n\0"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_mount_end:
		call	check_int_message
		cp	#ANSW_USB_INT_DISCONNECT
		ret	nz

resusb:		ld	hl,#msgunmounted
		call	prints

		ld	a,#ST_SET_USBH0
		ld	(run_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_read_sector1:
	;	ld	hl,#secbuf
	;	ld	(lastreadptr),hl
		call	ch376_rd_sector
		jp	nextstate

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_read_sector2:
		call	check_int_message
		cp	#ANSW_USB_INT_DISCONNECT
		jr	z,resusb
		cp	#ANSW_USB_INT_DISK_READ
		jp	z,nextstate
		cp	#ANSW_USB_INT_SUCCESS
		jr	z,stsec2a

		or	a	;Still waiting
		ret	z

	;	ld	hl,#msgunkerr
	;	call	prints
		ret

stsec2a:;	ld	hl,#msgendread
	;	call	prints
		ld	a,#ST_MOUNTEND
		ld	(run_state),a
		ret

;msgendread:	.ascii	"All read\r\n\0"
;msgunkerr:	.ascii	"Err ???\r\n\0"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

state_read_sector3:

		ld	hl,(lastreadptr)
		call	ch376_rdata0
	;	call	data0_dump
		call	ch376_rd_secgo

		ld	hl,(lastreadptr)
		ld	a,#64
		add	a,l
		ld	l,a
		jr	nc,rdsec3_1
		inc	h

rdsec3_1:	ld	(lastreadptr),hl
		ld	a,#ST_WT_NEXTSEC
		ld	(run_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

abortstate:	;ld	hl,#s_endstate
		;call	prints
		xor	a
		ld	(run_state),a
		ld	(mountok),a
state_null:	ret

;s_endstate:	.ascii	"\r\n[END]\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_init_system:
		;call	init_timer
		call	cs_off
		call	delay
		xor	a
		ld	(presc),a
		ld	(timer10hz),a
		inc	a
		ld	(run_state),a
		ret

		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////

ch376_reset:
	;	ld	hl,#msgreset
	;	call	prints

		ld	a,#4
		out	(PORTSPICTL),a	; Set RST=1 on USB ("disk") controller

		ld	hl,#0000
ch376_r1:	dec	hl
		ld	a,h
		or	l
		jr	nz,ch376_r1

		xor	a
		out	(PORTSPICTL),a	; Set RST=0 on USB ("disk") controller

		ld	hl,#0000
ch376_r2:	dec	hl
		ld	a,h
		or	l
		jr	nz,ch376_r2

		ld	hl,#0000
ch376_r3:	dec	hl
		ld	a,h
		or	l
		jr	nz,ch376_r3

		ret

;msgreset:	.ascii	"Reset CH376\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_init:
	;	ld	hl,#msginit
	;	call	prints

		call	cs_on
		ld	a,#CMD_GET_IC_VER
		call	spiwrite
		call	spiread
		call	cs_off
	;	call	out_read

		call	cs_on
		ld	a,#CMD_CHECK_EXIST
		call	spiwrite
		ld	a,#0x41
		call	spiwrite
		call	spiread
		call	cs_off
		push	af
	;	call	out_read
	;	call	sysm_crlf
		pop	af
		cp	#0xbe
		jr	z,ch376iniok
		xor	a

		ld	(ch376_found),a
	;	ld	hl,#msg_inerr
	;	jp	prints
		ret

ch376iniok:	ld	a,#1
		ld	(ch376_found),a

	;	ld	hl,#msg_inok
	;	call	prints

		call	cs_on
		ld	a,#CMD_SET_SD0_INT
		call	spiwrite
		ld	a,#0x16
		call	spiwrite
		ld	a,#0x90
		call	spiwrite
		call	cs_off

		ret

;msginit:	.ascii	"Init CH376\r\n\0"
;msg_inok:	.ascii	"CH376 Init OK\r\n\0"
;msg_inerr:	.ascii	"CH376 Init Error\r\n\0"

		;///////////////////////////////////////////////////////////////////////

setusbmode:	push	af

		call	cs_on
		ld	a,#CMD_SET_USB_MODE
		call	spiwrite
		pop	af
		call	spiwrite
		call	delay
		call	delay
		call	delay
		call	delay
		call	spiread
		jp	cs_off

		;///////////////////////////////////////////////////////////////////////

ch376_iniusbh0:
	;	ld	hl,#msginiusb5
	;	call	prints
		ld	a,#MODE_HOST_0
		call	setusbmode
	;	call	out_read
		ld	(cmd_res),a
	;	jp	sysm_crlf
		ret

;msginiusb5:	.ascii	"Set USB HOST0 (Mode 5)\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_iniusbh1:
	;	ld	hl,#msginiusb7
	;	call	prints
		ld	a,#MODE_HOST_1
		call	setusbmode
	;	call	out_read
		ld	(cmd_res),a
	;	jp	sysm_crlf
		ret

;msginiusb7:	.ascii	"Set USB HOST1 (Mode 7)\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_iniusbh2:
	;	ld	hl,#msginiusb6
	;	call	prints
		ld	a,#MODE_HOST_2
		call	setusbmode
	;	call	out_read
		ld	(cmd_res),a
	;	jp	sysm_crlf
		ret

;msginiusb6:	.ascii	"Set USB HOST2 (Mode 6)\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_mount:
	;	ld	hl,#msgmount
	;	call	prints
		call	cs_on
		ld	a,#CMD_DISK_MOUNT
		call	spiwrite
		jp	cs_off

;msgmount:	.ascii	"Mount DISK\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_rdata0:	;push	hl
		;ld	hl,#msgreaddata0
		;call	prints
		;pop	hl

		ld	(lastreadptr),hl
		call	cs_on
		ld	a,#CMD_RD_USB_DATA0
		call	spiwrite
		call	shortdelay
		call	spiread
		ld	(lastread),a
		ld	b,a	; # of bytes to read
rddata01:	call	spiread
		ld	(hl),a
		inc	hl
		djnz	rddata01
		jp	cs_off

;msgreaddata0:	.ascii	"CH376 Read DATA0\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_rd_sector:
	;	ld	hl,#msgrdsector
	;	call	prints
		call	cs_on
		ld	a,#CMD_DISK_READ
		call	spiwrite
		call	shortdelay
		ld	hl,#_ch376_secnum
		ld	b,#4
rdsec1:		ld	a,(hl)
		call	spiwrite
		inc	hl
		djnz	rdsec1
		ld	a,#1		; 1 sector
		call	spiwrite
		call	shortdelay
		call	cs_off
		ret

;msgrdsector:	.ascii	"READ Sector\r\n\0"

		;///////////////////////////////////////////////////////////////////////

ch376_rd_secgo:	;ld	hl,#msgrdsectorgo
		;call	prints
		call	cs_on
		ld	a,#CMD_DISK_RD_GO
		call	spiwrite
		jp	cs_off

;msgrdsectorgo:	.ascii	"READ Sector GO!\r\n\0"

		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////

check_int_message:
		in	a,(PORTSPICTL)
		bit	1,a
		jr	nz,check_int1

		call	get_interrupt
	;	push	af
	;	call	out_read
	;	call	sysm_crlf
	;	pop	af
		ret

check_int1:	xor	a
		ret

		;///////////////////////////////////////////////////////////////////////

get_interrupt:	call	cs_on
		ld	a,#CMD_GET_STATUS
		call	spiwrite
		call	spiread
		jp	cs_off

		;///////////////////////////////////////////////////////////////////////

ch376_timer_cb:
		push	af
		ld	a,(presc)	; Prescaler 30 for 10 Hz
		or	a
		jr	z,cb1
		dec	a
		ld	(presc),a
		jr	tcb1
cb1:		ld	a,#30
		ld	(presc),a

		ld	a,(timer10hz)
		or	a
		jr	z,tcb1
		dec	a
		ld	(timer10hz),a
tcb1:		pop	af
		ret

		;///////////////////////////////////////////////////////////////////////

;data0_dump:	ld	hl,(lastreadptr)
;		ld	a,(lastread)
;		ld	b,a
;		call	sysm_crlf
;data0dmp1:	ld	a,(hl)
;		call	out_read
;		inc	hl
;		djnz	data0dmp1
;		call	sysm_crlf
;		ret

		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////

;ch376_read:	ld	a,(mountok)
;		or	a
;		ret	z
;
;		ld	hl,#secbuf
;		ld	(lastreadptr),hl
;
;		ld	hl,#_ch376_secnum
;		ld	b,#4
;ch376rd_1:	ld	(hl),a
;		inc	hl
;		djnz	ch376rd_1
;
;		ld	a,#ST_READ_SEC
;		ld	(run_state),a
;		ret

		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////

_ch376_read_sector:
		ld	a,(mountok)
		or	a
		jr	nz,_ch376_rs1

		ld	a,#0xfe
		ld	(_ch376_result),a
		ret

_ch376_rs1:	ld	hl,(_ch376_nextread)
		ld	(lastreadptr),hl

		ld	a,#ST_READ_SEC
		ld	(run_state),a

_ch376_rs2:	call	ch376_run

		ld	a,(run_state)
		cp	#ST_MOUNTEND
		jr	z,_ch376_rs3
		jr	_ch376_rs2

_ch376_rs3:	xor	a
		ld	(_ch376_result),a
		ret

		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////
		;///////////////////////////////////////////////////////////////////////

		.area	_DATA

run_state:	.ds	1
ch376_found:	.ds	1
cmd_res:	.ds	1
presc:		.ds	1
timer10hz:	.ds	1
mountok:	.ds	1
lastread:	.ds	1
lastreadptr:	.ds	2
mountdata:	.ds	36

;/////////////////////////////////////////////////////

_ch376_nextread:.ds	2
_ch376_secnum:	.ds	4
_ch376_result:	.ds	1




