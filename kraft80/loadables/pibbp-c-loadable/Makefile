all:				pibbp.bin

pibbp.bin:			pibbp.c ../io-kraft80/io-kraft80.h ../io-kraft80/crt0-kraft80-loadable.rel ../io-kraft80/io-kraft80.rel 
				sdcc -c -V --disable-warning 85 -mz80 -I../io-kraft80 --opt-code-size --std-sdcc99 pibbp.c
				sdcc -mz80 --code-loc 0x4280 -DUSE_KRAFTMON=0 --no-std-crt0 ../io-kraft80/crt0-kraft80-loadable.rel ../io-kraft80/io-kraft80.rel pibbp.rel
				mv crt0-kraft80-loadable.ihx pibbp.ihx
				objcopy --input-target=ihex --output-target=binary pibbp.ihx pibbp.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

