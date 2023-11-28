;
; selftest.s - Self-test ROM for Ben Eater style 6502 computers.
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

;
; The code below is heavily inlined with no "JSR" instructions.
; This is because we cannot rely upon RAM to work during the early tests.
; In particular, if the stack doesn't work, then a "RET" instruction
; will jump off into the middle of nowhwere.  Once RAM is verified we
; can start doing tests that require RAM.
;

;
; List of tests:
;
;  0: Blink all four indicator LED's three times to indicate test start.
;  1: Test that the stack between $0100 and $01FF appears to work.
;  2: Test that the zero page between $0000 and $00FF appears to work.
;  3: Write test values to all of RAM (except the stack and zero page).
;  4: Read the test values back from RAM and verify them.
;  5: Test that the BRK instruction will generate a BREAK interrupt.
;  6: Test that timer interrupts can be generated from the VIA.
;  7: Beep the piezobuzzer on PB7 for 100ms with a 1kHz square wave.
;  8: Test that code can be executed from all addresses in ROM.
;
; After all tests have been successful, the LED's will display a chase
; back and forth.  If a test fails, then the LED's will stop and
; display the number of the test that failed.
;

;
; Configurable parameters for different types of hardware.
;
RAM_START       = $0200           ; Start address for RAM, excluding zp/stack.
RAM_END         = $4000           ; End address for RAM + 1.
ACIA_BASE       = $5000           ; Base address for the ACIA.
VIA_BASE        = $6000           ; Base address for the VIA.
ROM_START       = $8000           ; Start address for ROM, extends to $FFFF.

;
; Registers on the VIA.
;
VIA_PORTB       = VIA_BASE
VIA_PORTA       = (VIA_BASE+1)
VIA_DDRB        = (VIA_BASE+2)
VIA_DDRA        = (VIA_BASE+3)
VIA_T1CL        = (VIA_BASE+4)
VIA_T1CH        = (VIA_BASE+5)
VIA_T1LL        = (VIA_BASE+6)
VIA_T1LH        = (VIA_BASE+7)
VIA_T2CL        = (VIA_BASE+8)
VIA_T2CH        = (VIA_BASE+9)
VIA_SR          = (VIA_BASE+10)
VIA_ACR         = (VIA_BASE+11)
VIA_PCR         = (VIA_BASE+12)
VIA_IFR         = (VIA_BASE+13)
VIA_IER         = (VIA_BASE+14)

;
; Registers on the ACIA.
;
ACIA_DATA       = ACIA_BASE
ACIA_STATUS     = (ACIA_BASE+1)
ACIA_CMD        = (ACIA_BASE+2)
ACIA_CTRL       = (ACIA_BASE+3)

;
; Zero page variables.  Can only use these after we verify that the
; zero page is actually working.
;
PTR             = $20
BRK_SEEN        = $22
T1_SEEN         = $23
SAVE_A          = $24
SAVE_Y          = $25
ACIA_ACTIVE     = $26

;
; Start assembling code at the beginning of ROM.
;
    .org    ROM_START

;
; Delay for a certain number of milliseconds (1-255).  Destroys X and Y.
; Note: This assumes a 1MHz clock.  Add extra nop's after the "b_\@" label
; for higher clock speeds.
;
  .macro DELAY
    ldx #\1                 ; 2 clock cycles
a_\@:
    ldy #199                ; 2 clock cycles
b_\@:
    dey                     ; 2 clock cycles
    bne b_\@                ; 3 clock cycles if branch taken
    dex                     ; 2 clock cycles
    bne a_\@                ; 3 clock cycles if branch taken
  .endm

;
; Delay for 1 second.
;
  .macro DELAY_1s
    DELAY 250
    DELAY 250
    DELAY 250
    DELAY 250
  .endm

;
; Turn on the LED's on PB0..PB3.  Destroys A.
;
  .macro SET_LEDS
    lda #\1
    sta VIA_PORTB
  .endm

;
; Print the character in A on the serial port.  Destroys Y.
;
  .macro PRINT_CHAR
    sta ACIA_DATA           ; Transmit A using the ACIA.
    ldy #$ff                ; Wait for the byte to be transmitted.
a_\@:
    dey
    bne a_\@
  .endm

;
; Print a message on the serial port.  Destroys A, X, and Y.
;
  .macro PRINT
    ldx #0
