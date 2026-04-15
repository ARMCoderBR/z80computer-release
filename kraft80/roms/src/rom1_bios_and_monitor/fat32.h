/*
 * fat.h
 *
 *  Created on: 7 de abr. de 2026
 *      Author: milton
 */

#ifndef FAT_H_
#define FAT_H_

#include <stdint.h>

#define DIRENTRYSIZE 32
#define MAXSECSIZE   512
#define MAXHANDLER   4

typedef struct {

    uint8_t dummy[4];
    uint8_t type;
    uint8_t dummy2[3];
    uint32_t startSector;
    uint32_t numberOfSectors;
} primary_partition_t;

typedef struct {

    uint8_t  fileName[8];           //0x00
    uint8_t  fileExt[3];            //0x08
    uint8_t  fileAttrs;             //0x0B
    uint8_t  unused1;               //0x0C
    uint8_t  unused2;               //0x0D
    uint16_t fileCreateTime;        //0x0E
    uint16_t fileCreateDate;        //0x10
    uint16_t unused3;               //0x12
    uint16_t startClusterHi;        //0x14
    uint16_t fileModTime;           //0x16
    uint16_t fileModDate;           //0x18
    uint16_t startClusterlo;        //0x1A
    uint32_t fileSize;              //0x1C
} direntry_t;

#define ATTRS_RO    0x01
#define ATTRS_HID   0x02
#define ATTRS_SYS   0x04
#define ATTRS_VOL   0x08
#define ATTRS_DIR   0x10
#define ATTRS_ARC   0x20
#define ATTRS_DEV   0x40

typedef struct {

    uint32_t currentCluster;
    uint32_t currentLogicalSector;
    uint32_t streamSize;
    uint32_t streamPtr;
    uint16_t currentByteInSector;
    uint8_t  currentSectorInCluster;
    uint8_t  bufsector[MAXSECSIZE];
    uint8_t  inUse;
    uint8_t  eof;
} handler_t;

typedef struct {
    uint32_t  partitionLogicalSector;
    uint32_t  totalLogicalSectors;
    uint32_t  logicalSectorsPerFat;
    uint32_t  rootDir1stCluster;
    uint32_t  ssaIndex;
    uint16_t  bytesPerSector;
    uint16_t  reservedSectors;
    uint16_t  rootDirSectors;
    uint16_t  rootDirEntries;
    uint16_t  fsInfoLogicalSector;
    uint16_t  logicalSectorBootAreaCopy;
    uint8_t   sectorsPerCluster;
    uint8_t   numberOfFATs;

    uint32_t fi_startCluster;
    uint32_t fi_fileSize;
    uint16_t fi_fileCreateTime;
    uint16_t fi_fileCreateDate;
    uint16_t fi_fileModTime;
    uint16_t fi_fileModDate;
    uint8_t  fi_fileAttrs;

    uint8_t bufdir[DIRENTRYSIZE];
    handler_t handler[MAXHANDLER];
} fatfs_t;

#endif /* FAT_H_ */
