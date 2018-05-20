----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: test_multiplier - Behavioral
-- Project Name: Key-Time-Capsule
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

ENTITY test_multiplier IS
    GENERIC (l: NATURAL:= 1024);
END test_multiplier;

ARCHITECTURE test OF test_multiplier IS
-- Signal Declerations
SIGNAL r1, r2     : std_logic_vector(l-1 DOWNTO 0);
SIGNAL s          : std_logic_vector(2*l-1 DOWNTO 0);

COMPONENT multiplier
    PORT (
        MUL1, MUL2     : IN std_logic_vector(l-1 DOWNTO 0);
        PRODUCT        : OUT std_logic_vector(2*l-1 DOWNTO 0));
END COMPONENT;

BEGIN
    I1: multiplier  PORT MAP (r1, r2, s);
    
    r1 <= std_logic_vector(to_unsigned(5, l)) after 0 ns, 
	    std_logic_vector(to_unsigned(7, l)) after 20 ns;
    r2 <= std_logic_vector(to_unsigned(7, l)) after 0 ns,
	    std_logic_vector(to_unsigned(11, l)) after 40 ns;

END test;
