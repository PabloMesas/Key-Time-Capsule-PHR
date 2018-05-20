----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: multiplier - Behavioral
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

ENTITY multiplier IS
    GENERIC (l: INTEGER:= 1024);
    PORT (
        MUL1, MUL2     : IN std_logic_vector(l-1 DOWNTO 0);
        PRODUCT        : OUT std_logic_vector(2*l-1 DOWNTO 0));
END multiplier;

ARCHITECTURE Behavioral OF multiplier IS

FUNCTION adder (A, B: std_logic_vector) RETURN std_logic_vector IS
VARIABLE sum	   : unsigned(l DOWNTO 0);
BEGIN
    sum := ('0' & unsigned(A)) + ('0' & unsigned(B));
    RETURN std_logic_vector(sum);
END adder;

BEGIN
    PROCESS(MUL1, MUL2)
    VARIABLE r1, r2, r3  : std_logic_vector(l-1 DOWNTO 0);
    VARIABLE s           : std_logic_vector(l DOWNTO 0);
    VARIABLE zero        : std_logic_vector(l-1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        r1 := MUL1;
        r2 := MUL2;
        r3 := (OTHERS => '0');

        FOR i IN l-1 DOWNTO 0 LOOP
            IF (r1(0)='1') THEN s := adder(r3, r2);
            ELSE s := adder(r3, zero);
            END IF;
            r3 := s(l DOWNTO 1);
            r1 := s(0) & r1(l-1 DOWNTO 1);
        END LOOP;
        PRODUCT <= r3 & r1;
    END PROCESS;
    
END Behavioral;