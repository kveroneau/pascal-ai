unit CloneWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, AIChat,
  ModelLogonWindow;

type

  { TCloneForm }

  TCloneForm = class(TForm)
    AIChat: TAIChat;
    CancelBtn: TButton;
    CloneBtn: TButton;
    CloneName: TEdit;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Output: TMemo;
    procedure CancelBtnClick(Sender: TObject);
    procedure CloneBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  CloneForm: TCloneForm;

implementation

{$R *.lfm}

{ TCloneForm }

procedure TCloneForm.FormShow(Sender: TObject);
begin
  CloneName.Text:='';
end;

procedure TCloneForm.CloneBtnClick(Sender: TObject);
begin
  CloneBtn.Enabled:=False;
  AIChat.URL:=ModelLogonForm.ServerURL.Text;
  AIChat.Model:=ModelLogonForm.Model.Text;
  AIChat.Active:=True;
  try
    Sleep(1000);
    AIChat.SendMessage('Can you create me a system prompt to replicate the personality of '+CloneName.Text);
    AIChat.SendMessage('I was hoping you could condense that down into a single line, but can include multiple sentences if needed.');
    Output.Text:=AIChat.Message;
  finally
    AIChat.Free;
    CloneBtn.Enabled:=True;
  end;
end;

procedure TCloneForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

end.

