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
USE ieee.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decipher_module is
    GENERIC (L: natural:= 32; Y: natural:= 8);
    Port ( CLK      : in STD_LOGIC;
           RST      : in STD_LOGIC;
           LOAD     : in STD_LOGIC;
           CK       : in STD_LOGIC_VECTOR (L-1 downto 0);
           A        : in STD_LOGIC_VECTOR (L-1 downto 0);
           N        : in STD_LOGIC_VECTOR (L-1 downto 0);
           T        : in STD_LOGIC_VECTOR (L-1 downto 0);
           K        : out STD_LOGIC_VECTOR (Y-1 downto 0) := (OTHERS => '0');
           F        : out STD_LOGIC := '0');
end decipher_module;

architecture Behavioral of decipher_module is
TYPE calculus_machine IS (load_d, calc1_d, calc2_d, calc3_d, find_k, t_k, void);
SIGNAL calculus_state   : calculus_machine;
SIGNAL calculus_stNext  : calculus_machine := void;
SIGNAL K_Next           : std_logic_vector (Y-1 downto 0) := (OTHERS => '0');
SIGNAL F_Next           : std_logic := '0';
BEGIN

  comb: PROCESS (calculus_state, CK, A, N, T)
  VARIABLE rCK          : unsigned (L-1 DOWNTO 0);
  VARIABLE rT           : unsigned(L-1 DOWNTO 0);
    -- Double length because of the multiplication of result
  VARIABLE square    : unsigned(L*2-1 DOWNTO 0);
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE module       : unsigned(L*2-1 DOWNTO 0);
  VARIABLE result       : unsigned(L-1 DOWNTO 0);
  BEGIN
    CASE calculus_state IS
      WHEN load_d =>
        rCK := unsigned(CK);
        rT := unsigned(T);
        module := RESIZE(unsigned(N), L*2);
        result := unsigned(A);
        calculus_stNext <= calc1_d;
      WHEN calc1_d =>
        square := result * result;
        calculus_stNext <= calc2_d;
      WHEN calc2_d =>
        result := square(L-1 DOWNTO 0);
        calculus_stNext <= calc3_d;
      WHEN calc3_d =>
        IF square >= module THEN
          square := square - module;
          calculus_stNext <= calc2_d;
        ELSE
          calculus_stNext <= find_k;
        END IF;
      WHEN find_k =>
        result := rCK - result;
        calculus_stNext <= t_k;
      WHEN t_k =>
        K_Next <=  std_logic_vector(result(Y-1 DOWNTO 0)) ;
        F_Next <= '1';
        calculus_stNext <= void;
      WHEN void =>
        calculus_stNext <= void;
    END CASE;
  END PROCESS;
  
  PROCESS (RST, LOAD, CLK)
  BEGIN
  IF LOAD = '1' THEN
    F <= '0';
    calculus_state <= load_d;
  ELSIF RST = '0' THEN
    F <= '0';
    calculus_state <= void;
  ELSIF rising_edge(CLK) THEN
    K <= K_Next;
    F <= F_Next;
    calculus_state <= calculus_stNext;
  END IF;
  END PROCESS;


end Behavioral;
