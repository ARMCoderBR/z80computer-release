all:				pibbp.bin

pibbp.bin:			crt0-kraft80-loadable.s pibbp.c io-kraft80.c io-kraft80.h
				sdasz80 -o -l -s -g crt0-kraft80-loadable.s
				sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 pibbp.c
				sdcc -c -V --disable-warning 85 -mz80 --opt-code-size --std-sdcc99 io-kraft80.c
				sdcc -mz80 --code-loc 0x3200 --no-std-crt0 -Wl -b_MAIN=0x2100,-b_DATA=0x3800 crt0-kraft80-loadable.rel pibbp.rel io-kraft80.rel
				mv crt0-kraft80-loadable.ihx pibbp.ihx
				objcopy --input-target=ihex --output-target=binary pibbp.ihx pibbp.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

