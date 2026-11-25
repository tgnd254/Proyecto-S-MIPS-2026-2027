# Cubre (casos extra, ademas de arithmetic_logic, control_flow y memory_access):
# estado inicial tras reset ($gp, $sp, $ra, $t0, $s7);
# lb/lbu en las posiciones 0, 1 y 2 de una palabra (byte negativo y positivo);
# sb en las cuatro posiciones con registros de bits altos no nulos, comprobando
# con lw la palabra y las palabras vecinas;
# beq/bne con operandos que solo difieren en los bits altos, y beq hacia atras;
# jr con registros distintos de $ra; recursion (fibonacci) con $ra y $a0 en la pila;
# banco de registros: se escribe un valor de 32 bits distinto en $1..$31
# (incluidos $gp, $sp y $ra), se vuelcan a memoria con sw y se imprimen;
# syscall 11 (impresion) y syscall 10 (fin).
.data
dump:    .space 128
lbword:  .word 0xF0427F85
sbarea:  .word 0x01010101, 0xAABBCCDD, 0x02020202
.text
main:
    # --- estado inicial (antes de cualquier jal) ---
    add  $s0, $gp, $zero
    add  $s1, $sp, $zero
    add  $s2, $ra, $zero
    add  $s3, $t0, $zero
    add  $s4, $s7, $zero
    add  $a0, $s0, $zero
    jal  print_hex
    add  $a0, $s1, $zero
    jal  print_hex
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    jal  newline

    # --- lb/lbu en posiciones 0, 1 y 2 ---
    la   $s0, lbword
    lb   $s1, 0($s0)
    lbu  $s2, 0($s0)
    lb   $s3, 1($s0)
    lbu  $s4, 1($s0)
    lb   $s5, 2($s0)
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

    # --- sb con bits altos no nulos; solo debe escribirse rt[7:0] ---
    la   $s0, sbarea
    li   $s1, 0x12345611
    sb   $s1, 4($s0)
    lw   $s2, 4($s0)
    li   $s1, 0xFEDCBA22
    sb   $s1, 5($s0)
    lw   $s3, 4($s0)
    li   $s1, 0x76543233
    sb   $s1, 6($s0)
    lw   $s4, 4($s0)
    li   $s1, 0x89ABCD44
    sb   $s1, 7($s0)
    lw   $s5, 4($s0)
    lw   $k0, 0($s0)
    lw   $k1, 8($s0)
    add  $a0, $s2, $zero
    jal  print_hex
    add  $a0, $s3, $zero
    jal  print_hex
    add  $a0, $s4, $zero
    jal  print_hex
    add  $a0, $s5, $zero
    jal  print_hex
    jal  newline

    # --- beq/bne: operandos que difieren solo en los bits altos ---
    # cada caso suma su peso si el salto se comporta como debe (total 0xFF)
    addi $s0, $zero, 0
    li   $s1, 0x00010000
    li   $s2, 0x80000000
    li   $s5, 0x00010000
    li   $s6, 0xABCD0001
    li   $s7, 0x12340001
    beq  $s1, $zero, b1          # no tomado
    addi $s0, $s0, 1
b1:
    addi $s0, $s0, 2
    bne  $s1, $zero, b2          # tomado
    addi $s0, $s0, -2
b2:
    beq  $s2, $zero, b3          # no tomado
    addi $s0, $s0, 4
b3:
    addi $s0, $s0, 8
    bne  $s2, $zero, b4          # tomado
    addi $s0, $s0, -8
b4:
    addi $s0, $s0, 16
    beq  $s1, $s5, b5            # tomado (iguales)
    addi $s0, $s0, -16
b5:
    bne  $s1, $s5, b6            # no tomado (iguales)
    addi $s0, $s0, 32
b6:
    beq  $s6, $s7, b7            # no tomado (bits bajos iguales)
    addi $s0, $s0, 64
b7:
    addi $s0, $s0, 128
    bne  $s6, $s7, b8            # tomado
    addi $s0, $s0, -128
b8:
    # beq hacia atras (tomado) con salida por beq hacia delante
    addi $s3, $zero, 0
bk:
    addi $s3, $s3, 1
    slti $t0, $s3, 3
    beq  $t0, $zero, bk_end
    beq  $zero, $zero, bk
bk_end:
    sll  $s3, $s3, 8
    add  $s0, $s0, $s3           # 0x3FF

    # --- jr con registros distintos de $ra ---
    addi $s6, $zero, 0
    la   $s5, jr_a
    jr   $s5
    addi $s6, $s6, 100
jr_a:
    addi $s6, $s6, 1
    la   $t9, jr_b
    jr   $t9
    addi $s6, $s6, 100
