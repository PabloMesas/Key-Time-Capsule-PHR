----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: multiplier - Behavioural
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY multiplier IS
    GENERIC (l: INTEGER:= 1024);
    PORT (
        MUL1, MUL2     : IN std_logic_vector(l-1 DOWNTO 0);
        PRODUCT        : OUT std_logic_vector(2*l-1 DOWNTO 0));
END multiplier;

ARCHITECTURE Behavioural OF multiplier IS
-- Signal Declerations
SIGNAL r1, r2, r3  : std_logic_vector(l-1 DOWNTO 0);
SIGNAL s           : std_logic_vector(l DOWNTO 0);
SIGNAL zero        : std_logic_vector(l-1 DOWNTO 0) := (OTHERS => '0');

COMPONENT bin_adder
    PORT (
        NUM1, NUM2     : IN std_logic_vector(l-1 DOWNTO 0);
        SUM            : OUT std_logic_vector(l DOWNTO 0));
END COMPONENT;

BEGIN
    PROCESS(MUL1, MUL2)
    BEGIN
        r1 := MUL1;
        r2 := MUL2;
        r3 := (OTHERS => '0');

        FOR i IN l-1 DOWNTO 0 LOOP
            CASE r1 (0) IS
                WHEN '1' => bin_adder PORT MAP (r3, r2, s);
                WHEN '0' => bin_adder PORT MAP (r3, cero, s);
            END CASE;
            r3 := s (l DOWNTO 1);
            r1 := s (0) & r1 (l-1 DOWNTO 1);
        END LOOP;
        PRODUCT <= r3 & r1;
    END PROCESS;
    
END Behavioural;