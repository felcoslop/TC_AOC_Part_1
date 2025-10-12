-- ULA de Inteiros - Unidade Logica Aritmetica de 32 bits
-- Faz operacoes basicas com inteiros: soma, subtracao, AND, OR, SLT, NOR
-- Recebe dois operandos de 32 bits e um codigo de controle de 4 bits
-- Retorna o resultado da operacao e uma flag indicando se resultado e zero

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula_inteiros is
    Port ( 
        operando_a  : in  STD_LOGIC_VECTOR(31 downto 0);
        operando_b  : in  STD_LOGIC_VECTOR(31 downto 0);
        controle    : in  STD_LOGIC_VECTOR(3 downto 0);
        resultado   : out STD_LOGIC_VECTOR(31 downto 0);
        zero        : out STD_LOGIC
    );
end ula_inteiros;

architecture Behavioral of ula_inteiros is
    signal resultado_interno : STD_LOGIC_VECTOR(31 downto 0);  -- Armazena resultado temporario
begin
    -- Processo combinacional: executa a cada mudanca nos operandos ou controle
    process(operando_a, operando_b, controle)
        variable temp : signed(31 downto 0);  -- Variavel temporaria (nao usada aqui)
    begin
        -- Decodifica o codigo de controle e executa a operacao correspondente
        case controle is
            when "0010" =>  -- ADD: soma com sinal (A + B)
                resultado_interno <= std_logic_vector(signed(operando_a) + signed(operando_b));
                
            when "0110" =>  -- SUB: subtracao com sinal (A - B)
                resultado_interno <= std_logic_vector(signed(operando_a) - signed(operando_b));
                
            when "0000" =>  -- AND: E logico bit a bit
                resultado_interno <= operando_a AND operando_b;
                
            when "0001" =>  -- OR: OU logico bit a bit
                resultado_interno <= operando_a OR operando_b;
                
            when "0111" =>  -- SLT: Set on Less Than (retorna 1 se A < B, senao 0)
                if signed(operando_a) < signed(operando_b) then
                    resultado_interno <= x"00000001";  -- A e menor: retorna 1
                else
                    resultado_interno <= x"00000000";  -- A nao e menor: retorna 0
                end if;
                
            when "1100" =>  -- NOR: NaO-OU logico bit a bit
                resultado_interno <= operando_a NOR operando_b;
                
            when others =>  -- Operacao invalida: retorna zero
                resultado_interno <= (others => '0');
        end case;
    end process;
    
    -- Conecta resultado interno a saida
    resultado <= resultado_interno;
    
    -- Flag zero: indica se o resultado e zero (importante pra branches)
    -- Fica em '1' quando resultado e 0x00000000, senao fica em '0'
    zero <= '1' when resultado_interno = x"00000000" else '0';
    
end Behavioral;


