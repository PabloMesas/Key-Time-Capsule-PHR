----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: test_bin_adder - Behavioural
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

ENTITY test_bin_adder IS
    GENERIC (l: INTEGER:= 1024);
END test_bin_adder;

ARCHITECTURE test OF test_bin_adder IS

COMPONENT bin_adder
    PORT (
        NUM1, NUM2     : IN std_logic_vector(l-1 DOWNTO 0);
        SUM            : OUT std_logic_vector(l DOWNTO 0));
END COMPONENT;

SIGNAL r1, r2       : std_logic_vector(l-1 DOWNTO 0);
SIGNAL s          : std_logic_vector(l DOWNTO 0);

BEGIN
    I1: bin_adder  PORT MAP (r1, r2, s);
    
    r1 <= std_logic_vector(to_unsigned(5, l)) after 0 ns,
        std_logic_vector(to_unsigned(7, l)) after 20 ns;
    r2 <= std_logic_vector(to_unsigned(7, l)) after 0 ns,
        std_logic_vector(to_unsigned(11, l)) after 40 ns;

END test;