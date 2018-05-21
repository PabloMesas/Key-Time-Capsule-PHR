--------------------------------------------------------------------------------
-- Test the decrypt module
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TestDecryptModule21 IS
END TestDecryptModule21;

ARCHITECTURE test OF TestDecryptModule21 IS

  COMPONENT decrypt_module_v22
    GENERIC (L : NATURAL := 32; Y : NATURAL := 8);
    PORT ( CLK, LOAD	: IN std_logic;
         CK, A, N	: IN std_logic_vector(L-1 DOWNTO 0);
         t 		: IN std_logic_vector(L-1 DOWNTO 0);
         k		: OUT std_logic_vector(Y-1 DOWNTO 0);
	 F		: OUT std_logic);
  END COMPONENT;

  SIGNAL CLK, LOAD : STD_LOGIC;
  SIGNAL CK, A, N : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL t : STD_LOGIC_VECTOR(32-1 DOWNTO 0);
  SIGNAL k : STD_LOGIC_VECTOR(8-1 DOWNTO 0);
  SIGNAL F : STD_LOGIC;

  BEGIN

    I1: decrypt_module_v22 GENERIC MAP (32, 8) PORT MAP (CLK, LOAD,
                                                     CK, A, N, t, k, F);

    iClock: PROCESS
    BEGIN 
      CLK <= '0';
      WAIT FOR 5 NS; CLK <='1';
      WAIT FOR 5 NS; CLK <='0';
    END PROCESS;

    LOAD <= '0' after 0 ns, '1' after 10 ns, '0' after 15 ns, 
            '1' after 75 ns, '0' after 80 ns,
            '1' after 200 ns, '0' after 205 ns;


    CK <= "00000000000000000000000100111111" after 5 ns,   -- 0x13F  / 319
          "00000000000000000000100111111101" after 40 ns,  -- 0x9FD  / 255;
          "00000000000000000111111001110011" after 195 ns;  -- 0x7E73 / 32371

    A <= "00000000000000000000000000000011" after 5 ns,   -- 0x3  / 3
         "00000000000000000000000000011010" after 40 ns,  -- 0x1A / 26
         "00000000000000000000000000010000" after 195 ns;  -- 0x10 / 16

    N <= "00000000000000000000001011111111" after 5 ns,   -- 0x2FF  / 767
         "00000000000000000001000110110101" after 40 ns,  -- 0x11B5 / 4533
         "00000000000000001000110000100111" after 195 ns;  -- 0x8C27 / 35879

    t <= "00000000000000000000000000000101" after 5 ns,   -- 0x5  / 5
         "00000000000000000000000000001011" after 70 ns,  -- 0xB  / 11
         "00000000000000000000000000010001" after 195 ns;  -- 0x11 / 17

							-- k1 = 0x73 / 115
							-- k2 = 0xD5 / 213
							-- k3 = 0x30 / 48
END test;

--------------------------------------------------------------------------------
