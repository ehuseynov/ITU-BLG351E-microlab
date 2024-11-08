; Setup direction registers for Port 1 and Port 2
SetupP2
    mov.b  #11111111b, &P1DIR       ; Set all bits of P1 direction register to output
    mov.b  #11111111b, &P2DIR       ; Set all bits of P2 direction register to output
    mov.b  #00000000b, &P1OUT       ; Set all bits of P1 output register to low
    mov.b  #00000000b, &P2OUT       ; Set all bits of P2 output register to low

    mov.b  #10000000b, R6          ; Load R6
    mov.b  #0d, R8                ; Initialize counter R8 to 0
    jmp Mainloop1
Mainloop1
	mov.b  #00000000b, &P2OUT
	bis.b  R6, &P1OUT             ; R6 Bitwise AND P1OUT
	inc   R8                      ; Increment counter R8
	rra   R6                       ; Rotate R6 left 0000 0001 -> 0000 0010

	mov.w  #00500000, R15         ; Load R15 with a delay value
	jmp Mainloop2

Mainloop2
	dec.w  R15                    ; Decrement R15 (delay loop)
    jnz    Mainloop2

	mov.b  #00000000b, &P1OUT

	mov.w  #00500000, R15
	jmp delay




delay
	dec.w  R15                    ; Decrement R15 (delay loop)
    jnz    delay

Mainloop3
    bis.b   R6, &P2OUT             ; R6(rotated value 0000 0010) Bitwise AND P2OUT
    rra     R6                     ; rotate R6 again
    inc     R8                      ; increment index
	mov.w  #00500000, R15         ; Load R15 with a delay value
	jmp L1
L1
    dec.w  R15                    ; Decrement R15 (delay loop)
    jnz    L1                     ; Jump back to L1 if R15 is not zero



	       ; Set all bits of P1 output register to low


    cmp    #8d, R8                ; Compare R8 with 8d (decimal 8)
    jeq    SetupP2		  ; Jump to SetupP1 if R8 == 8

    jmp     Mainloop1 ; go to P1OUT loop