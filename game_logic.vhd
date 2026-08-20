--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- game logic
-- attempt 1
-- last edited 8/20/26
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
entity game_logic is
    generic (
        cols : integer := 40;
        rows : integer := 30
    );
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        mode_en     : in  std_logic;
        update_tick : in  std_logic;
        cell_toggle : in  std_logic;
        cursor_x    : in  integer range 0 to cols - 1;
        cursor_y    : in  integer range 0 to rows - 1;
        grid_out    : out std_logic_vector((rows * cols) - 1 downto 0)
    );
end entity game_logic;

--=============================================================
-- architecture
--=============================================================
architecture rtl of game_logic is
    --=========================================================
    -- signals
    --=========================================================
    type grid_t is array (0 to rows - 1, 0 to cols - 1) of std_logic;

    -- initial pattern
    constant init_pattern : grid_t := (
        10 => (10 => '1', 11 => '1', 12 => '1', others => '0'),
        11 => (12 => '1', others => '0'),
        12 => (11 => '1', others => '0'),

        18 => (15 => '1', 16 => '1', others => '0'),
        19 => (15 => '1', 17 => '1', others => '0'),
        20 => (15 => '1', others => '0'),

        23 => (23 => '1', others => '0'),
        24 => (24 => '1', others => '0'),
        25 => (22 => '1', 23 => '1', 24 => '1', others => '0'),

        others => (others => '0')
    );

    signal grid_reg        : grid_t := init_pattern;
    signal next_grid_sig   : grid_t := (others => (others => '0'));
    signal neighbor_count_next : integer range 0 to 8 := 0;
    signal count_sig       : integer range 0 to 8 := 0;
    signal n1, n2, n3, n4, n5, n6, n7, n8 : integer range 0 to 1 := 0;

    -- fsm state
    type fsm_state is (HOLD, EVALUATE, COMMIT);
    signal current_state   : fsm_state := HOLD;
    signal next_state      : fsm_state := HOLD;
    signal row_index       : integer range 0 to rows - 1 := 0;
    signal next_row_index  : integer range 0 to rows - 1 := 0;
    signal col_index       : integer range 0 to cols - 1 := 0;
    signal next_col_index  : integer range 0 to cols - 1 := 0;
    signal neighbor_count_sig : integer range 0 to 8 := 0;
    signal cell_next_val   : std_logic := '0';

begin

    -- state registers
    state_reg : process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process state_reg;

    -- next-state logic
    next_state_logic : process(current_state, row_index, col_index, mode_en, update_tick, reset, cell_toggle, cursor_x, cursor_y)
    begin
        next_state <= current_state;
        next_row_index <= row_index;
        next_col_index <= col_index;

        if reset = '1' then
            next_state <= HOLD;
            next_row_index <= 0;
            next_col_index <= 0;
        else
            case current_state is
                when HOLD =>
                    if mode_en = '1' and update_tick = '1' then
                        next_row_index <= 0;
                        next_col_index <= 0;
                        next_state <= EVALUATE;
                    end if;

                when EVALUATE =>
                    if col_index = cols - 1 then
                        if row_index = rows - 1 then
                            next_state <= COMMIT;
                        else
                            next_row_index <= row_index + 1;
                            next_col_index <= 0;
                        end if;
                    else
                        next_col_index <= col_index + 1;
                    end if;

                when COMMIT =>
                    next_row_index <= 0;
                    next_col_index <= 0;
                    next_state <= HOLD;

                when others =>
                    null;
            end case;
        end if;
    end process next_state_logic;

    -- output logic
    output_logic : process(current_state, row_index, col_index, grid_reg, neighbor_count_sig, reset)
    begin
        if reset = '1' then
            cell_next_val <= '0';
        elsif current_state = EVALUATE then
            if (grid_reg(row_index, col_index) = '1' and neighbor_count_sig = 2) or (neighbor_count_sig = 3) then
                cell_next_val <= '1';
            else
                cell_next_val <= '0';
            end if;
        else
            cell_next_val <= '0';
        end if;

        for r in 0 to rows - 1 loop
            for c in 0 to cols - 1 loop
                grid_out((r * cols) + c) <= grid_reg(r, c);
            end loop;
        end loop;
    end process output_logic;

    -- update registers
    update_reg : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                grid_reg <= init_pattern;
                next_grid_sig <= (others => (others => '0'));
                row_index <= 0;
                col_index <= 0;
            else
                row_index <= next_row_index;
                col_index <= next_col_index;

                -- toggle cell in edit mode
                if cell_toggle = '1' then
                    grid_reg(cursor_y, cursor_x) <= not grid_reg(cursor_y, cursor_x);
                end if;

                if current_state = EVALUATE then
                    next_grid_sig(row_index, col_index) <= cell_next_val;
                elsif current_state = COMMIT then
                    grid_reg <= next_grid_sig;
                end if;
            end if;
        end if;
    end process update_reg;

    -- neighbor counts
    n1 <= 1 when (row_index > 0 and col_index > 0 and grid_reg(row_index - 1, col_index - 1) = '1') else 0;
    n2 <= 1 when (row_index > 0 and grid_reg(row_index - 1, col_index) = '1') else 0;
    n3 <= 1 when (row_index > 0 and col_index < cols - 1 and grid_reg(row_index - 1, col_index + 1) = '1') else 0;
    n4 <= 1 when (col_index > 0 and grid_reg(row_index, col_index - 1) = '1') else 0;
    n5 <= 1 when (col_index < cols - 1 and grid_reg(row_index, col_index + 1) = '1') else 0;
    n6 <= 1 when (row_index < rows - 1 and col_index > 0 and grid_reg(row_index + 1, col_index - 1) = '1') else 0;
    n7 <= 1 when (row_index < rows - 1 and grid_reg(row_index + 1, col_index) = '1') else 0;
    n8 <= 1 when (row_index < rows - 1 and col_index < cols - 1 and grid_reg(row_index + 1, col_index + 1) = '1') else 0;

    count_sig <= n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8;
    neighbor_count_sig <= count_sig;

end architecture rtl;
