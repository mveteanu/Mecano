uses crt;
const filename='ime';                   { numele fisierului fara extensie }

type header=
       record
         copyright:string[32];           { mesajul de copyright }
         pc:byte;                        { numarul de pagini }
         pags:array[1..150] of longint;  { offseturile de la care incep paginile in fisierul compilat }
         cpc:byte;                       { numarul de pagini de la cuprins }
         ic:byte;                        { numarul de imagini }
         imags:array[1..250] of longint; { offseturile de la care incep imaginile in fisierul compilat }
         doctheme:byte;                  { tema documentului. Ex. mec,electric,optica }
         doctitle:string;                { titlul documentului }
       end;

type string2=string[2];string4=string[4];
    fileb=file of byte;
var fis:text;dest,ft:fileb;
    crtcol,crtfnt,crtmar:byte;
    s:string;
    t1,t2,t3:byte;t4,t5,t6,t7:string;
    hdr:header;
    ij,ij1,ij2:word;ib,ib2:byte;
    memotemp:array[1..50] of string;
    cuprins:boolean;

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
assign(dest,filename+'.htd');rewrite(dest);
hdr.copyright:='HiperText Document (c) VMA soft ';
hdr.pags[1]:=0;
hdr.pc:=1;hdr.ic:=0;
hdr.cpc:=0;cuprins:=false;
crtcol:=0;crtfnt:=0;crtmar:=1;
hdr.doctheme:=0;
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

 else if getparam(s,1)='.doctheme' then hdr.doctheme:=vali(getparam(s,2))

 else if getparam(s,1)='.doctitle' then
   begin
    t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
    t2:=byte(length(t6)-1);
    t6:=copy(t6,1,word(t2));
    hdr.doctitle:=t6;
   end

  else if getparam(s,1)='.stringcenter' then
    begin
     t1:=4;
     t6:='';for ij:=2 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6));
     write(dest,t1,t2);writestr(dest,t6);
    end

  else if getparam(s,1)='.link' then
    begin
     t1:=9;t2:=vali(getparam(s,2));write(dest,t1,t2);
     t6:='';for ij:=3 to nrcuvinte(s) do t6:=t6+getparam(s,ij)+' ';
     t2:=byte(length(t6)-1);
     t6:=copy(t6,1,word(t2));
     write(dest,t2);writestr(dest,t6);
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
     if not cuprins
      then
        begin
         inc(hdr.pc);
         hdr.pags[hdr.pc]:=filesize(dest);
        end
      else
        begin
         inc(hdr.cpc);
         hdr.pags[hdr.cpc]:=filesize(dest);
        end;
     t1:=1;t2:=crtcol;write(dest,t1,t2);
     t1:=2;t2:=crtfnt;t3:=crtmar;write(dest,t1,t2,t3);
    end

   else if getparam(s,1)='.cuprins' then begin hdr.cpc:=hdr.pc;cuprins:=true;end

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


