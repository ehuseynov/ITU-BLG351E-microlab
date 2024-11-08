; Setup direction registers for Port 1 and Port 2
SetupP1.2
    mov.b  #11111111b, &P1DIR       ; Set all bits of P1 direction register to output
    mov.b  #11111111b, &P2DIR       ; Set all bits of P2 direction register to output
    mov.b  #00000000b, &P1OUT       ; Set all bits of P1 output register to low
    mov.b  #00000000b, &P2OUT       ; Set all bits of P2 output register to low

    mov.b  #00001000b, R6          ; Load R6 
    mov.b  #00010000b, R7          ; Load R7  
    mov.b  #0d, R8                ; Initialize counter R8 to 0
    jmp Mainloop1
Mainloop2
	mov.b  #00000000b, &P2OUT
	bis.b  R6, &P1OUT             ; R6 Bitwise OR P1OUT
	inc   R8                      ; Increment counter R8
	rra   R6                       ; Rotate R6 right 
	mov.w  #00500000, R15         ; Load R15 with a delay value
	jmp L1

Mainloop1
    
    bis.b  R7, &P2OUT             ; R7 Bitwise OR P2OUT

    inc   R8                      ; Increment counter R8
    
    rla   R7                       ; Rotate R7 left 

    mov.w  #00500000, R15         ; Load R15 with a delay value
L1
    dec.w  R15                    ; Decrement R15 (delay loop)
    jnz    L1                     ; Jump back to L1 if R15 is not zero

    cmp    #8d, R8                ; Compare R8 with 8d (decimal 8)
    jeq    SetupP1.2              ; Jump to SetupP1.2 if R8 == 8
    
    cmp    #4d, R8                ; Compare R8 with 4d (decimal 4)
    jge    Mainloop2		  ; Jump to Mainloop2 if R8 >= 4
   

    jmp    Mainloop1               ; Repeat Mainloop1
