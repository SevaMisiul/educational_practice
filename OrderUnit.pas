unit OrderUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ModelUnit;

type
  TPaymentMethod = (pmCard = 0, pmCash = 1);

  TOrder = record
    PymentMethod: TPaymentMethod;
    Address: string[100];
    Count: Integer;
  end;

  TOrderForm = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    edtCount: TEdit;
    lbCount: TLabel;
    edtAddress: TEdit;
    lbAddress: TLabel;
    cbPayMethod: TComboBox;
    lbPayMethod: TLabel;
    lbPrice: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    function ShowForMakeOrder(Price: Integer; var Order: TOrder): TModalResult;
  end;

const
  PaymentMethodName: array [TPaymentMethod] of string[30] = ('Card', 'Cash');

var
  OrderForm: TOrderForm;

implementation

{$R *.dfm}
{ TOrderForm }

procedure TOrderForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ModalResult = mrOk) and ((edtCount.Text = '') or (edtAddress.Text = '') or (cbPayMethod.ItemIndex = -1)) then
  begin
    ShowMessage('Fill in required fields');
    CanClose := False;
  end;
end;

procedure TOrderForm.FormCreate(Sender: TObject);
var
  I: TPaymentMethod;
begin
  for I := Low(TPaymentMethod) to High(TPaymentMethod) do
    cbPayMethod.Items.Add(PaymentMethodName[I]);
end;

function TOrderForm.ShowForMakeOrder(Price: Integer; var Order: TOrder): TModalResult;
begin
  edtCount.Text := '';
  edtAddress.Text := '';
  lbPrice.Caption := 'Price: ' + IntToStr(Price);

  result := ShowModal;

  if result = mrOk then
  begin
    Order.PymentMethod := TPaymentMethod(cbPayMethod.ItemIndex);
    Order.Count := StrToInt(edtCount.Text);
    Order.Address := edtAddress.Text;
  end;
end;

end.
