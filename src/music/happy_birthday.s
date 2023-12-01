
    .include play1.s

; Melody data: https://github.com/robsoncouto/arduino-songs/blob/master/happybirthday/happybirthday.ino
; Original score: https://musescore.com/user/8221/scores/26906

song:
    .db NOTE_C4, DUR_Q,  NOTE_C4, DUR_E,  NOTE_D4, DUR_QD
    .db NOTE_C4, DUR_QD, NOTE_F4, DUR_QD, NOTE_E4, DUR_HD
    .db NOTE_C4, DUR_Q,  NOTE_C4, DUR_E,  NOTE_D4, DUR_QD
    .db NOTE_C4, DUR_QD, NOTE_G4, DUR_QD, NOTE_F4, DUR_HD
    .db NOTE_C4, DUR_Q,  NOTE_C4, DUR_E,  NOTE_C5, DUR_QD
    .db NOTE_A4, DUR_QD, NOTE_F4, DUR_QD, NOTE_E4, DUR_QD
    .db NOTE_D4, DUR_QD, NOTE_AS4, DUR_Q, NOTE_AS4, DUR_E
    .db NOTE_A4, DUR_QD, NOTE_F4, DUR_QD, NOTE_G4, DUR_QD
    .db NOTE_F4, DUR_HD, 0

    .include play2.s
