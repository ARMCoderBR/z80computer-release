#include <stdio.h>
#include <ctype.h>

#include "io-kraft80.h"

#pragma codeseg MAIN

////////////////////////////////////////////////////////////////////////////////
void main (void){

    setleds(0x55);
    lcd_begin();

    putstr ("PI CALC BBP\r\n");
    putstr_lcd("PI CALC BBP     ");
    
    int k;
    
    float pi, oitok, sum;
    
    pi = 0;
    oitok = 1;
        
    for (k = 0; k < 10; k++){
    
        oitok = 8*k;
    	sum = (4/(oitok+1) - 2/(oitok+4) - 1/(oitok+5) - 1/(oitok+6));
    	for (int l = 0; l < k; l++)
	    sum /= 16;
        pi += sum;
    }
    
    putstr("PI:3.");
    putstr_lcd("PI:3.");
    
    pi -= (int)pi;
    pi *= 10;
    
    for (int i = 0; i < 7; i++){
    	putchar ('0'+(int)pi);
    	putchar_lcd('0'+(int)pi);
        pi -= (int)pi;
        pi *= 10;
    }

    putstr("\r\n");
    
    char *p = 0xfffe;
    for (;;){

        setleds(*p & readbuttons());
    }
}

