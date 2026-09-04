unit ModelLogonWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls,
  IniPropStorage, fphttpclient, fpjson, dbmodel;

type

  { TModelLogonForm }

  TModelLogonForm = class(TForm)
    BeginBtn: TButton;
    CloseBtn: TButton;
    IniPropStorage1: TIniPropStorage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Model: TComboBox;
    Label2: TLabel;
    ServerURL: TComboBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ServerURLChange(Sender: TObject);
  private

  public

  end;

var
  ModelLogonForm: TModelLogonForm;

implementation

{$R *.lfm}

{ TModelLogonForm }

procedure TModelLogonForm.ServerURLChange(Sender: TObject);
var
  json: TJSONObject;
  i: Integer;
begin
  Model.Clear;
  json:=Nil;
  with TFPHTTPClient.Create(Nil) do
  try
    json:=TJSONObject(GetJSON(Get(ServerURL.Text+'/models')));
    for i:=0 to json.Arrays['data'].Count-1 do
      Model.Items.Add(json.Arrays['data'].Objects[i].Strings['id']);
  finally
    Free;
    if Assigned(json) then
      json.Free;
  end;
end;

procedure TModelLogonForm.FormCreate(Sender: TObject);
begin
  IniPropStorage1.IniFileName:=GetConfigPath+PathDelim+IniPropStorage1.IniFileName;
end;

end.

