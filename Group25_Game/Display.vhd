LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_UNSIGNED.all;
USE IEEE.NUMERIC_STD.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

PACKAGE de0core IS
	COMPONENT vga_sync
 		PORT(clock_25Mhz							: IN		STD_LOGIC;
				red, green, blue 					: IN 		STD_LOGIC_VECTOR(3 DOWNTO 0);
         	red_out, green_out, blue_out	: OUT 	STD_LOGIC_VECTOR(3 DOWNTO 0);
				horiz_sync_out, vert_sync_out	: OUT 	STD_LOGIC;
				pixel_row, pixel_column			: OUT 	STD_LOGIC_VECTOR(9 DOWNTO 0)
				);
	END COMPONENT;
END de0core;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.de0core.all;

ENTITY Display IS
   PORT(	SIGNAL Clock 						: IN std_logic;
			SIGNAL State						: IN std_logic_vector(1 DOWNTO 0);
			SIGNAL Ship_Y						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Ship_X						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Ship_Size					: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Alive						: IN std_logic;
			SIGNAL Pipe1_X						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe1_Y						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe2_X						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe2_Y						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe1_Size					: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe2_Size					: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Pipe_Gap_Size				: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL char_on						: IN std_logic;
			SIGNAL ship_fuel					: IN std_logic_vector(6 DOWNTO 0);
			SIGNAL Fuel_X						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Fuel_Y						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Gift_X						: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL Gift_Y						: IN std_logic_vector(9 DOWNTO 0);	
			SIGNAL FuelSize					: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL GiftSize					: IN std_logic_vector(9 DOWNTO 0);
			SIGNAL BackgroundColour			: IN std_logic_vector(11 DOWNTO 0);
			SIGNAL CharacterColour			: IN std_logic_vector(11 DOWNTO 0);
			SIGNAL ShipColour					: IN std_logic_vector(11 DOWNTO 0);
		  
			SIGNAL Red,Green,Blue 			: OUT std_logic_vector(3 DOWNTO 0);
			SIGNAL Horiz_sync,Vert_sync	: OUT std_logic;
			SIGNAL pixelrow, pixelcol		: OUT std_logic_vector(9 DOWNTO 0);
			SIGNAL address						: OUT std_logic_vector(14 DOWNTO 0);
			SIGNAL shipAddress				: OUT std_logic_vector(9 DOWNTO 0)
			);
END Display;

architecture behavior of Display is

-- Video Display Signals   
SIGNAL Red_Data, Green_Data, Blue_Data 													: std_logic_vector(3 DOWNTO 0);
SIGNAL vert_sync_int, Ball_on, Pipe_on, Fuel_on, FuelDrop_on, GiftDrop_on		: std_logic; 
SIGNAL pixel_row, pixel_column																: std_logic_vector(9 DOWNTO 0);
SIGNAL FuelX																						: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
SIGNAL FuelY																						: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(56,10);

BEGIN           
   SYNC: vga_sync
 		PORT MAP(clock_25Mhz => clock, 
				red => red_data, 
				green => green_data, 
				blue => blue_data,	
    	     	red_out => red, 
				green_out => green, 
				blue_out => blue,
			 	horiz_sync_out => horiz_sync, 
				vert_sync_out => vert_sync_int,
			 	pixel_row => pixel_row, 
				pixel_column => pixel_column
		);

-- need internal copy of vert_sync to read
vert_sync <= vert_sync_int;
FuelX <= CONV_STD_LOGIC_VECTOR(16,10);
FuelY <= CONV_STD_LOGIC_VECTOR(56,10);

--Primary display process, update when positons or object sizes/colours change.
RGB_Display: Process (pixel_column, pixel_row, Ship_X, Ship_Y, Ship_Size, Pipe1_X, Pipe1_Y, Pipe1_Size, Pipe2_X, Pipe2_Y, Pipe2_Size, Pipe_Gap_Size, ShipColour, Fuel_X, Fuel_Y,
								FuelSize, Gift_X, Gift_Y, GiftSize, CharacterColour, FuelX, ship_fuel, State)
	VARIABLE scaledCol : std_logic_vector(7 DOWNTO 0);
	VARIABLE scaledRow : std_logic_vector(6 DOWNTO 0);
	VARIABLE pipeColour : std_logic_vector(11 DOWNTO 0) := "101010101010";
		
	VARIABLE shipScaledCol : std_logic_vector(9 DOWNTO 0);
	VARIABLE shipScaledRow : std_logic_vector(9 DOWNTO 0);
	VARIABLE shipAddressLarge 	: std_logic_vector(10 DOWNTO 0);
