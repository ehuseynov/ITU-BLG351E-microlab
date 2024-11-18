SetupP3
    mov.b  #11111111b, &P1DIR       ; set P1 as output
    mov.b  #00000000b, &P2DIR       ; set P2.4 as input and others as input
    mov.b  #00000000b, &P2OUT
    mov.b  #00000000b, &P1OUT       ; Set all bits of P1 output register to low

    mov.b  #00001000b, R6          ; Load R6
    jmp Mainloop1

Mainloop1
	mov.b	&P2IN, R4
	cmp 	#10000001b, R4             ; Check if the starter bit is on
	jeq		Turnp1on                      ; if starter bit is on then jump to L1
    jmp     Mainloop1                    ; else keep waiting

Turnp1on
    bis.b 	R6, &P1OUT             ; set p1.4
    jmp 	L1                      ; go infinite

L1
    jmp     L1                  ; infinite loop
