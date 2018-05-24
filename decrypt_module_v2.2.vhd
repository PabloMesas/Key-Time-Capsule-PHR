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
TYPE calculus_machine     IS (ld_d, assign_d, calc1_d, calc2_d, calc3_d, find_k, t_k);
SIGNAL calculus_state   : calculus_machine := ld_d;
SIGNAL rCK              : std_logic_vector (L-1 DOWNTO 0);  -- Internal registers
SIGNAL rA               : std_logic_vector (L-1 DOWNTO 0);  -- for input data:
SIGNAL rN               : std_logic_vector (L-1 DOWNTO 0);  -- CK, A,
SIGNAL rT               : std_logic_vector (L-1 DOWNTO 0);  -- N, T

BEGIN

  PROCESS (LOAD, CLK)
  VARIABLE result	: unsigned(L-1 DOWNTO 0);
  VARIABLE texp		: unsigned(L-1 DOWNTO 0);
  -- Double length because of the multiplication of result
  VARIABLE square	: unsigned(L*2-1 DOWNTO 0);
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE modul	: unsigned(L*2-1 DOWNTO 0);
  VARIABLE ready	: std_logic := '0';
  BEGIN
    IF (LOAD = '1') THEN
      -- Loading variables
      rCK <= CK;
      rA <= A;
      rN <= N;
      rT <= T;
      F <= '0';
      -- Setting all bits to 0
      modul := (OTHERS => '0');
      ready := '1';
    ELSIF (rising_edge(CLK)) THEN
      CASE calculus_state IS
        WHEN ld_d =>
          IF ready = '1' THEN
            calculus_state <= assign_d;
          END IF;
        WHEN assign_d =>
          result := unsigned(rA);
          texp := unsigned(rT);
          modul (L-1 DOWNTO 0) := unsigned(rN);
          calculus_state <= assign_d;
        WHEN calc1_d =>
          IF texp > 0 THEN
            square := result * result;
            calculus_state <= calc2_d;
          ELSE
            calculus_state <= find_k;
          END IF;
        WHEN calc2_d =>
          square := square mod modul;
          calculus_state <= calc3_d;
        WHEN calc3_d =>
          -- We only need lower L bits
          result := square(L-1 DOWNTO 0);
          texp := texp - 1;
          calculus_state <= calc1_d;
        WHEN find_k =>
          -- Resolving the subtraction part
          result := unsigned(rCK) - result;
          calculus_state <= t_k;
        WHEN t_k =>
          -- We only need the lower 256 bits
          k <= std_logic_vector(result(Y-1 DOWNTO 0));
          -- Stop calculating
          F <= '1';
          ready := '0';
          calculus_state <= ld_d;
      END CASE;
    END IF;        
  END PROCESS;
END decryptClkFunc;

--------------------------------------------------------------------------------