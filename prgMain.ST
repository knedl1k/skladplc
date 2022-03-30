VAR_GLOBAL
cidloAnalog0 at %XW34:int; //dolni cidlo na dopravniku - poznava barevny kod na palete
cidloAnalog1 at %XW46:int; //horni cidlo na dopravniku - poznava barevny kod na palete
cidlo_horiz at %X100.4:bool; //mechanicke cidlo na horizontalni ose prepravniku
cidlo_verti at %X100.7:bool; //mechanicke cidlo na vertikalni ose prepravniku
cidlo_rameno_zad at %X10.7:bool; //mechanicke cidlo v zadni casti ramena prepravniku
cidlo_rameno_pre at %X10.6:bool; //mechanicke cidlo v predni casti ramena prepravniku
doprav_cidlo_zad at %X100.6:bool;  //svetelna brana dopravniku vzadu
doprav_cidlo_pre at %X100.5:bool; // svetelna brana dopravniku vpredu
//zk0 at %X101.0:bool; //manualni input
//zk1 at %X101.1:bool;
//zk2 at %X101.2:bool;
//zk3 at %X101.3:bool;
doprav_do at %Y32.4:bool; //pohon dopravniku - dovnitr
doprav_ve at %Y32.5:bool; //pohon dopravniku - ven
horiz_vl at %Y32.6:bool; //horizontalni, vlevo:ccw
horiz_vp at %Y32.7:bool; //horizontalni, vpravo:cw
verti_do at %Y33.0:bool; //vertikalni, dolu
verti_na at %Y33.1:bool; //vertikalni, nahoru
ram_vy at %Y33.2:bool; //rameno, vysun
ram_vs at %Y33.3:bool; //rameno, vsun
horiz_ink:udint;
verti_ink:udint;
jednou3:bool:=0;
kalibruj:bool:=0; //pomocna promenna pro to, jestli se sklad po spusteni zkalibroval
displejBarva:string;
casovac,casovac1:TON;
PolohaVerti: array[0..3] of udint:=[290,1892,3852]; //pole pro inkr. hodnoty regalu ve vertikalni ose
PolohaHoriz: array[0..3] of udint:=[3629,6462,9403]; //pole pro inkr. hodnoty regalu v horizontalni ose
nalozeno at %X101.0:bool; //tlacitko, uzivatel macka jako potvrzeni, ze obrok vlozil do palety
inkrementalni_horiz at %XL106:udint;
inkrementalni_verti at %XL116:udint;
ridSlovo at %YW20:uint;
ridSlovo1 at %YW26:uint;
END_VAR
FUNCTION kalibrace:bool  //funkce na uvodni kalibraci jednotky
   IF not cidlo_rameno_zad then //dokud se nesepne zadni cidlo ramena, zatahuj rameno
      ram_vs:=1;
   ELSE 
      ram_vs:=0;
      IF not cidlo_horiz then //dokud se nesepne horizontalni cidlo dopravniku, pohyb vpravo
         horiz_vp:=1;
      ELSE 
         horiz_vp:=0;
      END_IF;
      IF not cidlo_verti then //dokud se nesepne vertikalni cidlo dopravniku, pohyb nahoru
         verti_na:=1;
      ELSE 
         verti_na:=0;
      END_IF;
   END_IF;
   IF cidlo_rameno_zad AND cidlo_horiz AND cidlo_verti then //pokud jsou sepnuty vsechny tri cidla, vysle TRUE
      kalibrace:=1;
   END_IF;
END_FUNCTION
(*
FUNCTION manualni:bool   //funkce na manualni ovladani
   horiz_vp:=zk0 and not zk3; //sepnuti prvniho spinace
   verti_na:=zk1 and not zk3; //sepnuti druheho spinace
   ram_vs:=zk2 and not zk3; //sepnuti tretiho spinace
   horiz_vl:=zk0 and zk3; //sepnuti prvniho a ctvrteho spinace
   verti_do:=zk1 and zk3; //sepnuti druheho a ctvrteho spinace
   ram_vy:=zk2 and zk3; //sepnuti tretiho a ctvrteho spinace
END_FUNCTION
*)
FUNCTION_BLOCK color_FCB //funkcblok pro rozpoznani caroveho kodu na paletach
   VAR_INPUT
      a0:int;
      a1:int;
   END_VAR
   VAR
      h:int:=-1; //buffer pro color
   END_VAR
   VAR_OUTPUT
      color:int:=-1;
   END_VAR
   IF (h=0 OR h=-1) AND (a0>=5000 OR a1>=5000) then //pta se, jestli neco vjelo
      IF a0<5000 then //bily pruh dole, CERVENA
         h:=1;   
      ELSIF a1<5000 then //bily pruh nahoře, MODRA
         h:=2;
      ELSE //zadny bily pruh, BILA
         h:=0;
      END_IF;
   END_IF;
   IF not h=-1 AND a0<5000 AND a1<5000 then //podminka kvuli falesnym skenum
      color:=h;
      h:=-1;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   col:color_FCB;
   dd:bool:=0;
   done:bool:=0;
