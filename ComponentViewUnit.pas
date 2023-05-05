unit ComponentViewUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, ModelUnit;

type
  TComponentForm = class(TForm)
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
    procedure FillListBox(Code: Integer = -1);
  private
    FIsSave: Boolean;
  public
    property IsSave: Boolean read FIsSave;
  end;

var
  ComponentForm: TComponentForm;

implementation

{$R *.dfm}

procedure TComponentForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TComponentForm.btnOkClick(Sender: TObject);
begin
  if (cbComponentTypes.Text = '') or (edtModel.Text = '') or (edtPrice.Text = '') or (mDescription.Text = '') then
    ShowMessage('Fill in required fields')
  else
  begin
    FIsSave := True;
    Close;
  end;
end;

procedure TComponentForm.FillListBox(Code: Integer);
var
  Res: TListBorders;
begin
  chlbCompatibleComponents.Items.Clear;

  Res := ListsModel.GetComponentListBorders;
  if Res.Last <> nil then
    Res.Last := Res.Last^.Next;

  while Res.First <> Res.Last do
  begin
    if Code <> Res.First^.Info.TypeCode then
      chlbCompatibleComponents.Items.Add(IntToStr(Res.First^.Info.ComponentCode) + ' ' + Res.First^.Info.Model);
    Res.First := Res.First^.Next;
  end;
end;

procedure TComponentForm.FormShow(Sender: TObject);
begin
  FIsSave := False;
end;

end.
