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
    GENERIC (
        lb              : natural:= 64;
        lr              : natural:= 32;
        lk              : natural:= 8;
        d_width         : natural:= 8;
        clk_freq        : integer:= 100_000_000);
    PORT (
        CLK             : IN std_logic;
        ledRST          : OUT std_logic := '1';
        sw              : IN std_logic;
        RsRx            : IN std_logic;
        Tx              : OUT std_logic);
END top;

ARCHITECTURE Behavioral OF top IS
TYPE cipher_machine     IS (r_CK, t_CK, r_A, t_A, r_N, t_N, r_T, t_T, l_DATA, l_DATA1, w_K, t_K);
-- SIGNAL Declerations
SIGNAL tiuring_state    : cipher_machine                            := r_CK             ;
SIGNAL tx_state         : natural           RANGE 0 TO 2            := 0                ;
SIGNAL rx_state         : natural           RANGE 0 TO 1            := 0                ;
SIGNAL RST              : std_logic                                 := '1'              ;
SIGNAL LOAD             : std_logic                                 := '0'              ;
SIGNAL F                : std_logic                                 := '0'              ;

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
SIGNAL A                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL N                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL T                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL K                : std_logic_vector  (lk-1 DOWNTO 0)         := (OTHERS => '0')  ;

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

COMPONENT decrypt_module IS
  GENERIC (
      L             : natural:= lr;
      Y             : natural:= lk);   
  PORT (
      CLK           : IN std_logic;
      RST           : IN std_logic;
      LOAD          : IN std_logic;
      CK            : IN std_logic_vector(L-1 DOWNTO 0);
      A             : IN std_logic_vector(L-1 DOWNTO 0);
      N             : IN std_logic_vector(L-1 DOWNTO 0);
      T             : IN std_logic_vector(L-1 DOWNTO 0);
      K             : OUT std_logic_vector(Y-1 DOWNTO 0);
      F             : OUT std_logic);
END COMPONENT decrypt_module;
  
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

