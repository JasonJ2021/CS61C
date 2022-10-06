.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
	# Prologue
	addi sp , sp , -4
	sw ra , 0(sp)

	addi t0 , zero , 1
	blt a1 , t0 , end
	addi t0 , x0 , 1 # i = 1
	lw t1 , 0(a0)    # max = a[0]
	addi t2 , x0 , 0 # max_index = 0 
	bne t0 , a1 , loop_start
	jal loop_end
loop_start:
	slli t3 , t0 , 2 
	add t3 , a0 , t3
	lw t3 , 0(t3)
	blt t1 , t3 , loop_continue
	addi t0 , t0 , 1
	bne t0 , a1 , loop_start
	jal loop_end
loop_continue:
	# max < a[i]
	add t1 , zero , t3
	addi t2 , t0 , 0
	addi t0 , t0 , 1
	blt t0 , a1 , loop_start

loop_end:
	lw ra , 0(sp)
	addi sp , sp , 4
	add a0 , x0 , t2
	ret

end:
	li a0 , 36
	j exit