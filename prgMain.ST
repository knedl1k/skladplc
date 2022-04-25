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
//cas at %S13.2:bool;
kalibruj:bool:=0;
casovac:TON;
PolohaVerti: array[0..3] of udint:=[290,2020,4000];
PolohaHoriz: array[0..3] of udint:=[3629,6462,9300];
nalozeno at %X101.0:bool;
inkrementalni_horiz at %XL106:udint;
inkrementalni_verti at %XL116:udint;
ridSlovo at %YW20:uint;
ridSlovo1 at %YW26:uint;
hlavni_barva:byte:=0;
probehlo_hybej:bool:=0;
probehlo_nabirani:bool:=0;
probehlo_vraceni:bool:=0;
END_VAR
FUNCTION kalibrace:bool //funkce na kalibraci jednotky
   IF not cidlo_rameno_zad then
      ram_vs:=1;
   ELSE
      ram_vs:=0;
      IF not cidlo_horiz then
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
      END_IF;
      IF not cidlo_verti then
         verti_na:=1;
      ELSE
         verti_na:=0;
      END_IF;
   END_IF;
   IF cidlo_rameno_zad AND cidlo_horiz AND cidlo_verti then
      kalibrace:=1;
   END_IF;
END_FUNCTION
(*
FUNCTION manualni:bool //funkce na manualni ovladani skladu
   horiz_vp:=zk0 and not zk3;
   verti_na:=zk1 and not zk3;
   ram_vs:=zk2 and not zk3;
   horiz_vl:=zk0 and  zk3;
   verti_do:=zk1 and  zk3;
   ram_vy:=zk2 and  zk3;
END_FUNCTION
*)
FUNCTION_BLOCK color_FCB //FCB na poznavani barevneho kodovani na boku palet
   VAR_INPUT
      a0:int;
      a1:int;
   END_VAR
   VAR
      h:int:=6; //buffer pro color
   END_VAR
   VAR_OUTPUT
      color:int:=6;
   END_VAR
   IF (h=2 or h=6) and (a0>=5000 or a1>=5000) then //neco vjelo
      IF a0<5000 then //bily pruh dole, CERVENA
         h:=0;
      ELSIF a1<5000 then //bily pruh nahoře, MODRA
         h:=1;
      ELSE //žádný bílý pruh, BILA
         h:=2;
      END_IF;
   END_IF;
   IF not h=6 AND a0<5000 AND a1<5000 then //ochrana proti falesnym skenum
      color:=h;
      h:=6;
   END_IF;
   IF probehlo_hybej then
      color:=6;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   col:color_FCB;
