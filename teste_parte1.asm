# ============================================================================
# Programa de Teste - Processador MIPS com FPU
# Parte 1: Single-Cycle
# ============================================================================
# Este programa testa todas as funcionalidades do processador:
# - Instruções de load/store
# - Instruções aritméticas inteiras
# - Instruções de ponto flutuante (fadd, fsub, fmul)
# - Instruções de desvio (branch)
# ============================================================================

.data
    # Valores em ponto flutuante (IEEE 754 single-precision)
    # 2.5 = 0x40200000
    # 3.0 = 0x40400000
    # 5.5 = 0x40B00000
    # 1.5 = 0x3FC00000
    # 7.5 = 0x40F00000
    
    valor1: .word 0x40200000    # 2.5 em ponto flutuante
    valor2: .word 0x40400000    # 3.0 em ponto flutuante
    valor3: .word 0x3FC00000    # 1.5 em ponto flutuante
    resultado_add: .word 0      # Para armazenar 2.5 + 3.0 = 5.5
    resultado_sub: .word 0      # Para armazenar 5.5 - 1.5 = 4.0
    resultado_mul: .word 0      # Para armazenar 2.5 * 3.0 = 7.5
    
    # Valores inteiros para testes
    int_a: .word 10
    int_b: .word 20
    int_result: .word 0

.text
.globl main

main:
    # ========== TESTE 1: Instruções de Load/Store ==========
    # Carrega valores da memória
    lui  $t0, 0x1001        # Endereço base da memória de dados
    
    lw   $s0, 0($t0)        # $s0 = valor1 = 2.5 (0x40200000)
    lw   $s1, 4($t0)        # $s1 = valor2 = 3.0 (0x40400000)
    lw   $s2, 8($t0)        # $s2 = valor3 = 1.5 (0x3FC00000)
    
    # VALORES ESPERADOS após TESTE 1:
    # $s0 = 0x40200000 (2.5)
    # $s1 = 0x40400000 (3.0)
    # $s2 = 0x3FC00000 (1.5)
    
    
    # ========== TESTE 2: Instrução FADD (Soma Ponto Flutuante) ==========
    # Operação: 2.5 + 3.0 = 5.5
    # NOTA: Esta instrução não existe no MIPS padrão
    # Opcode: 0x00 (Tipo-R), Funct: 0x23
    
    # fadd $s3, $s0, $s1   # $s3 = $s0 + $s1 = 2.5 + 3.0 = 5.5
    # Codificação: 000000 10000 10001 10011 00000 100011
    # Usando .word para inserir a instrução diretamente
    .word 0x02119823         # fadd $s3, $s0, $s1
    
    # Salva o resultado na memória
    sw   $s3, 12($t0)       # resultado_add = 5.5 (0x40B00000)
    
    # VALORES ESPERADOS após TESTE 2:
    # $s3 = 0x40B00000 (5.5)
    # Memória[12] = 0x40B00000
    
    
    # ========== TESTE 3: Instrução FSUB (Subtração Ponto Flutuante) ==========
    # Operação: 5.5 - 1.5 = 4.0
    # Opcode: 0x00 (Tipo-R), Funct: 0x26
    
    # fsub $s4, $s3, $s2   # $s4 = $s3 - $s2 = 5.5 - 1.5 = 4.0
    # Codificação: 000000 10011 10010 10100 00000 100110
    .word 0x0272A026         # fsub $s4, $s3, $s2
    
    # Salva o resultado na memória
    sw   $s4, 16($t0)       # resultado_sub = 4.0 (0x40800000)
    
    # VALORES ESPERADOS após TESTE 3:
    # $s4 = 0x40800000 (4.0)
    # Memória[16] = 0x40800000
    
    
    # ========== TESTE 4: Instrução FMUL (Multiplicação Ponto Flutuante) ==========
    # Operação: 2.5 * 3.0 = 7.5
    # Opcode: 0x00 (Tipo-R), Funct: 0x27
    
    # fmul $s5, $s0, $s1   # $s5 = $s0 * $s1 = 2.5 * 3.0 = 7.5
    # Codificação: 000000 10000 10001 10101 00000 100111
    .word 0x0211A827         # fmul $s5, $s0, $s1
    
    # Salva o resultado na memória
    sw   $s5, 20($t0)       # resultado_mul = 7.5 (0x40F00000)
    
    # VALORES ESPERADOS após TESTE 4:
    # $s5 = 0x40F00000 (7.5)
    # Memória[20] = 0x40F00000
    
    
    # ========== TESTE 5: Operações Inteiras ==========
    # Testa ULA de inteiros
    
    lw   $t1, 24($t0)       # $t1 = int_a = 10
    lw   $t2, 28($t0)       # $t2 = int_b = 20
    
    add  $t3, $t1, $t2      # $t3 = 10 + 20 = 30
    sub  $t4, $t2, $t1      # $t4 = 20 - 10 = 10
    and  $t5, $t1, $t2      # $t5 = 10 AND 20 = 0
    or   $t6, $t1, $t2      # $t6 = 10 OR 20 = 30
    slt  $t7, $t1, $t2      # $t7 = (10 < 20) = 1
    
    # Salva resultado da soma
    sw   $t3, 32($t0)       # int_result = 30
    
    # VALORES ESPERADOS após TESTE 5:
    # $t1 = 10 (0x0000000A)
    # $t2 = 20 (0x00000014)
    # $t3 = 30 (0x0000001E)
    # $t4 = 10 (0x0000000A)
    # $t5 = 0  (0x00000000)
    # $t6 = 30 (0x0000001E)
    # $t7 = 1  (0x00000001)
    # Memória[32] = 30
    
    
    # ========== TESTE 6: Instruções de Branch ==========
    # Testa beq (branch if equal)
    
    addi $t8, $zero, 5      # $t8 = 5
    addi $t9, $zero, 5      # $t9 = 5
    
    beq  $t8, $t9, igual    # Se $t8 == $t9, salta para 'igual'
    
    # Este código NÃO deve ser executado
    addi $s6, $zero, 99     # $s6 = 99 (não deve acontecer)
    
