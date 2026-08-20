--=============================================================
-- ENGS 31 FINAL PROJECT 
--=============================================================
-- Conway's Game of Life on VGA
-- VGA SYNC
-- Attempt 1
-- Last Edited 8/19/26
--=============================================================

--=============================================================
-- Explanation
--=============================================================
-- controls the syncing functions of the vga
--=============================================================

--=============================================================
--Library Declarations
--=============================================================
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--=============================================================

--=============================================================
--Entity Declarations
--=============================================================
entity vga_sync is
port	(
	--INPUT PORTS
	clk			    : in std_logic; -- from top level
	reset_db		: in std_logic; -- from debouncer
	
	--OUTPUT PORTS
	hsync_port		: out std_logic;			-- to display
	vsync_port		: out std_logic;			-- to display
	);
end vga_sync;
--=============================================================

architecture behavior of vga_sync is

-- signal declaration 
signal H_video_on 	    : std_logic := '0';
signal V_video_on 	    : std_logic := '0';

signal h_counter 	    : unsigned (9 downto 0) := (others => '0');
signal v_counter 	    : unsigned (9 downto 0) := (others => '0');

signal h_sync_int	    : std_logic := '0';
signal v_sync_int	    : std_logic := '0';

--VGA Constants (taken directly from VGA Class Notes)

constant left_border    : integer := 48;
constant h_display      : integer := 640;
constant right_border   : integer := 16;
constant h_retrace      : integer := 96;
constant HSCAN          : integer := left_border + h_display + right_border + h_retrace - 1; --number of PCLKs in an H_sync period


constant top_border     : integer := 29;
constant v_display      : integer := 480;
constant bottom_border  : integer := 10;
constant v_retrace      : integer := 2;
constant VSCAN          : integer := top_border + v_display + bottom_border + v_retrace - 1; --number of H_syncs in an V_sync period

constant H_END_DISPLAY : integer := left_border + h_display;
constant H_END_RIGHT   : integer := left_border + h_display + right_border;
constant H_END_RETRACE : integer := left_border + h_display + right_border + h_retrace; 

constant V_END_DISPLAY : integer := top_border + v_display;
constant V_END_BOTTOM  : integer := top_border + v_display + bottom_border;
constant V_END_RETRACE : integer := top_border + v_display + bottom_border + v_retrace; 

BEGIN

--H_sync generating process
Hsync_proc : process(clk)
begin
	if rising_edge(clk) then
        	if h_counter = HSCAN then 
            		h_counter <= (others => '0'); 
        	else 
        		h_counter <= h_counter + 1; 
        	end if;
            
            	if (h_counter >= left_border and h_counter < H_END_DISPLAY) then
            		H_video_on <= '1';
           	 else    
            		H_video_on <= '0';
          	end if;
            
            	if (h_counter >= H_END_DISPLAY and h_counter < H_END_RETRACE) then
            		h_sync_int <= '0'; 
            	else 
            		h_sync_int <= '1';
            	end if;
        end if;
end process Hsync_proc;

--V_sync generating process
Vsync_proc : process(clk)
begin
	if rising_edge(clk) then
    		if h_counter = HSCAN then 
        		if v_counter = VSCAN then 
            			v_counter <= (others => '0');
            		else 
               			v_counter <= v_counter + 1;
            		end if;
                
            		if (v_counter >= top_border and v_counter < V_END_DISPLAY) then
               			V_video_on <= '1';
            		else
               			V_video_on <= '0';
            		end if;
                
            		if (v_counter >= V_END_DISPLAY and v_counter < V_END_RETRACE) then
               			v_sync_int <= '0'; 
           	 	else 
               			v_sync_int <= '1';
            		end if; 
		end if;                 
	end if;
end process Vsync_proc;

Hsync_port <= h_sync_int;
Vsync_port <= v_sync_int;

video_on <= H_video_on AND V_video_on; --Only enable video out when H_video_out and V_video_out are high. It's important to set the output to zero when you aren't actively displaying video. That's how the monitor determines the black level.

end behavior;
