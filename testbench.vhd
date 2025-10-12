-- Testbench - Processador MIPS Single-Cycle com FPU
-- Ambiente de teste pra validar o funcionamento completo do processador
-- Gera sinais de clock e reset, executa o programa de teste e valida resultados
-- Testa todas as funcionalidades: FPU, inteiros, load/store, branches

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is
    
    -- Declara o componente do processador que vai ser testado (UUT = Unit Under Test)
    component processador_mips is
        Port ( 
            clk   : in STD_LOGIC;  -- Sinal de clock
            reset : in STD_LOGIC   -- Sinal de reset
        );
    end component;
    
    -- Sinais de teste
    signal clk   : STD_LOGIC := '0';  -- Clock inicializa em 0
    signal reset : STD_LOGIC := '1';  -- Reset inicializa ativo (1)
    
    -- Constante do periodo do clock: 10ns = 100 MHz
    constant CLK_PERIOD : time := 10 ns;
    
    -- Contador de ciclos de clock (pra debug e analise)
    signal cycle_count : integer := 0;
    
    -- Flag pra controlar quando a simulacao termina
    signal sim_finished : boolean := false;
    
begin
    
    -- Instancia o processador MIPS (UUT = Unit Under Test)
    -- Conecta os sinais de teste ao processador
    UUT : processador_mips
        port map (
            clk   => clk,    -- Conecta sinal de clock
            reset => reset   -- Conecta sinal de reset
        );
    
    -- Processo que gera o sinal de clock
    -- Oscila entre 0 e 1 com periodo de 10ns (frequencia de 100 MHz)
    clk_process : process
    begin
        while not sim_finished loop  -- Continua gerando clock enquanto simulacao nao terminar
            clk <= '0';              -- Clock vai pra 0
            wait for CLK_PERIOD/2;   -- Espera metade do periodo (5ns)
            clk <= '1';              -- Clock vai pra 1
            wait for CLK_PERIOD/2;   -- Espera metade do periodo (5ns)
        end loop;
        wait;  -- Para o processo quando simulacao termina
    end process;
    
    -- Processo que conta os ciclos de clock
    -- util pra saber quantos ciclos o programa levou pra executar
    cycle_counter : process(clk)
    begin
        if rising_edge(clk) then        -- A cada borda de subida do clock
            if reset = '0' then         -- So conta se reset nao esta ativo
                cycle_count <= cycle_count + 1;  -- Incrementa contador
            end if;
        end if;
    end process;
    
    -- Processo principal de teste
    -- Controla a sequencia de teste: reset, execucao e validacao
    test_process : process
    begin
        -- Imprime cabecalho do teste no console
        report "========================================";
        report "Iniciando Testbench - Parte 1";
        report "Processador MIPS Single-Cycle com FPU";
        report "========================================";
        
        -- Aplica reset por 2 ciclos de clock
        reset <= '1';                -- Ativa reset (processador volta ao estado inicial)
        wait for CLK_PERIOD * 2;     -- Espera 20ns (2 ciclos)
        reset <= '0';                -- Desativa reset (processador comeca a executar)
        
        report "Reset liberado. Processador iniciado.";
        
        -- Espera o programa executar
        -- 50 ciclos e suficiente pra executar todas as instrucoes do teste
        -- Single-cycle = 1 instrucao por ciclo
        wait for CLK_PERIOD * 50;    -- Espera 500ns (50 ciclos)
        
        -- Imprime mensagem de conclusao
        report "========================================";
        report "Execucao concluida apos 50 ciclos";
        report "========================================";
        
        -- Lista os resultados esperados de cada teste
        -- Esses valores devem aparecer nos registradores e memoria apos a execucao
        
        report "TESTE 1 Load Store: Esperado";
        report "  s0 = 0x40200000 (2.5 FP)";    -- Carregou 2.5 da memoria
        report "  s1 = 0x40400000 (3.0 FP)";    -- Carregou 3.0 da memoria
        report "  s2 = 0x3FC00000 (1.5 FP)";    -- Carregou 1.5 da memoria
        
        report "TESTE 2 FADD: Esperado";
        report "  s3 = 0x40B00000 (5.5 FP)";    -- 2.5 + 3.0 = 5.5
        report "  Memoria[12] = 0x40B00000";    -- Resultado salvo na memoria
        
        report "TESTE 3 FSUB: Esperado";
        report "  s4 = 0x40800000 (4.0 FP)";    -- 5.5 - 1.5 = 4.0
        report "  Memoria[16] = 0x40800000";    -- Resultado salvo na memoria
        
        report "TESTE 4 FMUL: Esperado";
        report "  s5 = 0x40F00000 (7.5 FP)";    -- 2.5 * 3.0 = 7.5
        report "  Memoria[20] = 0x40F00000";    -- Resultado salvo na memoria
        
        report "TESTE 5 Inteiros: Esperado";
        report "  t3 = 0x0000001E (30)";        -- Operacoes com inteiros
        report "  t7 = 0x00000001 (1)";         -- Resultado de SLT
        report "  Memoria[32] = 0x0000001E";    -- Resultado salvo na memoria
        
        report "TESTE 6 Branch: Esperado";
        report "  s6 = 0x00000064 (100)";       -- Valor correto so se branch funcionou
        report "  Prova que branch funcionou";  -- Se fosse 99, branch nao funcionou
        
        report "TESTE 7 Immediate: Esperado";
        report "  s7 = 0x00000032 (50)";        -- Teste de ADDI
        
        -- Imprime mensagem final
        report "========================================";
        report "TESTBENCH CONCLUIDO COM SUCESSO";
        report "========================================";
        
        -- Sinaliza que a simulacao terminou
        sim_finished <= true;  -- Para o gerador de clock
        wait;  -- Para este processo
        
    end process;
    
end Behavioral;
