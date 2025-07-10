library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.all;

entity freq_div_tb is
end freq_div_tb;

architecture tb_architecture of freq_div_tb is
	
	constant clk_period : time := 125 ns;	--system clock period
	constant number_of_clocks : integer := 256;	--number of clocks
	
	-- Stimulus signals
	signal clk : STD_LOGIC := '0';		--system clock
	signal rst_bar : STD_LOGIC;		--synchronous reset		
	signal divisor : STD_LOGIC_VECTOR(3 downto 0) := "0100";	-- divisor value
	-- Observed signals
	signal clk_dvd : STD_LOGIC;		--divisor output value
	
	signal clocks : integer := 0;		--count of clock positive edges		
	signal END_SIM : boolean := false;	--boolean to stop sys. clock
	
begin	
	-- Unit Under Test port map
	UUT : entity freq_div		
	port map (
		clk => clk,
		rst_bar => rst_bar,
		divisor => divisor,
		clk_dvd => clk_dvd
		);
	
	-- System Clock Process
	clock_gen : process		--system clock generating process
	begin
		clk <= '0';
		wait for clk_period/2;
		loop	-- inifinite loop
			clk <= not clk;
			wait for clk_period/2;
			exit when END_SIM = true; --stop clk when END_SIM is true
		end loop;
		std.env.finish;		--stop simulation
	end process;
	
	-- Reset Signal
	rst_bar <= '0', '1' after 2.5 * clk_period; --reset for 2.5 clocks
	
	--Clocks limit
	clocks_limit: process (clk)	--controls how many clocks in sim.
	begin	
		if rising_edge(clk) then
			clocks <= clocks + 1;
		end if;
		
		if (clocks > number_of_clocks)
			then
			END_SIM <= true;	--stop system clock
		end if;
	end process;	
end tb_architecture;
