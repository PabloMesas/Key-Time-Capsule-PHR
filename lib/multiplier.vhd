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
    GENERIC (l: INTEGER:= 32);
    PORT (
        CLK             : IN std_logic                                                  ;
        RST             : IN std_logic                                                  ;
        LD              : IN std_logic                                                  ;
        MUL1, MUL2      : IN std_logic_vector(l-1 DOWNTO 0)                             ;
        S               : OUT std_logic_vector(2*l-1 DOWNTO 0)      := (OTHERS => '0')  ;
        F               : OUT std_logic                             := '0'             );
END multiplier;

ARCHITECTURE Behavioral OF multiplier IS
TYPE multiplier_machine IS (wait_d, calc1_d, calc2_d, t_S);
-- SIGNAL Declerations
SIGNAL multiplier_state     : multiplier_machine                := wait_d               ;
SIGNAL r1, r2, r3           : std_logic_vector(l-1 DOWNTO 0)    := (OTHERS => '0')      ;
SIGNAL r4                    : std_logic_vector(l DOWNTO 0)     := (OTHERS => '0')      ;


-- FUNCTION Declarations
FUNCTION adder (A, B: std_logic_vector) RETURN std_logic_vector IS
  VARIABLE sum	   : unsigned(l DOWNTO 0);
BEGIN
    sum := ('0' & unsigned(A)) + ('0' & unsigned(B));
    RETURN std_logic_vector(sum);
END adder;

BEGIN
  PROCESS(RST, LD, multiplier_state, CLK)
  VARIABLE start            : natural      RANGE 0 TO 1        := 0                     ;
  VARIABLE r_1, r_2, r_3    : std_logic_vector  (l-1 DOWNTO 0) := (OTHERS => '0')       ;
  VARIABLE r_4              : std_logic_vector  (l DOWNTO 0  ) := (OTHERS => '0')       ;
  VARIABLE index            : natural      RANGE 0 TO l-1      := 0                     ;
  VARIABLE zero             : std_logic_vector(l-1 DOWNTO 0)   := (OTHERS => '0')       ;
  BEGIN
    IF RST = '0' THEN
      F <= '0';
      multiplier_state <= wait_d;
    ELSIF LD = '1' THEN
      F <= '0';
      r1 <= MUL1;
      r2 <= MUL2;
      r3 <= (OTHERS => '0');
      index := 0;
      multiplier_state <= calc1_d;
    ELSIF rising_edge(CLK) THEN
      CASE multiplier_state IS
        WHEN wait_d =>

        WHEN calc1_d =>
          IF index < l THEN
            IF r1(0) = '1' THEN 
              r_4 := adder(r3, r2);
            ELSE
              r_4 := adder(r3, zero);
            END IF;
            multiplier_state <= calc2_d;
          ELSE
            multiplier_state <= t_S;
          END IF;
        WHEN calc2_d =>
          r_3 := r4(l DOWNTO 1);
          r_1 := r4(0) & r1(l-1 DOWNTO 1);
          index := index + 1;
          multiplier_state <= calc1_d;
        WHEN t_S =>
          F <= '1';
          S <= r3 & r1;
          start := 0;
          multiplier_state <= wait_d;
      END CASE;
      r1 <= r_1;
      r2 <= r_2;
      r3 <= r_3;
      r4 <= r_4;
    END IF;
  END PROCESS;
    
END Behavioral;