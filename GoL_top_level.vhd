library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port(
		clk	: in std_logic;
		reset	: in std_logic;
		vga_hs	: out std_logic;
		vga_vs	: out std_logic;
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
			reset_db	: in std_logic;
			hsync_port	: out std_logic;
			vsync_port	: out std_logic;
			video_on	: out std_logic;
			hcount   : out std_logic_vector(9 downto 0);
			vcount   : out std_logic_vector(9 downto 0)
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
	

	--signals
	signal hcount, vcount : std_logic_vector(9 downto 0);
	signal video_on        : std_logic;
	
	signal gen_tick : std_logic;
    signal p_tick   : std_logic;

	signal red, grn, blu	: std_logic_vector(3 downto 0);
	signal vga_hs_sig, vga_vs_sig : std_logic;


begin
	
	--port maps
	vga : vga_sync
	port map(
		clk=>p_tick,
		reset_db=>reset,
		hsync_port=>vga_hs_sig,
		vsync_port=>vga_vs_sig,
		video_on=>video_on,
		hcount=>hcount,
		vcount=>vcount
	);

	gen: gen_timer
	port map(
		clk=>clk,
		reset=>reset,
		tick=>gen_tick,
		p_tick=>p_tick
	);

	--processes
	draw : process(video_on)
		begin
			if video_on = '0' then
				red <= "0000"; grn <= "0000"; blu <= "0000";
			else
				red <= "0000"; grn <= "1111"; blu <= "0000";
			end if;
	end process;

	vga_r <= red;
	vga_g <= grn;
	vga_b <= blu;
	vga_hs <= vga_hs_sig;
	vga_vs <= vga_vs_sig;

end architecture arch;
