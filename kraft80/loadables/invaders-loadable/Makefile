all:				invaders.bin

invaders.bin:			invaders.s graphics.s inputs.s font.s defines.h
				sdasz80 -o -l -s -g invaders.s
				sdasz80 -o -l -s -g graphics.s
				sdasz80 -o -l -s -g inputs.s
				sdasz80 -o -l -s -g timer.s
				sdasz80 -o -l -s -g font.s
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 invaders.rel graphics.rel inputs.rel timer.rel font.rel
				objcopy --input-target=ihex --output-target=binary invaders.ihx invaders.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

