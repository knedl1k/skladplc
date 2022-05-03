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
   END_IF;
   IF not jednou then
      verti:=verti_ink;
      jednou:=1;
   END_IF;
   IF horiz_ink<PolohaHoriz[j] AND not horizontalne then //posune prepravnik na horizontalni uroven
      horiz_vl:=1;
   ELSE
      horiz_vl:=0;
      horizontalne:=1;
   END_IF;
   IF not cidlo_rameno_pre AND not vysunute AND horizontalne AND vertikalne then //vysune rameno
      ram_vy:=1; 
   ELSE
      ram_vy:=0;
      vysunute:=1;
   END_IF;
   IF verti_ink<(verti+200) AND vysunute then //vysunute rameno posune dolu, paleta zustane v regalu
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
      END_IF;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   vraceni:vraceni_FCB;
END_VAR
