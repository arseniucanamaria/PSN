
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Functie is
Port 
(
signal led:out std_logic_vector(2 downto 0); --vom semnaliza luminos folosind 3 leduri atunci cand nu mai sunt bilete in autonomat,
                            -- cand utilizatorul introduce mai putini bani decat e costul biletului sau cand nu se poate da rest 
signal sw:in std_logic_vector(5 downto 0); --se folosesc in total 6 switch-uri, 2 cand se introduce distanta, si 6 atunci cand se introduc bancnotele (6 tipuri de bancnote)
signal anulare:in std_logic; --utilizatorul are posibilitatea sa renunte la operatia curenta folosind un buton (btn 3)
signal digits:out std_logic_vector(15 downto 0); --ceea ce punem pe afisor; cei 4 anozi (1 anod primeste 4 biti)
signal clk:in std_logic;
signal introducere:in std_logic;--btn incrementare
signal reset:in std_logic; --in starea de reset, automatul revine la starea initiala, cea in care se introduce distanta 
signal confirmare:in std_logic --dupa o anumita stare, se apasa pe butonul din centru(btn 0) pentru a trece la urmatoarea operatie 
 );
end Functie;

architecture Behavioral of Functie is

--registrul imi pastreaza anumite valori a semnalelor pentru a nu se pierde pe parcursul functionarii automatului
component reg is
Port
 (
 signal clk:in std_logic;
 signal wd:in std_logic_vector(9 downto 0); --data pe care o introduc 
 signal regwr:in std_logic; -- "enable" pentru registru
 signal rd:out std_logic_vector(9 downto 0) --data care e stocata in registru "iese" afara atunci cand regwr='1'
  );
end component;

signal reset1:std_logic;
signal counter:std_logic_vector(2 downto 0);
type stari is (introducereKM,afisareS,introducereS,eliberareR,elibB,golire);
signal blocare:std_logic;
signal stare,stare_urm:stari;
signal suta:std_logic_vector(9 downto 0);
signal zeci:std_logic_vector(9 downto 0);
signal distanta:std_logic_vector(9 downto 0);
signal rezdist:std_logic_vector(9 downto 0);
signal rezsuma:std_logic_vector(9 downto 0);
    --semnale care trebuie transmise la afisor
signal concat1:std_logic_vector(15 downto 0);--distanta
signal concat2:std_logic_vector(15 downto 0);--pret
signal concat3:std_logic_vector(15 downto 0);--suma introduse
signal concat4:std_logic_vector(15 downto 0);--restul
signal concat5:std_logic_vector(15 downto 0);--biletul


signal dist:integer;
--semnale pentru a transforma fiecare cifra a distantei intr-un vector pe 4 biti
signal cifra1:integer;
signal cifra2:integer;
signal cifra3:integer;

signal pret:integer;
--semnale pentru a transforma fiecare cifra a pretului intr-un vector pe 4 biti
signal cif1:integer;
signal cif2:integer;

signal suma:std_logic_vector(9 downto 0);

signal sint:integer;
--semnale pentru a transforma fiecare cifra a sumei introduse intr-un vector pe 4 biti
signal cf1:integer;
signal cf2:integer;
signal cf3:integer;

  --semnale pentru calcularea restului  
signal rest:integer;
signal rest_aux:integer;


--semnale pentru 2 registre
signal regwr:std_logic;
signal regwr1:std_logic;


signal euro1:std_logic_vector(7 downto 0);
signal euro2:std_logic_vector(7 downto 0);
signal euro5:std_logic_vector(7 downto 0);
signal euro10:std_logic_vector(7 downto 0);
signal euro20:std_logic_vector(7 downto 0);
signal euro50:std_logic_vector(7 downto 0);

signal l1,l2,l3:std_logic; --semnale pentru leduri

signal ENbilet:std_logic; --acest semnal se activeaza cand trebuie dat bilet 
signal nr_bilete:std_logic_vector(3 downto 0):="0111"; --numarul de bilete pe care il initializam noi cu o anumita valoare
signal decrementare:std_logic;--semnal care decrementeaza numarul de bilete din casa in momentul in care se da biletul

