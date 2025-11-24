;//////////////////////////////////////////////////////////////////////////////;
; Project:                                                                     ;
;    PICALC-Z80-KRAFT80                                                        ;
;                                                                              ;
; Description:                                                                 ;
;    A calculator that yields an arbitrary number of digits of the number PI.  ;
;                                                                              ;
; Targets:                                                                     ;
;    1. The modified WR Kits' Z80 Alpha computer (AKA Z80 Alpha Plus by ARM    ;
;       Coder).                                                                ;
;    2. Kraft 80 Computer by ARM Coder (that's a derivative from the project   ;
;       above).                                                                ;
;                                                                              ;
;    Details of memory allocation and stack positioning must be adjusted for   ;
;    the specifics of other targets, if any. In addition, INT 08h is used as a ;
;    function call to print character over TTY (A = character), which          ;
;    implementation has to be adjusted to the target.                          ;
;                                                                              ;
; Compiler:                                                                    ;
;    Tasm + DosBox                                                             ;
;                                                                              ;
;    Other compilers/assemblers may require minor changes in the source code.  ;
;                                                                              ;
; Usage:                                                                       ;
;    The desired amount of PI digits is defined in the macro NUM_DECS. Default ;
;    value is 100. Note that incrementing this value will increase RAM usage   ;
;    proportionally, and the needed CPU cycles quadratically. Don't change the ;
;    other algorithm constants unless you really know what you are doing.      ;
;                                                                              ;
;    The algorithm was validated for 1,000 digits of PI, all of them checked   ;
;    against the generally known published digits. For an actual Z80, yielding ;
;    this number of digits may prove to be a daunting task, especially because ;
;    of the gigantic number of CPU cycles needed (RAM is a lesser problem in   ;
;    this regard). 100 digits is way more practical amount, unless you have A  ;
;    LOT of time to spare.                                                     ;
;                                                                              ;
;    The main loop iteracts as many times as needed to calculate all the       ;
;    decimal places requested (the number of iterations / number of digits have;
;    a ratio close to 0.9). With each iteration the message 'TOTAL:' is printed;
;    along the PI approximation calculated so far.                             ;
;                                                                              ;
; Version & Date:                                                              ;
;    1.0 - 2025-MAY-01                                                         ;
;                                                                              ;
; Author:                                                                      ;
;    Milton Maldonado Jr (ARM_Coder)                                           ;
;                                                                              ;
; License:                                                                     ;
;    GPL V2                                                                    ;
;                                                                              ;
; Disclaimer:                                                                  ;
;    This code is supplied 'as is' with no warranty against bugs. It was tested;
;    on a Z80 simulator that *I* wrote (haha), so it was not tested against any;
;    actual, validated target.                                                 ;
;                                                                              ;
; Note:                                                                        ;
;    Along the ASM source, you will see some commented 'C' statemens. The      ;
;    project was initially built and tested in C, and then hand-translated     ;
;    to Z80 ASM.                                                               ;
;                                                                              ;
; Funny note:                                                                  ;
;    This project implements the Bailey-Borwein-Plouffe method of calculating  ;
;    PI. This method is much, much faster that the classic Leibniz series.     ;
;    The funny thing is that the method was discovered (invented?) in 1995,    ;
;    when the Z80 had already passed its heyday and was fading into a niche,   ;
;	retro platform.                                                           ;
;//////////////////////////////////////////////////////////////////////////////;

; Hardware constants
PORTLEDS	.equ	0x00
PORTBUTTONS	.equ	0x00
PORTDISP	.equ	0x10

ROMBASE         .equ 0
ROMSZ           .equ 0x2000
RAMBASE         .equ 0x4000
RAMSZ           .equ 0xC000

; Algorithm constants
NUM_DECS        .equ 27
NUM_IT          .equ ((NUM_DECS*9)/10)
NBITS_FR        .equ (3*NUM_DECS + (NUM_DECS >> 1))
NBITS_INT       .equ 16
NBITS_FRAC      .equ 8*(1 + (NBITS_FR >> 3)) ; The number of bits should be at least 3.33x (1 / log(2)) the number of decimal places, plus a small cushion.
NBYTES_INT      .equ NBITS_INT >> 3
NBITS           .equ NBITS_INT+NBITS_FRAC
NBYTES          .equ NBITS>>3
NBYTES1         .equ (NBYTES-1)

	.area	_HEADER (ABS)

	.org	ROMBASE	; Expected to be 0x00. Other values will clash with the
			; interrupt handlers below.

	jp	start

	.org	0x0008
	push	bc
	call	lcd_write
	pop	bc
	ret

	.org	0x0038      ; HW Interrupt IM 1.
	reti

	.org	0x0066      ; NMI
	retn

start:
	;ld	hl,RAMBASE+RAMSZ-1
	;xor	a
	;ld	(hl),a
loopled:
	;in	a,(PORTX)
	;cpl
	;or	a
	;jr	z,loopled
	;ld	a,(hl)
	;out	(PORTA),a
	;inc	a
	;ld	(hl),a
	;jr	loopled
	
	ld	sp,#(RAMBASE + RAMSZ)
	call	_main
	halt

;///////////////////////////////////////////////////////////////////////////////
;   print_crlf
;   void print_crlf(void);
;   Parameters: Nothing
;   Returns: Nothing
;   Affects: HL
print_crlf:

	ld	a,#0x0d
	rst	#0x08
	ld	a,#0x0a
	rst	#0x08
	ret

