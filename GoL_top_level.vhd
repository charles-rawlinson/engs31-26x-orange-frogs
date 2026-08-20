library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		clk	: in std_logic;
		vga_r	: out std_logic_vector(3 downto 0);
		vga_g	: out std_logic_vector(3 downto 0);
		vga_b	: out std_logic_vector(3 downto 0)
	);
end entity top;

architecture arch of top is
	--signals
	signal red, grn, blu	: std_logic_vector(3 downto 0);

	--processes

	pick_colour : process(video_on, mode_edit, on_cursor, on_border, cell_alive)
	begin
		if video_on = '0' then
			red <= "0000"; grn <= "0000"; blu <= "0000";
		end if;
	end process;

	vga_r <= red;
	vga_g <= grn;
	vga_b <= blu;

end architecture arch;
