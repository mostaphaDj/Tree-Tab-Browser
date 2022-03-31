Unit SidePanel;

interface

uses Windows, Messages, SysUtils, Classes, Controls, ExtCtrls, Buttons,
  Graphics,
  Forms, Math;

{$R SidePanel.res}

type
  TSidePanelAlign = (spaLeft, spaRight);
  TSidePanelPopupMode = (spmMouseOn, spmMouseClick);

  TSidePanel = class(TCustomPanel)
  private
    FPinBtn: TSpeedButton;
    FBorderColor: TColor;
    FTitleBitmap: TBitmap;
    FHandleBitmap: TBitmap;
    FSideColor: TColor;
    FCaptionFontColor: TColor;
    FPoped: Boolean;
    FShowButton: Boolean;

    FTimer: TTimer;

    FnWidth: Integer;
    FbMoving: Boolean;
    FAlign: TSidePanelAlign;
    FStayOn: Boolean;
    FPopupMode: TSidePanelPopupMode;
    FQuickMove: Boolean;

    FOnPop: TNotifyEvent;
    FOnPush: TNotifyEvent;
    FOnPin: TNotifyEvent;
    FOnUnPin: TNotifyEvent;

    procedure OnPinClick(Sender: TObject);
    procedure OnTimerCheck(Sender: TObject);

    procedure SetWidth(NewValue: Integer);
    procedure SetSideColor(NewValue: TColor);
    function GetSideColor(): TColor;
    function GetSideWidth(): Integer;
    procedure SetAlign(const Value: TSidePanelAlign);
    procedure SetStayOn(const Value: Boolean);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCaptionFontColor(const Value: TColor);
    procedure SetSideWidth(const Value: Integer);
    procedure SetHandleBitmap(const Value: TBitmap);
    procedure SetTitleBitmap(const Value: TBitmap);
    procedure SetShowButton(const Value: Boolean);

    procedure WMERASEBKGND(var Msg: TMessage);
    message WM_ERASEBKGND;
    procedure CMTextChanged(var Msg: TMessage);
    message CM_TEXTCHANGED;

  protected
    procedure Paint(); override;
    procedure Resize(); override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    procedure Pop(bQuick: Boolean = true);
    procedure Push(bQuick: Boolean = true);

    property HandleImage: TBitmap read FHandleBitmap write SetHandleBitmap;
    property TitleImage: TBitmap read FTitleBitmap write SetTitleBitmap;

  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property CaptionFontColor: TColor read FCaptionFontColor write
      SetCaptionFontColor;
    property ShowButton: Boolean read FShowButton write SetShowButton;
    property Popped: Boolean read FPoped;

    property Anchors;
    property BiDiMode;
    property Width read FnWidth write SetWidth;
    property SideBarColor: TColor read GetSideColor write SetSideColor;
    property Caption;
    property Font;
    property Alignment;
    property Align: TSidePanelAlign read FAlign write SetAlign;
    property StayOn: Boolean read FStayOn write SetStayOn;
    property Visible;
    property Color;
    property ParentColor;
    property ParentShowHint;
    property ParentBiDiMode;
    property ParentFont;
    property PopupMenu;

    property PopupMode: TSidePanelPopupMode read FPopupMode write FPopupMode;
    property QuickMove: Boolean read FQuickMove write FQuickMove;

    property OnResize;
    property OnCanResize;
    property OnPush: TNotifyEvent read FOnPush write FOnPush;
    property OnPop: TNotifyEvent read FOnPop write FOnPop;
    property OnPin: TNotifyEvent read FOnPin write FOnPin;
    property OnUnPin: TNotifyEvent read FOnUnPin write FOnUnPin;

    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;

    // no use, only for compatibility
    property SideBarWidth: Integer read GetSideWidth write SetSideWidth;
  end;

procedure Register;

implementation

{ TSidePanel }

constructor TSidePanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTitleBitmap := TBitmap.Create();
  FTitleBitmap.LoadFromResourceName(hInstance, 'SIDEPANEL_TITLE');
  FHandleBitmap := TBitmap.Create();
  FHandleBitmap.LoadFromResourceName(hInstance, 'SIDEPANEL_HANDLE');

  FPinBtn := TSpeedButton.Create(self);
  FPinBtn.Parent := self;
  FPinBtn.Flat := true;
  FPinBtn.Height := 16;
  FPinBtn.Width := 20;
  FPinBtn.GroupIndex := 1;
  FPinBtn.AllowAllUp := true;
  FPinBtn.Glyph.LoadFromResourceName(hInstance, 'SIDEPANEL_BTN');
  FPinBtn.Top := 1;
  FPinBtn.Left := Width - FPinBtn.Width - 1;
  FPinBtn.OnClick := OnPinClick;
  ShowButton := true;

  FTimer := TTimer.Create(self);
  FTimer.Interval := 1000;
  FTimer.Enabled := false;
  FTimer.OnTimer := OnTimerCheck;

  FbMoving := false;

  BevelOuter := bvNone;
  Align := spaLeft;
  SideBarColor := clBtnFace;
  PopupMode := spmMouseOn;
  QuickMove := false;
  Font.Name := 'Tahoma';
  FPoped := false;

  if (csDesigning in ComponentState) then
    Exit;

  Push(true);
