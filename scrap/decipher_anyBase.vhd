----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: decipher_anybase - Behavioural
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY decipher_anybase IS
    GENERIC (l: INTEGER:= 1024);
    PORT (
        CLK         : IN std_logic;
        RESET       : IN std_logic;
        CK          : IN std_logic_vector(l DOWNTO 0);
        A           : IN std_logic_vector(l DOWNTO 0);
        N           : IN std_logic_vector(l DOWNTO 0);
        T           : IN std_logic_vector(l DOWNTO 0);
        K           : OUT std_logic_vector(l DOWNTO 0));
END decipher_anybase;

ARCHITECTURE Behavioural OF decipher_anybase IS
-- After this line all code showed belongs to other different program.
-- DON'T PANIC AND KEEP CALM

-- Signal Declerations
SIGNAL sys_enable  : std_logic;
SIGNAL bcd_i       : std_logic_vector(3 DOWNTO 0);
SIGNAL count       : std_logic_vector(16 DOWNTO 0) := (OTHERS => '0');
SIGNAL count_an    : std_logic_vector(1 DOWNTO 0) := "00";

BEGIN
    DP <= '1';

    -- Simple Clock Divider (100MHz -> 1kHz)
    PROCESS(CLK, RESET)
    BEGIN
        IF (RESET = '1') THEN
            sys_enable <= '0';
            count <= (OTHERS => '0');
        ELSIF (rising_edge(CLK)) THEN
            sys_enable <= '0';
            count <= count + 1;
            
            IF (count = "11000011010100000") THEN
                sys_enable <= '1';
                count <= (OTHERS => '0');
            END IF;
        END IF;
    END PROCESS;
    
    -- Anode Drive PROCESS
    PROCESS(CLK, RESET)
    BEGIN
        IF (RESET = '1') THEN
            AN <= "0000";
        ELSIF (rising_edge(CLK)) THEN
            IF (sys_enable = '1') THEN
                CASE count_an IS
                    WHEN "00" => bcd_i <= BCD(15 DOWNTO
         12); AN <= "0111";
                    WHEN "01" => bcd_i <= BCD(11 DOWNTO
         8); AN <= "1011";
                    WHEN "10" => bcd_i <= BCD(7 DOWNTO
         4); AN <= "1101";
                    WHEN "11" => bcd_i <= BCD(3 DOWNTO
         0); AN <= "1110";
                    WHEN OTHERS => bcd_i <= "1111"; AN <= "1111";
                END CASE;
                
                count_an <= count_an + 1;
            END IF;
        END IF;
    END PROCESS;
    
    -- SSD Drive PROCESS
    PROCESS(CLK, RESET)
    BEGIN
        IF (RESET = '1') THEN
            SSD <= "0000000";
        ELSIF (rising_edge(CLK)) THEN
            IF (sys_enable = '1') THEN
                CASE bcd_i IS
                    WHEN "0000" => SSD <= "1000000"; -- '0'
                    WHEN "0001" => SSD <= "1111001"; -- '1'
                    WHEN "0010" => SSD <= "0100100"; -- '2'
                    WHEN "0011" => SSD <= "0110000"; -- '3'
                    WHEN "0100" => SSD <= "0011001"; -- '4'
                    WHEN "0101" => SSD <= "0010010"; -- '5'
                    WHEN "0110" => SSD <= "0000010"; -- '6'
                    WHEN "0111" => SSD <= "1111000"; -- '7'
                    WHEN "1000" => SSD <= "0000000"; -- '8'
                    WHEN "1001" => SSD <= "0010000"; -- '9'
                    WHEN OTHERS => SSD <= "1111111"; -- 'null'
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END Behavioural;