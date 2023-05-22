unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Grids, Vcl.Menus,
  ComponentViewUnit, TypeViewUnit, System.Actions, Vcl.ActnList, ModelUnit, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    MenuBar: TMainMenu;
    menuFile: TMenuItem;
    menuExitSave: TMenuItem;
    menuExit: TMenuItem;
    menuBuildPC: TMenuItem;
    pnLists: TPanel;
    pnTypeListButtons: TPanel;
    btnEditType: TButton;
    btnAddComponent: TButton;
    btnDeleteComponent: TButton;
    btnShowCompatible: TButton;
    sgListInfo: TStringGrid;
    cbLists: TComboBox;
    pnBuildPC: TPanel;
    menuWatchLists: TMenuItem;
    sgComputersInfo: TStringGrid;
    pnBuildPCButtons: TPanel;
    edtFromPrice: TEdit;
    lbTextPrice: TLabel;
    lbFromPrice: TLabel;
    lbToPrice: TLabel;
    edtToPrice: TEdit;
    btnBuildPC: TButton;
    btnAddType: TButton;
    btnEditComponent: TButton;
    btnDeleteType: TButton;
    pnComponentListButtons: TPanel;
    btnSortDecrease: TButton;
    btnSortIncrease: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddTypeClick(Sender: TObject);
    procedure btnEditTypeClick(Sender: TObject);
    procedure btnDeleteTypeClick(Sender: TObject);
    procedure btnAddComponentClick(Sender: TObject);
    procedure btnEditComponentClick(Sender: TObject);
    procedure btnDeleteComponentClick(Sender: TObject);
    procedure menuWatchListsClick(Sender: TObject);
    procedure menuBuildPCClick(Sender: TObject);
    procedure menuExitSaveClick(Sender: TObject);
    procedure menuExitClick(Sender: TObject);
    procedure btnShowCompatibleClick(Sender: TObject);
    procedure edtFromPriceChange(Sender: TObject);
    procedure edtToPriceChange(Sender: TObject);
    procedure btnBuildPCClick(Sender: TObject);
    procedure sgComputersInfoClick(Sender: TObject);
    procedure sgListInfoSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure cbListsChange(Sender: TObject);
    procedure btnSortDecreaseClick(Sender: TObject);
    procedure btnSortIncreaseClick(Sender: TObject);
  private
    FExitMode: Integer;
    procedure AddTypeView(TypeInfo: TTypeInfo);
    procedure UpdateTypeView(TypeInfo: TTypeInfo);
    procedure UpdateTypeList();

    procedure AddComponentView(ComponentInfo: TComponentInfo);
    procedure UpdateComponentView(ComponentInfo: TComponentInfo);
    procedure DeleteComponentView;
    procedure UpdateComponentList(Borders: TListBorders);

    procedure SetControlBox;
    procedure FillCompatibleList(CompatibleInfo1: TCompatibleInfo);
    procedure UpdateComputerList;

    procedure CheckPCButtonsState;
    procedure CheckListButtonsState(Row: Integer);
  public
    property ExitMode: Integer read FExitMode write FExitMode;
  end;

var
  MainForm: TMainForm;

implementation

uses
  ComputerViewUnit, GetTypeUnit;

{$R *.dfm}

procedure TMainForm.AddComponentView(ComponentInfo: TComponentInfo);
begin
  with sgListInfo, ComponentInfo do
  begin
    RowCount := RowCount + 1;
    Cells[0, RowCount - 1] := IntToStr(ComponentCode);
    Cells[1, RowCount - 1] := IntToStr(TypeCode);;
    Cells[2, RowCount - 1] := Model;
    Cells[3, RowCount - 1] := Description;
    Cells[4, RowCount - 1] := IntToStr(Price);
    if IsInStock then
      Cells[5, RowCount - 1] := 'Yes'
    else
      Cells[5, RowCount - 1] := 'No';

    CheckListButtonsState(Row);
  end;
end;

procedure TMainForm.AddTypeView(TypeInfo: TTypeInfo);
begin
  with sgListInfo, TypeInfo do
  begin
    RowCount := RowCount + 1;
    Cells[0, RowCount - 1] := IntToStr(TypeCode);
    Cells[1, RowCount - 1] := TypeName;
    CheckListButtonsState(Row);
  end;
  cbLists.Items.Add(TypeInfo.TypeName);
end;

