library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity out_reg is
    generic (n : integer := 16);  -- width of register
    port (
        clk     : in std_logic;                              -- system clock
        enable  : in std_logic;                              -- parallel load enable
        rst_bar : in std_logic;                              -- synchronous reset (active low)
        d       : in std_logic_vector(n-1 downto 0);         -- data in
        q       : out std_logic_vector(n-1 downto 0)         -- data out
    );
end out_reg;

architecture behavioral of out_reg is
    signal reg : std_logic_vector(n-1 downto 0) := (others => '0'); -- internal register
begin
    process (all)
    begin
        if rising_edge(clk) then
            if rst_bar = '0' then
                reg <= (others => '0');   --synchronous reset
            elsif enable = '1' then
                reg <= d;                 --load input data
            end if;
        end if;
    end process;

    q <= reg;  							              --q gets loaded input data	
	
end behavioral;
