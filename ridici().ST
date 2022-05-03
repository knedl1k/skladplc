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
               //hlavni_barva:=3;
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
