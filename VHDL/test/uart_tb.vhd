--------------------------------------------------------------------------------
-- PROJECT: SIMPLE UART FOR FPGA
--------------------------------------------------------------------------------
-- MODULE:  TESTBANCH OF UART TOP MODULE
-- AUTHORS: Jakub Cabal <jakubcabal@gmail.com>
-- LICENSE: The MIT License (MIT), please read LICENSE file
-- WEBSITE: https://github.com/jakubcabal/uart_for_fpga
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tb is
end uart_tb;

architecture FULL of uart_tb is

	signal CLK           : std_logic := '0';
	signal RST           : std_logic := '1';
	signal tx            : std_logic;
	signal rx_uart       : std_logic := '1';
	signal rx_busy       : std_logic;
	signal data_out      : std_logic_vector(7 downto 0);
	signal frame_error   : std_logic;
	signal data_send     : std_logic;
	signal tx_busy          : std_logic;
	signal data_in       : std_logic_vector(7 downto 0);

    constant clk_period  : time := 10 ns;
	constant uart_period : time := 104.167 us;
	constant data_value  : std_logic_vector(7 downto 0) := "10100111";
	constant data_value2 : std_logic_vector(7 downto 0) := "00110110";
	
	COMPONENT UART IS
          GENERIC(
              clk_freq         :    INTEGER        := 100_000_000;    --frequency of system clock in Hertz
              baud_rate         :   INTEGER        := 9600;        --data link baud rate in bits/second
              os_rate             : INTEGER        := 16;            --oversampling rate to find center of receive bits (in samples per baud period)
              d_width             : INTEGER        := 8;             --data bus width
              parity             :  INTEGER        := 0;            --0 for no parity, 1 for parity
              parity_eo         :   STD_LOGIC    := '0');        --'0' for even, '1' for odd parity
          PORT(
              clk        :    IN        STD_LOGIC;                                        --system clock
              reset_n    :    IN        STD_LOGIC;                                       --ascynchronous reset
              tx_ena        :    IN        STD_LOGIC;                                       --initiate transmission
              tx_data       :    IN        STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);  --data to transmit
              rx            :    IN        STD_LOGIC;                                        --receive pin
              rx_busy    :    OUT    STD_LOGIC;                                        --data reception in progress
              rx_error    :    OUT    STD_LOGIC;                                        --start, parity, or stop bit error detected
              rx_data    :    OUT    STD_LOGIC_VECTOR(d_width-1 DOWNTO 0);    --data received
              tx_busy    :    OUT    STD_LOGIC;                                      --transmission in progress
              tx            :    OUT    STD_LOGIC);                                        --transmit pin
      END COMPONENT UART;

begin

	utt: UART
    GENERIC MAP(
            clk_freq      => 100_000_000,
            baud_rate     => 9600,
            os_rate       => 16,
            d_width       => 8,
            parity        => 0,
            parity_eo     => '0'
            )
        PORT MAP(
            clk           => CLK,
            reset_n       => RST,
            tx_ena        => DATA_SEND,
            tx_data       => DATA_IN,
            rx            => rx_uart,
            rx_busy       => rx_busy,
            rx_error      => OPEN,
            rx_data       => DATA_OUT,
            tx_busy       => tx_busy,
            tx            => tx
            );

	clk_process : process
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;

	test_rx_uart : process
	begin
		rx_uart <= '1';
		RST <= '0';
		wait for 100 ns;
    	RST <= '1';

		wait until rising_edge(CLK);

		rx_uart <= '0'; -- start bit
		wait for uart_period;

		for i in 0 to (data_value'LENGTH-1) loop
			rx_uart <= data_value(i); -- data bits
			wait for uart_period;
		end loop;

		rx_uart <= '1'; -- stop bit
		wait for uart_period;

		rx_uart <= '0'; -- start bit
		wait for uart_period;

		for i in 0 to (data_value2'LENGTH-1) loop
			rx_uart <= data_value2(i); -- data bits
			wait for uart_period;
		end loop;

		rx_uart <= '1'; -- stop bit
		wait for uart_period;

		wait;

	end process;

	test_tx : process
	begin
		data_send <= '0';
		RST <= '0';
		wait for 100 ns;
      	RST <= '1';

		wait until rising_edge(CLK);

		data_send <= '1';
		data_in <= data_value;

		wait until rising_edge(CLK);

		data_send <= '0';

		wait until rising_edge(CLK);

		wait until falling_edge(tx_busy);
		wait for 100 us;
		wait until rising_edge(CLK);

		data_send <= '1';
		data_in <= data_value2;

		wait until rising_edge(CLK);

		data_send <= '0';

		wait until rising_edge(CLK);

		wait;

	end process;

end FULL;
