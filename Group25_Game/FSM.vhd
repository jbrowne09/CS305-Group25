library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
	port 
	(Clk 			: in std_logic;
	SW_0 			: in std_logic;
	PB_0 			: in std_logic;
	Ship_Alive	: in std_logic;

	State			: out std_logic_vector(1 DOWNTO 0)
	);

end FSM;

architecture behaviour of FSM is
	
	type STATES is (MENU, TRAINING, NORMAL, GAMEOVER);
	SIGNAL current_state, next_state : STATES := MENU;
	SIGNAL CHANGING : std_logic := '0';
begin
	process(Clk)
	begin
		if (Clk'event AND Clk = '1') then
		
			case current_state is
				when MENU =>
					if (pb_0 = '0' AND CHANGING <= '0') then
						if (SW_0 = '1') then
							next_state <= TRAINING;
						elsif (SW_0 = '0') then
							next_state <= NORMAL;
						end if;
						
						CHANGING <= '1';
					end if;
				
					State <= "00";
				
				when TRAINING =>
					if(Ship_Alive = '0') then
						next_state <= GAMEOVER;
						
						CHANGING <= '1';
					end if;
				
					State <= "01";
				
				when NORMAL =>
					if(Ship_Alive = '0') then
						next_state <= GAMEOVER;
						
						CHANGING <= '1';
					end if;
				
					State <= "10";
				
				when GAMEOVER =>
					if (pb_0 = '0' AND CHANGING = '0') then
						next_state <= MENU;
						
						CHANGING <= '1';
					end if;
				
					State <= "11";	
			end case;
			
			current_state <= next_state;
			
			--Prevent instant state change from menu to game when leaving gameover.
			if (pb_0 = '1') then
				CHANGING <= '0';
			end if;
			
		end if;
	end process;
end architecture behaviour;

