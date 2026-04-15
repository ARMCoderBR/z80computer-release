all:				kraftbios-v2.ihx

spi.rel:			spi.s fat32.h
				sdasz80 -o -l -s -g spi.s

ch376.rel:			ch376.s fat32.h
				sdasz80 -o -l -s -g ch376.s

fat32.rel:			fat32.c *.h
				sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 fat32.c

crt0-kraft80-v2.rel:		crt0-kraft80-v2.s defines.s
				sdasz80 -o -l -s -g crt0-kraft80-v2.s

kraftmon.rel:			kraftmon.s defines.s
				sdasz80 -o -l -s -g kraftmon.s

kraftbios-v2.ihx:		crt0-kraft80-v2.rel kraftmon.rel spi.rel ch376.rel fat32.rel
				sdcc -mz80 --no-std-crt0 --code-loc 0x0040 --data-loc 0xf700 crt0-kraft80-v2.rel kraftmon.rel spi.rel ch376.rel fat32.rel
				mv crt0-kraft80-v2.ihx rom1-kraftmon.ihx

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

