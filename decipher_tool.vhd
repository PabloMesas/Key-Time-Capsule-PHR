----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: decipher_tool - Behavioral
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- DepENDencies: 
-- 
-- RevISion:
-- RevISion 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY decipher_tool IS
    GENERIC (l: inTEGER:= 1024);
    PORT (
        CLK         : IN std_logic;
        RsRx        : IN std_logic;
        Tx          : IN std_logic;
        RESET       : IN std_logic;
        CK          : IN std_logic_vector(l DOWNTO 0);
        A           : IN std_logic_vector(l DOWNTO 0);
        N           : IN std_logic_vector(l DOWNTO 0);
        T           : IN std_logic_vector(l DOWNTO 0);
        K           : OUT std_logic_vector(l DOWNTO 0));
END decipher_tool;

ARCHITECTURE Behavioral OF decipher_tool IS
-- SIGNAL Declerations
SIGNAL RESET        : std_logic;
SIGNAL o_rx_dv      : std_logic;
SIGNAL o_rx_byte    : std_logic_vector(7 DOWNTO 0);
SIGNAL i_tx_dv      : std_logic;
SIGNAL i_tx_byte    : std_logic_vector(7 DOWNTO 0);
SIGNAL count        : std_logic_vector(16 DOWNTO 0) := (OTHERS => '0');

COMPONENT uart_tx IS
    GENERIC (
      g_CLKS_PER_BIT : integer := 1042   -- Needs to be set correctly (9600)
      );
    PORT (
      i_clk       : IN  std_logic;
      i_tx_dv     : IN  std_logic;
      i_tx_byte   : IN  std_logic_vector(7 DOWNTO 0);
      o_tx_active : OUT std_logic;
      o_tx_serial : OUT std_logic;
      o_tx_done   : OUT std_logic
      );
  END COMPONENT uart_tx;
 
  COMPONENT uart_rx IS
    GENERIC (
      g_CLKS_PER_BIT : integer := 1042   -- Needs to be set correctly (9600)
      );
    PORT (
      i_clk       : IN  std_logic;
      i_rx_serial : IN  std_logic;
      o_rx_dv     : OUT std_logic;
      o_rx_byte   : OUT std_logic_vector(7 DOWNTO 0)
      );
  END COMPONENT uart_rx;

    -- Low-level byte-write
  PROCEDURE uart_write_byte (
    i_data_IN       : IN  std_logic_vector(7 DOWNTO 0);
    SIGNAL o_serial : OUT std_logic) IS
  BEGIN
 
    -- send Start Bit
    o_serial <= '0';
    WAIT for c_BIT_PERIOD;
 
    -- send Data Byte
    for ii IN 0 to 7 loop
      o_serial <= i_data_IN(ii);
      WAIT for c_BIT_PERIOD;
    END loop;  -- ii
 
    -- send Stop Bit
    o_serial <= '1';
    WAIT for c_BIT_PERIOD;
  END uart_write_byte;
 
  -- INstantiate UART transmitter
  UART_TX_INST : uart_tx
    GENERIC MAP (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    PORT MAP (
      i_clk       => CLK,
      i_tx_dv     => r_TX_DV,
      i_tx_byte   => r_TX_BYTE,
      o_tx_active => OPEN,
      o_tx_serial => w_TX_SERIAL,
      o_tx_done   => w_TX_DONE
      );
 
  -- INstantiate UART Receiver
  UART_RX_INST : uart_rx
    GENERIC MAP (
      g_CLKS_PER_BIT => c_CLKS_PER_BIT
      )
    PORT MAP (
      i_clk       => CLK,
      i_rx_serial => r_RX_SERIAL,
      o_rx_dv     => w_RX_DV,
      o_rx_byte   => w_RX_BYTE
      );
 
   
  PROCESS IS -- MANEJANDO CHICHA
  BEGIN
 
    -- Tell the UART to send a command.
    WAIT UNTIL rising_edge(CLK);
    WAIT UNTIL rising_edge(CLK);
    r_TX_DV   <= '1';
    r_TX_BYTE <= X"AB";
    WAIT UNTIL rising_edge(CLK);
    r_TX_DV   <= '0';
    WAIT UNTIL w_TX_DONE = '1';
 
     
    -- send a command to the UART
    WAIT UNTIL rising_edge(CLK);
    uart_write_byte(X"3F", r_RX_SERIAL);
    WAIT UNTIL rising_edge(CLK);
 
    -- Check that the correct command was received
    if w_RX_BYTE = X"3F" THEN
      rePORT "Test Passed - Correct Byte Received" severity NOTe;
    else
      rePORT "Test Failed - INcorrect Byte Received" severity NOTe;
    END if;
 
    assert false rePORT "Tests Complete" severity failure;
     
  END PROCESS;

END Behavioral;