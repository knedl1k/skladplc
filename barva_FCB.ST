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
   IF hybej.odvezl then
      color:=6;
   END_IF;
END_FUNCTION_BLOCK
VAR_GLOBAL
   barva:barva_FCB;
END_VAR
