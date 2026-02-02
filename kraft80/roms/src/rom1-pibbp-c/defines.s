; defines for a standalone ROM app (no monitor, no BASIC)
RAMTOP		.equ 0x10000
STACKTOP	.equ RAMTOP - 0x100
timecount	.equ RAMTOP-2		;0xfffe


