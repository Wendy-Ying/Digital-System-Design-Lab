----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/11 17:48:27
-- Design Name: 
-- Module Name: fibonacci - Behavioral
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

entity fibonacci is
    Port (
        n : in  STD_LOGIC_VECTOR (5 downto 0);
        fib_n : out STD_LOGIC_VECTOR (63 downto 0)
    );
end fibonacci;

architecture Behavioral of fibonacci is
    signal a : unsigned(63 downto 0) := x"0000000000000000"; -- fib(n-2)
    signal b : unsigned(63 downto 0) := x"0000000000000001"; -- fib(n-1)
    signal temp : unsigned(63 downto 0);
    signal n_int : integer range 0 to 63;
begin
    process(n)
    begin
        n_int := to_integer(unsigned(n));
        
        if n_int = 0 then
            fib_n <= std_logic_vector(a);
        elsif n_int = 1 then
            fib_n <= std_logic_vector(b);
        else
            a <= x"0000000000000000"; -- fib(0)
            b <= x"0000000000000001"; -- fib(1)
            
            for i in 2 to n_int loop
                temp <= a + b;
                a <= b;
                b <= temp;
            end loop;
            
            fib_n <= std_logic_vector(b);
        end if;
    end process;
end Behavioral;