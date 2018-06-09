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
      RST               : IN std_logic;
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
SIGNAL LOAD_mult        : std_logic                                 := '0'              ;
SIGNAL MUL1             : std_logic_vector    (l-1 downto 0)                            ;
SIGNAL S_mult           : std_logic_vector    (l*2-1 downto 0)                          ;
SIGNAL F_mult           : std_logic                                 := '0'              ;
SIGNAL CLK_1            : std_logic                                 := '0'              ;
SIGNAL LOAD_mod         : std_logic                                 := '0'              ;
SIGNAL NUM              : std_logic_vector    (l*2-1 downto 0)                          ;
SIGNAL N_mod            : std_logic_vector    (l-1 downto 0)                            ;
SIGNAL S_mod            : std_logic_vector    (l-1 downto 0)                            ;
SIGNAL F_mod            : std_logic                                 := '0'              ;
SIGNAL CLK_2            : std_logic                                 := '0'              ;
SIGNAL calculus_state   : natural           RANGE 0 TO 6            := 0                ;

  -- Double length because of the multiplication of result
SIGNAL result           : std_logic_vector    (L-1 DOWNTO 0)        := (OTHERS => '0')  ;
SIGNAL expT             : unsigned            (L-1 DOWNTO 0)        := (OTHERS => '0')  ;

COMPONENT mult IS
  GENERIC (
      L   : natural:= L);
  PORT (
      CLK : IN std_logic;
      RST : in std_logic;
      LOAD : in std_logic;
      MUL1 : in STD_LOGIC_VECTOR (l-1 downto 0);
      S : out STD_LOGIC_VECTOR (l*2-1 downto 0) := (OTHERS => '0');
      F : out STD_LOGIC := '0');
END COMPONENT mult;

COMPONENT modulus IS
  GENERIC (
      L   : natural:= L);
  PORT (
      CLK : IN std_logic;
      RST : in std_logic;
      LOAD : in std_logic;
      NUM : in STD_LOGIC_VECTOR (l*2-1 downto 0);
      N : in STD_LOGIC_VECTOR (l-1 downto 0);
      S : out STD_LOGIC_VECTOR (l-1 downto 0) := (OTHERS => '0');
      F : out STD_LOGIC := '0');
END COMPONENT modulus;

BEGIN
  multi: mult
  GENERIC MAP(
          L             => L
          )   
      PORT MAP(
          CLK           => CLK_1,
          RST           => RST,
          LOAD          => LOAD_mult,
          MUL1          => MUL1,
          S             => S_mult,
          F             => F_mult
          );
  
  modul: modulus
  GENERIC MAP(
          L             => L
          )   
      PORT MAP(
          CLK           => CLK_2,
          RST           => RST,
          LOAD          => LOAD_mod,
          NUM           => NUM,
          N             => N_mod,
          S             => S_mod,
          F             => F_mod
          );
        
  comb: PROCESS (LOAD, CLK)
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE module       : unsigned          (L-1 DOWNTO 0)       := (OTHERS => '0')   ;
  BEGIN
    IF LOAD = '1' THEN
      F <= '0';
      calculus_state <= 1;
    ELSIF rising_edge(CLK) THEN
      CASE calculus_state IS
        WHEN 1 =>                     -- Loading Data
          IF LOAD = '0' THEN
            expT    <= unsigned(T);
            module  := unsigned(N);
            result  <= A;
            calculus_state <= 2;
          END IF;
        WHEN 2 =>                     -- If expT > 0 : do exp mod
          IF expT > 0 THEN
            LOAD_mult <= '1';
            MUL1 <= std_logic_vector(result);
            calculus_state <= 3;
          ELSE
            calculus_state <= 5;
          END IF;
        WHEN 3 =>
          LOAD_mult <= '0';
          IF F_mult = '1' THEN
            LOAD_mod <= '1';
            NUM <= S_mult;
            N_mod <= std_logic_vector(module);
            calculus_state <= 4;
          END IF;
        WHEN 4 =>
          LOAD_mod <= '0';
          IF F_mod = '1' THEN
            result <= S_mod;
            expT <= expT - 1;
            calculus_state <= 2;
          END IF;
        WHEN 5 =>
          result <= std_logic_vector(unsigned(CK) - unsigned(result));
          calculus_state <= 6;
        WHEN 6 =>
          K <= result(Y-1 DOWNTO 0) ;
          F <= '1';
          calculus_state <= 0;
        WHEN 0 =>
          calculus_state <= 0;
      END CASE;
    END IF;
  END PROCESS;
  
  dividerMul: PROCESS (CLK)
    VARIABLE count        : natural RANGE 0 to 1;
    BEGIN
    IF rising_edge(CLK) THEN
      IF count = 1 THEN
        count := 0;
        CLK_1 <= NOT CLK_1;
      ELSE
        count := count + 1;
      END IF;
    END IF;  
    END PROCESS;
    
  dividerMod: PROCESS (CLK)
    VARIABLE count        : natural RANGE 0 to 1;
    BEGIN
    IF rising_edge(CLK) THEN
      IF count = 1 THEN
        count := 0;
        CLK_2 <= NOT CLK_2;
      ELSE
        count := count + 1;
      END IF;
    END IF;  
    END PROCESS;

end Behavioral;
