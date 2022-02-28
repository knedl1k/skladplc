VAR_GLOBAL
cidloAnalog0 at %XW34:int; //dolni cidlo na dopravniku - poznava barevny kod na palete
cidloAnalog1 at %XW46:int; //horni cidlo na dopravniku - poznava barevny kod na palete
cidlo_horiz at %X100.4:bool; //mechanicke cidlo na horizontalni ose prepravniku
cidlo_verti at %X100.7:bool; //mechanicke cidlo na vertikalni ose prepravniku
cidlo_rameno_zad at %X10.7:bool; //mechanicke cidlo v zadni casti ramena prepravniku
cidlo_rameno_pre at %X10.6:bool; //mechanicke cidlo v predni casti ramena prepravniku
doprav_cidlo_zad at %X100.6:bool;  //svetelna brana dopravniku vzadu
doprav_cidlo_pre at %X100.5:bool; // svetelna brana dopravniku vpredu
zk0 at %X101.0:bool; //manualni input
zk1 at %X101.1:bool;
zk2 at %X101.2:bool;
zk3 at %X101.3:bool;
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
cas at %S13.2:bool;
jednou3:bool:=0;
kalibruj:bool:=0;
odvezl:bool:=0;
barva:usint:=4;
displejBarva:string;
casovac,casovac1:TON;
//PolohaVerti: array[0..4] of udint:=[3852,1892,204,3420];
//PolohaHoriz: array[0..4] of udint:=[9403,6462,3629,12];
PolohaVerti: array[0..3] of udint:=[284,1892,3852];
PolohaHoriz: array[0..3] of udint:=[3629,6462,9403];
nalozeno at %X101.0:bool;
END_VAR

FUNCTION kalibrace:bool  //HOTOVO, funkce na kalibraci jednotky
   IF not cidlo_rameno_zad then;
      ram_vs:=1;
      else ram_vs:=0;
      IF not cidlo_horiz then;
         horiz_vp:=1;
         else horiz_vp:=0;
      END_IF;
      IF not cidlo_verti then;
         verti_na:=1;
         else verti_na:=0;
      END_IF;
   END_IF;
   IF cidlo_rameno_zad AND cidlo_horiz AND cidlo_verti then;
      kalibrace:=1;
   END_IF;
END_FUNCTION
FUNCTION manualni:bool     //HOTOVO, funkce na manualni ovladani
   horiz_vp:=zk0 and not zk3;
   verti_na:=zk1 and not zk3;
   ram_vs:=zk2 and not zk3;
   horiz_vl:=zk0 and  zk3;
   verti_do:=zk1 and  zk3;
   ram_vy:=zk2 and  zk3;
END_FUNCTION
FUNCTION_BLOCK color_fb //FCB na poznávání barevného kódování na boku palet
   VAR_INPUT
      a0:int;
      a1:int;
   END_VAR
   VAR
      h:usint:=6; // buffer pro color
   END_VAR
   VAR_OUTPUT
      color:int:=6;
   END_VAR
   IF (h=3 or h=6) and (a0>=5000 or a1>=5000) then; // něco vjelo
      IF a0<5000 then; //bílý pruh dole
         h:=0;
      ELSIF a1<5000 then; //bílý pruh nahoře
         h:=1;
      ELSE //žádný bílý pruh
         h:=2;
      END_IF;
   END_IF;
   IF not h=6 AND a0<5000 AND a1<5000 then;
      //color:=h;
      barva:=h;
      h:=6;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   col:color_fb;
   dd:bool:=0;
   done:bool:=0;
END_VAR

FUNCTION hybej:bool //funkce pro rozvoz palet
   VAR
      verti:udint;
      horiz:udint;
      pomoc:bool:=0;
      pomoc1:bool:=0;
      displayInited:bool:=0;
      pomoc2:bool:=0;
      pomoc3:bool:=0;
      pomoc4:bool:=0;
      jednou:bool:=0;
   END_VAR
   IF not pomoc4 then;
      verti:=verti_ink;
      pomoc4:=1;
   END_IF;
   IF nalozeno then;
      pomoc2:=1;
   END_IF;
   IF not pomoc2 then;
      IF verti < 3350 then; //dojede na vertikalni polohu nakladaci oblasti
         verti_do:=1;
         horiz:=horiz_ink;
      //ELSIF verti > 3250 then;
      // verti_na:=1;
      ELSE
         verti_do:=0;
         //verti_na:=0;
         pomoc1:=1;
      END_IF;
      IF not cidlo_horiz then; //dojede na horizontalni polohu nakladaci oblasti
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
         pomoc:=1;
      END_IF;
      ram_vy:=not cidlo_rameno_pre and pomoc and pomoc1; //pokud je v poloze oblasti, zacne se vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
      //1. část
      doprav_do:=doprav_cidlo_zad AND cidlo_rameno_pre AND not nalozeno;
      col(a0:=cidloAnalog0,a1:=cidloAnalog1); //sken barvy
      CASE col.color OF //vypise pozadovanou barvu na displej PLC - nutne dodelat
         3:
            displejBarva:='bila';
         1:
            displejBarva:='cervena';
         2:
            displejBarva:='modra';
      END_CASE;
   END_IF;
   //3. část
   IF pomoc2 AND not jednou then;
      jednou:=1;
      verti:=verti_ink;
   END_IF;
   IF pomoc2 then; //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      IF verti<3420 then; //vylozi paletu na dopravnik
         verti_do:=1;
      ELSE
        verti_do:=0;
      END_IF;
      IF doprav_cidlo_pre then;
         doprav_ve:=1;
      ELSE
         doprav_ve:=0;
         pomoc3:=1;
      END_IF;
      IF pomoc3 then;
         IF verti<3150 then;
            verti_na:=1;
         ELSE
            verti_na:=0;
            ram_vs:=not cidlo_rameno_zad;
            IF cidlo_rameno_zad then;
               //pomoc2:=0;
               odvezl:=1;
            END_IF;
         END_IF;
      END_IF;
   END_IF;


   //2. část
