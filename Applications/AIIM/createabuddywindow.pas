unit CreateABuddyWindow;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBCtrls, DB,
  CloneWindow;

type

  { TCreateABuddyForm }

  TCreateABuddyForm = class(TForm)
    CancelBtn: TButton;
    CreateBtn: TButton;
    CloneBtn: TButton;
    BuddyName: TEdit;
    BuddyDesc: TEdit;
    BuddyTopic: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    procedure CloneBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  CreateABuddyForm: TCreateABuddyForm;

implementation

{$R *.lfm}

{ TCreateABuddyForm }

procedure TCreateABuddyForm.FormShow(Sender: TObject);
begin
  BuddyName.Text:='';
  BuddyDesc.Text:='';
  BuddyTopic.Text:='';
end;

procedure TCreateABuddyForm.CloneBtnClick(Sender: TObject);
begin
  CloneForm.Show;
end;

end.

