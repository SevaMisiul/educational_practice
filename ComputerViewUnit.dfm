object ComputerForm: TComputerForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'ComputerForm'
  ClientHeight = 500
  ClientWidth = 500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object scrlbInfo: TScrollBox
    Left = 0
    Top = 0
    Width = 500
    Height = 450
    BorderStyle = bsNone
    TabOrder = 0
  end
  object btnClose: TButton
    Left = 40
    Top = 464
    Width = 113
    Height = 33
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 8
    ParentFont = False
    TabOrder = 1
  end
  object btnMakeOrder: TButton
    Left = 344
    Top = 464
    Width = 129
    Height = 33
    Caption = 'Make an order'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnMakeOrderClick
  end
end
