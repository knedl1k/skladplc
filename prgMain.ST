VAR_GLOBAL
cidloAnalog0 at %XW34:int; //dolni cidlo na dopravniku - poznava barevny kod na palete
cidloAnalog1 at %XW46:int; //horni cidlo na dopravniku - poznava barevny kod na palete
cidlo_horiz at %X100.4:bool; //mechanicke cidlo na horizontalni ose prepravniku
cidlo_verti at %X100.7:bool; //mechanicke cidlo na vertikalni ose prepravniku
cidlo_rameno_zad at %X10.7:bool; //mechanicke cidlo v zadni casti ramena prepravniku
cidlo_rameno_pre at %X10.6:bool; //mechanicke cidlo v predni casti ramena prepravniku
doprav_cidlo_zad at %X100.6:bool;  //svetelna brana dopravniku vzadu
doprav_cidlo_pre at %X100.5:bool; // svetelna brana dopravniku vpredu
horiz_ink at %XL106:udint;
verti_ink at %XL116:udint;
ridSlovo at %YW20:uint;
ridSlovo1 at %YW26:uint;
//zk0 at %X101.0:bool; //pro manualni ovladani
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
PolohaVerti: array[0..3] of udint:=[310,2050,4030]; //ulozene vertikalni hodnoty regalu
PolohaHoriz: array[0..3] of udint:=[3629,6462,9300]; //ulozene horizontalni hodnoty regalu
nalozeno at %X101.0:bool;
kalibruj:bool:=0;
casovac:TON;
hlavni_barva:byte:=3;
END_VAR
FUNCTION kalibrace:bool //funkce na kalibraci jednotky
   IF not cidlo_rameno_zad then //zatahne rameno
      ram_vs:=1;
   ELSE
      ram_vs:=0;
      IF not cidlo_horiz then //narazi na horizontalni snimac
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
      END_IF;
      IF not cidlo_verti then //narazi na vertikalni snimac
         verti_na:=1;
      ELSE
         verti_na:=0;
      END_IF;
   END_IF;
   IF cidlo_rameno_zad AND cidlo_horiz AND cidlo_verti then //"vrati", ze probehla funkce
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
FUNCTION_BLOCK barva_FCB //FCB na poznavani barevneho kodovani na boku palet
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
      ELSIF a1<5000 then //bily pruh nahore, MODRA
         h:=1;
      ELSE //zadny bily pruh, BILA
         h:=2;
      END_IF;
   END_IF;
   IF not h=6 AND a0<5000 AND a1<5000 then //ochrana proti falesnym skenum
      color:=h;
      h:=6;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   barva:barva_FCB;
END_VAR
FUNCTION_BLOCK hybej_FCB //funkce pro rozvoz palet
   VAR_INPUT
   END_VAR
   VAR
      vertikalne:bool:=0;
      horizontalne:bool:=0;
      zmacknute:bool:=0;
      plna:bool:=0;
      dole:bool:=0;
      nahore:bool:=0;
   END_VAR
   VAR_OUTPUT
      odvezl:bool:=0;
   END_VAR
   IF not zmacknute then
      IF verti_ink < 3350 AND not nahore then //dojede na vertikalni polohu nakladaci oblasti smerem dolu
         verti_do:=1;
         dole:=1;
      ELSIF verti_ink > 3350 AND not dole then //dojede na vertikalni polohu nakladaci oblasti smerem nahoru
         verti_na:=1;
         nahore:=1;
      ELSE
         verti_do:=0;
         verti_na:=0;
         vertikalne:=1;
      END_IF;
      IF horiz_ink>75 then //dojede na horizontalni polohu nakladaci oblasti
         horiz_vp:=1;
      ELSE
         horiz_vp:=0;
         horizontalne:=1;
      END_IF;
      ram_vy:=not cidlo_rameno_pre AND vertikalne AND horizontalne; //paleta se posadi na dopravnik v nakl. obasti
      doprav_do:=doprav_cidlo_zad AND not doprav_ve AND vertikalne AND horizontalne; //dopravnik posune paletu dovnitr
      barva(a0:=cidloAnalog0,a1:=cidloAnalog1); //sken barvy
      CASE barva.color OF //vypise pozadovanou barvu na displej PLC pres PanelMaker
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
   IF nalozeno then //pokud je zmacklo tlacitko, nastavi pomocnou
      zmacknute:=TRUE;
   END_IF;
   IF zmacknute AND not plna then //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      IF verti_ink<3400 then //rameno sjede trochu dolu
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
   END_IF;
   IF zmacknute AND doprav_cidlo_pre AND not plna then
      doprav_ve:=1;
   ELSIF zmacknute AND not doprav_cidlo_pre AND doprav_cidlo_zad AND not plna then
      doprav_ve:=0;
      plna:=TRUE;
   END_IF;
   IF plna then
      IF verti_ink>3150 then //rameno jiz s paletou vyjede vyse a zatahne se
         verti_na:=1;
      ELSE
         verti_na:=0;
         ram_vs:=not cidlo_rameno_zad;
         odvezl:=cidlo_rameno_zad;
         IF odvezl then //reset vsech pomocnych pro dalsi pouziti
            vertikalne:=0;
            horizontalne:=0;
            zmacknute:=0;
            plna:=0;
            dole:=0;
            nahore:=0;
         END_IF;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   hybej:hybej_FCB;
