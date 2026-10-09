----------------------------------------------------------------------------------
-- Company: IPSA
-- Engineer: ALAUX Florian, BOLTEAU Maëva

-- Create Date:

----------------------------------------------------------------------------------
library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;



entity countled is
port(
-- Clock
        CLK : in std_logic ; -- Horloge principale à 100 MHz

-- LEDs
        LED : out std_logic_vector (15 downto 0);        
-- Boutons
        BTND : in std_logic ; --Bouton du bas pour la pause
        BTNU : in std_logic ; --Bouton du haut pour start et reprendre
        BTNR : in std_logic ; --Bouton de droite
        BTNL : in std_logic ; --Bouton de gauche
        BTNC : in std_logic ; --Bouton central pour reset    

 -- Cathodes de l'afficheur 7 segments
        CA : out std_logic ;      
        CB : out std_logic ;
        CC : out std_logic ;
        CD : out std_logic ;
        CE : out std_logic ;
        CF : out std_logic ;
        CG : out std_logic ;
        DP : out std_logic ; -- Point décimal

--Anodes
        AN0 : out std_logic ;
        AN1 : out std_logic ;
        AN2 : out std_logic ;
        AN3 : out std_logic ;
--Switches
        SW : in std_logic_vector (3 downto 0)  -- on ne les utilise plus ici c'était pour le tp introductif
    );
end countled;

architecture rtl of countled is

-- Création de toutes les variables
signal s_clk_lent : STD_LOGIC; -- Variable pour la clock à 100 Hz
signal s_clk_compteur : STD_LOGIC_VECTOR (26 downto 0); -- Variable qui compte les valeurs de la clock interne à 100 MHz. 27 bits pour compter jusqu'à 100 millions
signal s_cathode : STD_LOGIC_VECTOR (3 downto 0); -- Valeur à afficher sur les segments
signal s_clk_dizaine : STD_LOGIC_VECTOR (3 downto 0); -- Dizaines de seconde
signal s_clk_unite : STD_LOGIC_VECTOR (3 downto 0);  -- Unités de seconde
signal s_clk_dizieme : STD_LOGIC_VECTOR (3 downto 0);  -- Dixièmes de seconde
signal s_clk_centieme : STD_LOGIC_VECTOR (3 downto 0); -- Centièmes de seconde
signal s_2bit : STD_LOGIC_VECTOR (1 downto 0); -- Sélectionne l'afficheur
signal s_reset : std_logic := '0'; -- Signal de reset
signal btnu_sync : std_logic_vector(2 downto 0);  -- pour BTNU (start/reprise)
signal btnd_sync : std_logic_vector(2 downto 0);  -- pour BTND (pause)
signal s_running  : std_logic := '0'; -- compteur désactivé au départ
signal s_refresh  : std_logic_vector(17 downto 0); -- pour avoir un refresh plus rapide de l'affichage



begin
process(CLK, s_reset )--Création du process de la clock pour passer de 100 Mhz à 100 Hz
begin
    if s_reset = '1' then
        s_clk_compteur <= (others => '0'); -- Remise à zéro du compteur si reset
    elsif CLK'event and CLK='1' then
    elsif CLK'event and CLK='1' then -- SI la clock change d'état en passant à 1 alors :
        if s_clk_compteur > 1000000 then -- SI la variable qui compte la clock dépasse 1 000 000 alors on reset
            s_clk_compteur <= (others => '0');
        else -- SINON on lui ajoute 1
            s_clk_compteur <= s_clk_compteur + 1 ;
        end if ;
        -- maintenant on crée le signal d'horloge à 100 Hz
        if s_clk_compteur < 500000 then -- SI la variable qui compte la clock est inférieur à 500 000 alors :
            s_clk_lent <= '0' ; -- On attribue 0 à la clock de sortie à 100 Hz
        else -- SINON on lui attribue 1
            s_clk_lent <= '1' ;
        end if ; -- Cette boucle à pour but de créer une deuxième clock à 100 Hz à partir de la clock interne à 100 MHz
    end if ;
end process ; -- Fin du process