END_FUNCTION

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
     // jednou3:bool:=0;
     jednou4:bool:=0;
   END_VAR
   VAR_OUTPUT
      probehlo:bool:=0;
   END_VAR
   horiz:=horiz_ink;
   IF verti_ink<PolohaVerti[i] then; //posune prepravnik na vertikalni uroven
      verti_do:=1;
   ELSE
      verti_do:=0;
      IF not jednou then;
         verti:=verti_ink;
         jednou:=1;
      END_IF;
      IF horiz<PolohaHoriz[j] AND not jednou1 then; //posune prepravnik na horizontalni uroven
         horiz_vl:=1;
      //ELSIF horiz>PolohaHoriz[j] AND not jednou1 then;
      //   horiz_vp:=1;
      ELSE
         horiz_vl:=0;
         horiz_vp:=0;
         jednou1:=1;
      END_IF;
   END_IF;
      IF jednou1 AND not cidlo_rameno_pre AND not jednou4 then;
         ram_vy:=1;
      ELSIF jednou1 then;
        ram_vy:=0;
        jednou4:=1;
        IF not jednou2 then;
          verti:=verti_ink;
          jednou2:=1;
        END_IF;
        IF verti_ink>(verti-100) then; //nadzvedne rameno uz s paletou
            verti_na:=1;
            jednou3:=1;
         ELSE
            verti_na:=0;
         END_IF;
         IF jednou3 then;
            IF not cidlo_rameno_zad then;
               ram_vs:=1;
            ELSE
              ram_vs:=0;
              probehlo:=1;
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
      //vrat:bool;
   END_VAR
   VAR
      horiz:udint;
      verti:udint;
   END_VAR
   VAR_OUTPUT
      vraceno:bool:=0;
   END_VAR
   //IF odvezl AND vrat then;
      IF verti_ink>PolohaVerti[i] then; //posune prepravnik na vertikalni uroven
         verti_na:=1;
      ELSE
         verti_na:=0;
         verti:=verti_ink;
         horiz:=horiz_ink;
         IF horiz<PolohaHoriz[j] then; //posune prepravnik na horizontalni uroven
            horiz_vl:=1;
         ELSIF horiz>PolohaHoriz[j] then;
            horiz_vp:=1;
         ELSE
            horiz_vl:=0;
            horiz_vp:=0;
            ram_vy:= not cidlo_rameno_pre; //vysune rameno
            IF verti<verti_ink+50 then; //vysunute rameno posune dolu, paleta zustane v regalu
               verti_do:=1;
            ELSE
               verti_do:=0;
               ram_vs:= not cidlo_rameno_zad; //zasune rameno
            END_IF;
            vraceno:=1; //vrati, ze FCB probehl
         END_IF;
      END_IF;
   //END_IF;
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
   IF nabirani.probehlo AND not blokace then;
      odvezl:=hybej(); //odveze prazdnou paletu do nakladaci oblasti
      IF odvezl AND vraceni.vraceno then; //zmeni polohu v regalu
         IF i<=2 AND j<2 then;
            j:=j+1;
         ELSIF i<2 then;
            i:=i+1;
         ELSE
            blokace:=1;
         END_IF;
      ELSIF odvezl then;
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
horiz_ink:=inkrementalni_horiz;
verti_ink:=inkrementalni_verti;
cidlo0:=cidloAnalog0;
cidlo1:=cidloAnalog1;
IF not kalibruj then; //uvodni kalibrace, zajisti, ze po spusteni se system vzdy nejdrive zkalibruje
   kalibruj:=kalibrace();
ELSE
   IF casovac.Q then; //seridi nejdrive inkrementalni snimace, po te program dale pokracuje
      ridSlovo:=1;
      ridSlovo1:=1;
      manualni();
      ridici();
   ELSE
      ridSlovo:=2;
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s); //prodleva pro korektni serizeni snimacu
   END_IF;
END_IF;
END_PROGRAM
