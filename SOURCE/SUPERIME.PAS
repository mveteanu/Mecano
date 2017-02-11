{$d+,l+,s+}
uses Fonts,VesaDrv,AppBmp,AppMcga,Graph,Mouse,
     ViewHTD,OBJ,OBJ2,OBJ3,Events,XMS;

type PApplication=^TApplication;
     TApplication=object
                   ev:TEvent;
                   main:pwindow;fe1:p1bwin;
                   b1,b2,b3,b4:pbutton;
                   app:PManual;
                   Constructor Init;
                   Procedure   Run;
                   Function    TestIesire:boolean;
                   Destructor  Done;
                   private
                   han:word;
                   pal:virtualpal;
                  end;

constructor TApplication.Init;
begin
 OpenGraph(VESA_800X600X256);
 SetUniformPal;
 OutTextXY(10,10,'Please wait ...');

 if not XMSInstalled then
   begin
     CloseGraph;
     writeln('Eroare XMS');
     halt(1);
   end;
 AllocExtMem(512,han);
 if XMSError>0 then
   begin
     CloseGraph;
     writeln('Insuficienta memorie extinsa sau sunteti in modul protejat');
     halt(1);
   end;
 LoadBMPinXMS('Tigru2.bmp',han,0,pal);
 VideoScreenOff;RestoreImage2(0,0,han,0,pal);VideoScreenOn;
 FreeExtMem(han);

 Initmouse;SelectStdCursor(arrow);
 SetSenzitivity(trunc(120*0.75),120,2);
 Showmouse;
 new(main,init(0,0,639,479,'VMA soft',1,false));
 new(b1,Init(main,106,500,240,32,'Teorie'));b1^.show;
 new(b2,Init(main,106,550,240,32,'Scheme'));b2^.show;
 new(b3,Init(main,452,500,240,32,'Despre program'));b3^.show;
 new(b4,Init(main,452,550,240,32,'Iesire'));b4^.show;
end;

destructor TApplication.Done;
begin
 dispose(b1,done);
 dispose(b2,done);
 dispose(b3,done);
 dispose(b4,done);
 dispose(main,done);
 CloseGraph;
end;

Function  TApplication.TestIesire:boolean;
var fer1:PBorWindow2B;
    rasp:byte;
begin
 new(fer1,init(240,220,1,'Da','Nu','Mesaj','DoriÄi sÜ pÜrÜsiÄi acest program ?'));
 fer1^.setattr(10,1,blue);
 rasp:=fer1^.run;
 dispose(fer1,done);
 TestIesire:=false;
 If rasp=1 then TestIesire:=true;
end;

procedure TApplication.Run;
var Iesire:boolean;
begin
 Iesire:=false;
 repeat
  GetEvent(ev);
  if b1^.clicked(ev) then
    begin
      new(app,init(80,10,639,479,2,'ime.htd',1,Arrow,true));
      app^.run;
      dispose(app,done);
    end;
  if b2^.clicked(ev) then
    begin
      new(app,init(80,10,639,479,2,'ime.htd',6,Arrow,true));
      app^.run;
      dispose(app,done);
    end;
  if b3^.clicked(ev) then
    begin
      new(fe1,init(240,220,'O.K.','Mesaj','Acest program este realizat pentru sesiunea de comunicÜri ÅtiinÄifice '+
  'la I.M.E. de cÜtre:    < Marian VeÄeanu (E.A. anul I) > Åi este bazat pe studiul'+
  ' fÜcut de Andrei Beloiu Åi Florin BÜdÜrÜu'));
      fe1^.setattr(LittFont,5,Blue);
      fe1^.run;
      dispose(fe1,done);
    end;
  if b4^.clicked(ev) then Iesire:=TestIesire;
 until Iesire;
end;


var imeapp:PApplication;

begin
 new(IMEApp,Init);
 IMEApp^.Run;
 Dispose(IMEApp,Done);
end.


