unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, RTTICtrls,
  AIChat;

type

  { TForm1 }

  TForm1 = class(TForm)
    AIChat1: TAIChat;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    TICheckBox1: TTICheckBox;
    TIEdit1: TTIEdit;
    TIEdit2: TTIEdit;
    TIEdit3: TTIEdit;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  if not AIChat1.Active then
    raise Exception.Create('Please Activate before sending a message.');
  Button1.Enabled:=False;
  AIChat1.SendMessage(Edit1.Text); // Not technically blocking...
  // However, the rest of the code will not run until it's done, but the UI will remain response.
  Button1.Enabled:=True;
end;

end.

