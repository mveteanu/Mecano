{$G+,X+,R-,F-,S-,D-,L-}
unit BasicBMP;
interface
uses AppMcga,Graph;
procedure LoadBMP(x,y:integer;NameCode: string);
function  BMPError: Boolean;

type
BitMapFileHeader=record
                   Types:array[1..2] of char;
                   Size:LongInt;
                   Reserved1:word;
                   Reserved2:word;
                   OffBits:LongInt;
                 end;

BitMapInfoHeader=record
                   Size:LongInt;
                   Width:LongInt;
                   Height:LongInt;
                   Planes:word;
                   BitCount:word;
                   Compression:LongInt;
                   SizeImage:LongInt;
                   XPelsPerMeter:LongInt;
                   YPelsPerMeter:LongInt;
                   ClrUsed:LongInt;
                   ClrImportant:LongInt;
                 end;

RGBQuad = record
                   Blue:byte;
                   Green:byte;
                   Red:byte;
                   Reserved:byte;
          end;

BitMapInfo=record
                   H:BitMapInfoHeader;
                   C:array[0..255] of RGBQuad;
           end;

var  testH: BitMapFileHeader;
     testI: BitMapInfo;

implementation
var
     cRed, cGreen, cBlue: byte;
     cRGB: RGBQuad;
     cReg: byte;
     fBMP: file;
     iBMP, jBMP: LongInt;
     memBMP: byte;
     nrcul:word;
     extra:word;
     readByte: byte;
     LineBuff: array[0..639] of byte;
     Error: Boolean;
     pal,pal2:virtualpal;
     palnoua:array[0..255] of byte;f:byte;
     dist,savedist,dx,dy,dz:longint;

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

procedure LoadBMP;
begin
   Assign(fBMP, NameCode);
   {$I-}Reset(fBMP, 1);{$I+}
   if ioresult<>0 then begin
                        closegraph;
                        writeln(' Eroare de executie !');
                        writeln(' Fisierul '+NameCode+' este inexistent');
                        halt(1);
                      end;
   BlockRead(fBMP, testH, SizeOf(testH));
   BlockRead(fBMP, testI.H, SizeOf(testI.H));
   nrcul:=(testh.offbits-testi.h.size-14) div 4;
   extra:=(testh.size-testI.H.Width*testI.H.Height-testh.offbits) div testI.H.Height;

   if testI.H.BitCount < 4 then
      begin
         Closegraph;
         Error := True;
         Exit
      end
   else if (testI.H.BitCount = 8) and (testI.H.ClrImportant >= 0) then
      begin
         for iBMP := 0 to nrcul-1 do
             begin
                BlockRead(fBMP, testI.C[iBMP], SizeOf(testI.C[iBMP]));
                testI.C[iBMP].Blue := testI.C[iBMP].Blue div 4;
                testI.C[iBMP].Green := testI.C[iBMP].Green div 4;
                testI.C[iBMP].Red := testI.C[iBMP].Red div 4;
             end;
      end;
   for ibmp:=0 to nrcul-1 do begin
                           pal[ibmp,1]:=testi.c[ibmp].red;
                           pal[ibmp,2]:=testi.c[ibmp].green;
                           pal[ibmp,3]:=testi.c[ibmp].blue;
                         end;

   appmcga.getallpal(pal2);for f:=0 to 255 do palnoua[f]:=findclosest(pal,pal2,f);

   for iBMP := 0 to testI.H.Height - 1 do
       begin
          BlockRead(fBMP, LineBuff, testI.H.Width+Extra);
          for jBMP := 0 to testI.H.Width - 1 do
              putpixel(jBMP+x ,(y+testI.H.Height - iBMP - 1),palnoua[LineBuff[jBMP]]);
       end;
   Close(fBMP);
end;

function BMPError;
begin
  BMPError := Error;
  Error := False
end;

end.