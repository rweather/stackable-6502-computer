
Self-Test
---------

The 32K `selftest.bin` ROM image is intended for boards that are
fitted with a 74LS00 for address decoding, just like the original
[Breadboard 6502 Computer](https://eater.net/6502) from Ben Eater.

The ROM performs a number of tests on the RAM, ROM, and peripherals
to verify correct operation.  It is assumed that four LED's have
been connected to PB0, PB1, PB2, and PB3 on the 65C22 VIA at
address 0x6000 in the memory map.

The tests begin by blinking all four LED's together three times.
Then it runs each of the tests, displaying the test number on the
LED's as it goes:

1. Test that the stack between `$0100` and `$01FF` appears to work.
2. Test that the zero page between `$0000` and `$00FF` appears to work.
3. Write test values to all of RAM (except the stack and zero page).
4. Read the test values back from RAM and verify them.
5. Test that the BRK instruction will generate a BREAK interrupt.
6. Test that timer interrupts can be generated from the 65C22 VIA.
7. Beep the piezobuzzer on PB7 for 100ms with a 1kHz square wave.
8. Test that code can be executed from all addresses in ROM.

If a test fails, the number of the test that failed is displayed on the
LED's and testing stops.  If all tests pass, then a Knight Rider style
LED chase will be done to indicate success.

If you have a 65C51 ACIA connected at address 0x5000 in the memory map,
then you can connect a serial terminal program at 19200 N-8-1 to
see additional messages.  If you see messages like "Self test started!"
and "Stack check: Running", then you know that serial transmit on
the ACIA is working.

At the end of the tests, you can type characters at the serial terminal
and they should be echo'ed back to you.  This tells you that serial
receive on the ACIA is working.

There are many things that are not yet tested, but the above tests
should give a pretty good indication if the board is wired up properly.

The source code for the self test is under `src/selftest` in the
repository.

Music Examples
--------------

The ROM images `happy_birthday.bin` and `merry_christmas.bin` play
music on a piezobuzzer between PB7 and ground.  This uses the
square wave output feature on the 65C22 VIA.
