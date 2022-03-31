unit ExplorerTreeview;
{$I ..\DEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Math,
  Dialogs, ComCtrls, TreeComboBox, Buttons, CommCtrl, ImgList, RTLConsts,
  ComStrs, ExtCtrls, Menus, ShellAPI,
  Types;

const
  NODE_SEP = '\';
  DROPDOWNBTN_WIDTH = 15;
  REFRESHBTN_WIDTH = 24;
  ICON_WIDTH = 22;
  DwBUTTON_WIDTH = 14;

type
  TCustomExplorerTreeComboBox = class;

  ETreeViewError = class(Exception);

    TDropDownButton = class(TGraphicControl)private FHot, FDown: Boolean;
    FExplorerTreeview: TCustomExplorerTreeComboBox;
    FGlyph: TBitmap;
    FImageIndex: Integer;
    procedure WMLButtonDown(var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure OnGlyphChanged(Sender: TObject);
    procedure SetGlyph(const Value: TBitmap);
    procedure SetDown(const Value: Boolean);
    procedure setImageIndex(const Value: Integer);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure DrawButton;
    function IsActive: Boolean;

    property Down: Boolean read FDown write SetDown;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ExplorerTreeview
      : TCustomExplorerTreeComboBox read FExplorerTreeview;
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property ImageIndex: Integer read FImageIndex write setImageIndex default -
      1;
  published
  end;

  TNodeButton = class;

  TCloseButton = class(TSpeedButton)
  private
    FNodeButton: TNodeButton;
    procedure OnCloseButtonClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TNodeButton = class(TGraphicControl)
  private
    FHot, FDown, FDwBtnHot: Boolean;
    FExplorerTreeview: TCustomExplorerTreeComboBox;
    FGlyph: TBitmap;
    FNode: TTreeNode;
    FScrollButton: Boolean;
    FOffsetX: Integer;
    FCloseButton: TCloseButton;
    procedure OnMenuItemClick(Sender: TObject);
    procedure WMLButtonDown(var Msg: TMessage); message WM_LBUTTONDOWN;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure SetGlyph(const Value: TBitmap);
    procedure SetNode(const Value: TTreeNode);
    procedure SetDown(const Value: Boolean);
    procedure SetScrollButton(const Value: Boolean);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure DrawButton;
    procedure ButtonClick;
    procedure DropDownPress;
    function IsSplitButton: Boolean;
    function IsActive: Boolean;
  public
    procedure UpdateSize;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property ExplorerTreeview
      : TCustomExplorerTreeComboBox read FExplorerTreeview;
    property Glyph: TBitmap read FGlyph write SetGlyph;

    property Node: TTreeNode read FNode write SetNode;
    property Down: Boolean read FDown write SetDown default false;
    property ScrollButton
      : Boolean read FScrollButton write SetScrollButton default
      false; // <<
  published
  end;

  TButtonAppearance = class(TPersistent)
  private
    FBorderColorHot: TColor;
    FColorHot: TColor;
    FArrowColorHot: TColor;
    FColorMirrorHot: TColor;
    FColorMirrorHotTo: TColor;
    FColorHotTo: TColor;

    FArrowColorDown: TColor;
    FColorDownTo: TColor;
    FColorDown: TColor;
    FOnChange: TNotifyEvent;
    FColorMirrorDownTo: TColor;
    FColorMirrorDown: TColor;
    FBorderColorDown: TColor;
    FFont: TFont;
    FColorMirrorNodeHotTo: TColor;
    FBorderColorNodeHot: TColor;
    FColorNodeHot: TColor;
    FColorMirrorNodeHot: TColor;
    FColorNodeHotTo: TColor;
    procedure OnFontChanged(Sender: TObject);
    procedure SetColorDown(const Value: TColor);
    procedure SetColorDownTo(const Value: TColor);
    procedure SetColorMirrorDown(const Value: TColor);
    procedure SetColorMirrorDownTo(const Value: TColor);
    procedure SetArrowColorDown(const Value: TColor);
    procedure SetArrowColorHot(const Value: TColor);
    procedure SetBorderColorDown(const Value: TColor);
    procedure SetBorderColorHot(const Value: TColor);
    procedure SetColorHot(const Value: TColor);
    procedure SetColorHotTo(const Value: TColor);
    procedure SetColorMirrorHot(const Value: TColor);
    procedure SetColorMirrorHotTo(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetBorderColorNodeHot(const Value: TColor);
    procedure SetColorMirrorNodeHot(const Value: TColor);
    procedure SetColorMirrorNodeHotTo(const Value: TColor);
    procedure SetColorNodeHot(const Value: TColor);
    procedure SetColorNodeHotTo(const Value: TColor);
  protected
    procedure Changed;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ArrowColorDown
      : TColor read FArrowColorDown write SetArrowColorDown
      default clBlack;
    property ArrowColorHot
      : TColor read FArrowColorHot write SetArrowColorHot
      default clBlack;
    property BorderColorDown
      : TColor read FBorderColorDown write SetBorderColorDown default
      $008B622C;
    property BorderColorHot
      : TColor read FBorderColorHot write SetBorderColorHot
      default $008B5816;
    property BorderColorNodeHot: TColor read FBorderColorNodeHot write
      SetBorderColorNodeHot default $008F8F8E;
    property ColorDown
      : TColor read FColorDown write SetColorDown default $00FCF1E4;
    property ColorDownTo
      : TColor read FColorDownTo write SetColorDownTo default $00F7E7C9;
    property ColorMirrorDown
      : TColor read FColorMirrorDown write SetColorMirrorDown default
      $00EDCE93;
    property ColorMirrorDownTo: TColor read FColorMirrorDownTo write
      SetColorMirrorDownTo default $00DDB66D;
    property ColorHot
      : TColor read FColorHot write SetColorHot default $00FBEDD3;
    property ColorHotTo
      : TColor read FColorHotTo write SetColorHotTo default $00FAE9C7;
    property ColorMirrorHot
      : TColor read FColorMirrorHot write SetColorMirrorHot
      default $00F7D89C;
    property ColorMirrorHotTo: TColor read FColorMirrorHotTo write
      SetColorMirrorHotTo default $00F5D089;
    property ColorNodeHot
      : TColor read FColorNodeHot write SetColorNodeHot default
      $00F2F2F2;
    property ColorNodeHotTo
      : TColor read FColorNodeHotTo write SetColorNodeHotTo
      default $00EEEEEE;
    property ColorMirrorNodeHot: TColor read FColorMirrorNodeHot write
      SetColorMirrorNodeHot default $00D9D9D9;
    property ColorMirrorNodeHotTo: TColor read FColorMirrorNodeHotTo write
      SetColorMirrorNodeHotTo default $00D2D2D2;
    property Font: TFont read FFont write SetFont;
  end;

  TExpTreeviewAppearance = class(TPersistent)
  private
    FColor: TColor;
    FFocusColor: TColor;
    FOnChange: TNotifyEvent;
    FFocusOuterBorderColor: TColor;
    FInnerBorderColor: TColor;
    FOuterBorderColor: TColor;
    FFocusInnerBorderColor: TColor;
    FButtonAppearance: TButtonAppearance;
    FHotColor: TColor;
    FInnerMostBorderColor: TColor;
    procedure OnButtonAppearanceChanged(Sender: TObject);
    procedure SetColor(const Value: TColor);
    procedure SetFocusColor(const Value: TColor);
    procedure Changed;
    procedure SetFocusInnerBorderColor(const Value: TColor);
    procedure SetFocusOuterBorderColor(const Value: TColor);
    procedure SetInnerBorderColor(const Value: TColor);
    procedure SetOuterBorderColor(const Value: TColor);
    procedure SetButtonAppearance(const Value: TButtonAppearance);
    procedure SetHotColor(const Value: TColor);
    procedure SetInnerMostBorderColor(const Value: TColor);
  protected
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ButtonAppearance: TButtonAppearance read FButtonAppearance write
      SetButtonAppearance;
    property OuterBorderColor: TColor read FOuterBorderColor write
      SetOuterBorderColor default clNone;
    property InnerBorderColor: TColor read FInnerBorderColor write
      SetInnerBorderColor default $B99D7F;
    property InnerMostBorderColor: TColor read FInnerMostBorderColor write
      SetInnerMostBorderColor default clNone;
    property FocusOuterBorderColor: TColor read FFocusOuterBorderColor write
      SetFocusOuterBorderColor default clNone;
    property FocusInnerBorderColor: TColor read FFocusInnerBorderColor write
      SetFocusInnerBorderColor default $B99D7F;
    property Color: TColor read FColor write SetColor default $00FAF0E6;
    property FocusColor
      : TColor read FFocusColor write SetFocusColor default clWhite;
    property HotColor
      : TColor read FHotColor write SetHotColor default $00FFF9F4;
  end;

  { TCustomExplorerTreeview }
  TNodeEvent = procedure(Sender: TObject; Node: TTreeNode) of object;
  TPopulateChildEvent = procedure(Sender: TObject; ParentNode: TTreeNode;
    Path: string; var PopulateAllowed: Boolean) of object;

  TCustomExplorerTreeComboBox = class(TTreeComboBox)
  private
    FSelectedNode: TTreeNode;
    FOldSelected: TTreeNode;
    FAppearance: TExpTreeviewAppearance;
    FDropDownButton: TDropDownButton;
    FMouseInControl: Boolean;
    FNodeButtons: TList;
    FCloseClick: Boolean;
    FOnBeforeDropDown: TNotifyEvent;
    FOnPopulateChildNode: TPopulateChildEvent;
    FOnSelect: TNodeEvent;
    FUpdateCount: Integer;
    FIsInternal: Boolean;
    FBufferedDraw: Boolean;
    FMaxWidth: Integer;
    procedure OnDropDownBtnClick(Sender: TObject);
    procedure OnExplorerTreeviewClick(Sender: TObject);
    procedure OnDropDownBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnAppearanceChanged(Sender: TObject);
    procedure OnTreeViewClick(Sender: TObject);
    procedure OnTreeViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OnTreeViewKeyPress(Sender: TObject; var Key: Char);
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure WMPaste(var Message: TWMPaste); message WM_PASTE;
    procedure WMCut(var Message: TWMCut); message WM_CUT;
    procedure WMKeyDown(var Msg: TWMKeydown); message WM_KEYDOWN;
    procedure WMChar(var Msg: TWMChar); message WM_CHAR;
    procedure WMSysKeyDown(var Msg: TWMKeydown); message WM_SYSKEYDOWN;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMGetDlgCode(var Message: TMessage); message WM_GETDLGCODE;
    function GetSelectedNode: TTreeNode;
    procedure SetSelectedNode(const Value: TTreeNode);
    procedure SetAppearance(const Value: TExpTreeviewAppearance);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DestroyWnd; override;
    // procedure WndProc(var Message: TMessage); override;
    function GetParentForm(Control: TControl): TCustomForm; virtual;
    procedure DoEnter; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;

    procedure InvalidateDropDownButton;

    function IsUpdating: Boolean;
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetMinHeight: Integer;
    procedure UpdateNodeButtonsPositions;
    procedure RemoveNodeButtons;
    procedure GenerateNodeButtons;
    procedure ShowDropDownList;
    procedure HideDropDownList;
    procedure UpdateButtonsPosition;
    procedure UpdateDropDownRefreshBtnsPos;
    function GetBorderWidth: Integer;
    function GetNodeButtonsRect: TRect;
    function GetDropDownButtonRect: TRect;
    procedure DrawBackGround;
    property IsInternal: Boolean read FIsInternal write FIsInternal;
    property Appearance: TExpTreeviewAppearance read FAppearance write
      SetAppearance;
    property OnBeforeDropDown
      : TNotifyEvent read FOnBeforeDropDown write FOnBeforeDropDown;
    property OnPopulateChildNode
      : TPopulateChildEvent read FOnPopulateChildNode write
      FOnPopulateChildNode;
    property OnSelect: TNodeEvent read FOnSelect write FOnSelect;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property BufferedDraw: Boolean read FBufferedDraw write FBufferedDraw;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth default 200;
    property SelectedNode: TTreeNode read GetSelectedNode write SetSelectedNode;
    property OldSelected: TTreeNode read FOldSelected;
  end;

  TExplorerTreeComboBox = class(TCustomExplorerTreeComboBox)
  public
    property SelectedNode;
  published
    property Align;
{$IFDEF DELPHI4_LVL}
    property Anchors;
    property Constraints;
{$ENDIF}
    property Appearance;
    property Font;
    property Height;
    property Images;
    property Items;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width;
    property OnBeforeDropDown;
    property OnPopulateChildNode;
    property OnSelect;

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
    property DragKind;
{$ENDIF}
    property SelectMode;
    property DropWidth;
    property DropHeight;
    property CollapseOnDrop;
    property ExpandOnDrop;
    property DropPosition;
    property Flat;
    // ----- Tree properties
    property ShowButtons;
    property ShowLines;
    property ShowRoot;
    property SortType;
    property RightClickSelect;
    property RowSelect;
    property Indent;
    property StateImages;
    property TreeFont;
    property TreeColor;
    property TreeBorder;
    property TreePopupMenu;
    property Selection;
    // --------
    property OnDropDown;
    property OnDropUp;

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
    property ParentColor;
    property ParentCtl3D;
  end;

var
  WM_ET_HIDEDROPDOWN: Word;
  WM_ET_SETFOLDERPATH: Word;

procedure Register;

implementation

uses
  ShlObj, ComObj
{$IFDEF DELPHI2007_LVL}
  , uxTheme
{$ENDIF}, TreeTab;

// ----------------------------------------------------------------- DrawGradient

procedure DrawGradient(Canvas: TCanvas; FromColor, ToColor: TColor;
  Steps: Integer; R: TRect; Direction: Boolean);
var
  diffr, startr, endr: Integer;
  diffg, startg, endg: Integer;
  diffb, startb, endb: Integer;
  rstepr, rstepg, rstepb, rstepw: Real;
  i, stepw: Word;

begin
  if (ToColor = clNone) then
  begin
    Canvas.Brush.Color := FromColor;
    Canvas.Pen.Color := FromColor;
    Canvas.FillRect(R);
    Exit;
  end;

  if Direction then
    R.Right := R.Right - 1
  else
    R.Bottom := R.Bottom - 1;

  if Steps = 0 then
    Steps := 1;

  FromColor := ColorToRGB(FromColor);
  ToColor := ColorToRGB(ToColor);

  startr := (FromColor and $0000FF);
  startg := (FromColor and $00FF00) shr 8;
  startb := (FromColor and $FF0000) shr 16;
  endr := (ToColor and $0000FF);
  endg := (ToColor and $00FF00) shr 8;
  endb := (ToColor and $FF0000) shr 16;

  diffr := endr - startr;
  diffg := endg - startg;
  diffb := endb - startb;

  rstepr := diffr / Steps;
  rstepg := diffg / Steps;
  rstepb := diffb / Steps;

  if Direction then
    rstepw := (R.Right - R.Left) / Steps
  else
    rstepw := (R.Bottom - R.Top) / Steps;

  with Canvas do
  begin
    for i := 0 to Steps - 1 do
    begin
      endr := startr + Round(rstepr * i);
      endg := startg + Round(rstepg * i);
      endb := startb + Round(rstepb * i);
      stepw := Round(i * rstepw);
      Pen.Color := endr + (endg shl 8) + (endb shl 16);
      Brush.Color := Pen.Color;
      if Direction then
        Rectangle(R.Left + stepw, R.Top, R.Left + stepw + Round(rstepw) + 1,
          R.Bottom)
      else
        Rectangle(R.Left, R.Top + stepw, R.Right,
          R.Top + stepw + Round(rstepw) + 1);
    end;
  end;
end;

// ------------------------------------------------------------------------------

function BlendColor(Col1, Col2: TColor; BlendFactor: Integer): TColor;
var
  r1, g1, b1: Integer;
  r2, g2, b2: Integer;

begin
  if BlendFactor >= 100 then
  begin
    Result := Col1;
    Exit;
  end;
  if BlendFactor <= 0 then
  begin
    Result := Col2;
    Exit;
  end;

  Col1 := Longint(ColorToRGB(Col1));
  r1 := GetRValue(Col1);
  g1 := GetGValue(Col1);
  b1 := GetBValue(Col1);

  Col2 := Longint(ColorToRGB(Col2));
  r2 := GetRValue(Col2);
  g2 := GetGValue(Col2);
  b2 := GetBValue(Col2);

  r1 := Round(BlendFactor / 100 * r1 + (1 - BlendFactor / 100) * r2);
  g1 := Round(BlendFactor / 100 * g1 + (1 - BlendFactor / 100) * g2);
  b1 := Round(BlendFactor / 100 * b1 + (1 - BlendFactor / 100) * b2);

  Result := RGB(r1, g1, b1);
end;

// ------------------------------------------------------------------------------

procedure DrawVistaGradient(Canvas: TCanvas; R: TRect; GradHeight: Integer;
  FC, TC, MFC, MTC, PC: TColor; Down: Boolean;
  BothSideBorder: Boolean = false);
var
  r1, r2: TRect;
begin
  r1 := Rect(R.Left, R.Top, R.Right, R.Top + GradHeight + 1);
  r2 := Rect(R.Left, R.Top + GradHeight, R.Right, R.Bottom);
  if (MFC <> clNone) and (MTC <> clNone) then
  begin
    DrawGradient(Canvas, FC, TC, 40, r1, false);
    DrawGradient(Canvas, MFC, MTC, 40, r2, false);
  end
  else
    DrawGradient(Canvas, FC, TC, 40, R, false);

  if (PC <> clNone) then
  begin
    Canvas.Pen.Color := PC;
    if Down then
    begin
      Canvas.Brush.Style := bsClear;
      r2 := R;
      InflateRect(r2, -1, -1);
      r2.Bottom := r2.Bottom + 5;
      Canvas.Pen.Color := BlendColor(PC, clWhite, 50);
      Canvas.Rectangle(r2);

      Canvas.Pen.Color := PC;
      Canvas.Rectangle(R);
    end
    else
    begin
      Canvas.MoveTo(R.Left, R.Top);
      Canvas.LineTo(R.Left, R.Bottom);
      if BothSideBorder then
      begin
        Canvas.MoveTo(R.Right - 1, R.Top);
        Canvas.LineTo(R.Right - 1, R.Bottom);
        R.Right := R.Right - 1;
      end;
      R.Left := R.Left + 1;
      Canvas.Pen.Color := clWhite; // BlendColor(PC, clWhite, 50);
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(R);
    end;
  end;
end;

// ------------------------------------------------------------------------------

// Draw Auto centered Arrow
procedure DrawArrow(Canvas: TCanvas; R: TRect; ArClr, ArShad: TColor;
  LeftDir: Boolean); // Dir : true = Left; False = down
var
  ArP: TPoint;
  i, j: Integer;
begin
  if not LeftDir then // Down direction
  begin
    j := 6;
    i := R.Right - R.Left;
    if (ArShad <> clNone) then
      j := j + 0;
    ArP.X := R.Left + (i - j) div 2;
    j := 4;
    i := R.Bottom - R.Top;
    if (ArShad <> clNone) then
      j := j + 0;
    ArP.Y := R.Top + (i - j) div 2;

    Canvas.Pen.Color := ArClr;
    Canvas.MoveTo(ArP.X, ArP.Y);
    Canvas.LineTo(ArP.X + 7, ArP.Y);
    Canvas.MoveTo(ArP.X + 1, ArP.Y + 1);
    Canvas.LineTo(ArP.X + 6, ArP.Y + 1);
    Canvas.MoveTo(ArP.X + 2, ArP.Y + 2);
    Canvas.LineTo(ArP.X + 5, ArP.Y + 2);
    Canvas.Pixels[ArP.X + 3, ArP.Y + 3] := ArClr;
    if (ArShad <> clNone) then
    begin
      Canvas.Pen.Color := ArShad;
      Canvas.MoveTo(ArP.X - 1, ArP.Y - 1);
      Canvas.LineTo(ArP.X + 8, ArP.Y - 1);
      Canvas.Pixels[ArP.X - 1, ArP.Y] := ArShad;
      // Canvas.Pixels[ArP.X - 1, ArP.Y + 1] := ArShad;
      Canvas.Pixels[ArP.X + 7, ArP.Y] := ArShad;
      // Canvas.Pixels[ArP.X + 7, ArP.Y + 1] := ArShad;

      Canvas.Pixels[ArP.X, ArP.Y + 1] := ArShad;
      Canvas.Pixels[ArP.X + 1, ArP.Y + 2] := ArShad;
      Canvas.Pixels[ArP.X + 2, ArP.Y + 3] := ArShad;
      Canvas.Pixels[ArP.X + 3, ArP.Y + 4] := ArShad;
      Canvas.Pixels[ArP.X + 6, ArP.Y + 1] := ArShad;
      Canvas.Pixels[ArP.X + 5, ArP.Y + 2] := ArShad;
      Canvas.Pixels[ArP.X + 4, ArP.Y + 3] := ArShad;
    end;
  end
  else
  begin
    j := 4;
    i := R.Right - R.Left;
    ArP.X := R.Left + (i - j) div 2;
    j := 6;
    i := R.Bottom - R.Top;
    ArP.Y := R.Top + (i - j) div 2;

    Canvas.Pen.Color := ArClr;
    Canvas.MoveTo(ArP.X, ArP.Y);
    Canvas.LineTo(ArP.X, ArP.Y + 7);
    Canvas.MoveTo(ArP.X + 1, ArP.Y + 1);
    Canvas.LineTo(ArP.X + 1, ArP.Y + 6);
    Canvas.MoveTo(ArP.X + 2, ArP.Y + 2);
    Canvas.LineTo(ArP.X + 2, ArP.Y + 5);
    Canvas.Pixels[ArP.X + 3, ArP.Y + 3] := ArClr;
  end;
end;

// ------------------------------------------------------------------------------

// Draw Auto centered Scroll Arrow
procedure DrawScrollArrow(Canvas: TCanvas; R: TRect; ArClr: TColor);
var
  ArP: TPoint;
  i, h, w: Integer;

  procedure DrawSingleArrow;
  begin
    Canvas.Pen.Color := ArClr;
    Canvas.MoveTo(ArP.X, ArP.Y + 2);
    Canvas.LineTo(ArP.X + 2, ArP.Y + 2);
    Canvas.MoveTo(ArP.X + 1, ArP.Y + 1);
    Canvas.LineTo(ArP.X + 3, ArP.Y + 1);
    Canvas.MoveTo(ArP.X + 2, ArP.Y);
    Canvas.LineTo(ArP.X + 4, ArP.Y);

    Canvas.MoveTo(ArP.X + 1, ArP.Y + 3);
    Canvas.LineTo(ArP.X + 3, ArP.Y + 3);
    Canvas.MoveTo(ArP.X + 2, ArP.Y + 4);
    Canvas.LineTo(ArP.X + 4, ArP.Y + 4);
  end;

begin
  w := 7;
  i := R.Right - R.Left - w;
  ArP.X := R.Left + (i div 2);
  h := 5;
  i := R.Bottom - R.Top - h;
  ArP.Y := R.Top + (i div 2);
  DrawSingleArrow;
  ArP.X := ArP.X + 4;
  DrawSingleArrow;
end;

{ TButtonAppearance }

procedure TButtonAppearance.Assign(Source: TPersistent);
begin
  if (Source is TButtonAppearance) then
  begin
    FColorHot := TButtonAppearance(Source).ColorHot;
    FColorHotTo := TButtonAppearance(Source).ColorHotTo;
    FColorMirrorHot := TButtonAppearance(Source).ColorMirrorHot;
    FColorMirrorHotTo := TButtonAppearance(Source).ColorMirrorHotTo;

    FBorderColorHot := TButtonAppearance(Source).FBorderColorHot;
    FArrowColorHot := TButtonAppearance(Source).FArrowColorHot;

    FArrowColorDown := TButtonAppearance(Source).FArrowColorDown;
    FColorDownTo := TButtonAppearance(Source).FColorDownTo;
    FColorDown := TButtonAppearance(Source).FColorDown;
    FColorMirrorDownTo := TButtonAppearance(Source).FColorMirrorDownTo;
    FColorMirrorDown := TButtonAppearance(Source).FColorMirrorDown;
    FBorderColorDown := TButtonAppearance(Source).FBorderColorDown;
    FFont.Assign(TButtonAppearance(Source).Font);
    FColorMirrorNodeHotTo := TButtonAppearance(Source).FColorMirrorNodeHotTo;
    FBorderColorNodeHot := TButtonAppearance(Source).FBorderColorNodeHot;
    FColorNodeHot := TButtonAppearance(Source).FColorNodeHot;
    FColorMirrorNodeHot := TButtonAppearance(Source).FColorMirrorNodeHot;
    FColorNodeHotTo := TButtonAppearance(Source).FColorNodeHotTo;
  end
  else
    inherited;
end;

// ------------------------------------------------------------------------------

constructor TButtonAppearance.Create;
begin
  inherited;
  FColorDown := RGB(228, 241, 252);
  FColorDownTo := RGB(201, 231, 247);
  FColorMirrorDown := RGB(147, 206, 237);
  FColorMirrorDownTo := RGB(109, 182, 221);
  FFont := TFont.Create;
  FFont.OnChange := OnFontChanged;
  FArrowColorHot := clBlack;
  FArrowColorDown := clBlack;
  FBorderColorHot := RGB(22, 88, 139);
  FColorHot := RGB(211, 237, 251);
  FColorHotTo := RGB(199, 233, 250);
  FColorMirrorHot := RGB(156, 216, 247);
  FColorMirrorHotTo := RGB(137, 208, 245);
  FBorderColorDown := RGB(44, 98, 139);

  FBorderColorNodeHot := RGB(142, 143, 143);
  FColorNodeHot := RGB(242, 242, 242);
  FColorNodeHotTo := RGB(238, 238, 238);
  FColorMirrorNodeHot := RGB(217, 217, 217);
  FColorMirrorNodeHotTo := RGB(210, 210, 210);
end;

// ------------------------------------------------------------------------------

destructor TButtonAppearance.Destroy;
begin
  FFont.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorDown(const Value: TColor);
begin
  if (FColorDown <> Value) then
  begin
    FColorDown := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorDown(const Value: TColor);
begin
  if (FColorMirrorDown <> Value) then
  begin
    FColorMirrorDown := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorDownTo(const Value: TColor);
begin
  if (FColorMirrorDownTo <> Value) then
  begin
    FColorMirrorDownTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorDownTo(const Value: TColor);
begin
  if (FColorDownTo <> Value) then
  begin
    FColorDownTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.OnFontChanged(Sender: TObject);
begin
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetArrowColorDown(const Value: TColor);
begin
  FArrowColorDown := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetArrowColorHot(const Value: TColor);
begin
  FArrowColorHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetBorderColorDown(const Value: TColor);
begin
  FBorderColorDown := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetBorderColorHot(const Value: TColor);
begin
  FBorderColorHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorHot(const Value: TColor);
begin
  FColorHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorHotTo(const Value: TColor);
begin
  FColorHotTo := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorHot(const Value: TColor);
begin
  FColorMirrorHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorHotTo(const Value: TColor);
begin
  FColorMirrorHotTo := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetBorderColorNodeHot(const Value: TColor);
begin
  FBorderColorNodeHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorNodeHot(const Value: TColor);
begin
  FColorMirrorNodeHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorMirrorNodeHotTo(const Value: TColor);
begin
  FColorMirrorNodeHotTo := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorNodeHot(const Value: TColor);
begin
  FColorNodeHot := Value;
end;

// ------------------------------------------------------------------------------

procedure TButtonAppearance.SetColorNodeHotTo(const Value: TColor);
begin
  FColorNodeHotTo := Value;
end;

// ------------------------------------------------------------------------------

{ TExpTreeviewAppearance }

procedure TExpTreeviewAppearance.Assign(Source: TPersistent);
begin
  if (Source is TExpTreeviewAppearance) then
  begin
    FColor := (Source as TExpTreeviewAppearance).Color;
    FFocusColor := (Source as TExpTreeviewAppearance).FocusColor;
    FFocusOuterBorderColor := (Source as TExpTreeviewAppearance)
      .FFocusOuterBorderColor;
    FInnerBorderColor := (Source as TExpTreeviewAppearance).FInnerBorderColor;
    FOuterBorderColor := (Source as TExpTreeviewAppearance).FOuterBorderColor;
    FInnerMostBorderColor := (Source as TExpTreeviewAppearance)
      .InnerMostBorderColor;
    FFocusInnerBorderColor := (Source as TExpTreeviewAppearance)
      .FFocusInnerBorderColor;
    FButtonAppearance.Assign((Source as TExpTreeviewAppearance)
        .ButtonAppearance);
    FHotColor := (Source as TExpTreeviewAppearance).FHotColor;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.Changed;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

// ------------------------------------------------------------------------------

constructor TExpTreeviewAppearance.Create;
begin
  inherited;
  FColor := RGB(230, 240, 250);
  FFocusColor := clWhite;
  FHotColor := RGB(244, 249, 255);
  FOuterBorderColor := clNone;
  FInnerBorderColor := $B99D7F;
  FFocusOuterBorderColor := clNone;
  FFocusInnerBorderColor := $B99D7F;
  FInnerMostBorderColor := clNone;
  FButtonAppearance := TButtonAppearance.Create;
  FButtonAppearance.OnChange := OnButtonAppearanceChanged;
end;

// ------------------------------------------------------------------------------

destructor TExpTreeviewAppearance.Destroy;
begin
  FButtonAppearance.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.OnButtonAppearanceChanged(Sender: TObject);
begin
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetButtonAppearance
  (const Value: TButtonAppearance);
begin
  FButtonAppearance.Assign(Value);
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetFocusColor(const Value: TColor);
begin
  if (FFocusColor <> Value) then
  begin
    FFocusColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetFocusInnerBorderColor(const Value: TColor);
begin
  if (FFocusInnerBorderColor <> Value) then
  begin
    FFocusInnerBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetFocusOuterBorderColor(const Value: TColor);
begin
  if (FFocusOuterBorderColor <> Value) then
  begin
    FFocusOuterBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetHotColor(const Value: TColor);
begin
  if (FHotColor <> Value) then
  begin
    FHotColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetInnerBorderColor(const Value: TColor);
begin
  if (FInnerBorderColor <> Value) then
  begin
    FInnerBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetInnerMostBorderColor(const Value: TColor);
begin
  if (FInnerMostBorderColor <> Value) then
  begin
    FInnerMostBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TExpTreeviewAppearance.SetOuterBorderColor(const Value: TColor);
begin
  if (FOuterBorderColor <> Value) then
  begin
    FOuterBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

{ TCustomExplorerTreeview }

constructor TCustomExplorerTreeComboBox.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls];

  Ctl3D := false;
  FOldSelected := nil;

  ControlStyle := ControlStyle - [csSetCaption];

  FNodeButtons := TList.Create;
  FMaxWidth := 200;

  FAppearance := TExpTreeviewAppearance.Create;
  FAppearance.OnChange := OnAppearanceChanged;

  FDropDownButton := TDropDownButton.Create(Self);
  FDropDownButton.Parent := Self;
  FDropDownButton.OnMouseDown := OnDropDownBtnMouseDown;
  OnClick := OnExplorerTreeviewClick;
  FDropDownButton.OnClick := OnDropDownBtnClick;
  FDropDownButton.Visible := True;

  Width := 300;
  Height := 25;

  Treeview.Ctl3D := false;
  Treeview.Align := alClient;
  Treeview.Font.Assign(Self.Font);
  Treeview.Canvas.Font.Assign(Treeview.Font);
  // if Assigned(CurrentImages) then
  // FListBox.ItemHeight := CurrentImages.Height;
  // if (FListBox.Canvas.TextHeight('Wy') > FListBox.ItemHeight - 1) then
  // FListBox.ItemHeight := FListBox.Canvas.TextHeight('Wy');
  Treeview.OnClick := OnTreeViewClick;
  Treeview.OnKeyDown := OnTreeViewKeyDown;
  Treeview.OnKeyPress := OnTreeViewKeyPress;

  UpdateDropDownRefreshBtnsPos;

  DoubleBuffered := True;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

// ------------------------------------------------------------------------------

destructor TCustomExplorerTreeComboBox.Destroy;
begin
  RemoveNodeButtons;
  Items.Clear;
  FDropDownButton.Free;
  FAppearance.Free;

  FNodeButtons.Free;
  // Items.Free; يحدث خطأ
  inherited;
end;

procedure TCustomExplorerTreeComboBox.DestroyWnd;
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CMEnter(var Message: TCMGotFocus);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CMExit(var Message: TCMExit);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := True;
  Color := Appearance.HotColor;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  FMouseInControl := false;
  Color := Appearance.Color;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.CMTextChanged(var Message: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.DoEnter;
begin
  inherited;

end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetParentForm(Control: TControl)
  : TCustomForm;
begin
  Result := nil;
  if Assigned(Control) then
    if Control is TCustomForm then
    begin
      Result := Control as TCustomForm;
      Exit;
    end
    else
    begin
      if Assigned(Control.Parent) then
        Result := GetParentForm(Control.Parent);
    end;
end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetSelectedNode: TTreeNode;
begin
  Result := FSelectedNode;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.SetSelectedNode(const Value: TTreeNode);
begin
  if (Value <> FSelectedNode) then
  begin
    RemoveNodeButtons;
    FOldSelected := FSelectedNode;
    FSelectedNode := Value;
    if not IsUpdating then
    begin
      GenerateNodeButtons
    end;
    if Assigned(FSelectedNode) then
    begin
      FSelectedNode.Treeview.Selected := FSelectedNode;
      if Assigned(FOnSelect) and not IsUpdating and not IsInternal then
        FOnSelect(Self, FSelectedNode);
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.UpdateNodeButtonsPositions;
var
  i, X: Integer;
  R: TRect;
begin
  R := GetNodeButtonsRect;
  X := R.Left;
  for i := FNodeButtons.Count - 1 downto 0 do
  begin
    with TNodeButton(FNodeButtons[i]) do
    begin
      Top := R.Top;
      Left := X;
      X := X + Width;
      Height := R.Bottom - R.Top;
      FCloseButton.Left := X - FCloseButton.Width - 6;
      FCloseButton.BringToFront;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.RemoveNodeButtons;
var
  i: Integer;
begin
  for i := 0 to FNodeButtons.Count - 1 do
  begin
    with TNodeButton(FNodeButtons[i]) do
    begin
      if Assigned(Node.Data) then
        if Assigned(TTabSheetBrowser(Node.Data).NodeButton) then
          TTabSheetBrowser(Node.Data).NodeButton := nil;
      Free;
    end;
  end;
  FNodeButtons.Clear;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.GenerateNodeButtons;
  function CreateNodeButton: TNodeButton;
  begin
    Result := TNodeButton.Create(Self);
    Result.Parent := Self;
    Result.Visible := True;
  end;

var
  NB: TNodeButton;
  N: TTreeNode;
  s: Integer;
  R: TRect;
  // bmp: TBitmap;
begin
  RemoveNodeButtons;
  if Assigned(FSelectedNode) then
  begin
    R := GetNodeButtonsRect;
    s := R.Right - R.Left; // available space for buttons
    if (s < DwBUTTON_WIDTH) then // not enough space to even display scroll button
      Exit;

    N := FSelectedNode;
    while (N <> nil) do
    begin
      NB := CreateNodeButton;
      NB.Node := TTreeNode(N);
      if Assigned(N.Data) then
      begin
        TTabSheetBrowser(N.Data).NodeButton := NB;
      end;
      N := N.Parent;

      FNodeButtons.Add(NB);
      if (NB.Width > s) or (Assigned(N) and (NB.Width > s - DwBUTTON_WIDTH))
        then
      begin
        NB.ScrollButton := false;
        Break;
      end;
      s := s - NB.Width;
    end;
    UpdateNodeButtonsPositions;
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.KeyDown(var Key: Word;
  Shift: TShiftState);
begin
  inherited;

  { if (Key = VK_ESCAPE) then
    begin
    SelectedNode := FOldSelected;
    end
    else
    begin
    SelectedNode := nil;
    end; }

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.KeyPress(var Key: Char);
begin

  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.Loaded;
begin
  if not(csDesigning in ComponentState) and not Focused then
  begin
    if (Appearance.FocusColor <> clNone) then
      inherited Color := Appearance.Color;
  end;
  if not Assigned(SelectedNode) then
    SelectedNode := Items.GetFirstNode;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnDropDownBtnClick(Sender: TObject);
begin

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnDropDownBtnMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not FCloseClick then
    ShowDropDownList;
  FCloseClick := false;
end;

procedure TCustomExplorerTreeComboBox.OnExplorerTreeviewClick(Sender: TObject);
begin
  ShowDropDownList;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnTreeViewClick(Sender: TObject);
begin
  if Assigned(Treeview.Selected) then
  begin
    SelectedNode := TTreeNode(Treeview.Selected);
  end;

  HideDropDownList;
  // PostMessage(Handle, WM_ET_HIDEDROPDOWN, 0, 0);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.SetBounds(ALeft, ATop, AWidth,
  AHeight: Integer);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.ShowDropDownList;
var
  P: TPoint;
begin
  if Assigned(OnBeforeDropDown) then
    OnBeforeDropDown(Self);

  DropHeight := Items.Count * 17;
  Treeview.FullExpand;
  ShowTree;

  if (Treeview.Items.Count <= 0) then
  begin
    HideDropDownList;
    Exit;
  end;

  P := Point(0, 0);
  P := ClientToScreen(P);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.HideDropDownList;
begin
  FDropDownButton.Down := false;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMChar(var Msg: TWMChar);
begin
  if Msg.CharCode = Ord(#13) then
    Msg.Result := 0
  else
    inherited;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMCut(var Message: TWMCut);
var
  ch: Char;
begin
  inherited;

  ch := #0;
  KeyPress(ch);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMGetDlgCode(var Message: TMessage);
begin
  inherited;
  // Message.Result := {DLGC_WANTTAB or }DLGC_WANTARROWS;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMKeyDown(var Msg: TWMKeydown);
begin
  inherited;
  if (Msg.CharCode in [VK_DOWN, VK_F4]) then
  begin
    if not FCloseClick then
      ShowDropDownList;
    FCloseClick := false;
  end;

  if (Msg.CharCode in [VK_DOWN, VK_F4]) or
    ((Msg.CharCode in [Ord('A') .. Ord('Z'), Ord('1') .. Ord('9')])) then
  begin
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;
  if (Appearance.FocusColor <> clNone) and not(csDesigning in ComponentState)
    then
  begin
    inherited Color := Appearance.Color;
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMPaste(var Message: TWMPaste);
var
  ch: Char;
begin
  inherited;

  ch := #0;
  KeyPress(ch);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;
  if (Appearance.FocusColor <> clNone) and not(csDesigning in ComponentState)
    then
  begin
    inherited Color := Appearance.FocusColor;
  end;
  if HandleAllocated and not(csDesigning in ComponentState) then
    HideCaret(Handle);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMSize(var Message: TWMSize);
var
  N: TTreeNode;
  { MinHeight: Integer;
    Dist:integer; }
begin
  inherited;
  UpdateButtonsPosition;
  if Width < 500 then
    DropWidth := 500
  else
    DropWidth := Width;

  if not(csDesigning in ComponentState) and not(csLoading in ComponentState)
    then
  begin
    IsInternal := True;
    N := SelectedNode;
    SelectedNode := nil;
    SelectedNode := N;
    IsInternal := false;
  end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMSysKeyDown(var Msg: TWMKeydown);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

// procedure TCustomExplorerTreeComboBox.WndProc(var Message: TMessage);
// begin
// inherited;
//
// if (Message.Msg = WM_ET_HIDEDROPDOWN) then
// HideDropDownList;
//
// // if (Message.Msg = WM_ET_SETFOLDERPATH) then
// // SetFolderPath(FNewSelectedFolderPath);
// end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  i: Integer;
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

// ------------------------------------------------------------------------------

// function TCustomExplorerTreeviewNew.GetHierarchicalNodeText(N: TTreeNodeNew; IncludeFolderPath: Boolean = True): string;
// begin
// Result := '';
// if Assigned(N) then
// begin
// Result := N.Text;
// if N.VirtualParent then
// Exit;
//
// N := N.Parent;
// if Assigned(N) then
// begin
// while (N <> nil) and not N.VirtualParent do
// begin
// if (Length(N.Text) > 0) and (N.Text[Length(N.Text)] = NODE_SEP) then
// Result := N.Text + Result
// else
// Result := N.Text + NODE_SEP + Result;
// N := N.Parent;
// end;
// end
// else
// Result := Result + NODE_SEP;
//
// if IncludeFolderPath and (Mode = aeFolder) then
// begin
// if (Length(FolderPath) > 0) and (FolderPath[Length(FolderPath)] <> NODE_SEP) then
// Result := NODE_SEP + Result;
// Result := FolderPath + Result;
// end;
// end;
// end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.UpdateButtonsPosition;
begin
  UpdateDropDownRefreshBtnsPos;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.UpdateDropDownRefreshBtnsPos;
var
  R: TRect;
begin
  if Assigned(FDropDownButton) then
  begin
    R := GetDropDownButtonRect;
    FDropDownButton.Width := R.Right - R.Left;
    FDropDownButton.Height := R.Bottom - R.Top;
    FDropDownButton.Left := R.Left;
    FDropDownButton.Top := R.Top;
  end;
end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetNodeButtonsRect: TRect;
begin
  Result := GetDropDownButtonRect;
  Result.Left := Result.Right + 1;
  Result.Right := Width - 2;
end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetDropDownButtonRect: TRect;
begin
  Result := Rect(2, 2, 2 + DROPDOWNBTN_WIDTH, Self.Height - 2);
end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.GetBorderWidth: Integer;
var
  BrIn, BrOut: TColor;
begin
  Result := 0;
  if Focused then
  begin
    BrIn := Appearance.FocusInnerBorderColor;
    BrOut := Appearance.FocusOuterBorderColor;
  end
  else
  begin
    BrIn := Appearance.InnerBorderColor;
    BrOut := Appearance.OuterBorderColor;
  end;

  if (BrOut <> clNone) then
    Inc(Result);
  if (BrIn <> clNone) then
    Inc(Result);
  { if (Appearance.InnerMostBorderColor <> clNone) then
    Inc(Result); }

  if (Result <= 0) then
    Result := 1;
  if (Result > 2) then
    Result := 2;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMNCPaint(var Message: TMessage);
begin
  inherited;
  // NCPaintProc;
  // Message.Result := 0;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.WMPaint(var Message: TWMPaint);
begin
  inherited;
{$IFDEF DELPHI_UNICODE}
  FBufferedDraw := (csGlassPaint in ControlState) or FBufferedDraw;
{$ENDIF}
  DrawBackGround;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.DrawBackGround;
var
  DC: HDC;
  Canvas: TCanvas;
  BrIn, BrOut: TColor;
  R: TRect;
  i, j: Integer;
begin
  DC := GetWindowDC(Handle);
  try
    Canvas := TCanvas.Create;
    Canvas.Handle := DC;

    if Focused then
    begin
      BrIn := Appearance.FocusInnerBorderColor;
      BrOut := Appearance.FocusOuterBorderColor;
    end
    else
    begin
      BrIn := Appearance.InnerBorderColor;
      BrOut := Appearance.OuterBorderColor;
    end;

    R := ClientRect;
    Canvas.Brush.Style := bsClear;
    if (BrOut <> clNone) then
    begin
      Canvas.Pen.Color := BrOut;
      Canvas.Rectangle(R);
      {
        Canvas.Pixels[R.Left, R.Top] := Color;
        Canvas.Pixels[R.Right-1, R.Top] := Color;
        Canvas.Pixels[R.Left, R.Bottom-1] := Color;
        Canvas.Pixels[R.Right-1, R.Bottom-1] := Color;
        }
      InflateRect(R, -1, -1);
    end;
    if (BrIn <> clNone) then
    begin
      Canvas.Pen.Color := BrIn;
      Canvas.Rectangle(R);
      {
        Canvas.Pixels[R.Left, R.Top] := Color;
        Canvas.Pixels[R.Right-1, R.Top] := Color;
        Canvas.Pixels[R.Left, R.Bottom-1] := Color;
        Canvas.Pixels[R.Right-1, R.Bottom-1] := Color;
        }
      InflateRect(R, -1, -1);
    end;

    if not FMouseInControl and (Appearance.InnerMostBorderColor <> clNone) then
    begin
      Canvas.Pen.Color := Appearance.InnerMostBorderColor;
      Canvas.Rectangle(R);

      Canvas.Pixels[R.Left, R.Top] := Color;
      Canvas.Pixels[R.Right - 1, R.Top] := Color;
      Canvas.Pixels[R.Left, R.Bottom - 1] := Color;
      Canvas.Pixels[R.Right - 1, R.Bottom - 1] := Color;
    end;

    Canvas.Free;
  finally
    ReleaseDC(Handle, DC);
  end;

  // repaint Active button
  j := -1;
  for i := 0 to FNodeButtons.Count - 1 do
  begin
    if TNodeButton(FNodeButtons[i]).IsActive then
    begin
      j := i;
      Break;
    end;
  end;
  if (j >= 0) then
    TNodeButton(FNodeButtons[j]).DrawButton;

  if FDropDownButton.IsActive then
    FDropDownButton.DrawButton;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.SetAppearance
  (const Value: TExpTreeviewAppearance);
begin
  FAppearance.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnAppearanceChanged(Sender: TObject);
var
  P: TPoint;
  R: TRect;
begin
  if (csLoading in ComponentState) and not(csDesigning in ComponentState) then
    Exit;

  if (csDesigning in ComponentState) then
    Color := Appearance.Color
  else
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);
    R := ClientRect;
    if PtInRect(R, P) then
    begin
      Color := Appearance.HotColor;
    end
    else
    begin
      Color := Appearance.Color;
    end;
  end;

  UpdateNodeButtonsPositions;
  UpdateDropDownRefreshBtnsPos;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.InvalidateDropDownButton;
var
  R: TRect;
begin
  R := GetDropDownButtonRect;
  InvalidateRect(Handle, @R, True);
end;

// ------------------------------------------------------------------------------

function GetDisplayName(ShellFolder: IShellFolder; PIDL: PItemIDList;
  ForParsing: Boolean): string;
var
  StrRet: TStrRet;
  Flags: Integer;
  wstr: string;
begin
  Result := '';
  if ForParsing then
    Flags := SHGDN_FORPARSING
  else
    Flags := SHGDN_NORMAL;

  ShellFolder.GetDisplayNameOf(PIDL, Flags, StrRet);

  wstr := string(StrRet.cStr);

  case StrRet.uType of
{$IFNDEF DELPHI_UNICODE}
    STRRET_CSTR:
      SetString(Result, PAnsiChar(wstr), Length(wstr));
{$ENDIF}
    STRRET_WSTR:
      Result := StrRet.pOleStr;
  end;
end;

// ------------------------------------------------------------------------------

function RemoveTailSep(Path: string): string;
begin
  Result := Path;
  if (Length(Path) > 0) and (Path[Length(Path)] = NODE_SEP) then
    Result := Copy(Path, 1, Length(Path) - 1);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnTreeViewKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  // if Showing then
  // begin
  // if (Key = VK_UP) and (FListBox.ItemIndex > 0) then
  // FListBox.MoveSelect(-1);
  //
  // if (Key = VK_DOWN) then
  // FListBox.MoveSelect(1);
  //
  // if (Key = VK_ESCAPE) then
  // begin
  // HideDropDownList;
  // Self.SetFocus;
  // SelectAll;
  // end;
  // end;
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.OnTreeViewKeyPress(Sender: TObject;
  var Key: Char);
begin
  // if not Assigned(FListBox) then
  // Exit;
  //
  // if (Key = #13 {VK_ENTER}) then
  // begin
  // if (FListBox.ItemIndex >= 0) then
  // begin
  // if (SelectedNode = TTreeNodeNew(FListBox.Items.Objects[FListBox.ItemIndex])) then
  // Text := GetHierarchicalNodeText(SelectedNode)
  // else
  // SelectedNode := TTreeNodeNew(FListBox.Items.Objects[FListBox.ItemIndex]);
  // end;
  // HideDropDownList;
  // Self.SetFocus;
  // SelectAll;
  // Exit;
  // end;
end;

procedure TCustomExplorerTreeComboBox.BeginUpdate;
begin
  if not Visible then
    Exit;

  Inc(FUpdateCount);
end;

// ------------------------------------------------------------------------------

procedure TCustomExplorerTreeComboBox.EndUpdate;
var
  N: TTreeNode;
begin
  if not Visible then
    Exit;

  if FUpdateCount > 0 then
    Dec(FUpdateCount);

  if (FUpdateCount = 0) then
  begin
    N := SelectedNode;
    SelectedNode := nil;
    SelectedNode := N;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

function TCustomExplorerTreeComboBox.IsUpdating: Boolean;
begin
  Result := (FUpdateCount > 0);
end;

// ------------------------------------------------------------------------------

{ TDropDownButton }

constructor TDropDownButton.Create(AOwner: TComponent);
begin
  inherited;
  if (AOwner is TCustomExplorerTreeComboBox) then
    FExplorerTreeview := TCustomExplorerTreeComboBox(AOwner)
  else
    raise Exception.Create('Invalid parent');

  FGlyph := TBitmap.Create;
  FGlyph.OnChange := OnGlyphChanged;
  FImageIndex := -1;
  Cursor := crArrow;
end;

// ------------------------------------------------------------------------------

destructor TDropDownButton.Destroy;
begin
  FGlyph.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin
    FHot := True;
    DrawButton;
  end;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  if not(csDesigning in ComponentState) then
  begin
    FHot := false;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (csDesigning in ComponentState) then
    Exit;

  if (Button = mbLeft) then
  begin
    FDown := True;
    DrawButton;
  end;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if (csDesigning in ComponentState) or not Assigned(ExplorerTreeview) then
    Exit;

  if FDown { and not ExplorerTreeview.IsDroppedDown لاحقا } then
  begin
    FDown := false;
    if ExplorerTreeview.FBufferedDraw then
      DrawButton
    else
      Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.SetDown(const Value: Boolean);
begin
  FDown := Value;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.Paint;
begin
  DrawButton;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.DrawButton;
var
  R: TRect;
  Clr, ClrTo, MClr, MClrTo, BrClr, ArClr, ArShad: TColor;
  X, Y: Integer;
  Imges: TCustomImageList;

  MemDC: HDC;
  Rb: TRect;
{$IFDEF DELPHI2007_LVL}
  PaintBuffer: HPAINTBUFFER;
{$ENDIF}
  bmp: TBitmap;
  aCanvas: TCanvas;
  BufferedDraw: Boolean;
begin
  if not Assigned(ExplorerTreeview) then
    Exit;

  R := ClientRect;

  Rb := ClientRect;
{$IFDEF DELPHI2007_LVL}
  BufferedDraw := ExplorerTreeview.FBufferedDraw;
{$ELSE}
  BufferedDraw := false;
{$ENDIF}
  if BufferedDraw then
  begin
    bmp := TBitmap.Create;
    bmp.Height := Rb.Bottom - Rb.Top;
    bmp.Width := Rb.Right - Rb.Left;
    bmp.Canvas.CopyMode := cmSrcCopy;
    bmp.Canvas.CopyRect(Rb, Canvas, Rb);
    aCanvas := bmp.Canvas;
{$IFDEF DELPHI2007_LVL}
    PaintBuffer := BeginBufferedPaint(Canvas.Handle, Rb, BPBF_DIB
      { BPBF_TOPDOWNDIB } , nil, MemDC);
{$ELSE}
    MemDC := 0;
{$ENDIF}
  end
  else
  begin
    bmp := nil;
{$IFDEF DELPHI2007_LVL}
    PaintBuffer := 0;
{$ENDIF}
    MemDC := 0;
    aCanvas := Canvas;
  end;

  try
    if BufferedDraw then
      Canvas.Handle := MemDC;

    ArClr := clBlack;
    ArShad := clWhite;
    if FHot or FDown then
    begin
      with ExplorerTreeview do
        if FDown then
        begin
          Clr := Appearance.ButtonAppearance.ColorDown;
          ClrTo := Appearance.ButtonAppearance.ColorDownTo;
          MClr := Appearance.ButtonAppearance.ColorMirrorDown;
          MClrTo := Appearance.ButtonAppearance.ColorMirrorDownTo;
          BrClr := Appearance.ButtonAppearance.BorderColorDown;
          ArClr := Appearance.ButtonAppearance.ArrowColorDown;
          ArShad := clNone;
        end
        else
        begin
          Clr := Appearance.ButtonAppearance.ColorHot;
          ClrTo := Appearance.ButtonAppearance.ColorHotTo;
          MClr := Appearance.ButtonAppearance.ColorMirrorHot;
          MClrTo := Appearance.ButtonAppearance.ColorMirrorHotTo;
          BrClr := Appearance.ButtonAppearance.BorderColorHot;
          ArClr := Appearance.ButtonAppearance.ArrowColorHot;
        end;

      DrawVistaGradient(aCanvas, R, (R.Bottom - R.Top) div 2, Clr, ClrTo, MClr,
        MClrTo, BrClr, FDown, True);
    end;

    Imges := ExplorerTreeview.Images;
    if Assigned(Imges) and (ImageIndex >= 0) then
    begin
      X := R.Left + (((R.Right - R.Left) - Imges.Width) div 2);
      Y := R.Top + (((R.Bottom - R.Top) - Imges.Height) div 2);
      if FDown then
        Y := Y + 2;
      ExplorerTreeview.Images.Draw(aCanvas, X, Y, ImageIndex);
    end
    else if Assigned(FGlyph) and (not FGlyph.Empty) then
    begin
      X := R.Left + (((R.Right - R.Left) - FGlyph.Width) div 2);
      Y := R.Top + (((R.Bottom - R.Top) - FGlyph.Height) div 2);
      if FDown then
        Y := Y + 2;
      FGlyph.Transparent := True;
      aCanvas.Draw(X, Y, FGlyph);
    end
    else
    begin
      if FDown then
        R.Top := R.Top + 2;
      DrawArrow(aCanvas, R, ArClr, ArShad, false);
    end;

    if BufferedDraw then
    begin
      Canvas.Draw(0, 0, bmp);
      bmp.Free;
{$IFDEF DELPHI2007_LVL}
{$IFDEF DELPHI_UNICODE}
      BufferedPaintMakeOpaque(PaintBuffer, R);
{$ELSE}
      BufferedPaintMakeOpaque(PaintBuffer, @R);
{$ENDIF}
{$ENDIF}
    end;
  finally
{$IFDEF DELPHI2007_LVL}
    if BufferedDraw then
      EndBufferedPaint(PaintBuffer, True);
{$ENDIF}
  end;
end;

// ------------------------------------------------------------------------------

function TDropDownButton.IsActive: Boolean;
begin
  Result := FHot or FDown;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.WMLButtonDown(var Msg: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.WMPaint(var Message: TWMPaint);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.setImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TDropDownButton.OnGlyphChanged(Sender: TObject);
begin
  Invalidate;
end;

// ------------------------------------------------------------------------------

{ TNodeButton }

constructor TNodeButton.Create(AOwner: TComponent);
begin
  inherited;
  if (AOwner is TCustomExplorerTreeComboBox) then
    FExplorerTreeview := TCustomExplorerTreeComboBox(AOwner)
  else
    raise Exception.Create('Invalid parent');

  FNode := nil;
  FOffsetX := 4;

  FGlyph := TBitmap.Create;
  Cursor := crArrow;

  ShowHint := True;

  FCloseButton := TCloseButton.Create(Self);
  with FCloseButton do
  begin
    Parent := FExplorerTreeview;
    // OnClick := OnCloseButtonClick;
    Flat := True;
    Width := DwBUTTON_WIDTH;
    Height := DwBUTTON_WIDTH;
    Glyph.LoadFromResourceName(HInstance, 'CLOSETAB');
    Hint := 'Close Page';
    ShowHint := True;
    FNodeButton := Self;
  end;
end;

// ------------------------------------------------------------------------------

destructor TNodeButton.Destroy;
begin
  FGlyph.Free;
  FCloseButton.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.ButtonClick;
begin
  if Assigned(Node) and Assigned(ExplorerTreeview) and IsSplitButton then
  begin
    ExplorerTreeview.SelectedNode := Node;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.CMMouseEnter(var Msg: TMessage);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TNodeButton.CMMouseLeave(var Msg: TMessage);
begin
  inherited;
  FHot := false;
  FDwBtnHot := false;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) then
  begin
    FDown := True;
    DrawButton;

    if ((X > Width - DwBUTTON_WIDTH) and IsSplitButton) or ScrollButton then
      DropDownPress;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (X < (Width - DwBUTTON_WIDTH)) or not IsSplitButton then
  begin
    if not FHot then
    begin
      FHot := True;
      DrawButton;
    end;
  end
  else
  begin
    if not FDwBtnHot then
    begin
      FHot := false;
      FDwBtnHot := True;
      DrawButton;
    end
    else if FHot then
    begin
      FHot := false;
      DrawButton;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if (FDown) then
  begin
    FDown := false;
    if ExplorerTreeview.FBufferedDraw then
      DrawButton
    else
      Invalidate;
  end;

  if (X < (Width - DwBUTTON_WIDTH)) or not IsSplitButton then
  begin
    ButtonClick;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.SetDown(const Value: Boolean);
begin
  FDown := Value;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.SetGlyph(const Value: TBitmap);
begin
  FGlyph.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.SetNode(const Value: TTreeNode);
begin
  FNode := Value;
  UpdateSize;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.SetScrollButton(const Value: Boolean);
begin
  FScrollButton := Value;
  UpdateSize;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.UpdateSize;
var
  R: TRect;
  w: Integer;
begin
  if not Assigned(ExplorerTreeview) or not Assigned(Node) then
    Exit;

  Height := ExplorerTreeview.GetNodeButtonsRect.Bottom -
    ExplorerTreeview.GetNodeButtonsRect.Top;
  if ScrollButton then
    Width := DwBUTTON_WIDTH
  else
  begin
    w := 0;
    if (Node.Text <> '') then
    begin
      Canvas.Font.Assign(ExplorerTreeview.Appearance.ButtonAppearance.Font);
      R := Rect(ICON_WIDTH, 0, 1000, 100);
      DrawText(Canvas.Handle, PChar(Node.Text), Length(Node.Text), R,
        DT_CALCRECT or DT_LEFT or DT_SINGLELINE or DT_TOP);
      w := R.Right + FOffsetX * 2;
    end;

    if IsSplitButton then
      w := w + DwBUTTON_WIDTH;
    w := Max(DwBUTTON_WIDTH, w);
    if w > ExplorerTreeview.MaxWidth then
      w := ExplorerTreeview.MaxWidth;
    Width := w;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.Paint;
begin
  DrawButton;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.DrawButton;
var
  r1, r2: TRect;
  Clr, ClrTo, MClr, MClrTo, BrClr, ArClr, ArShad: TColor;
  X, Y: Integer;
  IsSplit: Boolean;

  MemDC: HDC;
  R: TRect;
{$IFDEF DELPHI2007_LVL}
  PaintBuffer: HPAINTBUFFER;
{$ENDIF}
  bmp, LeftIcon: TBitmap;
  aCanvas: TCanvas;
  BufferedDraw: Boolean;
begin
  if not Assigned(ExplorerTreeview) or not Assigned(Node) then
    Exit;

  r1 := ClientRect;
  r2 := r1;

  R := ClientRect;
{$IFDEF DELPHI2007_LVL}
  BufferedDraw := ExplorerTreeview.FBufferedDraw;
{$ELSE}
  BufferedDraw := false;
{$ENDIF}
  if BufferedDraw then
  begin
    bmp := TBitmap.Create;
    bmp.Height := r1.Bottom - r1.Top;
    bmp.Width := r1.Right - r1.Left;
    bmp.Canvas.CopyMode := cmSrcCopy;
    bmp.Canvas.CopyRect(r1, Canvas, r1);
    aCanvas := bmp.Canvas;
{$IFDEF DELPHI2007_LVL}
    PaintBuffer := BeginBufferedPaint(Canvas.Handle, R, BPBF_DIB
      { BPBF_TOPDOWNDIB } , nil, MemDC);
{$ELSE}
    MemDC := 0;
{$ENDIF}
  end
  else
  begin
    bmp := nil;
{$IFDEF DELPHI2007_LVL}
    PaintBuffer := 0;
{$ENDIF}
    MemDC := 0;
    aCanvas := Canvas;
  end;

  try
    if BufferedDraw then
      Canvas.Handle := MemDC;

    if IsSplitButton and not ScrollButton then
    begin
      r2.Left := r2.Right - DwBUTTON_WIDTH;
      r1.Right := r2.Left;
    end;

    ArClr := clBlack;
    ArShad := clWhite;
    Clr := clNone;
    ClrTo := clNone;
    MClr := clNone;
    MClrTo := clNone;
    BrClr := clNone;
    IsSplit := IsSplitButton;

    if FHot or FDown or FDwBtnHot then
    begin
      with ExplorerTreeview do
        if FDown then
        begin
          Clr := Appearance.ButtonAppearance.ColorDown;
          ClrTo := Appearance.ButtonAppearance.ColorDownTo;
          MClr := Appearance.ButtonAppearance.ColorMirrorDown;
          MClrTo := Appearance.ButtonAppearance.ColorMirrorDownTo;
          BrClr := Appearance.ButtonAppearance.BorderColorDown;
          ArClr := Appearance.ButtonAppearance.ArrowColorDown;
          ArShad := clNone;
        end
        else if FHot or FDwBtnHot then
        begin
          Clr := Appearance.ButtonAppearance.ColorHot;
          ClrTo := Appearance.ButtonAppearance.ColorHotTo;
          MClr := Appearance.ButtonAppearance.ColorMirrorHot;
          MClrTo := Appearance.ButtonAppearance.ColorMirrorHotTo;
          BrClr := Appearance.ButtonAppearance.BorderColorHot;
          ArClr := Appearance.ButtonAppearance.ArrowColorHot;
        end;

      if ScrollButton then
        DrawVistaGradient(aCanvas, r1, (r1.Bottom - r1.Top) div 2, Clr, ClrTo,
          MClr, MClrTo, BrClr, FDown, True)
      else
      begin
        if IsSplit then
        begin
          // Dw part
          DrawVistaGradient(aCanvas, r2, (r2.Bottom - r2.Top) div 2, Clr,
            ClrTo, MClr, MClrTo, BrClr, FDown, True);
        end;

        if FDwBtnHot and not FHot and not FDown then
        begin
          with ExplorerTreeview do
          begin
            Clr := Appearance.ButtonAppearance.ColorNodeHot;
            ClrTo := Appearance.ButtonAppearance.ColorNodeHotTo;
            MClr := Appearance.ButtonAppearance.ColorMirrorNodeHot;
            MClrTo := Appearance.ButtonAppearance.ColorMirrorNodeHotTo;
            BrClr := Appearance.ButtonAppearance.BorderColorNodeHot;
          end;
        end;

        // Node part
        DrawVistaGradient(aCanvas, r1, (r1.Bottom - r1.Top) div 2, Clr, ClrTo,
          MClr, MClrTo, BrClr, FDown, not IsSplit);
      end;
    end;

    // draw text
    if (Node.Text <> '') and not ScrollButton then
    begin
      if FDown then
        r1.Top := r1.Top + 2;
      aCanvas.Font.Assign(ExplorerTreeview.Appearance.ButtonAppearance.Font);
      aCanvas.Brush.Style := bsClear;
      if Assigned(FExplorerTreeview.Images) then
      begin
        LeftIcon := TBitmap.Create;
        LeftIcon.SetSize(FExplorerTreeview.Images.Width,
          FExplorerTreeview.Images.Height);
        FExplorerTreeview.Images.Draw(LeftIcon.Canvas, 0, 0, FNode.ImageIndex);
        aCanvas.Draw(r1.Left + 2,
          ((r1.Bottom - FExplorerTreeview.Images.Height) div 2) + r1.Top,
          LeftIcon);
      end;
      r1.Left := r1.Left + ICON_WIDTH;
      DrawText(aCanvas.Handle, PChar(Node.Text), Length(Node.Text), r1,
        DT_VCENTER or DT_SINGLELINE or DT_CENTER);
    end;

    if ScrollButton then
    begin
      DrawScrollArrow(aCanvas, ClientRect, ArClr);
    end
    else if not ScrollButton and IsSplitButton then
    begin
      if FDown then
        r2.Top := r2.Top + 2;
      DrawArrow(aCanvas, r2, ArClr, ArShad, not FDown);
    end;
    // else if not ShowText then أنا
    // begin
    // R2 := ClientRect;
    // if FDown then
    // R2.Top := R2.Top + 2;
    // DrawArrow(aCanvas, R2, ArClr, ArShad, not FDown);
    // end;

    if Assigned(FGlyph) and (not FGlyph.Empty) then
    begin
      X := r1.Left + (((r1.Right - r1.Left) - FGlyph.Width) div 2);
      Y := r1.Top + (((r1.Bottom - r1.Top) - FGlyph.Height) div 2);
      if FDown then
        Y := Y + 2;
      aCanvas.Draw(X, Y, FGlyph);
    end
    else
    begin
      // if FDown then
      // R1.Top := R1.Top + 2;
      // DrawArrow(Canvas, R1, ArClr, ArShad, False);
    end;

    if BufferedDraw then
    begin
      Canvas.Draw(0, 0, bmp);
      bmp.Free;
{$IFDEF DELPHI2007_LVL}
{$IFDEF DELPHI_UNICODE}
      BufferedPaintMakeOpaque(PaintBuffer, R);
{$ELSE}
      BufferedPaintMakeOpaque(PaintBuffer, @R);
{$ENDIF}
{$ENDIF}
    end;

  finally
{$IFDEF DELPHI2007_LVL}
    if BufferedDraw then
      EndBufferedPaint(PaintBuffer, True);
{$ENDIF}
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.DropDownPress;
var
  Menu: TPopupMenu;
  MI: TMenuItem;
  N, NP: TTreeNode;
  P: TPoint;
  R: TRect;

  procedure AddSeparator;
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := '-';
    Menu.Items.Add(MI);
  end;

begin
  if not Assigned(Node) or not Assigned(ExplorerTreeview) then
    Exit;

  Menu := TPopupMenu.Create(Owner);
  Menu.Images := ExplorerTreeview.Images;

  NP := Node;

  if ScrollButton then
  begin
    if Assigned(NP) and (ExplorerTreeview.SelectedNode <> Node) then
    begin
      N := NP;
      while (N <> nil) do
      begin
        MI := TMenuItem.Create(Menu);
        MI.Caption := N.Text;
        MI.ImageIndex := N.ImageIndex;
        MI.Tag := Integer(N);
        MI.OnClick := OnMenuItemClick;
        Menu.Items.Add(MI);
        N := N.Parent;
      end;
    end;

    NP := ExplorerTreeview.Items.GetFirstNode;
    if not Assigned(NP) then
      NP := Node;
    AddSeparator;
  end
  else if (Node.Parent = nil) and (ExplorerTreeview.SelectedNode <> Node) then
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := Node.Text;
    MI.ImageIndex := Node.ImageIndex;
    MI.Tag := Integer(Node);
    MI.OnClick := OnMenuItemClick;
    Menu.Items.Add(MI);
    AddSeparator;
  end;

  N := NP.getFirstChild;
  while (N <> nil) do
  begin
    MI := TMenuItem.Create(Menu);
    MI.Caption := N.Text;
    MI.ImageIndex := N.ImageIndex;
    MI.Tag := Integer(N);
    MI.OnClick := OnMenuItemClick;
    Menu.Items.Add(MI);
    N := N.getNextSibling;
  end;
  P := Point(Width div 2, Height);
  P := ClientToScreen(P);
  Menu.Popup(P.X, P.Y);

  if (FDown) then
  begin
    FDown := false;
    GetCursorPos(P);
    P := ScreenToClient(P);
    R := ClientRect;
    FHot := PtInRect(R, P);
    R.Left := Width - DwBUTTON_WIDTH;
    FDwBtnHot := PtInRect(R, P);
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.OnMenuItemClick(Sender: TObject);
var
  MI: TMenuItem;
begin
  if not Assigned(Sender) or not(Sender is TMenuItem) or not Assigned
    (ExplorerTreeview) then
    Exit;

  MI := TMenuItem(Sender);
  ExplorerTreeview.SelectedNode := TTreeNode(Pointer(MI.Tag));
end;

// ------------------------------------------------------------------------------

function TNodeButton.IsActive: Boolean;
begin
  Result := FHot or FDown or FDwBtnHot;
end;

// ------------------------------------------------------------------------------

function TNodeButton.IsSplitButton: Boolean;
begin
  Result := false;
  if Assigned(Node) and not ScrollButton then
    Result := Node.getFirstChild <> nil;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.WMLButtonDown(var Msg: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TNodeButton.WMPaint(var Message: TWMPaint);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure Register;
begin
  RegisterComponents('Tree Browser', [TExplorerTreeComboBox]);
end;

{ TCloseButton }

constructor TCloseButton.Create(AOwner: TComponent);
begin
  inherited;
  OnClick := OnCloseButtonClick;
end;

procedure TCloseButton.OnCloseButtonClick(Sender: TObject);
begin
  if Assigned(FNodeButton.FNode.Data) then
    TTabSheetBrowser(FNodeButton.FNode.Data).FTreeTab.Remove
      (FNodeButton.FNode.Data);
end;

initialization

WM_ET_HIDEDROPDOWN := RegisterWindowMessage('ET_HIDEDROPDOWN');
WM_ET_SETFOLDERPATH := RegisterWindowMessage('ET_SETFOLDERPATH');

end.
