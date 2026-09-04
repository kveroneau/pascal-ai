unit dbmodel;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, SQLite3DS;

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

implementation

{$R *.lfm}

{ TDatabase }

procedure TDatabase.DataModuleCreate(Sender: TObject);
begin
  BuddyDB.Active:=True;
end;

procedure TDatabase.DataModuleDestroy(Sender: TObject);
begin
  BuddyDB.Active:=False;
end;

end.

