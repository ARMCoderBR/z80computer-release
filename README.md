# Kraft 80
A Z80-based computer for nostalgic enthusiasts\
©2025 - ARMCoder\
UPDATED 2025 - October 12

<IMG SRC="https://github.com/ARMCoderBR/z80computer-release/blob/main/kraft80/kraft80-1.jpg?raw=true" width=600>


## Q & A

## What is this?

  For starters, this is no more than a hobby project: a Z80-based computer. By no means it aims to be a practical solution to anything, as any modern microcontroller can do much better with lower cost, lower complexity, lower power consumption and much more ease of use. You can eventually make changes on it to perform some practical automation tasks and it WILL work, it's just not recommended nowadays. Get a PIC or Arduino instead.


## Why did I build it?

  I began building a 3rd party kit called "Z80 Alpha" from a company called WR Kits here in Brazil. The kit was a box of parts (minus PCB), a set of manuals and a minimalistic monitor software.

  This was initially intended to be a quick pastime, but in time, I decided to expand the original kit with new features and write new software. See ALPHAPLUS-README.md for the historic background on that kit.


## What is the Kraft 80 computer, then?

It's a homebrew computer in development. This is the first Kraft 80's prototype:

<IMG SRC="https://github.com/ARMCoderBR/z80computer-release/blob/main/kraft80/kraft80-2.jpg?raw=true" width=600>

Then I've already built a first tentative true PCB for it, This one pictured here is the Rev 2.0:

<IMG SRC="https://github.com/ARMCoderBR/z80computer-release/blob/main/kraft80/IMG-20250930-WA0026.jpeg?raw=true" width=600>

There's a newer revision already designed and ordered (not delivered yet). This revision (called 2.2) fixes some mistakes and add some expansion connectors:

<IMG SRC="https://github.com/ARMCoderBR/z80computer-release/blob/main/kraft80/Captura%20de%20tela_2025-10-11_11-37-06.png?raw=true" width=600>
  
Characteristics:
```
  CPU:   Z80A, 4 MHz

  ROM BIOS + Monitor:  8 kbytes
  ROM BASIC: 8 kbytes

  RAM:   16 kbytes (disabled at boot) + 48 kbytes (the lower RAM can be remapped
         over the ROMs, yielding the full 64 kbytes ready for use)

  VIDEO: Text Mode: 48 rows x 80 columns - Monochrome
         Graphics Mode: 320x240 Framebuffer - 16 Color

  KEYBOARD: PS/2 compatible

  SOUND: Mono, compatible with GI AY3-891x (the famous so-called 'PSG' used in MSX computers and others from the 80s)

  TIMER Interrupt: Fixed, 300 Hz

  SERIAL: USB 19200 BPS, 8N1, RTS Flow control (via FTDI - USB chip)

  MICRO SD CARD CONTROLLER: Software still WIP, hardware already tested

  POWER: 5V 1A (via USB, the same of the FTDI above), or a separate Power connector (barrel P4 jack in PCB Rev 2.2)

  EXTRA IOS:
    LCD Alphanumeric 16x2
    8 Pushbuttons
    8 Controllable LEDs
    The Pushbuttons and LEDs also have corresponding expansion headers in PCB Rev 2.2.

```


What can the Kraft 80 currently do?
===================================

  Through its serial port, it can have software downloaded to its RAM. A serial monitor, 'Sysmon' (that runs on the BIOS ROM), is supplied for this purpose.

  Sysmon also has functions to edit and display the RAM contents using the PS/2 keyboard and monitor, or alternatively, through a serial terminal over the Serial 
port in the case you don't have a PS/2 keyboard or a spare VGA monitor.

  BASIC Interpreter: The ROM BASIC is the Microsoft BASIC 4.7b interpreter. There are two ROM images made available: the one that uses the BIOS, so the VGA output and the PS/2 keyboard are functional, and a standalone image that works only over the serial port. For those really nostalgic, there are some nice text-only games written in BASIC at this repository:

                    http://vintage-basic.net/games.html

  Remember that in order to switch ROM programs, the actual ROM chip needs to be replaced (and because of that, a ZIF socket is instrumental to keep the process smooth and safe!). 

  As the VGA controller is the latest addition to the Kraft80, not much software is available for it (yet). Currently, there's a clock demo (written in C) and I'm writing a Space Invaders clone (this one in pure Assembly). I'm planning to find out whether I can integrate graphics function into that BASIC interpreter!


Need more info?
===============

  You will find some other documentation in the project's directories. This part is still WIP, so please be patient and check every few days. New documentation is being added often.
