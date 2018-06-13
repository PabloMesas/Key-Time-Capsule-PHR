----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: top - Behavioral
-- Project Name: Key-Time-Capsule
-- Description: 
-- 
-- Dependencies: uart.vhd, decrypt_module.vhd
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY top IS
    GENERIC (
        lb              : natural:= 64;             -- Data buffer: bit size
        lr              : natural:= 32;             -- CK, A, N, T bit width
        lk              : natural:= 8;              -- K bits width
        d_width         : natural:= 8;              -- UART: data bus width
        clk_freq        : integer:= 100_000_000);   -- Clock freq (Hz)
    PORT (
        CLK             : IN std_logic;
        ledRST          : OUT std_logic := '1';
        sw              : IN std_logic;
        RsRx            : IN std_logic;
        Tx              : OUT std_logic);
END top;

ARCHITECTURE Behavioral OF top IS
TYPE cipher_machine     IS (r_CK, t_CK,
                            r_A, t_A,
                            r_N, t_N,
                            r_T, t_T, 
                            l_DATA, l_DATA1,
                            w_K, t_K);
-- SIGNAL Declarations
SIGNAL PROG_STATE       : cipher_machine                            := r_CK             ;
SIGNAL Tx_STATE         : natural           RANGE 0 TO 2            := 0                ;
SIGNAL Rx_STATE         : natural           RANGE 0 TO 1            := 0                ;
SIGNAL RST              : std_logic                                 := '1'              ;
SIGNAL LOAD             : std_logic                                 := '0'              ;
SIGNAL F                : std_logic                                 := '0'              ;

