;
; play1.s - Play music via a piezobuzzer on PB7 (top half of the code).
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

    .org $8000

reset:
    cld
    cli
    jmp     start

; These durations should be multiplied by 9 to get the actual duration in ms.
; Adjusting DUR_W will change the tempo of the piece.
DUR_W  = 172                            ; whole note
DUR_H  = (DUR_W / 2)                    ; half note
DUR_HD = (DUR_W / 2) + (DUR_W / 4)      ; half note, dotted
DUR_Q  = (DUR_W / 4)                    ; quarter note
DUR_QD = (DUR_W / 4) + (DUR_W / 8)      ; quarter note, dotted
DUR_E  = (DUR_W / 8)                    ; eighth note
DUR_ED = (DUR_W / 8) + (DUR_W / 16)     ; eighth note, dotted
    .include notes.s
