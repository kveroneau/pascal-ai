unit BuddyChatWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, AIChat,
  CreateABuddyWindow, ModelLogonWindow, dbmodel;

type

  { TBuddyChatForm }

  TBuddyChatForm = class(TForm)
    AIChat: TAIChat;
    SendBtn: TButton;
    ChatText: TMemo;
    UserInput: TMemo;
    procedure AIChatChat(Sender: TObject; const AResponse: string;
      Success: Boolean);
    procedure AIChatFinish(Sender: TObject);
    procedure AIChatStart(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
  private
    FBuddy: String;
  public
    procedure NewChat;
    procedure OpenChatFor(buddy: string);
  end;

var
  BuddyChatForm: TBuddyChatForm;

implementation

{$R *.lfm}

{ TBuddyChatForm }

procedure TBuddyChatForm.FormResize(Sender: TObject);
begin
  ChatText.Width:=ClientWidth;
  ChatText.Height:=ClientHeight-UserInput.Height;
  UserInput.Top:=ChatText.Height;
  UserInput.Width:=ClientWidth-90;
  SendBtn.Top:=ClientHeight-60;
  SendBtn.Left:=ClientWidth-80;
end;

procedure TBuddyChatForm.FormDestroy(Sender: TObject);
begin
  AIChat.Active:=False;
end;

procedure TBuddyChatForm.AIChatStart(Sender: TObject);
begin
  with Database.BuddyDB do
  begin
    if Locate('name', FBuddy, []) then
      AIChat.LoadJSON(FieldByName('history').AsString);
  end;
end;

procedure TBuddyChatForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  AIChat.Active:=False;
  CloseAction:=caFree;
end;

procedure TBuddyChatForm.AIChatFinish(Sender: TObject);
begin
  with Database.BuddyDB do
  begin
    if Locate('name', FBuddy, []) then
    begin
      Edit;
      FieldByName('history').AsString:=AIChat.AsJSON;
      Post;
    end
    else
    begin
      Append;
      FieldByName('name').AsString:=FBuddy;
      FieldByName('history').AsString:=AIChat.AsJSON;
      Post;
    end;
  end;
end;

procedure TBuddyChatForm.AIChatChat(Sender: TObject; const AResponse: string;
  Success: Boolean);
begin
  SendBtn.Enabled:=True;
end;

procedure TBuddyChatForm.FormShow(Sender: TObject);
begin
  ChatText.Text:='';
  UserInput.Text:='';
  Caption:='Chat with '+FBuddy;
  AIChat.URL:=ModelLogonForm.ServerURL.Text;
  AIChat.Model:=ModelLogonForm.Model.Text;
  AIChat.Active:=True;
  Sleep(500);
  ChatText.Text:=AIChat.ChatHistory;
end;

procedure TBuddyChatForm.SendBtnClick(Sender: TObject);
begin
  SendBtn.Enabled:=False;
  AIChat.SendMessage(UserInput.Text);
  UserInput.Text:='';
end;

procedure TBuddyChatForm.NewChat;
begin
  FBuddy:=CreateABuddyForm.BuddyName.Text;
  AIChat.Prompt:='You are playing the role of an instant messenger friend from the late 1990s. Your friend tag is '+FBuddy+'. '+CreateABuddyForm.BuddyDesc.Text+' You love chatting about '+CreateABuddyForm.BuddyTopic.Text+' the most, and always try to incorporate it in any conversation if possible.';
  Show;
end;

procedure TBuddyChatForm.OpenChatFor(buddy: string);
begin
  FBuddy:=buddy;
  Show;
end;

end.

