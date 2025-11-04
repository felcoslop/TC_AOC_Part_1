-- FPU Multiplier - Multiplicador de Ponto Flutuante IEEE 754
-- Implementa multiplicação de números em formato single-precision (32 bits)
-- Formato: [sinal(1)][expoente(8)][mantissa(23)]
-- Algoritmo: XOR dos sinais, soma dos expoentes, multiplicação das mantissas

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu_multiplier is
    Port ( 
        operando_a : in  STD_LOGIC_VECTOR(31 downto 0);  -- Primeiro número FP
        operando_b : in  STD_LOGIC_VECTOR(31 downto 0);  -- Segundo número FP
        resultado  : out STD_LOGIC_VECTOR(31 downto 0)   -- Resultado A * B
    );
end fpu_multiplier;

architecture Behavioral of fpu_multiplier is
    -- BIAS do expoente IEEE 754: 127 (pra representar expoentes negativos)
    -- Expoente real = expoente armazenado - 127
    constant BIAS : integer := 127;
    
    -- Função auxiliar: verifica se todos os bits são válidos (0 ou 1)
    -- Evita erros com sinais não inicializados ('U', 'X', etc)
    function is_valid(vec : STD_LOGIC_VECTOR) return boolean is
    begin
        for i in vec'range loop
            if vec(i) /= '0' and vec(i) /= '1' then
                return false;  -- Encontrou bit inválido
            end if;
        end loop;
        return true;  -- Todos os bits são válidos
    end function;
    
begin
    
    -- Processo combinacional: calcula A * B
    process(operando_a, operando_b)
        -- Variáveis pra armazenar os campos dos números FP
        variable sinal_r : STD_LOGIC;  -- Sinal do resultado
        variable exp_a_int, exp_b_int, exp_r_int : integer;  -- Expoentes
        variable mant_a_ext, mant_b_ext : unsigned(23 downto 0);  -- Mantissas com bit implícito
        variable mant_product : unsigned(47 downto 0);  -- Produto das mantissas (dobra de bits)
    begin
        -- Inicializa resultado com zero (importante pra evitar sinais indefinidos)
        resultado <= (others => '0');
        
        -- Só processa se os operandos são válidos
        if is_valid(operando_a) and is_valid(operando_b) then
            -- Casos especiais: se algum operando é zero, resultado é zero
            if operando_a = x"00000000" or operando_b = x"00000000" then
                resultado <= x"00000000";  -- 0 * qualquer coisa = 0
            -- Se algum expoente é zero (número denormalizado), considera como zero
            elsif operando_a(30 downto 23) = x"00" or operando_b(30 downto 23) = x"00" then
                resultado <= x"00000000";
            else
                -- Calcula o sinal do resultado: XOR dos sinais
                -- Positivo * Positivo = Positivo (0 XOR 0 = 0)
                -- Positivo * Negativo = Negativo (0 XOR 1 = 1)
                -- Negativo * Negativo = Positivo (1 XOR 1 = 0)
                sinal_r := operando_a(31) xor operando_b(31);
                
                -- Extrai os expoentes dos operandos (bits 30 até 23)
                exp_a_int := to_integer(unsigned(operando_a(30 downto 23)));
                exp_b_int := to_integer(unsigned(operando_b(30 downto 23)));
                
                -- Extrai mantissas e adiciona o bit implícito "1" na frente
                -- IEEE 754 tem um "1" implícito: mantissa real = 1.mantissa
                mant_a_ext := unsigned('1' & operando_a(22 downto 0));
                mant_b_ext := unsigned('1' & operando_b(22 downto 0));
                
                -- Multiplica as mantissas
                -- 24 bits * 24 bits = 48 bits (por isso precisa de variável maior)
                mant_product := mant_a_ext * mant_b_ext;
                
                -- Normalização do resultado
                -- Produto de mantissas pode ter bit 47 ou 46 como MSB
                if mant_product(47) = '1' then
                    -- Caso 1: bit 47 = 1, resultado já está normalizado
                    -- Calcula expoente: soma os expoentes, subtrai o BIAS, adiciona 1
                    -- +1 porque o ponto decimal deslocou uma casa
                    exp_r_int := exp_a_int + exp_b_int - BIAS + 1;
                    
                    -- Verifica se expoente está dentro da faixa válida (1 a 254)
                    if exp_r_int >= 1 and exp_r_int <= 254 then
                        -- Monta resultado: [sinal][expoente][mantissa normalizada]
                        -- Pega bits 46-24 do produto (23 bits) pra mantissa
                        resultado <= sinal_r & 
                                   std_logic_vector(to_unsigned(exp_r_int, 8)) & 
                                   std_logic_vector(mant_product(46 downto 24));
                    end if;
                else
                    -- Caso 2: bit 47 = 0, resultado precisa shift left
                    -- Calcula expoente: soma os expoentes, subtrai o BIAS
                    exp_r_int := exp_a_int + exp_b_int - BIAS;
                    
                    -- Verifica se expoente está dentro da faixa válida
                    if exp_r_int >= 1 and exp_r_int <= 254 then
                        -- Monta resultado: [sinal][expoente][mantissa normalizada]
                        -- Pega bits 45-23 do produto (23 bits) pra mantissa
                        resultado <= sinal_r & 
                                   std_logic_vector(to_unsigned(exp_r_int, 8)) & 
                                   std_logic_vector(mant_product(45 downto 23));
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;