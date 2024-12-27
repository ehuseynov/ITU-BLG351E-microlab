; MSP430 Assembler Code Template for use with TI Code Composer Studio

            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

                                            .data

    ; Define segment mapping array for digits 0 to 3
array:
    .byte   00111111b, 00000110b, 01011011b, 01001111b
    ; 0, 1, 2, 3

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Initialize GPIO
;-------------------------------------------------------------------------------
            mov.w   #0xFF, &P1DIR           ; Set Port 1 as output (connected to 7-segment segments)
            mov.w   #0x00, &P1OUT           ; Clear Port 1 output (all segments off)
            mov.w   #0x0F, &P2DIR           ; Set P2.0-P2.3 as output (connected to digit select)
            mov.w   #0x00, &P2OUT           ; Clear Port 2 output (all digits off)

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
main_loop:
            mov.b   #0, R5                  ; Initialize digit index
            mov.b   #1, R6                  ; Initialize digit index
            mov.b   #2, R7                  ; Initialize digit index
            mov.b   #3, R8                  ; Initialize digit index

            ; Clear display
            mov.w   #0x00, &P1OUT
            mov.w   #0x00, &P2OUT

            ; Display digits
            mov.b   array(R5), &P1OUT       ; Display digit 0 on first 7-segment display
            mov.b   #0x01, &P2OUT           ; Select first digit
            call    #ShortDelay             ; Short delay to ensure digit is displayed

            mov.w   #0x00, &P1OUT
            mov.w   #0x00, &P2OUT

            mov.b   array(R6), &P1OUT       ; Display digit 1 on second 7-segment display
            mov.b   #0x02, &P2OUT           ; Select second digit
            call    #ShortDelay             ; Short delay to ensure digit is displayed

            mov.w   #0x00, &P1OUT
            mov.w   #0x00, &P2OUT

            mov.b   array(R7), &P1OUT       ; Display digit 2 on third 7-segment display
            mov.b   #0x04, &P2OUT           ; Select third digit
            call    #ShortDelay             ; Short delay to ensure digit is displayed

            mov.w   #0x00, &P1OUT
            mov.w   #0x00, &P2OUT

            mov.b   array(R8), &P1OUT       ; Display digit 3 on fourth 7-segment display
            mov.b   #0x08, &P2OUT           ; Select fourth digit
            call    #ShortDelay             ; Short delay to ensure digit is displayed

            jmp     main_loop               ; Repeat main loop indefinitely

;-------------------------------------------------------------------------------
; Short delay function to avoid ghosting
;-------------------------------------------------------------------------------
ShortDelay:
            mov.w   #0001h, R14             ; Load short delay value
short_delay_loop:
            dec.w   R14                     ; Decrement delay counter
            jnz     short_delay_loop        ; Repeat until counter is zero
            ret

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
