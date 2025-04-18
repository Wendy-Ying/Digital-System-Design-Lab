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
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port ( 
        clk : in std_logic;
        btnc : in std_logic;
        btnu : in std_logic;
        number : out std_logic_vector (31 downto 0)
    );
end timer;

architecture Behavioral of timer is

    signal clock_divider : integer range 0 to 99999999 := 0;
    signal count : std_logic := '0';

    signal seconds_reg : integer range 0 to 59 := 0;  -- 0-59
    signal minutes_reg : integer range 0 to 59 := 0;  -- 0-59
    signal hours_reg : integer range 0 to 11 := 0;    -- 0-11
    signal noon_reg : std_logic := '0';               -- 0=AM, 1=PM

    signal seconds_next : integer range 0 to 59 := 0;
    signal minutes_next : integer range 0 to 59 := 0;
    signal hours_next : integer range 0 to 11 := 0;
    signal noon_next : std_logic := '0';

    signal seconds_add : integer range 0 to 59 := 0;
    signal minutes_add : integer range 0 to 59 := 0;
    signal hours_add : integer range 0 to 11 := 0;
    signal noon_add : std_logic := '0';

    signal sec_tens : integer range 0 to 5 := 0;  -- s (0-5)
    signal sec_units : integer range 0 to 9 := 0; -- s (0-9)
    signal min_tens : integer range 0 to 5 := 0;  -- m (0-5)
    signal min_units : integer range 0 to 9 := 0; -- m (0-9)
    signal hour_tens : integer range 0 to 1 := 0; -- h (0-1)
    signal hour_units : integer range 0 to 9 := 0; -- h (0-9)
    signal noon_tens : std_logic_vector (3 downto 0); -- A/P

    signal state : integer range 0 to 3 := 0;
    signal blink_m : std_logic := '0';
    signal blink_h : std_logic := '0';
    signal blink_a : std_logic := '0';

begin

    -- clock divider
    process (clk)
    begin
        if rising_edge(clk) then
            if clock_divider = 99999999 then
                clock_divider <= 0;
                if state = 0 then
                    seconds_reg <= seconds_next;
                    minutes_reg <= minutes_next;
                    hours_reg <= hours_next;
                    noon_reg <= noon_next;
                    blink_m <= '0';
                    blink_h <= '0';
                    blink_a <= '0';
                elsif state = 1 then
                    minutes_reg <= minutes_add;
                    blink_m <= not blink_m;
                    blink_h <= '0';
                    blink_a <= '0';
                elsif state = 2 then
                    hours_reg <= hours_add;
                    blink_h <= not blink_h;
                    blink_m <= '0';
                    blink_a <= '0';
                elsif state = 3 then
                    noon_reg <= noon_add;
                    blink_a <= not blink_a;
                    blink_m <= '0';
                    blink_h <= '0';
                end if;
            else
                clock_divider <= clock_divider + 1;
                if state = 1 then
                    minutes_reg <= minutes_add;
                elsif state = 2 then
                    hours_reg <= hours_add;
                elsif state = 3 then
                    noon_reg <= noon_add;
                end if;
            end if;
        end if;
    end process;

    -- state detection
    process (btnc)
    begin
        if rising_edge(btnc) then
            if state < 3 then
                state <= state + 1;
            else
                state <= 0;
            end if;
        end if;
    end process;

    -- button detection
    process (btnu)
    begin
        if rising_edge(btnu) then
            if state = 1 then
                if minutes_reg = 59 then
                    minutes_add <= 0;
                else
                    minutes_add <= minutes_reg + 1;
                end if;
            elsif state = 2 then
                if hours_reg = 11 then
                    hours_add <= 0;
                else
                    hours_add <= hours_reg + 1;
                end if;
            elsif state = 3 then
                noon_add <= not noon_reg;
            end if;
        end if;
    end process;

    seconds_next <= 0 when seconds_reg = 59 else seconds_reg + 1;

    minutes_next <= 0 when (minutes_reg = 59 and seconds_reg = 59) 
                    else minutes_reg + 1 when seconds_reg = 59 
                    else minutes_reg;

    hours_next <= 0 when (hours_reg = 11 and minutes_reg = 59 and seconds_reg = 59)
                  else hours_reg + 1 when (minutes_reg = 59 and seconds_reg = 59)
                  else hours_reg;

    noon_next <= not noon_reg when (hours_reg = 11 and minutes_reg = 59 and seconds_reg = 59)
                 else noon_reg;

    -- separate time units
    sec_tens <= seconds_reg / 10;
    sec_units <= seconds_reg mod 10;
    
    min_tens <= minutes_reg / 10;
    min_units <= minutes_reg mod 10;
    
    hour_tens <= hours_reg / 10;
    hour_units <= hours_reg mod 10;

    noon_tens <= "1010" when noon_reg = '0' else "1100";

    -- output
    number(31 downto 28) <= noon_tens when blink_a = '0' else "1111";
    number(27 downto 24) <= "1011" when blink_a = '0' else "1111";
    number(23 downto 20) <= std_logic_vector(to_unsigned(hour_tens, 4)) when blink_h = '0' else "1111";
    number(19 downto 16) <= std_logic_vector(to_unsigned(hour_units, 4)) when blink_h = '0' else "1111";
    number(15 downto 12) <= std_logic_vector(to_unsigned(min_tens, 4)) when blink_m = '0' else "1111";
    number(11 downto 8) <= std_logic_vector(to_unsigned(min_units, 4)) when blink_m = '0' else "1111";
    number(7 downto 4) <= std_logic_vector(to_unsigned(sec_tens, 4));
    number(3 downto 0) <= std_logic_vector(to_unsigned(sec_units, 4));
    
end Behavioral;