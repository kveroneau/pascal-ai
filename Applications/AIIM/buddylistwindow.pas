unit BuddyListWindow;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ModelLogonWindow;

type

  { TBuddyListForm }

  TBuddyListForm = class(TForm)
    MainMenu: TMainMenu;
    MenuItem1: TMenuItem;
    ExitMenu: TMenuItem;
    MenuItem2: TMenuItem;
    CreateMenu: TMenuItem;
    BuddyList: TTreeView;
    procedure ExitMenuClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
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
end;

procedure TBuddyListForm.ExitMenuClick(Sender: TObject);
begin
  Close;
end;

end.

