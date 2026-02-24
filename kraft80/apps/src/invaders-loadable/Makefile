all:				invaders.bin

invaders.rel:			invaders.s defines.h
				sdasz80 -o -l -s -g invaders.s

graphics.rel:			graphics.s defines.h
				sdasz80 -o -l -s -g graphics.s

inputs.rel:			inputs.s defines.h
				sdasz80 -o -l -s -g inputs.s

timer.rel:			timer.s defines.h
				sdasz80 -o -l -s -g timer.s

font.rel:			font.s defines.h
				sdasz80 -o -l -s -g font.s

sound.rel:			sound.s defines.h
				sdasz80 -o -l -s -g sound.s

invaders.bin:			invaders.rel graphics.rel inputs.rel timer.rel font.rel sound.rel
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 invaders.rel graphics.rel inputs.rel timer.rel font.rel sound.rel
				objcopy --input-target=ihex --output-target=binary invaders.ihx invaders.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

