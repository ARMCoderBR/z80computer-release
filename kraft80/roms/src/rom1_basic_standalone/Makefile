all:						rom1-bas32k-standalone.ihx


rom1-bas32k-standalone.ihx:	bas32k-standalone.s
							sdasz80 -o -l -s -g bas32k-standalone.s
							sdcc --verbose -mz80 --no-std-crt0 bas32k-standalone.rel
							mv bas32k-standalone.ihx rom1-bas32k-standalone.ihx
clean:
							rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

