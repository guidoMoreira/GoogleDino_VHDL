library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package Corpo is

    -- Constants
    constant c_num_text_elems: integer := 8;
    constant c_screen_width  : integer := 640;
    constant c_screen_height : integer := 480;
    constant c_bar_height    : integer := 3;
    constant c_bar_offset    : integer := 30;
    constant c_upper_bar_pos : integer := c_bar_offset - c_bar_height;
    constant c_lower_bar_pos : integer := c_screen_height - c_bar_offset;
	

    -- Initial conditions
    constant food_begin_x        : integer := 100;
    constant food_begin_y        : integer := 100;
	 constant snake_begin_x       : integer := 320;
    constant snake_begin_y       : integer := 240;
	 constant snake_length_begin  : integer := 1;
    constant snake_length_max    : integer := 40;
	 
    -- Integer ranges
    constant food_width  : integer := 20;
    constant head_width  : integer := 20;

	 
	

end Corpo;
