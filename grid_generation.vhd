library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity grid_generation is
    generic (
        cols : integer := 40;
        rows : integer := 30
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        enable_mode : in  std_logic;
        update_tick : in  std_logic;
        grid_out    : out std_logic_vector((rows * cols) - 1 downto 0)
    );
end entity grid_generation;

architecture rtl of grid_generation is
    type grid_t is array (0 to rows - 1, 0 to cols - 1) of std_logic;
    signal grid_mem : grid_t := (others => (others => '0'));
begin
    flatten_grid : process(grid_mem)
    begin
        for r in 0 to rows - 1 loop
            for c in 0 to cols - 1 loop
                grid_out((r * cols) + c) <= grid_mem(r, c);
            end loop;
        end loop;
    end process flatten_grid;

    hold_grid : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                grid_mem <= (others => (others => '0'));
            end if;
        end if;
    end process hold_grid;
end architecture rtl;
