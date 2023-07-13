library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- For vgaText library
use work.commonPak.all;
-- Variaveis
use work.Corpo.all;

entity gameLogic is
    port(
        --game logic part
        clk_25_175_MHz            : in  std_logic;

        stop                : in  std_logic;--Pausa movimento cobra
        reseta               : in  std_logic;--Reseta jogo
		  --button : in std_logic_vector(2 downto 0);
		  
		  --Display pontos
		  saidaSeg: out std_logic_vector(6 downto 0);
		  saidaSeg2: out std_logic_vector(6 downto 0);
		  
		  --Display game Mode
		  digtMode : OUT std_logic_vector(6 DOWNTO 0);

		  --Comandos jogo 
		  JumpBt		  : in std_logic;
		  
			--Entradas valores
		  cheatcode : IN std_logic_vector(5 DOWNTO 0);
 
		  


		  
		  --Leds representando direção em binário
		  --led : out std_logic;
		  
        clk_50mhz          : in  std_logic;
        en                  : in  std_logic;
        row, col            : in  std_logic_vector(15 downto 0);
		  --rgb
        rout, gout, bout    : out std_logic_vector(3 downto 0));
end gameLogic;

architecture main of gameLogic is
    --                                -----------------------------------------
    --components of 32 bit body part: | 16bit: x position | 16bit: y position |
    --                                -----------------------------------------
    subtype xy is std_logic_vector(31 downto 0);
    type xys is array (integer range <>) of xy;
	constant starty : integer := 400;
	
    --assume the left most xy is the head position
    --signal snake_length         : integer range 0 to snake_length_max;
    signal snake_mesh_xy        : xys(0 to snake_length_max - 1);
    --signal food_xy              : xy;
    --signal random_xy            : unsigned(31 downto 0);
	 signal player_xy : xy;
	 signal enemy_xy : xy;
	 
	 signal points: integer := 0;
	 signal PALTURA : INTEGER := 100;
	signal PLargura : INTEGER := 140;
	signal OALTURA : INTEGER := 100;
	signal OLARGURA : INTEGER := 70;
	
	
		signal segundo :integer :=0;
		signal GRAVITY : INTEGER := 10;
	
	signal Ospeed : INTEGER := 40;
	
begin 



	 

