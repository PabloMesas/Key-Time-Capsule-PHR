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
	constant uart_period : time := 104.17 us;
	constant data_length : natural := 8;
	constant data_ck     : std_logic_vector(31 downto 0) := "00100000111101101100010100110101";
	constant data_a      : std_logic_vector(31 downto 0) := "00101011101000101010111010011101";
	constant data_n      : std_logic_vector(31 downto 0) := "01101101000110001101010011101111";
	constant data_t      : std_logic_vector(31 downto 0) := "00000000000000010000000000000000";
	
	COMPONENT top IS
        PORT (
            CLK         : IN std_logic;
            ledRST      : OUT std_logic;
            sw          : IN std_logic;
            RsRx        : IN std_logic;
            Tx          : OUT std_logic);                                        --transmit pin
    END COMPONENT top;

begin

	top_mod: top
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


		for i in 0 TO (data_ck'LENGTH-1) loop
		    IF count = 0 THEN
		      rx <= '0'; -- start bit
              wait for uart_period;
		    END IF;
		    
			rx <= data_ck(i); -- data bits
			wait for uart_period;
			
			IF count = 7 THEN
              rx <= '1'; -- stop bit
              wait for uart_period;
              count := 0;
            ELSE
              count := count + 1;
            END IF;
		end loop;
		
		wait until rising_edge(CLK);
		
		for i in 0 TO (data_a'LENGTH-1) loop
            IF count = 0 THEN
              rx <= '0'; -- start bit
              wait for uart_period;
            END IF;
            
            rx <= data_a(i); -- data bits
            wait for uart_period;
            
            IF count = 7 THEN
              rx <= '1'; -- stop bit
              wait for uart_period;
              count := 0;
            ELSE
              count := count + 1;
            END IF;
        end loop;
        
        wait until rising_edge(CLK);
        
        for i in 0 TO (data_n'LENGTH-1) loop
            IF count = 0 THEN
              rx <= '0'; -- start bit
              wait for uart_period;
            END IF;
            
            rx <= data_n(i); -- data bits
            wait for uart_period;
            
            IF count = 7 THEN
              rx <= '1'; -- stop bit
              wait for uart_period;
              count := 0;
            ELSE
              count := count + 1;
            END IF;
        end loop;
        
        wait until rising_edge(CLK);
        
        for i in 0 TO (data_t'LENGTH-1) loop
            IF count = 0 THEN
              rx <= '0'; -- start bit
              wait for uart_period;
            END IF;
            
            rx <= data_t(i); -- data bits
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

		rx <= '1'; -- stop bit
		wait for uart_period;

		wait;

	end process;

end FULL;
