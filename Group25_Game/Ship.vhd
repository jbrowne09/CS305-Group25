LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY Ship IS
   PORT(	Clock 						: IN std_logic;
			State							: IN std_logic_vector(1 DOWNTO 0);
			mouse_left					: IN std_logic;
			mouse_right 				: IN std_logic;
			Pipe1_X						: IN std_logic_vector(9 DOWNTO 0);
			Pipe1_Y						: IN std_logic_vector(9 DOWNTO 0);
			Pipe2_X						: IN std_logic_vector(9 DOWNTO 0);
			Pipe2_Y						: IN std_logic_vector(9 DOWNTO 0);
			Pipe_Gap_Size				: IN std_logic_vector(9 DOWNTO 0);
			vert_sync_int				: IN std_logic;
			Fuel_X						: IN std_logic_vector(9 DOWNTO 0);
			Fuel_Y						: IN std_logic_vector(9 DOWNTO 0);
			Gift_X						: IN std_logic_vector(9 DOWNTO 0);
			Gift_Y						: IN std_logic_vector(9 DOWNTO 0);	
			FuelSize						: IN std_logic_vector(9 DOWNTO 0);
			GiftSize						: IN std_logic_vector(9 DOWNTO 0);
		  
			Ship_YOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Ship_XOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Size_OUT						: OUT std_logic_vector(9 DOWNTO 0);
			Alive							: OUT std_logic;
			ScoreTHOUSAND_OUT			: OUT std_logic_vector(3 DOWNTO 0);
			ScoreHUNDRED_OUT			: OUT std_logic_vector(3 DOWNTO 0);
			ScoreTEN_OUT				: OUT std_logic_vector(3 DOWNTO 0);
			ScoreONE_OUT				: OUT std_logic_vector(3 DOWNTO 0);
			FuelOUT						: OUT std_logic_vector(6 DOWNTO 0);
			GiftPickUp 					: OUT std_logic;
			FuelPickUp					: OUT std_logic;
			SpeedOUT						: OUT std_logic_vector(9 DOWNTO 0)
			);
END Ship;


ARCHITECTURE BEHAVIOUR OF SHIP IS
	SIGNAL Ship_Y_motion							: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(0,10);
	SIGNAL Ship_Y_pos								: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240,10);
	SIGNAL Ship_X_pos								: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320,10);
	SIGNAL Size										: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(32,10);
	SIGNAL Pipe_Size 								: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(64,10);
	SIGNAL scored1, scored2						: std_logic := '1';
	SIGNAL Speed 									: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(2,10);
BEGIN

Size <= CONV_STD_LOGIC_VECTOR(32,10);
Pipe_Size <= CONV_STD_LOGIC_VECTOR(64,10);
Size_OUT <= Size;