END_VAR
FUNCTION_BLOCK nabirani_FCB //FCB pro nabrani prazdnych palet a dovezeni je do nakladaci oblasti
   VAR_INPUT
      i:int;
      j:int;
   END_VAR
   VAR
      verti:udint;
      vertikalne:bool:=0;
      jednou:bool:=0;
      horizontalne:bool:=0;
      vysunute:bool:=0;
      nadzvednuto:bool:=0;
      nahoru:bool:=0;
      dolu:bool:=0;
      vpravo:bool:=0;
      vlevo:bool:=0;
   END_VAR
   VAR_OUTPUT
      probehlo:bool:=0;
   END_VAR
   IF verti_ink<PolohaVerti[i] AND not nahoru AND not vertikalne then //posune prepravnik na vertikalni uroven
      verti_do:=1;
      dolu:=1;
   ELSIF verti_ink>PolohaVerti[i] AND not dolu AND not vertikalne then
      verti_na:=1;
      nahoru:=1;
   ELSE
      verti_do:=0;
      verti_na:=0;
      vertikalne:=1;
      IF not jednou then
         verti:=verti_ink;
         jednou:=1;
      END_IF;
   END_IF;
   IF horiz_ink<PolohaHoriz[j] AND not vpravo AND not horizontalne then //posune prepravnik na horizontalni uroven
      horiz_vl:=1;
      vlevo:=1;
   ELSIF horiz_ink>PolohaHoriz[j] AND not vlevo AND not horizontalne then
      horiz_vp:=1;
      vpravo:=1;
   ELSE
      horiz_vl:=0;
      horiz_vp:=0;
      horizontalne:=1;
   END_IF;
   IF horizontalne AND vertikalne AND not cidlo_rameno_pre AND not vysunute then
      ram_vy:=1;
   ELSIF horizontalne AND vertikalne then
      ram_vy:=0;
      vysunute:=1;
      IF verti_ink>(verti-90) then //nadzvedne rameno uz s paletou
         verti_na:=1;
      ELSE
         verti_na:=0;
         nadzvednuto:=1;
      END_IF;
      IF nadzvednuto then
         IF not cidlo_rameno_zad then
            ram_vs:=1;
         ELSE
            ram_vs:=0;
            probehlo:=1; //vrati, ze FCB probehl
            jednou:=0; //reset vsech pomocnych pro dalsi pouziti
            nadzvednuto:=0;
            vysunute:=0;
            nahoru:=0;
            dolu:=0;
            vpravo:=0;
            vlevo:=0;
            vertikalne:=0;
            horizontalne:=0;
         END_IF;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   nabirani:nabirani_FCB;
