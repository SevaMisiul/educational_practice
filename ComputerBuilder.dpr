program ComputerBuilder;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  AddComponentUnit in 'AddComponentUnit.pas' {AddComponentForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAddComponentForm, AddComponentForm);
  Application.Run;
end.
