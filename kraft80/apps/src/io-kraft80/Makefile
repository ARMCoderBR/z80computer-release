all:				crt0-kraft80-loadable.rel io-kraft80.rel

crt0-kraft80-loadable.rel:	crt0-kraft80-loadable.s 
				sdasz80 -o -l -s -g crt0-kraft80-loadable.s

io-kraft80.rel:			io-kraft80.c io-kraft80.h
				sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 io-kraft80.c

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

