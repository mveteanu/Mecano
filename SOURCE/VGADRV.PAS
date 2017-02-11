{$G+}
unit VGADrv;

interface
uses appmcga,graph,xms;

procedure OpenGraph;
procedure SetUniformPal;
function  GetImageSize(x1,y1,x2,y2:integer):word;
procedure StoreImage(x1,y1,x2,y2:integer;handler:word;ofs:longint);
procedure RestoreImage(x,y:integer;handler:word;ofs:longint);
procedure RestoreImage2(x,y:integer;handler:word;ofs:longint;pal:virtualpal);
procedure QuickStoreImage(x1,y1,x2,y2:integer;handler:word;ofs:longint);
procedure QuickRestoreImage(x,y:integer;handler:word;ofs:longint);

implementation
var dr:integer;

function DetectDriver:Integer; far; begin DetectDriver:=0; end;

procedure VGADriver;external;{$L egavga.obj}
procedure UniformPal;external;{$l uniform.obj}

procedure Opengraph;
var dr,mo:integer;
begin
 dr:=VGA;mo:=VGAHi;
 If RegisterBGIDriver(@vgadriver)<0 then
   Begin
    writeln(' Eroare la inregistrarea fisierului egavga.obj');
    halt(2);
   End;
 InitGraph(dr,mo,'');
end;

procedure SetUniformPal;
var p:pointer;
    f:integer;
begin
for f:=0 to 15 do setpalette(f,f);
p:=@UniformPal;
Asm
   push  ds
   lds   si, p
   mov   dx, 3c8h
   xor   al,al
   out   dx, al
   inc   dx
   mov   cx, 768
   rep   outsb
   pop   ds
end;
end;

function GetImageSize(x1,y1,x2,y2:integer):word;
var l:longint;
begin
 l:=(x2-x1+1);
 l:=l*(y2-y1+1)+8;
 GetImageSize:=(l div 1024)+1;
end;

procedure StoreImage(x1,y1,x2,y2:integer;handler:word;ofs:longint);
var LineBuff:
      record
        lung  : word;
        lat   : word;
        bytes : array[0..1279] of byte;
      end;
    f,g:integer;ofs2:longint;
    lung,lat:longint;
    delta:integer;
    p:pointer;mp:word;
begin
ofs2:=ofs;
if not odd(x2-x1) then delta:=1 else delta:=0;
lung:=x2-x1+1;lat:=y2-y1+1;
writeextmem(lung,4,handler,ofs2);inc(ofs2,4);
writeextmem(lat ,4,handler,ofs2);inc(ofs2,4);
mp:=lung+1024;getmem(p,mp);
for g:=y1 to y2 do
 begin
  {for f:=x1 to x2 do LineBuff[f-x1]:=getpixel(f,g);}
  getimage(x1,g,x2,g,linebuff);
  writeextmem(LineBuff.bytes,lung+delta,handler,ofs2);inc(ofs2,lung);
 end;
freemem(p,mp);
end;

procedure RestoreImage(x,y:integer;handler:word;ofs:longint);
var LineBuff:
     record
       lung   : word;
       lat    : word;
       bytes  : array[0..1279] of byte;
     end;
    f,g:integer;ofs2:longint;
    lung,lat:longint;delta:integer;
begin
 ofs2:=ofs;
 readextmem(4,handler,ofs2,lung);inc(ofs2,4);
 readextmem(4,handler,ofs2,lat);inc(ofs2,4);
 setwritemode(copyput);
 if odd(lung) then delta:=1 else delta:=0;

  LineBuff.lat:=0;LineBuff.lung:=lung-1;
for g:=y to y+lat-1 do
 begin
  readextmem(lung+delta,handler,ofs2,LineBuff.bytes[0]);inc(ofs2,lung);
  {for f:=x to x+lung-1 do putpixel(f,g,LineBuff.bytes[f-x]);}
  PutImage(x,g,LineBuff.Lung,CopyPut);
 end;
end;

procedure RestoreImage2(x,y:integer;handler:word;ofs:longint;pal:virtualpal);
var LineBuff:
     record
       lung   : word;
       lat    : word;
       bytes  : array[0..1279] of byte;
     end;
    g:integer;ofs2:longint;
    lung,lat:longint;delta:integer;
    pal2:virtualpal;
    dist,savedist,dx,dy,dz:longint;
    f:word;a,b:byte;
    palnoua:array[0..255] of byte;
