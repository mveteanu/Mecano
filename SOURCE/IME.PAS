{$d+,l+,s+}
uses Fonts,VGADrv,Graph,Mouse,ViewHTD,OBJ,OBJ2,Events;

type PApplication=^TApplication;
     TApplication=object
                   ev:TEvent;
                   main:pwindow;fe1:p1bwin;
                   b1,b2,b3,b4:pbutton;
                   app:PManual;
                   Constructor Init;
                   Procedure   Run;
                   Destructor  Done;
                  end;

constructor TApplication.Init;
begin
 OpenGraph;
 SetUniformPal;
 Initmouse;SelectStdCursor(arrow);Showmouse;
 hidemouse;
 setfillstyle(solidfill,darkgray);
 bar(0,0,getmaxx,getmaxy);setcolor(blue);
 msettextstyle(4,0,3);
 outtextxy(60,30,'Mecanisme de amplificare cu raport de');
 outtextxy(100,70,'transmitere constant i variabil');
 showmouse;
 new(main,init(0,0,639,479,'VMA soft',1,false));
 new(b1,Init(main,200,180,240,32,'Teorie'));b1^.show;
 new(b2,Init(main,200,230,240,32,'Scheme'));b2^.show;
 new(b3,Init(main,200,280,240,32,'Despre program'));b3^.show;
 new(b4,Init(main,200,330,240,32,'Iesire'));b4^.show;
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


procedure TApplication.Run;
begin
 repeat
  GetEvent(ev);
  if b1^.clicked(ev) then
    begin
      new(app,init(0,0,639,479,2,'ime.htd',1,Arrow,true));
      app^.run;
      dispose(app,done);
    end;
  if b2^.clicked(ev) then
    begin
      new(app,init(0,0,639,479,2,'ime.htd',6,Arrow,true));
      app^.run;
      dispose(app,done);
    end;
  if b3^.clicked(ev) then
    begin
      new(fe1,init(180,120,'O.K.','Mesaj','Acest program este realizat pentru sesiunea de comunic†ri tiin€ifice '+
  'la I.M.E. de c†tre:    < Marian Ve€eanu (E.A. anul I) > i este bazat pe studiul'+
  ' f†cut de Andrei Beloiu i Florin B†d†r†u'));
      fe1^.setattr(LittFont,5,Blue);
      fe1^.run;
      dispose(fe1,done);
    end;
 until b4^.clicked(ev);
end;


var imeapp:PApplication;

begin
 new(IMEApp,Init);
 IMEApp^.Run;
 Dispose(IMEApp,Done);
end.


