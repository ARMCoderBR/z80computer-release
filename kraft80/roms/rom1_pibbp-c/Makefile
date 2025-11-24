all:			crt0-kraft80-v2.ihx

crt0-kraft80-v2.ihx:	pibbp.c crt0-kraft80-v2.s io-kraft80.c io-kraft80.h
			sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 pibbp.c
			sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 io-kraft80.c
			sdasz80 -o -l -s -g crt0-kraft80-v2.s
			sdcc -mz80 --no-std-crt0 -Wl -b_CODE=0x500,-b_DATA=0x2000 crt0-kraft80-v2.rel pibbp.rel io-kraft80.rel
clean:
			rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

