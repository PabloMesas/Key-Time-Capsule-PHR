----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: decipher_module - Behavioral
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: mult.vhd, modulus.vhd
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
--use UNISIM.VComponents.all;

ENTITY decrypt_module is
  GENERIC (
      L                 : natural:= 32;             -- CK, A, N, T bit width
      Y                 : natural:= 8);             -- K bits width
  PORT (
      CLK               : IN std_logic;
      RST               : IN std_logic;             -- Reset, active at low level
      LOAD              : IN std_logic;             -- Load data, active at high level
      CK                : IN std_logic_vector (L-1 DOWNTO 0);
      A                 : IN std_logic_vector (L-1 DOWNTO 0);
      N                 : IN std_logic_vector (L-1 DOWNTO 0);
      T                 : IN std_logic_vector (L-1 DOWNTO 0);
      K                 : OUT std_logic_vector(Y-1 DOWNTO 0) := (OTHERS => '0');
	  F                 : OUT std_logic := '0');    -- Finish flag, when '1': end of process
END decrypt_module;

ARCHITECTURE Behavioral OF decrypt_module IS
-- SIGNAL Declarations
SIGNAL calculus_state   : natural           RANGE 0 TO 6            := 0                ;

SIGNAL MCalc            : std_logic                                 := '0'              ;
SIGNAL CLK_1            : std_logic                                 := '1'              ;
SIGNAL LOAD_mult        : std_logic                                 := '0'              ;
SIGNAL MUL1             : std_logic_vector    (L-1 DOWNTO 0)                            ;
SIGNAL S_mult           : std_logic_vector    (L*2-1 DOWNTO 0)                          ;
SIGNAL F_mult           : std_logic                                 := '0'              ;

SIGNAL MdCalc           : std_logic                                 := '0'              ;
SIGNAL CLK_2            : std_logic                                 := '1'              ;
SIGNAL LOAD_mod         : std_logic                                 := '0'              ;
SIGNAL NUM              : std_logic_vector    (L*2-1 DOWNTO 0)                          ;
SIGNAL N_mod            : std_logic_vector    (L-1 DOWNTO 0)                            ;
SIGNAL S_mod            : std_logic_vector    (L-1 DOWNTO 0)                            ;
SIGNAL F_mod            : std_logic                                 := '0'              ;

SIGNAL result           : unsigned            (L-1 DOWNTO 0)        := (OTHERS => '0')  ;
SIGNAL expT             : unsigned            (L-1 DOWNTO 0)        := (OTHERS => '0')  ;
SIGNAL temp1            : unsigned            (L-1 DOWNTO 0)        := (OTHERS => '0')  ;


COMPONENT mult IS
  GENERIC (
      L     : natural:= L);
  PORT (
      CLK   : IN std_logic;
      RST   : IN std_logic;
      LOAD  : IN std_logic;
      MUL1  : IN std_logic_vector (L-1 DOWNTO 0);
      S     : OUT std_logic_vector (L*2-1 DOWNTO 0) := (OTHERS => '0');
      F     : OUT std_logic := '0');
END COMPONENT mult;

COMPONENT modulus IS
  GENERIC (
      L   : natural:= L);
  PORT (
      CLK : IN std_logic;
      RST : IN std_logic;
      LOAD : IN std_logic;
      NUM : IN std_logic_vector (L*2-1 DOWNTO 0);
      N : IN std_logic_vector (L-1 DOWNTO 0);
      S : OUT std_logic_vector (L-1 DOWNTO 0) := (OTHERS => '0');
      F : OUT std_logic := '0');
END COMPONENT modulus;

