;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  Rev 1.0
;  12-Feb-2026 - ARMCoder
;  Sound module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.globl	init_sound
		.globl	end_sound
		.globl	sound_run
		.globl	sound_missile
		.globl	sound_move
		.globl	sound_inv_die
		.globl	sound_ply_die
		.globl	sound_ufo_on, sound_ufo_off

		.area	CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

init_sound:	xor	a
		ld	(sound_presc),a
		ld	(sound_state),a
		ld	(soundtmr1),a
		ld	(soundtmr2),a
		ld	(soundtmr3),a
		jr	end_sound

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end_sound:	ld	a,#7			;Disable all
		out	(PORTAYADDR),a
		ld	a,#0b00111111
		out	(PORTAYDATA),a
		ld	(r7copy),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_run:	ld	a,(sound_presc)		;Divides by 10 (9+1) -> 30 Hz
		or	a
		jr	z,sound_run1
		dec	a
		ld	(sound_presc),a
		ret

sound_run1:	ld	a,#9
		ld	(sound_presc),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ld	a,(sound_state)
		bit	0,a			;Missile fired
		jr	z,sound_run2

		xor	a			;Chan A Tone Period
		out	(PORTAYADDR),a
		ld	a,#50
		out	(PORTAYDATA),a
		ld	a,#1
		out	(PORTAYADDR),a
		xor	a
		out	(PORTAYDATA),a

		ld	a,#6			;Noise Period
		out	(PORTAYADDR),a
		ld	a,#2
		out	(PORTAYDATA),a

		ld	a,#7			;Enable Channel A (Tone+Noise)
		out	(PORTAYADDR),a
		;ld	a,#0b00110110
		ld	a,(r7copy)
		and	#0b11110110
		out	(PORTAYDATA),a
		ld	(r7copy),a

		ld	a,#11			;Envelope Period
		out	(PORTAYADDR),a
		ld	a,#1
		out	(PORTAYDATA),a
		ld	a,#12
		out	(PORTAYADDR),a
		ld	a,#1
		out	(PORTAYDATA),a

		ld	a,#8			;Chan A Amp
		out	(PORTAYADDR),a
		ld	a,#0b00010000
		out	(PORTAYDATA),a

		ld	a,#13			;Envelope Shape
		out	(PORTAYADDR),a
		xor	a
		out	(PORTAYDATA),a

		ld	a,(sound_state)
		res	0,a
		ld	(sound_state),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_run2:	bit	1,a			;Invaders moving
		jr	z,sound_run3

		xor	#0x04
		ld	(sound_state),a
		bit	2,a
		jr	z,sound_run2a

		ld	a,#2			;Chan B Tone Period 1
		out	(PORTAYADDR),a
		ld	a,#0x40
		out	(PORTAYDATA),a
		ld	a,#0x03
		out	(PORTAYADDR),a
		ld	a,#0x06
		out	(PORTAYDATA),a
		jr	sound_run2b

sound_run2a:	ld	a,#2			;Chan B Tone Period 2
		out	(PORTAYADDR),a
		ld	a,#0xd0
		out	(PORTAYDATA),a
		ld	a,#0x03
		out	(PORTAYADDR),a
		ld	a,#0x07
		out	(PORTAYDATA),a

sound_run2b:	ld	a,#9			;Chan B Amp
		out	(PORTAYADDR),a
		ld	a,#0b00001111
		out	(PORTAYDATA),a

		ld	a,#7			;Enable Channel B
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		and	#0b11111101
		out	(PORTAYDATA),a
		ld	(r7copy),a

		ld	a,#3
		ld	(soundtmr1),a

		ld	a,(sound_state)
		res	1,a
		ld	(sound_state),a