;///////////////////////////////////////////////////////////////////////////////
;   zero_reg
;   void zero_reg(uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Nothing
;   Affects: BC DE HL AF
zero_reg:

	;    memset(reg,0,NBYTES);
	ld	bc,#(NBYTES-1)
	xor	a
	ld	(hl),a
	ld	d,h
	ld	e,l
	inc	de
	ldir
	ret

;///////////////////////////////////////////////////////////////////////////////
;   set_bit_reg
;   void set_bit_reg(uint8_t *reg, int place);
;   Parameters:
;     HL: reg
;     BC: place
;   Returns: Nothing
;   Affects: BC DE HL AF
set_bit_reg:

    ;   int byte = NBYTES1 - (place >> 3);
	push	hl
	ld	hl,#NBYTES1

set_bit_reg0:

	ld	d,b
	ld	e,c
	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	scf
	ccf
	sbc	hl,de
	ex	de,hl    ;DE: byte
	pop	hl

    ;   int bits = place & 0x07;
	ld	a,c
	and	#0x07    ;A: bits

    ;   reg[byte] |= 1<<bits;
	add	hl,de

	ld	b,#1
	or	a
	jr	z,set_bit_reg2

set_bit_reg1:

	sla	b
	dec	a
	jr	nz,set_bit_reg1

set_bit_reg2:

	ld	a,(hl)
	or	b
	ld	(hl),a
	ret

;///////////////////////////////////////////////////////////////////////////////
;   set_bit_reg_int
;   void set_bit_reg_int(uint8_t *reg, int place);
;   Parameters:
;     HL: reg
;     BC: place
;   Returns: Nothing
;   Affects: BC DE HL AF
set_bit_reg_int:

    ;   int byte = NBYTES_INT - 1 - (place >> 3);
	push	hl
	ld	hl,#(NBYTES_INT-1)
	jr	set_bit_reg0

;///////////////////////////////////////////////////////////////////////////////
;   print_reg
;   void print_reg(uint8_t *reg);
;   Não portada

;///////////////////////////////////////////////////////////////////////////////
;   add_reg2_to_reg1
;   void add_reg2_to_reg1(uint8_t *reg1, const uint8_t *reg2);
;   Parameters:
;     HL: reg2
;     DE: reg1
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
add_reg2_to_reg1:

    ;   uint16_t cy = 0;
    ;   int i;
    ;   for (i = NBYTES1; i >= 0; i--){
    ;       uint16_t sum = (uint16_t)reg1[i] + (uint16_t)reg2[i] + cy;
    ;       if (sum & 0x100)
    ;           cy = 1;
    ;       else
    ;           cy = 0;
    ;       reg1[i] = sum & 0xff;
    ;   }

	ld	bc,#NBYTES1
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	exx
	ld	bc,#NBYTES1
	inc	bc
	exx
	sub	a   ;zero Carry Flag

add_reg2_to_reg1_0:

	ld	b,(hl)
	ld	a,(de)
	adc	a,b
	ld	(de),a

	dec	hl
	dec	de

	exx                         ; Save HL & DE, restores counter in BC
	ex	af,af'                   ; Save CY
	dec	bc
	ld	a,b
	or	c
	ret	z                       ; End loop, bye
	ex	af,af'                   ; Restore CY
	exx                         ; Save counter in BC, restores HL & DE
	jr	add_reg2_to_reg1_0

;///////////////////////////////////////////////////////////////////////////////
;   add_reg_to_acc
;   void add_reg_to_acc(const uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
add_reg_to_acc:

	ld	de,#acc
	jr	add_reg2_to_reg1

;///////////////////////////////////////////////////////////////////////////////
;   inc_reg_int8
;   void inc_reg_int8(uint8_t *reg, uint8_t byteval);
;   Parameters:
;     DE: reg
;     A:  byteval
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
inc_reg_int8:

    ;    uint16_t cy = byteval;
    ;    int i;
    ;    for (i = NBYTES_INT - 1; i >= 0; i--){
    ;        uint16_t sum =(uint16_t)reg[i] + cy;
    ;        reg[i] = sum & 0xff;
    ;        if (!(sum & 0x100))
    ;        	return;
    ;        cy = 1;
    ;    }

	ld	bc,#NBYTES_INT
	ex	de,hl
	add	hl,bc
	dec	hl
	ld	e,a

inc_reg_int8_0:

	ld	a,(hl)
	add	a,e
	ld	(hl),a

	ld	e,#0
	jr	nc, inc_reg_int8_1
	inc	e       ; Here E propagates the carry for the sums.

inc_reg_int8_1:

	dec	bc
	ld	a,b
	or	c
	ret	z                       ; End loop, bye

	dec	hl
	jr	inc_reg_int8_0

;///////////////////////////////////////////////////////////////////////////////
;   load_reg_int
;   void load_reg_int(uint8_t *reg, int val);
;   Parameters:
;     DE: reg
;     HL: val
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
load_reg_int:

;    for (int i = NBYTES_INT - 1; i >= 0; i--){
;        reg[i] = val & 0xff;
;        val >>= 8;
;    }
	ex	de,hl
	ld	bc,#NBYTES_INT
	add	hl,bc
	dec	hl
	ld	b,#NBYTES_INT
	ld	a,e
	ld	(hl),a
	dec	hl
	ld	a,d
	ld	(hl),a
	dec	b
	dec	b
	ld	a,b
	or	a
	ret	z
	dec	hl
	xor	a
load_reg_int_0:
	ld	(hl),a
	dec	hl
	djnz	load_reg_int_0
	ret

;///////////////////////////////////////////////////////////////////////////////
;   sub_reg2_from_reg1
;   void sub_reg2_from_reg1(uint8_t *reg1, const uint8_t *reg2);
;   Parameters:
;     DE: reg1
;     HL: reg2
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
sub_reg2_from_reg1:

;    uint16_t cy = 0;
;    int i;
;    for (i = NBYTES1; i >= 0; i--){
;        uint16_t diff = (uint16_t)reg1[i] - (uint16_t)reg2[i] - cy;
;        if (diff & 0x8000)
;            cy = 1;
;        else
;            cy = 0;
;        reg1[i] = diff & 0xff;
;    }

	ld	bc,#NBYTES1
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	exx
	ld	bc,#NBYTES1
	inc	bc
	exx
	sub	a   ;zera CY

sub_reg2_to_reg1_0:

	ld	b,(hl)
	ld	a,(de)
	sbc	a,b
	ld	(de),a

	dec	hl
	dec	de

	exx                         ; Save HL & DE, restores counter in BC
	ex	af,af'                   ; Save CY
	dec	bc
	ld	a,b
	or	c
	ret	z                       ; End loop, bye
	ex	af,af'                   ; Restore CY
	exx                         ; Save counter in BC, restore HL & DE
	jr	sub_reg2_to_reg1_0

;///////////////////////////////////////////////////////////////////////////////
;   sub_reg_from_acc
;   void sub_reg_from_acc(const uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Nothing
;   Affects: BC DE HL AF BC' DE' HL' AF'
sub_reg_from_acc:

	ld	de,#acc
	call	sub_reg2_from_reg1
	ret

;///////////////////////////////////////////////////////////////////////////////
;   shl_reg
;   void shl_reg(uint8_t *reg, int places)
;   Parameters:
;     DE: reg
;     BC: places
;   Returns: Nothing
;   Affects: BC DE HL AF
shl_reg:

	push	ix
	ld	ix,#0xFFF8    ; Allocates 8 bytes
	add	ix,sp
	ld	sp,ix

	ld	0(ix),e     ;IX+0, IX+1 = 'reg'
	ld	1(ix),d

;    if (places > NBITS)
;        places = NBITS;
	ld	a,#(NBITS >> 8)
	sub	b
	jr	c,shl_reg_0
	jr	nz,shl_reg_1

	ld	a,#(NBITS & 255)
	sub	c
	jr	nc, shl_reg_1

shl_reg_0:

	ld	bc,#NBITS

shl_reg_1:

;    int bytes = places >> 3;
;    int bits = places & 0x07;
	ld	a,c
	and	#0x07
	ld	2(ix),a     ; IX+2 = 'bits'
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c            ; BC = 'bytes'

;    int leftbytes = NBYTES - bytes;
	ld	hl,#NBYTES
	xor	a
	sbc	hl,bc       ; HL = 'leftbytes'
	ld	4(ix),l     ; IX+4, IX+5 = 'leftbytes'
	ld	5(ix),h

;    if (bytes){
	ld	a,b
	or	c
	jr	z,shl_reg_2

;        if (leftbytes)
	ld	a,h
	or	l
	jr	z,shl_reg_1a

	push	bc         ; Save 'bytes'
	push	hl         ; Save 'leftbytes'

;            memmove(&reg[0], &reg[bytes], leftbytes);
	ld	h,d
	ld	l,e
	add	hl,bc       ; DE='reg' HL='reg[bytes]'
	pop	bc          ; Restore 'leftbytes'
	ldir

	pop	bc          ; Restore 'bytes'

shl_reg_1a:

;        memset(&reg[leftbytes],0,bytes);
;    }

	ld	h,d  ; Here DE points to the 1st byte to fill w/ zero (obtained from the
	ld	l,e  ; previous LDIR if it took place, or the previous value).

shl_reg_1b:

	xor	a
	ld	(hl),a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,shl_reg_1b

shl_reg_2:

;    if (bits){
	ld	a,2(ix)     ; 'bits'
	or	a
	jr	z,shl_reg_end

;        for (i = 0; i < (leftbytes-1); i++){
    ; Vai fazer o shift
	ld	c,4(ix)
	ld	b,5(ix)     ;'leftbytes'
	ld	a,b
	or	c
	jr	z,shl_reg_3
	dec	bc
	ld	a,b
	or	c
	jr	z,shl_reg_3

	ld	l,(ix)
	ld	h,1(ix)     ; HL = 'reg'

shl_reg_2a:

;            reg[i] <<= bits;
	ld	a,2(ix)     ; 'bits'
	ld	e,a          ; 'bits'
	neg
	add	a,#8
	ld	d,a
	ld	a,(hl)

shl_reg_2b:

	sla	a
	dec	e
	jr	nz,shl_reg_2b

;            uint8_t aux = reg[i+1] >> (8-bits);
	ld	e,a

	inc	hl
	ld	a,(hl)
	dec	hl

shl_reg_2c:

	srl	a
	dec	d
	jr	nz,shl_reg_2c

;            reg[i] |= aux;
;        }
	or	e
	ld	(hl),a
	inc	hl

	dec	bc
	ld	a,b
	or	c
	jr	nz,shl_reg_2a

shl_reg_3:
;        reg[leftbytes - 1] <<= bits;
	ld	a,(hl)
	ld	b,2(IX)     ; 'bits'

shl_reg_2d:

	sla	a
	djnz	shl_reg_2d

	ld	(hl),a

;    }

shl_reg_end:

	ld	hl,#0x0008    ; Frees 8 bytes
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
stack_test:

	push	ix
	ld	ix,#0xFFF8    ; Allocates 8 bytes
	add	ix,sp
	ld	sp,ix

	ld	c,(ix)
	ld	b,1(ix)
    	;....
	ld	hl,#0x0008    ; Frees 8 bytes
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
;   shr_reg
;   void shr_reg(uint8_t *reg, int places);
;   Parameters:
;     DE: reg
;     BC: places
;   Returns: Nothing
;   Affects: BC DE HL AF
shr_reg:

	push	ix
	ld	ix,#0xFFF8    ; Allocates 8 bytes
	add	ix,sp
	ld	sp,ix

	ld	(ix),e     ; IX+0, IX+1 = 'reg'
	ld	1(ix),d

;    if (places > NBITS)
;        places = NBITS;
	ld	a,#(NBITS >> 8)
	sub	b
	jr	c,shr_reg_0
	jr	nz,shr_reg_1

	ld	a,#(NBITS & #255)
	sub	c
	jr	nc, shr_reg_1

shr_reg_0:

	ld	bc,#NBITS

shr_reg_1:

;    int bytes = places >> 3;
;    int bits = places & 0x07;
	ld	a,c
	and	#0x07
	ld	2(ix),a     ; IX+2 = 'bits'
	srl	b
	rr	c
	srl	b
	rr	c
	srl	b
	rr	c            ; BC = 'bytes'
	ld	6(ix),c
	ld	7(ix),b     ; IX+6, IX+7 = 'bytes'

;    int rightbytes = NBYTES - bytes;
	ld	hl,#NBYTES
	xor	a
	sbc	hl,bc       ; HL = 'rightbytes'
	ld	4(ix),l     ; IX+4, IX+5 = 'rightbytes'
	ld	5(ix),h

;    if (bytes){
	ld	a,b
	or	c
	jr	z,shr_reg_2

;        if (rightbytes)
	ld	a,h
	or	l
	jr	z,shr_reg_1a

;            memmove(&reg[bytes], &reg[0], rightbytes);
	ld	hl,#NBYTES1
	add	hl,de
	ld	d,h
	ld	e,l          ; DE = last buffer's byte (destination)

	xor	a           ; BC = 'bytes'
	sbc	hl,bc       ; HL = origem
	ld	c,4(ix)     ; 'rightbytes'
	ld	b,5(ix)
	lddr

shr_reg_1a:

;        memset(&reg[0],0,bytes);
	ld	c,6(ix)
	ld	b,7(ix)     ; IX+6, IX+7 = 'bytes'
	ld	l,0(ix)
	ld	h,1(ix)     ; IX+0, IX+1 = 'reg'

shr_reg_1b:

	xor	a
	ld	(hl),a
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,shr_reg_1b

;    }

shr_reg_2:

;    if (bits){
	ld	a,2(ix)     ; 'bits'
	or	a
	jr	z,shr_reg_end


;        for (i = NBYTES1; i > bytes; i--){
	ld	hl,#NBYTES1
	ld	c,6(ix)
	ld	b,7(ix)     ; IX+6, IX+7 = 'bytes'
	xor	a
	sbc	hl,bc

	ld	a,h
	or	l
	jr	z,shr_reg_2e

	ld	b,h
	ld	c,l          ; BC = # of bytes to process

	ld	l,0(ix)
	ld	h,1(ix)     ; HL = 'reg'

	ld	de,#NBYTES1
	add	hl,de

shr_reg_2a:

;            reg[i] >>= bits;
	ld	a,2(ix)     ; 'bits'
	ld	e,a          ; E = 'bits'
	neg
	add	a,#8
	ld	d,a          ; D = 8 - 'bits'
	ld	a,(hl)

shr_reg_2b:

	srl	a
	dec	e
	jr	nz,shr_reg_2b

	ld	e,a

;            uint8_t aux = reg[i-1] << (8-bits);
	dec	hl
	ld	a,(hl)
	inc	hl

shr_reg_2c:

	sla	a
	dec	d
	jr	nz,shr_reg_2c

;            reg[i] |= aux;
	or	e
	ld	(hl),a

;        }
	dec	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,shr_reg_2a

shr_reg_2e:

;        reg[bytes] >>= bits;
	ld	a,(hl)
	ld	b,2(IX)     ; 'bits'

shr_reg_2d:
	srl	a
	djnz	shr_reg_2d
	ld	(hl),a

;    }

shr_reg_end:

	ld	hl,#0x0008    ; Frees 8 bytes
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
;   mul_reg2_by_reg1
;   void mul_reg2_by_reg1(const uint8_t *reg1, uint8_t *reg2);
;   Parameters:
;     HL: reg1
;     DE: reg2
;   Returns: Nothing
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
mul_reg2_by_reg1:

	push	ix
	ld	ix,#(0xFFF8-2*NBYTES)    ; Allocates 8 bytes + 2 buffers
	add	ix,sp
	ld	sp,ix

	ld	(ix),l
	ld	1(ix),h         ; IX+0, IX+1: reg1
	ld	2(ix),e
	ld	3(ix),d         ; IX+2, IX+3: reg2

;    uint8_t regmdiv[NBYTES];
	.db	0xdd
	ld	c,l
	.db	0xdd
	ld	b,h            ; Copia IX em BC
	ld	HL,#8
	add	hl,bc
	ld	4(ix),l
	ld	5(ix),h         ; IX+4, IX+5: regmdiv

;    uint8_t regmdiv2[NBYTES];
	ld	bc,#NBYTES
	add	hl,bc
	ld	6(ix),l
	ld	7(ix),h         ; IX+6, IX+7: regmdiv2

;    memcpy(regmdiv, reg2, NBYTES);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	bc,#NBYTES
	ldir

;    memcpy(regmdiv2, reg2, NBYTES);
	ld	e,6(ix)
	ld	d,7(ix)         ; IX+6, IX+7: regmdiv2
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	bc,#NBYTES
	ldir

;    zero_reg(reg2);
	ld	l,2(ix)
	ld	h,3(ix)
	call	zero_reg       ;Zera reg2

;    int places = 0;
	ld	iy,#0            ; IY = places

;    // Integer part
;    for (int i = NBYTES_INT-1; i>=0; i--){

	ld	bc,#NBYTES_INT
	ld	l,(ix)
	ld	h,1(ix)       ; IX+0, IX+1: reg1
	add	hl,bc
	dec	hl            ; HL: buffer to process

mul_reg2_by_reg1_1:

;        int msk = 1;
	ld	d,#1

;        for (int j = 0; j < 8; j++){
	ld	e,#8

mul_reg2_by_reg1_2:

;            if (reg1[i] & msk){
	ld	a,(hl)
	and	d
	jr	z, mul_reg2_by_reg1_3

;                shl_reg(regmdiv,places);
	push	bc
	push	de
	push	hl

	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	.db	0xfd
	ld	b,h
	.db	0xfd
	ld	c,l            ; BC gets IY = 'places'
	call	shl_reg

;                add_reg2_to_reg1(reg2, regmdiv);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regmdiv
	call	add_reg2_to_reg1

	pop	hl
	pop	de
	pop	bc

;                places = 1;
	ld	iy,#1     ; IY = places
;            }
;            else
;                places++;
	jr	mul_reg2_by_reg1_4

mul_reg2_by_reg1_3:

	inc	iy

mul_reg2_by_reg1_4:

;            msk <<= 1;
	ld	a,d
	sla	a
	ld	d,a

;        }
	dec	e
	jr	nz,mul_reg2_by_reg1_2

;    }
	dec	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,mul_reg2_by_reg1_1

;    memcpy(regmdiv, regmdiv2, NBYTES);
	ld	l,6(ix)
	ld	h,7(ix)         ; IX+6, IX+7: regmdiv2
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	bc,#NBYTES
	ldir

;    shr_reg(regmdiv,1);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	bc,#1
	call	shr_reg

;    places = 0;
	ld	iy,#0

;    //Frac part
;    for (int i = NBYTES_INT; i < NBYTES; i++){
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg1
	ld	bc,#NBYTES_INT
	add	hl,bc
	ld	bc, #(NBYTES - NBYTES_INT)

mul_reg2_by_reg1_5:

;        int msk = 128;
	ld	d,#128

;        for (int j = 0; j < 8; j++){
	ld	e,#8

mul_reg2_by_reg1_6:

;            if (reg1[i] & msk){
	ld	a,(hl)
	and	d
	jr	z,mul_reg2_by_reg1_7

	push	bc
	push	de
	push	hl

;                shr_reg(regmdiv,places);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	.db	0xfd
	ld	b,h
	.db	0xfd
	ld	c,l            ; BC <- IY = 'places'
	call	shr_reg

;                add_reg2_to_reg1(reg2, regmdiv);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regmdiv
	call	add_reg2_to_reg1

	pop	hl
	pop	de
	pop	bc

;                places = 1;
	ld	iy,#1
	jr	mul_reg2_by_reg1_8
;            }
;            else
;                places++;
mul_reg2_by_reg1_7:

	inc	iy

mul_reg2_by_reg1_8:

;            msk >>= 1;
	ld	a,d
	srl a
	ld	d,a

;        }
	dec	e
	jr	nz, mul_reg2_by_reg1_6

;    }
	inc	hl
	dec	bc
	ld	a,b
	or	c
	jr	nz,mul_reg2_by_reg1_5

mul_reg2_by_reg1_end:

	ld	hl,#(0x0008+(2*NBYTES))    ; Frees 8 bytes + 2 buffers
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
;   mul_acc_by_reg
;   void mul_acc_by_reg(const uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Nothing
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
mul_acc_by_reg:

;    mul_reg2_by_reg1(reg, acc);
	ld	de,#acc
	call	mul_reg2_by_reg1
	ret

;///////////////////////////////////////////////////////////////////////////////
;   mul_reg_10
;   void mul_reg_10(uint8_t *reg);
;   Parameters:
;     DE: reg
;   Returns: Nothing
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
mul_reg_10:

	push	ix
	ld	ix,#(0xFFF8-NBYTES)    ; Allocates 8 bytes + buffer
	add	ix,sp
	ld	sp,ix

	ld	(ix),e
	ld	1(ix),d         ; IX+0, IX+1: reg

;    uint8_t regmdiv[NBYTES];
	.db	0xdd
	ld	c,l
	.db	0xdd
	ld	b,h            ; Copy IX -> BC
	ld	HL,#8
	add	hl,bc
	ld	4(ix),l
	ld	5(ix),h         ; IX+4, IX+5: regmdiv

;    memcpy(regmdiv, reg, NBYTES);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg
	ld	bc,#NBYTES
	ldir

;    shl_reg(reg, 1);
	ld	e,(ix)
	ld	d,1(ix)         ; IX+0, IX+1: reg
	ld	bc,#1
	call	shl_reg

;    shl_reg(regmdiv, 3);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	bc,#3
	call	shl_reg

;    add_reg2_to_reg1(reg,regmdiv);
	ld	e,(ix)
	ld	d,1(ix)         ; IX+0, IX+1: reg
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regmdiv
	call	add_reg2_to_reg1

	ld	hl,#(0x0008+NBYTES)    ; Frees 8 bytes + buffer
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
;   compare
;   int compare (const uint8_t *reg1, const uint8_t *reg2);
;   Parameters:
;     HL: reg1
;     DE: reg2
;   Returns: Flags: Z:        reg1 = reg2
;                   NZ & C:   reg1 < reg2
;                   NC & NC:  reg1 > reg2
;   Affects: BC DE HL AF
compare:

;    for (int i = 0; i < NBYTES; i++){
	ld	bc,#NBYTES

compare_1:

;        if (reg1[i] < reg2[i]) return -1;   // reg1 < reg2
;        if (reg1[i] > reg2[i]) return 1;    // reg1 > reg2
;    }

	ld	a,(de)
	cpi
	jr	nz,compare_2
	inc	de
	jp	pe,compare_1

;	return 0;   // Same value
	xor	a
	ret

compare_2:
	dec	hl
	cp	(hl)
	ccf
	ret

;///////////////////////////////////////////////////////////////////////////////
;   iszero
;   int iszero (const uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Flags: Z:        reg = 0
;                   NZ:       reg1 != 0
;   Affects: BC DE HL AF
iszero:

;    for (int i = 0; i < NBYTES; i++){
	ld	bc,#NBYTES
	xor	a

iszero_1:

;        if (reg[i]) return 0;   // nonzero
	cpi
	ret	nz

;    }
	jp	pe,iszero_1

;	return 1;   // Is zero
	xor	a
	ret

;///////////////////////////////////////////////////////////////////////////////
;   div_reg2_by_reg1
;   int div_reg2_by_reg1(const uint8_t *reg1, uint8_t *reg2);
;   Parameters:
;     HL: reg1
;     DE: reg2
;   Returns: Flags: Z:        Div OK
;                   NZ:       Div Error
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
div_reg2_by_reg1:

	push	ix
	ld	ix,#(0xFFF6-3*NBYTES)    ; Allocates 10 bytes + 3 buffers
	add	ix,sp
	ld	sp,ix

	ld	(ix),l
	ld	1(ix),h         ; IX+0, IX+1: reg1
	ld	2(ix),e
	ld	3(ix),d         ; IX+2, IX+3: reg2

;    uint8_t regmdiv[NBYTES];
	.db	0xdd
	ld	c,l
	.db	0xdd
	ld	b,h            ; Copia IX em BC
	ld	HL,#10
	add	hl,bc
	ld	4(ix),l
	ld	5(ix),h         ; IX+4, IX+5: regmdiv

;    uint8_t regmdiv2[NBYTES];
	ld	bc,#NBYTES
	add	hl,bc
	ld	6(ix),l
	ld	7(ix),h         ; IX+6, IX+7: regmdiv2

;    if (iszero(reg1)) return -1; // Divide by zero
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg
	call	iszero
	jr	nz, div_reg2_by_reg1_1
	ld	a,#0xff
	jp	div_reg2_by_reg1_end

div_reg2_by_reg1_1:

;    int res = compare (reg2, reg1);
;    if (res == 0){   // iguais
;        zero_reg(reg2);
;        set_bit_reg_int(reg2, 0);    //1
;    	return 0;   //ok
;    }
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg1
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	call	compare
	jr	nz, div_reg2_by_reg1_2

	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	call	zero_reg
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	bc,#0
	call	set_bit_reg_int
	xor	a
	jp	div_reg2_by_reg1_end

div_reg2_by_reg1_2:

;    uint8_t regquot[NBYTES];
	ld	bc,#NBYTES
	ld	l,6(ix)
	ld	h,7(ix)         ; IX+6, IX+7: regmdiv2
	add	hl,bc
	ld	8(ix),l
	ld	9(ix),h         ; IX+8, IX+9: regquot

;    zero_reg(regquot);
    	;ld l,8(ix)
    	;ld h,9(ix)         ; IX+8, IX+9: regquot
	call	zero_reg

;    memcpy(regmdiv, reg1, NBYTES);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg1
	ld	bc,#NBYTES
	ldir

;    memcpy(regmdiv2, reg1, NBYTES);
	ld	e,6(ix)
	ld	d,7(ix)         ; IX+6, IX+7: regmdiv2
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg1
	ld	bc,#NBYTES
	ldir

;    for (;!iszero(reg2);){
div_reg2_by_reg1_3:

	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	call	iszero
	jp	z, div_reg2_by_reg1_5

;        int res = compare (reg2, regmdiv);
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	compare

;        if (res == -1){ // reg2 < regmdiv
	jp	nc, div_reg2_by_reg1_4
	jp	z, div_reg2_by_reg1_4

;            int order = 0;
	ld	iy,#0

;            for (;!iszero(reg2);){
div_reg2_by_reg1_3a:

	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	call	iszero
	jr	z, div_reg2_by_reg1_3b

;                if (compare(reg2, regmdiv) < 0){ //reg2 < regmdiv

	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	compare
	jr	nc, div_reg2_by_reg1_3c
	jr	z, div_reg2_by_reg1_3c

;                    shr_reg(regmdiv, 1);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	bc,#1
	call	shr_reg

;                    order++;
	inc	iy
;                    if (order >= NBITS_FRAC){
;                        memcpy(reg2, regquot, NBYTES);
;                    	return 0;
;                    }
	.db	0xfd
	ld	d,h
	.db	0xfd
	ld	e,l
	ex de,hl
	ld	de,#NBITS_FRAC
	xor	a
	sbc	hl,de
	jr	nc, div_reg2_by_reg1_3b

;                   continue;
	jr	div_reg2_by_reg1_3a
;                }

div_reg2_by_reg1_3c:

;                sub_reg2_from_reg1(reg2, regmdiv);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+0, IX+1: regmdiv
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	call	sub_reg2_from_reg1

;                set_bit_reg(regquot, NBITS_FRAC - order);
	ld	hl,#NBITS_FRAC
	.db	0xfd
	ld	c,l
	.db	0xfd
	ld	b,h
	xor	a
	sbc	hl,bc
	ld	c,l
	ld	b,h
	ld	l,8(ix)
	ld	h,9(ix)         ; IX+8, IX+9: regquot
	call	set_bit_reg

;            }
	jp	div_reg2_by_reg1_3a

div_reg2_by_reg1_3b:

;            memcpy(reg2, regquot, NBYTES);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	ld	l,8(ix)
	ld	h,9(ix)         ; IX+8, IX+9: regquot
	ld	bc,#NBYTES
	ldir

;        	return 0;
	xor	a
	jp	div_reg2_by_reg1_end

;        }
;        else{   // reg2 >= regmdiv

div_reg2_by_reg1_4:

;            int order = 0;
	ld	iy,#0

;            for (;;){
div_reg2_by_reg1_4a:

;                if (compare(reg2, regmdiv) < 0){ //reg2 < regmdiv
;                    break;
;                }
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	compare
	jr	c, div_reg2_by_reg1_4b

;                shl_reg(regmdiv, 1);
	ld	bc,#1
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	shl_reg

;                if (compare(reg2, regmdiv) < 0){ //reg2 < regmdiv
;                    break;
;                }
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: reg2
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	compare
	jr	c, div_reg2_by_reg1_4b

;                order++;
	inc	iy

;            }
	jr	div_reg2_by_reg1_4a

div_reg2_by_reg1_4b:

;            memcpy(regmdiv, regmdiv2, NBYTES);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	l,6(ix)
	ld	h,7(ix)         ; IX+6, IX+7: regmdiv2
	ld	bc,#NBYTES
	ldir

;            shl_reg(regmdiv, order);
	.db	0xfd
	ld	c,l
	.db	0xfd
	ld	b,h
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	call	shl_reg

;            sub_reg2_from_reg1(reg2, regmdiv);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regmdiv
	call	sub_reg2_from_reg1

;            set_bit_reg_int(regquot, order);
	ld	l,8(ix)
	ld	h,9(ix)         ; IX+8, IX+9: regquot
	.db	0xfd
	ld	c,l
	.db	0xfd
	ld	b,h
	call	set_bit_reg_int

;            memcpy(regmdiv, regmdiv2, NBYTES);
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regmdiv
	ld	l,6(ix)
	ld	h,7(ix)         ; IX+6, IX+7: regmdiv2
	ld	bc,#NBYTES
	ldir

;        }
;    }
	jp	div_reg2_by_reg1_3

div_reg2_by_reg1_5:

;    memcpy(reg2, regquot, NBYTES);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: reg2
	ld	l,8(ix)
	ld	h,9(ix)         ; IX+8, IX+9: regquot
	ld	bc,#NBYTES
	ldir

;	return 0;
	xor	a

div_reg2_by_reg1_end:

	ld	hl,#(0x000A+3*NBYTES)    ; Frees 10 bytes + 3 buffers
	add	hl,sp
	ld	sp,hl
	pop	ix
	or	a
	ret

;///////////////////////////////////////////////////////////////////////////////
;   div_acc_by_reg
;   int div_acc_by_reg(const uint8_t *reg)
;   Parameters:
;     HL: reg
;   Returns: Flags: Z:        Div OK
;                   NZ:       Div Error
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
div_acc_by_reg:

    ;return div_reg2_by_reg1(reg, acc);
	ld	de,#acc
	jp	div_reg2_by_reg1

;///////////////////////////////////////////////////////////////////////////////
;   print_int_part
;   void print_int_part(const uint8_t *reg);
;   Parameters:
;     HL: reg
;   Returns: Nothing
;   Affects: BC DE HL AF
print_int_part_digit:

	ld	e,#0
	xor	a

print_int_part_digit_0:

	sbc	hl,bc
	jr	z,print_int_part_digit_2b
	jr	c,print_int_part_digit_2a
	inc	e
	jr	print_int_part_digit_0

print_int_part_digit_2a:
	add	hl,bc
	jr	print_int_part_digit_2

print_int_part_digit_2b:
	inc	e

print_int_part_digit_2:

	ld	a,e
	or	a
	jr	nz,print_int_part_digit_3

	bit 0,d
	ret	z

print_int_part_digit_3:

	ld	d,#1
	add	a,#'0'
	rst	0x08
	ret

print_int_part:

	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	ld	l,c
	ld	h,b

	ld	d,#0
	ld	bc,#10000
	call	print_int_part_digit
	ld	bc,#1000
	call	print_int_part_digit
	ld	bc,#100
	call	print_int_part_digit
	ld	bc,#10
	call	print_int_part_digit
    	;ld bc,#1
    	;call print_int_part_digit
	ld	a,l
	add	a,#'0'
	rst	0x08
	ret

;///////////////////////////////////////////////////////////////////////////////
;   print_bc
;   Internal function for debugging
;   Parameters:
;     BC: value to print
;   Returns: Nothing
;   Affects: BC DE HL AF
print_bc:

	ld	l,c
	ld	h,b

	ld	d,#0
	ld	bc,#10000
	call	print_int_part_digit
	ld	bc,#1000
	call	print_int_part_digit
	ld	bc,#100
	call	print_int_part_digit
	ld	bc,#10
	call	print_int_part_digit
	ld	a,l
	add	a,#'0'
	rst	0x08
	ret

;///////////////////////////////////////////////////////////////////////////////
;   print_reg_decimal
;   void print_reg_decimal(const uint8_t *reg, int nplaces);
;   Parameters:
;     HL: reg
;     BC: nplaces
;   Returns: Nothing
;   Affects: BC DE HL AF
print_reg_decimal:

	push	ix
	ld	ix,#(0xFFF8-NBYTES)    ; Allocates 8 bytes + buffer
	add	ix,sp
	ld	sp,ix
	ld	(ix),l
	ld	1(ix),h         ; IX+0, IX+1: reg

    ;uint8_t regtmp[NBYTES];
	.db	0xdd
	ld	e,l
	.db	0xdd
	ld	d,h            ; Copia IX em DE
	ld	HL,#8
	add	hl,de
	ld	2(ix),l
	ld	3(ix),h         ; IX+2, IX+3: regtmp

;    print_int_part(reg);
;    printf(".");
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: reg
	push	hl
	push	bc
	call	print_int_part
	pop	bc
	ld	a,#'.'
	rst	0x08
	pop	hl

;    memcpy(regtmp, reg, NBYTES);
	push	bc

	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regtmp
	ld	bc,#NBYTES
	ldir

	pop	bc

	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: regtmp

;    if (nplaces)
;        ++nplaces;
	ld	a,b
	or	c
	jr	z, print_reg_decimal_1
	inc	bc

print_reg_decimal_1:

;    for (;;){
;        if (nplaces){
	ld	a,b
	or	c
	jr	z, print_reg_decimal_2

;            --nplaces;
	dec	bc
;            if (!nplaces)
;                break;
	ld	a,b
	or	c
	jr	z, print_reg_decimal_3
;        }

print_reg_decimal_2:

;        memset(regtmp,0,NBYTES_INT);
	xor	a
	ld	(hl),a
	inc	hl
	ld	(hl),a
	dec	hl

;        if (iszero(regtmp)) break;
	push	bc
	push	hl
	call	iszero
	pop	hl
	pop	bc
	jr	z, print_reg_decimal_3

;        mul_reg_10(regtmp);
	push	bc
	push	hl
	ld	e,l
	ld	d,h
	call	mul_reg_10
	pop	hl
	pop	bc

;        print_int_part(regtmp);
	inc	hl
	ld	a,(hl)
	dec	hl
	add	a,#'0'
	rst	0x08

;    }
	jr	print_reg_decimal_1

print_reg_decimal_3:
print_reg_decimal_end:

	ld	hl,#(0x0008+NBYTES)    ; Frees 8 bytes + buffer
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

;///////////////////////////////////////////////////////////////////////////////
;   println_reg_decimal
;   void println_reg_decimal(const uint8_t *reg, int nplaces);
;   Parameters:
;     HL: reg
;     BC: nplaces
;   Returns: Nothing
;   Affects: BC DE HL AF
println_reg_decimal:

	call	print_reg_decimal
	call	print_crlf
	ret

;///////////////////////////////////////////////////////////////////////////////
;   test_pi_bbp
;   void test_pi_bbp(void); // Bailey-Borwein-Plouffe
;   Parameters: Nothing
;   Returns: Nothing
;   Affects: BC DE HL AF
test_pi_bbp:

	push	ix
	ld	ix,#(0xFFF6-3*NBYTES)    ; Allocates 10 bytes + 3 buffers
	add	ix,sp
	ld	sp,ix

;    uint8_t regtotal[NBYTES];
	.db	0xdd
	ld	c,l
	.db	0xdd
	ld	b,h            ; IX -> BC
	ld	HL,#10
	add	hl,bc
	ld	(ix),l
	ld	1(ix),h         ; IX+0, IX+1: regtotal

;    uint8_t regsubtotal[NBYTES];
	ld	bc,#NBYTES
	add	hl,bc
	ld	2(ix),l
	ld	3(ix),h         ; IX+2, IX+3: regsubtotal

;    uint8_t regden[NBYTES];
    ;ld bc,#NBYTES
	add	hl,bc
	ld	4(ix),l
	ld	5(ix),h         ; IX+4, IX+5: regden

;    zero_reg(regtotal);
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: regtotal
	call	zero_reg

;    for (int k = 0; k < 10000; k++){
	ld	bc,#0

test_pi_bbp_1:

	ld	6(ix),c
	ld	7(ix),b         ; IX+6, IX+7: k

	ld	a,b
	cp	#(NUM_IT >> 8)
	jr	c, test_pi_bbp_1a

	ld	a,c
	cp	#(NUM_IT & 0xff)
	jr	c, test_pi_bbp_1a

	jp	test_pi_bbp_2

test_pi_bbp_1a:

;        zero_reg(regsubtotal);
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: regsubtotal
	call	zero_reg

;        zero_reg(regden);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regden
	push	hl
	call	zero_reg
	pop	de              ; DE has regden

;        load_reg_int(regden,8*k+1);     // Sets 8k+1
	ld	l,6(ix)
	ld	h,7(ix)         ; IX+6, IX+7: k
	sla	l
	rl	h
	sla	l
	rl	h
	sla	l
	rl	h
	inc	hl
	call	load_reg_int   ; DE is correct here

;        zero_reg(acc);
	ld	hl,#acc
	call	zero_reg

;        set_bit_reg_int(acc, 2);        // Sets with 4
	ld	hl,#acc
	ld	bc,#2
	call	set_bit_reg_int

;        div_acc_by_reg(regden);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regden
	call	div_acc_by_reg

;        add_reg2_to_reg1(regsubtotal,acc);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regsubtotal
	ld	hl,#acc
	call	add_reg2_to_reg1

;        inc_reg_int8(regden, 3);        // 8k+4
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regden
	ld	a,#3
	call	inc_reg_int8

;        zero_reg(acc);
	ld	hl,#acc
	call	zero_reg

;        set_bit_reg_int(acc, 1);        // Sets with 2
	ld	hl,#acc
	ld	bc,#1
	call	set_bit_reg_int

;        div_acc_by_reg(regden);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regden
	call	div_acc_by_reg

;        sub_reg2_from_reg1(regsubtotal,acc);
	ld	hl,#acc
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regsubtotal
	call	sub_reg2_from_reg1

;        inc_reg_int8(regden, 1);        // 8k+5
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regden
	ld	a,#1
	call	inc_reg_int8

;        zero_reg(acc);
	ld	hl,#acc
	call	zero_reg

;        set_bit_reg_int(acc, 0);        // Sets with 1
	ld	hl,#acc
	ld	bc,#0
	call	set_bit_reg_int

;        div_acc_by_reg(regden);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regden
	call	div_acc_by_reg

;        sub_reg2_from_reg1(regsubtotal,acc);
	ld	hl,#acc
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regsubtotal
	call	sub_reg2_from_reg1

;        inc_reg_int8(regden, 1);        // 8k+6
	ld	e,4(ix)
	ld	d,5(ix)         ; IX+4, IX+5: regden
	ld	a,#1
	call	inc_reg_int8

;        zero_reg(acc);
	ld	hl,#acc
	call	zero_reg

;        set_bit_reg_int(acc, 0);        // Sets with 1
	ld	hl,#acc
	ld	bc,#0
	call	set_bit_reg_int

;        div_acc_by_reg(regden);
	ld	l,4(ix)
	ld	h,5(ix)         ; IX+4, IX+5: regden
	call	div_acc_by_reg

;        sub_reg2_from_reg1(regsubtotal,acc);
	ld	hl,#acc
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regsubtotal
	call	sub_reg2_from_reg1

;        shr_reg(regsubtotal, 4*k);
	ld	e,2(ix)
	ld	d,3(ix)         ; IX+2, IX+3: regsubtotal
	ld	c,6(ix)
	ld	b,7(ix)         ; IX+6, IX+7: k
	sla	c
	rl	b
	sla	c
	rl	b
	call	shr_reg

;        add_reg2_to_reg1(regtotal, regsubtotal);
	ld	e,(ix)
	ld	d,1(ix)         ; IX+0, IX+1: regtotal
	ld	l,2(ix)
	ld	h,3(ix)         ; IX+2, IX+3: regsubtotal
	call	add_reg2_to_reg1

;;        if (!(k % 10)){
;;            printf("%5d: ",k);
;;            print_reg_decimal(regtotal, 120);
;;            int places_ok = compare_digits_to_pi(regtotal);
;;            printf(" (%d)\n",places_ok);
;;            if (places_ok >= 1000) return;
;;        }
;            print_reg_decimal(regtotal, 120);
	ld	a,#'*'
	rst	0x08
	;ld l,(ix)
	;ld h,1(ix)         ; IX+0, IX+1: regtotal
	;ld bc,NUM_DECS
	;call println_reg_decimal

;    }
	ld	c,6(ix)
	ld	b,7(ix)         ; IX+6, IX+7: k
	inc	bc
	;ld 6(ix),c
	;ld 7(ix),b         ; IX+6, IX+7: k

	jp	test_pi_bbp_1

test_pi_bbp_2:
test_pi_bbp_end:

	call	lcd_clear
	ld	hl,#msg_pi
	call	lcd_wmsg
	ld	l,(ix)
	ld	h,1(ix)         ; IX+0, IX+1: regtotal
	ld	bc,#NUM_DECS
    ;call println_reg_decimal
	call	print_reg_decimal

	ld	hl,#(0x000A+3*NBYTES)    ; Frees 10 bytes + 3 buffers
	add	hl,sp
	ld	sp,hl
	pop	ix
	ret

msg_pi:	.ascii	"PI:\0"

;///////////////////////////////////////////////////////////////////////////////
;   _main
;   void _main(void);
;   Parameters: Nothing
;   Returns: Nothing
;   Affects: BC DE HL AF IY BC' DE' HL' AF'
_main:

	call	lcd_init
	call	msg_init     ;escreve título "Alpha Z80" 
	call	test_pi_bbp
	ret

; =============================================================================
; --- Imprime o título na segunda linha do LCD ---
msg_init:
	call	lcd_home2
	ld	hl,#msg_picalc
	jp	lcd_wmsg

msg_picalc:    
	.ascii "PICALC 1.0\0"

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

;///////////////////////////////////////////////////////////////////////////////
    .org RAMBASE

acc:	.ds NBYTES   ; Global variable, to make things a bit easier.
dispcol:.ds 1

	.area _DATA

;	.end

