LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;


ENTITY SevenSegConverter IS
   PORT(ScoreTHOUSAND, ScoreHUNDRED, ScoreTEN, ScoreONE : IN std_logic_vector(3 DOWNTO 0);
        Seg3, Seg2, Seg1, Seg0 					: OUT std_logic_vector(6 DOWNTO 0)
		  );
END SevenSegConverter;

architecture behavior of SevenSegConverter is
begin
	process (ScoreTHOUSAND, ScoreHUNDRED, ScoreTEN, ScoreONE)
		variable currentScore : std_logic_vector(3 DOWNTO 0);
		variable output : std_logic_vector(6 DOWNTO 0);
	begin
	
		conv : FOR k IN 0 TO 3 LOOP
		
			case k is
				when 0 => currentScore := ScoreTHOUSAND;
				when 1 => currentScore := ScoreHUNDRED;
				when 2 => currentScore := ScoreTEN;
				when 3 => currentScore := ScoreONE;
			end case;
			
			case currentScore is
				when "0000" => output := "1000000"; --0
				when "0001" => output := "1111001"; --1
				when "0010" => output := "0100100"; --2
				when "0011" => output := "0110000"; --3
				when "0100" => output := "0011001"; --4
				when "0101" => output := "0010010"; --5
				when "0110" => output := "0000010"; --6
				when "0111" => output := "1111000"; --7
				when "1000" => output := "0000000"; --8
				when "1001" => output := "0011000"; --9
				when others => output := "1111111"; --all segs off (error case)
			end case;
			
			case k is
				when 0 => seg0 <= output;
				when 1 => seg1 <= output;
				when 2 => seg2 <= output;
				when 3 => seg3 <= output;
			end case;
		END LOOP conv;
	end process;

END behavior;