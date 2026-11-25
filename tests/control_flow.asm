# Cubre:
# beq tomado/no tomado; bne tomado/no tomado y salto hacia atras;
# j; jal/jr con una rutina no hoja que llama a otra, guarda/restaura
# $ra en la pila y retorna correctamente; syscall 11 y syscall 10.
.text
main:
    addi $s0, $zero, 0
    addi $s1, $zero, 1

    # beq tomado
    beq  $s1, $s1, beq_taken
    addi $s0, $s0, 100
beq_taken:
    addi $s0, $s0, 1

    # beq no tomado
    beq  $s1, $zero, beq_unexpected
    addi $s0, $s0, 2
    j    after_beq
beq_unexpected:
    addi $s0, $s0, 100
after_beq:

    # bne tomado
    bne  $s1, $zero, bne_taken
    addi $s0, $s0, 100
bne_taken:
    addi $s0, $s0, 4

    # bne no tomado
    bne  $s1, $s1, bne_unexpected
    addi $s0, $s0, 8
    j    after_bne
bne_unexpected:
    addi $s0, $s0, 100
after_bne:

    # bne hacia atras: dos iteraciones tomadas y una no tomada
    addi $s2, $zero, 3
loop:
    addi $s2, $s2, -1
    bne  $s2, $zero, loop

    # j evita ejecutar la instruccion siguiente
    j    call_outer
    addi $s0, $s0, 100
call_outer:
    jal  outer
    add  $s3, $v0, $zero
    add  $s4, $sp, $zero

    # Esperado: s0=15, s2=0, s3=16, s4=0x3ffc
    add  $a0, $s0, $zero
    jal  print_hex
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    jal  newline
    addi $v0, $zero, 10
    syscall

# Rutina no hoja: guarda $ra antes de llamar a inner.
outer:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
    addi $a0, $zero, 5
    jal  inner
    addi $v0, $v0, 1
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
inner:
    addi $v0, $a0, 10
    jr   $ra

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
