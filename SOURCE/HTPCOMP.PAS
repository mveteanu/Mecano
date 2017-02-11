unit HTPComp;

interface
uses graph,obj,events;

type header=
  record
   copyright:string[32];             { mesaj de copyright }
   pc:byte;                          { numarul de pagini din fisier }
   pags:array[1..100] of longint;    { offseturile in fisier de la care incep paginile }
   ic:byte;                          { numarul de imagini .GIF incluse in fisier }
   imags:array[1..250] of longint;   { offseturile in fisier de la care incep imaginile }

   nrprobl:byte;                     { numarul de probleme din test }
   probl:array[1..50] of             { situatia fiecarei probleme }
   record
     capteorie:string[12];           { fisierul cu capitolul de teorie la care se sare daca s-a gresit }
     pagteorie:byte;                 { pagina din capitolul de teorie la care se sare daca s-a gresit }
     puncte:byte;                    { numarul de puncte care se obtine daca se rezolva }
     variante:byte;                  { numarul de variante de raspuns }
     nrcorecte:byte;                 { numarul de rapunsuri corecte }
     corecte:array[1..12]of byte;    { sirul raspunsurilor corecte. Ex. 3,5,7 sunt raspunsurile corecte }
   end;
   testautor:string;                 { autorul testului }
   timelimit:word;                   { numarul de minute in care trebuie rezolvat testul }
   testtheme:byte;
   testnivel:byte;                   { nivelul de dificultate al testului }
   testtitle:string;                 { titlul testului }
  end;


type PFoaie=^TFoaie;
     TFoaie=object
             fx1,fy1,fx2,fy2:integer;frame:pframe;
             Constructor Init(fr:pframe;x1,y1,x2,y2:integer);
             Procedure   Show(f:byte);
             Procedure   ShowSelected(f:byte);
             function    Clicked(ev:TEvent):boolean;
             Destructor  Done;
            end;


type PAllFiles=^TAllFiles;
     TAllFiles=object
                fra:pframe;
                foaie:array[1..100] of pfoaie;
                foaiecrt:byte;
                nf:byte;
                Constructor Init(fr:pframe;numarfoi:byte);
                Procedure   Show;
                Function    Clicked(ev:tevent):byte;
                Destructor  Done;
               end;

type
 PTestCompiler=^TTestCompiler;
 TTestCompiler=object
                hdr:header;
                nrpagini,paginacur:byte;
                foi:pallfiles;
                constructor Init(x,y:integer;nume:string);
                procedure   Run;
                destructor  Done;
                private
                ev:tevent;
                main:pwindow;
                b1,b2,b3,b4,b5,b6,b7,b8:pmsbutton;
                bb1,bb2,bb3,bb4,bb5:pbutton;
                fra:pframe;
                function  Vali(x:string):integer;
                function  OpenSrc:string;
                Function  SetParameters:boolean;
                procedure UpdateDisplay(nrpag:byte);
               end;


implementation
uses fonts,browse2,mouse,kerets;

constructor TFoaie.Init;
begin
 fx1:=x1;fy1:=y1;
 fx2:=x2;fy2:=y2;
 frame:=fr;
end;

function Stri(x:byte):string;
var strt:string;
Begin
  str(x,strt);
  stri:=strt;
End;

procedure TFoaie.Show;
var x1,y1,x2,y2:integer;
begin
 x1:=frame^.frawin^.winx+frame^.frax+fx1;
 y1:=frame^.frawin^.winy+frame^.fray+fy1;
 x2:=frame^.frawin^.winx+frame^.frax+fx2;
 y2:=frame^.frawin^.winy+frame^.fray+fy2;
 hidemouse;
 setfillstyle(solidfill,white);
 setwritemode(copyput);setlinestyle(0,0,0);
 bar(x1,y1,x2,y2);setcolor(black);rectangle(x1,y1,x2,y2);
 msettextstyle(5,0,4);
 settextjustify(centertext,centertext);
 outtextxy((x1+x2)div 2,(y1+y2) div 2,'Pag.'+stri(f));
 showmouse;
end;

procedure TFoaie.ShowSelected;
var x1,y1,x2,y2:integer;
begin
 x1:=frame^.frawin^.winx+frame^.frax+fx1;
 y1:=frame^.frawin^.winy+frame^.fray+fy1;
 x2:=frame^.frawin^.winx+frame^.frax+fx2;
 y2:=frame^.frawin^.winy+frame^.fray+fy2;
 hidemouse;
 setfillstyle(solidfill,white);
 setwritemode(copyput);setlinestyle(0,0,0);
 bar(x1,y1,x2,y2);setcolor(black);rectangle(x1,y1,x2,y2);
 setcolor(blue);setlinestyle(1,0,3);rectangle(x1+3,y1+3,x2-3,y2-3);
 msettextstyle(5,0,4);
 settextjustify(centertext,centertext);
 outtextxy((x1+x2)div 2,(y1+y2) div 2,'Pag.'+stri(f));
 setlinestyle(0,0,0);
 showmouse;
end;

Function  TFoaie.Clicked;
var x1,y1,x2,y2:integer;
begin
 Clicked:=false;
 x1:=frame^.frawin^.winx+frame^.frax+fx1;
 y1:=frame^.frawin^.winy+frame^.fray+fy1;
 x2:=frame^.frawin^.winx+frame^.frax+fx2;
 y2:=frame^.frawin^.winy+frame^.fray+fy2;
 if (ev.tip=evmouse)and(ev.but=1) then
 if (ev.mx>x1)and(ev.mx<x2)and(ev.my>y1)and(ev.my<y2)then
  begin
   while leftpressed and(mousex>x1)and(mousex<x2)and(mousey>y1)and(mousey<y2) do;
   if (mousex>x1)and(mousex<x2)and(mousey>y1)and(mousey<y2) then Clicked:=true;
  end;
end;

destructor TFoaie.done;
begin
end;

Constructor TAllFiles.Init;
begin
 NF:=NumarFoi;if NF<1 then NF:=1;
 Foaiecrt:=1;
 Fra:=Fr;
end;

Function TAllFiles.Clicked;
var f:byte;
begin
  Clicked:=0;
  for f:=1 to nf do
   if foaie[f]^.clicked(ev) then
      begin
       Foaie[FoaieCrt]^.Show(foaiecrt);
       FoaieCrt:=f;Foaie[FoaieCrt]^.ShowSelected(foaiecrt);
       Clicked:=FoaieCrt;
      end;
end;

procedure TAllFiles.Show;
var f,g:integer;
    hf,lf,sf:byte;delta:real;
    lungpag,latpag:integer;
    nrfoilung,nrfoilat:byte;
    nflat,nflung,nflungrest:byte;
    filecount:integer;
begin
 lungpag:=fra^.fralung-2;latpag:=fra^.fralat-2;
 delta:=1.001;
 hf:=110;lf:=90;sf:=10;
 repeat
  delta:=delta-0.001;
  hf:=trunc(hf*delta);lf:=trunc(lf*delta);sf:=trunc(sf*delta);
  nrfoilung:=((lungpag-sf) div (lf+sf));
  nrfoilat:=((latpag-sf) div (hf+sf));
 until nrfoilung*nrfoilat>=nf;

 nflat:=1;nflung:=1;
 if nf<=nrfoilung
   then begin nflat:=1;nflung:=nf;nflungrest:=0;end
   else begin nflung:=nrfoilung;nflat:=nf div nflung;nflungrest:=nf-nflung*nflat;end;

 filecount:=1;

 for g:=1 to nflat do
 for f:=1 to nflung do
  begin
   new(foaie[filecount],init(fra,sf+(f-1)*(lf+sf),sf+(g-1)*(hf+sf),sf+lf+(f-1)*(lf+sf),sf+hf+(g-1)*(hf+sf)));
   foaie[filecount]^.show(pred(g)*nflung+f);
   inc(filecount);
  end;
 g:=nflat+1;
 for f:=1 to nflungrest do
  begin
   new(foaie[filecount],init(fra,sf+(f-1)*(lf+sf),sf+(g-1)*(hf+sf),sf+lf+(f-1)*(lf+sf),sf+hf+(g-1)*(hf+sf)));
   foaie[filecount]^.show(pred(g)*nflung+f);
   inc(filecount);
  end;
 Foaie[FoaieCrt]^.ShowSelected(1);
end;

Destructor TAllFiles.Done;
var f:integer;
begin
 for f:=1 to nf do dispose(foaie[f],done);
end;


function TTestCompiler.Vali(x:string):integer;
var t:integer;code:integer;
  Begin
    val(x,t,code);
    if code <> 0 then t:=-1;
    vali:=t;
  End;

procedure TTestCompiler.UpDateDisplay(nrpag:byte);
begin
 if nrpagini<>0 then foi^.done;
 nrpagini:=nrpag;
 new(foi,init(fra,nrpagini));
 fra^.show;
 foi^.Show;
end;

Function TTestCompiler.OpenSrc;
var brow:PBrowse;s:string;
begin
 new(brow,init(100,100,3,'Deschide fisier','*.src',$01+$20));
 s:=brow^.run;
 brow^.done;
 OpenSrc:=s;
end;

