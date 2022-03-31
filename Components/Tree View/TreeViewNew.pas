unit TreeViewNew;

interface

uses
  Windows, SysUtils, Classes, Controls, ComCtrls, CommCtrl, Messages, Buttons,
  Forms;

{$R ..\TreeTab.res}

type

  TFormButtons = class(TForm)
  private
    procedure SetTreeNode(const Value: TTreeNode);
    procedure UpdateSize(Value: Integer);virtual;
    procedure Reposition;
  protected
    procedure WMShowWindow(var Message: TWMShowWindow); message WM_SHOWWINDOW;
  public
    FTreeNode: TTreeNode;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    property TreeNode: TTreeNode read FTreeNode write SetTreeNode;
  end;

  TFormTab = class(TFormButtons)
  private
    FButtonEdit, FButtonAdd, FButtonAddSub, FButtonClose: TSpeedButton;
    FOnButtonAddSubClick: TNotifyEvent;
    FOnButtonAddClick: TNotifyEvent;
    FOnButtonCloseClick: TNotifyEvent;
    procedure UpdateSize(Value: Integer);override;
    procedure WMKillFocus(var Message: TWMKillFocus);
    message WM_KILLFOCUS;
    procedure OnButtonEditClick(Sender: TObject);
    procedure SetOnButtonAddSubClick(const Value: TNotifyEvent);
    procedure SetOnButtonAddClick(const Value: TNotifyEvent);
    procedure SetOnButtonCloseClick(const Value: TNotifyEvent);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    property OnButtonAddClick:TNotifyEvent  read FOnButtonAddClick write SetOnButtonAddClick;
    property OnButtonAddSubClick:TNotifyEvent  read FOnButtonAddSubClick write SetOnButtonAddSubClick;
    property OnButtonCloseClick:TNotifyEvent  read FOnButtonCloseClick write SetOnButtonCloseClick;
  end;

  TFormEdit = class(TFormButtons)
  private
    FButtonCancel, FButtonGo: TSpeedButton;
    FOnButtonGoClick: TNotifyEvent;
    procedure UpdateSize(Value: Integer);override;
    procedure WMKillFocus(var Message: TWMKillFocus);
    message WM_KILLFOCUS;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonGoClick(Sender: TObject);
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    property OnButtonGoClick:TNotifyEvent  read FOnButtonGoClick write FOnButtonGoClick;
  end;

  TTreeViewNew = class(TTreeView)
  private
    { Private declarations }
    procedure WMSetFocus(var Message: TWMSetFocus);
    message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus);
    message WM_KILLFOCUS;
  protected
    { Protected declarations }
    procedure Change(Node: TTreeNode); override;
    procedure ConstrainedResize(var MinWidth, MinHeight, MaxWidth,
      MaxHeight: Integer); override;
    procedure Edit(const Item: TTVItem); override;
//    function CanEdit(Node: TTreeNode): Boolean; override;
  public
    { Public declarations }
    FIsEditing:Boolean;
    OldText:string;
    URLNew:string;
    FFormTab: TFormTab;
    FFormEdit: TFormEdit;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Tree Browser', [TTreeViewNew]);
end;

{ TTreeViewNew }

//function TTreeViewNew.CanEdit(Node: TTreeNode): Boolean;
//begin
//   Result := inherited;
//   FFormEdit.TreeNode:=Node;
//   FFormEdit.Visible:=True;
//   FFormTab.Visible:=False;
//end;

procedure TTreeViewNew.Change(Node: TTreeNode);
begin
  inherited;
  FFormTab.TreeNode := Node;
end;

procedure TTreeViewNew.ConstrainedResize(var MinWidth, MinHeight, MaxWidth,
  MaxHeight: Integer);
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin
    FFormTab.Reposition;
    FFormEdit.Reposition;
  end;
end;

constructor TTreeViewNew.Create(AOwner: TComponent);
begin
  inherited;
  FFormTab := TFormTab.CreateNew(self); ;
  FFormEdit := TFormEdit.CreateNew(self);
  ReadOnly:=True;
