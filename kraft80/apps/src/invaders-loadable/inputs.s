;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  Rev 1.0
;  14-Oct-2025 - ARMCoder
;  Inputs module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.area	CODE

		.globl	init_inputs, update_inputs
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

init_inputs:
		xor	a
		ld	(kbd_state),a
		ld	(portbuttons_kbd),a
		di
		ld	hl,(isr1vector)
		ld	(isr1vector_copy),hl
		ld	hl,#ps2_isr
		ld	(isr1vector),hl
		ei
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

update_inputs:
		; return inputs in ACC as:
		; 76543210
		; R0L0000F
		; | |    +--FIRE  (1:pressed  0:not pressed)
		; | +-------LEFT  (1:pressed  0:not pressed)
		; +---------RIGHT (1:pressed  0:not pressed)

		in	a,(PORTBUTTONS)
		cpl
		ld	c,a
		ld	a,(portbuttons_kbd)
		or	c
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

ps2_isr:
		; SPACE: 0x29      / 0xF0-0x29
		; LEFT:  0xE0-0x6B / 0xE0-0xF0-0x6B 
		; RIGHT: 0xE0-0x74 / 0xE0-0xF0-0x74 

		push	bc
		in	a,(PORTKEY)
		ld	c,a
		;call	sysm_printh8
		
		ld	a,(kbd_state)
		or	a
		jr	z,ps2_state0
		cp	#1
		jr	z,ps2_state1
		cp	#2
		jr	z,ps2_state2
		cp	#3
		jr	z,ps2_state3
		jr	ps2_st2_c
		
ps2_state0:	; STATE 0
		ld	a,c
		cp	#0x29		; Space, make
		jr	nz,ps2_st0_a
		
		ld	a,(portbuttons_kbd)
		set	0,a
		ld	(portbuttons_kbd),a
		jr	ps2_end

ps2_st0_a:	cp	#0xf0		; Break code
		jr	nz,ps2_st0_b
		ld	a,#1
		ld	(kbd_state),a
		jr	ps2_end

ps2_st0_b:	cp	#0xe0		; Arrows prefix
		jr	nz,ps2_end
		ld	a,#2
		ld	(kbd_state),a
		jr	ps2_end

ps2_state1:	; STATE 1
		ld	a,c
		cp	#0x29		; Space, break
		jr	nz,ps2_st2_c
		ld	a,(portbuttons_kbd)
		res	0,a
		ld	(portbuttons_kbd),a
		jr	ps2_st2_c

ps2_state2:	; STATE 2
		ld	a,c
		cp	#0xf0		; Break code after E0
		jr	nz,ps2_st2_a
		ld	a,#3
		ld	(kbd_state),a
		jr	ps2_end
		
ps2_st2_a:	cp	#0x6b		; Left, make
		jr	nz,ps2_st2_b
		ld	a,(portbuttons_kbd)
		set	5,a
		res	7,a
		ld	(portbuttons_kbd),a
		jr	ps2_st2_c

ps2_st2_b:	cp	#0x74		; Right, make
		jr	nz,ps2_st2_c
		ld	a,(portbuttons_kbd)
		set	7,a
		res	5,a
		ld	(portbuttons_kbd),a

ps2_st2_c:	xor	a
		ld	(kbd_state),a
ps2_end:	pop	bc
		ret

ps2_state3:	; STATE 3
		ld	a,c
		cp	#0x6b		; Left, break
		jr	nz,ps2_st3_a
		ld	a,(portbuttons_kbd)
		res	5,a
		ld	(portbuttons_kbd),a
		jr	ps2_st2_c

ps2_st3_a:	cp	#0x74		; Right, break
		jr	nz,ps2_st2_c
		ld	a,(portbuttons_kbd)
		res	7,a
		ld	(portbuttons_kbd),a
		jr	ps2_st2_c

		.area _DATA

isr1vector_copy:.ds	2	; PS2 keyboard
portbuttons_kbd: .ds	1
kbd_state:	.ds	1

