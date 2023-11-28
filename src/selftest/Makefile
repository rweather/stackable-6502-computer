
VASM = vasm6502_oldstyle
VASM_OPTS = -quiet -dotdir -Fbin

TARGET = ../../roms/selftest.bin
SOURCES = selftest.s
LIST = selftest.lst

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(VASM) $(VASM_OPTS) -L $(LIST) -o $(TARGET) $(SOURCES)

clean:
	rm -f *.bin *.lst
