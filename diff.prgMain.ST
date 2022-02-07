29,31c29
< casovac, casovac1:TON;
< 
< 
---
> casovac, casovac1, casovac2:TON;
35c33
< Obsazenost:  array [0..9] of int:=[0,0,0,0,0,0,0,0,0,0]; 
---
> Obsazenost: array [0..9] of int:=[0,0,0,0,0,0,0,0,0,0]; //not completed
39c37
< 
---
> nalozeno:bool:=0;
45c43,51
< FUNCTION kalibrace:bool  //HOTOVO, funkce na kalibraci
---
> FUNCTION manualni:bool     //HOTOVO, funkce pro servisni ovladani jednotky, pozdeji se smaze
>    horiz_vp:=zk0 and not zk3;
>    verti_na:=zk1 and not zk3;
>    ram_vs:=zk2 and not zk3;
>    horiz_vl:=zk0 and  zk3;
>    verti_do:=zk1 and  zk3;
>    ram_vy:=zk2 and  zk3;
> END_FUNCTION
> FUNCTION kalibrace:bool  //HOTOVO, funkce na uvodni kalibraci jednotky
62,70c68,69
< FUNCTION manualni:bool     //HOTOVO, funkce na manualni ovladani pomoci switche
<    horiz_vp:=zk0 and not zk3;
<    verti_na:=zk1 and not zk3;
<    ram_vs:=zk2 and not zk3;
<    horiz_vl:=zk0 and  zk3;
<    verti_do:=zk1 and  zk3;
<    ram_vy:=zk2 and  zk3;
< END_FUNCTION
< FUNCTION umisti:bool       //SKORO, funkce, ktera ma jiz naplnene palety rozmistovat do regalu
---
> 
> FUNCTION umisti:bool
82a82
> 
114,118c114,115
< FUNCTION nakladani:bool    //DODELAT, funkce pro nosič palet. umístí prázdné palety na přepravník
<    VAR
<       nulovani:int:=1;
<    END_VAR
<    IF verti_ink < 3350 then;
---
> FUNCTION nakladani:bool //funkce pro posun dopravniku s obrokem do nakladaci oblasti
>    IF verti_ink < 3350 then; //dojede na vertikalni polohu nakladaci oblasti
124c121
<    IF horiz_ink < 10 then;
---
>    IF horiz_ink < 10 then; //dojede na horizontalni polohu nakladaci oblasti
129c126
<    IF pomoc1 and not casovac1.Q then;
---
>    IF pomoc1 and not casovac1.Q then; //pokud je ve vertikalni poloze oblasti, zacne na 3s vysouvat rameno = paleta se posadi na dopravnik v nakl. obasti
132,139c129,133
<    ELSIF pomoc1 and casovac1.Q then;
<       nulovani:=1;
<       casovac1(IN:=2, PT:=T#3s);
<       casovac1(IN:=1, PT:=T#3s);
<       IF not casovac1.Q then
<          ram_vy:=0;
<          ram_vs:=1;
<       END_IF;
---
>    ELSIF nalozeno and casovac1.Q then; //pokud uzivatel stiskne tlacitko, ze barevny obrok vlozil, tak se paleta vrati zpet na rameno a to se zatahne
>       doprav_
>       ram_vy:=0;
>       casovac2(IN:1, PT:=T#3s);
>       ram_vs:=ram_vs and casovac2.Q
141a136,139
> FUNCTION barva:int //funkce pro určení barvy + vypsání požadované barvy obroku na displej PLC
> //hodnota 31500 pro analogove cidlo znamena, ze na dane pozici je cerna barva = neni bily prouzek
>    IF not doprav_cidlo_pre AND doprav_cidlo_zad then;
>       doprav_do:=1;
143,188c141,142
< FUNCTION_BLOCK color_fb
<    var_input
<       reset:bool;
<       a0:int;
<       a1:int;
<    end_var
<    var
<       b0:int;
<       b1:int;
<       something:bool;
<    end_var
<    var_output
<       color:int;
<    end_var
<   if reset then;
<     b0:=1;
<     b1:=1;
<     color:=-1;
<     something:=0;
<     reset:=0;
<     else
<       if a0<5000 and b0=1 then;
<          b0:=0;
<       elsif a0>=5000 then;
<          b0:=1;
<          something:=1;
<       end_if;
<       if a1<5000 and b1=1 then;
<          b1:=0;
<       elsif a0>=5000 then;
<          b1:=1;
<          something:=1;
<       end_if;
<       if color=-1 and a0<5000 and a1<5000 and something then;
<          color:=b0+2*b1;
<       end_if;
<   end_if;
< END_FUNCTION_BLOCK
< var_global
< col:color_fb;
< dd:bool:=0;
<       done:bool:=0;
< end_var
< FUNCTION barva:int  //SKORO, funkce pro určení barvy + vypsání požadované barvy obroku na displej PLC
<    barva:=-1;
<       IF (cidloAnalog0=31500 AND cidloAnalog0>cidloAnalog1) then; //bila, nahore bila
---
>       barva:=-1;
>       IF (cidloAnalog0=31500 AND cidloAnalog0>cidloAnalog1) then; //bily obrok, nahore bila
190,191c144,145
<         barva:=0;
<       ELSIF (cidloAnalog1=31500 AND cidloAnalog0<cidloAnalog1) then; //cervena, dole bila
---
>         
>       ELSIF (cidloAnalog1=31500 AND cidloAnalog0<cidloAnalog1) then; //cerveny obrok, dole bila
193,194c147,148
<         barva:=1;
<       ELSIF (cidloAnalog0=31500 AND cidloAnalog0=cidloAnalog1) then; //modra, nikde bila
---
>         
>       ELSIF (cidloAnalog0=31500 AND cidloAnalog0=cidloAnalog1) then; //modry obrok, nikde bila
196c150
<         barva:=2;
---
>         
198c152,155
< END_FUNCTION
---
>       
>       
>    END_IF;
>    doprav_do:=doprav_cidlo_zad AND doprav_do;
200,203c157,159
< FUNCTION hybej:bool //funkce pro rozvoz naplněných palet do regálů
<    VAR
<       nakladej:bool:=0;
<    END_VAR
---
>    
> END_FUNCTION
> FUNCTION hybej:bool //funkce, ktera podle definovani barvy z funkce barva() urci na jakou pozici se ma naplnena paleta umistit v regalu 
206,228c162,169
<       //sken barvy - vypis na obrazovku
<       //bar:=barva();
<       if not col.color=-1 then;
<         col(reset:=1);
<       end_if;
<       if col.color=-1 then;
<          col(a0:=cidloAnalog0,a1:=cidloAnalog1);
<          done:=0;
<       else
<          done:=1;
<       end_if;
<       if col.color=1 then;
<          dd:=1;
<       end_if;
<       if not col.color=-1 then;
<          IF (umistit) then;
<             IF not doprav_cidlo_zad then;
<                doprav_ve:=1;
<                doprav_ve:=doprav_cidlo_pre AND doprav_ve;
<                nakladej:=nakladani();
<                IF nakladej then;
<                   umisti();
<                END_IF;
---
>       //sken barvy
>       IF (umistit) then;
>          IF not doprav_cidlo_zad then; //zajisti, ze dopravnik prestane presouvat prazdnou paletu do zadni oblasti jakmile do ni dorazi
>             doprav_do:=1;
>             doprav_ve:=doprav_cidlo_pre AND doprav_ve;
>             nakladej:=nakladani();     
>             IF nakladej then;
>                umisti();
230c171,172
<             IF (col.color = 0) then;
---
>          END_IF;
>          IF (barva() = 0) then;
232c174
<             ELSIF (col.color = 1) then;
---
>          ELSIF (barva() = 1) then;S
234c176
<             ELSIF (col.color = 2) then;
---
>          ELSIF (barva () = 2) then;
236d177
<             END_IF;
238c179
<       end_if;
---
>       END_IF;
241,243c182
<    //IF not doprav_cidlo_zad then;
<    //   doprav_do:=0;
<    //END_IF;
---
>    
245d183
< 
266c204,205
<       hybej();
---
>       //hybej();
>       barva();
268c207
<       ridSlovo:=2;        //serizeni inkrementalnich snimacu
---
>       ridSlovo:=2;
