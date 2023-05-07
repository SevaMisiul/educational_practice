program ComputerBuilder;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  ComponentViewUnit in 'ComponentViewUnit.pas' {ComponentForm},
  TypeViewUnit in 'TypeViewUnit.pas' {TypeForm},
  ModelUnit in 'ModelUnit.pas',
  ComputerViewUnit in 'ComputerViewUnit.pas' {ComputerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TComponentForm, ComponentForm);
  Application.CreateForm(TTypeForm, TypeForm);
  Application.CreateForm(TComputerForm, ComputerForm);
  Application.Run;
end.
