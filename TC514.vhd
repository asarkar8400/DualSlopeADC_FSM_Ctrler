library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	
use work.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;  
use work.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity tc514fsm is
    port (
        soc           : in  std_logic;  -- start conversion control input
        cmptr         : in  std_logic;  -- comparator status input from TC514
        max_cnt       : in  std_logic;  -- counter max count indication
        clk           : in  std_logic;  -- system clock
        clk_dvd       : in  std_logic;  -- divided clock input
        rst_bar       : in  std_logic;  -- active-low synchronous reset
        a             : out std_logic;  -- phase control A
        b             : out std_logic;  -- phase control B
        busy_bar      : out std_logic;  -- active-low busy signal
        cnt_en        : out std_logic;  -- counter enable signal
        clr_cntr_bar  : out std_logic;  -- counter clear signal (active low)
        load_result   : out std_logic   -- result latch enable
    );
end tc514fsm;

architecture FSM of tc514fsm is

    type state is (
        AUTOZERO,
        IDLE,
        INTEGRATE,
        DEINTEGRATE,
        INTEGRATOR_ZERO,
        CLEAR_CNTR
    );

    signal present_state, next_state : state;

begin

    --state register
    state_reg : process (clk)
    begin
        if rising_edge(clk) then
            if rst_bar = '0' then
                present_state <= AUTOZERO;
            else
                present_state <= next_state;
            end if;
        end if;
    end process;

    --outputs process
    outputs : process (present_state)
    begin
        --default outputs
        a             <= '0';
        b             <= '0';
        cnt_en        <= '0';
        clr_cntr_bar  <= '1';
        load_result   <= '0';
        busy_bar      <= '1';

        case present_state is
            when AUTOZERO =>
                a             <= '0';
                b             <= '1';
                cnt_en        <= '1';
                clr_cntr_bar  <= '1';
                busy_bar      <= '0';

            when IDLE =>
                a             <= '0';
                b             <= '1';
                cnt_en        <= '0';
                clr_cntr_bar  <= '0';
                busy_bar      <= '1';

            when INTEGRATE =>
                a             <= '1';
                b             <= '0';
                cnt_en        <= '1';
                clr_cntr_bar  <= '1';
                busy_bar      <= '0';

            when DEINTEGRATE =>
                a             <= '1';
                b             <= '1';
                cnt_en        <= '1';
                clr_cntr_bar  <= '1';
                busy_bar      <= '0';

            when INTEGRATOR_ZERO =>
                a             <= '0';
                b             <= '0';
                cnt_en        <= '0';
                clr_cntr_bar  <= '1';
                load_result   <= '1';
                busy_bar      <= '0';

            when CLEAR_CNTR =>
                a             <= '0';
                b             <= '0';
                cnt_en        <= '0';
                clr_cntr_bar  <= '0';
                busy_bar      <= '0';
        end case;
    end process;

    --next state process
    nxt_state : process (present_state, max_cnt, clk_dvd, soc, cmptr)
    begin
        case present_state is

            when AUTOZERO =>
                if max_cnt = '1' and clk_dvd = '1' then
                    next_state <= IDLE;
                else
                    next_state <= AUTOZERO;
                end if;

            when IDLE =>
                if soc = '1' then
                    next_state <= INTEGRATE;
                else
                    next_state <= IDLE;
                end if;

            when INTEGRATE =>
                if max_cnt = '1' and clk_dvd = '1' then
                    next_state <= DEINTEGRATE;
                else
                    next_state <= INTEGRATE;
                end if;

            when DEINTEGRATE =>
                if cmptr = '0' then
                    next_state <= INTEGRATOR_ZERO;
                else
                    next_state <= DEINTEGRATE;
                end if;

            when INTEGRATOR_ZERO =>
                if cmptr = '1' then
                    next_state <= CLEAR_CNTR;
                else
                    next_state <= INTEGRATOR_ZERO;
                end if;

            when CLEAR_CNTR =>
                next_state <= AUTOZERO;

            when others =>
                next_state <= AUTOZERO;

        end case;
    end process;
end FSM;

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
	attribute loc             : string;
	attribute loc of soc      : signal is "A13";
	attribute loc of rst_bar  : signal is "F8";
	attribute loc of clk      : signal is "C12";
	attribute loc of cmptr    : signal is "F5";
	attribute loc of a        : signal is "E3";
	attribute loc of b        : signal is "B1";
	attribute loc of dout     : signal is "F3,D3,G3,C2,D1,E1,F1,G1,H1,H3,J2,J1,L5,L1,M1,N3";
	attribute loc of busy_bar : signal is "E10";
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
