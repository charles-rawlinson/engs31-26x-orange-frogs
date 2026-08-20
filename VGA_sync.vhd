--=============================================================
-- engs 31 final project
--=============================================================
-- conway's game of life on vga
-- vga sync
-- attempt 1
-- last edited 8/19/26
--=============================================================

--=============================================================
-- explanation
--=============================================================
-- controls the syncing functions of the vga
--=============================================================

--=============================================================
-- library declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--=============================================================

--=============================================================
-- entity declarations
--=============================================================
entity vga_sync is
	port (
		-- input ports
		clk : in std_logic; -- from top level
		p_tick : in std_logic; -- pixel clock enable pulse

		--output ports
		hsync_port : out std_logic;
		vsync_port : out std_logic;
		video_on : out std_logic;
		hcount : out std_logic_vector(9 downto 0);
		vcount : out std_logic_vector(9 downto 0)
	);
end vga_sync;
--=============================================================

architecture behavior of vga_sync is

	-- signal declaration 
	signal H_video_on : std_logic := '0';
	signal V_video_on : std_logic := '0';

	signal h_counter : unsigned (9 downto 0) := (others => '0');
	signal v_counter : unsigned (9 downto 0) := (others => '0');

	signal h_sync_int : std_logic := '0';
	signal v_sync_int : std_logic := '0';

	-- vga 640x480@60 timing constants

	constant h_back_porch : integer := 48;
	constant h_display : integer := 640;
	constant h_front_porch : integer := 16;
	constant h_retrace : integer := 96;
	constant HSCAN : integer := h_back_porch + h_display + h_front_porch + h_retrace - 1; -- number of PCLKs in an H sync period

	constant v_back_porch : integer := 33;
	constant v_display : integer := 480;
	constant v_front_porch : integer := 10;
	constant v_retrace : integer := 2;
	constant VSCAN : integer := v_back_porch + v_display + v_front_porch + v_retrace - 1; -- number of H syncs in a V sync period

	constant H_END_DISPLAY : integer := h_back_porch + h_display;
	constant H_END_FRONT : integer := h_back_porch + h_display + h_front_porch;
	constant H_END_RETRACE : integer := h_back_porch + h_display + h_front_porch + h_retrace;

	constant V_END_DISPLAY : integer := v_back_porch + v_display;
	constant V_END_FRONT : integer := v_back_porch + v_display + v_front_porch;
	constant V_END_RETRACE : integer := v_back_porch + v_display + v_front_porch + v_retrace;

begin

	-- h sync generating process
	Hsync_proc : process (clk)
	begin
		if rising_edge(clk) then
			if p_tick = '1' then
				if h_counter = HSCAN then
					h_counter <= (others => '0');
				else
					h_counter <= h_counter + 1;
				end if;
			end if;
		end if;
	end process Hsync_proc;

	H_video_on <= '1' when (h_counter >= h_back_porch and h_counter < H_END_DISPLAY) else '0';
	h_sync_int <= '0' when (h_counter >= H_END_FRONT and h_counter < H_END_RETRACE) else '1';

	-- v sync generating process
	Vsync_proc : process (clk)
	begin
		if rising_edge(clk) then
			if p_tick = '1' then
				if h_counter = HSCAN then
					if v_counter = VSCAN then
						v_counter <= (others => '0');
					else
						v_counter <= v_counter + 1;
					end if;
				end if;
			end if;
		end if;
	end process Vsync_proc;
	
	V_video_on <= '1' when (v_counter >= v_back_porch and v_counter < V_END_DISPLAY) else '0';
	v_sync_int <= '0' when (v_counter >= V_END_FRONT and v_counter < V_END_RETRACE) else '1';

	hcount <= std_logic_vector(h_counter);
	vcount <= std_logic_vector(v_counter);

	Hsync_port <= h_sync_int;
	Vsync_port <= v_sync_int;

	video_on <= H_video_on and V_video_on; -- only enable video out when H_video_out and V_video_out are high. it's important to set the output to zero when you aren't actively displaying video. that's how the monitor determines the black level.

end behavior;