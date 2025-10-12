## 1. Propósito do Waveform

O waveform visualiza os valores dos sinais internos e externos do processador ao longo do tempo, permitindo:
- **Verificar funcionalidade:** Confirmar execução correta das instruções - **Depuração:** Identificar erros rastreando valores dos sinais - **Validação:** Comparar resultados com valores esperados do testbench 
## 2. Sinais do Testbench (Scope: `/testbench`)

### 2.1. Sinais de Controle Global
- **`clk`**: **Clock principal do sistema**
  - **Significado:** Sinal de clock com período de 10ns (100 MHz)
  - **O que observar:** Deve alternar entre '0' e '1' continuamente
  - **Importância:** Todas as operações síncronas são sincronizadas com este clock

- **`reset`**: **Sinal de reset do processador**
  - **Significado:** Inicializa o processador para estado conhecido
  - **O que observar:** Deve estar '1' no início da simulação e depois ir para '0'
  - **Importância:** Quando ativo, zera PC e registradores

- **`cycle_count`**: **Contador de ciclos de clock**
  - **Significado:** Conta quantos ciclos de clock se passaram desde o reset
  - **O que observar:** Deve incrementar a cada borda de subida do clock (quando reset = '0')
  - **Importância:** Útil para acompanhar progresso da simulação e número de instruções executadas

- **`sim_finished`**: **Flag de término da simulação**
  - **Significado:** Indica quando o testbench terminou sua sequência de testes
  - **O que observar:** Deve estar `false` durante execução e `true` no final
  - **Importância:** Controla quando a simulação deve parar

## 3. Sinais do Banco de Registradores (Scope: `/testbench/uut/regs`)

### 3.1. Sinais de Interface do Banco de Registradores
- **`clk`**: **Clock do banco de registradores**
  - **Significado:** Clock para operações síncronas (escrita)
  - **O que observar:** Mesmo clock do sistema

- **`reset`**: **Reset do banco de registradores**
  - **Significado:** Inicializa todos os registradores com zero
  - **O que observar:** Deve estar ativo no início da simulação

- **`reg_write`**: **Habilita escrita no banco**
  - **Significado:** Quando '1', permite escrita no registrador especificado
  - **O que observar:** Deve estar '1' durante instruções que escrevem em registradores
  - **Importância:** Controla quando dados são salvos nos registradores

- **`read_reg1[4:0]`**: **Endereço do primeiro registrador a ler**
  - **Significado:** Campo Rs da instrução (5 bits = 32 registradores)
  - **O que observar:** Deve mudar a cada instrução executada
  - **Mapeamento MIPS:** Registradores $0 a $31

- **`read_reg2[4:0]`**: **Endereço do segundo registrador a ler**
  - **Significado:** Campo Rt da instrução
  - **O que observar:** Deve mudar conforme instrução executada

- **`write_reg[4:0]`**: **Endereço do registrador para escrita**
  - **Significado:** Registrador de destino (Rd ou Rt dependendo da instrução)
  - **O que observar:** Deve indicar qual registrador será atualizado

- **`write_data[31:0]`**: **Dados a serem escritos**
  - **Significado:** Valor de 32 bits a ser armazenado no registrador
  - **O que observar:** Dados que serão salvos no registrador especificado

- **`read_data1[31:0]`**: **Dados lidos do primeiro registrador**
  - **Significado:** Valor atual do registrador read_reg1
  - **O que observar:** Deve conter o valor do registrador especificado

- **`read_data2[31:0]`**: **Dados lidos do segundo registrador**
  - **Significado:** Valor atual do registrador read_reg2
  - **O que observar:** Deve conter o valor do registrador especificado

### 3.2. Array de Registradores Internos
- **`registradores[0]` até `registradores[31]`**: **Valores dos 32 registradores**
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

## 4. Outros Scopes Importantes para Análise

### 4.1. Processador Principal (Scope: `/testbench/uut`)
- **`pc`**: **Program Counter**
  - **Significado:** Endereço da próxima instrução a ser executada
  - **O que observar:** Deve incrementar a cada ciclo ou saltar em branches

- **`instrucao`**: **Instrução atual**
  - **Significado:** Instrução de 32 bits sendo executada
  - **O que observar:** Deve mudar a cada ciclo conforme PC

### 4.2. Unidade de Controle (Scope: `/testbench/uut/ctrl`)
- **`reg_dst`**: **Seleciona registrador de destino**
- **`alu_src`**: **Seleciona fonte da ULA**
- **`mem_to_reg`**: **Seleciona fonte para write-back**
- **`mem_read`**, **`mem_write`**: **Controle de memória**
- **`branch`**: **Indica instrução de branch**
- **`alu_op`**: **Tipo de operação da ULA**
- **`is_fp_op`**: **Indica operação de ponto flutuante**
- **`fp_op_type`**: **Tipo de operação FPU**

### 4.3. Módulos FPU (Scopes: `/testbench/uut/fpu_add`, `/testbench/uut/fpu_sub`, `/testbench/uut/fpu_mul`)
- **`operando_a[31:0]`**, **`operando_b[31:0]`**: **Entradas da FPU**
- **`resultado[31:0]`**: **Resultado da operação FPU**

