; Define initial setup for LEDs and Button
SetupP3
    mov.b   #11111111b, &P2DIR       ; Set P2 as output
    mov.b   #11011111b, &P1DIR       ; Set P1 as input
    mov.b   #00000000b, &P2OUT       ; Set P2.2 ON (LED on), P2.3 OFF
    mov.b   #00000000b, &P2OUT       ; Set P2.2 ON (LED on), P2.3 OFF


; Initialize registers for toggling states
    mov.b   #00000100b, R6           ; (P2.2 ON, P2.3 OFF state)
    mov.b   #00001000b, R7           ; (P2.2 OFF, P2.3 ON state)

Mainloop
    ; Check if BUTTON P1.5 is pressed
    cmp     #00100000b, &P1IN         ; Check P1.5 (button state)
    jnz     Mainloop                  ; If not pressed, continue

    ; Toggle LED states
    cmp.b   #00000100b, &P2OUT       ; Check if P2.2 is ON
    jeq     ToggleToP2_3             ; If yes, turn on P2.3 and turn off P2.2

    ; Otherwise, toggle to P2.2
    mov.b   R6, &P2OUT               ; Set P2.2 ON, P2.3 OFF
    jmp     Debounce                 ; Wait for debounce

ToggleToP2_3
    mov.b   R7, &P2OUT               ; Set P2.2 OFF, P2.3 ON
    jmp     Debounce                 ; Wait for debounce

Debounce
    mov.w   #00500000, R15           ; Delay for debounce
DebounceLoop
    dec.w   R15                      ; Delay loop
    jnz     DebounceLoop             ; Continue delay until R15 reaches zero

    
WaitRelease
    bit.b   #00100000b, &P1IN        ; Check if button is still pressed
    jnz     WaitRelease              ; Loop until button is released

    jmp     Mainloop                 ; Return to main loop
