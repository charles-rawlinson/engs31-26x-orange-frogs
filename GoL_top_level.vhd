library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    port(
        clk     : in std_logic;
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

	--components
    component vga_sync is
        port(
            clk         : in std_logic;
            p_tick      : in std_logic;
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
            cols : integer := 40;
            rows : integer := 30
        );
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            mode_en     : in  std_logic;
            update_tick : in  std_logic;
            grid_out    : out std_logic_vector((rows * cols) - 1 downto 0)
        );
    end component;

	--signals
    signal hcount, vcount : std_logic_vector(9 downto 0);
    signal video_on       : std_logic;
    signal gen_tick       : std_logic;
    signal p_tick         : std_logic;
    signal red, grn, blu  : std_logic_vector(3 downto 0);
    signal vga_hs_sig, vga_vs_sig : std_logic;
    signal game_grid      : std_logic_vector(1199 downto 0);
    signal cell_x, cell_y, cell_index : integer;
    signal sw1_meta       : std_logic := '0';
    signal sw1_sync       : std_logic := '0';

begin

	reset_sync : process(clk)
	begin
		if rising_edge(clk) then
			sw1_meta <= sw1;
			sw1_sync <= sw1_meta;
		end if;
	end process reset_sync;

	--port maps
    vga : vga_sync
    port map(
        clk        => clk,
        p_tick     => p_tick,
        hsync_port => vga_hs_sig,
        vsync_port => vga_vs_sig,
        video_on   => video_on,
        hcount     => hcount,
        vcount     => vcount
    );

    gen: gen_timer
    port map(
        clk   => clk,
        reset => sw1_sync,
        tick  => gen_tick,
        p_tick => p_tick
    );

    life : game_logic
    generic map (
        cols => 40,
        rows => 30
    )
    port map (
        clk         => clk,
        reset       => sw1_sync,
        mode_en     => sw0,
        update_tick => gen_tick,
        grid_out    => game_grid
    );

	--processes
    draw : process(video_on, hcount, vcount, game_grid)
        constant cell_size : integer := 16;
        constant x_offset  : integer := 48;
        constant y_offset  : integer := 33;
        variable x_pix     : integer;
        variable y_pix     : integer;
        variable x_cell    : integer;
        variable y_cell    : integer;
        variable index     : integer;
    begin
        if video_on = '0' then
            red <= "0000"; grn <= "0000"; blu <= "0000";
        else
            x_pix := to_integer(unsigned(hcount)) - x_offset;
            y_pix := to_integer(unsigned(vcount)) - y_offset;

            if x_pix >= 0 and y_pix >= 0 then
                x_cell := x_pix / cell_size;
                y_cell := y_pix / cell_size;
                index := (y_cell * 40) + x_cell;

                if x_cell < 40 and y_cell < 30 and index >= 0 and index < 1200 and game_grid(index) = '1' then
                    red <= "0000"; grn <= "1111"; blu <= "0000";
                else
                    red <= "1000"; grn <= "1000"; blu <= "1000";
                end if;
            else
                red <= "0000"; grn <= "0000"; blu <= "0000";
            end if;
        end if;
    end process;

	--outputs
    vga_r <= red;
    vga_g <= grn;
    vga_b <= blu;
    vga_hs <= vga_hs_sig;
    vga_vs <= vga_vs_sig;

end architecture rtl;
