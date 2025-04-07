----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/04/07 17:24:24
-- Design Name: 
-- Module Name: topmodule - Behavioral
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

entity topmodule is
    Port ( CLK : in std_logic;
           AN : out std_logic_vector (7 downto 0);
           SEG : out std_logic_vector (7 downto 0));
end topmodule;

architecture Behavioral of topmodule is

    component frequency_divider is
        Port ( clk : in std_logic;
               count : out std_logic);
    end component frequency_divider;

    component SevenSegDisplay is
        Port ( clk : in  std_logic;
               en_n : in std_logic_vector (7 downto 0);
               dp : in std_logic_vector (7 downto 0);
               number : in  std_logic_vector (31 downto 0);
               seg : out  std_logic_vector (7 downto 0);
               an : out  std_logic_vector (7 downto 0));
    end component SevenSegDisplay;

    component ButtonDebounce is
        Port ( clk : in std_logic;
               btn_in : in std_logic;
               btn_out : out std_logic);
    end component ButtonDebounce;

    component timer is
        Port ( count : in std_logic;
               btnc : in std_logic;
               btnu : in std_logic;
               en : out std_logic_vector (7 downto 0);
               number : out std_logic_vector (31 downto 0));

    signal count : std_logic;
    signal dp : std_logic_vector (7 downto 0) = "11111111";

begin

    freqency_divider port map ( clk => CLK, count => count );


    SevenSegDisplay port map ( clk =>, en_n =>, dp => dp, number =>, seg => SEG, an => AN );


end Behavioral;
