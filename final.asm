#Chris Hayward--Author
#CS260 Final Assignment
.data
ErrorBaseRange:	.asciiz "Error: The given base is outside the accepted range."
		.align 2
ErrorValidChar:	.asciiz "Error: The given string contains at least one invalid character"
		.align 2


.text
main:
stringToInt:

		addi $sp, $sp, -20	# move stack pointer
		sw $ra, 16($sp)		#save $ra, $s3, $s2, $s1, and $s0 to stack
		sw $s3, 12($sp)		
		sw $s2, 8($sp)		
		sw $s1, 4($sp)		
		sw $s0, 0($sp)		
		
		li, $v0, 0		#set the return initally to 0
		li, $s2, 0		#make sure $s2 and $s3 start as 0
		li, $s3, 0		
checkBase:
		slti $t0, $a1, 2	#sets $t0 to 1 if the base argument is LESS than 2
		slti $t1, $a1, 17	#sets $t1 to 1 if the base argument is LESS than 17
		not $t1, $t1		#bitwise NOT of $t1 so that it gives if the argument is MORE than 16
		andi $t1, $t1, 1	#removes extraneous 1's created by the previous NOT
		or $t0, $t1, $t0	#if argument is outside either bound, $t0 should be 1	
		bne $t0, 0, ErrorBase	#if base is outside accepted range, jump to ErrorBase to handle, else continue

checkNeg:	lbu	$t0, 0($a0)	#load first character of string 
		li	$t1, '-'	#load ascii '-' for negative comparison
		bne	$t0, $t1, checkCharValue
		li	$s3, 1		#if string starts with '-' and is therefore negative, set $s3 to 1 for use later
		addi $a0, $a0, 1	#increment and load next char
		lbu	$t0, 0($a0)
		
checkCharValue:	
		beqz $t0, doConversion
		jal	isDigitOrNot	#jump to check if current character is a digit or a letter(or invalid)
		addi $s2, $s2, 1	#add 1 to count length of given string
		addi $a0, $a0, 1	#increment and load next character
		lbu	$t0, 0($a0)	
		j checkCharValue

isDigitOrNot:		
		li $t1, '9'
		bltu $t1, $t0, isNotDigit	#checks if the current character is between 0 and 9 inclusive 
		li $t1, '0'
		bltu $t0, $t1, isNotDigit
		
		sub $t6, $t0, $t1		#gets value of digit
		slt $t2, $t6, $a1		#if this gives a value of 1, then the digit is valid for the given base
		beq $t2, $0, ErrorChar		
		
		jr	$ra
isNotDigit:	
		li $t1, 'F'
		bltu $t1, $t0, ErrorChar
		li $t1, 'A'
		bltu $t0, $t1, ErrorChar	#checks if character is between 'A' and 'F'. if outside this range then go to ErrorChar
		sub $t6, $t0, $t1
		addi $t6, $t6, 10		#adds 10 to value since letters should only show up after 0-9
		slt $t2, $t6, $a1		#if value is less than base value, treat as valid, 
		beq $t2, $0, ErrorChar		#otherwise jump to ErrorChar
		
		jr	$ra

doConversion:
		li $s0, 0		#digit starting at 0
		li $v0, 0		#result starting at 0
		li $s1, 1		#position value starting at 1
		
Loop:		slt $t3, $s0, $s2	#beginning test for while loop given in assignment instructions
		beqz $t3, endLoop
		addi $a0, $a0, -1	#on the first run through of this loop $a0 should be pointing at the null terminator of the given string, 
		lbu $t0, 0($a0)		#this loop then reads through the string from least significant to most
		jal isDigitOrNot	#loads value of character in $t0 into $t6
		mul $t6, $t6, $s1	# currentDigitValue*PositionValue
		add $v0, $v0, $t6	# result=result+currentDigitValue*PositionValue
		mul $s1, $s1, $a1	# positionValue = positionValue*base
		addi $s0, $s0, 1	# digit = digit+1
		j Loop
				
endLoop:
		beq $s3, 0, returnBookKeep	#checks value stored in $s3 earlier for negative or not, if 0, then result should be positive, and jump to next section
		not $v0, $v0		
		addi $v0, $v0, 1	#twos compliment conversion
		

returnBookKeep:	lw $s0, 0($sp)		# restore $ra, $s3, $s2, $s1, and $s0 from stack
		lw $s1, 4($sp)		
        	lw $s2, 8($sp)		
        	lw $s3, 12($sp)		
        	lw $ra, 16($sp)		
        	addi $sp,$sp, 20	# restore stack pointer
        	jr $ra
ErrorBase:
		la $a0, ErrorBaseRange	#Prints Base Error message
		li $v0, 4
		syscall
		li $v0, 0
		j returnBookKeep
ErrorChar:	
		la $a0, ErrorValidChar	#Prints Invalid Character Error message
		li $v0, 4
		syscall
		li $v0, 0
		j returnBookKeep