sound_run3:	ld	a,(soundtmr1)
		or	a
		jr	z,sound_run4

		dec	a
		ld	(soundtmr1),a
		or	a
		jr	nz,sound_run4

		ld	a,#7			;Disable Channel B
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		or	#0b00000010
		out	(PORTAYDATA),a
		ld	(r7copy),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_run4:	ld	a,(sound_state)		;Invader killed
		bit	3,a
		jr	z,sound_run5

		ld	hl,#40
		ld	(soundtonec),hl
		
		ld	a,#4			;Chan C Tone Period
		out	(PORTAYADDR),a
		ld	a,l
		out	(PORTAYDATA),a
		ld	a,#5
		out	(PORTAYADDR),a
		ld	a,h
		out	(PORTAYDATA),a

		ld	a,#10			;Chan C Amp
		out	(PORTAYADDR),a
		ld	a,#0b00001111
		out	(PORTAYDATA),a

		ld	a,#7			;Enable Channel C
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		and	#0b11111011
		out	(PORTAYDATA),a
		ld	(r7copy),a

		ld	a,#8
		ld	(soundtmr2),a

		ld	a,(sound_state)
		res	3,a
		ld	(sound_state),a
		jr	sound_run7

sound_run5:	ld	a,(soundtmr2)
		or	a
		jr	z,sound_run7

		dec	a
		ld	(soundtmr2),a
		or	a
		jr	nz,sound_run6

		ld	a,#7			;Disable Channel C
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		or	#0b00000100
		out	(PORTAYDATA),a
		ld	(r7copy),a
		jr	sound_run7

sound_run6:	ld	hl,(soundtonec)
		ld	a,#40
		add	a,l
		ld	l,a
		jr	nc,sound_run6a
		inc	h

sound_run6a:	ld	(soundtonec),hl
		ld	a,#4			;Chan C Tone Period
		out	(PORTAYADDR),a
		ld	a,l
		out	(PORTAYDATA),a
		ld	a,#5
		out	(PORTAYADDR),a
		ld	a,h
		out	(PORTAYDATA),a

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_run7:	ld	a,(sound_state)		;Player killed
		bit	4,a
		jr	z,sound_run8

		ld	hl,#300
		ld	(soundtonec),hl

		ld	a,#4			;Chan C Tone Period
		out	(PORTAYADDR),a
		ld	a,l
		out	(PORTAYDATA),a
		ld	a,#5
		out	(PORTAYADDR),a
		ld	a,h
		out	(PORTAYDATA),a

		ld	a,#6			;Noise Period
		out	(PORTAYADDR),a
		ld	a,#31
		out	(PORTAYDATA),a

		ld	a,#11			;Envelope Period
		out	(PORTAYADDR),a
		ld	a,#1
		out	(PORTAYDATA),a
		ld	a,#12
		out	(PORTAYADDR),a
		ld	a,#2
		out	(PORTAYDATA),a

		ld	a,#10			;Chan C Amp
		out	(PORTAYADDR),a
		ld	a,#0b00010000
		out	(PORTAYDATA),a

		ld	a,#7			;Enable Channel C / Disable A+B
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		and	#0b11011011
		or	#0b00011011
		out	(PORTAYDATA),a
		ld	(r7copy),a

		ld	a,#13			;Envelope Shape
		out	(PORTAYADDR),a
		xor	a
		out	(PORTAYDATA),a

		xor	a
		ld	(soundtmr1),a
		ld	(soundtmr2),a
		ld	a,#32
		ld	(soundtmr3),a

		ld	a,(sound_state)
		res	4,a
		ld	(sound_state),a
		jr	sound_run9

sound_run8:	ld	a,(soundtmr3)
		or	a
		jr	z,sound_run10

		dec	a
		ld	(soundtmr3),a
		or	a
		jr	nz,sound_run9

		ld	a,#7			;Disable Channel C
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		or	#0b00100100
		out	(PORTAYDATA),a
		ld	(r7copy),a
		jr	sound_run10

sound_run9:	ld	hl,(soundtonec)
		ld	a,#40
		add	a,l
		ld	l,a
		jr	nc,sound_run9a
		inc	h