process(CLK)   -- On définit la logique qui controle le signal s_reset. Quand le bouton BTNC est pressé le signal passe à '1'
              -- puis repasse à '0' une fois relaché. On ajoute des LED pour visualiser le reset.
begin
    if rising_edge(CLK) then
        if BTNC = '1' then
            s_reset <= '1';
            LED <= "1111111100000000";
        else
            s_reset <= '0';
            LED <= "0000000000000000";
        end if;
    end if;
end process;

process(CLK)  --permet de vérifer si notre compteur est en route ou en pause
begin
    if rising_edge(CLK) then
        -- synchronisation anti-rebond pour BTNU (strat/reprise)
        btnu_sync(0) <= BTNU;
        btnu_sync(1) <= btnu_sync(0);
        btnu_sync(2) <= btnu_sync(1);

        -- synchronisation anti-rebond pour BTND (pause)
        btnd_sync(0) <= BTND;
        btnd_sync(1) <= btnd_sync(0);
        btnd_sync(2) <= btnd_sync(1);

        -- détection du front montant BTNU -> start ou reprise
        if btnu_sync(1) = '1' and btnu_sync(2) = '0' then
            s_running <= '1';
        end if;

        -- détection du front montant BTND -> pause
        if btnd_sync(1) = '1' and btnd_sync(2) = '0' then
            s_running <= '0';
        end if;
    end if;
end process;


process(s_reset,CLK) -- incrémente le signal pour la vitesse de rafraichissement de l'affichage
begin

    if s_reset = '1' then
        s_refresh <= (others => '0');
    elsif rising_edge(CLK) then
        s_refresh <= s_refresh +1;
    end if;
end process;