procedure TMainForm.btnAddComponentClick(Sender: TObject);
var
  ComponentInfo: TComponentInfo;
  CompatibleArr: TCompatibleArr;
  Res: TModalResult;
begin
  Res := ComponentForm.ShowForNewType(ComponentInfo, CompatibleArr, cbLists.Text);

  if Res = mrOk then
    ListsModel.AddComponent(ComponentInfo, CompatibleArr);
  CompatibleArr := nil;
end;

procedure TMainForm.btnAddTypeClick(Sender: TObject);
var
  TypeInfo: TTypeInfo;
  Res: TModalResult;
begin
  Res := TypeForm.ShowForNewType(TypeInfo);

  if Res = mrOk then
    ListsModel.AddType(TypeInfo);
end;

procedure TMainForm.btnBuildPCClick(Sender: TObject);
var
  TmpType: PTypeLI;
  PriceFrom, PriceTo, I: Integer;
  Tmp: PComputerLI;
begin
  PriceFrom := StrToInt(edtFromPrice.Text);
  PriceTo := StrToInt(edtToPrice.Text);
  if PriceFrom > PriceTo then
    ShowMessage('Fill in the price correctly')
  else if ListsModel.TypeCount <> 0 then
    ListsModel.ComputerAssembly(PriceFrom, PriceTo);
end;

procedure TMainForm.btnDeleteComponentClick(Sender: TObject);
var
  PressedBtn: Integer;
begin
  with sgListInfo do
  begin
    PressedBtn := MessageDlg('Are you sure you want to delete this component', mtWarning, [mbYes, mbNo], 0);
    if PressedBtn = 6 then
      ListsModel.DeleteComponent(StrToInt(Cells[0, Row]), StrToInt(Cells[1, Row]));
  end;
  CheckListButtonsState(sgListInfo.Row);
end;

procedure TMainForm.btnDeleteTypeClick(Sender: TObject);
var
  PressedBtn: Integer;
  TmpType: PTypeLI;
begin
  PressedBtn := MessageDlg
    ('Are you sure you want to delete this type. Àll components of this type will be deletd automatically', mtWarning,
    [mbYes, mbNo], 0);
  if PressedBtn = 6 then
    ListsModel.DeleteType(StrToInt(sgListInfo.Cells[0, sgListInfo.Row]));
end;

procedure TMainForm.btnEditComponentClick(Sender: TObject);
var
  Res: TModalResult;
  ComponentInfo: TComponentInfo;
  CompatibleArr: TCompatibleArr;
  Tmp: PComponentLI;
begin
  with sgListInfo do
    Tmp := ListsModel.GetComponent(StrToInt(Cells[0, Row]), StrToInt(Cells[1, Row]));
  ComponentInfo := Tmp^.Info;

  Res := ComponentForm.ShowForEditType(ComponentInfo, CompatibleArr);

  if Res = mrOk then
    ListsModel.SetComponent(Tmp, ComponentInfo, CompatibleArr);
  CompatibleArr := nil;
end;

procedure TMainForm.btnEditTypeClick(Sender: TObject);
var
  Res: TModalResult;
  TypeInfo: TTypeInfo;
  Tmp: PTypeLI;
begin
  Tmp := ListsModel.GetType(StrToInt(sgListInfo.Cells[0, sgListInfo.Row]));
  TypeInfo := Tmp^.Info;

  Res := TypeForm.ShowForEditType(TypeInfo);

  if Res = mrOk then
    ListsModel.SetType(Tmp, TypeInfo);
end;

procedure TMainForm.btnShowCompatibleClick(Sender: TObject);
var
  TmpCompatibleL: PCompatibleList;
  TmpCompatibleI: PCompatibleLI;
  TmpComponent: PComponentLI;
  TypeCode: Integer;
  Res: TModalResult;
begin
  Res := GetTypeForm.GetType(TypeCode);

  if Res = mrOk then
    with sgListInfo do
    begin
      btnAddComponent.Enabled := False;
      cbLists.ItemIndex := -1;
      TmpCompatibleL := ListsModel.GetCompatibleList(StrToInt(Cells[0, Row]));
      if TmpCompatibleL <> nil then
        TmpCompatibleI := TmpCompatibleL^.Header^.Next
      else
        TmpCompatibleI := nil;
      RowCount := 2;
      while TmpCompatibleI <> nil do
      begin
        if (TypeCode = -1) or (TmpCompatibleI^.Info.TypeCode = TypeCode) then
        begin
          TmpComponent := ListsModel.GetComponent(TmpCompatibleI^.Info.ComponentCode, TmpCompatibleI^.Info.TypeCode);
          AddComponentView(TmpComponent^.Info);
        end;
        TmpCompatibleI := TmpCompatibleI^.Next;
      end;
    end;
