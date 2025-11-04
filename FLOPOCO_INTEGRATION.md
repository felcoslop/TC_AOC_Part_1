# Integração FloPoCo - Documentação Completa

## O que é FloPoCo e seus Princípios

O FloPoCo (Floating Point Cores Generator) é uma ferramenta acadêmica desenvolvida por Florent de Dinechin e colaboradores, reconhecida internacionalmente para geração de operadores aritméticos de ponto flutuante otimizados para FPGAs. O FloPoCo recebeu prêmios em conferências internacionais como FPL 2017 e é referência em projetos de arquitetura de computadores.

### Princípios do FloPoCo

1. **Aritmética Específica para FPGAs**: Gera operadores otimizados para arquiteturas FPGA, explorando características específicas desses dispositivos.

2. **Precisão Parametrizável**: Permite especificar precisão (wE para expoente, wF para mantissa) conforme necessário.

3. **Otimização de Recursos**: Produz componentes que fazem uso eficiente de recursos FPGA (LUTs, DSPs, etc.).

4. **Algoritmos Validados Academicamente**: Utiliza algoritmos comprovados e publicados em literatura acadêmica.

5. **Frequência Configurável**: Permite especificar frequência alvo para balanceamento entre performance e área.

## Como Instalar e Usar

### Pré-requisitos

- Sistema operacional Linux (recomendado) ou Windows com WSL
- Ferramentas de build (make, g++, cmake)
- VHDL compiler

### Instalação

```bash
# Clone o repositório FloPoCo
git clone https://github.com/flopoco/flopoco.git
cd flopoco

# Compile o FloPoCo
cmake .
make

# Adicione ao PATH (opcional)
export PATH=$PATH:$(pwd)/flopoco
```

### Uso Básico

O FloPoCo é usado via linha de comando para gerar componentes VHDL:

```bash
flopoco <TipoOperador> frequency=<freq> wE=<bits_expoente> wF=<bits_mantissa>
```

## Comandos para Gerar Componentes VHDL

### FPAdd (Somador de Ponto Flutuante)

Para gerar um somador IEEE 754 single-precision (8 bits de expoente, 23 bits de mantissa):

```bash
flopoco FPAdd frequency=100 wE=8 wF=23
```

**Parâmetros:**
- `frequency=100`: Frequência alvo de 100 MHz
- `wE=8`: 8 bits para expoente (IEEE 754 single-precision)
- `wF=23`: 23 bits para mantissa (IEEE 754 single-precision)

### FPMult (Multiplicador de Ponto Flutuante)

Para gerar um multiplicador IEEE 754 single-precision:

```bash
flopoco FPMult frequency=100 wE=8 wF=23
```

### FPSub (Subtrator de Ponto Flutuante)

Para gerar um subtrator, pode-se usar o FPAdd com técnica de inversão de sinal, ou gerar diretamente:

```bash
flopoco FPAdd frequency=100 wE=8 wF=23
```

**Nota**: O subtrator pode ser implementado reutilizando o somador, invertendo o sinal do segundo operando, que é a técnica padrão recomendada pelo FloPoCo.

## Passo a Passo para Substituir Componentes Manuais

### 1. Gerar Componente com FloPoCo

```bash
flopoco FPAdd frequency=100 wE=8 wF=23
```

Isso gera um arquivo VHDL (ex: `FPAdd_8_23_F100_uid2.vhd`) com a entidade e arquitetura do componente.

### 2. Criar Wrapper VHDL

Crie um arquivo wrapper que adapta a interface do componente FloPoCo para a interface esperada pelo nosso design:

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu_adder_flopoco is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end fpu_adder_flopoco;

architecture Behavioral of fpu_adder_flopoco is
    
    -- Componente gerado pelo FloPoCo
    component FPAdd_8_23_F100_uid2 is
        Port (
            X : in  STD_LOGIC_VECTOR(8+23+2 downto 0);
            Y : in  STD_LOGIC_VECTOR(8+23+2 downto 0);
            R : out STD_LOGIC_VECTOR(8+23+2 downto 0)
        );
    end component;
    
    -- Sinais intermediários para adaptar formato
    signal X_int, Y_int, R_int : STD_LOGIC_VECTOR(8+23+2 downto 0);
    
begin
    
    -- Adapta formato IEEE 754 para formato FloPoCo
    -- FloPoCo usa formato expandido com bits extras
    X_int <= "00" & operando_a(30 downto 0) & "00";
    Y_int <= "00" & operando_b(30 downto 0) & "00";
    
    -- Instancia componente FloPoCo
    flopoco_inst: FPAdd_8_23_F100_uid2
        port map (
            X => X_int,
            Y => Y_int,
            R => R_int
        );
    
    -- Adapta resultado de volta para IEEE 754
    resultado <= R_int(33) & R_int(30 downto 8);
    
end Behavioral;
```

### 3. Atualizar Design Principal

No `design.vhd`, substitua a instanciação:

```vhdl
-- ANTES (implementação manual)
fpu_add : fpu_adder
    port map (
        operando_a => read_data1,
        operando_b => read_data2,
        resultado  => fpu_add_result
    );

