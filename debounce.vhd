--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- debouncer
-- attempt 1
-- last edited 8/20/26
--=============================================================

--=============================================================
-- explanation
--=============================================================
-- cleans up a noisy button input and outputs a single clock pulse per press
--=============================================================

--=============================================================
-- library declarations
--=============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--=============================================================
-- entity declarations
--=============================================================
entity debouncer is
    generic (
        STABLE_CYCLES : integer := 250000
    );
    port (
        clk : in std_logic; -- from top level
        reset_port : in std_logic;
        start_stop_port : in std_logic;
        btn_left_port : in std_logic;
        btn_right_port : in std_logic;
        btn_up_port : in std_logic;
        btn_down_port : in std_logic;
        btn_center_port : in std_logic;
        sw6 : in std_logic;
        sw6_db : out std_logic;
        reset_db : out std_logic; -- debounced reset
        start_stop_db : out std_logic; -- debounced start/stop
        left_db : out std_logic; -- debounced left
        right_db : out std_logic; -- debounced right
        up_db : out std_logic; -- debounced up
        down_db : out std_logic; -- debounced down
        center_db : out std_logic; -- debounced center
        left_mp : out std_logic; -- left monopulse
        right_mp : out std_logic; -- right monopulse
        up_mp : out std_logic; -- up monopulse
        down_mp : out std_logic; -- down monopulse
        center_mp : out std_logic -- center monopulse

    );
end entity debouncer;

--=============================================================
-- architecture
--=============================================================
architecture rtl of debouncer is
    -- signals
    signal reset_sync_0 : std_logic := '0';
    signal reset_sync_1 : std_logic := '0';

    signal start_stop_sync_0 : std_logic := '0';
    signal start_stop_sync_1 : std_logic := '0';

    signal left_sync_0 : std_logic := '0';
    signal left_sync_1 : std_logic := '0';

    signal right_sync_0 : std_logic := '0';
    signal right_sync_1 : std_logic := '0';

    signal up_sync_0 : std_logic := '0';
    signal up_sync_1 : std_logic := '0';

    signal down_sync_0 : std_logic := '0';
    signal down_sync_1 : std_logic := '0';

    signal center_sync_0 : std_logic := '0';
    signal center_sync_1 : std_logic := '0';

    signal sw6_sync_0 : std_logic := '0';
    signal sw6_sync_1 : std_logic := '0';

    -- debounced values
    signal reset_stable : std_logic := '0';
    signal start_stop_stable : std_logic := '0';
    signal left_stable : std_logic := '0';
    signal right_stable : std_logic := '0';
    signal up_stable : std_logic := '0';
    signal down_stable : std_logic := '0';
    signal center_stable : std_logic := '0';
    signal sw6_stable : std_logic := '0';

    -- previous debounced values
    signal left_previous : std_logic := '0';
    signal right_previous : std_logic := '0';
    signal up_previous : std_logic := '0';
    signal down_previous : std_logic := '0';
    signal center_previous : std_logic := '0';
    signal sw6_previous : std_logic := '0';

    -- debounce counters
    signal reset_count : integer range 0 to STABLE_CYCLES := 0;
    signal start_stop_count : integer range 0 to STABLE_CYCLES := 0;

    signal left_count : integer range 0 to STABLE_CYCLES := 0;
    signal right_count : integer range 0 to STABLE_CYCLES := 0;
    signal up_count : integer range 0 to STABLE_CYCLES := 0;
    signal down_count : integer range 0 to STABLE_CYCLES := 0;
    signal center_count : integer range 0 to STABLE_CYCLES := 0;
    signal sw6_count : integer range 0 to STABLE_CYCLES := 0;

