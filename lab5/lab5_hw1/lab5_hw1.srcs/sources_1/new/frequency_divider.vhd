----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/07 17:41:12
-- Design Name: 
-- Module Name: frequency_divider - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity frequency_divider is
    Port ( clk : in std_logic;
           count : out std_logic);
end frequency_divider;

architecture Behavioral of frequency_divider is

    signal clock_divider : std_logic_vector (26 downto 0) := (others => '0');

begin

    -- clock register
    process (clk) is
    begin
        if clk'event and clk='1' then
            if clock_divider = "101111101011110000011111111" then
                clock_divider <= (others => '0');
                count <= count + '1';
            else
                clock_divider <= clock_divider + 1;
            end if;
        end if;
    end process;

end Behavioral;
