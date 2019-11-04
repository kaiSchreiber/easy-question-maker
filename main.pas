unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, StdCtrls, Math, import, LCLType;

type

  { TFormMain }

  TFormMain = class(TForm)
    ButtonLoad: TButton;
    ButtonSave: TButton;
    Bildhoehe: TEdit;
    Composite: TImage;
    Label1: TLabel;
    OpenDialog: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure ButtonLoadClick(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure CompositeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpdateImage;
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  FormMain: TFormMain;

procedure LoadImage(filename:String);

implementation

{$R *.lfm}

{ TFormMain }

procedure TFormMain.ButtonLoadClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    LoadImage(OpenDialog.FileName);
end;

procedure TFormMain.ButtonSaveClick(Sender: TObject);
var Image: TPicture;
begin
  Image:=TPicture.Create;
  Image.Assign(MakeComposite(10000,StrToInt(FormMain.Bildhoehe.Text)));
  if SaveDialog1.Execute then
    Image.SaveToFile(SaveDialog1.Filename+'.jpg');
end;

procedure TFormMain.CompositeMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i,b,br:Integer;
begin
  bild:=-1;
  br:=0;
  for i:=0 to High(Bilder) do
    begin
      b:=Floor((limit[i][2]-limit[i][0])/(limit[i][3]-limit[i][1])*Composite.Height);
      if (X<b+br) and (bild=-1) then
        bild:=i;
      br:=br+b;
    end;
  if bild>-1 then
    if Button=mbLeft then
      begin
        //FormMain.Enabled:=false;
        FormImport.Display;
      end
    else
      begin
        for i:=bild to High(Bilder)-1 do
          begin
            Bilder[i].Assign(Bilder[i+1]);
            limit[i] := limit[i+1];
          end;
        Bilder[High(Bilder)].Free;
        SetLength(Bilder,Length(Bilder)-1);
        SetLength(limit,Length(limit)-1);
        UpdateImage;
      end;
end;

procedure TFormMain.UpdateImage;
var Comp: TPicture;
begin
  Comp:=TPicture.Create;
  Comp:=MakeComposite(488,100);
  Composite.Width:=Comp.Width;
  Composite.Height:=Comp.Height;
  Composite.Picture.Assign(Comp);
end;

procedure TFormMain.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  Accept:=(Source is TImage);
end;

procedure LoadImage(filename:String);
begin
  SetLength(Bilder,Length(Bilder)+1);
  Bilder[High(Bilder)]:=TPicture.Create;
  Bilder[High(Bilder)].LoadFromFile(filename);
  SetLength(limit,Length(limit)+1);
  limit[High(Limit)][0] := 0;
  limit[High(Limit)][1] := 0;
  limit[High(Limit)][2] := Bilder[High(Bilder)].Width;;
  limit[High(Limit)][3] := Bilder[High(Bilder)].Height;
  FormMain.UpdateImage;
end;

procedure TFormMain.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  LoadImage(FileNames[0]);
end;

end.
