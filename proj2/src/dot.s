.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:

	# Prologue
	addi t0 , x0 , 1
	blt a2 , t0 , end_1
	blt a3 , t0 , end_2
	blt a4 , t0 , end_2
	
	addi sp , sp , -12
	sw ra , 0(sp)
	sw s0 , 4(sp)
	sw s1 , 8(sp)


	addi s0 , x0 , 0 # sum = 0
	addi s1 , x0 , 0 # i = 0 
loop_start:
	add t0 , x0 , s1
	mul t0 , t0 , a3 # t0 = stride1 * i 
	slli t0 , t0 , 2
	add t0 , a0 , t0
	lw t0 , 0(t0)
	add t1 , x0 , s1
	mul t1 , t1 , a4 # t1 = stride2 * i 
	slli t1 , t1 , 2
	add t1 , a1 , t1
	lw t1 , 0(t1)
	mul t2 , t0 , t1
	add s0 , s0 , t2
	addi s1 , s1 , 1
	bne s1, a2, loop_start # if s1 != a2 go to loop_start
	add a0 , zero , s0

loop_end:

	# Epilogue
	lw ra , 0(sp)
	lw s0 , 4(sp)
	lw s1 , 8(sp)
	addi sp , sp , 12

	ret

end_1:
	addi a0 , x0 , 36
	j exit

end_2:
	addi a0 , x0 , 37
	j exit