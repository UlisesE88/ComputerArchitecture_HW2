.data
	newline: .asciiz "\n"
.text
main:
	li $v0, 5
	syscall
	move $t0, $v0 #saving N into t0

	addi $t1, $t1, 0 #this is i
	addi $t2, $t2, 0 #intiazing t2 to hold 13
	addi $t3, $t3, 0 #initizing product value


	addi $t2, $t2, 13

	loop:
		beq $t1, $t0, exit  
		addi $t1, $t1, 1 # i++

		# mul $t3, $t1, $t2 #stores the prduct into t3

		mult $t1, $t2
		mflo $t3

		li $v0, 1
		move $a0, $t3
		syscall

		li $v0, 4
		la $a0, newline #newline
		syscall
		
		j loop
exit:
	li $v0, 10
	syscall