END_VAR
FUNCTION_BLOCK hybej_FCB //funkcblok pro dovoz prazdnych palet do nakladaci oblasti
   VAR_INPUT
   
   END_VAR
   VAR
      verti:udint;
      horiz:udint;
      pomoc:bool:=0;
      pomoc1:bool:=0;
      pomoc3:bool:=0;
      pomoc2:bool:=0;
      pomoc4:bool:=0;
      jednou:bool:=0;
   END_VAR
   VAR_OUTPUT
      odvezl:bool:=0;
   END_VAR
   IF not pomoc4 then //ulozi uvodni hodnotu vertikalniho inkr.snimace, dale jiz neprepisuje
      verti:=verti_ink;
      pomoc4:=1;
   END_IF;
   IF not pomoc2 then //bezi tak dlouho, dokud uzivatel nezmackne 'nalozeno'
      IF verti_ink < 3350 then //dojede na vertikalni polohu nakladaci oblasti
         verti_do:=1;
         //horiz:=horiz_ink;
      //ELSIF verti > 3250 then
      // verti_na:=1;
      ELSE
         verti_do:=0;
         //verti_na:=0;
         pomoc1:=1;
      END_IF;
      IF horiz_ink>75 then //dojede na horizontalni polohu nakladaci oblasti
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
         pomoc:=1;
      END_IF;
      ram_vy:=not cidlo_rameno_pre AND pomoc AND pomoc1; //pokud je v poloze oblasti, zacne se vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
      doprav_do:=doprav_cidlo_zad AND not doprav_ve AND pomoc AND pomoc1; //posun palety v nakladaci oblasti dovnitr
      col(a0:=cidloAnalog0,a1:=cidloAnalog1); //sken barvy
         CASE col.color OF //podle vraceni z funkcbloku col vyhodnoti pozadovanou barvu
            0:
               displejBarva:='bila';
            1:
               displejBarva:='cervena';
            2:
               displejBarva:='modra';
         END_CASE;
   END_IF;
   IF nalozeno then //pokud uzivatel zmackne tlacitko pro potvrzeni, ze obrok nalozil, nastavi se pomocna promenna pevne na TRUE
      pomoc2:=1;
   END_IF;
   IF pomoc2 AND not jednou then //znovu nastaveni vychozi verti polohy po zmacknuti tlacitka
      verti:=verti_ink;
      jednou:=1;
   END_IF;
   IF pomoc2 AND not pomoc3 then //pokud uzivatel stiskne tlacitko 'nalozeno', tak se paleta vrati zpet na rameno a to se zatahne
      IF verti_ink<3400 then //rameno sjede trochu dolu, aby byl pod paletou
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
   END_IF;
   IF doprav_cidlo_pre AND pomoc2 and not pomoc3 then //posun palety v nakladaci oblasti ven, zpet na rameno dopravniku
      doprav_ve:=1;
   ELSIF pomoc2 AND NOT doprav_cidlo_pre AND doprav_cidlo_zad and not pomoc3 then
      doprav_ve:=0;
      pomoc3:=1;
   END_IF;
   IF pomoc3 then //spusti se, pokud paleta dorazila na venkovni svetelnou branu
      IF verti_ink>3150 then //dopravnik se zvedne a nabere plnou paletu
         verti_na:=1;
      ELSE
         verti_na:=0;
         ram_vs:=not cidlo_rameno_zad; //rameno se zatahne
         odvezl:=cidlo_rameno_zad; //vrati, ze funkcblok probehl
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   hybej:hybej_FCB;
END_VAR
FUNCTION_BLOCK prazdne_FCB //FCB pro nabrani prazdnych palet a dovezeni je do nakladaci oblasti
   VAR_INPUT
      i:int;
      j:int;
   END_VAR
   VAR
      verti:udint;
      horiz:udint;
      jednou:bool:=0;
      jednou1:bool:=0;
      jednou2:bool:=0;
      jednou3:bool:=0;
   END_VAR
   VAR_OUTPUT
      probehlo:bool:=0;
   END_VAR
   horiz:=horiz_ink;
   IF verti_ink<PolohaVerti[i] then //posune prepravnik na vertikalni uroven
      verti_do:=1;
   ELSE
      verti_do:=0;
      IF not jednou then //ulozi vertikalni hodnotu inkr. snimace poprve, dale uz neprepisuje
         verti:=verti_ink;
         jednou:=1;
      END_IF;
      IF horiz<PolohaHoriz[j] AND not jednou1 then //posune prepravnik na horizontalni uroven
         horiz_vl:=1;
      //ELSIF horiz>PolohaHoriz[j] AND not jednou1 then
      //   horiz_vp:=1;
      ELSE
         horiz_vl:=0;
         horiz_vp:=0;
         jednou1:=1;
      END_IF;
   END_IF;
   IF jednou1 AND not cidlo_rameno_pre AND not jednou2 then //jestli se dopravnik dopravil na horiz a verti uroven, zacne vysouvat rameno dokud se nesepne spinac vpredu ramena
      ram_vy:=1;
   ELSIF jednou1 then
      ram_vy:=0;
      jednou2:=1;
      IF verti_ink>(verti-150) then //nadzvedne rameno uz s paletou
         verti_na:=0;
         jednou3:=1;
      ELSE
         verti_na:=0;
      END_IF;
      IF jednou3 then
         IF not cidlo_rameno_zad then //zasouva rameno dokud se nesepne spinac vzadu ramena
            ram_vs:=1;
         ELSE
            ram_vs:=0;
            probehlo:=1; //vrati, ze funkcblok probehl cely
         END_IF;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   nabirani:prazdne_FCB;
