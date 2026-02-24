all:				mandel.bin

mandel.bin:			mandel.c ../io-kraft80/io-kraft80.h ../io-kraft80/crt0-kraft80-loadable.rel ../io-kraft80/io-kraft80.rel 
				sdcc -c -V --disable-warning 85 -mz80 -I../io-kraft80 --opt-code-size --std-sdcc99 mandel.c
				sdcc -mz80 --code-loc 0x4280 -DUSE_KRAFTMON=0 --no-std-crt0 ../io-kraft80/crt0-kraft80-loadable.rel ../io-kraft80/io-kraft80.rel mandel.rel
				mv crt0-kraft80-loadable.ihx mandel.ihx
				objcopy --input-target=ihex --output-target=binary mandel.ihx mandel.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

