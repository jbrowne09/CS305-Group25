library ieee;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;

entity TEXT is
	port(	Clk 							: in std_logic;
			State 						: in std_logic_vector(1 DOWNTO 0);
			vert_sync_int				: IN std_logic;
			pixel_row					: in std_logic_vector(9 DOWNTO 0);
			pixel_column				: in std_logic_vector(9 DOWNTO 0);
			char_data 					: in std_logic;
			scoreTHOUSAND				: in std_logic_vector(3 DOWNTO 0);
			scoreHUNDRED				: in std_logic_vector(3 DOWNTO 0);
			scoreTEN						: in std_logic_vector(3 DOWNTO 0);
			scoreONE						: in std_logic_vector(3 DOWNTO 0);
			switchIN						: in std_logic;
			
			char_address				: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			char_row						: OUT std_logic_vector(2 DOWNTO 0);
			char_col						: OUT std_logic_vector(2 DOWNTO 0);
			char_on						: OUT std_logic;
			char_Colour					: OUT std_logic_vector(11 DOWNTO 0)
			);

end TEXT;

architecture behaviour of TEXT is
	
	type CHARACTERS is (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, 
		ZERO, ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, SPACE, COLON);
	
	SIGNAL currentCHAR : CHARACTERS := A;
	SIGNAL thousands : CHARACTERS := ZERO;
	SIGNAL hundreds : CHARACTERS := ZERO;
	SIGNAL tens : CHARACTERS := ZERO;
	SIGNAL ones : CHARACTERS := ZERO;
	SIGNAL printCHAR : std_logic;
	
	--MENU LINES
	SIGNAL menuLine1X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(128,10);
	SIGNAL menuLine1Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(56,10);
	
	SIGNAL menuLine2X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(176,10);
	SIGNAL menuLine2Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(124,10);
	
	SIGNAL menuLine3X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(168,10);
	SIGNAL menuLine3Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(284,10);
	
	SIGNAL menuLine4X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(168,10);
	SIGNAL menuLine4Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(316,10);
	
	SIGNAL menuLine5X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(144,10);
	SIGNAL menuLine5Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(408,10);
	--
	
	--TRAINING LINES
	SIGNAL trainingLine1X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	SIGNAL trainingLine1Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	--
	
	--NORMAL LINES
	SIGNAL normalLine1X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	SIGNAL normalLine1Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	
	SIGNAL normalLine2X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	SIGNAL normalLine2Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(36,10);
	
	SIGNAL normalFuelX  : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(34,10);
	SIGNAL normalFuelY  : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(64,10);
	--
	
	--GAMEOVER LINES
	SIGNAL gameoverLine1X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(192,10);
	SIGNAL gameoverLine1Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(56,10);
	
	SIGNAL gameoverLine2X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(192,10);
	SIGNAL gameoverLine2Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(124,10);
	
	SIGNAL gameoverLine3X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(144,10);
	SIGNAL gameoverLine3Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(252,10);
	
	SIGNAL gameoverLine4X : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(144,10);
	SIGNAL gameoverLine4Y : std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(408,10);
	--
