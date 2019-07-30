.data
name:			.asciiz "Pizza name: "
diameter:		.asciiz "Pizza diameter: "
cost:			.asciiz "Pizza cost: "
DONE_word: 		.asciiz "DONE\n"
newline: 		.asciiz "\n"

zeroAsFloat: .float 0.0
PI: .float 3.14159265358979323846
FourAsFloat: .float 4.0

.text
.globl main
main:	

##########################################Creating the link list#####################################################
#####################################################################################################################
Create_new_list:

	li $a0, 72			
	li $v0, 9						# allocated byte space for one struct 
	syscall								

	move $s0, $v0
	move $s5, $v0					# s5 head of the list

	li $v0, 4						
	la $a0, name 					# Pizza input
	syscall						

	li $v0, 8 						
    move $a0, $s0	 				
    li $a1, 64 						
    syscall
        						
    la $a1, DONE_word

    jal strcmp
    bnez $v0, continue
    beq $v0,$zero,DONE_first 		# go to DONE if the first word entered is DONE

	sw $s0, 0($s1)		

strcmp:								# compares each input to the word DONE
	addi $sp, $sp, -16		
    sw $ra, 0($sp)			
    sw $t0, 4($sp)		
    sw $t1, 8($sp)			
    sw $t2, 12($sp)				

    add $t0,$zero,$zero
    add $t1,$zero,$a0
    add $t2,$zero,$a1

    loop:
        lb $t3($t1)  #load a byte from each string
        lb $t4($t2)  #DONE

        beqz $t3,out 
        beqz $t4,missmatch

        bne $t3,$t4, missmatch  
        addi $t1,$t1,1  
        addi $t2,$t2,1
    j loop

    out:
        bnez $t4,missmatch
        add $v0,$zero,$zero
        j endfunction

    missmatch: 
        addi $v0,$zero,1
        j endfunction

endfunction:
    lw $t1, 8($sp) 
	lw $t0, 4($sp) 				
	lw $ra, 0($sp)				
	addi $sp, $sp, 16
    jr $ra


DONE_first:
	li	$v0, 10					# exit if first input is DONE
	syscall	

continue:						
    addi $s8, $s8, 1			# s8 stores the number of nodes in the list
   	addi $s0, $s0, 64			

	l.s $f26, zeroAsFloat		# put zero into f26
						
	li $v0, 4					
	la $a0, diameter 			
	syscall						

	li $v0, 6					# save total diameter input into $f20
	syscall						
	mov.s $f20, $f0 		

	li $v0, 4					
	la $a0, cost 					
	syscall						

	li	$v0, 6					# save total cost input into $f21
	syscall						
	mov.s $f21, $f0  		

	c.eq.s $f21, $f26
	bc1t pizza_per_dollar_function_0	# if cost = 0, branch to ppd0

	j pizza_per_dollar_function 	

	pizza_per_dollar_function_0:
		mov.s $f24, $f26 		
		j move_pointer

	pizza_per_dollar_function: #calculate ppd for inputs
		l.s $f9, PI
		l.s $f10, FourAsFloat

		div.s $f6, $f9, $f10 
		mul.s $f7, $f20, $f20 	
		mul.s $f7, $f7, $f6 	
										
		div.s $f24, $f7, $f21 	
		j move_pointer

	move_pointer:
		s.s $f24, 0($s0) 			# stores current ppd into current struct
		addi $s0, $s0, 4			# s0 points next address

		move $s1, $s0				# Storing s0, which points to start of the next field for the head node, to s1
		lw $zero, 0($s0)	
	
	j insert_new_node


insert_new_node:
	li $a0, 72				
	li $v0, 9						
	syscall							

	move $s0, $v0

	sw $s0, 0($s1)				

	li $v0, 4		
	la $a0, name 						
	syscall							

	li $v0, 8 						
    move $a0, $s0 	
    li $a1, 64 						
    syscall
  
    la $a1,DONE_word

    jal strcmp      			    #Check if name is "DONE"

    bnez $v0, continue
    beq $v0,$zero,DONE_second
 
DONE_second:
    sw $zero, 0($s1)				# loading 0 into NEXT field of last node in list

    addi $sp, $sp, -32				
	sw $t0, 0($sp)
	sw $t1, 4($sp)					
	sw $t2, 8($sp)				
	sw $t3, 12($sp)					
	sw $t4, 16($sp)					
	sw $t5, 20($sp)					
	sw $t6, 24($sp)					
	sw $t7, 28($sp)	

    j head_node


