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
