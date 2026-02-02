/***********************************************************
 * KHEX_CHECK
 * By Milton Maldonado Jr.
 */

#include <termios.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <unistd.h>
#include <termios.h>
#include <errno.h>
#include <string.h>
#include <sys/select.h>
#include <stdlib.h>
#include <getopt.h>
#include <ctype.h>

#define VERSION "1.0"

////////////////////////////////////////////////////////////////////////////////
unsigned int parsehex(char *s, int digits){

    unsigned int aux = 0;

    for (int i = 0; i < digits; i++){

        char c = *s;

        if (isalnum(c)){

            if (isdigit(c))
                c -= '0';
            else{
                c &= ~0x20;
                c -= ('A'-10);
            }
        }
        else
            break;
        aux <<= 4;
        aux += c;
        s++;
    }

    return aux;
}

////////////////////////////////////////////////////////////////////////////////
unsigned int parsehex8(char *s){

    return parsehex(s,2);
}

////////////////////////////////////////////////////////////////////////////////
unsigned int parsehex16(char *s){

    return parsehex(s,4);
}

////////////////////////////////////////////////////////////////////////////////
int xlat_hexfile(char *infile, char *outfile, int memsize){

    int areabase = 8192;

    int res = 0;

    char *mem = malloc(memsize);
    if (!mem){

        return -2;
    }

    memset(mem,0,memsize);

    char buf[255];

    FILE *f = fopen (infile,"r");
    if (!f){
        res = -1;
        goto endcheck;
    }

    FILE *fo = fopen (outfile,"w");
    if (!fo){
        res = -1;
        goto endcheck1;
    }


    int overflow = 0;
    int maxsize = 0;

    while (!feof(f)){

        char *res = fgets (buf, sizeof(buf),f);

        if (res){

            int type = parsehex8(buf+7);
            int addr = parsehex16(buf+3);
            int size = parsehex8(buf+1);

            printf("size:%2x addr:%04x type:%02x - %s",size,addr,type,buf);

            if (type == 0){ // data

                if (addr < areabase){

                    printf("Mem Underflow!\n");
                    overflow = 1;
                    goto error;
                }

                addr -= areabase;

                for (int i = 0; i < size; i++){

                    if ((addr + i) > maxsize)
                        maxsize = addr+i;

                    if (addr + i >= memsize){
                        printf("Mem Overflow!\n");
                        overflow = 1;
                    }
                    else{
                        if (mem[addr+i]){
                            printf("Mem Overlap!\n");
                        }
                        mem[addr+i]++;
                    }
                }
            }
        }
    }

error:
    printf("\n\nMem map:\n");
    printf("    +");
    for (int j = 0; j < 64; j++) printf("-");
    printf("+\n");

    int count = 0;
    int overlap = 0;

    for (int i = 0; i < memsize; i+= 64){

        printf("%04x|",i);
        for (int j = 0; j < 64; j++){

            switch (mem[i+j]){
            case 0:
                printf(" ");
                break;
            case 1:
                printf(".");
                count++;
                break;
            default:
                printf("V");
                count++;
                overlap++;
                break;
            }
        }
        printf("|\n");
    }
    printf("    +");
    for (int j = 0; j < 64; j++) printf("-");
    printf("+\n");

    if (overflow){
        if (overlap)
            printf("ERROR! Memory overflow, size:%d, some overlap found:%d (count may be incomplete)\n",maxsize,overlap);
        else
            printf("ERROR! Memory overflow, size:%d\n",maxsize);
    }else{
        if (overlap)
            printf("ERROR! Used:%d, overlapped:%d!\n",count,overlap);
        else
            printf("Used:%d from %d (~%d%%), top addr:0x%04x\n",count,memsize,(100*count/memsize),maxsize);
    }

    if (!(overflow|overlap)){

        fseek(f,0,SEEK_SET);

        while (!feof(f)){

            char *res = fgets (buf, sizeof(buf),f);

            if (res){

                int type = parsehex8(buf+7);
                int addr = parsehex16(buf+3);
                int size = parsehex8(buf+1);

                if (type == 0)
                    addr -= areabase;
                else
                    size = 0;

                fprintf(fo,":%02x%04x%02x",size,addr,type);

                int ofs = 9;
                int checksum = type + size + (addr & 0xff) + (addr >> 8);
                for (int i = 0; i < size; i++){

                    int data = parsehex8(buf+ofs);
                    checksum += data;
                    fprintf(fo,"%02x",data);
                    ofs += 2;
                }
                checksum ^= 0xFF; checksum++; checksum &= 0xFF;
                fprintf(fo,"%02x\n",checksum);
            }
        }
    }

    fclose (fo);

endcheck1:
    fclose (f);

endcheck:
    free(mem);
    return res;
}

////////////////////////////////////////////////////////////////////////////////
typedef enum {

    COD_PRM_INFILE=101,
    COD_PRM_OUTFILE=102,
    COD_CMD_VERSION=1,
    COD_CMD_HELP=3,
} cod_option;

struct option longopts[] = {
    {
        "f",                    //const char *name;
        required_argument,      //int         has_arg;
        0,                      //int        *flag;
        COD_PRM_INFILE,         //int         val;
    },
    {
        "o",                    //const char *name;
        required_argument,      //int         has_arg;
        0,                      //int        *flag;
        COD_PRM_OUTFILE,        //int         val;
    },
    {
        "v",                    //const char *name;
        0,                      //int         has_arg;
        0,                      //int        *flag;
        COD_CMD_VERSION,        //int         val;
    },
    {
        "h",                    //const char *name;
        0,                      //int         has_arg;
        0,                      //int        *flag;
        COD_CMD_HELP,           //int         val;
    },
    {
        "help",                 //const char *name;
        0,                      //int         has_arg;
        0,                      //int        *flag;
        COD_CMD_HELP,           //int         val;
    },
    {
        0,                      //const char *name;
        0,                      //int         has_arg;
        0,                      //int        *flag;
        0,                      //int         val;
    }
};

////////////////////////////////////////////////////////////////////////////////
int main(int argc, char *argv[]) {

    int res;
    int longindex;
    char infile[200]="";
    char outfile[200]="";
    int cmd = 0;
    int memsize = 8192;

    for (;;){

        res = getopt_long_only(argc, argv, "", longopts, &longindex);

        if ((res == -1) || (res == 63))
            break;

        //printf("res:%d longindex:%d\n",res,longindex);
        int val = longopts[longindex].val;

        if ((cmd)&&(val<100)){

            perror("Use only one option!\n");
            exit(-1);
        }

        if (val < 100)
            cmd = val;

        switch (val){

        case COD_PRM_INFILE:
            if (optarg)
                strncpy(infile,optarg,sizeof(infile)-1);
            break;

        case COD_PRM_OUTFILE:
            if (optarg)
                strncpy(outfile,optarg,sizeof(infile)-1);
            break;

        case COD_CMD_VERSION:
            printf("Version:%s\n",VERSION);
            exit(0);
        }
    }

    if (!infile[0])
        cmd = COD_CMD_HELP;

    if (!outfile[0])
        cmd = COD_CMD_HELP;

    if (cmd == COD_CMD_HELP){

        printf("khex_check by ARMCoder\n");
        printf("Usage:\n");
        printf(" khex_xlat -v\n");
        printf(" khex_xlat -f <filename> -o filename\n");
        exit(0);
    }

    printf("infile:%s outfile:%s memsize:%d\n",infile, outfile, memsize);

    res = xlat_hexfile(infile,outfile,memsize);

    ////////////////////////////////////////////////////////////////////////////

    return res;
}
