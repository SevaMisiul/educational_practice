unit TypeViewUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ModelUnit;

type
  TTypeForm = class(TForm)
    lbTypeText: TLabel;
    edtType: TEdit;
    btnCancel: TButton;
    btnOk: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
  public
    function ShowForNewType(var TypeInfo: TTypeInfo): TModalResult;
    function ShowForEditType(Var TypeInfo: TTypeInfo): TModalResult;
  end;

var
  TypeForm: TTypeForm;

implementation

{$R *.dfm}

procedure TTypeForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Self.ModalResult = mrOk) and (edtType.Text = '') then
  begin
    ShowMessage('Fill in required fields');
    CanClose := False;
  end;
end;

function TTypeForm.ShowForEditType(var TypeInfo: TTypeInfo): TModalResult;
begin
  edtType.Text := TypeInfo.TypeName;

  result := ShowModal;

  if result = mrOk then
  begin
    TypeInfo.TypeName := edtType.Text;
  end;
end;

function TTypeForm.ShowForNewType(var TypeInfo: TTypeInfo): TModalResult;
begin
  edtType.Text := '';

  result := ShowModal;

  if result = mrOk then
  begin
    TypeInfo.TypeCode := ListsModel.TypeID + 1;
    TypeInfo.TypeName := edtType.Text;
  end;
end;

end.
