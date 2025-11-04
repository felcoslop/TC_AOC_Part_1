# Guia de Análise do Waveform

## 1. Propósito do Waveform

O waveform visualiza os valores dos sinais internos e externos do processador ao longo do tempo, permitindo:
- **Verificar funcionalidade:** Confirmar execução correta das instruções
- **Depuração:** Identificar erros rastreando valores dos sinais
- **Validação:** Comparar resultados com valores esperados do testbench

## 2. Sinais Principais para Análise

### 2.1. Sinais do Testbench (Scope: `/testbench`)

**Formato Recomendado:** Hexadecimal para todos os sinais, exceto `clk` e `reset` que devem ser binários.

#### Sinais de Controle Global

- **`clk`**: Clock principal do sistema
  - **Formato:** Binário
  - **Significado:** Sinal de clock com período de 10ns (100 MHz)
  - **O que observar:** Deve alternar entre '0' e '1' continuamente
  - **Importância:** Todas as operações síncronas são sincronizadas com este clock

- **`reset`**: Sinal de reset do processador
  - **Formato:** Binário
  - **Significado:** Inicializa o processador para estado conhecido
  - **O que observar:** Deve estar '1' no início da simulação e depois ir para '0'
  - **Importância:** Quando ativo, zera PC e registradores

#### Sinais de Monitoramento

- **`cycle_count`**: Contador de ciclos de clock
  - **Formato:** Hexadecimal
  - **Significado:** Conta quantos ciclos de clock se passaram desde o reset
  - **O que observar:** Deve incrementar a cada borda de subida do clock (quando reset = '0')
  - **Importância:** Útil para acompanhar progresso da simulação e número de instruções executadas

- **`sim_finished`**: Flag de término da simulação
  - **Formato:** Binário (mas pode ser hexadecimal para consistência)
  - **Significado:** Indica quando o testbench terminou sua sequência de testes
  - **O que observar:** Deve estar `false` durante execução e `true` no final
  - **Importância:** Controla quando a simulação deve parar

### 2.2. Sinais do Processador Principal (Scope: `/testbench/uut`)

**Formato Recomendado:** Hexadecimal

- **`pc`**: Program Counter - Endereço da instrução
  - **Significado:** Endereço da próxima instrução a ser executada
  - **O que observar:** Deve incrementar de 4 a cada ciclo ou saltar em branches
  - **Exemplo:** `0x00000000`, `0x00000004`, `0x00000008`, etc.
  - **Importância:** Rastreia o fluxo de execução do programa

- **`instrucao`**: Instrução atual sendo executada
  - **Significado:** Instrução de 32 bits sendo executada
  - **O que observar:** Deve mudar a cada ciclo conforme PC
  - **Formato:** Hexadecimal (ex: `0x8E100000` para LW)
  - **Importância:** Permite verificar qual instrução está sendo executada

### 2.3. Sinais da Unidade de Controle (Scope: `/testbench/uut/ctrl`)

**Formato Recomendado:** Hexadecimal para vetores, Binário para sinais simples

#### Sinais de Controle do Datapath

- **`reg_write`**: Habilita escrita no banco de registradores
  - **Formato:** Binário
  - **Significado:** Quando '1', permite escrita no registrador especificado
  - **O que observar:** Deve estar '1' durante instruções que escrevem em registradores
  - **Instruções ativas:** ADD, SUB, AND, OR, SLT, ADDI, LW, FADD, FSUB, FMUL, LUI

- **`reg_dst`**: Seleção do registrador destino
  - **Formato:** Binário
  - **Significado:** Seleciona rd (1) ou rt (0) como registrador de destino
  - **O que observar:** '1' para Tipo-R (incluindo FPU), '0' para Tipo-I

- **`alu_src`**: Seleção da segunda entrada da ULA
  - **Formato:** Binário
  - **Significado:** Seleciona rt (0) ou imediato (1) para segunda entrada da ULA
  - **O que observar:** '1' para LW, SW, ADDI, LUI; '0' para Tipo-R

- **`mem_to_reg`**: Seleção da origem dos dados para write-back
  - **Formato:** Binário
  - **Significado:** Seleciona ULA/FPU (0) ou memória (1) como fonte de dados
  - **O que observar:** '1' para LW, '0' para outras instruções

- **`mem_read`**: Habilita leitura da memória
  - **Formato:** Binário
  - **Significado:** Quando '1', habilita leitura da memória de dados
  - **O que observar:** '1' apenas durante instruções LW

