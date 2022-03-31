unit TreeTab;
{$I ..\DEFS.INC}

interface

uses
  Types, Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Math, Menus, ExplorerTreeview,
  Dialogs, Forms, ImgList, CommCtrl, ExtCtrls, ComCtrls, GDIP, TreeViewNew,
  Buttons, StdCtrls, MSHTML, OleCtrls, SHDocVw, ActiveX;
{$R ..\TreeTab.res}

const
  GLOWSPEED = 50;
  GLOWSTEP = 20;
  IMG_SPACE = 2;
  DropDownSectWidth = 13;
  DEFAULT_TABHEIGHT = 26;
  PAGE_OFFSET = 1;
  PAGEBUTTON_SIZE = 16;

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 8; // Minor version nr.
  REL_VER = 2; // Release nr.
  BLD_VER = 1; // Build nr.

type
  TGDIPGradient = (ggRadial, ggVertical, ggDiagonalForward, ggDiagonalBackward);
{$IFDEF DELPHI_UNICODE}
  THintInfo = Controls.THintInfo;
  PHintInfo = Controls.PHintInfo;
{$ENDIF}
  TPageBrowser = class;
  TTabSheetBrowser = class;

  TMouseEnterTabEvent = procedure(Sender: TObject;
    ATabSheetBrowser: TTabSheetBrowser) of object;

  TGradientDirection = (gdHorizontal, gdVertical);
  TGlowState = (gsHover, gsPush, gsNone);
  TButtonLayout = (blGlyphLeft, blGlyphTop, blGlyphRight, blGlyphBottom);
  TImagePosition = (ipLeft, ipTop, ipRight, ipBottom);
  TDropDownPosition = (dpRight, dpBottom);
  TCloseOnTabPos = (cpRight, cpLeft);
  TTabShape = (tsRectangle, tsLeftRamp, tsRightRamp, tsLeftRightRamp);
  TPageBrowserStyle = (pbsGoogleChrome);
  TTabRounding = 0 .. 8;

  TPagerTabSettings = class(TPersistent)
  private
    FLeftMargin: Integer;
    FRightMargin: Integer;
    FOnChange: TNotifyEvent;
    FHeight: Integer;
    FStartMargin: Integer;
    FEndMargin: Integer;
    FSpacing: Integer;
    FWidth: Integer;
    FWordWrap: Boolean;
    FImagePosition: TImagePosition;
    FRounding: TTabRounding;
    FShape: TTabShape;
    FAlignment: TAlignment;
    procedure SetLeftMargin(const Value: Integer);
    procedure SetRightMargin(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetStartMargin(const Value: Integer);
    procedure SetEndMargin(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetWordWrap(const Value: Boolean);
    procedure SetImagePosition(const Value: TImagePosition);
    procedure SetRounding(const Value: TTabRounding);
    procedure SetShape(const Value: TTabShape);
    procedure SetAlignment(const Value: TAlignment);
  protected
    procedure Changed;
    property EndMargin: Integer read FEndMargin write SetEndMargin;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default
      taLeftJustify;
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin default 4;
    property RightMargin
      : Integer read FRightMargin write SetRightMargin default 4;
    property StartMargin
      : Integer read FStartMargin write SetStartMargin default 60;
    property Height: Integer read FHeight write SetHeight default 26;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
    property Width: Integer read FWidth write SetWidth default 0;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
    property ImagePosition: TImagePosition read FImagePosition write
      SetImagePosition default ipLeft;
    property Shape: TTabShape read FShape write SetShape default tsRectangle;
    property Rounding: TTabRounding read FRounding write SetRounding default 1;
  end;

  TGradientBackground = class(TPersistent)
  private
    FSteps: Integer;
    FColor: TColor;
    FColorTo: TColor;
    FDirection: TGradientDirection;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetDirection(const Value: TGradientDirection);
    procedure SetSteps(const Value: Integer);
    procedure Changed;
  protected
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property Direction: TGradientDirection read FDirection write SetDirection;
    property Steps: Integer read FSteps write SetSteps default 64;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TVistaBackground = class(TPersistent)
  private
    FSteps: Integer;
    FColor: TColor;
    FColorTo: TColor;
    FOnChange: TNotifyEvent;
    FColorMirror: TColor;
    FColorMirrorTo: TColor;
    FBorderColor: TColor;
    FGradientMirror: TGDIPGradient;
    FGradient: TGDIPGradient;
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetSteps(const Value: Integer);
    procedure Changed;
    procedure SetBorderColor(const Value: TColor);
    procedure SetColorMirror(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
    procedure SetGradient(const Value: TGDIPGradient);
    procedure SetGradientMirror(const Value: TGDIPGradient);
  protected
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property ColorMirror: TColor read FColorMirror write SetColorMirror;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo;
    property Gradient: TGDIPGradient read FGradient write SetGradient;
    property GradientMirror: TGDIPGradient read FGradientMirror write
      SetGradientMirror;
    property Steps: Integer read FSteps write SetSteps default 64;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TTabAppearance = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FBorderColor: TColor;
    FBorderColorHot: TColor;
    FColor: TColor;
    FColorTo: TColor;
    FColorHot: TColor;
    FColorHotTo: TColor;
    FColorSelectedTo: TColor;
    FBorderColorDisabled: TColor;
    FBorderColorSelected: TColor;
    FColorDisabled: TColor;
    FColorDisabledTo: TColor;
    FColorSelected: TColor;
    FColorMirror: TColor;
    FColorMirrorTo: TColor;
    FColorMirrorHot: TColor;
    FColorMirrorHotTo: TColor;
    FGradientMirror: TGDIPGradient;
    FGradientMirrorHot: TGDIPGradient;
    FGradient: TGDIPGradient;
    FGradientHot: TGDIPGradient;
    FColorMirrorDisabledTo: TColor;
    FColorMirrorDisabled: TColor;
    FColorMirrorSelectedTo: TColor;
    FColorMirrorSelected: TColor;
    FGradientSelected: TGDIPGradient;
    FGradientDisabled: TGDIPGradient;
    FGradientMirrorSelected: TGDIPGradient;
    FGradientMirrorDisabled: TGDIPGradient;
    FTextColorDisabled: TColor;
    FTextColorSelected: TColor;
    FTextColor: TColor;
    FTextColorHot: TColor;
    FBackGround: TGradientBackground;
    FBorderColorSelectedHot: TColor;
    FBorderColorDown: TColor;
    FFont: TFont;
    FHighLightColorHot: TColor;
    FShadowColor: TColor;
    FHighLightColorDown: TColor;
    FHighLightColorSelected: TColor;
    FHighLightColorSelectedHot: TColor;
    FHighLightColor: TColor;
    FOnFontChange: TNotifyEvent;
    procedure OnBackGroundChanged(Sender: TObject);
    procedure OnFontChanged(Sender: TObject);
    procedure SetBackGround(const Value: TGradientBackground);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderColorDisabled(const Value: TColor);
    procedure SetBorderColorSelected(const Value: TColor);
    procedure SetBorderColorSelectedHot(const Value: TColor);
    procedure SetColor(const Value: TColor);
    procedure SetColorDisabled(const Value: TColor);
    procedure SetColorDisabledTo(const Value: TColor);
    procedure SetColorHot(const Value: TColor);
    procedure SetColorHotTo(const Value: TColor);
    procedure SetColorMirror(const Value: TColor);
    procedure SetColorMirrorDisabled(const Value: TColor);
    procedure SetColorMirrorDisabledTo(const Value: TColor);
    procedure SetColorMirrorHot(const Value: TColor);
    procedure SetColorMirrorHotTo(const Value: TColor);
    procedure SetColorMirrorSelected(const Value: TColor);
    procedure SetColorMirrorSelectedTo(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
    procedure SetColorSelected(const Value: TColor);
    procedure SetColorSelectedTo(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetGradient(const Value: TGDIPGradient);
    procedure SetGradientDisabled(const Value: TGDIPGradient);
    procedure SetGradientHot(const Value: TGDIPGradient);
    procedure SetGradientMirror(const Value: TGDIPGradient);
    procedure SetGradientMirrorDisabled(const Value: TGDIPGradient);
    procedure SetGradientMirrorHot(const Value: TGDIPGradient);
    procedure SetGradientMirrorSelected(const Value: TGDIPGradient);
    procedure SetGradientSelected(const Value: TGDIPGradient);
    procedure SetTextColor(const Value: TColor);
    procedure SetTextColorDisabled(const Value: TColor);
    procedure SetTextColorHot(const Value: TColor);
    procedure SetTextColorSelected(const Value: TColor);
    procedure SetBorderColorDown(const Value: TColor);
    procedure SetFont(const Value: TFont);
  protected
    procedure Changed;
    property BackGround: TGradientBackground read FBackGround write
      SetBackGround;
    property OnFontChange: TNotifyEvent read FOnFontChange write FOnFontChange;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderColorHot: TColor read FBorderColorHot write FBorderColorHot;
    property BorderColorSelected: TColor read FBorderColorSelected write
      SetBorderColorSelected;
    property BorderColorSelectedHot: TColor read FBorderColorSelectedHot write
      SetBorderColorSelectedHot;
    property BorderColorDisabled: TColor read FBorderColorDisabled write
      SetBorderColorDisabled;
    property BorderColorDown
      : TColor read FBorderColorDown write SetBorderColorDown;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property ColorSelected: TColor read FColorSelected write SetColorSelected;
    property ColorSelectedTo
      : TColor read FColorSelectedTo write SetColorSelectedTo;
    property ColorDisabled: TColor read FColorDisabled write SetColorDisabled;
    property ColorDisabledTo
      : TColor read FColorDisabledTo write SetColorDisabledTo;
    property ColorHot: TColor read FColorHot write SetColorHot;
    property ColorHotTo: TColor read FColorHotTo write SetColorHotTo;
    property ColorMirror: TColor read FColorMirror write SetColorMirror;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo;
    property ColorMirrorHot
      : TColor read FColorMirrorHot write SetColorMirrorHot;
    property ColorMirrorHotTo: TColor read FColorMirrorHotTo write
      SetColorMirrorHotTo;
    property ColorMirrorSelected: TColor read FColorMirrorSelected write
      SetColorMirrorSelected;
    property ColorMirrorSelectedTo: TColor read FColorMirrorSelectedTo write
      SetColorMirrorSelectedTo;
    property ColorMirrorDisabled: TColor read FColorMirrorDisabled write
      SetColorMirrorDisabled;
    property ColorMirrorDisabledTo: TColor read FColorMirrorDisabledTo write
      SetColorMirrorDisabledTo;
    property Font: TFont read FFont write SetFont;
    property Gradient: TGDIPGradient read FGradient write SetGradient;
    property GradientMirror: TGDIPGradient read FGradientMirror write
      SetGradientMirror;
    property GradientHot: TGDIPGradient read FGradientHot write SetGradientHot;
    property GradientMirrorHot: TGDIPGradient read FGradientMirrorHot write
      SetGradientMirrorHot;
    property GradientSelected: TGDIPGradient read FGradientSelected write
      SetGradientSelected;
    property GradientMirrorSelected
      : TGDIPGradient read FGradientMirrorSelected write
      SetGradientMirrorSelected;
    property GradientDisabled: TGDIPGradient read FGradientDisabled write
      SetGradientDisabled;
    property GradientMirrorDisabled
      : TGDIPGradient read FGradientMirrorDisabled write
      SetGradientMirrorDisabled;
    property TextColor: TColor read FTextColor write SetTextColor;
    property TextColorHot: TColor read FTextColorHot write SetTextColorHot;
    property TextColorSelected: TColor read FTextColorSelected write
      SetTextColorSelected;
    property TextColorDisabled: TColor read FTextColorDisabled write
      SetTextColorDisabled;
    property ShadowColor: TColor read FShadowColor write FShadowColor;
    property HighLightColor: TColor read FHighLightColor write FHighLightColor;
    property HighLightColorHot
      : TColor read FHighLightColorHot write FHighLightColorHot;
    property HighLightColorSelected: TColor read FHighLightColorSelected write
      FHighLightColorSelected;
    property HighLightColorSelectedHot
      : TColor read FHighLightColorSelectedHot write FHighLightColorSelectedHot;
    property HighLightColorDown
      : TColor read FHighLightColorDown write FHighLightColorDown;
  end;

  TDbgList = class(TList)
  private
    function GetItemsEx(Index: Integer): Pointer;
    procedure SetItemsEx(Index: Integer; const Value: Pointer);
  public
    property Items[Index: Integer]: Pointer read GetItemsEx write SetItemsEx;
    default;
  end;

  TPageButtonSettings = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FCloseButton: Boolean;
    FCloseButtonPicture: TPicture;
    FCloseButtonHint: String;
    procedure Changed;
    procedure SetCloseButton(const Value: Boolean);
    procedure SetCloseButtonPicture(const Value: TPicture);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CloseButton
      : Boolean read FCloseButton write SetCloseButton default False;
    property CloseButtonPicture: TPicture read FCloseButtonPicture write
      SetCloseButtonPicture;
    property CloseButtonHint
      : String read FCloseButtonHint write FCloseButtonHint;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TPageBrowserStyler = class(TComponent)
  private
    FControlList: TDbgList;
    FTabAppearance: TTabAppearance;
    FPageAppearance: TVistaBackground;
    FRoundEdges: Boolean;
    FAutoThemeAdapt: Boolean;
    FBlendFactor: Integer;
    procedure OnTabAppearanceChanged(Sender: TObject);
    procedure OnTabAppearanceFontChanged(Sender: TObject);
    procedure OnPageAppearanceChanged(Sender: TObject);
    procedure SetRoundEdges(const Value: Boolean);
    procedure SetTabAppearance(const Value: TTabAppearance);
    procedure SetPageAppearance(const Value: TVistaBackground);
  protected
    procedure AddControl(AControl: TCustomControl);
    procedure RemoveControl(AControl: TCustomControl);
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure Change(PropID: Integer);
    property BlendFactor: Integer read FBlendFactor write FBlendFactor;

    property AutoThemeAdapt
      : Boolean read FAutoThemeAdapt write FAutoThemeAdapt default False;
    property TabAppearance: TTabAppearance read FTabAppearance write
      SetTabAppearance; // 1
    property PageAppearance: TVistaBackground read FPageAppearance write
      SetPageAppearance; // 2
    property RoundEdges
      : Boolean read FRoundEdges write SetRoundEdges default True; // 3
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure Assign(Source: TPersistent); override;
  end;

  TProWinControl = class(TWinControl)
  end;

  TToolbar = class(TObject)
  private
    FButtonBack, FButtonBackDown, FButtonForward, FButtonForwardDown,
      FSpeedButtonGo: TSpeedButton;
    FComboBox: TComboBox;
    FIcon: TImage;
    FHeight, FControlsTop, FSide: Integer;
    FVisible: Boolean;
    FParent: TWinControl;
    procedure SetParent(AParent: TWinControl);
    procedure SetHeight(val: Integer);
    procedure SetVisible(val: Boolean);
    procedure OnComboBoxKeyPress(Sender: TObject; var Key: Char);
    procedure OnButtonBackClick(Sender: TObject);
    procedure OnButtonForwardClick(Sender: TObject);
    procedure OnButtonGoClick(Sender: TObject);
  protected

  public
    constructor Create(AOwner: TTabSheetBrowser);
    destructor Destroy; override;
    property Parent: TWinControl read FParent write SetParent;
  private

  public
    property Height: Integer read FHeight write SetHeight default 10;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TObjectProcedure = procedure of object;

  TEventObject = class(TInterfacedObject, IDispatch)
  private
    FOnEvent: TObjectProcedure;
  protected
    function GetTypeInfoCount(out Count: Integer): HResult; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HResult;
      stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HResult; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HResult;
      stdcall;
  public
    constructor Create(const OnEvent: TObjectProcedure);
    property OnEvent: TObjectProcedure read FOnEvent write FOnEvent;
  end;

  TTreeTab = class;

  TTabSheetBrowser = class(TCustomControl)
  private
    FPageBrowserChild: TPageBrowser;
    FWebBrowser: TWebBrowser;
    FPanelWebBrowser: TPanel;
    FToolbar: TToolbar;
    FTabSheetParent: TTabSheetBrowser;
    FTreeNodeETC: TTreeNode;
    FTreeNodeTV: TTreeNode;
    FNodeButton: TNodeButton;
    FURL: string;
    FhtmlDoc: IHTMLDocument2;
    FTabVisible: Boolean;
    FPageBrowser: TPageBrowser;
    FCaption: TCaption;
    FTabEnabled: Boolean;
    FImageIndex: Integer;
    FTimer: TTimer;
    FTimeInc: Integer;
    FStepHover: Integer;
    FStepPush: Integer;
    FGlowState: TGlowState;
    FTabHint: string;
    FIPicture: TPicture;
    FIDisabledPicture: TPicture;
    FUpdatingParent: Boolean;
    FOnShow: TNotifyEvent;
    FOnHide: TNotifyEvent;
    FShowClose: Boolean;
    FUseTabAppearance: Boolean;
    FTabAppearance: TTabAppearance;
    FPageAppearance: TVistaBackground;
    FUsePageAppearance: Boolean;
    FBkgCache: TBitmap;
    FValidCache: Boolean;
    FWideCaption: widestring;
    FShowCheckBox: Boolean;
    FChecked: Boolean;
    FCloseButton: TSpeedButton;
    URLNewTab: string;
    procedure TimerProc(Sender: TObject);
    procedure WMSize(var Message: TWMSize);
    message WM_SIZE;
    procedure CMVisibleChanged(var Message: TMessage);
    message CM_VISIBLECHANGED;
    procedure CMShowingChanged(var Message: TMessage);
    message CM_SHOWINGCHANGED;
    procedure CMControlChange(var Message: TCMControlChange);
    message CM_CONTROLCHANGE;
    procedure CMControlListChange(var Message: TCMControlListChange);
    message CM_CONTROLLISTCHANGE;
    procedure WMEraseBkGnd(var Message: TWMEraseBkGnd);
    message WM_ERASEBKGND;
    procedure PictureChanged(Sender: TObject);
    procedure SetPageBrowser(const Value: TPageBrowser);
    procedure SetTabVisible(const Value: Boolean);
    procedure SetCaption(const Value: TCaption);
    procedure SetTabEnabled(const Value: Boolean);
    procedure SetImageIndex(const Value: Integer);
    procedure SetDisabledPicture(const Value: TPicture);
    procedure SetPicture(const Value: TPicture);
    function GetPageIndex: Integer;
    procedure SetPageIndex(const Value: Integer);
    procedure SetShowClose(const Value: Boolean);
    procedure SetTabAppearance(const Value: TTabAppearance);
    procedure SetUseTabAppearance(const Value: Boolean);
    procedure SetPageAppearance(const Value: TVistaBackground);
    procedure SetUsePageAppearance(const Value: Boolean);
    procedure SetWideCaption(const Value: widestring);
    procedure SetShowCheckBox(const Value: Boolean);
    procedure SetChecked(const Value: Boolean);
    procedure OnTabAppearanceFontChanged(Sender: TObject);
    procedure OnTabAppearanceChanged(Sender: TObject);
    procedure OnPageAppearanceChanged(Sender: TObject);
    procedure OnWebBrowserNewWindow2(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool);
    procedure OnWebBrowserBeforeNavigate2(ASender: TObject;
      const pDisp: IDispatch; var URL, Flags, TargetFrameName, PostData,
      Headers: OleVariant; var Cancel: WordBool);
    procedure OnWebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; var URL: OleVariant);
    procedure OnWebBrowserTitleChange(ASender: TObject; const Text: widestring);
    procedure Document_OnMouseOver;
    procedure SetURL(const Value: string);
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetParent(AParent: TWinControl); override;
    procedure Paint; override;
    procedure ReadState(Reader: TReader); override;
    procedure AdjustClientRect(var Rect: TRect); override;
  public
    FHeighta: Integer;
    FTreeTab: TTreeTab;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Delete;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SelectFirstControl;

    property PageBrowser: TPageBrowser read FPageBrowser write SetPageBrowser;
    property PageBrowserChild: TPageBrowser read FPageBrowserChild;
    property Toolbar: TToolbar read FToolbar write FToolbar;
    property WebBrowser: TWebBrowser read FWebBrowser write FWebBrowser;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property WideCaption: widestring read FWideCaption write SetWideCaption;
    property DisabledPicture: TPicture read FIDisabledPicture write
      SetDisabledPicture;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -
      1;
    property PageAppearance: TVistaBackground read FPageAppearance write
      SetPageAppearance;
    property UsePageAppearance: Boolean read FUsePageAppearance write
      SetUsePageAppearance default False;
    property Picture: TPicture read FIPicture write SetPicture;
    property TabHint: string read FTabHint write FTabHint;
    property TabVisible
      : Boolean read FTabVisible write SetTabVisible default True;
    property TabEnabled
      : Boolean read FTabEnabled write SetTabEnabled default True;
    property ShowClose: Boolean read FShowClose write SetShowClose default True;
    property ShowHint;
    property PageIndex
      : Integer read GetPageIndex write SetPageIndex stored False;
    property TabAppearance: TTabAppearance read FTabAppearance write
      SetTabAppearance;
    property UseTabAppearance: Boolean read FUseTabAppearance write
      SetUseTabAppearance default False;
    property ShowCheckBox
      : Boolean read FShowCheckBox write SetShowCheckBox default False;
    property Checked: Boolean read FChecked write SetChecked default False;
    property OnHide: TNotifyEvent read FOnHide write FOnHide;
    property OnShow: TNotifyEvent read FOnShow write FOnShow;
    property TabSheetParent
      : TTabSheetBrowser read FTabSheetParent write FTabSheetParent;
    property NodeButton: TNodeButton read FNodeButton write FNodeButton;
    property URL: string read FURL write SetURL;
    property OnClick;
    property OnDblClick;
    property PopupMenu;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDragOver;
    property OnDragDrop;
    property OnEndDrag;
    property OnStartDrag;
    property OnExit;
    property OnEnter;

  end;

  TTabChangingEvent = procedure(Sender: TObject; FromPage, ToPage: Integer;
    var AllowChange: Boolean) of object;
  TOnClosePage = procedure(Sender: TObject; PageIndex: Integer;
    var Allow: Boolean) of object;
  TOnClosedPage = procedure(Sender: TObject; PageIndex: Integer) of object;

  TOnPageListClick = procedure(Sender: TObject; X, Y: Integer) of object;
  TTabMovedEvent = procedure(Sender: TObject; FromPos: Integer; ToPos: Integer)
    of object;
  TDrawTabEvent = procedure(Sender: TObject; TabIndex: Integer; TabRect: TRect)
    of object;
  TTabClickEvent = procedure(Sender: TObject; PageIndex: Integer) of object;

  TPageBrowser = class(TCustomControl)
  private
    FButtonNewTab, FButtonNewSubtab: TSpeedButton;
    FPageBrowserStyler: TPageBrowserStyler;
    FPageMargin: Integer;
    FOffSetY: Integer;
    FOffSetX: Integer;
    FPages: TDbgList;
    FPropertiesLoaded: Boolean;
    FShowNonSelectedTabs: Boolean;
    FTabSettings: TPagerTabSettings;
    FActivePageIndex: Integer;
    FHotPageIndex: Integer;
    FDownPageIndex: Integer;
    FOldHotPageIndex: Integer;
    FHintPageIndex: Integer;
    FImages: TCustomImageList;
    FDisabledImages: TCustomImageList;
    FNewPage: TTabSheetBrowser;
    FUndockPage: TTabSheetBrowser;
    FShowTabHint: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TTabChangingEvent;
    FOldCapRightIndent: Integer;
    FTabPosition: TTabPosition;
    FAntiAlias: TAntiAlias;
    FButtonSettings: TPageButtonSettings;
    FOnClosePage: TOnClosePage;
    FOnClosedPage: TOnClosedPage;
    FOnPageListClick: TOnPageListClick;
    FRotateTabLeftRight: Boolean;
    FTabOffSet: Integer;
    FUseMaxSpace: Boolean;
    FFreeOnClose: Boolean;
    FFormWndProc: TWndMethod;
    FTabReorder: Boolean;
    FOnTabMoved: TTabMovedEvent;
    FIsClosing: Boolean;
    FOnDrawTab: TDrawTabEvent;
    FButtonsBkg: TBitmap;
    FCloseOnTabPosition: TCloseOnTabPos;
    FDesignTime: Boolean;
    FBufferedPages: Boolean;
    FOnTabClick: TTabClickEvent;
    FOnTabDblClick: TTabClickEvent;
    FOnTabRightClick: TTabClickEvent;
    FOnTabCheckBoxClick: TTabClickEvent;
    FGlow: Boolean;
    FTransparent: Boolean;
    FShowCloseOnNonSelectedTabs: Boolean;
    FOnLastClick: TNotifyEvent;
    FOnFirstClick: TNotifyEvent;
    FOnPrevClick: TNotifyEvent;
    FOnNextClick: TNotifyEvent;
    FOnMouseEnterTab: TMouseEnterTabEvent;
    procedure WMSize(var Message: TWMSize);
    message WM_SIZE;
    procedure CMVisibleChanged(var Message: TMessage);
    message CM_VISIBLECHANGED;
    procedure CMShowingChanged(var Message: TMessage);
    message CM_SHOWINGCHANGED;
    procedure CMControlChange(var Message: TCMControlChange);
    message CM_CONTROLCHANGE;
    procedure CMControlListChange(var Message: TCMControlListChange);
    message CM_CONTROLLISTCHANGE;
    procedure CMMouseLeave(var Message: TMessage);
    message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Msg: TMessage);
    message CM_MOUSEENTER;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest);
    message CM_DESIGNHITTEST;
    procedure CMHintShow(var Message: TMessage);
    message CM_HINTSHOW;
    procedure WMNCHitTest(var Msg: TWMNCHitTest);
    message WM_NCHITTEST;
    procedure CMDialogChar(var Message: TCMDialogChar);
    message CM_DIALOGCHAR;
    procedure WMKeyDown(var Message: TWMKeyDown);
    message WM_KEYDOWN;
    procedure CMDialogKey(var Message: TCMDialogKey);
    message CM_DIALOGKEY;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode);
    message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TWMSetFocus);
    message WM_KILLFOCUS;
    procedure CMFocusChanged(var Message: TCMFocusChanged);
    message CM_FOCUSCHANGED;
    procedure WMLButtonDown(var Message: TWMLButtonDown);
    message WM_LBUTTONDOWN;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk);
    message WM_LBUTTONDBLCLK;
    procedure CMDockClient(var Message: TCMDockClient);
    message CM_DOCKCLIENT;
    procedure CMDockNotification(var Message: TCMDockNotification);
    message CM_DOCKNOTIFICATION;
    procedure CMUnDockClient(var Message: TCMUnDockClient);
    message CM_UNDOCKCLIENT;

    procedure OnTabSettingsChanged(Sender: TObject);
    procedure OnButtonSettingChanged(Sender: TObject);
    procedure OnCloseButtonClick(Sender: TObject);
    procedure OnExitTab(PageIndex: Integer);
    procedure SetPageValidCache(Value: Boolean);
    procedure SetPagePosition(Page: TTabSheetBrowser);
    procedure SetAllPagesPosition;
    function GetTabSheetBrowserCount: Integer;
    function GetTabSheetBrowser(index: Integer): TTabSheetBrowser;
    function GetPopupMenuEx: TPopupMenu;
    procedure SetPopupMenuEx(const Value: TPopupMenu);
    procedure SetShowNonSelectedTabs(const Value: Boolean);
    function GetActivePage: TTabSheetBrowser;
    function GetActivePageIndex: Integer;
    procedure SetActivePage(const Value: TTabSheetBrowser);
    procedure SetActivePageIndex(const Value: Integer);
    procedure SetTabSettings(const Value: TPagerTabSettings);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetDisabledImages(const Value: TCustomImageList);
    procedure SetTabPosition(const Value: TTabPosition);
    procedure SetAntiAlias(const Value: TAntiAlias);
    procedure SetButtonSettings(const Value: TPageButtonSettings);
    procedure SetRotateTabLeftRight(const Value: Boolean);
    procedure SetPageMargin(const Value: Integer);
    procedure SetCloseOnTabPosition(const Value: TCloseOnTabPos);
    function GetDockClientFromMousePos(MousePos: TPoint): TControl;
    procedure SetShowCloseOnNonSelectedTabs(const Value: Boolean);
    procedure SetTransparent(const Value: Boolean);
    procedure UpdateButtonsPos;
    procedure TabWidth;
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetParent(AParent: TWinControl); override;
    procedure WndProc(var Msg: TMessage); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure DoAddDockClient(Client: TControl; const ARect: TRect); override;
    procedure DockOver(Source: TDragDockObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean); override;
    procedure DoRemoveDockClient(Client: TControl); override;
    function GetPageFromDockClient(Client: TControl): TTabSheetBrowser;

    procedure AdjustClientRect(var Rect: TRect); override;
    procedure DrawTab(PageIndex: Integer);
    procedure DrawAllTabs;
    procedure Paint; override;

    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    procedure SetPageBounds(Page: TTabSheetBrowser; var ALeft, ATop, AWidth,
      AHeight: Integer);

    procedure UpdateMe(PropID: Integer);
    procedure ChangeActivePage(PageIndex: Integer);

    procedure InitializeAndUpdateButtons;

    function CanShowTab(PageIndex: Integer): Boolean;
    function GetVisibleTabCount: Integer;

    function GetTextSize(PageIndex: Integer): TSize;
    function GetTabImageSize(PageIndex: Integer): TSize;
    procedure GetCloseBtnImageAndTextRect(PageIndex: Integer; var CloseBtnR,
      TextR: TRect; var ImgP: TPoint); // used when TabSettings.Width > 0
    procedure InvalidateTab(PageIndex: Integer);
    function GetPageRect: TRect;
    function GetTabsArea: TRect;
    function GetTabsRect: TRect;
    function GetTabRect(StartIndex, PageIndex: Integer): TRect; overload;
    function PTOnTab(X, Y: Integer): Integer;
    function PTOnCheckBox(PageIndex, X, Y: Integer): Boolean;
    function GetCheckBoxRect(PageIndex: Integer): TRect;
    function GetCloseButtonRect(PageIndex: Integer): TRect;

    function IsActivePageNeighbour(PageIndex: Integer): Integer;
    // -1= previous;  0= No;   +1= Next
    function GetLeftRoundingOffset: Integer;
    function GetRightRoundingOffset: Integer;

    function CanShowCloseButton: Boolean;
    function UseOldDrawing: Boolean;
    procedure UpdatePageAppearanceOfPages;
    procedure UpdateTabAppearanceOfPages;

  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    destructor Destroy; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure Init;
    function CloseActivePage: Boolean;
    function GetTabRect(PageIndex: Integer): TRect; overload;
    function GetTabRect(Page: TTabSheetBrowser): TRect; overload;

    procedure DragDrop(Source: TObject; X, Y: Integer); override;

    function AddPage(Page: TTabSheetBrowser): Integer; overload;
    function AddPage(PageCaption: TCaption): Integer; overload;
    procedure RemovePage(Page: TTabSheetBrowser);
    procedure MovePage(CurIndex, NewIndex: Integer);
    function FindNextPage(CurPage: TTabSheetBrowser; GoForward,
      CheckTabVisible: Boolean): TTabSheetBrowser;
    procedure SelectNextPage(GoForward: Boolean);
    function IndexOfPage(Page: TTabSheetBrowser): Integer;
    function IndexOfTabAt(X, Y: Integer): Integer;
    property ActivePageIndex: Integer read GetActivePageIndex write
      SetActivePageIndex;
    property BufferedPages: Boolean read FBufferedPages write FBufferedPages;
    property TabSheetBrowserCount: Integer read GetTabSheetBrowserCount;
    property TabSheetBrowser[index: Integer]
      : TTabSheetBrowser read GetTabSheetBrowser;
    property HotPageIndex: Integer read FHotPageIndex;
    property ButtonNewTab: TSpeedButton read FButtonNewTab;
    property ButtonNewSubtab: TSpeedButton read FButtonNewSubtab;
  published
    property Align;
    property Anchors;
    property ActivePage
      : TTabSheetBrowser read GetActivePage write SetActivePage;
    property AntiAlias: TAntiAlias read FAntiAlias write SetAntiAlias default
      aaClearType;
    property ButtonSettings: TPageButtonSettings read FButtonSettings write
      SetButtonSettings;
    property Constraints;
    property CloseOnTabPosition: TCloseOnTabPos read FCloseOnTabPosition write
      SetCloseOnTabPosition default cpRight;
    property DisabledImages: TCustomImageList read FDisabledImages write
      SetDisabledImages;
    property FreeOnClose
      : Boolean read FFreeOnClose write FFreeOnClose default False;
    property DockSite;
    property Glow: Boolean read FGlow write FGlow default True;
    property Images: TCustomImageList read FImages write SetImages;
    property PageMargin: Integer read FPageMargin write SetPageMargin default 1;
    property PopupMenu: TPopupMenu read GetPopupMenuEx write SetPopupMenuEx;
    property RotateTabLeftRight: Boolean read FRotateTabLeftRight write
      SetRotateTabLeftRight default True;
    property ShowCloseOnNonSelectedTabs
      : Boolean read FShowCloseOnNonSelectedTabs write
      SetShowCloseOnNonSelectedTabs default True;
    property ShowNonSelectedTabs: Boolean read FShowNonSelectedTabs write
      SetShowNonSelectedTabs default True;
    property ShowTabHint
      : Boolean read FShowTabHint write FShowTabHint default False;
    property ShowHint;
    property TabPosition
      : TTabPosition read FTabPosition write SetTabPosition default tpTop;
    property TabSettings: TPagerTabSettings read FTabSettings write
      SetTabSettings;
    property TabReorder: Boolean read FTabReorder write FTabReorder;
    property Transparent
      : Boolean read FTransparent write SetTransparent default False;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TTabChangingEvent read FOnChanging write FOnChanging;
    property OnClosePage: TOnClosePage read FOnClosePage write FOnClosePage;
    property OnClosedPage: TOnClosedPage read FOnClosedPage write FOnClosedPage;
    property OnDrawTab: TDrawTabEvent read FOnDrawTab write FOnDrawTab;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnDockDrop;
    property OnDockOver;
    property OnEndDock;
    property OnStartDock;
    property OnUnDock;

    property OnEnter;
    property OnExit;
    property OnPageListClick
      : TOnPageListClick read FOnPageListClick write FOnPageListClick;
    property OnTabMoved: TTabMovedEvent read FOnTabMoved write FOnTabMoved;
    property OnTabClick: TTabClickEvent read FOnTabClick write FOnTabClick;
    property OnTabCheckBoxClick: TTabClickEvent read FOnTabCheckBoxClick write
      FOnTabCheckBoxClick;
    property OnTabDblClick
      : TTabClickEvent read FOnTabDblClick write FOnTabDblClick;
    property OnTabRightClick
      : TTabClickEvent read FOnTabRightClick write FOnTabRightClick;
    property OnKeyDown;
    property OnKeyUp;
    property OnKeyPress;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseEnterTab: TMouseEnterTabEvent read FOnMouseEnterTab write
      FOnMouseEnterTab;
    property OnResize;
    property OnStartDrag;
    property TabOrder;
    property TabStop;
    property OnPrevClick: TNotifyEvent read FOnPrevClick write FOnPrevClick;
    property OnNextClick: TNotifyEvent read FOnNextClick write FOnNextClick;
    property OnFirstClick: TNotifyEvent read FOnFirstClick write FOnFirstClick;
    property OnLastClick: TNotifyEvent read FOnLastClick write FOnLastClick;
  end;

  TTreeTab = class(TCustomPanel)
  private
    { Private declarations }
    FMainPageBrowser: TPageBrowser;
    FTabSheetList: TList;
    FSelected, FOldSelected: TTabSheetBrowser;
    FbMoving: Boolean;
    FPoped: Boolean;
    FQuickMove: Boolean;
    FnTop: Integer;
    FTimer: TTimer;
    FSelList: TList;
    FBackList: TList;
    FBack: Boolean;
    FTreeViewNew: TTreeViewNew;
    FExplorerTreeComboBox: TExplorerTreeComboBox;

    FOnPop: TNotifyEvent;
    FOnPush: TNotifyEvent;
    FPinBtn: TSpeedButton;
    FStayOn: Boolean;
    FOnPin: TNotifyEvent;
    FOnUnPin: TNotifyEvent;
    FImages: TCustomImageList;
    FB: TBitmap;

    procedure SetSelected(const Value: TTabSheetBrowser);
    procedure SetStayOn(const Value: Boolean);
    procedure SetExplorerTreeComboBox(const Value: TExplorerTreeComboBox);
    procedure SetTreeView(const Value: TTreeViewNew);
    procedure SetImages(const Value: TCustomImageList);
    function GetExplorerTreeComboBox: TExplorerTreeComboBox;
    function GetTreeView: TTreeViewNew;

    procedure SelectExplorerTreeComboBox;
    procedure SelectTreeView;

    procedure OnButtonNewTabClick(Sender: TObject);
    procedure OnButtonNewSubtabClick(Sender: TObject);
    procedure OnPageBrowserClosePage(Sender: TObject; PageIndex: Integer;
      var Allow: Boolean);

    procedure OnTreeViewButtonAddClick(Sender: TObject);
    procedure OnTreeViewButtonAddSubClick(Sender: TObject);
    procedure OnTreeViewButtonDeleteClick(Sender: TObject);
    procedure OnTreeViewButtonGoClick(Sender: TObject);

    procedure OnPageBrowserShow(Sender: TObject);
    procedure OnPageBrowserTabClick(Sender: TObject; PageIndex: Integer);
    procedure OnPageBrowserMouseEnterTab(Sender: TObject;
      ATabSheetBrowser: TTabSheetBrowser);
    procedure OnTimerCheck(Sender: TObject);
    procedure OnPinClick(Sender: TObject);
    procedure OnTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure OnExplorerTreeComboBoxSelect(Sender: TObject; Node: TTreeNode);

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function add(AParent: TTabSheetBrowser; AURL: string = 'about:blank')
      : TTabSheetBrowser;
    procedure Remove(ATabSheetBrowser: TTabSheetBrowser);
    procedure Pop(bQuick: Boolean = True);
    procedure Push(bQuick: Boolean = True);
    function SelectBack: Boolean;
    function SelectForward: Boolean;
    property Selected: TTabSheetBrowser read FSelected write SetSelected;
  published
    { Published declarations }
    property StayOn: Boolean read FStayOn write SetStayOn;
    property OnPin: TNotifyEvent read FOnPin write FOnPin;
    property OnUnPin: TNotifyEvent read FOnUnPin write FOnUnPin;
    property Images: TCustomImageList read FImages write SetImages;
    property ExplorerTreeComboBox
      : TExplorerTreeComboBox read GetExplorerTreeComboBox write
      SetExplorerTreeComboBox;
    property TreeViewNew: TTreeViewNew read GetTreeView write SetTreeView;
    property Align;
    property Anchors;
    property Constraints;
    property DockSite;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnDockDrop;
    property OnDockOver;
    property OnEndDock;
    property OnStartDock;
    property OnUnDock;
    property OnEnter;
    property OnExit;
  end;

  { function DrawVistaText(Canvas: TCanvas; Alignment: TAlignment; r: TRect; Caption:string; AFont: TFont; Enabled: Boolean; RealDraw: Boolean; AntiAlias: TAntiAlias; Direction: TTabPosition): TRect;
    procedure DrawVistaGradient(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB, PC: TColor;
    GradientU,GradientB: TGDIPGradient; Caption:string; AFont: TFont; Enabled: Boolean; Focus: Boolean;
    AntiAlias: TAntiAlias; RoundEdges: Boolean; Direction: TTabPosition = tpTop; X: Integer = 0; Y: Integer =0; Ang: Single = 0); overload;
    }
