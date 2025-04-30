library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity pipeline_testbench is
end pipeline_testbench;

architecture Behavioral of pipeline_testbench is
    component pipeline_multiplier is
        generic(WIDTH : integer := 5);
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            a     : in  std_logic_vector(4 downto 0);
            b     : in  std_logic_vector(4 downto 0);
            y     : out std_logic_vector(9 downto 0)
        );
    end component;

    constant CLK_PERIOD : time := 10 ns;
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';
    signal a, b  : std_logic_vector(4 downto 0);
    signal y     : std_logic_vector(9 downto 0);
    
    -- Pipeline latency (5 stages)
    constant PIPELINE_DELAY : integer := 5;
    type data_queue is array(0 to PIPELINE_DELAY-1) of std_logic_vector(9 downto 0);
    signal expected_results : data_queue;

begin
    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;

    -- Instantiate DUT
    uut: pipeline_multiplier
        generic map(WIDTH => 5)
        port map(
            clk   => clk,
            reset => reset,
            a     => a,
            b     => b,
            y     => y
        );

    -- Test stimulus
    stimulus: process
        variable test_pass : boolean := true;
        variable line_out : line;
    begin
        -- Initialize system
        reset <= '1';
        wait for CLK_PERIOD*2;
        reset <= '0';
        wait until falling_edge(clk);

        -- ========== Basic Tests ==========
        write(line_out, string'("=== Pipeline Multiplier Test ==="));
        writeline(output, line_out);
        
        -- Test 1: 0 * 0
        push_test_case("00000", "00000", 0);
        
        -- Test 2: 1 * 1
        push_test_case("00001", "00001", 1);
        
        -- Test 3: 31 * 31
        push_test_case("11111", "11111", 961);

        -- ========== Random Tests ==========
        write(line_out, string'("Random testing (20 cases)..."));
        writeline(output, line_out);
        for i in 1 to 20 loop
            push_random_case;
        end loop;

        -- Wait for final results
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        
        -- Final report
        if test_pass then
            write(line_out, string'("All pipeline tests PASSED!"));
        else
            write(line_out, string'("Some pipeline tests FAILED!"));
        end if;
        writeline(output, line_out);
        wait;
    end process;

    -- Result checker process
    checker: process(clk)
        variable expected : std_logic_vector(9 downto 0);
        variable line_out : line;
    begin
        if rising_edge(clk) and reset = '0' then
            expected := expected_results(0);
            expected_results(0 to PIPELINE_DELAY-2) := expected_results(1 to PIPELINE_DELAY-1);
            
            if y /= expected then
                write(line_out, string'("Mismatch at cycle ") & time'image(now) &
                      string'(" Expected: ") & to_hstring(expected) &
                      string'(" Received: ") & to_hstring(y));
                writeline(output, line_out);
                report "Test failed" severity error;
            end if;
        end if;
    end process;

    -- Helper procedures
    procedure push_test_case(
        a_in : std_logic_vector(4 downto 0);
        b_in : std_logic_vector(4 downto 0);
        expected : integer
    ) is
        variable line_out : line;
    begin
        a <= a_in;
        b <= b_in;
        expected_results(PIPELINE_DELAY-1) <= std_logic_vector(to_unsigned(expected, 10));
        wait until rising_edge(clk);
    end procedure;

    procedure push_random_case is
        variable a_val, b_val : std_logic_vector(4 downto 0);
        variable product : integer;
    begin
        a_val := std_logic_vector(to_unsigned(integer(rand(0.0, 31.0)), 5);
        b_val := std_logic_vector(to_unsigned(integer(rand(0.0, 31.0)), 5);
        product := to_integer(unsigned(a_val)) * to_integer(unsigned(b_val));
        
        a <= a_val;
        b <= b_val;
        expected_results(PIPELINE_DELAY-1) <= std_logic_vector(to_unsigned(product, 10));
        wait until rising_edge(clk);
    end procedure;

end Behavioral;