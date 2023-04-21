unit AddComponentUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst;

type
  TAddComponentForm = class(TForm)
    cbComponentTypes: TComboBox;
    lbPriceText: TLabel;
    edtPrice: TEdit;
    chbStock: TCheckBox;
    chlbCompatibleComponents: TCheckListBox;
    edtModel: TEdit;
    lbModelText: TLabel;
    lbTypeText: TLabel;
    lbDescriptionText: TLabel;
    mDescription: TMemo;
    lbCompatibleText: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FIsSave: Boolean;
  public
    property IsSave: Boolean read FIsSave;
  end;

var
  AddComponentForm: TAddComponentForm;

implementation

{$R *.dfm}

procedure TAddComponentForm.btnCancelClick(Sender: TObject);
begin
  FIsSave := False;
  Close;
end;

procedure TAddComponentForm.btnOkClick(Sender: TObject);
begin
  if (cbComponentTypes.Text = '') or (edtModel.Text = '') or
    (edtPrice.Text = '') or (mDescription.Text = '') then
    ShowMessage('Fill in required fields')
  else
  begin
    FIsSave := True;
    Close;
  end;
end;

procedure TAddComponentForm.FormShow(Sender: TObject);
begin
  edtModel.Text := '';
  edtPrice.Text := '';
  chbStock.Checked := False;
  mDescription.Text := '';
end;

end.
