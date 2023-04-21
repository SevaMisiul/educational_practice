object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 754
  ClientWidth = 1219
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
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnLists: TPanel
    Left = 0
    Top = 0
    Width = 1219
    Height = 754
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object pnListItemButtons: TPanel
      Left = 919
      Top = 21
      Width = 300
      Height = 733
      Align = alRight
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
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
      object btnAddComponent: TButton
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
        OnClick = btnAddComponentClick
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
      object btnAddType: TButton
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
        TabOrder = 4
      end
    end
    object sgListInfo: TStringGrid
      Left = 0
      Top = 21
      Width = 919
      Height = 733
      Align = alClient
      ColCount = 1
      DefaultColWidth = 30
      DefaultRowHeight = 30
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
      ParentFont = False
      TabOrder = 1
    end
    object cbLists: TComboBox
      Left = 0
      Top = 0
      Width = 1219
      Height = 21
      Align = alTop
      Style = csDropDownList
      TabOrder = 2
      OnChange = cbListsChange
      Items.Strings = (
        'Components'#39' types'
        'All components')
    end
  end
  object pnBuildPC: TPanel
    Left = 0
    Top = 0
    Width = 1219
    Height = 754
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object sgComputersInfo: TStringGrid
      Left = 0
      Top = 0
      Width = 919
      Height = 754
      Align = alClient
      ColCount = 1
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect, goFixedRowDefAlign]
      TabOrder = 0
    end
    object pnBuildPCButtons: TPanel
      Left = 919
      Top = 0
      Width = 300
      Height = 754
      Align = alRight
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
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
      object btnBuildPC: TButton
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
    Left = 1104
    Top = 624
    object menuFile: TMenuItem
      AutoHotkeys = maAutomatic
      Caption = 'File'
      object menuExitSave: TMenuItem
        Caption = 'Exit and save'
        Hint = 'Closes the program saving all changes made'
        OnClick = menuExitSaveClick
      end
      object menuExit: TMenuItem
        Caption = 'Exit'
        Hint = 'Closes the program without saving the changes made'
        OnClick = menuExitClick
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
