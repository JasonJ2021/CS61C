.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:
	# Error checks
	addi t0 , zero , 1
	blt a1 , t0 , end
	blt a2 , t0 , end
	blt a4 , t0 , end
	blt a5 , t0 , end
	bne a1 , a5 , end
	bne a2 , a4 , end

	# Prologue
	addi sp , sp , -48
	sw ra , 0(sp)
	sw s0 , 4(sp)
	sw s1 , 8(sp)
	sw s2 , 12(sp)
	sw s3 , 16(sp)
	sw s4 , 20(sp)
	sw s5 , 24(sp)
	sw s6 , 28(sp)
	sw s7 , 32(sp)
	sw s8 , 36(sp)
	sw s9 , 40(sp)
	sw s10 , 44(sp)
	add s0 , a0 , x0
	add s1 , a1 , x0
	add s2 , a2 , x0
	add s3 , a3 , x0
	add s4 , a4 , x0
	add s5 , a5 , x0
	add s6 , a6 , x0
	addi s7 , zero , 0 # i = 0 
	addi s8 , zero , 0 # j = 0
	addi s9 , zero , 0 # sum = 0
outer_loop_start:
	addi t0 , s7 , 0
	mul t0 , s2 , t0
	slli t0 , t0 , 2
	add s10 , s0 , t0 # 这里存放matrix 1 数组的地址

inner_loop_start:
	addi t0 , s8 , 0
	slli t0 , t0 , 2
	add a1 , s3 , t0 # 这里存放matrix 2 数组的地址
	add a0 , zero , s10
	add a2 , zero , s2
	addi a3 , zero , 1
	add a4 , zero , s5
	jal dot
	# We should set s6[i * col_2 + j ] = a0
	mul t0 , s7 , s5
	add t0 , t0 , s8
	slli t0 , t0 , 2
	add t0 , s6 , t0
	sw a0 , 0(t0)

	addi s8 , s8 , 1
	bne s8 , s5 , inner_loop_start
inner_loop_end:
	addi s8 , zero , 0
outer_loop_end:
	addi s7 , s7 , 1
	bne s7 , s1 , outer_loop_start 

	# Epilogue
	lw ra , 0(sp)
	lw s0 , 4(sp)	
	lw s1 , 8(sp)
	lw s2 , 12(sp)
	lw s3 , 16(sp)
	lw s4 , 20(sp)
	lw s5 , 24(sp)
	lw s6 , 28(sp)
	lw s7 , 32(sp)
	lw s8 , 36(sp)
	lw s9 , 40(sp)
	lw s10 , 44(sp)
	addi sp , sp , 48
	ret

end:
	li a0 , 38
	j exit