jogo:
    process(clk_25_175_MHz, jumpBt, segundo,reseta)
        --speed in pixel
		  constant startx : integer := 50;
		  
		  
		  constant Estartx : integer := 650;
		  constant Estarty : integer := 400;
		  
		  -- Variables
        variable inited                     : std_logic := '1';

	--Stats
	variable fall_speed : INTEGER := 0;--to_signed(SPEED, 16);
	variable JUMPFORCE : INTEGER := 50;
	

	variable invencible : std_logic := '0';
	
	--Checar colisao
	variable xdiv : integer := 0;
	variable ydiv : integer := 0;
	
    begin
	 
	
        --food_xy         <= food_xy_future;
		  --snake_length    <= snake_length_future;
        if (inited = '0') or reseta = '0' then
		  if reseta = '0'then
		  case cheatcode is
				-- g Gravidade baixa
				when "100111" =>
					digtMode <= "0100000";
					GRAVITY <= 5;
				-- h heitgh menor altura player
				when "101000" =>
					digtMode <= "1001000";
					PAltura <= 50;
				--c cactus menores
				when "100011" =>
					digtMode <= "0110001";
					OALTURA <= 60;
				--f velocidade flash
				when "100110" =>
					digtMode <= "0111000";
					GRAVITY <= 20;
					JUMPFORCE := 70;
					Ospeed <= 100;
				--t tall player alto
				when "110100" =>
					digtMode <= "0111001";
					PAltura<= 160;
				-- w wide player largo
				when "110111" =>
					digtMode <= "1100011";
					plargura <= 240;
					JUMPFORCE := 50;
				--i invencivel
				when "101001" =>
					digtMode <= "1001111";
					invencible := '1';
					
				--Reset
				when others =>	
					digtMode <= "0000000";
					GRAVITY <= 10;
					OALTURA <= 100;
					PAltura <= 100;
					Ospeed <= 40;
					JUMPFORCE := 50;
					plargura <= 140;
					invencible := '0';
			end case;
			end if;
				points <= 0;
            --reset snake length
            --snake_length_future := snake_length_begin;
				
            --Reseta posições
				player_xy(31 downto 16)  <= std_logic_vector(to_signed(startx , 16));--x
            player_xy(15 downto 0)   <= std_logic_vector(to_signed(starty , 16));--y
				enemy_xy(31 downto 16)	<= std_logic_vector(to_signed(Estartx , 16));--x
				enemy_xy(15 downto 0)	<= std_logic_vector(to_signed(Estarty , 16));--y

            inited := '1';
        elsif (falling_edge(clk_25_175_MHz)) then
					segundo <= segundo+1;

					--Cair
					if to_integer(signed(player_xy(15 downto 0))) < starty then
					--Acima do chão logo reduzir  velocidade e não pode pular
						--jump <= '0';
						fall_speed := fall_speed -	GRAVITY;
						player_xy(15 downto 0) <= std_logic_vector(to_signed( to_integer(signed(player_xy(15 downto 0))) - fall_speed , 16));
						
					--Pular
						elsif jumpBt = '0' then
						fall_speed := JUMPFORCE;--Começa a "cair" pra cima
						player_xy(15 downto 0) <= std_logic_vector(to_signed( to_integer(signed(player_xy(15 downto 0))) - fall_speed , 16));
					--no chão pode pular
						else
						
						player_xy(15 downto 0) <=  std_logic_vector(to_signed(starty , 16));
						--jump <= '1';--Led dizendo que pode pular
					end if;
					 
					 
	
					--Teste Colisão (Compara x player com x inimigo) e (yplayer com y do inimgo)
                if signed(player_xy(31 downto 16))+ plargura > signed(enemy_xy(31 downto 16)) and signed(player_xy(31 downto 16)) < signed(enemy_xy(31 downto 16)) + Olargura and
                   signed(player_xy(15 downto 0)) >= (signed(enemy_xy(15 downto 0)) - OALTURA) and invencible = '0' then--Checa se altura colidindo com inimigo
						  xdiv := Plargura/4;
							ydiv := Paltura/7;
							
							--Linha para colisão mais precisa
						 if signed(player_xy(15 downto 0))-(signed(enemy_xy(31 downto 16)) -Plargura) >= (signed(enemy_xy(15 downto 0)) - OALTURA) then
                --    --Morrer
						  inited := '0';
						  end if;
					end if;
					
					--Teste cactos já passou player
					if inited = '1' and -olargura> signed(enemy_xy(31 downto 16)) then
						points <= points+1;
						--Respawn obstaculo
						enemy_xy(31 downto 16)	<= std_logic_vector(to_signed(Estartx , 16));--x
						enemy_xy(15 downto 0)	<= std_logic_vector(to_signed(Estarty , 16));--y
           
						
				
						--Mover Obstaculo
						else
						enemy_xy(31 downto 16)<= std_logic_vector(to_signed( to_integer(signed(enemy_xy(31 downto 16))) - Ospeed, 16));
					end if;
					
			--	end if;
		
        end if;
    end process;


