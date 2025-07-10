library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity binary_cntr is
    generic (n : integer := 16); 						-- generic to countrol width of counter 
    port (
        clk     : in std_logic;                             -- system clock
        cnten1  : in std_logic;                             -- active high count enable 1
        cnten2  : in std_logic;                             -- active high count enable 2
        up      : in std_logic;                             -- count direction (up = '1', down = '0')
        clr_bar : in std_logic;                             -- synchronous clear (active low)
        rst_bar : in std_logic;                             -- synchronous reset (active low)
        q       : out std_logic_vector (n-1 downto 0);      -- output count
        max_cnt : out std_logic                             -- maximum count indication
    );
end binary_cntr;

architecture behavioral of binary_cntr is
    signal count : unsigned(n-1 downto 0) := (others => '0');
begin
    process (all)
    begin
        if rising_edge(clk) then
            if rst_bar = '0' then
                count <= (others => '0');                   -- reset counter
            elsif clr_bar = '0' then
                count <= (others => '0');                   -- clear counter
            elsif (cnten1 = '1' and cnten2 = '1') then      -- counting enabled only if both enables are high
                if up = '1' then
                    count <= count + 1;
                else
                    count <= count - 1;
                end if;
            end if;
        end if;
    end process;

    q <= std_logic_vector(count);                           	 	-- output assignment

   max_cnt <= '1' when count = to_unsigned(2**n - 1, n) else '0';	--maximum count detection

end behavioral;