a_\@:
    lda b_\@,x              ; Load the next character of the message
    beq c_\@                ; Bail out when we see the NUL.
    PRINT_CHAR              ; Print the character to the serial port.
    inx
    jmp a_\@
b_\@:
    .asc \1                 ; Inject the message string into the code here.
    .db 13                  ; Terminating CRLF and NUL.
    .db 10
    .db 0
c_\@:
  .endm

;
; Print a message on the serial port without a newline.  Destroys A, X, and Y.
;
  .macro PRINT_NO_NL
    ldx #0
a_\@:
    lda b_\@,x              ; Load the next character of the message
    beq c_\@                ; Bail out when we see the NUL.
    PRINT_CHAR              ; Print the character to the serial port.
    inx
    jmp a_\@
b_\@:
    .asc \1                 ; Inject the message string into the code here.
    .db 0
c_\@:
  .endm

;
; Print a hexadecimal nibble.
;
  .macro PRINT_HEX
    clc
    adc #$30
    cmp #$3a
    bcc a_\@
    adc #6
a_\@:
    PRINT_CHAR
  .endm

;
; Print the low nibble of a hexadecimal byte.
;
  .macro PRINT_HEX_LOW
    and #$0f
    PRINT_HEX
  .endm

;
; Print the high nibble of a hexadecimal byte.
;
  .macro PRINT_HEX_HIGH
    lsr
    lsr
    lsr
    lsr
    PRINT_HEX
  .endm

;
; Main code starts here on reset.
;
reset:
    cld                     ; Fix the D and I flags.
    cli
    ldx #$ff                ; Set up the stack pointer for later.
    tsx
;
; Startup delay to let the voltage rails settle on the daughter
; chips before we try to activate them.  The ACIA in particular
; can be slow to start up.
;
    DELAY 250
;
; Initialize the VIA.
;
    lda #$0f                ; Configure PB0..PB3 as outputs.
    sta VIA_DDRB            ; We assume they are connected to LED's.
;
; Initialize the ACIA.
;
    lda ACIA_STATUS         ; Clear any reported errors.
    lda ACIA_DATA           ; Empty the receive buffer if something is in it.
    lda #$00
    sta ACIA_STATUS         ; Force the ACIA to reset itself.
    lda #$1f                ; 19200-N-8-1
    sta ACIA_CTRL
    lda #$0b                ; Turn on DTR and turn off interrupts.
    sta ACIA_CMD
;
; Print a banner to the serial port.
;
    PRINT ""
    PRINT "Self test started!"
;
; Blink all LED's three times at startup.
;
startup_blink:
    SET_LEDS 15
    DELAY 250
    SET_LEDS 0
    DELAY 250
    SET_LEDS 15
    DELAY 250
    SET_LEDS 0
    DELAY 250
    SET_LEDS 15
    DELAY 250
    SET_LEDS 0
    DELAY 250
;
; Test the stack by pushing certain values and then checking that
; they are still there when popped off.
;
test_stack:
    SET_LEDS 1
    PRINT "Stack check: Running"
    lda #$55
    pha
    lda #$aa
    pha
    lda #$0b
    pha
    lda #$ad
    pha
    lda #$be
    pha
    lda #$ef
    pha
    php
    pla
    pla
    cmp #$ef
    bne test_stack_failed
    pla
    cmp #$be
    bne test_stack_failed
    pla
    cmp #$ad
    bne test_stack_failed
    pla
    cmp #$0b
    bne test_stack_failed
    pla
    cmp #$aa
    bne test_stack_failed
    pla
    cmp #$55
    bne test_stack_failed
    jmp test_stack_ok
test_stack_failed:
    PRINT "Stack check: FAILED"
    jmp failed
test_stack_ok:
    PRINT "Stack check: Success"
    DELAY_1s

;
; Test the zero page so that we can rely upon it in later tests.
;
test_zp:
    SET_LEDS 2
    PRINT "Zero page check: Running"
;
; Fill the zero page with primes.
;
    ldx #0
test_zp_loop_1:
    lda primes,x
    sta $0000,x
    dex
    bne test_zp_loop_1
;
; Read the data back and compare with what we expect.
;
test_zp_loop_2:
    lda $0000,x
    cmp primes,x
    bne test_zp_failed
    dex
    bne test_zp_loop_2
;
; Now fill the zero page with zeroes to initialize it properly.
;
    lda #0
test_zp_loop_3:
    sta $0000,x
    dex
    bne test_zp_loop_3
