unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Grids, Vcl.Menus, ViewUnit,
  AddComponentUnit;

type
  TTypeInfo = record
    TypeCode: Integer;
    TypeName: string[20];
  end;

  TComponentInfo = record
    ComponentCode: Integer;
    TypeCode: Integer;
    Model: string[20];
    Description: string[100];
    Price: Integer;
    IsInStock: Boolean;
  end;

  TCompatibleInfo = record
    ComponentCode1: Integer;
    ComponentCode2: Integer;
  end;

  PComponentLI = ^TComponentLI;

  TComponentLI = record
    Info: TComponentInfo;
    Next: PComponentLI;
  end;

  PTypeLI = ^TTypeLI;

  TTypeLI = record
    Info: TTypeInfo;
    Last: PComponentLI;
    Next: PTypeLI;
  end;

  PCompatibleLI = ^TCompatibleLI;

  TCompatibleLI = record
    Info: TCompatibleInfo;
    Next: PCompatibleLI;
  end;

  TListBorders = record
    First: PComponentLI;
    Last: PComponentLI;
  end;

  TMainForm = class(TForm)
    MenuBar: TMainMenu;
    menuFile: TMenuItem;
    menuExitSave: TMenuItem;
    menuExit: TMenuItem;
    menuBuildPC: TMenuItem;
    pnLists: TPanel;
    pnListItemButtons: TPanel;
    btnEditItem: TButton;
    btnAddComponent: TButton;
    btnDeleteItem: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure cbListsChange(Sender: TObject);
    procedure btnAddComponentClick(Sender: TObject);
    procedure menuExitSaveClick(Sender: TObject);
    procedure menuExitClick(Sender: TObject);
  private
    TypeList: PTypeLI;
    ComponentHeader: PComponentLI;
    CompatibleList: PCompatibleLI;
    ComponentsCount, TypesCount: Integer;
    procedure AddType(var P: PTypeLI; const Info: TTypeInfo);
    procedure AddComponent(const Info: TComponentInfo);
    procedure AddCompatible(var P: PCompatibleLI; const Info: TCompatibleInfo);
    procedure ViewComponentList(Borders: TListBorders);
    procedure ViewTypeList(P: PTypeLI);
    function GetComponentListBorders(TypeName: string = ''): TListBorders;
  public

  end;

var
  TypeF: file of TTypeInfo;
  ComponentF: file of TComponentInfo;
  CompatibleF: file of TCompatibleInfo;
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.AddCompatible(var P: PCompatibleLI;
  const Info: TCompatibleInfo);
var
  Tmp: PCompatibleLI;
begin
  new(Tmp);
  Tmp^.Info := Info;
  Tmp^.Next := P;
  P := Tmp;
end;

procedure TMainForm.AddComponent(const Info: TComponentInfo);
var
  Tmp, LastComponent: PComponentLI;
  PrevType, CurrType: PTypeLI;
begin
  new(Tmp);

  CurrType := TypeList;
  while CurrType^.Info.TypeCode <> Info.TypeCode do
    CurrType := CurrType^.Next;
  PrevType := CurrType;
  while (PrevType <> nil) and (PrevType^.Last = nil) do
    PrevType := PrevType^.Next;

  if PrevType = nil then
    LastComponent := ComponentHeader
  else
    LastComponent := PrevType^.Last;

  CurrType^.Last := Tmp;

  Tmp^.Info := Info;
  Tmp^.Next := LastComponent^.Next;
  LastComponent^.Next := Tmp;

end;

procedure TMainForm.AddType(var P: PTypeLI; const Info: TTypeInfo);
var
  Tmp: PTypeLI;
begin
  new(Tmp);
  Tmp^.Info := Info;
  Tmp^.Next := P;
  Tmp^.Last := nil;
  P := Tmp;
end;

procedure TMainForm.btnAddComponentClick(Sender: TObject);
var
  TmpType: PTypeLI;
  Res: TListBorders;
  ComponentInfo: TComponentInfo;
begin
  AddComponentForm.cbComponentTypes.Items.Clear;
  if cbLists.Text = 'All components' then
  begin
    AddComponentForm.cbComponentTypes.Enabled := True;
    TmpType := TypeList;
    while TmpType <> nil do
    begin
      AddComponentForm.cbComponentTypes.Items.Add(TmpType^.Info.TypeName);
      TmpType := TmpType^.Next;
    end;
  end
  else
  begin
    with AddComponentForm.cbComponentTypes do
    begin
      Items.Add(cbLists.Text);
      ItemIndex := 0;
      Enabled := False;
    end;
  end;

  Res := GetComponentListBorders;
  if Res.Last <> nil then
    Res.Last := Res.Last^.Next;
  AddComponentForm.chlbCompatibleComponents.Items.Clear;

  while Res.First <> Res.Last do
  begin
    AddComponentForm.chlbCompatibleComponents.Items.Add(Res.First^.Info.Model);
    Res.First := Res.First^.Next;
  end;

  AddComponentForm.ShowModal;

  with AddComponentForm do
    if IsSave then
    begin
      with ComponentInfo do
      begin
        ComponentCode := ComponentsCount;
        TmpType := TypeList;
        while TmpType^.Info.TypeName <> cbComponentTypes.Text do
          TmpType := TmpType^.Next;
        TypeCode := TmpType^.Info.TypeCode;
        Model := edtModel.Text;
        Price := StrToInt(edtPrice.Text);
        IsInStock := chbStock.Checked;
        Description := mDescription.Text;
      end;
      Inc(ComponentsCount);
      AddComponent(ComponentInfo);
    end;

  ViewComponentList(GetComponentListBorders(cbLists.Text));
