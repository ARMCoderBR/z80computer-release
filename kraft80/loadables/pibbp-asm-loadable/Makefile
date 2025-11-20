all:		picalc.bin

picalc.bin:	picalc.s
		sdasz80 -o -l -s -g picalc.s
		#sdcc -mz80 --no-std-crt0 -Wl -b_CODE=0x0000,-b_DATA=0x2000 picalc.rel
		sdcc -mz80 --no-std-crt0 --code-loc 0x4200 picalc.rel
		objcopy --input-target=ihex --output-target=binary picalc.ihx picalc.bin

clean:
		rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin

