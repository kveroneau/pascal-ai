unit TheatreWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, dbmodel,
  AIChat, ModelLogonWindow;

type

  { TTheatreForm }

  TTheatreForm = class(TForm)
    AIChat1: TAIChat;
    AIChat2: TAIChat;
    Buddy1: TComboBox;
    Buddy2: TComboBox;
    NextBtn: TButton;
    ConnectBtn: TButton;
    FirstPrompt: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ChatText: TMemo;
    procedure AIChat1Chat(Sender: TObject; const AResponse: string;
      Success: Boolean);
    procedure AIChat1Start(Sender: TObject);
    procedure AIChat2Chat(Sender: TObject; const AResponse: string;
      Success: Boolean);
    procedure AIChat2Start(Sender: TObject);
    procedure Buddy1Change(Sender: TObject);
    procedure Buddy2Change(Sender: TObject);
    procedure ConnectBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NextBtnClick(Sender: TObject);
  private
    FCurChat: Integer;
    procedure UpdateBuddies;
  public

  end;

var
  TheatreForm: TTheatreForm;

implementation

{$R *.lfm}

{ TTheatreForm }

procedure TTheatreForm.FormShow(Sender: TObject);
begin
  Buddy1.Items.Clear;
  Buddy2.Items.Clear;
  ChatText.Text:='';
  with Database.BuddyDB do
  begin
    First;
    if EOF then
    begin
      ShowMessage('Cannot use this mode with no buddies.');
      Close;
    end;
    repeat
      Buddy1.Items.Add(FieldByName('name').AsString);
      Buddy2.Items.Add(FieldByName('name').AsString);
      Next;
    until EOF;
  end;
end;

procedure TTheatreForm.NextBtnClick(Sender: TObject);
begin
  NextBtn.Enabled:=False;
  if FCurChat = 1 then
    AIChat1.SendMessage(AIChat2.Message)
  else if FCurChat = 2 then
    AIChat2.SendMessage(AIChat1.Message);
end;

procedure TTheatreForm.UpdateBuddies;
begin
  Label7.Caption:='How will '+Buddy2.Text+' greet '+Buddy1.Text+'?';
  FirstPrompt.Text:='Hey '+Buddy1.Text+'! It''s me '+Buddy2.Text+'. Been awhile, how have you been doing?';
end;

procedure TTheatreForm.Buddy1Change(Sender: TObject);
begin
  UpdateBuddies;
end;

procedure TTheatreForm.AIChat1Start(Sender: TObject);
begin
  with Database.BuddyDB do
  begin
    if not Locate('name', Buddy1.Text, []) then
      raise Exception.Create('Could not find: '+Buddy1.Text+'!');
    AIChat1.LoadJSON(FieldByName('history').AsString);
  end;
end;

procedure TTheatreForm.AIChat2Chat(Sender: TObject; const AResponse: string;
  Success: Boolean);
var
  caret: TPoint;
begin
  caret:=ChatText.CaretPos;
  ChatText.Text:=ChatText.Text+Buddy2.Text+':'+#13+AIChat2.Message+#13#13;
  ChatText.CaretPos:=caret;
  FCurChat:=1;
  NextBtn.Enabled:=True;
end;

procedure TTheatreForm.AIChat1Chat(Sender: TObject; const AResponse: string;
  Success: Boolean);
var
  caret: TPoint;
begin
  caret:=ChatText.CaretPos;
  ChatText.Text:=ChatText.Text+Buddy1.Text+':'+#13+AIChat1.Message+#13#13;
  ChatText.CaretPos:=caret;
  FCurChat:=2;
  NextBtn.Enabled:=True;
end;

procedure TTheatreForm.AIChat2Start(Sender: TObject);
begin
  with Database.BuddyDB do
  begin
    if not Locate('name', Buddy2.Text, []) then
      raise Exception.Create('Could not find: '+Buddy2.Text+'!');
    AIChat2.LoadJSON(FieldByName('history').AsString);
  end;
end;

procedure TTheatreForm.Buddy2Change(Sender: TObject);
begin
  UpdateBuddies;
end;

procedure TTheatreForm.ConnectBtnClick(Sender: TObject);
begin
  ConnectBtn.Enabled:=False;
  Buddy1.Enabled:=False;
  Buddy2.Enabled:=False;
  FirstPrompt.Enabled:=False;
  AIChat1.URL:=ModelLogonForm.ServerURL.Text;
  AIChat1.Active:=True;
  Application.ProcessMessages;
  Sleep(500);
  AIChat1.Reset;
  AIChat2.URL:=ModelLogonForm.ServerURL.Text;
  AIChat2.Active:=True;
  Sleep(500);
  AIChat2.Reset;
  ChatText.Text:=Buddy2.Text+':'+#13+FirstPrompt.Text+#13#13;
  AIChat1.SendMessage(FirstPrompt.Text);
end;

end.

