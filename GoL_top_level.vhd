--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- top level
-- attempt 1
-- last edited 8/20/26
--=============================================================

--=============================================================
-- explanation
--=============================================================
-- top-level file that connects all modules together
-- handles coordinate calculations and output routing
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
entity top is
    generic (
        cell_size : integer := 16;
        x_offset : integer := 48;
        y_offset : integer := 33
    );
    port (
        clk : in std_logic;
        sw0 : in std_logic; -- simulate / edit
        sw1 : in std_logic; -- reset
        btn_left : in std_logic;
        btn_right : in std_logic;
        btn_up : in std_logic;
        btn_down : in std_logic;
        btn_center : in std_logic;
        vga_hs : out std_logic;
        vga_vs : out std_logic;
        vga_r : out std_logic_vector(3 downto 0);
        vga_g : out std_logic_vector(3 downto 0);
        vga_b : out std_logic_vector(3 downto 0)
    );
end entity top;

--=============================================================
-- architecture
--=============================================================
architecture rtl of top is

    -- components
    component vga_sync is
        port (
            clk : in std_logic;
            p_tick : in std_logic;
            hsync_port : out std_logic;
            vsync_port : out std_logic;
            video_on : out std_logic;
            hcount : out std_logic_vector(9 downto 0);
            vcount : out std_logic_vector(9 downto 0)
        );
    end component;

    component gen_timer is
        generic (
            tick_max : integer := 25000000
        );
        port (
            clk : in std_logic;
            tick : out std_logic;
            p_tick : out std_logic
        );
    end component;

    component game_logic is
        generic (
            cols : integer := 40;
            rows : integer := 30
        );
        port (
            clk : in std_logic;
            reset : in std_logic;
            mode_en : in std_logic;
            update_tick : in std_logic;
            cell_toggle : in std_logic;
            cursor_x : in integer range 0 to cols - 1;
            cursor_y : in integer range 0 to rows - 1;
            grid_out : out std_logic_vector((rows * cols) - 1 downto 0)
        );
    end component;

    component debouncer is
        generic (
            STABLE_CYCLES : integer := 250000
        );
        port (
            clk : in std_logic;
            reset_port : in std_logic;
            start_stop_port : in std_logic;
            btn_left_port : in std_logic;
            btn_right_port : in std_logic;
            btn_up_port : in std_logic;
            btn_down_port : in std_logic;
            btn_center_port : in std_logic;
            reset_db : out std_logic;
            start_stop_db : out std_logic;
            left_db : out std_logic;
            right_db : out std_logic;
            up_db : out std_logic;
            down_db : out std_logic;
            center_db : out std_logic;
            left_mp : out std_logic;
            right_mp : out std_logic;
            up_mp : out std_logic;
            down_mp : out std_logic;
            center_mp : out std_logic
        );
    end component;

    component cursor_movement is
        generic (
            cols : integer := 40;
            rows : integer := 30
        );
        port (
            clk : in std_logic;
            sw0 : in std_logic;
            left_mp : in std_logic;
            right_mp : in std_logic;
            up_mp : in std_logic;
            down_mp : in std_logic;
            center_mp : in std_logic;
            left_db : in std_logic;
            right_db : in std_logic;
            up_db : in std_logic;
            down_db : in std_logic;
            center_db : in std_logic;
            cursor_x : out integer range 0 to cols - 1;
            cursor_y : out integer range 0 to rows - 1;
            cell_toggle : out std_logic
        );
    end component;

    component vga_graphics is
        generic (
            cell_size : integer := 16
        );
        port (
            clk : in std_logic;
            p_tick : in std_logic;
            video_on : in std_logic;
            x_pix : in integer;
            y_pix : in integer;
            cell_x : in integer;
            cell_y : in integer;
            cell_index : in integer;
            game_grid : in std_logic_vector(1199 downto 0);
            image_data : in std_logic_vector(11 downto 0);
            cursor_x : in integer;
            cursor_y : in integer;
            sw0_sync : in std_logic;
            vga_r : out std_logic_vector(3 downto 0);
            vga_g : out std_logic_vector(3 downto 0);
            vga_b : out std_logic_vector(3 downto 0)
        );
    end component;

    -- signals
    signal hcount, vcount : std_logic_vector(9 downto 0);
    signal video_on : std_logic;
    signal gen_tick : std_logic;
    signal p_tick : std_logic;
    signal red, grn, blu : std_logic_vector(3 downto 0);
    signal vga_hs_sig, vga_vs_sig : std_logic;
    signal game_grid : std_logic_vector(1199 downto 0);
    signal x_pix, y_pix : integer;
    signal cell_x, cell_y, cell_index : integer;
    signal sw1_meta : std_logic := '0';
    signal sw1_sync : std_logic := '0';
    signal sw0_meta : std_logic := '0';
    signal sw0_sync : std_logic := '0';

    --TAD signals
    signal image_address  : std_logic_vector (14 downto 0);
    signal image_data     : std_logic_vector (11 downto 0);
    signal image_x : integer; 
    signal image_y : integer; 
    -- debouncer signals
    signal left_mp, right_mp, up_mp, down_mp, center_mp : std_logic;

    -- cursor signals
    signal cursor_x_sig, cursor_y_sig : integer range 0 to 39;
    signal cell_toggle_sig : std_logic;

