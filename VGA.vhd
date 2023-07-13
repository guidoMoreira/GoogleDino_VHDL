library IEEE;
use IEEE.STd_LOGIC_1164.all;
use IEEE.STd_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
library work;


-- For vgaText library
use work.commonPak.all;
-- Variaveis
use work.Corpo.all;

entity vga is
	generic (

        -- RGB, 4 bits each
        g_bg_color : integer := 16#777#;
        g_text_color : integer := 16#000#;
		  red  : integer := 16#F00#;
		  green : integer := 16#0F0#;
		  blue : integer := 16#00F#
    );
	port (
		  buttonjp										 : in STD_LOGIC;--bt_reset
		  btreseta										 : in STD_LOGIC;--bt_jump
		  cheatc : IN std_logic_vector(5 DOWNTO 0);-- codigo cheat
		  
		  digitoct : out std_logic_vector(6 downto 0);
		  
		  MAX10_CLK1_50                      : IN STD_LOGIC; -- 50 MHz clock input
		  
		  --led : out std_logic_VECTOR(1 DOWNTO 0);
		  SevenSeg: out std_logic_vector(0 to 6);
		  SevenSeg2: out std_logic_vector(0 to 6);
        -- VGA I/O  
        VGA_HS		         :	OUT	 STD_LOGIC;	-- horizontal sync pulse
        VGA_VS		         :	OUT	 STD_LOGIC;	-- vertical sync pulse 
        
        VGA_R                 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  -- red magnitude output to DAC
        VGA_G                 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0');  -- green magnitude output to DAC
        VGA_B                 :  OUT  STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'));  -- blue magnitude output to DAC
end VGA;

architecture alo of VGA is
	
	component vga_pll_25_175 is 
        port(
            inclk0		:	IN  STD_LOGIC := '0';  -- Input clock that gets divided (50 MHz for max10)
            c0			:	OUT STD_LOGIC          -- Output clock for vga timing (25.175 MHz)
        );
    end component;
	 
	component gameLogic is
		 port(
        clk_25_175_MHz            : in  std_logic;
        stop                : in  std_logic;--Pausa movimento cobra
        reseta               : in  std_logic;--Reseta jogo
		  saidaSeg: out std_logic_vector(6 downto 0);
		  saidaSeg2: out std_logic_vector(6 downto 0);
		  digtMode : OUT std_logic_vector(6 DOWNTO 0);
		  JumpBt		  : in std_logic;
		  cheatcode : IN std_logic_vector(5 DOWNTO 0);
        clk_50mhz          : in  std_logic;
        en                  : in  std_logic;
        row, col            : in  std_logic_vector(15 downto 0);
        rout, gout, bout    : out std_logic_vector(3 downto 0)
			  );
	end component;

	 
	 signal clk_25_175_MHz: STD_LOGIC;
	 signal disp_en : STD_LOGIC;
	 signal reset : STD_LOGIC := '1';
	 signal row : integer range 0 to c_screen_height-1;
    signal column : INTEGER range 0 to c_screen_width-1;
	 signal row_vector   : std_logic_vector(15 downto 0);
	 signal column_vector: std_logic_vector(15 downto 0);
	 signal stop : std_logic;
	 signal clk_60hz : std_logic;
	 
	 begin 
	 

	 
	-- VGA
	U1	:	vga_pll_25_175 port map (inclk0 => MAX10_CLK1_50, c0 => clk_25_175_MHz);
   U2	:	entity work.vga_controller port map (
			pixel_clk => clk_25_175_MHz,
			reset_n => '1',
			h_sync => VGA_HS,
			v_sync => VGA_VS,
			disp_ena => disp_en,
			column => column,
			row => row,
			n_blank => open,
			n_sync => open
		);
		
	 row_vector    <= std_logic_vector(to_unsigned(row, 16));
    column_vector <= std_logic_vector(to_unsigned(column, 16));	
	
	U3: gameLogic port map(
        clk_25_175_MHz    => clk_60hz,
        stop        => stop,
        reseta       => btreseta,
		  saidaSeg => SevenSeg,
		  saidaSeg2 =>SevenSeg2,
		  
		  digtMode => digitoct,
		  
		  JumpBt =>buttonjp,
		  cheatcode =>cheatc,
		  
		  
		  
        clk_50mhz  => MAX10_CLK1_50,
        en      => disp_en,
        row     => row_vector,
        col     => column_vector,
        rout    => VGA_R,
        gout    => VGA_G,
        bout    => VGA_B);
 

	use_clk_60hz:
		process(clk_25_175_MHz)
		  --counter reverts in 25 / x = 120hz
		  constant counter_max    : integer := 833333;

		  variable counter        : integer range 0 to counter_max - 1 := 0;
		  variable clk_60hz_future: std_logic := '0';
		begin 
		  if (rising_edge(clk_25_175_MHz)) then 
				if (counter = counter_max - 1) then
					 counter := 0;
					 clk_60hz_future := not clk_60hz_future;
				else
					 counter := counter + 1;
				end if;
		  end if;
		  clk_60hz <= clk_60hz_future;
		end process;
	
end alo;
