            .data                     ; Data section
count       .byte   0                 ; Define a 4-bit variable `count` initialized to 0

            .text                     ; Code section
            .global  main             ; Main entry point

main
            ; Setup P2.1 as input for button and P1 as output for display
            mov.b   #11111111b, &P2DIR  		; Set P2.1 as input, others as needed
            mov.b   #11111110b, &P1DIR  		; Set all bits of P1 as output
            mov.b   #00000000b, &P1OUT          ; Initialize P1OUT to display 0
			 mov.b   #00000000b, &P2OUT          ; Initialize P1OUT to display 0
Mainloop
            ; Check if the button (P2.1) is pressed
            mov.b	&P1IN, R4
            cmp     #1d, R4    			; Check P2.1 (button state)
            jnz      Mainloop              ; If not pressed, skip counting

            ; Increment the count
            inc.b   count                   ; Increment R5
            and.b   #00001111b, count        ; M
            mov.b   count, &P2OUT           ; Display count on Port 1

            ; Debounce delay
Debounce
            mov.w   #00500000, R15       ; Delay for debounce
DebounceLoop
            dec.w   R15                  ; Decrement delay counter
            jnz     DebounceLoop         ; Continue delay until R15 reaches zero

            ; Wait until button is released to avoid continuous increment
WaitRelease
			mov.b	&P1IN, R4
            cmp     #1d, R4    			; Check P2.1 (button state)
            jeq     WaitRelease          ; Loop until button is released

            jmp     Mainloop             ; Return to main loop

