unit GetTypeUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TGetTypeForm = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbText: TLabel;
    edtTypeCode: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function GetType(var T: Integer): TModalResult;
  end;

var
  GetTypeForm: TGetTypeForm;

implementation

{$R *.dfm}
{ TGetTypeForm }

procedure TGetTypeForm.FormCreate(Sender: TObject);
begin
  lbText.Caption :=
    'Enter the type of components'#10#13'you want to view, leave it empty, '#10#13'if you want view all components';
end;

function TGetTypeForm.GetType(var T: Integer): TModalResult;
begin
  edtTypeCode.Text := '';

  result := ShowModal;

  if result = mrOk then
    if edtTypeCode.Text = '' then
      T := -1
    else
      T := StrToInt(edtTypeCode.Text);
end;

end.
