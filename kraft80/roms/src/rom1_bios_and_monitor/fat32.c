/*
 * main.c
 *
 *  Created on: 7 de abr. de 2026
 *      Author: milton
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "fat32.h"

#define SECSIZE 512

#define DUMP 0
#define DEBUG 0

fatfs_t fatdata;
#define bufdata fatdata.handler[0].bufsector //char bufdata[MAXSECSIZE];

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
void putstr(char *s){

    while(*s){
        putchar(*(s++));
    }
}

////////////////////////////////////////////////////////////////////////////////
void putcrlf(void){

    putstr("\r\n");
}

////////////////////////////////////////////////////////////////////////////////
void printdec(uint32_t x, int8_t nplaces){   //1.000.000.000

    uint32_t dividec = 1000000000;
    uint8_t leadzero=0;
    int8_t places = 9;
    
    for (;dividec;){
        
        if (!leadzero){
            if ((dividec == 1) || (x >= dividec) || (places < nplaces))
                leadzero = 1;
        }

        if (leadzero){
            
            putchar('0'+ (x / dividec));

            x %= dividec;
        }

        dividec /= 10;
        --places;
    }
}

////////////////////////////////////////////////////////////////////////////////
void printAscii(uint8_t *buf, uint8_t n){

    for (uint8_t i = 0; i < n; i++)
        putchar(buf[i]);
}

const char dhex[]="0123456789ABCDEF";
////////////////////////////////////////////////////////////////////////////////
void printhex8(uint8_t b){

    putchar(dhex[b>>4]);
    putchar(dhex[b&0x0F]);
}

#if DEBUG
////////////////////////////////////////////////////////////////////////////////
void printhex16(uint16_t w){

    printhex8(w>>8);
    printhex8(w&0xFF);
}

////////////////////////////////////////////////////////////////////////////////
void printhex32(uint32_t dw){

    printhex16(dw>>16);
    printhex16(dw&0xFFFF);
}
#endif

////////////////////////////////////////////////////////////////////////////////
#if DUMP
void dumpBuf (uint8_t *buf, int size){

    putstr("\r\n      00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F\r\n");
    putstr("      -----------------------------------------------");
    for (uint8_t i = 0; i < size; i++){

        if (!(i % 16)){
            putcrlf();    
            printhex16(i);
            putstr(": ");
	}
        printhex8(buf[i]);
	putchar(' ');
    }
    putcrlf();
}
#endif

////////////////////////////////////////////////////////////////////////////////
#if DUMP
void dumpSector (uint8_t *buf){

    dumpBuf (buf, SECSIZE);
}
#endif

////////////////////////////////////////////////////////////////////////////////
uint16_t get16(uint8_t *buf){

    uint16_t w = *(buf+1); w <<= 8; w |= *buf;
    return w;
}

////////////////////////////////////////////////////////////////////////////////
uint32_t get32(uint8_t *buf){

    uint32_t w = get16(buf+2); w <<= 16; w |= get16(buf);
    return w;
}

////////////////////////////////////////////////////////////////////////////////
extern uint32_t ch376_secnum;
extern uint8_t *ch376_nextread;
extern uint8_t ch376_result;
void ch376_read_sector(void);

////////////////////////////////////////////////////////////////////////////////
int readSector(uint8_t *sector_buf, uint32_t sector_num){

#if DEBUG
    putstr("READ SECTOR:");
    printdec(sector_num,0);
    putcrlf();
#endif

    ch376_secnum = sector_num;
    ch376_nextread = sector_buf;
    ch376_read_sector();

    int res = ch376_result;

    if (!res)
	res = SECSIZE;
    else
	res = -1;

    return res;
}

////////////////////////////////////////////////////////////////////////////////
int getMBRSector (void){

#if DEBUG
    putstr("\r\nRead MBR SECTOR\r\n");
#endif

    int res = readSector(bufdata, 0);
    if (res != SECSIZE){
        return -1;
    }

#if DUMP
    dumpSector(bufdata);
#endif

    if ( (bufdata[SECSIZE-2] != 0x55) || (bufdata[SECSIZE-1] != 0xAA)) {

#if DEBUG
        putstr("MBR sector w/o final signature.\r\n");
#endif
        return -1;
    }

    uint16_t ofs = 0x1be;
    for (uint8_t i = 0; i < 4; i++){

        primary_partition_t *pp = (void*)&bufdata[ofs];
#if DEBUG
        putstr("PART #");
        printdec (i,0);
        putstr("  TYPE:");
        printhex8 (pp->type);
        putstr("  STARTSEC:");
        printhex32 (pp->startSector);
        putstr("  SIZESEC:");
        printhex32 (pp->numberOfSectors);
        putcrlf();
#endif
        if (pp->type == 0x0C){	// FAT32

            fatdata.partitionLogicalSector = pp->startSector;
            return 0;
        }
        ofs += 16;
    }

    return -1;
}

////////////////////////////////////////////////////////////////////////////////
int getBootSector (void){

#if DEBUG
    putstr("\r\nRead BOOT SECTOR\r\n");
#endif

    int res = readSector(bufdata, fatdata.partitionLogicalSector);
    if (res != SECSIZE){
        return -1;
    }

#if DUMP
    dumpSector(buf);
#endif

    if ( (bufdata[SECSIZE-2] != 0x55) || (bufdata[SECSIZE-1] != 0xAA)) {

#if DEBUG
        putstr("Boot sector w/o final signature.\r\n");
#endif
        return -1;
    }

    if (get16(bufdata+0x16)){

#if DEBUG
        putstr("Not a FAT32 system.\r\n");
#endif
        return -1;
    }

    if (memcmp(bufdata+0x52,"FAT32   ",8)){

#if DEBUG
        putstr("FAT32 signature not found.\r\n");
#endif
        return -1;
    }

#if DEBUG
    putcrlf();
    putstr("OEM NAME:");
    printAscii(buf+3,8);
    putstr("\r\n=== DOS 2.0 BPB ===\r\n");
#endif

    fatdata.bytesPerSector = get16(bufdata+0x0b);
    fatdata.sectorsPerCluster = bufdata[0x0d];
    fatdata.reservedSectors = get16(bufdata+0x0e);
    fatdata.numberOfFATs = bufdata[0x10];
    fatdata.rootDirEntries = get16(bufdata+0x11);
    fatdata.logicalSectorsPerFat = get32(bufdata+0x24);
    fatdata.rootDir1stCluster = get32(bufdata+0x2C);
    fatdata.fsInfoLogicalSector = get16(bufdata+0x30);
    fatdata.logicalSectorBootAreaCopy = get16(bufdata+0x32);
    fatdata.totalLogicalSectors = get32(bufdata+0x20);

#if DEBUG1
    printf("Bytes per Sector:%d\n",fat->bytesPerSector);
    printf("Sectors per Cluster:%d\n",fat->sectorsPerCluster);
    printf("Reserved Logical Sectors:%d\n",fat->reservedSectors);
    printf("Number of FATs:%d\n",fat->numberOfFATs);
    printf("Entries in Root Dir (N/A in FAT32):%d\n",fat->rootDirEntries);
    printf("Total Logical Sectors (N/A in FAT32):%d\n",get16(buf+0x13));
    printf("Media Descriptor:0x%02x\n",buf[0x15]);
    printf("Logical Sectors / FAT (N/A in FAT32):%d\n",get16(buf+0x16));
    printf("=== DOS 3.0 BPB ===\n");
    printf("CHS # of Sectors:%d\n",get16(buf+0x18));
    printf("CHS # of Heads:%d\n",get16(buf+0x1A));
    printf("Hidden Sectors (beware):%d\n",get16(buf+0x1C));
    printf("=== DOS 3.2 BPB ===\n");
    printf("Total (+Hidden) Sectors (beware):%d\n",get16(buf+0x1E));
    printf("=== DOS 3.31 BPB ===\n");
    printf("Total (+Hidden) Sectors (beware):%d\n",get32(buf+0x1C));
    printf("Total Logical Sectors (if >65535):%d\n",fat->totalLogicalSectors);
    printf("=== FAT32 EBPB ===\n");
    printf("Logical Sectors / FAT:%d\n",fat->logicalSectorsPerFat);
    printf("Drive Description:%04x\n",get16(buf+0x28));
    printf("Version:%04x\n",get16(buf+0x2A));
    printf("Root Dir 1st Cluster:%d\n",fat->rootDir1stCluster);
    printf("FS Info Logical Sector:%d\n",fat->fsInfoLogicalSector);
    printf("1st Logical Sector of Boot Area Copy:%d\n",fat->logicalSectorBootAreaCopy);
    putstr("FS Type:");
    printAscii(buf+0x52,8);
    printf("\n");
#endif

    int rootDirBytes = 32*fatdata.rootDirEntries;
    int rootDirSectors = rootDirBytes / fatdata.bytesPerSector;
    if ((rootDirSectors * fatdata.bytesPerSector) < rootDirBytes)
        rootDirSectors++;

    fatdata.rootDirSectors = rootDirSectors;
    fatdata.ssaIndex = fatdata.reservedSectors + fatdata.numberOfFATs*fatdata.logicalSectorsPerFat + rootDirSectors;

#if DEBUG
    printf("SSA Index:%d  RootDirSectors:%d\n",fatdata.ssaIndex,fatdata.rootDirSectors);
#endif

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
int getFsiSector (void){

#if DEBUG
    putstr("\r\nRead FS INFO SECTOR\r\n");
#endif

    int res = readSector(bufdata, fatdata.partitionLogicalSector + fatdata.fsInfoLogicalSector);
    if (res != SECSIZE){
        return -1;
    }

#if DUMP
    dumpSector(buf);
#endif

    if (memcmp(bufdata,"RRaA",4)||memcmp(bufdata+0x1e4,"rrAa",4)||memcmp(bufdata+0x1fc,"\x00\x00\x55\xAA",4)){
#if DEBUG
        putstr("FS Info signature not found.\r\n");
#endif
        return -1;
    }

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
void getNextCluster(handler_t *fh){

    uint32_t sector = fatdata.partitionLogicalSector + fatdata.reservedSectors + (fh->currentCluster * 4) / fatdata.bytesPerSector;
    readSector(fh->bufsector, sector);

    uint16_t offset = (fh->currentCluster * 4) % fatdata.bytesPerSector;

#if DEBUG
    printf("Current cluster(before):%08x\n",fh->currentCluster);
#endif

    fh->currentCluster = get32(fh->bufsector + offset);
    if (fh->currentCluster >= 0x0ffffff0)
        fh->eof = 1;

#if DEBUG
    printf("Current cluster(after):%08x\n",fh->currentCluster);
#endif
}

////////////////////////////////////////////////////////////////////////////////
uint32_t getSectorFromCluster (uint32_t cluster){

    return (cluster-2) * fatdata.sectorsPerCluster + fatdata.ssaIndex;
}

////////////////////////////////////////////////////////////////////////////////
int8_t openHandler(uint32_t start_cluster, uint16_t strlo, uint16_t strhi){

    uint32_t streamSize = strhi; streamSize <<= 16; streamSize |= strlo;
#if DEBUG
    putstr("Open Handler\r\nstreamSize:");
    printhex32(streamSize); putcrlf();
#endif

    if (start_cluster < fatdata.rootDir1stCluster)
        return -1;  // Invalid cluster

    for (uint8_t i = 0; i < MAXHANDLER; i++)
        if (!fatdata.handler[i].inUse){

            fatdata.handler[i].inUse = 1;
            fatdata.handler[i].currentCluster = start_cluster;
            fatdata.handler[i].currentByteInSector = fatdata.bytesPerSector;
            fatdata.handler[i].currentSectorInCluster = 0;
            fatdata.handler[i].currentLogicalSector = getSectorFromCluster(start_cluster);
            fatdata.handler[i].eof = 0;
            fatdata.handler[i].streamSize = streamSize;
            fatdata.handler[i].streamPtr = 0;
            return 1+i;
        }

    return -2;   //No handler left
}

////////////////////////////////////////////////////////////////////////////////
uint32_t readHandler (uint8_t *readbuf, uint8_t handler, uint32_t nbytesToRead){

#if DEBUG
    putstr("=== READHANDLER(1)\r\n");
    printhex32(nbytesToRead);
    putcrlf();
#endif
    
    if (!handler) return -1;
    
    if (handler > MAXHANDLER) return -1;

    handler--;

    handler_t *fh = &fatdata.handler[handler];

    if (!fh->inUse) return -2;

    if (!nbytesToRead) return 0;

    uint32_t bytesread = 0;

    uint32_t nbytes = nbytesToRead;

#if DEBUG
    putstr("=== READHANDLER(2)\n");
#endif

    while (nbytes && (!fh->eof)){

        uint32_t qty = nbytes;
        uint32_t rembytesInSector = fatdata.bytesPerSector - fh->currentByteInSector;
        uint32_t rembytesInFile = fh->streamSize - fh->streamPtr;

        if (!rembytesInFile){

            fh->eof = 1;
            continue;
        }

        if (!rembytesInSector){

redo:
#if DEBUG
            //printf("\r\n\n=== READHANDLER - NEXT SECTOR(%d)\r\n",fh->currentSectorInCluster);
		putstr("\r\n\n=== READHANDLER - NEXT SECTOR\r\n\n");
#endif

            if (fh->currentSectorInCluster == fatdata.sectorsPerCluster){
                fh->currentSectorInCluster = 0;
                getNextCluster(fh);
                fh->currentLogicalSector = getSectorFromCluster(fh->currentCluster);

#if DEBUG
                putstr("\r\nNEXT CLUSTER - redo\r\n");
#endif
                goto redo;
            }

#if DEBUG
            putstr("READH ");
            printhex32(fatdata.partitionLogicalSector);
            putstr(" + ");
            printhex32(fh->currentLogicalSector);
            putcrlf();
#endif

            /*int res =*/ readSector(fh->bufsector, fatdata.partitionLogicalSector + fh->currentLogicalSector);

            fh->currentByteInSector = 0;
            fh->currentSectorInCluster++;
            fh->currentLogicalSector++;

            rembytesInSector = fatdata.bytesPerSector;
        }

	//putstr(">>>>>");
	//printhex32(nbytes);
	//putstr(">>>>>");
	//printhex32(qty);
	//putcrlf();

        if (qty > rembytesInFile)
            qty = rembytesInFile;

        if (qty > rembytesInSector)
            qty = rembytesInSector;

	//putstr("\r\nMEMCPY TO:");
	//printhex32((uint32_t)(readbuf+bytesread));
	//putstr("  FROM:");
	//printhex32((uint32_t)(fh->bufsector+fh->currentByteInSector));
	//putstr("  SIZE:");
	//printhex32(qty);
	//putcrlf();
        memcpy(readbuf+bytesread, fh->bufsector+fh->currentByteInSector, qty);

        fh->currentByteInSector += qty;
