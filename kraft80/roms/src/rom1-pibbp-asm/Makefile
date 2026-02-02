all:					rom1-pibbp-asm.ihx

rom1-pibbp-asm.ihx:		rom1-pibbp-asm.s
						sdasz80 -o -l -s -g rom1-pibbp-asm.s
						sdcc -mz80 --no-std-crt0 rom1-pibbp-asm.rel

clean:
						rm *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

