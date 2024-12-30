.cdecls C,LIST,"msp430.h"       ; Include device header file

            .def    RESET

.data
; Define segment mapping array
array:
    .byte   00111111b, 00000110b, 01011011b, 01001111b
    .byte   01100110b, 01101101b, 01111101b, 00000111b
    .byte   01111111b, 01101111b

.text
            .retain
            .retainrefs

RESET       mov.w   #__STACK_END, SP       ; Initialize stack pointer
StopWDT     mov.w   #WDTPW|WDTHOLD, &WDTCTL; Stop watchdog timer
            bis.b   #0xFF, &P1DIR          ; Set Port 1 as output for 7-segment
            clr.b   &P1OUT                 ; Clear output
            bis.b   #0x20, &P2IE           ; Enable interrupt on P2.5
            and.b   #0DFh, &P2SEL
            and.b   #0DFh, &P2SEL2
            bis.b   #0x20, &P2IES          ; Set interrupt edge
            clr     &P2IFG          ; Clear interrupt flag
            mov.w   #5, r13         ;s

            mov.w   #0, r15         ; w
           mov.w    #0, r12         ; x
           eint

main_loop:
            jmp     main_loop

MSWS_ISR    dint
            ; x = square(x)
            mov.b   R12, R14               ; Use R14 for x (replace x with R12)
            call    #Square

            ; x = x + (w = w + s)
            add.b   R13, R15               ; w = w + s (R13 holds s, R15 is used for w)
            add.b   R15, R12               ; x = x + w
            ; mov.b   R14, R12               ; Save the new x value back to R12

            ; r = (x >> 4) | (x << 4)
            mov.b   R12, R14               ; Copy x to R14 (R14 will hold the shifted value)
            rra.b   R14
            rra.b   R14
            rra.b   R14
            rra.b   R14
            mov.b   R12, R10               ; Copy x to R15 for the left shift
            rla.b   R10
            rla.b   R10
            rla.b   R10
            rla.b   R10
            bis.b   R10, R14               ; Combine the left and right shifts into R14

            ; Display the random number
            mov.b   R14, R5
            call    #DisplayNumber

            bic.b   #0x20, &P2IFG          ; Clear interrupt flag
            eint
            reti

Square:
            push.w  R6
            clr.w   R6
            clr.w   R5
            mov.b   R12, R11              ; Use R11 to store x

Square_Loop:
            add.b   R12, R6                ; Add x to the accumulator
            dec.b   R11                    ; Decrement the loop counter
            cmp     #0, R11                ; Compare to zero
            jlo     Square_Loop            ; Loop until R11 reaches zero
            mov.b   R6, R5                 ; Store the result in R5
            pop.w   R6
            ret

DisplayNumber:

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
            .short  MSWS_ISR                ; Middle Square Weyl Sequence ISR