END_VAR
FUNCTION_BLOCK hybej_FCB //funkce pro rozvoz palet
   VAR_INPUT
   END_VAR
   VAR
      pomoc:bool:=0;
      pomoc1:bool:=0;
      pomoc2:bool:=0;
      pomoc3:bool:=0;
      dole:bool:=0;
      nahore:bool:=0;
   END_VAR
   VAR_OUTPUT
      odvezl:bool:=0;
   END_VAR
   IF not pomoc2 then
      IF verti_ink < 3350 AND not nahore then //dojede na vertikalni polohu nakladaci oblasti
         verti_do:=1;
         dole:=1;
      ELSIF verti_ink > 3350 AND not dole then
         verti_na:=1;
         nahore:=1;
      ELSE
         verti_do:=0;
         verti_na:=0;
         pomoc1:=1;
      END_IF;
      IF horiz_ink>75 then //dojede na horizontalni polohu nakladaci oblasti
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
         pomoc:=1;
      END_IF;
      ram_vy:=not cidlo_rameno_pre and pomoc and pomoc1; //pokud je v poloze oblasti, zacne se vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
      doprav_do:=doprav_cidlo_zad AND NOT doprav_ve and pomoc and pomoc1;
      col(a0:=cidloAnalog0,a1:=cidloAnalog1); //sken barvy
      CASE col.color OF //vypise pozadovanou barvu na displej PLC
         0:
            hlavni_barva:=0;
         1:
            hlavni_barva:=1;
         2:
            hlavni_barva:=2;
         6:
            hlavni_barva:=3;
      END_CASE;
   END_IF;
   IF nalozeno then
      pomoc2:=TRUE;
   END_IF;
   IF pomoc2 AND not pomoc3 then //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      IF verti_ink<3400 then //rameno sjede trochu dolu
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
   END_IF;
   IF doprav_cidlo_pre AND pomoc2 and not pomoc3 then
      doprav_ve:=1;
   ELSIF pomoc2 AND NOT doprav_cidlo_pre AND doprav_cidlo_zad and not pomoc3 then
      doprav_ve:=0;
      pomoc3:=TRUE;
   END_IF;
   IF pomoc3 then
      IF verti_ink>3150 then //rameno jiz s paletou vyjede vyse a zatahne se
         verti_na:=1;
      ELSE
         verti_na:=0;
         ram_vs:=not cidlo_rameno_zad;
         odvezl:=cidlo_rameno_zad;
         probehlo_hybej:= not ram_vs;
         IF probehlo_hybej then
            pomoc:=0;
            pomoc1:=0;
            pomoc2:=0;
            pomoc3:=0;
            dole:=0;
            nahore:=0;
         END_IF;
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
      vlevo:bool:=0;
      nahoru:bool:=0;
      dolu:bool:=0;
      vpravo:bool:=0;
   END_VAR
   VAR_OUTPUT
      probehlo:bool:=0;
   END_VAR
   horiz:=horiz_ink;
   IF verti_ink<PolohaVerti[i] AND not nahoru then //posune prepravnik na vertikalni uroven
      verti_do:=1;
      dolu:=1;
   ELSIF verti_ink>PolohaVerti[i] AND not dolu then
      verti_na:=1;
      nahoru:=1;
   ELSE
      verti_do:=0;
      verti_na:=0;
      IF not jednou then
         verti:=verti_ink;
         jednou:=1;
      END_IF;
      IF horiz<PolohaHoriz[j] AND not jednou1 AND not vpravo then //posune prepravnik na horizontalni uroven
         horiz_vl:=1;
         vlevo:=1;
      ELSIF horiz>PolohaHoriz[j] AND not jednou1 AND not vlevo then
         horiz_vp:=1;
         vpravo:=1;
      ELSE
         horiz_vl:=0;
         horiz_vp:=0;
         jednou1:=1;
      END_IF;
   END_IF;
   IF jednou1 AND not cidlo_rameno_pre AND not jednou2 then
      ram_vy:=1;
   ELSIF jednou1 then
      ram_vy:=0;
      jednou2:=1;
      IF verti_ink>(verti-50) then //nadzvedne rameno uz s paletou
         //verti_na:=1;
         jednou3:=1;
      ELSE
         verti_na:=0;
      END_IF;
      IF jednou3 AND not verti_na then
         IF not cidlo_rameno_zad then
            ram_vs:=1;
         ELSE
            ram_vs:=0;
            probehlo:=1;
            probehlo_nabirani:=not ram_vs;
            IF probehlo_nabirani then
                  jednou:=0;
                  jednou1:=0;
                  jednou2:=0;
                  jednou3:=0;
                  vlevo:=0;
                  nahoru:=0;
                  dolu:=0;
                  vpravo:=0;
            END_IF;
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
      verti:udint;
      jednou:bool:=0;
      pomoc:bool:=0;
      pomoc2:bool:=0;
      nahoru:bool:=0;
   END_VAR
   VAR_OUTPUT
      vraceno:bool:=0;
   END_VAR
   IF verti_ink>PolohaVerti[i] AND not pomoc then //posune prepravnik na vertikalni uroven
      verti_na:=1;
      nahoru:=1;
   ELSIF verti_ink<PolohaVerti[i] AND not pomoc AND not nahoru then
      verti_do:=1;
   ELSE
      verti_na:=0;
      verti_do:=0;
      IF not jednou then
         verti:=verti_ink;
         jednou:=1;
      END_IF;
      IF horiz_ink<PolohaHoriz[j] then //posune prepravnik na horizontalni uroven
         horiz_vl:=1;
      ELSIF jednou AND pomoc2 then
         horiz_vl:=0;
         IF not cidlo_rameno_pre AND not pomoc then
            ram_vy:=1; //vysune rameno
         ELSE
            ram_vy:=0;
            pomoc:=1;
         END_IF;
         IF verti_ink<(verti+200) AND pomoc then //vysunute rameno posune dolu, paleta zustane v regalu
            verti_do:=1;
         ELSIF pomoc then
            verti_do:=0;
            IF not cidlo_rameno_zad then
               ram_vs:=1;
            ELSE
               ram_vs:=0;   //zasune rameno
               vraceno:=1;  //vrati, ze FCB probehl
               probehlo_vraceni:=not ram_vs;
               jednou:=0;
               pomoc:=0;
               pomoc2:=0;
               nahoru:=0;
            END_IF;
         END_IF;
      ELSE
         pomoc2:=1;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   vraceni:plne_FCB;
END_VAR
VAR_GLOBAL
   horizontal:int:=0;
   vertikal:int:=0;
   blokace:bool:=0;
END_VAR
FUNCTION ridici:bool
   VAR
      jednou:bool:=0;
   END_VAR
   IF not blokace then
      IF not probehlo_nabirani then
         nabirani(i:=vertikal, j:=horizontal);
      ELSE
         IF not probehlo_hybej then
            hybej();
         ELSE
            IF not probehlo_vraceni then
               vraceni(i:=vertikal, j:=horizontal);
            ELSE
               IF vertikal<=2 AND horizontal<2 then //podminka pro posun v polich
                  horizontal:=horizontal+1; //posun v horizontalnim poli
                  probehlo_nabirani:=0;
                  probehlo_hybej:=0;
                  probehlo_vraceni:=0;
                  nabirani.probehlo:=0;
                  hybej.odvezl:=0;
               ELSIF vertikal<2 AND not jednou then
                  vertikal:=vertikal+1; //posun ve vertikalnim poli
                  jednou:=1;
               ELSE
                  blokace:=1; //zablokuje funkci po naplneni vsech palet
               END_IF;
            END_IF;
         END_IF;
      END_IF;
   ELSE
      kalibrace();
   END_IF;
END_FUNCTION
PROGRAM prgMain
VAR
   cidlo0, cidlo1:INT;
END_VAR
horiz_ink:=inkrementalni_horiz;
verti_ink:=inkrementalni_verti;
cidlo0:=cidloAnalog0;
cidlo1:=cidloAnalog1;
IF not kalibruj then //uvodni kalibrace, zajisti, ze po spusteni se system vzdy nejdrive zkalibruje
   kalibruj:=kalibrace();
ELSE
   IF casovac.Q then //seridi nejdrive inkrementalni snimace, po te program dale pokracuje
      ridSlovo:=1;
      ridSlovo1:=1;
      //manualni();
      ridici();
   ELSE
      ridSlovo:=2;
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s); //prodleva pro korektni serizeni snimacu
   END_IF;
END_IF;
END_PROGRAM
