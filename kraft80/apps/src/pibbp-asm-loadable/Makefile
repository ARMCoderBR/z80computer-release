all:					pibbp-asm.bin

pibbp-asm.bin:			pibbp.s
						sdasz80 -o -l -s -g pibbp.s
						sdcc -mz80 --no-std-crt0 --code-loc 0x4200 pibbp.rel
						mv pibbp.ihx pibbp-asm.ihx
						objcopy --input-target=ihex --output-target=binary pibbp-asm.ihx pibbp-asm.bin

clean:
						rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