- **`mem_write`**: Habilita escrita na memória
  - **Formato:** Binário
  - **Significado:** Quando '1', habilita escrita na memória de dados
  - **O que observar:** '1' apenas durante instruções SW

- **`branch`**: Indica instrução de desvio
  - **Formato:** Binário
  - **Significado:** Quando '1', indica instrução de branch (BEQ)
  - **O que observar:** '1' durante instruções BEQ

- **`alu_op[1:0]`**: Tipo de operação da ULA
  - **Formato:** Hexadecimal (2 bits)
  - **Significado:** Controla o tipo de operação da ULA
  - **Valores:**
    - `00` = ADD (LW, SW, ADDI)
    - `01` = SUB (BEQ)
    - `10` = Tipo-R (instruções aritméticas)
    - `11` = LUI (Load Upper Immediate)
  - **Importância:** Define qual operação será executada na ULA

#### Sinais de Controle da FPU

- **`is_fp_op`**: Indica operação de ponto flutuante
  - **Formato:** Binário
  - **Significado:** Quando '1', ativa operação na FPU
  - **O que observar:** '1' durante instruções FADD, FSUB, FMUL

- **`fp_op_type[1:0]`**: Tipo de operação da FPU
  - **Formato:** Hexadecimal (2 bits)
  - **Significado:** Define qual operação FPU será executada
  - **Valores:**
    - `00` = FADD (Soma de ponto flutuante)
    - `01` = FSUB (Subtração de ponto flutuante)
    - `10` = FMUL (Multiplicação de ponto flutuante)
  - **Importância:** Seleciona qual unidade FPU será utilizada

### 2.4. Sinais do Banco de Registradores (Scope: `/testbench/uut/regs`)

**Formato Recomendado:** Hexadecimal

#### Sinais de Interface

- **`read_reg1[4:0]`**: Endereço do primeiro registrador a ler
  - **Significado:** Campo Rs da instrução (5 bits = 32 registradores)
  - **O que observar:** Deve mudar a cada instrução executada
  - **Exemplo:** `0x10` = registrador $s0 (16)

- **`read_reg2[4:0]`**: Endereço do segundo registrador a ler
  - **Significado:** Campo Rt da instrução
  - **O que observar:** Deve mudar conforme instrução executada

- **`write_reg[4:0]`**: Endereço do registrador para escrita
  - **Significado:** Registrador de destino (Rd ou Rt dependendo da instrução)
  - **O que observar:** Deve indicar qual registrador será atualizado
  - **Importância:** Confirma qual registrador receberá o resultado

- **`write_data[31:0]`**: Dados a serem escritos
  - **Significado:** Valor de 32 bits a ser armazenado no registrador
  - **O que observar:** Dados que serão salvos no registrador especificado
  - **Exemplos:**
    - `0x40200000` = 2.5 em IEEE 754
    - `0x0000001E` = 30 em decimal

- **`read_data1[31:0]`**: Dados lidos do primeiro registrador
  - **Significado:** Valor atual do registrador read_reg1
  - **O que observar:** Deve conter o valor do registrador especificado

- **`read_data2[31:0]`**: Dados lidos do segundo registrador
  - **Significado:** Valor atual do registrador read_reg2
  - **O que observar:** Deve conter o valor do registrador especificado

- **`reg_write`**: Habilita escrita no banco (repetido aqui para contexto local)
  - **Formato:** Binário
  - **Significado:** Quando '1', permite escrita no registrador especificado

#### Array de Registradores Internos

- **`registradores[0]` até `registradores[31]`**: Valores dos 32 registradores
  - **Formato:** Hexadecimal
  - **Significado:** Array interno com valores de todos os registradores
  - **Mapeamento MIPS:**
    - `registradores[0]` = $0 (sempre zero)
    - `registradores[1]` = $at (assembler temporary)
    - `registradores[2-3]` = $v0-$v1 (return values)
    - `registradores[4-7]` = $a0-$a3 (arguments)
    - `registradores[8-15]` = $t0-$t7 (temporaries)
    - `registradores[16-23]` = $s0-$s7 (saved registers) ⭐ **IMPORTANTES**
    - `registradores[24-25]` = $t8-$t9 (temporaries)
    - `registradores[26-27]` = $k0-$k1 (kernel)
    - `registradores[28]` = $gp (global pointer)
    - `registradores[29]` = $sp (stack pointer)
    - `registradores[30]` = $fp (frame pointer)
    - `registradores[31]` = $ra (return address)

