LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY PIPE IS
	Generic(StartX: integer:= 640);
   PORT(	Clock 						: IN std_logic;
			State 						: IN std_logic_vector(1 DOWNTO 0);
			vert_sync_int				: IN std_logic;
			Random						: IN std_logic_vector(9 DOWNTO 0);
			Speed							: IN std_logic_vector(9 DOWNTO 0);
		  
			Pipe_XOUT					: OUT std_logic_vector(9 DOWNTO 0);
			Pipe_YOUT					: OUT std_logic_vector(9 DOWNTO 0);
			SizeOUT						: OUT std_logic_vector(9 DOWNTO 0);
			GapOUT						: OUT std_logic_vector(9 DOWNTO 0)
			);
END PIPE;


ARCHITECTURE BEHAVIOUR OF PIPE IS
	SIGNAL Pipe_X_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(StartX,10);
	SIGNAL Pipe_Y_pos					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(176,10);
	SIGNAL Size							: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(64,10); 
	SIGNAL Gap_Size					: std_logic_vector(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(128,10);
BEGIN

Gap_Size <= CONV_STD_LOGIC_VECTOR(128,10);
GapOut <= Gap_Size;

Move_Pipe: process
BEGIN

	-- Move pipe once every vertical sync
	WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';
			
	IF (State = "01" OR State = "10") THEN
				
		--Pipe movement logic.
		IF (Pipe_X_pos = CONV_STD_LOGIC_VECTOR(0,10)) THEN
			IF (Size > CONV_STD_LOGIC_VECTOR(0,10)) THEN
				IF (Size >= Speed) THEN
					Size <= Size - Speed;
				ELSE
					Size <= CONV_STD_LOGIC_VECTOR(0,10);
				END IF;
			ELSE 
				Pipe_X_pos <= CONV_STD_LOGIC_VECTOR(640,10);
				Size <= CONV_STD_LOGIC_VECTOR(64,10);
				
				IF (unsigned(Random) < unsigned(CONV_STD_LOGIC_VECTOR(32,10))) THEN
					Pipe_Y_pos <= CONV_STD_LOGIC_VECTOR(32,10);
				ELSIF (unsigned(Random) > unsigned(CONV_STD_LOGIC_VECTOR(320,10))) THEN
					Pipe_Y_pos <= CONV_STD_LOGIC_VECTOR(320,10);
				ELSE
					Pipe_Y_pos <= Random;
				END IF;
			END IF;
		ELSE
			IF (unsigned(Pipe_X_pos) >= unsigned(Speed)) THEN
				Pipe_X_pos <= Pipe_X_pos - Speed;
			ELSE
				Pipe_X_pos <= CONV_STD_LOGIC_VECTOR(0,10);
			END IF;
		END IF;
	ELSE 
		Pipe_X_pos <= CONV_STD_LOGIC_VECTOR(StartX,10);
		Pipe_Y_pos <= CONV_STD_LOGIC_VECTOR(176,10);
		Size <= CONV_STD_LOGIC_VECTOR(64,10);
	END IF;
	
	Pipe_YOUT <= Pipe_Y_pos;
	Pipe_XOUT <= Pipe_X_pos;
	SizeOUT <= Size;
END process Move_Pipe;
END BEHAVIOUR;