begin
	process (pixel_row, pixel_column)
		VARIABLE scaledCol, scaledRow : std_logic_vector(9 DOWNTO 0);
	begin
		
		--get thousands digit
		case ScoreTHOUSAND is 
				when "0000" => thousands <= ZERO;
				when "0001" => thousands <= ONE;
				when "0010" => thousands <= TWO;
				when "0011" => thousands <= THREE;
				when "0100" => thousands <= FOUR;
				when "0101" => thousands <= FIVE;
				when "0110" => thousands <= SIX;
				when "0111" => thousands <= SEVEN;
				when "1000" => thousands <= EIGHT;
				when "1001" => thousands <= NINE;
				when others => thousands <= E;
		end case;
		
		--get hundreds digit
		case ScoreHUNDRED is 
				when "0000" => hundreds <= ZERO;
				when "0001" => hundreds <= ONE;
				when "0010" => hundreds <= TWO;
				when "0011" => hundreds <= THREE;
				when "0100" => hundreds <= FOUR;
				when "0101" => hundreds <= FIVE;
				when "0110" => hundreds <= SIX;
				when "0111" => hundreds <= SEVEN;
				when "1000" => hundreds <= EIGHT;
				when "1001" => hundreds <= NINE;
				when others => hundreds <= E;
		end case;
		
		--get tens digit
		case ScoreTEN is 
				when "0000" => tens <= ZERO;
				when "0001" => tens <= ONE;
				when "0010" => tens <= TWO;
				when "0011" => tens <= THREE;
				when "0100" => tens <= FOUR;
				when "0101" => tens <= FIVE;
				when "0110" => tens <= SIX;
				when "0111" => tens <= SEVEN;
				when "1000" => tens <= EIGHT;
				when "1001" => tens <= NINE;
				when others => tens <= E;
		end case;
		
		--get ones digit
		case ScoreONE is 
				when "0000" => ones <= ZERO;
				when "0001" => ones <= ONE;
				when "0010" => ones <= TWO;
				when "0011" => ones <= THREE;
				when "0100" => ones <= FOUR;
				when "0101" => ones <= FIVE;
				when "0110" => ones <= SIX;
				when "0111" => ones <= SEVEN;
				when "1000" => ones <= EIGHT;
				when "1001" => ones <= NINE;
				when others => ones <= E;
		end case;
		
		--easier letter reference (dont have to change address all the time).
		case currentCHAR is
			when A 		=> char_address <= "000001"; --01
			when B 		=> char_address <= "000010"; --02
			when C 		=> char_address <= "000011"; --03
			when D 		=> char_address <= "000100"; --04
			when E 		=> char_address <= "000101"; --05
			when F 		=> char_address <= "000110"; --06
			when G 		=> char_address <= "000111"; --07
			when H 		=> char_address <= "001000"; --10
			when I 		=> char_address <= "001001"; --11
			when J 		=> char_address <= "001010"; --12
			when K 		=> char_address <= "001011"; --13
			when L 		=> char_address <= "001100"; --14
			when M 		=> char_address <= "001101"; --15
			when N 		=> char_address <= "001110"; --16
			when O 		=> char_address <= "001111"; --17
			when P 		=> char_address <= "010000"; --20
			when Q 		=> char_address <= "010001"; --21
			when R 		=> char_address <= "010010"; --22
			when S 		=> char_address <= "010011"; --23
			when T 		=> char_address <= "010100"; --24
			when U 		=> char_address <= "010101"; --25
			when V 		=> char_address <= "010110"; --26
			when W		=> char_address <= "010111"; --27
			when X		=> char_address <= "011000"; --30
			when Y 		=> char_address <= "011001"; --31
			when Z 		=> char_address <= "011010"; --32
			when ZERO	=> char_address <= "110000"; --60
			when ONE 	=> char_address <= "110001"; --61
			when TWO 	=> char_address <= "110010"; --62
			when THREE 	=> char_address <= "110011"; --63
			when FOUR 	=> char_address <= "110100"; --64
			when FIVE 	=> char_address <= "110101"; --65
			when SIX 	=> char_address <= "110110"; --66
			when SEVEN 	=> char_address <= "110111"; --67
			when EIGHT 	=> char_address <= "111000"; --70
			when NINE 	=> char_address <= "111001"; --71
			when SPACE 	=> char_address <= "100000"; --40
			when COLON 	=> char_address <= "111111"; --77
			when others => char_address <= "000000"; --00 (others case displays lower e for ERROR)
		end case;
	
		--reset printCHAR for all states, a particular state can set printCHAR to '1'
		--if it has a character pixel to print at the current row and column.
		printCHAR <= '0';
	
		case State is
			--MENU STATE
			when "00" =>	
				IF (unsigned(pixel_row) >= unsigned(menuLine1Y) AND unsigned(pixel_row) < unsigned(menuLine1Y + 64)) THEN
					
					char_Colour <= "111111111111";
					
					Mline1 : FOR k IN 0 TO 5 LOOP
					
						scaledCol := pixel_column - (menuLine1X + k*64);
						scaledRow := pixel_row - menuLine1Y;
						
						IF (unsigned(pixel_column) >= unsigned(menuLine1X + k*64) AND unsigned(pixel_column) < unsigned(menuLine1X + ((k+1)*64))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= B;
								WHEN 1 => currentCHAR <= O;
								WHEN 2 => currentCHAR <= U;
								WHEN 3 => currentCHAR <= N;
								WHEN 4 => currentCHAR <= C;
								WHEN 5 => currentCHAR <= Y;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Mline1;
					
					char_col <= scaledCol(5 downto 3);
					char_row <= scaledRow(5 downto 3);
					
				ELSIF (unsigned(pixel_row) >= unsigned(menuLine2Y) AND unsigned(pixel_row) < unsigned(menuLine2Y + 32)) THEN
					
					char_Colour <= "111111111111";
					
					Mline2 : FOR k IN 0 TO 8 LOOP
					
						scaledCol := pixel_column - (menuLine2X + k*32);
						scaledRow := pixel_row - menuLine2Y;
						
						IF (unsigned(pixel_column) >= unsigned(menuLine2X + k*32) AND unsigned(pixel_column) < unsigned(menuLine2X + ((k+1)*32))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= S;
								WHEN 1 => currentCHAR <= P;
								WHEN 2 => currentCHAR <= A;
								WHEN 3 => currentCHAR <= C;
								WHEN 4 => currentCHAR <= E;
								WHEN 5 => currentCHAR <= S;
								WHEN 6 => currentCHAR <= H;
								WHEN 7 => currentCHAR <= I;
								WHEN 8 => currentCHAR <= P;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Mline2;
					
					char_col <= scaledCol(4 downto 2);
					char_row <= scaledRow(4 downto 2);
					
				ELSIF (unsigned(pixel_row) >= unsigned(menuLine3Y) AND unsigned(pixel_row) < unsigned(menuLine3Y + 16)) THEN
					
					IF (switchIN = '1') THEN
						char_Colour <= "111111110000";
					ELSE
						char_Colour <= "111111111111";
					END IF;
					
					Mline3 : FOR k IN 0 TO 18 LOOP
					
						scaledCol := pixel_column - (menuLine3X + k*16);
						scaledRow := pixel_row - menuLine3Y;
						
						IF (unsigned(pixel_column) >= unsigned(menuLine3X + k*16) AND unsigned(pixel_column) < unsigned(menuLine3X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= S;
								WHEN 1 => currentCHAR <= W;
								WHEN 2 => currentCHAR <= ZERO;
								WHEN 3 => currentCHAR <= SPACE;
								WHEN 4 => currentCHAR <= U;
								WHEN 5 => currentCHAR <= P;
								WHEN 6 => currentCHAR <= SPACE;
								WHEN 7 => currentCHAR <= F;
								WHEN 8 => currentCHAR <= O;
								WHEN 9 => currentCHAR <= R;
								WHEN 10 => currentCHAR <= SPACE;
								WHEN 11 => currentCHAR <= T;
								WHEN 12 => currentCHAR <= R;
								WHEN 13 => currentCHAR <= A;
								WHEN 14 => currentCHAR <= I;
								WHEN 15 => currentCHAR <= N;
								WHEN 16 => currentCHAR <= I;
								WHEN 17 => currentCHAR <= N;
								WHEN 18 => currentCHAR <= G;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Mline3;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
					
				ELSIF (unsigned(pixel_row) >= unsigned(menuLine4Y) AND unsigned(pixel_row) < unsigned(menuLine4Y + 16)) THEN
					
					IF (switchIN = '0') THEN
						char_Colour <= "111111110000";
					ELSE
						char_Colour <= "111111111111";
					END IF;
					
					Mline4 : FOR k IN 0 TO 18 LOOP
					
						scaledCol := pixel_column - (menuLine4X + k*16);
						scaledRow := pixel_row - menuLine4Y;
						
						IF (unsigned(pixel_column) >= unsigned(menuLine4X + k*16) AND unsigned(pixel_column) < unsigned(menuLine4X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= S;
								WHEN 1 => currentCHAR <= W;
								WHEN 2 => currentCHAR <= ZERO;
								WHEN 3 => currentCHAR <= SPACE;
								WHEN 4 => currentCHAR <= D;
								WHEN 5 => currentCHAR <= O;
								WHEN 6 => currentCHAR <= W;
								WHEN 7 => currentCHAR <= N;
								WHEN 8 => currentCHAR <= SPACE;
								WHEN 9 => currentCHAR <= F;
								WHEN 10 => currentCHAR <= O;
								WHEN 11 => currentCHAR <= R;
								WHEN 12 => currentCHAR <= SPACE;
								WHEN 13 => currentCHAR <= N;
								WHEN 14 => currentCHAR <= O;
								WHEN 15 => currentCHAR <= R;
								WHEN 16 => currentCHAR <= M;
								WHEN 17 => currentCHAR <= A;
								WHEN 18 => currentCHAR <= L;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Mline4;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
					
				ELSIF (unsigned(pixel_row) >= unsigned(menuLine5Y) AND unsigned(pixel_row) < unsigned(menuLine5Y + 16)) THEN
					
					char_Colour <= "111111111111";

					Mline5 : FOR k IN 0 TO 21 LOOP
					
						scaledCol := pixel_column - (menuLine5X + k*16);
						scaledRow := pixel_row - menuLine5Y;
						
						IF (unsigned(pixel_column) >= unsigned(menuLine5X + k*16) AND unsigned(pixel_column) < unsigned(menuLine5X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= P;
								WHEN 1 => currentCHAR <= R;
								WHEN 2 => currentCHAR <= E;
								WHEN 3 => currentCHAR <= S;
								WHEN 4 => currentCHAR <= S;
								WHEN 5 => currentCHAR <= SPACE;
								WHEN 6 => currentCHAR <= B;
								WHEN 7 => currentCHAR <= U;
								WHEN 8 => currentCHAR <= T;
								WHEN 9 => currentCHAR <= T;
								WHEN 10 => currentCHAR <= O;
								WHEN 11 => currentCHAR <= N;
								WHEN 12 => currentCHAR <= ZERO;
								WHEN 13 => currentCHAR <= SPACE;
								WHEN 14 => currentCHAR <= T;
								WHEN 15 => currentCHAR <= O;
								WHEN 16 => currentCHAR <= SPACE;
								WHEN 17 => currentCHAR <= S;
								WHEN 18 => currentCHAR <= T;
								WHEN 19 => currentCHAR <= A;
								WHEN 20 => currentCHAR <= R;
								WHEN 21 => currentCHAR <= T;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Mline5;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				END IF;
				
			--TRAINING STATE
			when "01" => 
				IF (unsigned(pixel_row) >= unsigned(trainingLine1Y) AND unsigned(pixel_row) < unsigned(trainingLine1Y + 16)) THEN
					
					char_Colour <= "111111111111";
					
					Tline1 : FOR k IN 0 TO 7 LOOP
					
						scaledCol := pixel_column - (trainingLine1X + k*16);
						scaledRow := pixel_row - trainingLine1Y;
						
						IF (unsigned(pixel_column) >= unsigned(trainingLine1X + k*16) AND unsigned(pixel_column) < unsigned(trainingLine1X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= T;
								WHEN 1 => currentCHAR <= R;
								WHEN 2 => currentCHAR <= A;
								WHEN 3 => currentCHAR <= I;
								WHEN 4 => currentCHAR <= N;
								WHEN 5 => currentCHAR <= I;
								WHEN 6 => currentCHAR <= N;
								WHEN 7 => currentCHAR <= G;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Tline1;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				END IF;
			
			--NORMAL STATE
			when "10" => 
				IF (unsigned(pixel_row) >= unsigned(normalLine1Y) AND unsigned(pixel_row) < unsigned(normalLine1Y + 16) AND unsigned(pixel_column) < unsigned(normalLine1X + 96)) THEN
					
					char_Colour <= "111111111111";
					
					Nline1 : FOR k IN 0 TO 5 LOOP
					
						scaledCol := pixel_column - (normalLine1X + k*16);
						scaledRow := pixel_row - normalLine1Y;
						
						IF (unsigned(pixel_column) >= unsigned(normalLine1X + k*16) AND unsigned(pixel_column) < unsigned(normalLine1X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= N;
								WHEN 1 => currentCHAR <= O;
								WHEN 2 => currentCHAR <= R;
								WHEN 3 => currentCHAR <= M;
								WHEN 4 => currentCHAR <= A;
								WHEN 5 => currentCHAR <= L;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Nline1;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				
				ELSIF (unsigned(pixel_row) >= unsigned(normalFuelY) AND unsigned(pixel_row) < unsigned(normalFuelY + 16)) THEN
					
					char_Colour <= "111111111111";
					
					NFuel : FOR k IN 0 TO 3 LOOP
					
						scaledCol := pixel_column - (normalFuelX + k*16);
						scaledRow := pixel_row - normalFuelY;
						
						IF (unsigned(pixel_column) >= unsigned(normalFuelX + k*16) AND unsigned(pixel_column) < unsigned(normalFuelX + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= F;
								WHEN 1 => currentCHAR <= U;
								WHEN 2 => currentCHAR <= E;
								WHEN 3 => currentCHAR <= L;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP NFuel;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				
				ELSIF (unsigned(pixel_row) >= unsigned(normalLine2Y) AND unsigned(pixel_row) < unsigned(normalLine2Y + 16)) THEN
					
					char_Colour <= "111111111111";
					
					Nline2 : FOR k IN 0 TO 9 LOOP
					
						scaledCol := pixel_column - (normalLine2X + k*16);
						scaledRow := pixel_row - normalLine2Y;
						
						IF (unsigned(pixel_column) >= unsigned(normalLine2X + k*16) AND unsigned(pixel_column) < unsigned(normalLine2X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= S;
								WHEN 1 => currentCHAR <= C;
								WHEN 2 => currentCHAR <= O;
								WHEN 3 => currentCHAR <= R;
								WHEN 4 => currentCHAR <= E;
								WHEN 5 => currentCHAR <= COLON;
								WHEN 6 => currentCHAR <= thousands;
								WHEN 7 => currentCHAR <= hundreds;
								WHEN 8 => currentCHAR <= tens;
								WHEN 9 => currentCHAR <= ones;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP Nline2;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				END IF;
			
			--GAMEOVER STATE
			when "11" =>
				IF (unsigned(pixel_row) >= unsigned(gameoverLine1Y) AND unsigned(pixel_row) < unsigned(gameoverLine1Y + 64)) THEN
					
					char_Colour <= "111111111111";
					
					GOline1 : FOR k IN 0 TO 3 LOOP
					
						scaledCol := pixel_column - (gameoverLine1X + k*64);
						scaledRow := pixel_row - gameoverLine1Y;
						
						IF (unsigned(pixel_column) >= unsigned(gameoverLine1X + k*64) AND unsigned(pixel_column) < unsigned(gameoverLine1X + ((k+1)*64))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= G;
								WHEN 1 => currentCHAR <= A;
								WHEN 2 => currentCHAR <= M;
								WHEN 3 => currentCHAR <= E;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP GOline1;
					
					char_col <= scaledCol(5 downto 3);
					char_row <= scaledRow(5 downto 3);
				
				ELSIF (unsigned(pixel_row) >= unsigned(gameoverLine2Y) AND unsigned(pixel_row) < unsigned(gameoverLine2Y + 64)) THEN
					
					char_Colour <= "111111111111";
					
					GOline2 : FOR k IN 0 TO 3 LOOP
					
						scaledCol := pixel_column - (gameoverLine2X + k*64);
						scaledRow := pixel_row - gameoverLine2Y;
						
						IF (unsigned(pixel_column) >= unsigned(gameoverLine2X + k*64) AND unsigned(pixel_column) < unsigned(gameoverLine2X + ((k+1)*64))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= O;
								WHEN 1 => currentCHAR <= V;
								WHEN 2 => currentCHAR <= E;
								WHEN 3 => currentCHAR <= R;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP GOline2;
					
					char_col <= scaledCol(5 downto 3);
					char_row <= scaledRow(5 downto 3);
					
				ELSIF (unsigned(pixel_row) >= unsigned(gameoverLine3Y) AND unsigned(pixel_row) < unsigned(gameoverLine3Y + 32)) THEN
					
					char_Colour <= "111111111111";
					
					GOline3 : FOR k IN 0 TO 10 LOOP
					
						scaledCol := pixel_column - (gameoverLine3X + k*32);
						scaledRow := pixel_row - gameoverLine3Y;
						
						IF (unsigned(pixel_column) >= unsigned(gameoverLine3X + k*32) AND unsigned(pixel_column) < unsigned(gameoverLine3X + ((k+1)*32))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= S;
								WHEN 1 => currentCHAR <= C;
								WHEN 2 => currentCHAR <= O;
								WHEN 3 => currentCHAR <= R;
								WHEN 4 => currentCHAR <= E;
								WHEN 5 => currentCHAR <= COLON;
								WHEN 6 => currentCHAR <= SPACE;
								WHEN 7 => currentCHAR <= thousands;
								WHEN 8 => currentCHAR <= hundreds;
								WHEN 9 => currentCHAR <= tens;
								WHEN 10 => currentCHAR <= ones;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP GOline3;
					
					char_col <= scaledCol(4 downto 2);
					char_row <= scaledRow(4 downto 2);
					
				ELSIF (unsigned(pixel_row) >= unsigned(gameoverLine4Y) AND unsigned(pixel_row) < unsigned(gameoverLine4Y + 16)) THEN
					
					char_Colour <= "111111111111";
					
					GOline4 : FOR k IN 0 TO 21 LOOP
					
						scaledCol := pixel_column - (gameoverLine4X + k*16);
						scaledRow := pixel_row - gameoverLine4Y;
						
						IF (unsigned(pixel_column) >= unsigned(gameoverLine4X + k*16) AND unsigned(pixel_column) < unsigned(gameoverLine4X + ((k+1)*16))) THEN
							
							CASE k IS
								WHEN 0 => currentCHAR <= P;
								WHEN 1 => currentCHAR <= R;
								WHEN 2 => currentCHAR <= E;
								WHEN 3 => currentCHAR <= S;
								WHEN 4 => currentCHAR <= S;
								WHEN 5 => currentCHAR <= SPACE;
								WHEN 6 => currentCHAR <= B;
								WHEN 7 => currentCHAR <= U;
								WHEN 8 => currentCHAR <= T;
								WHEN 9 => currentCHAR <= T;
								WHEN 10 => currentCHAR <= O;
								WHEN 11 => currentCHAR <= N;
								WHEN 12 => currentCHAR <= ZERO;
								WHEN 13 => currentCHAR <= SPACE;
								WHEN 14 => currentCHAR <= F;
								WHEN 15 => currentCHAR <= O;
								WHEN 16 => currentCHAR <= R;
								WHEN 17 => currentCHAR <= SPACE;
								WHEN 18 => currentCHAR <= M;
								WHEN 19 => currentCHAR <= E;
								WHEN 20 => currentCHAR <= N;
								WHEN 21 => currentCHAR <= U;
								WHEN others => currentCHAR <= E;
							END CASE;
							
							printCHAR <= '1';
						END IF;
					END LOOP GOline4;
					
					char_col <= scaledCol(3 downto 1);
					char_row <= scaledRow(3 downto 1);
				END IF;
				
		end case;
		
		if (char_data = '1' AND printCHAR = '1') then
			char_on <= '1';
		else 
			char_on <= '0';
		end if;

	end process;
end architecture behaviour;