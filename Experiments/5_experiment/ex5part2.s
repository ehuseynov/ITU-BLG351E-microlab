;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

.data

    ; Define segment mapping array
array:
    .byte   000111111b, 000000110b, 001011011b, 001001111b
    .byte   001100110b, 001101101b, 001111101b, 000000111b
    .byte   001111111b, 001101111b

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stack pointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
            mov.b   #0d, P2SEL              ; Set Port 2 as GPIO

;-------------------------------------------------------------------------------
; Initialize GPIO and Interrupts
;-------------------------------------------------------------------------------
            mov.w   #0xFF, &P1DIR      ; Set Port 1 as output (connected to 7-segment)
            mov.w   #0x00, &P1SEL      ; Set Port 1 to GPIO function
            mov.w   #0x00, &P1OUT      ; Clear output (start with all segments off)

            ; Enable interrupt on P2.6 (button press)
            bis.b   #040h, &P2IE       ; Enable interrupt at P2.6
            and.b   #0BFh, &P2SEL      ; Set P2.6 to GPIO
            and.b   #0BFh, &P2SEL2     ; Set P2.6 to GPIO
            bis.b   #040h, &P2IES      ; High-to-low interrupt mode (edge trigger)
            clr     &P2IFG             ; Clear interrupt flag
            eint                        ; Enable interrupts

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
main_loop:
    cmp.b   #0, R4                     ; Check if mode is even
    jeq     even_mode                  ; Jump to even mode if 0

odd_mode:
    mov.w   R12, R13
    inc     R13                   ; Load counter
    cmp.w   #10, R13                    ; Check if counter exceeds 9
    jge     reset_counter              ; Reset if out of range
    call    #DisplayNumber             ; Display current counter
    add.w   #2, R12                    ; Increment by 2 (odd)
    jmp     main_loop

reset_counter:
    clr.w   R12                        ; Reset counter to 0
    jmp     main_loop

even_mode:
    mov.w   R12, R13                   ; Load counter
    cmp.w   #9, R13                    ; Check if counter exceeds 8
    jge     reset_even                 ; Reset if out of range
    call    #DisplayNumber             ; Display current counter
    add.w   #2, R12                    ; Increment by 2 (even)
    jmp     main_loop

reset_even:
    clr.w   R12                        ; Reset counter to 0 (even counting)
    jmp     main_loop

;-------------------------------------------------------------------------------
; Display the number on the 7-segment display
;-------------------------------------------------------------------------------
DisplayNumber:
    mov.b   array(R13), &P1OUT         ; Load corresponding 7-segment pattern
    call    #Delay                     ; 1-second delay
    ret

;-------------------------------------------------------------------------------
; Delay function
;-------------------------------------------------------------------------------
Delay:
    mov.w   #0Ah, R14                  ; Outer loop count (10 iterations)
L2:
    mov.w   #07A00h, R15               ; Inner loop count (3100 iterations)
L1:
    dec.w   R15                        ; Decrement inner loop
    jnz     L1                         ; Repeat until zero
    dec.w   R14                        ; Decrement outer loop
    jnz     L2                         ; Repeat outer loop
    ret

;-------------------------------------------------------------------------------
; Interrupt Service Routine (ISR)
;-------------------------------------------------------------------------------
ISR         dint                         ; Disable interrupts
            mov.b   R4, R5              ; Copy current mode to R5
            xor.b   #1, R5              ; Toggle mode (0 -> 1, 1 -> 0)
            mov.b   R5, R4              ; Store updated mode back to R4
            clr     &P2IFG               ; Clear interrupt flag
            eint                         ; Enable interrupts
            reti                         ; Return from ISR

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack

;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"             ; MSP430 RESET Vector
            .short  RESET
            .sect   ".int03"             ; Port 2 Interrupt Vector
            .short  ISR