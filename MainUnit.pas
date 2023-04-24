unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Grids, Vcl.Menus,
  ComponentViewUnit, TypeViewUnit, System.Actions, Vcl.ActnList, ModelUnit;

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
    procedure FormCreate(Sender: TObject);
    procedure cbListsChange(Sender: TObject);
    procedure btnAddComponentClick(Sender: TObject);
    procedure menuExitSaveClick(Sender: TObject);
    procedure menuExitClick(Sender: TObject);
    procedure btnAddTypeClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnEditComponentClick(Sender: TObject);
    procedure btnEditTypeClick(Sender: TObject);
    procedure menuWatchListsClick(Sender: TObject);
    procedure menuBuildPCClick(Sender: TObject);
    procedure btnShowCompatibleClick(Sender: TObject);
    procedure btnDeleteComponentClick(Sender: TObject);
    procedure btnDeleteTypeClick(Sender: TObject);
    procedure SetControlBox;
  private
    FExitMode: Integer;
    procedure FillCompatibleList(Code1: Integer);
    procedure ViewComponentList(Borders: TListBorders);
    procedure ViewTypeList();
  public
    property ExitMode: Integer read FExitMode write FExitMode;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.btnAddComponentClick(Sender: TObject);
var
  TmpType: PTypeLI;
  Res: TListBorders;
  ComponentInfo: TComponentInfo;
  Code1, Code2, I: Integer;
begin
  with ComponentForm do
  begin
    edtModel.Text := '';
    edtPrice.Text := '';
    chbStock.Checked := False;
    mDescription.Text := '';
    cbComponentTypes.Items.Clear;

    if (cbLists.Text = 'All components') or (cbLists.Text = '') then
    begin
      cbComponentTypes.Enabled := True;
      TmpType := ListsModel.TypeList;
      while TmpType <> nil do
      begin
        cbComponentTypes.Items.Add(TmpType^.Info.TypeName);
        TmpType := TmpType^.Next;
      end;
    end
    else
    begin
      with cbComponentTypes do
      begin
        Items.Add(cbLists.Text);
        ItemIndex := 0;
        Enabled := False;
      end;
    end;

    FillListBox;

    ComponentForm.ShowModal;

    if IsSave then
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
      Code1 := ComponentInfo.ComponentCode;
      FillCompatibleList(Code1);
      ListsModel.AddComponent(ComponentInfo);

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
      end;
    end;
  end;
end;

procedure TMainForm.btnAddTypeClick(Sender: TObject);
var
  TypeInfo: TTypeInfo;
begin
  with TypeForm do
  begin
    edtType.Text := '';
    TypeForm.ShowModal;
    if IsSave then
    begin
      TypeInfo.TypeCode := ListsModel.TypeID + 1;
      TypeInfo.TypeName := edtType.Text;
      ListsModel.AddType(TypeInfo);
      with sgListInfo, TypeInfo do
      begin
        RowCount := RowCount + 1;
        Cells[0, RowCount - 1] := IntToStr(TypeCode);
        Cells[1, RowCount - 1] := TypeName;
      end;
      cbLists.Items.Add(TypeInfo.TypeName);
    end;
  end;
end;

procedure TMainForm.btnDeleteComponentClick(Sender: TObject);
var
  PressedBtn: Integer;
begin
  with sgListInfo do
  begin
    if Cells[0, Row] <> '' then
    begin
      PressedBtn := MessageDlg('Are you sure you want to delete this component', mtWarning, [mbYes, mbNo], 0);
      if PressedBtn = 6 then
      begin
        ListsModel.DeleteComponent(StrToInt(Cells[0, Row]), StrToInt(Cells[1, Row]));
        RowHeights[Row] := -1;
        Rows[Row].Clear;
      end;
    end;
  end;
end;

procedure TMainForm.btnDeleteTypeClick(Sender: TObject);
var
  PressedBtn: Integer;
  TmpType: PTypeLI;
begin
  with sgListInfo do
  begin
    if Cells[0, Row] <> '' then
    begin
      PressedBtn :=
        MessageDlg
        ('Are you sure you want to delete this type. �ll components of this type will be deletd automatically',
        mtWarning, [mbYes, mbNo], 0);
      if PressedBtn = 6 then
      begin
        ListsModel.DeleteType(StrToInt(Cells[0, Row]));
        RowHeights[Row] := -1;
        Rows[Row].Clear;
        SetControlBox;
        cbLists.ItemIndex := 0;
      end;
    end;
  end;