end;

destructor TSidePanel.Destroy;
begin
  FTimer.Free();
  FPinBtn.Free();
  FHandleBitmap.Free();
  FTitleBitmap.Free();

  inherited;
end;

procedure TSidePanel.OnTimerCheck(Sender: TObject);
var
  CurPos: TPoint;
  LeftTop: TPoint;
  RightBottum: TPoint;
begin
  if FbMoving then
    Exit;
  LeftTop.X := 0;
  LeftTop.Y := 0;
  RightBottum.X := inherited Width;
  RightBottum.Y := Height;
  GetCursorPos(CurPos);

  if Parent <> nil then
  begin
    LeftTop := ClientToScreen(LeftTop);
    RightBottum := ClientToScreen(RightBottum);
  end
  else
    Push(FQuickMove);

  if ((CurPos.X > LeftTop.X) and (CurPos.X < RightBottum.X) and
      (CurPos.Y > LeftTop.Y) and (CurPos.Y < RightBottum.Y)) then
    Exit; // in

  // out
  Push(FQuickMove);
end;

procedure TSidePanel.Pop(bQuick: Boolean = true);
begin
  FbMoving := true;

  FPinBtn.Visible := true;

  if not bQuick then
  begin
    while inherited Width + 15 < FnWidth do
    begin
      inherited Width := inherited Width + 15;
      Refresh();
      Application.ProcessMessages();
    end;
  end;
  inherited Width := FnWidth;
  Refresh();

  FTimer.Enabled := true;
  FbMoving := false;
  FPoped := true;
  Repaint();
  if Assigned(FOnPop) then
    FOnPop(self);
end;

procedure TSidePanel.Push(bQuick: Boolean = true);
begin
  FbMoving := true;
  FPoped := false;
  FTimer.Enabled := false;

  if not bQuick then
  begin
    while inherited Width - 15 > 10 do
    begin
      inherited Width := inherited Width - 15;
      Refresh();
      Application.ProcessMessages();
    end;
  end;
  inherited Width := 10;
  Refresh();

  FPinBtn.Visible := false;
  FbMoving := false;
  Repaint();
  if Assigned(FOnPush) then
    FOnPush(self);
end;

procedure TSidePanel.SetWidth(NewValue: Integer);
begin
  FnWidth := NewValue;

  if (csDesigning in ComponentState) or FPoped then
    inherited Width := FnWidth;
end;

function TSidePanel.GetSideColor: TColor;
begin
  Result := FSideColor;
end;

procedure TSidePanel.SetSideColor(NewValue: TColor);
begin
  FSideColor := NewValue;
  Repaint();
end;

procedure RoundPicture3(SrcBuf: TBitmap);
var
  Buf: TBitmap;
  i, j: Integer;
begin
  Buf := TBitmap.Create();

  Buf.Width := SrcBuf.Height;
  Buf.Height := SrcBuf.Width;

  for i := 0 to SrcBuf.Height do
    for j := 0 to SrcBuf.Width do
      Buf.Canvas.Pixels[i, j] := SrcBuf.Canvas.Pixels[j, SrcBuf.Height - i - 1];

  SrcBuf.Height := Buf.Height;
  SrcBuf.Width := Buf.Width;
  SrcBuf.Canvas.Draw(0, 0, Buf);

  Buf.Free();
end;

procedure TSidePanel.OnPinClick(Sender: TObject);
begin
  FTimer.Enabled := not FPinBtn.Down;
  FPinBtn.Glyph.LoadFromResourceName(hInstance, 'SIDEPANEL_BTN');
  if FPinBtn.Down then
    RoundPicture3(FPinBtn.Glyph);
  FStayOn := FPinBtn.Down;
  if FStayOn then
  begin
    if Assigned(FOnPin) then
      FOnPin(self);
  end
  else
  begin
    Push;
    if Assigned(FOnUnPin) then
      FOnUnPin(self);
  end;
  SetAlign(FAlign);
end;

function TSidePanel.GetSideWidth: Integer;
begin
  Result := 10;
end;

procedure TSidePanel.SetAlign(const Value: TSidePanelAlign);
begin
  FAlign := Value;
  if FStayOn then
  begin
    if FAlign = spaLeft then
      inherited Align := alLeft
    else
      inherited Align := alRight;
  end
  else
  begin
    inherited Align := alNone;
    if FAlign = spaLeft then
    begin
      Left := 0;
      Anchors := AnchorAlign[alLeft];
    end
    else
    begin
      Left := Parent.ClientWidth - Width;
      Anchors := AnchorAlign[alRight];
    end;
  end;
  RequestAlign;
end;

procedure TSidePanel.SetStayOn(const Value: Boolean);
begin
  FStayOn := Value;

  if Value then
  begin
    if not(csDesigning in ComponentState) then
      Pop(FQuickMove);
    FPinBtn.Down := true;
  end
  else
  begin
    FPinBtn.Down := false;
    if not(csDesigning in ComponentState) then
      Push(true);
  end;
  Resize();
  if not(csDesigning in ComponentState) then
    FPinBtn.Click();
