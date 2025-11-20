all:			kraftbios-v2.ihx

kraftbios-v2.ihx:	crt0-kraft80-v2.s sysmon.s defines.s
			sdasz80 -o -l -s -g crt0-kraft80-v2.s
			sdasz80 -o -l -s -g sysmon.s
			sdcc -mz80 --no-std-crt0 --code-loc 0x0040 crt0-kraft80-v2.rel sysmon.rel
			mv crt0-kraft80-v2.ihx kraftbios-v2.ihx

clean:
			rm -f *.ihx *.map *.sym *.lk *.rel *.lst *.noi *.asm *.mem *.hex