;
; And check that everything in the zero page is zero now.
;
test_zp_loop_4:
    lda $0000,x
    bne test_zp_failed
    dex
    bne test_zp_loop_4
    jmp test_zp_ok
;
test_zp_failed:
    PRINT "Zero page check: FAILED"
    jmp failed
test_zp_ok:
    PRINT "Zero page check: Success"
    DELAY_1s

;
; Test the remainder of RAM.  We assume that the RAM chips are
; reliable and that their memory cells were tested in the factory.
; We might still find faulty cells by accident with this test.
;
; What we are trying to test are board-related faults:
;
;   - Is the RAM fitted at all?
;   - Are all of the address and data lines connected?
;   - Are there any shorts between address and data lines that alter
;     the value that is read back?
;
; What this won't find:
;
;   - Data or address lines that have been swapped.  For example, the
;     connections from the CPU to D0 and D1 on the RAM were swapped so
;     that they arrive at D1 and D0 instead.  The RAM will work just fine.
;     Similarly with address lines.
;
; Since we already checked the stack and zero page above, we assume
; that they work and we can use them now.
;
test_ram:
    SET_LEDS 3
    PRINT "RAM check: Filling memory"
;
; Fill all of RAM with prime numbers, with the values shifted from
; one page to the next.  The first prime number ends up in page
; offset 0 in the first page, page offset 1 in the second, and so on.
;
; If there is a problem where writing a value to one page makes it
; ghost in another page, then the page shifting should help find it.
;
    lda #0
    sta PTR
    lda #>RAM_START
    sta PTR+1
    ldy #<RAM_START
test_ram_fill_page:
    ldx PTR+1   ; Shift the table offset by the high byte of the pointer.
test_ram_fill_loop:
    lda primes,x
    sta (PTR),y
    inx
    iny
    bne test_ram_fill_loop
    inc PTR+1   ; Move to the next page.
    lda PTR+1
    cmp #>RAM_END
    bcc test_ram_fill_page
    DELAY 250
    DELAY 250
;
; Read the data back and check that it matches what we put in.
;
    SET_LEDS 4
    PRINT "RAM check: Verifying memory"
    lda #>RAM_START
    sta PTR+1
    ldy #<RAM_START
test_ram_verify_page:
    ldx PTR+1
test_ram_verify_loop:
    lda (PTR),y
    cmp primes,x
    bne test_ram_failed
    inx
    iny
    bne test_ram_verify_loop
    inc PTR+1
    lda PTR+1
    cmp #>RAM_END
    bcc test_ram_verify_page
    jmp test_ram_ok
test_ram_failed:
    PRINT_NO_NL "RAM check: FAILED at 0x"
    lda PTR+1
    PRINT_HEX_HIGH
    lda PTR+1
    PRINT_HEX_LOW
    lda PTR
    PRINT_HEX_HIGH
    lda PTR
    PRINT_HEX_LOW
    PRINT ""
    jmp failed
test_ram_ok:
    PRINT "RAM check: Success"
    DELAY 250
    DELAY 250

;
; Now that we have working RAM, we can do more useful things with it,
; like store the return address and status for an interrupt call.
;

;
; Issue a BRK instruction, which will return right back to us but
; with a variable in the zero page set.
;
test_break:
    SET_LEDS 5
    PRINT "BRK check: Running"
    lda #0
    sta BRK_SEEN
    brk
    nop
    lda BRK_SEEN
    cmp #$aa
    beq test_break_ok
;
test_break_failed:
    PRINT "BRK check: FAILED"
    jmp failed
test_break_ok:
    PRINT "BRK check: Success"
    DELAY_1s

;
; Set up T1 on the VIA in one-shot mode to generate an interrupt.
; We assume that the VIA is running off the same clock as the CPU.
;
test_t1:
    SET_LEDS 6
    PRINT "Timer interrupt check: Running"
    lda #$00            ; Set up T1 for one-shot mode.
    sta VIA_ACR
    sta T1_SEEN
    lda #$c0            ; Enable the T1 interrupt.
    sta VIA_IER
;
TIMEOUT = 50000         ; 50ms in 1MHz clock ticks.
    lda #<TIMEOUT       ; Set the timeout.
    sta VIA_T1CL
    lda #>TIMEOUT
    sta VIA_T1CH        ; T1 starts running here.
;
    DELAY 70            ; Wait for the timer to well and truly expire.
;
    lda #$40            ; Disable the T1 interrupt.
    sta VIA_IER
