/*
WOLFRAM.C
Example program for the KRAFT 80
2025 - ARM Coder
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "io-kraft80.h"

#pragma codeseg CODE

////////////////////////////////////////////////////////////////////////////////
int wolfram(int width, int height, int rulenum) {

    char cells[160];
    char nextcells[160];

    memset(cells, 0, width);
    memset(nextcells, 0, width);

    cells[width / 2] = 1;

    char rule[8];

    int mask = 1;

    ////////////////////////////////////////////////////////////////////////////

    int i;

    for (i = 0; i < 8; i++) {

        if (rulenum & mask)
            rule[i] = 1;
        else
            rule[i] = 0;

        mask <<= 1;
    }

    ////////////////////////////////////////////////////////////////////////////

    putstr("\r\n.");
    for (i = 0; i < width; i++)
        putstr("=");
    putstr(".\r\n.");

    int it;
    for (it = 0; it < height; it++) {

        for (i = 0; i < width; i++) {

            if (cells[i])
                putstr("#");
            else
                putstr(" ");
        }

        putstr(".\r\n.");

        for (i = 0; i < width; i++) {

            int il = i - 1;
            if (il < 0)
                il = width - 1;

            int ir = i + 1;
            if (ir == width)
                ir = 0;

            int idx = 4 * cells[il] + 2 * cells[i] + cells[ir];

            nextcells[i] = rule[idx];
        }

        memcpy(cells, nextcells, width);
    }

    for (i = 0; i < width; i++)
        putstr("=");

    putstr(".\r\n");

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
void main (void){

char buf[16];
    
    putstr("\r\nWolfram Cell Automaton 1.0 by ARMCoder - 2025\r\n");

    for (;;){

        putstr("\r\nEnter rule (0-255):");
        lgets(buf, sizeof(buf));
        int rule = atoi(buf);
        
        wolfram(50, 20, rule);
    }
}

