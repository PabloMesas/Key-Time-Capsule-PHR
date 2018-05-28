----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.05.2018 01:20:11
-- Design Name: 
-- Module Name: top_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;

entity top_tb is
end top_tb;

architecture FULL of top_tb is

	signal CLK           : std_logic := '0';
	signal ledRST        : std_logic := '1';
	signal sw            : std_logic := '1';
	signal rx            : std_logic := '1';
	signal tx            : std_logic;

    constant clk_period  : time := 10 ns;
	constant uart_period : time := 104.167 us;
	constant data_length : natural := 8;
	constant data_value  : std_logic_vector(31 downto 0) := "00000000000000000000000100111111";
	constant data_value2 : std_logic_vector(7 downto 0) := "01110011";
	
	COMPONENT top IS
        GENERIC (
            lb          : natural;
            lr          : natural;
            lk          : natural;
            d_width     : natural;
            clk_freq    : integer);
        PORT (
            CLK         : IN std_logic;
            ledRST      : OUT std_logic;
            sw          : IN std_logic;
            RsRx        : IN std_logic;
            Tx          : OUT std_logic);                                        --transmit pin
    END COMPONENT top;

begin

	top_mod: top
      GENERIC MAP (
        lb => 32,
        lr => 32,
        lk => 8,
        d_width => 8,
        clk_freq => 100_000_000
        )
      PORT MAP (
        CLK => CLK,
        ledRST => ledRST,
        sw => sw,
        RsRx => rx,
        Tx => tx
        );

	clk_process : process
	begin
		CLK <= '0';
		wait for clk_period/2;
		CLK <= '1';
		wait for clk_period/2;
	end process;

	test_rx_uart : process
	variable count         : integer RANGE 0 TO 7;
	begin
	    count := 0;
		rx <= '1';
		sw <= '0';
		wait for 100 ns;
    	sw <= '1';

		wait until rising_edge(CLK);


		for i in 0 TO (data_value'LENGTH-1) loop
		    IF count = 0 THEN
		      rx <= '0'; -- start bit
              wait for uart_period;
		    END IF;
		    
			rx <= data_value(i); -- data bits
			wait for uart_period;
			
			IF count = 7 THEN
              rx <= '1'; -- stop bit
              wait for uart_period;
              count := 0;
            ELSE
              count := count + 1;
            END IF;
		end loop;

		rx <= '1'; -- stop bit
		wait for uart_period;

		rx <= '0'; -- start bit
		wait for uart_period;

		for i in 0 to (data_value2'LENGTH-1) loop
			rx <= data_value2(i); -- data bits
			wait for uart_period;
		end loop;

		rx <= '1'; -- stop bit
		wait for uart_period;

		wait;

	end process;

end FULL;
