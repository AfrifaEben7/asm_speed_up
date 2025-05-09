/*
This function serves as the comparison function. Initially, it compares the sizes of two numbers. 
If the sizes are equal, it proceeds to examine the signs of the numbers and returns the comparison 
result accordingly. In cases where the signs are the same, it conducts a thorough comparison of 
individual digits, proceeding from the end to the start of the numbers.

On the other hand, when the sizes are unequal, the function takes into account the sign of the numbers. 
If both numbers are positive, the one with the greater length is considered greater in value.
*/
	.text
	.type bigint_cmp, %function
	.global bigint_cmp

bigint_cmp:
	//store the regs on stack 
    stp x29, x30, [sp, #-16]!     
    stp x27, x28, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

	//move adr of bigints
	mov x27, x0
	mov x28, x1

	//get size of the bigints
	ldr w25, [x27,#8]
	ldr w26, [x28,#8]

	//compare the sizes
	cmp x25,x26
	
	//decrease size by 1 to get the last 64 bits
	sub x25, x25, #1
	sub x26, x26, #1

	//branch to Firstlonger if size1>size2
	bgt Firstlonger 
	//branch to Secondlonger if size1<size2
	blt Secondlonger

	//if size is equal
	ldr x23, [x27]  	//load the first 64 bits of a
	ldr x24, [x28]   	//load the first 64 bits of b

	mov x12, x25
	lsl x12, x12 ,#3
	ldr x1, [x23, x12] 	//load the last 64 bits
	ldr x2, [x24, x12] 	//load the last 64 bits
	lsr x1, x1, #63		//get the last bit
	lsr x2, x2, #63		//get the last bit

	//compare the last bit to find out whether the signs are different
	cmp x1, x2
	//compare all chunks if size and sign are equal
	beq Comparechunks

	//if signs are different, check the positive one
	mov x3, #0 	//move 0 to x3
	cmp x1, x3
	beq Firstgreater
	bgt Secondgreater

//first number is greater
Firstgreater: 
	mov x0, #1	//return 1
	b return

//second number is greater
Secondgreater:
	mov x0, #-1	//return -1
	b return

//both numbers are equal
Bothequal:
	mov  x0, #0	//return 0
	b return

//compare all the chunks
Comparechunks:
	cmp x25, #0	//compare till size is 0
	//if size = 0, both are equal
	blt Bothequal

	//load 64 bits from the end
	mov x12, x25
	lsl x12, x12 ,#3
	ldr x1, [x23, x12]
	ldr x2, [x24, x12]

	sub x25, x25, #1	//decrement size

	//compare bits
	cmp x1, x2

	//branch back to top if equal
	beq Comparechunks
	//if less than, branch to second greater
    blo Secondgreater 
	//else branch to first greater
	b Firstgreater

//first one longer
Firstlonger: 
	ldr x24, [x27]	//load the first 64 bits

	//load the last 64 bits, last=first+ (size-1)*64
	mov x12, x25
	lsl x12, x12 ,#3
	ldr x23, [x24, x12]

	lsr x23, x23, #63	//shift by 63 to check the sign

	//compare the sign bit
	cmp x23, #0
	//if first one is +ve, its greater
	beq Firstgreater
	//second one is greater
	b Secondgreater

Secondlonger:
	ldr x24, [x28]		//load the first 64 bits

	//load the last 64 bits, last=first+ (size-1)*64
	mov x12, x26
	lsl x12, x12 ,#3
	ldr x23, [x24, x26, lsl #3]
	lsr x23, x23, #63	//shift by 63 to check sign

	cmp x23, #0
	//if second one i spositive, its greater
	beq Secondgreater
	//else first one is greater
	b Firstgreater

return:
	//restore the reg stack
    ldp x19, x20, [sp], #16
    ldp x21, x22, [sp], #16
	ldp x23, x24, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x27, x28, [sp], #16
    ldp x29, x30, [sp], #16 	
	ret	

	.size bigint_cmp,(. - bigint_cmp)
	