END_VAR
FUNCTION_BLOCK plne_FCB //FCB pro odvoz a odkladani plnych palet na puvodni pozici
   VAR_INPUT
      i:int;
      j:int;
   END_VAR
   VAR
      horiz:udint;
      verti:udint;
      jednou:bool:=0;
      pomoc:bool:=0;
      pomoc2:bool:=0;
   END_VAR
   VAR_OUTPUT
      vraceno:bool:=0;
   END_VAR
   IF verti_ink>PolohaVerti[i] then //posune prepravnik na vertikalni uroven
      verti_na:=1;
   ELSE
      verti_na:=0;
      IF not jednou then //ulozi vertikalni hodnotu inkr. snimace poprve, dale uz neprepisuje
         verti:=verti_ink;
         jednou:=1;
      END_IF;
      IF horiz_ink<PolohaHoriz[j] then //posune prepravnik na horizontalni uroven
         horiz_vl:=1;
      //ELSIF horiz_ink>PolohaHoriz[j] then
      //   horiz_vp:=1;
      ELSIF jednou then
         horiz_vl:=0;
         horiz_vp:=0;
         IF not cidlo_rameno_pre then //vysouva rameno tak dlouho, dokud se nesepne predni spinac
            ram_vy:=1; 
         ELSE
            ram_vy:=0;
            pomoc:=1;
         END_IF;
         IF verti_ink<(verti+200) AND pomoc then //vysunute rameno posune dolu, paleta zustane v regalu
            verti_do:=1;
         ELSIF pomoc then
            verti_do:=0;
            IF not cidlo_rameno_zad then //zasouva rameno tak dlouho, dokud se nesepne zadni spinac
               ram_vs:=1;
            ELSE
               ram_vs:=0;   
               vraceno:=1;  //vrati, ze FCB probehl
            END_IF;
         END_IF;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   vraceni:plne_FCB;
END_VAR
FUNCTION ridici:bool //ridici funkce, ktera spousti ve spravny cas dane funkce
   VAR
      i:int:=0;
      j:int:=0;
      //vrat:bool:=0;
      blokace:bool;
   END_VAR
   //blokace:=0;
   IF nabirani.probehlo AND not blokace then //podminka, ktera zacykly cely proces dokud nebudou vsechny palety naplnene, po te blokace:=TRUE
      //hybej(); //odveze prazdnou paletu do nakladaci oblasti
      IF not hybej.odvezl then
         hybej();
      END_IF;
      IF hybej.odvezl AND vraceni.vraceno then //zmeni polohu v regalu
         IF i<=2 AND j<2 then //podminka pro posun v polich
            j:=j+1; //posun nakladace v rovine
            help:=0;
            hybej.odvezl:=0;
            vraceni.vraceno:=0;
         ELSIF i<2 then //jestli dopravnik vybral uz vsechny palety v rovine, posun se horizontalne dolu
            i:=i+1;
            j:=0;
         ELSE
            blokace:=1;
         END_IF;
      ELSIF hybej.odvezl then
         vraceni(i:=i, j:=j); //vrati naplnenou paletu na jeji polohu
      END_IF; 
   ELSE
      nabirani(i:=i, j:=j); //nabere prazdnou paletu na prislusne pozici v regalu
   END_IF;
END_FUNCTION
PROGRAM prgMain
VAR
   cidlo0, cidlo1:INT;
END_VAR
//horiz_ink:=inkrementalni_horiz;
//verti_ink:=inkrementalni_verti;
cidlo0:=cidloAnalog0;
cidlo1:=cidloAnalog1;
IF not kalibruj then //uvodni kalibrace, zajisti, ze po spusteni se system vzdy nejdrive zkalibruje
   kalibruj:=kalibrace();
ELSE
   IF casovac.Q then //seridi nejdrive inkrementalni snimace, po te program dale pokracuje
      ridSlovo:=1; //spusteni pocitani snimacu
      ridSlovo1:=1;
      //manualni();
      ridici(); //volani ridici fce
   ELSE
      ridSlovo:=2; //vyresetovani snimacu
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s); //prodleva pro korektni serizeni snimacu
   END_IF;
END_IF;
END_PROGRAM