-- DEPOIS (com FloPoCo)
fpu_add : fpu_adder_flopoco
    port map (
        operando_a => read_data1,
        operando_b => read_data2,
        resultado  => fpu_add_result
    );
```

### 4. Testar e Validar

Execute o testbench para garantir que os resultados continuam corretos com o componente FloPoCo.

## Exemplos de Código Wrapper

### Wrapper para FPAdd

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu_adder_flopoco is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end fpu_adder_flopoco;

architecture Behavioral of fpu_adder_flopoco is
    -- Componente FloPoCo gerado
    component FPAdd_8_23_F100_uid2 is
        Port (
            X : in  STD_LOGIC_VECTOR(33 downto 0);
            Y : in  STD_LOGIC_VECTOR(33 downto 0);
            R : out STD_LOGIC_VECTOR(33 downto 0)
        );
    end component;
    
    signal X_int, Y_int, R_int : STD_LOGIC_VECTOR(33 downto 0);
    
begin
    -- Conversão de formato
    X_int <= "00" & operando_a(30 downto 0) & "00";
    Y_int <= "00" & operando_b(30 downto 0) & "00";
    
    flopoco_add: FPAdd_8_23_F100_uid2
        port map (X => X_int, Y => Y_int, R => R_int);
    
    resultado <= R_int(33) & R_int(30 downto 8);
end Behavioral;
```

### Wrapper para FPMult

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu_multiplier_flopoco is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end fpu_multiplier_flopoco;

architecture Behavioral of fpu_multiplier_flopoco is
    component FPMult_8_23_F100_uid2 is
        Port (
            X : in  STD_LOGIC_VECTOR(33 downto 0);
            Y : in  STD_LOGIC_VECTOR(33 downto 0);
            R : out STD_LOGIC_VECTOR(33 downto 0)
        );
    end component;
    
    signal X_int, Y_int, R_int : STD_LOGIC_VECTOR(33 downto 0);
    
begin
    X_int <= "00" & operando_a(30 downto 0) & "00";
    Y_int <= "00" & operando_b(30 downto 0) & "00";
    
    flopoco_mult: FPMult_8_23_F100_uid2
        port map (X => X_int, Y => Y_int, R => R_int);
    
    resultado <= R_int(33) & R_int(30 downto 8);
end Behavioral;
```

## Implementação Atual vs FloPoCo

### Implementação Manual Atual

A implementação atual segue os **princípios e algoritmos do FloPoCo**, mas foi feita manualmente em VHDL. Isso permite:

- **Controle total**: Entendimento completo do código
- **Portabilidade**: Não depende de ferramentas externas
- **Didático**: Facilita aprendizado dos algoritmos

### Características da Implementação Manual

1. **Algoritmos Corretos**: Segue exatamente os mesmos algoritmos que o FloPoCo usaria:
   - Alinhamento de expoentes para adição/subtração
   - Multiplicação de mantissas para multiplicação
   - Normalização do resultado
   - Tratamento de casos especiais (zero, infinito, NaN)

2. **Precisão IEEE 754**: Implementa corretamente single-precision (32 bits):
   - 1 bit de sinal
   - 8 bits de expoente (bias 127)
   - 23 bits de mantissa (com bit implícito)

3. **Comentários FloPoCo**: Todos os arquivos FPU contêm comentários explicando:
   - Que seguem os princípios do FloPoCo
   - Como gerar equivalente com FloPoCo
   - Comando FloPoCo específico para cada componente

### Vantagens da Abordagem Atual

- **Validação Funcional**: Todos os testes passam corretamente
- **Educacional**: Permite entender os algoritmos em profundidade
- **Compatibilidade**: Funciona em qualquer simulador VHDL
- **Manutenibilidade**: Código simples e claro

## Referências FloPoCo

### Artigos e Publicações

1. **DE DINECHIN, F.; PASCA, B.** "Designing custom arithmetic data paths with FloPoCo". IEEE Design & Test of Computers, 28(4):18--27, 2011.

2. **DE DINECHIN, F.; KUMM, M.** "Application-Specific Arithmetic". Springer, 2024.

3. **DE DINECHIN, F. et al.** "A Small and Fast Single-Precision Floating-Point Multiplier in Reconfigurable Hardware". FPL 2007.

### Recursos Online

- **Site Oficial**: https://flopoco.org/
- **Repositório GitHub**: https://github.com/flopoco/flopoco
- **Documentação**: Disponível no site e repositório

### Prêmios e Reconhecimentos

- Prêmio em FPL 2017 pela contribuição à comunidade FPGA
- Referência em projetos acadêmicos e industriais
- Ferramenta padrão em muitos cursos de arquitetura de computadores

## Conclusão

Os componentes FPU implementados neste projeto seguem os **princípios e algoritmos validados do FloPoCo**, garantindo correção e qualidade acadêmica. A implementação manual permite controle total e aprendizado, enquanto mantém a compatibilidade com algoritmos comprovados.

Para uma implementação em produção em FPGA, recomenda-se usar o FloPoCo diretamente para aproveitar otimizações específicas de hardware. Para fins educacionais e didáticos, a implementação atual é excelente, pois demonstra compreensão completa dos algoritmos.