sound_run9a:	ld	(soundtonec),hl
		ld	a,#4			;Chan C Tone Period
		out	(PORTAYADDR),a
		ld	a,l
		out	(PORTAYDATA),a
		ld	a,#5
		out	(PORTAYADDR),a
		ld	a,h
		out	(PORTAYDATA),a

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
sound_run10:	ld	a,(sound_state)		;UFO Flying?
		bit	5,a
		jr	nz,sound_ufo		; Yes

		set	6,a			; No
		ld	(sound_state),a

		xor	a
		ld	(soundtmr4),a

		ld	a,(soundtmr2)		;Check if need to kill Channel C
		ld	l,a
		ld	a,(soundtmr3)
		or	l
		jr	nz,sound_ufo3

		ld	a,#7			;Disable Channel C
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		or	#0b00100100
		out	(PORTAYDATA),a
		ld	(r7copy),a
		jr	sound_ufo3

sound_ufo:	ld	a,(soundtmr2)		;Playing invader dying? 
		or	a
		jr	z,sound_ufo1		;No

		ld	a,(sound_state)		;Yes, set force tone and return
		set	6,a
		ld	(sound_state),a
		jr	sound_ufo3

sound_ufo1:	ld	a,(sound_state)
		bit	6,a
		jr	nz,sound_ufo1a

		ld	a,(soundtmr4)
		and	#0b00100000
		sla	a
		sla	a
		ld	l,a
		ld	a,(sound_state)
		and	#0b10000000		;Retrieve last tone sent
		xor	l
		
		jr	z,sound_ufo3		;Same as last, return

sound_ufo1a:	ld	a,(sound_state)
		res	6,a
		ld	(sound_state),a

		ld	a,(soundtmr4)
		bit	5,a

		ld	a,(sound_state)

		jr	nz,tonelo

		res	7,a			;Mark tone HI
		ld	hl,#110
		jr	sound_ufo2

tonelo:		set	7,a			;Mark tone LO
		ld	hl,#140		

sound_ufo2:	ld	(sound_state),a

		ld	a,#4			;Chan C Tone Period
		out	(PORTAYADDR),a
		ld	a,l
		out	(PORTAYDATA),a
		ld	a,#5
		out	(PORTAYADDR),a
		ld	a,h
		out	(PORTAYDATA),a

		ld	a,#10			;Chan C Amp = 2
		out	(PORTAYADDR),a
		ld	a,#0b00000010
		out	(PORTAYDATA),a

		ld	a,#7			;Enable Channel C
		out	(PORTAYADDR),a
		ld	a,(r7copy)
		and	#0b11111011
		out	(PORTAYDATA),a
		ld	(r7copy),a

sound_ufo3:	ld	a,(soundtmr4)
		inc	a
		ld	(soundtmr4),a

		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_missile:	ld	a,(sound_state)
		set	0,a
		ld	(sound_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_move:	ld	a,(sound_state)
		set	1,a
		ld	(sound_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_inv_die:	push	af
		ld	a,(sound_state)
		set	3,a
		ld	(sound_state),a
		pop	af
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_ply_die:	ld	a,#0x10
		di
		ld	(sound_state),a
		xor	a
		ld	(soundtmr1),a
		ld	(soundtmr2),a
		ld	(soundtmr3),a
		ei
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sound_ufo_on:	ld	a,(sound_state)
		set	5,a
		ld	(sound_state),a
		ret

sound_ufo_off:	ld	a,(sound_state)
		res	5,a
		ld	(sound_state),a
		ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.area _DATA

r7copy:		.ds	1
sound_presc:	.ds	1
sound_state:	.ds	1	;xxxxxxxx
				;|||||||`--> Player Missile Fired (Chan A)
				;||||||`---> Invaders March Tick  (Chan B)
				;|||||`----> Invaders March Tone (hi/lo)
				;||||`-----> Invader Die (Chan C)
				;|||`------> Player Die (Chan C)
				;||`-------> UFO Flying (Chan C)
				;|`--------> Force update UFO tone
				;`---------> Last tone sent (H/L)

soundtonec:	.ds	2
soundtmr1:	.ds	1	; Invader move tick
soundtmr2:	.ds	1	; Invader dying
soundtmr3:	.ds	1	; Player dying
soundtmr4:	.ds	1	; UFO siren tone timer

