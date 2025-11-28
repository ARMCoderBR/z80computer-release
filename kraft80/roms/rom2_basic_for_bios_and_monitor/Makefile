all:		rom2-bas32k.ihx

bas32k.ihx:	bas32k.s
		sdasz80 -o -l -s -g bas32k.s
		sdcc --verbose -mz80 --no-std-crt0 -Wl -b_CODE=0x2000 bas32k.rel

rom2-bas32k.ihx: bas32k.ihx
		../../linux-utils/khex_xlat/Release/khex_xlat -f bas32k.ihx -o rom2-bas32k.ihx

clean:
		rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

