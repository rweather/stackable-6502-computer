
Stackable 6502 Computer
=======================

This repository contains schematics, PCB layouts, and other information
for a "stackable" design for a 6502-based computer.  Stackable in the same
way as Arduino boards that have pin headers to attach shields in the
vertical direction.

The CPU, memory, VIA, and address decoding are on the base board with pin
headers to connect to other boards.

Repository Layout
-----------------

* `kicad` - Schematics and PCB layouts in [KiCad format](https://www.kicad.org/).
* `kicad/BaseBoard` - Base board schematic and layout (4-layer).
* `kicad/IoBoard` - I/O board schematic and layout (2-layer).
* `kicad/Library` - Library of common schematic symbols and footprints.
* `schematics` - PDF versions of the schematics.
* `gerber` - Gerber files for all of the boards.
* `pld` - Images for the ATF22V10C PLD to implement various address decoding
  configurations.

Base Board
----------

The 156mm x 82mm base board was based on the design for
[Ben Eater's Breadboard 6502 Computer](https://eater.net/6502) with some
modifications to help with expandability:

* W65C02S or pin-compatible microprocessor.
* 62256 32K x 8 static RAM.
* 28C256 32K x 8 EEPROM, mounted in a 28-pin ZIF socket at the end of the
  base board to give clearance between the socket and daughter boards.
  A regular 28-pin socket can be used instead of the ZIF if you prefer.
* 6522 Versatile Interface Adapter (VIA).
* Address decoding logic using either a 74LS00 quad NAND gate as in Ben Eater's
  original design, or a ATF22V10C programmable logic device (PLD).
* 5V and 3.3V power supplies based on a 9-12V DC input.
* Pin headers to expose power, bus lines, and control lines to the
  attached daughter boards.
* 4-layer PCB with ground and 5V on the two inner layers.

The pin headers are aligned on a strict 2.54mm (0.1 inch) grid to allow
standard 120mm x 80mm stripboard or protoboard to be used when creating
daughter board "shields".

If you want to lay out your own shield PCB, then you can use the
`Stackable6502Shield` symbol and footprint from `kicad/Library`
as a starting point.

I/O Board
---------

The 125 x 82mm I/O board provides the following features:

* RS-232 serial interface using the 6551 ACIA, with RTS handshaking.
* SPI bus interface, connected to the 6522 VIA on the base board.
* SD card interface, connected to the SPI bus interface.
* 8 analog inputs using the MCP3208 12-bit SPI ADC chip.
* "PWM" header for square wave output on PB7 of the 6522 VIA.
  A piezo-buzzer can be connected to the header for making simple sounds.
* Provision for 3mm LED's on PB0..PB3 for indication.

As can be seen, the I/O board is very featureful.  Not all features need
to be fitted at once.  You can customise it for your requirements.

Future Expansion Ideas
----------------------

I'd like to design a memory expansion board with large amounts of
bank-switched RAM.  The ATF22V10C PLD can help with this, redirecting
memory requests away from the standard RAM to the additional banks.

SPI-based NAND or NOR flash chip for long term storage.  The contents of
flash could be loaded into the bank-switched RAM at startup to provide
ROM replacement capabilities.

An interface to an SPI-based Arduino LCD or OLED module may be interesting.

An alternative serial interface using a FTDI chip for serial over USB.

It would be useful to interface to peripherals via USB, particularly a
keyboard and mouse.  It will probably have to use a modern microcontroller
to handle the USB parts because the 6502 isn't fast enough to keep up
with even USB 1.0 (1.5 Mbps).

Address Decoding
----------------

The 74LS00 quad NAND gate on the base board implements the same memory
map as Ben Eater's original design:

* `0x0000 - 0x3FFF` - 16K of static RAM
* `0x4000 - 0x4FFF` - Unused
* `0x5000 - 0x5FFF` - ACIA
* `0x6000 - 0x6FFF` - VIA
* `0x7000 - 0x7FFF` - Do not use due to conflicts between the ACIA and VIA
* `0x8000 - 0xFFFF` - 32K of EEPROM

This arrangement is very wasteful of address space, particularly the
static RAM, but is very simple.  More complex arrangements require more
logic gates.

The ATF22V10C PLD provides greater flexibility in allocating address
ranges.  The PLD can be programmed to allocate the memory map in almost
any way, and to provide additional chip select outputs for devices on
daughter boards.  Addresses can be mapped with 64-byte granularity.

The `pld` directory contains a number of configurations that can be
programmed into the ATF22V10C.  Among these are:

* `standard` - Standard layout for the stackable configuration with all
  I/O in the range `0x7C00 - 0x7FFF`.
* `eater` - Same Ben Eater layout as above.

The standard memory layout is as follows:

* `0x0000 - 0x7BFF` - 31K of static RAM
* `0x7C00 - 0x7F7F` - For I/O devices on daughter boards
* `0x7F80 - 0x7FBF` - ACIA - 64 bytes
* `0x7FC0 - 0x7FFF` - VIA - 64 bytes
* `0x8000 - 0xFFFF` - 32K of EEPROM

This loses only 1K of static RAM instead of 16K.

Contact
-------

For more information on this project, to report bugs, or to suggest
improvements, please contact the author Rhys Weatherley via
[email](mailto:rhys.weatherley@gmail.com).
