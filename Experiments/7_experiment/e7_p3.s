            .cdecls C,LIST,"msp430.h"       ; Include device header file

            .def    RESET

.data

; Blum-Blum-Shub değişkenleri
p              .word 11
q              .word 13
M              .word 143                    ; M = p * q
seed           .word 5
r              .word 0

; Rastgele sayılar için hafıza alanı
random_numbers .space 128

; Rastgele sayıların sayısını saymak için sayaçlar
count_0        .byte 0
count_1        .byte 0
count_2        .byte 0
count_3        .byte 0
count_4        .byte 0
count_5        .byte 0
count_6        .byte 0
count_7        .byte 0

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
            bis.b   #0x20, &P2IES          ; Set interrupt edge
            bic.b   #0x20, &P2IFG          ; Clear interrupt flag

			mov.w #random_numbers, R13 ; Hafızaya yazma adresini yükle

            bis.w   #GIE, SR               ; Enable global interrupts

main_loop:
            jmp     main_loop


BBS_ISR     push.w  SR
            push.w  R15
            push.w  R14
            push.w  R13

            ; Blum-Blum-Shub algoritması ile rastgele sayı üretimi
            mov.w   seed, R5
            call    #Square                ; s^2
            mov.w   R5, R6
            mov.w   #M, R7
            call    #Mod                   ; (s^2) % M
            mov.w   R5, r                  ; r = (s^2) % M
            mov.w   r, seed                ; s = r

            ; Rastgele sayıyı 0-7 aralığına indirgeme
            and.w   #0x0007, r             ; 0-7 arasında değer elde etme
            mov.b   r, 0(R13)              ; Rastgele sayıyı hafızaya yaz
            inc.w   R13                    ; Hafızada bir sonraki konuma ilerle

            ; Hafızadaki konumun sayısını kontrol et
            cmp.w   #random_numbers+128, R13
            jne     continue_generating

            jmp     write_done

continue_generating:
            ; Burada sayı üretmeye devam edebiliriz
            jmp     BBS_ISR

write_done:
           ; dist kontrol etme
           call #CheckUniformity

            bic.b   #0x20, &P2IFG          ; Clear interrupt flag
            pop.w   R13
            pop.w   R14
            pop.w   R15
            pop.w   SR
            reti

Square:
            push.w  R6
            clr.w   R6
            clr.w   R5
Square_Loop:
            add.w   seed, R6
            dec.w   seed
            jnz     Square_Loop
            mov.w   R6, R5
            pop.w   R6
            ret

Mod:
            push.w  R4
            push.w  R5
            clr.w   R5
Mod_Loop:
            cmp.w   R7, R6
            jlo     Mod_Done
            sub.w   R7, R6
            jmp     Mod_Loop
Mod_Done:
            mov.w   R6, R5
            pop.w   R5
            pop.w   R4
            ret

CheckUniformity:
            mov.w   #random_numbers, R13
            mov.w   #128, R12              ; 128 sayıyı saymak için sayaç
            clr.b   count_0
            clr.b   count_1
            clr.b   count_2
            clr.b   count_3
            clr.b   count_4
            clr.b   count_5
            clr.b   count_6
            clr.b   count_7
count_loop:
            cmp.w   #0, R12
            jeq     count_done
            mov.b   0(R13), R5
            inc.w   R13
            dec.w   R12
            cmp.b   #0, R5
            jeq     incr_count_0
            cmp.b   #1, R5
            jeq     incr_count_1
            cmp.b   #2, R5
            jeq     incr_count_2
            cmp.b   #3, R5
            jeq     incr_count_3
            cmp.b   #4, R5
            jeq     incr_count_4
            cmp.b   #5, R5
            jeq     incr_count_5
            cmp.b   #6, R5
            jeq     incr_count_6
            cmp.b   #7, R5
            jeq     incr_count_7
            jmp     count_loop

incr_count_0:
            inc.b   count_0
            jmp     count_loop
incr_count_1:
            inc.b   count_1
            jmp     count_loop
incr_count_2:
            inc.b   count_2
            jmp     count_loop
incr_count_3:
            inc.b   count_3
            jmp     count_loop
incr_count_4:
            inc.b   count_4
            jmp     count_loop
incr_count_5:
            inc.b   count_5
            jmp     count_loop
incr_count_6:
            inc.b   count_6
            jmp     count_loop
incr_count_7:
            inc.b   count_7
            jmp     count_loop

count_done:
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

            .sect   ".int02"                ; Port 2 interrupt vector
            .short  BBS_ISR                ; Blum-Blum-Shub ISR
