----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 1025/04/11 17:47:38
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
    signal finish    : STD_LOGIC;

begin

    -- Generate clock signal
    clk <= not clk after 5 ns;

    -- Instantiate the Unit Under Test (UUT)
    uut: entity fibonacci_fsm
        port map (
            clk     => clk,
            rst     => rst,
            start   => start,
            n       => n,
            fib_n   => fib_n,
            finish  => finish
        );

    -- Stimulus process
    stimulus_process : process
    begin
        -- Initialize signals
        rst <= '1';
        wait for 10 ns;
        rst <= '0';
        n <= "000000";
        start <= '0';
        wait for 100 ns;

        -- test: n = 5
        start <= '1';
        n <= "000101";
        wait for 10 ns;
        start <= '0';
        wait until finish = '1';
        wait for 10 ns;
        
        -- test: n = 10
        start <= '1';
        n <= "001010";
        wait for 10 ns;
        start <= '0';
        wait until finish = '1';
        wait for 10 ns;

        -- test: n = 63
        start <= '1';
        n <= "111111";
        wait for 10 ns;
        start <= '0';
        wait until finish = '1';
        wait for 10 ns;

        -- end of test
        wait;

    end process;

end Behavioral;