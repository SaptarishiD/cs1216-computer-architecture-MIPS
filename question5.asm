
.data
	
	newLinePrint:		.asciiz "\n"
	promptForString: 	.asciiz "Please enter a string of 50 valid characters or less\n"
	printSuccess: 		.asciiz "Yes, the string is a palindrome.\n"
	printFailed: 		.asciiz "No, the string is not a palindrome.\n"
	
	inputString:		
		.space 52	# demarcates space of 52 to store the user's input string.
				# 52 since inputString will store the characters entered along with a newline and the null terminator
				

.text

main:
	
	
	li $v0, 4		# for printing string	
	la $a0, newLinePrint
	syscall
	
	li $v0, 4
	la $a0, promptForString  
	syscall
	
	li $v0, 8   		# for reading string
	la $a0, inputString
	li $a1, 52		# if the user types more than 50 characters then it automatically cut off and ask the user to
				# input 50 valid characters again
				# Moreover, if the user inputs 50 or less characters then a newline is automatically after the last
				# character inputted by the user
				
	syscall    		
		    		
	


	move $t0, $a0 		# t0 now has the address of the input string 
				# hence t0 contains pointer to first character of string
				
	
pointerToLastChar:
				
	move $t1, $t0  		# t1 now also has pointer to first character of string, say B
	
	Loop1: 
		lb $t7, 0($t1)			# t7 now has the value at B, which occupies 1 byte since it is a character
		beq $t7, $zero, decrementB	# if t7 is the null character then jump to label 
		addi $t1, $t1, 1		# if t7 is not null then increase the address stored in t1 by 1
		j Loop1				
	
	
	


decrementB:	
	addi $t1, $t1, -2 			# now t1 has the pointer to the last non-newline and non-null char in string
	
	
	

checkStringLen:
	
	sub $t2, $t1, $t0 		# difference between addresses of last and first characters is stored in $t2 (B-A)
					# if B-A > 49 then length error and re-prompt the user
	li $t3, 49
	bgt $t2, $t3, main
	

#==========================================================================
# the following code checks for special characters within input string which are not space and are not english

checkSpecialChars:
	
	move $t2, $t0		       # t2 now also has pointer to first character of string
	
	specialLoop:
		lb $t7, 0($t2)		
		li $t6, 10		
		beq $t7, $t6, trimLeadingWhiteSpace	# if we hit the newline then no special characters are there	
		
		li $t6, 32
		blt $t7, $t6, main	# if less then ascii value for space = 32 then re-prompt
		sgt $t5, $t7, $t6 	#t5 is 1 if t7 > 32 else t5 is 0
		
		jal more32
		
		addi $t2, $t2, 1	# point to next character
		j specialLoop
		

more32:
	li $t6, 1
	beq $t5, $t6, more32final	# if t7 > 32 then branch
	jr $ra				# reaches this instr if t7 is both not < 32 and > 32 
					# which means t7 is 32 which is valid so return control
	
more32final:
	li $t6, 65			
	blt $t7, $t6, main		# t7 > 32 and < 65 then re-prompt
	bgt $t7, $t6, more65		# t7 > 65 then branch
	jr $ra				# t7 = 65 so its valid so return control

more65:
	li $t6, 90			
	bgt $t7, $t6, more90		# t7 > 90 then branch	
	jr $ra				# t7 > 65 and <= 90 so its valid so return control
	

more90:
	li $t6, 97
	blt $t7, $t6, main		# t7 > 90 and < 97 then re-prompt
	bgt $t7, $t6, more97		# t7 > 97 then reprompt
	jr $ra				# t7 = 97 so its valid

more97:
	li $t6, 122
	bgt $t7, $t6, main		# t7 > 122 then re-prompt
	jr $ra				# t7 > 97 and <= 122 which is valid
	
#==========================================================================		
	
	

trimLeadingWhiteSpace:
	
	move $t2, $t0 			# t2 has pointer to first char of string
	
	leadingLoop:
		lb $t7, 0($t2)
		li $t6, 32
		bne $t7, $t6, trimTrailingWhiteSpace # if $t7 val not a space then t2 points to first english character in string so then branch to trimming trailing
		addi $t2, $t2, 1		     # if $t7 val is a space then increment $t2 to point to the next char
		j leadingLoop

		
trimTrailingWhiteSpace:
	
	move $t3, $t1 		#now t3 has the pointer to the last char in string before \n and \0
	
	trailingLoop:
		lb $t7, 0($t3)
		li $t6, 32
		bne $t7, $t6, lowerToUpper  # if $t7 val not a space then t2 points to last english character in string so then branch to case conversion
		addi $t3, $t3, -1	    # if $t7 val is space then decrement $t2
		j trailingLoop
		
		
lowerToUpper:
	
	move $t4, $t2			# $t4 points to first non-space char in string
	
	caseLoop:
		lb $t7, 0($t4)
		beq $t7, $zero, decrementLastCharPointer # if reached end of string then branch
		li $t6, 90 
		sgt $t5, $t7, $t6		 # if $t7 has a lowercase char then set $t5 to 1 else if upper then set to 0
		
		jal convertCase
		
		addi $t4, $t4, 1		# increment $t4 to point to next char
		j caseLoop
		
convertCase:
	
	li $t6, 1
	beq $t5, $t6, convertCaseFinal 	# if lowercase then convert to uppercase
	jr $ra				# if uppercase then return control



convertCaseFinal:
	
	addi $t7, $t7, -32	# converts case
	sb $t7, 0($t4)		# stores converted value in correct place
	jr $ra
	

decrementLastCharPointer:
	
	addi $t4, $t4, -2	# point to last char before \n and \0
		
	
movingStuff:
	
	move $t0, $t2 		# $t0 now points to first english char
	move $t1, $t3 		# $t1 now points to last english char
	
	

palindromeLoop:

	bge $t0, $t1, printSuccessLabel		# if the address in t0 (A), is >= the address in t1 (B), then go to printSuccessLabel
	lb $t2, 0($t0) 				# contents of 0($t0) in t2 so t2 has *A which is the value at address t0
	lb $t3, 0($t1) 				# contents of 0($t1) in t3 so t3 has *B which is the value at address t1
	bne $t2, $t3, printFailedLabel		# if the values are not equal then the string is not a palindrome
	addi $t0, $t0, 1			# increment the address in t0 by 1 so it now has the address of the next character
	addi $t1, $t1, -1			# decrement the address in t1 by 1 so it now has the address of the previous character
	j palindromeLoop
	


printSuccessLabel:
	li $v0, 4
	la $a0, printSuccess
	syscall
	j exit
	
	

printFailedLabel:
	li $v0, 4
	la $a0, printFailed
	syscall
	j exit



exit:
	li $v0, 10    
	syscall
	

	
	
	
	 
	
	
	
	
	
	



