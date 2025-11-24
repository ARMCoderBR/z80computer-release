# Kraft80
# A Z80-based computer for nostalgic enthusiasts
# 2025 - ARMCoder
# Core Test 1 Program

Description
===========

  This is a very minimal program that helps to test the CPU and its associated
  
circuits of the Kraft80 (the minimal 'core').

  
  It makes the LEDs (D3 to D10) to flash in a 'walking pattern' and reads the
  
pushbuttons (SW1 to SW8). For every pressed button, the corresponding LED will

stay lit for as long the button stays pressed.


  No RAM is used, nor interrupts, nor the LCD display, nor any other peripheral.


How to Use
==========

  Just program a 'ROM' chip (EEPROM, EPROM) of up to 8 kbytes with the IHX
  
image, plug it into the BIOS socket (U2) and power up the board.


License
=======

  GPL v2.