### 2.5. Sinais da ULA de Inteiros (Scope: `/testbench/uut/alu`)

**Formato Recomendado:** Hexadecimal

- **`resultado[31:0]`**: Resultado da operação da ULA
  - **Significado:** Resultado de 32 bits da operação aritmética ou lógica
  - **Exemplos:**
    - `0x0000001E` = 30 (resultado de ADD)
    - `0x00000001` = 1 (resultado de SUB ou SLT)
  - **Importância:** Resultado final das operações de inteiros

- **`zero`**: Flag de comparação para branches
  - **Formato:** Binário
  - **Significado:** Quando '1', indica que o resultado da subtração é zero
  - **O que observar:** Usado para instruções BEQ (Branch if Equal)
  - **Importância:** Determina se um branch deve ser tomado

### 2.6. Sinais do Controle da ULA (Scope: `/testbench/uut/alu_ctrl`)

**Formato Recomendado:** Hexadecimal

- **`controle[3:0]`**: Sinal de controle de 4 bits para a ULA
  - **Significado:** Define qual operação específica a ULA deve executar
  - **Valores:**
    - `0x0` = AND
    - `0x1` = OR
    - `0x2` = ADD
    - `0x6` = SUB
    - `0x7` = SLT (Set Less Than)
  - **Importância:** Controle fino das operações da ULA baseado em `alu_op` e `funct`

### 2.7. Sinais das Unidades FPU

**Formato Recomendado:** Hexadecimal

#### FPU Adder (Scope: `/testbench/uut/fpu_add`)

- **`operando_a[31:0]`**: Primeiro operando de ponto flutuante
  - **Formato:** Hexadecimal (IEEE 754 single-precision)
  - **Exemplo:** `0x40200000` = 2.5

- **`operando_b[31:0]`**: Segundo operando de ponto flutuante
  - **Formato:** Hexadecimal (IEEE 754 single-precision)
  - **Exemplo:** `0x40400000` = 3.0

- **`resultado[31:0]`**: Resultado da soma
  - **Formato:** Hexadecimal (IEEE 754 single-precision)
  - **Exemplo:** `0x40B00000` = 5.5 (resultado de 2.5 + 3.0)

#### FPU Subtractor (Scope: `/testbench/uut/fpu_sub`)

- **`operando_a[31:0]`**: Primeiro operando de ponto flutuante
- **`operando_b[31:0]`**: Segundo operando de ponto flutuante (será invertido)
- **`resultado[31:0]`**: Resultado da subtração
  - **Exemplo:** `0x40800000` = 4.0 (resultado de 5.5 - 1.5)

#### FPU Multiplier (Scope: `/testbench/uut/fpu_mul`)

- **`operando_a[31:0]`**: Primeiro operando de ponto flutuante
- **`operando_b[31:0]`**: Segundo operando de ponto flutuante
- **`resultado[31:0]`**: Resultado da multiplicação
  - **Exemplo:** `0x40F00000` = 7.5 (resultado de 2.5 × 3.0)

### 2.8. Sinais do Datapath (Scope: `/testbench/uut`)

**Formato Recomendado:** Hexadecimal

- **`lui_result[31:0]`**: Resultado da instrução LUI
  - **Significado:** Valor calculado para Load Upper Immediate
  - **O que observar:** Aparece quando `alu_op = "11"`
  - **Exemplo:** `0x10010000` (resultado de `lui $t0, 0x1001`)

- **`exec_result[31:0]`**: Resultado final da execução (após multiplexação)
  - **Significado:** Seleciona entre resultado da ULA, FPU ou LUI
  - **O que observar:** 
    - Se `is_fp_op = '1'`, vem da FPU
    - Se `alu_op = "11"`, vem de `lui_result`
    - Caso contrário, vem da ULA de inteiros

### 2.9. Sinais da Memória de Dados (Scope: `/testbench/uut/mem_data_inst`)

**Formato Recomendado:** Hexadecimal

- **`endereco[31:0]`**: Endereço acessado na memória
  - **Significado:** Endereço de 32 bits para acesso à memória
  - **O que observar:** Deve ser múltiplo de 4 (word-aligned)
  - **Exemplo:** `0x00000030` = endereço 48 (palavra 12)

- **`write_data[31:0]`**: Dados a serem escritos na memória
  - **Significado:** Valor de 32 bits a ser armazenado
  - **O que observar:** Aparece durante instruções SW

