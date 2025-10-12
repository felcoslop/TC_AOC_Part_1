-- Memoria de Dados - RAM
-- Memoria de leitura/escrita pra armazenar variaveis do programa
-- 256 palavras de 32 bits (1KB total)
-- Leitura assincrona, escrita sincrona (no clock)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memoria_dados is
    Port ( 
        clk         : in  STD_LOGIC;
        mem_write   : in  STD_LOGIC;
        mem_read    : in  STD_LOGIC;
        endereco    : in  STD_LOGIC_VECTOR(31 downto 0);
        write_data  : in  STD_LOGIC_VECTOR(31 downto 0);
        read_data   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end memoria_dados;

architecture Behavioral of memoria_dados is
    -- Define um array de 256 palavras de 32 bits (1KB total)
    type mem_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memoria RAM inicializada com dados de teste
    signal memoria : mem_array := (
      0  => x"40200000",  -- 2.5 em ponto flutuante (IEEE 754)
      1  => x"40400000",  -- 3.0 em ponto flutuante
      2  => x"3FC00000",  -- 1.5 em ponto flutuante
      3  => x"00000000",  -- Espaco pra guardar resultado do FADD
      4  => x"00000000",  -- Espaco pra guardar resultado do FSUB
      5  => x"00000000",  -- Espaco pra guardar resultado do FMUL
      6  => x"0000000A",  -- int_a: 10 em decimal
      7  => x"00000014",  -- int_b: 20 em decimal
      8  => x"00000000",  -- Espaco pra guardar resultado de inteiros
      others => x"00000000"  -- Resto da memoria inicializa com zero
    );
    
begin
    
    -- Processo de ESCRITA (sincrono, acontece no clock)
    -- Instrucao SW (store word) usa esse processo
    process(clk)
        variable index : integer;  -- indice calculado do array
    begin
        if rising_edge(clk) then  -- So escreve na borda de subida do clock
            if mem_write = '1' then  -- E so se mem_write estiver habilitado
                -- Converte endereco de byte pra indice de palavra (divide por 4)
                index := to_integer(unsigned(endereco(9 downto 2)));
                
                -- Verifica se o indice e valido antes de escrever
                if index >= 0 and index < 256 then
                    memoria(index) <= write_data;  -- Escreve dado na posicao index
                end if;
            end if;
        end if;
    end process;
    
    -- Processo de LEITURA (assincrono, nao precisa de clock)
    -- Instrucao LW (load word) usa esse processo
    process(mem_read, endereco, memoria)
        variable index : integer;  -- indice calculado do array
    begin
        if mem_read = '1' then  -- So le se mem_read estiver habilitado
            -- Converte endereco de byte pra indice de palavra (divide por 4)
            index := to_integer(unsigned(endereco(9 downto 2)));
            
            -- Verifica se o indice e valido
            if index >= 0 and index < 256 then
                read_data <= memoria(index);  -- Retorna dado na posicao index
            else
                read_data <= (others => '0');  -- Retorna zero se endereco invalido
            end if;
        else
            read_data <= (others => '0');  -- Retorna zero se leitura nao habilitada
        end if;
    end process;
    
end Behavioral;
