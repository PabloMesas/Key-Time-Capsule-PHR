----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: bin_adder - Behavioral
-- Project Name: Basys 3 Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY bin_adder IS
    GENERIC (l: NATURAL:= 1024);
    PORT (
        NUM1, NUM2       : IN std_logic_vector(l-1 DOWNTO 0);
        SUM              : OUT std_logic_vector(l DOWNTO 0));
END bin_adder;

ARCHITECTURE Behavioral OF bin_adder IS
-- Signal Declerations
SIGNAL r1, r2      : std_logic_vector(l-1 DOWNTO 0);
SIGNAL x           : unsigned(l DOWNTO 0);

BEGIN
    x <= ('0' & unsigned(r1)) + ('0' & unsigned(r2));

    r1 <= NUM1;
    r2 <= NUM2;
    SUM <= std_logic_vector(x);

END Behavioral;