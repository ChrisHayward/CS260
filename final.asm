#Chris Hayward--Author
#CS260 Final Assignment
.data
ErrorBaseRange:	.asciiz "Error: The given base is outside the accepted range."
		.align 2
ErrorValidChar:	.asciiz "Error: The given string contains at least one invalid character"
		.align 2
testbase13:	.asciiz "1849AC"
		.align 2
testbase10:	.asciiz	"1337"
		.align 2
testbase3:	.asciiz "10210"
		.align 2
testnegbase10:	.asciiz "-1999"
		.align 2
testfailbase13:	.asciiz "DEADBEEF"
		.align 2
testOuterRange:	.asciiz "123U"
		.align 2
testNegBase16:	.asciiz "-FFA1"
		.align 2
newLine:	.asciiz "\n"
		.align 2
test16:		.asciiz "D000"
		.align 2
test162:	.asciiz "D0000000"
		.align 2

.text
main:
		jal testCode
exitprog:	li $v0, 10
		syscall 
stringToInt:

		addi $sp, $sp, -20	# move stack pointer
		sw $ra, 16($sp)		#save $ra to stack
		sw $s3, 12($sp)		#save $s3 to stack,
		sw $s2, 8($sp)		#save $s2 to stack
		sw $s1, 4($sp)		#save $s1 to stack
		sw $s0, 0($sp)		#save $s0 to stack
		
		li, $v0, 0		#set the return initally to 0
		li, $s2, 0		#make sure $s2 starts as 0
		li, $s3, 0		#make sure $s3 starts as 0
checkBase:
		slti $t0, $a1, 2	#sets $t0 to 1 if the base argument is LESS than 2
		slti $t1, $a1, 17	#sets $t1 to 1 if the base argument is LESS than 17
		not $t1, $t1		#bitwise NOT of $t1 so that it gives if the argument is MORE than 16
		andi $t1, $t1, 1
		or $t0, $t1, $t0	#if argument is outside either bound, $t0 should be 1	
		bne $t0, 0, ErrorBase	#if base is outside accepted range, jump to ErrorBase to handle, else continue

checkNeg:	lbu	$t0, 0($a0)	#load first character of string 
		li	$t1, '-'	#load ascii '-' for negative comparison
		bne	$t0, $t1, checkCharValue
		li	$s3, 1		#if string starts with '-' and is therefore negative, set $s3 to 1 for use later
		addi $a0, $a0, 1	#increment to next char
		lbu	$t0, 0($a0)
		
checkCharValue:	
		beqz $t0, doConversion
		jal	isDigitOrNot	#jump to check if current character is a digit or a letter(or something else entirely)
		addi $s2, $s2, 1	#add 1 to count length of given string
		addi $a0, $a0, 1	#increment to next character
		lbu	$t0, 0($a0)	#load next character
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
		beq $s3, 0, returnBookKeep	#checks value stored in $s3 earlier for negative or not, if 0, then positive, and jump to next section
		not $v0, $v0		
		addi $v0, $v0, 1	#twos compliment conversion
		

returnBookKeep:	lw $s0, 0($sp)		# restore $s0 from stack
		lw $s1, 4($sp)		# restore $s1 from stack
        	lw $s2, 8($sp)		# restore $s2 from stack
        	lw $s3, 12($sp)		# restore $s3 from stack
        	lw $ra, 16($sp)		# restore $ra from stack
        	addi $sp,$sp, 20	# restore stack pointer
        	jr $ra
ErrorBase:
		la $a0, ErrorBaseRange
		li $v0, 4
		syscall
		li $v0, 0
		j returnBookKeep
ErrorChar:	
		la $a0, ErrorValidChar
		li $v0, 4
		syscall
		li $v0, 0
		j returnBookKeep



##########################################
#begin test code
##########################################


testCode:
		addi $sp, $sp, -20
		sw $ra, 16($sp)

		li $a1, 17		#test for failue using base 17
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		######
		
		la $a0, testbase13
		li $a1, 13
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		#####
		
		la $a0, testbase10
		li $a1, 10
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		######
		
		la $a0, testbase3
		li $a1, 3
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		######
		
		la $a0, testnegbase10
		li $a1, 10
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		#######
		
		la $a0, testfailbase13
		li $a1, 13
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		#######
		
		la $a0, testOuterRange
		li $a1, 16
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		
		######
		la $a0, testfailbase13	##DEADBEEF with correct base
		li $a1, 16
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
				######
		
		la $a0, testbase13
		li $a1, 13
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		
				######
		la $a0, test16
		li $a1, 16
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		
				######
		la $a0, test162
		li $a1, 16
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall
		
		la $a0, newLine
		li $v0, 4
		syscall
		######
		
		la $a0, testNegBase16
		li $a1, 16
		jal stringToInt
		
		move $a0, $v0
		li $v0, 1
		syscall

		lw $ra, 16($sp)
		addi $sp,$sp, 20
		jr $ra



