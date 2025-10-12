-- Processador MIPS Single-Cycle com FPU
-- Implementacao de um processador MIPS 32-bit com suporte a operacoes
-- de ponto flutuante (FPU) seguindo arquitetura single-cycle

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity processador_mips is
    Port ( 
        clk   : in STD_LOGIC;
        reset : in STD_LOGIC
    );
end processador_mips;

architecture Behavioral of processador_mips is
    
    -- Declaracao dos componentes principais do processador
    
    component unidade_controle is
        Port ( 
            opcode      : in  STD_LOGIC_VECTOR(5 downto 0);
            funct       : in  STD_LOGIC_VECTOR(5 downto 0);
            reg_dst     : out STD_LOGIC;
            alu_src     : out STD_LOGIC;
            mem_to_reg  : out STD_LOGIC;
            reg_write   : out STD_LOGIC;
            mem_read    : out STD_LOGIC;
            mem_write   : out STD_LOGIC;
            branch      : out STD_LOGIC;
            alu_op      : out STD_LOGIC_VECTOR(1 downto 0);
            is_fp_op    : out STD_LOGIC;
            fp_op_type  : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    component ula_control is
        Port ( 
            alu_op   : in  STD_LOGIC_VECTOR(1 downto 0);
            funct    : in  STD_LOGIC_VECTOR(5 downto 0);
            controle : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component banco_registradores is
        Port ( 
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            reg_write  : in  STD_LOGIC;
            read_reg1  : in  STD_LOGIC_VECTOR(4 downto 0);
            read_reg2  : in  STD_LOGIC_VECTOR(4 downto 0);
            write_reg  : in  STD_LOGIC_VECTOR(4 downto 0);
            write_data : in  STD_LOGIC_VECTOR(31 downto 0);
            read_data1 : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component ula_inteiros is
        Port ( 
            operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
            operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
            controle   : in  STD_LOGIC_VECTOR(3 downto 0);
            resultado  : out STD_LOGIC_VECTOR(31 downto 0);
            zero       : out STD_LOGIC
        );
    end component;
    
    component memoria_instrucoes is
        Port ( 
            endereco  : in  STD_LOGIC_VECTOR(31 downto 0);
            instrucao : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component memoria_dados is
        Port ( 
            clk        : in  STD_LOGIC;
            mem_write  : in  STD_LOGIC;
            mem_read   : in  STD_LOGIC;
            endereco   : in  STD_LOGIC_VECTOR(31 downto 0);
            write_data : in  STD_LOGIC_VECTOR(31 downto 0);
            read_data  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component fpu_adder is
        Port ( 
            operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
            operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
            resultado  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component fpu_subtractor is
        Port ( 
            operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
            operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
            resultado  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component fpu_multiplier is
        Port ( 
            operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
            operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
            resultado  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Sinais internos para interconexao dos componentes
    
    -- Program Counter
    signal pc, pc_next, pc_plus4, pc_branch : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    -- Instrucao
    signal instrucao : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode    : STD_LOGIC_VECTOR(5 downto 0);
    signal rs, rt, rd : STD_LOGIC_VECTOR(4 downto 0);
    signal shamt     : STD_LOGIC_VECTOR(4 downto 0);
    signal funct     : STD_LOGIC_VECTOR(5 downto 0);
    signal imediato  : STD_LOGIC_VECTOR(15 downto 0);
    signal imediato_ext : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Sinais de controle
    signal reg_dst, alu_src, mem_to_reg, reg_write : STD_LOGIC;
    signal mem_read, mem_write, branch, pc_src : STD_LOGIC;
    signal alu_op : STD_LOGIC_VECTOR(1 downto 0);
    signal is_fp_op : STD_LOGIC;
    signal fp_op_type : STD_LOGIC_VECTOR(1 downto 0);
    
    -- Banco de registradores
    signal write_reg : STD_LOGIC_VECTOR(4 downto 0);
    signal write_data, read_data1, read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- ULA
    signal alu_control_signal : STD_LOGIC_VECTOR(3 downto 0);
    signal alu_operand_b : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero : STD_LOGIC;
    
    -- FPU
    signal fpu_add_result, fpu_sub_result, fpu_mul_result : STD_LOGIC_VECTOR(31 downto 0);
    signal fpu_result : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memoria de dados
    signal mem_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Resultado final (ULA ou FPU ou Memoria)
    signal exec_result : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    
    -- Implementacao do Program Counter (PC)
    -- O PC armazena o endereco da proxima instrucao a ser executada
    process(clk, reset)
    begin
        if reset = '1' then
            pc <= (others => '0');  -- Reset: volta pro inicio do programa (endereco 0)
        elsif rising_edge(clk) then
            pc <= pc_next;  -- A cada clock, atualiza PC com o proximo endereco
        end if;
    end process;
    
    -- Calcula PC + 4 (proxima instrucao sequencial)
    -- Soma 4 porque cada instrucao tem 4 bytes (32 bits)
    pc_plus4 <= std_logic_vector(unsigned(pc) + 4);
    
    -- Calcula endereco de destino do branch
    -- Pega o offset do imediato, desloca 2 bits pra esquerda (multiplica por 4)
    -- e soma com PC+4 pra saber onde o branch vai pular
    pc_branch <= std_logic_vector(unsigned(pc_plus4) + shift_left(unsigned(imediato_ext), 2));
    
    -- Decide se vai fazer branch ou nao
    -- So faz branch se: instrucao for branch (branch=1) E resultado da ULA for zero (alu_zero=1)
    pc_src <= branch AND alu_zero;
    pc_next <= pc_branch when pc_src = '1' else pc_plus4;  -- Multiplexador: escolhe branch ou sequencial
    
    -- Memoria de instrucoes - busca a instrucao baseada no PC
    mem_inst : memoria_instrucoes
        port map (
            endereco  => pc,        -- Endereco da instrucao que queremos buscar
            instrucao => instrucao  -- Instrucao de 32 bits que vem da memoria
        );
    
    -- Decodificacao da instrucao - quebra a instrucao de 32 bits em campos
    -- Formato MIPS: [opcode(6)][rs(5)][rt(5)][rd(5)][shamt(5)][funct(6)]
    opcode   <= instrucao(31 downto 26);  -- Bits 31-26: codigo da operacao
    rs       <= instrucao(25 downto 21);  -- Bits 25-21: registrador fonte 1
    rt       <= instrucao(20 downto 16);  -- Bits 20-16: registrador fonte 2
    rd       <= instrucao(15 downto 11);  -- Bits 15-11: registrador destino
    shamt    <= instrucao(10 downto 6);   -- Bits 10-6: shift amount (nao usado aqui)
    funct    <= instrucao(5 downto 0);    -- Bits 5-0: funcao (pra instrucoes tipo-R)
    imediato <= instrucao(15 downto 0);   -- Bits 15-0: valor imediato (pra instrucoes tipo-I)
    
    -- Extensao de sinal do imediato de 16 bits pra 32 bits
    -- Se bit 15 e 1 (numero negativo), completa com 1s na frente
    -- Se bit 15 e 0 (numero positivo), completa com 0s na frente
    imediato_ext <= x"FFFF" & imediato when imediato(15) = '1' else
                    x"0000" & imediato;
    
    -- Unidade de controle principal - gera todos os sinais de controle
    -- Basicamente o "cerebro" que decide o que fazer baseado no opcode e funct
    ctrl : unidade_controle
        port map (
            opcode     => opcode,      -- Entra: codigo da operacao
            funct      => funct,       -- Entra: funcao (pra tipo-R)
            reg_dst    => reg_dst,     -- Sai: qual reg e destino (rd ou rt)
            alu_src    => alu_src,     -- Sai: segundo operando da ULA (rt ou imediato)
            mem_to_reg => mem_to_reg,  -- Sai: dado vem da ULA ou da memoria
            reg_write  => reg_write,   -- Sai: habilita escrita no banco de regs
            mem_read   => mem_read,    -- Sai: habilita leitura da memoria
            mem_write  => mem_write,   -- Sai: habilita escrita na memoria
            branch     => branch,      -- Sai: indica se e instrucao de branch
            alu_op     => alu_op,      -- Sai: tipo de operacao da ULA
            is_fp_op   => is_fp_op,    -- Sai: indica se e operacao de ponto flutuante
            fp_op_type => fp_op_type   -- Sai: tipo de operacao FPU (add/sub/mul)
        );
    
    -- Controle da ULA - decodifica alu_op e funct pra gerar codigo especifico da ULA
    -- Traduz os sinais da unidade de controle pro codigo que a ULA entende
    alu_ctrl : ula_control
        port map (
            alu_op   => alu_op,              -- Entra: tipo geral de operacao
            funct    => funct,               -- Entra: funcao especifica (pra tipo-R)
            controle => alu_control_signal   -- Sai: codigo de 4 bits pra ULA
        );
    
    -- Seleciona registrador de destino
    -- Tipo-R: rd (bits 15-11), Tipo-I: rt (bits 20-16)
    -- Multiplexador controlado por reg_dst
    write_reg <= rd when reg_dst = '1' else rt;
    
    -- Banco de registradores - armazena os 32 registradores do MIPS
    regs : banco_registradores
        port map (
            clk        => clk,
            reset      => reset,
            reg_write  => reg_write,   -- Entra: habilita escrita (1=escreve, 0=nao escreve)
            read_reg1  => rs,          -- Entra: endereco do reg a ler (porta 1)
            read_reg2  => rt,          -- Entra: endereco do reg a ler (porta 2)
            write_reg  => write_reg,   -- Entra: endereco do reg pra escrever
            write_data => write_data,  -- Entra: dado a ser escrito
            read_data1 => read_data1,  -- Sai: dado lido da porta 1
            read_data2 => read_data2   -- Sai: dado lido da porta 2
        );
    
    -- Seleciona o segundo operando da ULA
    -- Pode ser: conteudo do registrador rt OU valor imediato estendido
    -- Multiplexador controlado por alu_src
    alu_operand_b <= imediato_ext when alu_src = '1' else read_data2;
    
    -- ULA de inteiros - faz operacoes aritmeticas e logicas com inteiros
    alu : ula_inteiros
        port map (
            operando_a => read_data1,          -- Entra: primeiro operando (do reg rs)
            operando_b => alu_operand_b,       -- Entra: segundo operando (rt ou imediato)
            controle   => alu_control_signal,  -- Entra: codigo que define qual operacao fazer
            resultado  => alu_result,          -- Sai: resultado da operacao
            zero       => alu_zero             -- Sai: flag que indica se resultado e zero (pra branch)
        );
    
    -- Unidades de ponto flutuante (FPU)
    -- Tres unidades separadas pra cada operacao (add, sub, mul)
    -- Todas trabalham em paralelo e a gente escolhe qual resultado usar depois
    
    -- FPU Adder - soma dois numeros em ponto flutuante IEEE 754
    fpu_add : fpu_adder
        port map (
            operando_a => read_data1,      -- Entra: primeiro numero FP
            operando_b => read_data2,      -- Entra: segundo numero FP
            resultado  => fpu_add_result   -- Sai: A + B em formato IEEE 754
        );
    
    -- FPU Subtractor - subtrai dois numeros em ponto flutuante
    fpu_sub : fpu_subtractor
        port map (
            operando_a => read_data1,      -- Entra: primeiro numero FP
            operando_b => read_data2,      -- Entra: segundo numero FP
            resultado  => fpu_sub_result   -- Sai: A - B em formato IEEE 754
        );
    
    -- FPU Multiplier - multiplica dois numeros em ponto flutuante
    fpu_mul : fpu_multiplier
        port map (
            operando_a => read_data1,      -- Entra: primeiro numero FP
            operando_b => read_data2,      -- Entra: segundo numero FP
            resultado  => fpu_mul_result   -- Sai: A * B em formato IEEE 754
        );
    
    -- Multiplexador para selecionar qual resultado da FPU usar
    -- Dependendo do tipo de operacao FP, escolhe add, sub ou mul
    process(fp_op_type, fpu_add_result, fpu_sub_result, fpu_mul_result)
    begin
        case fp_op_type is
            when "00"   => fpu_result <= fpu_add_result; -- FADD: pega resultado do somador
            when "01"   => fpu_result <= fpu_sub_result; -- FSUB: pega resultado do subtrator
            when "10"   => fpu_result <= fpu_mul_result; -- FMUL: pega resultado do multiplicador
            when others => fpu_result <= (others => '0'); -- Caso invalido: retorna zero
        end case;
    end process;
    
    -- Seleciona entre resultado da ULA de inteiros ou da FPU
    -- Se is_fp_op = 1, usa FPU; senao usa ULA de inteiros
    exec_result <= fpu_result when is_fp_op = '1' else alu_result;
    
    -- Memoria de dados - RAM pra armazenar variaveis do programa
    mem_data_inst : memoria_dados
        port map (
            clk        => clk,
            mem_write  => mem_write,   -- Entra: habilita escrita (sw)
            mem_read   => mem_read,    -- Entra: habilita leitura (lw)
            endereco   => exec_result, -- Entra: endereco calculado pela ULA
            write_data => read_data2,  -- Entra: dado a ser escrito (conteudo de rt)
            read_data  => mem_data     -- Sai: dado lido da memoria
        );
    
    -- Seleciona dado para escrever no banco de registradores (write-back)
    -- Pode vir da memoria (lw) ou do resultado da execucao (ULA/FPU)
    write_data <= mem_data when mem_to_reg = '1' else exec_result;
    
end Behavioral;
