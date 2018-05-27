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
        ledRST      : OUT std_logic := '1';
        sw          : IN std_logic;
        RsRx        : IN std_logic;
        Tx          : OUT std_logic);
END top;

ARCHITECTURE Behavioral OF top IS
TYPE cipher_machine     IS (r_CK, p_CK, t_CK);
-- SIGNAL Declerations
SIGNAL tiuring_state    : cipher_machine                            := r_CK             ;
SIGNAL tx_state         : natural           RANGE 0 TO 4            := 0                ;
SIGNAL rx_state         : natural           RANGE 0 TO 1            := 0                ;
SIGNAL RST              : std_logic                                 := '1'              ;

SIGNAL DATA_SEND        : std_logic                                 := '0'              ;
SIGNAL Tx_BUSY          : std_logic                                                     ;
SIGNAL DATA_IN          : std_logic_vector  (d_width-1 DOWNTO 0)    := (OTHERS => '0')  ;
SIGNAL Tx_BUF           : std_logic_vector  (lb-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL Tx_INDEX         : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_IndexSub      : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_IndexAdd      : natural           RANGE 0 TO lb           := 0                ;

SIGNAL Rx_ERROR         : std_logic                                                     ;
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
        rx_error      => Rx_ERROR,
        rx_data       => DATA_OUT,
        Tx_BUSY       => Tx_BUSY,
        tx            => Tx
        );
      
  Controller: PROCESS (RST, CLK)
    BEGIN
    Rx_IndexSub <= Rx_INDEX;
    Tx_IndexAdd <= Tx_INDEX;
    IF RST = '0' THEN
      tiuring_state <= r_CK;
    ELSIF rising_edge(CLK) THEN
      CASE tiuring_state IS
        WHEN r_CK =>
          IF Rx_INDEX >= lr THEN
            CK <= Rx_BUF(Rx_INDEX-1 DOWNTO 0);
            Rx_IndexSub <= Rx_INDEX - lr;
            tiuring_state <= p_CK;
          END IF;
        WHEN p_CK =>
          Tx_BUF <= CK;
          tiuring_state <= t_CK;
        WHEN t_CK =>
          Tx_IndexAdd <= Tx_INDEX + lr;
          tiuring_state <= r_CK;
      END CASE;
    END IF;
    END PROCESS;
      
      
      Reciever: PROCESS (RST, CLK)
      BEGIN
      Rx_IndexAdd <= Rx_INDEX;
      
      IF RST = '0' THEN
        Rx_BUF <= (OTHERS => '0');
      ELSIF rising_edge(CLK) THEN
        CASE rx_state IS
          WHEN 0 =>
            IF Rx_BUSY = '1' THEN
              rx_state <= 1;
            END IF;
          WHEN 1 =>
            IF Rx_BUSY = '0' THEN
              IF Rx_ERROR = '0' THEN
                Rx_BUF <= Rx_BUF (lb-1-d_width DOWNTO 0) & DATA_OUT;
                IF Rx_INDEX < lb THEN
                  Rx_IndexAdd <= Rx_INDEX + d_width;
                END IF;
              END IF;
              rx_state <= 0;
            END IF;
        END CASE;
      END IF;
      END PROCESS;
      
      Transmitter: PROCESS (RST, CLK)
      BEGIN
      Tx_IndexSub <= Tx_INDEX;
      
      IF RST = '0' THEN
        tx_state <= 0;
      ELSIF rising_edge(CLK) THEN
        CASE tx_state IS
          WHEN 0 =>
            IF Tx_BUSY = '0' AND Tx_INDEX > 0 THEN
              DATA_SEND <= '1';
              tx_state <= 1;
            END IF;
          WHEN 1 =>
            DATA_IN <= Tx_BUF (Tx_INDEX-1 DOWNTO Tx_INDEX-d_width);
            tx_state <= 2;
          WHEN 2 =>
            DATA_SEND <= '0';
            tx_state <= 3;
          WHEN 3 =>
            IF Tx_BUSY = '1' THEN
              tx_state <= 4;
            END IF;
          WHEN 4 =>
            IF Tx_BUSY = '0' THEN
              IF Tx_INDEX > 0 THEN
                Tx_IndexSub <= Tx_INDEX - d_width;
              END IF;
              tx_state <= 0;
            END IF;
        END CASE;
      END IF;
      END PROCESS;
      
 registerC: PROCESS(RST, CLK)
 BEGIN
   IF RST = '0' THEN
     Rx_INDEX <= 0;
     Tx_INDEX <= 0;
   ELSIF rising_edge(CLK) THEN
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
   END IF;
   END PROCESS;

  resete: PROCESS (sw)
  VARIABLE reset_PrevState      : std_logic     := '1'; 
  BEGIN
  IF reset_PrevState /= sw THEN
    reset_PrevState := sw;
    ledRST <= sw;
    RST <= reset_PrevState;
  END IF;
  END PROCESS;

END Behavioral;
