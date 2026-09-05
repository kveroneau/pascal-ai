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
    procedure AIChatChat(Sender: TObject; const AResponse: string;
      Success: Boolean);
    procedure CancelBtnClick(Sender: TObject);
    procedure CloneBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FPhase: Integer;
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
  Sleep(1000);
  AIChat.SendMessage('Can you create me a system prompt to replicate the personality of '+CloneName.Text);
  FPhase:=1;
end;

procedure TCloneForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TCloneForm.AIChatChat(Sender: TObject; const AResponse: string;
  Success: Boolean);
begin
  if FPhase = 1 then
    AIChat.SendMessage('I was hoping you could condense that down into a single line, but can include multiple sentences if needed.')
  else if FPhase = 2 then
  begin
    Output.Text:=AIChat.Message;
    AIChat.Free;
    CloneBtn.Enabled:=True;
  end;
  Inc(FPhase);
end;

end.

