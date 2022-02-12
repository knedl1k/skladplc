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
      //IF doprav_cidlo_pre and not doprav_cidlo_zad then;
         //casovac2(IN:=0, PT:=T#3s);
         ram_vs:=not cidlo_rameno_zad;
      //END_IF;
   END_IF;
END_FUNCTION