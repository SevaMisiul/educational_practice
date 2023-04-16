unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.CheckLst,
  Vcl.Grids, Vcl.Menus;

type
  TMainForm = class(TForm)
    MenuBar: TMainMenu;
    menuFile: TMenuItem;
    menuExitSave: TMenuItem;
    menuExit: TMenuItem;
    menuBuildPC: TMenuItem;
    pnLists: TPanel;
    pnListItemButtons: TPanel;
    btnEditItem: TButton;
    btnAddItem: TButton;
    btnDeleteItem: TButton;
    btnShowCompatible: TButton;
    sgListInfo: TStringGrid;
    cbLists: TComboBox;
    pnBuildPC: TPanel;
    menuWatchLists: TMenuItem;
    StringGrid1: TStringGrid;
    pnBuildPCButtons: TPanel;
    edtFromPrice: TEdit;
    lbTextPrice: TLabel;
    lbFromPrice: TLabel;
    lbToPrice: TLabel;
    edtToPrice: TEdit;
    Button1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}



end.
