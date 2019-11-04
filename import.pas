unit import;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, Math;

type

  { TFormImport }

  TFormImport = class(TForm)
    Zuschnitt: TImage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure Display;
    procedure ZuschnittMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Bilder: array of TPicture;
  limit: array of array[0..3] of Integer;
  bild: Integer;
  FormImport: TFormImport;
  faktor: Double;

function MakeComposite(breite,hoehe:Integer):TPicture;

implementation

uses main;

{$R *.lfm}

{ TFormImport }

procedure TFormImport.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  FormMain.Enabled:=true;
  FormMain.UpdateImage;
end;

procedure TFormImport.Display;
var R: array[0..4] of TPoint;
begin
  faktor := 1;
  FormImport.Zuschnitt.Picture.Assign(Bilder[bild]);
  R[0]:= Point(limit[bild][0],limit[bild][1]);
  R[1]:= Point(limit[bild][2],limit[bild][1]);
  R[2]:= Point(limit[bild][2],limit[bild][3]);
  R[3]:= Point(limit[bild][0],limit[bild][3]);
  R[4]:= Point(limit[bild][0],limit[bild][1]);
  FormImport.Zuschnitt.Canvas.Pen.Style := psSolid;
  FormImport.Zuschnitt.Canvas.Pen.Color:=clBlack;
  FormImport.Zuschnitt.Canvas.Pen.Width:=Ceil(faktor*5);
  FormImport.Zuschnitt.Canvas.Polyline(R);
  FormImport.Zuschnitt.Canvas.Pen.Width:=Ceil(faktor*2);
  FormImport.Zuschnitt.Canvas.Pen.Color:=clWhite;
  FormImport.Zuschnitt.Canvas.Polyline(R);
  FormImport.Zuschnitt.Canvas.FillRect(0,0,Bilder[bild].Width,limit[bild][1]);
  FormImport.Zuschnitt.Canvas.FillRect(0,0,limit[bild][0],Bilder[bild].Height);
  FormImport.Zuschnitt.Canvas.FillRect(limit[bild][2],0,
    Bilder[bild].Width,Bilder[bild].Height);
  FormImport.Zuschnitt.Canvas.FillRect(0,limit[bild][3],
    Bilder[bild].Width,Bilder[bild].Height);

  faktor := FormImport.Zuschnitt.Picture.Height/400;
  if FormImport.Zuschnitt.Picture.Width/600> faktor then
    faktor := FormImport.Zuschnitt.Picture.Width/600;
  if faktor<1 then faktor:=1;
  FormImport.Height := Floor(FormImport.Zuschnitt.Picture.Height/faktor);
  FormImport.Width := Floor(FormImport.Zuschnitt.Picture.Width/faktor);
  FormImport.Zuschnitt.Height := Floor(FormImport.Zuschnitt.Picture.Height/faktor);
  FormImport.Zuschnitt.Width := Floor(FormImport.Zuschnitt.Picture.Width/faktor);
  FormImport.Show;
end;

procedure TFormImport.ZuschnittMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var foo: Integer;

begin
  case Button of
      mbLeft:
        if ssShift in Shift then
          begin
            limit[bild][0]:=0;
            limit[bild][1]:=0;
          end
        else
          begin
            limit[bild][0]:=Floor(X*faktor);
            limit[bild][1]:=Floor(Y*faktor);
          end;
      mbRight:
      if ssShift in Shift then
        begin
          limit[bild][2]:=Bilder[bild].Width;
          limit[bild][3]:=Bilder[bild].Height;
        end
      else
        begin
          limit[bild][2]:=Floor(X*faktor);
          limit[bild][3]:=Floor(Y*faktor);
        end;
    end;
  if limit[bild][0]>limit[bild][2] then
    begin
      foo := limit[bild][2];
      limit[bild][2]:=limit[bild][0];
      limit[bild][0]:=foo;
    end;
  if limit[bild][1]>limit[bild][3] then
    begin
      foo := limit[bild][3];
      limit[bild][3]:=limit[bild][1];
      limit[bild][1]:=foo;
    end;

  Display;
end;

function MakeComposite(breite,hoehe:Integer):TPicture;
var i,br,b: Integer;

begin
  Result := TPicture.Create;
  br:=0;
  for i:=0 to High(Bilder) do
    br:=br+Floor((limit[i][2]-limit[i][0])/(limit[i][3]-limit[i][1])*hoehe);
  // jetzt ist br die Gesamtbreite bei der vorgegebenen Höhe
  if br>breite then
    hoehe:=Floor(hoehe/br*488)
  else
    breite:=br;
  Result.Bitmap.Height:=hoehe;
  Result.Bitmap.Width:=breite;
  br:=0;
  for i:=0 to High(Bilder) do
    begin
      b:=Floor((limit[i][2]-limit[i][0])/(limit[i][3]-limit[i][1])*hoehe);
      Result.Bitmap.Canvas.CopyRect(Rect(br,0,br+b-1,hoehe),Bilder[i].Bitmap.Canvas,Rect(limit[i][0],limit[i][1],limit[i][2],limit[i][3]));
      br:=br+b;
    end;
  Result.Bitmap.Width:=br;
end;

end.