procedure DrawVistaTab(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB,
  PC: TColor; GradientU, GradientB: TGDIPGradient; Enabled: Boolean;
  Shape: TTabShape; Focus: Boolean;
  { AntiAlias: TAntiAlias; } Rounding: TTabRounding; RotateLeftRight: Boolean;
  Direction: TTabPosition);

procedure Register;

implementation

type
  TAccessCanvas = class(TCanvas)
  end;

var
  WM_OPDESTROYCLOSEBTN: Word;

  // ------------------------------------------------------------------------------

function ColorToARGB(Color: TColor): ARGB;

var
  c: TColor;
begin
  c := ColorToRGB(Color);
  Result := ARGB($FF000000 or ((dword(c) and $FF) shl 16) or
      ((dword(c) and $FF00) or ((dword(c) and $FF0000) shr 16)));
end;

// ------------------------------------------------------------------------------

procedure DrawGradient(Canvas: TCanvas; FromColor, ToColor: TColor;
  Steps: Integer; r: TRect; Direction: Boolean);

var
  diffr, startr, endr: Integer;
  diffg, startg, endg: Integer;
  diffb, startb, endb: Integer;
  rstepr, rstepg, rstepb, rstepw: Real;
  i, stepw: Word;

begin
  if Direction then
    r.Right := r.Right - 1
  else
    r.Bottom := r.Bottom - 1;

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
    rstepw := (r.Right - r.Left) / Steps
  else
    rstepw := (r.Bottom - r.Top) / Steps;

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
        Rectangle(r.Left + stepw, r.Top, r.Left + stepw + Round(rstepw) + 1,
          r.Bottom)
      else
        Rectangle(r.Left, r.Top + stepw, r.Right, r.Top + stepw + Round(rstepw)
            + 1);
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

procedure DrawRoundRect(Graphics: TGPGraphics; Pen: TGPPen; X, Y, Width,
  Height, Radius: Integer);

var
  path: TGPGraphicsPath;
begin
  path := TGPGraphicsPath.Create;
  path.AddLine(X + Radius, Y, X + Width - (Radius * 2), Y);
  path.AddArc(X + Width - (Radius * 2), Y, Radius * 2, Radius * 2, 270, 90);
  path.AddLine(X + Width, Y + Radius, X + Width, Y + Height - (Radius * 2));
  path.AddArc(X + Width - (Radius * 2), Y + Height - (Radius * 2), Radius * 2,
    Radius * 2, 0, 90);
  path.AddLine(X + Width - (Radius * 2), Y + Height, X + Radius, Y + Height);
  path.AddArc(X, Y + Height - (Radius * 2), Radius * 2, Radius * 2, 90, 90);
  path.AddLine(X, Y + Height - (Radius * 2), X, Y + Radius);
  path.AddArc(X, Y, Radius * 2, Radius * 2, 180, 90);
  path.CloseFigure;
  Graphics.DrawPath(Pen, path);
  path.Free;
end;

// ------------------------------------------------------------------------------

procedure DrawRect(Graphics: TGPGraphics; Pen: TGPPen; X, Y, Width,
  Height: Integer);

var
  path: TGPGraphicsPath;
begin
  path := TGPGraphicsPath.Create;
  path.AddLine(X, Y, X + Width, Y);
  path.AddLine(X + Width, Y, X + Width, Y + Height);
  path.AddLine(X + Width, Y + Height, X, Y + Height);
  path.AddLine(X, Y + Height, X, Y);
  path.CloseFigure;
  Graphics.DrawPath(Pen, path);
  path.Free;
end;

// ------------------------------------------------------------------------------

function TrimText(Text: String; r: TRect; GDIPDraw: Boolean;
  Graphics: TGPGraphics; Canvas: TCanvas; Font: TGPFont;
  stringFormat: TGPStringFormat; Ellipsis: Boolean; Direction: TTabPosition;
  WordWrap: Boolean): string;

var
  rectf: TGPRectF;
  w, h: Integer;
  x1, y1, y2: single;
  sizerect: TGPRectF;
  s, s2: string;
  i, j: Integer;
  r2: TRect;
begin
  if WordWrap then
  begin
    Result := Text;
    Exit;
  end;

  // R.Right := R.Right - 2;
  w := r.Right - r.Left;
  h := r.Bottom - r.Top;
  x1 := r.Left;
  y1 := r.Top;
  y2 := h;

  if Direction in [tpLeft, tpRight] then
  begin
    // h := R.Right - R.Left;
    w := r.Bottom - r.Top;
  end;

  if Ellipsis then
    s := '...'
  else
    s := '';

  if GDIPDraw then
  begin
    stringFormat := TGPStringFormat.Create;
    w := w - 2;
    rectf := MakeRect(x1, y1, 1000, y2);
    Graphics.MeasureString(Text, Length(Text), Font, rectf, stringFormat,
      sizerect);

    // -- Add ellipsis
    if (sizerect.Width >= w) then
    begin
      rectf := MakeRect(x1, y1, 1000, y2);
      j := Length(Text);
      for i := 0 to j do
      begin
        s2 := Text + s;
        Graphics.MeasureString(s2, Length(s2), Font, rectf, stringFormat,
          sizerect);
        if (sizerect.Width >= w) and (Text <> '') then
        begin
          Text := Copy(Text, 1, Length(Text) - 1);
        end
        else
        begin
          Break;
        end;
      end;
      Text := Text + s;
    end;
    stringFormat.Free;
  end
  else
  begin
    r2 := Rect(0, 0, 1000, 100);
    DrawText(Canvas.Handle, PChar(Text), Length(Text), r2,
      DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
    if (r2.Right >= w) then
    begin
      j := Length(Text);
      for i := 0 to j do
      begin
        s2 := Text + s;
        DrawText(Canvas.Handle, PChar(s2), Length(s2), r2,
          DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
        if (r2.Right >= w) and (Text <> '') then
        begin
          Text := Copy(Text, 1, Length(Text) - 1);
        end
        else
        begin
          Break;
        end;
      end;
      Text := Text + s;
    end;
  end;

  Result := Text;
end;

function TrimTextW(Text: widestring; r: TRect; GDIPDraw: Boolean;
  Graphics: TGPGraphics; Canvas: TCanvas; Font: TGPFont;
  stringFormat: TGPStringFormat; Ellipsis: Boolean; Direction: TTabPosition;
  WordWrap: Boolean): widestring;

var
  rectf: TGPRectF;
  w, h: Integer;
  x1, y1, y2: single;
  sizerect: TGPRectF;
  s, s2: widestring;
  i, j: Integer;
  r2: TRect;
begin
  if WordWrap then
  begin
    Result := Text;
    Exit;
  end;

  // R.Right := R.Right - 2;
  w := r.Right - r.Left;
  h := r.Bottom - r.Top;
  x1 := r.Left;
  y1 := r.Top;
  y2 := h;

  if Direction in [tpLeft, tpRight] then
  begin
    // h := R.Right - R.Left;
    w := r.Bottom - r.Top;
  end;

  if Ellipsis then
    s := '...'
  else
    s := '';

  if GDIPDraw then
  begin
    stringFormat := TGPStringFormat.Create;
    w := w - 2;
    rectf := MakeRect(x1, y1, 1000, y2);
    Graphics.MeasureString(Text, Length(Text), Font, rectf, stringFormat,
      sizerect);
    // -- Add ellipsis
    if (sizerect.Width >= w) then
    begin
      rectf := MakeRect(x1, y1, 1000, y2);
      j := Length(Text);
      for i := 0 to j do
      begin
        s2 := Text + s;
        Graphics.MeasureString(s2, Length(s2), Font, rectf, stringFormat,
          sizerect);
        if (sizerect.Width >= w) and (Text <> '') then
        begin
          Text := Copy(Text, 1, Length(Text) - 1);
        end
        else
        begin
          Break;
        end;
      end;
      Text := Text + s;
    end;
    stringFormat.Free;
  end
  else
  begin
    r2 := Rect(0, 0, 1000, 100);
    DrawTextW(Canvas.Handle, PWideChar(Text), -1, r2,
      DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
    if (r2.Right >= w) then
    begin
      j := Length(Text);
      for i := 0 to j do
      begin
        s2 := Text + s;
        DrawTextW(Canvas.Handle, PWideChar(s2), -1, r2,
          DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
        if (r2.Right >= w) and (Text <> '') then
        begin
          Text := Copy(Text, 1, Length(Text) - 1);
        end
        else
        begin
          Break;
        end;
      end;
      Text := Text + s;
    end;
  end;

  Result := Text;
end;

// ------------------------------------------------------------------------------

function WideDCTextExtent(hDC: THandle; const Text: widestring): TSize;
begin
  Result.cx := 0;
  Result.cy := 0;
  Windows.GetTextExtentPoint32W(hDC, PWideChar(Text), Length(Text), Result);
end;

function WideCanvasTextExtent(Canvas: TCanvas; const Text: widestring): TSize;
begin
  with TAccessCanvas(Canvas) do
  begin
    RequiredState([csHandleValid, csFontValid]);
    Result := WideDCTextExtent(Handle, Text);
  end;
end;

function WideCanvasTextWidth(Canvas: TCanvas; const Text: widestring): Integer;
begin
  Result := WideCanvasTextExtent(Canvas, Text).cx;
end;

function WideCanvasTextHeight(Canvas: TCanvas; const Text: widestring): Integer;
begin
  Result := WideCanvasTextExtent(Canvas, Text).cy;
end;

// ------------------------------------------------------------------------------

function DrawVistaText(Canvas: TCanvas; Alignment: TAlignment; r: TRect;
  Caption: string; WideCaption: widestring; AFont: TFont; Enabled: Boolean;
  RealDraw: Boolean; AntiAlias: TAntiAlias; Direction: TTabPosition;
  Ellipsis, WordWrap: Boolean): TRect;

var
  Graphics: TGPGraphics;
  w, h: Integer;
  fontFamily: TGPFontFamily;
  Font: TGPFont;
  rectf: TGPRectF;
  stringFormat: TGPStringFormat;
  solidBrush: TGPSolidBrush;
  x1, y1, x2, y2: single;
  fs: Integer;
  sizerect: TGPRectF;
  szRect: TRect;
  DTFLAG: dword;
begin
  stringFormat := nil;
  Graphics := nil;
  fontFamily := nil;
  Font := nil;
  solidBrush := nil;

  if (Caption <> '') or (WideCaption <> '') then
  begin
    try
      w := r.Right - r.Left;
      h := r.Bottom - r.Top;

      x1 := r.Left;
      y1 := r.Top;
      x2 := w;
      y2 := h;

      rectf := MakeRect(x1, y1, x2, y2);

      try
        if AntiAlias <> aaNone then
        begin
          Graphics := TGPGraphics.Create(Canvas.Handle);
          fontFamily := TGPFontFamily.Create(AFont.Name);

          if (fontFamily.Status in [FontFamilyNotFound, FontStyleNotFound]) then
          begin
            fontFamily.Free;
            fontFamily := TGPFontFamily.Create('Arial');
          end;

          fs := 0;

          if (fsBold in AFont.Style) then
            fs := fs + 1;

          if (fsItalic in AFont.Style) then
            fs := fs + 2;

          if (fsUnderline in AFont.Style) then
            fs := fs + 4;

          Font := TGPFont.Create(fontFamily, AFont.Size, fs, UnitPoint);

          Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

          if RealDraw then
          begin
            case Direction of
              tpTop, tpBottom:
                stringFormat := TGPStringFormat.Create;
              tpLeft:
                stringFormat := TGPStringFormat.Create;
              tpRight:
                stringFormat := TGPStringFormat.Create($00000002);
            end;
          end
          else
            stringFormat := TGPStringFormat.Create;

          if Enabled then
            solidBrush := TGPSolidBrush.Create(ColorToARGB(AFont.Color))
          else
            solidBrush := TGPSolidBrush.Create(ColorToARGB(clGray));

          case Alignment of
            taLeftJustify:
              stringFormat.SetAlignment(StringAlignmentNear);
            taCenter:
              stringFormat.SetAlignment(StringAlignmentCenter);
            taRightJustify:
              stringFormat.SetAlignment(StringAlignmentFar);
          end;

          // Center the block of text (top to bottom) in the rectangle.
          stringFormat.SetLineAlignment(StringAlignmentCenter);
          stringFormat.SetHotkeyPrefix(HotkeyPrefixShow);

          case AntiAlias of
            aaClearType:
              Graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
            aaAntiAlias:
              Graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
          end;
        end;

        if AntiAlias = aaNone then
        begin
          szRect.Left := Round(rectf.X);
          szRect.Top := Round(rectf.Y);

          szRect.Right := szRect.Left + $FFFF;
          DTFLAG := DT_CALCRECT or DT_LEFT;
          if Ellipsis then
            DTFLAG := DTFLAG or DT_END_ELLIPSIS
          else
            DTFLAG := DTFLAG or DT_WORDBREAK;

          if RealDraw and Ellipsis then
          begin
            if (Caption <> '') then
              Caption := TrimText(Caption, r, False, nil, Canvas, Font, nil,
                True, Direction, WordWrap)
            else if (WideCaption <> '') then
              WideCaption := TrimTextW(WideCaption, r, False, nil, Canvas,
                Font, nil, True, Direction, WordWrap);
          end;

          if (Caption <> '') then
            szRect.Bottom := DrawText(Canvas.Handle, PChar(Caption), Length
                (Caption), szRect, DTFLAG)
          else
            szRect.Bottom := DrawTextW(Canvas.Handle, PWideChar(WideCaption),
              -1, szRect, DTFLAG);

          sizerect.X := szRect.Left;
          sizerect.Y := szRect.Top;
          sizerect.Width := szRect.Right - szRect.Left;
          sizerect.Height := szRect.Bottom - szRect.Top;
        end
        else
        begin
          if RealDraw and Ellipsis then
          begin
            // stringFormat.SetTrimming(StringTrimmingEllipsisCharacter);
            if (Caption <> '') then
              Caption := TrimText(Caption, r, True, Graphics, nil, Font,
                stringFormat, True, Direction, WordWrap)
            else if (WideCaption <> '') then
              WideCaption := TrimTextW(WideCaption, r, True, Graphics, nil,
                Font, stringFormat, True, Direction, WordWrap);
          end;

          if (Caption <> '') then
            Graphics.MeasureString(Caption, Length(Caption), Font, rectf,
              stringFormat, sizerect)
          else
            Graphics.MeasureString(WideCaption, Length(WideCaption), Font,
              rectf, stringFormat, sizerect);

        end;

        Result := Rect(Round(sizerect.X), Round(sizerect.Y), Round
            (sizerect.X + sizerect.Width), Round(sizerect.Y + sizerect.Height));
        rectf := MakeRect(x1, y1, x2, y2);

        if RealDraw then
        begin
          // graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);
          if AntiAlias = aaNone then
          begin
            szRect.Left := Round(rectf.X) + 3;
            szRect.Top := Round(rectf.Y);
            szRect.Right := szRect.Left + Round(rectf.Width);
            szRect.Bottom := szRect.Top + Round(rectf.Height);
            Canvas.Brush.Style := bsClear;

            DTFLAG := DT_LEFT;
            case Alignment of
              taRightJustify:
                DTFLAG := DT_RIGHT;
              taCenter:
                DTFLAG := DT_CENTER;
            end;

            { if Ellipsis then
              begin
              Caption := TrimText(Caption, r, False, nil, Canvas, font, stringformat, True);
              end; }
            if (Caption <> '') then
              DrawText(Canvas.Handle, PChar(Caption), Length(Caption), szRect,
                DTFLAG or DT_VCENTER or DT_SINGLELINE)
            else
              DrawTextW(Canvas.Handle, PWideChar(WideCaption), -1, szRect,
                DTFLAG or DT_VCENTER or DT_SINGLELINE);
          end
          else
          begin
            { if Ellipsis then
              begin
              //stringFormat.SetTrimming(StringTrimmingEllipsisCharacter);
              Caption := TrimText(Caption, r, True, graphics, nil, font, stringformat, True);
              end; }

            if (Caption <> '') then
              Graphics.DrawString(Caption, Length(Caption), Font, rectf,
                stringFormat, solidBrush)
            else
              Graphics.DrawString(WideCaption, Length(WideCaption), Font,
                rectf, stringFormat, solidBrush);
          end;
        end;
      except

      end;

    finally

      if (AntiAlias <> aaNone) then
      begin
        if Assigned(stringFormat) then
          FreeAndNil(stringFormat);

        if Assigned(solidBrush) then
          FreeAndNil(solidBrush);

        if Assigned(Font) then
          FreeAndNil(Font);

        if Assigned(fontFamily) then
          FreeAndNil(fontFamily);

        if Assigned(Graphics) then
          FreeAndNil(Graphics);
      end;

    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure DrawVistaGradient(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB,
  PC: TColor; GradientU, GradientB: TGDIPGradient; Caption: string;
  AFont: TFont; Images: TImageList; ImageIndex: Integer; EnabledImage: Boolean;
  Layout: TButtonLayout; DropDownButton: Boolean; DrawDwLine: Boolean;
  Enabled: Boolean; Focus: Boolean; DropDownPos: TDropDownPosition;
  Picture: TPicture; AntiAlias: TAntiAlias; RoundEdges: Boolean;
  RotateLeftRight: Boolean; Direction: TTabPosition); overload;

var
  Graphics: TGPGraphics;
  path: TGPGraphicsPath;
  pthGrBrush: TGPPathGradientBrush;
  solGrBrush: TGPSolidBrush;
  linGrBrush: TGPLinearGradientBrush;
  gppen: TGPPen;
  Count: Integer;
  w, h, h2, w2: Integer;
  colors: array [0 .. 0] of TGPColor;
  fontFamily: TGPFontFamily;
  Font: TGPFont;
  rectf: TGPRectF;
  stringFormat: TGPStringFormat;
  solidBrush: TGPSolidBrush;
  x1, y1, x2, y2: single;
  fs: Integer;
  sizerect: TGPRectF;
  ImgX, ImgY, ImgW, ImgH: Integer;
  BtnR, DwR: TRect;
  AP: TPoint;
  szRect: TRect;

  procedure DrawArrow(ArP: TPoint; ArClr: TColor);
  begin
    Canvas.Pen.Color := ArClr;
    Canvas.MoveTo(ArP.X, ArP.Y);
    Canvas.LineTo(ArP.X + 5, ArP.Y);
    Canvas.MoveTo(ArP.X + 1, ArP.Y + 1);
    Canvas.LineTo(ArP.X + 4, ArP.Y + 1);
    Canvas.Pixels[ArP.X + 2, ArP.Y + 2] := ArClr;
  end;

begin
  BtnR := r;
  if DropDownPos = dpRight then
  begin
    DwR := Rect(BtnR.Right - DropDownSectWidth, BtnR.Top, BtnR.Right,
      BtnR.Bottom);
    if DropDownButton then
      BtnR.Right := DwR.Left;
  end
  else // DropDownPos = doBottom
  begin
    DwR := Rect(BtnR.Left, BtnR.Bottom - DropDownSectWidth, BtnR.Right,
      BtnR.Bottom);
    if DropDownButton then
      BtnR.Bottom := DwR.Top;
  end;

  w := r.Right - r.Left;
  h := r.Bottom - r.Top;

  h2 := h div 2;
  w2 := w div 2;

  Graphics := TGPGraphics.Create(Canvas.Handle);

  case (Direction) of
    tpTop:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top + h2, w, h2));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfb;
        // Canvas.FillRect(rect(r.Left , r.top +  h2, r.Right , r.Bottom ));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        // path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
        path.AddEllipse(r.Left, r.Top + h2, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + h2, w - 1,
            h2 + 1);
          pthGrBrush.Free;
        end
        else
        begin
          if not RotateLeftRight then
            Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2 + 1,
              w - 1, h2 - 1)
          else
            Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2 + 1,
              w - 1, h2 + 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w, h2));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfu;
        // Canvas.FillRect(rect(r.Left , r.Top , r.Right , r.top +  h2));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left, r.Top - h2, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2 + 1), ColorToARGB(CFU), ColorToARGB
                (CTU), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Top));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + 1, w - 1,
            h - h2 - 1);
          pthGrBrush.Free;
        end
        else
        begin
          if (PC <> clNone) then
            Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w - 1, h2)
          else
            Graphics.FillRectangle(linGrBrush, r.Left, r.Top + 1, w, h2);
          linGrBrush.Free;
        end;

        path.Free;

      end;
    tpBottom:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w, h2));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfb;
        // Canvas.FillRect(rect(r.Left , r.top, r.Right , r.top +  h2));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        // path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
        path.AddEllipse(r.Left, r.Top, w, h2);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Top));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top, w - 1, h2 + 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w - 1,
            h2 + 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top + h2, w, h2));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfu;
        // Canvas.FillRect(rect(r.Left , r.top +  h2, r.Right , r.Bottom));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left, r.Bottom - h2, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2 - 1, w, h2), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h), ColorToARGB(CTU), ColorToARGB
                (CFU), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h), ColorToARGB(CTU), ColorToARGB
                (CFU), LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + h2 + 1, w - 1,
            h2 - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2, w - 1,
            h2 - 1);
          linGrBrush.Free;
        end;

        path.Free;
      end;
    tpLeft:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left + w2, r.Top, w2, h));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfb;
        // Canvas.FillRect(rect(r.Left + w2, r.top, r.Right , r.Bottom));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        // path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
        path.AddEllipse(r.Left + w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + w2, r.Top, w2 + 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + w2 + 1, r.Top, w2 + 1,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w2, h));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfu;
        // Canvas.FillRect(rect(r.Left , r.Top , r.Left + w2 , r.Bottom));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left - w2, r.Top, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CFU), ColorToARGB
                (CTU), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + 1, w2 - 1,
            h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w2 - 1,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

      end;
    tpRight:
      begin

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Right - w2, r.Top, w2, h)
          );
        solGrBrush.Free;

        // Canvas.Brush.Color := cfu;
        // Canvas.FillRect(rect(r.Right - w2 , r.Top , r.Right ,r.Bottom));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Right - w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w2, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Right - w2 + 1, r.Top + 1,
            w2 - 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Right - w2, r.Top + 1, w2,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w2, h));
        solGrBrush.Free;

        // Canvas.Brush.Color := cfb;
        // Canvas.FillRect(rect(r.Left , r.top, r.Left + w2, r.Bottom ));

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        // path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
        path.AddEllipse(r.Left - w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2 + 2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left, r.Top, w2 + 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left, r.Top, w2 + 2, h - 1);
          linGrBrush.Free;
        end;

        path.Free;

      end;
  end;

  gppen := TGPPen.Create(ColorToARGB(PC), 1);

  Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  if (PC <> clNone) then
  begin
    if not RoundEdges then
      DrawRect(Graphics, gppen, r.Left, r.Top, w - 1, h - 1)
    else
      DrawRoundRect(Graphics, gppen, r.Left, r.Top, w - 1, h - 1, 3);
  end;

  gppen.Free;

  if Focus then
  begin
    gppen := TGPPen.Create(ColorToARGB($E4AD89), 1);
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(Graphics, gppen, r.Left + 1, r.Top + 1, r.Right - 3,
      r.Bottom - 3, 3);
    gppen.Free;
    gppen := TGPPen.Create(ColorToARGB(clGray), 1);
    gppen.SetDashStyle(DashStyleDot);
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(Graphics, gppen, r.Left + 2, r.Top + 2, r.Right - 5,
      r.Bottom - 5, 3);
    gppen.Free;
  end;

  fontFamily := TGPFontFamily.Create(AFont.Name);

  fs := 0;

  ImgH := 0;
  ImgW := 0;

  if (fsBold in AFont.Style) then
    fs := fs + 1;
  if (fsItalic in AFont.Style) then
    fs := fs + 2;
  if (fsUnderline in AFont.Style) then
    fs := fs + 4;

  if Assigned(Picture) and not Picture.Bitmap.Empty then
  begin
    ImgW := Picture.Width;
    ImgH := Picture.Height;
  end
  else
  begin
    if (ImageIndex > -1) and Assigned(Images) then
    begin
      ImgW := Images.Width;
      ImgH := Images.Height;
    end;
  end;

  if (Caption <> '') then
  begin
    Font := TGPFont.Create(fontFamily, AFont.Size, fs, UnitPoint);

    w := BtnR.Right - BtnR.Left;
    h := BtnR.Bottom - BtnR.Top;

    x1 := r.Left;
    y1 := r.Top;
    x2 := w;
    y2 := h;

    rectf := MakeRect(x1, y1, x2, y2);

    stringFormat := TGPStringFormat.Create;

    if Enabled then
      solidBrush := TGPSolidBrush.Create(ColorToARGB(AFont.Color))
    else
      solidBrush := TGPSolidBrush.Create(ColorToARGB(clGray));

    // Center-justify each line of text.
    stringFormat.SetAlignment(StringAlignmentCenter);

    // Center the block of text (top to bottom) in the rectangle.
    stringFormat.SetLineAlignment(StringAlignmentCenter);

    stringFormat.SetHotkeyPrefix(HotkeyPrefixShow);

    case AntiAlias of
      aaClearType:
        Graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
      aaAntiAlias:
        Graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    end;

    // graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect);
    if AntiAlias = aaNone then
    begin
      szRect.Left := Round(rectf.X);
      szRect.Top := Round(rectf.Y);

      szRect.Right := szRect.Left + 2;
      szRect.Bottom := DrawText(Canvas.Handle, PChar(Caption), Length(Caption),
        szRect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK);

      sizerect.X := szRect.Left;
      sizerect.Y := szRect.Top;
      sizerect.Width := szRect.Right - szRect.Left;
      sizerect.Height := szRect.Bottom - szRect.Top;
    end
    else
      Graphics.MeasureString(Caption, Length(Caption), Font, rectf,
        stringFormat, sizerect);

    if (ImgW > 0) then
    begin
      case Layout of
        blGlyphLeft:
          begin
            x1 := r.Left + 2 + ImgW;
            x2 := w - 2 - ImgW;

            ImgX := Round(sizerect.X - ImgW div 2);
            if ImgX < 2 then
              ImgX := 2;
            ImgY := r.Top + Max(0, (h - ImgH) div 2);
          end;
        blGlyphTop:
          begin
            y1 := r.Top { + 2 } + ImgH;
            y2 := h - 2 - ImgH;

            ImgX := r.Left + Max(0, (w - ImgW) div 2);
            ImgY := Round(y2 - sizerect.Height);
            ImgY := Max(0, ImgY div 2);
            ImgY := Round(y1) - ImgH + ImgY;
            // round(sizerect.Height) - ImgY - 4;
            if ImgY < 2 then
              ImgY := 2;
          end;
        blGlyphRight:
          begin
            x1 := 2;
            x2 := w - 4 - ImgW;

            ImgX := Round(x2 - sizerect.Width);
            ImgX := Max(0, ImgX div 2);
            ImgX := ImgX + Round(sizerect.Width) + 4;
            if ImgX > (w - ImgW) then
              ImgX := w - ImgW - 2;
            ImgY := r.Top + Max(0, (h - ImgH) div 2);
          end;
        blGlyphBottom:
          begin
            y1 := 2;
            y2 := h - 2 - ImgH;

            ImgX := r.Left + Max(0, (w - ImgW) div 2);
            ImgY := Round(y2 - sizerect.Height);
            ImgY := Max(0, ImgY div 2);
            ImgY := Round(sizerect.Height + 2) + ImgY;
            if ImgY > (h - ImgH) then
              ImgY := h - ImgH - 2;
          end;
      end;
    end;

    rectf := MakeRect(x1, y1, x2, y2);

    // graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);
    if AntiAlias = aaNone then
    begin
      szRect.Left := Round(rectf.X);
      szRect.Top := Round(rectf.Y);
      szRect.Right := szRect.Left + Round(rectf.Width);
      szRect.Bottom := szRect.Top + Round(rectf.Height);
      Canvas.Brush.Style := bsClear;
      DrawText(Canvas.Handle, PChar(Caption), Length(Caption), szRect,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE)
    end
    else
      Graphics.DrawString(Caption, Length(Caption), Font, rectf, stringFormat,
        solidBrush);

    stringFormat.Free;
    Font.Free;
  end;

  fontFamily.Free;

  if DropDownButton then
  begin

    if DropDownPos = dpRight then
      w := w - 8
    else
      h := h - 8;
  end;

  if Assigned(Picture) and not Picture.Bitmap.Empty then
  begin
    if Caption = '' then
      Canvas.Draw(r.Left + Max(0, (w - ImgW) div 2), r.Top + Max
          (0, (h - ImgH) div 2), Picture.Bitmap)
    else
      Canvas.Draw(ImgX, ImgY, Picture.Bitmap);
  end
  else if (ImageIndex <> -1) and Assigned(Images) then
  begin
    if Caption = '' then
      Images.Draw(Canvas, r.Left + Max(0, (w - Images.Width) div 2), r.Top + Max
          (0, (h - Images.Height) div 2), ImageIndex, EnabledImage)
    else
    begin
      Images.Draw(Canvas, ImgX, ImgY, ImageIndex, EnabledImage);
    end;
  end;

  Canvas.Brush.Style := bsClear;
  if DropDownButton then
  begin
    if DrawDwLine then
    begin
      Canvas.Pen.Color := PC;
      // Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 6, 6);
      if (DropDownPos = dpRight) then
      begin
        Canvas.MoveTo(DwR.Left, DwR.Top);
        Canvas.LineTo(DwR.Left, DwR.Bottom);
      end
      else
      begin
        Canvas.MoveTo(DwR.Left, DwR.Top);
        Canvas.LineTo(DwR.Right, DwR.Top);
      end;
    end;
    AP.X := DwR.Left + ((DwR.Right - DwR.Left - 5) div 2);
    AP.Y := DwR.Top + ((DwR.Bottom - DwR.Top - 3) div 2) + 1;
    if not Enabled then
      DrawArrow(AP, clGray)
    else
      DrawArrow(AP, clBlack);
  end;

  Graphics.Free;
end;

procedure DrawVistaGradient(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB,
  PC: TColor; GradientU, GradientB: TGDIPGradient; Caption: string;
  AFont: TFont; Layout: TButtonLayout; Enabled: Boolean; Focus: Boolean;
  AntiAlias: TAntiAlias; RoundEdges: Boolean; RotateLeftRight: Boolean;
  Direction: TTabPosition = tpTop); overload;
begin
  DrawVistaGradient(Canvas, r, CFU, CTU, CFB, CTB, PC, GradientU, GradientB,
    Caption, AFont, nil, -1, True, Layout, False, False, Enabled, Focus,
    dpRight, nil, AntiAlias, RoundEdges, RotateLeftRight, Direction);
end;

// ------------------------------------------------------------------------------

function GetTabPath(r: TRect; Shape: TTabShape; Rounding: TTabRounding;
  RotateLeftRight: Boolean; Direction: TTabPosition): TGPGraphicsPath;

var
  p, P2: array [0 .. 2] of TGPPoint;
  P5, p6: array [0 .. 3] of TGPPoint;
  tension: double;
  w, h, i, j, h3, w3, rd2: Integer;
