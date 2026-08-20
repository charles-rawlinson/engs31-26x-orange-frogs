--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- vga graphics
-- attempt 1
-- last edited 8/20/26
--=============================================================

--=============================================================
-- explanation
--=============================================================
-- handles vga color output with animated rainbow gradient for live cells
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
entity vga_graphics is
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
        cursor_x : in integer;
        cursor_y : in integer;
        sw0_sync : in std_logic;
        vga_r : out std_logic_vector(3 downto 0);
        vga_g : out std_logic_vector(3 downto 0);
        vga_b : out std_logic_vector(3 downto 0)
    );
end entity vga_graphics;

--=============================================================
-- architecture
--=============================================================
architecture rtl of vga_graphics is
    --=========================================================
    -- signals
    --=========================================================
    signal x_within_cell : integer;
    signal y_within_cell : integer;
    signal on_border : std_logic;

    signal scroll_offset : integer range 0 to 511 := 0;
    signal diag_pos : integer;
    signal gradient_phase : integer range 0 to 95;
    signal r_smooth, g_smooth, b_smooth : std_logic_vector(3 downto 0);

    signal red, grn, blu : std_logic_vector(3 downto 0);

begin

    -- animation counter
    scroll_anim : process (clk)
    begin
        if rising_edge(clk) then
            if p_tick = '1' then
                scroll_offset <= (scroll_offset + 1) mod 512;
            end if;
        end if;
    end process scroll_anim;

    -- concurrent signal assignments
    x_within_cell <= x_pix mod cell_size when x_pix >= 0 else
                     0;
    y_within_cell <= y_pix mod cell_size when y_pix >= 0 else
                     0;
    on_border <= '1' when (x_within_cell = 0 or x_within_cell = cell_size - 1 or
                 y_within_cell = 0 or y_within_cell = cell_size - 1) else
                 '0';

    -- diagonal rainbow position
    diag_pos <= x_pix + y_pix + scroll_offset;
    gradient_phase <= (diag_pos / 2) mod 96;

    -- smooth rainbow gradient (0-31: R->Y->G, 32-63: G->C->B, 64-95: B->M->R)
    r_smooth <= "1111" when gradient_phase < 32 else
                std_logic_vector(to_unsigned(15 - (gradient_phase - 32) / 2, 4)) when gradient_phase < 64 else
                std_logic_vector(to_unsigned((gradient_phase - 64) / 2, 4));
    g_smooth <= std_logic_vector(to_unsigned((gradient_phase) / 2, 4)) when gradient_phase < 32 else
                "1111" when gradient_phase < 64 else
                std_logic_vector(to_unsigned(15 - (gradient_phase - 64) / 2, 4));
    b_smooth <= "0000" when gradient_phase < 32 else
                std_logic_vector(to_unsigned((gradient_phase - 32) / 2, 4)) when gradient_phase < 64 else
                "1111";

    -- draw process
    draw : process (video_on, x_pix, y_pix, cell_x, cell_y, cell_index, game_grid, cursor_x, cursor_y, sw0_sync, on_border, r_smooth, g_smooth, b_smooth)
    begin
        if video_on = '0' then
            red <= "0000";
            grn <= "0000";
            blu <= "0000";
        else
            if x_pix >= 0 and y_pix >= 0 then
                if cell_x < 40 and cell_y < 30 and cell_index >= 0 and cell_index < 1200 then
                    -- cursor border in edit mode
                    if sw0_sync = '1' and cell_x = cursor_x and cell_y = cursor_y and on_border = '1' then
                        red <= "1111";
                        grn <= "0000";
                        blu <= "0000";
                        -- live cells with smooth scrolling rainbow
                    elsif game_grid(cell_index) = '1' then
                        red <= r_smooth;
                        grn <= g_smooth;
                        blu <= b_smooth;
                        -- dead cells in black
                    else
                        red <= "0000";
                        grn <= "0000";
                        blu <= "0000";
                    end if;
                else
                    -- out of bounds, draw blue
                    red <= "0000";
                    grn <= "0000";
                    blu <= "1111";
                end if;
            else
                red <= "0000";
                grn <= "0000";
                blu <= "1111";
            end if;
        end if;
    end process;

    -- outputs
    vga_r <= red;
    vga_g <= grn;
    vga_b <= blu;

end architecture rtl;
