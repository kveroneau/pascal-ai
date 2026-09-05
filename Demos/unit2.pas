unit unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, RTTICtrls,
  AIChat;

type

  { TForm1 }

  TForm1 = class(TForm)
    AIChat1: TAIChat;
    Memo1: TMemo;
    TIEdit1: TTIEdit;
    TIEdit2: TTIEdit;
    procedure AIChat1Chat(Sender: TObject; const AResponse: string;
      Success: Boolean);
    procedure FormResize(Sender: TObject);
    procedure Memo1DblClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Memo1DblClick(Sender: TObject);
begin
  if AIChat1.Sending then
    Exit;
  if (TIEdit1.Text = '') or (TIEdit2.Text = '') then
    Exit;
  AIChat1.Active:=True;
  Sleep(1000);
  AIChat1.SendMessage('Can you please summarize the following text for me: '+Memo1.Text);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  Memo1.Width:=ClientWidth;
  Memo1.Height:=ClientHeight-TIEdit1.Height;
  TIEdit1.Width:=ClientWidth div 2;
  TIEdit2.Left:=TIEdit1.Width;
  TIEdit2.Width:=TIEdit1.Width;
end;

procedure TForm1.AIChat1Chat(Sender: TObject; const AResponse: string;
  Success: Boolean);
begin
  AIChat1.Active:=False;
end;

end.

