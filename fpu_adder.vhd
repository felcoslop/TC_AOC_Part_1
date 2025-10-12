-- FPU Adder - Somador de Ponto Flutuante IEEE 754
-- Implementa soma de numeros em formato single-precision (32 bits)
-- Formato: [sinal(1)][expoente(8)][mantissa(23)]
-- Algoritmo: alinha expoentes, soma mantissas, normaliza resultado

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu_adder is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);  -- Primeiro numero FP
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);  -- Segundo numero FP
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)   -- Resultado A + B
    );
end fpu_adder;

architecture Behavioral of fpu_adder is
    
    -- Funcao auxiliar: verifica se todos os bits sao validos (0 ou 1)
    -- Evita erros com sinais nao inicializados ('U', 'X', etc)
    function is_valid(vec : STD_LOGIC_VECTOR) return boolean is
    begin
        for i in vec'range loop
            if vec(i) /= '0' and vec(i) /= '1' then
                return false;  -- Encontrou bit invalido
            end if;
        end loop;
        return true;  -- Todos os bits sao validos
    end function;
    
begin
    
    -- Processo combinacional: calcula A + B
    process(operando_a, operando_b)
        -- Variaveis pra armazenar os campos dos numeros FP
        variable sinal_r : STD_LOGIC;  -- Sinal do resultado
        variable exp_a_int, exp_b_int, exp_maior : integer;  -- Expoentes
        variable mant_a_ext, mant_b_ext : unsigned(24 downto 0);  -- Mantissas com bit implicito
        variable mant_sum : unsigned(25 downto 0);  -- Soma das mantissas (precisa 1 bit extra)
        variable exp_diff : integer;  -- Diferenca entre expoentes
    begin
        -- Inicializa resultado com zero (importante pra evitar sinais indefinidos)
        resultado <= (others => '0');
        
        -- So processa se os operandos sao validos
        if is_valid(operando_a) and is_valid(operando_b) then
            -- Casos especiais: se um dos operandos e zero
            if operando_a = x"00000000" then
                resultado <= operando_b;  -- 0 + B = B
            elsif operando_b = x"00000000" then
                resultado <= operando_a;  -- A + 0 = A
            else
                -- Extrai os expoentes dos operandos (bits 30 ate 23)
                exp_a_int := to_integer(unsigned(operando_a(30 downto 23)));
                exp_b_int := to_integer(unsigned(operando_b(30 downto 23)));
                
                -- Extrai mantissas e adiciona o bit implicito "1" na frente
                -- IEEE 754 tem um "1" implicito antes da mantissa (ex: 1.mantissa)
                mant_a_ext := unsigned("01" & operando_a(22 downto 0));
                mant_b_ext := unsigned("01" & operando_b(22 downto 0));
                
                if exp_a_int >= exp_b_int then
                    exp_maior := exp_a_int;
                    exp_diff := exp_a_int - exp_b_int;
                    if exp_diff < 25 then
                        mant_sum := resize(mant_a_ext, 26) + resize(shift_right(mant_b_ext, exp_diff), 26);
                    else
                        mant_sum := resize(mant_a_ext, 26);
                    end if;
                else
                    exp_maior := exp_b_int;
                    exp_diff := exp_b_int - exp_a_int;
                    if exp_diff < 25 then
                        mant_sum := resize(shift_right(mant_a_ext, exp_diff), 26) + resize(mant_b_ext, 26);
                    else
                        mant_sum := resize(mant_b_ext, 26);
                    end if;
                end if;
                
                sinal_r := operando_a(31);
                
                if mant_sum(25) = '1' then
                    resultado <= sinal_r & 
                               std_logic_vector(to_unsigned(exp_maior + 1, 8)) & 
                               std_logic_vector(mant_sum(24 downto 2));
                else
                    resultado <= sinal_r & 
                               std_logic_vector(to_unsigned(exp_maior, 8)) & 
                               std_logic_vector(mant_sum(23 downto 1));
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