end;

procedure TMainForm.cbListsChange(Sender: TObject);
var
  TmpType: PTypeLI;
  First, Last: PComponentLI;
  I: Integer;
begin
  if cbLists.Text = 'Components'' types' then
  begin
    btnAddComponent.Visible := False;
    btnAddType.Visible := True;
    ViewTypeList(TypeList);
  end
  else
  begin
    btnAddComponent.Visible := True;
    btnAddType.Visible := False;
    if cbLists.Text = 'All components' then
      ViewComponentList(GetComponentListBorders)
    else
      ViewComponentList(GetComponentListBorders(cbLists.Text));
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  TypeInfo: TTypeInfo;
  ComponentInfo: TComponentInfo;
  CompatibleInfo: TCompatibleInfo;
  TmpTypeList: PTypeLI;
begin

  pnBuildPC.Visible := False;

  TypeList := nil;
  new(ComponentHeader);
  ComponentHeader^.Next := nil;
  CompatibleList := nil;

  ComponentsCount := 0;
  TypesCount := 0;

  AssignFile(TypeF, 'lists\types.info');
  Reset(TypeF);
  while not EOF(TypeF) do
  begin
    read(TypeF, TypeInfo);
    AddType(TypeList, TypeInfo);
    Inc(TypesCount);
    cbLists.Items.Add(TypeInfo.TypeName);
  end;
  CloseFile(TypeF);

  AssignFile(ComponentF, 'lists\components.info');
  Reset(ComponentF);
  while not EOF(ComponentF) do
  begin
    read(ComponentF, ComponentInfo);
    AddComponent(ComponentInfo);
    Inc(ComponentsCount);
  end;
  CloseFile(ComponentF);

  AssignFile(CompatibleF, 'lists\compatible.info');
  Reset(CompatibleF);
  while not EOF(CompatibleF) do
  begin
    read(CompatibleF, CompatibleInfo);
    AddCompatible(CompatibleList, CompatibleInfo);
  end;
  CloseFile(CompatibleF);

end;

function TMainForm.GetComponentListBorders(TypeName: string = ''): TListBorders;
var
  TmpType: PTypeLI;
begin
  TmpType := TypeList;
  if TypeName = 'All components' then
    TypeName := '';

  if TypeName <> '' then
  begin
    while TmpType^.Info.TypeName <> TypeName do
      TmpType := TmpType^.Next;
    result.Last := TmpType^.Last;

    TmpType := TmpType^.Next;
  end;
  while (TmpType <> nil) and (TmpType^.Last = nil) do
    TmpType := TmpType^.Next;
  if TypeName <> '' then
    if TmpType = nil then
      result.First := ComponentHeader^.Next
    else
      result.First := TmpType^.Last^.Next
  else
  begin
    if TmpType = nil then
      result.Last := nil
    else
      result.Last := TmpType^.Last;

    result.First := ComponentHeader^.Next;
  end;
end;

procedure TMainForm.menuExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.menuExitSaveClick(Sender: TObject);
begin
  AssignFile(TypeF, 'lists\types.info');
  Rewrite(TypeF);
  while TypeList <> nil do
  begin
    write(TypeF, TypeList^.Info);
    TypeList := TypeList^.Next;
  end;
  CloseFile(TypeF);

  AssignFile(ComponentF, 'lists\components.info');
  Rewrite(ComponentF);
  ComponentHeader := ComponentHeader^.Next;
  while ComponentHeader <> nil do
  begin
    write(ComponentF, ComponentHeader^.Info);
    ComponentHeader := ComponentHeader^.Next;
  end;
  CloseFile(ComponentF);

  AssignFile(CompatibleF, 'lists\compatible.info');
  Rewrite(CompatibleF);
  while CompatibleList <> nil do
  begin
    write(CompatibleF, CompatibleList^.Info);
    CompatibleList := CompatibleList^.Next;
  end;
  CloseFile(CompatibleF);

  Close;
end;

procedure TMainForm.ViewComponentList(Borders: TListBorders);
var
  I: Integer;
begin
  sgListInfo.Rows[1].Clear;
  I := 1;
  with sgListInfo do
  begin
    DefaultColWidth := 85;
    DefaultRowHeight := 30;
    ColCount := 5;
    ColWidths[0] := 130;
    ColWidths[2] := 300;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := 'Component code';
    Cells[1, 0] := 'Type code';
    Cells[2, 0] := 'Component name';
    Cells[3, 0] := 'Price';
    Cells[4, 0] := 'In stock';
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
          Cells[3, I] := IntToStr(Price);
          if IsInStock then
            Cells[4, I] := 'Yes'
          else
            Cells[4, I] := 'No'
        end;
        Borders.First := Borders.First^.Next;
        RowCount := RowCount + 1;
        Inc(I);
      end;
      RowCount := RowCount - 1;
    end;
  end
end;

procedure TMainForm.ViewTypeList(P: PTypeLI);
var
  I: Integer;
begin
  sgListInfo.Rows[1].Clear;
  I := 1;
  with sgListInfo do
  begin
    DefaultColWidth := 100;
    DefaultRowHeight := 30;
    ColCount := 2;
    RowCount := 2;
    FixedRows := 1;
    Cells[0, 0] := 'Type code';
    Cells[1, 0] := 'Type name';
    while P <> nil do
    begin
      with P^.Info do
      begin
        Cells[0, I] := IntToStr(TypeCode);
        Cells[1, I] := TypeName;
      end;
      P := P^.Next;
      RowCount := RowCount + 1;
      Inc(I);
    end;
    if RowCount <> 2 then
      RowCount := RowCount - 1;
  end
end;

end.
