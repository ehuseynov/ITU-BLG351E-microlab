       .text
    .global main

main:
    ; Initialize stack pointer
    mov #0x0400, SP

    ; Initialize the parameters for the dot product calculation
    mov #arrayA, r4         ; Load base address of arrayA into R4
    push r4                 ; Push arrayA onto the stack
    mov #arrayB, r5         ; Load base address of arrayB into R5
    push r5                 ; Push arrayB onto the stack
    mov #0, r6              ; Initialize i = 0
    push r6                 ; Push i onto the stack
    mov #5, r7              ; Set N = 5 (length of the arrays)
    push r7                 ; Push N onto the stack
    call #dotProduct        ; Call the dotProduct subroutine

    ; Retrieve the result
    mov @SP+, r8            ; Pop the result into R8

    ; End the program
    jmp End

dotProduct:
    ; Retrieve parameters: N, i, arrayB, arrayA
    mov 2(SP), r7            ; Pop N into R7
    mov 4(SP), r6            ; Pop i into R6
    mov 6(SP), r5            ; Pop arrayB base address into R5
    mov 8(SP), r4            ; Pop arrayA base address into R4

    ; Base case: if i >= N, return 0
    cmp r7, r6              ; Compare i and N
    jge DotBaseCase         ; If i >= N, jump to base case

    ; Recursive case
    ; Compute A[i] * B[i] using repeated addition
    mov 0(r4), r8         ; Load A[i] into R8 (byte)
    mov 0(r5), r9         ; Load B[i] into R9 (byte)

    ; Check if B[i] is negative
    cmp #0, r9              ; Compare B[i] with 0
    jge PositiveB           ; If B[i] is >= 0, jump to PositiveB

    ; If B[i] is negative, manually negate A[i] and B[i] by subtracting from zero
    xor.b #1111111111111111b, r9              ; Negate B[i] (B[i] = 0 - B[i])
    add #1, r9
    mov #0, r10             ; Initialize result in R10 (for multiplication result)
    mov r9, r11             ; Copy B[i] to r11 (counter)
    jmp MultiplyLoop        ; Jump to multiplication loop

PositiveB:
    mov #0, r10             ; Initialize result in R10 (for multiplication result)
    mov r9, r11             ; Copy B[i] to r11 (counter)

MultiplyLoop:
    cmp #0, r11             ; Check if B[i] is zero
    jz EndMultiply          ; If B[i] is zero, end the loop

    add r8, r10             ; Add A[i] (R8) to result (R10)
    dec r11                 ; Decrement the counter (B[i])
    jmp MultiplyLoop        ; Repeat the loop

EndMultiply:
    ; Now R10 contains the product A[i] * B[i]
    ; Push the result onto the stack
    push r10

    ; Push updated parameters for the next recursive call
    inc r4
	inc r4                  ; Increment arrayA pointer
    push r4                 ; Push updated arrayA onto the stack
    inc r5
    inc r5                  ; Increment arrayB pointer
    push r5                 ; Push updated arrayB onto the stack
    inc r6                  ; Increment i
    push r6                 ; Push updated i onto the stack
    push r7                 ; Push N onto the stack
    call #dotProduct        ; Recursive call

    ; Add the recursive result to the current product
    mov 10(SP), r10           ; Pop the recursive result into R10
    add r10, r8             ; Add recursive result to the current product

    ; Push the final result onto the stack and return
    push r8
    ret



DotBaseCase:
    mov #0, r8              ; Base case result is 0
    push r8                 ; Push 0 onto the stack
    ret

End:
    nop                     ; End of program

    ; Data section
    .data
arrayA:
    .word 15, 3, 7, 5, 1     ; Array A elements (byte values)
arrayB:
    .word 2, -1, 7, 3, 5     ; Array B elements (byte values)