end;

destructor TTreeViewNew.Destroy;
begin

  inherited;
end;

procedure TTreeViewNew.Edit(const Item: TTVItem);
begin
  inherited;
  FIsEditing:=False;
  URLNew:=Item.pszText;
  FFormEdit.FTreeNode.Text:=OldText;
  if not FFormEdit.Focused  then
  begin
      FFormEdit.Visible := False;
      ReadOnly:=True;
      if Focused then
      FFormTab.Visible := True;

  end;

  with Item do
  begin
    if pszText <> nil then //FOnEdited
    begin

    end
    else  // FOnCancelEdit
    begin

    end;
  end;
end;

procedure TTreeViewNew.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not FFormTab.Focused  then
  FFormTab.Visible := False;
end;

procedure TTreeViewNew.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited ;
  if Assigned(Selected)and not FFormEdit.Visible then
    FFormTab.Visible := True;
end;

{ TFormButtons }

constructor TFormButtons.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  Visible := False;
  TransparentColor := True;
  TransparentColorValue := Color;
  BorderStyle := bsNone;
  FormStyle := fsStayOnTop;
end;

procedure TFormButtons.Reposition;
var
  TreeNodeRect: TRect;
  FormButtonsLeft: Integer;
  TreeNodeTopLeft, TreeViewBottomRight: TPoint;
const
  HWND_STYLE: array[Boolean] of HWND = (HWND_NOTOPMOST, HWND_TOPMOST);
begin
  if not Visible then Exit;

  TreeNodeRect := FTreeNode.DisplayRect(True);
  TreeNodeTopLeft := FTreeNode.TreeView.ClientToScreen(TreeNodeRect.TopLeft);
  TreeViewBottomRight := FTreeNode.TreeView.ClientToScreen
    (FTreeNode.TreeView.ClientRect.BottomRight);

  FormButtonsLeft := TreeNodeTopLeft.X - Width - (TTreeViewNew(FTreeNode.TreeView).Indent+20);
  if FormButtonsLeft < 0 then
    FormButtonsLeft := TreeNodeTopLeft.X+(TreeNodeRect.Right-TreeNodeRect.Left);
  if FormButtonsLeft > TreeViewBottomRight.X then
      FormButtonsLeft := TreeViewBottomRight.X;

  Left := FormButtonsLeft;
  Top := TreeNodeTopLeft.Y;
 if not (csDesigning in ComponentState) and HandleAllocated then
    SetWindowPos(Handle, HWND_STYLE[fsStayOnTop = fsStayOnTop], 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
end;

procedure TFormButtons.UpdateSize(Value: Integer);
begin
  ClientHeight := Value;
end;

procedure TFormButtons.SetTreeNode(const Value: TTreeNode);
var
  VRect: TRect;
begin
  if FTreeNode = Value then
    Exit;
  FTreeNode := Value;
  if not Assigned(Value) then
  begin
    Visible := False;
    Exit
  end;
  VRect := Value.DisplayRect(True);
  UpdateSize(VRect.Bottom - VRect.Top);
  Reposition;
end;

procedure TFormButtons.WMShowWindow(var Message: TWMShowWindow);
begin
   inherited;
   if Message.Show then
   begin
     Reposition;
     FormStyle := fsNormal;
     FormStyle := fsStayOnTop;
   end;
end;

{ TFormTab }

procedure TFormTab.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not FTreeNode.TreeView.Focused then
    Visible := False;
end;

constructor TFormTab.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  FButtonEdit := TSpeedButton.Create(self);
  with FButtonEdit do
  begin
    Flat := True;
    OnClick := OnButtonEditClick;
    Hint := 'Change URL';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'EDIT');
    Parent := self;
  end;

  FButtonAdd := TSpeedButton.Create(self);
  with FButtonAdd do
  begin
    Flat := True;
    OnClick := FOnButtonAddClick;
    Hint := 'New tab';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'ADD');
    Parent := self;
  end;

  FButtonAddSub := TSpeedButton.Create(self);
  with FButtonAddSub do
  begin
    Flat := True;
    OnClick := FOnButtonAddSubClick;
    Hint := 'New Subtab';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'ADDSUB');
    Parent := self;
  end;

  FButtonClose := TSpeedButton.Create(self);
  with FButtonClose do
  begin
    Flat := True;
    OnClick := FOnButtonCloseClick;
    Hint := 'Close Page';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'DELETE');
    Parent := self;
  end;
