;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  INVADERS FOR KRAFT 80
;  A mini game inspired on Taito's Space Invaders
;  Rev 1.0
;  14-Oct-2025 - ARMCoder
;  Timer module
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		.include "defines.h"

		.globl	init_timer
		
		.area	CODE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

init_timer:
		di
		ld	(timer_srvector),hl
		ld	hl,(isr2vector)
		ld	(isr2vector_copy),hl
		ld	hl,#timer_isr
		ld	(isr2vector),hl
		ei
		ret
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

timer_isr:	ld	hl,#timer_isr2
		push	hl
		ld	hl,(timer_srvector)
		jp	(hl)

timer_isr2:
		ld	hl,(isr2vector_copy)
		jp	(hl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		.area _DATA

timer_srvector:	.ds	2	; User service
isr2vector_copy:.ds	2	; Timer

