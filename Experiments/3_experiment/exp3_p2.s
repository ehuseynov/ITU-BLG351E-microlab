
		.data
hash_table .space 58
split_ids  .word 123, 7, 789

        .text

        mov.w   #hash_table, R5
        mov.w   #29, R6
        mov.w   #-1, R7

InitializeHashTable:
        mov.w   R7, 0(R5)
        add.w   #2, R5
        dec.w   R6
        jnz     InitializeHashTable

        mov.w   #split_ids, R4
        mov.w   #hash_table, R5
        mov.w   #3, R6

HashLoop:
        mov.w   @R4+, R7
        clr.w   R8
        mov.w   R7, R9

HashFunction:
        cmp.w   #29, R9
        jl      HashDone
        sub.w   #29, R9
        jmp     HashFunction

HashDone:
        mov.w   R9, R8

        mov.w   R5, R10
        rla.b		R8
        add.w   R8, R10
CollisionCheck:
        cmp.w   #-1, 0(R10)
        jeq     PlaceInTable
        add.w   #2, R10
        jmp     CollisionCheck

PlaceInTable:
        mov.w   R7, 0(R10)
        dec.w   R6
        jnz     HashLoop

Stop 	jmp       Stop

