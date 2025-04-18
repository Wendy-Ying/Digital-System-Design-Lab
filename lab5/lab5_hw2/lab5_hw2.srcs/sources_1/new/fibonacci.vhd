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
        clk : in  STD_LOGIC; -- state transfer
        rst : in  STD_LOGIC; -- reset signal
        start : in STD_LOGIC; -- start computing
        n : in  STD_LOGIC_VECTOR (5 downto 0); -- input
        fib_n : out STD_LOGIC_VECTOR (63 downto 0); -- output
        finish : out STD_LOGIC -- judge ok, for testbench to automatically run
    );
end fibonacci_fsm;

architecture Behavioral of fibonacci_fsm is
    type state_type is (IDLE, CALC, DONE);
    signal state : state_type := IDLE;
    signal prev : unsigned(63 downto 0) := (others => '0'); -- fib(n-2)
    signal current : unsigned(63 downto 0) := (others => '0'); -- fib(n-1)
    signal counter : integer := 0; -- count
    signal n_int : integer := 0; -- convert n to integer for comparison
begin
    n_int <= to_integer(unsigned(n));
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset state machine
            state <= IDLE;
            prev <= (others => '0');
            current <= (others => '0');
            counter <= 0;
            fib_n <= (others => '0');
            finish <= '0';
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    -- start computing
                    if start = '1' then
                        finish <= '0'; -- reset finish signal
                        prev <= (others => '0');
                        if n_int = 0 then
                            current <= (others => '0');
                            counter <= 0;
                        else
                            current <= (0 => '1', others => '0'); -- 1
                            counter <= 1;
                        end if;
                        state <= CALC;
                    end if;
                when CALC =>
                    if counter < n_int then
                        -- calculate fib(n)
                        prev <= current;
                        current <= current + prev;
                        counter <= counter + 1;
                    else
                        state <= DONE;
                    end if;
                when DONE =>
                    -- output result
                    fib_n <= std_logic_vector(current);
                    finish <= '1';
                    state <= IDLE;
            end case;
        end if;
    end process;
end Behavioral;