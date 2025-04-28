library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity tb_combinational_design is
end tb_combinational_design;

architecture Behavioral of tb_combinational_design is
    component combinational_design is
        port (
            a, b : in std_logic_vector(4 downto 0);
            y : out std_logic_vector(9 downto 0)
        );
    end component;

    signal a, b : std_logic_vector(4 downto 0);
    signal y : std_logic_vector(9 downto 0);
    
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
    -- Unit Under Test instantiation
    uut: combinational_design port map (a => a, b => b, y => y);

    stimulus: process
        variable expected_y : std_logic_vector(9 downto 0);
        variable test_pass : boolean := true;
        variable line_out : line;
    begin
        -- Print test header
        write(line_out, string'("=== Starting Combinational Multiplier Test ==="));
        writeline(output, line_out);
        
        -- ========== Basic Test Cases ==========
        write(line_out, string'("Basic test cases..."));
        writeline(output, line_out);
        
        -- Test 1: 0 * 0
        a <= "00000"; b <= "00000";
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 1 failed: 0*0 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- Test 2: 1 * 1
        a <= "00001"; b <= "00001";
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 2 failed: 1*1 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- Test 3: Max value * Max value (31*31)
        a <= "11111"; b <= "11111";
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 3 failed: 31*31 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- ========== Edge Cases ==========
        write(line_out, string'("Edge cases..."));
        writeline(output, line_out);
        
        -- Test 4: Max * 1
        a <= "11111"; b <= "00001";
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 4 failed: 31*1 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- Test 5: 1 * Max
        a <= "00001"; b <= "11111";
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 5 failed: 1*31 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- Test 6: Power of 2 multiplication
        a <= "00100"; b <= "01000";  -- 4 * 8
        wait for 10 ns;
        expected_y := std_logic_vector(unsigned(a) * unsigned(b));
        assert y = expected_y 
            report "Test 6 failed: 4*8 expected " & to_hstring(expected_y) & 
                   " got " & to_hstring(y)
            severity error;
        
        -- ========== Pattern Testing ==========
        write(line_out, string'("Pattern testing..."));
        writeline(output, line_out);
        
        -- Test 7-10: Sequential patterns
        for i in 1 to 4 loop
            a <= std_logic_vector(to_unsigned(i*5, 5));
            b <= std_logic_vector(to_unsigned(i*3, 5));
            wait for 10 ns;
            expected_y := std_logic_vector(unsigned(a) * unsigned(b));
            assert y = expected_y 
                report "Test " & integer'image(6+i) & " failed: " & 
                       integer'image(i*5) & "*" & integer'image(i*3) & 
                       " expected " & to_hstring(expected_y) & 
                       " got " & to_hstring(y)
                severity error;
        end loop;
        
        -- ========== Random Testing ==========
        write(line_out, string'("Random testing (20 cases)..."));
        writeline(output, line_out);
        
        -- Test 11-30: Random values
        for i in 1 to 20 loop
            a <= random_slv(5);
            b <= random_slv(5);
            wait for 10 ns;
            expected_y := std_logic_vector(unsigned(a) * unsigned(b));
            assert y = expected_y 
                report "Test " & integer'image(10+i) & " failed: " & 
                       "a=" & to_hstring(a) & " b=" & to_hstring(b) & 
                       " expected " & to_hstring(expected_y) & 
                       " got " & to_hstring(y)
                severity error;
        end loop;
        
        -- ========== Complete Testing ==========
        -- Uncomment to run exhaustive testing (1024 cases)
        -- Note: This will significantly increase simulation time
        /*
        write(line_out, string'("Exhaustive testing..."));
        writeline(output, line_out);
        
        for i in 0 to 31 loop
            for j in 0 to 31 loop
                a <= std_logic_vector(to_unsigned(i, 5));
                b <= std_logic_vector(to_unsigned(j, 5));
                wait for 1 ns;
                expected_y := std_logic_vector(unsigned(a) * unsigned(b));
                if y /= expected_y then
                    write(line_out, string'("Error at a=") & to_hstring(a) & 
                          string'(" b=") & to_hstring(b) & 
                          string'(" expected ") & to_hstring(expected_y) & 
                          string'(" got ") & to_hstring(y));
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