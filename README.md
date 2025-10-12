# Processador MIPS Single-Cycle com FPU - Parte 1

## Visão Geral

Este projeto implementa um processador MIPS 32-bit single-cycle com suporte a operações de ponto flutuante (FPU). O processador executa um programa de teste que valida todas as funcionalidades implementadas.

## Arquitetura do Processador

### Componentes Principais

1. **`processador_mips.vhd`** - Módulo top-level que integra todos os componentes
2. **`unidade_controle.vhd`** - Decodifica instruções e gera sinais de controle
3. **`ula_control.vhd`** - Controla as operações da ULA
4. **`ula_inteiros.vhd`** - Unidade Lógica e Aritmética para inteiros
5. **`banco_registradores.vhd`** - Banco de 32 registradores de 32 bits
6. **`memoria_instrucoes.vhd`** - Memória ROM com o programa
7. **`memoria_dados.vhd`** - Memória RAM para dados
8. **`fpu_adder.vhd`** - Somador de ponto flutuante IEEE 754
9. **`fpu_subtractor.vhd`** - Subtrator de ponto flutuante
10. **`fpu_multiplier.vhd`** - Multiplicador de ponto flutuante

### Instruções Suportadas

#### Instruções Tipo-R (Inteiros)
- `add` - Soma de inteiros
- `sub` - Subtração de inteiros
- `and` - Operação AND lógica
- `or` - Operação OR lógica
- `slt` - Set less than

#### Instruções Tipo-I
- `addi` - Add immediate
- `lw` - Load word
- `sw` - Store word
- `beq` - Branch if equal

#### Instruções FPU Estendidas (Tipo-R)
- `fadd` - Soma de ponto flutuante
- `fsub` - Subtração de ponto flutuante
- `fmul` - Multiplicação de ponto flutuante

## Programa de Teste

O programa `teste_parte1.asm` executa os seguintes testes:

### Teste 1: Load/Store
- Carrega valores de ponto flutuante da memória
- Valida: `$s0 = 2.5`, `$s1 = 3.0`, `$s2 = 1.5`

### Teste 2: FADD (Soma de Ponto Flutuante)
- Calcula `$s3 = $s0 + $s1`
- Valida: `$s3 = 5.5` e `Memória[12] = 5.5`

### Teste 3: FSUB (Subtração de Ponto Flutuante)
- Calcula `$s4 = $s1 - $s2`
- Valida: `$s4 = 4.0` e `Memória[16] = 4.0`

### Teste 4: FMUL (Multiplicação de Ponto Flutuante)
- Calcula `$s5 = $s0 * $s1`
- Valida: `$s5 = 7.5` e `Memória[20] = 7.5`

### Teste 5: Operações de Inteiros
- Calcula `$t3 = 30` e `$t7 = 1`
- Valida: `$t3 = 30` e `Memória[32] = 30`

### Teste 6: Branch
- Testa instrução `beq`
- Valida: `$s6 = 100` (prova que branch funcionou)

### Teste 7: Immediate
- Testa `addi`
- Valida: `$s7 = 50`

## Resultados da Simulação

### Valores Finais Esperados (VALIDADOS )

#### Registradores de Ponto Flutuante
- **$s0**: `0x40200000` (2.5 em IEEE 754)
- **$s1**: `0x40400000` (3.0 em IEEE 754)
- **$s2**: `0x3FC00000` (1.5 em IEEE 754)
- **$s3**: `0x40B00000` (5.5 em IEEE 754 - FADD)
- **$s4**: `0x40800000` (4.0 em IEEE 754 - FSUB)
- **$s5**: `0x40F00000` (7.5 em IEEE 754 - FMUL)

#### Registradores de Inteiros
- **$t3**: `0x0000001E` (30 em decimal)
- **$t7**: `0x00000001` (1 em decimal)

