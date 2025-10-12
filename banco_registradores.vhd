-- Banco de Registradores MIPS
-- Implementa os 32 registradores de proposito geral do MIPS
-- 2 portas de leitura, 1 porta de escrita
-- Registrador $0 sempre retorna zero conforme especificacao MIPS

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity banco_registradores is
    Port ( 
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        reg_write     : in  STD_LOGIC;
        read_reg1     : in  STD_LOGIC_VECTOR(4 downto 0);
        read_reg2     : in  STD_LOGIC_VECTOR(4 downto 0);
        write_reg     : in  STD_LOGIC_VECTOR(4 downto 0);
        write_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        read_data1    : out STD_LOGIC_VECTOR(31 downto 0);
        read_data2    : out STD_LOGIC_VECTOR(31 downto 0)
    );
end banco_registradores;

architecture Behavioral of banco_registradores is
    -- Array de 32 registradores de 32 bits
    type reg_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal registradores : reg_array := (others => (others => '0')); -- Inicializa todos com zero
begin
    
    -- Processo de escrita (sincrono)
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reset todos os registradores para zero
            registradores <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if reg_write = '1' then
                -- Nao permite escrita no registrador $0 (especificacao MIPS)
                if unsigned(write_reg) /= 0 then
                    registradores(to_integer(unsigned(write_reg))) <= write_data;
                end if;
            end if;
        end if;
    end process;
    
    -- Leitura assincrona dos registradores
    -- Registrador $0 sempre retorna zero (especificacao MIPS)
    read_data1 <= (others => '0') when unsigned(read_reg1) = 0 else
                  registradores(to_integer(unsigned(read_reg1)));
                  
    read_data2 <= (others => '0') when unsigned(read_reg2) = 0 else
                  registradores(to_integer(unsigned(read_reg2)));
    
end Behavioral;
