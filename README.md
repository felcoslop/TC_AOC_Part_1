# Projeto de Arquitetura e Organização de Computadores
## Processador MIPS 32-bit com Unidade de Ponto Flutuante

## Descrição do Projeto

Este projeto implementa um processador MIPS de 32 bits em duas fases:

**Parte 1**: Processador de ciclo único com ULA de Ponto Flutuante integrada  
**Parte 2**: Evolução para arquitetura pipeline com memória cache

## ISA Estendida - Instruções de Ponto Flutuante

A arquitetura MIPS foi estendida com três novas instruções de ponto flutuante no formato Tipo-R:

### Formato das Instruções (Tipo-R)
```
| opcode (6) | rs (5) | rt (5) | rd (5) | shamt (5) | funct (6) |
```

### Instruções Implementadas

| Instrução | Formato | Opcode | Funct | Descrição |
|-----------|---------|--------|-------|-----------|
| **fadd** | `fadd rd, rs, rt` | 0x00 | 0x23 (35) | Soma ponto flutuante: rd = rs + rt |
| **fsub** | `fsub rd, rs, rt` | 0x00 | 0x26 (38) | Subtração ponto flutuante: rd = rs - rt |
| **fmul** | `fmul rd, rs, rt` | 0x00 | 0x27 (39) | Multiplicação ponto flutuante: rd = rs × rt |

### Justificativa dos Opcodes

- **Opcode 0x00**: Utilizado para manter compatibilidade com instruções Tipo-R do MIPS padrão
- **Funct codes 0x23-0x27**: Escolhidos para não conflitar com instruções aritméticas básicas

## Arquitetura do Processador

### Parte 1: Processador Single-Cycle

#### Componentes Principais

1. **Unidade de Controle** (`unidade_controle.vhd`)
   - Decodifica opcode e funct
   - Gera sinais de controle para datapath
   - Suporta instruções de ponto flutuante
   - Suporta instrução LUI (Load Upper Immediate)

2. **ULA de Inteiros** (`ula_inteiros.vhd`)
   - Operações: ADD, SUB, AND, OR, SLT, NOR
   - Largura: 32 bits
   - Flag de zero para desvios

3. **ULA de Ponto Flutuante** (`fpu_*.vhd`)
   - FPAdder: Soma IEEE 754 single-precision
   - FPSubtractor: Subtração IEEE 754
   - FPMultiplier: Multiplicação IEEE 754
   - Implementados seguindo os princípios do FloPoCo (Floating Point Cores)
   - Veja `FLOPOCO_INTEGRATION.md` para detalhes sobre integração com FloPoCo

4. **Banco de Registradores** (`banco_registradores.vhd`)
   - 32 registradores de 32 bits
   - 2 portas de leitura, 1 porta de escrita
   - Registrador $0 sempre zero

5. **Memórias**
   - `memoria_instrucoes.vhd`: ROM para código de máquina
   - `memoria_dados.vhd`: RAM para dados

6. **Componentes Auxiliares**
   - Program Counter (PC)
   - Multiplexadores
   - Extensor de sinal

#### Datapath

```
[PC] -> [Memoria Instrucoes] -> [Unidade Controle]
                              -> [Banco Registradores] -> [MUX] -> [ULA Inteiros]
                                                       -> [MUX] -> [FPU]
[Memoria Dados] <-> [MUX resultados]
```

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
- `lui` - Load upper immediate

#### Instruções FPU Estendidas (Tipo-R)
- `fadd` - Soma de ponto flutuante (baseado em FloPoCo)
- `fsub` - Subtração de ponto flutuante (baseado em FloPoCo)
- `fmul` - Multiplicação de ponto flutuante (baseado em FloPoCo)

### Parte 2: Processador Pipeline (A ser implementado)

#### Estágios do Pipeline

1. **IF** (Instruction Fetch): Busca da instrução
2. **ID** (Instruction Decode): Decodificação e leitura de registradores
3. **EX** (Execute): Execução na ULA/FPU
4. **MEM** (Memory Access): Acesso à memória/cache
5. **WB** (Write Back): Escrita no banco de registradores

#### Tratamento de Hazards

- **Data Hazards**: Unidade de forwarding
- **Control Hazards**: Branch prediction (not-taken) + flush

#### Memória Cache

- **Tipo**: Mapeamento direto
- **Justificativa**: Simplicidade favorece a regularidade
- **Política de substituição**: Não aplicável (direto)
- **Política de escrita**: Write-through com write buffer

## Integração FloPoCo

Os componentes FPU seguem os princípios do FloPoCo (Floating Point Cores Generator), uma ferramenta acadêmica reconhecida internacionalmente para geração de operadores aritméticos de ponto flutuante otimizados. Todos os arquivos FPU contêm comentários explicando como gerar versões equivalentes usando FloPoCo. 

**Veja `FLOPOCO_INTEGRATION.md` para detalhes completos sobre integração com FloPoCo.**

## Programa de Teste

O programa `teste_parte1.asm` executa os seguintes testes:

