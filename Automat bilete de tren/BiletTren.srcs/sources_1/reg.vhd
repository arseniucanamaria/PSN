----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2019 02:49:18 AM
-- Design Name: 
-- Module Name: reg - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reg is
Port
 (
 signal clk:in std_logic;
 signal wd:in std_logic_vector(9 downto 0);
 signal regwr:in std_logic;
 signal rd:out std_logic_vector(9 downto 0)
  );
end reg;

architecture Behavioral of reg is
signal stocare:std_logic_vector(9 downto 0);
begin
process(clk,regwr)
begin
if clk='1' and clk'event then
if regwr='1' then
stocare<=wd;
end if;
end if;
end process;
rd<=stocare;
end Behavioral;
