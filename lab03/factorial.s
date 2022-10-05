.globl factorial

.data
n: .word 1

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, factorial

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

factorial:
    addi t0, x0, 1 #sum = 1
    addi t1, t1, 1 #k = 1
    addi a0, a0, 1 
loop:
    beq t1, a0, exit
    mul t0, t0, t1
    addi t1 , t1 , 1
    jal x0 , loop
exit:
    add a0, t0 , x0
    jr ra
