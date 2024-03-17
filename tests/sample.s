
    addi s0, zero, 10
    jal x1, there
    addi s1, zero, 20
    addi x10, zero, 25
there:
    addi s1, zero, -10
    jr x1
