unit BuddyListWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  IniPropStorage, ModelLogonWindow, CreateABuddyWindow, BuddyChatWindow,
  dbmodel, TheatreWindow;

type

  { TBuddyListForm }

  TBuddyListForm = class(TForm)
    IniPropStorage1: TIniPropStorage;
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    ExitMenu: TMenuItem;
    MenuItem2: TMenuItem;
    CreateMenu: TMenuItem;
    BuddyList: TTreeView;
    TheatreMenu: TMenuItem;
    procedure BuddyListDblClick(Sender: TObject);
    procedure CreateMenuClick(Sender: TObject);
    procedure ExitMenuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TheatreMenuClick(Sender: TObject);
  private

  public

  end;

var
  BuddyListForm: TBuddyListForm;

implementation

{$R *.lfm}

{ TBuddyListForm }

procedure TBuddyListForm.FormResize(Sender: TObject);
begin
  BuddyList.Width:=ClientWidth;
  BuddyList.Height:=ClientHeight;
end;

procedure TBuddyListForm.FormShow(Sender: TObject);
var
  r: TModalResult;
begin
  r:=ModelLogonForm.ShowModal;
  if r <> mrOK then
    Close;
  with Database.BuddyDB do
  begin
    First;
    if EOF then
      Exit;
    repeat
      BuddyList.Items.Add(Nil, FieldByName('name').AsString);
      Next;
    until EOF;
  end;
end;

procedure TBuddyListForm.TheatreMenuClick(Sender: TObject);
begin
  TheatreForm.Show;
end;

procedure TBuddyListForm.ExitMenuClick(Sender: TObject);
begin
  Close;
end;

procedure TBuddyListForm.FormCreate(Sender: TObject);
begin
  IniPropStorage1.IniFileName:=GetConfigPath+PathDelim+IniPropStorage1.IniFileName;
end;

procedure TBuddyListForm.CreateMenuClick(Sender: TObject);
var
  r: TModalResult;
  f: TBuddyChatForm;
begin
  r:=CreateABuddyForm.ShowModal;
  if r <> mrOK then
    Exit;
  BuddyList.Items.Add(Nil, CreateABuddyForm.BuddyName.Text);
  f:=TBuddyChatForm.Create(Self);
  f.NewChat;
end;

procedure TBuddyListForm.BuddyListDblClick(Sender: TObject);
var
  f: TBuddyChatForm;
begin
  if not Assigned(BuddyList.Selected) then
    Exit;
  f:=TBuddyChatForm.Create(Self);
  f.OpenChatFor(BuddyList.Selected.Text);
end;

end.

