/*
CLOCK.C
Example program for the KRAFT 80
2025 - ARM Coder
*/

#include <stdio.h>
#include <ctype.h>

#include "io-kraft80.h"
#include "videodisp.h"

#pragma codeseg CODE


void new_isr2(void) __interrupt;

int presc = 0;
unsigned char hours = 0, mins = 0, secs = 0, secs_a = 0;

int *isr2vector;
int isr2vector_copy;

void printtime(void);
void di();
void ei();
////////////////////////////////////////////////////////////////////////////////
void main (void){

    unsigned char buttons;
    unsigned char buttons_a;
    unsigned char delta;

#if USE_KRAFTMON == 1
    isr2vector = (int*)0xff04;
    char *p = 0xfffe;
#else
    isr2vector = (int*)0x4104;
    char *p = 0x41fe;
#endif

    setleds(0x55);
    lcd_begin();
    
    video_begin(1);
    video_border();

    isr2vector_copy = *isr2vector;

    di();
    
    *isr2vector = (int)new_isr2;

    ei();
    
    printtime();

    video_printtime(hours, mins, secs);

    buttons = buttons_a = readbuttons();
    
    for (;;){

        buttons = readbuttons();
        delta = buttons ^ buttons_a;
        
        if (delta & 0x01 & buttons_a){
            di();
            hours++;
            if (hours == 24) hours = 0;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }

        if (delta & 0x02 & buttons_a){
            di();
            mins++;
            if (mins == 60) mins = 0;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }

        if (delta & 0x04 & buttons_a){
            di();
            secs++;
            if (secs == 60) secs = 0;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }

        if (delta & 0x08 & buttons_a){
            di();
            if (hours)
                hours--;
            else
                hours = 23;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }

        if (delta & 0x10 & buttons_a){
            di();
            if (mins)
                mins--;
            else
                mins = 59;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }

        if (delta & 0x20 & buttons_a){
            di();
            if (secs)
                secs--;
            else
                secs = 59;
            ei();
            printtime();
            video_printtime(hours, mins, secs);
        }
        
        buttons_a = buttons;
        
        setleds(*p & buttons);
        if (secs != secs_a){
            secs_a = secs;
            printtime();
            video_printtime(hours, mins, secs);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
void di() __naked{

    __asm
    di
    ret
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void ei() __naked{

    __asm
    ei
    ret
    __endasm;
}

////////////////////////////////////////////////////////////////////////////////
void printlcddec(int d){

    putchar_lcd('0' + (d / 10));
    putchar_lcd('0' + (d % 10));
}

////////////////////////////////////////////////////////////////////////////////
void printtime(void){

    lcd_home();
    printlcddec(hours);
    putchar_lcd(':');
    printlcddec(mins);
    putchar_lcd(':');
    printlcddec(secs);
}

////////////////////////////////////////////////////////////////////////////////
void new_isr2(void) __interrupt {

    presc++;
    if (presc == 300){
        presc = 0;
        secs++;
        if (secs == 60){
            secs = 0;
            ++mins;
            if (mins == 60){
                mins = 0;
                ++hours;
                if (hours == 24){
                    hours = 0;
                }
            }
        }
    }

    __asm

    ld hl,#ret_isr2
    push hl
    ld hl,(_isr2vector_copy)
    jp (hl)
ret_isr2:

    __endasm;
}

