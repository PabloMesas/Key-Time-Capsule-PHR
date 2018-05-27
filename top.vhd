----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top IS
    GENERIC (lb: natural:= 32; lr: natural:= 32; lk: natural:= 8; d_width: natural:= 8; clk_freq: integer:= 100_000_000);
    PORT (
        CLK         : IN std_logic;
        led         : OUT std_logic_vector(6 DOWNTO 0);
        ledV         : OUT std_logic_vector(2 DOWNTO 0);
        ledRST      : OUT std_logic;
        sw          : IN std_logic;
        RsRx        : IN std_logic;
        Tx          : OUT std_logic);
END top;

ARCHITECTURE Behavioral OF top IS
TYPE cipher_machine     IS (r_CK, p_CK, t_CK, t_K);
-- SIGNAL Declerations
SIGNAL tiuring_state    : cipher_machine                            := r_CK             ;
SIGNAL tiuring_stNext   : cipher_machine                            := r_CK             ;
SIGNAL tx_state         : natural           RANGE 0 TO 4            := 0                ;
SIGNAL tx_stNext        : natural           RANGE 0 TO 4            := 0                ;
SIGNAL RST              : std_logic                                 := '1'              ;

SIGNAL led_stNext       : std_logic_vector  (6 DOWNTO 0)            := (OTHERS => '0')  ;

SIGNAL DATA_SEND        : std_logic                                 := '0'              ;
SIGNAL Tx_BUSY          : std_logic                                                     ;
SIGNAL DATA_IN          : std_logic_vector  (d_width-1 DOWNTO 0)    := (OTHERS => '0')  ;
SIGNAL Tx_BUF           : std_logic_vector  (lb-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL Tx_INDEX         : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_IndexSub      : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_IndexAdd      : natural           RANGE 0 TO lb           := 0                ;

SIGNAL Rx_BUSY          : std_logic                                                     ;
SIGNAL DATA_OUT         : std_logic_vector  (d_width-1 DOWNTO 0)                        ;
SIGNAL Rx_BUF           : std_logic_vector  (lb-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL Rx_INDEX         : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Rx_IndexSub      : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Rx_IndexAdd      : natural           RANGE 0 TO lb           := 0                ;

SIGNAL CK               : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;

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
      Rx_BUSY       : OUT std_logic;                            --data reception in progress
      rx_error      : OUT std_logic;                            --start, parity, or stop bit error detected
      rx_data       : OUT std_logic_vector(d_width-1 DOWNTO 0); --data received
      Tx_BUSY       : OUT std_logic;                            --transmission in progress
      tx            : OUT std_logic);                           --transmit pin
END COMPONENT UART;
  
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
        Rx_BUSY       => Rx_BUSY,
        rx_error      => OPEN,
        rx_data       => DATA_OUT,
        Tx_BUSY       => Tx_BUSY,
        tx            => Tx
        );
      
  Controller: PROCESS (tiuring_state, Rx_INDEX, Tx_INDEX)
    VARIABLE led_state        : std_logic_vector (6 DOWNTO 0) := (OTHERS => '0');
    VARIABLE ledV_state       : std_logic_vector (2 DOWNTO 0) := (OTHERS => '0');
    BEGIN

    CASE tiuring_state IS
      WHEN r_CK =>
        led_state := (OTHERS => '0');
        IF Rx_INDEX >= lr THEN
          CK <= Rx_BUF(Rx_INDEX-1 DOWNTO 0);
          Rx_IndexSub <= Rx_INDEX - lr;
          led_state(0) := '1';
          tiuring_stNext <= p_CK;
        END IF;
      WHEN p_CK =>
        Tx_BUF <= CK;
        tiuring_stNext <= t_CK;
      WHEN t_CK =>
        Tx_IndexAdd <= lr;
        tiuring_stNext <= t_K;
      WHEN t_K =>
        IF Tx_INDEX = 0 THEN
          Tx_BUF <= Tx_BUF(lb-lk-1 DOWNTO 0) & "01110011";
          Tx_IndexAdd <= lk;
          tiuring_stNext <= r_CK;
        END IF;
    END CASE;
      ledV <= ledV_state;
      led_stNext <= led_state;
    END PROCESS;
      
      
      Reciever: PROCESS (Rx_BUSY, DATA_OUT)
      BEGIN
      IF falling_edge(Rx_BUSY) THEN
        Rx_BUF <= Rx_BUF (lb-1-d_width DOWNTO 0) & DATA_OUT;
        IF Rx_INDEX < lb THEN
          Rx_IndexAdd <= Rx_INDEX + d_width;
        END IF;
      END IF;
      END PROCESS;
      
      Transmitter: PROCESS (tx_state, Tx_BUSY, Tx_INDEX)
      BEGIN

      CASE tx_state IS
        WHEN 0 =>
          IF Tx_BUSY = '0' AND Tx_INDEX > 0 THEN
            DATA_IN <= Tx_BUF (Tx_INDEX-1 DOWNTO Tx_INDEX-d_width);
            tx_stNext <= 1;
          END IF;
        WHEN 1 =>
          DATA_SEND <= '1';
          tx_stNext <= 2;
        WHEN 2 =>
          DATA_SEND <= '0';
          tx_stNext <= 3;
        WHEN 3 =>
          IF Tx_BUSY = '1' THEN
            tx_stNext <= 4;
          END IF;
        WHEN 4 =>
          IF Tx_BUSY = '0' THEN
            IF Tx_INDEX > 0 THEN
              Tx_IndexSub <= Tx_INDEX - d_width;
            END IF;
            tx_stNext <= 0;
          END IF;
      END CASE;
      END PROCESS;
      
 registerC: PROCESS(RST, CLK)
 BEGIN
   IF RST = '0' THEN
     tiuring_state <= r_CK;
     tx_state <= 0;
   ELSIF rising_edge(CLK) THEN
     led <= led_stNext;
      
     IF Rx_INDEX > Rx_IndexSub THEN
       IF Rx_INDEX < Rx_IndexAdd THEN
         Rx_INDEX <= Rx_IndexAdd + Rx_IndexSub - RX_INDEX;
       ELSE
         Rx_INDEX <= Rx_IndexSub;
       END IF;
     ELSE
       Rx_INDEX <= Rx_IndexAdd;
     END IF;
          
     IF Tx_INDEX > Tx_IndexSub THEN
       IF Tx_INDEX < Tx_IndexAdd THEN
         Tx_INDEX <= Tx_IndexAdd + Tx_IndexSub - Tx_INDEX;
       ELSE
         Tx_INDEX <= Tx_IndexSub;
       END IF;
     ELSE
       Tx_INDEX <= Tx_IndexAdd;
     END IF;
          
     tiuring_state <= tiuring_stNext;
     tx_state <= tx_stNext;
   END IF;
   END PROCESS;

  resete: PROCESS (sw)
  VARIABLE reset_PrevState      : std_logic     := '0'; 
  BEGIN
  IF reset_PrevState /= sw THEN
    reset_PrevState := sw;
    ledRST <= sw;
  END IF;
  RST <= reset_PrevState;
  END PROCESS;

END Behavioral;
