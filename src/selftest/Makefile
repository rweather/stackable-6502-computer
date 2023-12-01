
VASM = vasm6502_oldstyle
VASM_OPTS = -quiet -dotdir -Fbin

TARGET = ../../roms/selftest.bin
SOURCES = selftest.s

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(VASM) $(VASM_OPTS) -o $(TARGET) $(SOURCES)

clean:
	rm -f $(TARGET)
