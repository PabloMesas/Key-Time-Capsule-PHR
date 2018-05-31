--------------------------------------------------------------------------------
-- Test the decrypt module
--------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY decrypt_module_tb IS
END decrypt_module_tb;

ARCHITECTURE test OF decrypt_module_tb IS

  COMPONENT decrypt_module
    GENERIC (
        L           : natural := 32;
        Y           : natural := 8);
    PORT (
        CLK         : IN std_logic;
        LOAD	    : IN std_logic;
        RST         : IN std_logic;
        CK, A, N	: IN std_logic_vector(L-1 DOWNTO 0);
        t 		    : IN std_logic_vector(L-1 DOWNTO 0);
        k		    : OUT std_logic_vector(Y-1 DOWNTO 0);
	    F		    : OUT std_logic);
  END COMPONENT;

  SIGNAL CLK        : STD_LOGIC                                 := '0'              ;
  SIGNAL LOAD       : STD_LOGIC                                                     ;
  SIGNAL RST        : STD_LOGIC                                 := '1'              ;
  SIGNAL CK, A, N   : STD_LOGIC_VECTOR  (32-1 DOWNTO 0)                             ;
  SIGNAL T          : STD_LOGIC_VECTOR  (32-1 DOWNTO 0)                             ;
  SIGNAL K          : STD_LOGIC_VECTOR  (8-1 DOWNTO 0)                              ;
  SIGNAL F          : STD_LOGIC                                                     ;

  BEGIN

    I1: decrypt_module GENERIC MAP (32, 8) PORT MAP (CLK, LOAD, RST,
                                                     CK, A, N, T, K, F);

    iClock: PROCESS
    BEGIN 
      CLK <= '0';
      WAIT FOR 5 NS; CLK <='1';
      WAIT FOR 5 NS; CLK <='0';
    END PROCESS;

    LOAD <= '0' after 0 ns, '1' after 10 ns, '0' after 15 ns;


    CK <= "00000000000000000000000100111111" after 5 ns;  -- 0x7E73 / 32371

    A <= "00000000000000000000000000000011" after 5 ns;  -- 0x10 / 16

    N <= "00000000000000000000001011111111" after 5 ns;  -- 0x8C27 / 35879

    t <= "00000000000000000000000000000101" after 5 ns;  -- 0x11 / 17

							-- k1 = 0x73 / 115
							-- k2 = 0xD5 / 213
							-- k3 = 0x30 / 48
END test;

--------------------------------------------------------------------------------