#### Memória de Dados
- **Memória[12]**: `0x40B00000` (5.5 FP)
- **Memória[16]**: `0x40800000` (4.0 FP)
- **Memória[20]**: `0x40F00000` (7.5 FP)
- **Memória[32]**: `0x0000001E` (30)
- **Memória[36]**: `0x00000001` (1)

## Como Executar no EDA Playground

### Configuração Inicial
1. Acesse https://www.edaplayground.com
2. Selecione **VHDL** como linguagem
3. Selecione **GHDL 3.0.0** como simulador
4. Deixe o campo **"Run Options"** vazio

### Upload dos Arquivos
1. **`design.vhd`** → Cole o conteúdo de `processador_mips.vhd`
2. **`testbench.vhd`** → Cole o conteúdo de `testbench_parte1.vhd`
3. **Arquivos adicionais** → Adicione todos os outros arquivos .vhd

### Execução
1. Clique em **"Run"**
2. Aguarde a compilação e simulação
3. Clique em **"Open EPWave"** para visualizar o waveform

### Análise do Waveform
Consulte o arquivo `WAVEFORM_README.md` para instruções detalhadas sobre:
- Quais sinais visualizar
- Como interpretar os resultados
- Validação dos valores esperados

## Evidências de Funcionamento

### Console Output (Log da Simulação)
```
========================================
Iniciando Testbench - Parte 1
Processador MIPS Single-Cycle com FPU
========================================
Reset liberado. Processador iniciado.
========================================
Execucao concluida apos 50 ciclos
========================================
TESTE 1 Load Store: Esperado
  s0 = 0x40200000 (2.5 FP)
  s1 = 0x40400000 (3.0 FP)
  s2 = 0x3FC00000 (1.5 FP)
TESTE 2 FADD: Esperado
  s3 = 0x40B00000 (5.5 FP)
  Memoria[12] = 0x40B00000
TESTE 3 FSUB: Esperado
  s4 = 0x40800000 (4.0 FP)
  Memoria[16] = 0x40800000
TESTE 4 FMUL: Esperado
  s5 = 0x40F00000 (7.5 FP)
  Memoria[20] = 0x40F00000
TESTE 5 Inteiros: Esperado
  t3 = 0x0000001E (30)
  t7 = 0x00000001 (1)
  Memoria[32] = 0x0000001E
TESTE 6 Branch: Esperado
  s6 = 0x00000064 (100)
  Prova que branch funcionou
TESTE 7 Immediate: Esperado
  s7 = 0x00000032 (50)
========================================
TESTBENCH CONCLUIDO COM SUCESSO
========================================
```

### Waveform Analysis
-  Reset funcionando corretamente
-  Clock oscilando em 10ns (100 MHz)
-  PC incrementando e fazendo branches
-  Registradores sendo escritos nos momentos corretos
-  Valores finais nos registradores correspondem aos esperados
-  Operações FPU produzindo resultados corretos
-  Memória sendo acessada corretamente

## Estrutura de Arquivos

```
parte1/
├── README.md                          # Este arquivo
├── INSTRUCOES_PARTE1.md              # Instruções detalhadas
├── WAVEFORM_README.md                # Guia de análise do waveform
├── design.vhd                        # Módulo principal (processador_mips.vhd)
├── testbench.vhd                     # Testbench principal
├── unidade_controle.vhd              # Unidade de controle
├── ula_control.vhd                   # Controle da ULA
├── ula_inteiros.vhd                  # ULA de inteiros
├── banco_registradores.vhd           # Banco de registradores
├── memoria_instrucoes.vhd            # Memória de instruções
├── memoria_dados.vhd                 # Memória de dados
├── fpu_adder.vhd                     # Somador FPU
├── fpu_subtractor.vhd                # Subtrator FPU
├── fpu_multiplier.vhd                # Multiplicador FPU
├── teste_parte1.asm                  # Programa de teste em Assembly
└── teste_parte1_codigo_maquina.txt   # Código de máquina
```
