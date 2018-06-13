----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: mult - Behavioral
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: none
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--USE UNISIM.VComponents.all;

ENTITY mult IS
    GENERIC (
        L               : natural:= 32);            -- Data bit width
    PORT ( 
        CLK             : IN std_logic;
        RST             : IN std_logic;             -- Reset active at low level
        LOAD            : IN std_logic;             -- Load active at high level
        MUL1            : IN std_logic_vector (l-1 DOWNTO 0);
        S               : OUT std_logic_vector (l*2-1 DOWNTO 0);
        F               : OUT std_logic := '0');    -- Finish flag, when '1': end of process
END mult;

ARCHITECTURE Behavioral of mult IS
TYPE multiplier_machine IS (wait_d, calc1_d);
-- SIGNAL Declarations
SIGNAL calc             : natural           RANGE 0 TO 1            := 0                ;
SIGNAL calc_status      : natural           RANGE 0 TO 1            := 0                ;

SIGNAL r1               : unsigned          (L-1 DOWNTO 0)          := (OTHERS => '0')  ;
SIGNAL temp1            : unsigned          (L*2-1 DOWNTO 0)        := (OTHERS => '0')  ;

BEGIN
  -- Main program
  PROCESS(RST, LOAD, CLK)
  BEGIN
    IF RST = '0' THEN  -- Asynchronous Reset
      F <= '0';
      calc <= 0;
    ELSIF LOAD = '1' THEN  -- Asynchronous Load
      F <= '0';
      r1 <= unsigned(mul1);
      calc <= 1;                        -- Start calc
    ELSIF rising_edge(CLK) THEN
      IF calc = 1 AND LOAD = '0' THEN
        CASE calc_status IS
          WHEN 0 =>     -- Initiate calc 
            temp1 <= r1 * r1;           -- Square calculus
            calc_status <= 1;
          WHEN 1 =>     -- Finish calc 
            calc <= 0;                  -- Stop calc
            F <= '1';                   -- End of calculus
            calc_status <= 0;           -- Return to initial state
          WHEN OTHERS => null;
        END CASE;
      END IF;
      S <= std_logic_vector(temp1);
    END IF;
  END PROCESS;

END Behavioral;
