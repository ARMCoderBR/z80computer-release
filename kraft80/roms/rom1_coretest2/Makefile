all:		coretest2.ihx

coretest2.ihx:	coretest2.s
		sdasz80 -o -l -s -g coretest2.s
		sdcc -mz80 --no-std-crt0 coretest2.rel

clean:
		rm *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