signal digrest:std_logic_vector(15 downto 0);--semnal pentru afisarea restului pe direct pe afisor

   --rest1, ... , rest6 va fi un vector pe 3 biti care tine numarul de bancnote de fiecare tip care trebuie dat ca si rest
signal rest1:std_logic_vector(3 downto 0);
signal rest2:std_logic_vector(3 downto 0);
signal rest5:std_logic_vector(3 downto 0);
signal rest10:std_logic_vector(3 downto 0);
signal rest20:std_logic_vector(3 downto 0);
signal rest50:std_logic_vector(3 downto 0);


signal selectie:std_logic_vector(2 downto 0);--ne arata ce bancnota trebuie sa punem la un moment dat

signal secunde:std_logic_vector(1 downto 0);
signal clk_divizat:std_logic;
signal clk_divizat2:std_logic;

signal counter10:std_logic_vector(26 downto 0);

signal nr1_casa,nr2_casa,nr5_casa,nr10_casa,nr20_casa,nr50_casa:integer:=9;-- banii care ii am in casa
signal numar1,numar2,numar5,numar10,numar20,numar50:integer:=0; ---numarul de bancnote care trebuie date utilizatorului

signal nubine:std_logic;


signal ex1:std_logic_vector(9 downto 0);
signal ex2:std_logic_vector(9 downto 0);
signal ex5:std_logic_vector(9 downto 0);
signal ex10:std_logic_vector(9 downto 0);
signal ex20:std_logic_vector(9 downto 0);
signal ex50:std_logic_vector(9 downto 0);


signal stoc1:integer;
signal stoc2:integer;
signal stoc5:integer;
signal stoc10:integer;
signal stoc20:integer;
signal stoc50:integer;

signal st1:integer;
signal st2:integer;
signal st5:integer;
signal st10:integer;
signal st20:integer;
signal st50:integer;

signal suma_casa:integer;