end;

procedure TSidePanel.Paint;
var
  Buf: TBitmap;
  R: TRect;
  Y: Integer;
begin
  Buf := TBitmap.Create();
  Buf.Width := inherited Width;
  Buf.Height := Height;

  Buf.Canvas.Brush.Color := Color;
  Buf.Canvas.Pen.Color := FBorderColor;
  Buf.Canvas.Rectangle(ClientRect);

  R := Rect(1, 0, inherited Width - 1, FTitleBitmap.Height);
  Buf.Canvas.StretchDraw(R, FTitleBitmap);

  if FPoped or (csDesigning in ComponentState) then
  begin
    R.Left := R.Left + FPinBtn.Width;
    R.Right := R.Right - FPinBtn.Width;
    Buf.Canvas.Font.Assign(Font);
    Buf.Canvas.Font.Color := FCaptionFontColor;
    Buf.Canvas.Brush.Style := bsClear;
    case Alignment of
      taLeftJustify:
        DrawText(Buf.Canvas.Handle, PChar(Caption), -1, R,
          DT_LEFT or DT_SINGLELINE or DT_VCENTER);
      taCenter:
        DrawText(Buf.Canvas.Handle, PChar(Caption), -1, R,
          DT_CENTER or DT_SINGLELINE or DT_VCENTER);
      taRightJustify:
        DrawText(Buf.Canvas.Handle, PChar(Caption), -1, R,
          DT_RIGHT or DT_SINGLELINE or DT_VCENTER);
    end;
  end;

  R := Rect(1, FTitleBitmap.Height, 9, Height - 1);
  Buf.Canvas.Brush.Color := FSideColor;
  Buf.Canvas.FillRect(R);
  Buf.Canvas.Pen.Color := clGray;
  Buf.Canvas.MoveTo(9, FTitleBitmap.Height);
  Buf.Canvas.LineTo(9, Height - 1);
  Y := (Height - FHandleBitmap.Height) div 2;
  if Y < FTitleBitmap.Height + 1 then
    Y := FTitleBitmap.Height + 1;
  Buf.Canvas.Draw(1, Y, FHandleBitmap);

  BitBlt(Canvas.Handle, 0, 0, Width, Height, Buf.Canvas.Handle, 0, 0, SRCCOPY);

  Buf.Free();
end;

procedure TSidePanel.Resize;
begin
  inherited;

  if ((not FbMoving) and ( inherited Width > 10)) then
  begin
    FnWidth := inherited Width;
  end;

  FPinBtn.Left := Width - FPinBtn.Width - 1;
end;

function TSidePanel.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  if ((not FbMoving) and (FPinBtn.Visible) and (NewWidth < 50)) then
    Result := false
  else
    Result := true;
end;

procedure TSidePanel.SetBorderColor(const Value: TColor);
begin
  FBorderColor := Value;
  Repaint();
end;

procedure TSidePanel.SetCaptionFontColor(const Value: TColor);
begin
  FCaptionFontColor := Value;
  Repaint();
end;

procedure TSidePanel.AlignControls(AControl: TControl; var Rect: TRect);
begin
  Rect.Right := Rect.Right - 3;
  Rect.Bottom := Rect.Bottom - 3;
  Rect.Top := Rect.Top + FTitleBitmap.Height + 3;
  Rect.Left := Rect.Left + 13;
  inherited AlignControls(AControl, Rect);
end;

procedure TSidePanel.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Form: TCustomForm;
begin
  inherited;

  if FbMoving then
    Exit;

  if (FPoped or (FPopupMode <> spmMouseOn)) then
    Exit;
  Form := GetParentForm(self);
  if Form = nil then
    Exit;
  if (not Form.Active) and ((Form as TForm).FormStyle <> fsMDIForm) then
    Exit;
  // if not FormHasFocus(Form) then
  // Exit;
  Pop(FQuickMove);
end;

procedure TSidePanel.SetSideWidth(const Value: Integer);
begin
  // do nothing
end;

procedure TSidePanel.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;

  if FPoped or (FPopupMode <> spmMouseClick) then
    Exit;

  Pop(FQuickMove);
end;

procedure TSidePanel.SetHandleBitmap(const Value: TBitmap);
begin
  FHandleBitmap.Assign(Value);
  Repaint();
end;

procedure TSidePanel.SetTitleBitmap(const Value: TBitmap);
begin
  FTitleBitmap.Assign(Value);
  Repaint();
end;

procedure TSidePanel.WMERASEBKGND(var Msg: TMessage);
begin
  // do nothing
end;

procedure TSidePanel.CMTextChanged(var Msg: TMessage);
begin
  Repaint();
end;

procedure TSidePanel.SetShowButton(const Value: Boolean);
begin
  FShowButton := Value;
  if Value then
  begin
    FPinBtn.Top := 1;
  end
  else
  begin
    FPinBtn.Top := -50;
    StayOn := true;
  end;
end;

procedure Register;
begin
  RegisterComponents('Tree Browser', [TSidePanel]);
end;

end.