end;

procedure TMainForm.btnSortDecreaseClick(Sender: TObject);
begin
  ListsModel.SortComputerList(LowerComp);
end;

procedure TMainForm.btnSortIncreaseClick(Sender: TObject);
begin
  ListsModel.SortComputerList(UpperComp);
end;

procedure TMainForm.cbListsChange(Sender: TObject);
var
  TmpType: PTypeLI;
  First, Last: PComponentLI;
  I: Integer;
begin
  if cbLists.Text = 'Components'' types' then
    UpdateTypeList()
  else
    UpdateComponentList(ListsModel.GetComponentListBorders(ListsModel.GetTypeCode(cbLists.Text)));
  CheckListButtonsState(sgListInfo.Row);
  btnAddComponent.Enabled := True;
end;

procedure TMainForm.CheckListButtonsState(Row: Integer);
begin
  if sgListInfo.Cells[0, Row] = '' then
  begin
    btnDeleteComponent.Enabled := False;
    btnDeleteType.Enabled := False;

    btnEditComponent.Enabled := False;
    btnEditType.Enabled := False;

    btnShowCompatible.Enabled := False;
  end
  else
  begin
    btnDeleteComponent.Enabled := True;
    btnDeleteType.Enabled := True;

    btnEditComponent.Enabled := True;
    btnEditType.Enabled := True;

    btnShowCompatible.Enabled := True;
  end;
end;

procedure TMainForm.CheckPCButtonsState;
begin
  if sgComputersInfo.RowCount <= 2 then
  begin
    btnSortDecrease.Enabled := False;
    btnSortIncrease.Enabled := False;
  end
  else
  begin
    btnSortDecrease.Enabled := True;
    btnSortIncrease.Enabled := True;
  end;
end;

procedure TMainForm.DeleteComponentView;
var
  I, J: Integer;
begin
  with sgListInfo do
  begin
    for I := Row + 1 to RowCount - 1 do
      for J := 0 to ColCount - 1 do
        Cells[J, I - 1] := Cells[J, I];
    RowCount := RowCount - 1;
    CheckListButtonsState(Row);
  end;
end;

procedure TMainForm.edtFromPriceChange(Sender: TObject);
begin
  btnBuildPC.Enabled := (edtFromPrice.Text <> '') and (edtToPrice.Text <> '');
end;

procedure TMainForm.edtToPriceChange(Sender: TObject);
begin
  btnBuildPC.Enabled := (edtFromPrice.Text <> '') and (edtToPrice.Text <> '');
end;

procedure TMainForm.FillCompatibleList(CompatibleInfo1: TCompatibleInfo);
var
  I: Integer;
  CompatibleInfo2: TCompatibleInfo;
begin
  with ComponentForm.chlbCompatibleComponents do
    for I := 0 to Items.Count - 1 do
    begin
      if Checked[I] then
      begin
        CompatibleInfo2.ComponentCode := StrToInt(Copy(Items[I], 1, Pos(' ', Items[I]) - 1));
        CompatibleInfo2.TypeCode := ListsModel.GetComponent(CompatibleInfo2.ComponentCode)^.Info.TypeCode;
        ListsModel.AddCompatible(CompatibleInfo1, CompatibleInfo2);
        ListsModel.AddCompatible(CompatibleInfo2, CompatibleInfo1);
      end;
    end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  PressedBtn: Integer;
begin
  if ExitMode = 2 then
  begin
    PressedBtn := MessageDlg('Do you want to save changes', mtWarning, [mbYes, mbNo], 0);
    if PressedBtn = 6 then
      ListsModel.SaveLists('lists\types.info', 'lists\components.info', 'lists\compatible.info');
  end;
  ListsModel.Destroy;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  TmpType: PTypeLI;
  F: file;
