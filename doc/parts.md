
Parts List for the Stackable 6502 Computer
==========================================

Base Board
----------

* PCB; see the `gerber/BaseBoard` directory for the 4-layer Gerbers.
* Integrated Circuits:
  * 1 x W65C02SxP microprocessor
  * 1 x W65C22NxP Versatile Interface Adapter (VIA)
  * 1 x 62256 32 kByte static RAM
  * 1 x 28C256 23 kByte EEPROM
  * 1 x 74LS00 NAND gate (not needed if using the ATF22V10C)
  * 1 x ATF22V10C Programmable Logic Device (optional)
  * 1 x LM7805 5V voltage regulator (TO-220 package)
  * 1 x L78L33 3.3V voltage regulator (TO-92 package) (optional, 3.3V supply only)
* IC Sockets:
  * 2 x 40-pin wide DIP sockets (15.24mm width) (for W65C02SxP and W65C22NxP)
  * 1 x 14-pin narrow DIP socket (7.62mm width) (for 74LS00)
  * 1 x 28-pin wide DIP socket (15.24mm width) (for 62256)
  * 1 x 24-pin narrow DIP socket (7.62mm width) (optional, needed for ATF22V10C)
  * 1 x 28-pin ZIF socket (for 28C256, or use an ordinary 28-pin wide DIP socket instead)
* Resistors:
  * 1 x 220R resistor
  * 1 x 1K resistor
  * 2 x 3.3K resistor
  * 2 x 10K resistor
* Capacitors:
  * 9 x 100nF ceramic or monolithic capacitor
  * 1 x 330nF ceramic or monolithic capacitor (220nF is sufficient in a pinch)
  * 1 x 47uF electrolytic capacitor, 16V rating or better
* Diodes and LED's:
  * 2 x Schottky diodes, 1N5189, SB140, or equivalent
  * 1 x 5mm LED for power indication (red, green, blue, etc - your choice)
* Stackable pin headers, 2.54mm pitch:
  * 2 x 6-pin
  * 1 x 10-pin
  * 1 x 20-pin
  * 2 x 16-pin
* Other:
  * 1 x 1MHz crystal oscillator module in either 14-pin or 8-pin DIP package
  * 1 x pushbutton switch for RESET
  * 1 x SPDT slider switch for power (can be mounted off-board)
  * 1 x DC barrel jack
  * 1 x 2-pin 2.54mm header plus jumper if using the 74LS00 and JP1
  * 1 x 9V or 12V DC plug pack / wall wart

I/O Board
---------

* PCB; see the `gerber/IoBoard` directory for the 4-layer Gerbers.
* Integrated Circuits:
  * W65C51NxP Asynchronous Communications Interface Adapter (ACIA)
  * MAX232 RS-232 line driver
  * MCP3208 12-bit SPI ADC (optional, only needed if you need analog inputs)
* IC Sockets:
  * 1 x 28-pin wide DIP socket (15.24mm width) (for W65C51NxP)
  * 2 x 16-pin narrow DIP sockets (7.62mm width) (for MAX232 and MCP3208)
* Resistors:
  * 5 x 1K resistor
  * 1 x 1M resistor
* Capacitors:
  * 2 x 100nF ceramic or monolithic capacitor
  * 1 x 22pF ceramic capacitor
  * 1 x 1uF ceramic or non-polarized capacitor
* Diodes and LED's:
  * 1 x Schottky diode, 1N5189, SB140, or equivalent
  * 5 x 3mm red or green LED's for power indication and digital outputs
* Other:
  * 1 x 1.8432MHz crystal oscillator module in HC49 package
  * 1 x DB9 female right angle connector
  * 2 x 2.54mm 8-pin headers for the SD card interface and analogs
  * 1 x 2.54mm 2-pin header for the PWM connector
  * 2.54mm pin headers or stackable headers for board edges, similar to
    those for the base board.
