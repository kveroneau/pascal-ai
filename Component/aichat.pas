unit AIChat;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, LResources, kaithread, StdCtrls;

type

  TChatEvent = procedure(Sender: TObject; const AResponse: string; Success: Boolean) of object;
  TPromptEvent = function(Sender: TObject): string of object;

  { TAIChat }

  TAIChat = class(TComponent)
  private
    FChat: TAIThread;
    FActive, FSending: Boolean;
    FPrompt, FModel, FURL: string;
    FOnChat: TChatEvent;
    FOnPrompt: TPromptEvent;
    FOutput: TMemo;
    FAppend: Boolean;
    FOnStart, FOnFinish: TNotifyEvent;
    function GetChatHistory: string;
    function GetMessage: string;
    function GetMessageReady: Boolean;
    procedure SetActive(AValue: Boolean);
    procedure SetModel(AValue: string);
    procedure SetOutput(AValue: TMemo);
    procedure SetPrompt(AValue: string);
    procedure SetURL(AValue: string);
    procedure HandleThreadChat(Sender: TObject; const AResponse: string; Success: Boolean);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    property MessageReady: Boolean read GetMessageReady;
    property Message: string read GetMessage;
    property ChatHistory: string read GetChatHistory;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SendMessage(msg: string);
    procedure LoadJSON(json: string);
    function AsJSON: string;
    procedure Reset;
  published
    property Active: Boolean read FActive write SetActive;
    property Prompt: string read FPrompt write SetPrompt;
    property Model: string read FModel write SetModel;
    property URL: string read FURL write SetURL;
    property Append: Boolean read FAppend write FAppend;
    property Sending: Boolean read FSending;
    property OnChat: TChatEvent read FOnChat write FOnChat;
    property OnPrompt: TPromptEvent read FOnPrompt write FOnPrompt;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property Output: TMemo read FOutput write SetOutput;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I aichat_icon.lrs}
  RegisterComponents('AI',[TAIChat]);
end;

{ TAIChat }

procedure TAIChat.SetActive(AValue: Boolean);
begin
  if FActive=AValue then Exit;
  if AValue and (not (csDesigning in ComponentState)) then
  begin
    if (FPrompt = '') and Assigned(FOnPrompt) then
      FPrompt:=FOnPrompt(Self);
    if FPrompt = '' then
      FPrompt:='You are a helpful assistant.';
    FChat:=TAIThread.Create(FPrompt, FModel, FURL);
    FChat.OnChat:=@HandleThreadChat;
    if Assigned(FOnStart) then
      FOnStart(Self);
    FChat.Start;
  end
  else
  begin
    if Assigned(FChat) and (not FChat.Finished) then
    begin
      FChat.StopThread;
      FChat.WaitFor;
      if Assigned(FOnFinish) then
        FOnFinish(Self);
      FChat.Free;
    end;
  end;
  FActive:=AValue;
end;

function TAIChat.GetChatHistory: string;
begin
  if not FActive then
    raise Exception.Create('Cannot check when AIChat is active.');
  Result:=FChat.ChatHistory;
end;

function TAIChat.GetMessage: string;
begin
  if not FActive then
    raise Exception.Create('Cannot check when AIChat is active.');
  Result:=FChat.Message;
end;

function TAIChat.GetMessageReady: Boolean;
begin
  if not FActive then
    raise Exception.Create('Cannot check when AIChat is active.');
  Result:=FChat.MessageReady;
end;

procedure TAIChat.SetModel(AValue: string);
begin
  if FModel=AValue then Exit;
  if FActive then
    raise Exception.Create('Cannot set Model on active AIChat.');
  FModel:=AValue;
end;

procedure TAIChat.SetOutput(AValue: TMemo);
begin
  if FOutput=AValue then Exit;
  if Assigned(FOutput) then
    FOutput.RemoveFreeNotification(Self);
  FOutput := AValue;
  if Assigned(FOutput) then
    FOutput.FreeNotification(Self);
end;

procedure TAIChat.SetPrompt(AValue: string);
begin
  if FPrompt=AValue then Exit;
  if FActive then
    raise Exception.Create('Cannot set Prompt on active AIChat.');
  FPrompt:=AValue;
end;

procedure TAIChat.SetURL(AValue: string);
begin
  if FURL=AValue then Exit;
  if FActive then
    raise Exception.Create('Cannot set URL on active AIChat.');
  FURL:=AValue;
end;

procedure TAIChat.HandleThreadChat(Sender: TObject; const AResponse: string;
  Success: Boolean);
var
  caret: TPoint;
begin
  FSending := False;
  if Success and Assigned(FOutput) then
  begin
    if FAppend then
    begin
      caret:=FOutput.CaretPos;
      FOutput.Lines.Add(AResponse);
      FOutput.CaretPos:=caret;
    end
    else
      FOutput.Text := AResponse;
  end;
  if Assigned(FOnChat) then
    FOnChat(Self, AResponse, Success);
end;

procedure TAIChat.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FOutput) then
    FOutput := Nil;
end;

constructor TAIChat.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChat:=Nil
end;

destructor TAIChat.Destroy;
begin
  if Assigned(FChat) then
    SetActive(False);
  inherited Destroy;
end;

procedure TAIChat.SendMessage(msg: string);
begin
  if not FActive then
    raise EInvalidOperation.Create('AIChat must be Active before sending a message.');
  if FSending then
    raise EInvalidOperation.Create('Cannot Send a message when one is already sending.');
  FSending:=True;
  FChat.SendMessage(msg);
end;

procedure TAIChat.LoadJSON(json: string);
begin
  if FActive then
    raise Exception.Create('Cannot load context after activation!');
  if not Assigned(FChat) then
    raise Exception.Create('Cannot be called outside callback event!');
  FChat.LoadJSON(json);
end;

function TAIChat.AsJSON: string;
begin
  Result:=FChat.AsJSON;
end;

procedure TAIChat.Reset;
begin
  if not FActive then
    raise Exception.Create('Cannot Reset Context on inactive AI Chat.');
  FChat.SendMessage('#!RESET!#');
end;

end.
