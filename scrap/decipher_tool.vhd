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
    GENERIC (lr: natural:= 32; lk: natural:= 8; d_width: natural:= 8; clk_freq: integer:= 100_000_000);
    PORT (
        CLK         : IN std_logic;
        led         : OUT std_logic_vector(7 DOWNTO 0);
        RsRx        : IN std_logic;
        Tx          : OUT std_logic);
END decipher_tool;

ARCHITECTURE Behavioral OF decipher_tool IS
TYPE cipher_machine     IS (r_CK, r_A, r_N, r_T, ld_data, wait_F, t_K);
-- SIGNAL Declerations
SIGNAL tiuring_state    : cipher_machine;
SIGNAL tiuring_stNext   : cipher_machine               := r_CK;
SIGNAL rx_state         : natural RANGE 0 TO 1;
SIGNAL rx_stNext        : natural RANGE 0 TO 1 := 0;
SIGNAL tx_state         : natural RANGE 0 TO 1;
SIGNAL tx_stNext        : natural RANGE 0 TO 1 := 0;
SIGNAL RST              : std_logic                    := '0';
SIGNAL DATA_SEND        : std_logic                    := '0';
SIGNAL DATA_IN          : std_logic_vector(d_width-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL TX_BUSY          : std_logic;
SIGNAL DATA_VLD         : std_logic;
SIGNAL DATA_OUT         : std_logic_vector(d_width-1 DOWNTO 0);
SIGNAL RX_BUSY          : std_logic;
SIGNAL Rx_BUF           : std_logic_vector(lr*2-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL Tx_BUF           : std_logic_vector(lk*2-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL DATA_INDEX       : natural RANGE 0 TO lr := 0;

SIGNAL LD               : std_logic := '0';
SIGNAL CK               : std_logic_vector (lr-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL A                : std_logic_vector (lr-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL N                : std_logic_vector (lr-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL T                : std_logic_vector (lr-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL K                : std_logic_vector (lk-1 DOWNTO 0);
SIGNAL F                : std_logic;
  
  COMPONENT UART IS
      GENERIC(
          clk_freq      : integer       := clk_freq; --frequency of system clock in Hertz
          baud_rate     : integer       := 9600;        --data link baud rate in bits/second
          os_rate       : integer       := 16;          --oversampling rate to find center of receive bits (in samples per baud period)
          d_width       : integer       := d_width;           --data bus width
          parity        : integer       := 0;           --0 for no parity, 1 for parity
          parity_eo     : std_logic     := '0');        --'0' for even, '1' for odd parity
      PORT(
          clk           : IN std_logic;                             --system clock
          reset_n       : IN std_logic;                             --ascynchronous reset
          tx_ena        : IN std_logic;                             --initiate transmission
          tx_data       : IN std_logic_vector(d_width-1 DOWNTO 0);  --data to transmit
          rx            : IN std_logic;                             --receive pin
          rx_busy       : OUT std_logic;                            --data reception in progress
          rx_error      : OUT std_logic;                            --start, parity, or stop bit error detected
          rx_data       : OUT std_logic_vector(d_width-1 DOWNTO 0); --data received
          tx_busy       : OUT std_logic;                            --transmission in progress
          tx            : OUT std_logic);                           --transmit pin
  END COMPONENT UART;

  COMPONENT decipher_module IS
    GENERIC (L: natural:= 32; Y: natural:= 8);   
    PORT (
      CLK           : IN std_logic;
      RST           : IN STD_LOGIC;
      LOAD          : IN std_logic;
      CK            : IN std_logic_vector(L-1 DOWNTO 0);
      A             : IN std_logic_vector(L-1 DOWNTO 0);
      N             : IN std_logic_vector(L-1 DOWNTO 0);
      T             : IN std_logic_vector(L-1 DOWNTO 0);
      K             : OUT std_logic_vector(Y-1 DOWNTO 0);
      F             : OUT std_logic);
  END COMPONENT decipher_module;
 
BEGIN

utt: UART
    GENERIC MAP(
		clk_freq      => clk_freq,
		baud_rate     => 9600,
		os_rate       => 16,
		d_width       => d_width,
		parity        => 0,
		parity_eo     => '0'
		)
	PORT MAP(
		clk           => CLK,
		reset_n       => RST,
		tx_ena        => DATA_SEND,
		tx_data       => DATA_IN,
		rx            => RsRx,
		rx_busy       => RX_BUSY,
		rx_error      => OPEN,
		rx_data       => DATA_OUT,
		tx_busy       => TX_BUSY,
		tx            => Tx
		);
		
decipher: decipher_module
    GENERIC MAP(
        L             => lr,
        Y             => lk
        )   
    PORT MAP(
        CLK           => CLK,
        RST           => RST,
        LOAD          => LD,
        CK            => CK,
        A             => A,
        N             => N,
        T             => T,
        K             => K,
        F             => F
        ); 
  
  Controller: PROCESS (rx_state, tx_state, tiuring_state, RX_BUSY, RX_BUF, TX_BUSY, TX_BUF, LD, F, K)
  VARIABLE index            : natural RANGE 0 TO lr := 0;
  VARIABLE blink            : natural RANGE 0 TO 50_000_000-1 := 0;
  VARIABLE led_state        : std_logic := '1';
  BEGIN
  CASE rx_state IS
    WHEN 0 =>
      IF RX_BUSY = '1' THEN
          rx_stNext <= 1;
      END IF;
    WHEN 1 =>
      IF RX_BUSY = '0' THEN
        IF index < lr THEN
          index := index + d_width;
          rx_stNext <= 0;
        END IF;
      END IF;
  END CASE;
    
  CASE tx_state IS
    WHEN 0 =>
      IF TX_BUSY = '1' THEN
        led(7) <= '1';
        tx_stNext <= 1;
      END IF;
    WHEN 1 =>
      IF TX_BUSY = '0' THEN
          IF index > 0 THEN
            index := index - d_width;
            tx_stNext <= 0;
          END IF;
        END IF;
    END CASE;
    
    CASE tiuring_state IS
      WHEN r_CK =>
        led <= (OTHERS => '0');
        IF index >= lr THEN
          CK <= Rx_BUF(index-1 DOWNTO index-lr);
          index := 0;
          led(0) <= '1';
          tiuring_stNext <= r_A;
        END IF;
      WHEN r_A =>
        IF index >= lr THEN
          A <= Rx_BUF(index-1 DOWNTO index-lr);
          index := 0;
          LED(1) <= '1';
          tiuring_stNext <= r_N;
        END IF;
      WHEN r_N =>
        IF index >= lr THEN
          N <= Rx_BUF(index-1 DOWNTO index-lr);
          index := 0;
          led(2) <= '1';
          tiuring_stNext <= r_T;
        END IF;
      WHEN r_T =>
        IF index >= lr THEN
          T <= Rx_BUF(index-1 DOWNTO index-lr);
          index := 0;
          led(3) <= '1';
          tiuring_stNext <= ld_data;
        END IF;
      WHEN ld_data =>
        IF LD = '0' THEN
          LD <= '1';
          led(4) <= '1';
        ELSIF LD = '1' THEN
          LD <= '0';
          led(5) <= '1';
          tiuring_stNext <= wait_F;
        END IF;
      WHEN wait_F => 
          blink := blink + 1;
          IF blink <= 50_000_000 THEN
            blink := 0;
            IF led_state = '1' THEN
              led(5) <= '0';
              led_state := '0';
            ELSE
              led(5) <= '1';
              led_state := '1';
            END IF;
          END IF;
          IF F = '1' THEN
            Tx_BUF <= Tx_BUF(lk-1 DOWNTO 0) & K (lk-1 DOWNTO 0);
            index := lk;
            led(6) <= '1';
            tiuring_stNext <= t_K;
          END IF;
      WHEN t_K =>
        IF index = 0 THEN
          tiuring_stNext <= r_CK;
        END IF;
    END CASE;
    DATA_INDEX <= index;
  END PROCESS;
  
  
  Reciever: PROCESS (RX_BUSY, tiuring_state, Rx_BUF, DATA_OUT)
  VARIABLE step         : natural RANGE 0 TO 1 := 0;
  BEGIN
  CASE step IS
    WHEN 0 =>
      IF (tiuring_state = r_CK OR 
         tiuring_state = r_A OR
         tiuring_state = r_N OR
         tiuring_state = r_T) AND 
         RX_BUSY = '1' THEN
        step := step + 1;
      END IF;
    WHEN 1 =>
      IF RX_BUSY = '0' THEN
        Rx_BUF <= Rx_BUF (lr*2-1-d_width DOWNTO 0) & DATA_OUT;
        step := 0;
      END IF;
  END CASE;
  END PROCESS;
  
  Transmitter: PROCESS (TX_BUSY, tiuring_state, Tx_BUF, DATA_INDEX)
  VARIABLE step         : natural RANGE 0 TO 3 := 0;
  BEGIN
  CASE step IS
    WHEN 0 =>
      IF tiuring_state = t_K AND TX_BUSY = '0' AND DATA_INDEX > 0 THEN
        DATA_IN <= Tx_BUF (DATA_INDEX-1 DOWNTO DATA_INDEX-d_width);
        DATA_SEND <= '1';
        step := step + 1;
      END IF;
    WHEN 1 =>
      DATA_SEND <= '0';
      step := step + 1;
    WHEN 2 =>
      IF TX_BUSY = '1' THEN
        step := step + 1;
      END IF;
    WHEN 3 =>
      IF TX_BUSY = '0' THEN
        step := 0;
      END IF;
  END CASE;
  END PROCESS;
  
  registerC: PROCESS(RST, CLK)
  BEGIN
    IF RST = '0' THEN
      tiuring_state <= r_CK;
      rx_state <= 0;
      tx_state <= 0;
    ELSIF rising_edge(CLK) THEN
      tiuring_state <= tiuring_stNext;
      rx_state <= rx_stNext;
      tx_state <= tx_stNext;
    END IF;
  END PROCESS;
  
  PROCESS
  BEGIN
  WAIT UNTIL rising_edge(CLK);
  IF RST = '0' THEN
      RST <= '1';
  END IF;
  END PROCESS;

END Behavioral;