function findclosest(pa1,pa2:virtualpal;chkcol:byte):byte;
var i:byte;
    savecol:byte;
begin
  savedist:=200000;
  for i:=0 to 255 do begin
                dx:=pa2[i,1]-pa1[chkcol,1];
                dy:=pa2[i,2]-pa1[chkcol,2];
                dz:=pa2[i,3]-pa1[chkcol,3];
                dist:=dx*dx+dy*dy+dz*dz;
                if dist < savedist then
                        begin
                          savedist:=dist;
                          savecol:=i;
                        end;
                    end;
  findclosest:=savecol;
end;
begin
 ofs2:=ofs;
 readextmem(4,handler,ofs2,lung);inc(ofs2,4);
 readextmem(4,handler,ofs2,lat);inc(ofs2,4);
 getallpal(pal2);for f:=0 to 255 do palnoua[f]:=findclosest(pal,pal2,f);
 if odd(lung) then delta:=1 else delta:=0;setwritemode(copyput);
 LineBuff.lat:=0;LineBuff.lung:=lung-1;
for g:=y to y+lat-1 do
 begin
  readextmem(lung+delta,handler,ofs2,LineBuff.bytes[0]);inc(ofs2,lung);
  {for f:=0 to lung-1 do putpixel(f+x,g,palnoua[LineBuff[f]]);}
  for f:=0 to lung-1 do LineBuff.bytes[f]:=PalNoua[LineBuff.bytes[f]];
  PutImage(x,g,LineBuff.Lung,CopyPut);
 end;
end;

procedure QuickStoreImage(x1,y1,x2,y2:integer;handler:word;ofs:longint);
var f,g:integer;ofs2:longint;
    lung,lat:longint;
    delta:integer;
    E:POINTER;
    panala,pasul,diferenta,SIZE:WORD;
begin
ofs2:=ofs;
lung:=x2-x1+1;lat:=y2-y1+1;
writeextmem(lung,4,handler,ofs2);inc(ofs2,4);
writeextmem(lat ,4,handler,ofs2);inc(ofs2,4);
panala:=(lung*lat) div 60000;
pasul:=60000 div lung;
diferenta:=lung*lat-panala*60000;


FOR f:=1 TO panala DO
    BEGIN
    SIZE:=60512;
    GETMEM(E,SIZE);
    GETIMAGE(x1,y1+pasul*(f-1),x2,y1+pasul*f,E^);
    writeextmem(e^,size,handler,ofs2);inc(ofs2,size);
    FREEMEM(E,SIZE);
    END;
    SIZE:=diferenta+2048;
    if odd(size) then delta:=1 else delta:=0;
    GETMEM(E,SIZE);
    GETIMAGE(x1,y1+pasul*panala+1,x2,y2,E^);
    writeextmem(e^,size+delta,handler,ofs2);
    FREEMEM(E,SIZE);
end;

procedure QuickRestoreImage(x,y:integer;handler:word;ofs:longint);
var f,g:integer;ofs2:longint;
    lung,lat:longint;delta:integer;
    E:POINTER;
    diferenta,panala,pasul,SIZE:WORD;
begin
 ofs2:=ofs;
 readextmem(4,handler,ofs2,lung);inc(ofs2,4);
 readextmem(4,handler,ofs2,lat);inc(ofs2,4);
 setwritemode(copyput);
 panala:=(lung*lat) div 60000;
 pasul:=60000 div lung;
 diferenta:=lung*lat-panala*60000;
FOR f:=1 TO panala DO
    BEGIN
    SIZE:=60512;
    GETMEM(E,SIZE);
    readextmem(size,handler,ofs2,e^);inc(ofs2,size);
    putIMAGE(x,y+pasul*(f-1),E^,copyput);
    FREEMEM(E,SIZE);
    END;
    SIZE:=diferenta+2048;
    if odd(size) then delta:=1 else delta:=0;
    GETMEM(E,SIZE);
    readextmem(size+delta,handler,ofs2,e^);
    putIMAGE(x,y+pasul*panala+1,E^,copyput);
    FREEMEM(E,SIZE);
end;

end.

