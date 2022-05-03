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
      IF verti_ink<3350 AND not nahore then //dojede na vertikalni polohu nakladaci oblasti smerem dolu
         verti_do:=1;
         dole:=1;
      ELSIF verti_ink>3350 AND not dole then //dojede na vertikalni polohu nakladaci oblasti smerem nahoru
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
      barvuj(a0:=cidloAnalog0,a1:=cidloAnalog1); //sken barvy
      CASE barvuj.color OF //vypise pozadovanou barvu na displej PLC pres PanelMaker
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
