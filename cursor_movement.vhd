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
-- sw0 = '1' runs the simulation (mode_en in game_logic); sw0 = '0' pauses it
-- and enters edit mode, at which point the cursor becomes visible/movable
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
        sw0 : in std_logic; -- edit mode enable
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
        cell_toggle : out std_logic -- pulse to toggle selected cell
    );
end entity cursor_movement;

--=============================================================
-- architecture
--=============================================================
architecture rtl of cursor_movement is
    -- signals
    constant repeat_time : integer := 20000000;
    signal repeat_count : integer range 0 to repeat_time := 0;
    signal cursor_x_reg : integer range 0 to cols - 1 := 0;
    signal cursor_y_reg : integer range 0 to rows - 1 := 0;
    signal cursor_x_next : integer range 0 to cols - 1 := 0;
    signal cursor_y_next : integer range 0 to rows - 1 := 0;

    signal cell_toggle_next : std_logic := '0';

begin
    -- cursor movement and cell toggle
    cursor_process : process (clk)
    begin
        if rising_edge(clk) then

            -- only allow movement/editing when paused
            if sw0 = '0' then

                -- center, only toggle once when center is initially pressed
                if center_mp = '1' then
                    cell_toggle <= '1';
                else
                    cell_toggle <= '0';
                end if;

                -- initial, monopulse gives one movement when button is pressed
                if left_mp = '1' then
                    if cursor_x_reg > 0 then
                        cursor_x_reg <= cursor_x_reg - 1;
                    end if;

                    repeat_count <= 0;

                elsif right_mp = '1' then
                    if cursor_x_reg < cols - 1 then
                        cursor_x_reg <= cursor_x_reg + 1;
                    end if;

                    repeat_count <= 0;

                elsif up_mp = '1' then
                    if cursor_y_reg > 0 then
                        cursor_y_reg <= cursor_y_reg - 1;
                    end if;

                    repeat_count <= 0;

                elsif down_mp = '1' then
                    if cursor_y_reg < rows - 1 then
                        cursor_y_reg <= cursor_y_reg + 1;
                    end if;

                    repeat_count <= 0;

                    -- held, wait repeat_time clocks, then move again
                elsif left_db = '1' then

                    if repeat_count = repeat_time then
                        repeat_count <= 0;

                        if cursor_x_reg > 0 then
                            cursor_x_reg <= cursor_x_reg - 1;
                        end if;

                    else
                        repeat_count <= repeat_count + 1;
                    end if;

                elsif right_db = '1' then

                    if repeat_count = repeat_time then
                        repeat_count <= 0;

                        if cursor_x_reg < cols - 1 then
                            cursor_x_reg <= cursor_x_reg + 1;
                        end if;

                    else
                        repeat_count <= repeat_count + 1;
                    end if;

                elsif up_db = '1' then

                    if repeat_count = repeat_time then
                        repeat_count <= 0;

                        if cursor_y_reg > 0 then
                            cursor_y_reg <= cursor_y_reg - 1;
                        end if;

                    else
                        repeat_count <= repeat_count + 1;
                    end if;

                elsif down_db = '1' then

                    if repeat_count = repeat_time then
                        repeat_count <= 0;

                        if cursor_y_reg < rows - 1 then
                            cursor_y_reg <= cursor_y_reg + 1;
                        end if;

                    else
                        repeat_count <= repeat_count + 1;
                    end if;

                else
                    -- no directional button is being held
                    repeat_count <= 0;
                end if;

            else
                -- simulation mode
                repeat_count <= 0;
                cell_toggle <= '0';
            end if;

        end if;
    end process cursor_process;

    --=========================================================
    -- Outputs
    --=========================================================
    cursor_x <= cursor_x_reg;
    cursor_y <= cursor_y_reg;

end architecture rtl;