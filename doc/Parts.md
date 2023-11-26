
Parts List for the Stackable 6502 Computer
==========================================

There is no kit that you can buy yet for this design, but if you have
already built or plan to build [Ben Eater's Breadboard 6502 Computer](https://eater.net/6502), then most of the components can be gotten from his kits.
Build the breadboard version first, following his
[instructions on YouTube](https://www.youtube.com/playlist?list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH).
Then solder up a permanent one using the same parts plus a few extras!

You will need at least the basic "6502 Computer Kit", the
"6502 Serial Interface Kit", and of course an "EEPROM Programmer".
I have marked the parts that you can get from Ben's kits with (BE) below.

If you are a supplier of hobbyist kits or know a reputable supplier and
want to make up a kit based on my design, then contact me via
[email](mailto:rhys.weatherley@gmail.com).  The basic design is licensed
under the [Attribution-NonCommercial-ShareAlike 4.0 International](http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1) license,
but I will be happy to relax that for a cut of the kit purchase price.

Base Board
----------

* PCB; see the `gerber/BaseBoard` directory for the 4-layer Gerbers.
* Integrated Circuits:
  * 1 x W65C02SxP microprocessor, 40-pin DIP (BE)
  * 1 x W65C22NxP Versatile Interface Adapter, 40-pin DIP (VIA) (BE)
  * 1 x 62256 32 kByte static RAM, 28-pin DIP (BE)
  * 1 x 28C256 32 kByte EEPROM, 28-pin DIP (BE)
  * 1 x 74LS00 or 74HC00 NAND gate (not needed if using the ATF22V10C-7PX), 14-pin DIP (BE)
  * 1 x ATF22V10C-7PX Programmable Logic Device, 24-pin DIP (optional)
  * 1 x LM7805 5V voltage regulator (TO-220 package)
  * 1 x L78L33 3.3V voltage regulator (TO-92 package) (optional, 3.3V supply only)
* IC Sockets:
  * 2 x 40-pin wide DIP sockets (15.24mm width) (for W65C02SxP and W65C22NxP)
  * 1 x 14-pin narrow DIP socket (7.62mm width) (for 74LS00)
  * 1 x 28-pin wide DIP socket (15.24mm width) (for 62256)
  * 1 x 24-pin narrow DIP socket (7.62mm width) (for ATF22V10C-7PX)
  * 1 x 28-pin ZIF socket (for 28C256, or use an ordinary 28-pin wide DIP socket instead)
* Resistors:
  * 1 x 220R resistor (BE)
  * 1 x 1K resistor (BE)
  * 2 x 3.3K resistor
  * 2 x 10K resistor
* Capacitors:
  * 9 x 100nF ceramic or monolithic capacitor (BE)
  * 1 x 330nF ceramic or monolithic capacitor (220nF is sufficient in a pinch)
  * 1 x 47uF electrolytic capacitor, 16V rating or better
* Diodes and LED's:
  * 2 x Schottky diodes, 1N5189, SB140, or equivalent
  * 1 x 5mm LED for power indication (red, green, blue, etc - your choice) (BE)
* Stackable pin headers, 2.54mm pitch:
  * 2 x 6-pin
  * 1 x 10-pin
  * 1 x 20-pin
  * 2 x 16-pin
* Other:
  * 1 x 1MHz crystal oscillator module in either 14-pin or 8-pin DIP package (BE)
  * 1 x pushbutton switch for RESET
  * 1 x SPDT slider switch for power (can be mounted off-board)
  * 1 x DC barrel jack
  * 1 x 2-pin 2.54mm header plus jumper if using the 74LS00 and JP1
  * 1 x 9V or 12V DC plug pack / wall wart

I/O Board
---------

* PCB; see the `gerber/IoBoard` directory for the 4-layer Gerbers.
* Integrated Circuits:
  * W65C51NxP Asynchronous Communications Interface Adapter (ACIA), 28-pin DIP (BE)
  * MAX232 RS-232 line driver, 16-pin DIP (BE)
  * MCP3208 12-bit SPI ADC, 16-pin DIP (optional, only needed if you need analog inputs)
* IC Sockets:
  * 1 x 28-pin wide DIP socket (15.24mm width) (for W65C51NxP)
  * 2 x 16-pin narrow DIP sockets (7.62mm width) (for MAX232 and MCP3208)
* Resistors:
  * 5 x 220R resistor (BE)
  * 1 x 1M resistor
* Capacitors:
  * 2 x 100nF ceramic or monolithic capacitor (BE)
  * 1 x 22pF ceramic capacitor (20pF or 30pF will also work) (BE)
  * 1 x 1uF ceramic or non-polarized capacitor (BE)
* Diodes and LED's:
  * 1 x Schottky diode, 1N5189, SB140, or equivalent
  * 5 x 3mm red or green LED's for power indication and digital outputs (5mm will also work - BE)
* Stackable pin headers, 2.54mm pitch:
  * 2 x 6-pin
  * 1 x 10-pin
  * 1 x 20-pin
  * 2 x 16-pin
* Other:
  * 1 x 1.8432MHz crystal oscillator module in HC49 package (BE)
  * 1 x DB9 female right angle connector
  * 2 x 2.54mm low height 8-pin headers for the SD card interface and analogs
  * 1 x 2.54mm low height 2-pin header for the PWM connector
