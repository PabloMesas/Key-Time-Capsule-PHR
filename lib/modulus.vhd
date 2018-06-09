----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09.06.2018 01:34:43
-- Design Name: 
-- Module Name: modulus - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modulus is
    GENERIC (l: natural:= 32);
    Port ( CLK : IN std_logic;
           RST : in STD_LOGIC;
           LOAD : in STD_LOGIC;
           NUM : in STD_LOGIC_VECTOR (l*2-1 downto 0);
           N : in STD_LOGIC_VECTOR (l-1 downto 0);
           S : out STD_LOGIC_VECTOR (l-1 downto 0) := (OTHERS => '0');
           F : out STD_LOGIC := '0');
end modulus;

ARCHITECTURE Behavioral of modulus is
TYPE multiplier_machine IS (wait_d, calc1_d);
-- SIGNAL Declerations
SIGNAL calc                 : natural RANGE 0 TO 2      := 0                            ;
SIGNAL r1                   : unsigned(l*2-1 DOWNTO 0)  := (OTHERS => '0')              ;
SIGNAL r2                   : unsigned(l-1 DOWNTO 0)    := (OTHERS => '0')              ;

begin

  PROCESS(RST, LOAD, CLK)
  VARIABLE sol              : unsigned(l-1 DOWNTO 0)    := (OTHERS => '0')              ;
  BEGIN
    IF RST = '0' THEN
      F <= '0';
      calc <= 0;
    ELSIF LOAD = '1' THEN
      F <= '0';
      r1 <= unsigned(NUM);
      r2 <= unsigned(N);
      calc <= 1;
    ELSIF rising_edge(CLK) THEN
      CASE calc IS
        WHEN 0 =>
          calc <= 0;
        WHEN 1 =>
          IF LOAD = '0' THEN
            sol := r1 mod r2;
            calc <= 2;
          ELSE
            
          END IF;
        WHEN 2 =>
          S <= std_logic_vector(sol);
          F <= '1';
          calc <= 0;
      END CASE;
    END IF;
  END PROCESS;

end Behavioral;
