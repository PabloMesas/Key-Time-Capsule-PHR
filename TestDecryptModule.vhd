--------------------------------------------------------------------------------
-- Test the decrypt module
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TestDecryptModule IS
END TestDecryptModule;

ARCHITECTURE test1 OF TestDecryptModule IS

  COMPONENT DecryptModule
    GENERIC (L : NATURAL := 32; Y : NATURAL := 8);
    PORT (Ck, a, n : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
        t : IN STD_LOGIC_VECTOR(L-1 DOWNTO 0);
        k : OUT STD_LOGIC_VECTOR(Y-1 DOWNTO 0)
       );
  END COMPONENT;

  SIGNAL Ck, a, n : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL t : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL k : STD_LOGIC_VECTOR(8-1 DOWNTO 0);

  BEGIN

    I1: DecryptModule GENERIC MAP (32, 8) PORT MAP (Ck, a, n, t, k);

    Ck <= "00000000000000000000000100111111" after 0 ns,   -- 0x13F  / 319
          "00000000000000000000100111111101" after 20 ns,  -- 0x9FD  / 2557
          "00000000000000000111111001110011" after 40 ns;  -- 0x7E73 / 32371

    a <= "00000000000000000000000000000011" after 0 ns,   -- 0x3  / 3
         "00000000000000000000000000011010" after 20 ns,  -- 0x1A / 26
         "00000000000000000000000000010000" after 40 ns;  -- 0x10 / 16

    n <= "00000000000000000000001011111111" after 0 ns,   -- 0x2FF  / 767
         "00000000000000000001000110110101" after 20 ns,  -- 0x11B5 / 4533
         "00000000000000001000110000100111" after 40 ns;  -- 0x8C27 / 35879

    t <= "00000000000000000000000000000101" after 0 ns,   -- 0x5  / 5
         "00000000000000000000000000001011" after 20 ns,  -- 0xB  / 11
         "00000000000000000000000000010001" after 40 ns;  -- 0x11 / 17

							-- k1 = 0x73 / 115
							-- k2 = 0xD5 / 213
							-- k3 = 0x30 / 48
END test1;