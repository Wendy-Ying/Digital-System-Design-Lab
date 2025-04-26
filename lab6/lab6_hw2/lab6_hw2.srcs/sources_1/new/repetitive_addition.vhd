----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/26 17:19:20
-- Design Name: 
-- Module Name: repetitive_addition - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity repetitive_addition is
    port(
        CLK, RESET, start: in std_logic;  -- Clock, reset, and start signals
        a_in, b_in: in std_logic_vector(7 downto 0);  -- Two 8-bit binary inputs
        ready: out std_logic;  -- Signal indicating the completion of the operation
        r: out std_logic_vector(15 downto 0)  -- 16-bit output result
    );
end entity repetitive_addition;

architecture Behavioral of repetitive_addition is

    constant WIDTH: integer := 8;  -- Define the width as 8 bits
    type state_type is (idle, ab0, load, op1, op2);  -- Define the state types
    signal state_reg, state_next: state_type;  -- Current state and next state signals
    signal a_reg, a_next, n_reg, n_next: std_logic_vector(WIDTH-1 downto 0);  -- Register signals
    signal r_reg, r_next: std_logic_vector(2*WIDTH-1 downto 0);  -- Result register signals
    signal adder_scr1, adder_scr2: std_logic_vector(2*WIDTH-1 downto 0);  -- Adder input signals
    signal adder_out: std_logic_vector(2*WIDTH-1 downto 0);  -- Adder output signal

begin
    -- State and data registers
    process(CLK, RESET) is
    begin
        -- Initialize states and registers when reset is active
        if RESET = '1' then
            state_reg <= idle;
            a_reg <= "00000000";
            n_reg <= "00000000";
            r_reg <= "0000";
        elsif CLK'event and CLK = '1' then  -- Update states and registers on the rising edge of the clock
            state_reg <= state_next;
            a_reg <= a_next;
            n_reg <= n_next;
            r_reg <= r_next;
        end if;
    end process;

    -- Next-state, logic/output logic, and data path routing
    process(start, state_reg, a_reg, n_reg, r_reg, a_in, b_in, adder_out) is
    begin
        -- Default values
        a_next <= a_reg;
        n_next <= n_reg;
        r_next <= r_reg;
        ready <= '0';
        -- Determine the next state based on the current state
        case state_reg is
            when idle =>
                if start = '1' then
                    if (a_in = "00000000" or b_in = "00000000") then
                        state_next <= ab0;
                        r_next <= "0000";
                    else
                        state_next <= load;
                    end if;
                else
                    state_next <= idle;
                end if;
                ready <= '1';
            when ab0 =>
                a_next <= a_in;
                n_next <= b_in;
                r_next <= "00000";
                state_next <= idle;
            when load =>
                a_next <= a_in;
                n_next <= b_in;
                r_next <= "00000";
                state_next <= op1;
            when op1 =>
                if (n_reg = adder_out(WIDTH-1 downto 0)) then
                    state_next <= idle;
                else
                    state_next <= op1;
                end if;
            when op2 =>
                if (n_reg = adder_out(WIDTH-1 downto 0)) then
                    state_next <= idle;
                else
                    state_next <= op1;
                end if;
        end case;
    end process;

    -- Datapath input routing and functional units
    process(state_reg, r_reg, a_reg, n_reg) is
    begin
        if (state_reg = op1) then
            adder_scr1 <= r_reg;
            adder_scr2 <= "00000000" & a_reg;
        else -- for op2 state
            adder_scr1 <= "00000000" & n_reg;
            adder_scr2 <= x"FFFF";
        end if;
    end process;
    adder_out <= adder_scr1 + adder_scr2;  -- Calculate the adder output

    -- Output the result
    r <= r_reg;
end architecture Behavioral;