begin
  CreateDir('lists');
  CreateDir('computers');
  if not FileExists('lists\types.info') then
  begin
    AssignFile(F, 'lists\types.info');
    Rewrite(F);
    CloseFile(F);
  end;
  if not FileExists('lists\components.info') then
  begin
    AssignFile(F, 'lists\components.info');
    Rewrite(F);
    CloseFile(F);
  end;
  if not FileExists('lists\compatible.info') then
  begin
    AssignFile(F, 'lists\compatible.info');
    Rewrite(F);
    CloseFile(F);
  end;
  if not FileExists('computers\orders.txt') then
  begin
    AssignFile(F, 'computers\orders.txt');
    Rewrite(F);
    CloseFile(F);
  end;

  ExitMode := 2;
  sgListInfo.RowHeights[0] := -1;
  sgComputersInfo.RowHeights[0] := -1;

  pnBuildPC.Visible := False;
  pnComponentListButtons.Visible := False;
  pnTypeListButtons.Visible := False;
  ListsModel := TModel.Create;
  ListsModel.ReadLists('lists\types.info', 'lists\components.info', 'lists\compatible.info');
  ListsModel.LastTypeUpdate := AddTypeView;
  ListsModel.OneTypeUpdate := UpdateTypeView;
  ListsModel.TypesUpdate := UpdateTypeList;

  ListsModel.LastComponentUpdate := AddComponentView;
  ListsModel.OneComponentUpdate := UpdateComponentView;
  ListsModel.ComponentDeleteUpdate := DeleteComponentView;

  ListsModel.UpdateComputerView := UpdateComputerList;

  SetControlBox;
end;

procedure TMainForm.menuBuildPCClick(Sender: TObject);
var
  I: Integer;
begin
  btnBuildPC.Enabled := False;
  edtFromPrice.Text := '';
  edtToPrice.Text := '';
  with sgComputersInfo do
  begin
    ColCount := 0;
    RowCount := 0;
    RowHeights[0] := -1;
  end;
  pnBuildPC.Visible := True;
  CheckPCButtonsState;
  pnLists.Visible := False;
end;

procedure TMainForm.menuExitClick(Sender: TObject);
begin
  FExitMode := 0;
  Close;
end;

procedure TMainForm.menuExitSaveClick(Sender: TObject);
begin
  FExitMode := 1;
  ListsModel.SaveLists('lists\types.info', 'lists\components.info', 'lists\compatible.info');
  Close;
end;

procedure TMainForm.menuWatchListsClick(Sender: TObject);
begin
  pnBuildPC.Visible := False;
  pnLists.Visible := True;
end;

procedure TMainForm.SetControlBox;
var
  TmpType: PTypeLI;
  OldItem: string;
  I: Integer;
begin
  OldItem := cbLists.Items[cbLists.ItemIndex];
  cbLists.Clear;
  cbLists.Items.Add('Components'' types');
  cbLists.Items.Add('All components');
  TmpType := ListsModel.TypeList;
  while TmpType <> nil do
  begin
    cbLists.Items.Add(TmpType^.Info.TypeName);
    TmpType := TmpType^.Next;
  end;

  for I := 0 to ListsModel.TypeCount + 1 do
    if OldItem = cbLists.Items[I] then
      cbLists.ItemIndex := I;
end;

procedure TMainForm.sgComputersInfoClick(Sender: TObject);
begin
  with sgComputersInfo do
    if Row <> 1 then
      ComputerForm.ShowComputer(ListsModel.ComputerList[StrToInt(Cells[ColCount - 2, Row])]^.Build);
end;

procedure TMainForm.sgListInfoSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  CheckListButtonsState(ARow);
end;

procedure TMainForm.UpdateComponentList(Borders: TListBorders);
begin
  pnComponentListButtons.Visible := True;
  pnTypeListButtons.Visible := False;

  with sgListInfo do
  begin
    DefaultColWidth := 65;
    DefaultRowHeight := 30;
    ColCount := 6;
    ColWidths[0] := 130;
    ColWidths[1] := 90;
    ColWidths[2] := 250;
    ColWidths[3] := 350;
    RowCount := 2;
    FixedRows := 1;
    Rows[1].Clear;
    RowHeights[RowCount - 1] := 0;
    Cells[0, 0] := 'Component code';
    Cells[1, 0] := 'Type code';
    Cells[2, 0] := 'Component name';
    Cells[3, 0] := 'Description';
    Cells[4, 0] := 'Price';
    Cells[5, 0] := 'In stock';
    if Borders.Last <> nil then
    begin
      Borders.Last := Borders.Last^.Next;
      while Borders.First <> Borders.Last do
      begin
        RowCount := RowCount + 1;
        with Borders.First^.Info do
        begin
          Cells[0, RowCount - 1] := IntToStr(ComponentCode);
          Cells[1, RowCount - 1] := IntToStr(TypeCode);;
          Cells[2, RowCount - 1] := Model;
          Cells[3, RowCount - 1] := Description;
          Cells[4, RowCount - 1] := IntToStr(Price);
          if IsInStock then
            Cells[5, RowCount - 1] := 'Yes'
          else
            Cells[5, RowCount - 1] := 'No';
        end;
        Borders.First := Borders.First^.Next;
      end;
    end;
    CheckListButtonsState(Row);
  end;
