library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity repetitve_addtion is
    port (
        CLK, RESET, start : in  std_logic;
        a_in, b_in        : in  std_logic_vector(7 downto 0);
        r                 : out std_logic_vector(15 downto 0);
        ready             : out std_logic
    );
end entity repetitve_addtion;

architecture Behavioral of repetitve_addtion is
    constant WIDTH : integer := 8;
    type state_type is (idle, ab0, load, op);
    signal state_reg, state_next : state_type;
    signal a_reg, a_next, n_reg, n_next : std_logic_vector(WIDTH-1 downto 0);
    signal r_reg, r_next : std_logic_vector(2*WIDTH-1 downto 0);
begin

    -- state and data registers
    process (CLK, RESET) is
    begin
        if RESET = '1' then
            state_reg <= idle;
            a_reg     <= "00000000";
            n_reg     <= "00000000";
            r_reg     <= x"0000";
        elsif CLK'event and CLK = '1' then
            state_reg <= state_next;
            a_reg     <= a_next;
            n_reg     <= n_next;
            r_reg     <= r_next;
        end if;
    end process;

    -- combinational circuit
    process (start, state_reg, a_reg, n_reg, r_reg, a_in, b_in) is
    begin
        -- default value
        a_next  <= a_reg;
        n_next  <= n_reg;
        r_next  <= r_reg;
        ready   <= '0';
        case state_reg is
            when idle =>
                if start = '1' then
                    if (a_in = "00000000" or b_in = "00000000") then
                        state_next <= ab0;
                    else
                        state_next <= load;
                    end if;
                else
                    state_next <= idle;
                end if;
                ready <= '1';
            when ab0 =>
                a_next   <= a_in;
                n_next   <= b_in;
                r_next   <= x"0000";
                state_next <= idle;
            when load =>
                a_next   <= a_in;
                n_next   <= b_in;
                r_next   <= x"0000";
                state_next <= op;
            when op =>
                n_next   <= n_reg - 1;
                r_next   <= ("00000000" & a_reg) + r_reg;
                if (n_reg = "00000001") then
                    state_next <= idle;
                else
                    state_next <= op;
                end if;
        end case;
    end process;

    r <= r_reg;

end architecture Behavioral;