begin
  w := r.Right - r.Left;
  h := r.Bottom - r.Top;
  // h2 := h div 2;
  h3 := h div 3;
  w3 := w div 3;
  tension := 0.8;
  i := 3;

  Result := TGPGraphicsPath.Create;
  case Shape of
    tsRectangle:
      begin
        case (Direction) of
          tpTop:
            begin
              p[0] := MakePoint(r.Left, r.Top + Rounding * i);
              p[1] := MakePoint(r.Left + Rounding, r.Top + Rounding);
              p[2] := MakePoint(r.Left + Rounding * i, r.Top);
              Result.AddLine(r.Left, r.Bottom, r.Left, p[0].Y);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P2[0] := MakePoint(r.Right - (Rounding * i), r.Top);
              P2[1] := MakePoint(r.Right - Rounding, r.Top + Rounding);
              P2[2] := MakePoint(r.Right, r.Top + (Rounding * i));
              Result.AddLine(p[2].X, r.Top, P2[0].X, r.Top);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              Result.AddLine(r.Right, P2[2].Y, r.Right, r.Bottom);
              Result.CloseFigure;
            end;
          tpBottom:
            begin
              p[0] := MakePoint(r.Left, r.Bottom - Rounding * i);
              p[1] := MakePoint(r.Left + Rounding, r.Bottom - Rounding);
              p[2] := MakePoint(r.Left + Rounding * i, r.Bottom);
              Result.AddLine(r.Left, r.Top, r.Left, p[0].Y);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P2[0] := MakePoint(r.Right - (Rounding * i), r.Bottom);
              P2[1] := MakePoint(r.Right - Rounding, r.Bottom - Rounding);
              P2[2] := MakePoint(r.Right, r.Bottom - (Rounding * i));
              Result.AddLine(p[2].X, r.Bottom, P2[0].X, r.Bottom);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              Result.AddLine(r.Right, P2[2].Y, r.Right, r.Top);
              Result.CloseFigure;
            end;
          tpLeft:
            begin
              p[0] := MakePoint(r.Left + Rounding * i, r.Top);
              p[1] := MakePoint(r.Left + Rounding, r.Top + Rounding);
              p[2] := MakePoint(r.Left, r.Top + Rounding * i);
              Result.AddLine(r.Right, r.Top, p[0].X, r.Top);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P2[0] := MakePoint(r.Left, r.Bottom - (Rounding * i));
              P2[1] := MakePoint(r.Left + Rounding, r.Bottom - Rounding);
              P2[2] := MakePoint(r.Left + (Rounding * i), r.Bottom);
              Result.AddLine(r.Left, p[2].Y, r.Left, P2[0].Y);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              Result.AddLine(P2[2].X, r.Bottom, r.Right, r.Bottom);
              Result.CloseFigure;
            end;
          tpRight:
            begin
              p[0] := MakePoint(r.Right - Rounding * i, r.Top);
              p[1] := MakePoint(r.Right - Rounding, r.Top + Rounding);
              p[2] := MakePoint(r.Right, r.Top + Rounding * i);
              Result.AddLine(r.Left, r.Top, p[0].X, r.Top);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P2[0] := MakePoint(r.Right, r.Bottom - (Rounding * i));
              P2[1] := MakePoint(r.Right - Rounding, r.Bottom - Rounding);
              P2[2] := MakePoint(r.Right - (Rounding * i), r.Bottom);
              Result.AddLine(r.Right, p[2].Y, r.Right, P2[0].Y);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              Result.AddLine(P2[2].X, r.Bottom, r.Left, r.Bottom);
              Result.CloseFigure;
            end;
        end;
      end;
    tsLeftRamp:
      begin
        case (Direction) of
          tpTop:
            begin
              j := h3 + Rounding;

              P5[0] := MakePoint(r.Left, r.Bottom);
              P5[1] := MakePoint(r.Left + Rounding * i, r.Bottom - Rounding
                { * 2 } );
              P5[2] := MakePoint(r.Left - Rounding + j, r.Top + Rounding);
              P5[3] := MakePoint(r.Left + (Rounding * 2) + j, r.Top);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              rd2 := Max(0, Rounding div 2);

              P2[0] := MakePoint(r.Right - (rd2 * i), r.Top);
              P2[1] := MakePoint(r.Right - rd2, r.Top + rd2);
              P2[2] := MakePoint(r.Right, r.Top + (rd2 * i));
              Result.AddLine(P5[3].X, r.Top, P2[0].X, r.Top);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              Result.AddLine(r.Right, P2[2].Y, r.Right, r.Bottom);

              // Result.AddLine(R.Right, R.Bottom, R.Left, R.Bottom);
              Result.CloseFigure;
            end;
          tpBottom:
            begin
              j := h3 + Rounding;

              P5[0] := MakePoint(r.Left + (Rounding * 2) + j, r.Bottom);
              P5[1] := MakePoint(r.Left - Rounding + j, r.Bottom - Rounding);
              P5[2] := MakePoint(r.Left + Rounding * i, r.Top + Rounding
                { * 2 } );
              P5[3] := MakePoint(r.Left, r.Top);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              rd2 := Max(0, Rounding div 2);

              P2[0] := MakePoint(r.Right, r.Bottom - (rd2 * i));
              P2[1] := MakePoint(r.Right - rd2, r.Bottom - rd2);
              P2[2] := MakePoint(r.Right - (rd2 * i), r.Bottom);

              Result.AddLine(r.Left, r.Top, r.Right, r.Top);
              Result.AddLine(r.Right, r.Top, r.Right, P2[0].Y);
              Result.AddCurve(PGPPoint(@P2), 3, tension);
              // Result.AddLine(P2[2].X, R.Bottom, P5[0].x, R.Bottom);
              Result.CloseFigure;
            end;
          tpLeft:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;
              rd2 := Max(0, Rounding div 2);

              p[0] := MakePoint(r.Left + rd2 * i, r.Top);
              p[1] := MakePoint(r.Left + rd2, r.Top + rd2);
              p[2] := MakePoint(r.Left, r.Top + rd2 * i);
              Result.AddLine(r.Right, r.Top, p[0].X, r.Top);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P5[0] := MakePoint(r.Left, r.Bottom - (Rounding * 2) - j);
              P5[1] := MakePoint(r.Left + Rounding, r.Bottom + Rounding - j);
              P5[2] := MakePoint(r.Right - Rounding
                { * 2 } , r.Bottom - Rounding * i);
              P5[3] := MakePoint(r.Right, r.Bottom);
              Result.AddLine(r.Left, p[2].Y, r.Left, P5[0].Y);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);
              // Result.AddLine(R.Right, R.Bottom, R.Right, R.Top);
              Result.CloseFigure;
            end;
          tpRight:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;

              P5[0] := MakePoint(r.Left, r.Top);
              P5[1] := MakePoint(r.Left + Rounding
                { * 2 } , r.Top + Rounding * i);
              P5[2] := MakePoint(r.Right - Rounding, r.Top - Rounding + j);
              P5[3] := MakePoint(r.Right, r.Top + (Rounding * 2) + j);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              rd2 := Max(0, Rounding div 2);
              P2[0] := MakePoint(r.Right, r.Bottom - (rd2 * i));
              P2[1] := MakePoint(r.Right - rd2, r.Bottom - rd2);
              P2[2] := MakePoint(r.Right - (rd2 * i), r.Bottom);

              Result.AddLine(r.Right, P5[3].Y, r.Right, P2[0].Y);
              Result.AddCurve(PGPPoint(@P2), 3, tension);

              Result.AddLine(P2[2].X, r.Bottom, r.Left, r.Bottom);
              // Result.AddLine(R.Right, R.Bottom, R.Right, Top);
              Result.CloseFigure;
            end;
        end;
      end;
    tsRightRamp:
      begin
        case (Direction) of
          tpTop:
            begin
              // k := 0;
              // if (Rounding * i > h2) then
              // k := i div 2;

              j := h3 + Rounding;
              // k := (j div 2);

              rd2 := Max(0, Rounding div 2);

              p[0] := MakePoint(r.Left, r.Top + rd2 * i);
              p[1] := MakePoint(r.Left + rd2, r.Top + rd2);
              p[2] := MakePoint(r.Left + rd2 * i, r.Top);

              Result.AddLine(r.Left, r.Bottom, r.Left, p[0].Y);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P5[0] := MakePoint(r.Right - (Rounding * 2) - j, r.Top);
              P5[1] := MakePoint(r.Right + Rounding - j, r.Top + Rounding);
              P5[2] := MakePoint(r.Right - Rounding * i, r.Bottom - Rounding
                { * 2 } );
              P5[3] := MakePoint(r.Right, r.Bottom);
              Result.AddLine(p[2].X, r.Top, P5[0].X, r.Top);
              // Result.AddCurve(PGPPoint(@p5), 4, tension);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              Result.AddLine(r.Left, r.Bottom, r.Right, r.Bottom);
              Result.CloseFigure;
            end;
          tpBottom:
            begin
              j := h3 + Rounding;
              rd2 := Max(0, Rounding div 2);

              p[0] := MakePoint(r.Left, r.Bottom - rd2 * i);
              p[1] := MakePoint(r.Left + rd2, r.Bottom - rd2);
              p[2] := MakePoint(r.Left + rd2 * i, r.Bottom);
              Result.AddLine(r.Left, r.Top, r.Left, p[0].Y);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P5[0] := MakePoint(r.Right - (Rounding * 2) - j, r.Bottom);
              P5[1] := MakePoint(r.Right + Rounding - j, r.Bottom - Rounding);
              P5[2] := MakePoint(r.Right - Rounding * i, r.Top + Rounding
                { * 2 } );
              P5[3] := MakePoint(r.Right, r.Top);
              Result.AddLine(p[2].X, r.Bottom, P5[0].X, r.Bottom);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              Result.AddLine(r.Left, r.Top, r.Right, r.Top);
              Result.CloseFigure;
            end;
          tpLeft:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;
              rd2 := Max(0, Rounding div 2);

              P5[0] := MakePoint(r.Right, r.Top);
              P5[1] := MakePoint(r.Right - Rounding
                { * 2 } , r.Top + Rounding * i);
              P5[2] := MakePoint(r.Left + Rounding, r.Top - Rounding + j);
              P5[3] := MakePoint(r.Left, r.Top + (Rounding * 2) + j);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              P2[0] := MakePoint(r.Left, r.Bottom - (rd2 * i));
              P2[1] := MakePoint(r.Left + rd2, r.Bottom - rd2);
              P2[2] := MakePoint(r.Left + (rd2 * i), r.Bottom);

              Result.AddLine(r.Left, P5[3].Y, r.Left, P2[0].Y);
              Result.AddCurve(PGPPoint(@P2), 3, tension);

              Result.AddLine(P2[2].X, r.Bottom, r.Right, r.Bottom);
              // Result.AddLine(R.Right, R.Bottom, R.Right, Top);
              Result.CloseFigure;
            end;
          tpRight:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;
              rd2 := Max(0, Rounding div 2);

              p[0] := MakePoint(r.Right - rd2 * i, r.Top);
              p[1] := MakePoint(r.Right - rd2, r.Top + rd2);
              p[2] := MakePoint(r.Right, r.Top + rd2 * i);
              Result.AddLine(r.Left, r.Top, p[0].X, r.Top);
              Result.AddCurve(PGPPoint(@p), 3, tension);

              P5[0] := MakePoint(r.Right, r.Bottom - (Rounding * 2) - j);
              P5[1] := MakePoint(r.Right - Rounding, r.Bottom + Rounding - j);
              P5[2] := MakePoint(r.Left + Rounding
                { * 2 } , r.Bottom - Rounding * i);
              P5[3] := MakePoint(r.Left, r.Bottom);
              Result.AddLine(r.Right, p[2].Y, r.Right, P5[0].Y);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);
              // Result.AddLine(R.Right, R.Bottom, R.Right, R.Top);
              Result.CloseFigure;
            end;
        end;
      end;
    tsLeftRightRamp:
      begin
        case (Direction) of
          tpTop:
            begin
              j := h3 + Rounding;

              P5[0] := MakePoint(r.Left, r.Bottom);
              P5[1] := MakePoint(r.Left + Rounding * i, r.Bottom - Rounding
                { * 2 } );
              P5[2] := MakePoint(r.Left - Rounding + j, r.Top + Rounding);
              P5[3] := MakePoint(r.Left + (Rounding * 2) + j, r.Top);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              p6[0] := MakePoint(r.Right - (Rounding * 2) - j, r.Top);
              p6[1] := MakePoint(r.Right + Rounding - j, r.Top + Rounding);
              p6[2] := MakePoint(r.Right - Rounding * i, r.Bottom - Rounding
                { * 2 } );
              p6[3] := MakePoint(r.Right, r.Bottom);

              Result.AddLine(P5[3].X, r.Top, p6[0].X, r.Top);
              Result.AddBezier(p6[0], p6[1], p6[2], p6[3]);

              // Result.AddLine(R.Right, R.Bottom, R.Left, R.Bottom);
              Result.CloseFigure;
            end;
          tpBottom:
            begin
              j := h3 + Rounding;

              P5[0] := MakePoint(r.Left + (Rounding * 2) + j, r.Bottom);
              P5[1] := MakePoint(r.Left - Rounding + j, r.Bottom - Rounding);
              P5[2] := MakePoint(r.Left + Rounding * i, r.Top + Rounding
                { * 2 } );
              P5[3] := MakePoint(r.Left, r.Top);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              p6[0] := MakePoint(r.Right, r.Top);
              p6[1] := MakePoint(r.Right - Rounding * i, r.Top + Rounding
                { * 2 } );
              p6[2] := MakePoint(r.Right + Rounding - j, r.Bottom - Rounding);
              p6[3] := MakePoint(r.Right - (Rounding * 2) - j, r.Bottom);

              Result.AddLine(r.Left, r.Top, r.Right, r.Top);
              Result.AddBezier(p6[0], p6[1], p6[2], p6[3]);
              Result.AddLine(p6[3].X, r.Bottom, P5[0].X, r.Bottom);

              Result.CloseFigure;
            end;
          tpLeft:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;

              P5[0] := MakePoint(r.Right, r.Top);
              P5[1] := MakePoint(r.Right - Rounding
                { * 2 } , r.Top + Rounding * i);
              P5[2] := MakePoint(r.Left + Rounding, r.Top - Rounding + j);
              P5[3] := MakePoint(r.Left, r.Top + (Rounding * 2) + j);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              p6[0] := MakePoint(r.Left, r.Bottom - (Rounding * 2) - j);
              p6[1] := MakePoint(r.Left + Rounding, r.Bottom + Rounding - j);
              p6[2] := MakePoint(r.Right - Rounding
                { * 2 } , r.Bottom - Rounding * i);
              p6[3] := MakePoint(r.Right, r.Bottom);
              Result.AddLine(r.Left, P5[3].Y, r.Left, p6[0].Y);
              Result.AddBezier(p6[0], p6[1], p6[2], p6[3]);
              // Result.AddLine(R.Right, R.Bottom, R.Right, R.Top);
              Result.CloseFigure;
            end;
          tpRight:
            begin
              j := w3 + Rounding;
              if not RotateLeftRight then
                j := h3 + Rounding;

              P5[0] := MakePoint(r.Left, r.Top);
              P5[1] := MakePoint(r.Left + Rounding
                { * 2 } , r.Top + Rounding * i);
              P5[2] := MakePoint(r.Right - Rounding, r.Top - Rounding + j);
              P5[3] := MakePoint(r.Right, r.Top + (Rounding * 2) + j);
              Result.AddBezier(P5[0], P5[1], P5[2], P5[3]);

              p6[0] := MakePoint(r.Right, r.Bottom - (Rounding * 2) - j);
              p6[1] := MakePoint(r.Right - Rounding, r.Bottom + Rounding - j);
              p6[2] := MakePoint(r.Left + Rounding
                { * 2 } , r.Bottom - Rounding * i);
              p6[3] := MakePoint(r.Left, r.Bottom);
              Result.AddLine(r.Right, P5[3].Y, r.Right, p6[0].Y);
              Result.AddBezier(p6[0], p6[1], p6[2], p6[3]);

              // Result.AddLine(R.Right, R.Bottom, R.Right, R.Top);
              Result.CloseFigure;
            end;
        end;
      end;
  end;
end;

// ------------------------------------------------------------------------------

procedure DrawVistaTab(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB,
  PC: TColor; GradientU, GradientB: TGDIPGradient; Enabled: Boolean;
  Shape: TTabShape; Focus: Boolean;
  { AntiAlias: TAntiAlias; } Rounding: TTabRounding; RotateLeftRight: Boolean;
  Direction: TTabPosition);

var
  Graphics: TGPGraphics;
  TabPath, path: TGPGraphicsPath;
  pthGrBrush: TGPPathGradientBrush;
  solGrBrush: TGPSolidBrush;
  linGrBrush: TGPLinearGradientBrush;
  gppen: TGPPen;
  Count: Integer;
  w, h, h2, w2: Integer;
  colors: array [0 .. 0] of TGPColor;
  BtnR: TRect;
  Rgn: TGPRegion;
begin
  BtnR := r;

  w := r.Right - r.Left;
  h := r.Bottom - r.Top;

  h2 := h div 2;
  w2 := w div 2;

  Graphics := TGPGraphics.Create(Canvas.Handle);
  TabPath := GetTabPath(r, Shape, Rounding, RotateLeftRight, Direction);

  if (Direction in [tpLeft, tpRight]) and not RotateLeftRight then
  begin
    Direction := tpTop;
    RotateLeftRight := False;
  end;

  Rgn := TGPRegion.Create(TabPath);
  Graphics.SetClip(Rgn);

  case (Direction) of
    tpTop:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top + h2, w, h2));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left, r.Top + h2, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h2), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + h2, w - 1,
            h2 + 1);
          pthGrBrush.Free;
        end
        else
        begin
          if not RotateLeftRight then
            Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2 + 1,
              w - 1, h2 - 1)
          else
            Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2 + 1,
              w - 1, h2 + 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w, h2));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left, r.Top - h2, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2 + 1), ColorToARGB(CFU), ColorToARGB
                (CTU), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Top));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + 1, w - 1,
            h - h2 - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w - 1, h2);
          linGrBrush.Free;
        end;

        path.Free;

      end;
    tpBottom:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w, h2));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        // path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
        path.AddEllipse(r.Left, r.Top, w, h2);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h2), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Top));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top, w - 1, h2 + 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w - 1,
            h2 + 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top + h2, w, h2));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left, r.Bottom - h2, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2 - 1, w, h2), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeVertical);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h), ColorToARGB(CTU), ColorToARGB
                (CFU), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top + h2, w, h), ColorToARGB(CTU), ColorToARGB
                (CFU), LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + h2 + 1, w - 1,
            h2 - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + h2, w - 1,
            h2 - 1);
          linGrBrush.Free;
        end;

        path.Free;
      end;
    tpLeft:
      begin
        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left + w2, r.Top, w2, h));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left + w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left + w2, r.Top, w2, h), ColorToARGB(CFB),
              ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left + w2, r.Top, w2 + 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + w2 + 1, r.Top, w2 + 1,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w2, h));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left - w2, r.Top, w, h);

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CFU), ColorToARGB
                (CTU), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w, h), ColorToARGB(CFU), ColorToARGB(CTU)
                , LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Left + 1, r.Top + 1, w2 - 1,
            h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left + 1, r.Top + 1, w2 - 1,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

      end;
    tpRight:
      begin

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFU));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Right - w2, r.Top, w2, h)
          );
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Right - w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientU of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          // FF: Gradient fix here replace h by h2
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w2, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Right - w2, r.Top, w, h), ColorToARGB(CTU),
              ColorToARGB(CFU), LinearGradientModeBackwardDiagonal);
        end;

        if GradientU = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTU));

          colors[0] := ColorToARGB(CFU);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);

          Graphics.FillRectangle(pthGrBrush, r.Right - w2 + 1, r.Top + 1,
            w2 - 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Right - w2, r.Top + 1, w2,
            h - 1);
          linGrBrush.Free;
        end;

        path.Free;

        // down ellips brush

        solGrBrush := TGPSolidBrush.Create(ColorToARGB(CFB));
        Graphics.FillRectangle(solGrBrush, MakeRect(r.Left, r.Top, w2, h));
        solGrBrush.Free;

        // Create a path that consists of a single ellipse.
        path := TGPGraphicsPath.Create;
        path.AddEllipse(r.Left - w2, r.Top, w, h);

        pthGrBrush := nil;
        linGrBrush := nil;

        case GradientB of
          ggRadial:
            pthGrBrush := TGPPathGradientBrush.Create(path);
          ggVertical:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2 + 2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeHorizontal);
          ggDiagonalForward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeForwardDiagonal);
          ggDiagonalBackward:
            linGrBrush := TGPLinearGradientBrush.Create
              (MakeRect(r.Left, r.Top, w2, h), ColorToARGB(CTB), ColorToARGB
                (CFB), LinearGradientModeBackwardDiagonal);
        end;

        if GradientB = ggRadial then
        begin
          pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.Top + h2));

          // Set the color at the center point to blue.
          pthGrBrush.SetCenterColor(ColorToARGB(CTB));

          colors[0] := ColorToARGB(CFB);
          Count := 1;
          pthGrBrush.SetSurroundColors(@colors, Count);
          Graphics.FillRectangle(pthGrBrush, r.Left, r.Top, w2 + 1, h - 1);
          pthGrBrush.Free;
        end
        else
        begin
          Graphics.FillRectangle(linGrBrush, r.Left, r.Top, w2 + 2, h - 1);
          linGrBrush.Free;
        end;

        path.Free;

      end;
  end;

  Graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  if (PC <> clNone) then
  begin
    Graphics.ResetClip;
    gppen := TGPPen.Create(ColorToARGB(PC), 1.6);
    Graphics.DrawPath(gppen, TabPath);
    gppen.Free;
  end;

  if Focus then
  begin
    gppen := TGPPen.Create(ColorToARGB($E4AD89), 1);
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(Graphics, gppen, r.Left + 1, r.Top + 1, r.Right - 3,
      r.Bottom - 3, 3);
    gppen.Free;
    gppen := TGPPen.Create(ColorToARGB(clGray), 1);
    gppen.SetDashStyle(DashStyleDot);
    Graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(Graphics, gppen, r.Left + 2, r.Top + 2, r.Right - 5,
      r.Bottom - 5, 3);
    gppen.Free;
  end;

  if Assigned(Rgn) then
    Rgn.Free;
  TabPath.Free;
  Graphics.Free;
end;

// ------------------------------------------------------------------------------

{ TPagerTabSettings }

constructor TPagerTabSettings.Create;
begin
  inherited;
  FLeftMargin := 4;
  FRightMargin := 4;
  FHeight := DEFAULT_TABHEIGHT;
  FStartMargin := 4;
  FEndMargin := 0;
  FSpacing := 4;
  FWidth := 0;
  FWordWrap := False;
  FImagePosition := ipLeft;
  FShape := tsRectangle;
  FRounding := 1;
  FAlignment := taLeftJustify;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.Assign(Source: TPersistent);
begin
  if (Source is TPagerTabSettings) then
  begin
    LeftMargin := (Source as TPagerTabSettings).LeftMargin;
    RightMargin := (Source as TPagerTabSettings).RightMargin;
    Height := (Source as TPagerTabSettings).Height;
    StartMargin := (Source as TPagerTabSettings).StartMargin;
    EndMargin := (Source as TPagerTabSettings).EndMargin;
    Width := (Source as TPagerTabSettings).Width;
    WordWrap := (Source as TPagerTabSettings).WordWrap;
    ImagePosition := (Source as TPagerTabSettings).ImagePosition;
    Shape := (Source as TPagerTabSettings).Shape;
    Rounding := (Source as TPagerTabSettings).Rounding;
    Alignment := (Source as TPagerTabSettings).Alignment;
  end
  else
    inherited;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetLeftMargin(const Value: Integer);
begin
  if (FLeftMargin <> Value) then
  begin
    FLeftMargin := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetRightMargin(const Value: Integer);
begin
  if (FRightMargin <> Value) then
  begin
    FRightMargin := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetHeight(const Value: Integer);
begin
  if (FHeight <> Value) then
  begin
    FHeight := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetStartMargin(const Value: Integer);
begin
  if (FStartMargin <> Value) then
  begin
    FStartMargin := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetEndMargin(const Value: Integer);
begin
  if (FEndMargin <> Value) then
  begin
    FEndMargin := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetSpacing(const Value: Integer);
begin
  if (FSpacing <> Value) then
  begin
    FSpacing := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetWidth(const Value: Integer);
begin
  if (FWidth <> Value) then
  begin
    FWidth := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetWordWrap(const Value: Boolean);
begin
  if (FWordWrap <> Value) then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetImagePosition(const Value: TImagePosition);
begin
  if (FImagePosition <> Value) then
  begin
    FImagePosition := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetRounding(const Value: TTabRounding);
begin
  if (FRounding <> Value) then
  begin
    FRounding := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetShape(const Value: TTabShape);
begin
  if (FShape <> Value) then
  begin
    FShape := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPagerTabSettings.SetAlignment(const Value: TAlignment);
begin
  if (FAlignment <> Value) then
  begin
    FAlignment := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

{ TGradientBackground }

procedure TGradientBackground.Assign(Source: TPersistent);
begin
  if (Source is TGradientBackground) then
  begin
    FColor := (Source as TGradientBackground).Color;
    FColorTo := (Source as TGradientBackground).ColorTo;
    FDirection := (Source as TGradientBackground).Direction;
    FSteps := (Source as TGradientBackground).Steps;
  end;
end;

// ------------------------------------------------------------------------------

procedure TGradientBackground.Changed;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

// ------------------------------------------------------------------------------

constructor TGradientBackground.Create;
begin
  inherited;
  Color := clWhite;
  ColorTo := clBtnFace;
  Steps := 64;
  Direction := gdHorizontal;
end;

// ------------------------------------------------------------------------------

procedure TGradientBackground.SetColor(const Value: TColor);
begin
  FColor := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TGradientBackground.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TGradientBackground.SetDirection(const Value: TGradientDirection);
begin
  FDirection := Value;
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TGradientBackground.SetSteps(const Value: Integer);
begin
  FSteps := Value;
  Changed;
end;


// ------------------------------------------------------------------------------

{ TVistaBackground }

constructor TVistaBackground.Create;
begin
  inherited;
  FSteps := 64;
  FBorderColor := $BB763D;

  FColor := $F8E9DA; // $00FEFAF5;
  FColorTo := $00FEFAF5;
  FColorMirror := $00FEFAF5;
  FColorMirrorTo := $00F8E9DA;

  FGradient := ggVertical;
  FGradientMirror := ggVertical;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.Assign(Source: TPersistent);
begin
  if (Source is TVistaBackground) then
  begin
    FSteps := (Source as TVistaBackground).Steps;
    FColor := (Source as TVistaBackground).Color;
    FColorTo := (Source as TVistaBackground).ColorTo;
    FColorMirror := (Source as TVistaBackground).ColorMirror;
    FColorMirrorTo := (Source as TVistaBackground).ColorMirrorTo;
    FBorderColor := (Source as TVistaBackground).BorderColor;
    Gradient := (Source as TVistaBackground).Gradient;
    GradientMirror := (Source as TVistaBackground).GradientMirror;
  end
  else
    inherited Assign(Source);
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetColorMirror(const Value: TColor);
begin
  if (FColorMirror <> Value) then
  begin
    FColorMirror := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetColorMirrorTo(const Value: TColor);
begin
  if (FColorMirrorTo <> Value) then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetGradient(const Value: TGDIPGradient);
begin
  if (FGradient <> Value) then
  begin
    FGradient := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetGradientMirror(const Value: TGDIPGradient);
begin
  if (FGradientMirror <> Value) then
  begin
    FGradientMirror := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TVistaBackground.SetSteps(const Value: Integer);
begin
  if (FSteps <> Value) then
  begin
    FSteps := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

{ TCustomTabAppearance }

constructor TTabAppearance.Create;
begin
  FBorderColor := $BB763D; // clNone;
  FBorderColorDisabled := $BB763D; // clNone;
  FBorderColorHot := $11CAFF; // $EABC99;
  FBorderColorSelected := $BB763D; // $E3B28D;
  FBorderColorSelectedHot := $11CAFF; // $60CCF9;
  FBorderColorDown := $BB763D;

  FTextColor := $8B4215;
  FTextColorHot := $8B4215;
  FTextColorSelected := $8B4215;
  FTextColorDisabled := clGray;

  FColor := $F4D6BD;
  FColorTo := $F0C39D;
  FColorSelected := clWhite; // $FEF6F0;
  FColorSelectedTo := $F8E9DA; // $FAF1E9;
  FColorMirrorSelected := $F8E9DA; // $FAF1E9;
  FColorMirrorSelectedTo := $F8E9DA; // $F6EAE0;

  FColorDisabled := clWhite;
  FColorDisabledTo := clSilver;
  FColorMirrorDisabled := clWhite;
  FColorMirrorDisabledTo := clSilver;

  FColorHot := $F6D7BD; // $DDE5E4;
  FColorHotTo := $FCF2E9; // $FFDEC5;
  FColorMirror := $F0C39D;
  FColorMirrorTo := $ECB080;
  FColorMirrorHot := $F6D7BD; // $D5DFDD;
  FColorMirrorHotTo := $F0BC91; // $A3D3E1;
  FBackGround := TGradientBackground.Create;
  FBackGround.OnChange := OnBackGroundChanged;
  FBackGround.FColor := $FFDBBF;
  FBackGround.FColorTo := clNone;

  FFont := TFont.Create;
  FFont.Name := 'Tahoma';
  FFont.Size := 8;
  FFont.Style := [];
  FFont.OnChange := OnFontChanged;

  FShadowColor := $E8C7AE; // $00E8C7AE;
  FHighLightColor := $FFFABF; // $00FFFABF;
  FHighLightColorSelected := $63CCF8; // $0063CCF8;
  FHighLightColorSelectedHot := $BDFFFF; // $00BDFFFF;
  FHighLightColorDown := $FFFBD0; // $00FFFBD0;
  FHighLightColorHot := $FDF4ED; // $00FDF4ED;

  FGradient := ggVertical;
  FGradientMirror := ggVertical;
  FGradientHot := ggRadial;
  FGradientMirrorHot := ggRadial;
  FGradientSelected := ggVertical;
  FGradientMirrorSelected := ggVertical;
  FGradientDisabled := ggVertical;
  FGradientMirrorDisabled := ggVertical;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.Assign(Source: TPersistent);
begin
  if (Source is TTabAppearance) then
  begin
    FBorderColor := (Source as TTabAppearance).BorderColor;
    FBorderColorHot := (Source as TTabAppearance).BorderColorHot;
    FBorderColorSelectedHot := (Source as TTabAppearance)
      .BorderColorSelectedHot;
    FBorderColorDown := (Source as TTabAppearance).BorderColorDown;
    FColor := (Source as TTabAppearance).Color;
    FColorTo := (Source as TTabAppearance).ColorTo;
    FColorHot := (Source as TTabAppearance).ColorHot;
    FColorHotTo := (Source as TTabAppearance).ColorHotTo;
    FColorSelectedTo := (Source as TTabAppearance).ColorSelectedTo;
    FBorderColorDisabled := (Source as TTabAppearance).BorderColorDisabled;
    FBorderColorSelected := (Source as TTabAppearance).BorderColorSelected;
    FColorDisabled := (Source as TTabAppearance).ColorDisabled;
    FColorDisabledTo := (Source as TTabAppearance).ColorDisabledTo;
    FColorSelected := (Source as TTabAppearance).ColorSelected;
    FColorMirror := (Source as TTabAppearance).ColorMirror;
    FColorMirrorTo := (Source as TTabAppearance).ColorMirrorTo;
    FColorMirrorHot := (Source as TTabAppearance).ColorMirrorHot;
    FColorMirrorHotTo := (Source as TTabAppearance).ColorMirrorHotTo;
    FGradientMirror := (Source as TTabAppearance).GradientMirror;
    FGradientMirrorHot := (Source as TTabAppearance).GradientMirrorHot;
    FGradient := (Source as TTabAppearance).Gradient;
    FGradientHot := (Source as TTabAppearance).GradientHot;
    FColorMirrorDisabledTo := (Source as TTabAppearance).ColorMirrorDisabledTo;
    FColorMirrorDisabled := (Source as TTabAppearance).ColorMirrorDisabled;
    FColorMirrorSelectedTo := (Source as TTabAppearance).ColorMirrorSelectedTo;
    FColorMirrorSelected := (Source as TTabAppearance).ColorMirrorSelected;
    FGradientSelected := (Source as TTabAppearance).GradientSelected;
    FGradientDisabled := (Source as TTabAppearance).GradientDisabled;
    FGradientMirrorSelected := (Source as TTabAppearance)
      .GradientMirrorSelected;
    FGradientMirrorDisabled := (Source as TTabAppearance)
      .GradientMirrorDisabled;
    FTextColorDisabled := (Source as TTabAppearance).TextColorDisabled;
    FTextColorSelected := (Source as TTabAppearance).TextColorSelected;
    Font.Assign((Source as TTabAppearance).Font);
    TextColor := (Source as TTabAppearance).TextColor;
    TextColorHot := (Source as TTabAppearance).TextColorHot;
    FShadowColor := (Source as TTabAppearance).ShadowColor;
    FHighLightColor := (Source as TTabAppearance).HighLightColor;
    FHighLightColorHot := (Source as TTabAppearance).HighLightColorHot;
    FHighLightColorDown := (Source as TTabAppearance).HighLightColorDown;
    FHighLightColorSelected := (Source as TTabAppearance)
      .HighLightColorSelected;
    FHighLightColorSelectedHot := (Source as TTabAppearance)
      .HighLightColorSelectedHot;
    BackGround.Assign((Source as TTabAppearance).BackGround);
  end
  else
    inherited Assign(Source);
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// ------------------------------------------------------------------------------

destructor TTabAppearance.Destroy;
begin
  FBackGround.Free;
  FFont.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBackGround(const Value: TGradientBackground);
begin
  FBackGround.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBorderColorDisabled(const Value: TColor);
begin
  if (FBorderColorDisabled <> Value) then
  begin
    FBorderColorDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBorderColorSelected(const Value: TColor);
begin
  if (FBorderColorSelected <> Value) then
  begin
    FBorderColorSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBorderColorSelectedHot(const Value: TColor);
begin
  if (FBorderColorSelectedHot <> Value) then
  begin
    FBorderColorSelectedHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorDisabled(const Value: TColor);
begin
  if (FColorDisabled <> Value) then
  begin
    FColorDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorDisabledTo(const Value: TColor);
begin
  if (FColorDisabledTo <> Value) then
  begin
    FColorDisabledTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorHot(const Value: TColor);
begin
  if (FColorHot <> Value) then
  begin
    FColorHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorHotTo(const Value: TColor);
begin
  if (FColorHotTo <> Value) then
  begin
    FColorHotTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirror(const Value: TColor);
begin
  if (FColorMirror <> Value) then
  begin
    FColorMirror := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorDisabled(const Value: TColor);
begin
  if (FColorMirrorDisabled <> Value) then
  begin
    FColorMirrorDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorDisabledTo(const Value: TColor);
begin
  if (FColorMirrorDisabledTo <> Value) then
  begin
    FColorMirrorDisabledTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorHot(const Value: TColor);
begin
  if (FColorMirrorHot <> Value) then
  begin
    FColorMirrorHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorHotTo(const Value: TColor);
begin
  if (FColorMirrorHotTo <> Value) then
  begin
    FColorMirrorHotTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorSelected(const Value: TColor);
begin
  if (FColorMirrorSelected <> Value) then
  begin
    FColorMirrorSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorSelectedTo(const Value: TColor);
begin
  if (FColorMirrorSelectedTo <> Value) then
  begin
    FColorMirrorSelectedTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorMirrorTo(const Value: TColor);
begin
  if (FColorMirrorTo <> Value) then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorSelected(const Value: TColor);
begin
  if (FColorSelected <> Value) then
  begin
    FColorSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorSelectedTo(const Value: TColor);
begin
  if (FColorSelectedTo <> Value) then
  begin
    FColorSelectedTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradient(const Value: TGDIPGradient);
begin
  if (FGradient <> Value) then
  begin
    FGradient := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientDisabled(const Value: TGDIPGradient);
begin
  if (FGradientDisabled <> Value) then
  begin
    FGradientDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientHot(const Value: TGDIPGradient);
begin
  if (FGradientHot <> Value) then
  begin
    FGradientHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientMirror(const Value: TGDIPGradient);
begin
  if (FGradientMirror <> Value) then
  begin
    FGradientMirror := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientMirrorDisabled(const Value: TGDIPGradient);
begin
  if (FGradientMirrorDisabled <> Value) then
  begin
    FGradientMirrorDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientMirrorHot(const Value: TGDIPGradient);
begin
  if (FGradientMirrorHot <> Value) then
  begin
    FGradientMirrorHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientMirrorSelected(const Value: TGDIPGradient);
begin
  if (FGradientMirrorSelected <> Value) then
  begin
    FGradientMirrorSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetGradientSelected(const Value: TGDIPGradient);
begin
  if (FGradientSelected <> Value) then
  begin
    FGradientSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetTextColor(const Value: TColor);
begin
  if (FTextColor <> Value) then
  begin
    FTextColor := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetTextColorDisabled(const Value: TColor);
begin
  if (FTextColorDisabled <> Value) then
  begin
    FTextColorDisabled := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetTextColorHot(const Value: TColor);
begin
  if (FTextColorHot <> Value) then
  begin
    FTextColorHot := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetTextColorSelected(const Value: TColor);
begin
  if (FTextColorSelected <> Value) then
  begin
    FTextColorSelected := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.OnBackGroundChanged(Sender: TObject);
begin
  Changed;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetBorderColorDown(const Value: TColor);
begin
  if (FBorderColorDown <> Value) then
  begin
    FBorderColorDown := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TTabAppearance.OnFontChanged(Sender: TObject);
begin
  if Assigned(FOnFontChange) then
    FOnFontChange(Self);
end;

// ------------------------------------------------------------------------------

{ TDbgList }

function TDbgList.GetItemsEx(Index: Integer): Pointer;
begin
  if (Index >= Count) then
  begin
    raise Exception.Create('Index out of bounds in list read access');
    Exit;
  end;

  if Index < Count then
    Result := inherited Items[Index]
  else
    Result := nil;
end;

// ------------------------------------------------------------------------------

procedure TDbgList.SetItemsEx(Index: Integer; const Value: Pointer);
begin
  if (Index >= Count) then
  begin
    raise Exception.Create('Index out of bounds in list write access');
  end;
  if Index < Count then
    inherited Items[Index] := Value;
end;

// ------------------------------------------------------------------------------

{ TCustomPageBrowserStyler }

procedure TPageBrowserStyler.AddControl(AControl: TCustomControl);
begin
  FControlList.add(AControl);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.Assign(Source: TPersistent);
begin
  if Source is TPageBrowserStyler then
  begin
    TabAppearance.Assign((Source as TPageBrowserStyler).TabAppearance);
    PageAppearance.Assign((Source as TPageBrowserStyler).PageAppearance);
    RoundEdges := (Source as TPageBrowserStyler).RoundEdges;
  end
  else
    inherited Assign(Source);
end;

// ------------------------------------------------------------------------------

constructor TPageBrowserStyler.Create(AOwner: TComponent);
begin
  inherited;
  FControlList := TDbgList.Create;
  FRoundEdges := True;
  FBlendFactor := 50;

  FTabAppearance := TTabAppearance.Create;
  FTabAppearance.OnChange := OnTabAppearanceChanged;
  FTabAppearance.OnFontChange := OnTabAppearanceFontChanged;
  FPageAppearance := TVistaBackground.Create;
  FPageAppearance.OnChange := OnPageAppearanceChanged;
end;

// ------------------------------------------------------------------------------

destructor TPageBrowserStyler.Destroy;
begin
  FControlList.Free;
  FTabAppearance.Free;
  FPageAppearance.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.Change(PropID: Integer);

var
  i: Integer;
begin
  if (csDestroying in ComponentState) then
    Exit;

  for i := 0 to FControlList.Count - 1 do
  begin
    if (TCustomControl(FControlList[i]) is TPageBrowser) then
      TPageBrowser(FControlList[i]).UpdateMe(PropID);
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.Notification(AComponent: TComponent;
  Operation: TOperation);

var
  i: Integer;
begin
  inherited;
  if not(csDestroying in ComponentState) and (Operation = opRemove) then
  begin
    i := FControlList.IndexOf(AComponent);
    if i >= 0 then
      FControlList.Remove(AComponent);
  end;

end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.RemoveControl(AControl: TCustomControl);

var
  i: Integer;
begin
  i := FControlList.IndexOf(AControl);
  if i >= 0 then
    FControlList.Delete(i);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.OnTabAppearanceChanged(Sender: TObject);
begin
  Change(1);
end;

procedure TPageBrowserStyler.OnTabAppearanceFontChanged(Sender: TObject);
begin
  Change(5);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.OnPageAppearanceChanged(Sender: TObject);
begin
  Change(2);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.Loaded;
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.SetRoundEdges(const Value: Boolean);
begin
  FRoundEdges := Value;
  Change(3);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.SetTabAppearance(const Value: TTabAppearance);
begin
  FTabAppearance.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowserStyler.SetPageAppearance(const Value: TVistaBackground);
begin
  FPageAppearance.Assign(Value);
end;

{ TTabSheetBrowser }

constructor TTabSheetBrowser.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls] - [csOpaque];
  FCaption := '';
  FWideCaption := '';
  FTabVisible := True;
  FTabEnabled := True;
  FImageIndex := -1;
  FTimer := nil;
  FTabHint := '';
  FCloseButton := nil;
  FHeighta := 35;
  FIPicture := TPicture.Create;
  FIPicture.OnChange := PictureChanged;

  FIDisabledPicture := TPicture.Create;
  FIDisabledPicture.OnChange := PictureChanged;

  FBkgCache := TBitmap.Create;

  FShowClose := True;

  FChecked := False;
  FShowCheckBox := False;

  FTabAppearance := TTabAppearance.Create;
  FTabAppearance.OnChange := OnTabAppearanceChanged;
  FUseTabAppearance := False;
  FTabAppearance.OnFontChange := OnTabAppearanceFontChanged;

  FPageAppearance := TVistaBackground.Create;
  FPageAppearance.OnChange := OnPageAppearanceChanged;
  FUsePageAppearance := False;

  DoubleBuffered := True;
end;

// ------------------------------------------------------------------------------

destructor TTabSheetBrowser.Destroy;
begin
  if (FPageBrowser <> nil) then
  begin
    FPageBrowser.RemovePage(Self);
  end;

  if Assigned(FTimer) then
  begin
    FTimer.Enabled := False;
    FreeAndNil(FTimer);
  end;

  FIPicture.Free;
  FIDisabledPicture.Free;
  FTabAppearance.Free;
  FPageAppearance.Free;
  FBkgCache.Free;
  FPageBrowserChild.Free;
  FTreeTab.FSelList.Remove(Self);
  FTreeTab.FBackList.Remove(Self);
  inherited;
end;

procedure TTabSheetBrowser.Delete;
var
  i: Integer;
begin
  if Assigned(FPageBrowserChild) then
  begin
    for i := 0 to FPageBrowserChild.TabSheetBrowserCount - 1 do
      FPageBrowserChild.TabSheetBrowser[0].Delete;
  end;
  Free;
end;

procedure TTabSheetBrowser.AlignControls(AControl: TControl; var ARect: TRect);
begin
  inherited;
end;

procedure TTabSheetBrowser.CMShowingChanged(var Message: TMessage);
begin
  inherited;
  if Showing then
  begin
    if Assigned(FOnShow) then
      FOnShow(Self);
  end;
end;

procedure TTabSheetBrowser.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
end;

procedure TTabSheetBrowser.Loaded;
begin
  inherited;

end;

procedure TTabSheetBrowser.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.Paint;

var
  r, TabR: TRect;
  LnClr: TColor;
  i: Integer;
  Layout: TButtonLayout;
  aPageAppearance: TVistaBackground;
