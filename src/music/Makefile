
VASM = vasm6502_oldstyle

INCLUDES = via.s
MUSIC_SOURCES = play1.s play2.s notes.s

TARGET1 = ../../roms/happy_birthday.bin
TARGET2 = ../../roms/merry_christmas.bin

all: $(TARGET1) $(TARGET2)

$(TARGET1): happy_birthday.s $(MUSIC_SOURCES) $(INCLUDES)
	$(VASM) -quiet -dotdir -Fbin -c02 -o $(TARGET1) happy_birthday.s

$(TARGET2): merry_christmas.s $(MUSIC_SOURCES) $(INCLUDES)
	$(VASM) -quiet -dotdir -Fbin -c02 -o $(TARGET2) merry_christmas.s

clean:
	rm -f $(TARGET1) $(TARGET2)
