#solution to question 4
#Author: Nadya Balandin
#Date: 28.11.20
#Version: 1
# This program counts how many each character occurs in the given string. 
# Further removes the most common character from the string.

################ Data segment ##################
.data
CharStr: .asciiz "AEZKLBXWZXYALKFKWZRYLAKWLQLEK"
answer1: .asciiz "\nThe most ocurres character in the string is "
answer2: .asciiz "\nNumber of occurs is "
modStr: .asciiz "\nString after changes: "
msg: .asciiz "\nDo you want to repeat a task? Enter 1 – YES or 2 – No\n"
ResultArray: .space 26
NL: .byte '\n'

################ Code segment ##################
.text
.globl main
main:
loop:	la $a0, CharStr			# set $a0 to CharStr
	la $a1, ResultArray		# set $a1 to ResultArray
	move $s0, $a0			# save CharStr address
	move $s1, $a1			# save ResultArray address
	
	lb $t0, 0($s0)			# load first character in the string
	beqz $t0, exit			# string is empty (first character NULL)
	
	jal char_occurences
	move $s2, $v0			# save character that occurs most
	
	############ print result of char_occurences procedure #########
	li $v0, 4
	la $a0, CharStr
	syscall
	la $a0, answer1
	syscall
	li $v0, 11
	move $a0, $s2
	syscall
	li $v0, 4
	la $a0, answer2
	syscall
	li $v0, 1
	move $a0, $v1
	syscall
	########### end of print ############
	
	move $a1, $s1			# restore ResultArray address
	jal print_Char_by_occurrences
	
	move $a0, $s0			# restore CharStr
	move $a1, $s2			# restore character that occurs most
	jal delete
	
	############## print result of delete procedure ###################
	lb $t0, 0($s0)			# load first character in the string after changes
	beqz $t0, exit			# string is empty (first character NULL)
	li $v0, 4
	la $a0, modStr			# print string after modification
	syscall
	move $a0, $s0
	syscall
	la $a0, msg			# print question to continue
	syscall
	li $v0, 5			# read answer
	syscall
	li $t0, 2			# load code for answer to exit
	beq $v0, $t0, exit		# check if user chose exit
	j loop				
	
exit: 	li $v0, 10			# code for exit from programm
	syscall
	
# procedure for searching character that occurs maximum times in the string	
char_occurences:
	addi $sp, $sp, -4		# make room on stack for 1 register
	sw $a0, 0($sp)			# save $a0 on stack (CharStr)
	
########################### counting characters in string ###########################	
# $t0 = i
# $t1 = pointer to current character in CharStr
# $t2 = counter
# $t3 = character for looking
# $t4 = current character in ChatStr
# $t5 = boolean, check if i >= 26 (lenthg of ResultArray)

	move $t0, $zero			# i = 0
aplhabetLoop:	
	move $t1, $a0			
	move $t2, $zero			# count = 0
	addi $t3, $t0, 0x41		# code ascii = i + 'A'
	
	b test_strLoop
strLoop: 			
	addi $t1, $t1, 1		# move pointer to next character in CharStr
	bne $t3, $t4, test_strLoop	# if ResultArray[i] != current character
	addi, $t2, $t2, 1		# else increase counter
test_strLoop:
	lb $t4, 0($t1)
	bnez $t4, strLoop		# character is not NULL ('\0')
	 
	sb $t2, 0($a1)			# save counter for current character
	addi $a1, $a1, 1		# move pointer to next character in RessultArray
	addi $t0, $t0, 1		# increase i
	slti $t5, $t0, 26		# if i < 26 (the last letter in alphabet)
	bne $t5, $zero, aplhabetLoop 

########################### end counting characters in string ###########################	

######################### search character occurs maximum times #########################
# $t0 = index
# $t1 = max
# $t2 = i
# $t3 = number of occurs character - ResultArray[i]
# $t4 = boolean, if ResultArray[i] >= max
# $t5 = boolean, check if i >= 26 (lenthg of ResultArray)
	la $a1, ResultArray		# move pointer back to first char in ResultArray
	move $t0, $zero			# index = 0
	lb $t1, 0($a1)			# max = ResultArray[0]
	move $t2, $zero			# i = 0
findMax:
	addi $t2, $t2, 1		# increase i
	addi $a1, $a1, 1		# move pointer to ResultArray[i]
	lb $t3, 0($a1)		
	slt $t4, $t3, $t1		# ResultArray[i] < max	
	bne $t4, $zero, test_findMax
	move $t1, $t3			# max = ResultArray[i]
	move $t0, $t2			# index = i	
test_findMax:	
	slti $t5, $t2, 25		# if i < 25
	bne $t5, $zero, findMax 
##################### end search character occurs maximum times ######################	
	
	addi $v0, $t0, 0x41	# compute code ascii (index + 'A')
	add $v1, $t1, $zero	# save number of occur
	lw $a0, 0($sp)		# restore $a0 (CharStr) from stack
	addi $sp, $sp, 4	# restore stack pointer
	jr $ra

# procedure for printing all characters from the string in alphabetical order
print_Char_by_occurrences:
# $t0 = i
# $t1 = j
# $t2 = character for print
# $t3 = new line
# $t4 = boolean, check if i >= 26 (lenthg of ResultArray)
	move $t0, $zero			# i = 0
	lb $t3, NL
printArray:
	lb $t1, 0($a1)			# j = ResultArray[i]
	bnez $t1, printCharacter	
test_printArray:	
	addi $t0, $t0, 1		# increase i
	addi $a1, $a1, 1		# move pointer to ResultArray[i]
	slti $t4, $t0, 26		# if i < 26 (last letter in alphabet)
	bne $t4, $zero, printArray 
	jr $ra	
		
printCharacter:
	addi $t2, $t0, 0x41		# code ascii = i + 'A'
	li $v0, 11
	move $a0, $t3
	syscall
	move $a0, $t2
charLoop:
	syscall
	addi $t1, $t1, -1		# decrease j
	bgt $t1, $zero, charLoop	# j >= 0
	b test_printArray

# procedure for deleting character that occurs maximum times from the string
delete:	
	addi $sp, $sp, -4		# make room on stack for 1 register
	sw $ra, 0($sp)			# save $ra on stack (link to return to main)
	
# $t0 = pointer to current character in CharStr
# $t1 = current character
	move $t0, $a0
delLoop: 	
	lb $t1, 0($t0)
	beqz $t1, endLoop		# character is NULL ('\0')	
	beq $t1, $a1, red		# if current character == max occurs character
	addi $t0, $t0, 1		# move pointer to next character in CharStr
	b delLoop
red:
	move $s2, $t0			# save the current posititon in the string 
	move $a0, $t0
	jal reduction			# call to reduction procedure
	move $t0, $s2			# restore the current position
	b delLoop			

endLoop:
	lw $ra, 0($sp)		# restore $ra from stack
	addi $sp, $sp, 4	# restore stack pointer
	jr $ra	
	
# procedure for reducing the string
reduction:
# $t0 = pointer to next character
# $t1 = value next character in string
redLoop:
	addi $t0, $a0, 1
	lb $t1, 0($t0)
	sb $t1, 0($a0)		# CharStr[i] = CharStr[i+1]
	beqz $t1, endReduction	# character is NULL ('\0')
	addi $a0, $a0, 1	# move pointer
	b redLoop
endReduction:
	jr $ra