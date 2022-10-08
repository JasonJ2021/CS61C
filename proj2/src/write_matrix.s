.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
	addi sp , sp , -24
	sw ra , 0(sp)
	sw s0 , 4(sp)
	sw s1 , 8(sp)
	sw s2 , 12(sp)
	sw s3 , 16(sp)
	sw s4 , 20(sp)
	addi sp , sp , -8
	sw a2 , 0(sp)
	sw a3 , 4(sp)
	addi s0 , a0 , 0 # save string ptr
	addi s1 , a1 , 0 # save matrix ptr
	addi s2 , sp , 0 # save matrix row
	addi s3 , sp , 4 # save matrix col

	# fopen
	addi a1 , zero , 1 # write-only
	jal fopen
	blt a0 , zero , fopen_error
	addi s4 , a0 , 0 # save file descriptor

	# write the row and col
	addi a0 , s4 , 0
	addi a1 , s2 , 0
	addi a2 , zero , 1 
	addi a3 , zero , 4
	jal fwrite
	addi t0 , zero , 1
	bne a0 , t0 , fwrite_error

	addi a0 , s4 , 0
	addi a1 , s3 , 0
	addi a2 , zero , 1 
	addi a3 , zero , 4
	jal fwrite
	addi t0 , zero , 1
	bne a0 , t0 , fwrite_error

	# write the data
	addi a0 , s4 , 0
	addi a1 , s1 , 0
	lw t0 , 0(s2)
	lw t1 , 0(s3)
	mul t2 , t0 , t1
	addi a2 , t2 , 0 
	addi a3 , zero , 4
	jal fwrite
	lw t0 , 0(s2)
	lw t1 , 0(s3)
	mul t2 , t0 , t1
	bne a0 , t2 , fwrite_error

	# close the file
	addi a0 , s4 , 0 
	jal fclose 
	bne a0 , zero , fclose_error

	# Epilogue
	addi sp , sp , 8
	lw ra , 0(sp)
	lw s0 , 4(sp)
	lw s1 , 8(sp)
	lw s2 , 12(sp)
	lw s3 , 16(sp)
	lw s4 , 20(sp)
	addi sp , sp , 24
	ret


fopen_error:
	addi a0 , zero , 27
	j exit

fwrite_error:
	addi a0 , zero , 30
	j exit

fclose_error:
	addi a0 , x0 , 28
	j exit