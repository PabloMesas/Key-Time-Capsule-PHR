----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2018 20:29:43
-- Design Name: 
-- Module Name: decipher_module - Behavioral
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

ENTITY decrypt_module is
  GENERIC (
      L                 : natural:= 32;
      Y                 : natural:= 8);   
  PORT (
      CLK               : IN std_logic;
      LOAD              : IN std_logic;
      CK                : IN std_logic_vector (L-1 DOWNTO 0);
      A                 : IN std_logic_vector (L-1 DOWNTO 0);
      N                 : IN std_logic_vector (L-1 DOWNTO 0);
      T                 : IN std_logic_vector (L-1 DOWNTO 0);
      K                 : OUT std_logic_vector(Y-1 DOWNTO 0) := (OTHERS => '0');
	  F                 : OUT std_logic := '0');
END decrypt_module;

architecture Behavioral of decrypt_module is
-- SIGNAL Declerations
SIGNAL calculus_state   : natural           RANGE 0 TO 6          := 0                 ;
  -- Double length because of the multiplication of result
SIGNAL square           : unsigned          (L*2-1 DOWNTO 0)      := (OTHERS => '0')   ;
SIGNAL result           : unsigned          (L-1 DOWNTO 0)        := (OTHERS => '0')   ;

BEGIN
        
  comb: PROCESS (LOAD, CLK)
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE module       : unsigned          (L*2-1 DOWNTO 0)       := (OTHERS => '0')   ;
  VARIABLE i            : unsigned          (L-1 DOWNTO 0)         := (OTHERS => '0')   ;
  VARIABLE expT         : unsigned          (L-1 DOWNTO 0)         := (OTHERS => '0')   ;
  BEGIN
    IF LOAD = '1' THEN
      F <= '0';
      calculus_state <= 1;
    ELSIF falling_edge(CLK) THEN
        CASE calculus_state IS
          WHEN 1 =>
            expT    := unsigned(T);
            module  := RESIZE(unsigned(N), L*2);
            result  <= unsigned(A);
            square <= (OTHERS => '0');
            calculus_state <= 2;
          WHEN 2 =>
            IF expT > 0 AND LOAD = '0' THEN
              i := result;
              calculus_state <= 3;
            ELSE
              calculus_state <= 5;
            END IF;
          WHEN 3 =>
            IF i > 0 THEN
              square <= square + result;
              i := i-1;
            ELSE
              calculus_state <= 4;
            END IF;
          WHEN 4 =>
            IF square >= module THEN
              square <= square - module;
            ELSE
              result <= square(L-1 DOWNTO 0);
              square <= (OTHERS => '0');
              expT := expT - 1;
              calculus_state <= 2;
            END IF;
          WHEN 5 =>
            result <= unsigned(CK) - result;
            calculus_state <= 6;
          WHEN 6 =>
            K <= std_logic_vector(result(Y-1 DOWNTO 0)) ;
            F <= '1';
            calculus_state <= 0;
          WHEN 0 =>
            calculus_state <= 0;
        END CASE;
    END IF;
  END PROCESS;

end Behavioral;
