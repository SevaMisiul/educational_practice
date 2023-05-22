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
    Model: string[25];
    Description: string[100];
    Price: Integer;
    IsInStock: Boolean;
  end;

  TCompatibleInfo = record
    ComponentCode: Integer;
    TypeCode: Integer;
  end;

  TCompatibleArr = array of TCompatibleInfo;

  TComputerArr = array of TComponentInfo;

  TComputerBuild = record
    Components: TComputerArr;
    Price: Integer;
    IsInStock: Boolean;
  end;

  PComputerLI = ^TComputerLI;

  TComputerLI = record
    Build: TComputerBuild;
    Index: Integer;
    Next: PComputerLI;
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

  TOnTypeUpdated = procedure(TypeInfo: TTypeInfo) of object;

  TOnListChanged = procedure of object;

  TOnComponentUpdated = procedure(ComponentInfo: TComponentInfo) of object;

  TComp = function(Price1, Price2: Integer): Boolean;

  TModel = class(TObject)
  private
    FLastTypeUpdate: TOnTypeUpdated;
    FOneTypeUpdate: TOnTypeUpdated;
    FTypesUpdate: TOnListChanged;

    FLastComponentUpdate: TOnComponentUpdated;
    FOneComponentUpdate: TOnComponentUpdated;
    FComponentDeleteUpdate: TOnListChanged;

    FUpdateComputerView: TOnListChanged;
    FTypeList: PTypeLI;
    FIsUpdatingType, FIsUpdatingComponent: Boolean;
    FComponentHeader: PComponentLI;
    FCompatibleList: PCompatibleList;
    FComponentID, FTypeID, FTypeCount: Integer;
    FComputerList: PComputerLI;
    procedure DeleteCompatibleItem(Code1, Code2: Integer);
    function GetComputer(Index: Integer): PComputerLI;
    procedure SetLastTypeUpdate(const Value: TOnTypeUpdated);
    procedure SetTypesUpdate(const Value: TOnListChanged);
    procedure SetOneTypeUpdate(const Value: TOnTypeUpdated);
    procedure SetLastComponentUpdate(const Value: TOnComponentUpdated);
    procedure SetOneComponentUpdate(const Value: TOnComponentUpdated);
    procedure SetComponentsUpdate(const Value: TOnListChanged);
    procedure SetComputerView(const Value: TOnListChanged);
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddCompatible(const CompatibleInfo1, CompatibleInfo2
      : TCompatibleInfo);
    procedure AddComponent(const Info: TComponentInfo;
      CompatibleArr: TCompatibleArr);
    procedure AddType(const Info: TTypeInfo);
    procedure AddComputer(const Build: TComputerArr);
    procedure SortComputerList(Comp: TComp);
    procedure SetCompatibleFromArr(const CompatibleInfo: TCompatibleInfo;
      const Arr: TCompatibleArr);
    procedure SetType(const ListItem: PTypeLI; const TypeInfo: TTypeInfo);
    procedure SetComponent(const ComponentItem: PComponentLI;
      const ComponentInfo: TComponentInfo; const CompatibleArr: TCompatibleArr);
    function GetComponent(ComponentCode: Integer; TypeCode: Integer = -1)
      : PComponentLI;
    function GetComponentListBorders(TypeCode: Integer = -1): TListBorders;
    function GetCompatibleList(ComponentCode: Integer): PCompatibleList;
    function GetType(TypeCode: Integer): PTypeLI;
    function GetTypeCode(TypeName: string): Integer;
    function GetComputerList: PComputerLI;
    function IsCompatible(CompatibleL: PCompatibleList; Code2: Integer)
      : Boolean;
    procedure ComputerAssembly(PriceFrom, PriceTo: Integer);
    procedure SaveLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
    procedure ReadLists(TypeLPath, ComponentLPath, CompatibleLPath: string);
    procedure DeleteComponent(ComponentCode, TypeCode: Integer);
    procedure DeleteType(TypeCode: Integer);
    procedure DeleteCompatibleList(CompatibleL: PCompatibleList);
    procedure DeleteComputerList;
    { properties }
    property LastTypeUpdate: TOnTypeUpdated read FLastTypeUpdate
      write SetLastTypeUpdate;
    property OneTypeUpdate: TOnTypeUpdated read FOneTypeUpdate
      write SetOneTypeUpdate;
    property TypesUpdate: TOnListChanged read FTypesUpdate write SetTypesUpdate;

    property LastComponentUpdate: TOnComponentUpdated read FLastComponentUpdate
      write SetLastComponentUpdate;
    property OneComponentUpdate: TOnComponentUpdated read FOneComponentUpdate
      write SetOneComponentUpdate;
    property ComponentDeleteUpdate: TOnListChanged read FComponentDeleteUpdate
      write SetComponentsUpdate;

    property UpdateComputerView: TOnListChanged read FUpdateComputerView
      write SetComputerView;

    property TypeCount: Integer read FTypeCount;
    property ComputerList[Index: Integer]: PComputerLI read GetComputer;
    property ComponentID: Integer read FComponentID;
    property TypeID: Integer read FTypeID;
    property TypeList: PTypeLI read FTypeList;
    property ComponentHeader: PComponentLI read FComponentHeader;
    property CompatibleList: PCompatibleList read FCompatibleList;
  end;

