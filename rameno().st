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