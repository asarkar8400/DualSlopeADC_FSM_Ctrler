library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use work.all;

entity binary_cntr_tb is
	-- Generic declarations of the tested unit
		generic(
		n : integer := 16 );
end binary_cntr_tb;

architecture tb_architecture of binary_cntr_tb is
	-- Stimulus signals
	signal clk : std_logic := '0';
	signal cnten1 : std_logic := '0';
	signal cnten2 : std_logic := '0';
	signal up : std_logic := '1';
	signal clr_bar : std_logic := '1';
	signal rst_bar : std_logic := '0';
	-- Observed signals
	signal q : std_logic_vector(n-1 downto 0);
	signal max_cnt : std_logic;
	
	constant clk_period : time := 125 ns;
	signal END_SIM : boolean := false;
	
begin
	-- Unit Under Test port map
	UUT : entity binary_cntr
		generic map (
			n => n
		)
		port map (
			clk => clk,
			cnten1 => cnten1,
			cnten2 => cnten2,
			up => up,
			clr_bar => clr_bar,
			rst_bar => rst_bar,
			q => q,
			max_cnt => max_cnt
		);

	-- System Clock Process
	clock_gen : process
	begin
		clk <= '0';
		wait for clk_period/2;
		loop	-- inifinite loop
			clk <= not clk;
			wait for clk_period/2;
			exit when END_SIM = true;
		end loop;
		std.env.finish;
	end process;
	
	-- Reset Signal
	rst_bar <= '0', '1' after 2.5 * clk_period;
	
	-- Simulation control process
	sim_cntrl: process
	begin
		cnten1 <= '1' after 5 * clk_period, '0' after (2**(n + 1) + 10) * clk_period;
		cnten2 <= '1' after 10 * clk_period, '0' after (2**(n + 1) + 10) * clk_period;
		wait for (2**(n + 1) + 10) * clk_period; 
		std.env.finish;		-- done
	end process;		

end tb_architecture;
