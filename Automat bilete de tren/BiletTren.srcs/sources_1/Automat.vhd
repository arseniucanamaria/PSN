----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/04/2019 01:16:00 AM
-- Design Name: 
-- Module Name: Automat - Behavioral
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

entity Automat is
 Port
  (
  signal clk:in std_logic;
  signal btn:in std_logic_vector(4 downto 0);
  signal sw:in std_logic_vector(15 downto 0);
  signal led:out std_logic_vector(15 downto 0);
  signal cat:out std_logic_vector(6 downto 0);
  signal an:out std_logic_vector(3 downto 0)
   );
end Automat;

architecture Behavioral of Automat is

component Functie is
Port 
(
signal led:out std_logic_vector(2 downto 0);
signal sw:in  std_logic_vector(5 downto 0);
signal anulare:in std_logic; --utilizatorul are un buton(btn 3) de renuntare
signal digits:out std_logic_vector(15 downto 0); --ceea ce vom pune pe afisor
signal clk:in std_logic;
signal introducere:in std_logic; --buton (btn 1) pentru incrementarea distantei si banilor
signal reset:in std_logic; --buton(btn 2) care, daca e apasat, ne duce in starea 0, cea de intoducere a distantei, pentru a o putea modifica 
signal confirmare:in std_logic --buton (btn 0) pentru trecerea dintr-o stare in alta
 );
end component;

component SSD is
  Port (
  signal digit0: in std_logic_vector(3 downto 0);
  signal digit1: in std_logic_vector(3 downto 0);
  signal digit2: in std_logic_vector(3 downto 0);
  signal digit3: in std_logic_vector(3 downto 0);
  signal clk:in std_logic;
  signal cat:out std_logic_vector(6 downto 0);
  signal an:out std_logic_vector(3 downto 0)
  
  );
end component;

component mpg is
 Port ( signal btn:in std_logic;
        signal clk:in std_logic;
        signal en:out std_logic
 );

end component;

signal digits:std_logic_vector(15 downto 0);
signal mpge0,mpge1,mpge2,mpge3:std_logic;

begin

mpg0:mpg port map(en=>mpge0,clk=>clk,btn=>btn(0));--trecere dintr-o stare in alta
mpg1:mpg port map(en=>mpge1,clk=>clk,btn=>btn(1));--incrementare
mpg2:mpg port map(en=>mpge2,clk=>clk,btn=>btn(2)); --revenire in starea 0, in caz ca vrea sa schimbe distanta 
mpg3:mpg port map(en=>mpge3,clk=>clk,btn=>btn(3));--anulare operatie
SSD1:SSD port map(digit0=>digits(3 downto 0),digit1=>digits(7 downto 4),digit2=>digits(11 downto 8),digit3=>digits(15 downto 12),cat=>cat,an=>an,clk=>clk);
Functie1:Functie port map(led=>led(2 downto 0),introducere=>mpge1,sw=>sw(5 downto 0),anulare=>mpge3,digits=>digits,clk=>clk,reset=>mpge2,confirmare=>mpge0);

end Behavioral;
