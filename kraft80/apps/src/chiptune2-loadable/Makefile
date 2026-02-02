all:					chiptune2.bin vgm

chiptune2.bin:			chiptune2.s challenger.s
						sdasz80 -o -l -s -g chiptune2.s
						sdcc -mz80 --no-std-crt0 --code-loc 0x4200 chiptune2.rel
						objcopy --input-target=ihex --output-target=binary chiptune2.ihx chiptune2.bin

vgm:					vgm.c
						gcc -c vgm.c
						gcc -o vgm vgm.o

clean:
						rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex *.bin *.o vgm

