/*
This function exhibits enhanced computational prowess by engaging 
in a meticulous process of addition with carry, systematically 
processing 64 bits at a time until it traverses the entirety of 
one numerical value. Notably, it incorporates a mechanism to 
handle the inherent sign of the numbers, ensuring a comprehensive 
and accurate addition operation.
*/
    .text
    .type bigint_adc, %function
    .global bigint_adc

bigint_adc:
     //store regs on stack
     stp x29, x30, [sp, #-16]!     
     stp x27, x28, [sp, #-16]!
     stp x25, x26, [sp, #-16]!
     stp x23, x24, [sp, #-16]!
     stp x21, x22, [sp, #-16]!
     stp x19, x20, [sp, #-16]!
     
     mov x23, x0 //first bigint
     mov x24, x1 //second bigint
     mov x25, x2 //carry
     
     //get size and load adr of both bigints
     ldr w26, [x23, #8]
     ldr w27, [x24, #8]
     ldr x19, [x23]
     ldr x20, [x24]
     
     cmp x26, x27               //compare the sizes of both the bigints
     csel x28, x26, x27, gt     //get size of the greater bigint
     add x28, x28, #1          //allocate size of greater bigint +1 to store sum
     
     mov  x0, x28               //move bigint to x0 to allocate memory
     bl bigint_alloc 
     mov x22, x0                //move allocated bigint to x22

     cmp x26, x27               //compare size
     csel x5, x20, x19, le      //contains bigger number of the 2
     csel x6, x26, x27, le      //contains smaller number of the 2
     csel x7, x19, x20, le      //contains smaller number
     
     //load the address of the resulting bigint
     ldr x4, [x22]
     sub w28, w28, #1
     
     //initiize i and j
     mov x8, #0
     mov x9, #0
     mov x0, #0
     mov x2, #0

First:
     cmp x8, x28                //compare if i==size
     //if i==size branch to result
     bge Result

     asr x0, x2, #63            //write bit in x0 
     
     //if second number is bigger brand to next
     cmp x9, x6
     bge Next
     
     //load from x7 + x9* 64
     mov x15,x9
     lsl x15, x15, #3
     ldr x2, [x7, x15]
     add w9, w9, #1             //increment j
     mov x0, x2                 //move 64 bits to x0

Next:
     //load from the second number
     mov x15, x8
     lsl x15, x15, #3
     ldr x1, [x5, x15]
     b Addition

Addition:
     // compare to set the carry flag
     cmp x25, #1
     adcs x3, x0, x1            //add carry flag and set it
     cset x25, cs               //set carry flag to x25
     b Storenums

Storenums:
     //store the number in x4 + x8*64
     mov x15, x8
     lsl x15, x15, #3
     str x3, [x4, x15]
     
     add w8, w8, #1             //increment i
     b First

Result:
     //comparing the sign
     asr x1, x1, #63            //shift the first number by 63 bits to get sign bit
     asr x2, x2, #63            //shift the second number by 63 bits to get sign bit
     cmp x25, #1                //compare the sign of first number to set carry
     adc x1, x2, x1             //add with carry to get the sign bit
     //store the number
     lsl x3, x8, #3
     str x1, [x4, x3]
     
     //branch and link to trim(new trim void)
     mov x0, x22
     bl bigint_trim_void
     mov x0, x22                //return trimed number
     
     //restore stack regs
     ldp x19, x20, [sp], #16
     ldp x21, x22, [sp], #16
     ldp x23, x24, [sp], #16
     ldp x25, x26, [sp], #16
     ldp x27, x28, [sp], #16
     ldp x29, x30, [sp], #16
     ret

     .size   bigint_adc,(. - bigint_adc)
     