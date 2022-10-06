.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
	# Prologue
	addi t0 , zero , 1
	blt a1 , t0 , end
	addi sp , sp , -16
	sw s0 , 0(sp)
	sw s1 , 4(sp)
	sw ra , 8(sp)
	sw s2 , 12(sp)
	add s2 , x0 , a1   # s2 = size
	addi s0 , zero , 0 # s0 = i = 0
	addi s1 , a0 , 0      # s1 = address of the array

loop_start:
	slli t0 , s0 , 2
	add t1 , s1 , t0 # t1 = int[] + i
	lw a0 , 0(t1)
	jal helper
	sw a0 , 0(t1)
	addi s0 , s0 , 1
	bne s0 , s2 , loop_start
loop_end:
	# Epilogue
	lw s0 , 0(sp)
	lw s1 , 4(sp)
	lw ra , 8(sp)
	lw s2 , 12(sp)
	addi sp , sp , 16
	ret
# argument:
# 	a0(int),relu element
helper:
	blt zero,a0 , done
	addi a0 , x0 , 0
done:
	ret


end:
	li a0 , 36
	j exit
