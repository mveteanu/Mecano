uses crt;
const filename='test1';              { numele fisierului fara extensie }

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

type string2=string[2];string4=string[4];
    fileb=file of byte;
var fis:text;dest,ft:fileb;
    crtcol,crtfnt,crtmar:byte;nrproblpepag:byte;
    s:string;
    t1,t2,t3:byte;t4,t5,t6,t7:string;
    hdr:header;
    ij,ij1,ij2:word;ib,ib2:byte;
    memotemp:array[1..50] of string;
    crtprobl:byte;

function vali(x:string):byte;
var t:byte;code:integer;
  Begin
    val(x,t,code);
    if code <> 0 then t:=0;
    vali:=t;
  End;


procedure writestr(var f:fileb;x:string);
var i:word;
begin
 for i:=1 to length(x) do write(f,byte(x[i]));
end;

procedure writeword(var f:fileb;x:string);
var t:word;code:integer;t1,t2:byte;
  Begin
    val(x,t,code);
    if code <> 0 then t:=0;
    t1:=lo(t);t2:=hi(t);
    write(f,t1);write(f,t2);
  End;

procedure writelong(var f:fileb;x:string);
var t:longint;w1,w2:word;code:integer;
    t1,t2,t3,t4:byte;
  Begin
    val(x,t,code);
    if code <> 0 then t:=0;
    w1:=t div 65536;w2:=t mod 65536;
    t1:=lo(w2);t2:=hi(w2);t3:=lo(w1);t4:=hi(w2);
    write(f,t1);write(f,t2);write(f,t3);write(f,t4);
  End;

Function NrCuvinte(x:string):byte;
var f:word;cuv:byte;
begin
 cuv:=1;
 for f:=1 to length(x) do if x[f]=' ' then inc(cuv);
 NrCuvinte:=cuv;
end;

Function GetParam(x:string;c:byte):string;
function pozsp(y:string;v:byte):byte;
var f:word;vt:byte;
begin
 vt:=0;
 for f:=1 to length(y) do if y[f]=' ' then
  begin
   inc(vt);
   if vt=v then begin pozsp:=f;exit;end;
  end;
end;
begin
 if nrcuvinte(x)=1 then begin GetParam:=x;exit;end;
 if c=1 then begin GetParam:=copy(x,1,pos(' ',x)-1);exit;end;
 if c=nrcuvinte(x) then begin GetParam:=copy(x,pozsp(x,c-1)+1,length(x)-pozsp(x,c-1));exit;end;
 GetParam:=copy(x,pozsp(x,c-1)+1,pozsp(x,c)-pozsp(x,c-1)-1);
end;

begin
assign(fis,filename+'.src');reset(fis);
assign(dest,filename+'.htp');rewrite(dest);
hdr.copyright:='HiperText Problems (c) VMA soft ';
hdr.pags[1]:=0;hdr.pc:=1;hdr.ic:=0;
hdr.timelimit:=15;
hdr.nrprobl:=0;
hdr.testtitle:='Test';
hdr.testautor:='Necunoscut';
hdr.testnivel:=1;
hdr.testtheme:=0;
crtcol:=0;crtfnt:=0;crtmar:=1;
while not eof(fis) do
begin
 readln(fis,s);

 if getparam(s,1)='.color' then
    begin
     t1:=1;t2:=vali(getparam(s,2));
     write(dest,t1,t2);
     crtcol:=t2;
    end

  else if getparam(s,1)='.font' then
    begin
     t1:=2;t2:=vali(getparam(s,2));t3:=vali(getparam(s,3));
     write(dest,t1,t2,t3);
     crtfnt:=t2;crtmar:=t3;
    end

 else if getparam(s,1)='.incy' then
    begin
     t1:=5;t2:=vali(getparam(s,2));
     write(dest,t1,t2);
    end

 else if getparam(s,1)='.nrprob' then
    begin         { nr problemelor de pe pagina curenta }
     t1:=20;t2:=vali(getparam(s,2));
     write(dest,t1,t2);
    end

 else if getparam(s,1)='.timelimit' then
     hdr.timelimit:=vali(getparam(s,2))

 else if getparam(s,1)='.testtheme' then
     hdr.testtheme:=vali(getparam(s,2))

 else if getparam(s,1)='.testnivel' then
     hdr.testnivel:=vali(getparam(s,2))

  else if getparam(s,1)='.testtitle' then
    begin
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     hdr.testtitle:=t6;
    end

  else if getparam(s,1)='.testautor' then
    begin
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     hdr.testautor:=t6;
    end

  else if getparam(s,1)='.probl' then
    begin
     t6:='';for ij:=5 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     crtprobl:=vali(getparam(s,2));
     hdr.probl[crtprobl].capteorie:=getparam(s,3);
     hdr.probl[crtprobl].pagteorie:=vali(getparam(s,4));
     hdr.probl[crtprobl].puncte:=vali(getparam(t6,1));
     hdr.probl[crtprobl].variante:=vali(getparam(t6,2));
     hdr.probl[crtprobl].nrcorecte:=nrcuvinte(t6)-2;
     for ij:=1 to nrcuvinte(t6)-2 do
       hdr.probl[crtprobl].corecte[ij]:=vali(getparam(t6,2+ij));
     inc(hdr.nrprobl);
    end

  else if getparam(s,1)='.stringcenter' then
    begin
     t1:=4;
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6));
     write(dest,t1,t2);writestr(dest,t6);
    end

  else if getparam(s,1)='.subscript' then
    begin
     t1:=6;
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     write(dest,t1,t2);writestr(dest,t6);
    end

  else if getparam(s,1)='.vector' then
    begin
     t1:=7;
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     write(dest,t1,t2);writestr(dest,t6);
    end

  else if getparam(s,1)='.superscript' then
    begin
     t1:=8;
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     write(dest,t1,t2);writestr(dest,t6);
    end

   else if getparam(s,1)='.eop' then
    begin
     t1:=255;t2:=13;t3:=10;
     write(dest,t1,t2,t3);
     inc(hdr.pc);
     hdr.pags[hdr.pc]:=filesize(dest);
     t1:=1;t2:=crtcol;write(dest,t1,t2);
     t1:=2;t2:=crtfnt;t3:=crtmar;write(dest,t1,t2,t3);
    end

   else if getparam(s,1)='.image' then
    begin
     t1:=3;
     inc(hdr.ic);
     t2:=byte(hdr.ic);
     t6:=getparam(s,2);
     t4:=getparam(s,3);t5:=getparam(s,4);
     write(dest,t1);
     writeword(dest,t6);writeword(dest,t4);writeword(dest,t5);
     write(dest,t2);
     memotemp[hdr.ic]:=getparam(s,5);
    end

   else if copy(s,length(s)-8,9)='{noteoln}' then writestr(dest,copy(s,1,length(s)-9))

 else writestr(dest,s+#13#10);
end;

if hdr.ic>0 then for ib:=1 to hdr.ic do
 begin
  hdr.imags[ib]:=filesize(dest);
  assign(ft,memotemp[ib]);reset(ft);
  while not eof(ft) do begin read(ft,ib2);write(dest,ib2);end;
  close(ft);
 end;

blockwrite(file(dest),hdr,sizeof(header));
close(fis);close(dest);
end.


