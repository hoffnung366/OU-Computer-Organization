#solution to question 3
#Author: Nadya Balandin
#Date: 01.12.20
#Version: 1
# This program reverses the order of the bits in received number

################ Data segment ##################
.data
msg: .asciiz "\nPlease enter a number in the  range -9999....9999\n"
error_msg: .asciiz "\nThe number is illegal. Enter a new number in the range.\n"

################ Code segment ##################
.text
.globl main
main:
	li $v0, 4
	la $a0, msg			# print welcome message
	syscall				
get_input:
	li $v0, 5
	syscall				# read int from keyboard
	slti $t0, $v0, -9999
	not $t0, $t0			# set $t0 to 1 if number in range (bigger than -10000)		
	slti $t1, $v0, 10000		# set $t1 to 1 if number in range (less than 10000)			
	and $t2, $t1, $t0		
	bne $t2, $zero, continue	# if number in range - continue
	li $v0, 4			# else try again
	la $a0, error_msg
	syscall
	j get_input

# $s0 = number
# t0 = mask
# $a0 = current bit
# $t1 = number after reverse
# $t2 = sign (0 is positive, 1 is negative)

continue:
	move $s0, $v0			# save the number
	li $v0, 1
	li $t0, 0x8000			# mask 0000 0000 0000 0000 1000 0000 0000 0000
	move $t1, $zero
print_16_bit:
	and $a0, $s0, $t0		# bit №16
	beq $a0, $zero, print_digit	# print 0 
	li $a0, 1			# print 1
print_digit:
	syscall
	srl $t0, $t0, 1			# shift right to mask
	bne $t0, $zero, print_16_bit	# if mask is not zero - go back to loop
	
	move $t2, $a0			# save last bit in original number for sign extending for reverse number
	
	li $v0, 11
	li $a0, '\n'			# new line
	syscall
	
	
	li $v0, 1			
	li $t0, 0x1			# mask 0000 0000 0000 0000 0000 0000 0000 0001
print_16_bit_reverse:
	and $a0, $s0, $t0
	beq $a0, $zero, print_digit_reverse
	li $a0, 1
	
print_digit_reverse:
	syscall
	sll $t0, $t0, 1
	sll $t1, $t1, 1
	or $t1, $t1, $a0		# fill bit in new number (after reverse)
	bne $t0, 0x10000, print_16_bit_reverse
	
	li $v0, 11
	li $a0, '\n'			# new line
	syscall
			
	beqz $t2, print_decemal		# don't need sign extending, number is positive
	addi $t0, $zero, 0xFFFF0000	# mask for sign extending 1111 1111 1111 1111 0000 0000 0000 0000
	or $t1, $t1, $t0
	
print_decemal:
	li $v0, 1
	move $a0, $t1
	syscall 
	   
	li $v0, 10			#exit programm
	syscall