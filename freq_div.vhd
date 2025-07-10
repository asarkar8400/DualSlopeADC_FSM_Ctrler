library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_div is
	port (
		clk: in std_logic; -- clock
		rst_bar: in std_logic; -- synchronous reset
		divisor: in std_logic_vector(3 downto 0); -- divisor
		clk_dvd: out std_logic
		); -- output
end freq_div;

architecture behavioral of freq_div is
signal counter : unsigned(3 downto 0) := (others => '0');
signal clk_out : std_logic := '0';
begin 
	process(all) 
	begin
		if rising_edge(clk) then
			if rst_bar = '0' then
				counter <= (others => '0');
				clk_out <= '0';
			else
				if counter = unsigned(divisor) - 1 then
					counter <= (others => '0');
					clk_out <= '1';
				else
					counter <= counter + 1;
					clk_out <= '0';
				end if;
			end if;
		end if;
	end process;
	
	clk_dvd <= clk_out;
	
end behavioral;
