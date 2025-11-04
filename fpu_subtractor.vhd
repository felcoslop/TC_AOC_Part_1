-- FPU Subtractor - Subtrator de Ponto Flutuante IEEE 754
-- Implementa subtração A - B reutilizando o somador
-- Truque: A - B = A + (-B), então só inverte o sinal de B e usa o adder
-- Muito mais simples que implementar subtração do zero!

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu_subtractor is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);  -- Primeiro número FP
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);  -- Segundo número FP
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)   -- Resultado A - B
    );
end fpu_subtractor;

architecture Behavioral of fpu_subtractor is
    
    -- Declara o componente do somador FPU que vamos reutilizar
    component fpu_adder is
        Port ( 
            operando_a : in  STD_LOGIC_VECTOR(31 downto 0);
            operando_b : in  STD_LOGIC_VECTOR(31 downto 0);
            resultado  : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Sinal intermediário: operando B com sinal invertido
    signal operando_b_negado : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    
    -- Inverte o sinal de B (bit 31 em ponto flutuante IEEE 754)
    -- Mantém todos os outros bits iguais (expoente e mantissa)
    -- Exemplo: se B é +3.0, vira -3.0; se B é -2.5, vira +2.5
    operando_b_negado <= NOT operando_b(31) & operando_b(30 downto 0);
    
    -- Instancia o somador FPU e passa A e (-B)
    -- Resultado final: A + (-B) = A - B
    adder_inst : fpu_adder
        port map (
            operando_a => operando_a,        -- A entra normal
            operando_b => operando_b_negado, -- B entra com sinal invertido
            resultado  => resultado          -- Saída é A - B
        );
    
end Behavioral;