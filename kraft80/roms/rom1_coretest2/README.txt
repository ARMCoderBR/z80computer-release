# Kraft80
# A Z80-based computer for nostalgic enthusiasts
# 2025 - ARMCoder
# Core Test 2 Program

Description
===========

  This is a small program that helps to test the CPU and its associated circuits
  
of the Kraft80 (the minimal 'core').

  
  It makes the LEDs (D3 to D10) to flash in a 'walking pattern' and reads the
  
pushbuttons (SW1 to SW8). For every pressed button, the corresponding LED will

stay lit for as long the button stays pressed.


  Unlike the Core Test 1, this one uses the system RAM and the LCD display.

Interrupts, and the remaining peripherals are not used.


  Finally, this program also makes a basic test on the RAMs, indicating 'OK' or

'ER' for the RAM0 (U9) and the RAM1 (U90). This is not a comprehensive RAM test

by any means, just a very basic sanity.


How to Use
==========

  Just program a 'ROM' chip (EEPROM, EPROM) of up to 8 kbytes with the IHX
  
image, plug it into the BIOS socket (U2) and power up the board.


License
=======

  GPL v2.

