.data
	newline: .asciiz "\n"
.text
.globl main
main:
	li $v0, 5
	syscall
	
	add $a0, $v0, $zero

	jal recursion

	add $a0, $v0, $zero
    li  $v0, 1
    syscall

    la $a0, newline
	li $v0, 4
	syscall

    li $v0, 10
    syscall

	
recursion:

	addi $sp, $sp, -12 
	sw   $ra, 0($sp) 
    sw   $s0, 4($sp)
    sw   $s1, 8($sp)

    add $s0, $a0, $zero

    addi $t1, $zero, 1
    beq $s0, $zero, return2 #base cases
    beq $s0, $t1, return5 #base cases
	
	addi $a0, $s0, -1
	
	jal recursion

	mul $s1, $v0, 3 		#multi 3 to (N-1)

	addi $a0, $s0, -2

	jal recursion

	mul 	$v0, $v0, 2 	#multi 2 to (N-2)
	add 	$v0, $v0, $s1	#add 3(N-1) to 2(n-2)
	addi 	$v0, $v0, 1 	#add one to final value

	exitrecursion:
		lw   $ra, 0($sp) 
        lw   $s0, 4($sp)
        lw   $s1, 8($sp)
        addi $sp, $sp, 12       
        jr $ra

return2:
    li $v0, 2
    j exitrecursion

return5:     
    li $v0, 5
    j exitrecursion