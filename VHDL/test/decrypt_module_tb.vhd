----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: decrypt_module_tb - FULL
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: decrypt_module.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY decrypt_module_tb IS
END decrypt_module_tb;

ARCHITECTURE FULL OF decrypt_module_tb IS
  -- Signal declarations
SIGNAL CLK           : std_logic                      := '0'                                  ;
SIGNAL RST           : std_logic                      := '1'                                  ;
SIGNAL LOAD          : std_logic                      := '0'                                  ;
SIGNAL CK            : std_logic_vector(31 downto 0)  := "00001010000001010011110110100110"   ;
SIGNAL A             : std_logic_vector(31 downto 0)  := "01101100111001011111010010011001"   ;
SIGNAL N             : std_logic_vector(31 downto 0)  := "01111111010000010100100111111101"   ;
SIGNAL T             : std_logic_vector(31 downto 0)  := "00000000000000000000000000001010"   ;
SIGNAL K             : std_logic_vector(7 downto 0);
SIGNAL F             : std_logic;
  
CONSTANT clk_period  : time := 10 ns;  -- 100 MHz

-- Component to test:
COMPONENT decrypt_module IS
  PORT (
    CLK               : IN std_logic;
    RST               : IN std_logic;
    LOAD              : IN std_logic;
    CK                : IN std_logic_vector (31 DOWNTO 0);
    A                 : IN std_logic_vector (31 DOWNTO 0);
    N                 : IN std_logic_vector (31 DOWNTO 0);
    T                 : IN std_logic_vector (31 DOWNTO 0);
    K                 : OUT std_logic_vector (7 DOWNTO 0);
    F                 : OUT std_logic := '0');
  END COMPONENT decrypt_module;

BEGIN
  -- Instantiation:
  decrypt_mod: decrypt_module
  PORT MAP (
    CLK => CLK,
    RST => RST,
    LOAD => LOAD,
    CK => CK,
    A => A,
    N => N,
    T => T,
    K => K,
    F => F
    );

  -- Process: CLK simulator
  clk_process : PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR clk_period/2;
    CLK <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  test: PROCESS
  BEGIN
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '1';                -- Load data
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '0';                -- Start decrypt
  
    WAIT UNTIL rising_edge(F);  -- Wait to finish
    
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '1';                -- Load data
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '0';                -- Start decrypt
  
    WAIT UNTIL rising_edge(F);  -- Wait to finish
    
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '1';                -- Load data
    WAIT UNTIL rising_edge(CLK);
    LOAD <= '0';                -- Start decrypt
  
    WAIT UNTIL rising_edge(F);  -- Wait to finish
    
    WAIT;
  END PROCESS;
END FULL;







