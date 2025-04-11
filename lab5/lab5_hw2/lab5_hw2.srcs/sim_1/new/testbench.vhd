----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/11 17:47:38
-- Design Name: 
-- Module Name: testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is

    signal n       : STD_LOGIC_VECTOR (5 downto 0);
    signal fib_n   : STD_LOGIC_VECTOR (63 downto 0);
    signal clk     : STD_LOGIC := '0';
    signal reset   : STD_LOGIC := '0';

    constant clk_period : time := 10 ns;

begin

    uut: entity work.fibonacci
        port map (
            n     => n,
            fib_n => fib_n
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    stimulus_process : process
    begin
        -- initialize
        reset <= '1';
        n <= "000000";
        wait for clk_period;
        reset <= '0';

        -- test 1: n = 0
        n <= "000000"; -- 0
        wait for clk_period;
        assert fib_n = std_logic_vector(to_unsigned(0, 64)) report "Test case 1 failed" severity error;

        -- test 2: n = 1
        n <= "000001"; -- 1
        wait for clk_period;
        assert fib_n = std_logic_vector(to_unsigned(1, 64)) report "Test case 2 failed" severity error;

        -- test 3: n = 5
        n <= "000101"; -- 5
        wait for clk_period;
        assert fib_n = std_logic_vector(to_unsigned(5, 64)) report "Test case 3 failed" severity error;

        -- test 4: n = 10
        n <= "001010"; -- 10
        wait for clk_period;
        assert fib_n = std_logic_vector(to_unsigned(55, 64)) report "Test case 4 failed" severity error;

        -- test 5: n = 63
        n <= "111111"; -- 63
        wait for clk_period;
        assert fib_n = std_logic_vector(to_unsigned(44701154615323443421050492017, 64)) report "Test case 5 failed" severity error;

        -- end of test
        wait;
    end process;

end Behavioral;