Function TTestCompiler.SetParameters;
var fer:pwindow;
    t1,t2,t3:ptext;
    i1,i2,i3:pinput;
    bu1,bu2:pmsbutton;
    a:array[1..5] of pchkbox;
    c:array[1..7] of pchkbox;
    f,g:byte;
    iesire,okpressed:boolean;
begin
 new(fer,initxms(140,30,300,500,'',5,true));fer^.show;
 new(t1,init(fer,20,30,80,20,6,'Titlu   :'));
 new(t2,init(fer,20,60,80,20,6,'Autor   :'));
 new(t3,init(fer,20,90,80,20,6,'Timp    :'));
 t1^.setjustify(lefttext,centertext,false);t1^.show;
 t2^.setjustify(lefttext,centertext,false);t2^.show;
 t3^.setjustify(lefttext,centertext,false);t3^.show;
 new(i1,init(fer,110,30,170,1,0));
 new(i2,init(fer,110,60,170,1,0));
 new(i3,init(fer,110,90,170,1,0));
 if nrpagini<> 0 then
   begin
     i1^.settext(hdr.testtitle);
     i2^.settext(hdr.testautor);
     i3^.settext(stri(hdr.timelimit));
   end;
 i1^.show;i2^.show;i3^.show;
 new(a[1],init(fer,20,140,1,true, 'Studiul fenomenelor mecanice  '));a[1]^.show;
 new(a[2],init(fer,20,160,1,false,'Studiul fenomenelor termice   '));a[2]^.show;
 new(a[3],init(fer,20,180,1,false,'Studiul fenomenelor electrice '));a[3]^.show;
 new(a[4],init(fer,20,200,1,false,'Studiul fenomenelor optice    '));a[4]^.show;
 new(a[5],init(fer,20,220,1,false,'Studiul fenomenelor atomice   '));a[5]^.show;
 new(c[1],init(fer,20,270,1,false,'Test de nivelul 1             '));c[1]^.show;
 new(c[2],init(fer,20,290,1,true, 'Test de nivelul 2             '));c[2]^.show;
 new(c[3],init(fer,20,310,1,false,'Test de nivelul 3             '));c[3]^.show;
 new(c[4],init(fer,20,330,1,false,'Test de nivelul 4             '));c[4]^.show;
 new(c[5],init(fer,20,350,1,false,'Test de nivelul 5             '));c[5]^.show;
 new(c[6],init(fer,20,370,1,false,'Test de nivelul 6             '));c[6]^.show;
 new(c[7],init(fer,20,390,1,false,'Test de nivelul 7             '));c[7]^.show;
 new(bu1,init(fer,40,440,80,20,'O.K.'));bu1^.show;
 new(bu2,init(fer,180,440,80,20,'Cancel'));bu2^.show;
 iesire:=false;okpressed:=false;
 repeat
  fer^.move;
  getevent(ev);
  if i1^.clicked(ev) then i1^.edit;
  if i2^.clicked(ev) then i2^.edit;
  if i3^.clicked(ev) then i3^.edit;
  for f:=1 to 5 do
   if a[f]^.clicked(ev)and (a[f]^.chkchecked=false) then
     begin
       for g:=1 to 5 do begin a[g]^.chkchecked:=true;a[g]^.toggle;end;
       a[f]^.toggle;
     end;
  for f:=1 to 7 do
   if c[f]^.clicked(ev)and (c[f]^.chkchecked=false) then
     begin
       for g:=1 to 7 do begin c[g]^.chkchecked:=true;c[g]^.toggle;end;
       c[f]^.toggle;
     end;
  if fer^.clicked(ev) then iesire:=true;
  if bu1^.clicked(ev) then begin iesire:=true;okpressed:=true;end;
  if bu2^.clicked(ev) then iesire:=true;
 until iesire;

 if okpressed then
   begin
    if i1^.inpmesage='' then hdr.testtitle:='Test' else hdr.testtitle:=i1^.inpmesage;
    if i2^.inpmesage='' then hdr.testautor:='Necunoscut' else hdr.testautor:=i2^.inpmesage;
    if vali(i3^.inpmesage)=-1 then hdr.timelimit:=5 else hdr.timelimit:=vali(i3^.inpmesage);
    for f:=1 to 5 do if a[f]^.chkchecked then hdr.testtheme:=f;
    for f:=1 to 7 do if c[f]^.chkchecked then hdr.testnivel:=f;
   end;

 dispose(fer,done);
 dispose(t1,done);
 dispose(t2,done);
 dispose(t3,done);
 dispose(i1,done);
 dispose(i2,done);
 dispose(i3,done);
 for f:=1 to 5 do dispose(a[f],done);
 for f:=1 to 7 do dispose(c[f],done);
 dispose(bu1,done);
 dispose(bu2,done);

 SetParameters:=okpressed;
