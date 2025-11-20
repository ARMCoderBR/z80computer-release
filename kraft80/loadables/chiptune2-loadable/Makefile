all:				chiptunes2.bin

chiptunes2.bin:			chiptunes2.s challenger.s
				sdasz80 -o -l -s -g chiptunes2.s
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 chiptunes2.rel
				objcopy --input-target=ihex --output-target=binary chiptunes2.ihx chiptunes2.bin
clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin *.o vgm

