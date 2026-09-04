unit kaithread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, fpjson, jsonparser;

type

  { TAIThread }

  TAIThread = class(TThread)
  private
    FLock: TRTLCriticalSection;
    FEvent: PRTLEvent;
    FRunning: boolean;
    FMsgReady: boolean;
    FMessage: string;
    FPrompt, FModel, FURL: string;
    FMemory: boolean;
    FMsgList: TJSONObject;
    FAsJSON: string;
    procedure AddMessage(role, content: string);
    procedure SendChat;
    function CreateTool(name, desc: string): TJSONObject;
    function CreateParam(na, typ, desc: string): TJSONObject;
  protected
    procedure Execute; override;
  public
    constructor Create(prompt, model, url: string);
    property MessageReady: Boolean read FMsgReady;
    property Message: string read FMessage;
    property EnableMemory: boolean read FMemory write FMemory;
    procedure SendMessage(msg: string);
    procedure StopThread;
    function AsJSON: string;
    procedure LoadJSON(json: string);
    function ChatHistory: string;
  end;

implementation

{ TAIThread }

procedure TAIThread.AddMessage(role, content: string);
var
  msg: TJSONObject;
begin
  msg:=TJSONObject.Create;
  msg.Strings['role']:=role;
  msg.Strings['content']:=content;
  FMsgList.Arrays['messages'].Add(msg);
end;

procedure TAIThread.SendChat;
var
  resp, msg: TJSONObject;
  loc: string;
begin
  EnterCriticalSection(FLock);
  AddMessage('user', FMessage);
  FMessage:='';
  LeaveCriticalSection(FLock);
  with TFPHTTPClient.Create(Nil) do
  try
    RequestBody:=TStringStream.Create(FMsgList.AsJSON);
    AddHeader('Content-Type', 'application/json');
    resp:=TJSONObject(GetJSON(Post(FURL+'/chat/completions')));
    RequestBody.Free;
    msg:=resp.Arrays['choices'].Objects[0].Objects['message'];
    if msg.Strings['content'] = '' then
    begin
      if msg.Arrays['tool_calls'].Objects[0].Objects['function'].Strings['name'] = 'get_weather' then
      begin
        WriteLn('We got successful use of tools!');
        loc:=msg.Arrays['tool_calls'].Objects[0].Objects['function'].Strings['arguments'];
      end;
    end
    else
    begin
      AddMessage(msg.Strings['role'], msg.Strings['content']);
      FMessage:=msg.Strings['content'];
    end;
    resp.Free;
  finally
    Free;
    FMsgReady:=True;
  end;
end;

function TAIThread.CreateTool(name, desc: string): TJSONObject;
begin
  Result:=TJSONObject.Create;
  Result.Strings['type']:='function';
  Result.Objects['function']:=TJSONObject.Create;
  Result.Objects['function'].Strings['name']:=name;
  Result.Objects['function'].Strings['description']:=desc;
end;

function TAIThread.CreateParam(na, typ, desc: string): TJSONObject;
begin
  Result:=TJSONObject.Create;
  Result.Strings['type']:='object';
  Result.Objects['properties']:=TJSONObject.Create;
  Result.Objects['properties'].Objects[na]:=TJSONObject.Create;
  Result.Objects['properties'].Objects[na].Strings['type']:=typ;
  Result.Objects['properties'].Objects[na].Strings['description']:=desc;
  Result.Arrays['required']:=TJSONArray.Create([na]);
end;

procedure TAIThread.Execute;
var
  tool: TJSONObject;
begin
  InitCriticalSection(FLock);
  FEvent:=RTLEventCreate;
  if not Assigned(FMsgList) then
  begin
    FMsgList:=TJSONObject.Create;
    FMsgList.Strings['model']:=FModel;
    FMsgList.Arrays['messages']:=TJSONArray.Create;
{    FMsgList.Arrays['tools']:=TJSONArray.Create;
    tool:=CreateTool('get_weather', 'Get current weather for a location');
    FMsgList.Arrays['tools'].Add(tool);
    tool.Objects['function'].Objects['parameters']:=CreateParam('location', 'string', 'City name');
    FMsgList.Floats['temperature']:=0.8;}
    AddMessage('system', FPrompt);
  end;
  FRunning:=True;
  try
    repeat
      RTLEventResetEvent(FEvent);
      RTLEventWaitFor(FEvent);
      if FMessage <> '' then
        SendChat;
    until not FRunning;
  finally
    FAsJSON:=FMsgList.AsJSON;
    FMsgList.Free;
    RTLEventDestroy(FEvent);
    DoneCriticalSection(FLock);
  end;
end;

constructor TAIThread.Create(prompt, model, url: string);
begin
  inherited Create(True);
  if prompt = '' then
    FPrompt:='You are a helpful assistant.'
  else
    FPrompt:=prompt;
  if model = '' then
    raise Exception.Create('Model is not set!')
  else
    FModel:=model;
  if url = '' then
    raise Exception.Create('URL is not set!')
  else
    FURL:=url;
  FMemory:=True;
end;

procedure TAIThread.SendMessage(msg: string);
begin
  EnterCriticalSection(FLock);
  FMsgReady:=False;
  FMessage:=msg;
  LeaveCriticalSection(FLock);
  RTLEventSetEvent(FEvent);
end;

procedure TAIThread.StopThread;
begin
  FRunning:=False;
  FMessage:='';
  RTLEventSetEvent(FEvent);
end;

function TAIThread.AsJSON: string;
begin
  if FRunning then
    Result:=''
  else
    Result:=FAsJSON;
end;

procedure TAIThread.LoadJSON(json: string);
begin
  if Assigned(FMsgList) then
    Exit;
  FMsgList:=TJSONObject(GetJSON(json));
end;

function TAIThread.ChatHistory: string;
var
  i: integer;
  msg: TJSONObject;
begin
  Result:='';
  if FRunning then
    Exit;
  for i:=0 to FMsgList.Arrays['messages'].Count-1 do
  begin
    msg:=FMsgList.Arrays['messages'].Objects[i];
    if msg.Strings['role'] = 'assistant' then
      Result:=Result+msg.Strings['content']+#13;
  end;
end;

end.