decrypter: decrypt_module
    GENERIC MAP(
        L             => lr,
        Y             => lk
        )   
    PORT MAP(
        CLK           => CLK,
        RST           => RST,
        LOAD          => LOAD,
        CK            => CK,
        A             => A,
        N             => N,
        T             => T,
        K             => K,
        F             => F
        );
      
  Controller: PROCESS (RST, CLK)
  VARIABLE r_index      : NATURAL RANGE 0 to lb;
  VARIABLE t_index      : NATURAL RANGE 0 to lb;
  BEGIN
    IF RST = '0' THEN
      Tx_BUF <= (OTHERS => '0');
      tiuring_state <= r_CK;
    ELSIF rising_edge(CLK) THEN
      r_index := 0;
      t_index := 0;
      CASE tiuring_state IS
        WHEN r_CK =>
          IF Rx_INDEX >= lr THEN
            CK <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              r_index := lr;
            END IF;
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            tiuring_state <= t_CK;
          END IF;
        WHEN t_CK =>
          IF Tx_INDEX < lb THEN
            t_index := lr;
          END IF;
          tiuring_state <= r_A;
        WHEN r_A =>
          IF Rx_INDEX >= lr THEN
            A <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              r_index := lr;
            END IF;
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            tiuring_state <= t_A;
          END IF;
        WHEN t_A =>
            IF Tx_INDEX < lb THEN
              t_index := lr;
            END IF;
            tiuring_state <= r_N;          
        WHEN r_N =>
          IF Rx_INDEX >= lr THEN
            N <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              r_index := lr;
            END IF;
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            tiuring_state <= t_N;
          END IF;
        WHEN t_N =>
            IF Tx_INDEX < lb THEN
              t_index := lr;
            END IF;
            tiuring_state <= r_T;          
        WHEN r_T =>
          IF Rx_INDEX >= lr THEN
            T <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              r_index := lr;
            END IF;
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            tiuring_state <= t_T;
          END IF;
        WHEN t_T =>
            IF Tx_INDEX < lb THEN
              t_index := lr;
            END IF;
            tiuring_state <= l_DATA;          
        WHEN l_DATA =>
            LOAD <= '1';
            tiuring_state <= l_DATA1;
        WHEN l_DATA1 =>
          LOAD <= '0';
          tiuring_state <= w_K;
        WHEN w_K =>
          IF F = '1' THEN
            Tx_BUF <= K & Tx_BUF (lb-1 DOWNTO lk);
            tiuring_state <= t_K;
          END IF;
        WHEN t_K =>
          IF Tx_INDEX < lb THEN
            t_index := lk;
          END IF;
          tiuring_state <= r_CK;
      END CASE;
    END IF;
    Rx_IndexSub <= r_index;
    Tx_IndexAdd <= t_index;
  END PROCESS;
      
      
      Reciever: PROCESS (Rx_BUSY, RST, CLK)
      VARIABLE index    : NATURAL RANGE 0 TO lb;
      BEGIN
      IF RST = '0' THEN
        Rx_BUF <= (OTHERS => '0');
      ELSIF rising_edge(CLK) THEN
        index := 0;
        CASE rx_state IS
          WHEN 0 =>
            IF Rx_BUSY = '1' THEN
              rx_state <= 1;
            END IF;
          WHEN 1 =>
            IF Rx_BUSY = '0' THEN
              Rx_BUF <= DATA_OUT & Rx_BUF (lb-1 DOWNTO d_width);
              IF Rx_INDEX < lb THEN
                index := d_width;
              END IF;
              rx_state <= 0;
            END IF;
        END CASE;
      END IF;
      Rx_IndexAdd <= index;
      END PROCESS;
      
      Transmitter: PROCESS (RST, CLK)
      VARIABLE index      : NATURAL RANGE 0 to lb-1;
      BEGIN
      IF RST = '0' THEN
        tx_state <= 0;
      ELSIF rising_edge(CLK) THEN
        index := 0;
        CASE tx_state IS
          WHEN 0 =>
            IF Tx_BUSY = '0' AND Tx_INDEX > 0 THEN
              DATA_SEND <= '1';
              DATA_IN <= Tx_BUF (lb-Tx_INDEX+d_width-1 DOWNTO lb-Tx_INDEX);
              tx_state <= 1;
            END IF;
          WHEN 1 =>
            DATA_SEND <= '0';
            IF Tx_INDEX > 0 THEN
              index := d_width;
            END IF;
            tx_state <= 2;
          WHEN 2 =>
            IF Tx_BUSY = '1' THEN
              tx_state <= 0;
            END IF;
        END CASE;
      END IF;
      Tx_IndexSub <= index;
      END PROCESS;
      
 registerC: PROCESS(RST, CLK)
 BEGIN
   IF RST = '0' THEN
     Rx_INDEX <= 0;
     Tx_INDEX <= 0;
   ELSIF falling_edge(CLK) THEN
     IF 0 < Rx_IndexSub THEN
       IF 0 < Rx_IndexAdd THEN
         Rx_INDEX <= RX_INDEX + Rx_IndexAdd - Rx_IndexSub;
       ELSE
         Rx_INDEX <= Rx_INDEX - Rx_IndexSub;
       END IF;
     ELSE
       Rx_INDEX <= Rx_INDEX + Rx_IndexAdd;
     END IF;
          
     IF 0 < Tx_IndexSub THEN
       IF 0 < Tx_IndexAdd THEN
         Tx_INDEX <= Tx_INDEX + Tx_IndexAdd - Tx_IndexSub;
       ELSE
         Tx_INDEX <= Tx_INDEX - Tx_IndexSub;
       END IF;
     ELSE
       Tx_INDEX <= Tx_INDEX + Tx_IndexAdd;
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
