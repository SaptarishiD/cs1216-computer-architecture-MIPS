#ASSUMPTIONS: I assume that the input number is small enough such that I can use the mul instruction which only deals with 32 bits
# Hence I assume that the input will be lesser or equal to the decimal number 1023, since for the interesting procedure does N(N+1)(2N+1)
# which, if N is > 1023, results in a number greater than the largest number that can be stored in a MIPS 32 bit register. Hence, I assume N
# to be <= 1023 for the product to be computed properly using the Interesting procedure

# For the Naive procedure to work properly I assume N to be <= 1860 for the same reason as above


.data

	promptInteger:		.asciiz "Enter N: "
	errorMessage:		.asciiz "Input is erroneous\n"
	naivePrinting:		.asciiz "Naive: "
	interestingPrinting:	.asciiz "Interesting: "
	newLinePrint:		.asciiz "\n"



.text

main:
	
	li $v0, 4
	la $a0, promptInteger
	syscall
	
	li $v0, 5			# for reading an integer
	syscall
	
	move $s0, $v0  			# s0 now has N
	
	li $t0, 1
	
	blt $s0, $t0, errorLabel	# if N < 1 then give an error
	
	li $v0, 4
	la $a0, newLinePrint
	syscall
	
	jal Naive
	
	li $v0, 4
	la $a0, newLinePrint
	syscall
	
	
	jal Interesting
	
	j exit
	

	
	
	

errorLabel:
	li $v0, 4
	la $a0, errorMessage
	syscall
	j exit
	
	
	
	
Naive:  
	
	move $t1, $s0			# t1 now has N
	
	Loop1: 
		beq $t1, $t0, addOne	# jumps to label addOne if the value in t1 has become 1
		mul $t3, $t1, $t1	# multiples the value in t1 with itself and stores the result in t3
		add $t4, $t4, $t3	# adds the value of t4 and t3, then stores the result in t4
		subi $t1, $t1, 1	# decrements the value in t1 by 1
		j Loop1 
					

addOne:
	addi $t4, $t4, 1
	j printNaiveResult
	

printNaiveResult:
	
	li $v0, 4
	la $a0, naivePrinting
	syscall
	
	li $v0, 1		# for printing an integer
	move $a0, $t4
	syscall
	
	jr $ra			# returns control back to the instruction after jal was called for Naive
	
	
			
	
			
Interesting:

	move $t2, $s0		# t2 now has N
	
	addi $t2, $t2, 1 	# adds 1 to n and stores (n+1) in t2
	mul $t5, $s0, $t2 	# multiplies n with (n+1) and stores the result in t5
	add $t7, $s0, $s0 	# adds n with itself and stores the result 2n in t7
	addi $t7, $t7, 1  	# adds 1 to 2n and stores the result in t7
	mul $t5, $t5, $t7  	# multiplies n(n+1) with (2n+1) and stores the result in $t5
	
	li $t1, 6
	div $t6, $t5, $t1	# divides n(n+1)(2n+1) whole by 6
	
	li $v0, 4
	la $a0, interestingPrinting
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	jr $ra			
	
	

	
exit:
	li $v0, 10    		# code for terminating execution
	syscall