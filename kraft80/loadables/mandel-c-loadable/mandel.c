/*
MANDEL.C
Example program for the KRAFT 80
2025 - ARM Coder
*/

#include <stdio.h>
#include <ctype.h>

#include "io-kraft80.h"

#pragma codeseg CODE

#define X0 160.0
#define Y0 120.0
#define SCALE 80
#define ITMAX 15

////////////////////////////////////////////////////////////////////////////////
void plot (int x, int y, char color){

	video_setpos(y, x >> 1);

	int b = video_in();
	if (x & 1){
		b &= 0xf0;
		b |= (color & 0x0f);
	}
	else{
		b &= 0x0f;
		b |= (color << 4);
	}

	video_out(b);
}

////////////////////////////////////////////////////////////////////////////////
void plotasm (int x, int y, char color) __naked __sdcccall(0) {

	__asm
	ld iy,#2
	add iy,sp
	ld l,2(iy)	;y
	ld h,3(iy)
	sla l		;160 = 128+32
	rl h
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h

	ld c,l		;BC stores the origind hl * 32
	ld b,h

	sla l
	rl h
	sla l
	rl h

	add hl,bc	;HL is multiplied by 160

	ld c,(iy)	;x
	ld b,1(iy)
	srl b		;halves BC
	rr c

	add hl,bc
	ld a,l
	out (0x51),a
	ld a,h
	out (0x52),a

	in a,(0x50)
	bit 0,(iy)
	jr z,plotasm_coleven

	;column is odd here

	and #0xf0
	ld b,a
	ld a,4(iy)
	and #0x0f
	or b
	out (0x50),a
	ret

plotasm_coleven:

	and #0x0f
	ld b,a
	ld a,4(iy)
	sla a	
	sla a	
	sla a	
	sla a	
	or b
	out (0x50),a
	ret
	__endasm;
}

////////////////////////////////////////////////////////////////////////////////
void plot2 (int x, int y, char color){

	int b = color << 4; b |= (color & 0x0f);

	video_setpos(y, x >> 1);
	video_out(b);
	video_setpos(y+1, x >> 1);
	video_out(b);
}

////////////////////////////////////////////////////////////////////////////////
void plot2asm (int x, int y, char color) __naked __sdcccall(0) {

	__asm
	ld iy,#2
	add iy,sp
	ld l,2(iy)	;y
	ld h,3(iy)
	sla l		;160 = 128+32
	rl h
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h

	ld c,l		;BC stores the origind hl * 32
	ld b,h

	sla l
	rl h
	sla l
	rl h

	add hl,bc	;HL is multiplied by 160

	ld c,(iy)	;x
	ld b,1(iy)
	srl b		;halves BC
	rr c

	add hl,bc

	ld a,l
	out (0x51),a
	ld a,h
	out (0x52),a

	ld a,4(iy)
	and #0x0f
	ld e,a
        sla a
        sla a
        sla a
        sla a
	or e
	ld e,a		;E = new color

	out (0x50),a

	ld bc,#160
	add hl,bc
	ld a,l
	out (0x51),a
	ld a,h
	out (0x52),a
	ld a,e

	out (0x50),a
	ret
	__endasm;
}

////////////////////////////////////////////////////////////////////////////////
void main (void){

	video_begin(1);

	int ix,iy;

	float x0;
	float y0;
	float x;
	float y;
	int itcount;
	float xtemp,xx,yy;

	int step = 1;

	for (iy = 0; iy < 240; iy+=step){

		for (ix = 0; ix < 320; ix+=step){

			x0 = ((float)ix - X0)/SCALE;
			y0 = ((float)iy - Y0)/SCALE;
			x = 0.0;
			y = 0.0;
			itcount = 0;

			while (itcount < ITMAX) {

				xx = x*x;
				yy = y*y;

				if (xx + yy > 4.0)
					break;

				xtemp = xx-yy+x0;
				y = 2 * x*y + y0;
				x = xtemp;
				itcount++;
			}

			if (step == 1)
				plotasm (ix, iy, itcount);
			else
			for (int i = 0; i < step; i+=2){
				for (int j = 0; j < step; j+=2)
					plot2asm (ix+j, iy+i, itcount);
			}
		}
	}

	for (;;);
}










