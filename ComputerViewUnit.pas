unit ComputerViewUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, ModelUnit;

type
  TComputerForm = class(TForm)
    scrlbInfo: TScrollBox;
    btnClose: TButton;
    btnMakeOrder: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    procedure ShowComputer(ComputerBuild: TComputerBuild);
  end;

var
  ComputerForm: TComputerForm;

implementation

{$R *.dfm}
{ TComputerForm }

procedure TComputerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  while scrlbInfo.ControlCount <> 0 do
  begin
    while (scrlbInfo.Controls[0] as TPanel).ControlCount <> 0 do
      (scrlbInfo.Controls[0] as TPanel).Controls[0].Destroy;
    scrlbInfo.Controls[0].Destroy;
  end;
end;

procedure TComputerForm.ShowComputer(ComputerBuild: TComputerBuild);
var
  I: Integer;
  pn: TPanel;
  lb: TLabel;
  memo: TMemo;
begin
  for I := 0 to Length(ComputerBuild.Components) - 1 do
  begin
    pn := TPanel.Create(scrlbInfo);
    pn.Parent := scrlbInfo;
    pn.Height := 140;
    pn.Width := 475;
    pn.Top := I * 140;

    lb := TLabel.Create(pn);
    lb.Parent := pn;
    lb.Font.Size := 12;
    lb.Top := 10;
    lb.Left := 10;
    lb.Caption := ListsModel.GetType(ComputerBuild.Components[I].TypeCode)^.Info.TypeName + ':';

    lb := TLabel.Create(pn);
    lb.Parent := pn;
    lb.Font.Size := 12;
    lb.Top := 35;
    lb.Left := 10;
    lb.Caption := 'Model: ' + ComputerBuild.Components[I].Model;

    lb := TLabel.Create(pn);
    lb.Parent := pn;
    lb.Font.Size := 12;
    lb.Top := 60;
    lb.Left := 10;
    lb.Caption := 'Description:';

    lb := TLabel.Create(pn);
    lb.Parent := pn;
    lb.Font.Size := 12;
    lb.Top := 10;
    lb.Left := 340;
    lb.Caption := 'Price: ' + IntToStr(ComputerBuild.Components[I].Price);

    memo := TMemo.Create(pn);
    memo.Parent := pn;
    memo.Font.Size := 12;
    memo.Top := 85;
    memo.Left := 10;
    memo.Text := ComputerBuild.Components[I].Description;
    memo.Height := 45;
    memo.Width := 465;
    memo.ReadOnly := True;
  end;
  btnMakeOrder.Enabled := ComputerBuild.IsInStock;
  ShowModal;
end;

end.
