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
    GENERIC (clks: integer:= 1042; lr: integer:= 1024; lk: integer:= 256);
    PORT (
        CLK         : IN std_logic;
        RsRx        : IN std_logic;
        Tx          : OUT std_logic);
END decipher_tool;

ARCHITECTURE Behavioral OF decipher_tool IS
-- SIGNAL Declerations
SIGNAL RESET       : std_logic;
SIGNAL r_TX_DV     : std_logic                    := '0';
SIGNAL r_TX_BYTE   : std_logic_vector(7 downto 0) := (others => '0');
SIGNAL w_TX_DONE   : std_logic;
SIGNAL w_RX_DV     : std_logic;
SIGNAL w_RX_BYTE   : std_logic_vector(7 downto 0);
SIGNAL SIGE        : std_logic                   := '0';

COMPONENT uart_tx IS
    GENERIC (
      g_CLKS_PER_BIT : integer := clks);   -- Needs to be set correctly (9600)
    PORT (
      i_clk       : IN  std_logic;
      i_tx_dv     : IN  std_logic;
      i_tx_byte   : IN  std_logic_vector(7 DOWNTO 0);
      o_tx_active : OUT std_logic;
      o_tx_serial : OUT std_logic;
      o_tx_done   : OUT std_logic);
  END COMPONENT uart_tx;
 
  COMPONENT uart_rx IS
    GENERIC (
      g_CLKS_PER_BIT : integer := clks);   -- Needs to be set correctly (9600)
    PORT (
      i_clk       : IN  std_logic;
      i_rx_serial : IN  std_logic;
      o_rx_dv     : OUT std_logic;
      o_rx_byte   : OUT std_logic_vector(7 DOWNTO 0));
  END COMPONENT uart_rx;

  COMPONENT decrypt_module_v22 IS
    GENERIC (L: natural:= lr; Y: natural:= lk);   
    PORT (
      CLK       : IN std_logic;
      LOAD	    : IN std_logic;
      CK, A, N	: IN std_logic_vector(L-1 DOWNTO 0);
      T 		    : IN std_logic_vector(L-1 DOWNTO 0);
      K		      : OUT std_logic_vector(Y-1 DOWNTO 0);
      F		      : OUT std_logic);
  END COMPONENT decrypt_module_v22;
 
BEGIN

  -- Instantiate UART transmitter
  UART_TX_INST : uart_tx
    GENERIC MAP (g_CLKS_PER_BIT => clks)
    PORT MAP (
      i_clk       => CLK,
      i_tx_dv     => r_TX_DV,
      i_tx_byte   => r_TX_BYTE,
      o_tx_active => OPEN,
      o_tx_serial => Tx,
      o_tx_done   => w_TX_DONE);
 
  -- Instantiate UART Receiver
  UART_RX_INST : uart_rx
    GENERIC MAP (g_CLKS_PER_BIT => clks)
    PORT MAP (
      i_clk       => CLK,
      i_rx_serial => RsRx,
      o_rx_dv     => w_RX_DV,
      o_rx_byte   => w_RX_BYTE);
 
   
  PROCESS (CLK)
  BEGIN
    IF rising_edge(CLK) THEN
      IF r_TX_DV = '1' THEN
        r_TX_DV   <= '0';
        SIGE <= '1';
      END IF;
      IF w_RX_DV = '1' AND SIGE = '0' THEN
        r_TX_DV   <= '1';
        r_TX_BYTE <= w_RX_BYTE;
      END IF;
    END IF;
     
  END PROCESS;
  
  PROCESS
  BEGIN
    WAIT UNTIL w_TX_DONE = '1';
    SIGE <= '0';
  END PROCESS;

END Behavioral;