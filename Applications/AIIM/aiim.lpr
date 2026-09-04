program aiim;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, sqlite3laz, BuddyListWindow, ModelLogonWindow, dbmodel,
  BuddyChatWindow, CreateABuddyWindow, CloneWindow, TheatreWindow
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='AI Instant Messenger';
  Application.Scaled:=True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar:=True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TBuddyListForm, BuddyListForm);
  Application.CreateForm(TModelLogonForm, ModelLogonForm);
  Application.CreateForm(TDatabase, Database);
  Application.CreateForm(TCreateABuddyForm, CreateABuddyForm);
  Application.CreateForm(TCloneForm, CloneForm);
  Application.CreateForm(TTheatreForm, TheatreForm);
  Application.Run;
end.

