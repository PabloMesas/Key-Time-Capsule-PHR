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

ENTITY DecryptModule IS
-- Length of modulus and key in bits
GENERIC (L : NATURAL := 32; Y : NATURAL := 8);
PORT (Ck, a, n : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
      t : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);  -- t is subjet to possible changes
      k : OUT STD_LOGIC_VECTOR(Y-1 DOWNTO 0));-- Length of key will be constant
END DecryptModule;

ARCHITECTURE DecrModFunc OF DecryptModule IS
  BEGIN
    PROCESS (Ck, a, t, n)
      VARIABLE result : SIGNED(L DOWNTO 0);
      VARIABLE texp : SIGNED(L DOWNTO 0);
      -- Double length because of the multiplication of result
      VARIABLE square : SIGNED((L+1)*2-1 DOWNTO 0);
      -- Modul must have the same length as square to calculate its modulus
      VARIABLE modul : SIGNED((L+1)*2-1 DOWNTO 0);
      VARIABLE paso: SIGNED (L DOWNTO 0);
      BEGIN
        -- Loading variables
        result := SIGNED('0'&a);
        texp := SIGNED('0'&t);
        -- Setting all bits to 0
        modul := (OTHERS => '0');
        modul := modul + SIGNED('0'&n);
        paso := (OTHERS => '0');
        paso := paso + 1;

        -- Resolving the [a ^ (2 ^ t) mod n] part
        WHILE texp > 0 LOOP
          square := result * result;
          square := square mod modul;
          result := square(L DOWNTO 0); -- We only need lower L bits
          texp := texp - paso; 
        END LOOP;

        -- Resolving the subtraction part
        result := SIGNED('0'&Ck) - result;
        -- We only need the lower 256 bits
        k <= STD_LOGIC_VECTOR(result(Y-1 DOWNTO 0));
      END PROCESS;
END DecrModFunc;