function UpperComp(Price1, Price2: Integer): Boolean;
function LowerComp(Price1, Price2: Integer): Boolean;

var
  ListsModel: TModel;

implementation

procedure TModel.AddCompatible(const CompatibleInfo1, CompatibleInfo2
  : TCompatibleInfo);
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

procedure TModel.AddComponent(const Info: TComponentInfo;
  CompatibleArr: TCompatibleArr);
var
  Tmp, LastComponent: PComponentLI;
  PrevType, CurrType: PTypeLI;
  CompatibleInfo: TCompatibleInfo;
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

  CompatibleInfo.ComponentCode := Info.ComponentCode;
  CompatibleInfo.TypeCode := Info.TypeCode;

  SetCompatibleFromArr(CompatibleInfo, CompatibleArr);

  if FIsUpdatingComponent and Assigned(LastComponentUpdate) then
    LastComponentUpdate(Info);
end;

procedure TModel.AddComputer(const Build: TComputerArr);
var
  Tmp: PComputerLI;
  IsInStock: Boolean;
  I, Price: Integer;
begin
  IsInStock := True;
  Price := 0;
  new(Tmp);
  Tmp^.Build.Components := Copy(Build, 0, TypeCount);
  for I := 0 to Length(Build) - 1 do
  begin
    IsInStock := IsInStock and Build[I].IsInStock;
    Inc(Price, Build[I].Price);
  end;
  Tmp^.Build.IsInStock := IsInStock;
  Tmp^.Build.Price := Price;
  if FComputerList <> nil then
    Tmp^.Index := FComputerList^.Index + 1
  else
    Tmp^.Index := 0;
  Tmp^.Next := FComputerList;
  FComputerList := Tmp;
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
  Inc(FTypeCount);
  FTypeID := Max(Info.TypeCode, FTypeID);
  if FIsUpdatingType and Assigned(LastTypeUpdate) then
    LastTypeUpdate(Info);
end;

procedure TModel.ComputerAssembly(PriceFrom, PriceTo: Integer);
var
  TmpType: PTypeLI;
  ComputerBuild: TComputerArr;
  CurrCompatibleList: PCompatibleList;
  Borders: TListBorders;

  procedure SetComputer(ComponentType: PTypeLI; ArrIndex, CurrPrice: Integer);
  var
    Component: TComponentInfo;
    TmpCompatibleItem: PCompatibleLI;
    IsCompatibleAll: Boolean;
    I: Integer;
  begin
    if (ComponentType = nil) and (CurrPrice >= PriceFrom) then
      AddComputer(ComputerBuild)
    else if ComponentType <> nil then
    begin
      if CurrCompatibleList <> nil then
        TmpCompatibleItem := CurrCompatibleList^.Header^.Next
      else
        TmpCompatibleItem := nil;
      while TmpCompatibleItem <> nil do
      begin
        with TmpCompatibleItem^.Info do
          if ComponentType^.Info.TypeCode = TypeCode then
          begin
            Component := ListsModel.GetComponent(ComponentCode, TypeCode)^.Info;
            if CurrPrice + Component.Price <= PriceTo then
            begin
              IsCompatibleAll := True;
              for I := 1 to ArrIndex - 1 do
              begin
                IsCompatibleAll := IsCompatibleAll and
                  ListsModel.IsCompatible
                  (ListsModel.GetCompatibleList(ComputerBuild[I].ComponentCode),
                  Component.ComponentCode);
              end;
              if IsCompatibleAll then
              begin
                ComputerBuild[ArrIndex] := Component;
                SetComputer(ComponentType^.Next, ArrIndex + 1,
                  CurrPrice + Component.Price);
              end;
            end;
          end;
        TmpCompatibleItem := TmpCompatibleItem^.Next;
      end;
    end;
  end;

