-- ULA Control - Controle da ULA
-- Traduz os sinais da unidade de controle (alu_op) e o funct da instrução
-- em um código de controle de 4 bits que a ULA entende
-- ALUOp "00" = add (lw/sw), "01" = sub (beq), "10" = depende do funct (tipo-R)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ula_control is
    Port ( 
        alu_op   : in  STD_LOGIC_VECTOR(1 downto 0);
        funct    : in  STD_LOGIC_VECTOR(5 downto 0);
        controle : out STD_LOGIC_VECTOR(3 downto 0)
    );
end ula_control;

architecture Behavioral of ula_control is
    
    -- Códigos funct das instruções Tipo-R (vem dos bits 5-0 da instrução)
    constant FUNCT_ADD : STD_LOGIC_VECTOR(5 downto 0) := "100000"; -- 0x20: add
    constant FUNCT_SUB : STD_LOGIC_VECTOR(5 downto 0) := "100010"; -- 0x22: sub
    constant FUNCT_AND : STD_LOGIC_VECTOR(5 downto 0) := "100100"; -- 0x24: and
    constant FUNCT_OR  : STD_LOGIC_VECTOR(5 downto 0) := "100101"; -- 0x25: or
    constant FUNCT_SLT : STD_LOGIC_VECTOR(5 downto 0) := "101010"; -- 0x2A: slt
    constant FUNCT_NOR : STD_LOGIC_VECTOR(5 downto 0) := "100111"; -- 0x27: nor
    
begin
    
    -- Processo combinacional: gera código de controle baseado em alu_op e funct
    process(alu_op, funct)
    begin
        case alu_op is
            
            when "00" =>  -- lw, sw, addi: sempre ADD
                controle <= "0010";  -- Código 0010 = ADD (pra calcular endereço)
                
            when "01" =>  -- beq: sempre SUB
                controle <= "0110";  -- Código 0110 = SUB (pra comparar se são iguais)
                
            when "10" =>  -- Tipo-R: olha o funct pra decidir
                case funct is
                    when FUNCT_ADD =>
                        controle <= "0010";  -- ADD
                    when FUNCT_SUB =>
                        controle <= "0110";  -- SUB
                    when FUNCT_AND =>
                        controle <= "0000";  -- AND
                    when FUNCT_OR =>
                        controle <= "0001";  -- OR
                    when FUNCT_SLT =>
                        controle <= "0111";  -- SLT
                    when FUNCT_NOR =>
                        controle <= "1100";  -- NOR
                    when others =>
                        controle <= "0000";  -- Default: AND (caso não reconheça)
                end case;
                
            when others =>  -- ALUOp inválido
                controle <= "0000";  -- Default: AND
                
        end case;
    end process;
    
end Behavioral;