draw:
    process(player_xy,enemy_xy, row, col, en)
        --x and y distance from body part or food
        variable dx, dy             : signed(15 downto 0) := (others => '0');
        --if current pixel is belong to body or food
        variable is_player, is_enemy   : std_logic := '0';
		  variable xdiv : integer := 0;
		  variable ydiv : integer := 0;
    begin
        if (en = '1') then 
            --draw body
            is_player := '0';
			
                dx := signed(col) - signed(player_xy(31 downto 16));
                dy := signed(row) - signed(player_xy(15 downto 0));
                    if (dx < Plargura   and dx > 0 and dy < 0 and dy > -Paltura) then
                        
								xdiv := Plargura/4;
								ydiv := Paltura/7;
								--Calda
								if dx <= xdiv and dx > 0  and ( dy < -ydiv+dx-ydiv*3 and dy > -ydiv * 3 +dx/2 -ydiv*2)then
									is_player := '1';
									--pés e costas
									elsif dx <= xdiv*2 and dx > xdiv and ((dy <= 0 and dy > -ydiv and ( dx <= (xdiv + xdiv/3) or dx > (xdiv + xdiv*2/3))) or (dy <= -ydiv and dy > -(dx - xdiv)*3 -ydiv*7/2))then 
									is_player := '1';
									--Barriga e boca
									elsif dx <= xdiv*3 and dx > xdiv*2 and (dy <= -(dx - xdiv*2)*2 -ydiv*2 or dy <= -ydiv*3 - ydiv/2) then
									is_player := '1';
									--cabeça
									elsif dx <= xdiv*4 and dx > xdiv*3 and dy < -ydiv*4 then 
									is_player := '1';
									else
									is_player := '0';
								end if;
                    end if;

            dx := signed(col) - signed(enemy_xy(31 downto 16));
            dy := signed(row) - signed(enemy_xy(15 downto 0));
            if (dx < Olargura and dx > 0 and dy < 0 and dy > -Oaltura) then
						xdiv := Olargura/5;
						ydiv := Oaltura/5;
						if dx > xdiv*2 and dx < xdiv*3 then
							is_enemy := '1';
							elsif dy < -ydiv*2 and dy > -ydiv*3 then
							is_enemy := '1';
							elsif (dx <= xdiv or dx >= xdiv*4) and dy <= -ydiv*3 and dy >= -ydiv*4 then
							is_enemy := '1';
							else
							is_enemy := '0';
						end if;
            else 
                is_enemy := '0';
            end if;

            if (is_enemy = '1') then --cor obstaculo
                rout <= "0000";
                gout <= "1111";
                bout <= "0000";
            elsif (is_player = '1') then --cor player
                rout <= "1011";
                gout <= "1101";
                bout <= "1111";
				elsif signed(row) > starty then 
				    rout <= "1100";
                gout <= "1011";
                bout <= "1010";
            else--Cor fundo
                rout <= "1111";
                gout <= "1111";
                bout <= "1111";
            end if;
        else--Cor fundo
            rout <= "0011";
            gout <= "0011";
            bout <= "0011";
        end if;
    end process;
	 
	contador : process(points)
	
	variable num : integer := 0;
	variable dez : integer := 0;
	
	begin
	
		num := points MOD 10;
		dez := abs(points)/10 MOD 10 ;
	--Pontuação no display 7 segmentos
		case num is
			when 0 => 
							saidaSeg2<= "1000000"; -- 0
			when 1 => 
							saidaSeg2<= "1111001"; -- 1
			when 2 => 
							saidaSeg2<= "0100100"; -- 2
			when 3 => 
							saidaSeg2<= "0110000"; -- 3
			when 4 => 
							saidaSeg2<= "0011001"; -- 4
			when 5 => 
							saidaSeg2<= "0010010"; -- 5
			when 6 => 
							saidaSeg2<= "0000010"; -- 6
			when 7 => 
							saidaSeg2<= "1111000"; -- 7
			when 8 => 
							saidaSeg2<= "0000000"; -- 8
			when 9 => 
							saidaSeg2 <= "0010000"; -- 0
			
			when others =>
							saidaSeg2<= "1110111"; -- -
			end case;
			--Fazer segundo divido/10
			case dez is
			when 0 => 
							saidaSeg<= "1000000"; -- 0
			when 1 => 
							saidaSeg<= "1111001"; -- 1
			when 2 => 
							saidaSeg<= "0100100"; -- 2
			when 3 => 
							saidaSeg<= "0110000"; -- 3
			when 4 => 
							saidaSeg<= "0011001"; -- 4
			when 5 => 
							saidaSeg<= "0010010"; -- 5
			when 6 => 
							saidaSeg<= "0000010"; -- 6
			when 7 => 

							saidaSeg<= "1111000"; -- 7
			when 8 => 
							saidaSeg<= "0000000"; -- 8
			when 9 => 
							saidaSeg <= "0010000"; -- 0
			
			when others =>
					   	saidaSeg <= "1110111"; -- -
			end case;
	end process;


	 
end main;