END_VAR
FUNCTION_BLOCK vraceni_FCB //FCB pro odvoz a odkladani plnych palet na puvodni pozici
   VAR_INPUT
      i:int;
      j:int;
   END_VAR
   VAR
      verti:udint;
      jednou:bool:=0;
      vysunute:bool:=0;
      nahoru:bool:=0;
      dolu:bool:=0;
      vertikalne:bool:=0;
      horizontalne:bool:=0;
   END_VAR
   VAR_OUTPUT
      vraceno:bool:=0;
   END_VAR
   IF verti_ink>PolohaVerti[i] AND not dolu AND not vertikalne then //posune prepravnik na vertikalni uroven, nahoru
      verti_na:=1;
      nahoru:=1;
   ELSIF verti_ink<PolohaVerti[i] AND not nahoru AND not vertikalne then //posune prepravnik na vertikalni uroven, dolu
      verti_do:=1;
      dolu:=1;
   ELSE
      verti_na:=0;
      verti_do:=0;
      vertikalne:=1;
      IF not jednou then
         verti:=verti_ink;
         jednou:=1;
      END_IF;
   END_IF;
   IF horiz_ink<PolohaHoriz[j] AND not horizontalne then //posune prepravnik na horizontalni uroven
      horiz_vl:=1;
   ELSE
      horiz_vl:=0;
      horizontalne:=1;
   END_IF;
   IF not cidlo_rameno_pre AND not vysunute AND horizontalne AND vertikalne then //vysune rameno
      ram_vy:=1;
   ELSIF cidlo_rameno_pre AND not vysunute AND horizontalne AND vertikalne then
      ram_vy:=0;
      vysunute:=1;
   END_IF;
   IF verti_ink<(verti+50) AND vysunute then //vysunute rameno posune dolu, paleta zustane v regalu
      verti_do:=1;
   ELSIF vysunute then
      verti_do:=0;
      IF not cidlo_rameno_zad then
         ram_vs:=1;
      ELSE
         ram_vs:=0; //zasune rameno
         vraceno:=1; //vrati, ze FCB probehl
         jednou:=0; //reset vsech pomocnych pro dalsi pouziti
         vysunute:=0;
         nahoru:=0;
         dolu:=0;
         vertikalne:=0;
         horizontalne:=0;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   vraceni:vraceni_FCB;
END_VAR
VAR_GLOBAL
   horizontal:int:=0;
   vertikal:int:=0;
   blokace:bool:=0;
END_VAR
FUNCTION ridici:bool
   IF not blokace then
      IF not nabirani.probehlo then
         nabirani(i:=vertikal, j:=horizontal);
      ELSE
         IF not hybej.odvezl then
            hybej();
         ELSE
            IF not vraceni.vraceno then
               hlavni_barva:=3;
               vraceni(i:=vertikal, j:=horizontal);
            ELSE
               IF horizontal<2 then //podminka pro posun v polich
                  horizontal:=horizontal+1; //posun v horizontalnim poli
                  nabirani.probehlo:=0;
                  hybej.odvezl:=0;
                  vraceni.vraceno:=0;
               END_IF;
               IF horizontal=2 AND vraceni.vraceno then
                  IF vertikal<2 then
                     vertikal:=vertikal+1;
                     horizontal:=-1;
                  ELSE
                     blokace:=1;
                  END_IF;
               END_IF;
            END_IF;
         END_IF;
      END_IF;
   ELSE
      kalibrace();
   END_IF;
END_FUNCTION
PROGRAM prgMain
IF not kalibruj then //uvodni kalibrace, zajisti, ze po spusteni se system vzdy nejdrive zkalibruje
   kalibruj:=kalibrace();
ELSE
   IF casovac.Q then //seridi nejdrive inkrementalni snimace, po te program dale pokracuje
      ridSlovo:=1; //spusti pocitani inkr. snimacu
      ridSlovo1:=1;
      //manualni();
      ridici(); //hlavni ridici funkce
   ELSE
      ridSlovo:=2; //vyresetuje hodnotu inkr. snimacu
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s); //prodleva pro korektni serizeni snimacu
   END_IF;
END_IF;
END_PROGRAM
