library ieee;
use ieee.std_logic_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

Entity LSFR is
	Generic(StartValue: integer:= 256);
	port(
	Clk 	: in std_logic;
	res	: out std_logic_vector(9 downto 0)
	);
End LSFR;

Architecture rtl of LSFR is
	Signal reg : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(StartValue,10);
Begin
	Process(Clk) 
	begin
		if (rising_edge(Clk)) then	
			reg(9) <= '0';
			reg(8) <= reg(7);
			reg(7) <= reg(6);
			reg(6) <= reg(5);
			reg(5) <= reg(4);
			reg(4) <= reg(3) xor reg(8);
			reg(3) <= reg(2) xor reg(8);
			reg(2) <= reg(1) xor reg(8);
			reg(1) <= reg(0);
			reg(0) <= reg(7);
			
			res <= reg;
		end if;
	end process;
end architecture rtl;