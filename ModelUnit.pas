unit ModelUnit;

interface

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
    ComponentCode: Integer;
    Next: PCompatibleLI;
  end;

  PCompatibleList = ^TCompatibleList;

  TCompatibleList = record
    ComponentCode: Integer;
    LastItem: PCompatibleLI;
    List: PCompatibleLI;
    Next: PCompatibleList;
  end;

  TListBorders = record
    First: PComponentLI;
    Last: PComponentLI;
  end;

  TModel = class
  private
    FTypeList: PTypeLI;
    FComponentHeader: PComponentLI;
    FCompatibleList: PCompatibleList;
    FComponentsCount, FTypesCount: Integer;
  public
    constructor Create;
    procedure AddCompatible(const ComponentCode1, ComponentCode2: Integer);
    procedure AddComponent(const Info: TComponentInfo);
    procedure AddType(const Info: TTypeInfo);
    procedure FreeMemory;
    function GetComponent(ComponentCode: Integer; TypeCode: Integer = -1): PComponentLI;
    function GetComponentListBorders(TypeCode: Integer = -1): TListBorders;
    function GetCompatibleList(ComponentCode: Integer): PCompatibleList;
    function GetType(TypeCode: Integer): PTypeLI;
    function GetTypeCode(TypeName: string): Integer;
    function IsCompatible(Code1, Code2: Integer): Boolean;
    procedure SaveLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
    procedure ReadLists(TypeLPath, ComponentLPath, CompatibleLPath: string);

    property ComponentsCount: Integer read FComponentsCount;
    property TypesCount: Integer read FTypesCount;
    property TypeList: PTypeLI read FTypeList;
    property ComponentHeader: PComponentLI read FComponentHeader;
    property CompatibleList: PCompatibleList read FCompatibleList;
  end;

var
  ListsModel: TModel;

implementation

procedure TModel.AddCompatible(const ComponentCode1, ComponentCode2: Integer);
var
  TmpList: PCompatibleList;
  TmpItem: PCompatibleLI;
begin
  TmpList := GetCompatibleList(ComponentCode1);
  new(TmpItem);
  if TmpList <> nil then
    TmpList^.LastItem^.Next := TmpItem
  else
  begin
    new(TmpList);
    TmpList^.Next := FCompatibleList;
    FCompatibleList := TmpList;
    TmpList^.ComponentCode := ComponentCode1;
    TmpList^.List := TmpItem;
  end;
  TmpList^.LastItem := TmpItem;
  TmpItem^.Next := nil;
  TmpItem^.ComponentCode := ComponentCode2;
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
  Inc(FComponentsCount);
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
  Inc(FTypesCount);
end;

constructor TModel.Create;
begin
  FTypeList := nil;
  new(FComponentHeader);
  FComponentHeader^.Next := nil;
  FCompatibleList := nil;

  FComponentsCount := 0;
  FTypesCount := 0;
end;

procedure TModel.FreeMemory;
var
  TmpType: PTypeLI;
  TmpComponent: PComponentLI;
  TmpCompatibleL: PCompatibleList;
  TmpCompatibleI: PCompatibleLI;
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
  begin
    TmpCompatibleL := FCompatibleList;
    while TmpCompatibleL^.List <> nil do
    begin
      TmpCompatibleI := TmpCompatibleL^.List;
      TmpCompatibleL^.List := TmpCompatibleL^.List^.Next;
      Dispose(TmpCompatibleI);
    end;
    FCompatibleList := FCompatibleList^.Next;
    Dispose(TmpCompatibleL);
  end;
end;

function TModel.GetCompatibleList(ComponentCode: Integer): PCompatibleList;
begin
  result := FCompatibleList;
  while (result <> nil) and (result^.ComponentCode <> ComponentCode) do
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
  if TypeName = 'All components' then
    result := -1
  else
  begin
    TmpType := FTypeList;
    while TmpType^.Info.TypeName <> TypeName do
      TmpType := TmpType^.Next;
    result := TmpType^.Info.TypeCode;
  end;
end;

function TModel.IsCompatible(Code1, Code2: Integer): Boolean;
var
  TmpCompatibleL: PCompatibleList;
  TmpCompatibleItem: PCompatibleLI;
begin
  TmpCompatibleL := GetCompatibleList(Code1);
  TmpCompatibleItem := nil;
  if TmpCompatibleL <> nil then
  begin
    TmpCompatibleItem := TmpCompatibleL^.List;
    while (TmpCompatibleItem <> nil) and (TmpCompatibleItem^.ComponentCode <> Code2) do
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
  Code1, Code2: Integer;
  TypeF: file of TTypeInfo;
  ComponentF: file of TComponentInfo;
  CompatibleF: file of Integer;
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
    read(CompatibleF, Code1);
    while Code2 <> -1 do
    begin
      read(CompatibleF, Code2);
      if Code2 <> -1 then
      begin
        AddCompatible(Code1, Code2);
        AddCompatible(Code2, Code1);
      end;
    end;
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
  CompatibleF: file of Integer;
  I: Integer;
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

  I := -1;
  TmpCompatibleList := FCompatibleList;
  AssignFile(CompatibleF, 'lists\compatible.info');
  Rewrite(CompatibleF);
  while TmpCompatibleList <> nil do
  begin
    TmpCompatibleItem := TmpCompatibleList^.List;
    while TmpCompatibleItem <> nil do
    begin
      write(CompatibleF, TmpCompatibleItem^.ComponentCode);
      TmpCompatibleItem := TmpCompatibleItem^.Next;
    end;
    write(CompatibleF, I);
    TmpCompatibleList := TmpCompatibleList^.Next;
  end;
  CloseFile(CompatibleF);
end;

end.
