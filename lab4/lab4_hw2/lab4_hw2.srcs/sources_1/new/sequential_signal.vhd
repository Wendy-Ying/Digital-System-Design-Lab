----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/03/17 16:52:23
-- Design Name: 
-- Module Name: sequential_signal - concurrent_arcg
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

entity sequence_generator is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        dataout : out STD_LOGIC
    );
end sequence_generator;

architecture Behavioral of sequence_generator is
    signal current_state : integer range 0 to 7 := 0;
    signal next_state : integer range 0 to 7;
begin
    -- accident
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= 0;
        elsif CLK'event and CLK = '1' then
            current_state <= next_state;
        end if;
    end process;

    -- state transfer
    process(current_state)
    begin
        case current_state is
            when 0 =>
                dataout <= '1';
                next_state <= 1;
            when 1 =>
                dataout <= '1';
                next_state <= 2;
            when 2 =>
                dataout <= '0';
                next_state <= 3;
            when 3 =>
                dataout <= '1';
                next_state <= 4;
            when 4 =>
                dataout <= '1';
                next_state <= 5;
            when 5 =>
                dataout <= '1';
                next_state <= 6;
            when 6 =>
                dataout <= '0';
                next_state <= 7;
            when 7 =>
                dataout <= '0';
                next_state <= 0;
            when others =>
                dataout <= '0';
                next_state <= 0;
        end case;
    end process;
end Behavioral;