.cdecls C,LIST,"msp430.h"       ; Include device header file

            .def    RESET

.data

; Blum-Blum-Shub variables
p              .word 11
q              .word 13
M              .word 143                    ; M = p * q
seed           .word 5
rr              .word 0

; Define segment mapping array
array:
    .byte  0x3F  ; 0
    .byte  0x06  ; 1
    .byte  0x5B  ; 2
    .byte  0x4F  ; 3
    .byte  0x66  ; 4
    .byte  0x6D  ; 5
    .byte  0x7D  ; 6
    .byte  0x07  ; 7
    .byte  0x7F  ; 8
    .byte  0x6F  ; 9

.text
            .retain
            .retainrefs

RESET       mov.w   #__STACK_END, SP       ; Initialize stack pointer
StopWDT     mov.w   #WDTPW|WDTHOLD, &WDTCTL; Stop watchdog timer
            mov.b #0d, P2SEL
            mov.w  #0x05, R11
            bis.b   #0xFF, &P1DIR          ; Set Port 1 as output for 7-segment
            clr.b   &P1OUT                 ; Clear output
            mov.w   #0x0F,  &P2DIR
            clr.b   &P2OUT
            bis.b   #0x20, &P2IE           ; Enable interrupt on P2.5
            and.b   #0DFh, &P2SEL
            and.b   #0DFh, &P2SEL2
            bis.b   #0x20, &P2IES          ; Set interrupt edge
            clr.b   &P2IFG          ; Clear interrupt flag

            eint

main_loop:

            ; Convert the value in 'r' to 7-segment display format
            mov.w   r11, R5             ; Copy result (r) to R5
            mov.b   #8h, &P2OUT
            and.w   #0x0F, R5          ; Get the lower nibble (ones place)
            mov.b   array(R5), &P1OUT  ; Display the ones digit

            clr     &P2OUT
            clr     &P1OUT

            ; Update the display for tens digit
            mov.w   r11, R5             ; Copy result (r) to R5
            rra R5                  ; Swap high and low bytes (tens place now in low byte)
            rra R5
            rra R5
            rra R5
            and.w   #0x0F, R5         ; Get the tens digit (upper nibble)
            mov.b   #4h, &P2OUT
            mov.b   array(R5), &P1OUT ; Display the tens digit


            clr     &P2OUT
            clr     &P1OUT
            jmp     main_loop

BBS_ISR     dint
            mov.w   r11, R5
            call    #Square                ; s^2
            mov.w   R5, R6
            mov.w   #143, R7
            call    #Mod                   ; (s^2) % M
            mov.w   R5, r11               ; s = r

            ; 7-segment display update


            bic.b   #0x20, &P2IFG          ; Clear interrupt flag
            eint
            reti

Square:
            clr.w   R6          ;
            clr.w   R5          ;
            mov.w   r11, R6    ;

Square_Loop:
            add.w   r11, R5      ;
            dec.w   R6          ;
            cmp     #0, R6      ;
            jne     Square_Loop ;
            ret

Mod:
            push.w  R4

Mod_Loop:
            cmp.w   R7, R5
            jlo     Mod_Done
            sub.w   R7, R5
            jmp     Mod_Loop
Mod_Done:


            pop.w   R4
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

            .sect   ".int03"                ; Port 2 interrupt vector
            .short  BBS_ISR                ; Blum-Blum-Shub ISR