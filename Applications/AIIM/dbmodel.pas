unit dbmodel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLite3DS, FileUtil;

type

  { TDatabase }

  TDatabase = class(TDataModule)
    BuddyDB: TSqlite3Dataset;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private

  public

  end;

var
  Database: TDatabase;

function GetConfigPath: string;

implementation

function GetConfigPath: string;
begin
  {$IFDEF UNIX}
  Result:=GetUserDir+PathDelim+'.config'+PathDelim+'aiim';
  {$ELSE}
  Result:='';
  {$ENDIF}
end;

{$R *.lfm}

{ TDatabase }

procedure TDatabase.DataModuleCreate(Sender: TObject);
{$IFDEF UNIX}
var
  cfgpath: string;
  r: TResourceStream;
{$ENDIF}
begin
  {$IFDEF UNIX}
  cfgpath:=GetConfigPath;
  if not DirectoryExists(cfgpath) then
    CreateDir(cfgpath);
  BuddyDB.FileName:=cfgpath+PathDelim+BuddyDB.FileName;
  if not FileExists(BuddyDB.FileName) then
  begin
    r:=TResourceStream.Create(HINSTANCE, 'DATABASE', RT_RCDATA);
    try
      r.SaveToFile(BuddyDB.FileName);
    finally
      r.Free;
    end;
  end;
  {$ENDIF}
  // Windows AppData or recommended storage location will come in later update.
  BuddyDB.Active:=True;
end;

procedure TDatabase.DataModuleDestroy(Sender: TObject);
begin
  BuddyDB.Active:=False;
end;

end.