begin

    -- reset synchronizer
    reset_sync : process (clk)
    begin
        if rising_edge(clk) then
            sw1_meta <= sw1;
            sw1_sync <= sw1_meta;
            sw0_meta <= sw0;
            sw0_sync <= sw0_meta;
        end if;
    end process reset_sync;

    -- port maps
    vga : vga_sync
    port map(
        clk => clk,
        p_tick => p_tick,
        hsync_port => vga_hs_sig,
        vsync_port => vga_vs_sig,
        video_on => video_on,
        hcount => hcount,
        vcount => vcount
    );

    gen : gen_timer
    port map(
        clk => clk,
        tick => gen_tick,
        p_tick => p_tick
    );

    life : game_logic
    generic map(
        cols => 40,
        rows => 30
    )
    port map(
        clk => clk,
        reset => sw1_sync,
        mode_en => sw0_sync,
        update_tick => gen_tick,
        cell_toggle => cell_toggle_sig,
        cursor_x => cursor_x_sig,
        cursor_y => cursor_y_sig,
        grid_out => game_grid
    );

    dbnc : debouncer
    port map(
        clk => clk,
        reset_port => sw1,
        start_stop_port => '0',
        btn_left_port => btn_left,
        btn_right_port => btn_right,
        btn_up_port => btn_up,
        btn_down_port => btn_down,
        btn_center_port => btn_center,
        reset_db => open,
        start_stop_db => open,
        left_db => open,
        right_db => open,
        up_db => open,
        down_db => open,
        center_db => open,
        left_mp => left_mp,
        right_mp => right_mp,
        up_mp => up_mp,
        down_mp => down_mp,
        center_mp => center_mp
    );

    cursor : cursor_movement
    generic map(
        cols => 40,
        rows => 30
    )
    port map(
        clk => clk,
        sw0 => sw0_sync,
        left_mp => left_mp,
        right_mp => right_mp,
        up_mp => up_mp,
        down_mp => down_mp,
        center_mp => center_mp,
        cursor_x => cursor_x_sig,
        cursor_y => cursor_y_sig,
        cell_toggle => cell_toggle_sig
    );

    -- graphics and vga output
    graphics : vga_graphics
    generic map (
        cell_size => 16
    )
    port map (
        clk => clk,
        p_tick => p_tick,
        video_on => video_on,
        x_pix => x_pix,
        y_pix => y_pix,
        cell_x => cell_x,
        cell_y => cell_y,
        cell_index => cell_index,
        game_grid => game_grid,
        image_data => image data,
        cursor_x => cursor_x_sig,
        cursor_y => cursor_y_sig,
        sw0_sync => sw0_sync,
        vga_r => red,
        vga_g => grn,
        vga_b => blu
    );

    -- coordinate calculations
    x_pix <= to_integer(unsigned(hcount)) - x_offset;
    y_pix <= to_integer(unsigned(vcount)) - y_offset;
    cell_x <= x_pix / cell_size when x_pix >= 0 else
              0;
    cell_y <= y_pix / cell_size when y_pix >= 0 else
              0;
    cell_index <= (cell_y * 40) + cell_x;

    --tad coordinate calculations
    image_x = x_pix / 4 when x_pix >= 0 else 0;
    image_y = y_pix / 4 when y_pix >= 0 else 0;
    image_address <= std_logic_vector(to_unsigned((image_y * 160) + image_x, 15));

    -- port assignments
    vga_r <= red;
    vga_g <= grn;
    vga_b <= blu;
    vga_hs <= vga_hs_sig;
    vga_vs <= vga_vs_sig;

    --TAD face image memory 
    professor_image : blk_mem_gen_0
    port map (
        clka  => clk,
        wea   => "0",
        addra => image_address,
        dina  => (others => '0'),
        douta => image_data
    );

end architecture rtl;