process(CLK) -- incrémente le 2bit (qui est le sélecteur d'afficheur)sur ce signal ansi la vitesse de raffraichisement de chaque annode est controlée par s_refresh
--qui est bien plus rapide que nos autres clk ce qui evite donc d'observer un aspect de clignotemennt du au changement d'incrementation des annodes une à une
begin
if rising_edge(CLK) then
    if s_refresh = 0 then  
        s_2bit <= s_2bit +1; -- l'affichage passe à l'annode suivante
    end if;
    end if;
end process;



process(s_clk_lent)
begin

if rising_edge(s_clk_lent) then


        if s_reset = '1' then -- si resent= 1 alors il faut réinitialiser toutes les valeurs
            s_clk_dizieme  <= "0000";
            s_clk_centieme <= "0000";
            s_clk_unite    <= "0000";
            s_clk_dizaine  <= "0000";
        elsif s_running = '1' then
            -- ce compteur est actif seulement si pas en pause
            if s_clk_centieme = "1001" then -- methode d'incrémentation en cascade donnée par M.Salvetat, pas la bonne mais on avait ça dans le TP
                s_clk_centieme <= "0000"; -- quand on arrive à 9 on reinitialise le compteur et on incrémente 1 à l'unité superieur
   
                if s_clk_dizieme = "1001" then
                    s_clk_dizieme <= "0000";

                    if s_clk_unite = "1001" then
                        s_clk_unite <= "0000";

                        if s_clk_dizaine = "1001" then
                            s_clk_dizaine <= "0000"; -- revient à 00.00 et reprend le compte
                        else
                            s_clk_dizaine <= s_clk_dizaine + 1; -- si on arrive ici alors unité, dizieme et cententieme sont à 9 mais pas dizaine
                            --alors on ajoute 1 à sa valeur et la boucle recommence avec les unités inferieures remise à 0
                        end if;

                    else
                        s_clk_unite <= s_clk_unite + 1; -- si on arrive ici alors centième, dizieme sont à 9 mais pas unité
                    --alors on ajoute 1 à sa valeur et la boucle recommence avec les unités inferieures remise à 0
                    end if;

                else
                    s_clk_dizieme <= s_clk_dizieme + 1;-- si on arrive ici alors centième est à 9 mais pas dizieme
                    --alors on ajoute 1 à sa valeur et la boucle recommence avec les centiemes remis à 0
                end if;

            else
                s_clk_centieme <= s_clk_centieme + 1;-- si on arrive ici alors centième n'est pas à 9
                    --alors on ajoute 1 à sa valeur et la boucle recommence
            end if;
         end if;
       end if;
end process;

process (s_2bit)  -- affiche sur le bon afficheur les centiemes, dizieme, unite et dizaine
-- pour cela on allume qu'une seule anode à la fois, celle qui correspond à l'élément qu'on veut changer
begin
case s_2bit is
    when "00" =>
            DP <= '1';  
            AN0 <= '0';
            AN1 <= '1';
            AN2 <= '1';
            AN3 <= '1';  
            s_cathode <= s_clk_centieme; -- ici on allume AN0 et s_catode qui définit le valeur à afficher prendra la valeur des centièmes
    when "01" =>
            DP <= '1';
            AN0 <= '1';
            AN1 <= '0';
            AN2 <= '1';
            AN3 <= '1';
            s_cathode <= s_clk_dizieme; -- ici on allume AN1 et s_catode prendra la valeur des diziemes
    when "10" =>
            DP <= '0';
            AN1 <= '1';
            AN2 <= '0';
            AN0 <= '1';
            AN3 <= '1';  
            s_cathode <= s_clk_unite; -- ici on allume AN2 et le point de cette annode et s_catode prendra la valeur des unités
    when others =>
            DP <= '1';
            AN1 <= '1';
            AN2 <= '1';
            AN0 <= '1';
            AN3 <= '0';  
            s_cathode <= s_clk_dizaine;-- ici on allume AN3 et s_catode prendra la valeur des dizaimes

end case;      
end process;


process(s_cathode)--ce process à pour but d'associé chaque chiffre au cathode à allumer pour l'afficher
-- attention une cathode à 0 est une cathode allumer
begin
case s_cathode is
        when "0000" => --0
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '1';
 
        when "0001" => --1
                CA <= '1';
                CB <= '0';
                CC <= '0';
                CD <= '1';
                CE <= '1';
                CF <= '1';
                CG <= '1';

        when "0010" => --2
                CA <= '0';
                CB <= '0';
                CC <= '1';
                CD <= '0';
                CE <= '0';
                CF <= '1';
                CG <= '0';

        when "0011" => --3
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '0';
                CE <= '1';
                CF <= '1';
                CG <= '0';

        when "0100" => --4
                CA <= '1';
                CB <= '0';
                CC <= '0';
                CD <= '1';
                CE <= '1';
                CF <= '0';
                CG <= '0';

        when "0101" =>--5
                CA <= '0';
                CB <= '1';
                CC <= '0';
                CD <= '0';
                CE <= '1';
                CF <= '0';
                CG <= '0';

        when "0110" =>--6
                CA <= '0';
                CB <= '1';
                CC <= '0';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '0';

        when "0111" =>--7
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '1';
                CE <= '1';
                CF <= '1';
                CG <= '1';

        when "1000" =>--8
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '0';

        when "1001" => --9
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '0';
                CE <= '1';
                CF <= '0';
                CG <= '0';
-- ces cas sont inutiles car s_cathode ne peut pas être superieur à 9
--mais on en avait besoin pour le tp précédent et comme on a repris le même code on les à garder
        when "1010" => --A
                CA <= '0';
                CB <= '0';
                CC <= '0';
                CD <= '1';
                CE <= '0';
                CF <= '0';
                CG <= '0';

        when "1011" => --b
                CA <= '1';
                CB <= '1';
                CC <= '0';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '0';

        when "1100" => --C
                CA <= '0';
                CB <= '1';
                CC <= '1';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '1';

        when "1101" => --d
                CA <= '1';
                CB <= '0';
                CC <= '0';
                CD <= '0';
                CE <= '0';
                CF <= '1';
                CG <= '0';  

        when "1110" => --E
                CA <= '0';
                CB <= '1';
                CC <= '1';
                CD <= '0';
                CE <= '0';
                CF <= '0';
                CG <= '0';

        when others =>
                CA <= '0';
                CB <= '1';
                CC <= '1';
                CD <= '1';
                CE <= '0';
                CF <= '0';
                CG <= '0';
                                                   

end case;
end process;
end rtl; -- Fin du code