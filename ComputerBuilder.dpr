program ComputerBuilder;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  ComponentUnit in 'ComponentUnit.pas' {ComponentForm},
  TypeUnit in 'TypeUnit.pas' {AddTypeForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TComponentForm, ComponentForm);
  Application.CreateForm(TAddTypeForm, AddTypeForm);
  Application.Run;
end.