begin

 reg1:reg port map (clk=>clk,wd=>distanta,regwr=>regwr,rd=>rezdist);
  suta<=rezdist+100; --imi creste cu o unitate cifra sutelor
  zeci<=rezdist+10; --imi creste cu o unitate cifra zecilor
        
        
        --sw
        process(sw,zeci,suta,distanta,counter)
        begin
          if counter="001" or counter="010" or counter="011" or counter="100" then --daca ne aflam in starea de afisare pret, introd suma sau eliberare rest
                   distanta<=distanta;
                   regwr<='0';
          elsif counter="101" or counter="111" then --daca suntem in stare de reset sau anulare
                  distanta<=(others=>'0');
                  regwr<='1';
          elsif counter="000" then --starea de introducere a distantei
                   regwr<=introducere;
                   
            case sw(1 downto 0) is
                when "01"=>distanta<=zeci; --cand e aprins switch-ul pentru zeci (sw0),si, desigur, apasam pe butonul de incrementare, cifra zecilor de pe afisor creste cu o unitate
                when "10"=>distanta<=suta;  --sw1-pentru incrementarea sutelor
                when others=> distanta<=distanta;
            end case;
            
          end if;
        end process;
        
           --transformam distanta in intreg si o pregatim pentru punerea pe afisor (transformare fiecarei cifre in vector de 4 biti)
        dist<=conv_integer(rezdist);
        cifra1<=dist mod 10;
        cifra2<=dist/10 mod 10;
        cifra3<=dist/100 mod 10;
        
        pret<=cifra3*10+cifra2;
        cif1<=pret mod 10;
        cif2<=pret/10 mod 10;  
       
        
      sint<=conv_integer(rezsuma);
            cf1<=sint mod 10;
            cf2<=sint/10 mod 10;
            cf3<=sint/100 mod 10;
            
        concat1<="1110" & conv_std_logic_vector(cifra3,4) & conv_std_logic_vector(cifra2,4) & "0000"; --distanta de pus pe afisor (1110-codul pentru "d" pe afisor)
        concat2<="1100" & "0000" & conv_std_logic_vector(cif2,4) & conv_std_logic_vector(cif1,4);  --pretul (1100-codul pentru "P") 
        concat3<="0101" & conv_std_logic_vector(cf3,4) & conv_std_logic_vector(cf2,4) & conv_std_logic_vector(cf1,4);--suma introdusa care trebuie pusa pe afisor     
            
          
        process(sint,pret)
        begin
            if sint-pret>=0 and sint/=0 and pret/=0 then --daca suma>pret, dam bilet
                l1<='0';
                ENbilet<='1';
            elsif sint-pret<0 or (sint=0 and pret=0) then
                l1<='1';
                ENbilet<='0';
            end if;
        end process;
    
    
        
        --calculam suma totala din casa
    suma_casa<=nr1_casa+(2*nr2_casa)+(5*nr5_casa)+(nr10_casa*10)+(nr20_casa*20)+(nr50_casa*50);
    
    
    process(sint,pret)
    begin
      if sint-pret>=0 then  --daca avem suma mai mare decat costul biletului, calculam restul 
           rest<=sint-pret;
           l3<='0';
      else
           rest<=sint; --daca S<P semnalizam luminos, iar restul e tot suma introdusa deaorece ii dam banii inapoi 
           l3<='1';
      end if;
    end process;


     reg2:reg port map (clk=>clk,wd=>suma,regwr=>regwr1,rd=>rezsuma);
     
    ex1<=rezsuma+1;
    ex2<=rezsuma+2;
    ex5<=rezsuma+5;
    ex10<=rezsuma+10;
    ex20<=rezsuma+20;
    ex50<=rezsuma+50;
    
    stoc1<=nr1_casa+1;
    stoc2<=nr2_casa+1;
    stoc5<=nr5_casa+1;
    stoc10<=nr10_casa+1;
    stoc20<=nr20_casa+1;
    stoc50<=nr50_casa+1;
    
    
    process(clk,introducere,counter,sw,nubine)  
	begin
	   if nubine='1' then --atunci cand sunt in orice alta stare decat cea in care dam restul, pastram in semnalul rest_aux restul, 
	                --pentru a nu se face aceeasi atribuire de mai multe ori cand facem algoritmul de rest 
	        rest_aux<=rest;
	   else
          if counter="011" or counter="111" then	
              if rising_edge(clk) then
                if rest_aux-50>=0 then
                    numar50<=numar50+1;
                    rest_aux<=rest_aux-50;
                elsif rest_aux-20>=0 then
                    numar20<=numar20+1;
                    rest_aux<=rest_aux-20;
                elsif rest_aux-10>=0 then
                    numar10<=numar10+1;
                    rest_aux<=rest_aux-10;
                elsif rest_aux-5>=0 then
                    numar5<=numar5+1;
                    rest_aux<=rest_aux-5;
                elsif rest_aux-2>=0 then
                    numar2<=numar2+1;
                    rest_aux<=rest_aux-2;
                elsif rest_aux-1>=0 then
                    numar1<=numar1+1;
                    rest_aux<=rest_aux-1;
		        end if; 
	         end if; 	
	      end if;		
	end if;
	          --atunci cand se reseteaza automatul(starea 101), reinitializam numarul de bancnote introduse
        if counter="101"  then --starea de reset
            numar1<=0;
            numar2<=0;
            numar5<=0;
            numar10<=0;
            numar20<=0;
            numar50<=0;
            suma<=(others=>'0');
                --iar numarul din casa e stocul initial 
            nr1_casa<=st1;
            nr2_casa<=st2;
            nr5_casa<=st5;
            nr10_casa<=st10;
            nr20_casa<=st20;
            nr50_casa<=st50;        
         end if;
        
        if   counter="000" or counter="001" or counter="100" then --stare introd distanta, afisare pret, eliberare bilet       
            suma<=suma;
            nr1_casa<=st1;
            nr2_casa<=st2;
            nr5_casa<=st5;
            nr10_casa<=st10;
            nr20_casa<=st20;
            nr50_casa<=st50;
        end if;
        
           --actualizare casa bani introdusi din switch-uri
        if counter="010" then --stare introducere bancnote     
          case sw is
            when "000001"=>st1<=stoc1+1;suma<=ex1; --cand e aprins switch-ul pt bancnota de 1 euro, si apasam pe buton, mi se adauga la casa de bani numarul de bancnote respectiv, iar la suma, valoarea bancnotei 
            when "000010"=>st2<=stoc2+1;suma<=ex2;--cand e aprins switch-ul pt bancnota de 2 euro, si apasam pe buton, mi se adauga la casa de bani numarul de bancnote respectiv, iar la suma, valoarea bancnotei
            when "000100"=>st5<=stoc5+1;suma<=ex5; -- ----------------||------------------5 euro -------------||----------------------------
            when "001000"=>st10<=stoc10+1;suma<=ex10; -- ----------------||------------------10 euro -------------||----------------------------
            when "010000"=>st20<=stoc20+1;suma<=ex20;-- ----------------||------------------20 euro -------------||----------------------------
            when "100000"=>st50<=stoc50+1;suma<=ex50;-- ----------------||------------------50 euro -------------||----------------------------
            when others=> suma<=suma;       
          end case;  
        end if;
      end process;