#if DEBUG
        //printf("=== CURBYTEINSECTOR:%d\n",fh->currentByteInSector);
#endif
        nbytes -= qty;
	//putstr("!!!!!!");
	//printhex32(nbytes);
	//putcrlf();
        bytesread += qty;
        fh->streamPtr += qty;
    }

#if DEBUG
    putstr("=== READHANDLER(3)\n");
#endif

    return bytesread;
}

////////////////////////////////////////////////////////////////////////////////
int closeHandler(uint8_t handler){

#if DEBUG
    putstr("\r\nClose Handler\r\n");
#endif

    if (!handler) return -1;
    if (handler > MAXHANDLER) return -1;

    handler--;

    if (fatdata.handler[handler].inUse){

        // TODO: Pending writes go here
        fatdata.handler[handler].inUse = 0;
    }

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
int8_t openRootDir(void){
#if DEBUG
    putstr("OpenRoot\r\n");
#endif

    return openHandler(fatdata.rootDir1stCluster,0xFFFF,0xFFFF);
}

////////////////////////////////////////////////////////////////////////////////
void prline(void){

    for (uint8_t i = 0; i < 40; i++)
        putchar('=');

    putcrlf();
}

////////////////////////////////////////////////////////////////////////////////
int listDir(int handler){

    prline();

    int res = 1;

    while (res > 0){

        res = readHandler (fatdata.bufdir, handler, DIRENTRYSIZE);
        if (res){

            direntry_t *d = (void *)&fatdata.bufdir;

            if ((d->fileAttrs & 0x0F) == 0x0F) continue;
            if (!d->fileName[0]) continue;
            if (d->fileName[0] == 0xE5) continue;

            printAscii(d->fileName,8);
            putstr(".");
            printAscii(d->fileExt,3);
            putstr("  ATTRs:0x");
            printhex8(d->fileAttrs);

#if DEBUG
            uint32_t startClu = d->startClusterHi;
            startClu <<= 16; startClu |= d->startClusterlo;
            putstr("  St.Clu:0x");
            printhex32(startClu);
#endif
            putstr("  SZ:");
            printdec(d->fileSize,0);
            putcrlf();
        }
    }

    prline();

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
int check_vchar(uint8_t a){

    if ((a >= 'a') && (a <= 'z'))
        return 1;

    if ((a >= 'A') && (a <= 'Z'))
        return 1;

    if ((a >= '0') && (a <= '9'))
        return 1;

    const uint8_t vchar[] = "!#$%&'()-@^_`{}~.";

    for (int i = 0; i < 17; i++)
        if (a == vchar[i]) return 1;

    return -1;
}

////////////////////////////////////////////////////////////////////////////////
int check_fname(const char *fname, char *resname){

    int len = strlen(fname);

    if ((!len)||(len > 12)) return -1;
    int dotindex = -1;
    //xxxxxxxx.xxx

    for (int i = 0; i < len; i++){

        uint8_t a = fname[i];

        if (a == '.'){
            if (dotindex >= 0)
                return -1;
            else
                dotindex = i;
        }

        if (check_vchar(a) < 0) return -1;
    }

    if ((len > 8) && (dotindex == -1)) return -1;

    if (dotindex > 0)
        if ((len - dotindex) > 4) return -1;

    int j = 0;
    for (int i = 0; i < len; i++){

        uint8_t a = fname[i];

        if ((a >= 'a') && (a <= 'z'))
            a &= ~0x20;

        if (a == '.'){

            while (j < 8)
                resname[j++] = ' ';
            continue;
        }

        resname[j++] = a;
    }

    while (j < 11)
        resname[j++] = ' ';

    resname[j] = 0;

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
int findFileInDir(uint8_t handler, const char *fname){

    char namebuf[14];

    //printf("===>NAME:[%s]\n",fname);

    if (check_fname(fname,namebuf) < 0) return 0;

    //printf("===>RES:[%s]\n",namebuf);

    int res = 1;

    while (res > 0){

        res = readHandler (fatdata.bufdir, handler, DIRENTRYSIZE);
        if (res){

            direntry_t *d = (void *)&fatdata.bufdir;

            if ((d->fileAttrs & 0x0F) == 0x0F) continue;
            if (!d->fileName[0]) continue;
            if (d->fileName[0] == 0xE5) continue;

            if (!memcmp(d->fileName,namebuf,11)){

#if DEBUG
                printAscii(d->fileName,8);
                putstr(".");
                printAscii(d->fileExt,3);
                putstr("FOUND\r\n");
                putstr("  ATTRs:0x");
                printhex8(d->fileAttrs);
#endif
                uint32_t startClu = d->startClusterHi;
                startClu <<= 16; startClu |= d->startClusterlo;
#if DEBUG
                putstr("  St.Clu:0x");
                printhex32(startClu);
                putstr("  SZ:");
                printdec(d->fileSize,0);
                putcrlf();
#endif

                fatdata.fi_fileAttrs = d->fileAttrs;
                fatdata.fi_fileCreateDate = d->fileCreateDate;
                fatdata.fi_fileCreateTime = d->fileCreateTime;
                fatdata.fi_fileModDate = d->fileModDate;
                fatdata.fi_fileModTime = d->fileModTime;
                fatdata.fi_fileSize = d->fileSize;
                fatdata.fi_startCluster = startClu;
                return 1;
            }
        }
    }

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
int8_t dumpFile(uint8_t *bufread, uint8_t handler, int bufsize){

    int res = 1;
    uint8_t *p = (void*)0x4200;

    while (res > 0){

        res = readHandler (bufread, handler, bufsize);
	
        if (res){

            for (int i = 0; i < res; i++){
		*(p++) = bufread[i];
            }
        }
    }

    return 0;
}

////////////////////////////////////////////////////////////////////////////////
void ch376_dumpfile(char *name) __sdcccall(0){

    int8_t nHandler;

    putstr(name);
    putcrlf();

    uint8_t userbuf[DIRENTRYSIZE];

    nHandler = openRootDir();
    if (nHandler > 0){

	int res = findFileInDir(nHandler, name);
        closeHandler(nHandler);

        if (res){
            nHandler = openHandler(fatdata.fi_startCluster, fatdata.fi_fileSize & 0xffff,fatdata.fi_fileSize >> 16);
            if (nHandler > 0){
                dumpFile(userbuf, nHandler, sizeof(userbuf));
                closeHandler(nHandler);
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
int8_t initFatFS(void) {

    memset(&fatdata,0,sizeof(fatfs_t));

    int8_t res = getMBRSector();

    res = getBootSector();
    if (res < 0) goto error;

    res = getFsiSector();

error:
    return res;
}

////////////////////////////////////////////////////////////////////////////////
void ch376_listdir(void) {

    int8_t nHandler = openRootDir();
    if (nHandler > 0){
        listDir(nHandler);
        closeHandler(nHandler);
    }
}

////////////////////////////////////////////////////////////////////////////////
void startfatfs (void){

    ////////////////////////
    putstr ("\r\nFATFS 1.0 Start\r\n");

    int8_t res = initFatFS();
    if (res < 0)
        putstr("Init FS Error\r\n");
    else
        putstr("Init FS OK\r\n");
}

