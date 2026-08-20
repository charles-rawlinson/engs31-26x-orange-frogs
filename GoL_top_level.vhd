library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        sw0     : in std_logic;
        sw1     : in std_logic;
        vga_hs  : out std_logic;
        vga_vs  : out std_logic;
        vga_r   : out std_logic_vector(3 downto 0);
        vga_g   : out std_logic_vector(3 downto 0);
        vga_b   : out std_logic_vector(3 downto 0)
    );
end entity top;

architecture rtl of top is

    component vga_sync is
        port(
            clk         : in std_logic;
            p_tick      : in std_logic;
            reset_db    : in std_logic;
            hsync_port  : out std_logic;
            vsync_port  : out std_logic;
            video_on    : out std_logic;
            hcount      : out std_logic_vector(9 downto 0);
            vcount      : out std_logic_vector(9 downto 0)
        );
    end component;

    component gen_timer is
        generic(
            tick_max : integer := 25000000
        );
        port(
            clk   : in  std_logic;
            reset : in  std_logic;
            tick  : out std_logic;
            p_tick : out std_logic
        );
    end component;

    component game_logic is
        generic (
            cols : integer := 30;
            rows : integer := 40
        );
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            mode_en     : in  std_logic;
            update_tick : in  std_logic;
            grid_out    : out std_logic_vector((rows * cols) - 1 downto 0)
        );
    end component;

    signal hcount, vcount : std_logic_vector(9 downto 0);
    signal video_on       : std_logic;
    signal gen_tick       : std_logic;
    signal p_tick         : std_logic;
    signal red, grn, blu  : std_logic_vector(3 downto 0);
    signal vga_hs_sig, vga_vs_sig : std_logic;
    signal game_grid      : std_logic_vector(1199 downto 0);
    signal game_reset     : std_logic;

begin

    game_reset <= reset or sw1;

    vga : vga_sync
    port map(
        clk        => clk,
        p_tick     => p_tick,
        reset_db   => reset,
        hsync_port => vga_hs_sig,
        vsync_port => vga_vs_sig,
        video_on   => video_on,
        hcount     => hcount,
        vcount     => vcount
    );

    gen: gen_timer
    port map(
        clk   => clk,
        reset => game_reset,
        tick  => gen_tick,
        p_tick => p_tick
    );

    life : game_logic
    generic map (
        cols => 30,
        rows => 40
    )
    port map (
        clk         => clk,
        reset       => sw1,
        mode_en     => sw0,
        update_tick => gen_tick,
        grid_out    => game_grid
    );

    draw : process(video_on, hcount, vcount, game_grid)
        variable cell_x : integer;
        variable cell_y : integer;
        variable cell_index : integer;
    begin
        if video_on = '0' then
            red <= "0000"; grn <= "0000"; blu <= "0000";
        else
            cell_x := to_integer(unsigned(hcount)) / 16;
            cell_y := to_integer(unsigned(vcount)) / 12;
            cell_index := (cell_y * 30) + cell_x;

            if cell_x < 30 and cell_y < 40 and cell_index >= 0 and cell_index < 1200 and game_grid(cell_index) = '1' then
                red <= "0000"; grn <= "1111"; blu <= "0000";
            else
                red <= "0000"; grn <= "0000"; blu <= "0000";
            end if;
        end if;
    end process;

    vga_r <= red;
    vga_g <= grn;
    vga_b <= blu;
    vga_hs <= vga_hs_sig;
    vga_vs <= vga_vs_sig;

end architecture rtl;