- **`read_data[31:0]`**: Dados lidos da memória
  - **Significado:** Valor de 32 bits lido da memória
  - **O que observar:** Aparece durante instruções LW

## 3. Valores Esperados para Validação

Conforme o testbench, após execução completa (50 ciclos, 520ns), verifique:

### 3.1. Registradores de Ponto Flutuante

- **`registradores[16]` ($s0)**: `0x40200000` (2.5 em IEEE 754)
- **`registradores[17]` ($s1)**: `0x40400000` (3.0 em IEEE 754)
- **`registradores[18]` ($s2)**: `0x3FC00000` (1.5 em IEEE 754)
- **`registradores[19]` ($s3)**: `0x40B00000` (5.5 em IEEE 754 - resultado FADD)
- **`registradores[20]` ($s4)**: `0x40800000` (4.0 em IEEE 754 - resultado FSUB)
- **`registradores[21]` ($s5)**: `0x40F00000` (7.5 em IEEE 754 - resultado FMUL)

### 3.2. Registradores de Inteiros

- **`registradores[8]` ($t0)**: `0x10010000` (LUI)
- **`registradores[11]` ($t3)**: `0x0000001E` (30 em decimal)
- **`registradores[15]` ($t7)**: `0x00000001` (1 em decimal)
- **`registradores[22]` ($s6)**: `0x00000064` (100 - Branch)
- **`registradores[23]` ($s7)**: `0x00000032` (50 - ADDI)

### 3.3. Memória de Dados

- **Memória[12]**: `0x40B00000` (5.5 FP - resultado FADD)
- **Memória[16]**: `0x40800000` (4.0 FP - resultado FSUB)
- **Memória[20]**: `0x40F00000` (7.5 FP - resultado FMUL)
- **Memória[32]**: `0x0000001E` (30 - resultado ADD)

## 4. Como Adicionar Sinais no EPWave

1. **Execute a simulação** no EDA Playground
2. **Clique em "Open EPWave"** após a simulação
3. **Navegue pela hierarquia** no painel esquerdo
4. **Expanda os scopes** desejados (testbench, uut, ctrl, regs, etc.)
5. **Selecione os sinais** clicando neles
6. **Arraste para o painel principal** ou use o botão direito → "Add to Waveform"
7. **Configure o formato de exibição:**
   - Sinais de dados: Hexadecimal
   - Sinais de controle binários: Binário
   - Clock e Reset: Binário
8. **Configure zoom** e escala de tempo conforme necessário

## 5. Sinais Recomendados para Análise Completa

### 5.1. Conjunto Mínimo Essencial

Estes sinais são suficientes para validar o funcionamento básico:

1. `/testbench/clk` (Binário)
2. `/testbench/reset` (Binário)
3. `/testbench/uut/pc` (Hexadecimal)
4. `/testbench/uut/instrucao` (Hexadecimal)
5. `/testbench/uut/regs/registradores[16]` até `registradores[23]` (s0-s7) (Hexadecimal)
6. `/testbench/uut/regs/registradores[8]` até `registradores[15]` (t0-t7) (Hexadecimal)

### 5.2. Para Análise Detalhada de Controle

Adicione estes sinais para entender o fluxo de controle:

1. `/testbench/uut/ctrl/reg_write` (Binário)
2. `/testbench/uut/ctrl/alu_op[1:0]` (Hexadecimal)
3. `/testbench/uut/ctrl/is_fp_op` (Binário)
4. `/testbench/uut/ctrl/fp_op_type[1:0]` (Hexadecimal)
5. `/testbench/uut/ctrl/mem_read` (Binário)
6. `/testbench/uut/ctrl/mem_write` (Binário)
7. `/testbench/uut/ctrl/branch` (Binário)

### 5.3. Para Análise de Execução

Adicione para verificar operações específicas:

1. `/testbench/uut/alu/resultado[31:0]` (Hexadecimal)
2. `/testbench/uut/alu/zero` (Binário)
3. `/testbench/uut/alu_ctrl/controle[3:0]` (Hexadecimal)
4. `/testbench/uut/fpu_add/resultado[31:0]` (Hexadecimal)
5. `/testbench/uut/fpu_sub/resultado[31:0]` (Hexadecimal)
6. `/testbench/uut/fpu_mul/resultado[31:0]` (Hexadecimal)
7. `/testbench/uut/exec_result[31:0]` (Hexadecimal)

### 5.4. Para Análise de Memória

Adicione para verificar operações de memória:

