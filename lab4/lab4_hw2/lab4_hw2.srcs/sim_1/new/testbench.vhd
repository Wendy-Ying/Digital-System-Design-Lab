----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2025/03/03 17:43:25
-- Design Name: 
-- Module Name: testbench - tb
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

entity testbench is
end testbench;

architecture tb of testbench is
component sequence_generator is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        dataout : out STD_LOGIC
    );
end component;

signal clk : STD_LOGIC := '0';
signal reset : STD_LOGIC := '0';
signal dataout : STD_LOGIC;
constant period : time := 10 ns;

begin
    uut: sequence_generator port map (
        clk => clk,
        reset => reset,
        dataout => dataout
    );

    clk <= not clk after period / 2;
    
    tb: process is
    begin
        reset <= '1';
        wait for 200 ns;
        reset <= '0';
        wait for 200 ns;
        wait;
    end process;

end tb;