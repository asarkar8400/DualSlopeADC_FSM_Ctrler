library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity tc514cntrl is
    generic (n : integer := 16);
    port (
        soc : in std_logic;          				-- start of conversion
        rst_bar : in std_logic;       				-- synchronous reset
        clk : in std_logic;           				-- system clock
        cmptr : in std_logic;         				-- comparator output from TC514
        a : out std_logic;            				-- phase control A
        b : out std_logic;            				-- phase control B
        dout : out std_logic_vector(n-1 downto 0); 	-- digital conversion result
        busy_bar : out std_logic      				-- converter busy flag
    );
end tc514cntrl;

architecture structure of tc514cntrl is
    signal clk_dvd : std_logic;
    signal q_cntr : std_logic_vector(n-1 downto 0);
    signal max_cnt : std_logic;
    signal cnt_en : std_logic;
    signal clr_cntr_bar : std_logic;
    signal load_result : std_logic;

begin

    --Frequency Divider
    u0: entity work.freq_div
        port map (
            clk => clk,
            rst_bar => rst_bar,
            divisor => "0100",        
            clk_dvd => clk_dvd
        );

    --Binary Counter
    u1: entity work.binary_cntr
        generic map (n => n)
        port map (
            clk => clk_dvd,             
            cnten1 => cnt_en,
            cnten2 => '1',              
            up => '1',                 
            clr_bar => clr_cntr_bar,
            rst_bar => rst_bar,
            q => q_cntr,
            max_cnt => max_cnt
        );

    --FSM Controller
    u2: entity work.TC514fsm
        port map (
            soc => soc,
            cmptr => cmptr,
            max_cnt => max_cnt,
            clk => clk,
            clk_dvd => clk_dvd,
            rst_bar => rst_bar,
            a => a,
            b => b,
            busy_bar => busy_bar,
            cnt_en => cnt_en,
            clr_cntr_bar => clr_cntr_bar,
            load_result => load_result
        );

    --Output Register
    u3: entity work.out_reg
        generic map (n => n)
        port map (
            clk => clk,
            enable => load_result,      
            rst_bar => rst_bar,
            d => q_cntr,
            q => dout
        );
		
end structure;
