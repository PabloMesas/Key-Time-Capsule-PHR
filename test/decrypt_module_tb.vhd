----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.05.2018 01:20:11
-- Design Name: 
-- Module Name: top_tb - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

ENTITY decrypt_module_tb IS
END decrypt_module_tb;

ARCHITECTURE test_1 OF decrypt_module_tb IS

  constant clk_period  : time := 10 ns;

  signal CLK           : std_logic := '0';
  signal RST           : std_logic := '1';
  signal LOAD          : std_logic := '0';
  signal CK            : std_logic_vector(31 downto 0) := "00001010000001010011110110100110";
  signal A             : std_logic_vector(31 downto 0) := "01101100111001011111010010011001";
  signal N             : std_logic_vector(31 downto 0) := "01111111010000010100100111111101";
  signal T             : std_logic_vector(31 downto 0) := "00000000000000000000000000001010";
  signal K             : std_logic_vector(7 downto 0);
  signal F             : std_logic;

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
    
    clk_process : process
    begin
      CLK <= '0';
      wait for clk_period/2;
      CLK <= '1';
      wait for clk_period/2;
    end process;

    LOAD <= '1' after 30 ns, '0' after 40 ns,
            '1' after 1.75 us, '0' after 1.76 us,
            '1' after 3.42 us, '0' after 3.43 us;
    

END test_1;






      
