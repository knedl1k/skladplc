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

pomoc:bool;

casovac, casovac1:TON;



PolohaVerti: array[0..4] of udint :=[3852,1892,204,3420];
PolohaHoriz: array[0..4] of udint:=[9403,6462,3629,12];
Obsazenost:  array [0..9] of int:=[0,0,0,0,0,0,0,0,0,0]; 

bar:int;
//umistit:bool:=0;
nalozeno:bool:=zk0;
pozice0:int:=0;
pozice1:int:=0;
pozice2:int:=0;

END_VAR
FUNCTION kalibrace:bool  //HOTOVO, funkce na kalibraci
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
FUNCTION manualni:bool     //HOTOVO, funkce na manualni ovladani pomoci switche
   horiz_vp:=zk0 and not zk3;
   verti_na:=zk1 and not zk3;
   ram_vs:=zk2 and not zk3;
   horiz_vl:=zk0 and  zk3;
   verti_do:=zk1 and  zk3;
   ram_vy:=zk2 and  zk3;
END_FUNCTION
FUNCTION umisti:bool       //SKORO, funkce, ktera ma jiz naplnene palety rozmistovat do regalu
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
   IF verti_ink < 3250 then; //dojede na vertikalni polohu nakladaci oblasti
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
   IF pomoc1 then; //pokud je ve vertikalni poloze oblasti, zacne na 3s vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
      casovac1(IN:=1, PT:=T#3s);
      ram_vy:=not casovac1.Q;
   END_IF;  
   IF nalozeno and casovac1.Q then; //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      IF verti_ink<3350 then; //vylozi paletu na dopravnik
      	verti_do:=1;
      ELSE
      	verti_do:=0;
      END_IF;
      //doprav_ve:=1;
      casovac2(IN:=1, PT:=T#3s);
      doprav_ve:=not casovac2.Q;
      IF verti_ink<3250 then;
         verti_na:=1;
      ELSE
         verti_na:=0;
      END_IF;
      IF doprav_cidlo_pre and not doprav_cidlo_zad then;
         casovac2(IN:=0, PT:=T#3s);
         ram_vs:=ram_vs and not casovac2.Q;
      END_IF;
   END_IF;
END_FUNCTION

FUNCTION_BLOCK color_fb

   var_input
      a0:int;
      a1:int;
   end_var
   var
			h:int:=-1;	// buffer pro color
   end_var
   var_output
      color:int:=-1;
   end_var

		if (h=0 or h=-1) and (a0>=5000 or a1>=5000) then;
			// něco vjelo
			if a0<5000 then;			//bílý pruh dole
				h:=1;	
			elsif a1<5000 then;		//bílý pruh nahoře
				h:=2;
			else									//žádný bílý pruh
				h:=0;
			end_if;
		end_if;

		if not h=-1 and a0<5000 and a1<5000 then;
			color:=h;
			h:=-1;
		end_if
END_FUNCTION_BLOCK

var_global
col:color_fb;
dd:bool:=0;
      done:bool:=0;
end_var
FUNCTION barva:int  //SKORO, funkce pro určení barvy + vypsání požadované barvy obroku na displej PLC
   barva:=-1;
      IF (cidloAnalog0=31500 AND cidloAnalog0>cidloAnalog1) then; //bila, nahore bila
        //vypsat na displej BILA
        barva:=0;
      ELSIF (cidloAnalog1=31500 AND cidloAnalog0<cidloAnalog1) then; //cervena, dole bila
        //vypsat na displej CERVENA
        barva:=1;
      ELSIF (cidloAnalog0=31500 AND cidloAnalog0=cidloAnalog1) then; //modra, nikde bila
        //vypsat na displej MODRA
        barva:=2;
      END_IF;
END_FUNCTION

FUNCTION hybej:bool //funkce pro rozvoz naplněných palet do regálů
   VAR
      nakladej:bool:=0;
   END_VAR
   IF not doprav_cidlo_pre AND doprav_cidlo_zad then;
      doprav_do:=1;
      //sken barvy - vypis na obrazovku
      //bar:=barva();
      if not col.color=-1 then;
        col(reset:=1);
      end_if;
      if col.color=-1 then;
         col(a0:=cidloAnalog0,a1:=cidloAnalog1);
         done:=0;
      else
         done:=1;
      end_if;
      if col.color=1 then;
         dd:=1;
      end_if;
      if not col.color=-1 then;
         IF (umistit) then;
            IF not doprav_cidlo_zad then;
               doprav_ve:=1;
               doprav_ve:=doprav_cidlo_pre AND doprav_ve;
               nakladej:=nakladani();
               IF nakladej then;
                  umisti();
               END_IF;
            END_IF;
            IF (col.color = 0) then;

            ELSIF (col.color = 1) then;

            ELSIF (col.color = 2) then;

            END_IF;
         END_IF;
      end_if;
      //ceka na potvrzeni vlozeni - stisk tlacitka
   END_IF;
   //IF not doprav_cidlo_zad then;
   //   doprav_do:=0;
   //END_IF;
   doprav_do:=doprav_cidlo_zad AND doprav_do;

END_FUNCTION
FUNCTION prazdne:bool //FUNKCE pro nabrani prazdnych palet a dovezeni je do nakladaci oblasti
   VAR
      i:int:=0;
      j:int:=0;
      blokace:bool:=0;
   END_VAR
   IF not blokace then;
      IF verti_ink<PolohaVerti[i] then;
         verti_do:=1;
      ELSE
         verti_do:=0;
         IF horiz_ink<PolohaHoriz[j] then;
            horiz_vl:=1;
         ELSE
            horiz_vl:=0;
            //udelat funkci, ktera bude jen vysouvat, nalozi, trochu zvedne (+50 na inkrementalni), a zatahne - pouziti tady + hybej()   



            IF i<=2 AND j<=2 then;
               j:=j+1;
            ELSIF i<2 then;
               i:=i+1;
            ELSE
               blokace:=1;
            END_IF;
         END_IF; 
      END_IF;
   END_IF;

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
      hybej();
   ELSE
      ridSlovo:=2;        //serizeni inkrementalnich snimacu
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s);
   END_IF;
END_IF;
END_PROGRAM