jr_b:
    addi $s6, $s6, 4             # 5

    # --- recursion: fib(8) = 21 ---
    addi $a0, $zero, 8
    jal  fib
    add  $s7, $v0, $zero

    add  $a0, $k0, $zero
    jal  print_hex
    add  $a0, $k1, $zero
    jal  print_hex
    add  $a0, $s0, $zero
    jal  print_hex
    add  $a0, $s6, $zero
    jal  print_hex
    add  $a0, $s7, $zero
    jal  print_hex
    jal  newline

    # --- banco de registros: valor distinto en $1..$31 ---
    lui  $1, 0x9E37
    ori  $1, $1, 0x79B9
    lui  $2, 0x3C6E
    ori  $2, $2, 0xF372
    lui  $3, 0xDAA6
    ori  $3, $3, 0x6D2B
    lui  $4, 0x78DD
    ori  $4, $4, 0xE6E4
    lui  $5, 0x1715
    ori  $5, $5, 0x609D
    lui  $6, 0xB54C
    ori  $6, $6, 0xDA56
    lui  $7, 0x5384
    ori  $7, $7, 0x540F
    lui  $8, 0xF1BB
    ori  $8, $8, 0xCDC8
    lui  $9, 0x8FF3
    ori  $9, $9, 0x4781
    lui  $10, 0x2E2A
    ori  $10, $10, 0xC13A
    lui  $11, 0xCC62
    ori  $11, $11, 0x3AF3
    lui  $12, 0x6A99
    ori  $12, $12, 0xB4AC
    lui  $13, 0x08D1
    ori  $13, $13, 0x2E65
    lui  $14, 0xA708
    ori  $14, $14, 0xA81E
    lui  $15, 0x4540
    ori  $15, $15, 0x21D7
    lui  $16, 0xE377
    ori  $16, $16, 0x9B90
    lui  $17, 0x81AF
    ori  $17, $17, 0x1549
    lui  $18, 0x1FE6
    ori  $18, $18, 0x8F02
    lui  $19, 0xBE1E
    ori  $19, $19, 0x08BB
    lui  $20, 0x5C55
    ori  $20, $20, 0x8274
    lui  $21, 0xFA8C
    ori  $21, $21, 0xFC2D
    lui  $22, 0x98C4
    ori  $22, $22, 0x75E6
    lui  $23, 0x36FB
    ori  $23, $23, 0xEF9F
    lui  $24, 0xD533
    ori  $24, $24, 0x6958
    lui  $25, 0x736A
    ori  $25, $25, 0xE311
    lui  $26, 0x11A2
    ori  $26, $26, 0x5CCA
    lui  $27, 0xAFD9
    ori  $27, $27, 0xD683
    lui  $28, 0x4E11
    ori  $28, $28, 0x503C
    lui  $29, 0xEC48
    ori  $29, $29, 0xC9F5
    lui  $30, 0x8A80
    ori  $30, $30, 0x43AE
    lui  $31, 0x28B7
    ori  $31, $31, 0xBD67
    sw   $1, 0x2004($zero)
    sw   $2, 0x2008($zero)
    sw   $3, 0x200C($zero)
    sw   $4, 0x2010($zero)
    sw   $5, 0x2014($zero)
    sw   $6, 0x2018($zero)
    sw   $7, 0x201C($zero)
    sw   $8, 0x2020($zero)
    sw   $9, 0x2024($zero)
    sw   $10, 0x2028($zero)
    sw   $11, 0x202C($zero)
    sw   $12, 0x2030($zero)
    sw   $13, 0x2034($zero)
    sw   $14, 0x2038($zero)
    sw   $15, 0x203C($zero)
    sw   $16, 0x2040($zero)
    sw   $17, 0x2044($zero)
    sw   $18, 0x2048($zero)
    sw   $19, 0x204C($zero)
    sw   $20, 0x2050($zero)
    sw   $21, 0x2054($zero)
    sw   $22, 0x2058($zero)
    sw   $23, 0x205C($zero)
    sw   $24, 0x2060($zero)
    sw   $25, 0x2064($zero)
    sw   $26, 0x2068($zero)
    sw   $27, 0x206C($zero)
    sw   $28, 0x2070($zero)
    sw   $29, 0x2074($zero)
    sw   $30, 0x2078($zero)
    sw   $31, 0x207C($zero)

    addi $s0, $zero, 0x2004
    addi $s1, $zero, 31
    addi $s2, $zero, 5
dump_loop:
    lw   $a0, 0($s0)
    jal  print_hex
    addi $s0, $s0, 4
    addi $s2, $s2, -1
    bne  $s2, $zero, no_nl
    jal  newline
    addi $s2, $zero, 5
no_nl:
    addi $s1, $s1, -1
    bne  $s1, $zero, dump_loop
    jal  newline
    addi $v0, $zero, 10
    syscall

fib:
    slti $t0, $a0, 2
    beq  $t0, $zero, fib_rec
    add  $v0, $a0, $zero
    jr   $ra
fib_rec:
    addi $sp, $sp, -12
    sw   $ra, 8($sp)
    sw   $a0, 4($sp)
    addi $a0, $a0, -1
    jal  fib
    sw   $v0, 0($sp)
    lw   $a0, 4($sp)
    addi $a0, $a0, -2
    jal  fib
    lw   $t1, 0($sp)
    add  $v0, $v0, $t1
    lw   $ra, 8($sp)
    addi $sp, $sp, 12
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
