unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, TreeTab, TreeComboBox, ExplorerTreeview, ComCtrls, Menus,
  Buttons, SidePanel, StdCtrls, ActnList, ActnMan,
  PlatformDefaultStyleActnCtrls, ActnPopup, ImgList, ToolWin, ActnCtrls,
  ActnMenus, TreeViewNew,ShellAPI;

type
  TMainForm = class(TForm)
    TreeTab1: TTreeTab;
    SidePanelTree: TSidePanel;
    ButtonedEdit1: TButtonedEdit;
    Panel1: TPanel;
    ExplorerTreeComboBox1: TExplorerTreeComboBox;
    SpeedButton3: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    ImageList1: TImageList;
    PopupFilter: TPopupActionBar;
    itleonly1: TMenuItem;
    ActionManager1: TActionManager;
    ActionNewTab: TAction;
    ActionNewSubtab: TAction;
    ActionCloseTab: TAction;
    ActionExit: TAction;
    ActionSelecteBack: TAction;
    ActionSelecteForward: TAction;
    ActionAbout: TAction;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    ActionMainMenuBar1: TActionMainMenuBar;
    SpeedButton7: TSpeedButton;
    TreeViewNew1: TTreeViewNew;
    SpeedButton8: TSpeedButton;
    ActionSearch: TAction;
    PanelFind: TPanel;
    TreeView1: TTreeView;
    Image1: TImage;
    SpeedButton9: TSpeedButton;
    Label1: TLabel;
    Content1: TMenuItem;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    chkArchive: TCheckBox;
    GroupBox3: TGroupBox;
    CheckBox4: TCheckBox;
    CheckBox2: TCheckBox;
    Label2: TLabel;
    rbAllOpenPages: TRadioButton;
    rbSelectedsPages: TRadioButton;
    CheckBox3: TCheckBox;
    ComboBox1: TComboBox;
    SpeedButton10: TSpeedButton;
    SpeedButton11: TSpeedButton;
    SpeedButton12: TSpeedButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    ActionTreeBrowserHelp: TAction;
    procedure ActionNewTabExecute(Sender: TObject);
    procedure ActionNewSubtabExecute(Sender: TObject);
    procedure ActionCloseTabExecute(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TreeView1MouseEnter(Sender: TObject);
    procedure TreeView1MouseLeave(Sender: TObject);
    procedure ActionSelecteBackExecute(Sender: TObject);
    procedure ActionSelecteForwardExecute(Sender: TObject);
    procedure ActionAboutExecute(Sender: TObject);
    procedure ActionSearchExecute(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure rbSelectedsPagesClick(Sender: TObject);
    procedure chkArchiveClick(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure ActionTreeBrowserHelpExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses About;

{$R *.dfm}

procedure TMainForm.ActionSearchExecute(Sender: TObject);
begin
  SidePanelTree.Visible:=not SpeedButton8.Down;
  PanelFind.Visible:= SpeedButton8.Down;
end;

procedure TMainForm.ActionAboutExecute(Sender: TObject);
begin
  AboutBox:= TAboutBox.Create(Self);
  AboutBox.ShowModal;
  AboutBox.Free;
end;

procedure TMainForm.ActionCloseTabExecute(Sender: TObject);
begin
  TreeTab1.Remove(TreeTab1.Selected);
end;

procedure TMainForm.ActionExitExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TMainForm.ActionNewSubtabExecute(Sender: TObject);
begin
  TreeTab1.Selected := TreeTab1.add(TreeTab1.Selected);
end;

procedure TMainForm.ActionNewTabExecute(Sender: TObject);
begin
  TreeTab1.Selected := TreeTab1.add(TreeTab1.Selected.TabSheetParent);
end;

procedure TMainForm.ActionSelecteBackExecute(Sender: TObject);
begin
   TreeTab1.SelectBack;
end;

procedure TMainForm.ActionSelecteForwardExecute(Sender: TObject);
begin
   TreeTab1.SelectForward;
end;

procedure TMainForm.ActionTreeBrowserHelpExecute(Sender: TObject);
begin
  ShellExecute(Handle,'open', 'Explanation.mht',nil, nil, SW_SHOWNORMAL) ;
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  rbSelectedsPages.Enabled:=CheckBox1.Checked;
  rbAllOpenPages.Enabled:=CheckBox1.Checked;
  CheckBox3.Enabled:=rbSelectedsPages.Checked and CheckBox1.Checked;
end;

procedure TMainForm.CheckBox3Click(Sender: TObject);
begin
 if CheckBox3.Checked then
 chkArchive.Checked:=False;
end;

procedure TMainForm.chkArchiveClick(Sender: TObject);
begin
if chkArchive.Checked then
  CheckBox3.Checked:=False;
  SpeedButton10.Visible:=(not chkArchive.Checked and rbSelectedsPages.Checked);
  SpeedButton11.Visible:=SpeedButton10.Visible  ;
  SpeedButton12.Visible:=not SpeedButton10.Visible;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  TreeTab1.Selected := TreeTab1.add(TreeTab1.Selected);
  TreeView1.FullExpand
end;

procedure TMainForm.rbSelectedsPagesClick(Sender: TObject);
begin
  CheckBox3.Enabled:=rbSelectedsPages.Checked;
  SpeedButton10.Visible:=(not chkArchive.Checked and rbSelectedsPages.Checked);
  SpeedButton11.Visible:=SpeedButton10.Visible  ;
  SpeedButton12.Visible:=not SpeedButton10.Visible;
end;

procedure TMainForm.SpeedButton9Click(Sender: TObject);
begin
  SpeedButton8.Down:=False;
  PanelFind.Visible:=False ;
  SidePanelTree.Visible:=True;
end;

procedure TMainForm.TreeView1MouseEnter(Sender: TObject);
begin
  TTreeView(Sender).Color:=$00FFF9F4;
end;

procedure TMainForm.TreeView1MouseLeave(Sender: TObject);
begin
  TTreeView(Sender).Color:=$00FAF0E6;
end;

end.
