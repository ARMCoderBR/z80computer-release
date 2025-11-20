all:				chiptunes.bin

chiptunes.bin:			chiptunes.s
				sdasz80 -o -l -s -g chiptunes.s
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 chiptunes.rel
				objcopy --input-target=ihex --output-target=binary chiptunes.ihx chiptunes.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

