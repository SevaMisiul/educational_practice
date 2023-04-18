unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.CheckLst,
  Vcl.Grids, Vcl.Menus;

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

  TMainForm = class(TForm)
    MenuBar: TMainMenu;
    menuFile: TMenuItem;
    menuExitSave: TMenuItem;
    menuExit: TMenuItem;
    menuBuildPC: TMenuItem;
    pnLists: TPanel;
    pnListItemButtons: TPanel;
    btnEditItem: TButton;
    btnAddItem: TButton;
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
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure cbListsChange(Sender: TObject);
  private
    TypeList: PTypeLI;
    ComponentList: PComponentLI;
    CompatibleList: PCompatibleLI;
    procedure AddType(var P: PTypeLI; const Info: TTypeInfo);
    procedure AddComponent(var P: PComponentLI; const Info: TComponentInfo);
    procedure AddCompatible(var P: PCompatibleLI; const Info: TCompatibleInfo);
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

procedure TMainForm.AddComponent(var P: PComponentLI;
  const Info: TComponentInfo);
var
  Tmp: PComponentLI;
begin
  new(Tmp);
  Tmp^.Info := Info;
  Tmp^.Next := P;
  P := Tmp;
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

procedure TMainForm.cbListsChange(Sender: TObject);
var
  TmpTypeList: PTypeLI;
  TmpComponentList: PComponentLI;
  TmpCompatibleList: PCompatibleLI;
  I: Integer;
begin
  if cbLists.Text = 'Components'' types' then
  begin
    TmpTypeList := TypeList;
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
      while TmpTypeList <> nil do
      begin
        Cells[0, I] := IntToStr(TmpTypeList^.Info.TypeCode);
        Cells[1, I] := TmpTypeList^.Info.TypeName;
        TmpTypeList := TmpTypeList^.Next;
        RowCount := RowCount + 1;
        Inc(I);
      end;
      if RowCount <> 2 then
        RowCount := RowCount - 1;
    end
  end
  else if cbLists.Text = 'All components' then
  begin
    TmpComponentList := ComponentList;
    I := 1;
    with sgListInfo do
    begin
      DefaultColWidth := 150;
      DefaultRowHeight := 30;
      ColCount := 6;
      RowCount := 2;
      FixedRows := 1;
      Cells[0, 0] := 'Component code';
      Cells[1, 0] := 'Type code';
      Cells[2, 0] := 'Component name';
      Cells[3, 0] := 'Description';
      Cells[4, 0] := 'Price';
      Cells[5, 0] := 'In stock';
      while TmpComponentList <> nil do
      begin
        with TmpComponentList^.Info do
        begin
          Cells[0, I] := IntToStr(ComponentCode);
          Cells[1, I] := IntToStr(TypeCode);;
          Cells[2, I] := Name;
          Cells[3, I] := Description;
          Cells[4, I] := IntToStr(Price);
          if IsInStock then
            Cells[5, I] := 'Yes'
          else
            Cells[5, I] := 'No'
        end;
        TmpComponentList := TmpComponentList^.Next;
        RowCount := RowCount + 1;
        Inc(I);
      end;
      if RowCount <> 2 then
        RowCount := RowCount - 1;
    end
  end
  else
  begin

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
  ComponentList := nil;
  CompatibleList := nil;

  AssignFile(TypeF, 'lists\types.info');
  Reset(TypeF);
  while not EOF(TypeF) do
  begin
    read(TypeF, TypeInfo);
    AddType(TypeList, TypeInfo);
    cbLists.Items.Add(TypeInfo.TypeName);
  end;
  CloseFile(TypeF);

  TmpTypeList := TypeList;
  AssignFile(ComponentF, 'lists\components.info');
  Reset(ComponentF);
  while not EOF(ComponentF) do
  begin
    read(ComponentF, ComponentInfo);
    AddComponent(ComponentList, ComponentInfo);
    while TmpTypeList^.Info.TypeCode <> ComponentInfo.TypeCode do
      TmpTypeList := TmpTypeList^.Next;
    TmpTypeList^.Last := ComponentList;
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

  // AssignFile(TypeF, 'types.info');
  // Rewrite(TypeF);
  //
  // with TypeInfo do
  // begin
  // TypeCode := 1;
  // TypeName := 'CPU';
  // end;
  // write(TypeF, TypeInfo);
  // AddType(TypesList, TypeInfo);
  //
  // with TypeInfo do
  // begin
  // TypeCode := 2;
  // TypeName := 'HDD';
  // end;
  // write(TypeF, TypeInfo);
  // AddType(TypesList, TypeInfo);
  //
  // with TypeInfo do
  // begin
  // TypeCode := 3;
  // TypeName := 'SDD';
  // end;
  // write(TypeF, TypeInfo);
  // AddType(TypesList, TypeInfo);
  //
  //
  // CloseFile(TypeF);

end;

end.