;
    lda T1_SEEN         ; Did the T1 interrupt occur?
    cmp #$55
    beq test_t1_ok
;
test_t1_failed:
    PRINT "Timer interrupt check: FAILED"
    jmp failed
test_t1_ok:
    PRINT "Timer interrupt check: Success"
    DELAY_1s

;
; Beep the piezobuzzer on PB7, if present.
;
test_pwm:
    SET_LEDS 7
    PRINT "PWM output check: Running"
    lda VIA_DDRB        ; Change PB7 to an output.
    ora #$80
    sta VIA_DDRB
    lda VIA_PORTB       ; Set PB7 to be initially low.
    and #$7F
    sta VIA_PORTB
    lda VIA_ACR         ; Configure T1 for square wave output on PB7.
    ora #$C0
    sta VIA_ACR
    lda #<500           ; Set the half-cycle time to 500us.
    sta VIA_T1CL
    lda #>500
    sta VIA_T1CH
    DELAY 100
    lda VIA_ACR         ; Disable square wave output on PB7.
    and #$3f
    sta VIA_ACR
    lda VIA_PORTB       ; Don't leave PB7 high by accident.
    and #$7f
    sta VIA_PORTB
    DELAY 150
test_pwm_ok:
    PRINT "PWM output check: Done"
    DELAY 250
    DELAY 250
    DELAY 250

;
; Fill with NOP's.  This pushes the address up into the high parts of ROM.
;
; Up until now we have tested that code will run successfully out of the
; low parts of ROM.  These NOP's and the success/failure handlers that
; follow test that we can run code out of the rest of ROM.
;
test_rom:
    SET_LEDS 8
    PRINT "ROM check: Running"
    .fill $FC00-*,$EA
    PRINT "ROM check: Success"
    DELAY_1s

;
; Is the ACIA active on the bus?  If it is, we can do a receive
; test during the success LED chase.  If not, we avoid trying to
; receive data on the serial port.
;
    lda ACIA_DATA           ; Clear the RX buffer before we start.
    lda #0                  ; Set the ACIA_ACTIVE flag to 0.
    sta ACIA_ACTIVE
    lda ACIA_CTRL           ; Are ACIA_CTRL and ACIA_CMD set to the
    cmp #$1f                ; values we set in them earlier?
    bne success             ; If not, the ACICA is probably not present.
    lda ACIA_CMD
    cmp #$0b
    bne success
    dec ACIA_ACTIVE         ; Set ACIA_ACTIVE to 0xFF.

;
; Delay loop that also checks for incoming characters from the ACIA.
;
  .macro RX_DELAY
    ldx #\1                 ; 2 clock cycles
a_\@:
    ldy #90                 ; 2 clock cycles
b_\@:
    bit ACIA_ACTIVE         ; 3 clock cycles
    bvc e_\@                ; 3 clock cycles if branch taken
    lda ACIA_STATUS         ; 4 clock cycles
    and #$08                ; 2 clock cycles
    beq d_\@                ; 3 clock cycles if branch taken
    sty SAVE_Y
    lda ACIA_DATA
    PRINT_CHAR
    cmp #$0d
    bne c_\@
    lda #$0a
    PRINT_CHAR
c_\@:
    ldy SAVE_Y
d_\@:
    dey
    beq f_\@
e_\@:
    dey                     ; 2 clock cycles
    bne b_\@                ; 3 clock cycles if branch taken
f_\@:
    dex                     ; 2 clock cycles
    bne a_\@                ; 3 clock cycles if branch taken
  .endm

;
; Stops running the test on success.  We chase the LED's back and
; forth forever to indicate success.
;
success:
    PRINT "All tests passed!"
chase:
    RX_DELAY 100
    SET_LEDS $01
    RX_DELAY 100
    SET_LEDS $02
    RX_DELAY 100
    SET_LEDS $04
    RX_DELAY 100
    SET_LEDS $08
    RX_DELAY 100
    SET_LEDS $04
    RX_DELAY 100
    SET_LEDS $02
    jmp chase

;
; Stops running the test on failure and loops forever displaying the
; number of the test that failed on the LED's.
;
failed:
    jmp failed

