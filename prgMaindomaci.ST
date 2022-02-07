VAR_GLOBAL
cidloAnalog0 at %XW34:int;
cidloAnalog1 at %XW46:int;
cidlo_horiz at %X100.4:bool;
cidlo_verti at %X100.7:bool;
cidlo_rameno_zadni at %X10.7:bool;
doprav_cidlo_zad at %X100.6:bool;
doprav_cidlo_pre at %X100.5:bool;
zk0 at %X101.0:bool;
zk1 at %X101.1:bool;
zk2 at %X101.2:bool;
zk3 at %X101.3:bool;
doprav_do at %Y32.4:bool;//dopravnik, dovnitr
doprav_ve at %Y32.5:bool;//dopravnik, ven
horiz_vl at %Y32.6:bool;//horizontalni, vlevo:ccw
horiz_vp at %Y32.7:bool;//horizontalni, vpravo:cw
verti_do at %Y33.0:bool;//vertikalni, dolu
verti_na at %Y33.1:bool;//vertikalni, nahoru
ram_vy at %Y33.2:bool;//rameno, vysun
ram_vs at %Y33.3:bool;//rameno, vsun
horiz_ink:udint;
verti_ink:udint;
cas at %S13.2:bool;
kalibruj:bool:=0;
misto:bool:=0;

pomoc, pomoc1:bool;

casovac, casovac1, casovac2:TON;
(*
PolohaVerti: array[0..4] of udint :=[3852,1892,204,3420];
PolohaHoriz: array[0..4] of udint:=[9403,6462,3629,12];
Obsazenost: array [0..9] of int:=[0,0,0,0,0,0,0,0,0,0]; //not completed
*)
bar:int;
umistit:bool:=0;
nalozeno:bool:=0;
pozice0:int:=0;
pozice1:int:=0;
pozice2:int:=0;

END_VAR
FUNCTION manualni:bool     //HOTOVO, funkce pro servisni ovladani jednotky, pozdeji se smaze
   horiz_vp:=zk0 and not zk3;
   verti_na:=zk1 and not zk3;
   ram_vs:=zk2 and not zk3;
   horiz_vl:=zk0 and  zk3;
   verti_do:=zk1 and  zk3;
   ram_vy:=zk2 and  zk3;
END_FUNCTION
FUNCTION kalibrace:bool  //HOTOVO, funkce na uvodni kalibraci jednotky
   IF not cidlo_rameno_zadni then;
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
   IF cidlo_rameno_zadni AND cidlo_horiz AND cidlo_verti then;
      kalibrace:=1;
   END_IF;
END_FUNCTION

FUNCTION umisti:bool
   IF cidloAnalog0<cidloAnalog1 then;
      IF verti_ink < 1892 then;
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
      IF horiz_ink < 6462 then;
         horiz_vl:=1;
      ELSE
         horiz_vl:=0;
      END_IF;
      Obsazenost[pozice1]:=1;

      //
   ELSIF (cidloAnalog0<3600 AND cidloAnalog1<3600) then;
      IF verti_ink < 3852 then;
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
      IF horiz_ink < 9403 then;
         horiz_vl:=1;
      ELSE
         horiz_vl:=0;
      END_IF;
      Obsazenost[pozice0]:=1;

      //
   ELSIF cidloAnalog0>cidloAnalog1  then;  //
      IF verti_ink < 204 then;
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
      IF horiz_ink < 3629 then;
         horiz_vl:=1;
      ELSE
         horiz_vl:=0;
      END_IF;
      Obsazenost[pozice2]:=1;

      //
   END_IF;
END_FUNCTION
FUNCTION nakladani:bool //funkce pro posun dopravniku s obrokem do nakladaci oblasti
   IF verti_ink < 3350 then; //dojede na vertikalni polohu nakladaci oblasti
      verti_do:=1;
   ELSE
      verti_do:=0;
      pomoc1:=1;
   END_IF;
   IF horiz_ink < 10 then; //dojede na horizontalni polohu nakladaci oblasti
      horiz_vl:=1;
   ELSE
      horiz_vl:=0;
   END_IF;
   IF pomoc1 and not casovac1.Q then; //pokud je ve vertikalni poloze oblasti, zacne na 3s vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
      ram_vy:=1;
      casovac1(IN:=1, PT:=T#3s); //misto jednicky promenna - nulovani
   ELSIF nalozeno and casovac1.Q then; //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      doprav_
      ram_vy:=0;
      casovac2(IN:1, PT:=T#3s);
      ram_vs:=ram_vs and casovac2.Q
   END_IF;
END_FUNCTION
FUNCTION barva:int //funkce pro určení barvy + vypsání požadované barvy obroku na displej PLC
//hodnota 31500 pro analogove cidlo znamena, ze na dane pozici je cerna barva = neni bily prouzek
   IF not doprav_cidlo_pre AND doprav_cidlo_zad then;
      doprav_do:=1;

      barva:=-1;
      IF (cidloAnalog0=31500 AND cidloAnalog0>cidloAnalog1) then; //bily obrok, nahore bila
        //vypsat na displej BILA
        
      ELSIF (cidloAnalog1=31500 AND cidloAnalog0<cidloAnalog1) then; //cerveny obrok, dole bila
        //vypsat na displej CERVENA
        
      ELSIF (cidloAnalog0=31500 AND cidloAnalog0=cidloAnalog1) then; //modry obrok, nikde bila
        //vypsat na displej MODRA
        
      END_IF;
      
      
   END_IF;
   doprav_do:=doprav_cidlo_zad AND doprav_do;

   
END_FUNCTION
FUNCTION hybej:bool //funkce, ktera podle definovani barvy z funkce barva() urci na jakou pozici se ma naplnena paleta umistit v regalu 
   IF not doprav_cidlo_pre AND doprav_cidlo_zad then;
      doprav_do:=1;
      //sken barvy
      IF (umistit) then;
         IF not doprav_cidlo_zad then; //zajisti, ze dopravnik prestane presouvat prazdnou paletu do zadni oblasti jakmile do ni dorazi
            doprav_do:=1;
            doprav_ve:=doprav_cidlo_pre AND doprav_ve;
            nakladej:=nakladani();     
            IF nakladej then;
               umisti();
            END_IF;
         END_IF;
         IF (barva() = 0) then;

         ELSIF (barva() = 1) then;S

         ELSIF (barva () = 2) then;

         END_IF;
      END_IF;
      //ceka na potvrzeni vlozeni - stisk tlacitka
   END_IF;
   
   doprav_do:=doprav_cidlo_zad AND doprav_do;
END_FUNCTION

PROGRAM prgMain
VAR
   cidlo0, cidlo1:INT;
   pomoc:bool;
END_VAR
horiz_ink:=inkrementalni_horiz;
verti_ink:=inkrementalni_verti;
pomoc:=0;
cidlo0:=cidloAnalog0;
cidlo1:=cidloAnalog1;
IF not kalibruj then;     //uvodni kalibrace a pak uvolni system pro dalsi pouziti
   kalibruj:=kalibrace(); //funkce na uvodni kalibraci jednotky
ELSE
   IF casovac.Q then;
      ridSlovo:=1;
      ridSlovo1:=1;
      pomoc:=1;
      //manualni();
      //hybej();
      barva();
   ELSE
      ridSlovo:=2;
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s);
   END_IF;
END_IF;
END_PROGRAM
