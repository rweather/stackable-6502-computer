;
; via.s - 6522 Versatile Interface Adapter addresses and registers.
;
; Addresses default to $6000 for the eater6502 target.  This can be
; overridden by setting VIA_BASE before including this file.
;

; I/O ports on the 6522 Versatile Interface Adapter.
; https://eater.net/datasheets/w65c22.pdf
    .ifdef VIA_BASE
VIA_PORTB           .equ    (VIA_BASE)
VIA_PORTA           .equ    (VIA_BASE+1)
VIA_DDRB            .equ    (VIA_BASE+2)
VIA_DDRA            .equ    (VIA_BASE+3)
VIA_T1CL            .equ    (VIA_BASE+4)
VIA_T1CH            .equ    (VIA_BASE+5)
VIA_T1LL            .equ    (VIA_BASE+6)
VIA_T1LH            .equ    (VIA_BASE+7)
VIA_T2CL            .equ    (VIA_BASE+8)
VIA_T2CH            .equ    (VIA_BASE+9)
VIA_SR              .equ    (VIA_BASE+10)
VIA_ACR             .equ    (VIA_BASE+11)
VIA_PCR             .equ    (VIA_BASE+12)
VIA_IFR             .equ    (VIA_BASE+13)
VIA_IER             .equ    (VIA_BASE+14)
VIA_PORTA_NO_HAND   .equ    (VIA_BASE+15)
    .else
VIA_PORTB           .equ    $6000
VIA_PORTA           .equ    $6001
VIA_DDRB            .equ    $6002
VIA_DDRA            .equ    $6003
VIA_T1CL            .equ    $6004
VIA_T1CH            .equ    $6005
VIA_T1LL            .equ    $6006
VIA_T1LH            .equ    $6007
VIA_T2CL            .equ    $6008
VIA_T2CH            .equ    $6009
VIA_SR              .equ    $600A
VIA_ACR             .equ    $600B
VIA_PCR             .equ    $600C
VIA_IFR             .equ    $600D
VIA_IER             .equ    $600E
VIA_PORTA_NO_HAND   .equ    $600F
    .endif

; Bits of interest in the VIA's Auxiliary Control Register (ACR).
VIA_ACR_T1_ONE_SHOT .equ    %00000000   ; T1 timer one-shot mode.
VIA_ACR_T1_FREE_RUN .equ    %01000000   ; T1 timer free-run mode.
VIA_ACR_T1_ONE_OUT  .equ    %10000000   ; T1 timer one-shot output on PB7.
VIA_ACR_T1_SQUARE   .equ    %11000000   ; T1 timer square wave output on PB7.
VIA_ACR_T1_BITS     .equ    %11000000   ; Bit mask for T1 control bits.
VIA_ACR_T2_ONE_SHOT .equ    %00000000   ; T2 timer one-shot mode.
VIA_ACR_T2_PULSE    .equ    %00100000   ; T2 timer pulse counting on PB6.
VIA_ACR_T2_BITS     .equ    %00100000   ; Bit mask for T2 control bits.
VIA_ACR_SR_DISABLE  .equ    %00000000   ; Shift register is disabled.
VIA_ACR_SR_SI_T2    .equ    %00000100   ; Shift in under control of T2.
VIA_ACR_SR_SI_PHI2  .equ    %00001000   ; Shift in under control of PHI2.
VIA_ACR_SR_SI_EXT   .equ    %00001100   ; Shift in under control of ext clock.
VIA_ACR_SR_SO_FREE  .equ    %00010000   ; Shift out free-running at T2 rate.
VIA_ACR_SR_SO_T2    .equ    %00010100   ; Shift out under control of T2.
VIA_ACR_SR_SO_PHI2  .equ    %00011000   ; Shift out under control of PHI2.
VIA_ACR_SR_SO_EXT   .equ    %00011100   ; Shift out under control of ext clock.
VIA_ACR_SR_BITS     .equ    %00011100   ; Bit mask for SR control bits.
VIA_ACR_PA_LATCH    .equ    %00000010   ; Enable latching on PORTA.
VIA_ACR_PB_LATCH    .equ    %00000001   ; Enable latching on PORTB.

; Bits of interest in the VIA's Peripheral Control Register (PCR).
VIA_PCR_CB2_NEG     .equ    %00000000   ; CB2 negative active edge.
VIA_PCR_CB2_INEG    .equ    %00100000   ; CB2 independent negative edge.
VIA_PCR_CB2_POS     .equ    %01000000   ; CB2 positive active edge.
VIA_PCR_CB2_IPOS    .equ    %01100000   ; CB2 independent positive edge.
VIA_PCR_CB2_HAND    .equ    %10000000   ; CB2 handshake output.
VIA_PCR_CB2_PULSE   .equ    %10100000   ; CB2 pulse output.
VIA_PCR_CB2_LOW     .equ    %11000000   ; CB2 low output.
VIA_PCR_CB2_HIGH    .equ    %11100000   ; CB2 high output.
VIA_PCR_CB1_NEG     .equ    %00000000   ; CB1 negative active edge.
VIA_PCR_CB1_POS     .equ    %00010000   ; CB1 positive active edge.
VIA_PCR_CA2_NEG     .equ    %00000000   ; CB2 negative active edge.
VIA_PCR_CA2_INEG    .equ    %00000010   ; CA2 independent negative edge.
VIA_PCR_CA2_POS     .equ    %00000100   ; CA2 positive active edge.
VIA_PCR_CA2_IPOS    .equ    %00000110   ; CA2 independent positive edge.
VIA_PCR_CA2_HAND    .equ    %00001000   ; CA2 handshake output.
VIA_PCR_CA2_PULSE   .equ    %00001010   ; CA2 pulse output.
VIA_PCR_CA2_LOW     .equ    %00001100   ; CA2 low output.
VIA_PCR_CA2_HIGH    .equ    %00001110   ; CA2 high output.
VIA_PCR_CA1_NEG     .equ    %00000000   ; CA1 negative active edge.
VIA_PCR_CA1_POS     .equ    %00000001   ; CA1 positive active edge.

; Bits of interest in the VIA's Interrupt Flag Register (IFR).
VIA_IFR_IRQ         .equ    %10000000   ; Any enabled interrupt.
VIA_IFR_T1          .equ    %01000000   ; T1 timer interrupt.
VIA_IFR_T2          .equ    %00100000   ; T2 timer interrupt.
VIA_IFR_CB1         .equ    %00010000   ; CB1 input edge interrupt.
VIA_IFR_CB2         .equ    %00001000   ; CB2 input edge interrupt.
VIA_IFR_SR          .equ    %00000100   ; Shift register interrupt.
VIA_IFR_CA1         .equ    %00000010   ; CA1 input edge interrupt.
VIA_IFR_CA2         .equ    %00000001   ; CA2 input edge interrupt.

; Bits of interest in the VIA's Interrupt Enable Register (IER).
VIA_IER_SET         .equ    %10000000   ; Set ints specified in low bits.
VIA_IER_CLEAR       .equ    %00000000   ; Clear ints specified in low bits.
VIA_IER_T1          .equ    %01000000   ; T1 timer interrupt.
VIA_IER_T2          .equ    %00100000   ; T2 timer interrupt.
VIA_IER_CB1         .equ    %00010000   ; CB1 input edge interrupt.
VIA_IER_CB2         .equ    %00001000   ; CB2 input edge interrupt.
VIA_IER_SR          .equ    %00000100   ; Shift register interrupt.
VIA_IER_CA1         .equ    %00000010   ; CA1 input edge interrupt.
VIA_IER_CA2         .equ    %00000001   ; CA2 input edge interrupt.
