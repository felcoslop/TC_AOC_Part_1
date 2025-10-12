-- Unidade de Controle MIPS
-- Decodifica instrucoes e gera sinais de controle para o datapath
-- Suporta instrucoes basicas MIPS e extensoes FPU (fadd, fsub, fmul)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity unidade_controle is
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
end unidade_controle;

architecture Behavioral of unidade_controle is
    
    -- Opcodes das instrucoes MIPS basicas
    constant OP_RTYPE   : STD_LOGIC_VECTOR(5 downto 0) := "000000"; -- Tipo-R
    constant OP_LW      : STD_LOGIC_VECTOR(5 downto 0) := "100011"; -- Load Word
    constant OP_SW      : STD_LOGIC_VECTOR(5 downto 0) := "101011"; -- Store Word
    constant OP_BEQ     : STD_LOGIC_VECTOR(5 downto 0) := "000100"; -- Branch Equal
    constant OP_ADDI    : STD_LOGIC_VECTOR(5 downto 0) := "001000"; -- Add Immediate
    
    -- Funct codes para instrucoes Tipo-R (inteiros)
    constant FUNCT_ADD  : STD_LOGIC_VECTOR(5 downto 0) := "100000"; -- ADD
    constant FUNCT_SUB  : STD_LOGIC_VECTOR(5 downto 0) := "100010"; -- SUB
    constant FUNCT_AND  : STD_LOGIC_VECTOR(5 downto 0) := "100100"; -- AND
    constant FUNCT_OR   : STD_LOGIC_VECTOR(5 downto 0) := "100101"; -- OR
    constant FUNCT_SLT  : STD_LOGIC_VECTOR(5 downto 0) := "101010"; -- SLT
    
    -- Funct codes para instrucoes FPU (extensao personalizada)
    constant FUNCT_FADD : STD_LOGIC_VECTOR(5 downto 0) := "100011"; -- FADD
    constant FUNCT_FSUB : STD_LOGIC_VECTOR(5 downto 0) := "100110"; -- FSUB
    constant FUNCT_FMUL : STD_LOGIC_VECTOR(5 downto 0) := "100111"; -- FMUL
    
begin
    
    process(opcode, funct)
    begin
        -- Valores padrao para evitar latches
        reg_dst    <= '0';
        alu_src    <= '0';
        mem_to_reg <= '0';
        reg_write  <= '0';
        mem_read   <= '0';
        mem_write  <= '0';
        branch     <= '0';
        alu_op     <= "00";
        is_fp_op   <= '0';
        fp_op_type <= "00";
        
        -- Decodifica o opcode e gera os sinais de controle apropriados
        case opcode is
            
            -- Instrucao Tipo-R: opcode = 000000
            -- Pode ser operacao de inteiros (add, sub, etc) ou FPU (fadd, fsub, fmul)
            when OP_RTYPE =>
                reg_dst   <= '1';  -- Destino e rd (bits 15-11)
                reg_write <= '1';  -- Vai escrever no banco de registradores
                alu_op    <= "10"; -- Operacao depende do funct
                
                -- Verifica se e operacao FPU pelo codigo funct
                case funct is
                    when FUNCT_FADD =>  -- FADD: soma de ponto flutuante
                        is_fp_op   <= '1';   -- E operacao FP
                        fp_op_type <= "00";  -- Tipo: ADD
                        
                    when FUNCT_FSUB =>  -- FSUB: subtracao de ponto flutuante
                        is_fp_op   <= '1';   -- E operacao FP
                        fp_op_type <= "01";  -- Tipo: SUB
                        
                    when FUNCT_FMUL =>  -- FMUL: multiplicacao de ponto flutuante
                        is_fp_op   <= '1';   -- E operacao FP
                        fp_op_type <= "10";  -- Tipo: MUL
                        
                    when others =>  -- Operacoes de inteiros (add, sub, and, or, slt)
                        is_fp_op <= '0';   -- Nao e FP, usa ULA de inteiros
                end case;
            
            -- LW: Load Word - carrega palavra da memoria
            when OP_LW =>
                alu_src    <= '1';  -- Segundo operando e imediato (offset)
                mem_to_reg <= '1';  -- Dado vem da memoria
                reg_write  <= '1';  -- Escreve no registrador
                mem_read   <= '1';  -- Habilita leitura da memoria
                alu_op     <= "00"; -- ADD (pra calcular endereco = base + offset)
                
            -- SW: Store Word - armazena palavra na memoria
            when OP_SW =>
                alu_src   <= '1';  -- Segundo operando e imediato (offset)
                mem_write <= '1';  -- Habilita escrita na memoria
                alu_op    <= "00"; -- ADD (pra calcular endereco = base + offset)
                
            -- BEQ: Branch if Equal - desvia se registradores sao iguais
            when OP_BEQ =>
                branch  <= '1';  -- E instrucao de branch
                alu_op  <= "01"; -- SUB (pra comparar os registradores)
                
            -- ADDI: Add Immediate - soma com imediato
            when OP_ADDI =>
                alu_src   <= '1';  -- Segundo operando e imediato
                reg_write <= '1';  -- Escreve resultado no registrador
                alu_op    <= "00"; -- ADD
                
            -- Opcode nao reconhecido: nao faz nada (valores padrao ja setados)
            when others =>
                null;
                
        end case;
    end process;
    
end Behavioral;