BEGIN
  -- Instantiation:
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

  -- Instantiation:  
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
        
  -- Main program
  Controller: PROCESS (RST, LOAD, CLK)
  VARIABLE module       : unsigned          (L-1 DOWNTO 0)       := (OTHERS => '0')   ;
  VARIABLE CKey         : unsigned          (L-1 DOWNTO 0)       := (OTHERS => '0')   ;
  VARIABLE tempT        : unsigned          (L-1 DOWNTO 0)       := (OTHERS => '0')   ;
  VARIABLE tempResult   : unsigned          (L-1 DOWNTO 0)       := (OTHERS => '0')   ;
  BEGIN
    IF RST = '0' THEN  -- Asynchronous Reset
      F <= '0';
      Mcalc <= '0';
      MdCalc <= '0';
      calculus_state <= 0;
    ELSIF LOAD = '1' THEN  -- Asynchronous Load
      F <= '0';
      calculus_state <= 1;
    ELSIF rising_edge(CLK) THEN
      CASE calculus_state IS
        WHEN 0 => null;
        WHEN 1 =>       -- Load Data
          IF LOAD = '0' THEN
            tempT       := unsigned(T);
            module      := unsigned(N);
            tempResult  := unsigned(A);
            CKey        := unsigned(CK);
            calculus_state <= 2;
          END IF;
        WHEN 2 =>       -- If expT > 0 : do exp mod
          IF expT > 0 THEN              -- If current T > 0
            LOAD_mult <= '1';               -- Load data into mult module
            MUL1 <= std_logic_vector(result);
            Mcalc <= '1';                   -- Start mult module clock
            calculus_state <= 3;
          ELSE                          -- Else end exp mod calculus
            calculus_state <= 5;
          END IF;
        WHEN 3 =>       -- Start mult calc, wait to finish and load modul calc
          LOAD_mult <= '0';                 -- Start mult calc
          IF F_mult = '1' THEN
            LOAD_mod <= '1';                -- Load data into modul module
            NUM <= S_mult;                  -- Out of mult => In of modul
            N_mod <= std_logic_vector(module);
            Mcalc <= '0';                   -- Stop mult module clock
            Mdcalc <= '1';                  -- Start modul module clock
            calculus_state <= 4;
          END IF;
        WHEN 4 =>       -- Start modul calc, wait to finish and decrement T
          LOAD_mod <= '0';
          IF F_mod = '1' THEN
            tempResult := unsigned(S_mod);
            tempT := expT - 1;              -- Decrement T
            Mdcalc <= '0';                  -- Stop modul module clock
            calculus_state <= 2;            -- Return to evaluate T
          END IF;
        WHEN 5 =>       -- Substraction of CK
          temp1 <= CKey - result;           -- Ending K calculus
          calculus_state <= 6;
        WHEN 6 =>       -- Writting K and turning F to '1'
          K <= std_logic_vector(temp1(Y-1 DOWNTO 0)) ;
          F <= '1';                         -- End of K calculus
          calculus_state <= 0;              -- Return to initial state
      END CASE;
      result <= tempResult;
      expT <= tempT;
    END IF;
  END PROCESS;
  
  -- Frequency divider (mul)
  dividerMul: PROCESS (CLK)
  -- Needed to complete the operation behind this clock.
  -- Adjusted to achieve a '*' operation with 32 bit width data.
  VARIABLE count        : natural RANGE 0 to 2; -- CLK divider
  BEGIN
    IF Mcalc = '0' THEN     -- Stop subCLK
      count := 0;
      CLK_1 <= '1';
    ELSIF rising_edge(CLK) THEN
      IF count = 2 THEN
        count := 0;
        CLK_1 <= NOT CLK_1; -- Invert state
      ELSE
        count := count + 1;
      END IF;
    END IF;  
  END PROCESS;
  
  -- Frequency divider (modul)
  dividerMod: PROCESS (CLK)
  -- Needed to complete the operation behind this clock.
  -- Adjusted to achieve a 'mod' operation with 32 bit width data
  VARIABLE count        : natural RANGE 0 to 6; -- CLK divider
  BEGIN
    IF Mdcalc = '0' THEN    -- Stop subCLK
      count := 0;
      CLK_2 <= '1';
    ELSIF rising_edge(CLK) THEN
      IF count = 6 THEN
        count := 0;
        CLK_2 <= NOT CLK_2; -- Invert state
      ELSE
        count := count + 1;
      END IF;
    END IF;  
  END PROCESS;

END Behavioral;