;
; First 256 primes, mod 256.
;
primes:
    .db 0x02, 0x03, 0x05, 0x07, 0x0b, 0x0d, 0x11, 0x13, 0x17, 0x1d, 0x1f, 0x25
    .db 0x29, 0x2b, 0x2f, 0x35, 0x3b, 0x3d, 0x43, 0x47, 0x49, 0x4f, 0x53, 0x59
    .db 0x61, 0x65, 0x67, 0x6b, 0x6d, 0x71, 0x7f, 0x83, 0x89, 0x8b, 0x95, 0x97
    .db 0x9d, 0xa3, 0xa7, 0xad, 0xb3, 0xb5, 0xbf, 0xc1, 0xc5, 0xc7, 0xd3, 0xdf
    .db 0xe3, 0xe5, 0xe9, 0xef, 0xf1, 0xfb, 0x01, 0x07, 0x0d, 0x0f, 0x15, 0x19
    .db 0x1b, 0x25, 0x33, 0x37, 0x39, 0x3d, 0x4b, 0x51, 0x5b, 0x5d, 0x61, 0x67
    .db 0x6f, 0x75, 0x7b, 0x7f, 0x85, 0x8d, 0x91, 0x99, 0xa3, 0xa5, 0xaf, 0xb1
    .db 0xb7, 0xbb, 0xc1, 0xc9, 0xcd, 0xcf, 0xd3, 0xdf, 0xe7, 0xeb, 0xf3, 0xf7
    .db 0xfd, 0x09, 0x0b, 0x1d, 0x23, 0x2d, 0x33, 0x39, 0x3b, 0x41, 0x4b, 0x51
    .db 0x57, 0x59, 0x5f, 0x65, 0x69, 0x6b, 0x77, 0x81, 0x83, 0x87, 0x8d, 0x93
    .db 0x95, 0xa1, 0xa5, 0xab, 0xb3, 0xbd, 0xc5, 0xcf, 0xd7, 0xdd, 0xe3, 0xe7
    .db 0xef, 0xf5, 0xf9, 0x01, 0x05, 0x13, 0x1d, 0x29, 0x2b, 0x35, 0x37, 0x3b
    .db 0x3d, 0x47, 0x55, 0x59, 0x5b, 0x5f, 0x6d, 0x71, 0x73, 0x77, 0x8b, 0x8f
    .db 0x97, 0xa1, 0xa9, 0xad, 0xb3, 0xb9, 0xc7, 0xcb, 0xd1, 0xd7, 0xdf, 0xe5
    .db 0xf1, 0xf5, 0xfb, 0xfd, 0x07, 0x09, 0x0f, 0x19, 0x1b, 0x25, 0x27, 0x2d
    .db 0x3f, 0x43, 0x45, 0x49, 0x4f, 0x55, 0x5d, 0x63, 0x69, 0x7f, 0x81, 0x8b
    .db 0x93, 0x9d, 0xa3, 0xa9, 0xb1, 0xbd, 0xc1, 0xc7, 0xcd, 0xcf, 0xd5, 0xe1
    .db 0xeb, 0xfd, 0xff, 0x03, 0x09, 0x0b, 0x11, 0x15, 0x17, 0x1b, 0x27, 0x29
    .db 0x2f, 0x51, 0x57, 0x5d, 0x65, 0x77, 0x81, 0x8f, 0x93, 0x95, 0x99, 0x9f
    .db 0xa7, 0xab, 0xad, 0xb3, 0xbf, 0xc9, 0xcb, 0xcf, 0xd1, 0xd5, 0xdb, 0xe7
    .db 0xf3, 0xfb, 0x07, 0x0d, 0x11, 0x17, 0x1f, 0x23, 0x2b, 0x2f, 0x3d, 0x41
    .db 0x47, 0x49, 0x4d, 0x53

;
; IRQBRK handler.
;
irqbrk:
    cld
    sta SAVE_A
    pla                 ; Was the interrupt due to BRK or IRQ?
    pha
    and #$10
    beq t1_check
;
    lda #$aa            ; This was a BRK, so set a flag indicating that.
    sta BRK_SEEN
    lda SAVE_A
    rti
;
t1_check:
    lda VIA_IFR         ; Did the T1 interrupt occur?
    and #$40
    beq irq_done
    lda VIA_T1CL        ; Clear the T1 interrupt.
    lda #$55            ; Tell the foreground code that the interrupt occurred.
    sta T1_SEEN
;
irq_done:
    lda SAVE_A
    rti

;
; NMI handler - not used.
;
nmi:
    rti

;
; Interrupt and reset vectors.
;
    .org    $FFFA
    .dw     nmi
    .dw     reset
    .dw     irqbrk
