----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: top_tb - FULL
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: top.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY top_tb IS
END top_tb;

ARCHITECTURE FULL OF top_tb IS
-- Signal declarations
SIGNAL CLK           : std_logic                       := '0'                                  ;
SIGNAL ledRST        : std_logic                       := '1'                                  ;
SIGNAL sw            : std_logic                       := '1'                                  ;
SIGNAL rx            : std_logic                       := '1'                                  ;
SIGNAL tx            : std_logic;

CONSTANT clk_period  : time := 10 ns;      -- 100 MHz
CONSTANT uart_period : time := 104.17 us;  -- 9600 Bauds
CONSTANT data_length : natural := 8;       -- Data bus width: bit size
CONSTANT data_ck     : std_logic_vector(31 DOWNTO 0)   := "00100000111101101100010100110101"   ;
CONSTANT data_a      : std_logic_vector(31 DOWNTO 0)   := "00101011101000101010111010011101"   ;
CONSTANT data_n      : std_logic_vector(31 DOWNTO 0)   := "01101101000110001101010011101111"   ;
CONSTANT data_t      : std_logic_vector(31 DOWNTO 0)   := "00000000000000010000000000000000"   ;
  
-- Component to test:
COMPONENT top IS
  PORT (
    CLK         : IN std_logic;
    ledRST      : OUT std_logic;
    Sw          : IN std_logic;
    RsRx        : IN std_logic;
    Tx          : OUT std_logic);
END COMPONENT top;

BEGIN
  -- Instantiation:
  top_mod: top
  PORT MAP (
    CLK => CLK,
    ledRST => ledRST,
    Sw => sw,
    RsRx => rx,
    Tx => tx
    );
  
  -- Process: CLK simulator
  Clk_process : PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR clk_period/2;
    CLK <= '1';
    WAIT FOR clk_period/2;
  END PROCESS;

  -- Process: Rx simulator (incoming data)
  test_rx_uart : PROCESS
  VARIABLE count         : integer RANGE 0 TO 7;
  BEGIN
    rx <= '1';  -- Rx: standby level
    
    Sw <= '0';  -- Reset: active at low level
    WAIT FOR 100 ns;
    Sw <= '1';  -- Reset: deactivated at high level

    WAIT UNTIL rising_edge(CLK);

    count := 0;
    -- Transmitting: CK data variable
    FOR i IN 0 TO (data_ck'LENGTH-1) LOOP
      IF count = 0 THEN
        rx <= '0'; -- start bit
        WAIT FOR uart_period;
      END IF;
        
      rx <= data_ck(i); -- data bits
      WAIT FOR uart_period;
      
      IF count = 7 THEN
        rx <= '1'; -- stop bit
        WAIT FOR uart_period;
        count := 0;
      ELSE
        count := count + 1;
      END IF;
    END LOOP;
    
    WAIT UNTIL rising_edge(CLK);
    
    -- TransmittINg: A data variable
    FOR i IN 0 TO (data_a'LENGTH-1) LOOP
      IF count = 0 THEN
        rx <= '0'; -- start bit
        WAIT FOR uart_period;
      END IF;
            
      rx <= data_a(i); -- data bits
      WAIT FOR uart_period;
            
      IF count = 7 THEN
        rx <= '1'; -- stop bit
        WAIT FOR uart_period;
        count := 0;
      ELSE
        count := count + 1;
      END IF;
    END LOOP;
        
    WAIT UNTIL rising_edge(CLK);
    
    -- TransmittINg: N data variable
    FOR i IN 0 TO (data_n'LENGTH-1) LOOP
      IF count = 0 THEN
        rx <= '0'; -- start bit
        WAIT FOR uart_period;
      END IF;
            
      rx <= data_n(i); -- data bits
      WAIT FOR uart_period;
           
      IF count = 7 THEN
        rx <= '1'; -- stop bit
        WAIT FOR uart_period;
        count := 0;
      ELSE
        count := count + 1;
      END IF;
    END LOOP;
        
    WAIT UNTIL rising_edge(CLK);
    
    -- TransmittINg: T data variable    
    FOR i IN 0 TO (data_t'LENGTH-1) LOOP
      IF count = 0 THEN
        rx <= '0'; -- start bit
        WAIT FOR uart_period;
      END IF;
            
      rx <= data_t(i); -- data bits
      WAIT FOR uart_period;
            
      IF count = 7 THEN
        rx <= '1'; -- stop bit
        WAIT FOR uart_period;
        count := 0;
      ELSE
        count := count + 1;
      END IF;
    END LOOP;

    rx <= '1'; -- stop bit
    WAIT FOR uart_period;

    -- Rx: standby level
    rx <= '1';
    WAIT FOR uart_period;

    WAIT;

  END PROCESS;

END FULL;
