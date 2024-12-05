; Initialization
    mov.b  #11111111b, &P1DIR      ; Set all P1 bits as output (P1DIR = 0xFF)
    mov.b  #00000000b, &P1OUT      ; Clear all P1 output bits (P1OUT = 0x00)

; Load A and B (Dividend and Divisor)
    mov.w  #150d, R4               ; A = 151 (Dividend)
    mov.w  #10d, R5                 ; B = 8 (Divisor)

    mov.w  R5, R7                  ; C = B
    mov.w  R4, R8                  ; D = A
    mov.w	R4, R9					;
    rra		R9						; A/2

First_Loop:
    cmp.w  R7, R9                  ; Compare A with C
    jlo     Second_Loop            ; Exit if C > A/2
    add.w   R7, R7                 ; C = C * 2
    jmp     First_Loop             ; Repeat loop

Second_Loop:

    cmp.w   R5, R8	                 ; Compare D with B
    jl      End                    ; Exit if D < B
    cmp.w   R7, R8                 ; Compare D with C
    jlo     Halve_C                ; If D < C, halve C
    sub.w   R7, R8                 ; D = D - C
    jmp     Second_Loop            ; Repeat loop

Halve_C:
    rra.w   R7                     ; C = C / 2
    jmp     Second_Loop            ; Back to Second_Loop

End:
    mov.b   R8, &P1OUT             ; Display remainder D on Port 1 LEDs
    jmp     End                    ; Stay here (halt program)

