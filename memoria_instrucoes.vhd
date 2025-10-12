-- Memoria de Instrucoes - ROM
-- Armazena as instrucoes do programa em codigo de maquina
-- e uma memoria somente leitura (ROM) com 256 palavras de 32 bits (1KB)
-- Enderecamento por palavra: cada endereco aponta pra uma instrucao de 32 bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoria_instrucoes is
    Port ( 
        endereco   : in  STD_LOGIC_VECTOR(31 downto 0);
        instrucao  : out STD_LOGIC_VECTOR(31 downto 0)
    );
end memoria_instrucoes;

architecture Behavioral of memoria_instrucoes is
    -- Define um array de 256 palavras de 32 bits cada (1KB total)
    type mem_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memoria ROM inicializada com o programa de teste
    -- Cada linha e uma instrucao de 32 bits em hexadecimal
    signal memoria : mem_array := (
        -- Exemplo: Programa simples de teste
        -- Sera substituido pelo codigo do teste_parte1.asm
        0  => x"3C081001",  -- lui  $t0, 0x1001
        1  => x"8D100000",  -- lw   $s0, 0($t0)
        2  => x"8D110004",  -- lw   $s1, 4($t0)
        3  => x"8D120008",  -- lw   $s2, 8($t0)
        4  => x"02119823",  -- fadd $s3, $s0, $s1
        5  => x"AD13000C",  -- sw   $s3, 12($t0)
        6  => x"0272A026",  -- fsub $s4, $s3, $s2
        7  => x"AD140010",  -- sw   $s4, 16($t0)
        8  => x"0211A827",  -- fmul $s5, $s0, $s1
        9  => x"AD150014",  -- sw   $s5, 20($t0)
        10 => x"8D090018",  -- lw   $t1, 24($t0)
        11 => x"8D0A001C",  -- lw   $t2, 28($t0)
        12 => x"012A5820",  -- add  $t3, $t1, $t2
        13 => x"01496022",  -- sub  $t4, $t2, $t1
        14 => x"012A6824",  -- and  $t5, $t1, $t2
        15 => x"012A7025",  -- or   $t6, $t1, $t2
        16 => x"012A782A",  -- slt  $t7, $t1, $t2
        17 => x"AD0B0020",  -- sw   $t3, 32($t0)
        18 => x"20180005",  -- addi $t8, $zero, 5
        19 => x"20190005",  -- addi $t9, $zero, 5
        20 => x"13190001",  -- beq  $t8, $t9, +1
        21 => x"20160063",  -- addi $s6, $zero, 99
        22 => x"20160064",  -- addi $s6, $zero, 100
        23 => x"2017002A",  -- addi $s7, $zero, 42
        24 => x"22F70008",  -- addi $s7, $s7, 8
        25 => x"08000019",  -- j 0x64
        others => x"00000000"
    );
    
begin
    -- Processo de leitura da memoria (combinacional, sem clock)
    -- Pega o endereco e retorna a instrucao correspondente
    process(endereco)
        variable index : integer;  -- indice calculado do array
    begin
        -- Converte endereco de byte pra endereco de palavra
        -- Enderecos MIPS sao em bytes, mas cada instrucao tem 4 bytes
        -- Entao divide por 4 (ignora bits 1 e 0) pegando bits 9 ate 2
        -- Isso da 8 bits = 256 posicoes possiveis
        index := to_integer(unsigned(endereco(9 downto 2)));
        
        -- Verifica se o indice e valido
        if index >= 0 and index < 256 then
            instrucao <= memoria(index);  -- Retorna instrucao na posicao index
        else
            instrucao <= x"00000000";  -- NOP (no operation) se endereco invalido
        end if;
    end process;
    
end Behavioral;
