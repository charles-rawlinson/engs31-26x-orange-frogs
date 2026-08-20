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
	--components
	component vga_sync is
		port(
			clk	: in std_logic;
			reset	: in std_logic;
			hsync	: out std_logic;
			vsync	: out std_logic;
			video_on	: out std_logic
		);
	end component;

	--signals
	signal red, grn, blu	: std_logic_vector(3 downto 0);

	--port maps
	vga : vga_sync port map(
		clk=>clk,
		reset_db=>reset,
		hsync_port=>vga_hs,
		vsync_port=>vga_vs,
		video_on=>video_on
	);

	--processes
	pick_colour : process(video_on)
	begin
		red <= "0000"; grn <= "1111"; blu <= "0000";
		end if;
	end process;

	vga_r <= red;
	vga_g <= grn;
	vga_b <= blu;

end architecture arch;
