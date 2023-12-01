#!/usr/bin/python3

# The formula for mapping MIDI note numbers to frequencies is from here:
# https://en.wikipedia.org/wiki/MIDI_tuning_standard

import math;

# Output convenient names for MIDI notes.
names = ['C', 'CS', 'D', 'DS', 'E', 'F', 'FS', 'G', 'GS', 'A', 'AS', 'B'];
num = 12
for octave in range(0, 10):
    for n in names:
        if num < 128:
            full_name = "%s%d" % (n, octave)
            print("NOTE_%-3s = %d" % (full_name, num));
            num = num + 1;
print();

# Output the frequencies of all MIDI notes as a counter value 500000 / f.
# The counter value can be used directly with the 6552 VIA's T1 timer.
print("midi_notes:");
for d in range(128):
    f = math.pow(2, (d - 69) / 12) * 440;
    counter = round(500000 / f);
    if counter >= 65535:
        counter = 0
    print("    .dw %5d ; %3d, %8.2fHz" % (counter, d, f));
    #print(d, f, 1000000 / f);
