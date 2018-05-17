library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY desplazador IS
GENERIC (l: INTEGER := 4);
PORT(t: IN STD_LOGIC_VECTOR(l-1 DOWNTO 0); S: OUT STD_LOGIC_VECTOR((2**l)-1 DOWNTO 0));
END desplazador;

ARCHITECTURE adesp OF desplazador IS
SIGNAL d: STD_LOGIC_VECTOR ((2**l)-1 DOWNTO 0);
SIGNAL r2: UNSIGNED INTEGER;
BEGIN
	r2 <= to_integer(t);
	d(0) <= '1';
	d <= d sll r2; 
	S <= d;

END adesp;