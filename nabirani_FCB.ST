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
   END_IF;
   IF not jednou then
      verti:=verti_ink;
      jednou:=1;
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
         nadzvednuto:1;
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
