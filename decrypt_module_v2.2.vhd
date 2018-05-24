--------------------------------------------------------------------------------
-- Task of this component is to resolve the formula:
-- k := CK - a ^ (2 ^ t) mod n
--
-- pseudocode:
--	r := a
--	while t > 0:
--	  r := r ^ 2 mod n
--	  t := t -1
--	k := CK - r
--
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY decrypt_module_v22 IS
  GENERIC (L: natural:= 32; Y: natural:= 8);   
  PORT (
        CLK       : IN std_logic;
        LOAD	    : IN std_logic;
        CK, A, N	: IN std_logic_vector(L-1 DOWNTO 0);
        T 		    : IN std_logic_vector(L-1 DOWNTO 0);
        K		      : OUT std_logic_vector(Y-1 DOWNTO 0);
	      F		      : OUT std_logic);
END decrypt_module_v22;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

ARCHITECTURE decryptClkFunc OF decrypt_module_v22 IS
SIGNAL rCK	: std_logic_vector (L-1 DOWNTO 0);  -- Internal registers
SIGNAL rA	: std_logic_vector (L-1 DOWNTO 0);  -- for input data:
SIGNAL rN	: std_logic_vector (L-1 DOWNTO 0);  -- CK, A,
SIGNAL rT	: std_logic_vector (L-1 DOWNTO 0);  -- N, T

BEGIN

  PROCESS
  VARIABLE result	: unsigned(L-1 DOWNTO 0);
  VARIABLE texp		: unsigned(L-1 DOWNTO 0);
  -- Double length because of the multiplication of result
  VARIABLE square	: unsigned(L*2-1 DOWNTO 0);
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE modul	: unsigned(L*2-1 DOWNTO 0);
  VARIABLE rdyCalc	: std_logic := '0';
    
  BEGIN
    WAIT UNTIL rising_edge(CLK);
    IF (LOAD = '1') THEN
      rCK <= CK;
      rA <= A;
      rN <= N;
      -- Loading variables
      result := unsigned(rA);
      texp := unsigned(t);   
      -- Setting all bits to 0
      modul := (OTHERS => '0');
      modul := modul + unsigned(rN);
      -- Ready to start calculating
      rdyCalc := '1';
      F <= '0';
    ELSIF (rdyCalc = '1') THEN 
      IF (texp > 0) THEN
        square := result * result;
        square := square mod modul;
        -- We only need lower L bits
        result := square(L-1 DOWNTO 0);
        texp := texp - 1;   
      ELSIF (texp = 0) THEN
        -- Resolving the subtraction part
        result := unsigned(rCK) - result;
        -- We only need the lower 256 bits
        k <= std_logic_vector(result(Y-1 DOWNTO 0));
        -- Stop calculating
        rdyCalc := '0';
        F <= '1';
      END IF;
    END IF;        
  END PROCESS;
END decryptClkFunc;

--------------------------------------------------------------------------------