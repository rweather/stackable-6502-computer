;
; play2.s - Play music via a piezobuzzer on PB7 (bottom half of the code).
;
; Copyright (C) 2023 Southern Storm Software, Pty Ltd.
;
; Permission is hereby granted, free of charge, to any person obtaining a
; copy of this software and associated documentation files (the "Software"),
; to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
; DEALINGS IN THE SOFTWARE.
;

    .include via.s

T2COUNTMS = 1000        ; Number of T2 ticks for one millisecond.

SYSTICK = $00           ; Location of the system millisecond tick counter.
TIMEBASE = $01          ; Time base for the current delay.
TIMEOUT = $02           ; Current timeout in milliseconds.

start:
;
; Set up T2 in the VIA to interrupt us once a millisecond so
; that we have a time source for measuring delays.
;
    lda     #(VIA_IER_SET | VIA_IER_T2)
    sta     VIA_IER
    lda     #(VIA_ACR_T2_ONE_SHOT | VIA_ACR_SR_SO_PHI2)
    sta     VIA_ACR
    lda     #<T2COUNTMS
    sta     VIA_T2CL
    lda     #>T2COUNTMS
    sta     VIA_T2CH
;
; Set up to output tones on PB7.
;
    lda     VIA_DDRB    ; Convert PB7 to output.
    ora     #%10000000
    sta     VIA_DDRB
    lda     VIA_PORTB   ; And initially set it to low.
    and     #%01111111
    sta     VIA_PORTB
    lda     #(VIA_IER_CLEAR | VIA_IER_T1)
    sta     VIA_IER     ; Turn off T1 interrupts, just in case.
    lda     VIA_T1CL    ; Clears any previous pending interrupt.
    lda     VIA_ACR     ; Disable square wave output on PB7 for now.
    and     #%00111111
    sta     VIA_ACR
;
; Wait for 0.5s before playing the first note.
;
    ldy     #5
    lda     #100
    jsr     delay_ms
;
; Play the musical composition.
;
    ldx     #0
next_note:
    lda     song,x      ; Get the MIDI note number.
    beq     done
    inx
    jsr     tone_on     ; Start generating the tone.
    lda     song,x      ; Get the duration of the tone.
    inx
    ldy     #9          ; 90% of the duration, the tone is on.
    jsr     delay_ms
    jsr     tone_off    ; Stop tone generation.
    ldy     #1          ; 10% of the duration, the tone is off.
    jsr     delay_ms
    jmp     next_note
;
; Finished - go into an infinite loop.  Re-play on next reset.
;
done:
    jmp     done

;
; Delay for A * Y milliseconds.  Preserves A and X.  Destroys Y.
;
delay_ms:
    sta     TIMEOUT
delay_ms_1:
    lda     SYSTICK
    sta     TIMEBASE
delay_ms_2:
    lda     SYSTICK
    sec
    sbc     TIMEBASE
    cmp     TIMEOUT
    blt     delay_ms_2
    dey
    bne     delay_ms_1
    lda     TIMEOUT
    rts

;
; Turn on the tone output.  A is the MIDI note number to play.
; A, X, and Y are preserved.
;
tone_on:
    pha
    phx
    phy
    asl
    tax
    lda     midi_notes,x ; Get the T1 counter value for this note.
    ldy     midi_notes+1,x
    tax
    lda     VIA_ACR     ; Configure T1 for square wave output.
    ora     #VIA_ACR_T1_SQUARE
    sta     VIA_ACR
    stx     VIA_T1CL    ; Set the count-down timer value and start the timer.
    sty     VIA_T1CH
    ply
    plx
    pla
    rts

;
; Turn off the tone output.  A, X, and Y are preserved.
;
tone_off:
    pha
    sei                 ; Stop other things interfering with VIA.
    lda     VIA_ACR     ; Disable square wave output.
    and     #%00111111
    sta     VIA_ACR
    lda     VIA_PORTB   ; Force PB7 to low, just in case.
    and     #%01111111  ; Don't leave it high by accident.
    sta     VIA_PORTB
    cli                 ; Safe for others to use the VIA now.
    pla
    rts

;
; Non-maskable interrupt handler - does nothing.
;
nmi:
    rti

;
; Handle the T2 timer tick interrupt for the millisecond time base.
;
irqbrk:
    pha
    phx
    phy
    lda     VIA_IFR     ; Has the T2 count down expired?
    and     #VIA_IFR_T2
    beq     irqdone
    inc     SYSTICK     ; Increment the system tick counter.
reset_t2:
    ldx     VIA_T2CH    ; Get the timer offset to adjust the
    lda     VIA_T2CL    ; deadline for the next T2 interrupt.
    cpx     VIA_T2CH    ; Redo this if the high byte has changed
    bne     reset_t2    ; due to counter wrap-around.
;
; T2CL:T2CH is the negative number of microseconds since the interrupt
; fired off.  Add (T2COUNTMS - 24) to adjust the value into a one-shot
; deadline for the next time T2 should fire off.  24 is the number of
; extra microseconds that have elapsed since we read T2CL:T2CH.
;
    clc                 ; Adjust T2CL:T2CH for the next tick.
    adc     #<(T2COUNTMS-24)
    sta     VIA_T2CL
    txa
    adc     #>(T2COUNTMS-24)
    sta     VIA_T2CH
irqdone:
    ply
    plx
    pla
    rti

    .org $FFFA
    .word nmi
    .word reset
    .word irqbrk