end;

Constructor TTestCompiler.Init;
begin
 new(main,initxms(x,y,776,500,nume,4,true));main^.show;
 new(fra,init(main,8,27,570,416,5,lightgray,'PagePreview'));fra^.show;
 new(b1,init(main,25,460,89,20,'Nou'));
 new(b2,init(main,115,460,89,20,'Deschide'));
 new(b3,init(main,205,460,89,20,'Salveaza'));
 new(b8,init(main,295,460,89,20,'Titluri'));
 new(b4,init(main,385,460,89,20,'Adauga pag'));
 new(b5,init(main,475,460,89,20,'Sterge pag'));
 new(b6,init(main,565,460,89,20,'Ruleaza'));
 new(b7,init(main,655,460,89,20,'Iesire'));

 new(bb1,init(main,596,290,165,20,'Seteaza problema'));
 new(bb2,init(main,596,320,165,20,'Adauga problema'));
 new(bb3,init(main,596,350,165,20,'Sterge problema'));
 new(bb4,init(main,596,380,165,20,'Editeaza text pag'));
 new(bb5,init(main,596,410,165,20,'Editeaza test'));

 hidemouse;
 setcolor(white);line(main^.winx+7,main^.winy+445,main^.winx+643+126,main^.winy+445);
 line(main^.winx+455+126,main^.winy+25,main^.winx+455+126,main^.winy+444);
 setcolor(darkgray);line(main^.winx+7,main^.winy+450,main^.winx+643+126,main^.winy+450);
 line(main^.winx+460+126,main^.winy+26,main^.winx+460+126,main^.winy+445);
 setcolor(lightgray);line(main^.winx+6,main^.winy+445,main^.winx+6,main^.winy+449);
 line(main^.winx+644+126,main^.winy+446,main^.winx+644+126,main^.winy+449);
 line(main^.winx+456+126,main^.winy+25,main^.winx+459+126,main^.winy+25);
 line(main^.winx+456+126,main^.winy+445,main^.winx+459+126,main^.winy+445);
 showmouse;
 b3^.butenabled:=false;
 b4^.butenabled:=false;
 b5^.butenabled:=false;
 b6^.butenabled:=false;
 b8^.butenabled:=false;
 b1^.show;b2^.show;b3^.show;b8^.show;
 b4^.show;b5^.show;b6^.show;b7^.show;
 bb1^.butenabled:=false;bb2^.butenabled:=false;
 bb3^.butenabled:=false;bb4^.butenabled:=false;
 bb5^.butenabled:=false;
 bb1^.show;bb2^.show;bb3^.show;bb4^.show;bb5^.show;
 nrpagini:=0;paginacur:=0;
end;

Procedure TTestCompiler.Run;
begin
 repeat
  getevent(ev);
  if b1^.clicked(ev) then
       begin
        if SetParameters then  {}
          begin
            UpdateDisplay(1);
            b3^.enable;b4^.enable;b5^.disable;b6^.enable;b8^.enable;
            bb1^.enable;bb2^.enable;bb3^.enable;bb4^.enable;bb5^.enable;
          end;
       end;
  if b2^.clicked(ev) then OpenSrc;
  b3^.clicked(ev);
  if b4^.clicked(ev)and(nrpagini<100) then
       begin
        b5^.enable;
        inc(nrpagini);
        UpdateDisplay(nrpagini);
       end;
  if b5^.clicked(ev) then
       begin
        if nrpagini=2 then b5^.disable;
        dec(nrpagini);
        UpdateDisplay(nrpagini);
       end;
  b6^.clicked(ev);
  if b8^.clicked(ev) then SetParameters;
  if nrpagini<>0 then foi^.clicked(ev);
  bb1^.clicked(ev);
  bb2^.clicked(ev);
  bb3^.clicked(ev);
  bb4^.clicked(ev);
  bb5^.clicked(ev);
 until main^.clicked(ev) or b7^.clicked(ev);;
end;

Destructor TTestCompiler.Done;
begin
 dispose(main,done);
 dispose(fra,done);
 dispose(b1,done);
 dispose(b2,done);
 dispose(b3,done);
 dispose(b4,done);
 dispose(b5,done);
 dispose(b6,done);
 dispose(b7,done);
 dispose(b8,done);
 dispose(bb1,done);
 dispose(bb2,done);
 dispose(bb3,done);
 dispose(bb4,done);
 dispose(bb5,done);
 if nrpagini<>0 then dispose(foi,done);
end;

end.