begin
  DeleteComputerList;
  TmpType := ListsModel.TypeList;
  SetLength(ComputerBuild, FTypeCount);
  Borders := ListsModel.GetComponentListBorders(TmpType^.Info.TypeCode);
  if Borders.Last <> nil then
    Borders.Last := Borders.Last^.Next;
  while Borders.First <> Borders.Last do
  begin
    CurrCompatibleList := ListsModel.GetCompatibleList
      (Borders.First^.Info.ComponentCode);
    ComputerBuild[0] := Borders.First^.Info;
    SetComputer(TmpType^.Next, 1, ComputerBuild[0].Price);
    Borders.First := Borders.First^.Next;
  end;

  if Assigned(UpdateComputerView) then
    UpdateComputerView;

  ComputerBuild := nil;
end;

constructor TModel.Create;
begin
  inherited Create;

  FComputerList := nil;
  FTypeList := nil;
  new(FComponentHeader);
  FComponentHeader^.Next := nil;
  FCompatibleList := nil;

  FTypeCount := 0;
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
      DeleteCompatibleItem(TmpCompatibleI^.Info.ComponentCode,
        CompatibleL^.Info.ComponentCode);
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

  if FIsUpdatingComponent and Assigned(ComponentDeleteUpdate) then
    ComponentDeleteUpdate;
end;

procedure TModel.DeleteComputerList;
var
  Tmp: PComputerLI;
begin
  while FComputerList <> nil do
  begin
    Tmp := FComputerList;
    FComputerList := FComputerList^.Next;
    Tmp^.Build.Components := nil;
    Dispose(Tmp);
  end;
end;

procedure TModel.DeleteType(TypeCode: Integer);
var
  ComponentBorders: TListBorders;
  Tmp: PComponentLI;
  TmpType, P: PTypeLI;
begin
  Dec(FTypeCount);
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

  if FIsUpdatingType and Assigned(TypesUpdate) then
    TypesUpdate;
end;

destructor TModel.Destroy;
var
  TmpType: PTypeLI;
  TmpComponent: PComponentLI;
begin
  DeleteComputerList;

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

function TModel.GetComputer(Index: Integer): PComputerLI;
begin
  result := FComputerList;
  while (result <> nil) and (result^.Index <> Index) do
    result := result^.Next;
end;

function TModel.GetComputerList: PComputerLI;
begin
  result := FComputerList;
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

function TModel.IsCompatible(CompatibleL: PCompatibleList;
  Code2: Integer): Boolean;
var
  TmpCompatibleItem: PCompatibleLI;
begin
  TmpCompatibleItem := nil;
  if CompatibleL <> nil then
  begin
    TmpCompatibleItem := CompatibleL^.Header^.Next;
    while (TmpCompatibleItem <> nil) and
      (TmpCompatibleItem^.Info.ComponentCode <> Code2) do
      TmpCompatibleItem := TmpCompatibleItem^.Next;
  end;
  if TmpCompatibleItem = nil then
    result := False
  else
    result := True;
end;

function LowerComp(Price1, Price2: Integer): Boolean;
begin
  result := Price1 <= Price2;
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
  FIsUpdatingType := False;
  AssignFile(TypeF, TypeLPath);
  Reset(TypeF);
  while not EOF(TypeF) do
  begin
    read(TypeF, TypeInfo);
    AddType(TypeInfo);
  end;
  CloseFile(TypeF);
  FIsUpdatingType := True;

  FIsUpdatingComponent := False;
  AssignFile(ComponentF, ComponentLPath);
  Reset(ComponentF);
  while not EOF(ComponentF) do
  begin
    read(ComponentF, ComponentInfo);
    AddComponent(ComponentInfo, nil);
  end;
  CloseFile(ComponentF);
  FIsUpdatingComponent := True;

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

