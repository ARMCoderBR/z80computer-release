/*
IO-KRAFT80.C
Support routines for the KRAFT 80
2025 - ARM Coder
LCD control functions by Wagner Rambo - WR Kits - wrkits.com.br
*/

#include <stdio.h>
#include "io-kraft80.h"

#pragma codeseg CODE

////////////////////////////////////////////////////////////////////////////////
char *lgets_noecho(char *buf, int bufsize){

    int i = 0;
    char a;
    for (;;){
    
        a = getchar();

        if (a == 0x0d){
            buf[i] = 0;
            return buf;
        }

        if (a == 0x08){
            if (i) --i;
            continue;
        }

        //if (i >= ' '){
            buf[i] = a;
            if (i < (bufsize-1))
                ++i;
        //}
    }
}

////////////////////////////////////////////////////////////////////////////////
char *lgets(char *buf, int bufsize){

    int i = 0;
    char a;
    for (;;){
    
        a = getchar();
        putchar(a);
        if (a == 0x0d){
            buf[i] = 0;
            return buf;
        }
        if (a == 0x08){
            if (i) --i;
            continue;
        }
        buf[i] = a;
        if (i < (bufsize-1))
            ++i;
    }
}

////////////////////////////////////////////////////////////////////////////////
void putstr(char *s){

    while(*s){
        putchar(*(s++));
    }
}
	
////////////////////////////////////////////////////////////////////////////////
void putstr_lcd(char *s){

    while(*s){
        putchar_lcd(*(s++));
    }
}

	
////////////////////////////////////////////////////////////////////////////////
int getchar() __naked{

    __asm

    rst #0x10
    jr z,_getchar
    ld e,a
    ld d,#0
    ret
    
    __endasm;
}
	
	
////////////////////////////////////////////////////////////////////////////////
int putchar (int a) __naked{

    __asm

    ld a,l
    rst #0x08
    ld l,#0
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void setleds(char leds) __naked{

    __asm

PORTA .equ 0x00

    out(PORTA),a
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
unsigned char readbuttons() __naked{

    __asm
PORTX .equ 0x00
    
    in a,(PORTX)
    ld l,a
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
int putchar_lcd (char a) __naked{
    __asm

    push bc
    ld c,#12
    rst	#0x20
    ld l,#0
    pop bc
    ret
    
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_home() __naked{

    __asm
    
    push bc
    ld c,#10
    rst #0x20
    pop bc
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_home2() __naked{

    __asm

    push bc
    ld c,#11
    rst #0x20
    pop bc
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_clear() __naked{

    __asm

    push bc
    ld c,#9
    rst #0x20
    pop bc
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void lcd_begin() __naked{

    __asm
    
    push bc
    ld c,#8
    rst #0x20
    pop bc
    ret

    __endasm;
}

int pos;

////////////////////////////////////////////////////////////////////////////////
void video_setpos(int row, int col){

  // Video is 160 bytes wide (320 pixels) by 200 rows
  // Each byte stores 2 pixels, the 4 MSBs store the "left" pixel color and the 4 LSBs store the "right" pixel.
  
  pos = 160*row + col;
  
  __asm

  di
  ld hl,(_pos)
  ld a,l
  out (0x51),a
  ld a,h
  out (0x52),a
  ei
  
  __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void video_out(unsigned char b){

  // Video is 160 bytes wide (320 pixels) by 200 rows
  // Each byte stores 2 pixels, the 4 MSBs store the "left" pixel color and the 4 LSBs store the "right" pixel.

  __asm

  out (0x50),a

  __endasm;
}

////////////////////////////////////////////////////////////////////////////////
int video_in(void){

  // Video is 160 bytes wide (320 pixels) by 200 rows
  // Each byte stores 2 pixels, the 4 MSBs store the "left" pixel color and the 4 LSBs store the "right" pixel.

  __asm

    in a,(0x50)
    ld e,a
    ld d,#0
    ret

  __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void video_begin(int mode){

  int row = 0;
  int col;
  
  pos = mode;
  __asm

  ld hl,(_pos)
  ld a,l
  out (0x53),a

  __endasm;
  
  video_setpos(row,0);

  for (row = 0; row < 240; row++){

    for (col = 0; col < 160; col++) video_out(0x00);
  }
}

////////////////////////////////////////////////////////////////////////////////
int serial_getchar() __naked{

    __asm

    ld c,#3
    rst #0x20
    jr z,_serial_getchar
    ld e,a
    ld d,#0
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
int serial_kbhit() __naked{

    __asm

    ld c,#2
    rst #0x20
    ld d,#0
    ld e,#0
    ret z
    inc e
    ret

    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
int serial_putchar (int a) __naked{

    __asm

    ld a,l
    ld c,#1
    rst #0x20
    ld l,#0
    ret

    __endasm;
}

