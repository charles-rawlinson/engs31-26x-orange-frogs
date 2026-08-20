--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- timer generation
-- attempt 1
-- last edited 8/19/26
--=============================================================

--=============================================================
-- library declarations
--=============================================================
library ieee;
use ieee.std_logic_1164.all;

-- produces one clock wide tick every tick_max clocks
entity gen_timer is
  generic (
    tick_max : integer := 25000000 -- 0.25 s at 100 mhz, 4 generations/sec
  );
  port (
    clk : in std_logic;
    tick : out std_logic;
    p_tick : out std_logic -- pixel tick: one pulse every 4 clocks
  );
end entity gen_timer;

--=============================================================
-- architecture
--=============================================================
architecture rtl of gen_timer is

  -- free running counter
  signal cnt : integer range 0 to tick_max := 0;
  -- pixel clock divider (divide by 4)
  signal pix_cnt : integer range 0 to 3 := 0;

begin

  process (clk)
  begin
    if rising_edge(clk) then
      if cnt = tick_max then
        cnt <= 0;
      else
        cnt <= cnt + 1;
      end if;

      -- pixel tick divider: one-cycle pulse every 4 clk
      if pix_cnt = 3 then
        pix_cnt <= 0;
      else
        pix_cnt <= pix_cnt + 1;
      end if;
    end if;
  end process;

  tick <= '1' when cnt = tick_max else
          '0';
  p_tick <= '1' when pix_cnt = 0 else
            '0';

end architecture rtl;