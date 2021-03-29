library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity SSD is
  Port (
   digit0: in std_logic_vector(3 downto 0);
   digit1: in std_logic_vector(3 downto 0);
   digit2: in std_logic_vector(3 downto 0);
   digit3: in std_logic_vector(3 downto 0);
   clk:in std_logic;
   cat:out std_logic_vector(6 downto 0);
   an:out std_logic_vector(3 downto 0)
  );
end SSD;

architecture Behavioral of SSD is
   signal semnal:std_logic_vector(1 downto 0);
   signal count_in:std_logic_vector(15 downto 0);
   signal outmux1:std_logic_vector(3 downto 0);
begin

process(clk)
begin
if rising_edge(clk) then
count_in<=count_in+1;
end if;
end process;

semnal<=count_in(15 downto 14);

process (digit0,digit1,digit2,digit3,semnal)
begin
case semnal is
when "00" => outmux1<=digit0;
when "01" => outmux1<=digit1;
when "10" => outmux1<=digit2;
when others => outmux1<=digit3;
end case;
end process;

process(outmux1)
begin
case outmux1 is  --afisarea cifrelor pe anozi (afisor) in hexazecimal  
when "0000" => cat <=not("0111111"); --0      --folosim ~not~ deoarece catozii sunt activi pe 0
when "0001" => cat <=not("0000110");  --1
when "0010" => cat <=not("1011011");  --2
when "0011" => cat <=not("1001111");  --3
when "0100" => cat <=not("1100110");  --4
when "0101" => cat <=not("1101101");  --5
when "0110" => cat <=not("1111101");  --6
when "0111" => cat <=not("0000111");  --7
when "1000" => cat <=not("1111111");  --8
when "1001" => cat <=not("1101111");  --9
when "1010" => cat <=not("1000000");  -- "-" -->pt afisarea restului (ex. 2-10, 0-05)
when "1011" => cat <=not("1111100");  --b   --> folosim ~b~ pentru cand returnam biletul
when "1100" => cat <=not("1110011");  --P   --> folosim ~P~ pentru cand afisam pretul biletului
when "1101" => cat <=not("1101101");  --S   --> ~S~ semnifica suma introdusa (bancnotele introduse)
when "1110" => cat <=not("1011110");  --d   --> folosim ~d~ pentru cand afisam distanta introdusa
when others => cat <=not("1110001");  --f   --> "FB1"
end case;
end process;

process (semnal)
begin
case semnal is
when "00" => an<="1110";
when "01" => an<="1101";
when "10" => an<="1011";
when others => an<="0111";
end case;
end process;

end Behavioral;