begin
  // inherited;
  if not Assigned(FPageBrowser) or not Assigned
    (FPageBrowser.FPageBrowserStyler) then
    Exit;

  if UsePageAppearance then
    aPageAppearance := PageAppearance
  else
    aPageAppearance := FPageBrowser.FPageBrowserStyler.PageAppearance;

  if (Self.Color <> aPageAppearance.Color) then
    Self.Color := aPageAppearance.Color;

  r := ClientRect;

  case FPageBrowser.TabSettings.ImagePosition of
    ipTop:
      Layout := blGlyphTop;
    ipBottom:
      Layout := blGlyphBottom;
    ipLeft:
      Layout := blGlyphLeft;
    ipRight:
      Layout := blGlyphRight;
  else
    Layout := blGlyphLeft;
  end;

  with aPageAppearance do
  begin
    LnClr := Color;

    if FValidCache and FPageBrowser.BufferedPages then
      Canvas.Draw(r.Left, r.Top, FBkgCache)
    else
    begin
      if FPageBrowser.BufferedPages then
      begin
        FBkgCache.Height := r.Bottom - r.Top;
        FBkgCache.Width := r.Right - r.Left;
        DrawVistaGradient(FBkgCache.Canvas, Rect(0, 0, FBkgCache.Width,
            FBkgCache.Height), Color, ColorTo, ColorMirror, ColorMirrorTo,
          BorderColor, Gradient, GradientMirror, '', Font, Layout, Enabled,
          False, FPageBrowser.AntiAlias,
          FPageBrowser.FPageBrowserStyler.RoundEdges, True,
          FPageBrowser.TabPosition);
        Canvas.Draw(r.Left, r.Top, FBkgCache);
        FValidCache := True;
      end
      else
      begin
        DrawVistaGradient(Canvas, Rect(0, 0, Width, FHeighta), Color, ColorTo,
          ColorMirror, ColorMirrorTo, BorderColor, Gradient, GradientMirror,
          '', Font, Layout, Enabled, False, FPageBrowser.AntiAlias,
          FPageBrowser.FPageBrowserStyler.RoundEdges, True,
          FPageBrowser.TabPosition);
        DrawVistaGradient(Canvas, Rect(0, FHeighta - 1, Width, Height), Color,
          ColorTo, ColorMirror, ColorMirrorTo, BorderColor, Gradient,
          GradientMirror, '', Font, Layout, Enabled, False,
          FPageBrowser.AntiAlias, FPageBrowser.FPageBrowserStyler.RoundEdges,
          True, FPageBrowser.TabPosition);
      end;
    end;

    i := 3;
    if not FPageBrowser.FPageBrowserStyler.RoundEdges then
      i := 2;

    if BorderColor <> clNone then
    begin
      case (FPageBrowser.TabPosition) of
        tpTop:
          begin
            // Draw 3D effect
            Canvas.Pen.Color := BlendColor(clWhite, BorderColor,
              FPageBrowser.FPageBrowserStyler.BlendFactor);
            Canvas.MoveTo(r.Left + 1, r.Top + i);
            Canvas.LineTo(r.Left + 1, r.Bottom - 2);
            // Canvas.Pixels[R.Left+2, R.Bottom-3] := Canvas.Pen.Color;
            Canvas.MoveTo(r.Right - 2, r.Top + i);
            Canvas.LineTo(r.Right - 2, r.Bottom - 2);
            // Canvas.Pixels[R.Right-3, R.Bottom-3] := Canvas.Pen.Color;

            Canvas.MoveTo(r.Left + 3, r.Bottom - 2);
            Canvas.LineTo(r.Right - 2, r.Bottom - 2);
          end;
        tpBottom:
          begin
            // Draw 3D effect
            Canvas.Pen.Color := BlendColor(clWhite, BorderColor,
              FPageBrowser.FPageBrowserStyler.BlendFactor);
            Canvas.MoveTo(r.Left + 1, r.Top + 2);
            Canvas.LineTo(r.Left + 1, r.Bottom - i);
            Canvas.MoveTo(r.Right - 2, r.Top + 2);
            Canvas.LineTo(r.Right - 2, r.Bottom - i);

            Canvas.MoveTo(r.Left + 3, r.Top + 1);
            Canvas.LineTo(r.Right - 2, r.Top + 1);
          end;
        tpLeft:
          begin
            // Draw 3D effect
            Canvas.Pen.Color := BlendColor(clWhite, BorderColor,
              FPageBrowser.FPageBrowserStyler.BlendFactor);
            Canvas.MoveTo(r.Left + i, r.Top + 1);
            Canvas.LineTo(r.Right - 2, r.Top + 1);
            Canvas.MoveTo(r.Left + i, r.Bottom - 2);
            Canvas.LineTo(r.Right - 2, r.Bottom - 2);

            Canvas.MoveTo(r.Right - 2, r.Top + 3);
            Canvas.LineTo(r.Right - 2, r.Bottom - 2);
          end;
        tpRight:
          begin
            // Draw 3D effect
            Canvas.Pen.Color := BlendColor(clWhite, BorderColor,
              FPageBrowser.FPageBrowserStyler.BlendFactor);
            Canvas.MoveTo(r.Left + 2, r.Top + 1);
            Canvas.LineTo(r.Right - i, r.Top + 1);
            Canvas.MoveTo(r.Left + 2, r.Bottom - 2);
            Canvas.LineTo(r.Right - i, r.Bottom - 2);

            Canvas.MoveTo(r.Left + 1, r.Top + 3);
            Canvas.LineTo(r.Left + 1, r.Bottom - 2);
          end;
      end;
    end;

  end;

  if (FPageBrowser.ActivePage = Self) then
  begin
    TabR := FPageBrowser.GetTabRect(Self);

    if (FPageBrowser.TabSettings.Height > 0) then
    begin
      // Attaching to Tab
      case (FPageBrowser.TabPosition) of
        tpTop:
          begin
            TabR.Left := TabR.Left - FPageBrowser.FPageMargin;
            TabR.Right := TabR.Right - FPageBrowser.FPageMargin;
            if not FPageBrowser.UseOldDrawing then
            begin
              case FPageBrowser.TabSettings.Shape of
                tsRectangle:
                  TabR.Left := TabR.Left + 1;
                tsLeftRamp:
                  TabR.Left := TabR.Left + 2 +
                    FPageBrowser.TabSettings.Rounding div 2;
                tsRightRamp:
                  begin
                    TabR.Left := TabR.Left + 1;
                    TabR.Right := TabR.Right - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
                tsLeftRightRamp:
                  begin
                    TabR.Left := TabR.Left + 2 +
                      FPageBrowser.TabSettings.Rounding div 2;
                    TabR.Right := TabR.Right - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
              end;
            end;
            Canvas.Pen.Color := LnClr;
            Canvas.MoveTo(TabR.Left, 0);
            Canvas.LineTo(TabR.Right, 0);
          end;
        tpBottom:
          begin
            TabR.Left := TabR.Left - FPageBrowser.FPageMargin;
            TabR.Right := TabR.Right - FPageBrowser.FPageMargin;
            if not FPageBrowser.UseOldDrawing then
            begin
              case FPageBrowser.TabSettings.Shape of
                tsRectangle:
                  TabR.Left := TabR.Left + 1;
                tsLeftRamp:
                  TabR.Left := TabR.Left + 2 +
                    FPageBrowser.TabSettings.Rounding div 2;
                tsRightRamp:
                  begin
                    TabR.Left := TabR.Left + 1;
                    TabR.Right := TabR.Right -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
                tsLeftRightRamp:
                  begin
                    TabR.Left := TabR.Left + 1 +
                      FPageBrowser.TabSettings.Rounding div 2;
                    TabR.Right := TabR.Right -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
              end;
            end;
            Canvas.Pen.Color := LnClr;
            Canvas.MoveTo(TabR.Left, Height - 1);
            Canvas.LineTo(TabR.Right, Height - 1);
          end;
        tpLeft:
          begin
            TabR.Top := TabR.Top - FPageBrowser.FPageMargin;
            TabR.Bottom := TabR.Bottom - FPageBrowser.FPageMargin;
            if not FPageBrowser.UseOldDrawing then
            begin
              case FPageBrowser.TabSettings.Shape of
                tsRectangle:
                  TabR.Top := TabR.Top + 1;
                tsLeftRamp:
                  begin
                    TabR.Top := TabR.Top + 1;
                    TabR.Bottom := TabR.Bottom - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
                tsRightRamp:
                  TabR.Top := TabR.Top + 2 +
                    FPageBrowser.TabSettings.Rounding div 2;
                tsLeftRightRamp:
                  begin
                    TabR.Top := TabR.Top + 2 +
                      FPageBrowser.TabSettings.Rounding div 2;
                    TabR.Bottom := TabR.Bottom - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
              end;
            end;
            Canvas.Pen.Color := LnClr;
            Canvas.MoveTo(0, TabR.Top - 1);
            Canvas.LineTo(0, TabR.Bottom - 1);
          end;
        tpRight:
          begin
            TabR.Top := TabR.Top - FPageBrowser.FPageMargin;
            TabR.Bottom := TabR.Bottom - FPageBrowser.FPageMargin;
            if not FPageBrowser.UseOldDrawing then
            begin
              case FPageBrowser.TabSettings.Shape of
                tsRectangle:
                  TabR.Top := TabR.Top + 1;
                tsLeftRamp:
                  TabR.Top := TabR.Top + 1 +
                    FPageBrowser.TabSettings.Rounding div 2;
                tsRightRamp:
                  begin
                    TabR.Top := TabR.Top + 1;
                    TabR.Bottom := TabR.Bottom - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
                tsLeftRightRamp:
                  begin
                    TabR.Top := TabR.Top + 2 +
                      FPageBrowser.TabSettings.Rounding div 2;
                    TabR.Bottom := TabR.Bottom - 1 -
                      FPageBrowser.TabSettings.Rounding div 2;
                  end;
              end;
            end;
            Canvas.Pen.Color := LnClr;
            Canvas.MoveTo(Width - 1, TabR.Top - 1);
            Canvas.LineTo(Width - 1, TabR.Bottom - 1);
          end;
      end;
    end;

    if FPageBrowser.FPageBrowserStyler.RoundEdges and
      (FPageBrowser.PageMargin > 0) then
    begin
      // Clean up edges
      Canvas.Pixels[r.Left, r.Top] := FPageBrowser.Canvas.Pixels
        [Self.Left - 1, Self.Top - 1];
      Canvas.Pixels[r.Left + 1, r.Top] := FPageBrowser.Canvas.Pixels
        [Self.Left + 1, Self.Top - 1];
      Canvas.Pixels[r.Left, r.Top + 1] := FPageBrowser.Canvas.Pixels
        [Self.Left - 1, Self.Top];

      Canvas.Pixels[r.Left, r.Bottom - 1] := FPageBrowser.Canvas.Pixels
        [Self.Left - 1, Self.Top + Height];
      Canvas.Pixels[r.Left + 1, r.Bottom - 1] := FPageBrowser.Canvas.Pixels
        [Self.Left - 1, Self.Top + Height];
      Canvas.Pixels[r.Left, r.Bottom - 2] := FPageBrowser.Canvas.Pixels
        [Self.Left - 1, Self.Top + Height];

      Canvas.Pixels[r.Right - 1, r.Top] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top];
      Canvas.Pixels[r.Right - 2, r.Top] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top];
      Canvas.Pixels[r.Right - 1, r.Top + 1] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top];

      Canvas.Pixels[r.Right - 1, r.Bottom - 1] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top + Height];
      Canvas.Pixels[r.Right - 2, r.Bottom - 1] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top + Height];
      Canvas.Pixels[r.Right - 1, r.Bottom - 2] := FPageBrowser.Canvas.Pixels
        [Self.Left + Width, Self.Top + Height];
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SelectFirstControl;
begin
  SelectFirst;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetPageBrowser(const Value: TPageBrowser);
begin
  if (FPageBrowser <> Value) then
  begin
    if FPageBrowser <> nil then
      FPageBrowser.RemovePage(Self);
    Parent := Value;
    if (Value <> nil) then
    begin
      Value.AddPage(Self);
    end;
    OnTabAppearanceFontChanged(FTabAppearance);
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetParent(AParent: TWinControl);

var
  ci, ni: Integer;
  APageBrowser: TPageBrowser;
begin
  if ((AParent is TTabSheetBrowser) or (AParent is TPageBrowser)) and not
    (FUpdatingParent) then
  begin
    APageBrowser := nil;
    if (AParent is TTabSheetBrowser) then
    begin
      APageBrowser := TTabSheetBrowser(AParent).FPageBrowser;
    end
    else if (AParent is TPageBrowser) then
    begin
      APageBrowser := TPageBrowser(AParent);
    end;

    if Assigned(FPageBrowser) and Assigned(APageBrowser) then
    begin

      if (FPageBrowser <> APageBrowser) then
      begin
        FUpdatingParent := True;
        PageBrowser := APageBrowser;
        FUpdatingParent := False;
      end;

      if (FPageBrowser = APageBrowser) then
      begin
        if (AParent is TTabSheetBrowser) then
        begin
          ci := FPageBrowser.IndexOfPage(Self);
          ni := FPageBrowser.IndexOfPage(TTabSheetBrowser(AParent));
          AParent := APageBrowser;
          if (ci >= 0) and (ci < FPageBrowser.FPages.Count) and (ni >= 0) and
            (ni < FPageBrowser.FPages.Count) then
          begin
            FPageBrowser.MovePage(ci, ni);
          end
          else
            raise Exception.Create('Invalid Parent ' + inttostr(ci)
                + ':' + inttostr(ni));
        end
        else if (AParent is TPageBrowser) then
        begin
          AParent := APageBrowser;
        end;

        FPageBrowser.Invalidate;
        Invalidate;
      end
      else
        raise Exception.Create('Invalid Parent');
    end;
    // else
    // raise Exception.Create('Invalid Parent3');
  end;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetTabVisible(const Value: Boolean);
begin
  if (FTabVisible <> Value) then
  begin
    FTabVisible := Value;
    if Assigned(FPageBrowser) then
    begin
      FPageBrowser.InitializeAndUpdateButtons;
      if Assigned(FPageBrowser.ActivePage) then
        FPageBrowser.ActivePage.Invalidate;
      FPageBrowser.Invalidate;
      FPageBrowser.TabWidth;
      FPageBrowser.UpdateButtonsPos;
    end;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.TimerProc(Sender: TObject);

var
  p: TPoint;
begin
  case FGlowState of
    gsHover:
      begin
        FStepHover := FStepHover + FTimeInc;
        if ((FStepHover > 100) and (FTimeInc > 0)) or
          ((FStepHover < 0) and (FTimeInc < 0)) then
        begin
          if (FStepHover > 100) and (FTimeInc > 0) and Assigned(FPageBrowser)
            then
          begin
            FStepHover := 120;
            GetCursorPos(p);
            p := FPageBrowser.ScreenToClient(p);
            if not PtInRect(FPageBrowser.GetTabRect(Self), p) then
            begin
              FTimeInc := -GLOWSTEP;
              FGlowState := gsHover;
              FPageBrowser.FHotPageIndex := -1;
              Exit;
            end;
          end
          else if ((FStepHover < 0) and (FTimeInc < 0)) then
          begin
            FreeAndNil(FTimer);
            FGlowState := gsNone;
            if Assigned(FPageBrowser) then
              FPageBrowser.InvalidateTab(-1);
          end;

          FStepPush := 0;
          if (FStepHover > 100) then
            FStepHover := 120;
          if (FStepHover < 0) then
            FStepHover := -20;
        end
        else if Assigned(FPageBrowser) then
          FPageBrowser.InvalidateTab(-1);
      end;
    gsPush:
      begin
        FStepPush := FStepPush + FTimeInc;
        if ((FStepPush > 100) and (FTimeInc > 0)) or
          ((FStepPush < 0) and (FTimeInc < 0)) then
        begin
          FreeAndNil(FTimer);
          FGlowState := gsNone;
          FStepPush := 0;
          // FStepHover := 0;
        end
        else if Assigned(FPageBrowser) then
          FPageBrowser.InvalidateTab(-1);
      end;
  end;

end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.WMSize(var Message: TWMSize);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.CMControlChange(var Message: TCMControlChange);
begin
  inherited;
  with Message do
  begin

  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.CMControlListChange
  (var Message: TCMControlListChange);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.WMEraseBkGnd(var Message: TWMEraseBkGnd);
{ var
  DC: HDC;
  i: Integer;
  p: TPoint; }
begin
  if { FTransparent } False then
  begin
    if Assigned(Parent) then
    begin
      { DC := Message.DC;
        i := SaveDC(DC);
        p := ClientOrigin;
        Windows.ScreenToClient(Parent.Handle, p);
        p.x := -p.x;
        p.y := -p.y;
        MoveWindowOrg(DC, p.x, p.y);
        SendMessage(Parent.Handle, WM_ERASEBKGND, DC, 0);
        SendMessage(Parent.Handle, WM_PAINT, DC, 0);
        if (Parent is TWinCtrl) then
        (Parent as TWinCtrl).PaintCtrls(DC, nil);
        RestoreDC(DC, i); }
    end;
  end
  else
  begin
    inherited;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if Reader.Parent is TPageBrowser then
    PageBrowser := TPageBrowser(Reader.Parent);
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.PictureChanged(Sender: TObject);
begin
  if Assigned(FPageBrowser) then
  begin
    FPageBrowser.Invalidate;
    if not(csLoading in ComponentState) then
    begin
      if (FPageBrowser.ActivePage = Self) then
        FPageBrowser.InitializeAndUpdateButtons;
      FPageBrowser.TabWidth;
      FPageBrowser.UpdateButtonsPos;
    end;
  end;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetDisabledPicture(const Value: TPicture);
begin
  FIDisabledPicture.Assign(Value);
  if Assigned(FPageBrowser) then
    FPageBrowser.Invalidate;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetPicture(const Value: TPicture);
begin
  FIPicture.Assign(Value);
  if Assigned(FPageBrowser) then
    FPageBrowser.Invalidate;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetCaption(const Value: TCaption);
begin
  if FCaption = Value then
    Exit;
  FCaption := Value;
  if Assigned(FTreeNodeETC) then
    FTreeNodeETC.Text := FCaption;
  if Assigned(FTreeNodeTV) then
    FTreeNodeTV.Text := FCaption;
  FCaption := Value;
  if Assigned(FNodeButton) then
  begin
    FNodeButton.Hint := FCaption;
    FNodeButton.UpdateSize;
  end;

  Invalidate;
  if Assigned(FPageBrowser) then
  begin
    FPageBrowser.Invalidate;
    if FPageBrowser.ActivePage = Self then
      FPageBrowser.InitializeAndUpdateButtons;
  end;
end;

procedure TTabSheetBrowser.SetChecked(const Value: Boolean);
begin
  if FChecked <> Value then
  begin
    FChecked := Value;
    if Assigned(FPageBrowser) then
      FPageBrowser.Invalidate;

    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetTabEnabled(const Value: Boolean);
begin
  if (FTabEnabled <> Value) then
  begin
    FTabEnabled := Value;
    Invalidate;
    if Assigned(FPageBrowser) then
      FPageBrowser.Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  if Assigned(FPageBrowser) then
    FPageBrowser.Invalidate;
end;

// ------------------------------------------------------------------------------

function TTabSheetBrowser.GetPageIndex: Integer;
begin
  if Assigned(FPageBrowser) then
    Result := FPageBrowser.IndexOfPage(Self)
  else
    Result := -1;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetPageIndex(const Value: Integer);
begin
  if Assigned(FPageBrowser) and (Value >= 0) and
    (Value < FPageBrowser.TabSheetBrowserCount) then
  begin
    FPageBrowser.MovePage(FPageBrowser.IndexOfPage(Self), Value);
    FPageBrowser.Invalidate;
    Invalidate;
  end;
end;


// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.AdjustClientRect(var Rect: TRect);
begin
  Rect := Classes.Rect(2, 2, Rect.Right - 2, Rect.Bottom - 2);
  inherited AdjustClientRect(Rect);
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetShowCheckBox(const Value: Boolean);
begin
  if FShowCheckBox <> Value then
  begin
    FShowCheckBox := Value;
    if Assigned(FPageBrowser) then
    begin
      FPageBrowser.InitializeAndUpdateButtons;
      FPageBrowser.Invalidate;
    end;
    Invalidate;
  end;
end;

procedure TTabSheetBrowser.SetShowClose(const Value: Boolean);
begin
  if (FShowClose <> Value) then
  begin
    FShowClose := Value;

    if not FShowClose and Assigned(FCloseButton) then
    begin
      FCloseButton.Free;
      FCloseButton := nil;
    end;

    if Assigned(FPageBrowser) then
    begin
      FPageBrowser.InitializeAndUpdateButtons;
      FPageBrowser.Invalidate;
    end;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetTabAppearance(const Value: TTabAppearance);
begin
  FTabAppearance.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetUseTabAppearance(const Value: Boolean);
begin
  if (FUseTabAppearance <> Value) then
  begin
    FUseTabAppearance := Value;
    OnTabAppearanceFontChanged(FTabAppearance);
    if Assigned(FPageBrowser) then
      FPageBrowser.Invalidate;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.OnTabAppearanceFontChanged(Sender: TObject);
begin
  if (FUseTabAppearance) then
  begin
    Invalidate;
    if Assigned(FPageBrowser) then
    begin
      FPageBrowser.Invalidate;
      if FPageBrowser.ActivePage = Self then
        FPageBrowser.InitializeAndUpdateButtons;
    end;
  end;
end;

procedure TTabSheetBrowser.OnWebBrowserBeforeNavigate2
  (ASender: TObject; const pDisp: IDispatch; var URL, Flags, TargetFrameName,
  PostData, Headers: OleVariant; var Cancel: WordBool);
begin
  FhtmlDoc := nil;
end;

procedure TTabSheetBrowser.OnWebBrowserDocumentComplete
  (ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
  if Assigned(WebBrowser.Document) then
  begin
    FhtmlDoc := WebBrowser.Document as IHTMLDocument2;
    FhtmlDoc.onmouseover := (TEventObject.Create(Document_OnMouseOver)
        as IDispatch);
  end;
  Self.URL := URL;
end;

procedure TTabSheetBrowser.OnWebBrowserNewWindow2
  (ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
begin
  FTreeTab.Selected := FTreeTab.add(Self, URLNewTab);
  Cancel := True;
end;

procedure TTabSheetBrowser.OnWebBrowserTitleChange
  (ASender: TObject; const Text: widestring);
begin
  Caption := Text;
end;

procedure TTabSheetBrowser.Document_OnMouseOver;
var
  element: IHTMLElement;
begin
  if FhtmlDoc = nil then
    Exit;

  element := FhtmlDoc.parentWindow.event.srcElement;

  if LowerCase(element.tagName) = 'a' then
    URLNewTab := element.getAttribute('href', 0);
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.OnTabAppearanceChanged(Sender: TObject);
begin
  if Assigned(FPageBrowser) then
    FPageBrowser.Invalidate;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetPageAppearance(const Value: TVistaBackground);
begin
  FPageAppearance.Assign(Value);
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.OnPageAppearanceChanged(Sender: TObject);
begin
  FValidCache := False;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetURL(const Value: string);
begin
  if FURL = Value then
    Exit;
  FURL := Value;
  FToolbar.FComboBox.Text := FURL;
end;

procedure TTabSheetBrowser.SetUsePageAppearance(const Value: Boolean);
begin
  if (FUsePageAppearance <> Value) then
  begin
    FUsePageAppearance := Value;
    FValidCache := False;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TTabSheetBrowser.SetWideCaption(const Value: widestring);
begin
  if (FWideCaption <> Value) then
  begin
    FWideCaption := Value;
    Invalidate;
    if Assigned(FPageBrowser) and (Caption = '') then
    begin
      FPageBrowser.Invalidate;
      if FPageBrowser.ActivePage = Self then
        FPageBrowser.InitializeAndUpdateButtons;
    end;
  end;
end;

// ------------------------------------------------------------------------------

{ TPageBrowser }

constructor TPageBrowser.Create(AOwner: TComponent);
var
  ps: TPageBrowserStyler;
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls] - [csOpaque];

  FBufferedPages := False;

  FPageBrowserStyler := TPageBrowserStyler.Create(Self); ;
  FPageBrowserStyler.AddControl(Self);
{$IFDEF DELPHI6_LVL}
  FPageBrowserStyler.SetSubComponent(True);
{$ENDIF}
  FOffSetX := 0;
  FOffSetY := 0;

  FTabOffSet := 4;
  FPageMargin := PAGE_OFFSET;
  FIsClosing := False;

  FTabPosition := tpTop;

  FAntiAlias := aaClearType;

  FPages := TDbgList.Create;

  FTabSettings := TPagerTabSettings.Create;
  FTabSettings.OnChange := OnTabSettingsChanged;

  FActivePageIndex := -1;
  FHotPageIndex := -1;
  FOldHotPageIndex := -1;
  FDownPageIndex := -1;

  FShowTabHint := False;
  FHintPageIndex := -1;
  ShowHint := False;
  FShowCloseOnNonSelectedTabs := False;

  FButtonSettings := TPageButtonSettings.Create;
  FButtonSettings.OnChange := OnButtonSettingChanged;
  FRotateTabLeftRight := True;
  FCloseOnTabPosition := cpRight;

  DoubleBuffered := True;
  Height := 200;
  Width := 400;
  FOldCapRightIndent := 0;

  FTabReorder := False;
  FButtonsBkg := TBitmap.Create;

  FDesignTime := (csDesigning in ComponentState) and not
    ((csReading in Owner.ComponentState) or (csLoading in Owner.ComponentState)
    );

  ps := TPageBrowserStyler.Create(Self);
  // ps.SetStyle(pbsGoogleChrome);

  FPageBrowserStyler.Assign(ps);
  ps.Free;

  FGlow := True;

  FButtonNewSubtab := TSpeedButton.Create(Self);
  with FButtonNewSubtab do
  begin
    Parent := Self;
    Flat := True;
    Hint := 'New subtab';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'ADDSUB');
  end;

  FButtonNewTab := TSpeedButton.Create(Self);
  with FButtonNewTab do
  begin
    Parent := Self;
    Flat := True;
    Hint := 'New tab';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'ADD');
  end;

  ButtonSettings.CloseButton := True;
  FShowCloseOnNonSelectedTabs := True;
  FShowNonSelectedTabs := True;
  ShowTabHint := True;
  TabSettings.StartMargin := 4;
  TabSettings.Height := 28;
  TabSettings.Spacing := -12;
  TabSettings.Width := 205;
  TabSettings.Shape := tsLeftRightRamp;
  TabSettings.Rounding := 2;
  Transparent := True;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CreateParams(var Params: TCreateParams);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

destructor TPageBrowser.Destroy;

var
  i: Integer;
begin
  FreeAndNil(FPageBrowserStyler);

  for i := 0 to FPages.Count - 1 do
    TTabSheetBrowser(FPages[i]).FPageBrowser := nil;

  FPages.Free;
  FTabSettings.Free;
  FButtonSettings.Free;

  FButtonsBkg.Free;
  FButtonNewTab.Free;
  FButtonNewSubtab.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.MovePage(CurIndex, NewIndex: Integer);

var
  OldActivePage: TTabSheetBrowser;
begin
  if (CurIndex >= 0) and (CurIndex < FPages.Count) and (NewIndex >= 0) and
    (NewIndex < FPages.Count) then
  begin
    OldActivePage := ActivePage;
    FPages.Move(CurIndex, NewIndex);
    ActivePage := OldActivePage;
    TabWidth;
    UpdateButtonsPos;
    if Assigned(FOnTabMoved) then
      FOnTabMoved(Self, CurIndex, NewIndex);
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.AddPage(Page: TTabSheetBrowser): Integer;
begin
  Result := FPages.IndexOf(Page);
  if (FPages.IndexOf(Page) < 0) then
  begin
    FPages.add(Page);
    Result := FPages.Count - 1;

    if (csDesigning in ComponentState) and Assigned(FPageBrowserStyler) then
    begin
      if not Page.UsePageAppearance then
        Page.PageAppearance.Assign(FPageBrowserStyler.PageAppearance);

      if not Page.UseTabAppearance then
        Page.TabAppearance.Assign(FPageBrowserStyler.TabAppearance);
    end;
  end;

  if (Page.Parent <> Self) then
    Page.Parent := Self;
  Page.FPageBrowser := Self;
  SetPagePosition(Page);
  if (Page <> ActivePage) then
    Page.Visible := False;

  InvalidateTab(-1);
  if Assigned(ActivePage) then
  begin
    ActivePage.BringToFront;
    ActivePage.Invalidate;
  end;
  TabWidth;
  UpdateButtonsPos;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.AddPage(PageCaption: TCaption): Integer;

var
  aPage: TTabSheetBrowser;
begin
  aPage := TTabSheetBrowser.Create(Self);
  aPage.Caption := PageCaption;
  Result := AddPage(aPage);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.AlignControls(AControl: TControl; var ARect: TRect);
begin
  inherited;
  { if (AControl <> nil) and (AControl is TTabSheetBrowser) then
    SetPagePosition(TTabSheetBrowser(AControl))
    else if (AControl is TTabSheetBrowser) then }
  SetAllPagesPosition;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.Loaded;
begin
  inherited;
  FPropertiesLoaded := True;
  InitializeAndUpdateButtons;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if not(csDestroying in ComponentState) and (Operation = opRemove) then
  begin
    if (AComponent = PopupMenu) then
      PopupMenu := nil;
    if (AComponent = Images) then
      Images := nil;
    if (AComponent = DisabledImages) then
      DisabledImages := nil;
  end;

  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabImageSize(PageIndex: Integer): TSize;

var
  Pic: TPicture;
begin
  Result.cx := 0;
  Result.cy := 0;
  if (PageIndex < 0) or (PageIndex >= FPages.Count) then
    Exit;

  if TabSheetBrowser[PageIndex].Enabled or TabSheetBrowser[PageIndex]
    .DisabledPicture.Bitmap.Empty then
    Pic := TabSheetBrowser[PageIndex].Picture
  else
    Pic := TabSheetBrowser[PageIndex].DisabledPicture;

  if Assigned(Pic) and not Pic.Bitmap.Empty then
  begin
    Result.cx := Pic.Width;
    Result.cy := Pic.Height;
  end
  else if (Assigned(FImages) or Assigned(DisabledImages)) and
    (TabSheetBrowser[PageIndex].ImageIndex >= 0) then
  begin
    if TabSheetBrowser[PageIndex].Enabled then
    begin
      if Assigned(FImages) then
      begin
        Result.cx := FImages.Width;
        Result.cy := FImages.Height;
      end;
    end
    else
    begin
      if Assigned(FDisabledImages) then
      begin
        Result.cx := FDisabledImages.Width;
        Result.cy := FDisabledImages.Height;
      end
      else if Assigned(FImages) then
      begin
        Result.cx := FImages.Width;
        Result.cy := FImages.Height;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTextSize(PageIndex: Integer): TSize;

var
  r: TRect;
  // Ellipsis: Boolean;
  OldF: TFont;
