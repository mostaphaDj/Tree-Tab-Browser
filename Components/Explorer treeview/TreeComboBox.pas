unit TreeComboBox;

{$I ..\DEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Imglist, Menus, ExtCtrls ,TreeViewNew
{$IFDEF TMSDOTNET}
  , Types, WinUtils, uxTheme
{$ENDIF}
  ;



type
  TSelectMode = (smSingleClick, smDblClick);

  TDropPosition = (dpAuto, dpDown, dpUp);
  // acceptdrop=true allow tree dropping

  TDropDown = procedure(Sender: TObject; var acceptdrop: boolean) of object;
  // canceled = true ignores SelecteItem and stores Old Edit caption
  // canceled = false on selection and true when Cancel (key=Esc, click outside of tree...)

  TDropUp = procedure(Sender: TObject; canceled: boolean) of object;

  TDropTreeForm = class(TForm)
  private
    FDeActivate: DWORD;
    procedure WMClose(var Msg: TMessage);
    message WM_CLOSE;
    procedure WMActivate(var Message: TWMActivate);
    message WM_ACTIVATE;
    function GetParentWnd: HWnd;
  published
    property DeActivateTime: DWORD read FDeActivate;
  end;

  TTreeComboBox = class(TWinControl)
  private
    { Private declarations }
    FTreeView: TTreeViewNew;
    FDropTreeForm: TDropTreeForm;
    FDropWidth: integer;
    FDropHeight: integer;
    FExpandOnDrop: boolean;
    FCollapseOnDrop: boolean;
    FDropPosition: TDropPosition;
    FOndropDown: TDropDown;
    FOndropUP: TDropUp;
    FSelectMode: TSelectMode;
    FFlat: boolean;
    function GetMinHeight: integer;
    procedure WMSize(var Message: TWMSize);
    message WM_SIZE;
    procedure WMKeyDown(var Message: TWMKeyDown);
    message WM_KEYDOWN;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
    message WM_GETDLGCODE;
    function GetTreeNodes: TTreeNodes;
    procedure SetTreeNodes(const Value: TTreeNodes);
    procedure SetCollapseOnDrop(const Value: boolean);
    procedure SetExpandOnDrop(const Value: boolean);
    procedure SetShowButtons(const Value: boolean);
    function GetShowButtons: boolean;
    function GetShowLines: boolean;
    procedure SetShowLines(const Value: boolean);
    function GetShowRoot: boolean;
    procedure SetShowRoot(const Value: boolean);
    function GetSortType: TSortType;
    procedure SetSortType(const Value: TSortType);
    function GetRightClickSelect: boolean;
    procedure SetRightClickSelect(const Value: boolean);
    function GetRowSelect: boolean;
    procedure SetRowSelect(const Value: boolean);
    function GetIndent: integer;
    procedure SetIndent(const Value: integer);
    function GetImages: TCustomImageList;
    procedure SetImages(const Value: TCustomImageList);
    procedure SetStateImages(const Value: TCustomImageList);
    function GetStateImages: TCustomImageList;
    function GetTreeFont: Tfont;
    procedure SetTreeFont(const Value: Tfont);
    function GetTreeColor: TColor;
    procedure SetTreeColor(const Value: TColor);
    function GetTreeBorder: TBorderStyle;
    procedure SetTreeBorder(const Value: TBorderStyle);
    function GetTreepopupmenu: Tpopupmenu;
    procedure SetTreepopupmenu(const Value: Tpopupmenu);
    function GetSelection: integer;
    procedure SetSelection(const Value: integer);
    procedure SetFlat(const Value: boolean);
    function GetAbsoluteIndex: integer;
  protected
    { Protected declarations }
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MouseButtonDown(Sender: TObject);
    procedure FindTextInNode;
    procedure HideTree(canceled: boolean);
    procedure TreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewKeyPress(Sender: TObject; var Key: Char);
    procedure TreeViewDblClick(Sender: TObject);
    procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure TreeViewBlockChanging(Sender: TObject; Node: TTreeNode;
      var AllowChange: boolean);
    procedure TreeViewExit(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
    function CreateTreeview(AOwner: TComponent): TTreeViewNew; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowTree;
    property AbsoluteIndex: integer read GetAbsoluteIndex;
    property Treeview: TTreeViewNew read FTreeView;
    { Public declarations }
  published
    { Published declarations }
    property SelectMode
      : TSelectMode read FSelectMode write FSelectMode default smDblClick;
    property DropWidth: integer read FDropWidth write FDropWidth;
    property DropHeight: integer read FDropHeight write FDropHeight;
    property Items: TTreeNodes read GetTreeNodes write SetTreeNodes;
    property CollapseOnDrop
      : boolean read FCollapseOnDrop write SetCollapseOnDrop default false;
    property ExpandOnDrop
      : boolean read FExpandOnDrop write SetExpandOnDrop default false;
    property DropPosition
      : TDropPosition read FDropPosition write FDropPosition default dpAuto;
    property Flat: boolean read FFlat write SetFlat default false;
    // ----- Tree properties
    property ShowButtons
      : boolean read GetShowButtons write SetShowButtons default True;
    property ShowLines
      : boolean read GetShowLines write SetShowLines default True;
    property ShowRoot: boolean read GetShowRoot write SetShowRoot default True;
    property SortType
      : TSortType read GetSortType write SetSortType default stNone;
    property RightClickSelect: boolean read GetRightClickSelect write
      SetRightClickSelect default false;
    property RowSelect
      : boolean read GetRowSelect write SetRowSelect default false;
    property Indent: integer read GetIndent write SetIndent;
    property Images: TCustomImageList read GetImages write SetImages;
    property StateImages: TCustomImageList read GetStateImages write
      SetStateImages;
    property TreeFont: Tfont read GetTreeFont write SetTreeFont;
    property TreeColor: TColor read GetTreeColor write SetTreeColor;
    property TreeBorder: TBorderStyle read GetTreeBorder write SetTreeBorder;
    property TreePopupMenu: Tpopupmenu read GetTreepopupmenu write
      SetTreepopupmenu;
    property Selection: integer read GetSelection write SetSelection;
    // --------
    property OnDropDown: TDropDown read FOndropDown write FOndropDown;
    property OnDropUp: TDropUp read FOndropUP write FOndropUP;

    property Align;
    // ------- Edit Properties
{$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
    property DragKind;
{$ENDIF}
    property AutoSize;
{$IFDEF DELPHI7_LVL}
    property BevelKind;
    property BevelInner;
    property BevelOuter;
    property BevelEdges;
{$ENDIF}
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Height;
    property Width;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
{$IFDEF DELPHI4_LVL}
    property OnEndDock;
    property OnStartDock;
{$ENDIF}
  end;

implementation

{ TTreeComboBox }

constructor TTreeComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // SetBounds(left, top, 200, 25);

  if not(csDesigning in ComponentState) then
  begin
{$IFDEF DELPHI4_LVL}
    FDropTreeForm := TDropTreeForm.CreateNew(self, 0);
{$ELSE}
    FDropTreeForm := TDropTreeForm.CreateNew(self);
{$ENDIF}
    with FDropTreeForm do
    begin
      BorderStyle := bsNone;
      FormStyle := fsStayOnTop;
      Visible := false;
      Width := FDropWidth;
      Height := FDropHeight;
      OnClose := FormClose;
    end;
  end;

  if not(csDesigning in ComponentState) then
    FTreeView := CreateTreeview(FDropTreeForm)
  else
  begin
    FTreeView := CreateTreeview(self);
  end;

  with FTreeView do
  begin
    if not(csDesigning in ComponentState) then
      Parent := FDropTreeForm
    else
      Parent := self;

    if not(csDesigning in ComponentState) then
      Align := alClient
    else
      Width := 0;

    ReadOnly := True;
    ShowButtons := True;
    ShowLines := True;
    ShowRoot := True;
    SortType := stNone;
    RightClickSelect := false;
    RowSelect := false;
    if not(csDesigning in ComponentState) then
      Visible := True
    else
      Visible := false;

    OnKeyDown := TreeViewKeyDown;
    OnChange := TreeViewChange;
    OnMouseDown := TreeViewMouseDown;
    OnDblClick := TreeViewDblClick;
    OnKeyPress := TreeViewKeyPress;
  end;

  ControlStyle := ControlStyle - [csSetCaption];
  FDropHeight := 100;
  FDropWidth := self.Width;
  FCollapseOnDrop := false;
  FExpandOnDrop := false;
  FDropPosition := dpAuto;
  FSelectMode := smDblClick;
end;

destructor TTreeComboBox.Destroy;
begin
  // this automatically destroys the child treeview
  if not(csDesigning in ComponentState) then
    FDropTreeForm.Free
  else
    FTreeView.Free;
  inherited Destroy;
end;

function TTreeComboBox.CreateTreeview(AOwner: TComponent): TTreeViewNew;
begin
  Result := TTreeViewNew.Create(AOwner);
end;

procedure TTreeComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TTreeComboBox.MouseButtonDown(Sender: TObject);
begin
  if csDesigning in ComponentState then
    Exit;

  if not FDropTreeForm.Visible and
    (GetTickCount - FDropTreeForm.DeActivateTime > 250) then
    ShowTree;
end;

procedure TTreeComboBox.WMSize(var Message: TWMSize);
var
  MinHeight: integer;
begin
  inherited;

  MinHeight := GetMinHeight;
  { text edit bug: if size to less than minheight, then edit ctrl does
    not display the text }

  if Height < MinHeight then
    Height := MinHeight
end;

function TTreeComboBox.GetMinHeight: integer;
var
  DC: HDC;
  SaveFont: HFont;
  i: integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  i := SysMetrics.tmHeight;
  if i > Metrics.tmHeight then
    i := Metrics.tmHeight;
  Result := Metrics.tmHeight + i div 4 { + GetSystemMetrics(SM_CYBORDER) * 4 } ;
end;

function TTreeComboBox.GetTreeNodes: TTreeNodes;
begin
  Result := FTreeView.Items;
end;

procedure TTreeComboBox.SetTreeNodes(const Value: TTreeNodes);
begin
  FTreeView.Items.Assign(Value);
  FTreeView.Update;
end;

procedure TTreeComboBox.CreateWnd;
begin
  inherited CreateWnd;
  // FTreeview.Name := self.Name + 'tv';
end;

procedure TTreeComboBox.DestroyWnd;
begin
  inherited;
end;

procedure TTreeComboBox.SetCollapseOnDrop(const Value: boolean);
begin
  FCollapseOnDrop := Value;
  if Value then
    FExpandOnDrop := false;
end;

procedure TTreeComboBox.SetExpandOnDrop(const Value: boolean);
begin
  FExpandOnDrop := Value;
  if Value then
    FCollapseOnDrop := false;
end;

procedure TTreeComboBox.TreeViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE, VK_F4:
      begin
        HideTree(True);
        Key := 0;
      end;
    VK_RETURN:
      begin
        HideTree(false);
      end;
  end;
end;

procedure TTreeComboBox.ShowTree;
var
  p: TPoint;
  acpt: boolean;
begin
  if csDesigning in ComponentState then
    Exit;

  if FDropTreeForm.Visible then
    Exit;

  FDropTreeForm.Left := self.Left;
  FDropTreeForm.Top := self.Top;
  FDropTreeForm.Width := FDropWidth;
  FDropTreeForm.Height := FDropHeight;
  p := Point(0, 0);
  p := ClientToScreen(p);
  case FDropPosition of
    dpAuto:
      begin
        if p.Y + FDropHeight >= GetSystemMetrics(SM_CYSCREEN) then
        begin // Up
          FDropTreeForm.Left := p.X;
          FDropTreeForm.Top := p.Y - FDropHeight;
        end
        else
        begin // Down
          FDropTreeForm.Left := p.X;
          FDropTreeForm.Top := p.Y + Height - 2;
        end;
      end;
    dpDown:
      begin
        FDropTreeForm.Left := p.X;
        FDropTreeForm.Top := p.Y + Height - 2;
      end;
    dpUp:
      begin
        FDropTreeForm.Left := p.X;
        FDropTreeForm.Top := p.Y - FDropHeight;
      end;
  end;

  if FCollapseOnDrop then
    FTreeView.FullCollapse;
  if FExpandOnDrop then
    FTreeView.FullExpand;
  acpt := True;

  FTreeView.Items.GetFirstNode; // Force return of correct items count

  FindTextInNode;

  if Assigned(FOndropDown) then
    FOndropDown(self, acpt);

  if acpt then
  begin
    // if FtreeView.Selected <> nil then
    // Text := FtreeView.Selected.Text;
    FDropTreeForm.Show;
    // FTreeView.SetFocus;
  end;
  FTreeView.OnChanging := nil; // Please leave this here, otherwise procedure FindtextinNode must be modified
end;

procedure TTreeComboBox.WMKeyDown(var Message: TWMKeyDown);
begin
  if csDesigning in ComponentState then
    Exit;
  {
    if message.CharCode = VK_RETURN then
    begin
    message.Result := 1;
    Exit;
    end;
    }

  inherited;
  case Message.CharCode of
    VK_DOWN:
      ShowTree;
    VK_F4:
      begin
        if FDropTreeForm.Visible then
          HideTree(false)
        else
          ShowTree;
      end;
  end;
end;

procedure TTreeComboBox.TreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  if csDesigning in ComponentState then
    Exit;

  if FDropTreeForm.Visible then
  begin
    if Assigned(Node) then
      Text := Node.Text;
  end;

end;

procedure TTreeComboBox.TreeViewDblClick(Sender: TObject);
begin
  if FSelectMode = smDblClick then
    HideTree(false);
end;

procedure TTreeComboBox.SetShowButtons(const Value: boolean);
begin
  FTreeView.ShowButtons := Value;
end;

function TTreeComboBox.GetShowButtons: boolean;
begin
  Result := FTreeView.ShowButtons;
end;

function TTreeComboBox.GetShowLines: boolean;
begin
  Result := FTreeView.ShowLines;
end;

procedure TTreeComboBox.SetShowLines(const Value: boolean);
begin
  FTreeView.ShowLines := Value;
end;

function TTreeComboBox.GetShowRoot: boolean;
begin
  Result := FTreeView.ShowRoot;
end;

procedure TTreeComboBox.SetShowRoot(const Value: boolean);
begin
  FTreeView.ShowRoot := Value;
end;

function TTreeComboBox.GetSortType: TSortType;
begin
  Result := FTreeView.SortType;
end;

procedure TTreeComboBox.SetSortType(const Value: TSortType);
begin
  FTreeView.SortType := Value;
end;

function TTreeComboBox.GetRightClickSelect: boolean;
begin
  Result := FTreeView.RightClickSelect;
end;

procedure TTreeComboBox.SetRightClickSelect(const Value: boolean);
begin
  FTreeView.RightClickSelect := Value;
end;

function TTreeComboBox.GetRowSelect: boolean;
begin
  Result := FTreeView.RowSelect;
end;

procedure TTreeComboBox.SetRowSelect(const Value: boolean);
begin
  FTreeView.RowSelect := Value;
end;

function TTreeComboBox.GetIndent: integer;
begin
  Result := FTreeView.Indent;
end;

procedure TTreeComboBox.SetIndent(const Value: integer);
begin
  FTreeView.Indent := Value;
end;

function TTreeComboBox.GetImages: TCustomImageList;
begin
  Result := FTreeView.Images;
end;

procedure TTreeComboBox.SetImages(const Value: TCustomImageList);
begin
  FTreeView.Images := Value;
end;

procedure TTreeComboBox.SetStateImages(const Value: TCustomImageList);
begin
  FTreeView.StateImages := Value;
end;

function TTreeComboBox.GetStateImages: TCustomImageList;
begin
  Result := FTreeView.StateImages;
end;

function TTreeComboBox.GetTreeFont: Tfont;
begin
  Result := FTreeView.Font;
end;

procedure TTreeComboBox.SetTreeFont(const Value: Tfont);
begin
  FTreeView.Font.Assign(Value);
end;

function TTreeComboBox.GetTreeColor: TColor;
begin
  Result := FTreeView.Color;
end;

procedure TTreeComboBox.SetTreeColor(const Value: TColor);
begin
  FTreeView.Color := Value;
end;

procedure TTreeComboBox.TreeViewKeyPress(Sender: TObject; var Key: Char);
begin
  if Key <= #27 then
    Key := #0; // stop beeping
end;

procedure TTreeComboBox.HideTree(canceled: boolean);
begin
  if csDesigning in ComponentState then
    Exit;

  if not FDropTreeForm.Visible then
    Exit;
  FDropTreeForm.Hide;
  Application.CancelHint;
  if Assigned(FTreeView.Selected) then
  begin
    Text := FTreeView.Selected.Text;
  end;
  if Assigned(FOndropUP) then
    FOndropUP(self, canceled);
end;

function TTreeComboBox.GetTreeBorder: TBorderStyle;
begin
  Result := FTreeView.BorderStyle;
end;

procedure TTreeComboBox.SetTreeBorder(const Value: TBorderStyle);
begin
  FTreeView.BorderStyle := Value;
end;

function TTreeComboBox.GetTreepopupmenu: Tpopupmenu;
begin
  Result := FTreeView.PopupMenu;
end;

procedure TTreeComboBox.SetTreepopupmenu(const Value: Tpopupmenu);
begin
  FTreeView.PopupMenu := Value;
end;

procedure TTreeComboBox.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  Message.Result := 1; // Message.Result and DLGC_WANTALLKEYS;
end;

procedure TTreeComboBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if (Key = Char(VK_RETURN)) then
    Key := #0;
end;

procedure TTreeComboBox.FindTextInNode;
var
  i: integer;
  itm, its: TTreeNode;
  sfind, stext: string;
  found: boolean;

  function noopen(Node: TTreeNode): boolean;
  begin
    Result := True;
    if Node = nil then
      Exit;
    while Node.Parent <> nil do
    begin
      Node := Node.Parent;
      if not Node.Expanded then
        Exit;
    end;
    Result := false;
  end;

begin
  sfind := UpperCase(Text);
  itm := nil;
  found := false;

  if FTreeView.Selected <> nil then
  begin
    itm := FTreeView.Selected;
    stext := UpperCase(itm.Text);
    if AnsiPos(sfind, stext) = 1 then
      found := True;
  end;

  if not found then
    repeat
      for i := 0 to FTreeView.Items.count - 1 do
      begin
        // Don't search if AutoOpen disabled and the nodes are not open.
        if noopen(FTreeView.Items[i]) then
          continue;
        stext := UpperCase(FTreeView.Items[i].Text);
        if AnsiPos(sfind, stext) = 1 then
        begin
          itm := FTreeView.Items[i];
          Break;
        end;
      end;
      if length(sfind) > 0 then
        delete(sfind, length(sfind), 1);
    until (itm <> nil) or (sfind = '');

    if itm = nil then
    begin
      FTreeView.OnChanging := TreeViewBlockChanging;
      Exit;
    end;
  its := itm;
  FTreeView.Selected := its;
  FTreeView.Selected.MakeVisible;
end;

procedure TTreeComboBox.TreeViewBlockChanging(Sender: TObject; Node: TTreeNode;
  var AllowChange: boolean);
begin
  AllowChange := false;
end;

procedure TTreeComboBox.TreeViewExit(Sender: TObject);
begin
  HideTree(false);
end;

procedure TTreeComboBox.TreeViewMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  AnItem: TTreeNode;
  HT: THitTests;
begin
  if FSelectMode = smDblClick then
    Exit;
  if FTreeView.Selected = nil then
    Exit;
  HT := FTreeView.GetHitTestInfoAt(X, Y);
  AnItem := FTreeView.GetNodeAt(X, Y);
  // We can add htOnLabel,htOnStateIcon,htOnItem,htOnLabel
  if (htOnitem in HT) and (AnItem <> nil) then
  begin
    HideTree(false);
  end;
end;

procedure TTreeComboBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // FormDeactivate(self);
end;

function TTreeComboBox.GetSelection: integer;
begin
  try
    if Assigned(FTreeView.Selected) then
      Result := FTreeView.Selected.AbsoluteIndex
    else
      Result := -1;
  except
    on Exception do
      Result := -1;
  end;
end;

procedure TTreeComboBox.SetSelection(const Value: integer);
begin
  if (Value = -1) then
  begin
    FTreeView.Selected := nil;
    Text := '';
    Exit;
  end;

  try
    FTreeView.Selected := FTreeView.Items[Value];
    Text := FTreeView.Selected.Text;
  except
    on Exception do
      FTreeView.Selected := nil;
  end;
end;

procedure TTreeComboBox.SetFlat(const Value: boolean);
begin
  FFlat := Value;
end;

function TTreeComboBox.GetAbsoluteIndex: integer;
begin
  Result := -1;
  if Assigned(FTreeView.Selected) then
    Result := FTreeView.Selected.AbsoluteIndex;
end;

{ TDropTreeForm }

function TDropTreeForm.GetParentWnd: HWnd;
var
  Last, p: HWnd;
begin
  p := GetParent((Owner as TWinControl).Handle);
  Last := p;
  while p <> 0 do
  begin
    Last := p;
    p := GetParent(p);
  end;
  Result := Last;
end;

procedure TDropTreeForm.WMActivate(var Message: TWMActivate);
begin
  inherited;
  if Message.Active = integer(false) then
  begin
    if Visible and not(fsShowing in FFormState) then
    begin
      FDeActivate := GetTickCount;
      Hide;
    end;
  end
  else
  begin
    SendMessage(GetParentWnd, WM_NCACTIVATE, 1, 0);
  end;
end;

procedure TDropTreeForm.WMClose(var Msg: TMessage);
begin
  inherited;
end;

end.
