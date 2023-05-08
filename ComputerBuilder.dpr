program ComputerBuilder;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  ComponentViewUnit in 'ComponentViewUnit.pas' {ComponentForm},
  TypeViewUnit in 'TypeViewUnit.pas' {TypeForm},
  ModelUnit in 'ModelUnit.pas',
  ComputerViewUnit in 'ComputerViewUnit.pas' {ComputerForm},
  OrderUnit in 'OrderUnit.pas' {OrderForm},
  GetTypeUnit in 'GetTypeUnit.pas' {GetTypeForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TComponentForm, ComponentForm);
  Application.CreateForm(TTypeForm, TypeForm);
  Application.CreateForm(TComputerForm, ComputerForm);
  Application.CreateForm(TOrderForm, OrderForm);
  Application.CreateForm(TGetTypeForm, GetTypeForm);
  Application.Run;
end.