##########################################Sort the link list#####################################################
#################################################################################################################		
head_node:
	li $s6, 0
	lw $t5, 68($s5)				
	beq $t5, $zero, end_of_list				# if list is one size length branch out	

	l.s $f21, 64($s5)						# ppd of head node in f21
	lw $t2, 68($s5)	
	
	l.s $f22, 64($t2)						# ppd of next node to f22

	c.eq.s $f21, $f22						
	bc1t head_tie_breaker					#values are the same --> check tie

	c.lt.s $f21, $f22						# swap --> swap_function_1
	bc1t swap_function_1					

	j middle_node							# jump to middle section if no swap needed

			
		head_tie_breaker:
			move $a0, $s5

			jal strcmp_swap
			bne $v0, $zero, swap_function_1
			beq $v0, $zero, middle_node


		swap_function_1:
			addi $s6, $s6, 1		
			move $t0, $s5	

			lw $t1, 68($s5)				# second node in t1

			move $s5, $t1				# move s5 to point to new head

			lw $t2, 68($s5)				

			sw $t0, 68($s5)				# old head is NEXT for new head 
			sw $t2, 68($t0)				

			j middle_node



middle_node:			
	move $t0, $s5
	lw $t1, 68($s5)	

	continue_middle:
		lw $t5, 68($t1)					# current node in $t5 
		beq $t5, $zero, end_of_list		# if at end of list branch out	

		l.s $f21, 64($t1)				# ppd of current node to f21
		lw $t2, 68($t1)				

		l.s $f22, 64($t2)				# ppd of next node to f22 

		c.eq.s $f21, $f22				#values are the same --> check tie
		bc1t middle_tie_breaker					

		c.lt.s $f21, $f22				# swap --> swap_function_2
		bc1t swap_function_2

		move $t0, $t1		
		move $t1, $t2					

		j continue_middle 

		
		middle_tie_breaker:		
			lw $t2, 68($t1)	

			move $t6, $t2
			move $t7, $t1
				
			move $a0, $t1
			jal strcmp_swap

			bne $v0, $zero, swap_function_2
			beq $v0, $zero, no_swap_middle

		no_swap_middle:
			move $t0, $t7					
			move $t1, $t6					
			j continue_middle	

		swap_function_2: 				#swap the nodes and changes the pointers from the previous and after nodes of $t1 and $t2
			addi $s6, $s6, 1			

			lw $t2, 68($t1)				# current next in t2
			lw $t3, 68($t2)				# current next next in t3

			sw $t3, 68($t1)				# current next next because the next of current node
			sw $t1, 68($t2)				# current next now becomes current
			sw $t2, 68($t0)				# previous current node becomes the previous node for new current

			move $t0, $t2			

			j continue_middle 		
			
strcmp_swap: 			#return 1 if values should swap or 0 if they should stay the same
 	addi $sp, $sp, -4
    sw $ra, 0($sp)

    move $t1, $a0
	lw $t2, 68($a0)

	loop2:
		lb $t3($t1)  
        lb $t4($t2) 

    	beq $t3, $t4 adding

    	slt $t5, $t4, $t3     		
        bne $t5, $zero, swap  	#if not equal to 0, then swap
		j dont_swap
					
      	adding:
    		addi $t1, $t1, 1
			addi $t2, $t2, 1
			j loop2

    dont_swap:
    	add $v0,$zero,$zero
    	j endfunction2

    swap: 
    	addi $v0,$zero,1 
    	j endfunction2

	endfunction2:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
    	jr $ra


end_of_list:
	beq $s6, $zero, collapse_stack
	j head_node						

	collapse_stack:
		lw $t7, 28($sp)
		lw $t6, 24($sp)				
		lw $t5, 20($sp)				
		lw $t4, 16($sp)			
		lw $t3, 12($sp) 			
        lw $t2, 8($sp) 				
		lw $t1, 4($sp) 				
		lw $t0, 0($sp)				
		addi $sp, $sp, 32			

		j begin_loop_print_linked_list



##########################################Print the link list########################################################
#####################################################################################################################
begin_loop_print_linked_list:
	li $s6, 0							# bits counter for the current string
		
	print_linked_list:
		lb $s2, newline					# loads "\n" into s3
		lb $s0, 0($s5)					

       	beq $s0, $s2, print_ppd			# jumps to print ppd when printing pizza name is finshed

		jal print_name_character

		addi $s6, $s6, 1				
		addi $s5, $s5, 1		
		j print_linked_list

    print_name_character:
    	li $v0, 11						
		move $a0, $s0					# prints out character of string
		syscall
		jr $ra

    print_ppd:
    	add $s7, $s7, 1	
    	li $s1, 64				
		jal space_in_between
		jal calculate_bytes

		l.s $f12, 0($s5)				# loading ppd of current node into f25

		li $v0, 2          				# printing ppd
       	syscall                			

       	li $v0, 4
		la $a0, newline 				
		syscall							

        addi $s5, $s5, 4				# moving s5 to the NEXT node

        beq $s7, $s8, finished			# goes to Finished if printed all nodes
        lw $s5, 0($s5)					
        j begin_loop_print_linked_list

    calculate_bytes:
    	sub $s1, $s1, $s6				# calculate bytes needed to get ppd spot
		add $s5, $s5, $s1
		jr $ra

    space_in_between:
     	li $v0, 11
		li $a0, 32					
		syscall
		jr $ra

finished:			
	li	$v0, 10
	syscall						

.end main