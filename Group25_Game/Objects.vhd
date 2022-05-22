LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY Objects IS
   PORT(	Clock 						: IN std_logic;
			State 						: IN std_logic_vector(1 DOWNTO 0);
			vert_sync_int				: IN std_logic;
			RandomY						: IN std_logic_vector(9 DOWNTO 0);
			RandomGEN					: IN std_logic_vector(9 DOWNTO 0);
			Ship_Fuel					: IN std_logic_vector(6 DOWNTO 0);
			Pipe1_X						: IN std_logic_vector(9 DOWNTO 0);
			Pipe2_X						: IN std_logic_vector(9 DOWNTO 0);
			ResetFuel					: IN std_logic;
			ResetGift					: IN std_logic;
			Speed							: IN std_logic_vector(9 DOWNTO 0);
		  
			Fuel_XOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Fuel_YOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Gift_XOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Gift_YOUT					: OUT std_logic_vector(9 DOWNTO 0);	
			FuelSizeOUT					: OUT std_logic_vector(9 DOWNTO 0);
			GiftSizeOUT					: OUT std_logic_vector(9 DOWNTO 0)
			);
END Objects;


ARCHITECTURE BEHAVIOUR OF Objects IS
	SIGNAL Fuel_X_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(640,10);
	SIGNAL Fuel_Y_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(232,10);
	SIGNAL Gift_X_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(640,10);
	SIGNAL Gift_Y_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(232,10);
	SIGNAL FuelSize					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
	SIGNAL GiftSize					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(16,10);
BEGIN

Move_Objects: process
	VARIABLE MovingFuel, MovingGift : std_logic := '0';
BEGIN

	-- Move object once every vertical sync
	WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';
			
	--Only update objects in normal mode.
	IF (State = "10") THEN
		
		IF (ResetFuel = '1') THEN
			Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			FuelSize <= CONV_STD_LOGIC_VECTOR(16,10);
			MovingFuel := '0';
		END IF;
		
		IF (ResetGift = '1') THEN
			Gift_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			GiftSize <= CONV_STD_LOGIC_VECTOR(16,10);
			MovingGift := '0';
		END IF;
		
		--TODO: 	Change speeds to be variable.
		IF (MovingFuel = '1') THEN
			IF (Fuel_X_pos = CONV_STD_LOGIC_VECTOR(0,10)) THEN
				IF (FuelSize > CONV_STD_LOGIC_VECTOR(0,10)) THEN
					IF (FuelSize >= Speed) THEN
						FuelSize <= FuelSize - Speed;
					ELSE
						FuelSize <= CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
				ELSE 
					MovingFuel := '0';
					Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
					FuelSize <= CONV_STD_LOGIC_VECTOR(16,10);
					Fuel_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
				END IF;
			ELSE
				IF (unsigned(Fuel_X_pos) >= unsigned(Speed)) THEN
					Fuel_X_pos <= Fuel_X_pos - Speed;
				ELSE
					Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(0,10);
				END IF;
			END IF;
		ELSIF (unsigned(Ship_Fuel) < unsigned(CONV_STD_LOGIC_VECTOR(75,7)) 
		AND (
		(unsigned(Pipe1_X) < unsigned(CONV_STD_LOGIC_VECTOR(478,10)) AND unsigned(Pipe1_X) > unsigned(CONV_STD_LOGIC_VECTOR(372,10)))
		OR (unsigned(Pipe2_X) < unsigned(CONV_STD_LOGIC_VECTOR(478,10)) AND unsigned(Pipe2_X) > unsigned(CONV_STD_LOGIC_VECTOR(372,10)))
		)) THEN
			Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			MovingFuel := '1';
			
			IF (unsigned(RandomY) < unsigned(CONV_STD_LOGIC_VECTOR(32,10))) THEN
				Fuel_Y_pos <= CONV_STD_LOGIC_VECTOR(32,10);
			ELSIF (unsigned(RandomY) > unsigned(CONV_STD_LOGIC_VECTOR(320,10))) THEN
				Fuel_Y_pos <= CONV_STD_LOGIC_VECTOR(320,10);
			ELSE
				Fuel_Y_pos <= RandomY;
			END IF;
		ELSE
			Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			Fuel_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
		END IF;
		
		IF (MovingGift = '1') THEN
			IF (Gift_X_pos = CONV_STD_LOGIC_VECTOR(0,10)) THEN
				IF (GiftSize > CONV_STD_LOGIC_VECTOR(0,10)) THEN
					IF (GiftSize >= Speed) THEN
						GiftSize <= GiftSize - Speed;
					ELSE
						GiftSize <= CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
				ELSE 
					MovingGift := '0';
					Gift_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
					Gift_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
					GiftSize <= CONV_STD_LOGIC_VECTOR(16,10);

				END IF;
			ELSE
				IF (unsigned(Gift_X_pos) >= unsigned(Speed)) THEN
					Gift_X_pos <= Gift_X_pos - Speed;
				ELSE
					Gift_X_pos <= CONV_STD_LOGIC_VECTOR(0,10);
				END IF;
			END IF;
		ELSIF (NOT(unsigned(Fuel_X_pos) = unsigned(CONV_STD_LOGIC_VECTOR(640,10)) AND MovingFuel = '1')
		AND (RandomGEN > CONV_STD_LOGIC_VECTOR(200,10))
		AND (
		(unsigned(Pipe1_X) < unsigned(CONV_STD_LOGIC_VECTOR(478,10)) AND unsigned(Pipe1_X) > unsigned(CONV_STD_LOGIC_VECTOR(372,10)))
		OR (unsigned(Pipe2_X) < unsigned(CONV_STD_LOGIC_VECTOR(478,10)) AND unsigned(Pipe2_X) > unsigned(CONV_STD_LOGIC_VECTOR(372,10)))
		)) THEN
			Gift_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			MovingGift := '1';
			
			IF (unsigned(RandomY) < unsigned(CONV_STD_LOGIC_VECTOR(32,10))) THEN
				Gift_Y_pos <= CONV_STD_LOGIC_VECTOR(32,10);
			ELSIF (unsigned(RandomY) > unsigned(CONV_STD_LOGIC_VECTOR(320,10))) THEN
				Gift_Y_pos <= CONV_STD_LOGIC_VECTOR(320,10);
			ELSE
				Gift_Y_pos <= RandomY;
			END IF;
		ELSE
			Gift_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
			Gift_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
		END IF;
		
	ELSE 
		MovingFuel := '0';
		MovingGift := '0';
		Fuel_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
		Fuel_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
		Gift_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
		Gift_Y_pos <= CONV_STD_LOGIC_VECTOR(232,10);
		FuelSize <= CONV_STD_LOGIC_VECTOR(16,10);
		GiftSize <= CONV_STD_LOGIC_VECTOR(16,10);
	END IF;
	
	Fuel_YOUT <= Fuel_Y_pos;
	Fuel_XOUT <= Fuel_X_pos;
	FuelSizeOUT <= FuelSize;
	Gift_YOUT <= Gift_Y_pos;
	Gift_XOUT <= Gift_X_pos;
	GiftSizeOUT <= GiftSize;
	
END process Move_Objects;
END BEHAVIOUR;