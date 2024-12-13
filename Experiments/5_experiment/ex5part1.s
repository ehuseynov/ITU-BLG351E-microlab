;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
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
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer
			mov.b	#0d, P2SEL


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------



    mov.w   #0xFF, &P1DIR      ; Set Port 1 as output
    mov.w   #0x00, &P1SEL      ; Set Port 2 as output
    mov.w	#0x00, &P1OUT
	mov.w	#0x00, R12



    ; Main loop
main_loop:

    cmp.w   #10, R12            ; Check if counter exceeds 9
    jge     reset_counter
    mov.b   array(R12), &P1OUT ; Load corresponding 7-segment pattern
    call    #Delay             ; 1-second delay
    add.w   #1, r12       ; Increment counter
    jmp     main_loop

reset_counter:
    clr.w   R12            ; Reset counter to 0
    jmp     main_loop

; Delay function
Delay:
    mov.w   #0Ah, R14          ; Outer loop count
L2:
    mov.w   #07A00h, R15       ; Inner loop count
L1:
    dec.w   R15                ; Decrement inner loop
    jnz     L1                 ; Repeat until zero
    dec.w   R14                ; Decrement outer loop
    jnz     L2                 ; Repeat outer loop
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