### 4.4. Memória de Dados (Scope: `/testbench/uut/mem_data_inst`)
- **`endereco[31:0]`**: **Endereço acessado**
- **`write_data[31:0]`**: **Dados escritos**
- **`read_data[31:0]`**: **Dados lidos**

## 5. Valores Esperados para Validação

Conforme o testbench, após execução completa, verifique:

### 5.1. Registradores de Ponto Flutuante
- **`registradores[16]` ($s0)**: `0x40200000` (2.5 em IEEE 754)
- **`registradores[17]` ($s1)**: `0x40400000` (3.0 em IEEE 754)
- **`registradores[18]` ($s2)**: `0x3FC00000` (1.5 em IEEE 754)
- **`registradores[19]` ($s3)**: `0x40B00000` (5.5 em IEEE 754 - resultado FADD)
- **`registradores[20]` ($s4)**: `0x40800000` (4.0 em IEEE 754 - resultado FSUB)
- **`registradores[21]` ($s5)**: `0x40F00000` (7.5 em IEEE 754 - resultado FMUL)

### 5.2. Registradores de Inteiros
- **`registradores[11]` ($t3)**: `0x0000001E` (30 em decimal)
- **`registradores[15]` ($t7)**: `0x00000001` (1 em decimal)

### 5.3. Memória de Dados
- **Memória[12]**: `0x40B00000`
- **Memória[16]**: `0x40800000`
- **Memória[20]**: `0x40F00000`
- **Memória[32]**: `0x0000001E`
- **Memória[36]**: `0x00000001`

## 6. Como Adicionar Sinais no EPWave

1. **Abra o EPWave** após a simulação
2. **Navegue pela hierarquia** no painel esquerdo
3. **Expanda os scopes** desejados
4. **Selecione os sinais** e arraste para o painel principal
5. **Configure zoom** e escala de tempo conforme necessário

## 7. Sinais Recomendados para Análise Completa

### 7.1. Mínimos Essenciais
- `/testbench/clk`
- `/testbench/reset`
- `/testbench/cycle_count`
- `/testbench/uut/pc`
- `/testbench/uut/regs/registradores[16]` até `registradores[21]` (s0-s5)
- `/testbench/uut/regs/registradores[11]` e `registradores[15]` (t3, t7)

### 7.2. Para Análise Detalhada
- Todos os sinais de controle da unidade de controle
- Sinais das FPUs
- Sinais de memória de dados
- Sinais de interface do banco de registradores

## 8. Sobre Arquivos para o Professor

**NÃO** é necessário pedir ao EDA Playground para "gerar arquivos" específicos. Para submissão ao professor, você precisa:

1. **Arquivos VHDL**: Todos os arquivos `.vhd` do seu projeto
2. **Log da Simulação**: Copie o texto da janela de console do EDA Playground
3. **Capturas de Tela**: Screenshots do waveform mostrando os sinais importantes
4. **Este README**: Para explicar os sinais e resultados

O EDA Playground é apenas uma ferramenta de simulação - os arquivos para submissão são seus códigos fonte e evidências da simulação bem-sucedida.

## 9. Validação dos Resultados 
### 9.1. Análise Realizada
O waveform foi analisado em detalhes e **TODOS OS VALORES FORAM CONFIRMADOS COMO CORRETOS**:

#### Registradores de Ponto Flutuante - VALIDADOS - **$s0** (`write_reg = 10`): `write_data = 4020_0000`  **2.5 FP**
- **$s1** (`write_reg = 11`): `write_data = 4040_0000`  **3.0 FP**
- **$s2** (`write_reg = 12`): `write_data = 3FC0_0000`  **1.5 FP**
- **$s3** (`write_reg = 13`): `write_data = 40B0_0000`  **5.5 FP (FADD)**
- **$s4** (`write_reg = 14`): `write_data = 4080_0000`  **4.0 FP (FSUB)**
- **$s5** (`write_reg = 15`): `write_data = 40F0_0000`  **7.5 FP (FMUL)**

#### Registradores de Inteiros - VALIDADOS - **$t3** (`write_reg = 0b`): `write_data = 0000_001E`  **30**
- **$t7** (`write_reg = 0f`): `write_data = 0000_0001`  **1**

### 9.2. Comportamento da Simulação - VALIDADO -  **Reset:** Funcionando corretamente (1→0)
-  **Clock:** Oscilando em 10ns (100 MHz)
-  **Ciclos:** Incrementando corretamente
-  **Escritas:** `reg_write` pulsando nos momentos corretos
-  **Finalização:** `sim_finished` indo para '1' ao final

### 9.3. Conclusão da Análise
**O processador MIPS está funcionando PERFEITAMENTE!**

Todos os valores esperados pelo testbench estão sendo escritos nos registradores corretos nos momentos certos. As operações de ponto flutuante (FADD, FSUB, FMUL) e as operações de inteiros estão produzindo os resultados corretos.
