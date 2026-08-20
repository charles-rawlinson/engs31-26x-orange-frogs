library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity game_logic is
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
end entity game_logic;

architecture rtl of game_logic is
    type grid_t is array (0 to rows - 1, 0 to cols - 1) of std_logic;

    signal grid_reg  : grid_t := (others => (others => '0'));
    signal next_grid : grid_t := (others => (others => '0'));

    type fsm_state is (HOLD, EVALUATE, COMMIT);
    signal current_state : fsm_state := HOLD;
    signal row_index    : integer range 0 to rows - 1 := 0;
    signal col_index    : integer range 0 to cols - 1 := 0;

    procedure init_pattern(signal g : out grid_t) is
    begin
        for r in 0 to rows - 1 loop
            for c in 0 to cols - 1 loop
                g(r, c) <= '0';
            end loop;
        end loop;

        -- Initial seed patterns
        g(10, 10) <= '1'; g(10, 11) <= '1'; g(10, 12) <= '1';
        g(11, 12) <= '1'; g(12, 11) <= '1';

        g(18, 15) <= '1'; g(19, 15) <= '1'; g(20, 15) <= '1';
        g(18, 16) <= '1'; g(19, 17) <= '1';

        g(25, 22) <= '1'; g(25, 23) <= '1'; g(25, 24) <= '1';
        g(24, 24) <= '1'; g(23, 23) <= '1';
    end procedure;

begin

    flatten_grid : process(grid_reg)
    begin
        for r in 0 to rows - 1 loop
            for c in 0 to cols - 1 loop
                grid_out((r * cols) + c) <= grid_reg(r, c);
            end loop;
        end loop;
    end process flatten_grid;

    state_machine : process(clk)
        variable neighbor_count : integer range 0 to 8;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                init_pattern(grid_reg);
                next_grid <= (others => (others => '0'));
                current_state <= HOLD;
                row_index <= 0;
                col_index <= 0;
            else
                case current_state is
                    when HOLD =>
                        if mode_en = '1' and update_tick = '1' then
                            next_grid <= grid_reg;
                            row_index <= 0;
                            col_index <= 0;
                            current_state <= EVALUATE;
                        end if;

                    when EVALUATE =>
                        neighbor_count := 0;

                        if row_index > 0 and col_index > 0 and grid_reg(row_index - 1, col_index - 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if row_index > 0 and grid_reg(row_index - 1, col_index) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if row_index > 0 and col_index < cols - 1 and grid_reg(row_index - 1, col_index + 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if col_index > 0 and grid_reg(row_index, col_index - 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if col_index < cols - 1 and grid_reg(row_index, col_index + 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if row_index < rows - 1 and col_index > 0 and grid_reg(row_index + 1, col_index - 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if row_index < rows - 1 and grid_reg(row_index + 1, col_index) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;
                        if row_index < rows - 1 and col_index < cols - 1 and grid_reg(row_index + 1, col_index + 1) = '1' then
                            neighbor_count := neighbor_count + 1;
                        end if;

                        if (grid_reg(row_index, col_index) = '1' and neighbor_count = 2) or (neighbor_count = 3) then
                            next_grid(row_index, col_index) <= '1';
                        else
                            next_grid(row_index, col_index) <= '0';
                        end if;

                        if col_index = cols - 1 then
                            if row_index = rows - 1 then
                                current_state <= COMMIT;
                            else
                                row_index <= row_index + 1;
                                col_index <= 0;
                            end if;
                        else
                            col_index <= col_index + 1;
                        end if;

                    when COMMIT =>
                        grid_reg <= next_grid;
                        current_state <= HOLD;

                    when others =>
                        current_state <= HOLD;
                end case;
            end if;
        end if;
    end process state_machine;

end architecture rtl;