begin
    -- synchronizer
    synchronize : process (clk)
    begin
        if rising_edge(clk) then

            reset_sync_0 <= reset_port;
            reset_sync_1 <= reset_sync_0;

            start_stop_sync_0 <= start_stop_port;
            start_stop_sync_1 <= start_stop_sync_0;

            left_sync_0 <= btn_left_port;
            left_sync_1 <= left_sync_0;

            right_sync_0 <= btn_right_port;
            right_sync_1 <= right_sync_0;

            up_sync_0 <= btn_up_port;
            up_sync_1 <= up_sync_0;

            down_sync_0 <= btn_down_port;
            down_sync_1 <= down_sync_0;

            center_sync_0 <= btn_center_port;
            center_sync_1 <= center_sync_0;

            sw6_sync_0 <= sw6;
            sw6_sync_1 <= sw6_sync_0;

        end if;
    end process synchronize;

    -- button debounce and monopulse
    start_stop_proc : process (clk)
    begin
        if rising_edge(clk) then
            if start_stop_sync_1 = start_stop_stable then
                start_stop_count <= 0;
            elsif start_stop_count = STABLE_CYCLES then
                start_stop_stable <= start_stop_sync_1;
                start_stop_count <= 0;
            else
                start_stop_count <= start_stop_count + 1;
            end if;
        end if;
    end process;

    reset_proc : process (clk)
    begin
        if rising_edge(clk) then
            if reset_sync_1 = reset_stable then
                reset_count <= 0;
            elsif reset_count = STABLE_CYCLES then
                reset_stable <= reset_sync_1;
                reset_count <= 0;
            else
                reset_count <= reset_count + 1;
            end if;
        end if;
    end process;

    left_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if left_sync_1 = left_stable then
                left_count <= 0;
            elsif left_count = STABLE_CYCLES then
                left_stable <= left_sync_1;
                left_count <= 0;
            else
                left_count <= left_count + 1;
            end if;
            --monopulse
            left_previous <= left_stable;
        end if;
    end process left_process;

    sw6_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if sw6_sync_1 = sw6_stable then
                sw6_count <= 0;
            elsif sw6_count = STABLE_CYCLES then
                sw6_stable <= sw6_sync_1;
                sw6_count <= 0;
            else
                sw6_count <= sw6_count + 1;
            end if;
        end if;
    end process sw6_process;

    right_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if right_sync_1 = right_stable then
                right_count <= 0;
            elsif right_count = STABLE_CYCLES then
                right_stable <= right_sync_1;
                right_count <= 0;
            else
                right_count <= right_count + 1;
            end if;
            --monopulse
            right_previous <= right_stable;
        end if;
    end process right_process;

    up_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if up_sync_1 = up_stable then
                up_count <= 0;
            elsif up_count = STABLE_CYCLES then
                up_stable <= up_sync_1;
                up_count <= 0;
            else
                up_count <= up_count + 1;
            end if;
            --monopulse
            up_previous <= up_stable;
        end if;
    end process up_process;

    down_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if down_sync_1 = down_stable then
                down_count <= 0;
            elsif down_count = STABLE_CYCLES then
                down_stable <= down_sync_1;
                down_count <= 0;
            else
                down_count <= down_count + 1;
            end if;
            --monopulse
            down_previous <= down_stable;
        end if;
    end process down_process;

    center_process : process (clk)
    begin
        if rising_edge(clk) then
            --debounce
            if center_sync_1 = center_stable then
                center_count <= 0;
            elsif center_count = STABLE_CYCLES then
                center_stable <= center_sync_1;
                center_count <= 0;
            else
                center_count <= center_count + 1;
            end if;
            --monopulse
            center_previous <= center_stable;
        end if;
    end process center_process;

    left_db <= left_stable;
    left_mp <= left_stable and not left_previous;

    right_db <= right_stable;
    right_mp <= right_stable and not right_previous;

    up_db <= up_stable;
    up_mp <= up_stable and not up_previous;

    down_db <= down_stable;
    down_mp <= down_stable and not down_previous;

    center_db <= center_stable;
    center_mp <= center_stable and not center_previous;

    reset_db <= reset_stable;
    start_stop_db <= start_stop_stable;

    sw6_db <= sw6_stable;

end architecture rtl;