end;

procedure TMainForm.btnEditComponentClick(Sender: TObject);
var
  TmpComponent: PComponentLI;
  CurrComaptibleList: PCompatibleList;
  Res: TListBorders;
  I, Code2: Integer;
begin
  with ComponentForm, sgListInfo do
  begin
    if Cells[0, Row] <> '' then
    begin
      edtModel.Text := Cells[2, Row];
      mDescription.Text := Cells[3, Row];
      edtPrice.Text := Cells[4, Row];
      if Cells[5, Row] = 'Yes' then
        chbStock.Checked := True
      else
        chbStock.Checked := False;
      with cbComponentTypes do
      begin
        Items.Clear;
        Items.Add(ListsModel.GetType(StrToInt(Cells[1, Row]))^.Info.TypeName);
        ItemIndex := 0;
        Enabled := False;
      end;

      FillListBox;

      CurrComaptibleList := ListsModel.GetCompatibleList(StrToInt(Cells[0, Row]));
      with chlbCompatibleComponents do
        for I := 0 to Items.Count - 1 do
        begin
          Code2 := StrToInt(Copy(Items[I], 1, Pos(' ', Items[I]) - 1));
          Checked[I] := ListsModel.IsCompatible(CurrComaptibleList, Code2);
        end;

      ComponentForm.ShowModal;

      if IsSave then
      begin
        TmpComponent := ListsModel.GetComponent(StrToInt(Cells[0, Row]), StrToInt(Cells[1, Row]));
        with TmpComponent.Info do
        begin
          Model := edtModel.Text;
          Price := StrToInt(edtPrice.Text);
          IsInStock := chbStock.Checked;
          Description := mDescription.Text;
        end;

        ListsModel.DeleteCompatibleList(CurrComaptibleList);
        FillCompatibleList(StrToInt(Cells[0, Row]));

        Cells[2, Row] := edtModel.Text;
        Cells[3, Row] := mDescription.Text;;
        Cells[4, Row] := edtPrice.Text;
        if chbStock.Checked then
          Cells[5, Row] := 'Yes'
        else
          Cells[5, Row] := 'No';
      end;
    end;
  end;
end;

procedure TMainForm.btnEditTypeClick(Sender: TObject);
var
  I: Integer;
begin
  with TypeForm, sgListInfo do
  begin
    if Cells[0, Row] <> '' then
    begin
      edtType.Text := Cells[1, Row];
      TypeForm.ShowModal;
      if IsSave then
      begin
        ListsModel.GetType(StrToInt(Cells[0, Row]))^.Info.TypeName := edtType.Text;
        with cbLists do
          for I := 0 to Items.Count do
            if Items[I] = Cells[1, Row] then
              Items[I] := edtType.Text;
        Cells[1, Row] := edtType.Text;
      end;
    end;
  end;
end;

procedure TMainForm.btnShowCompatibleClick(Sender: TObject);
var
  TmpCompatibleL: PCompatibleList;
  TmpCompatibleI: PCompatibleLI;
  TmpComponent: PComponentLI;
  I: Integer;
begin
  with sgListInfo do
  begin
    if Cells[0, Row] <> '' then
    begin
      cbLists.ItemIndex := -1;
      I := 1;

      TmpCompatibleL := ListsModel.GetCompatibleList(StrToInt(Cells[0, Row]));
      if TmpCompatibleL <> nil then
        TmpCompatibleI := TmpCompatibleL^.Header^.Next
      else
        TmpCompatibleI := nil;
      DefaultColWidth := 65;
      DefaultRowHeight := 30;
      ColCount := 6;
      ColWidths[0] := 130;
      ColWidths[1] := 90;
      ColWidths[2] := 250;
      ColWidths[3] := 300;
      RowCount := 2;
      Rows[1].Clear;
      FixedRows := 1;
      Cells[0, 0] := 'Component code';
      Cells[1, 0] := 'Type code';
      Cells[2, 0] := 'Component name';
      Cells[3, 0] := 'Description';
      Cells[4, 0] := 'Price';
      Cells[5, 0] := 'In stock';
      while TmpCompatibleI <> nil do
      begin
        TmpComponent := ListsModel.GetComponent(TmpCompatibleI^.ComponentCode);
        with TmpComponent^.Info do
        begin
          Cells[0, I] := IntToStr(ComponentCode);
          Cells[1, I] := IntToStr(TypeCode);;
          Cells[2, I] := Model;
          Cells[3, I] := Description;
          Cells[4, I] := IntToStr(Price);
          if IsInStock then
            Cells[5, I] := 'Yes'
          else
            Cells[5, I] := 'No';
        end;
        TmpCompatibleI := TmpCompatibleI^.Next;
        RowCount := RowCount + 1;
        Inc(I);
      end;
      RowHeights[RowCount - 1] := -1;
    end
  end;
