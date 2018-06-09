----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.05.2018 20:42:44
-- Design Name: 
-- Module Name: mult - Behavioral
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

entity mult is
    GENERIC (l: natural:= 32);
    Port ( CLK : IN std_logic;
           RST : in STD_LOGIC;
           LOAD : in STD_LOGIC;
           MUL1 : in STD_LOGIC_VECTOR (l-1 downto 0) := (OTHERS => '0');
           S : out STD_LOGIC_VECTOR (l*2-1 downto 0);
           F : out STD_LOGIC := '0');
end mult;

ARCHITECTURE Behavioral of mult is
TYPE multiplier_machine IS (wait_d, calc1_d);
-- SIGNAL Declerations
SIGNAL calc                 : natural RANGE 0 TO 1      := 0                            ;
SIGNAL r1                   : unsigned(l-1 DOWNTO 0)    := (OTHERS => '0')              ;

begin

  PROCESS(RST, LOAD, CLK)
  VARIABLE sol      : unsigned      (L*2-1 DOWNTO 0);
  BEGIN
    IF RST = '0' THEN
      F <= '0';
      calc <= 0;
    ELSIF LOAD = '1' THEN
      F <= '0';
      r1 <= unsigned(mul1);
      calc <= 1;
    ELSIF rising_edge(CLK) THEN
      IF calc = 1 AND LOAD = '0' THEN
        sol := r1 * r1;
        F <= '1';
        calc <= 0;
      END IF;
      S <= std_logic_vector(sol);
    END IF;
  END PROCESS;

end Behavioral;
