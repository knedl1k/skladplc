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
kalibruj:bool:=0;
misto:bool:=0;


casovac, casovac1:TON;



PolohaVerti: array[0..4] of udint:=[3852,1892,204,3420];
PolohaHoriz: array[0..4] of udint:=[9403,6462,3629,12];
Obsazenost:  array[0..9] of int:=[0,0,0,0,0,0,0,0,0,0]; 

bar:int;
//umistit:bool:=0;
nalozeno:bool:=zk0;
pozice0:int:=0;
pozice1:int:=0;
pozice2:int:=0;

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
FUNCTION nakladani:bool //funkce pro posun jiz nalozene prazdne palety do dopravnikove oblasti + odebrani naplnene palety
   VAR
      verti:udint:=verti_ink;
      horiz:udint:=horiz_ink;
      pomoc:bool:=0;
      pomoc1:bool:=0;
   END_VAR
   IF verti < 3250 then; //dojede na vertikalni polohu nakladaci oblasti
      verti_do:=1;
   ELSIF verti > 3250 then;
      verti_na:=1;
   ELSE
      verti_do:=0;
      verti_na:=0;
      pomoc1:=1;
   END_IF;
   IF horiz < 10 then; //dojede na horizontalni polohu nakladaci oblasti
      horiz_vl:=1;
   ELSIF horiz > 10 then;
      horiz_vp:=1;
   ELSE
      horiz_vl:=0;
      horiz_vp:=0;
      pomoc:=1;
   END_IF; 
   ram_vy:=not cidlo_rameno_pre and pomoc and pomoc1; //pokud je v poloze oblasti, zacne se vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
   IF nalozeno then; //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
      IF verti_ink<3150 then; //vylozi paletu na dopravnik
      	verti_na:=1;
      ELSE
      	verti_na:=0;
      END_IF;
      //doprav_ve:=1;
      //casovac2(IN:=1, PT:=T#3s);
      //doprav_ve:=not casovac2.Q;
      doprav_ve:=not cidlo_rameno_zad;
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
   doprav_do:=doprav_cidlo_zad AND doprav_do;

END_FUNCTION
(*
FUNCTION_BLOCK rameno:bool
  var_input
      zvedni:bool;
      poloz:bool;
      verti_ink:udint;
   end_var
   var
      verti:udint:=verti_ink;
      //pomoc:bool:=0;
   end_var
   var_output
      hotovo:bool;
   end_var 
   IF zvedni AND not hotovo then;
      IF verti<verti_ink+50 then;
         verti_na:=1;
      ELSE
         verti_na:=0;
      END_IF;
      ram_vs:= not cidlo_rameno_zad;
      IF cidlo_rameno_zad then;
         pomoc:=1;
         hotovo:=1;
      END_IF;
   END_IF;
   IF poloz AND not hotovo then;
      IF verti<verti_ink-50 then;
         verti_do:=1;
      ELSE
         verti_do:=0;
      END_IF;
      ram_vs:= not cidlo_rameno_zad;
      IF cidlo_rameno_zad then;
         pomoc:=1;
         hotovo:=1;
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
*)
FUNCTION_BLOCK prazdne_FCB:bool //FCB pro nabrani prazdnych palet a dovezeni je do nakladaci oblasti
   VAR_INPUT
      i:int;
      j:int;
   END_VAR
   VAR 
   (*
      i:int:=0;
      j:int:=0;
      blokace:bool:=0;
   *)
      verti:udint;
   END_VAR
   VAR_OUTPUT
      probehlo:bool:=0;
   END_VAR
   //IF not blokace then;
      IF verti_ink<PolohaVerti[i] then; //posune prepravnik na vertikalni uroven
         verti_do:=1;
      ELSE
         verti_do:=0;
         verti:=verti_ink;
         IF horiz_ink<PolohaHoriz[j] then; //posune prepravnik na horizontalni uroven
            horiz_vl:=1;
         ELSE
            horiz_vl:=0;
            ram_vy:= not cidlo_rameno_pre; //vysune rameno
            IF verti<verti_ink+50 then; //nadzvedne rameno uz s paletou
               verti_na:=1;
            ELSE
               verti_na:=0;
               ram_vs:= not cidlo_rameno_zad; //zasune rameno
            END_IF;
            probehlo:=1;
         END_IF; 
      END_IF;
   //END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   nabirani:=prazdne_FCB;
END_VAR
FUNCTION dovez_prazdne:bool
   VAR
      i:int:=0;
      j:int:=0;
      probehlo:bool=0;
      blokace:bool=0;
   END_VAR
   IF probehlo AND not blokace then;
      nakladani();
      IF i<=2 AND j<=2 then;
         j:=j+1;
      ELSIF i<2 then;
         i:=i+1;
      ELSE
         blokace:=1;
      END_IF; 
   ELSE
      nabirani(i:=i, j:=j, )
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
IF not kalibruj then;     //uvodni kalibrace, zajisti, ze po spusteni se system vzdy nejdrive zkalibruje
   kalibruj:=kalibrace(); 
ELSE
   IF casovac.Q then; //seridi nejdrive inkrementalni snimace, po te program dale pokracuje
      ridSlovo:=1;
      ridSlovo1:=1;
      pomoc:=1;
      //manualni();
      hybej();
   ELSE
      ridSlovo:=2;        
      ridSlovo1:=2;
      casovac(IN:=1, PT:=T#1s); //prodleva pro korektni serizeni snimacu
   END_IF;
END_IF;
END_PROGRAM