end;

procedure TMainForm.cbListsChange(Sender: TObject);
var
  TmpType: PTypeLI;
  First, Last: PComponentLI;
  I: Integer;
begin
  if cbLists.Text = 'Components'' types' then
  begin
    pnComponentListButtons.Visible := False;
    pnTypeListButtons.Visible := True;
    ViewTypeList();
  end
  else
  begin
    pnComponentListButtons.Visible := True;
    pnTypeListButtons.Visible := False;
    ViewComponentList(ListsModel.GetComponentListBorders(ListsModel.GetTypeCode(cbLists.Text)));
  end;
end;

procedure TMainForm.FillCompatibleList(Code1: Integer);
var
  I, Code2: Integer;
begin
  with ComponentForm.chlbCompatibleComponents do
    for I := 0 to Items.Count - 1 do
    begin
      if Checked[I] then
      begin
        Code2 := StrToInt(Copy(Items[I], 1, Pos(' ', Items[I]) - 1));
        ListsModel.AddCompatible(Code1, Code2);
        ListsModel.AddCompatible(Code2, Code1);
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
  ListsModel.FreeMemory;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  TmpType: PTypeLI;
  F: file;
begin
  CreateDir('lists');
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

  ExitMode := 2;
  sgListInfo.RowHeights[0] := -1;
  sgComputersInfo.RowHeights[0] := -1;

  pnBuildPC.Visible := False;
  pnComponentListButtons.Visible := False;
  pnTypeListButtons.Visible := False;
  ListsModel := TModel.Create;
  ListsModel.ReadLists('lists\types.info', 'lists\components.info', 'lists\compatible.info');

  SetControlBox;
end;

procedure TMainForm.menuBuildPCClick(Sender: TObject);
begin
  pnBuildPC.Visible := True;
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
begin
  cbLists.Clear;
  cbLists.Items.Add('Components'' types');
  cbLists.Items.Add('All components');
  TmpType := ListsModel.TypeList;
  while TmpType <> nil do
  begin
    cbLists.Items.Add(TmpType^.Info.TypeName);
    TmpType := TmpType^.Next;
  end;
end;

procedure TMainForm.ViewComponentList(Borders: TListBorders);
var
  I: Integer;
begin
  if cbLists.Text = '' then
    cbLists.ItemIndex := 1;
  I := 1;
  with sgListInfo do
  begin
    DefaultColWidth := 65;
    DefaultRowHeight := 30;
    ColCount := 6;
    ColWidths[0] := 130;
    ColWidths[1] := 90;
    ColWidths[2] := 250;
    ColWidths[3] := 300;
    RowCount := 2;
    FixedRows := 1;
    Rows[1].Clear;
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
        with Borders.First^.Info do
        begin
          Cells[0, I] := IntToStr(ComponentCode);
          Cells[1, I] := IntToStr(TypeCode);;
          Cells[2, I] := Model;
          Cells[3, I] := Description;
          Cells[4, I] := IntToStr(Price);
          if IsInStock then
            Cells[5, I] := 'Yes'
          else
            Cells[5, I] := 'No';
        end;
        Borders.First := Borders.First^.Next;
        RowCount := RowCount + 1;
        Inc(I);
      end;
    end;
    RowHeights[RowCount - 1] := -1;
  end
end;

procedure TMainForm.ViewTypeList();
var
  TmpType: PTypeLI;
  I: Integer;
begin
  I := 1;
  TmpType := ListsModel.TypeList;
  with sgListInfo do
  begin
    DefaultColWidth := 100;
    DefaultRowHeight := 30;
    ColCount := 2;
    RowCount := 2;
    Rows[1].Clear;
    FixedRows := 1;
    Cells[0, 0] := 'Type code';
    Cells[1, 0] := 'Type name';
    while TmpType <> nil do
    begin
      with TmpType^.Info do
      begin
        Cells[0, I] := IntToStr(TypeCode);
        Cells[1, I] := TypeName;
      end;
      TmpType := TmpType^.Next;
      RowCount := RowCount + 1;
      Inc(I);
    end;
    RowHeights[RowCount - 1] := -1;
  end
end;

end.
