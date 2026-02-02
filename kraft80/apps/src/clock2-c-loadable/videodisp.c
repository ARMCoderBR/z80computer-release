#include <stdio.h>
#include <ctype.h>
#include "io-kraft80.h"
#include "videodisp.h"

const char d0[] = { 
            0b00000000,
            0b01111100,
            0b10000010,
            0b10000010,
            0b10000010,
            0b10000010,
            0b01111100,
            0b00000000
};

const char d1[] = { 
            0b00000000,
            0b00010000,
            0b00110000,
            0b01010000,
            0b00010000,
            0b00010000,
            0b01111000,
            0b00000000,
};

const char d2[] = { 
            0b00000000,
            0b01111100,
            0b10000010,
            0b00011100,
            0b01100000,
            0b10000000,
            0b11111110,
            0b00000000,
};

const char d3[] = { 
            0b00000000,
            0b01111100,
            0b10000010,
            0b00011100,
            0b00000010,
            0b10000010,
            0b01111100,
            0b00000000,
};

const char d4[] = { 
            0b00000000,
            0b00011000,
            0b00101000,
            0b01001000,
            0b11111110,
            0b00001000,
            0b00001000,
            0b00000000,
};

const char d5[] = { 
            0b00000000,
            0b11111100,
            0b10000000,
            0b11111100,
            0b00000010,
            0b10000010,
            0b01111100,
            0b00000000,
};

const char d6[] = { 
            0b00000000,
            0b01111100,
            0b10000000,
            0b11111100,
            0b10000010,
            0b10000010,
            0b01111100,
            0b00000000,
};

const char d7[] = { 
            0b00000000,
            0b11111110,
            0b00000100,
            0b00001000,
            0b00010000,
            0b00100000,
            0b01000000,
            0b00000000,
};

const char d8[] = { 
            0b00000000,
            0b01111100,
            0b10000010,
            0b01111100,
            0b10000010,
            0b10000010,
            0b01111100,
            0b00000000,
};

const char d9[] = { 
            0b00000000,
            0b01111100,
            0b10000010,
            0b10000010,
            0b01111110,
            0b00000010,
            0b01111100,
            0b00000000,
};

const char d10[] = { 
            0b00000000,
            0b00000000,
            0b00110000,
            0b00110000,
            0b00000000,
            0b00110000,
            0b00110000,
            0b00000000,
};

const char * base[] = { d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10 };

////////////////////////////////////////////////////////////////////////////////
void rasterchar(char d, int line){

    char *base1 = base[d];
    
    int mask=128;
    int i;
    for (i = 0; i < 8; i++){
      if (base1[line] & mask)
        video_out(0x22);
      else
        video_out(0);
      mask >>= 1;
    }
}

////////////////////////////////////////////////////////////////////////////////
void rasterdec(char d, int line){

    char *base1 = base[d / 10];
    char *base2 = base[d % 10];
    
    int mask=128;
    int i;
    for (i = 0; i < 8; i++){
      if (base1[line] & mask)
        video_out(0x44);
      else
        video_out(0);
      mask >>= 1;
    }

    mask=128;
    for (i = 0; i < 8; i++){
      if (base2[line] & mask)
        video_out(0x44);
      else
        video_out(0);
      mask >>= 1;
    }
}

////////////////////////////////////////////////////////////////////////////////
void video_printtime(char h, char m, char s){

  int i;
  
  for (i = 0; i < 16; i+=2){

    video_setpos(i + 110, 48);

    rasterdec(h,i>>1);
    rasterchar(10,i>>1);
    rasterdec(m,i>>1);
    rasterchar(10,i>>1);
    rasterdec(s,i>>1);
  }
}

////////////////////////////////////////////////////////////////////////////////
void video_border(){

  int row = 0;
  int col;
  
  for (row = 1; row < 239; row++){
    video_setpos(row,0); 
    video_out(0x60);
    video_setpos(row,159); 
    video_out(0x06);
  }

  video_setpos(0,0); 
  for (col = 0; col < 160; col++)
    video_out(0x66);
#if 0
  video_setpos(1,0); 
  for (col = 0; col < 160; col++)
    video_out(0xe3);
  video_setpos(2,0); 
  for (col = 0; col < 160; col++)
    video_out(0x5f);
#endif

  video_setpos(239,0); 
  for (col = 0; col < 160; col++)
    video_out(0x66);
}

