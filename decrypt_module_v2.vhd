--------------------------------------------------------------------------------
-- Task of this component is to resolve the formula:
-- k = Ck - a ^ (2 ^ t) mod n
--
-- pseudocode:
--	r := a
--	while t > 0:
--	  r = r ^ 2 mod n
--	  t = t -1
--	k = Ck - r
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;	-- STD_LOGIC_VECTOR()
USE IEEE.NUMERIC_STD.ALL;	-- SIGNED()

ENTITY decrypt_module_v2 is
  GENERIC (L : NATURAL := 32; Y : NATURAL := 8);
         -- Load data control
  PORT ( clock, load : IN STD_LOGIC;
         -- Input decrypt data:
         Ck, a, n : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
         -- t is subjet to possible changes
         t : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
         -- t is subjet to possible changes
         k : OUT STD_LOGIC_VECTOR(Y-1 DOWNTO 0));
END decrypt_module_v2;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

ARCHITECTURE decryptClkFunc OF decrypt_module_v2 IS
  BEGIN
    calculate : PROCESS(load, clock)
      VARIABLE result : SIGNED(L DOWNTO 0);
      VARIABLE texp : SIGNED(L DOWNTO 0);
      -- Double length because of the multiplication of result
      VARIABLE square : SIGNED((L+1)*2-1 DOWNTO 0);
      -- Modul must have the same length as square to calculate its modulus
      VARIABLE modul : SIGNED((L+1)*2-1 DOWNTO 0);
      VARIABLE rdyCalc : STD_LOGIC := '0';
      BEGIN
        IF (load = '1') THEN
          -- Loading variables
          result := SIGNED('0'&a);
          texp := SIGNED('0'&t);
          -- Setting all bits to 0
          modul := (OTHERS => '0');
          modul := modul + SIGNED('0'&n);
          -- Ready to start calculating
          rdyCalc := '1';
        ELSIF (rdyCalc = '1') THEN
          IF (rising_edge(clock)) THEN 
            IF (texp > 0) THEN
              square := result * result;
              square := square mod modul;
              result := square(L DOWNTO 0); -- We only need lower L bits
              texp := texp - 1;
            END IF;
          END IF;
          IF (texp = 0) THEN
            -- Resolving the subtraction part
            result := SIGNED('0'&Ck) - result;
            -- We only need the lower 256 bits
            k <= STD_LOGIC_VECTOR(result(Y-1 DOWNTO 0));
            -- Stop calculating
            rdyCalc := '0';
          END IF;
        END IF;        
      END PROCESS calculate;
END decryptClkFunc;

--------------------------------------------------------------------------------