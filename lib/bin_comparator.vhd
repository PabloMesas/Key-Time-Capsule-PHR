----------------------------------------------------------------------------------
-- Company: KTC Team
-- 
-- Design Name: 
-- Module Name: bIN_adder - Behavioural
-- Project Name: Basys 3 Key-Time-Capsule
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


ENTITY comparator IS
    GENERIC (l: INTEGER:= 1024);
    PORT (
        CLK: IN std_logic; -- CLK for synchronization
        A, B: IN std_logic_vector(7 DOWNTO 0);
        IAB: IN std_logic; -- (Active low)
        RESULT: OUT std_logic);
END comparator;

ARCHITECTURE Behavioural OF comparator IS
-- Signal Declerations
SIGNAL AB: std_logic_vector(7 DOWNTO 0);
SIGNAL s: std_logic;

BEGIN

 AB(0) <= (not A(0)) xnor (not B(0));         
        -- combINational circuit
 AB(1) <= (not A(1)) xnor (not B(1)); 
 AB(2) <= (not A(2)) xnor (not B(2)); 
 AB(3) <= (not A(3)) xnor (not B(3)); 
 AB(4) <= (not A(4)) xnor (not B(4)); 
 AB(5) <= (not A(5)) xnor (not B(5)); 
 AB(6) <= (not A(6)) xnor (not B(6)); 
 AB(7) <= (not A(7)) xnor (not B(7)); 
 -- fpga4student.com FPGA projects, Verilog projects, VHDL projects
 PROCESS (CLK)
 BEGIN
 if(risINg_edge(CLK))then
   if(AB = x"FF" and IAB = '0') then         
         -- check whether A = B and IAB =0 or not
            s <= '0';
        else
        s <= '1';
        END if;
    END if;
    END PROCESS;
    RESULT <= s;
END Behavioural;

