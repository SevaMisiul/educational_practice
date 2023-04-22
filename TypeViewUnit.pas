unit TypeViewUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TTypeForm = class(TForm)
    lbTypeText: TLabel;
    edtType: TEdit;
    btnCancel: TButton;
    btnOk: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIsSave: Boolean;
  public
    property IsSave: Boolean read FIsSave;
  end;

var
  TypeForm: TTypeForm;

implementation

{$R *.dfm}

procedure TTypeForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TTypeForm.btnOkClick(Sender: TObject);
begin
  if (edtType.Text = '') then
    ShowMessage('Fill in required fields')
  else
  begin
    FIsSave := True;
    Close;
  end;
end;

procedure TTypeForm.FormShow(Sender: TObject);
begin
  FIsSave := False;
end;

end.
