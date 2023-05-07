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
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbComponentTypesChange(Sender: TObject);
  private
    procedure FillCompatibleArr(var Arr: TCompatibleArr);
  public
    function ShowForNewType(var ComponentInfo: TComponentInfo; var CompatibleArr: TCompatibleArr; cbText: string)
      : TModalResult;
    function ShowForEditType(var ComponentInfo: TComponentInfo; var CompatibleArr: TCompatibleArr): TModalResult;
  end;

var
  ComponentForm: TComponentForm;

implementation

{$R *.dfm}

uses MainUnit;

procedure TComponentForm.cbComponentTypesChange(Sender: TObject);
var
  Res: TListBorders;
  TypeCode: Integer;
begin
  chlbCompatibleComponents.Items.Clear;

  Res := ListsModel.GetComponentListBorders;
  if Res.Last <> nil then
    Res.Last := Res.Last^.Next;

  TypeCode := ListsModel.GetTypeCode(cbComponentTypes.Text);
  while Res.First <> Res.Last do
  begin
    if TypeCode <> Res.First^.Info.TypeCode then
      chlbCompatibleComponents.Items.Add(IntToStr(Res.First^.Info.ComponentCode) + ' ' + Res.First^.Info.Model);
    Res.First := Res.First^.Next;
  end;
end;

procedure TComponentForm.FillCompatibleArr(var Arr: TCompatibleArr);
var
  CheckedCount, I, J: Integer;
begin
  CheckedCount := 0;

  with chlbCompatibleComponents do
  begin
    for I := 0 to Items.Count - 1 do
      Inc(CheckedCount, Ord(Checked[I]));

    SetLength(Arr, CheckedCount);

    J := 0;
    for I := 0 to Items.Count - 1 do
    begin
      if Checked[I] then
      begin
        Arr[J].ComponentCode := StrToInt(Copy(Items[I], 1, Pos(' ', Items[I]) - 1));
        Arr[J].TypeCode := ListsModel.GetComponent(Arr[J].ComponentCode)^.Info.TypeCode;
        Inc(J);
      end;
    end;
  end;
end;

procedure TComponentForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Self.ModalResult = mrOk) and ((cbComponentTypes.Text = '') or (edtModel.Text = '') or (edtPrice.Text = '') or
    (mDescription.Text = '')) then
  begin
    ShowMessage('Fill in required fields');
    CanClose := False;
  end;
end;

function TComponentForm.ShowForEditType(var ComponentInfo: TComponentInfo; var CompatibleArr: TCompatibleArr)
  : TModalResult;
var
  I, Code2: Integer;
  CompatibleList: PCompatibleList;
begin
  with ComponentInfo do
  begin
    edtModel.Text := Model;
    mDescription.Text := Description;
    edtPrice.Text := IntToStr(Price);
    chbStock.Checked := IsInStock;

    cbComponentTypes.Items.Clear;
    cbComponentTypes.Items.Add(ListsModel.GetType(TypeCode)^.Info.TypeName);
    cbComponentTypes.ItemIndex := 0;
    cbComponentTypes.Enabled := False;
  end;

  cbComponentTypesChange(Self);
  CompatibleList := ListsModel.GetCompatibleList(ComponentInfo.ComponentCode);
  with chlbCompatibleComponents do
    for I := 0 to Items.Count - 1 do
    begin
      Code2 := StrToInt(Copy(Items[I], 1, Pos(' ', Items[I]) - 1));
      Checked[I] := ListsModel.IsCompatible(CompatibleList, Code2);
    end;

  result := ComponentForm.ShowModal;

  if result = mrOk then
  begin
    with ComponentInfo do
    begin
      Model := edtModel.Text;
      Price := StrToInt(edtPrice.Text);
      IsInStock := chbStock.Checked;
      Description := mDescription.Text;
    end;

    FillCompatibleArr(CompatibleArr);
  end;
end;

function TComponentForm.ShowForNewType(var ComponentInfo: TComponentInfo; var CompatibleArr: TCompatibleArr;
  cbText: string): TModalResult;
begin
  edtModel.Text := '';
  edtPrice.Text := '';
  chbStock.Checked := False;
  mDescription.Text := '';
  cbComponentTypes.Items.Clear;
  chlbCompatibleComponents.Clear;
  with cbComponentTypes do
    if (cbText = 'All components') or (cbText = '') then
    begin
      Enabled := True;
      Items := MainForm.cbLists.Items;
      Items.Delete(0);
      Items.Delete(0);
    end
    else
    begin
      Enabled := False;
      Items.Add(cbText);
      ItemIndex := 0;
      cbComponentTypesChange(Self);
    end;

  result := ShowModal;

  if result = mrOk then
  begin
    with ComponentInfo do
    begin
      ComponentCode := ListsModel.ComponentID + 1;
      TypeCode := ListsModel.GetTypeCode(cbComponentTypes.Text);
      Model := edtModel.Text;
      Price := StrToInt(edtPrice.Text);
      IsInStock := chbStock.Checked;
      Description := mDescription.Text;
    end;

    FillCompatibleArr(CompatibleArr);
  end;
end;

end.