### Teste 1: Load/Store
- Carrega valores de ponto flutuante da memória
- Valida: `$s0 = 2.5`, `$s1 = 3.0`, `$s2 = 1.5`

### Teste 2: FADD (Soma de Ponto Flutuante)
- Calcula `$s3 = $s0 + $s1`
- Resultado esperado: `$s3 = 5.5`
- Armazena resultado na memória[12]

### Teste 3: FSUB (Subtração de Ponto Flutuante)
- Calcula `$s4 = $s3 - $s2` (5.5 - 1.5)
- Resultado esperado: `$s4 = 4.0`
- Armazena resultado na memória[16]

### Teste 4: FMUL (Multiplicação de Ponto Flutuante)
- Calcula `$s5 = $s0 × $s1`
- Resultado esperado: `$s5 = 7.5`
- Armazena resultado na memória[20]

### Teste 5: Operações de Inteiros
- Calcula `$t3 = 30` e `$t7 = 1`
- Testa instruções ADD e SUB
- Armazena resultados na memória

### Teste 6: Branch
- Testa instrução `beq`
- Valida: `$s6 = 100` (prova que branch funcionou)

### Teste 7: Immediate
- Testa `addi`
- Valida: `$s7 = 50`

### Teste LUI (Load Upper Immediate)
- Testa instrução `lui $t0, 0x1001`
- Valida: `$t0 = 0x10010000`

## Resultados da Simulação

### Valores Finais Esperados (VALIDADOS)

#### Registradores de Ponto Flutuante
- **$s0**: `0x40200000` (2.5 em IEEE 754)
- **$s1**: `0x40400000` (3.0 em IEEE 754)
- **$s2**: `0x3FC00000` (1.5 em IEEE 754)
- **$s3**: `0x40B00000` (5.5 em IEEE 754 - FADD)
- **$s4**: `0x40800000` (4.0 em IEEE 754 - FSUB)
- **$s5**: `0x40F00000` (7.5 em IEEE 754 - FMUL)

#### Registradores de Inteiros
- **$t0**: `0x10010000` (LUI)
- **$t3**: `0x0000001E` (30 em decimal)
- **$t7**: `0x00000001` (1 em decimal)
- **$s6**: `0x00000064` (100 - Branch)
- **$s7**: `0x00000032` (50 - ADDI)

#### Memória de Dados
- **Memória[12]**: `0x40B00000` (5.5 FP)
- **Memória[16]**: `0x40800000` (4.0 FP)
- **Memória[20]**: `0x40F00000` (7.5 FP)
- **Memória[32]**: `0x0000001E` (30)

## Como Executar no EDA Playground

### Configuração Inicial
1. Acesse https://www.edaplayground.com
2. Selecione **VHDL** como linguagem
3. Selecione **GHDL 3.0.0** como simulador
4. Deixe o campo **"Run Options"** vazio

### Upload dos Arquivos
1. **`design.vhd`** → Cole o conteúdo de `design.vhd`
2. **`testbench.vhd`** → Cole o conteúdo de `testbench.vhd`
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
- Reset funcionando corretamente
- Clock oscilando em 10ns (100 MHz)
- PC incrementando e fazendo branches
- Registradores sendo escritos nos momentos corretos
- Valores finais nos registradores correspondem aos esperados
- Operações FPU produzindo resultados corretos
- Memória sendo acessada corretamente
- Instrução LUI funcionando corretamente

## Estrutura de Arquivos

```
.
├── README.md                          # Este arquivo
├── WAVEFORM_README.md                 # Guia de análise do waveform
├── FLOPOCO_INTEGRATION.md             # Documentação sobre FloPoCo
├── design.vhd                         # Módulo principal (processador_mips.vhd)
├── testbench.vhd                      # Testbench principal
├── unidade_controle.vhd               # Unidade de controle
├── ula_control.vhd                    # Controle da ULA
├── ula_inteiros.vhd                   # ULA de inteiros
├── banco_registradores.vhd            # Banco de registradores
├── memoria_instrucoes.vhd             # Memória de instruções
├── memoria_dados.vhd                  # Memória de dados
├── fpu_adder.vhd                      # Somador FPU (FloPoCo)
├── fpu_subtractor.vhd                 # Subtrator FPU (FloPoCo)
├── fpu_multiplier.vhd                 # Multiplicador FPU (FloPoCo)
├── teste_parte1.asm                   # Programa de teste em Assembly
├── teste_parte1_codigo_maquina.txt    # Código de máquina
├── trabalho_mips.tex                  # Relatório LaTeX do projeto
└── waveform*.png                      # Capturas de tela dos waveforms
```

## Referências

- Patterson & Hennessy - "Organização e Projeto de Computadores"
- MIPS32 Architecture for Programmers
- IEEE 754 Floating-Point Standard
- FloPoCo - Floating Point Cores Generator (https://flopoco.org/)
- DE DINECHIN, F.; KUMM, M. Application-Specific Arithmetic. Springer, 2024.
- DE DINECHIN, F.; PASCA, B. Designing custom arithmetic data paths with FloPoCo. IEEE Design & Test of Computers, 28(4):18--27, 2011.
