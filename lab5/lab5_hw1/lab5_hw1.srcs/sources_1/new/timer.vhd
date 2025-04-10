----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/07 18:01:59
-- Design Name: 
-- Module Name: timer - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port ( 
        clk : in std_logic;
        number : out std_logic_vector (31 downto 0)
    );
end timer;

architecture Behavioral of timer is

    signal clock_divider : std_logic_vector (26 downto 0) := (others => '0');
    signal count : std_logic := '0';

    signal seconds_reg : std_logic_vector (5 downto 0);  -- 0-59
    signal minutes_reg : std_logic_vector (5 downto 0);  -- 0-59
    signal hours_reg : std_logic_vector (3 downto 0);    -- 0-11
    signal noon_reg : std_logic;                         -- 0=AM, 1=PM

    signal seconds_next : std_logic_vector (5 downto 0);
    signal minutes_next : std_logic_vector (5 downto 0);
    signal hours_next : std_logic_vector (3 downto 0);
    signal noon_next : std_logic;

    signal sec_tens : std_logic_vector(3 downto 0);  -- s (0-5)
    signal sec_units : std_logic_vector(3 downto 0);  -- s (0-9)
    signal min_tens : std_logic_vector(3 downto 0);  -- m (0-5)
    signal min_units : std_logic_vector(3 downto 0);  -- m (0-9)
    signal hour_tens : std_logic_vector(3 downto 0);  -- h (0-1)
    signal hour_units : std_logic_vector(3 downto 0);  -- h (0-9)

    signal temp_s : integer range 0 to 59;
    signal tens_value_s : integer range 0 to 5;
    signal units_value_s : integer range 0 to 9;
    signal temp_m : integer range 0 to 59;
    signal tens_value_m : integer range 0 to 5;
    signal units_value_m : integer range 0 to 9;

begin

    -- clock divider
    process (clk)
    begin
        if rising_edge(clk) then
            if clock_divider = "101111101011110000011111111" then
                clock_divider <= (others => '0');
                count <= '1';
            else
                clock_divider <= clock_divider + 1;
            end if;
        end if;
    end process;

    -- time register
    process (count)
    begin
        if count = '1' then
            seconds_reg <= seconds_next;
            minutes_reg <= minutes_next;
            hours_reg <= hours_next;
            noon_reg <= noon_next;
            count <= '0';
        end if;
    end process;

    seconds_next <= "000000" when seconds_reg = "111100" else seconds_reg + 1;

    minutes_next <= "000000" when (minutes_reg = "111100" and seconds_reg = "111100") 
                    else minutes_reg + 1 when seconds_reg = "111100" 
                    else minutes_reg;

    hours_next <= "0000" when (hours_reg = "1100" and minutes_reg = "111100" and seconds_reg = "111100")
                  else hours_reg + 1 when (minutes_reg = "111100" and seconds_reg = "111100")
                  else hours_reg;

    noon_next <= not noon_reg when (hours_reg = "1100" and minutes_reg = "111100" and seconds_reg = "111100")
                 else noon_reg;

    -- separate time units
    temp_s <= TO_INTEGER(UNSIGNED(seconds_reg));
    tens_value_s <= temp_s / 10;
    units_value_s <= temp_s mod 10;
    sec_tens <= STD_LOGIC_VECTOR(TO_UNSIGNED(tens_value_s, 4));
    sec_units <= STD_LOGIC_VECTOR(TO_UNSIGNED(units_value_s, 4));
    
    temp_m <= TO_INTEGER(UNSIGNED(minutes_reg));
    tens_value_m <= temp_m / 10;
    units_value_m <= temp_m mod 10;
    min_tens <= STD_LOGIC_VECTOR(TO_UNSIGNED(tens_value_m, 4));
    min_units <= STD_LOGIC_VECTOR(TO_UNSIGNED(units_value_m, 4));
    
    hour_tens <= "00" & hours_reg(1) & "0" when hours_reg(3) = '1' else "0000";
    hour_units <= "000" & hours_reg(0) when hours_reg(3 downto 1) = "101" else hours_reg;

    -- output
    number(31 downto 28) <= "1010" when noon_reg = '0' else "1011";
    number(27 downto 24) <= "1111";
    number(23 downto 20) <= hour_tens;
    number(19 downto 16) <= hour_units;
    number(15 downto 12) <= min_tens;
    number(11 downto 8) <= min_units;
    number(7 downto 4) <= sec_tens;
    number(3 downto 0) <= sec_units;

end Behavioral;