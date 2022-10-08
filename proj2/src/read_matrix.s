.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# Steps:
# 1.Open the file with read permissions. The filepath is provided as an argument (a0).
# 2.Read the number of rows and columns from the file (remember: these are the first two integers in the file). 
# Store these integers in memory at the provided pointers (a1 for rows and a2 for columns).
# 3.Allocate space on the heap to store the matrix. 
# (Hint: Use the number of rows and columns from the previous step to determine how much space to allocate.)
# 4.Read the matrix from the file to the memory allocated in the previous step.
# 5.Close the file.
# 6.Return a pointer to the matrix in memory.
# ==============================================================================
read_matrix:

	# Prologue
	addi sp , sp , -24
	sw ra , 0(sp)
	sw s0 , 4(sp)
	sw s1 , 8(sp)
	sw s2 , 12(sp)
	sw s3 , 16(sp)	 # file descriptor
	sw s4 , 20(sp)   # pointer to malloc matrix

	add s0 , x0 , a0 # saved filename
	add s1 , x0 , a1 # saved row pointer
	add s2 , x0 , a2 # saved col pointer
	# fopen
	addi a0 , s0 , 0
	addi a1 , zero , 0 # read-only
	jal fopen
	blt a0 , zero , fopen_error
	addi s3 , a0 , 0 # save descriptor to s3 reg
	# fread , to get row and col
	addi a0 , s3 , 0
	addi a1 , s1 , 0
	addi a2 , zero , 4
	jal fread
	addi t2 , zero , 4
	bne t2 , a0 , fread_error
	addi a0 , s3 , 0
	addi a1 , s2 , 0
	addi a2 , zero , 4
	jal fread
	addi t2 , zero , 4
	bne t2 , a0 , fread_error
	# malloc matrix space
	lw t0 , 0(s1)
	lw t1 , 0(s2)
	mul a0 , t0 , t1
	slli a0 , a0 , 2
	jal malloc
	beq a0 , zero , malloc_error
	addi s4 , a0 , 0
	# read the matrix
	addi a0 , s3 , 0 
	addi a1 , s4 , 0
	lw t0 , 0(s1)
	lw t1 , 0(s2)
	mul a2 , t0 , t1
	slli a2 , a2 ,  2
	jal fread
	lw t0 , 0(s1)
	lw t1 , 0(s2)
	mul t2 , t0 , t1
	slli t2 , t2 , 2
	bne t2 , a0 , fread_error

	# close the file
	addi a0 , s3 , 0 
	jal fclose 
	bne a0 , zero , fclose_error

	# return pointer to the matrix
	addi a0 , s4 , 0 
	# Epilogue
	lw ra , 0(sp)
	lw s0 , 4(sp)
	lw s1 , 8(sp)
	lw s2 , 12(sp)
	lw s3 , 16(sp)
	lw s4 , 20(sp)
	addi sp , sp , 24
	ret

fopen_error:
	addi a0 , x0 , 27
	j exit

fread_error:
	addi a0 , x0 , 29
	j exit

malloc_error:
	addi a0 , x0 , 26
	j exit

fclose_error:
	addi a0 , x0 , 28
	j exit