--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- cursor movement
-- attempt 1
-- last edited 8/20/26
--=============================================================

--=============================================================
-- explanation
--=============================================================
-- manages cursor position and cell toggling in edit mode
-- when sw0 is asserted, gameplay is disabled and edit mode is active
-- buttons navigate the cursor, center button toggles cells
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
entity cursor_movement is
    generic (
        cols : integer := 40;
        rows : integer := 30
    );
    port (
        clk : in std_logic;
        reset : in std_logic;
        sw0 : in std_logic; -- edit mode enable
        left_mp : in std_logic;
        right_mp : in std_logic;
        up_mp : in std_logic;
        down_mp : in std_logic;
        center_mp : in std_logic;
        cursor_x : out integer range 0 to cols - 1;
        cursor_y : out integer range 0 to rows - 1;
        cell_toggle : out std_logic -- pulse to toggle selected cell
    );
end entity cursor_movement;

--=============================================================
-- architecture
--=============================================================
architecture rtl of cursor_movement is
    -- signals
    signal cursor_x_reg : integer range 0 to cols - 1 := 0;
    signal cursor_y_reg : integer range 0 to rows - 1 := 0;
    signal cursor_x_next : integer range 0 to cols - 1 := 0;
    signal cursor_y_next : integer range 0 to rows - 1 := 0;

    signal cell_toggle_next : std_logic := '0';

begin

    -- cursor state register
    cursor_reg : process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                cursor_x_reg <= 0;
                cursor_y_reg <= 0;
            else
                cursor_x_reg <= cursor_x_next;
                cursor_y_reg <= cursor_y_next;
            end if;
        end if;
    end process cursor_reg;

    -- cursor movement and toggle logic
    cursor_logic : process (cursor_x_reg, cursor_y_reg, left_mp, right_mp, up_mp, down_mp, center_mp, sw0)
    begin
        -- default: hold current position
        cursor_x_next <= cursor_x_reg;
        cursor_y_next <= cursor_y_reg;
        cell_toggle_next <= '0';

        -- only move cursor and allow toggle when in edit mode
        if sw0 = '1' then
            -- horizontal movement
            if left_mp = '1' then
                if cursor_x_reg > 0 then
                    cursor_x_next <= cursor_x_reg - 1;
                end if;
            elsif right_mp = '1' then
                if cursor_x_reg < cols - 1 then
                    cursor_x_next <= cursor_x_reg + 1;
                end if;
            end if;

            -- vertical movement
            if up_mp = '1' then
                if cursor_y_reg > 0 then
                    cursor_y_next <= cursor_y_reg - 1;
                end if;
            elsif down_mp = '1' then
                if cursor_y_reg < rows - 1 then
                    cursor_y_next <= cursor_y_reg + 1;
                end if;
            end if;

            -- toggle cell when center button pressed
            if center_mp = '1' then
                cell_toggle_next <= '1';
            end if;
        end if;
    end process cursor_logic;

    -- output assignments
    cursor_x <= cursor_x_reg;
    cursor_y <= cursor_y_reg;

    -- toggle output register
    toggle_reg : process (clk)
    begin
        if rising_edge(clk) then
            cell_toggle <= cell_toggle_next;
        end if;
    end process toggle_reg;

end architecture rtl;