end;

procedure TFormTab.OnButtonEditClick(Sender: TObject) ;
begin
  TTreeViewNew(FTreeNode.TreeView).FFormEdit.TreeNode:=FTreeNode;
  TTreeViewNew(FTreeNode.TreeView).FFormEdit.Visible:=True;
  TTreeViewNew(FTreeNode.TreeView).FIsEditing:=True;
  TTreeViewNew(FTreeNode.TreeView).OldText:=FTreeNode.Text;
  TTreeViewNew(FTreeNode.TreeView).ReadOnly:=False;
  FTreeNode.EditText;
end;


procedure TFormTab.UpdateSize(Value: Integer);
begin
  inherited;
  ClientWidth := Value * 4;
  with FButtonEdit do
  begin
    Width := Value;
    Height := Value;
  end;

  with FButtonAdd do
  begin
    Width := Value;
    Height := Value;
    Left := Value;
  end;

  with FButtonAddSub do
  begin
    Width := Value;
    Height := Value;
    Left := Value * 2;
  end;

  with FButtonClose do
  begin
    Width := Value;
    Height := Value;
    Left := Value * 3;
  end;
end;

procedure TFormTab.SetOnButtonAddSubClick(const Value: TNotifyEvent);
begin
  FOnButtonAddSubClick := Value;
   FButtonAddSub.OnClick:=FOnButtonAddSubClick;
end;

procedure TFormTab.SetOnButtonAddClick(const Value: TNotifyEvent);
begin
  FOnButtonAddClick := Value;
  FButtonAdd.OnClick :=FOnButtonAddClick;
end;

procedure TFormTab.SetOnButtonCloseClick(const Value: TNotifyEvent);
begin
  FOnButtonCloseClick := Value;
  FButtonClose.OnClick:=FOnButtonCloseClick;
end;

{ TFormEdit }

procedure TFormEdit.ButtonCancelClick(Sender: TObject);
begin
 Visible:=False;
 TTreeViewNew(FTreeNode.TreeView).FFormTab.Visible:=True;
end;

procedure TFormEdit.ButtonGoClick(Sender: TObject);
begin
 Visible:=False;
 TTreeViewNew(FTreeNode.TreeView).FFormTab.Visible:=True;
 if Assigned(FOnButtonGoClick) then
   FOnButtonGoClick(Sender);
end;

constructor TFormEdit.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;
  FButtonCancel := TSpeedButton.Create(self);
  with FButtonCancel do
  begin
    Flat := True;
    OnClick := ButtonCancelClick;
    Hint := 'Cancel';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'CANCEL');
    Parent := self;
  end;

  FButtonGo := TSpeedButton.Create(self);
  with FButtonGo do
  begin
    Flat := True;
    OnClick := ButtonGoClick;
    Hint := 'Go';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'GO');
    Parent := self;
  end;
end;

procedure TFormEdit.UpdateSize(Value: Integer);
begin
  inherited;
  ClientWidth := Value * 2;
  with FButtonCancel do
  begin
    Width := Value;
    Height := Value;
  end;

  with FButtonGo do
  begin
    Width := Value;
    Height := Value;
    Left := Value;
  end;
end;

procedure TFormEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not TTreeViewNew(FTreeNode.TreeView).FIsEditing  then
  Visible := False;
end;

end.