igual:
    addi $s6, $zero, 100    # $s6 = 100 (deve ser executado)
    
    # VALORES ESPERADOS após TESTE 6:
    # $t8 = 5   (0x00000005)
    # $t9 = 5   (0x00000005)
    # $s6 = 100 (0x00000064) - prova que o branch funcionou
    
    
    # ========== TESTE 7: Immediate Operations ==========
    # Testa addi
    
    addi $s7, $zero, 42     # $s7 = 0 + 42 = 42
    addi $s7, $s7, 8        # $s7 = 42 + 8 = 50
    
    # VALORES ESPERADOS após TESTE 7:
    # $s7 = 50 (0x00000032)
    
    
    # ========== FIM DO PROGRAMA ==========
    # Loop infinito para manter o processador ativo
fim:
    j fim                   # Loop infinito
    

# ============================================================================
# RESUMO DOS VALORES ESPERADOS AO FINAL DA EXECUÇÃO
# ============================================================================
#
# REGISTRADORES:
# $s0 = 0x40200000  (2.5 em FP)
# $s1 = 0x40400000  (3.0 em FP)
# $s2 = 0x3FC00000  (1.5 em FP)
# $s3 = 0x40B00000  (5.5 em FP) - resultado de fadd
# $s4 = 0x40800000  (4.0 em FP) - resultado de fsub
# $s5 = 0x40F00000  (7.5 em FP) - resultado de fmul
# $s6 = 0x00000064  (100 decimal) - teste de branch
# $s7 = 0x00000032  (50 decimal) - teste de addi
#
# $t1 = 0x0000000A  (10 decimal)
# $t2 = 0x00000014  (20 decimal)
# $t3 = 0x0000001E  (30 decimal)
# $t4 = 0x0000000A  (10 decimal)
# $t5 = 0x00000000  (0)
# $t6 = 0x0000001E  (30 decimal)
# $t7 = 0x00000001  (1)
# $t8 = 0x00000005  (5)
# $t9 = 0x00000005  (5)
#
# MEMÓRIA (base 0x10010000):
# [0]  = 0x40200000  (valor1: 2.5)
# [4]  = 0x40400000  (valor2: 3.0)
# [8]  = 0x3FC00000  (valor3: 1.5)
# [12] = 0x40B00000  (resultado_add: 5.5)
# [16] = 0x40800000  (resultado_sub: 4.0)
# [20] = 0x40F00000  (resultado_mul: 7.5)
# [24] = 0x0000000A  (int_a: 10)
# [28] = 0x00000014  (int_b: 20)
# [32] = 0x0000001E  (int_result: 30)
#
# ============================================================================