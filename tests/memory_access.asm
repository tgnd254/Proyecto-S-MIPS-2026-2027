# Cubre:
# lw/sw con desplazamiento positivo y negativo;
# lb/lbu sobre bytes con bit7=1 en posiciones 2 y 3 de una palabra;
# sb en las posiciones 0, 1, 2 y 3 de una misma palabra, verificando
# despues de cada escritura con lw que los demas bytes se conservan;
# syscall 11 (impresion) y syscall 10 (fin).
.data
loadword:  .word 0x80E97F11
storearea: .word 0x11223344, 0, 0, 0
.text
main:
    la   $s0, loadword
    lw   $s1, 0($s0)
    lb   $s2, 2($s0)
    lbu  $s3, 2($s0)
    lb   $s4, 3($s0)
    lbu  $s5, 3($s0)
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

    # sw/lw con desplazamiento positivo y negativo
    la   $s0, storearea
    addi $s1, $zero, 0x1234
    sw   $s1, 4($s0)
    addi $s2, $zero, 0x5678
    addi $s3, $s0, 12
    sw   $s2, -4($s3)
    lw   $s4, 4($s0)
    lw   $s5, -4($s3)
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    jal  newline

    # sb en cada carril; cada lw comprueba que los otros bytes no cambian
    addi $s1, $zero, 0x00AA
    sb   $s1, 0($s0)
    lw   $s2, 0($s0)
    add  $a0, $s2, $zero
    jal  print_hex
    addi $s1, $zero, 0x00BB
    sb   $s1, 1($s0)
    lw   $s3, 0($s0)
    add  $a0, $s3, $zero
    jal  print_hex
    addi $s1, $zero, 0x00CC
    sb   $s1, 2($s0)
    lw   $s4, 0($s0)
    add  $a0, $s4, $zero
    jal  print_hex
    addi $s1, $zero, 0x00DD
    sb   $s1, 3($s0)
    lw   $s5, 0($s0)
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
