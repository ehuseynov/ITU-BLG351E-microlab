; Main loop here
     .text
    .global main

main:

    ; Example: Call Add(5, 3)
    mov #5, r4              ; Load the first parameter into R4
    push r4                 ; Push the first parameter onto the stack
    mov #3, r5              ; Load the second parameter into R5
    push r5                 ; Push the second parameter onto the stack
    call #Add               ; Call the Add subroutine

    ; Retrieve the result from the stack



    ; End the program
    push r4
    jmp End

Add:
    mov 2(SP), r4            ; Pop the first parameter into R4
    mov 4(SP), r5            ; Pop the second parameter into R5
    add r5, r4              ; Add the two numbers, result in R4
    ret                     ; Return to the caller

End:
	mov	@SP, r6

Stop	jmp Stop; End of the program








; Main loop here
     .text
    .global main

main:

    ; Example: Call Add(5, 3)
    mov #5, r4              ; Load the first parameter into R4
    push r4                 ; Push the first parameter onto the stack
    mov #3, r5              ; Load the second parameter into R5
    push r5                 ; Push the second parameter onto the stack
    call #Subtract               ; Call the Add subroutine

    ; Retrieve the result from the stack



    ; End the program
    push r5
    jmp End

Subtract:
    mov 2(SP), r4            ; Pop the first parameter into R4
    mov 4(SP), r5            ; Pop the second parameter into R5
    sub r4, r5              ; sub the two numbers, result in R4
    ret                     ; Return to the caller

End:
	mov	@SP, r6

Stop	jmp Stop; End of the program




  .text
    .global main

main:

    ; Example: Call Add(5, 3)
    mov #5, r5              ; Load the first parameter into R4
    push r5                 ; Push the first parameter onto the stack
    mov #3, r4              ; Load the second parameter into R5
    push r4                 ; Push the second parameter onto the stack
    mov #0, r6


    ; Retrieve the result from the stack

	call #MultiplyLoop

    ; End the program
    jmp End

                     ; Return to the caller
MultiplyLoop:
    cmp #0, r5              ; Check if the multiplier is 0
    jz MultiplyEnd          ; If 0, exit loop
    call #Multiply               ; Add(R6, R4)

    jmp MultiplyLoop        ; Repeat

Multiply:
    mov 4(SP), r4            ; Pop the first parameter into R4
    add r4, r6            ; Pop the second parameter into R5
    dec	r5
    ret




MultiplyEnd:
    push r6                 ; Push the final result onto the stack
    add #2, SP
    ret                     ; Return to the caller
End:


Stop	jmp Stop; End of the program



	