Move_Ball: process
	variable aCount: integer := 0;
	variable fCount: integer := 0;
	variable SpeedCount : integer := 0;
	variable isALIVE: std_logic := '1';
	variable sCount1000: std_logic_vector(3 DOWNTO 0) := "0000";
	variable sCount100: std_logic_vector(3 DOWNTO 0) := "0000";
	variable sCount10: std_logic_vector(3 DOWNTO 0) := "0000";
	variable sCount1: std_logic_vector(3 DOWNTO 0) := "0000";
	variable incrementScore: std_logic := '0';
	variable GiftingScore: std_logic := '0';
	variable Fuel: std_logic_vector(6 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(100,7);
BEGIN

-- Move Ship once every vertical sync
WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';

IF (State = "01" OR State = "10") THEN

	--Pipe Scroll speed increases in normal difficulty over time.
	IF (State = "10") THEN
			
		IF (SpeedCount >= 5) THEN
			Speed <= Speed + CONV_STD_LOGIC_VECTOR(1,10);
				
			SpeedCount := 0;
		END IF;
			
		IF (unsigned(Speed) >= unsigned(CONV_STD_LOGIC_VECTOR(8,10))) THEN
			Speed <= CONV_STD_LOGIC_VECTOR(8,10);
		END IF;
			
	END IF;
	
	--Bounce up if the player clicks and they still have fuel remaining.
	IF (mouse_left = '1' AND unsigned(Fuel) > unsigned(CONV_STD_LOGIC_VECTOR(0,7))) THEN
		Ship_Y_motion <= - CONV_STD_LOGIC_VECTOR(4,10);
		aCount := 0;
	END IF;
	
	--Decceleration Logic.
	IF (aCount = 4) THEN
		Ship_Y_motion <= Ship_Y_motion + CONV_STD_LOGIC_VECTOR(1,10);
				
		IF (Ship_Y_motion > CONV_STD_LOGIC_VECTOR(8,10)) THEN
			Ship_Y_motion <= CONV_STD_LOGIC_VECTOR(8,10);
		END IF;
				
		aCount := 0;
	END IF;
			
	-- Compute next ball Y position.
	IF (Ship_Y_pos + Ship_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10)) THEN
		Ship_Y_pos <= CONV_STD_LOGIC_VECTOR(0,10);
	ELSE
		Ship_Y_pos <= Ship_Y_pos + Ship_Y_motion;
	END IF;
				
	--Collision Logic
	IF (unsigned(Ship_X_pos + Size) >= unsigned(Pipe1_X) AND unsigned(Ship_X_pos) <= unsigned(Pipe1_X + Pipe_Size)) THEN
		IF (unsigned(Ship_Y_pos) <= unsigned(Pipe1_Y) OR unsigned(Ship_Y_pos + Size) >= unsigned(Pipe1_Y + Pipe_Gap_Size)) THEN
			isALIVE := '0';
		END IF;
	ELSIF (unsigned(Ship_X_pos + Size) >= unsigned(Pipe2_X) AND unsigned(Ship_X_pos) <= unsigned(Pipe2_X + Pipe_Size)) THEN
		IF (unsigned(Ship_Y_pos) <= unsigned(Pipe2_Y) OR unsigned(Ship_Y_pos + Size) >= unsigned(Pipe2_Y + Pipe_Gap_Size)) THEN
			isALIVE := '0';
		END IF;
	END IF;
	
	--Die on dropping below the bottom of the map
	IF ((unsigned(Ship_Y_pos) >= unsigned(CONV_STD_LOGIC_VECTOR(479,10))) AND (unsigned(Ship_Y_pos) < unsigned(CONV_STD_LOGIC_VECTOR(900,10)))) THEN
		isALIVE := '0';
	END IF;
	
	--Score is only incremented in Normal Mode.
	--Fuel is only in Normal Mode.
	IF (State = "10") THEN
	
		--Reset Fuel upon collision with a fuel pickup.
		IF (unsigned(Ship_X_pos + Size) >= unsigned(Fuel_X) AND unsigned(Ship_X_pos) <= unsigned(Fuel_X + FuelSize)) THEN
			IF (unsigned(Ship_Y_pos + Size) >= unsigned(Fuel_Y) AND unsigned(Ship_Y_pos) <= unsigned(Fuel_Y + FuelSize)) THEN
				Fuel := CONV_STD_LOGIC_VECTOR(100,7);
				FuelPickUp <= '1';
			END IF;
		ELSE
			FuelPickUp <= '0';
		END IF;
		
		--IncrementScore upon collision with a score pickup.
		IF (unsigned(Ship_X_pos + Size) >= unsigned(Gift_X) AND unsigned(Ship_X_pos) <= unsigned(Gift_X + GiftSize)) THEN
			IF (unsigned(Ship_Y_pos + Size) >= unsigned(Gift_Y) AND unsigned(Ship_Y_pos) <= unsigned(Gift_Y + GiftSize) AND GiftingScore = '0') THEN
				sCount1 := sCount1 + "0010";
				
				IF (sCount1 = "1011") THEN
					sCount1 := "0001";
					sCount10 := sCount10 + "0001";
				END IF;
				
				GiftingScore := '1';
				GiftPickUp <= '1';
			END IF;
		ELSE
			GiftingScore := '0';
			GiftPickUp <= '0';
		END IF;
	
		IF (unsigned(Ship_X_pos) >= unsigned(Pipe1_X + Pipe_Size) AND scored1 = '0') THEN
			scored1 <= '1';
			incrementScore := '1';
			SpeedCount := SpeedCount + 1;
		
		ELSIF (unsigned(Ship_X_pos) < unsigned(Pipe1_X + Pipe_Size)) THEN
			scored1 <= '0';
		END IF;
	
		IF (unsigned(Ship_X_pos) >= unsigned(Pipe2_X + Pipe_Size) AND scored2 = '0') THEN
			scored2 <= '1';
			incrementScore := '1';
			SpeedCount := SpeedCount + 1;
		
		ELSIF (unsigned(Ship_X_pos) < unsigned(Pipe2_X + Pipe_Size)) THEN
			scored2 <= '0';
		END IF;
	
		IF (incrementScore = '1') THEN
			incrementScore := '0';
		
			sCount1 := sCount1 + "0001";
		END IF;
		
		--Adjust digits based on previous digits.
		IF (sCount1 = "1010") THEN
			sCount1 := "0000";
			sCount10 := sCount10 + "0001";
		END IF;
		
		IF (sCount10 = "1010") THEN
			sCount10 := "0000";
			sCount100 := sCount100 + "0001";
		END IF;
		
		IF (sCount100 = "1010") THEN
			sCount100 := "0000";
			sCount1000 := sCount100 + "0001";
		END IF;
		
		--Counter for fuel
		fCount := fCount + 1;
	
		IF (fCount >= 8) THEN
			IF (unsigned(Fuel) > unsigned(CONV_STD_LOGIC_VECTOR(0,7))) THEN
				Fuel := Fuel - CONV_STD_LOGIC_VECTOR(1,7);
			END IF;
			fCount := 0;
		END IF;
		
	END IF;
				
	--Counter for acceleration
	aCount := aCount + 1;
			
	Alive <= isALIVE;
	FuelOUT <= Fuel;
	
ELSIF (State = "00") THEN
	sCount1000 := "0000";
	sCount100 := "0000";
	sCount10 := "0000";
	sCount1 := "0000";
	GiftPickUp <= '0';
	FuelPickUp <= '0';
	scored1 <= '1';
	scored2 <= '1';
	Fuel := CONV_STD_LOGIC_VECTOR(100,7);
	FuelOUT <= CONV_STD_LOGIC_VECTOR(100,7);
	Speed <= CONV_STD_LOGIC_VECTOR(2,10);
	SpeedCount := 0;
ELSE 
	isAlive := '1';
	Alive <= '1';
	incrementScore := '0';
	Ship_Y_pos <= CONV_STD_LOGIC_VECTOR(240,10);
	Ship_X_pos <= CONV_STD_LOGIC_VECTOR(320,10);
END IF;

Ship_YOUT <= Ship_Y_pos;
Ship_XOUT <= Ship_X_pos;
ScoreTHOUSAND_OUT <= sCount1000;
ScoreHUNDRED_OUT <= sCount100;
ScoreTEN_OUT <= sCount10;
ScoreONE_OUT <= sCount1;
SpeedOUT <= Speed;
END process Move_Ball;
END BEHAVIOUR;