procedure TModel.SetCompatibleFromArr(const CompatibleInfo: TCompatibleInfo;
  const Arr: TCompatibleArr);
var
  I: Integer;
begin
  if Arr <> nil then
    for I := 0 to Length(Arr) - 1 do
    begin
      AddCompatible(CompatibleInfo, Arr[I]);
      AddCompatible(Arr[I], CompatibleInfo);
    end;
end;

procedure TModel.SetComponent(const ComponentItem: PComponentLI;
  const ComponentInfo: TComponentInfo; const CompatibleArr: TCompatibleArr);
var
  CompatibleInfo: TCompatibleInfo;
begin
  ComponentItem^.Info := ComponentInfo;

  CompatibleInfo.ComponentCode := ComponentInfo.ComponentCode;
  CompatibleInfo.TypeCode := ComponentInfo.TypeCode;
  DeleteCompatibleList(GetCompatibleList(ComponentInfo.ComponentCode));
  SetCompatibleFromArr(CompatibleInfo, CompatibleArr);

  if FIsUpdatingComponent and Assigned(OneComponentUpdate) then
    OneComponentUpdate(ComponentInfo);
end;

procedure TModel.SetComponentsUpdate(const Value: TOnListChanged);
begin
  FComponentDeleteUpdate := Value;
end;

procedure TModel.SetComputerView(const Value: TOnListChanged);
begin
  FUpdateComputerView := Value;
end;

procedure TModel.SetLastComponentUpdate(const Value: TOnComponentUpdated);
begin
  FLastComponentUpdate := Value;
end;

procedure TModel.SetLastTypeUpdate(const Value: TOnTypeUpdated);
begin
  FLastTypeUpdate := Value;
end;

procedure TModel.SetOneComponentUpdate(const Value: TOnComponentUpdated);
begin
  FOneComponentUpdate := Value;
end;

procedure TModel.SetOneTypeUpdate(const Value: TOnTypeUpdated);
begin
  FOneTypeUpdate := Value;
end;

procedure TModel.SetType(const ListItem: PTypeLI; const TypeInfo: TTypeInfo);
begin
  ListItem^.Info := TypeInfo;
  if FIsUpdatingType and Assigned(OneTypeUpdate) then
    OneTypeUpdate(TypeInfo);
end;

procedure TModel.SetTypesUpdate(const Value: TOnListChanged);
begin
  FTypesUpdate := Value;
end;

procedure TModel.SortComputerList(Comp: TComp);
var
  LastItem, PrevSwappedItem, PrevLastItem, Tmp, TmpLastNext: PComputerLI;
begin
  LastItem := FComputerList;
  if LastItem <> nil then
    while LastItem^.Next <> nil do
    begin
      LastItem := LastItem^.Next;
    end;

  new(Tmp);
  Tmp^.Next := FComputerList;
  FComputerList := Tmp;

  while LastItem <> FComputerList^.Next do
  begin
    PrevSwappedItem := FComputerList;
    Tmp := FComputerList;
    while Tmp <> LastItem do
    begin
      PrevLastItem := Tmp;
      if Comp(Tmp^.Next^.Build.Price, PrevSwappedItem^.Next^.Build.Price) then
        PrevSwappedItem := Tmp;
      Tmp := Tmp^.Next;
    end;
    if PrevSwappedItem^.Next <> LastItem then
    begin
      Tmp := PrevSwappedItem^.Next;
      TmpLastNext := LastItem^.Next;
      PrevSwappedItem^.Next := LastItem;
      PrevLastItem^.Next := Tmp;
      LastItem^.Next := Tmp^.Next;
      Tmp^.Next := TmpLastNext;
    end;
    LastItem := PrevLastItem;
  end;
  Tmp := FComputerList;
  FComputerList := FComputerList^.Next;
  Dispose(Tmp);
  if Assigned(UpdateComputerView) then
    UpdateComputerView;
end;

function UpperComp(Price1, Price2: Integer): Boolean;
begin
  result := Price1 >= Price2;
end;

end.