begin
  Result.cx := 0;
  Result.cy := 0;
  if (PageIndex < 0) or (PageIndex >= FPages.Count) then
    Exit;

  // Ellipsis := (TabSettings.Width > 0) and not TabSettings.WordWrap;
  OldF := TFont.Create;
  OldF.Assign(Canvas.Font);
  Canvas.Font.Assign(FPageBrowserStyler.TabAppearance.Font);

  if (TabSheetBrowser[PageIndex].Caption <> '') then
  begin
    r := Rect(0, 0, 1000, 100);
    DrawText(Canvas.Handle, PChar(TabSheetBrowser[PageIndex].Caption), Length
        (TabSheetBrowser[PageIndex].Caption), r,
      DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
    Result.cx := r.Right;
    Result.cy := r.Bottom;
    case AntiAlias of
      aaNone, aaClearType:
        Result.cx := Result.cx + Length(TabSheetBrowser[PageIndex].Caption)
          div 3;
    end;
  end
  else if (TabSheetBrowser[PageIndex].WideCaption <> '') then
  begin
    r := Rect(0, 0, 1000, 100);
{$IFNDEF TMSDOTNET}
    DrawTextW(Canvas.Handle, PWideChar(TabSheetBrowser[PageIndex].WideCaption),
      -1, r, DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
{$ENDIF}
{$IFDEF TMSDOTNET}
    DrawTextW(Canvas.Handle, Pages[PageIndex].WideCaption, -1, r,
      DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
{$ENDIF}
    Result.cx := r.Right;
    Result.cy := r.Bottom;
    case AntiAlias of
      aaNone, aaClearType:
        Result.cx := Result.cx + Length(TabSheetBrowser[PageIndex].WideCaption);
    end;
  end;

  Canvas.Font.Assign(OldF);
  OldF.Free;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.GetCloseBtnImageAndTextRect
  (PageIndex: Integer; var CloseBtnR, TextR: TRect; var ImgP: TPoint);

var
  ActivePg: Boolean;
  r: TRect;
  i: Integer;
  ImgSize, TxtSize, CloseBtnSize: TSize;
begin
  if (PageIndex < 0) or (PageIndex >= FPages.Count) or
    (TabSettings.Height <= 0) or (TabSettings.Width <= 0) then
    Exit;

  r := GetTabRect(PageIndex);
  if (r.Left <= -1) and (r.Right <= -1) then
    Exit;

  ActivePg := (ActivePageIndex = PageIndex);

  ImgSize := GetTabImageSize(PageIndex);
  TxtSize := GetTextSize(PageIndex);

  CloseBtnSize.cx := PAGEBUTTON_SIZE;
  CloseBtnSize.cy := PAGEBUTTON_SIZE;

  if (TabPosition in [tpTop, tpBottom]) or (not RotateTabLeftRight) then
  begin
    i := r.Right - r.Left;

    if (TabSettings.Shape in [tsRightRamp, tsLeftRightRamp]) then
      r.Right := r.Right - TabSettings.Rounding;

    case TabSettings.ImagePosition of
      ipTop, ipBottom:
        ImgSize.cx := 0;
      ipLeft, ipRight:
        begin
        end;
    end;

    case TabSettings.Alignment of
      taLeftJustify:
        begin
        end;
      taCenter:
        begin
          if (CloseBtnSize.cx > 0) and ActivePg then
            i := (i - CloseBtnSize.cx - 4);
          if (ImgSize.cx > 0) then
            i := i - ImgSize.cx - IMG_SPACE;
          i := (i - TxtSize.cx) div 2;
          r.Left := Max(r.Left + i, r.Left);

          if ActivePg and (CloseOnTabPosition = cpLeft) then
          begin
            CloseBtnR.Left := r.Left;
            CloseBtnR.Right := CloseBtnR.Left + PAGEBUTTON_SIZE;
            r.Left := CloseBtnR.Right + 4;
          end;

          if (TabSettings.ImagePosition = ipLeft) and (ImgSize.cx > 0) then
          begin
            ImgP.X := r.Left;
            r.Left := r.Left + ImgSize.cx + IMG_SPACE;
          end;

          if (TxtSize.cx > 0) then
          begin
            TextR.Left := r.Left;
            TextR.Right := TextR.Left + TxtSize.cx;
            r.Left := Min(r.Left + TxtSize.cx, r.Right);
          end;

          if (TabSettings.ImagePosition = ipRight) and (ImgSize.cx > 0) then
          begin
            ImgP.X := r.Left + IMG_SPACE;
            r.Left := r.Left + ImgSize.cx + IMG_SPACE;
          end;

          if ActivePg and (CloseOnTabPosition = cpRight) then
          begin
            CloseBtnR.Left := r.Left + 4;
            CloseBtnR.Right := CloseBtnR.Left + PAGEBUTTON_SIZE;
          end;
        end;
      taRightJustify:
        begin
        end;
    end;
  end
  else if (TabPosition = tpLeft) then
  begin
    i := r.Bottom - r.Top;
    if (TabSettings.Shape in [tsLeftRamp, tsLeftRightRamp]) then
      r.Bottom := r.Bottom - TabSettings.Rounding;
    if (TabSettings.Shape in [tsRightRamp, tsLeftRightRamp]) then
      r.Top := r.Top + TabSettings.Rounding;

    case TabSettings.ImagePosition of
      ipTop, ipBottom:
        ImgSize.cx := 0;
      ipLeft, ipRight:
        begin
        end;
    end;

    if (CloseBtnSize.cx > 0) and ActivePg then
      i := (i - CloseBtnSize.cx - 4);
    if (ImgSize.cx > 0) then
      i := i - ImgSize.cx - IMG_SPACE;
    i := (i - TxtSize.cx) div 2;

    case TabSettings.Alignment of
      taLeftJustify:
        begin
        end;
      taCenter:
        begin
          r.Bottom := Min(r.Bottom - i, r.Bottom);

          if ActivePg and (CloseOnTabPosition = cpLeft) then
          begin
            CloseBtnR.Top := r.Bottom - PAGEBUTTON_SIZE;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
            r.Bottom := CloseBtnR.Top - 4;
          end;

          if (TabSettings.ImagePosition = ipLeft) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Bottom - ImgSize.cy;
            r.Bottom := r.Bottom - ImgSize.cy - IMG_SPACE;
          end;

          if (TxtSize.cx > 0) then
          begin
            TextR.Bottom := r.Bottom;
            TextR.Top := TextR.Bottom - TxtSize.cx;
            r.Bottom := Max(r.Bottom - TxtSize.cx, r.Top);
          end;

          if (TabSettings.ImagePosition = ipRight) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Bottom - ImgSize.cy - IMG_SPACE;
            r.Bottom := ImgP.Y;
          end;

          if ActivePg and (CloseOnTabPosition = cpRight) then
          begin
            CloseBtnR.Bottom := r.Bottom - 4;
            CloseBtnR.Top := CloseBtnR.Bottom - PAGEBUTTON_SIZE;
          end;
        end;
      taRightJustify:
        begin
          r.Bottom := Min(r.Bottom - i, r.Bottom);

          if ActivePg and (CloseOnTabPosition = cpRight) then
          begin
            CloseBtnR.Top := r.Top;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
            r.Top := CloseBtnR.Bottom + 4;
          end;

          if (TabSettings.ImagePosition = ipRight) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Top;
            r.Top := ImgP.Y + ImgSize.cy + IMG_SPACE;
          end;

          if (TxtSize.cx > 0) then
          begin
            TextR.Top := r.Top;
            TextR.Bottom := TextR.Top + TxtSize.cx;
            r.Top := Min(r.Top + TxtSize.cx, r.Bottom);
          end;

          if (TabSettings.ImagePosition = ipLeft) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Top + IMG_SPACE;
            r.Top := ImgP.Y + ImgSize.cy;
          end;
          if ActivePg and (CloseOnTabPosition = cpLeft) then
          begin
            CloseBtnR.Top := r.Top + 4;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
            r.Top := CloseBtnR.Bottom;
          end;
        end;
    end;
  end
  else if (TabPosition = tpRight) then
  begin
    i := r.Bottom - r.Top;
    if (TabSettings.Shape in [tsLeftRamp, tsLeftRightRamp]) then
      r.Bottom := r.Bottom - TabSettings.Rounding;
    if (TabSettings.Shape in [tsRightRamp, tsLeftRightRamp]) then
      r.Top := r.Top + TabSettings.Rounding;

    case TabSettings.ImagePosition of
      ipTop, ipBottom:
        ImgSize.cx := 0;
      ipLeft, ipRight:
        begin
        end;
    end;

    if (CloseBtnSize.cx > 0) and ActivePg then
      i := (i - CloseBtnSize.cx - 4);
    if (ImgSize.cx > 0) then
      i := i - ImgSize.cx - IMG_SPACE;
    i := (i - TxtSize.cx) div 2;

    case TabSettings.Alignment of
      taLeftJustify:
        begin
        end;
      taCenter:
        begin
          r.Top := Min(r.Top + i, r.Bottom);

          if ActivePg and (CloseOnTabPosition = cpLeft) then
          begin
            CloseBtnR.Top := r.Top;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
            r.Top := CloseBtnR.Top + PAGEBUTTON_SIZE + 4;
          end;

          if (TabSettings.ImagePosition = ipLeft) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Top;
            r.Top := r.Top + ImgSize.cy + IMG_SPACE;
          end;

          if (TxtSize.cx > 0) then
          begin
            TextR.Top := r.Top;
            TextR.Bottom := TextR.Top + TxtSize.cx;
            r.Top := Min(r.Top + TxtSize.cx, r.Bottom);
          end;

          if (TabSettings.ImagePosition = ipRight) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Top + IMG_SPACE;
            r.Top := ImgP.Y + ImgSize.cy;
          end;

          if ActivePg and (CloseOnTabPosition = cpRight) then
          begin
            CloseBtnR.Top := r.Top + 4;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
          end;
        end;
      taRightJustify:
        begin
          // R.Top := Min(R.Top + i, R.Bottom);

          if ActivePg and (CloseOnTabPosition = cpRight) then
          begin
            CloseBtnR.Top := r.Bottom - PAGEBUTTON_SIZE;
            CloseBtnR.Bottom := CloseBtnR.Top + PAGEBUTTON_SIZE;
            r.Bottom := CloseBtnR.Top - 4;
          end;

          if (TabSettings.ImagePosition = ipRight) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Bottom - ImgSize.cy;
            r.Bottom := ImgP.Y - ImgSize.cy - IMG_SPACE;
          end;

          if (TxtSize.cx > 0) then
          begin
            TextR.Bottom := r.Bottom;
            TextR.Top := TextR.Bottom - TxtSize.cx;
            r.Bottom := Max(r.Bottom - TxtSize.cx, r.Top);
          end;

          if (TabSettings.ImagePosition = ipLeft) and (ImgSize.cx > 0) then
          begin
            ImgP.Y := r.Bottom - IMG_SPACE - ImgSize.cy;
            r.Bottom := ImgP.Y;
          end;
          if ActivePg and (CloseOnTabPosition = cpLeft) then
          begin
            CloseBtnR.Bottom := r.Bottom - 4;
            CloseBtnR.Top := CloseBtnR.Bottom - PAGEBUTTON_SIZE;
            r.Bottom := CloseBtnR.Top;
          end;
        end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.DrawTab(PageIndex: Integer);

var
  GradColor: TColor;
  GradColorTo: TColor;
  GradColorMirror: TColor;
  GradColorMirrorTo: TColor;
  PenColor, TempClr: TColor;
  GradB, GradU: TGDIPGradient;
  ImgList: TCustomImageList;
  Pic: TPicture;
  ImgEnabled: Boolean;
  r, CapR: TRect;
  ImgX, ImgY, ImgTxtSp: Integer;
  ImgW, ImgH: Integer;
  DCaption: string;
  WCaption: widestring;
  DoRepaint: Boolean;
  TxtClr: TColor;
  TabAppearance: TTabAppearance;
  tf: TFont;
  lf: TLogFont;
  bmp: TBitmap;
  TabPos: TTabPosition;
  RotateLR: Boolean;
  SelectedHot: Boolean;
  Ellipsis: Boolean;
  Layout: TButtonLayout;
  TxtR, r2, R3, CapR2: TRect;
  AAlign: TAlignment;
  Shape: TTabShape;
  HighLightClr: TColor;
  cbr, TR: TRect;
  ImgP: TPoint;
  htheme: THandle;
  rc: TRect;
  DChecked: Cardinal;
begin
  if (PageIndex < 0) or (PageIndex >= FPages.Count) or
    (TabSettings.Height <= 0) then
    Exit;

  ImgTxtSp := IMG_SPACE;
  GradColor := clNone;
  GradColorTo := clNone;
  GradColorMirror := clNone;
  GradColorMirrorTo := clNone;
  PenColor := clNone;
  TxtClr := clNone;
  GradB := ggRadial;
  GradU := ggRadial;

  ImgList := nil;
  DoRepaint := True;

  SelectedHot := False;

  r := GetTabRect(PageIndex);

  if (r.Left <= -1) and (r.Right <= -1) then
    Exit;

  Layout := blGlyphLeft;
  ImgY := 0;
  ImgX := 0;
  ImgH := 0;
  ImgW := 0;

  ImgEnabled := True;

  Ellipsis := (TabSettings.Width > 0) and not TabSettings.WordWrap;
  if TabSheetBrowser[PageIndex].UseTabAppearance then
    TabAppearance := TabSheetBrowser[PageIndex].TabAppearance
  else
    TabAppearance := FPageBrowserStyler.TabAppearance;

  HighLightClr := TabAppearance.HighLightColor;

  with TabAppearance do
  begin
    // DrawDwLn := False;
    if not(TabSheetBrowser[PageIndex].TabEnabled) and ShowNonSelectedTabs then
    begin
      if ShowNonSelectedTabs then
      begin
        GradColor := ColorDisabled;
        GradColorTo := ColorDisabledTo;
        GradColorMirror := ColorMirrorDisabled;
        GradColorMirrorTo := ColorMirrorDisabledTo;
        PenColor := BorderColorDisabled;
        GradU := GradientDisabled;
        GradB := GradientMirrorDisabled;
        TxtClr := TextColorDisabled;
      end
      else
      begin

      end;
    end
    else if (PageIndex = ActivePageIndex) then
    begin
      GradColor := ColorSelected;
      GradColorTo := ColorSelectedTo;
      GradColorMirror := ColorMirrorSelected;
      GradColorMirrorTo := ColorMirrorSelectedTo;
      PenColor := BorderColorSelected;
      GradU := GradientSelected;
      GradB := GradientMirrorSelected;
      TxtClr := TextColorSelected;
      HighLightClr := TabAppearance.HighLightColor;

      { if (GroupOfTab(PageIndex) >= 0) then
        begin
        GradColor := ColorSelectedGroup;
        GradColorTo := ColorSelectedGroupTo;
        GradColorMirror := ColorMirrorSelectedGroup;
        GradColorMirrorTo := ColorMirrorSelectedGroupTo;
        //PenColor := BorderColorSelectedGroup;
        GradU := GradientSelectedGroup;
        GradB := GradientMirrorSelectedGroup;
        TxtClr := TextColorSelectedGroup;
        end;
        }
      if (PageIndex = FHotPageIndex) then
      begin
        PenColor := BorderColorSelectedHot;
        HighLightClr := TabAppearance.HighLightColorSelectedHot;
      end;

      if Assigned(TabSheetBrowser[PageIndex].FTimer) then
      begin
        if (TabSheetBrowser[PageIndex].FGlowState = gsPush) then
        begin
          GradColor := BlendColor(GradColor, FColorHot,
            TabSheetBrowser[PageIndex].FStepPush);
          GradColorTo := BlendColor(GradColorTo, FColorHotTo,
            TabSheetBrowser[PageIndex].FStepPush);
          GradColorMirror := BlendColor(GradColorMirror, FColorMirrorHot,
            TabSheetBrowser[PageIndex].FStepPush);
          GradColorMirrorTo := BlendColor(GradColorMirrorTo, FColorMirrorHotTo,
            TabSheetBrowser[PageIndex].FStepPush);
          PenColor := BlendColor(PenColor, BorderColorHot,
            TabSheetBrowser[PageIndex].FStepPush);
        end
        else if (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
          PenColor := BlendColor(BorderColorSelectedHot, BorderColorSelected,
            TabSheetBrowser[PageIndex].FStepHover);
      end;

      if (FDownPageIndex = PageIndex) and not(csDesigning in ComponentState)
        then
      begin
        PenColor := BorderColorDown;
        HighLightClr := TabAppearance.HighLightColorDown;
      end;
    end
    else // if State = absUp then
    begin
      if (PageIndex = FHotPageIndex) then
      begin
        GradColor := ColorHot;
        GradColorTo := ColorHotTo;
        GradColorMirror := ColorMirrorHot;
        GradColorMirrorTo := ColorMirrorHotTo;
        PenColor := BorderColorHot;
        GradU := GradientHot;
        GradB := GradientMirrorHot;
        TxtClr := TextColorHot;
        HighLightClr := TabAppearance.HighLightColorHot;
        // DrawDwLn := True;
        if Assigned(TabSheetBrowser[PageIndex].FTimer) and
          (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
        begin
          if ShowNonSelectedTabs then
          begin
            GradColor := BlendColor
              (FColorHot, FColor, TabSheetBrowser[PageIndex].FStepHover);
            GradColorTo := BlendColor(FColorHotTo, FColorTo,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FColorMirror,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FColorMirrorTo,
              TabSheetBrowser[PageIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, BorderColor,
              TabSheetBrowser[PageIndex].FStepHover);
          end
          else
          begin
            GradColor := BlendColor(FColorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            if (FPageBrowserStyler.TabAppearance.BackGround.ColorTo <> clNone)
              then
              GradColorTo := BlendColor(FColorHotTo,
                FPageBrowserStyler.TabAppearance.BackGround.ColorTo,
                TabSheetBrowser[PageIndex].FStepHover)
            else
              GradColorTo := BlendColor(FColorHotTo,
                FPageBrowserStyler.TabAppearance.BackGround.Color,
                TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
          end;
        end;
      end
      else // Normal draw
      begin
        if ShowNonSelectedTabs then
        begin
          GradColor := Color;
          GradColorTo := ColorTo;
          GradColorMirror := ColorMirror;
          GradColorMirrorTo := ColorMirrorTo;
          PenColor := BorderColor;
          GradU := Gradient;
          GradB := GradientMirror;
          TxtClr := TextColor;
          if Assigned(TabSheetBrowser[PageIndex].FTimer) and
            (TabSheetBrowser[PageIndex].FGlowState = gsHover)
          { and (PageIndex = FOldHotPageIndex) } then
          begin
            GradColor := BlendColor
              (FColorHot, FColor, TabSheetBrowser[PageIndex].FStepHover);
            GradColorTo := BlendColor(FColorHotTo, FColorTo,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FColorMirror,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FColorMirrorTo,
              TabSheetBrowser[PageIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, BorderColor,
              TabSheetBrowser[PageIndex].FStepHover);
          end;
        end
        else
        begin
          DoRepaint := False;
          TxtClr := TextColor;
          GradU := GradientHot;
          GradB := GradientMirrorHot;

          if not TabSheetBrowser[PageIndex].TabEnabled then
            TxtClr := TextColorDisabled;

          if Assigned(TabSheetBrowser[PageIndex].FTimer) and
            (TabSheetBrowser[PageIndex].FGlowState = gsHover)
          { and (PageIndex = FOldHotPageIndex) } then
          begin
            GradColor := BlendColor(FColorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            if (FPageBrowserStyler.TabAppearance.BackGround.ColorTo <> clNone)
              then
              GradColorTo := BlendColor(FColorHotTo,
                FPageBrowserStyler.TabAppearance.BackGround.ColorTo,
                TabSheetBrowser[PageIndex].FStepHover)
            else
              GradColorTo := BlendColor(FColorHotTo,
                FPageBrowserStyler.TabAppearance.BackGround.Color,
                TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot,
              FPageBrowserStyler.TabAppearance.BackGround.Color,
              TabSheetBrowser[PageIndex].FStepHover);
            DoRepaint := True;
          end;
        end;
      end;
    end;

    if Focused and (PageIndex = ActivePageIndex) then
    begin
      GradColor := ColorHot;
      GradColorTo := ColorHotTo;
      GradColorMirror := ColorMirrorHot;
      GradColorMirrorTo := ColorMirrorHotTo;
      PenColor := BorderColorSelectedHot;
      GradU := GradientHot;
      GradB := GradientMirrorHot;
      TxtClr := TextColorHot;
      HighLightClr := TabAppearance.HighLightColorSelected;
      SelectedHot := True;
    end;

    { if FHot then
      begin
      GradColor := FColorHot;
      GradColorTo := FColorHotTo;
      GradColorMirror := FColorMirrorHot;
      GradColorMirrorTo := FColorMirrorHotTo;
      PenColor := BorderColorHot;
      GradU := GradientHot;
      GradB := GradientMirrorHot;
      end
      else
      begin
      GradColor := FColor;
      GradColorTo := FColorTo;
      GradColorMirror := FColorMirror;
      GradColorMirrorTo := FColorMirrorTo;
      PenColor := BorderColor;
      GradU := Gradient;
      GradB := GradientMirror;
      end;

      if FDown then
      begin
      PenColor := BorderColorDown;
      GradU := GradientDown;
      GradB := GradientMirrorDown;
      end;
      }
    (* if Assigned(FTimer) then
      begin
      if not FDown and not ((State = absExclusive) or ((Style = bsCheck) and (State = absDown))) then
      begin
      GradColor := BlendColor(FColorHot, FColor, FStepHover);
      GradColorTo := BlendColor(FColorHotTo, FColorTo, FStepHover);
      GradColorMirror := BlendColor(FColorMirrorHot, FColorMirror, FStepHover);
      GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FColorMirrorTo, FStepHover);
      PenColor := BlendColor(BorderColorHot, BorderColor, FStepHover);
      end
      else
      begin
      if FDown and (State <> absExclusive) then
      begin
      GradColor := BlendColor(FColorDown, FColorHot, FStepPush);
      GradColorTo := BlendColor(FColorDownTo, FColorHotTo, FStepPush);
      GradColorMirror := BlendColor(FColorMirrorDown, FColorMirrorHot, FStepPush);
      GradColorMirrorTo := BlendColor(FColorMirrorDownTo, FColorMirrorHotTo, FStepPush);
      PenColor := BlendColor(BorderColorDown, BorderColorHot, FStepPush);
      end;
      end;
      end; *)

    { if Enabled or (DisabledImages = nil) then
      begin
      ImgList := Images;
      EnabledImg := Enabled;
      end
      else
      begin
      ImgList := DisabledImages;
      EnabledImg := True;
      end;

      if Enabled or DisabledPicture.Empty then
      Pic := Picture
      else
      Pic := DisabledPicture;


      if (ImgList = nil) then
      begin
      ImgList := FInternalImages;
      EnabledImg := True;
      end;

      if ShowCaption then
      DCaption := Caption
      else
      DCaption := '';
      }
    DCaption := TabSheetBrowser[PageIndex].Caption;
    WCaption := TabSheetBrowser[PageIndex].WideCaption;
    { Canvas.Font.Name := 'Tahoma';
      Canvas.Font.Size := 8;
      Canvas.Font.Style := []; }
    Canvas.Font.Assign(TabAppearance.Font);
    Canvas.Font.Color := TxtClr;

    if DoRepaint then
    begin
      Shape := TabSettings.Shape;
      RotateLR := True;
      TabPos := TabPosition;
      if (TabPos in [tpLeft, tpRight]) and not RotateTabLeftRight then
      begin
        TabPos := tpTop;
        RotateLR := False;
        Shape := tsRectangle;
      end;

      if (ActivePageIndex = PageIndex) and (ButtonSettings.CloseButton) then
      begin
        bmp := TBitmap.Create;
        bmp.Height := r.Bottom - r.Top;
        bmp.Width := r.Right - r.Left;
        R3 := Rect(0, 0, r.Right - r.Left, r.Bottom - r.Top);
        if UseOldDrawing then
          DrawVistaGradient
            (bmp.Canvas, Rect(0, 0, r.Right - r.Left, r.Bottom - r.Top),
            GradColor, GradColorTo, GradColorMirror, GradColorMirrorTo,
            PenColor, GradU, GradB, '',
            { Canvas. } Font, Layout, Enabled, False, FAntiAlias, True
            { FCurrentToolBarStyler.RoundEdges } , RotateLR, TabPos)
        else
        begin
          case TabPosition of
            tpTop:
              R3.Bottom := R3.Bottom - 3;
            tpBottom:
              R3.Top := R3.Top + 2;
            tpLeft:
              R3.Right := R3.Right - 3;
            tpRight:
              R3.Left := R3.Left + 2;
          end;

          TempClr := BlendColor(PenColor, clWhite, 50);
          bmp.Canvas.Brush.Color := TempClr;
          bmp.Canvas.FillRect(R3);
          case TabPosition of
            tpTop:
              R3.Right := R3.Right - 1;
            tpBottom:
              begin
                R3.Right := R3.Right - 1;
                R3.Bottom := R3.Bottom - 1;
              end;
            tpLeft:
              R3.Bottom := R3.Bottom - 1;
            tpRight:
              begin
                R3.Right := R3.Right - 1;
                R3.Bottom := R3.Bottom - 2;
              end;
          end;
          DrawVistaTab(bmp.Canvas, R3, GradColor, GradColorTo, GradColorMirror,
            GradColorMirrorTo, PenColor, GradU, GradB, Enabled, Shape, False,
            TabSettings.Rounding, RotateTabLeftRight, TabPosition);
          bmp.TransparentColor := TempClr;
          bmp.Transparent := True;
        end;

        Canvas.Draw(r.Left, r.Top, bmp);
        bmp.Free;
      end
      else
      begin
        if UseOldDrawing then
          DrawVistaGradient(Canvas, r, GradColor, GradColorTo, GradColorMirror,
            GradColorMirrorTo, PenColor, GradU, GradB, '',
            { Canvas. } Font, Layout, Enabled, False, FAntiAlias, True
            { FCurrentToolBarStyler.RoundEdges } , RotateLR, TabPos)
        else
        begin
          R3 := r;
          case TabPosition of
            tpTop:
              R3.Bottom := R3.Bottom - 3;
            tpBottom:
              R3.Top := R3.Top + 2;
            tpLeft:
              R3.Right := R3.Right - 3;
            tpRight:
              R3.Left := R3.Left + 2;
          end;

          DrawVistaTab(Canvas, R3, GradColor, GradColorTo, GradColorMirror,
            GradColorMirrorTo, PenColor, GradU, GradB, Enabled, Shape, False,
            TabSettings.Rounding, RotateTabLeftRight, TabPosition);
        end;

        // DrawVistaButton(Canvas, R,GradColor, GradColorTo, GradColorMirror, GradColorMirrorTo, PenColor,
        // GradU, GradB, DCaption, {Canvas.}Font, nil, -1, True, blGlyphLeft, False, False, Enabled, False, dpRight, aaAntiAlias, True);
      end;

      if UseOldDrawing then
      begin
        case TabPosition of
          tpTop:
            begin
              if True then
              begin
                Canvas.Pixels[r.Left, r.Top] := Canvas.Pixels
                  [r.Left - 1, r.Top - 1];
                Canvas.Pixels[r.Left + 1, r.Top] := Canvas.Pixels
                  [r.Left + 1, r.Top - 1];
                Canvas.Pixels[r.Left, r.Top + 1] := Canvas.Pixels
                  [r.Left - 1, r.Top];

                Canvas.Pixels[r.Right - 1, r.Top] := Canvas.Pixels
                  [r.Right + 1, r.Top];
                Canvas.Pixels[r.Right - 2, r.Top] := Canvas.Pixels
                  [r.Right + 1, r.Top];
                Canvas.Pixels[r.Right - 1, r.Top + 1] := Canvas.Pixels
                  [r.Right + 1, r.Top];
              end;

              // --- Draw 3D effect
              if not Assigned(TabSheetBrowser[PageIndex].FTimer) then
              begin
                if SelectedHot then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                Canvas.MoveTo(r.Left + 3, r.Top + 3);
                Canvas.LineTo(r.Right - 3, r.Top + 3);
              end
              else
              begin
                if (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                begin
                  if SelectedHot then
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                  else
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                end;
                Canvas.MoveTo(r.Left + 3, r.Top + 3);
                Canvas.LineTo(r.Right - 3, r.Top + 3);
              end;

              // -- Draw Shadow
              if (TabAppearance.ShadowColor <> clNone) then
              begin
                Canvas.Pen.Color := TabAppearance.ShadowColor;
                Canvas.MoveTo(r.Right, r.Top + 3);
                Canvas.LineTo(r.Right, r.Bottom - 4);
                Canvas.Pen.Color := BlendColor(TabAppearance.ShadowColor,
                  TabAppearance.BackGround.Color, 40);
                Canvas.MoveTo(r.Right + 1, r.Top + 4);
                Canvas.LineTo(r.Right + 1, r.Bottom - 4);
              end;

              if (HighLightClr <> clNone) then
              begin
                Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
                Canvas.MoveTo(r.Left + 3, r.Top + 1);
                Canvas.LineTo(r.Right - 3, r.Top + 1);
                Canvas.Pen.Color := HighLightClr;
                Canvas.MoveTo(r.Left + 1, r.Top + 3);
                Canvas.LineTo(r.Left + 1, r.Bottom - 5);
                Canvas.MoveTo(r.Right - 2, r.Top + 3);
                Canvas.LineTo(r.Right - 2, r.Bottom - 5);
              end;
            end;
          tpBottom:
            begin
              if True then
              begin
                Canvas.Pixels[r.Left, r.Bottom - 2] := Canvas.Pixels
                  [r.Left - 1, r.Bottom - 1];
                Canvas.Pixels[r.Left + 1, r.Bottom - 1] := Canvas.Pixels
                  [r.Left - 1, r.Bottom - 1];
                Canvas.Pixels[r.Left, r.Bottom - 1] := Canvas.Pixels
                  [r.Left - 1, r.Bottom - 1];

                Canvas.Pixels[r.Right - 1, r.Bottom - 1] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
                Canvas.Pixels[r.Right - 2, r.Bottom - 1] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
                Canvas.Pixels[r.Right - 1, r.Bottom - 2] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
              end;

              // --- Draw 3D effect
              if not Assigned(TabSheetBrowser[PageIndex].FTimer) then
              begin
                if SelectedHot then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                Canvas.MoveTo(r.Left + 3, r.Bottom - 3);
                Canvas.LineTo(r.Right - 3, r.Bottom - 3);
              end
              else
              begin
                if (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                begin
                  if SelectedHot then
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                  else
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                end;
                Canvas.MoveTo(r.Left + 3, r.Bottom - 3);
                Canvas.LineTo(r.Right - 3, r.Bottom - 3);
              end;

              if (TabAppearance.ShadowColor <> clNone) then
              begin
                Canvas.Pen.Color := TabAppearance.ShadowColor;
                Canvas.MoveTo(r.Right, r.Top + 4);
                Canvas.LineTo(r.Right, r.Bottom - 2);
                Canvas.Pen.Color := BlendColor(TabAppearance.ShadowColor,
                  TabAppearance.BackGround.Color, 40);
                Canvas.MoveTo(r.Right + 1, r.Top + 4);
                Canvas.LineTo(r.Right + 1, r.Bottom - 3);
              end;

              if (HighLightClr <> clNone) then
              begin
                Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
                Canvas.MoveTo(r.Left + 3, r.Bottom - 2);
                Canvas.LineTo(r.Right - 3, r.Bottom - 2);
                Canvas.Pen.Color := HighLightClr;
                Canvas.MoveTo(r.Left + 1, r.Bottom - 3);
                Canvas.LineTo(r.Left + 1, r.Top + 5);
                Canvas.MoveTo(r.Right - 2, r.Bottom - 3);
                Canvas.LineTo(r.Right - 2, r.Top + 5);
              end;
            end;
          tpLeft:
            begin
              if True then
              begin
                Canvas.Pixels[r.Left, r.Top] := Canvas.Pixels
                  [r.Left - 1, r.Top - 1];
                Canvas.Pixels[r.Left + 1, r.Top] := Canvas.Pixels
                  [r.Left + 1, r.Top - 1];
                Canvas.Pixels[r.Left, r.Top + 1] := Canvas.Pixels
                  [r.Left - 1, r.Top];

                Canvas.Pixels[r.Left, r.Bottom - 1] := Canvas.Pixels
                  [r.Left - 1, r.Bottom];
                Canvas.Pixels[r.Left + 1, r.Bottom - 1] := Canvas.Pixels
                  [r.Left - 1, r.Bottom];
                Canvas.Pixels[r.Left, r.Bottom - 2] := Canvas.Pixels
                  [r.Left - 1, r.Bottom];
              end;

              // --- Draw 3D effect
              if not Assigned(TabSheetBrowser[PageIndex].FTimer) then
              begin
                if SelectedHot then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);

                if RotateTabLeftRight then
                begin
                  Canvas.MoveTo(r.Left + 3, r.Top + 3);
                  Canvas.LineTo(r.Left + 3, r.Bottom - 3);
                end
                else
                begin
                  Canvas.MoveTo(r.Left + 3, r.Top + 3);
                  Canvas.LineTo(r.Right - 5, r.Top + 3);
                end;
              end
              else
              begin
                if (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                begin
                  if SelectedHot then
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                  else
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                end;

                if RotateTabLeftRight then
                begin
                  Canvas.MoveTo(r.Left + 3, r.Top + 3);
                  Canvas.LineTo(r.Left + 3, r.Bottom - 3);
                end
                else
                begin
                  Canvas.MoveTo(r.Left + 3, r.Top + 3);
                  Canvas.LineTo(r.Right - 5, r.Top + 3);
                end
              end;

              // --- Draw Shadow
              if RotateTabLeftRight then
              begin
                if (TabAppearance.ShadowColor <> clNone) then
                begin
                  Canvas.Pen.Color := TabAppearance.ShadowColor;
                  Canvas.MoveTo(r.Left + 3, r.Top - 1);
                  Canvas.LineTo(r.Right, r.Top - 1);
                  Canvas.Pen.Color := BlendColor(TabAppearance.ShadowColor,
                    TabAppearance.BackGround.Color, 40);
                  Canvas.MoveTo(r.Left + 4, r.Top - 2);
                  Canvas.LineTo(r.Right, r.Top - 2);
                end;
              end
              else
              begin
                if (TabAppearance.ShadowColor <> clNone) then
                begin
                  Canvas.Pen.Color := TabAppearance.ShadowColor;
                  Canvas.MoveTo(r.Left + 3, r.Bottom);
                  Canvas.LineTo(r.Right, r.Bottom);
                  Canvas.Pen.Color := BlendColor(TabAppearance.ShadowColor,
                    TabAppearance.BackGround.Color, 40);
                  Canvas.MoveTo(r.Left + 4, r.Bottom + 1);
                  Canvas.LineTo(r.Right, r.Bottom + 1);
                end;
              end;

              if (HighLightClr <> clNone) then
              begin
                Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
                Canvas.MoveTo(r.Left + 1, r.Top + 3);
                Canvas.LineTo(r.Left + 1, r.Bottom - 3);
                Canvas.Pen.Color := HighLightClr;
                Canvas.MoveTo(r.Left + 3, r.Top + 1);
                Canvas.LineTo(r.Right - 5, r.Top + 1);
                Canvas.MoveTo(r.Left + 3, r.Bottom - 2);
                Canvas.LineTo(r.Right - 5, r.Bottom - 2);
              end;
            end;
          tpRight:
            begin
              if True then
              begin
                Canvas.Pixels[r.Right, r.Top] := Canvas.Pixels
                  [r.Right + 1, r.Top - 1];
                Canvas.Pixels[r.Right - 1, r.Top] := Canvas.Pixels
                  [r.Right + 1, r.Top - 1];
                Canvas.Pixels[r.Right, r.Top + 1] := Canvas.Pixels
                  [r.Right + 1, r.Top];

                Canvas.Pixels[r.Right, r.Bottom - 1] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
                Canvas.Pixels[r.Right - 1, r.Bottom - 1] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
                Canvas.Pixels[r.Right, r.Bottom - 2] := Canvas.Pixels
                  [r.Right + 1, r.Bottom];
              end;

              // --- Draw 3D effect
              if not Assigned(TabSheetBrowser[PageIndex].FTimer) then
              begin
                if SelectedHot then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);

                if RotateTabLeftRight then
                begin
                  Canvas.MoveTo(r.Right - 3, r.Top + 3);
                  Canvas.LineTo(r.Right - 3, r.Bottom - 3);
                end
                else
                begin
                  Canvas.MoveTo(r.Left + 5, r.Top + 3);
                  Canvas.LineTo(r.Right - 3, r.Top + 3);
                end;
              end
              else
              begin
                if (TabSheetBrowser[PageIndex].FGlowState = gsHover) then
                  Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                else
                begin
                  if SelectedHot then
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 20)
                  else
                    Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
                end;

                if RotateTabLeftRight then
                begin
                  Canvas.MoveTo(r.Right - 3, r.Top + 3);
                  Canvas.LineTo(r.Right - 3, r.Bottom - 3);
                end
                else
                begin
                  Canvas.MoveTo(r.Left + 5, r.Top + 3);
                  Canvas.LineTo(r.Right - 3, r.Top + 3);
                end;
              end;

              // -- Draw Shadow
              if (TabAppearance.ShadowColor <> clNone) then
              begin
                Canvas.Pen.Color := TabAppearance.ShadowColor;
                Canvas.MoveTo(r.Left + 3, r.Bottom);
                Canvas.LineTo(r.Right - 3, r.Bottom);
                Canvas.Pen.Color := BlendColor(TabAppearance.ShadowColor,
                  TabAppearance.BackGround.Color, 40);
                Canvas.MoveTo(r.Left + 4, r.Bottom + 1);
                Canvas.LineTo(r.Right - 4, r.Bottom + 1);
              end;

              if (HighLightClr <> clNone) then
              begin
                Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
                Canvas.MoveTo(r.Right - 2, r.Top + 3);
                Canvas.LineTo(r.Right - 2, r.Bottom - 3);
                Canvas.Pen.Color := HighLightClr;
                Canvas.MoveTo(r.Left + 5, r.Top + 1);
                Canvas.LineTo(r.Right - 3, r.Top + 1);
                Canvas.MoveTo(r.Left + 5, r.Bottom - 2);
                Canvas.LineTo(r.Right - 3, r.Bottom - 2);
              end;
            end;
        end;
      end;
    end;

    if TabSheetBrowser[PageIndex].ShowCheckBox then
    begin
      DChecked := 0;
      if TabSheetBrowser[PageIndex].Checked then
      begin
        DChecked := DFCS_BUTTONCHECK or DFCS_CHECKED;

        if not TabSheetBrowser[PageIndex].Enabled then
          DChecked := DChecked or DFCS_INACTIVE;
      end;

      rc := GetCheckBoxRect(PageIndex);

      DrawFrameControl(Canvas.Handle, rc, DFC_BUTTON, DChecked);
    end;

    if Assigned(FOnDrawTab) then
    begin
      FOnDrawTab(Self, PageIndex, r);
      Exit;
    end;

    if not UseOldDrawing then
    begin
      if TabPosition in [tpTop, tpBottom] then
      begin
        r.Left := r.Left + GetLeftRoundingOffset;
      end
      else if RotateTabLeftRight then
      begin
        if TabPosition = tpLeft then
          r.Bottom := r.Bottom - GetLeftRoundingOffset
        else
        begin
          if TabSettings.Shape in [tsLeftRamp, tsLeftRightRamp] then
            r.Top := r.Top + GetLeftRoundingOffset;
        end;
      end;
    end;

    if (TabSettings.Width > 0) then
      GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ImgP);

    case TabPosition of
      tpTop, tpBottom:
        begin
          CapR := Rect(r.Left + FTabSettings.LeftMargin, r.Top, r.Right,
            r.Bottom);

          if not ShowCloseOnNonSelectedTabs then
          begin
            if (ButtonSettings.CloseButton and (ActivePageIndex <> PageIndex)
                and TabSheetBrowser[PageIndex].ShowClose) then
              CapR.Left := CapR.Left + (PAGEBUTTON_SIZE + 4) div 2
            else if (ButtonSettings.CloseButton and
                (ActivePageIndex = PageIndex) and TabSheetBrowser[PageIndex]
                .ShowClose) and (CloseOnTabPosition = cpLeft) and
              (TabSettings.Alignment <> taCenter) then
              CapR.Left := CapR.Left + PAGEBUTTON_SIZE + 4;
          end
          else
          begin
            if (ButtonSettings.CloseButton and TabSheetBrowser[PageIndex]
                .ShowClose) and (CloseOnTabPosition = cpLeft) and
              (TabSettings.Alignment <> taCenter) then
              CapR.Left := CapR.Left + PAGEBUTTON_SIZE + 4;
          end;

          if TabSheetBrowser[PageIndex].ShowCheckBox then
            CapR.Left := CapR.Left + 20;
        end;
      tpLeft:
        begin
          if RotateTabLeftRight then
          begin
            CapR := Rect(r.Left, r.Top, r.Right,
              r.Bottom - FTabSettings.LeftMargin);
            if not ShowCloseOnNonSelectedTabs then
            begin
              if (ButtonSettings.CloseButton and (ActivePageIndex <> PageIndex)
                  and TabSheetBrowser[PageIndex].ShowClose) then
                CapR.Bottom := CapR.Bottom - (PAGEBUTTON_SIZE + 4) div 2
              else if (ButtonSettings.CloseButton and
                  (ActivePageIndex = PageIndex) and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Bottom := CapR.Bottom - PAGEBUTTON_SIZE - 4;
            end
            else
            begin
              if (ButtonSettings.CloseButton and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Bottom := CapR.Bottom - PAGEBUTTON_SIZE - 4;
            end;

            if TabSheetBrowser[PageIndex].ShowCheckBox then
              CapR.Bottom := CapR.Bottom - 25;
          end
          else
          begin
            CapR := Rect(r.Left + FTabSettings.LeftMargin, r.Top, r.Right,
              r.Bottom);
            if not ShowCloseOnNonSelectedTabs then
            begin
              if (ButtonSettings.CloseButton and (ActivePageIndex = PageIndex)
                  and TabSheetBrowser[PageIndex].ShowClose) and
                (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Left := CapR.Left + PAGEBUTTON_SIZE + 4
              else if (ButtonSettings.CloseButton and
                  (ActivePageIndex = PageIndex) and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpRight) and
                ((TabSettings.Width <= 0) or (TabSettings.Alignment <> taCenter)
                ) then
                CapR.Right := CapR.Right - (PAGEBUTTON_SIZE + 4);
            end
            else
            begin
              if (ButtonSettings.CloseButton and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpRight) and
                ((TabSettings.Width <= 0) or (TabSettings.Alignment <> taCenter)
                ) then
                CapR.Right := CapR.Right - (PAGEBUTTON_SIZE + 4);
            end;

            if TabSheetBrowser[PageIndex].ShowCheckBox then
              CapR.Left := CapR.Left + 20;
          end;
        end;
      tpRight:
        begin
          if RotateTabLeftRight then
          begin
            CapR := Rect(r.Left, r.Top + FTabSettings.LeftMargin, r.Right,
              r.Bottom);
            if not ShowCloseOnNonSelectedTabs then
            begin
              if (ButtonSettings.CloseButton and (ActivePageIndex <> PageIndex)
                  and TabSheetBrowser[PageIndex].ShowClose) then
                CapR.Top := CapR.Top + (PAGEBUTTON_SIZE + 4) div 2
              else if (ButtonSettings.CloseButton and
                  (ActivePageIndex = PageIndex) and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Top := CapR.Top + PAGEBUTTON_SIZE + 4;
            end
            else
            begin
              if (ButtonSettings.CloseButton and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Top := CapR.Top + PAGEBUTTON_SIZE + 4;
            end;

            if TabSheetBrowser[PageIndex].ShowCheckBox then
              CapR.Top := CapR.Top + 20;
          end
          else
          begin
            CapR := Rect(r.Left + FTabSettings.LeftMargin + 3, r.Top, r.Right,
              r.Bottom);
            // if (ButtonSettings.CloseButton and CloseOnTab and (ActivePageIndex <> PageIndex)) then
            // CapR.Top := CapR.Top + (PAGEBUTTON_SIZE+3) div 2;
            if not ShowCloseOnNonSelectedTabs then
            begin
              if (ButtonSettings.CloseButton and (ActivePageIndex = PageIndex)
                  and TabSheetBrowser[PageIndex].ShowClose) and
                (CloseOnTabPosition = cpLeft) and
                (TabSettings.Alignment <> taCenter) then
                CapR.Left := CapR.Left + PAGEBUTTON_SIZE + 5
              else if (ButtonSettings.CloseButton and
                  (ActivePageIndex = PageIndex) and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpRight) and
                ((TabSettings.Width <= 0) or (TabSettings.Alignment <> taCenter)
                ) then
                CapR.Right := CapR.Right - (PAGEBUTTON_SIZE + 4);
            end
            else
            begin
              if (ButtonSettings.CloseButton and TabSheetBrowser[PageIndex]
                  .ShowClose) and (CloseOnTabPosition = cpRight) and
                ((TabSettings.Width <= 0) or (TabSettings.Alignment <> taCenter)
                ) then
                CapR.Right := CapR.Right - (PAGEBUTTON_SIZE + 4);
            end;

            if TabSheetBrowser[PageIndex].ShowCheckBox then
              CapR.Left := CapR.Left + 20;
          end;
        end;
    end;

    if TabSheetBrowser[PageIndex].Enabled or TabSheetBrowser[PageIndex]
      .DisabledPicture.Bitmap.Empty then
      Pic := TabSheetBrowser[PageIndex].Picture
    else
      Pic := TabSheetBrowser[PageIndex].DisabledPicture;

    if Assigned(Pic) and not Pic.Bitmap.Empty then
    begin
      ImgW := Pic.Width;
      ImgH := Pic.Height;

      ImgY := CapR.Top;
      ImgX := CapR.Left;
      case TabPosition of
        tpTop, tpBottom:
          begin
            case TabSettings.ImagePosition of
              ipTop:
                begin
                  ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                  ImgY := CapR.Top + TabSettings.StartMargin;
                  CapR.Top := CapR.Top + ImgH { + ImgTxtSp } ;
                end;
              ipBottom:
                begin
                  ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                  ImgY := CapR.Bottom - ImgH - TabSettings.StartMargin;
                  CapR.Bottom := CapR.Bottom - ImgH;
                end;
              ipLeft:
                begin
                  if (TabSettings.Width > 0) and
                    (TabSettings.Alignment = taCenter) then
                    ImgX := ImgP.X
                  else
                    ImgX := CapR.Left + 2;
                  CapR.Left := CapR.Left + ImgW + ImgTxtSp;

                  ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                end;
              ipRight:
                begin
                  if (TabSettings.Width > 0) and
                    (TabSettings.Alignment = taCenter) then
                    ImgX := ImgP.X
                  else
                    ImgX := CapR.Right - ImgW - FTabSettings.RightMargin;
                  CapR.Right := ImgX - ImgTxtSp;
                  if (ButtonSettings.CloseButton and
                      ((ActivePageIndex = PageIndex)
                        or ShowCloseOnNonSelectedTabs) and TabSheetBrowser
                      [PageIndex].ShowClose) and (CloseOnTabPosition = cpRight)
                    and not((TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter)) then
                    ImgX := ImgX - PAGEBUTTON_SIZE;

                  if TabSheetBrowser[PageIndex].ShowCheckBox then
                    ImgX := ImgX - 25;

                  ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                end;
            end;
          end;
        tpLeft:
          begin
            if not RotateTabLeftRight then
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    ImgY := CapR.Top;
                    CapR.Top := CapR.Top + ImgH;
                  end;
                ipBottom:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    ImgY := CapR.Bottom - ImgH;
                    CapR.Bottom := CapR.Bottom - ImgH;
                  end;
                ipLeft:
                  begin
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgX := ImgP.X
                    else
                      ImgX := CapR.Left;
                    CapR.Left := CapR.Left + ImgW + ImgTxtSp;
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                  end;
                ipRight:
                  begin
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgX := ImgP.X
                    else
                      ImgX := CapR.Right - ImgW - FTabSettings.RightMargin;
                    CapR.Right := ImgX - ImgTxtSp;
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                  end;
              end;
            end
            else
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  begin
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                    ImgX := CapR.Left;
                    CapR.Left := CapR.Left + ImgW;
                  end;
                ipBottom:
                  begin
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                    ImgX := CapR.Right - ImgW;
                    CapR.Right := CapR.Right - ImgW;
                  end;
                ipLeft:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgY := ImgP.Y
                    else
                      ImgY := CapR.Bottom - ImgH;
                    CapR.Bottom := ImgY - ImgTxtSp;
                  end;
                ipRight:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgY := ImgP.Y
                    else
                      ImgY := CapR.Top + TabSettings.RightMargin;
                    CapR.Top := ImgY + ImgTxtSp;
                  end;
              end;
            end;
          end;
        tpRight:
          begin
            if not RotateTabLeftRight then
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    ImgY := CapR.Top;
                    CapR.Top := CapR.Top + ImgH;
                  end;
                ipBottom:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    ImgY := CapR.Bottom - ImgH;
                    CapR.Bottom := CapR.Bottom - ImgH;
                  end;
                ipLeft:
                  begin
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgX := ImgP.X
                    else
                      ImgX := CapR.Left;
                    CapR.Left := CapR.Left + ImgW + ImgTxtSp;
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                  end;
                ipRight:
                  begin
                    ImgX := CapR.Right - ImgW;
                    CapR.Right := ImgX - ImgTxtSp;
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                  end;
              end;
            end
            else
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  begin
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                    ImgX := CapR.Right - ImgW;
                    CapR.Right := CapR.Right - ImgW;
                  end;
                ipBottom:
                  begin
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgH) div 2;
                    ImgX := CapR.Left;
                    CapR.Left := CapR.Left + ImgW;
                  end;
                ipLeft:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgY := ImgP.Y
                    else
                      ImgY := CapR.Top;
                    CapR.Top := CapR.Top + ImgH + ImgTxtSp;
                  end;
                ipRight:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgW) div 2;
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgY := ImgP.Y
                    else
                      ImgY := CapR.Bottom - ImgH - TabSettings.RightMargin;
                    CapR.Bottom := ImgY - ImgTxtSp;
                  end;
              end;
            end;
          end;
      end;
      // Canvas.Draw(ImgX, ImgY, Pic);
    end
    else if (Assigned(FImages) or Assigned(DisabledImages)) and
      (TabSheetBrowser[PageIndex].ImageIndex >= 0) then
    begin

      if TabSheetBrowser[PageIndex].Enabled then
      begin
        if Assigned(FImages) then
          ImgList := FImages;

        ImgEnabled := TabSheetBrowser[PageIndex].TabEnabled;
      end
      else
      begin
        if Assigned(FDisabledImages) then
          ImgList := FDisabledImages
        else if Assigned(FImages) then
        begin
          ImgList := FImages;
          ImgEnabled := False;
        end;
      end;

      if (ImgList <> nil) then
      begin
        ImgY := CapR.Top;
        ImgX := CapR.Left;

        case TabPosition of
          tpTop, tpBottom:
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width) div 2;
                    ImgY := CapR.Top + TabSettings.StartMargin;
                    CapR.Top := CapR.Top + ImgList.Height { + ImgTxtSp } ;
                  end;
                ipBottom:
                  begin
                    ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width) div 2;
                    ImgY := CapR.Bottom - ImgList.Height -
                      TabSettings.StartMargin;
                    CapR.Bottom := CapR.Bottom - ImgList.Height;
                  end;
                ipLeft:
                  begin
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgX := ImgP.X
                    else
                      ImgX := CapR.Left;
                    CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height) div 2;
                  end;
                ipRight:
                  begin
                    if (TabSettings.Width > 0) and
                      (TabSettings.Alignment = taCenter) then
                      ImgX := ImgP.X
                    else
                      ImgX := CapR.Right - ImgList.Width -
                        FTabSettings.RightMargin;
                    CapR.Right := ImgX - ImgTxtSp;
                    if (ButtonSettings.CloseButton and
                        ((ActivePageIndex = PageIndex)
                          or ShowCloseOnNonSelectedTabs) and TabSheetBrowser
                        [PageIndex].ShowClose) and
                      (CloseOnTabPosition = cpRight) and not
                      ((TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter)) then
                      ImgX := ImgX - PAGEBUTTON_SIZE;

                    if TabSheetBrowser[PageIndex].ShowCheckBox then
                      ImgX := ImgX - 25;

                    ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height) div 2;
                  end;
              end;
            end;
          tpLeft:
            begin
              if not RotateTabLeftRight then
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      ImgY := CapR.Top;
                      CapR.Top := CapR.Top + ImgList.Height { + ImgTxtSp } ;
                    end;
                  ipBottom:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      ImgY := CapR.Bottom - ImgList.Height;
                      CapR.Bottom := CapR.Bottom - ImgList.Height;
                    end;
                  ipLeft:
                    begin
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgX := ImgP.X
                      else
                        ImgX := CapR.Left + 2;
                      CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                    end;
                  ipRight:
                    begin
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgX := ImgP.X
                      else
                        ImgX := CapR.Right - ImgList.Width -
                          FTabSettings.RightMargin;
                      CapR.Right := ImgX - ImgTxtSp;
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                    end;
                end;
              end
              else
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    begin
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                      ImgX := CapR.Left;
                      CapR.Left := CapR.Left + ImgList.Width;
                    end;
                  ipBottom:
                    begin
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                      ImgX := CapR.Right - ImgList.Width;
                      CapR.Right := CapR.Right - ImgList.Width;
                    end;
                  ipLeft:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgY := ImgP.Y
                      else
                        ImgY := CapR.Bottom - ImgList.Height;
                      CapR.Bottom := ImgY - ImgTxtSp;
                    end;
                  ipRight:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgY := ImgP.Y
                      else
                        ImgY := CapR.Top + TabSettings.RightMargin;
                      CapR.Top := ImgY + ImgTxtSp;
                    end;
                end;
              end;
            end;
          tpRight:
            begin
              if not RotateTabLeftRight then
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      ImgY := CapR.Top;
                      CapR.Top := CapR.Top + ImgList.Height;
                    end;
                  ipBottom:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      ImgY := CapR.Bottom - ImgList.Height;
                      CapR.Bottom := CapR.Bottom - ImgList.Height;
                    end;
                  ipLeft:
                    begin
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgX := ImgP.X
                      else
                        ImgX := CapR.Left;
                      CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                    end;
                  ipRight:
                    begin
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgX := ImgP.X
                      else
                        ImgX := CapR.Right - ImgList.Width;
                      CapR.Right := ImgX - ImgTxtSp;
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                    end;
                end;
              end
              else
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    begin
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                      ImgX := CapR.Right - ImgList.Width;
                      CapR.Right := CapR.Right - ImgList.Width;
                    end;
                  ipBottom:
                    begin
                      ImgY := r.Top + ((r.Bottom - r.Top) - ImgList.Height)
                        div 2;
                      ImgX := CapR.Left;
                      CapR.Left := CapR.Left + ImgList.Width;
                    end;
                  ipLeft:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgY := ImgP.Y
                      else
                        ImgY := CapR.Top;
                      CapR.Top := CapR.Top + ImgList.Height + ImgTxtSp;
                    end;
                  ipRight:
                    begin
                      ImgX := r.Left + ((r.Right - r.Left) - ImgList.Width)
                        div 2;
                      if (TabSettings.Width > 0) and
                        (TabSettings.Alignment = taCenter) then
                        ImgY := ImgP.Y
                      else
                        ImgY := CapR.Bottom - ImgList.Height -
                          TabSettings.RightMargin;
                      CapR.Bottom := ImgY - ImgTxtSp;
                    end;
                end;
              end;
            end;
        end;

        ImgList.Draw(Canvas, ImgX, ImgY, TabSheetBrowser[PageIndex].ImageIndex,
          ImgEnabled);
        ImgList := nil;
      end;

    end;

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := TxtClr;
    if (not RotateTabLeftRight and (TabPosition in [tpLeft, tpRight])) then
    begin
      CapR2 := CapR;
      AAlign := taLeftJustify;
      if (TabSettings.Width <> 0) then
      begin
        case TabSettings.Alignment of
          taLeftJustify:
            begin
              AAlign := taLeftJustify;
            end;
          taCenter:
            begin
              AAlign := taCenter;
              // CapR2.Left := TR.Left;
            end;
          taRightJustify:
            begin
              AAlign := taRightJustify;
              CapR2.Right := CapR.Right - 3;
            end;
        end;
      end
      else
      begin
        if TabSettings.ImagePosition in [ipTop, ipBottom] then
        begin
          AAlign := taCenter;
          if (TabPosition = tpLeft) then
          begin
            CapR2.Left := CapR2.Left - FTabSettings.LeftMargin;
            CapR2.Right := CapR2.Right - 3;
          end;
        end
        else
          AAlign := taLeftJustify;
      end;

      TxtR := DrawVistaText(Canvas, AAlign, CapR2, DCaption, WCaption,
        Canvas.Font, TabSheetBrowser[PageIndex].Enabled, True, FAntiAlias,
        tpTop, Ellipsis, TabSettings.WordWrap);
    end
    else if (TabPosition = tpLeft) then
    begin
      if (DCaption <> '') or (WCaption <> '') then
      begin
        CapR2 := CapR;
        TxtR.Left := CapR.Left + ((CapR.Right - CapR.Left) - Canvas.TextHeight
            ('gh')) div 2;
        if (TabSettings.Width <> 0) then
        begin
          case TabSettings.Alignment of
            taCenter:
              CapR2.Bottom := TR.Bottom;
            taRightJustify:
              CapR2.Bottom := TR.Bottom;
          end;
        end;

        TxtR.Top := CapR.Bottom;
        TxtR.Right := TxtR.Left + Canvas.TextHeight('gh');
        if (DCaption <> '') then
          TxtR.Bottom := TxtR.Top + Canvas.TextWidth(DCaption)
        else
          TxtR.Bottom := TxtR.Top + WideCanvasTextWidth(Canvas, WCaption);

        // Make sure to use a truetype font!
        // Font.Name := 'Tahoma';

        tf := TFont.Create;
        try
          if (TabPosition = tpLeft) or (TabPosition = tpRight) then
          begin
{$IFNDEF TMSDOTNET}
            FillChar(lf, SizeOf(lf), 0);
{$ENDIF}
            tf.Assign(Canvas.Font);
{$IFNDEF TMSDOTNET}
            GetObject(tf.Handle, SizeOf(lf), @lf);
{$ENDIF}
{$IFDEF TMSDOTNET}
            GetObject(tf.Handle, Marshal.SizeOf(TypeOf(lf)), lf);
{$ENDIF}
            if TabPosition = tpLeft then
              lf.lfEscapement := -2700
            else
              lf.lfEscapement := -900;
            lf.lfOrientation := 30;

            tf.Handle := CreateFontIndirect(lf);
            Canvas.Font.Assign(tf);
          end;
        finally
          tf.Free;
        end;
        if (DCaption <> '') then
        begin
          DCaption := TrimText(DCaption, CapR, False, nil, Canvas, nil, nil,
            Ellipsis, TabPosition, TabSettings.WordWrap);
          Canvas.TextOut(CapR.Left + ((CapR.Right - CapR.Left)
                - Canvas.TextHeight('gh')) div 2, CapR2.Bottom, DCaption);
        end
        else
        begin
          WCaption := TrimTextW(WCaption, CapR, False, nil, Canvas, nil, nil,
            Ellipsis, TabPosition, TabSettings.WordWrap);
          TextOutW(Canvas.Handle, CapR.Left + ((CapR.Right - CapR.Left)
                - Canvas.TextHeight('gh')) div 2, CapR2.Bottom, PWideChar
              (WCaption), Length(WCaption));
        end;
      end;
    end
    else if (TabPosition = tpRight) and
      ((AntiAlias = aaNone) or (TabSettings.Width > 0)) then
    begin
      if (DCaption <> '') or (WCaption <> '') then
      begin
        CapR2 := CapR;
        TxtR.Left := CapR.Left + ((CapR.Right - CapR.Left) - Canvas.TextHeight
            ('gh')) div 2;
        if (TabSettings.Width <> 0) then
        begin
          case TabSettings.Alignment of
            taCenter:
              CapR2.Top := TR.Top;
            taRightJustify:
              CapR2.Top := TR.Top;
          end;
        end;

        TxtR.Top := CapR.Bottom;
        TxtR.Right := TxtR.Left + Canvas.TextHeight('gh');
        if (DCaption <> '') then
          TxtR.Bottom := TxtR.Top + Canvas.TextWidth(DCaption)
        else
          TxtR.Bottom := TxtR.Top + WideCanvasTextWidth(Canvas, WCaption);

        // Make sure to use a truetype font!
        // Font.Name := 'Tahoma';

        tf := TFont.Create;
        try
          if (TabPosition = tpLeft) or (TabPosition = tpRight) then
          begin
{$IFNDEF TMSDOTNET}
            FillChar(lf, SizeOf(lf), 0);
{$ENDIF}
            tf.Assign(Canvas.Font);
{$IFNDEF TMSDOTNET}
            GetObject(tf.Handle, SizeOf(lf), @lf);
{$ENDIF}
{$IFDEF TMSDOTNET}
            GetObject(tf.Handle, Marshal.SizeOf(TypeOf(lf)), lf);
{$ENDIF}
            if TabPosition = tpLeft then
              lf.lfEscapement := -900
            else
              lf.lfEscapement := -900;
            lf.lfOrientation := 30;

            tf.Handle := CreateFontIndirect(lf);
            Canvas.Font.Assign(tf);
          end;
        finally
          tf.Free;
        end;

        if (DCaption <> '') then
        begin
          DCaption := TrimText(DCaption, CapR, False, nil, Canvas, nil, nil,
            Ellipsis, TabPosition, TabSettings.WordWrap);
          Canvas.TextOut(CapR.Right - ((CapR.Right - CapR.Left)
                - Canvas.TextHeight('gh')) div 2, CapR2.Top, DCaption);
        end
        else
        begin
          WCaption := TrimTextW(WCaption, CapR, False, nil, Canvas, nil, nil,
            Ellipsis, TabPosition, TabSettings.WordWrap);
          TextOutW(Canvas.Handle, CapR.Right - ((CapR.Right - CapR.Left)
                - Canvas.TextHeight('gh')) div 2, CapR2.Top, PWideChar(WCaption)
              , Length(WCaption));
        end;
      end;
    end
    else
    begin
      CapR2 := CapR;

      AAlign := taLeftJustify;

      if (TabSettings.Width <> 0) then
      begin
        case TabSettings.Alignment of
          taLeftJustify:
            begin
              AAlign := taLeftJustify;
            end;
          taCenter:
            begin
              AAlign := taLeftJustify;
              CapR2.Left := TR.Left;
            end;
          taRightJustify:
            begin
              AAlign := taRightJustify;
              // CapR2.Right := CapR2.Right - 3;
              if (TabSettings.Shape in [tsRightRamp, tsLeftRightRamp]) then
                CapR2.Right := CapR2.Right - GetRightRoundingOffset;
            end;
        end;
      end
      else
      begin
        if TabSettings.ImagePosition in [ipTop, ipBottom] then
        begin
          AAlign := taCenter;
        end
        else
        begin
          AAlign := taLeftJustify;
          CapR2.Right := CapR2.Right + 10;
        end;
      end;

      if (TabSettings.Width <> 0) and ((PageIndex = ActivePageIndex)
          or ShowCloseOnNonSelectedTabs) and TabSheetBrowser[PageIndex]
        .ShowClose then
      begin
        if CloseOnTabPosition = cpRight then
          CapR2.Right := CapR2.Right - PAGEBUTTON_SIZE - 4;
      end;

      if (DCaption <> '') then
        DCaption := TrimText(DCaption, CapR2, False, nil, Canvas, nil, nil,
          Ellipsis, TabPosition, TabSettings.WordWrap)
      else
        WCaption := TrimTextW(WCaption, CapR2, False, nil, Canvas, nil, nil,
          Ellipsis, TabPosition, TabSettings.WordWrap);

      TxtR := DrawVistaText(Canvas, AAlign, CapR2, DCaption, WCaption,
        Canvas.Font, TabSheetBrowser[PageIndex].Enabled, True, FAntiAlias,
        TabPosition, Ellipsis, TabSettings.WordWrap);
      // DrawText(Canvas.Handle, PChar(DCaption), Length(DCaption), R, DT_SINGLELINE or DT_VCENTER);
    end;

    if Assigned(Pic) and not Pic.Bitmap.Empty then
    begin
      case TabPosition of
        tpTop, tpBottom:
          begin
            case TabSettings.ImagePosition of
              ipTop:
                ImgY := Max(TxtR.Top - ImgH - ImgTxtSp, 4);
              ipBottom:
                ImgY := Min(TxtR.Bottom + ImgTxtSp, CapR.Bottom);
            end;
          end;
        tpLeft:
          begin
            if not RotateTabLeftRight then
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  ImgY := Max(TxtR.Top - ImgH - ImgTxtSp, 4);
                ipBottom:
                  ImgY := Max(TxtR.Bottom + ImgTxtSp, 4);
                ipRight:
                  ImgX := TxtR.Right + ImgTxtSp * 2;
              end;
            end
            else
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  ImgX := Max(TxtR.Left - ImgW - ImgTxtSp, 4);
                ipBottom:
                  ImgX := Max(TxtR.Right + ImgTxtSp, 4);
              end;
            end;
          end;
        tpRight:
          begin
            if not RotateTabLeftRight then
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  ImgY := Max(TxtR.Top - ImgH - ImgTxtSp, 4);
                ipBottom:
                  ImgY := Max(TxtR.Bottom + ImgTxtSp, 4);
                ipRight:
                  ImgX := TxtR.Right + ImgTxtSp * 2;
              end;
            end
            else
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  ImgX := Max(TxtR.Right + ImgTxtSp, 4);
                ipBottom:
                  ImgX := Max(TxtR.Left - ImgW - ImgTxtSp, 4);
              end;
            end;
          end;
      end;

      Canvas.Draw(ImgX, ImgY, Pic.Bitmap);
    end
    else if (Assigned(FImages) or Assigned(DisabledImages)) and
      (TabSheetBrowser[PageIndex].ImageIndex >= 0) then
    begin
      if (ImgList <> nil) then
      begin
        case TabPosition of
          tpTop, tpBottom:
            begin
              case TabSettings.ImagePosition of
                ipTop:
                  ImgY := Max(TxtR.Top - ImgList.Height - ImgTxtSp, 4);
                ipBottom:
                  ImgY := Min(TxtR.Bottom + ImgTxtSp, CapR.Bottom);
              end;
            end;
          tpLeft:
            begin
              if not RotateTabLeftRight then
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    ImgY := Max(TxtR.Top - ImgList.Height - ImgTxtSp, 4);
                  ipBottom:
                    ImgY := Max(TxtR.Bottom + ImgTxtSp, 4);
                  ipRight:
                    ImgX := TxtR.Right + ImgTxtSp * 2;
                end;
              end
              else
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    ImgX := Max(TxtR.Left - ImgList.Width - ImgTxtSp, 4);
                  ipBottom:
                    ImgX := Max(TxtR.Right + ImgTxtSp, 4);
                end;
              end;
            end;
          tpRight:
            begin
              if not RotateTabLeftRight then
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    ImgY := Max(TxtR.Top - ImgList.Height - ImgTxtSp, 4);
                  ipBottom:
                    ImgY := Max(TxtR.Bottom + ImgTxtSp, 4);
                  ipRight:
                    ImgX := TxtR.Right + ImgTxtSp * 2;
                end;
              end
              else
              begin
                case TabSettings.ImagePosition of
                  ipTop:
                    ImgX := Max(TxtR.Right + ImgTxtSp, 4);
                  ipBottom:
                    ImgX := Max(TxtR.Left - ImgList.Width - ImgTxtSp, 4);
                end;
              end;
            end;
        end;

        ImgList.Draw(Canvas, ImgX, ImgY, TabSheetBrowser[PageIndex].ImageIndex,
          True);
      end;
    end;

    { Canvas.Pen.Color := clBlack;
      Canvas.Brush.Style := bsClear;
      Canvas.Rectangle(R); }

    if (PageIndex <> ActivePageIndex) and
      (IsActivePageNeighbour(PageIndex) <> 0) then
      DrawTab(ActivePageIndex);

    if not Assigned(Parent) then
      Exit;
    {
      R := ClientRect;
      rgn1 := CreateRectRgn(0, 0, 1, 1);
      rgn2 := CreateRectRgn(R.Right-1, 0, R.Right, 1);
      CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
      DeleteObject(rgn2);
      rgn2 := CreateRectRgn(0, R.Bottom - 1, 1, R.Bottom);
      CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
      DeleteObject(rgn2);
      rgn2 := CreateRectRgn(R.Right - 1, R.Bottom - 1, R.Right, R.Bottom);
      CombineRgn(rgn1, rgn1, rgn2, RGN_OR);

      SelectClipRgn(Canvas.Handle, rgn1);

      i := SaveDC(Canvas.Handle);
      p := ClientOrigin;
      Windows.ScreenToClient(Parent.Handle, p);
      p.x := -p.x;
      p.y := -p.y;
      MoveWindowOrg(Canvas.Handle, p.x, p.y);
      //SendMessage(Parent.Handle, WM_ERASEBKGND, Canvas.Handle, 0);
      SendMessage(Parent.Handle, WM_PAINT, Canvas.Handle, 0);
      if (Parent is TWinCtrl) then
      (Parent as TWinCtrl).PaintCtrls(Canvas.Handle, nil);
      RestoreDC(Canvas.Handle, i);

      SelectClipRgn(Canvas.Handle, 0);
      DeleteObject(rgn1);
      DeleteObject(rgn2); }
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.DrawAllTabs;

var
  i: Integer;
  r: TRect;
begin
  // Draw TabBackGround

  r := GetTabsArea;

  case TabPosition of
    tpTop:
      r.Bottom := ClientRect.Bottom;
    tpBottom:
      r.Top := ClientRect.Top;
    tpLeft:
      r.Right := ClientRect.Right;
    tpRight:
      r.Left := ClientRect.Left;
  end;

  if not FTransparent then
  begin
    with FPageBrowserStyler.TabAppearance do
    begin
      if (BackGround.Color <> clNone) and (BackGround.ColorTo <> clNone) then
        DrawGradient(Canvas, BackGround.Color, BackGround.ColorTo,
          BackGround.Steps, r, BackGround.Direction = gdHorizontal)
      else if (BackGround.Color <> clNone) then
      begin
        Canvas.Brush.Color := BackGround.Color;
        Canvas.Pen.Color := BackGround.Color;
        Canvas.Rectangle(r.Left, r.Top, r.Right, r.Bottom);
      end;
    end;
  end;

  for i := 0 to FPages.Count - 1 do
    DrawTab(i);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.Paint;

var
  r: TRect;
  p: TPoint;
  DC: Integer;
begin
  r := ClientRect;
  if FTransparent then
  begin
    DC := SaveDC(Canvas.Handle);
    p := ClientOrigin;
    Windows.ScreenToClient(Parent.Handle, p);
    p.X := -p.X;
    p.Y := -p.Y;
    MoveWindowOrg(Canvas.Handle, p.X, p.Y);
    SendMessage(Parent.Handle, WM_ERASEBKGND, Canvas.Handle, 0);
    // transparency ?
    SendMessage(Parent.Handle, WM_PAINT, Canvas.Handle, 0);
    // if (Parent is TWinControl) then
    // (Parent as TWinControl).PaintCtrls(Canvas.Handle, nil);
    RestoreDC(Canvas.Handle, DC);
  end
  else
  begin
    inherited;
  end;

  with FPageBrowserStyler, Canvas do
  begin
    (* if not BackGround.Empty then
      begin

      case BackGroundDisplay of
      bdTile:
      begin
      c := 1;
      ro := 1;
      while ro < Height - 2 do
      begin
      while c < width - 2 do
      begin
      Draw(c, ro, BackGround);
      c := c + BackGround.Width;
      end;
      c := 1;
      ro := ro + BackGround.Height;
      end;
      end;
      bdCenter:
      begin
      Draw((Width - BackGround.Width) div 2, (Height - BackGround.Height) div 2, BackGround);
      end;
      bdStretch:
      begin
      StretchDraw(Rect(R.Left + 2, R.Top + 2, R.Right - 2, R.Bottom - 2), BackGround);
      end;
      end;
      end; *)
  end;

  DrawAllTabs;

  // Canvas.Draw(0, 0, FMyImage);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.RemovePage(Page: TTabSheetBrowser);

var
  i, ni: Integer;
begin
  i := FPages.IndexOf(Page);
  if (i >= 0) then
  begin
    if i < ActivePageIndex then
      ni := ActivePageIndex - 1
    else
      ni := ActivePageIndex;

    if (ActivePage = Page) then
      SelectNextPage(True);

    FPages.Delete(i);
    Page.FPageBrowser := nil;

    if Assigned(Page.FCloseButton) then
    begin
      Page.FCloseButton.Free;
      Page.FCloseButton := nil;
    end;

    ActivePageIndex := ni;

    if not(csDestroying in ComponentState) then
    begin
      InitializeAndUpdateButtons;
      TabWidth;
      UpdateButtonsPos;
    end;

    InvalidateTab(-1);
    Invalidate;
    if Assigned(ActivePage) then
      ActivePage.Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetParent(AParent: TWinControl);
begin
  if (AParent is TPageBrowser) then
    raise Exception.Create('Invalid Parent');

  inherited;

  if (not FPropertiesLoaded) and not(csDesigning in ComponentState) and not
    (csLoading in ComponentState) then
  begin
    Init;
    InitializeAndUpdateButtons;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabSheetBrowserCount: Integer;
begin
  Result := FPages.Count;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabSheetBrowser(index: Integer): TTabSheetBrowser;
begin
  Result := TTabSheetBrowser(FPages[index]);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetPageBounds(Page: TTabSheetBrowser; var ALeft, ATop,
  AWidth, AHeight: Integer);
begin
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetChildOrder(Child: TComponent; Order: Integer);
begin
  inherited SetChildOrder(Child, Order);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMSize(var Message: TWMSize);
begin
  inherited;
  SetAllPagesPosition;
  TabWidth;
  UpdateButtonsPos;
  SetPageValidCache(False);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetPopupMenuEx(const Value: TPopupMenu);
begin
  Inherited PopupMenu := Value;

end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMShowingChanged(var Message: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetPopupMenuEx: TPopupMenu;
begin
  Result := Inherited PopupMenu;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetShowCloseOnNonSelectedTabs(const Value: Boolean);
begin
  if FShowCloseOnNonSelectedTabs <> Value then
  begin
    FShowCloseOnNonSelectedTabs := Value;
    TabWidth;
    UpdateButtonsPos;
    InvalidateTab(-1);
  end;
end;

procedure TPageBrowser.SetShowNonSelectedTabs(const Value: Boolean);
begin
  FShowNonSelectedTabs := Value;
  InvalidateTab(-1);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMControlChange(var Message: TCMControlChange);
begin
  inherited;

  // with Message do
  // begin
  // if (Control is TTabSheetBrowser) then
  // begin
  // if Inserting then
  // // InsertControl(Control)
  // else
  // // RemoveControl(Control);
  // end;
  // end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMControlListChange(var Message: TCMControlListChange);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMMouseLeave(var Message: TMessage);
var
  p: TPoint;
  r: TRect;
begin
  inherited;

  FHintPageIndex := -1;

  if (csDesigning in ComponentState) then
    Exit;

  // work around to avoid false call
  GetCursorPos(p);
  p := ScreenToClient(p);
  r := GetTabsRect;
  case (TabPosition) of
    tpTop:
      r.Bottom := r.Bottom - 4;
    tpBottom:
      r.Top := r.Top + 4;
    tpLeft:
      r.Right := r.Right - 4;
    tpRight:
      r.Left := r.Left + 4;
  end;

  if PtInRect(r, p) then
    Exit;

  if (FHotPageIndex = FActivePageIndex) then
  begin
    FHotPageIndex := -1;
    Invalidate;
  end
  else if (FHotPageIndex >= 0) then
  begin
    if (FHotPageIndex < FPages.Count) then
    begin
      if not Assigned(TabSheetBrowser[FHotPageIndex].FTimer) and Glow then
      begin
        TabSheetBrowser[FHotPageIndex].FTimer := TTimer.Create(Self);
        TabSheetBrowser[FHotPageIndex].FTimer.OnTimer := TabSheetBrowser
          [FHotPageIndex].TimerProc;
        TabSheetBrowser[FHotPageIndex].FTimer.Interval := GLOWSPEED;
        TabSheetBrowser[FHotPageIndex].FTimer.Enabled := True;
      end;

      TabSheetBrowser[FHotPageIndex].FTimeInc := -GLOWSTEP;
      TabSheetBrowser[FHotPageIndex].FGlowState := gsHover;
    end;
    FHotPageIndex := -1;
    InvalidateTab(-1);
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  p: TPoint;
  Tab: Integer;
begin
  inherited;
  p := Point(X, Y);

  FDownPageIndex := -1;

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(X, Y);
    if (Tab >= 0) then
    begin
      if (Button = mbLeft) then
      begin
        if Assigned(FOnTabClick) then
          FOnTabClick(Self, Tab);
      end
      else if (Button = mbRight) then
      begin
        if Assigned(FOnTabRightClick) then
          FOnTabRightClick(Self, Tab);
      end;

      if (Button <> mbMiddle) and (Tab <> ActivePageIndex)
        and TabSheetBrowser[Tab].TabEnabled then
      begin
        // Select Tab
        ChangeActivePage(Tab);
        if not(csDesigning in ComponentState) then
        begin
          if not Assigned(TabSheetBrowser[Tab].FTimer) and Glow then
          begin
            TabSheetBrowser[Tab].FTimer := TTimer.Create(Self);
            TabSheetBrowser[Tab].FTimer.OnTimer := TabSheetBrowser[Tab]
              .TimerProc;
            TabSheetBrowser[Tab].FTimer.Interval := GLOWSPEED;
            TabSheetBrowser[Tab].FTimer.Enabled := True;
          end;
          TabSheetBrowser[Tab].FTimeInc := +GLOWSTEP;
          TabSheetBrowser[Tab].FGlowState := gsPush;
        end;
        Invalidate;
      end
      else
      begin
        FDownPageIndex := Tab;
        InvalidateTab(-1);
      end;

      if (Button = mbLeft) and TabSheetBrowser[Tab]
        .TabEnabled and TabReorder then
      begin
        BeginDrag(False, 4);
      end;
    end
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  p: TPoint;
  Tab: Integer;
begin
  inherited;

  if (csDesigning in ComponentState) then
    Exit;

  p := Point(X, Y);

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(X, Y);
    if (Tab >= 0) and (Tab <> FHotPageIndex) then
    begin
      if (FDownPageIndex >= 0) then
      begin
        FDownPageIndex := -1;
        InvalidateTab(-1);
      end;

      if (FHotPageIndex >= 0) then
      begin
        OnExitTab(FHotPageIndex);
        begin
          if (FHotPageIndex < FPages.Count) then
          begin
            if not Assigned(TabSheetBrowser[FHotPageIndex].FTimer) and Glow then
            begin
              TabSheetBrowser[FHotPageIndex].FTimer := TTimer.Create(Self);
              TabSheetBrowser[FHotPageIndex].FTimer.OnTimer := TabSheetBrowser
                [FHotPageIndex].TimerProc;
              TabSheetBrowser[FHotPageIndex].FTimer.Interval := GLOWSPEED;
              TabSheetBrowser[FHotPageIndex].FTimer.Enabled := True;
            end;
            TabSheetBrowser[FHotPageIndex].FTimeInc := -GLOWSTEP;

            TabSheetBrowser[FHotPageIndex].FGlowState := gsHover;
          end;
          FHotPageIndex := -1;
          InvalidateTab(-1);
        end;
      end;

      // Hot Tab
      if Assigned(FOnMouseEnterTab) then
        FOnMouseEnterTab(Self, TabSheetBrowser[Tab]);

      // InvalidateTab(-1);
      // if (Tab <> FActivePageIndex) then
      if TabSheetBrowser[Tab].TabEnabled then
      begin
        FHotPageIndex := Tab;
        FOldHotPageIndex := FHotPageIndex;
        if not Assigned(TabSheetBrowser[FHotPageIndex].FTimer) and Glow then
        begin
          TabSheetBrowser[FHotPageIndex].FTimer := TTimer.Create(Self);
          TabSheetBrowser[FHotPageIndex].FTimer.OnTimer := TabSheetBrowser
            [FHotPageIndex].TimerProc;
          TabSheetBrowser[FHotPageIndex].FTimer.Interval := GLOWSPEED;
          TabSheetBrowser[FHotPageIndex].FTimer.Enabled := True;
        end;

        TabSheetBrowser[FHotPageIndex].FTimeInc := GLOWSTEP;
        Invalidate;
        TabSheetBrowser[FHotPageIndex].FGlowState := gsHover;
      end;

      if (FHintPageIndex <> Tab) then
      begin
        FHintPageIndex := Tab;
        Application.CancelHint;
      end;
    end
    else if (Tab < 0) and (FHotPageIndex >= 0) then
    begin
      if (FDownPageIndex >= 0) then
      begin
        FDownPageIndex := -1;
        InvalidateTab(-1);
      end;
      OnExitTab(FHotPageIndex);
      if (FHotPageIndex = FActivePageIndex) and False then
      begin
        FHotPageIndex := -1;
        Invalidate;
      end
      else
      begin
        if (FHotPageIndex < FPages.Count) then
        begin
          if not Assigned(TabSheetBrowser[FHotPageIndex].FTimer) and Glow then
          begin
            TabSheetBrowser[FHotPageIndex].FTimer := TTimer.Create(Self);
            TabSheetBrowser[FHotPageIndex].FTimer.OnTimer := TabSheetBrowser
              [FHotPageIndex].TimerProc;
            TabSheetBrowser[FHotPageIndex].FTimer.Interval := GLOWSPEED;
            TabSheetBrowser[FHotPageIndex].FTimer.Enabled := True;
          end;
          TabSheetBrowser[FHotPageIndex].FTimeInc := -GLOWSTEP;

          TabSheetBrowser[FHotPageIndex].FGlowState := gsHover;
        end;
        FHotPageIndex := -1;
        InvalidateTab(-1);
      end;
    end;

    if (Tab < 0) then
    begin
      FHintPageIndex := -1;
      Application.CancelHint;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  p: TPoint;
  Tab: Integer;
begin
  inherited;
  p := Point(X, Y);

  if (FDownPageIndex >= 0) then
  begin
    FDownPageIndex := -1;
    InvalidateTab(-1);
  end;

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(X, Y);
    if (Tab >= 0) then
    begin
      if PTOnCheckBox(Tab, X, Y) then
      begin
        TabSheetBrowser[Tab].Checked := not TabSheetBrowser[Tab].Checked;
        if Assigned(FOnTabCheckBoxClick) then
          FOnTabCheckBoxClick(Self, Tab);
        InvalidateTab(Tab);
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetCheckBoxRect(PageIndex: Integer): TRect;
var
  rb, r: TRect;
  h, w: Integer;
begin
  r := GetTabRect(PageIndex);
  w := 0;
  h := 0;
  if (CloseOnTabPosition = cpLeft) and (ShowCloseOnNonSelectedTabs or
      ((ActivePageIndex = PageIndex) and not ShowCloseOnNonSelectedTabs)) then
  begin
    rb := GetCloseButtonRect(PageIndex);
    h := rb.Bottom - rb.Top;
    w := rb.Right - rb.Left;
  end;
  case TabPosition of
    tpTop, tpBottom:
      Result := Bounds(r.Left + 5 + w, r.Top + (r.Bottom - r.Top - 15) div 2,
        15, 15);
    tpLeft:
      Result := Bounds(r.Left + (r.Right - r.Left - 15) div 2,
        r.Bottom - h - 5 - 15, 15, 15);
    tpRight:
      Result := Bounds(r.Left + (r.Right - r.Left - 15) div 2, r.Top + 5 + h,
        15, 15);
  end;
end;

procedure TPageBrowser.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  i: Integer;
  Control: TControl;
begin
  for i := 0 to FPages.Count - 1 do
    Proc(TComponent(FPages[i]));

  for i := 0 to ControlCount - 1 do
  begin
    Control := Controls[i];
    if (Control.Owner = Root) and (FPages.IndexOf(Control) < 0) then
      Proc(Control);
  end;

end;

// ------------------------------------------------------------------------------

function TPageBrowser.FindNextPage(CurPage: TTabSheetBrowser; GoForward,
  CheckTabVisible: Boolean): TTabSheetBrowser;
var
  i, j, CurIndex: Integer;
begin
  Result := nil;
  CurIndex := FPages.IndexOf(CurPage);

  if (CurPage = nil) or (CurIndex < 0) then
  begin

    if FPages.Count > 0 then
    begin
      if GoForward then
        Result := FPages[0]
      else
        Result := FPages[FPages.Count - 1];
    end;
    Exit;
  end;

  if GoForward then
  begin
    i := CurIndex;
    j := 0; // 1;
    while (j < FPages.Count) do
    begin
      Inc(i);
      if (i >= FPages.Count) then
        i := 0;
      if (CheckTabVisible and TabSheetBrowser[i].TabVisible)
        or not CheckTabVisible then
      begin
        Result := TabSheetBrowser[i];
        Break;
      end;
      Inc(j);
    end;
  end
  else // BackWard
  begin
    i := CurIndex;
    j := 0; // 1;
    while (j < FPages.Count) do
    begin
      dec(i);
      if (i >= FPages.Count) then
        i := 0;
      if (i < 0) then
        i := FPages.Count - 1;
      if (CheckTabVisible and TabSheetBrowser[i].TabVisible)
        or not CheckTabVisible then
      begin
        Result := TabSheetBrowser[i];
        Break;
      end;
      Inc(j);
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetActivePage: TTabSheetBrowser;
begin
  Result := nil;
  if (ActivePageIndex >= 0) and (ActivePageIndex < FPages.Count) then
    Result := TabSheetBrowser[FActivePageIndex];
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetActivePageIndex: Integer;
begin
  Result := FActivePageIndex;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SelectNextPage(GoForward: Boolean);
var
  i, j: Integer;
begin
  if (ActivePageIndex < 0) then
    Exit;

  if GoForward then
  begin
    i := ActivePageIndex;
    j := 0; // 1;
    while (j < FPages.Count) do
    begin
      Inc(i);
      if (i >= FPages.Count) then
        i := 0;
      if (ActivePage <> TabSheetBrowser[i]) and TabSheetBrowser[i]
        .TabVisible and TabSheetBrowser[i].TabEnabled then
      begin
        ActivePageIndex := i;
        Break;
      end;
      Inc(j);
    end;
  end
  else // BackWard
  begin
    i := ActivePageIndex;
    j := 0; // 1;
    while (j < FPages.Count) do
    begin
      dec(i);
      if (i >= FPages.Count) then
        i := 0;
      if (i < 0) then
        i := FPages.Count - 1;
      if (ActivePage <> TabSheetBrowser[i]) and TabSheetBrowser[i]
        .TabVisible and TabSheetBrowser[i].TabEnabled then
      begin
        ActivePageIndex := i;
        Break;
      end;
      Inc(j);
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.IndexOfPage(Page: TTabSheetBrowser): Integer;
begin
  Result := FPages.IndexOf(Page);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetActivePage(const Value: TTabSheetBrowser);
begin
  if ActivePageIndex = FPages.IndexOf(Value) then
    Exit;
  if (FPages.IndexOf(Value) >= 0) then
    ActivePageIndex := FPages.IndexOf(Value);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.ChangeActivePage(PageIndex: Integer);
var
  aForm: TCustomForm;
  AllowChange, WasPageFocused: Boolean;
  OldActivePage: TTabSheetBrowser;
begin
  if (PageIndex >= -1) and (PageIndex < FPages.Count) and
    ((PageIndex <> ActivePageIndex) or (FPages.Count = 1)) then
  begin
    AllowChange := True;

    if Assigned(FOnChanging) and FPropertiesLoaded and not
      (csDestroying in ComponentState) then
      FOnChanging(Self, ActivePageIndex, PageIndex, AllowChange);

    if not AllowChange then
      Exit;

    aForm := GetParentForm(Self);
    WasPageFocused := (aForm <> nil) and (ActivePage <> nil) and
      ((aForm.ActiveControl = ActivePage) or ActivePage.ContainsControl
        (aForm.ActiveControl));

    if (ActivePageIndex >= 0) and (ActivePageIndex < FPages.Count) then
    begin
      TabSheetBrowser[FActivePageIndex].Visible := False;

      if Assigned(TabSheetBrowser[FActivePageIndex].FOnHide) then
        TabSheetBrowser[FActivePageIndex].FOnHide
          (TabSheetBrowser[FActivePageIndex]);
    end;

    OldActivePage := ActivePage;

    FActivePageIndex := PageIndex;

    if (csDesigning in ComponentState) and not(csLoading in ComponentState) then
    begin
      // aForm := GetParentForm(Self);
      if (aForm <> nil) and (aForm.Designer <> nil) then
        aForm.Designer.Modified;
    end;

    InitializeAndUpdateButtons;

    if ActivePage <> nil then
    begin
      if (aForm <> nil) and (OldActivePage <> nil) and WasPageFocused then
        if ActivePage.CanFocus then
          aForm.ActiveControl := ActivePage
        else
          aForm.ActiveControl := Self;
    end;

    if not(csDesigning in ComponentState) and (aForm <> nil) and
      (ActivePage <> nil) and (aForm.ActiveControl = ActivePage) then
      ActivePage.SelectFirstControl;

    if FActivePageIndex <> -1 then
    begin
      TabSheetBrowser[FActivePageIndex].Visible := True;
      TabSheetBrowser[FActivePageIndex].BringToFront;
    end;

    if Assigned(FOnChange) and not(csDestroying in ComponentState) and not
      (csLoading in ComponentState) then
      FOnChange(Self);

  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetActivePageIndex(const Value: Integer);
var
  r: TRect;
begin
  ChangeActivePage(Value);
  r := GetTabsArea;
  InvalidateRect(Handle, @r, True);
  // end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetTabSettings(const Value: TPagerTabSettings);
begin
  FTabSettings.Assign(Value);
end;

procedure TPageBrowser.SetTransparent(const Value: Boolean);
begin
  if (FTransparent <> Value) then
  begin
    FTransparent := Value;
    Invalidate;
  end;
end;

procedure TPageBrowser.UpdateButtonsPos;
var
  VRect: TRect;
begin
  if TabSheetBrowserCount > 0 then
  begin
    VRect := GetTabRect(TabSheetBrowserCount - 1);
    VRect.Left := VRect.Right + 2;
    VRect.Right := VRect.Right + VRect.Bottom - 2;
    VRect.Bottom := VRect.Bottom - 4;
    FButtonNewTab.BoundsRect := VRect;
    VRect.Left := VRect.Left + FButtonNewTab.Height;
    VRect.Right := VRect.Right + FButtonNewTab.Height;
    FButtonNewSubtab.BoundsRect := VRect;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetAllPagesPosition;
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
  begin
    SetPagePosition(TTabSheetBrowser(FPages[i]));
  end;
end;

function TPageBrowser.GetPageRect: TRect;
begin
  Result := ClientRect;
  case TabPosition of
    tpTop:
      begin
        Result.Top := Result.Top + TabSettings.Height;
        Result.Left := Result.Left + FPageMargin;
        Result.Right := Result.Right - FPageMargin;
        Result.Bottom := Result.Bottom - FPageMargin - 1;
      end;
    tpBottom:
      begin
        Result.Top := Result.Top + FPageMargin + 1;
        Result.Left := Result.Left + FPageMargin;
        Result.Right := Result.Right - FPageMargin;
        Result.Bottom := Result.Bottom - TabSettings.Height;
      end;
    tpLeft:
      begin
        Result.Top := Result.Top + FPageMargin + 1;
        Result.Left := Result.Left + TabSettings.Height;
        Result.Right := Result.Right - FPageMargin;
        Result.Bottom := Result.Bottom - FPageMargin - 1;
      end;
    tpRight:
      begin
        Result.Top := Result.Top + FPageMargin + 1;
        Result.Left := Result.Left + FPageMargin;
        Result.Right := Result.Right - TabSettings.Height;
        Result.Bottom := Result.Bottom - FPageMargin - 1;
      end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetPagePosition(Page: TTabSheetBrowser);
var
  r: TRect;
begin
  if (Page <> nil) and (FPages.IndexOf(Page) >= 0) then
  begin
    r := GetPageRect;
    Page.SetBounds(r.Left, r.Top, r.Right - r.Left, r.Bottom - r.Top);
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.IndexOfTabAt(X, Y: Integer): Integer;
begin
  Result := PTOnTab(X, Y);
end;

// ------------------------------------------------------------------------------

function TPageBrowser.PTOnCheckBox(PageIndex, X, Y: Integer): Boolean;
begin
  Result := False;
  if TabSheetBrowser[PageIndex].ShowCheckBox then
    Result := PtInRect(GetCheckBoxRect(PageIndex), Point(X, Y));
end;

function TPageBrowser.PTOnTab(X, Y: Integer): Integer;
var
  i: Integer;
  p: TPoint;
  TabR: TRect;
begin
  Result := -1;
  p := Point(X, Y);
  for i := 0 to FPages.Count - 1 do
  begin
    TabR := GetTabRect(i);
    if PtInRect(TabR, p) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

// ------------------------------------------------------------------------------

// Independent to Start/End Margins and Scroller
function TPageBrowser.GetTabsArea: TRect;
begin
  Result := ClientRect;
  case TabPosition of
    tpTop:
      Result.Bottom := Result.Top + FTabSettings.Height;
    tpBottom:
      Result.Top := Result.Bottom - FTabSettings.Height;
    tpLeft:
      Result.Right := Result.Left + FTabSettings.Height;
    tpRight:
      Result.Left := Result.Right - FTabSettings.Height;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabsRect: TRect;
begin
  Result := ClientRect;
  case TabPosition of
    tpTop:
      begin
        Result.Top := Result.Top + FTabOffSet;
        Result.Bottom := Result.Top + FTabSettings.Height;
        Result.Left := Result.Left + FTabSettings.StartMargin + FPageMargin;
        Result.Right := Result.Right - FTabSettings.EndMargin;
      end;
    tpBottom:
      begin
        Result.Top := Result.Bottom - FTabSettings.Height - FTabOffSet;
        Result.Bottom := Result.Bottom - FTabOffSet;
        Result.Left := Result.Left + FTabSettings.StartMargin + FPageMargin;
        Result.Right := Result.Right - FTabSettings.EndMargin;
      end;
    tpLeft:
      begin
        Result.Top := Result.Top + FTabSettings.StartMargin + FPageMargin;
        Result.Bottom := Result.Bottom - FTabSettings.EndMargin;
        Result.Left := Result.Left + FTabOffSet;
        Result.Right := Result.Left + FTabSettings.Height;
      end;
    tpRight:
      begin
        Result.Top := Result.Top + FTabSettings.StartMargin + FPageMargin;
        Result.Bottom := Result.Bottom - FTabSettings.EndMargin;
        Result.Left := Result.Right - TabSettings.Height - FTabOffSet;
        Result.Right := Result.Right - FTabOffSet;
      end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabRect(PageIndex: Integer): TRect;
begin
  Result := GetTabRect(0, PageIndex);
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabRect(StartIndex, PageIndex: Integer): TRect;
var
  i, TbW, TbH, Sp, fdW, ImgTxtSp, ImgW, ImgH: Integer;
  r, CR, r2: TRect;
  TabAppearance: TTabAppearance;
  Pic: TPicture;

begin
  Result := Rect(-1, -1, -1, -1);
  Sp := FTabSettings.Spacing; // 0;
  fdW := 5;
  ImgTxtSp := IMG_SPACE;

  // Ellipsis := (TabSettings.Width > 0) and not TabSettings.WordWrap;

  if (PageIndex >= 0) and (PageIndex < FPages.Count) then
  begin
    if not TabSheetBrowser[PageIndex].TabVisible then
      Exit;

    CR := GetTabsRect; // ClientRect;
    for i := StartIndex to PageIndex do
    begin
      if not TabSheetBrowser[i].TabVisible then
        Continue;

      if (TabSheetBrowser[i].UseTabAppearance) then
        TabAppearance := TabSheetBrowser[i].TabAppearance
      else
        TabAppearance := FPageBrowserStyler.TabAppearance;

      Canvas.Font.Assign(TabAppearance.Font);
      ImgW := 0;
      ImgH := 0;

      if (TabPosition in [tpTop, tpBottom]) then
      begin
        if FUseMaxSpace then
          CR.Right := GetTabsArea.Right;

        if (TabSheetBrowser[i].Caption <> '') then
        begin
          r2 := Rect(0, 0, 1000, 100);
          r2 := DrawVistaText(Canvas, taLeftJustify, r2,
            TabSheetBrowser[i].Caption, '', Canvas.Font,
            TabSheetBrowser[i].Enabled, False, FAntiAlias, tpTop, False,
            TabSettings.WordWrap);
          r2.Right := r2.Right - fdW;
        end
        else if (TabSheetBrowser[i].WideCaption <> '') then
        begin
          r2 := Rect(0, 0, 1000, 100);

          r2 := DrawVistaText(Canvas, taLeftJustify, r2, '',
            TabSheetBrowser[i].WideCaption, Canvas.Font,
            TabSheetBrowser[i].Enabled, False, FAntiAlias, tpTop, False,
            TabSettings.WordWrap);
          r2.Right := r2.Right - fdW;
        end
        else
          r2 := Rect(0, 0, 0, 0);

        TbW := GetLeftRoundingOffset + TabSettings.LeftMargin + r2.Right +
          fdW + TabSettings.RightMargin + GetRightRoundingOffset + 3;

        if TabSheetBrowser[i].Enabled or TabSheetBrowser[i]
          .DisabledPicture.Bitmap.Empty then
          Pic := TabSheetBrowser[i].Picture
        else
          Pic := TabSheetBrowser[i].DisabledPicture;

        if Assigned(Pic) and not Pic.Bitmap.Empty then
        begin
          // TbW := TbW + Pic.Width + ImgTxtSp;
          ImgW := Pic.Width;
        end
        else if (Assigned(FImages) or Assigned(DisabledImages)) and
          (TabSheetBrowser[i].ImageIndex >= 0) then
        begin
          if TabSheetBrowser[i].Enabled then
          begin
            if Assigned(FImages) then
            begin
              // TbW := TbW + FImages.Width + ImgTxtSp;
              ImgW := FImages.Width;
            end;
          end
          else
          begin
            if Assigned(FDisabledImages) then
            begin
              // TbW := TbW + FDisabledImages.Width + ImgTxtSp
              ImgW := FDisabledImages.Width;
            end
            else if Assigned(FImages) then
            begin
              // TbW := TbW + FImages.Width + ImgTxtSp;
              ImgW := FImages.Width;
            end;
          end;
        end;

        // TbW := TbW + ImgW;
        case TabSettings.ImagePosition of
          ipTop, ipBottom:
            begin
              // do nothing
            end;
          ipLeft, ipRight:
            begin
              TbW := TbW + ImgW;
              if ImgW > 0 then
                TbW := TbW + ImgTxtSp;
            end;
        end;

        if (ButtonSettings.CloseButton and TabSheetBrowser[i].ShowClose) then
          TbW := TbW + PAGEBUTTON_SIZE + 4;

        if TabSheetBrowser[i].ShowCheckBox then
          TbW := TbW + 20;

        if (TabSettings.Width > 0) then
          TbW := TabSettings.Width;

        r := Rect(CR.Left, CR.Top, CR.Left + TbW, CR.Bottom);
        if (i = PageIndex) then
          Result := r;
        CR.Left := CR.Left + TbW + Sp;
      end
      else // TabPosition in [tpLeft, tpRight]
      begin
        if FUseMaxSpace then
          CR.Bottom := GetTabsArea.Bottom;

        if (TabSheetBrowser[i].Caption <> '') then
        begin
          r2 := Rect(0, 0, 1000, 100);
          DrawText(Canvas.Handle, PChar(TabSheetBrowser[i].Caption), Length
              (TabSheetBrowser[i].Caption), r2,
            DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
        end
        else if (TabSheetBrowser[i].WideCaption <> '') then
        begin
          r2 := Rect(0, 0, 1000, 100);
{$IFNDEF TMSDOTNET}
          DrawTextW(Canvas.Handle, PWideChar(TabSheetBrowser[i].WideCaption),
            -1, r2, DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
{$ENDIF}
{$IFDEF TMSDOTNET}
          DrawTextW(Canvas.Handle, Pages[i].WideCaption, -1, r2,
            DT_CALCRECT or DT_LEFT or DT_SINGLELINE);
{$ENDIF}
        end
        else
          r2 := Rect(0, 0, 0, 0);

        TbW := TabSettings.LeftMargin + r2.Right + fdW +
          TabSettings.RightMargin;
        TbH := r2.Bottom;

        if TabSheetBrowser[i].Enabled or TabSheetBrowser[i]
          .DisabledPicture.Bitmap.Empty then
          Pic := TabSheetBrowser[i].Picture
        else
          Pic := TabSheetBrowser[i].DisabledPicture;

        if Assigned(Pic) and not Pic.Bitmap.Empty then
        begin
          // TbW := TbW + Pic.Height + ImgTxtSp;
          // TbH := Max(TbH, Pic.Height);
          ImgW := Pic.Width;
          ImgH := Pic.Height;
        end
        else if (Assigned(FImages) or Assigned(DisabledImages)) and
          (TabSheetBrowser[i].ImageIndex >= 0) then
        begin
          if TabSheetBrowser[i].Enabled then
          begin
            if Assigned(FImages) then
            begin
              // TbW := TbW + FImages.Height + ImgTxtSp;
              // TbH := Max(TbH, FImages.Height);
              ImgW := FImages.Width;
              ImgH := FImages.Height;
            end;
          end
          else
          begin
            if Assigned(FDisabledImages) then
            begin
              // TbW := TbW + FDisabledImages.Height + ImgTxtSp;
              // TbH := Max(TbH, FDisabledImages.Height);
              ImgW := FDisabledImages.Width;
              ImgH := FDisabledImages.Height;
            end
            else if Assigned(FImages) then
            begin
              // TbW := TbW + FImages.Height + ImgTxtSp;
              // TbH := Max(TbH, FImages.Height);
              ImgW := FImages.Width;
              ImgH := FImages.Height;
            end;
          end;
        end;

        case TabSettings.ImagePosition of
          ipTop, ipBottom:
            begin
              TbH := TbH + ImgH + ImgTxtSp;
            end;
          ipLeft, ipRight:
            begin
              TbW := TbW + ImgW + ImgTxtSp;
              TbH := Max(TbH, ImgH);
            end;
        end;

        TbH := TbH + 12; // TabSettings.RightMargin;

        if not RotateTabLeftRight then
        begin
          if (TabSettings.Width > 0) then
            TbH := TabSettings.Width;

          r := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbH);
          if (i = PageIndex) then
            Result := r;
          CR.Top := CR.Top + TbH + Sp;
        end
        else
        begin
          TbW := TbW + GetLeftRoundingOffset + GetRightRoundingOffset;
          if (ButtonSettings.CloseButton and TabSheetBrowser[i].ShowClose) then
            TbW := TbW + PAGEBUTTON_SIZE + 4;

          if TabSheetBrowser[i].ShowCheckBox then
            TbW := TbW + 20;

          if (TabSettings.Width > 0) then
            TbW := TabSettings.Width;

          r := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbW);
          if (i = PageIndex) then
            Result := r;
          CR.Top := CR.Top + TbW + Sp;
        end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetTabRect(Page: TTabSheetBrowser): TRect;
begin
  Result := GetTabRect(FPages.IndexOf(Page));
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMDesignHitTest(var Msg: TCMDesignHitTest);
var
  p: TPoint;
  Tab: Integer;
begin
  Tab := -1;
  if (csDesigning in ComponentState) then
  begin
    GetCursorPos(p);
    p := ScreenToClient(p);

    if PtInRect(GetTabsRect, p) and (GetAsyncKeyState(VK_LBUTTON) <> 0) then
    begin
      Tab := PTOnTab(p.X, p.Y);
      if (Tab >= 0) then
      begin
        // Select Tab
        // ActivePageIndex := Tab;
        Msg.Result := 1;
      end;
    end;

  end;

  if (Tab = -1) then
    inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
  Invalidate;
  if Assigned(ActivePage) then
    ActivePage.Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.InvalidateTab(PageIndex: Integer);
var
  r: TRect;
begin
  if (PageIndex >= 0) and (PageIndex < FPages.Count) then
    r := GetTabRect(PageIndex)
  else
    r := GetTabsArea;
  InvalidateRect(Handle, @r, True);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.OnExitTab(PageIndex: Integer);
begin

end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetDisabledImages(const Value: TCustomImageList);
begin
  FDisabledImages := Value;
  Invalidate;
  if Assigned(ActivePage) then
    ActivePage.Invalidate;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetCloseButtonRect(PageIndex: Integer): TRect;
var
  i: Integer;
  cbr, TR: TRect;
  ip: TPoint;
begin
  Result := Rect(-1, -1, -1, -1);
  if ButtonSettings.CloseButton then
  begin
    if (ShowCloseOnNonSelectedTabs or ((ActivePageIndex = PageIndex)
          and not ShowCloseOnNonSelectedTabs)) then
    begin
      case TabPosition of
        tpTop:
          begin
            Result := GetTabRect(PageIndex);

            if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
              and (PageIndex >= 0) then
            begin
              GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
              Result.Left := cbr.Left;
            end
            else
            begin
              if (CloseOnTabPosition = cpRight) then
                Result.Left := Result.Right - PAGEBUTTON_SIZE - 4 -
                  GetRightRoundingOffset
              else // CloseOnTabPosition = cpLeft
                Result.Left := Result.Left + 4 + GetLeftRoundingOffset
            end;
            Result.Right := Result.Left + PAGEBUTTON_SIZE;
            Result.Bottom := Result.Bottom - 5;
            Result.Top := Result.Bottom - PAGEBUTTON_SIZE;
          end;
        tpBottom:
          begin
            Result := GetTabRect(PageIndex);
            if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
              and (PageIndex >= 0) then
            begin
              GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
              Result.Left := cbr.Left;
            end
            else
            begin
              if (CloseOnTabPosition = cpRight) then
                Result.Left := Result.Right - PAGEBUTTON_SIZE - 4 -
                  GetRightRoundingOffset
              else // CloseOnTabPosition = cpLeft
                Result.Left := Result.Left + 4 + GetLeftRoundingOffset;
            end;
            Result.Right := Result.Left + PAGEBUTTON_SIZE;
            Result.Top := Result.Top + 5;
            Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
          end;
        tpLeft:
          begin
            if RotateTabLeftRight then
            begin
              Result := GetTabRect(PageIndex);
              Result.Right := Result.Right - 5;
              Result.Left := Result.Right - PAGEBUTTON_SIZE;
              if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
                and (PageIndex >= 0) then
              begin
                GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
                Result.Top := cbr.Top;
              end
              else
              begin
                if (CloseOnTabPosition = cpRight) then
                  Result.Top := Result.Top + 4 + GetRightRoundingOffset
                else
                  Result.Top := Result.Bottom - PAGEBUTTON_SIZE - 4 -
                    GetLeftRoundingOffset;
              end;
              Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
            end
            else
            begin
              Result := GetTabRect(PageIndex);
              i := (Result.Bottom - Result.Top - PAGEBUTTON_SIZE) div 2;

              if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
                and (PageIndex >= 0) then
              begin
                GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
                Result.Left := cbr.Left;
              end
              else
              begin
                if (CloseOnTabPosition = cpRight) then
                  Result.Left := Result.Right - PAGEBUTTON_SIZE - 5
                else // CloseOnTabPosition = cpLeft
                  Result.Left := Result.Left + 4;
              end;
              Result.Right := Result.Left + PAGEBUTTON_SIZE;
              Result.Top := Result.Top + i;
              Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
            end;
          end;
        tpRight:
          begin
            if RotateTabLeftRight then
            begin
              Result := GetTabRect(PageIndex);
              Result.Left := Result.Left + 5;
              Result.Right := Result.Left + PAGEBUTTON_SIZE;
              if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
                and (PageIndex >= 0) then
              begin
                GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
                Result.Bottom := cbr.Bottom;
              end
              else
              begin
                if (CloseOnTabPosition = cpRight) then
                  Result.Bottom := Result.Bottom - 4 - GetRightRoundingOffset
                else
                  Result.Bottom := Result.Top + PAGEBUTTON_SIZE + 4 +
                    GetLeftRoundingOffset;
              end;
              Result.Top := Result.Bottom - PAGEBUTTON_SIZE;
            end
            else
            begin
              Result := GetTabRect(PageIndex);
              i := (Result.Bottom - Result.Top - PAGEBUTTON_SIZE) div 2;

              if (TabSettings.Width > 0) and (TabSettings.Alignment = taCenter)
                and (PageIndex >= 0) then
              begin
                GetCloseBtnImageAndTextRect(PageIndex, cbr, TR, ip);
                Result.Left := cbr.Left;
              end
              else
              begin
                if (CloseOnTabPosition = cpRight) then
                  Result.Left := Result.Right - PAGEBUTTON_SIZE - 3
                else // CloseOnTabPosition = cpLeft
                  Result.Left := Result.Left + 5;
              end;

              Result.Right := Result.Left + PAGEBUTTON_SIZE;
              Result.Top := Result.Top + i;
              Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
            end;
          end;
      end;
    end
    else
    begin
      case TabPosition of
        tpTop:
          begin
            Result := GetTabsRect;
            Result.Left := Result.Left + 3;
            Result.Right := Result.Left + PAGEBUTTON_SIZE;
            Result.Bottom := Result.Bottom - 5;
            Result.Top := Result.Bottom - PAGEBUTTON_SIZE;
          end;
        tpBottom:
          begin
            Result := GetTabsRect;
            Result.Left := Result.Left + 3;
            Result.Right := Result.Left + PAGEBUTTON_SIZE;
            Result.Top := Result.Top + 5;
            Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
          end;
        tpLeft:
          begin
            Result := GetTabsRect;
            Result.Top := Result.Top + 3;
            Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
            Result.Right := Result.Right - 5;
            Result.Left := Result.Right - PAGEBUTTON_SIZE;
          end;
        tpRight:
          begin
            Result := GetTabsRect;
            Result.Top := Result.Top + 3;
            Result.Bottom := Result.Top + PAGEBUTTON_SIZE;
            Result.Left := Result.Left + 5;
            Result.Right := Result.Left + PAGEBUTTON_SIZE;
          end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMHintShow(var Message: TMessage);
var
  PHI: PHintInfo;
begin
  PHI := TCMHintShow(Message).HintInfo;
  if ShowTabHint then
  begin
    if (FHintPageIndex >= 0) then
      PHI^.HintStr := TabSheetBrowser[FHintPageIndex].TabHint;
  end
  else
    PHI^.HintStr := '';
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.OnTabSettingsChanged(Sender: TObject);
begin
  SetPageValidCache(False);
  SetAllPagesPosition;
  InitializeAndUpdateButtons;
  TabWidth;
  UpdateButtonsPos;
  Invalidate;
  if Assigned(ActivePage) then
    ActivePage.Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.UpdateMe(PropID: Integer);
begin
  UpdatePageAppearanceOfPages;
  UpdateTabAppearanceOfPages;

  SetPageValidCache(False);
  Invalidate;
  if Assigned(ActivePage) then
    ActivePage.Invalidate;

  case PropID of
    2, 4:
      InitializeAndUpdateButtons;
    5:
      OnTabSettingsChanged(Self);
  end;

end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;

  if (csDesigning in ComponentState) then
    Exit;

  { pt := ScreenToClient(point(msg.xpos,msg.ypos));

    if (FCaption.Visible) and PtInRect(GetCaptionRect, pt)
    and (Msg.Result = htClient) and FCanMove then
    begin
    //MouseMove([],pt.X,pt.Y);

    Msg.Result := htCaption;
    //FInMove := true;

    SetWindowPos(GetParentForm(Self).Handle, HWND_TOP,0,0,0,0,  SWP_NOMOVE or SWP_NOSIZE);
    end; }
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetTabPosition(const Value: TTabPosition);
begin
  if (FTabPosition <> Value) then
  begin
    FTabPosition := Value;
    SetPageValidCache(False);
    SetAllPagesPosition;
    TabWidth;
    UpdateButtonsPos;
    Invalidate;
    if Assigned(ActivePage) then
      ActivePage.Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMDialogChar(var Message: TCMDialogChar);
var
  i: Integer;
begin
  for i := 0 to FPages.Count - 1 do
  begin
    if TabSheetBrowser[i].Caption <> '' then
    begin
      if IsAccel(Message.CharCode, TabSheetBrowser[i].Caption) and CanShowTab
        (i) and CanFocus then
      begin
        Message.Result := 1;
        ActivePageIndex := i;
        Exit;
      end;
    end
    else
    begin
      if IsAccel(Message.CharCode, TabSheetBrowser[i].WideCaption)
        and CanShowTab(i) and CanFocus then
      begin
        Message.Result := 1;
        ActivePageIndex := i;
        Exit;
      end;
    end;
  end;
  inherited;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.CanShowTab(PageIndex: Integer): Boolean;
begin
  Result := (PageIndex >= 0) and (PageIndex < FPages.Count) and
    (TabSheetBrowser[PageIndex].TabVisible);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetAntiAlias(const Value: TAntiAlias);
begin
  FAntiAlias := Value;
  Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetButtonSettings(const Value: TPageButtonSettings);
begin
  FButtonSettings.Assign(Value);
  Invalidate;
  if Assigned(ActivePage) then
    ActivePage.Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.OnButtonSettingChanged(Sender: TObject);
begin
  TabWidth;
  UpdateButtonsPos;
  Invalidate;
  if (ActivePage <> nil) then
    ActivePage.Invalidate;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetPageMargin(const Value: Integer);
begin
  if FPageMargin <> Value then
  begin
    FPageMargin := Value;
    TabWidth;
    UpdateButtonsPos;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetDockClientFromMousePos(MousePos: TPoint): TControl;
var
  Page: TTabSheetBrowser;
  Tab: Integer;
begin
  Result := nil;
  if DockSite then
  begin
    Tab := PTOnTab(MousePos.X, MousePos.Y);

    if (Tab >= 0) and (Tab < TabSheetBrowserCount) then
    begin
      Page := TabSheetBrowser[Tab];
      if Page.ControlCount > 0 then
      begin
        Result := Page.Controls[0];
        if Result.HostDockSite <> Self then
          Result := nil;
      end;
    end;
  end;
end;


// ------------------------------------------------------------------------------

procedure TPageBrowser.SetCloseOnTabPosition(const Value: TCloseOnTabPos);
begin
  if (FCloseOnTabPosition <> Value) then
  begin
    FCloseOnTabPosition := Value;
    TabWidth;
    UpdateButtonsPos;
    InitializeAndUpdateButtons;
    if (ActivePage <> nil) then
      ActivePage.Invalidate;
    Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetRotateTabLeftRight(const Value: Boolean);
begin
  if (FRotateTabLeftRight <> Value) then
  begin
    FRotateTabLeftRight := Value;
    TabWidth;
    UpdateButtonsPos;
    Invalidate;
    if Assigned(ActivePage) then
      ActivePage.Invalidate;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetVisibleTabCount: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FPages.Count - 1 do
  begin
    if (TabSheetBrowser[i].TabVisible) then
      Result := Result + 1;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.Init;
begin
  FPropertiesLoaded := True;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.CloseActivePage: Boolean;
var
  lPage: TTabSheetBrowser;

begin
  Result := True;
  if Assigned(ActivePage) then
  begin
    lPage := ActivePage;
    OnCloseButtonClick(Self);
    Result := lPage <> ActivePage;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.CanShowCloseButton: Boolean;
begin
  Result := ButtonSettings.CloseButton;
  if Assigned(ActivePage) then
    Result := ActivePage.ShowClose and Result;

  Result := Result or (ShowCloseOnNonSelectedTabs and (TabSheetBrowserCount > 0)
    );
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.InitializeAndUpdateButtons;
var
  r: TRect;
  i: Integer;
begin
  if (not FPropertiesLoaded) and not(csDesigning in ComponentState) then
    Exit;

  if ButtonSettings.CloseButton
  { and not CloseOnTab  and (CanShowCloseButton or not CloseOnTab) } then
  begin

    for i := 0 to TabSheetBrowserCount - 1 do
    begin
      with TabSheetBrowser[i] do
      begin
        if ShowClose then
        begin
          if (FCloseButton = nil) then
          begin
            FCloseButton := TSpeedButton.Create(Self);
            FCloseButton.Parent := Self;
            FCloseButton.OnClick := OnCloseButtonClick;
            FCloseButton.Flat := True;
          end;

          r := GetCloseButtonRect(i);
          FCloseButton.Left := r.Left;
          FCloseButton.Top := r.Top;
          FCloseButton.Width := r.Right - r.Left;
          FCloseButton.Height := r.Bottom - r.Top;
          FCloseButton.Tag := i;
          FCloseButton.Glyph.Assign(ButtonSettings.CloseButtonPicture);
          FCloseButton.Hint := ButtonSettings.CloseButtonHint;
          FCloseButton.ShowHint := True;
          FCloseButton.Enabled := GetVisibleTabCount > 0;
          // (ActivePage <> nil);

          FCloseButton.Visible := ShowCloseOnNonSelectedTabs or
            ((ActivePageIndex = i)
              and not ShowCloseOnNonSelectedTabs and ShowClose);
          if not FCloseButton.Visible then
            FCloseButton.Width := 0;
        end
        else
        begin
          if Assigned(FCloseButton) then
            FCloseButton.Visible := False;
        end;
      end;
    end;
  end
  else
  begin
    for i := 0 to TabSheetBrowserCount - 1 do
    begin
      with TabSheetBrowser[i] do
      begin
        if (FCloseButton <> nil) then
        begin
          PostMessage(Handle, WM_OPDESTROYCLOSEBTN, Integer
              (Pointer(FCloseButton)), 0);
          FCloseButton := nil;
        end;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.OnCloseButtonClick(Sender: TObject);
var
  Allow: Boolean;
  ActTabIndex: Integer;
  NewActivePage: TTabSheetBrowser;
  i: Integer;
begin
  if (Sender is TSpeedButton) then
  begin
    i := (Sender as TSpeedButton).Tag
  end
  else
    i := ActivePageIndex;

  if (i >= 0) and not FIsClosing then
  begin
    Allow := True;
    FIsClosing := True;
    if Assigned(FOnClosePage) then
      FOnClosePage(Self, i, Allow);

    if Allow then
    begin
      if Assigned(TabSheetBrowser[i].FTimer) then
        FreeAndNil(TabSheetBrowser[i].FTimer);

      ActTabIndex := i;
      SelectNextPage(True);
      NewActivePage := ActivePage;
      InvalidateTab(-1);

      if FreeOnClose then
      begin
        if Assigned(TabSheetBrowser[ActTabIndex].FCloseButton) then
        begin
          PostMessage(Handle, WM_OPDESTROYCLOSEBTN, Integer
              (Pointer(TabSheetBrowser[ActTabIndex].FCloseButton)), 0);
          TabSheetBrowser[ActTabIndex].FCloseButton := nil;
        end;

        TabSheetBrowser[ActTabIndex].Free;

        FActivePageIndex := -1;
        ActivePage := NewActivePage;
        // SelectNextPage(True);
      end
      else if (ActTabIndex >= 0) then
      begin
        TabSheetBrowser[ActTabIndex].TabVisible := False;
        TabSheetBrowser[ActTabIndex].Visible := False;
        if Assigned(TabSheetBrowser[ActTabIndex].FCloseButton) then
          TabSheetBrowser[ActTabIndex].FCloseButton.Visible := False;
      end;

      TabWidth;
      UpdateButtonsPos;

      if Assigned(ActivePage) then
        ActivePage.Invalidate
      else
        Invalidate;

      if Assigned(FOnClosedPage) then
        FOnClosedPage(Self, ActTabIndex);
    end;
    FIsClosing := False;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMKeyDown(var Message: TWMKeyDown);
var
  Ctrl: TWinControl;
begin
  case Message.CharCode of
    VK_LEFT, VK_UP:
      begin
        SelectNextPage(False);
      end;
    VK_RIGHT, VK_DOWN:
      begin
        SelectNextPage(True);
      end;
    { VK_DOWN:
      begin
      if Assigned(ActivePage) and Focused and (ActivePage.ControlCount > 0) then
      begin
      ATB := ActivePage.GetFirstToolBar(True);
      ATB.SetFocus;
      HideShortCutHintOfAllPages;
      ActivePage.ShowShortCutHintOfAllToolBars;
      end;
      end; }
    // VK_ESCAPE:
    // begin
    //
    // end;
    VK_TAB:
      begin
        if Assigned(Self.Parent) then
        begin
          Ctrl := TProWinControl(Self.Parent).FindNextControl
            (Self, True, True, True);
          if Assigned(Ctrl) and Ctrl.CanFocus then
          begin
            Ctrl.SetFocus;
          end;
        end;
      end;
  end;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS { + DLGC_WANTTAB } ;
  { using DLGC_WANTTAB, disabled default Tab key functioning }
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMDialogKey(var Message: TCMDialogKey);
begin
  (* if TabStop and Assigned(ActivePage) and (Message.CharCode = 18{ALT}) then
    begin
    if not FTabShortCutHintShowing and (CanFocus) then
    begin
    if not Focused then
    Self.SetFocus;
    Message.Result := 1;
    ShowShortCutHintOfAllPages;
    Exit;
    end
    else if FTabShortCutHintShowing then
    begin
    HideShortCutHintOfAllPages;
    Message.Result := 1;
    Exit;
    end;
    end; *)
  if (Focused or Windows.IsChild(Handle, Windows.GetFocus)) and
    (Message.CharCode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then
  begin
    SelectNextPage(GetKeyState(VK_SHIFT) >= 0);
    Message.Result := 1;
  end
  else
    inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.CMFocusChanged(var Message: TCMFocusChanged);
{ var
  i: Integer;
  h: HWND;
  Active: Boolean; }
begin
  inherited;

  { Active := Self.Focused;
    if not Active and (Message.Sender <> Self) and (self.HandleAllocated) then
    begin
    h := GetFocus;
    i := 1;
    while (h <> 0) do
    begin
    if (h = self.Handle) then
    begin
    Active := True;
    Break;
    end;
    h := GetParent(h);
    inc(i);
    if (i > 50) then
    Break;
    end;
    end;
    }
  InvalidateTab(-1);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMKillFocus(var Message: TWMSetFocus);
begin
  inherited;

end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WndProc(var Msg: TMessage);
var
  p: TWinControl;
  cb: TSpeedButton;
begin
  if (Msg.Msg = WM_DESTROY) then
  begin
    // restore subclassed proc
    if not(csDesigning in ComponentState) and Assigned(FFormWndProc) then
    begin
      p := Self;
      repeat
        p := p.Parent;
      until (p is TForm) or not Assigned(p);

      if (p <> nil) then
      begin
        p.WindowProc := FFormWndProc;
        FFormWndProc := nil;
      end;
    end;
  end
  else if (Msg.Msg = WM_OPDESTROYCLOSEBTN) then
  begin
    if (Msg.WParam <> 0) then
    begin
      cb := TSpeedButton(Pointer(Msg.WParam));
      cb.Free;
    end;
  end;

  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.DragDrop(Source: TObject; X, Y: Integer);
var
  CurIndex, NewIndex: Integer;
begin
  inherited;
  CurIndex := ActivePageIndex;
  NewIndex := PTOnTab(X, Y);
  if (CurIndex >= 0) and (CurIndex < TabSheetBrowserCount) and (NewIndex >= 0)
    and (NewIndex < TabSheetBrowserCount) and (CurIndex <> NewIndex) then
  begin
    MovePage(CurIndex, NewIndex);
    Invalidate;
    if Assigned(ActivePage) then
      ActivePage.Invalidate;
  end;
end;

procedure TPageBrowser.CMDockClient(var Message: TCMDockClient);
var
  IsVisible: Boolean;
  DockCtl: TControl;
  i: Integer;
begin
  Message.Result := 0;
  DockCtl := Message.DockSource.Control;
  { First, look and see if the page is already docked. If it is,
    then simply move the page index to the end }
  for i := 0 to TabSheetBrowserCount - 1 do
  begin
    if DockCtl.Parent = TabSheetBrowser[i] then
    begin
      { We did find it; just move the page to the end }
      TabSheetBrowser[i].PageIndex := TabSheetBrowserCount - 1;
      Exit;
    end;
  end;

  FNewPage := TTabSheetBrowser.Create(Self);
  try
    try
      FNewPage.PageBrowser := Self;
      DockCtl.Dock(Self, Message.DockSource.DockRect);
    except
      FNewPage.Free;
      raise ;
    end;
    IsVisible := DockCtl.Visible;
    FNewPage.TabVisible := IsVisible;
    if IsVisible then
      ActivePage := FNewPage;
    DockCtl.Align := alClient;

    if DockCtl is TCustomForm then
    begin
      FNewPage.Caption := TCustomForm(DockCtl).Caption;
    end;

  finally
    FNewPage := nil;
  end;
end;

procedure TPageBrowser.CMDockNotification(var Message: TCMDockNotification);
var
  i: Integer;
  s: string;
  Page: TTabSheetBrowser;
begin
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
    case Message.NotifyRec.ClientMsg of
      WM_SETTEXT:
        begin
          s := PChar(Message.NotifyRec.MsgLParam);
          { Search for first CR/LF and end string there }
          for i := 1 to Length(s) do
{$IFDEF DELPHI_UNICODE}
            if CharInSet(s[i], [#13, #10]) then
{$ENDIF}
{$IFNDEF DELPHI_UNICODE}
              if s[i] in [#13, #10] then
{$ENDIF}
              begin
                SetLength(s, i - 1);
                Break;
              end;

          if (Message.Client is TCustomForm) then
            Page.Caption := (Message.Client as TCustomForm).Caption
          else
            Page.Caption := s;

        end;
      CM_VISIBLECHANGED:
        Page.TabVisible := Boolean(Message.NotifyRec.MsgWParam);
    end;
  inherited;
end;

procedure TPageBrowser.CMUnDockClient(var Message: TCMUnDockClient);
var
  Page: TTabSheetBrowser;
begin
  Message.Result := 0;
  Page := GetPageFromDockClient(Message.Client);
  if Page <> nil then
  begin
    FUndockPage := Page;
    Message.Client.Align := alNone;
  end;
end;

procedure TPageBrowser.DoAddDockClient(Client: TControl; const ARect: TRect);
begin
  if FNewPage <> nil then
    Client.Parent := FNewPage;
end;

procedure TPageBrowser.DockOver(Source: TDragDockObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  r: TRect;
begin
  GetWindowRect(Handle, r);
  Source.DockRect := r;
  DoDockOver(Source, X, Y, State, Accept);
end;

procedure TPageBrowser.DoRemoveDockClient(Client: TControl);
begin
  if (FUndockPage <> nil) and not(csDestroying in ComponentState) then
  begin
    SelectNextPage(True);
    FUndockPage.Free;
    FUndockPage := nil;
  end;
end;

function TPageBrowser.GetPageFromDockClient(Client: TControl): TTabSheetBrowser;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to TabSheetBrowserCount - 1 do
  begin
    if (Client.Parent = TabSheetBrowser[i]) and (Client.HostDockSite = Self)
      then
    begin
      Result := TabSheetBrowser[i];
      Exit;
    end;
  end;
end;



// ------------------------------------------------------------------------------

procedure TPageBrowser.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i: Integer;
begin
  inherited;
  i := PTOnTab(X, Y);
  Accept := (i >= 0) and (i < TabSheetBrowserCount) and (Source = Self);
end;

// ------------------------------------------------------------------------------

function TPageBrowser.UseOldDrawing: Boolean;
begin
  Result := (TabSettings.Shape = tsRectangle) and (TabSettings.Rounding = 1);
  if not Result and (TabPosition in [tpLeft, tpRight])
    and not RotateTabLeftRight then
    Result := (TabSettings.Rounding = 1);
end;

// ------------------------------------------------------------------------------

function TPageBrowser.IsActivePageNeighbour(PageIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  if (PageIndex = ActivePageIndex) or (PageIndex < 0) or
    (PageIndex >= TabSheetBrowserCount) then
    Exit;

  if (PageIndex < ActivePageIndex) then
  begin
    for i := ActivePageIndex - 1 downto PageIndex do
    begin
      if TabSheetBrowser[i].TabVisible then
      begin
        if (i = PageIndex) then
          Result := -1;
        Break;
      end;
    end;
  end
  else // if (PageIndex > ActivePageIndex) then
  begin
    for i := ActivePageIndex + 1 to PageIndex do
    begin
      if TabSheetBrowser[i].TabVisible then
      begin
        if (i = PageIndex) then
          Result := 1;
        Break;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetLeftRoundingOffset: Integer;
begin
  Result := 0;
  if (TabSettings.Shape in [tsLeftRamp, tsLeftRightRamp])
    and not UseOldDrawing and not((TabPosition in [tpLeft, tpRight])
      and not RotateTabLeftRight) then
    Result := TabSettings.Rounding * 2 + 5;
end;

// ------------------------------------------------------------------------------

function TPageBrowser.GetRightRoundingOffset: Integer;
begin
  Result := 0;
  if (TabSettings.Shape in [tsRightRamp, tsLeftRightRamp])
    and not UseOldDrawing and not((TabPosition in [tpLeft, tpRight])
      and not RotateTabLeftRight) then
    Result := TabSettings.Rounding * 2 + 5;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.SetPageValidCache(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to TabSheetBrowserCount - 1 do
    TabSheetBrowser[i].FValidCache := Value;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.UpdatePageAppearanceOfPages;
var
  i: Integer;
begin
  if not(csDesigning in ComponentState) or not Assigned(FPageBrowserStyler) then
    Exit;

  for i := 0 to TabSheetBrowserCount - 1 do
  begin
    if not TabSheetBrowser[i].UsePageAppearance then
      TabSheetBrowser[i].PageAppearance.Assign
        (FPageBrowserStyler.PageAppearance);
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.UpdateTabAppearanceOfPages;
var
  i: Integer;
begin
  if not(csDesigning in ComponentState) or not Assigned(FPageBrowserStyler) then
    Exit;

  for i := 0 to TabSheetBrowserCount - 1 do
  begin
    if not TabSheetBrowser[i].UseTabAppearance then
      TabSheetBrowser[i].TabAppearance.Assign(FPageBrowserStyler.TabAppearance);
  end;
end;

// ------------------------------------------------------------------------------

type
  TOverrideControl = class(TControl)
  end;

procedure TPageBrowser.WMLButtonDown(var Message: TWMLButtonDown);

var
  DockCtl: TControl;
  p: TPoint;
begin
  inherited;
  p := Point(Message.XPos, Message.YPos);
  DockCtl := GetDockClientFromMousePos(p);
  if (DockCtl <> nil) then
    if (TOverrideControl(DockCtl).DragMode = dmAutomatic) and
      (TOverrideControl(DockCtl).DragKind = dkDock) then
      DockCtl.BeginDrag(False);
end;

// ------------------------------------------------------------------------------

procedure TPageBrowser.WMLButtonDblClk(var Message: TWMLButtonDblClk);

var
  Tab: Integer;
  p: TPoint;
  DockCtl: TControl;

begin
  inherited;

  p := Point(Message.XPos, Message.YPos);

  DockCtl := GetDockClientFromMousePos(p);
  if DockCtl <> nil then
    DockCtl.ManualDock(nil, nil, alNone);

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(p.X, p.Y);
    if (Tab >= 0) then
    begin
      if Assigned(FOnTabDblClick) then
        FOnTabDblClick(Self, Tab);
    end;
  end;
end;

procedure TPageBrowser.TabWidth;

var
  VWidth: Integer;
begin
  if TabSheetBrowserCount > 0 then
  begin
    VWidth := ((Width - (TabSettings.Height * 2) - 20)
        div TabSheetBrowserCount);
    if VWidth > 205 then
      VWidth := 205;
    TabSettings.Width := VWidth + 12;
  end;
end;

// ------------------------------------------------------------------------------

{ TPageButtonSettings }

constructor TPageButtonSettings.Create;
begin
  inherited;
  FCloseButton := False;

  FCloseButtonPicture := TPicture.Create;
  FCloseButtonPicture.Bitmap.LoadFromResourceName(HInstance, 'CLOSETAB');

  FCloseButtonHint := 'Close Page';

end;

// ------------------------------------------------------------------------------

destructor TPageButtonSettings.Destroy;
begin
  FCloseButtonPicture.Free;
  inherited;
end;

// ------------------------------------------------------------------------------

procedure TPageButtonSettings.Assign(Source: TPersistent);
begin
  if (Source is TPageButtonSettings) then
  begin
    FCloseButton := (Source as TPageButtonSettings).FCloseButton;
    FCloseButtonPicture.Assign((Source as TPageButtonSettings)
        .FCloseButtonPicture);
  end
  else
    inherited Assign(Source);
end;

// ------------------------------------------------------------------------------

procedure TPageButtonSettings.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

// ------------------------------------------------------------------------------

procedure TPageButtonSettings.SetCloseButton(const Value: Boolean);
begin
  if (FCloseButton <> Value) then
  begin
    FCloseButton := Value;
    Changed;
  end;
end;

// ------------------------------------------------------------------------------

procedure TPageButtonSettings.SetCloseButtonPicture(const Value: TPicture);
begin
  FCloseButtonPicture.Assign(Value);
  Changed;
end;

constructor TTreeTab.Create(AOwner: TComponent);
begin
  inherited;
  Height := 300;
  Width := 500;
  FSelList := TList.Create;
  FBackList := TList.Create;
  FB := TBitmap.Create;

  FMainPageBrowser := TPageBrowser.Create(Self);
  with FMainPageBrowser do
  begin
    Parent := Self;
    Name := 'MainPageBrowser';
    Anchors := AnchorAlign[alClient];
    BoundsRect := Self.BoundsRect;
  end;

  FTabSheetList := TList.Create;
  with FMainPageBrowser do
  begin
    OnTabClick := OnPageBrowserTabClick;
    OnClosePage := OnPageBrowserClosePage;
    ButtonNewTab.OnClick := OnButtonNewTabClick;
    ButtonNewSubtab.OnClick := OnButtonNewSubtabClick;
  end;

  FPinBtn := TSpeedButton.Create(Self);
  With FPinBtn do
  begin
    Parent := FMainPageBrowser;
    Flat := True;
    Height := 16;
    Width := 20;
    GroupIndex := 1;
    AllowAllUp := True;
    Glyph.LoadFromResourceName(HInstance, 'PIN');
    Left := FMainPageBrowser.Width - FPinBtn.Width - 1;
    OnClick := OnPinClick;
    Anchors := [akRight, akTop];
  end;

  FTimer := TTimer.Create(Self);
  with FTimer do
  begin
    Interval := 1000;
    Enabled := False;
    OnTimer := OnTimerCheck;
  end;

  FbMoving := False;

  FPoped := False;

  if (csDesigning in ComponentState) then
    Exit;
end;

destructor TTreeTab.Destroy;
begin
  FTabSheetList.Free;
  FSelList.Free;
  FBackList.Free;
  FB.Free;
  inherited;
end;

function TTreeTab.GetExplorerTreeComboBox: TExplorerTreeComboBox;
begin
  if not Assigned(FExplorerTreeComboBox) then
    FExplorerTreeComboBox := nil;
  Result := FExplorerTreeComboBox;
end;

function TTreeTab.GetTreeView: TTreeViewNew;
begin
  if not Assigned(FTreeViewNew) then
    FTreeViewNew := nil;
  Result := FTreeViewNew;
end;

procedure TTreeTab.OnTimerCheck(Sender: TObject);
var
  CurPos: TPoint;
  LeftTop: TPoint;
  RightBottum: TPoint;
begin
  if FbMoving or FStayOn then
    Exit;
  LeftTop.X := 0;
  LeftTop.Y := 0;
  RightBottum.X := inherited Width;

  if Selected.PageBrowserChild.Visible then
    RightBottum.Y := -(FnTop - FMainPageBrowser.Top) +
      (FMainPageBrowser.TabSettings.Height + 2) * 3
  else
    RightBottum.Y := -(FnTop - FMainPageBrowser.Top)
      + FMainPageBrowser.TabSettings.Height + 2;

  GetCursorPos(CurPos);

  LeftTop := ClientToScreen(LeftTop);
  RightBottum := ClientToScreen(RightBottum);

  if ((CurPos.X > LeftTop.X) and (CurPos.X < RightBottum.X) and
      (CurPos.Y > LeftTop.Y) and (CurPos.Y < RightBottum.Y)) then
    Exit; // in

  // out
  Push(FQuickMove);
end;

procedure TTreeTab.OnTreeViewButtonAddClick(Sender: TObject);
begin
  Selected := add(TTabSheetBrowser(TFormTab(TSpeedButton(Sender).Parent)
        .FTreeNode.data).FTabSheetParent);
end;

procedure TTreeTab.OnTreeViewButtonAddSubClick(Sender: TObject);
begin
  Selected := add(TTabSheetBrowser(TFormTab(TSpeedButton(Sender).Parent)
        .FTreeNode.data));
end;

procedure TTreeTab.OnTreeViewButtonDeleteClick(Sender: TObject);
begin
  Remove(TTabSheetBrowser(TFormTab(TSpeedButton(Sender).Parent).FTreeNode.data)
    );
end;

procedure TTreeTab.OnTreeViewButtonGoClick(Sender: TObject);
begin
  TTabSheetBrowser(TFormTab(TSpeedButton(Sender).Parent).FTreeNode.data)
    .FWebBrowser.Navigate(TTreeViewNew(TFormTab(TSpeedButton(Sender).Parent).FTreeNode.TreeView).URLNew);
end;

procedure TTreeTab.OnTreeViewChange(Sender: TObject; Node: TTreeNode);
begin
  Selected := TTabSheetBrowser(Node.data);
  if not FStayOn then
    Push;
end;

procedure TTreeTab.OnPinClick(Sender: TObject);
  procedure RoundPicture(SrcBuf: TBitmap);
  var
    Buf: TBitmap;
    i, j: Integer;
  begin
    Buf := TBitmap.Create();

    Buf.Width := SrcBuf.Height;
    Buf.Height := SrcBuf.Width;

    for i := 0 to SrcBuf.Height do
      for j := 0 to SrcBuf.Width do
        Buf.Canvas.Pixels[i, j] := SrcBuf.Canvas.Pixels
          [j, SrcBuf.Height - i - 1];

    SrcBuf.Height := Buf.Height;
    SrcBuf.Width := Buf.Width;
    SrcBuf.Canvas.Draw(0, 0, Buf);

    Buf.Free();
  end;

begin
  FTimer.Enabled := not FPinBtn.Down;
  FPinBtn.Glyph.LoadFromResourceName(HInstance, 'PIN');
  if FPinBtn.Down then
    RoundPicture(FPinBtn.Glyph);
  FStayOn := FPinBtn.Down;
  if FStayOn then
  begin
    Pop;
    if Assigned(FOnPin) then
      FOnPin(Self);
  end
  else
  begin
    Push;
    if Assigned(FOnUnPin) then
      FOnUnPin(Self);
  end;
end;

procedure TTreeTab.OnPageBrowserMouseEnterTab(Sender: TObject;
  ATabSheetBrowser: TTabSheetBrowser);
// var
// Form: TCustomForm;
begin
  // Form := GetParentForm(self);
  // if Form = nil then
  // Exit;
  // if (not Form.Active) and ((Form as TForm).FormStyle <> fsMDIForm) then
  // Exit;

  if FbMoving or FPoped or (FSelList.Count < 1) then
    Exit;
  Pop(FQuickMove);
end;

procedure TTreeTab.Pop(bQuick: Boolean = True);
var
  i, j: Integer;
begin
  FbMoving := True;
  with FMainPageBrowser do
  begin
    if not bQuick then
    begin
      FB.SetSize(Width, Height);
      PaintTo(FB.Canvas, 0, 0);
      i := FnTop div FSelList.Count;
      j := FnTop - (FnTop - FMainPageBrowser.Top);
      Visible := False;
      while j < 0 do
      begin
        Self.Canvas.Draw(0, j, FB);
        j := j - i;
        Sleep(30);
      end;
      Self.Canvas.Draw(0, 0, FB);
    end;
    Height := Self.Height;
    Top := 0;
    Visible := True;
  end;
  Repaint;
  Application.ProcessMessages;

  FTimer.Enabled := True;
  FbMoving := False;
  FPoped := True;
  if Assigned(FOnPop) then
    FOnPop(Self);
end;

procedure TTreeTab.Push(bQuick: Boolean = True);
var
  i, j: Integer;
  RSource, RDest: TRect;
begin
  FbMoving := True;
  FPoped := False;
  FTimer.Enabled := False;
  with FMainPageBrowser do
  begin
    if not bQuick then
    begin
      FB.SetSize(Width, Height);
      PaintTo(FB.Canvas, 0, 0);
      RSource := FMainPageBrowser.BoundsRect;
      RSource.Top := RSource.Bottom - 30;
      RSource.Bottom := RSource.Bottom - 15;
      RDest := BoundsRect;
      RDest.Top := RDest.Bottom - 15;
      FB.Canvas.CopyRect(RDest, FB.Canvas, RSource);
      i := FnTop div FSelList.Count;
      j := FnTop - (FnTop - FMainPageBrowser.Top);
      Visible := False;
      while j > FnTop do
      begin
        Self.Canvas.Draw(0, j, FB);
        j := j + i;
        Sleep(30);
      end;
      Self.Canvas.Draw(0, FnTop, FB);
      Visible := True;
    end;

    Height := Self.Height - FnTop;
    Top := FnTop;
  end;
  Repaint;
  Application.ProcessMessages;
  FbMoving := False;
  if Assigned(FOnPush) then
    FOnPush(Self);
end;

function TTreeTab.SelectBack: Boolean;
var
  i:Integer;
begin
  Result := False;
  if Assigned(FSelected) then
  begin
    i:=FBackList.IndexOf(FSelected);
    if i>0 then
    begin
      FBack := True;
      Selected := FBackList[i-1];
      FBack := False;
    end;
  end;
end;

function TTreeTab.SelectForward: Boolean;
var
  i:Integer;
begin
  Result := False;
  if Assigned(FSelected) then
  begin
    i:=FBackList.IndexOf(FSelected);
    if i<FBackList.Count-1 then
    begin
      FBack := True;
      Selected := FBackList[i+1];
      FBack := False;
    end;
  end;
end;

procedure TTreeTab.SelectExplorerTreeComboBox;
begin
  if Assigned(FExplorerTreeComboBox) then
  begin
    FExplorerTreeComboBox.OnSelect := nil;
    FExplorerTreeComboBox.SelectedNode := FSelected.FTreeNodeETC;
    FExplorerTreeComboBox.OnSelect := OnExplorerTreeComboBoxSelect;
  end;
end;

procedure TTreeTab.SelectTreeView;
begin
  if Assigned(FTreeViewNew) then
  begin
    FTreeViewNew.OnChange := nil;
    FTreeViewNew.Selected := FSelected.FTreeNodeTV;
    FTreeViewNew.OnChange := OnTreeViewChange;
  end;
end;

procedure TTreeTab.SetExplorerTreeComboBox(const Value: TExplorerTreeComboBox);
begin
  FExplorerTreeComboBox := Value;
  if Assigned(FExplorerTreeComboBox) then
    FExplorerTreeComboBox.OnSelect := OnExplorerTreeComboBoxSelect;
end;

procedure TTreeTab.SetImages(const Value: TCustomImageList);
begin
  if FImages = Value then
    Exit;
  FImages := Value;
  FMainPageBrowser.Images := FImages
end;

procedure TTreeTab.SetSelected(const Value: TTabSheetBrowser);
var
  i: Integer;
begin
  if (FSelected = Value) or not Assigned(Value) then
    Exit;

  if Assigned(Value) and not FBack then
  begin
    FBackList.Remove(Value);
    FBackList.Add(Value);
  end;


  with Value do
  begin
    FOldSelected := FSelected;
    FSelected := Value;
    FSelList.Clear;
    while Assigned(FSelected) do
    begin
      FSelList.add(FSelected);
      FSelected := FSelected.TabSheetParent;
    end;
    FnTop := 0;
    for i := 1 to FSelList.Count do
    begin
      FSelected := TTabSheetBrowser(FSelList[FSelList.Count - i]);
      with FSelected do
      begin
        with FPageBrowser do
        begin
          OnShow := nil;
          ActivePage := FSelected;
          OnShow := OnPageBrowserShow;
          if FPageBrowser <> FMainPageBrowser then
          begin
            if Top <> 0 then
              Top := 0;
            Anchors := AnchorAlign[alClient];
            FnTop := FnTop - (TabSettings.Height);
            Height := FMainPageBrowser.ClientHeight + FnTop - 1;
          end;
        end;
        Toolbar.Visible := False;
      end;
    end;

    if Assigned(FOldSelected) then
    begin
      FOldSelected.UseTabAppearance := False;
      FOldSelected.UsePageAppearance := False;
    end;
    UseTabAppearance := True;
    UsePageAppearance := True;

    FPinBtn.Parent := Parent;

    FPageBrowser.OnMouseEnterTab := OnPageBrowserMouseEnterTab;

    if FPageBrowserChild.Visible then
    begin
      with FPageBrowserChild do
      begin
        ActivePageIndex := -1;
        Height := TabSettings.Height + 2;
        Top := 30; // Value.FToolbar.Height;
        Anchors := AnchorAlign[alTop];
        OnMouseEnterTab := nil;
      end;
      FPanelWebBrowser.Top := FPageBrowserChild.Top +
        FPageBrowserChild.Height + 5;
    end
    else
    begin
      FPanelWebBrowser.Top := FToolbar.Height + 10;
      FHeighta := 35;
    end;
    FPanelWebBrowser.Height := Selected.ClientHeight - FPanelWebBrowser.Top - 5;

    FToolbar.Visible := True;
  end;
  FSelected := Value;
  SelectExplorerTreeComboBox;
  SelectTreeView;
end;

procedure TTreeTab.SetStayOn(const Value: Boolean);
begin
  FStayOn := Value;

  if Value then
  begin
    if not(csDesigning in ComponentState) and (FSelList.Count > 0) then
      Pop(FQuickMove);
    FPinBtn.Down := True;
  end
  else
  begin
    FPinBtn.Down := False;
    if not(csDesigning in ComponentState) and not(csLoading in ComponentState)
      and (FSelList.Count > 0) then
      Push(True);
  end;
end;

procedure TTreeTab.SetTreeView(const Value: TTreeViewNew);
begin
  FTreeViewNew := Value;
  if not Assigned(FTreeViewNew) then
    Exit;
  with FTreeViewNew do
  begin
    OnChange := OnTreeViewChange;
    FFormTab.OnButtonAddClick := OnTreeViewButtonAddClick;
    FFormTab.OnButtonAddSubClick := OnTreeViewButtonAddSubClick;
    FFormTab.OnButtonCloseClick := OnTreeViewButtonDeleteClick;
    FFormEdit.OnButtonGoClick := OnTreeViewButtonGoClick;
  end;
end;

procedure TTreeTab.OnPageBrowserShow(Sender: TObject);
begin
  Selected := TTabSheetBrowser(Sender);
end;

procedure TTreeTab.OnPageBrowserTabClick(Sender: TObject; PageIndex: Integer);
begin
  Selected := TTabSheetBrowser(TPageBrowser(Sender).TabSheetBrowser[PageIndex]);
end;

procedure TTreeTab.OnPageBrowserClosePage(Sender: TObject; PageIndex: Integer;
  var Allow: Boolean);
begin
  Remove(TPageBrowser(Sender).TabSheetBrowser[PageIndex]);
  Allow := False;
end;

procedure TTreeTab.OnButtonNewSubtabClick(Sender: TObject);
begin
  if Assigned(TPageBrowser(TControl(Sender).Parent).ActivePage) then
  begin
    Selected := add(TTabSheetBrowser(TPageBrowser(TControl(Sender).Parent)
          .ActivePage));
  end;
end;

procedure TTreeTab.OnButtonNewTabClick(Sender: TObject);
var
  VTabSheetBrowser: TTabSheetBrowser;
begin
  VTabSheetBrowser := nil;
  if TControl(Sender).Parent.Name <> FMainPageBrowser.Name then
  begin
    VTabSheetBrowser := TTabSheetBrowser(TPageBrowser(TControl(Sender).Parent)
        .Parent);
  end;
  Selected := add(VTabSheetBrowser);
end;

procedure TTreeTab.OnExplorerTreeComboBoxSelect
  (Sender: TObject; Node: TTreeNode);
begin
  Selected := TTabSheetBrowser(Node.data);
  if not FStayOn then
    Push;
end;

function TTreeTab.add(AParent: TTabSheetBrowser; AURL: string = 'about:blank')
  : TTabSheetBrowser;

  procedure SetSelectedStyle;
  begin
    with Result.TabAppearance do
    begin
      BorderColorSelected := $000080FF; // $0060CCF9;
      TextColorSelected := $000061C1;
      ColorSelected := clWhite;
      ColorSelectedTo := $00FDF4EE;
      ColorMirrorSelected := $00FEF9F1;
      ColorMirrorSelectedTo := $00FDF4EE;
      GradientSelected := ggRadial;
      GradientMirrorSelected := ggVertical;
    end;
    with Result.PageAppearance do
    begin
      Color := $00FDF4EE;
      ColorTo := $00F9E2D0;
      ColorMirror := $00F9E2D0;
      ColorMirrorTo := $00FEFAF5;
      Gradient := ggVertical;
      GradientMirror := ggRadial;
    end;
  end;

var
  VTreeNodeETC, VTreeNodeTV: TTreeNode;
begin
  Result := TTabSheetBrowser.Create(Self);
  Result.FTreeTab := Self;
  FTabSheetList.add(Result);
  if Assigned(AParent) then
  begin
    with AParent.PageBrowserChild do
    begin
      AddPage(Result);
      Visible := True;
      AParent.FHeighta := 60;
      Width := AParent.ClientWidth - 1;
    end;
    VTreeNodeETC := AParent.FTreeNodeETC;
    VTreeNodeTV := AParent.FTreeNodeTV;
  end
  else
  begin
    FMainPageBrowser.AddPage(Result);
    VTreeNodeETC := nil;
    VTreeNodeTV := nil;
  end;

  FTimer.Enabled := True;
  with Result do
  begin
    FToolbar := TToolbar.Create(Result);
    FToolbar.Parent := Result;

    FPanelWebBrowser := TPanel.Create(Result);
    with FPanelWebBrowser do
    begin
      Parent := Result;
      Left := 5;
      Width := Result.ClientWidth - 10;
      Anchors := AnchorAlign[alClient];
    end;

    FWebBrowser := TWebBrowser.Create(Result);
    with FWebBrowser do
    begin

      TOleControl(FWebBrowser).Parent := FPanelWebBrowser;
      SendMessage(FWebBrowser.Handle, 0, 0, 0);
      OnBeforeNavigate2 := OnWebBrowserBeforeNavigate2;
      OnDocumentComplete := OnWebBrowserDocumentComplete;
      OnTitleChange := OnWebBrowserTitleChange;
      OnNewWindow2 := OnWebBrowserNewWindow2;
      Align := alClient;
      Navigate(AURL);
    end;

    FPageBrowserChild := TPageBrowser.Create(Self);
    with FPageBrowserChild do
    begin
      Left := 2;
      Visible := False;
      Images := Self.Images;
      OnTabClick := OnPageBrowserTabClick;
      OnClosePage := OnPageBrowserClosePage;
      ButtonNewTab.OnClick := OnButtonNewTabClick;
      ButtonNewSubtab.OnClick := OnButtonNewSubtabClick;
      ShowCloseOnNonSelectedTabs := True;
      Parent := Result;
    end;

    SetSelectedStyle;
    FTabSheetParent := AParent;

    ImageIndex := 0;
    OnShow := OnPageBrowserShow;

    if Assigned(FExplorerTreeComboBox) then
    begin
      FTreeNodeETC := FExplorerTreeComboBox.TreeView.Items.AddChild
        (VTreeNodeETC, FCaption);
      FTreeNodeETC.data := Result;
    end;

    if Assigned(FTreeViewNew) then
    begin
      FTreeNodeTV := FTreeViewNew.Items.AddChild(VTreeNodeTV, FCaption);
      FTreeNodeTV.data := Result;
      // FPageList.FTreeView.FullExpand;
    end;
  end;
end;

procedure TTreeTab.Remove(ATabSheetBrowser: TTabSheetBrowser);
var
  i: Integer;
begin
  if not Assigned(ATabSheetBrowser) or (FTabSheetList.IndexOf(ATabSheetBrowser)
      = -1) then
    Exit;

  if ATabSheetBrowser.FPageBrowserChild.Visible then
  begin
    case Application.MessageBox(
      'This page contains sub-pages. Do you want to close all of them ?', 'Close',
      MB_YESNOCANCEL + MB_ICONWARNING + MB_DEFBUTTON3) of
      IDCANCEL:
        Exit;
      IDNO:
        begin
          for i :=
            0 to ATabSheetBrowser.FPageBrowserChild.TabSheetBrowserCount - 1 do
          begin
            if ATabSheetBrowser <> FSelected then
              ATabSheetBrowser.FPageBrowserChild.ActivePageIndex := -1;
            with ATabSheetBrowser.FPageBrowserChild.TabSheetBrowser[0] do
            begin
              ATabSheetBrowser.FPageBrowser.AddPage
                (ATabSheetBrowser.FPageBrowserChild.TabSheetBrowser[0]);
              FTabSheetParent := ATabSheetBrowser.FTabSheetParent;
              if Assigned(FTabSheetParent) then
              begin
                if Assigned(FExplorerTreeComboBox) then
                  FTreeNodeETC.MoveTo(FTabSheetParent.FTreeNodeETC, naAddChild);
                if Assigned(FTreeViewNew) then
                  FTreeNodeTV.MoveTo(FTabSheetParent.FTreeNodeTV, naAddChild);
              end
              else
              begin
                if Assigned(FExplorerTreeComboBox) then
                  FTreeNodeETC.MoveTo(nil, naAddChild);
                if Assigned(FTreeViewNew) then
                  FTreeNodeTV.MoveTo(nil, naAddChild);
              end;
            end;
          end;
        end;
    end;
  end;
  FTabSheetList.Remove(ATabSheetBrowser);
  with ATabSheetBrowser do
  begin
    if FPageBrowser.TabSheetBrowserCount = 1 then
    begin
      FHeighta := 35;
      if FPageBrowser = FMainPageBrowser then
        Selected := add(nil)
      else
        FPageBrowser.Visible := False;
    end;
    Selected := ATabSheetBrowser.TabSheetParent;
    if Assigned(FExplorerTreeComboBox) then
      FTreeNodeETC.Delete;
    if Assigned(FTreeViewNew) then
      FTreeNodeTV.Delete;
    Delete;
  end;
end;

{ TToolbar }

constructor TToolbar.Create(AOwner: TTabSheetBrowser);
begin
  FButtonBack := TSpeedButton.Create(AOwner);
  with FButtonBack do
  begin
    Flat := True;
    OnClick := OnButtonBackClick;
    Hint := 'Pack page';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'BACK');
  end;

  FButtonForward := TSpeedButton.Create(AOwner);
  with FButtonForward do
  begin
    Flat := True;
    OnClick := OnButtonForwardClick;
    Hint := 'Forward page';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'FORWARD');
  end;

  FButtonBackDown := TSpeedButton.Create(AOwner);
  with FButtonBackDown do
  begin
    Flat := True;
    Width := 11;
    // OnClick := ;
    // Hint := 'Recent Pages';
    // ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'DOWN');
  end;

  FButtonForwardDown := TSpeedButton.Create(AOwner);
  with FButtonForwardDown do
  begin
    Flat := True;
    Width := 11;
    // OnClick := ;
    // Hint := 'Recent Pages';
    // ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'DOWN');
  end;

  FSpeedButtonGo := TSpeedButton.Create(AOwner);
  with FSpeedButtonGo do
  begin
    Flat := True;
    OnClick := OnButtonGoClick;
    Anchors := [akTop, akRight];
    Hint := 'Go';
    ShowHint := True;
    Glyph.LoadFromResourceName(HInstance, 'GO');
  end;

  FComboBox := TComboBox.Create(AOwner); ;
  with FComboBox do
  begin
    OnKeyPress := OnComboBoxKeyPress;
    Anchors := AnchorAlign[alTop];
  end;

  FIcon := TImage.Create(AOwner);
  with FIcon do
  begin
    FIcon.Picture.Bitmap.LoadFromResourceName(HInstance, 'EXPLORER');
    FIcon.BoundsRect := FButtonForward.BoundsRect;
  end;

  Height := 40;
  FSide := 10;
end;

destructor TToolbar.Destroy;
begin
  FButtonBack.Free;
  FButtonForward.Free;
  FSpeedButtonGo.Free;
  FComboBox.Free;
  FIcon.Free;
  inherited;
end;

procedure TToolbar.SetParent(AParent: TWinControl);
begin
  if FParent = AParent then
    Exit;
  FParent := AParent;

  with FButtonBackDown do
  begin
    Parent := FParent;
    Left := FSide;
  end;

  with FButtonBack do
  begin
    Parent := FParent;
    Left := FButtonBackDown.Left + FButtonBackDown.Width; ;
  end;

  with FButtonForward do
  begin
    Parent := FParent;
    Left := FButtonBack.Left + FButtonBack.Width;
  end;

  with FButtonForwardDown do
  begin
    Parent := FParent;
    Left := FButtonForward.Left + FButtonForward.Width;
  end;

  with FSpeedButtonGo do
  begin
    Parent := FParent;
    Left := FParent.ClientWidth - Width - FSide;
  end;

  with FIcon do
  begin
    Parent := FParent;
    Left := FButtonForwardDown.Left + FButtonForwardDown.Width;
  end;

  with FComboBox do
  begin
    Parent := FParent;
    Left := FIcon.Left + FIcon.Width;
    Width := FSpeedButtonGo.Left - Left;
  end;

end;

procedure TToolbar.SetHeight(val: Integer);
begin
  if FHeight = val then
    Exit;
  FHeight := val;
  FControlsTop := (FHeight - FComboBox.Height) div 2;

  FButtonBack.Top := FControlsTop;
  FButtonForward.Top := FControlsTop;
  FButtonBackDown.Top := FControlsTop;
  FButtonForwardDown.Top := FControlsTop;
  FSpeedButtonGo.Top := FControlsTop;
  FComboBox.Top := FControlsTop;
  FIcon.Top := FControlsTop + 2;
end;

procedure TToolbar.SetVisible(val: Boolean);
begin
  if FVisible = val then
    Exit;
  FVisible := val;
  FButtonBack.Visible := FVisible;
  FButtonForward.Visible := FVisible;
  FSpeedButtonGo.Visible := FVisible;
  FComboBox.Visible := FVisible;
  FIcon.Visible := FVisible;
end;

procedure TToolbar.OnComboBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(#13) then
    OnButtonGoClick(Sender);
end;

procedure TToolbar.OnButtonBackClick(Sender: TObject);
begin
  TTabSheetBrowser(Parent).WebBrowser.GoBack;
end;

procedure TToolbar.OnButtonForwardClick(Sender: TObject);
begin
  TTabSheetBrowser(Parent).WebBrowser.GoForward;
end;

procedure TToolbar.OnButtonGoClick(Sender: TObject);
begin
  TTabSheetBrowser(Parent).WebBrowser.Navigate(FComboBox.Text);
end;

{ TEventObject }

constructor TEventObject.Create(const OnEvent: TObjectProcedure);
begin
  inherited Create;
  FOnEvent := OnEvent;
end;

function TEventObject.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TEventObject.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo)
  : HResult;
begin
  Result := E_NOTIMPL;
end;

function TEventObject.GetTypeInfoCount(out Count: Integer): HResult;
begin
  Result := E_NOTIMPL;
end;

function TEventObject.Invoke(DispID: Integer; const IID: TGUID;
  LocaleID: Integer; Flags: Word; var Params; VarResult, ExcepInfo,
  ArgErr: Pointer): HResult;
begin
  if (DispID = DISPID_VALUE) then
  begin
    if Assigned(FOnEvent) then
      FOnEvent;
    Result := S_OK;
  end
  else
    Result := E_NOTIMPL;
end;

procedure Register;
begin
  RegisterComponents('Tree Browser', [TTreeTab]);
end;

initialization

WM_OPDESTROYCLOSEBTN := RegisterWindowMessage('OPDESTROYCLOSEBTN');

end.