BEGIN
	--copied pixel position data for text block.
	pixelcol <= pixel_column;
	pixelrow <= pixel_row;
	
	scaledCol := pixel_column(9 DOWNTO 2);
	scaledRow := pixel_row(8 DOWNTO 2);
	
	shipScaledCol := pixel_column - Ship_X;
	shipScaledRow := pixel_row - Ship_Y;
	
	address <= (unsigned(scaledRow) * unsigned(CONV_STD_LOGIC_VECTOR(160,8))) + scaledCol;

	shipAddressLarge := (unsigned(shipScaledRow(4 DOWNTO 0)) * unsigned(CONV_STD_LOGIC_VECTOR(32,6))) + shipScaledCol(4 DOWNTO 0);
	shipAddress <= shipAddressLarge(9 DOWNTO 0);
	
	-- Set Pipe_on ='1' to display a pipe
	IF (unsigned(pixel_column) >= unsigned(Pipe1_X)) AND
	(unsigned(pixel_column) < unsigned(Pipe1_X + Pipe1_Size)) AND
	((unsigned(pixel_row) >= unsigned(CONV_STD_LOGIC_VECTOR(0,10)) AND
	unsigned(pixel_row) <= unsigned(Pipe1_Y)) OR 
	(unsigned(pixel_row) >= unsigned(Pipe1_Y + Pipe_Gap_Size))) THEN
		Pipe_on <= '1';
		pipeColour := "111011101110";
 	ELSIF (unsigned(pixel_column) >= unsigned(Pipe2_X)) AND
	(unsigned(pixel_column) < unsigned(Pipe2_X + Pipe2_Size)) AND
	((unsigned(pixel_row) >= unsigned(CONV_STD_LOGIC_VECTOR(0,10)) AND
	unsigned(pixel_row) <= unsigned(Pipe2_Y)) OR 
	(unsigned(pixel_row) >= unsigned(Pipe2_Y + Pipe_Gap_Size))) THEN
		Pipe_on <= '1';
		pipeColour := "101010101010";
	ELSE
		Pipe_on <= '0';
	END IF;

	-- Set Ball_on ='1' to display ball
	IF ((unsigned(pixel_column) >= unsigned(Ship_X)) AND (unsigned(pixel_column) <= unsigned(Ship_X + Ship_Size)) AND
	(unsigned(pixel_row) >= unsigned(Ship_Y)) AND (unsigned(pixel_row) <= unsigned(Ship_Y + Ship_Size))) AND
	(shipColour /= "000000001111") THEN
		Ball_on <= '1';
	ELSE
		Ball_on <= '0';
	END IF;
	
	--Set Fuel_on ='1' to display fuel bar.
	IF ((unsigned(pixel_column) >= unsigned(FuelX)) AND (unsigned(pixel_column) <= unsigned(FuelX + CONV_STD_LOGIC_VECTOR(100,10))) AND
	(unsigned(pixel_row) >= unsigned(FuelY)) AND (unsigned(pixel_row) <= unsigned(FuelY + CONV_STD_LOGIC_VECTOR(32,10))) AND State = "10") THEN
		Fuel_on <= '1';
	ELSE
		Fuel_on <= '0';
	END IF;
	
	--Set FuelDrop_on ='1' to display collectible fuel.
	IF ((unsigned(pixel_column) >= unsigned(Fuel_X)) AND (unsigned(pixel_column) <= unsigned(Fuel_X + FuelSize)) AND
	(unsigned(pixel_row) >= unsigned(Fuel_Y)) AND (unsigned(pixel_row) <= unsigned(Fuel_Y + CONV_STD_LOGIC_VECTOR(16,10)))) THEN
		FuelDrop_on <= '1';
	ELSE
		FuelDrop_on <= '0';
	END IF;
	
	--Set GiftDrop_on ='1' to display collectible gifts.
	IF ((unsigned(pixel_column) >= unsigned(Gift_X)) AND (unsigned(pixel_column) <= unsigned(Gift_X + GiftSize)) AND
	(unsigned(pixel_row) >= unsigned(Gift_Y)) AND (unsigned(pixel_row) <= unsigned(Gift_Y + CONV_STD_LOGIC_VECTOR(16,10)))) THEN
		GiftDrop_on <= '1';
	ELSE
		GiftDrop_on <= '0';
	END IF;

--Only display pipes and ship if the game is not in menu or gameover.
IF (char_on = '1') THEN
		Red_Data <= CharacterColour(11 DOWNTO 8);
		Green_Data <= CharacterColour(7 DOWNTO 4);
		Blue_Data <= CharacterColour(3 DOWNTO 0);
ELSIF (Fuel_on = '1') THEN
	
	IF (unsigned(pixel_column - FuelX) <= unsigned("000" & ship_fuel) AND unsigned("000" & ship_fuel) > unsigned(CONV_STD_LOGIC_VECTOR(0,7))) THEN
		Red_Data <= "1010";
		Green_Data <= "1010";
		Blue_Data <= "0000";
	ELSE
		Red_Data <= "1010";
		Blue_Data <= "1010";
		Green_Data <= "1010";
	END IF;
	
ELSIF(Ball_on = '1' AND (State = "01" OR State = "10")) THEN
		Red_Data <= shipColour(11 DOWNTO 8);
		Green_Data <= shipColour(7 DOWNTO 4);
		Blue_Data <= shipColour(3 DOWNTO 0);
ELSIF (FuelDrop_on = '1' AND (State = "10")) THEN
		Red_Data <= "1010";
		Green_Data <= "1010";
		Blue_Data <= "0000";
ELSIF (GiftDrop_on = '1' AND (State = "10")) THEN
		Red_Data <= "0000";
		Green_Data <= "1111";
		Blue_Data <= "0000";
ELSIF (Pipe_on = '1' AND (State = "01" OR State = "10")) THEN
		Red_Data <= pipeColour(11 DOWNTO 8);
		Green_Data <= pipeColour(7 DOWNTO 4);
		Blue_Data <= pipeColour(3 DOWNTO 0);
ELSE 
		Red_Data <= backgroundColour(11 DOWNTO 8);
		Green_Data <= backgroundColour(7 DOWNTO 4);
		Blue_Data <= backgroundColour(3 DOWNTO 0);
END IF;


END process RGB_Display;
END behavior;

