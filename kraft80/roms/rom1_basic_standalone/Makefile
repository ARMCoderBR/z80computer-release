all:		bas32k.ihx

bas32k.ihx:	bas32k.s
		sdasz80 -o -l -s -g bas32k.s
		#sdcc -mz80 --no-std-crt0 -Wl -b_CODE=0x0000,-b_DATA=0x2000 picalc.rel
		sdcc --verbose -mz80 --no-std-crt0 bas32k.rel

clean:
		rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

