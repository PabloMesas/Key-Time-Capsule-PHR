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

ENTITY decrypt_module_v21 IS
  GENERIC (L: natural:= 32; Y: natural:= 8);
         
  PORT ( CLK, LOAD	: IN std_logic;
         CK, A, N	: IN std_logic_vector(L-1 DOWNTO 0);
         t 		: IN std_logic_vector(L-1 DOWNTO 0);
         k		: OUT std_logic_vector(Y-1 DOWNTO 0);
	 F		: OUT std_logic);
END decrypt_module_v21;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

ARCHITECTURE decryptClkFunc OF decrypt_module_v21 IS
BEGIN

  PROCESS(LOAD, CK, A, N, T, CLK)
  VARIABLE result	: unsigned(L-1 DOWNTO 0);
  VARIABLE texp		: unsigned(L-1 DOWNTO 0);
  -- Double length because of the multiplication of result
  VARIABLE square	: unsigned(L*2-1 DOWNTO 0);
  -- Modul must have the same length as square to calculate its modulus
  VARIABLE modul	: unsigned(L*2-1 DOWNTO 0) := (OTHERS => '0');
  VARIABLE rdyCalc	: std_logic := '0';
  VARIABLE finished         : std_logic := '0';
  VARIABLE k_value          : std_logic_vector(Y-1 DOWNTO 0) := (OTHERS => '0');
    
  BEGIN
    IF LOAD = '1' THEN
      -- Loading variables
      result := unsigned(A);
      texp := unsigned(t);
      modul(L-1 DOWNTO 0) := unsigned(N);
      -- Ready to start calculating
      rdyCalc := '1';
      finished := '0';
    ELSIF (rising_edge(CLK) AND rdyCalc = '1') THEN
      IF (texp > 0) THEN
        square := result * result;
        square := square mod modul;
        -- We only need lower L bits
        result := square(L-1 DOWNTO 0);
        texp := texp - 1;
      ELSE
        -- Resolving the subtraction part
        result := unsigned(CK) - result;
        -- We only need the lower 256 bits
        k_value := std_logic_vector(result(Y-1 DOWNTO 0));
        -- Stop calculating
        rdyCalc := '0';
        -- Setting all bits to 0
        modul := (OTHERS => '0');
        finished := '1';
      END IF;
    END IF;
    F <= finished;
    k <= k_value;        
  END PROCESS;
END decryptClkFunc;

--------------------------------------------------------------------------------