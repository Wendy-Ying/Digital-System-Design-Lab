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
use IEEE.NUMERIC_STD.ALL;

entity testbench is
    -- Port ( );
end testbench;

architecture Behavioral of testbench is

    signal clk       : STD_LOGIC := '0';
    signal rst       : STD_LOGIC := '1';
    signal start     : STD_LOGIC := '0';
    signal n         : STD_LOGIC_VECTOR (5 downto 0);
    signal fib_n     : STD_LOGIC_VECTOR (63 downto 0);
    signal done      : STD_LOGIC;

begin

    -- Generate clock signal
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns; -- half clock period
        clk <= '1';
        wait for 10 ns; -- half clock period
    end process clk_process;

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.fibonacci_fsm
        port map (
            clk     => clk,
            rst     => rst,
            start   => start,
            n       => n,
            fib_n   => fib_n,
            done    => done
        );

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initialize signals
        rst <= '1';
        start <= '0';
        wait for 100 ns;
        rst <= '0'; -- Release reset

        -- test 1: n = 0
        n <= "000000"; -- 0
        start <= '1'; -- Start the calculation
        wait for 10 ns;
        start <= '0'; -- Stop the start signal
        wait until done = '1'; -- Wait for calculation to complete
        assert fib_n = std_logic_vector(to_unsigned(0, 64)) report "Test case 1 failed" severity error;

        -- test 2: n = 1
        n <= "000001"; -- 1
        start <= '1';
        wait for 10 ns;
        start <= '0';
        wait until done = '1';
        assert fib_n = std_logic_vector(to_unsigned(1, 64)) report "Test case 2 failed" severity error;

        -- test 3: n = 5
        n <= "000101"; -- 5
        start <= '1';
        wait for 10 ns;
        start <= '0';
        wait until done = '1';
        assert fib_n = std_logic_vector(to_unsigned(5, 64)) report "Test case 3 failed" severity error;

        -- test 4: n = 10
        n <= "001010"; -- 10
        start <= '1';
        wait for 10 ns;
        start <= '0';
        wait until done = '1';
        assert fib_n = std_logic_vector(to_unsigned(55, 64)) report "Test case 4 failed" severity error;

        -- test 5: n = 63
        n <= "111111"; -- 63
        start <= '1';
        wait for 10 ns;
        start <= '0';
        wait until done = '1';
        assert fib_n = "01011111011011000111101100000110010011100010" report "Test case 5 failed" severity error;

        -- end of test
        wait;
    end process;

end Behavioral;