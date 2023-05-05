unit ModelUnit;

interface

uses math;

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
    ComponentCode: Integer;
    TypeCode: Integer;
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

  PCompatibleList = ^TCompatibleList;

  TCompatibleList = record
    Info: TCompatibleInfo;
    LastItem: PCompatibleLI;
    Header: PCompatibleLI;
    Next: PCompatibleList;
  end;

  TListBorders = record
    First: PComponentLI;
    Last: PComponentLI;
  end;

  TModel = class(TObject)
  private
    FTypeList: PTypeLI;
    FComponentHeader: PComponentLI;
    FCompatibleList: PCompatibleList;
    FComponentID, FTypeID: Integer;
    procedure DeleteCompatibleItem(Code1, Code2: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddCompatible(const CompatibleInfo1, CompatibleInfo2: TCompatibleInfo);
    procedure AddComponent(const Info: TComponentInfo);
    procedure AddType(const Info: TTypeInfo);
    function GetComponent(ComponentCode: Integer; TypeCode: Integer = -1): PComponentLI;
    function GetComponentListBorders(TypeCode: Integer = -1): TListBorders;
    function GetCompatibleList(ComponentCode: Integer): PCompatibleList;
    function GetType(TypeCode: Integer): PTypeLI;
    function GetTypeCode(TypeName: string): Integer;
    function IsCompatible(CompatibleL: PCompatibleList; Code2: Integer): Boolean;
    procedure SaveLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
    procedure ReadLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
    procedure DeleteComponent(ComponentCode, TypeCode: Integer);
    procedure DeleteType(TypeCode: Integer);
    procedure DeleteCompatibleList(CompatibleL: PCompatibleList);

    property ComponentID: Integer read FComponentID;
    property TypeID: Integer read FTypeID;
    property TypeList: PTypeLI read FTypeList;
    property ComponentHeader: PComponentLI read FComponentHeader;
    property CompatibleList: PCompatibleList read FCompatibleList;
  end;

var
  ListsModel: TModel;

implementation

procedure TModel.AddCompatible(const CompatibleInfo1, CompatibleInfo2: TCompatibleInfo);
var
  Info: TCompatibleInfo;
  TmpList: PCompatibleList;
  TmpItem, Header: PCompatibleLI;
begin
  TmpList := GetCompatibleList(CompatibleInfo1.ComponentCode);
  new(TmpItem);
  if (TmpList <> nil) and (TmpList^.Header <> nil) then
    TmpList^.LastItem^.Next := TmpItem
  else if TmpList = nil then
  begin
    new(TmpList);
    TmpList^.Next := FCompatibleList;
    FCompatibleList := TmpList;
    TmpList^.Info := CompatibleInfo1;
    new(Header);
    TmpList^.Header := Header;
    TmpList^.Header^.Next := TmpItem;
  end;
  TmpList^.LastItem := TmpItem;
  TmpItem^.Next := nil;
  TmpItem^.Info := CompatibleInfo2;
end;

procedure TModel.AddComponent(const Info: TComponentInfo);
var
  Tmp, LastComponent: PComponentLI;
  PrevType, CurrType: PTypeLI;
begin
  new(Tmp);

  CurrType := GetType(Info.TypeCode);
  PrevType := CurrType;
  while (PrevType <> nil) and (PrevType^.Last = nil) do
    PrevType := PrevType^.Next;

  if PrevType = nil then
    LastComponent := FComponentHeader
  else
    LastComponent := PrevType^.Last;

  CurrType^.Last := Tmp;
  Tmp^.Info := Info;
  Tmp^.Next := LastComponent^.Next;
  LastComponent^.Next := Tmp;
  FComponentID := Max(FComponentID, Info.ComponentCode);
end;

procedure TModel.AddType(const Info: TTypeInfo);
var
  Tmp: PTypeLI;
begin
  new(Tmp);
  Tmp^.Info := Info;
  Tmp^.Next := FTypeList;
  Tmp^.Last := nil;
  FTypeList := Tmp;
  FTypeID := Max(Info.TypeCode, FTypeID);
end;

constructor TModel.Create;
begin
  inherited Create;

  FTypeList := nil;
  new(FComponentHeader);
  FComponentHeader^.Next := nil;
  FCompatibleList := nil;

  FComponentID := 0;
  FTypeID := 0;
end;

procedure TModel.DeleteCompatibleItem(Code1, Code2: Integer);
var
  TmpCompatibleL: PCompatibleList;
  TmpCompatibleI, Tmp: PCompatibleLI;
begin
  TmpCompatibleL := GetCompatibleList(Code1);
  if TmpCompatibleL <> nil then
  begin
    TmpCompatibleI := TmpCompatibleL^.Header;
    while TmpCompatibleI^.Next^.Info.ComponentCode <> Code2 do
      TmpCompatibleI := TmpCompatibleI^.Next;
    if TmpCompatibleI^.Next = TmpCompatibleL^.LastItem then
      TmpCompatibleL^.LastItem := TmpCompatibleI;
    Tmp := TmpCompatibleI^.Next;
    TmpCompatibleI^.Next := Tmp^.Next;
    Dispose(Tmp);
  end;
end;

procedure TModel.DeleteCompatibleList(CompatibleL: PCompatibleList);
var
  TmpCompatibleI: PCompatibleLI;
  TmpList, Tmp: PCompatibleList;
begin
  if CompatibleL <> nil then
  begin
    TmpCompatibleI := CompatibleL^.Header;
    CompatibleL^.Header := CompatibleL^.Header^.Next;
    Dispose(TmpCompatibleI);
    while CompatibleL^.Header <> nil do
    begin
      TmpCompatibleI := CompatibleL^.Header;
      DeleteCompatibleItem(TmpCompatibleI^.Info.ComponentCode, CompatibleL^.Info.ComponentCode);
      CompatibleL^.Header := CompatibleL^.Header^.Next;
      Dispose(TmpCompatibleI);
    end;
    TmpList := CompatibleList;
    if CompatibleL = CompatibleList then
    begin
      FCompatibleList := CompatibleL^.Next;
      Dispose(CompatibleL);
    end
    else
    begin
      while TmpList^.Next <> CompatibleL do
        TmpList := TmpList^.Next;
      Tmp := TmpList^.Next;
      TmpList^.Next := TmpList^.Next^.Next;
      Dispose(Tmp);
    end;
  end;
end;

procedure TModel.DeleteComponent(ComponentCode, TypeCode: Integer);
var
  TmpComponent, Tmp: PComponentLI;
  TmpType: PTypeLI;
begin
  TmpComponent := ListsModel.ComponentHeader;
  while TmpComponent^.Next^.Info.ComponentCode <> ComponentCode do
    TmpComponent := TmpComponent^.Next;
  TmpType := ListsModel.GetType(TypeCode);
  if TmpComponent^.Next = TmpType^.Last then
    if TmpComponent^.Info.TypeCode = TmpType^.Info.TypeCode then
      TmpType^.Last := TmpComponent
    else
      TmpType^.Last := nil;
  Tmp := TmpComponent^.Next;
  TmpComponent^.Next := Tmp^.Next;
  Dispose(Tmp);
  DeleteCompatibleList(GetCompatibleList(ComponentCode));
end;

procedure TModel.DeleteType(TypeCode: Integer);
var
  ComponentBorders: TListBorders;
  Tmp: PComponentLI;
  TmpType, P: PTypeLI;
begin
  ComponentBorders := GetComponentListBorders(TypeCode);
  if ComponentBorders.Last <> nil then
  begin
    ComponentBorders.Last := ComponentBorders.Last^.Next;
    Tmp := ComponentBorders.First;
    while ComponentBorders.First <> ComponentBorders.Last do
    begin
      ComponentBorders.First := ComponentBorders.First^.Next;
      DeleteComponent(Tmp^.Info.ComponentCode, Tmp^.Info.TypeCode);
      Tmp := ComponentBorders.First;
    end;
  end;
  TmpType := TypeList;
  if TmpType^.Info.TypeCode = TypeCode then
  begin
    FTypeList := TmpType^.Next;
    Dispose(TmpType);
  end
  else
  begin
    while TmpType^.Next^.Info.TypeCode <> TypeCode do
      TmpType := TmpType^.Next;
    P := TmpType^.Next;
    TmpType^.Next := P^.Next;
    Dispose(P);
  end;
end;

destructor TModel.Destroy;
var
  TmpType: PTypeLI;
  TmpComponent: PComponentLI;
begin
  while FTypeList <> nil do
  begin
    TmpType := FTypeList;
    FTypeList := FTypeList^.Next;
    Dispose(TmpType);
  end;

  while FComponentHeader <> nil do
  begin
    TmpComponent := FComponentHeader;
    FComponentHeader := FComponentHeader^.Next;
    Dispose(TmpComponent);
  end;

  while FCompatibleList <> nil do
    DeleteCompatibleList(FCompatibleList);

  inherited Destroy;
end;

function TModel.GetCompatibleList(ComponentCode: Integer): PCompatibleList;
begin
  result := FCompatibleList;
  while (result <> nil) and (result^.Info.ComponentCode <> ComponentCode) do
    result := result^.Next;
end;

function TModel.GetComponent(ComponentCode, TypeCode: Integer): PComponentLI;
begin
  result := GetComponentListBorders(TypeCode).First;
  while (result <> nil) and (result^.Info.ComponentCode <> ComponentCode) do
    result := result^.Next;
end;

function TModel.GetComponentListBorders(TypeCode: Integer): TListBorders;
var
  TmpType: PTypeLI;
begin
  TmpType := FTypeList;
  if TypeCode <> -1 then
  begin
    TmpType := GetType(TypeCode);
    result.Last := TmpType^.Last;
    TmpType := TmpType^.Next;
  end;

  while (TmpType <> nil) and (TmpType^.Last = nil) do
    TmpType := TmpType^.Next;

  if TypeCode <> -1 then
    if TmpType = nil then
      result.First := FComponentHeader^.Next
    else
      result.First := TmpType^.Last^.Next
  else
  begin
    if TmpType = nil then
      result.Last := nil
    else
      result.Last := TmpType^.Last;

    result.First := FComponentHeader^.Next;
  end;
end;

function TModel.GetType(TypeCode: Integer): PTypeLI;
begin
  result := FTypeList;
  while result^.Info.TypeCode <> TypeCode do
    result := result^.Next;
end;

function TModel.GetTypeCode(TypeName: string): Integer;
var
  TmpType: PTypeLI;
begin
  if (TypeName = 'All components') or (TypeName = '') then
    result := -1
  else
  begin
    TmpType := FTypeList;
    while TmpType^.Info.TypeName <> TypeName do
      TmpType := TmpType^.Next;
    result := TmpType^.Info.TypeCode;
  end;
end;

function TModel.IsCompatible(CompatibleL: PCompatibleList; Code2: Integer): Boolean;
var
  TmpCompatibleItem: PCompatibleLI;
begin
  TmpCompatibleItem := nil;
  if CompatibleL <> nil then
  begin
    TmpCompatibleItem := CompatibleL^.Header^.Next;
    while (TmpCompatibleItem <> nil) and (TmpCompatibleItem^.Info.ComponentCode <> Code2) do
      TmpCompatibleItem := TmpCompatibleItem^.Next;
  end;
  if TmpCompatibleItem = nil then
    result := False
  else
    result := True;
end;

procedure TModel.ReadLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
var
  TypeInfo: TTypeInfo;
  ComponentInfo: TComponentInfo;
  TmpTypeList: PTypeLI;
  CompatibleInfo1, CompatibleInfo2: TCompatibleInfo;
  TypeF: file of TTypeInfo;
  ComponentF: file of TComponentInfo;
  CompatibleF: file of TCompatibleInfo;
begin
  AssignFile(TypeF, TypeLPath);
  Reset(TypeF);
  while not EOF(TypeF) do
  begin
    read(TypeF, TypeInfo);
    AddType(TypeInfo);
  end;
  CloseFile(TypeF);

  AssignFile(ComponentF, ComponentLPath);
  Reset(ComponentF);
  while not EOF(ComponentF) do
  begin
    read(ComponentF, ComponentInfo);
    AddComponent(ComponentInfo);
  end;
  CloseFile(ComponentF);

  AssignFile(CompatibleF, CompatibleLPath);
  Reset(CompatibleF);
  while not EOF(CompatibleF) do
  begin
    read(CompatibleF, CompatibleInfo1);
    while CompatibleInfo2.ComponentCode <> -1 do
    begin
      read(CompatibleF, CompatibleInfo2);
      if CompatibleInfo2.ComponentCode <> -1 then
      begin
        AddCompatible(CompatibleInfo1, CompatibleInfo2);
      end;
    end;
    CompatibleInfo2.ComponentCode := 0;
  end;
  CloseFile(CompatibleF);
end;

procedure TModel.SaveLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
var
  TmpType: PTypeLI;
  TmpComponent: PComponentLI;
  TmpCompatibleList: PCompatibleList;
  TmpCompatibleItem: PCompatibleLI;
  TypeF: file of TTypeInfo;
  ComponentF: file of TComponentInfo;
  CompatibleF: file of TCompatibleInfo;
  ListEnd: TCompatibleInfo;
begin
  TmpType := FTypeList;
  AssignFile(TypeF, 'lists\types.info');
  Rewrite(TypeF);
  while TmpType <> nil do
  begin
    write(TypeF, TmpType^.Info);
    TmpType := TmpType^.Next;
  end;
  CloseFile(TypeF);

  TmpComponent := FComponentHeader;
  AssignFile(ComponentF, 'lists\components.info');
  Rewrite(ComponentF);
  TmpComponent := TmpComponent^.Next;
  while TmpComponent <> nil do
  begin
    write(ComponentF, TmpComponent^.Info);
    TmpComponent := TmpComponent^.Next;
  end;
  CloseFile(ComponentF);

  ListEnd.ComponentCode := -1;
  ListEnd.TypeCode := -1;
  TmpCompatibleList := FCompatibleList;
  AssignFile(CompatibleF, 'lists\compatible.info');
  Rewrite(CompatibleF);
  while TmpCompatibleList <> nil do
  begin
    if TmpCompatibleList^.Header <> nil then
    begin
      write(CompatibleF, TmpCompatibleList^.Info);
      TmpCompatibleItem := TmpCompatibleList^.Header^.Next;
      while TmpCompatibleItem <> nil do
      begin
        write(CompatibleF, TmpCompatibleItem^.Info);
        TmpCompatibleItem := TmpCompatibleItem^.Next;
      end;
      write(CompatibleF, ListEnd);
    end;
    TmpCompatibleList := TmpCompatibleList^.Next;
  end;
  CloseFile(CompatibleF);
end;

end.
