all:		amon2.ihx

amon2.ihx:	amon2.s
		sdasz80 -o -l -s -g amon2.s
		sdcc -mz80 --no-std-crt0 amon2.rel

clean:
		rm *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

