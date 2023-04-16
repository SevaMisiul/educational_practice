object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 775
  ClientWidth = 1246
  Color = clBtnFace
  Constraints.MinHeight = 330
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MenuBar
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object pnLists: TPanel
    Left = 0
    Top = 0
    Width = 1246
    Height = 775
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    ExplicitLeft = 216
    ExplicitWidth = 766
    object pnListItemButtons: TPanel
      Left = 946
      Top = 21
      Width = 300
      Height = 754
      Align = alRight
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      ExplicitLeft = 0
      ExplicitHeight = 1246
      object btnEditItem: TButton
        Left = 50
        Top = 90
        Width = 200
        Height = 30
        Caption = 'Edit'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object btnAddItem: TButton
        Left = 50
        Top = 30
        Width = 200
        Height = 30
        Caption = 'Add'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object btnDeleteItem: TButton
        Left = 50
        Top = 150
        Width = 200
        Height = 30
        Caption = 'Delete'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
      object btnShowCompatible: TButton
        Left = 50
        Top = 210
        Width = 200
        Height = 30
        Caption = 'Show compatible'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
      end
    end
    object sgListInfo: TStringGrid
      Left = 0
      Top = 21
      Width = 946
      Height = 754
      Align = alClient
      TabOrder = 1
      ExplicitTop = 16
      ExplicitHeight = 775
    end
    object cbLists: TComboBox
      Left = 0
      Top = 0
      Width = 1246
      Height = 21
      Align = alTop
      Style = csDropDownList
      TabOrder = 2
      ExplicitWidth = 21
    end
  end
  object pnBuildPC: TPanel
    Left = 0
    Top = 0
    Width = 1246
    Height = 775
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitLeft = 632
    ExplicitTop = 367
    ExplicitWidth = 185
    ExplicitHeight = 41
    object StringGrid1: TStringGrid
      Left = 0
      Top = 0
      Width = 946
      Height = 775
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 176
      ExplicitTop = 231
      ExplicitWidth = 624
      ExplicitHeight = 192
    end
    object pnBuildPCButtons: TPanel
      Left = 946
      Top = 0
      Width = 300
      Height = 775
      Align = alRight
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      ExplicitLeft = 952
      object lbTextPrice: TLabel
        Left = 50
        Top = 30
        Width = 187
        Height = 19
        Caption = 'Please, enter a price range'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbFromPrice: TLabel
        Left = 50
        Top = 70
        Width = 34
        Height = 19
        Caption = 'from'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lbToPrice: TLabel
        Left = 50
        Top = 130
        Width = 14
        Height = 19
        Caption = 'to'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object edtFromPrice: TEdit
        Left = 50
        Top = 90
        Width = 200
        Height = 27
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        NumbersOnly = True
        ParentFont = False
        TabOrder = 0
      end
      object edtToPrice: TEdit
        Left = 50
        Top = 150
        Width = 200
        Height = 27
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        NumbersOnly = True
        ParentFont = False
        TabOrder = 1
      end
      object Button1: TButton
        Left = 50
        Top = 210
        Width = 200
        Height = 30
        Caption = 'Build PC'#39's'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
      end
    end
  end
  object MenuBar: TMainMenu
    Left = 592
    Top = 528
    object menuFile: TMenuItem
      AutoHotkeys = maAutomatic
      Caption = 'File'
      object menuExitSave: TMenuItem
        Caption = 'Exit and save'
        Hint = 'Closes the program saving all changes made'
      end
      object menuExit: TMenuItem
        Caption = 'Exit'
        Hint = 'Closes the program without saving the changes made'
      end
    end
    object menuBuildPC: TMenuItem
      Caption = 'Build PC'
    end
    object menuWatchLists: TMenuItem
      Caption = 'Watch Lists'
    end
  end
end
