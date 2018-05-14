-- task of this file is to resolve the formula:
-- s = a ^ (2 ^ t) mod n

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;	--- For STD_LOGIC_VECTOR
USE IEEE.NUMERIC_STD.ALL;	--- For SIGNED

ENTITY PowerModulus IS
PORT (a, t, n : IN STD_LOGIC_VECTOR(127 DOWNTO 0); -- 128 bits length just for testing
      r : OUT STD_LOGIC_VECTOR(127 DOWNTO 0));
END PowerModulus;

ARCHITECTURE PowModFunc OF PowerModulus IS
  BEGIN
    PROCESS (a, t, n)
      VARIABLE result: SIGNED(128 DOWNTO 0);  -- Adding 1 more bit for sign in case we do a substraction
      VARIABLE texp: SIGNED(128 DOWNTO 0);
      VARIABLE modul: SIGNED(257  DOWNTO 0);  -- modul and square must have the same length
      VARIABLE square: SIGNED(257 DOWNTO 0);
      BEGIN      
        --  pseudocode:
        -- r := a
        -- while t > 0:
        --   r = r ^ 2 mod n
        --   t = t -1

        result := SIGNED('0'&a);
        texp := SIGNED('0'&t);
        modul := (OTHERS => '0');
        modul := modul + SIGNED('0'&n);

        WHILE texp > 0
        LOOP
          square := result * result;  -- Result must have double length of factors
          square := square mod modul; -- Module body must have the same fucking length as left variable >:(
          result := square(128 DOWNTO 0); -- We only need lower 128 bits xddd
          texp := texp - 1; 
        END LOOP;

        r <= STD_LOGIC_VECTOR(result(127 DOWNTO 0));
      END PROCESS;
END PowModFunc;
