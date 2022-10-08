.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:
	addi t0 , zero , 5
	bne t0 , a0 , argc_error
	addi sp , sp , -52
	sw ra , 0(sp)
	sw s0 , 4(sp) # m0 matrix ptr
	sw s1 , 8(sp) # m0 matrix row
	sw s2 , 12(sp) # m0 matrix col
	sw s3 , 16(sp) # m1 matrix ptr
	sw s4 , 20(sp) # m1 matrix row
	sw s5 , 24(sp) # m1 matrix col
	sw s6 , 28(sp) # input matrix ptr
	sw s7 , 32(sp) # input matrix row
	sw s8 , 36(sp) # input matrix col
	sw s9 , 40(sp) # h pointer
	sw s10 , 44(sp)# o pointer
	sw s11 , 48(sp)# return a0
	addi sp , sp , -24
	sw a0 , 0(sp)

	lw t0 , 4(a1) # pointer to the filepath string of m0
	sw t0 , 4(sp)

	lw t0 , 8(a1)
	sw t0 , 8(sp)
	
	lw t0 , 12(a1)
	sw t0 , 12(sp)
	
	lw t0 , 16(a1)
	sw t0 , 16(sp)

	sw a2 , 20(sp)
	# Read pretrained m0
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s1 , a0 , 0
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s2 , a0 , 0
	lw a0 , 4(sp)
	addi a1 , s1 , 0 
	addi a2 , s2 , 0 
	jal read_matrix
	addi s0 , a0 , 0 
	# Read pretrained m1
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s4 , a0 , 0
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s5 , a0 , 0
	lw a0 , 8(sp)
	addi a1 , s4 , 0 
	addi a2 , s5 , 0 
	jal read_matrix
	addi s3 , a0 , 0 

	# Read input matrix
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s7 , a0 , 0
	addi a0 , zero , 4
	jal malloc
	beq a0 , zero , malloc_error
	addi s8 , a0 , 0
	lw a0 , 12(sp)
	addi a1 , s7 , 0 
	addi a2 , s8 , 0 
	jal read_matrix
	addi s6 , a0 , 0 

	# Compute h = matmul(m0, input)
	lw t0 , 0(s1) # m0 row
	lw t1 , 0(s8) # input col
	mul t2 , t0 , t1 
	slli a0 , t2 , 2
	jal malloc
	beq a0 , zero , malloc_error
	addi s9 , a0 , 0
	# ebreak
	addi a0 , s0 , 0
	lw a1 , 0(s1)
	lw a2 , 0(s2)
	addi a3 , s6 , 0 
	lw a4 , 0(s7)
	lw a5 , 0(s8)
	addi a6 , s9 , 0 
	jal matmul
	

	# Compute h = relu(h)
	addi a0 , s9 , 0
	lw t0 , 0(s1)
	lw t1 , 0(s8)
	mul t2 , t0 , t1
	addi a1 , t2 , 0
	jal relu

	# Compute o = matmul(m1, h)
	lw t0 , 0(s4) # m1 row
	lw t1 , 0(s8) # input col
	mul t2 , t0 , t1 
	slli a0 , t2 , 2
	jal malloc
	addi s10 , a0 , 0
	addi a0 , s3 , 0
	lw a1 , 0(s4)
	lw a2 , 0(s5)
	addi a3 , s9 , 0 
	lw a4 , 0(s1)
	lw a5 , 0(s8)
	addi a6 , s10 , 0 
	jal matmul

	# Write output matrix o
	lw a0 , 16(sp)
	addi a1 , s10 , 0
	lw a2 , 0(s4)
	lw a3 , 0(s8)
	jal write_matrix
	# Compute and return argmax(o)
	addi a0 , s10 , 0
	lw t0 , 0(s4)
	lw t1 , 0(s8)
	mul a1 , t0 , t1
	jal argmax
	addi s11 , a0 , 0
	# If enabled, print argmax(o) and newline
	lw t0 , 20(sp)
	bne t0 , zero , end
	addi a0 , s11 , 0
	jal print_int
	li a0 '\n'
	jal print_char


end:
	# free all the resources
	addi a0 , s0 , 0
	jal free
	addi a0 , s1 , 0
	jal free
	addi a0 , s2 , 0
	jal free
	addi a0 , s3 , 0
	jal free
	addi a0 , s4 , 0
	jal free
	addi a0 , s5 , 0
	jal free
	addi a0 , s6 , 0
	jal free
	addi a0 , s7 , 0
	jal free
	addi a0 , s8 , 0
	jal free
	addi a0 , s9 , 0
	jal free
	addi a0 , s10 , 0
	jal free

	#prologue
	addi a0 , s11 , 0
	addi sp , sp , 24
	lw ra , 0(sp)
	lw s0 , 4(sp) # m0 matrix ptr
	lw s1 , 8(sp) # m0 matrix row
	lw s2 , 12(sp) # m0 matrix col
	lw s3 , 16(sp) # m1 matrix ptr
	lw s4 , 20(sp) # m1 matrix row
	lw s5 , 24(sp) # m1 matrix col
	lw s6 , 28(sp) # input matrix ptr
	lw s7 , 32(sp) # input matrix row
	lw s8 , 36(sp) # input matrix col
	lw s9 , 40(sp) # h pointer
	lw s10 , 44(sp)# o pointer
	lw s11 , 48(sp)# return a0
	addi sp , sp , 52
	ret

malloc_error:
	addi a0 , zero , 26
	j exit

argc_error:
	addi a0 , zero , 31
	j exit