SIGNAL Tx_SEND          : std_logic                                 := '0'              ;
SIGNAL Tx_BUSY          : std_logic                                                     ;
SIGNAL Tx_DATA          : std_logic_vector  (d_width-1 DOWNTO 0)    := (OTHERS => '0')  ;
SIGNAL Tx_BUF           : std_logic_vector  (lb-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL Tx_INDEX         : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_INDEXSub      : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Tx_INDEXAdd      : natural           RANGE 0 TO lb           := 0                ;

SIGNAL Rx_ERROR         : std_logic                                                     ;
SIGNAL Rx_BUSY          : std_logic                                                     ;
SIGNAL Rx_DATA          : std_logic_vector  (d_width-1 DOWNTO 0)                        ;
SIGNAL Rx_BUF           : std_logic_vector  (lb-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL Rx_INDEX         : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Rx_INDEXSub      : natural           RANGE 0 TO lb           := 0                ;
SIGNAL Rx_INDEXAdd      : natural           RANGE 0 TO lb           := 0                ;

SIGNAL CK               : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL A                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL N                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL T                : std_logic_vector  (lr-1 DOWNTO 0)         := (OTHERS => '0')  ;
SIGNAL K                : std_logic_vector  (lk-1 DOWNTO 0)         := (OTHERS => '0')  ;

-- UART: Transmitter
COMPONENT UART IS
  GENERIC(
      clk_freq      : integer       := clk_freq;    
      baud_rate     : integer       := 9600;        
      os_rate       : integer       := 16;          
      d_width       : integer       := d_width;     
      parity        : integer       := 0;           
      parity_eo     : std_logic     := '0');        
  PORT(
      clk           : IN std_logic;
      reset_n       : IN std_logic;
      tx_ena        : IN std_logic;
      tx_data       : IN std_logic_vector(d_width-1 DOWNTO 0);
      rx            : IN std_logic;
      Rx_BUSY       : OUT std_logic;
      rx_error      : OUT std_logic;
      rx_data       : OUT std_logic_vector(d_width-1 DOWNTO 0);
      Tx_BUSY       : OUT std_logic;
      tx            : OUT std_logic);
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
  -- Instantiation:
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
      tx_ena        => Tx_SEND,
      tx_data       => Tx_DATA,
      rx            => RsRx,
      Rx_BUSY       => Rx_BUSY,
      rx_error      => Rx_ERROR,
      rx_data       => Rx_DATA,
      Tx_BUSY       => Tx_BUSY,
      tx            => Tx
      );

  -- Instantiation:
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
      
  -- Main program
  Controller: PROCESS (RST, CLK)
  VARIABLE temp_rx_index      : NATURAL RANGE 0 to lb;
  VARIABLE temp_tx_index      : NATURAL RANGE 0 to lb;
  BEGIN
    IF RST = '0' THEN  -- Asynchronous Reset
      Tx_BUF <= (OTHERS => '0');
      PROG_STATE <= r_CK;
    ELSIF rising_edge(CLK) THEN
      temp_rx_index := 0;
      temp_tx_index := 0;
      CASE PROG_STATE IS
        WHEN r_CK =>    -- Wait for read CK
          IF Rx_INDEX >= lr THEN        -- If index of Rx buffer has a 32 bit data
            CK <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              temp_rx_index := lr;      -- Decrement Rx buffer index
            END IF;
            -- Load read data into Tx buffer
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            PROG_STATE <= t_CK;
          END IF;
        WHEN t_CK =>    -- Transfer CK to ACK
          IF Tx_INDEX < lb THEN
            temp_tx_index := lr;        -- Increment Tx buffer index to send that amount of data
          END IF;
          PROG_STATE <= r_A;
        WHEN r_A =>     -- Wait for read A
          IF Rx_INDEX >= lr THEN        -- If index of Rx buffer has a 32 bit data
            A <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              temp_rx_index := lr;      -- Decrement Rx buffer index buffer
            END IF;
            -- Load read data into Tx buffer
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            PROG_STATE <= t_A;
          END IF;
        WHEN t_A =>     -- Transfer A to ACK
          IF Tx_INDEX < lb THEN
            temp_tx_index := lr;        -- Increment Tx buffer index to send that amount of data
          END IF;
          PROG_STATE <= r_N;          
        WHEN r_N =>     -- Wait for read N
          IF Rx_INDEX >= lr THEN        -- If index of Rx buffer has a 32 bit data
            N <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              temp_rx_index := lr;      -- Decrement Rx buffer index
            END IF;
            -- Load read data into Tx buffer
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            PROG_STATE <= t_N;
          END IF;
        WHEN t_N =>     -- Transfer N to ACK
          IF Tx_INDEX < lb THEN
            temp_tx_index := lr;        -- Increment Tx buffer index to send that amount of data
          END IF;
          PROG_STATE <= r_T;          
        WHEN r_T =>     -- Wait for read T
          IF Rx_INDEX >= lr THEN        -- If index of Rx buffer has a 32 bit data
            T <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX);
            IF Rx_INDEX >= lr THEN
              temp_rx_index := lr;      -- Decrement Rx buffer index
            END IF;
            -- Load read data into Tx buffer
            Tx_BUF <= Rx_BUF(lb-Rx_INDEX+lr-1 DOWNTO lb-Rx_INDEX) & Tx_BUF (lb-1 DOWNTO lr);
            PROG_STATE <= t_T;
          END IF;
        WHEN t_T =>     -- Transfer T to ACK
          IF Tx_INDEX < lb THEN
            temp_tx_index := lr;        -- Increment Tx buffer index to send that amount of data
          END IF;
          PROG_STATE <= l_DATA;          
        WHEN l_DATA =>  -- Load data into decrypt module
            LOAD <= '1';
            PROG_STATE <= l_DATA1;
        WHEN l_DATA1 => -- Initialize process to obtain K
          LOAD <= '0';
          PROG_STATE <= w_K;
        WHEN w_K =>     -- Wait decrypt to finish process
          IF F = '1' THEN
            -- Load K into Tx buffer
            Tx_BUF <= K & Tx_BUF (lb-1 DOWNTO lk);
            PROG_STATE <= t_K;
          END IF;
        WHEN t_K =>     -- Transfer K
          IF Tx_INDEX < lb THEN
            temp_tx_index := lk;        -- Increment Tx buffer index to send that amount of data
          END IF;
          PROG_STATE <= r_CK;           -- Return to initial state
      END CASE;
      Rx_INDEXSub <= temp_rx_index;
      Tx_INDEXAdd <= temp_tx_index;
    END IF;
  END PROCESS;
      
  -- Reciever program
  Reciever: PROCESS (Rx_BUSY, RST, CLK)
  VARIABLE temp_index    : NATURAL RANGE 0 TO lb;
  BEGIN
    IF RST = '0' THEN  -- Asynchronous Reset
      Rx_BUF <= (OTHERS => '0');
    ELSIF rising_edge(CLK) THEN
      temp_index := 0;
      CASE Rx_STATE IS
        WHEN 0 =>   -- Wait for next data
          IF Rx_BUSY = '1' THEN     -- UART: recieving data
            Rx_STATE <= 1;
          END IF;
        WHEN 1 =>   -- Wait for end of recieving
          IF Rx_BUSY = '0' THEN     -- If recieving finished then load data into buffer
            Rx_BUF <= Rx_DATA & Rx_BUF (lb-1 DOWNTO d_width);
            IF Rx_INDEX < lb THEN
              temp_index := d_width;    -- Increment Rx buffer index
            END IF;
            Rx_STATE <= 0;              -- Return to initial state
          END IF;
      END CASE;
      Rx_INDEXAdd <= temp_index;
    END IF;
  END PROCESS;
      
  -- Transmitter program
  Transmitter: PROCESS (RST, CLK)
  VARIABLE temp_index      : NATURAL RANGE 0 to lb-1;
  BEGIN
    IF RST = '0' THEN  -- Asynchronous Reset
      Tx_STATE <= 0;
    ELSIF rising_edge(CLK) THEN
      temp_index := 0;
      CASE Tx_STATE IS
        WHEN 0 =>   -- If transmitter is not busy AND something is required to send
          IF Tx_BUSY = '0' AND Tx_INDEX > 0 THEN
            Tx_SEND <= '1';             -- Load data into transmitter
            Tx_DATA <= Tx_BUF (lb-Tx_INDEX+d_width-1 DOWNTO lb-Tx_INDEX);
            Tx_STATE <= 1;
          END IF;
        WHEN 1 =>   -- Send data and update Tx buffer temp_index
          Tx_SEND <= '0';               -- Send data
          IF Tx_INDEX > 0 THEN
            temp_index := d_width;      -- Decrement Tx buffer index
          END IF;
          Tx_STATE <= 2;
        WHEN 2 =>   -- Wait for end of transmission
          IF Tx_BUSY = '1' THEN
            Tx_STATE <= 0;              -- Return to initial state
          END IF;
      END CASE;
      Tx_INDEXSub <= temp_index;
    END IF;
  END PROCESS;
      
 -- Register to concurrent manage Rx_INDEX and TX_INDEX
 registerC: PROCESS(RST, CLK)
 BEGIN
   IF RST = '0' THEN  -- Asynchronous Reset
     Rx_INDEX <= 0;
     Tx_INDEX <= 0;
   ELSIF falling_edge(CLK) THEN
     -- Rx_INDEX:
     IF 0 < Rx_INDEXSub THEN        -- If need to decrement
       IF 0 < Rx_INDEXAdd THEN      -- If need to increment
         Rx_INDEX <= Rx_INDEX + Rx_INDEXAdd - Rx_INDEXSub;
       ELSE                         -- Only decrement
         Rx_INDEX <= Rx_INDEX - Rx_INDEXSub;
       END IF;
     ELSE                           -- Only increment
       Rx_INDEX <= Rx_INDEX + Rx_INDEXAdd;
     END IF;
          
     -- Tx_INDEX:
     IF 0 < Tx_INDEXSub THEN        -- If need to decrement
       IF 0 < Tx_INDEXAdd THEN      -- If need to increment
         Tx_INDEX <= Tx_INDEX + Tx_INDEXAdd - Tx_INDEXSub;
       ELSE                         -- Only decrement
         Tx_INDEX <= Tx_INDEX - Tx_INDEXSub;
       END IF;
     ELSE                           -- Only increment
       Tx_INDEX <= Tx_INDEX + Tx_INDEXAdd;
     END IF;
   END IF;
 END PROCESS;

  -- Reset program
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
