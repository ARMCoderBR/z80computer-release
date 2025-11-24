all:		coretest1.ihx

coretest1.ihx:	coretest1.s
		sdasz80 -o -l -s -g coretest1.s
		sdcc -mz80 --no-std-crt0 coretest1.rel

clean:
		rm *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

