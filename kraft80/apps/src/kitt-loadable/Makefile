all:				kitt.bin blinker.bin

kitt.bin:			kitt.s
				sdasz80 -o -l -s -g kitt.s
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 kitt.rel
				objcopy --input-target=ihex --output-target=binary kitt.ihx kitt.bin

blinker.bin:			blinker.s
				sdasz80 -o -l -s -g blinker.s
				sdcc -mz80 --no-std-crt0 --code-loc 0x4200 blinker.rel
				objcopy --input-target=ihex --output-target=binary blinker.ihx blinker.bin

clean:
				rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

