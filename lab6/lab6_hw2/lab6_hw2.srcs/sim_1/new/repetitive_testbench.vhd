library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity repetitive_testbench is
end repetitive_testbench;

architecture Behavioral of repetitive_testbench is
    component repetitive_addition
        port(
            CLK    : in std_logic;
            RESET  : in std_logic;
            start  : in std_logic;
            a_in   : in std_logic_vector(7 downto 0);
            b_in   : in std_logic_vector(7 downto 0);
            ready  : out std_logic;
            r      : out std_logic_vector(15 downto 0)
        );
    end component;

    signal CLK     : std_logic := '0';
    signal RESET   : std_logic := '1';
    signal start   : std_logic := '0';
    signal a_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal b_in    : std_logic_vector(7 downto 0) := (others => '0');
    signal ready   : std_logic;
    signal r       : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    
    -- Function to generate random std_logic_vector
    impure function random_slv(len : integer) return std_logic_vector is
        variable seed1, seed2 : integer := 999;
        variable r : real;
        variable slv : std_logic_vector(len-1 downto 0);
    begin
        for i in slv'range loop
            uniform(seed1, seed2, r);
            if r > 0.5 then
                slv(i) := '1';
            else
                slv(i) := '0';
            end if;
        end loop;
        return slv;
    end function;

begin
    uut: repetitive_addition
        port map (
            CLK => CLK,
            RESET => RESET,
            start => start,
            a_in => a_in,
            b_in => b_in,
            ready => ready,
            r => r
        );

    -- Clock generation (100 MHz)
    CLK <= not CLK after CLK_PERIOD / 2;

    stimulus: process
        variable expected_r : std_logic_vector(15 downto 0);
        variable test_pass : boolean := true;
        variable line_out : line;
        variable operation_done : boolean := false;
    begin
        -- Print test header
        write(line_out, string'("=== Starting Repetitive Addition Multiplier Test ==="));
        writeline(output, line_out);
        
        -- Initialize and reset
        RESET <= '1';
        wait for CLK_PERIOD * 2;
        RESET <= '0';
        wait for CLK_PERIOD;

        -- ========== Basic Test Cases ==========
        write(line_out, string'("Basic test cases..."));
        writeline(output, line_out);
        
        -- Test 1: 0 * 0
        a_in <= "00000000"; b_in <= "00000000";
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        
        -- Wait for operation to complete
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := (others => '0');
        assert r = expected_r 
            report "Test 1 failed: 0*0 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- Test 2: 1 * 1
        a_in <= "00000001"; b_in <= "00000001";
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := std_logic_vector(to_unsigned(1, 16));
        assert r = expected_r 
            report "Test 2 failed: 1*1 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- Test 3: Max value * Max value (255*255)
        a_in <= "11111111"; b_in <= "11111111";
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := std_logic_vector(to_unsigned(255*255, 16));
        assert r = expected_r 
            report "Test 3 failed: 255*255 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- ========== Edge Cases ==========
        write(line_out, string'("Edge cases..."));
        writeline(output, line_out);
        
        -- Test 4: Max * 1
        a_in <= "11111111"; b_in <= "00000001";
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := std_logic_vector(to_unsigned(255, 16));
        assert r = expected_r 
            report "Test 4 failed: 255*1 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- Test 5: 1 * Max
        a_in <= "00000001"; b_in <= "11111111";
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := std_logic_vector(to_unsigned(255, 16));
        assert r = expected_r 
            report "Test 5 failed: 1*255 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- Test 6: Power of 2 multiplication
        a_in <= "00000100"; b_in <= "00001000";  -- 4 * 8
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';
        wait until ready = '1';
        wait for CLK_PERIOD;
        
        expected_r := std_logic_vector(to_unsigned(32, 16));
        assert r = expected_r 
            report "Test 6 failed: 4*8 expected " & to_hstring(expected_r) & 
                   " got " & to_hstring(r)
            severity error;
        
        -- ========== Pattern Testing ==========
        write(line_out, string'("Pattern testing..."));
        writeline(output, line_out);
        
        -- Test 7-10: Sequential patterns
        for i in 1 to 4 loop
            a_in <= std_logic_vector(to_unsigned(i*10, 8));
            b_in <= std_logic_vector(to_unsigned(i*5, 8));
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            wait until ready = '1';
            wait for CLK_PERIOD;
            
            expected_r := std_logic_vector(to_unsigned((i*10)*(i*5), 16));
            assert r = expected_r 
                report "Test " & integer'image(6+i) & " failed: " & 
                       integer'image(i*10) & "*" & integer'image(i*5) & 
                       " expected " & to_hstring(expected_r) & 
                       " got " & to_hstring(r)
                severity error;
        end loop;
        
        -- ========== Random Testing ==========
        write(line_out, string'("Random testing (20 cases)..."));
        writeline(output, line_out);
        
        -- Test 11-30: Random values
        for i in 1 to 20 loop
            a_in <= random_slv(8);
            b_in <= random_slv(8);
            start <= '1';
            wait for CLK_PERIOD;
            start <= '0';
            wait until ready = '1';
            wait for CLK_PERIOD;
            
            expected_r := std_logic_vector(
                unsigned(a_in) * unsigned(b_in));
            assert r = expected_r 
                report "Test " & integer'image(10+i) & " failed: " & 
                       "a=" & to_hstring(a_in) & " b=" & to_hstring(b_in) & 
                       " expected " & to_hstring(expected_r) & 
                       " got " & to_hstring(r)
                severity error;
        end loop;
        
        -- ========== Complete Testing ==========
        -- Uncomment to run exhaustive testing (65536 cases)
        -- Note: This will significantly increase simulation time
        /*
        write(line_out, string'("Exhaustive testing..."));
        writeline(output, line_out);
        
        for i in 0 to 255 loop
            for j in 0 to 255 loop
                a_in <= std_logic_vector(to_unsigned(i, 8));
                b_in <= std_logic_vector(to_unsigned(j, 8));
                start <= '1';
                wait for CLK_PERIOD;
                start <= '0';
                wait until ready = '1';
                wait for CLK_PERIOD;
                
                expected_r := std_logic_vector(to_unsigned(i*j, 16));
                if r /= expected_r then
                    write(line_out, string'("Error at a=") & to_hstring(a_in) & 
                          string'(" b=") & to_hstring(b_in) & 
                          string'(" expected ") & to_hstring(expected_r) & 
                          string'(" got ") & to_hstring(r));
                    writeline(output, line_out);
                    test_pass := false;
                end if;
            end loop;
        end loop;
        */
        
        -- ========== Test Summary ==========
        if test_pass then
            write(line_out, string'("All tests PASSED!"));
            writeline(output, line_out);
        else
            write(line_out, string'("Some tests FAILED!"));
            writeline(output, line_out);
        end if;
        
        write(line_out, string'("=== Test Complete ==="));
        writeline(output, line_out);
        wait;
    end process;
end Behavioral;