end;

procedure TMainForm.UpdateComponentView(ComponentInfo: TComponentInfo);
begin
  with sgListInfo, ComponentInfo do
  begin
    Cells[0, Row] := IntToStr(ComponentCode);
    Cells[1, Row] := IntToStr(TypeCode);;
    Cells[2, Row] := Model;
    Cells[3, Row] := Description;
    Cells[4, Row] := IntToStr(Price);
    if IsInStock then
      Cells[5, Row] := 'Yes'
    else
      Cells[5, Row] := 'No';
  end;
end;

procedure TMainForm.UpdateComputerList;
var
  I: Integer;
  TmpType: PTypeLI;
  Tmp: PComputerLI;
  F: TextFile;
begin
  AssignFile(F, 'computers\builds.txt');
  Rewrite(F);
  with sgComputersInfo do
  begin
    DefaultColWidth := 200;
    DefaultRowHeight := 30;
    ColCount := ListsModel.TypeCount + 2;
    RowCount := 2;
    FixedRows := 1;

    TmpType := ListsModel.TypeList;
    for I := 0 to ListsModel.TypeCount - 1 do
    begin
      Cells[I, 0] := TmpType^.Info.TypeName;
      TmpType := TmpType^.Next;
    end;

    RowHeights[RowCount - 1] := -1;
    ColWidths[ColCount - 2] := -1;
    ColWidths[ColCount - 1] := 80;
    Cols[ColCount - 1].Text := 'Price';

    Tmp := ListsModel.GetComputerList;
    while Tmp <> nil do
    begin
      RowCount := RowCount + 1;
      for I := 0 to ColCount - 3 do
      begin
        Cells[I, RowCount - 1] := Tmp^.Build.Components[I].Model;
        writeln(F, ListsModel.GetType(Tmp^.Build.Components[I].TypeCode)^.Info.TypeName + ': ' + Tmp^.Build.Components
          [I].Model);
      end;
      writeln(F, Tmp^.Build.Price);
      if Tmp^.Build.IsInStock then
        writeln(F, 'In stock')
      else
        writeln(F, 'Not in stock');
      writeln(F, '-----------------------------------');
      Cells[ColCount - 2, RowCount - 1] := IntToStr(Tmp^.Index);
      Cells[ColCount - 1, RowCount - 1] := IntToStr(Tmp^.Build.Price);
      Tmp := Tmp^.Next;
    end;
  end;
  CloseFile(F);
  CheckPCButtonsState;
end;

procedure TMainForm.UpdateTypeList();
var
  TmpType: PTypeLI;
begin
  pnComponentListButtons.Visible := False;
  pnTypeListButtons.Visible := True;

  SetControlBox;

  TmpType := ListsModel.TypeList;
  with sgListInfo do
  begin
    DefaultRowHeight := 30;
    ColCount := 2;
    ColWidths[0] := 100;
    ColWidths[1] := 190;
    RowCount := 2;
    Rows[1].Clear;
    FixedRows := 1;
    RowHeights[RowCount - 1] := 0;
    Cells[0, 0] := 'Type code';
    Cells[1, 0] := 'Type name';
    while TmpType <> nil do
    begin
      RowCount := RowCount + 1;
      with TmpType^.Info do
      begin
        Cells[0, RowCount - 1] := IntToStr(TypeCode);
        Cells[1, RowCount - 1] := TypeName;
      end;
      TmpType := TmpType^.Next;
    end;
    CheckListButtonsState(Row);
  end;
end;

procedure TMainForm.UpdateTypeView(TypeInfo: TTypeInfo);
var
  I: Integer;
begin
  with sgListInfo, cbLists do
  begin
    for I := 0 to Items.Count do
      if Items[I] = Cells[1, Row] then
        Items[I] := TypeInfo.TypeName;
    Cells[1, Row] := TypeInfo.TypeName;
  end;
end;

end.