--conversii din intreg in vector pentru a pune pe afisor
    rest1<=conv_std_logic_vector(numar1,4);
    rest2<=conv_std_logic_vector(numar2,4);
    rest5<=conv_std_logic_vector(numar5,4);
    rest10<=conv_std_logic_vector(numar10,4);
    rest20<=conv_std_logic_vector(numar20,4);
    rest50<=conv_std_logic_vector(numar50,4);
    
  
           --la fiecare 3 secunde (selectie), imi afiseaza pe afisor fiecare bancnote
           --"1010" -codul pentru "-" pt afisor
           --rest1, ..., rset50- numarul de bancnote de fiecare tip
        process(selectie,rest1,rest2,rest5,rest10,rest20,rest50)
        begin
             case selectie is 
                    when "000"=>digrest<= rest1 & "1010" & x"01"; 
                    when "001"=>digrest<= rest2 & "1010" & x"02";
                    when "010"=>digrest<= rest5 & "1010" & x"05";
                    when "011"=>digrest<= rest10 & "1010" & x"10";
                    when "100"=>digrest<= rest20 & "1010" & x"20";
                    when "101"=>digrest<= rest50 & "1010" & x"50";
                    when others=> digrest<=x"0000";
            end case;
        end process;
        
               --clk divizat pe o secunda
         process(clk,counter10)
        begin
            if clk='1' and clk'event then
                 if counter10<100000000 then
                    counter10<=counter10+1;
                    clk_divizat<='0';
                 else
                    counter10<=(others=>'0');
                    clk_divizat<='1';
                 end if;
            end if;
        end process;
        
            --clk divizat pe 3 secunde pentru afisarea restului
        process(clk_divizat,secunde)
        begin
             if clk_divizat='1' and clk_divizat'event then
                    if secunde<"11" then
                        secunde<=secunde+1;
                        clk_divizat2<='0';
              else
                        clk_divizat2<='1';
                        secunde<="00";
                    end if;
             end if;
        end process;
              
              --selectia ne arata ce bancnota trebuie sa punem pe afisor
              --selectia mi se incrementeaza o data la 3 secunde
        process(clk_divizat2,selectie)
        begin
            if rising_edge(clk_divizat2) then
                if selectie<"101" then
                   selectie<=selectie+1;
                else
                   selectie<="000";
                end if;
           end if;
        end process;
        
        
        
        process(nr_bilete)
        begin
            if nr_bilete=0 then
                 l2<='1';
                 blocare<='1'; --cand nu mai avem bilete, blocam automatul ca sa nu se mai poata face operatii si afisam luminos
            else
                  blocare<='0';
                  l2<='0';
            end if;
        end process;
        
        process(decrementare)
        begin
            if decrementare'event and decrementare='1' then --cand trebuie sa dam bilet, decrementam dn casa numarul de bilete
                   nr_bilete<=nr_bilete-1;
            end if;
        end process;
        
        process(ENbilet)
        begin
            if ENbilet='1' then --cand trebuie sa dam bilet, afisam pe afisor ca a primit bilet 
                concat5<=x"00B1";
            else
                concat5<=x"0FB1";--daca se introduc mai putini bani, afisam ca nu ii dam bilet  "FB1"
            end if;
        end process;

        
        
        process(clk,reset)
        begin
        if reset='1' then
            stare<=introducereKM;
        elsif clk='1' and clk'event then
            stare<=stare_urm;
        end if;
        end process;
        
        
           reset1<=reset or blocare;
        
        --numarator pe butonul din mijloc pentru a trece dintr-o stare in alta
        --counter-ul ne determina in ce stare suntem ca dupa sa punem pe afisor
        process(clk,confirmare,reset1,counter,anulare,blocare)
        begin
        if reset1='1' then
            counter<=(others =>'0');
        elsif clk'event and clk='1' then
           if confirmare='1' then
               counter<=counter+1;
           end if;
           if counter="110" then
               counter<="000";
           end if;
           if counter="111" and rest_aux=0 then
               counter<="101";
           end if;
           if anulare='1' then --daca am introdus bani si vrem sa renuntam, trebuie sa dam banii inapoi
               counter<="111";
           end if;
        end if;
        end process;
        
          -- l3->atunci cand nu se poate da rest
          -- l2->led pentru anuntarea lipsei de bilete
          -- l1-> se activeaza doar cand utilizatorul introduce mai putini bani decat e pretul
          -- counter->retine numarul de apasari pe butonul 0 care trece dintr-o stare in alta 
          -- concat1-distanta
          -- concat2-pret
          -- concat3-suma introdusa
          -- digrest-restul
          -- concat5-bilet
          -- decrementare->scade numarul de bilete  doar atunci cand trebuie sa ii dau bilet persoanei(starea 100-eliberare bilet)
          -- nubine-> --atunci cand sunt in orice alta stare decat cea in care dam restul, pastram in semnalul rest_aux restul, 
	                --iar cand suntem in starea in care trebuie sa calculam restul, trecem direct la algoritm, pentru a nu se face aceeasi atribuire a restului de mai multe ori 
	                
        process(counter)
        begin
        case counter is
            when "000" =>digits<=concat1;decrementare<='0';led(2)<='0';led(1)<=l2;led(0)<='0';nubine<='1';regwr1<='0';--distanta
            when "001" =>digits<=concat2;decrementare<='0';led(2)<='0';led(1)<=l2;led(0)<='0';nubine<='1';regwr1<='0';--pret
            when "010"=>digits<=concat3;decrementare<='0';led(2)<='0';led(1)<=l2;led(0)<=l1;nubine<='1';regwr1<=introducere; --regwr1-pt retinerea sumei
            when "011"=>digits<=digrest;decrementare<='0';led(2)<=l3;led(1)<=l2;led(0)<='0';nubine<='0';regwr1<='0';--rest
            when "100"=>digits<=concat5;decrementare<=ENbilet;led(2)<='0';led(1)<=l2;led(0)<=l1;nubine<='1';regwr1<='0';--bilet
            when "101"=>digits<=concat3;decrementare<='0';led(2)<='0';led(1)<=l2;led(0)<='0';nubine<='1';regwr1<='1';--reset
            when "111"=>digits<=digrest;decrementare<='0';led(2)<='0';led(1)<=l2;led(0)<='0';nubine<='1';regwr1<='1';--anulare
            when others => digits<=x"ffff";decrementare<='0';led(2)<='0';led(1)<='0';led(0)<='0';nubine<='1';regwr1<='0';
        end case;
        end process;

end Behavioral;