1. `/testbench/uut/mem_data_inst/endereco[31:0]` (Hexadecimal)
2. `/testbench/uut/mem_data_inst/read_data[31:0]` (Hexadecimal)
3. `/testbench/uut/mem_data_inst/write_data[31:0]` (Hexadecimal)

## 6. Validação dos Resultados

### 6.1. Análise Realizada

O waveform foi analisado em detalhes e **TODOS OS VALORES FORAM CONFIRMADOS COMO CORRETOS**:

#### Registradores de Ponto Flutuante - VALIDADOS

- **$s0** (`write_reg = 10`): `write_data = 0x40200000` - **2.5 FP**
- **$s1** (`write_reg = 11`): `write_data = 0x40400000` - **3.0 FP**
- **$s2** (`write_reg = 12`): `write_data = 0x3FC00000` - **1.5 FP**
- **$s3** (`write_reg = 13`): `write_data = 0x40B00000` - **5.5 FP (FADD)**
- **$s4** (`write_reg = 14`): `write_data = 0x40800000` - **4.0 FP (FSUB)**
- **$s5** (`write_reg = 15`): `write_data = 0x40F00000` - **7.5 FP (FMUL)**

#### Registradores de Inteiros - VALIDADOS

- **$t0** (`write_reg = 08`): `write_data = 0x10010000` - **LUI**
- **$t3** (`write_reg = 0B`): `write_data = 0x0000001E` - **30**
- **$t7** (`write_reg = 0F`): `write_data = 0x00000001` - **1**
- **$s6** (`write_reg = 16`): `write_data = 0x00000064` - **100 (Branch)**
- **$s7** (`write_reg = 17`): `write_data = 0x00000032` - **50 (ADDI)**

### 6.2. Comportamento da Simulação - VALIDADO

- **Reset:** Funcionando corretamente (1→0)
- **Clock:** Oscilando em 10ns (100 MHz)
- **Ciclos:** Incrementando corretamente
- **Escritas:** `reg_write` pulsando nos momentos corretos
- **Finalização:** `sim_finished` indo para '1' ao final
- **PC:** Incrementando de 4 ou fazendo branches corretamente
- **FPU:** Operações FADD, FSUB, FMUL produzindo resultados corretos
- **LUI:** Instrução LUI funcionando corretamente

### 6.3. Conclusão da Análise

**O processador MIPS está funcionando PERFEITAMENTE!**

Todos os valores esperados pelo testbench estão sendo escritos nos registradores corretos nos momentos certos. As operações de ponto flutuante (FADD, FSUB, FMUL), operações de inteiros, e a instrução LUI estão produzindo os resultados corretos.

## 7. Notas sobre Formato de Exibição

### Regra Geral

**Todos os sinais devem ser exibidos em hexadecimal, exceto:**
- `clk` e `reset`: Binário (para visualização clara do clock)
- Sinais de controle binários individuais (opcional, mas hexadecimal também funciona)

### Justificativa

O formato hexadecimal é ideal porque:
- **Instruções MIPS:** Naturalmente visualizadas em hex
- **Endereços:** Padrão hexadecimal
- **Valores IEEE 754:** Permitem verificação direta do padrão de bits
- **Consistência:** Todos os valores numéricos no mesmo formato facilitam comparação

### Exemplo de Configuração no EPWave

1. Selecione o sinal
2. Clique com botão direito
3. Escolha "Radix" → "Hexadecimal" (ou "Binary" para clk/reset)
4. Para vetores, use "Hexadecimal" para visualização compacta

## 8. Troubleshooting

### Problema: Sinais não aparecem no waveform

**Solução:** Certifique-se de:
1. Gerar o arquivo VCD durante a simulação: `ghdl -r testbench --vcd=dump.vcd`
2. Abrir o EPWave corretamente após a simulação
3. Navegar pela hierarquia corretamente (usar o caminho completo do scope)

### Problema: Valores aparecem como "X" ou "U"

**Solução:** 
- "X" (don't care) ou "U" (undefined) são normais no início da simulação
- Após o reset ser liberado, todos os sinais devem ter valores definidos
- Se persistir, verifique inicialização no código VHDL

### Problema: Valores não correspondem aos esperados

**Solução:**
1. Verifique se está olhando o momento correto (após execução completa)
2. Confirme que está verificando o registrador correto (índice correto)
3. Compare com os valores do console do testbench
4. Verifique se a simulação rodou completamente (50 ciclos, 520ns)
