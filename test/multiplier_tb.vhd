----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: multiplier_tb - Behavioral
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

ENTITY multiplier_tb IS
    GENERIC (l: NATURAL:= 32);
END multiplier_tb;

ARCHITECTURE test OF multiplier_tb IS
-- Signal Declerations
SIGNAL CLK             : std_logic := '0';
SIGNAL RST             : std_logic                                  := '1'              ;
SIGNAL LD              : std_logic                                  := '0'              ;
SIGNAL r1, r2          : std_logic_vector(l-1 DOWNTO 0)                                 ;
SIGNAL s               : std_logic_vector(2*l-1 DOWNTO 0)                               ;
SIGNAL F               : std_logic                                                      ;

constant clk_period  : time := 10 ns;

COMPONENT mult
    PORT (
        CLK : IN std_logic;
        RST             : IN std_logic;
        LD              : IN std_logic;
        MUL1, MUL2      : IN std_logic_vector(l-1 DOWNTO 0)                             ;
        S               : OUT std_logic_vector(2*l-1 DOWNTO 0)                          ;
        F               : OUT std_logic                             := '0'             );
END COMPONENT;

BEGIN
    clk_process : process
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;

    I1: mult  
      PORT MAP (
        CLK,
        RST,
        LD,
        r1,
        r2,
        s,
        F
        );
    
    multi: PROCESS
    BEGIN
      RST <= '0';
      wait for 20 ns;
      RST <= '1';
      
      wait until rising_edge(CLK);
      
      r1 <= "00000000000000000000000000000101";
      r2 <= "00000000000000000000000000000101";
      
      LD <= '1';
      wait until rising_edge(CLK);
      LD <= '0';
      
      wait until rising_edge(F);
      wait until rising_edge(CLK);
      
      r1 <= "00000000000000000000001011111111";
      r2 <= "00000000000000000000001011111111";
        
      LD <= '1';
      wait until rising_edge(CLK);
      LD <= '0';
      
      wait until rising_edge(F);
      wait until rising_edge(CLK);
      
      wait;
      
    END PROCESS;
	

END test;
