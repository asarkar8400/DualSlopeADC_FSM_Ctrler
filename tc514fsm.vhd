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
                if max_cnt = '1' then
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
                if cmptr = '0' and clk_dvd = '1' then
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
