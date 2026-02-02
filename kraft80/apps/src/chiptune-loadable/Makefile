all:					chiptune.bin

chiptune.bin:			chiptune.s
						sdasz80 -o -l -s -g chiptune.s
						sdcc -mz80 --no-std-crt0 --code-loc 0x4200 chiptune.rel
						objcopy --input-target=ihex --output-target=binary chiptune.ihx chiptune.bin

clean:
						rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

