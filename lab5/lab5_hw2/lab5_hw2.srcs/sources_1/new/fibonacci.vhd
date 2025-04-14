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

entity fibonacci_fsm is
    Port (
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        start : in  STD_LOGIC;
        n : in  STD_LOGIC_VECTOR (5 downto 0);
        fib_n : out STD_LOGIC_VECTOR (63 downto 0);
        done : out STD_LOGIC
    );
end fibonacci_fsm;

architecture Behavioral of fibonacci_fsm is
    type state_type is (IDLE, CALC, OK);
    signal state : state_type := IDLE;
    signal a : unsigned(63 downto 0) := (others => '0'); -- fib(n-2)
    signal b : unsigned(63 downto 0) := (others => '0'); -- fib(n-1)
    signal temp : unsigned(63 downto 0); -- Temporary result of the adder
    signal counter : integer := 0;
begin
    -- Adder
    temp <= a + b;

    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            a <= (others => '0');
            b <= (others => '0');
            counter <= 0;
            fib_n <= (others => '0');
            done <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    if start = '1' then
                        a <= (others => '0'); -- fib(0)
                        b <= (others => '0');
                        b(0) <= '1'; -- fib(1)
                        counter <= 2;
                        state <= CALC;
                    end if;
                when CALC =>
                    if counter <= to_integer(unsigned(n)) then
                        a <= b;
                        b <= temp;
                        counter <= counter + 1;
                    else
                        state <= OK;
                    end if;
                when OK =>
                    fib_n <= std_logic_vector(b);
                    done <= '1';
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;