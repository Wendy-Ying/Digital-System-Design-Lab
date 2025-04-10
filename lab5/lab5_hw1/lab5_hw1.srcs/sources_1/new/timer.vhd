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
        btnc : in std_logic;
        btnu : in std_logic;
        number : out std_logic_vector (31 downto 0);
    );
end timer;

architecture Behavioral of timer is

    signal clock_divider : std_logic_vector (26 downto 0) := (others => '0');
    signal count : std_logic := '0';

    signal seconds_reg : std_logic_vector (5 downto 0);  -- 0-59
    signal minutes_reg : std_logic_vector (5 downto 0);  -- 0-59
    signal hours_reg : std_logic_vector (3 downto 0);    -- 0-11
    signal noon_reg : std_logic;                         -- 0=AM, 1=PM

    signal seconds_next : std_logic_vector (5 downto 0) := "000000";
    signal minutes_next : std_logic_vector (5 downto 0) := "000000";
    signal hours_next : std_logic_vector (3 downto 0) := "0000";
    signal noon_next : std_logic := '0';

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

    signal state : integer range 0 to 3 := 0;
    signal blink : std_logic := '0';

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

    -- state detection
    process (btnc)
    begin
        if btnc = '1' then
            state <= state + 1;
        end if;
    end process;

    -- time register
    process (count)
    begin
        if state = 0 then
            if count = '1' then
                seconds_reg <= seconds_next;
                minutes_reg <= minutes_next;
                hours_reg <= hours_next;
                noon_reg <= noon_next;
                count <= '0';
                blink <= '0';
            end if;
        else
            blink <= not blink;
        end if;
    end process;

    -- btnu state machine
    process (clk)
    begin
        if rising_edge(clk) then
            if btnu = '1' then
                case state is
                    when 1 =>  -- set minutes
                        if minutes_reg < 59 then
                            minutes_next <= STD_LOGIC_VECTOR(UNSIGNED(minutes_reg) + 1);
                        else
                            minutes_next <= "000000";
                        end if;
                    when 2 =>  -- set hours
                        if hours_reg < 11 then
                            hours_next <= STD_LOGIC_VECTOR(UNSIGNED(hours_reg) + 1);
                        else
                            hours_next <= "0000";
                        end if;
                    when 3 =>  -- set AM/PM
                        noon_next <= not noon_reg;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    seconds_next <= "000000" when seconds_reg = "111011" else seconds_reg + 1;

    minutes_next <= "000000" when (minutes_reg = "111011" and seconds_reg = "111011") 
                    else minutes_reg + 1 when seconds_reg = "111011" 
                    else minutes_reg;

    hours_next <= "0000" when (hours_reg = "1011" and minutes_reg = "111011" and seconds_reg = "111011")
                  else hours_reg + 1 when (minutes_reg = "111011" and seconds_reg = "111011")
                  else hours_reg;

    noon_next <= not noon_reg when (hours_reg = "1011" and minutes_reg = "111011" and seconds_reg = "111011")
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
    process (state, blink, count)
    begin
        if state = 0 then
            number(31 downto 28) <= "1010" when noon_reg = '0' else "1011";
            number(27 downto 24) <= "1111";
            number(23 downto 20) <= hour_tens;
            number(19 downto 16) <= hour_units;
            number(15 downto 12) <= min_tens;
            number(11 downto 8) <= min_units;
            number(7 downto 4) <= sec_tens;
            number(3 downto 0) <= sec_units;
        else
            case state is
                when 1 =>
                    number(31 downto 28) <= "1010" when noon_reg = '0' else "1011";
                    number(27 downto 24) <= "1111";
                    number(23 downto 20) <= hour_tens;
                    number(19 downto 16) <= hour_units;
                    if blink = '0' then
                        number(15 downto 12) <= min_tens;
                        number(11 downto 8) <= min_units;
                    else
                        number(15 downto 12) <= "1110";
                        number(11 downto 8) <= "1110";
                    end if;
                    number(7 downto 4) <= sec_tens;
                    number(3 downto 0) <= sec_units;
                when 2 =>
                    number(31 downto 28) <= "1010" when noon_reg = '0' else "1011";
                    if blink = '0' then
                        number(23 downto 20) <= hour_tens;
                        number(19 downto 16) <= hour_units;
                    else
                        number(23 downto 20) <= "1110";
                        number(19 downto 16) <= "1110";
                    end if;
                    number(27 downto 24) <= "1111";
                    number(15 downto 12) <= min_tens;
                    number(11 downto 8) <= min_units;
                    number(7 downto 4) <= sec_tens;
                    number(3 downto 0) <= sec_units;
                when 3 =>
                    if blink = '0' then
                        number(31 downto 28) <= "1010" when noon_reg = '0' else "1011";
                        number(27 downto 24) <= "1111";
                    else
                        number(27 downto 24) <= "1110";
                        number(31 downto 28) <= "1110";
                    end if;
                    number(23 downto 20) <= hour_tens;
                    number(19 downto 16) <= hour_units;
                    number(15 downto 12) <= min_tens;
                    number(11 downto 8) <= min_units;
                    number(7 downto 4) <= sec_tens;
                    number(3 downto 0) <= sec_units;
                when others =>
                    number <= (others => '0');
            end case;
        end if;
    end process;

end Behavioral;