# Cubre:
# add/sub con operandos positivos y negativos; and/or con bits altos activos;
# slt/slti con resultados 1 y 0 y comparacion negativa con signo;
# sll/srl con shamt=0 y distinto de 0 (srl sobre negativo);
# addi con inmediato negativo; addiu mediante li; addu mediante move;
# andi/ori con inmediato bit15=1; lui con inmediato bit15=1;
# escritura en $zero; syscall 11 (impresion) y syscall 10 (fin).
.text
main:
    addi $s0, $zero, 20
    addi $s1, $zero, 7
    addi $s2, $zero, -9
    add  $s3, $s0, $s1
    add  $s4, $s0, $s2
    sub  $s5, $s0, $s1
    sub  $s6, $s1, $s2
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    add  $a0, $s6, $zero
    jal  print_hex
    jal  newline

    # and/or con bits altos activos; inmediatos con bit 15 = 1
    lui  $s0, 0xF0F0
    ori  $s0, $s0, 0x0F0F
    lui  $s1, 0x0FF0
    ori  $s1, $s1, 0xF00F
    and  $s2, $s0, $s1
    or   $s3, $s0, $s1
    andi $s4, $s0, 0x8001
    ori  $s5, $zero, 0x8001
    lui  $s6, 0x8001
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    add  $a0, $s6, $zero
    jal  print_hex
    jal  newline

    # addi negativo; li debe generar addiu; move debe generar addu
    addi $s0, $zero, -123
    li   $s1, -12345
    move $s2, $s1
    add  $a0, $s0, $zero
    jal  print_hex
    add  $a0, $s1, $zero
    jal  print_hex
    add  $a0, $s2, $zero
    jal  print_hex
    jal  newline

    # slt/slti: resultados 1 y 0; -1 < 1 con signo
    addi $s0, $zero, -1
    addi $s1, $zero, 1
    slt  $s2, $s0, $s1
    slt  $s3, $s1, $s0
    slti $s4, $s0, 1
    slti $s5, $s1, -1
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    jal  newline

    # sll/srl con shamt=0 y 4; srl sobre -16; comprobar $zero
    addi $s0, $zero, -16
    sll  $s1, $s0, 0
    sll  $s2, $s0, 4
    srl  $s3, $s0, 0
    srl  $s4, $s0, 4
    add  $zero, $s0, $s1
    add  $s5, $zero, $zero
    add  $a0, $s1, $zero
    jal  print_hex
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    jal  newline
    addi $v0, $zero, 10
    syscall

print_hex:
    add  $t0, $a0, $zero
    addi $t1, $zero, 8
hex_loop:
    srl  $t2, $t0, 28
    slti $t3, $t2, 10
    beq  $t3, $zero, hex_letter
    addi $a0, $t2, 48
    j    hex_output
hex_letter:
    addi $a0, $t2, 87
hex_output:
    addi $v0, $zero, 11
    syscall
    sll  $t0, $t0, 4
    addi $t1, $t1, -1
    bne  $t1, $zero, hex_loop
    addi $a0, $zero, 32
    addi $v0, $zero, 11
    syscall
    jr   $ra
newline:
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall
    jr   $ra
