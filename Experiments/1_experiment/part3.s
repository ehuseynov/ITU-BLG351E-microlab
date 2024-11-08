SetupP3
    mov.b  #11111111b, &P1DIR       ; Set all bits of P1 direction register to output
    mov.b  #11111100b, &P2DIR             ; set P1.0 as output and P1.1 as input
    mov.b  #00000000b, &P1OUT       ; Set all bits of P1 output register to low


    mov.b  #10000000b, R6          ; Load R6
    mov.b  #0d, R8                ; Initialize counter R8 to 0
    jmp Mainloop1
Mainloop1

	bis.b  R6, &P1OUT             ; Bitwise OR: Toggle bit 3 of P1OUT
	inc   R8                      ; Increment counter R8
	rra   R6                       ; Rotate R6 right (this will shift the bit in P1OUT)
	mov.w  #00500000, R15         ; Load R15 with a delay value
	jmp L1
Stop
	cmp 	#2d, &P2IN
	jeq		L1
    jmp     Stop

L1
    dec.w  R15                    ; Decrement R15 (delay loop)
    jnz    L1                     ; Jump back to L1 if R15 is not zero

    cmp    #1d, &P2IN        ; if we press the button then return to stop loop
    jeq     Stop


    cmp    #8d, R8                ; Compare R8 with 4d (decimal 4)
    jeq    SetupP3		  ; Jump to SetupP1 if R8 == 8

    jmp     Mainloop1
