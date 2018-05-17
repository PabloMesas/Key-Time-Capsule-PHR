library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY desplazadorTest IS

END desplazadorTest;

ARCHITECTURE desplazdorTest_a OF desplazadorTest IS

COMPONENT desplazador
GENERIC (l: INTEGER := 4);
PORT (t: IN STD_LOGIC_VECTOR(l-1 DOWNTO 0); S: OUT STD_LOGIC_VECTOR((2**l)-1 DOWNTO 0));
END COMPONENT;

SIGNAL t: STD_LOGIC_VECTOR(4-1 DOWNTO 0);
SIGNAL S: STD_LOGIC_VECTOR((2**4)-1 DOWNTO 0);
BEGIN
	i:desplazador GENERIC MAP (4) PORT MAP (t,S);
	t <= "0001" after 5 ns, "0100" after 15 ns, "1111" after 25 ns;

END desplazdorTest_a;
