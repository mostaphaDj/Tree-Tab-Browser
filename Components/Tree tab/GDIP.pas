unit GDIP;

{$HPPEMIT ''}
{$HPPEMIT '#pragma link "gdiplus.lib"'}
{$HPPEMIT ''}

{$I ..\DEFS.INC}
{$ALIGN ON}
{$MINENUMSIZE 4}

interface

uses
  Windows, ActiveX, Math, Graphics;


type
  IWinStyle = interface
  ['{41886CF9-1932-4DE4-A90B-6E3D0F181417}']
    procedure ChangeStyle(AWin7: Boolean);
  end;


function IsWin7: Boolean;
procedure SetWin7(AWin7: Boolean);

type
  INT16   = type Smallint;
  {$EXTERNALSYM INT16}
  UINT16  = type Word;
  {$EXTERNALSYM UINT16}
  PUINT16 = ^UINT16;
  {$EXTERNALSYM PUINT16}
  UINT32  = type Cardinal;
  {$EXTERNALSYM UINT32}
  TSingleDynArray = array of Single;

var
  GlowSpeed : integer = 30;


const
  GDIP_NOWRAP = 4096;
  {$EXTERNALSYM GDIP_NOWRAP}
  WINGDIPDLL = 'gdiplus.dll';

//----------------------------------------------------------------------------
// Memory Allocation APIs
//----------------------------------------------------------------------------

{$EXTERNALSYM GdipAlloc}
function GdipAlloc(size: ULONG): pointer; stdcall;
{$EXTERNALSYM GdipFree}
procedure GdipFree(ptr: pointer); stdcall;

(**************************************************************************\
*
*   GDI+ base memory allocation class
*
\**************************************************************************)

type
  TAntiAlias = (aaNone, aaClearType, aaAntiAlias);

  TGdiplusBase = class
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;

//--------------------------------------------------------------------------
// Fill mode constants
//--------------------------------------------------------------------------

  FillMode = (
    FillModeAlternate,        // 0
    FillModeWinding           // 1
  );
  TFillMode = FillMode;

//--------------------------------------------------------------------------
// Quality mode constants
//--------------------------------------------------------------------------

{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM QualityMode}
  QualityMode = (
    QualityModeInvalid   = -1,
    QualityModeDefault   =  0,
    QualityModeLow       =  1, // Best performance
    QualityModeHigh      =  2  // Best rendering quality
  );
  TQualityMode = QualityMode;
{$ELSE}
  {$EXTERNALSYM QualityMode}
  QualityMode = Integer;
  const
    QualityModeInvalid   = -1;
    QualityModeDefault   =  0;
    QualityModeLow       =  1; // Best performance
    QualityModeHigh      =  2; // Best rendering quality
{$ENDIF}

type
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM CompositingQuality}
  CompositingQuality = (
    CompositingQualityInvalid          = ord(QualityModeInvalid),
    CompositingQualityDefault          = ord(QualityModeDefault),
    CompositingQualityHighSpeed        = ord(QualityModeLow),
    CompositingQualityHighQuality      = ord(QualityModeHigh),
    CompositingQualityGammaCorrected,
    CompositingQualityAssumeLinear
  );
  TCompositingQuality = CompositingQuality;
{$ELSE}
  {$EXTERNALSYM CompositingQuality}
  CompositingQuality = Integer;
  const
    CompositingQualityInvalid          = QualityModeInvalid;
    CompositingQualityDefault          = QualityModeDefault;
    CompositingQualityHighSpeed        = QualityModeLow;
    CompositingQualityHighQuality      = QualityModeHigh;
    CompositingQualityGammaCorrected   = 3;
    CompositingQualityAssumeLinear     = 4;

type
  TCompositingQuality = CompositingQuality;
{$ENDIF}

const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatUndefined}
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatMemoryBMP}
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatBMP}
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEMF}
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatWMF}
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatJPEG}
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatPNG}
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatGIF}
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatTIFF}
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatEXIF}
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';
  {$EXTERNALSYM ImageFormatIcon}


type
//--------------------------------------------------------------------------
// Unit constants
//--------------------------------------------------------------------------

  Unit_ = (
    UnitWorld,      // 0 -- World coordinate (non-physical unit)
    UnitDisplay,    // 1 -- Variable -- for PageTransform only
    UnitPixel,      // 2 -- Each unit is one device pixel.
    UnitPoint,      // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,       // 4 -- Each unit is 1 inch.
    UnitDocument,   // 5 -- Each unit is 1/300 inch.
    UnitMillimeter  // 6 -- Each unit is 1 millimeter.
  );
  TUnit = Unit_;

//--------------------------------------------------------------------------
// Dash style constants
//--------------------------------------------------------------------------

  DashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom          // 5
  );
  TDashStyle = DashStyle;


//--------------------------------------------------------------------------
// Various wrap modes for brushes
//--------------------------------------------------------------------------

  WrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp        // 4
  );
  TWrapMode = WrapMode;

//--------------------------------------------------------------------------
// LineGradient Mode
//--------------------------------------------------------------------------

  LinearGradientMode = (
    LinearGradientModeHorizontal,         // 0
    LinearGradientModeVertical,           // 1
    LinearGradientModeForwardDiagonal,    // 2
    LinearGradientModeBackwardDiagonal    // 3
  );
  TLinearGradientMode = LinearGradientMode;

//--------------------------------------------------------------------------
// Line cap constants (only the lowest 8 bits are used).
//--------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM LineCap}
  LineCap = (
    LineCapFlat             = 0,
    LineCapSquare           = 1,
    LineCapRound            = 2,
    LineCapTriangle         = 3,

    LineCapNoAnchor         = $10, // corresponds to flat cap
    LineCapSquareAnchor     = $11, // corresponds to square cap
    LineCapRoundAnchor      = $12, // corresponds to round cap
    LineCapDiamondAnchor    = $13, // corresponds to triangle cap
    LineCapArrowAnchor      = $14, // no correspondence

    LineCapCustom           = $ff, // custom cap

    LineCapAnchorMask       = $f0  // mask to check for anchor or not.
  );
  TLineCap = LineCap;
{$ELSE}
  {$EXTERNALSYM LineCap}
  LineCap = Integer;
  const
    LineCapFlat             = 0;
    LineCapSquare           = 1;
    LineCapRound            = 2;
    LineCapTriangle         = 3;

    LineCapNoAnchor         = $10; // corresponds to flat cap
    LineCapSquareAnchor     = $11; // corresponds to square cap
    LineCapRoundAnchor      = $12; // corresponds to round cap
    LineCapDiamondAnchor    = $13; // corresponds to triangle cap
    LineCapArrowAnchor      = $14; // no correspondence

    LineCapCustom           = $ff; // custom cap

    LineCapAnchorMask       = $f0; // mask to check for anchor or not.

type
  TLineCap = LineCap;
{$ENDIF}

//--------------------------------------------------------------------------
// Region Comine Modes
//--------------------------------------------------------------------------

  CombineMode = (
    CombineModeReplace,     // 0
    CombineModeIntersect,   // 1
    CombineModeUnion,       // 2
    CombineModeXor,         // 3
    CombineModeExclude,     // 4
    CombineModeComplement   // 5 (Exclude From)
  );
  TCombineMode = CombineMode;

//--------------------------------------------------------------------------
// FontStyle: face types and common styles
//--------------------------------------------------------------------------
type
  {$EXTERNALSYM FontStyle}
  FontStyle = Integer;
  const
    FontStyleRegular    = Integer(0);
    FontStyleBold       = Integer(1);
    FontStyleItalic     = Integer(2);
    FontStyleBoldItalic = Integer(3);
    FontStyleUnderline  = Integer(4);
    FontStyleStrikeout  = Integer(8);
  Type
  TFontStyle = FontStyle;

//---------------------------------------------------------------------------
// Smoothing Mode
//---------------------------------------------------------------------------
{$IFDEF DELPHI6_UP}
  {$EXTERNALSYM SmoothingMode}
  SmoothingMode = (
    SmoothingModeInvalid     = ord(QualityModeInvalid),
    SmoothingModeDefault     = ord(QualityModeDefault),
    SmoothingModeHighSpeed   = ord(QualityModeLow),
    SmoothingModeHighQuality = ord(QualityModeHigh),
    SmoothingModeNone,
    SmoothingModeAntiAlias
  );
  TSmoothingMode = SmoothingMode;
{$ELSE}
  SmoothingMode = Integer;
  const
    SmoothingModeInvalid     = QualityModeInvalid;
    SmoothingModeDefault     = QualityModeDefault;
    SmoothingModeHighSpeed   = QualityModeLow;
    SmoothingModeHighQuality = QualityModeHigh;
    SmoothingModeNone        = 3;
    SmoothingModeAntiAlias   = 4;

type
  TSmoothingMode = SmoothingMode;

{$ENDIF}

//---------------------------------------------------------------------------
// Text Rendering Hint
//---------------------------------------------------------------------------

  TextRenderingHint = (
    TextRenderingHintSystemDefault,                // Glyph with system default rendering hint
    TextRenderingHintSingleBitPerPixelGridFit,     // Glyph bitmap with hinting
    TextRenderingHintSingleBitPerPixel,            // Glyph bitmap without hinting
    TextRenderingHintAntiAliasGridFit,             // Glyph anti-alias bitmap with hinting
    TextRenderingHintAntiAlias,                    // Glyph anti-alias bitmap without hinting
    TextRenderingHintClearTypeGridFit              // Glyph CT bitmap with hinting
  );
  TTextRenderingHint = TextRenderingHint;

//---------------------------------------------------------------------------
// StringFormatFlags
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// String format flags
//
//  DirectionRightToLeft          - For horizontal text, the reading order is
//                                  right to left. This value is called
//                                  the base embedding level by the Unicode
//                                  bidirectional engine.
//                                  For vertical text, columns are read from
//                                  right to left.
//                                  By default, horizontal or vertical text is
//                                  read from left to right.
//
//  DirectionVertical             - Individual lines of text are vertical. In
//                                  each line, characters progress from top to
//                                  bottom.
//                                  By default, lines of text are horizontal,
//                                  each new line below the previous line.
//
//  NoFitBlackBox                 - Allows parts of glyphs to overhang the
//                                  bounding rectangle.
//                                  By default glyphs are first aligned
//                                  inside the margines, then any glyphs which
//                                  still overhang the bounding box are
//                                  repositioned to avoid any overhang.
//                                  For example when an italic
//                                  lower case letter f in a font such as
//                                  Garamond is aligned at the far left of a
//                                  rectangle, the lower part of the f will
//                                  reach slightly further left than the left
//                                  edge of the rectangle. Setting this flag
//                                  will ensure the character aligns visually
//                                  with the lines above and below, but may
//                                  cause some pixels outside the formatting
//                                  rectangle to be clipped or painted.
//
//  DisplayFormatControl          - Causes control characters such as the
//                                  left-to-right mark to be shown in the
//                                  output with a representative glyph.
//
//  NoFontFallback                - Disables fallback to alternate fonts for
//                                  characters not supported in the requested
//                                  font. Any missing characters will be
//                                  be displayed with the fonts missing glyph,
//                                  usually an open square.
//
//  NoWrap                        - Disables wrapping of text between lines
//                                  when formatting within a rectangle.
//                                  NoWrap is implied when a point is passed
//                                  instead of a rectangle, or when the
//                                  specified rectangle has a zero line length.
//
//  NoClip                        - By default text is clipped to the
//                                  formatting rectangle. Setting NoClip
//                                  allows overhanging pixels to affect the
//                                  device outside the formatting rectangle.
//                                  Pixels at the end of the line may be
//                                  affected if the glyphs overhang their
//                                  cells, and either the NoFitBlackBox flag
//                                  has been set, or the glyph extends to far
//                                  to be fitted.
//                                  Pixels above/before the first line or
//                                  below/after the last line may be affected
//                                  if the glyphs extend beyond their cell
//                                  ascent / descent. This can occur rarely
//                                  with unusual diacritic mark combinations.

//---------------------------------------------------------------------------

Type

//---------------------------------------------------------------------------
// String alignment flags
//---------------------------------------------------------------------------

  StringAlignment = (
    // Left edge for left-to-right text,
    // right for right-to-left text,
    // and top for vertical
    StringAlignmentNear,
    StringAlignmentCenter,
    StringAlignmentFar
  );
  TStringAlignment = StringAlignment;


//---------------------------------------------------------------------------
// Trimming  flags
//---------------------------------------------------------------------------

  StringTrimming = (
    {
    #define GDIPLUS_STRINGTRIMMING_None 0 && no trimming.
    #define GDIPLUS_STRINGTRIMMING_Character 1 && nearest character.
    #define GDIPLUS_STRINGTRIMMING_Word 2 && nearest wor
    #define GDIPLUS_STRINGTRIMMING_EllipsisCharacter 3 && nearest character, ellipsis at end
    #define GDIPLUS_STRINGTRIMMING_EllipsisWord 4 && nearest word, ellipsis at end
    #define GDIPLUS_STRINGTRIMMING_EllipsisPath 5 && ellipsis in center, favouring last slash-delimited segment
    }
    StringTrimmingNone,
    StringTrimmingCharacter,
    StringTrimmingWord,
    StringTrimmingEllipsisCharacter,
    StringTrimmingEllipsisWord,
    StringTrimmingEllipsisPath
  );
  TStringTrimming = StringTrimming;

//---------------------------------------------------------------------------
// Hotkey prefix interpretation
//---------------------------------------------------------------------------

  HotkeyPrefix = (
    HotkeyPrefixNone,
    HotkeyPrefixShow,
    HotkeyPrefixHide
  );
  THotkeyPrefix = HotkeyPrefix;

//---------------------------------------------------------------------------
// Flush Intention flags
//---------------------------------------------------------------------------

  FlushIntention = (
    FlushIntentionFlush,  // Flush all batched rendering operations
    FlushIntentionSync    // Flush all batched rendering operations
                          // and wait for them to complete
  );
  TFlushIntention = FlushIntention;


  //{$EXTERNALSYM ImageAbort}
  ImageAbort = function: BOOL; stdcall;
  //{$EXTERNALSYM DrawImageAbort}
  DrawImageAbort = ImageAbort;

//--------------------------------------------------------------------------
// Status return values from GDI+ methods
//--------------------------------------------------------------------------
type
  Status = (
    Ok,
    GenericError,
    InvalidParameter,
    OutOfMemory,
    ObjectBusy,
    InsufficientBuffer,
    NotImplemented,
    Win32Error,
    WrongState,
    Aborted,
    FileNotFound,
    ValueOverflow,
    AccessDenied,
    UnknownImageFormat,
    FontFamilyNotFound,
    FontStyleNotFound,
    NotTrueTypeFont,
    UnsupportedGdiplusVersion,
    GdiplusNotInitialized,
    PropertyNotFound,
    PropertyNotSupported
  );
  TStatus = Status;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPPointF = ^TGPPointF;
  TGPPointF = packed record
    X : Single;
    Y : Single;
  end;
  TPointFDynArray = array of TGPPointF;

  function MakePoint(X, Y: Single): TGPPointF; overload;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPPoint = ^TGPPoint;
  TGPPoint = packed record
    X : Integer;
    Y : Integer;
  end;
  TPointDynArray = array of TGPPoint;

  function MakePoint(X, Y: Integer): TGPPoint; overload;

//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPRectF = ^TGPRectF;
  TGPRectF = packed record
    X     : Single;
    Y     : Single;
    Width : Single;
    Height: Single;
  end;
  TRectFDynArray = array of TGPRectF;

  function MakeRect(x, y, width, height: Single): TGPRectF; overload;

type
  PGPRect = ^TGPRect;
  TGPRect = packed record
    X     : Integer;
    Y     : Integer;
    Width : Integer;
    Height: Integer;
  end;
  TRectDynArray = array of TGPRect;


(**************************************************************************
*
*   GDI+ Startup and Shutdown APIs
*
**************************************************************************)
type
  DebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning
  );
  TDebugEventLevel = DebugEventLevel;

  // Callback function that GDI+ can call, on debug builds, for assertions
  // and warnings.

  DebugEventProc = procedure(level: DebugEventLevel; message: PChar); stdcall;

  // Notification functions which the user must call appropriately if
  // "SuppressBackgroundThread" (below) is set.

  NotificationHookProc = function(out token: ULONG): Status; stdcall;

  NotificationUnhookProc = procedure(token: ULONG); stdcall;

  // Input structure for GdiplusStartup

  GdiplusStartupInput = packed record
    GdiplusVersion          : Cardinal;       // Must be 1
    DebugEventCallback      : DebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL;           // FALSE unless you're prepared to call
                                              // the hook/unhook functions properly
    SuppressExternalCodecs  : BOOL;           // FALSE unless you want GDI+ only to use
  end;                                        // its internal image codecs.

  TGdiplusStartupInput = GdiplusStartupInput;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

  // Output structure for GdiplusStartup()

  GdiplusStartupOutput = packed record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.

    NotificationHook  : NotificationHookProc;
    NotificationUnhook: NotificationUnhookProc;
  end;
  TGdiplusStartupOutput = GdiplusStartupOutput;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

  // GDI+ initialization. Must not be called from DllMain - can cause deadlock.
  //
  // Must be called before GDI+ API's or constructors are used.
  //
  // token  - may not be NULL - accepts a token to be passed in the corresponding
  //          GdiplusShutdown call.
  // input  - may not be NULL
  // output - may be NULL only if input->SuppressBackgroundThread is FALSE.

 {$EXTERNALSYM GdiplusStartup}
 function GdiplusStartup(out token: ULONG; input: PGdiplusStartupInput;
   output: PGdiplusStartupOutput): Status; stdcall;

  // GDI+ termination. Must be called before GDI+ is unloaded.
  // Must not be called from DllMain - can cause deadlock.
  //
  // GDI+ API's may not be called after GdiplusShutdown. Pay careful attention
  // to GDI+ object destructors.

  {$EXTERNALSYM GdiplusShutdown}
  procedure GdiplusShutdown(token: ULONG); stdcall;

type
  PARGB  = ^ARGB;
  ARGB   = DWORD;
  {$EXTERNALSYM ARGB}

type

  PGPColor = ^TGPColor;
  {$EXTERNALSYM TGPCOLOR}
  TGPColor = ARGB;

  function MakeColor(r, g, b: Byte): ARGB; overload;
  function MakeColor(a, r, g, b: Byte): ARGB; overload;
  function MakeColor(a: Byte; Color: TColor): ARGB; overload;
  function GetAlpha(color: ARGB): BYTE;
  function GetRed(color: ARGB): BYTE;
  function GetGreen(color: ARGB): BYTE;
  function GetBlue(color: ARGB): BYTE;

const
  // Shift count and bit mask for A, R, G, B
  AlphaShift  = 24;
  {$EXTERNALSYM AlphaShift}
  RedShift    = 16;
  {$EXTERNALSYM RedShift}
  GreenShift  = 8;
  {$EXTERNALSYM GreenShift}
  BlueShift   = 0;
  {$EXTERNALSYM BlueShift}

  AlphaMask   = $ff000000;
  {$EXTERNALSYM AlphaMask}
  RedMask     = $00ff0000;
  {$EXTERNALSYM RedMask}
  GreenMask   = $0000ff00;
  {$EXTERNALSYM GreenMask}
  BlueMask    = $000000ff;
  {$EXTERNALSYM BlueMask}

type
  PixelFormat = Integer;
  {$EXTERNALSYM PixelFormat}
  TPixelFormat = PixelFormat;

const
  PixelFormatIndexed     = $00010000; // Indexes into a palette
  {$EXTERNALSYM PixelFormatIndexed}
  PixelFormatGDI         = $00020000; // Is a GDI-supported format
  {$EXTERNALSYM PixelFormatGDI}
  PixelFormatAlpha       = $00040000; // Has an alpha component
  {$EXTERNALSYM PixelFormatAlpha}
  PixelFormatPAlpha      = $00080000; // Pre-multiplied alpha
  {$EXTERNALSYM PixelFormatPAlpha}
  PixelFormatExtended    = $00100000; // Extended color 16 bits/channel
  {$EXTERNALSYM PixelFormatExtended}
  PixelFormatCanonical   = $00200000;
  {$EXTERNALSYM PixelFormatCanonical}

  PixelFormatUndefined      = 0;
  {$EXTERNALSYM PixelFormatUndefined}
  PixelFormatDontCare       = 0;
  {$EXTERNALSYM PixelFormatDontCare}

  PixelFormat1bppIndexed    = (1  or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat1bppIndexed}
  PixelFormat4bppIndexed    = (2  or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat4bppIndexed}
  PixelFormat8bppIndexed    = (3  or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat8bppIndexed}
  PixelFormat16bppGrayScale = (4  or (16 shl 8) or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat16bppGrayScale}
  PixelFormat16bppRGB555    = (5  or (16 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppRGB555}
  PixelFormat16bppRGB565    = (6  or (16 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppRGB565}
  PixelFormat16bppARGB1555  = (7  or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat16bppARGB1555}
  PixelFormat24bppRGB       = (8  or (24 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat24bppRGB}
  PixelFormat32bppRGB       = (9  or (32 shl 8) or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat32bppRGB}
  PixelFormat32bppARGB      = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  {$EXTERNALSYM PixelFormat32bppARGB}
  PixelFormat32bppPARGB     = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  {$EXTERNALSYM PixelFormat32bppPARGB}
  PixelFormat48bppRGB       = (12 or (48 shl 8) or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat48bppRGB}
  PixelFormat64bppARGB      = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat64bppARGB}
  PixelFormat64bppPARGB     = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  {$EXTERNALSYM PixelFormat64bppPARGB}
  PixelFormatMax            = 15;
  {$EXTERNALSYM PixelFormatMax}

type

{$IFDEF DELPHI6_UP}
  RotateFlipType = (
    RotateNoneFlipNone = 0,
    Rotate90FlipNone   = 1,
    Rotate180FlipNone  = 2,
    Rotate270FlipNone  = 3,

    RotateNoneFlipX    = 4,
    Rotate90FlipX      = 5,
    Rotate180FlipX     = 6,
    Rotate270FlipX     = 7,

    RotateNoneFlipY    = Rotate180FlipX,
    Rotate90FlipY      = Rotate270FlipX,
    Rotate180FlipY     = RotateNoneFlipX,
    Rotate270FlipY     = Rotate90FlipX,

    RotateNoneFlipXY   = Rotate180FlipNone,
    Rotate90FlipXY     = Rotate270FlipNone,
    Rotate180FlipXY    = RotateNoneFlipNone,
    Rotate270FlipXY    = Rotate90FlipNone
  );
  TRotateFlipType = RotateFlipType;
{$ELSE}

  RotateFlipType = (
    RotateNoneFlipNone, // = 0,
    Rotate90FlipNone,   // = 1,
    Rotate180FlipNone,  // = 2,
    Rotate270FlipNone,  // = 3,

    RotateNoneFlipX,    // = 4,
    Rotate90FlipX,      // = 5,
    Rotate180FlipX,     // = 6,
    Rotate270FlipX      // = 7,
  );
  const
    RotateNoneFlipY    = Rotate180FlipX;
    Rotate90FlipY      = Rotate270FlipX;
    Rotate180FlipY     = RotateNoneFlipX;
    Rotate270FlipY     = Rotate90FlipX;

    RotateNoneFlipXY   = Rotate180FlipNone;
    Rotate90FlipXY     = Rotate270FlipNone;
    Rotate180FlipXY    = RotateNoneFlipNone;
    Rotate270FlipXY    = Rotate90FlipNone;

type
  TRotateFlipType = RotateFlipType;
{$ENDIF}

//----------------------------------------------------------------------------
// Color Adjust Type
//----------------------------------------------------------------------------

  //{$EXTERNALSYM ColorAdjustType}
  ColorAdjustType = (
    ColorAdjustTypeDefault,
    ColorAdjustTypeBitmap,
    ColorAdjustTypeBrush,
    ColorAdjustTypePen,
    ColorAdjustTypeText,
    ColorAdjustTypeCount,
    ColorAdjustTypeAny      // Reserved
  );
  TColorAdjustType = ColorAdjustType;

//---------------------------------------------------------------------------
// Image encoder parameter related types
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderParameterValueType}
  EncoderParameterValueType = Integer;
  const
    EncoderParameterValueTypeByte          : Integer = 1;    // 8-bit unsigned int
    EncoderParameterValueTypeASCII         : Integer = 2;    // 8-bit byte containing one 7-bit ASCII
                                                             // code. NULL terminated.
    EncoderParameterValueTypeShort         : Integer = 3;    // 16-bit unsigned int
    EncoderParameterValueTypeLong          : Integer = 4;    // 32-bit unsigned int
    EncoderParameterValueTypeRational      : Integer = 5;    // Two Longs. The first Long is the
                                                             // numerator, the second Long expresses the
                                                             // denomintor.
    EncoderParameterValueTypeLongRange     : Integer = 6;    // Two longs which specify a range of
                                                             // integer values. The first Long specifies
                                                             // the lower end and the second one
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
    EncoderParameterValueTypeUndefined     : Integer = 7;    // 8-bit byte that can take any value
                                                             // depending on field definition
    EncoderParameterValueTypeRationalRange : Integer = 8;    // Two Rationals. The first Rational
                                                             // specifies the lower end and the second
                                                             // specifies the higher end. All values
                                                             // are inclusive at both ends
type
  TEncoderParameterValueType = EncoderParameterValueType;

  //---------------------------------------------------------------------------
// Image encoder value types
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderValue}
  EncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3,
    EncoderValueCompressionCCITT4,
    EncoderValueCompressionRle,
    EncoderValueCompressionNone,
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,
    EncoderValueTransformRotate180,
    EncoderValueTransformRotate270,
    EncoderValueTransformFlipHorizontal,
    EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame,
    EncoderValueLastFrame,
    EncoderValueFlush,
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage
  );
  TEncoderValue = EncoderValue;


//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderParameter}
  EncoderParameter = packed record
    Guid           : TGUID;   // GUID of the parameter
    NumberOfValues : ULONG;   // Number of the parameter values
    Type_          : ULONG;   // Value type, like ValueTypeLONG  etc.
    Value          : Pointer; // A pointer to the parameter values
  end;
  TEncoderParameter = EncoderParameter;
  PEncoderParameter = ^TEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------

  //{$EXTERNALSYM EncoderParameters}
  EncoderParameters = packed record
    Count     : UINT;               // Number of parameters in this structure
    Parameter : array[0..0] of TEncoderParameter;  // Parameter values
  end;
  TEncoderParameters = EncoderParameters;
  PEncoderParameters = ^TEncoderParameters;


//--------------------------------------------------------------------------
// ImageCodecInfo structure
//--------------------------------------------------------------------------

type
  //{$EXTERNALSYM ImageCodecInfo}
  ImageCodecInfo = packed record
    Clsid             : TGUID;
    FormatID          : TGUID;
    CodecName         : PWCHAR;
    DllName           : PWCHAR;
    FormatDescription : PWCHAR;
    FilenameExtension : PWCHAR;
    MimeType          : PWCHAR;
    Flags             : DWORD;
    Version           : DWORD;
    SigCount          : DWORD;
    SigSize           : DWORD;
    SigPattern        : PBYTE;
    SigMask           : PBYTE;
  end;
  TImageCodecInfo = ImageCodecInfo;
  PImageCodecInfo = ^TImageCodecInfo;


const
//---------------------------------------------------------------------------
// Encoder parameter sets
//---------------------------------------------------------------------------

  EncoderCompression      : TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}';
  {$EXTERNALSYM EncoderCompression}
  EncoderColorDepth       : TGUID = '{66087055-ad66-4c7c-9a18-38a2310b8337}';
  {$EXTERNALSYM EncoderColorDepth}
  EncoderScanMethod       : TGUID = '{3a4e2661-3109-4e56-8536-42c156e7dcfa}';
  {$EXTERNALSYM EncoderScanMethod}
  EncoderVersion          : TGUID = '{24d18c76-814a-41a4-bf53-1c219cccf797}';
  {$EXTERNALSYM EncoderVersion}
  EncoderRenderMethod     : TGUID = '{6d42c53a-229a-4825-8bb7-5c99e2b9a8b8}';
  {$EXTERNALSYM EncoderRenderMethod}
  EncoderQuality          : TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}';
  {$EXTERNALSYM EncoderQuality}
  EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  {$EXTERNALSYM EncoderTransformation}
  EncoderLuminanceTable   : TGUID = '{edb33bce-0266-4a77-b904-27216099e717}';
  {$EXTERNALSYM EncoderLuminanceTable}
  EncoderChrominanceTable : TGUID = '{f2e455dc-09b3-4316-8260-676ada32481c}';
  {$EXTERNALSYM EncoderChrominanceTable}
  EncoderSaveFlag         : TGUID = '{292266fc-ac40-47bf-8cfc-a85b89a655de}';
  {$EXTERNALSYM EncoderSaveFlag}


//---------------------------------------------------------------------------
// Private GDI+ classes for internal type checking
//---------------------------------------------------------------------------

type
  GpGraphics = Pointer;

  GpBrush = Pointer;
  GpSolidFill = Pointer;
  GpLineGradient = Pointer;
  GpPathGradient = Pointer;

  GpPen = Pointer;

  GpImage = Pointer;
  GpBitmap = Pointer;
  GpImageAttributes = Pointer;

  GpPath = Pointer;
  GpRegion = Pointer;

  GpFontFamily = Pointer;
  GpFont = Pointer;
  GpStringFormat = Pointer;
  GpFontCollection = Pointer;

  GpStatus          = TStatus;
  GpFillMode        = TFillMode;
  GpWrapMode        = TWrapMode;
  GpUnit            = TUnit;
  GpPointF          = PGPPointF;
  GpPoint           = PGPPoint;
  GpRectF           = PGPRectF;
  GpRect            = PGPRect;
  GpDashStyle       = TDashStyle;
  GpLineCap         = TLineCap;
  GpFlushIntention  = TFlushIntention;

  function GdipCreatePath(brushMode: GPFILLMODE;
    out path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePath}

 (* function GdipClonePath(path: GPPATH;
    out clonePath: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipClonePath}
 *)
  function GdipDeletePath(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeletePath}
 (*
  function GdipStartPathFigure(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipStartPathFigure}
 *)
  function GdipClosePathFigure(path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipClosePathFigure}

  function GdipAddPathLine(path: GPPATH;
    x1, y1, x2, y2: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathLine}

  function GdipAddPathArc(path: GPPATH; x, y, width, height, startAngle,
    sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathArc}

  function GdipAddPathEllipse(path: GPPATH;  x: Single; y: Single;
    width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathEllipse}

  function GdipAddPathPie(path: GPPATH; x: Single; y: Single; width: Single;
    height: Single; startAngle: Single; sweepAngle: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPie}

//----------------------------------------------------------------------------
// Brush APIs
//----------------------------------------------------------------------------

  function GdipDeleteBrush(brush: GPBRUSH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteBrush}

//----------------------------------------------------------------------------
// SolidBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateSolidFill(color: ARGB;
    out brush: GPSOLIDFILL): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateSolidFill}

//----------------------------------------------------------------------------
// LineBrush APIs
//----------------------------------------------------------------------------

  function GdipCreateLineBrushFromRect(rect: GPRECTF; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRect}

  function GdipCreateLineBrushFromRectI(rect: GPRECT; color1: ARGB;
    color2: ARGB; mode: LINEARGRADIENTMODE; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRectI}

  function GdipCreateLineBrushFromRectWithAngle(rect: GPRECTF; color1: ARGB;
    color2: ARGB; angle: Single; isAngleScalable: Bool; wrapMode: GPWRAPMODE;
    out lineGradient: GPLINEGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateLineBrushFromRectWithAngle}

//----------------------------------------------------------------------------
// PathGradientBrush APIs
//----------------------------------------------------------------------------

  function GdipCreatePathGradient(points: GPPOINTF; count: Integer;
    wrapMode: GPWRAPMODE; out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePathGradient}

  function GdipCreatePathGradientFromPath(path: GPPATH;
    out polyGradient: GPPATHGRADIENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePathGradientFromPath}

  function GdipGetPathGradientCenterColor(brush: GPPATHGRADIENT;
    out colors: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterColor}

  function GdipSetPathGradientCenterColor(brush: GPPATHGRADIENT;
    colors: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterColor}

  function GdipGetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientSurroundColorsWithCount}

  function GdipSetPathGradientSurroundColorsWithCount(brush: GPPATHGRADIENT;
    color: PARGB; var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientSurroundColorsWithCount}

  function GdipGetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterPoint}

  function GdipGetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientCenterPointI}

  function GdipSetPathGradientCenterPoint(brush: GPPATHGRADIENT;
    points: GPPOINTF): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterPoint}

  function GdipSetPathGradientCenterPointI(brush: GPPATHGRADIENT;
    points: GPPOINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPathGradientCenterPointI}

  function GdipGetPathGradientPointCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientPointCount}

  function GdipGetPathGradientSurroundColorCount(brush: GPPATHGRADIENT;
    var count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPathGradientSurroundColorCount}

//----------------------------------------------------------------------------
// Pen APIs
//----------------------------------------------------------------------------

  function GdipCreatePen1(color: ARGB; width: Single; unit_: GPUNIT;
    out pen: GPPEN): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreatePen1}

  function GdipDeletePen(pen: GPPEN): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeletePen}

//----------------------------------------------------------------------------
// Graphics APIs
//----------------------------------------------------------------------------

  function GdipFlush(graphics: GPGRAPHICS;
    intention: GPFLUSHINTENTION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFlush}

  function GdipCreateFromHDC(hdc: HDC;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFromHDC}

  function GdipGetImageGraphicsContext(image: GPIMAGE;
    out graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageGraphicsContext}


  function GdipDeleteGraphics(graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteGraphics}

  function GdipGetDC(graphics: GPGRAPHICS; var hdc: HDC): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetDC}

  function GdipReleaseDC(graphics: GPGRAPHICS; hdc: HDC): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipReleaseDC}

  function GdipSetSmoothingMode(graphics: GPGRAPHICS;
    smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetSmoothingMode}

  function GdipGetSmoothingMode(graphics: GPGRAPHICS;
    var smoothingMode: SMOOTHINGMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetSmoothingMode}

  function GdipSetTextRenderingHint(graphics: GPGRAPHICS;
    mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetTextRenderingHint}

  function GdipGetTextRenderingHint(graphics: GPGRAPHICS;
    var mode: TEXTRENDERINGHINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetTextRenderingHint}

 function GdipFillEllipse(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillEllipse}

  function GdipFillEllipseI(graphics: GPGRAPHICS; brush: GPBRUSH; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillEllipseI}

  function GdipDrawRectangle(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawRectangle}

  function GdipDrawRectangleI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawRectangleI}

  function GdipDrawLine(graphics: GPGRAPHICS; pen: GPPEN; x1: Single;
    y1: Single; x2: Single; y2: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawLine}

  function GdipDrawPath(graphics: GPGRAPHICS; pen: GPPEN;
    path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawPath}


  function GdipDrawEllipse(graphics: GPGRAPHICS; pen: GPPEN; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawEllipse}

  function GdipDrawEllipseI(graphics: GPGRAPHICS; pen: GPPEN; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawEllipseI}

  function GdipFillRectangle(graphics: GPGRAPHICS; brush: GPBRUSH; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillRectangle}

  function GdipFillPath(graphics: GPGRAPHICS; brush: GPBRUSH;
    path: GPPATH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipFillPath}

  function GdipDrawImageI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageI}

  function GdipDrawImage(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImage}

  function GdipDrawImageRect(graphics: GPGRAPHICS; image: GPIMAGE; x: Single;
    y: Single; width: Single; height: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRect}

  function GdipDrawImageRectI(graphics: GPGRAPHICS; image: GPIMAGE; x: Integer;
    y: Integer; width: Integer; height: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRectI}

  function GdipGetImageRawFormat(image: GPIMAGE;
  format: PGUID): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageRawFormat}

  function GdipGetPenDashStyle(pen: GPPEN;
    out dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetPenDashStyle}

  function GdipSetPenDashStyle(pen: GPPEN;
    dashstyle: GPDASHSTYLE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPenDashStyle}

  function GdipSetClipRect(graphics: GPGRAPHICS; x: Single; y: Single;
    width: Single; height: Single; combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetClipRect}

  function GdipSetClipRegion(graphics: GPGRAPHICS; region: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetClipRegion}

  function GdipCreateRegionRect(rect: GPRECTF;
    out region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateRegionRect}

  function GdipCreateRegionPath(path: GPPATH;
    out region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateRegionPath}

  function GdipDeleteRegion(region: GPREGION): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteRegion}

  function GdipCombineRegionPath(region: GPREGION; path: GPPATH;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCombineRegionPath}

  function GdipCombineRegionRegion(region: GPREGION; region2: GPREGION;
    combineMode: COMBINEMODE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCombineRegionRegion}

//----------------------------------------------------------------------------
// FontFamily APIs
//----------------------------------------------------------------------------

  function GdipCreateFontFamilyFromName(name: PWCHAR;
    fontCollection: GPFONTCOLLECTION;
    out FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFontFamilyFromName}

  function GdipDeleteFontFamily(FontFamily: GPFONTFAMILY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteFontFamily}

//----------------------------------------------------------------------------
// Font APIs
//----------------------------------------------------------------------------

  function GdipCreateFont(fontFamily: GPFONTFAMILY; emSize: Single;
    style: Integer; unit_: Integer; out font: GPFONT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateFont}

  function GdipDeleteFont(font: GPFONT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteFont}

//----------------------------------------------------------------------------
// Image APIs
//----------------------------------------------------------------------------

  function GdipGetImageDecodersSize(out numDecoders: UINT;
    out size: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageDecodersSize}

  function GdipGetImageDecoders(numDecoders: UINT; size: UINT;
    decoders: PIMAGECODECINFO): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageDecoders}

  function GdipGetImageEncoders(numEncoders: UINT; size: UINT;
    encoders: PIMAGECODECINFO): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageEncoders}

  function GdipGetImageEncodersSize(out numEncoders: UINT;
    out size: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageEncodersSize}

  function GdipSaveImageToFile(image: GPIMAGE;
  filename: PWCHAR;
  clsidEncoder: PGUID;
  encoderParams: PENCODERPARAMETERS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSaveImageToFile}

  function GdipLoadImageFromStream(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromStream}

  function GdipLoadImageFromFileICM(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromFileICM}

  function GdipLoadImageFromFile(filename: PWCHAR;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromFile}

  function GdipLoadImageFromStreamICM(stream: ISTREAM;
  out image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipLoadImageFromStreamICM}

  function GdipDisposeImage(image: GPIMAGE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDisposeImage}

  function GdipGetImageWidth(image: GPIMAGE; var width: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageWidth}

  function GdipGetImageHeight(image: GPIMAGE; var height: UINT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageHeight}

  function GdipGetImageHorizontalResolution(image: GPIMAGE; var resolution: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageHorizontalResolution}

  function GdipGetImageVerticalResolution(image: GPIMAGE; var resolution: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetImageVerticalResolution}


//----------------------------------------------------------------------------
// Text APIs
//----------------------------------------------------------------------------

  function GdipDrawString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; brush: GPBRUSH): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawString}

  function GdipMeasureString(graphics: GPGRAPHICS; string_: PWCHAR;
    length: Integer; font: GPFONT; layoutRect: PGPRectF;
    stringFormat: GPSTRINGFORMAT; boundingBox: PGPRectF;
    codepointsFitted: PInteger; linesFilled: PInteger): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipMeasureString}

  function GdipSetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    hotkeyPrefix: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatHotkeyPrefix}

  function GdipGetStringFormatHotkeyPrefix(format: GPSTRINGFORMAT;
    out hotkeyPrefix: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatHotkeyPrefix}

//----------------------------------------------------------------------------
// String format APIs
//----------------------------------------------------------------------------

  function GdipCreateStringFormat(formatAttributes: Integer; language: LANGID;
    out format: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateStringFormat}

  function GdipDeleteStringFormat(format: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDeleteStringFormat}

  function GdipCloneStringFormat(format: GPSTRINGFORMAT;
    out newFormat: GPSTRINGFORMAT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCloneStringFormat}

  function GdipSetStringFormatAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatAlign}

  function GdipGetStringFormatAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatAlign}

  function GdipSetStringFormatLineAlign(format: GPSTRINGFORMAT;
    align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatLineAlign}

  function GdipGetStringFormatLineAlign(format: GPSTRINGFORMAT;
    out align: STRINGALIGNMENT): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatLineAlign}


  function GdipSetStringFormatTrimming(format: GPSTRINGFORMAT;
    trimming: STRINGTRIMMING): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetStringFormatTrimming}

  function GdipGetStringFormatTrimming(format: GPSTRINGFORMAT;
    out trimming: STRINGTRIMMING): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetStringFormatTrimming}

  function GdipSetCompositingQuality(graphics: GPGRAPHICS;
    compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetCompositingQuality}

  function GdipGetCompositingQuality(graphics: GPGRAPHICS;
    var compositingQuality: COMPOSITINGQUALITY): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipGetCompositingQuality}

  function GdipImageRotateFlip(image: GPIMAGE; rfType: ROTATEFLIPTYPE): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipImageRotateFlip}

  function GdipCreateBitmapFromStreamICM(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromStreamICM}

  function GdipCreateBitmapFromStream(stream: ISTREAM;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromStream}

  function GdipCreateBitmapFromScan0(width: Integer; height: Integer;
    stride: Integer; format: PIXELFORMAT; scan0: PBYTE;
    out bitmap: GPBITMAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateBitmapFromScan0}

  function GdipBitmapGetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    var color: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipBitmapGetPixel}

  function GdipBitmapSetPixel(bitmap: GPBITMAP; x: Integer; y: Integer;
    color: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipBitmapSetPixel}

  function GdipBitmapSetResolution(bitmap: GPBITMAP; xdpi: Single;
    ydpi: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipBitmapSetResolution} 

  function GdipCreateImageAttributes(
    out imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipCreateImageAttributes}

  function GdipDisposeImageAttributes(
    imageattr: GPIMAGEATTRIBUTES): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDisposeImageAttributes}

  function GdipSetImageAttributesColorKeys(imageattr: GPIMAGEATTRIBUTES;
    type_: COLORADJUSTTYPE; enableFlag: Bool; colorLow: ARGB;
    colorHigh: ARGB): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetImageAttributesColorKeys}

  function GdipSetPenEndCap(pen: GPPEN; endCap: GPLINECAP): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipSetPenEndCap}

  function GdipAddPathLine2I(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathLine2I}
  

  function GdipAddPathPolygon(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPolygon}

  function GdipAddPathPolygonI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathPolygonI}

  function GdipAddPathCurveI(path: GPPATH; points: GPPOINT;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurveI}

  function GdipAddPathCurve(path: GPPATH; points: GPPOINTF;
    count: Integer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurve}

  function GdipAddPathCurve2I(path: GPPATH; points: GPPOINT; count: Integer;
    tension: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathCurve2I}

  function GdipResetClip(graphics: GPGRAPHICS): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipResetClip}

  function GdipAddPathBezier(path: GPPATH;
    x1, y1, x2, y2, x3, y3, x4, y4: Single): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipAddPathBezier}
  
  function GdipDrawImageRectRect(graphics: GPGRAPHICS; image: GPIMAGE;
    dstx: Single; dsty: Single; dstwidth: Single; dstheight: Single;
    srcx: Single; srcy: Single; srcwidth: Single; srcheight: Single;
    srcUnit: GPUNIT; imageAttributes: GPIMAGEATTRIBUTES;
    callback: DRAWIMAGEABORT; callbackData: Pointer): GPSTATUS; stdcall;
  {$EXTERNALSYM GdipDrawImageRectRect}


//***************************************************************************
//---------------------------------------------------------------------------
// GDI+ classes for forward reference
//---------------------------------------------------------------------------

type
  TGPGraphics = class;
  TGPPen = class;
  TGPBrush = class;
  TGPFontFamily = class;
  TGPGraphicsPath = class;
  TGPSolidBrush = class;
  TGPLinearGradientBrush = class;
  TGPPathGradientBrush = class;
  TGPFont = class;
  TGPFontCollection = class;

//------------------------------------------------------------------------------
// GPRegion
//------------------------------------------------------------------------------
  TGPRegion = class(TGdiplusBase)
  protected
    nativeRegion: GpRegion;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
    procedure SetNativeRegion(nativeRegion: GpRegion);
  public
    constructor Create(rect: TGPRectF); reintroduce; overload;
    constructor Create(path: TGPGraphicsPath); reintroduce; overload;
    destructor Destroy; override;
    function Exclude(path: TGPGraphicsPath): TStatus; overload;
    function Union(region: TGPRegion): TStatus; overload;
  end;

//--------------------------------------------------------------------------
// FontFamily
//--------------------------------------------------------------------------

  TGPFontFamily = class(TGdiplusBase)
  protected
    nativeFamily: GpFontFamily;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeOrig: GpFontFamily; status: TStatus); reintroduce; overload;
    constructor Create(name: WideString; fontCollection: TGPFontCollection = nil); reintroduce; overload;
    destructor Destroy; override;
    property Status: TStatus read lastResult;
  end;

//--------------------------------------------------------------------------
// Font Collection
//--------------------------------------------------------------------------

  TGPFontCollection = class(TGdiplusBase)
  protected
    nativeFontCollection: GpFontCollection;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create;
    destructor Destroy; override;
  end;

//--------------------------------------------------------------------------
// TFont
//--------------------------------------------------------------------------

  TGPFont = class(TGdiplusBase)
  protected
    nativeFont: GpFont;
    lastResult: TStatus;
    procedure SetNativeFont(Font: GpFont);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(font: GpFont; status: TStatus); reintroduce; overload;
    constructor Create(family: TGPFontFamily; emSize: Single;
      style: TFontStyle = FontStyleRegular;
      unit_: TUnit = UnitPoint); reintroduce; overload;
    destructor Destroy; override;
    property Status: TStatus read lastResult;    
  end;

(**************************************************************************\
*
*   GDI+ Brush class
*
\**************************************************************************)

  //--------------------------------------------------------------------------
  // Abstract base class for various brush types
  //--------------------------------------------------------------------------

  TGPBrush = class(TGdiplusBase)
  protected
    nativeBrush: GpBrush;
    lastResult: TStatus;
    procedure SetNativeBrush(nativeBrush: GpBrush);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeBrush: GpBrush; status: TStatus); reintroduce; overload;
    constructor Create; overload;
    destructor Destroy; override;
  end;

  //--------------------------------------------------------------------------
  // Solid Fill Brush Object
  //--------------------------------------------------------------------------

  TGPSolidBrush = class(TGPBrush)
  public
    constructor Create(color: TGPColor); reintroduce; overload;
    constructor Create; reintroduce; overload;
  end;

  //--------------------------------------------------------------------------
  // Linear Gradient Brush Object
  //--------------------------------------------------------------------------

  TGPLinearGradientBrush = class(TGPBrush)
  public
    constructor Create; reintroduce; overload;
    constructor Create(rect: TGPRectF; color1, color2: TGPColor;
      mode: TLinearGradientMode); reintroduce; overload;
    constructor Create(rect: TGPRect; color1, color2: TGPColor;
      mode: TLinearGradientMode); reintroduce; overload;
  end;

(**************************************************************************\
*
*   GDI+ Pen class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Pen class 
//--------------------------------------------------------------------------

  TGPPen = class(TGdiplusBase)
  protected
    nativePen: GpPen;
    lastResult: TStatus;
    procedure SetNativePen(nativePen: GpPen);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativePen: GpPen; status: TStatus); reintroduce; overload;
    constructor Create(color: TGPColor; width: Single = 1.0); reintroduce; overload;
    destructor Destroy; override;
    function GetDashStyle: TDashStyle;
    function SetDashStyle(dashStyle: TDashStyle): TStatus;
    function SetEndCap(endCap: TLineCap): TStatus;
  end;

(**************************************************************************\
*
*   GDI+ StringFormat class
*
\**************************************************************************)

  TGPStringFormat = class(TGdiplusBase)
  protected
    nativeFormat: GpStringFormat;
    lastError: TStatus;
    function SetStatus(newStatus: GpStatus): TStatus;
    procedure Assign(source: TGPStringFormat);
  public
    constructor Create(clonedStringFormat: GpStringFormat; status: TStatus); reintroduce; overload;
    constructor Create(formatFlags: Integer = 0; language: LANGID = LANG_NEUTRAL); reintroduce; overload;
    destructor Destroy; override;
    function SetAlignment(align: TStringAlignment): TStatus;
    function GetAlignment: TStringAlignment;
    function SetLineAlignment(align: TStringAlignment): TStatus;
    function GetLineAlignment: TStringAlignment;
    function SetTrimming(trimming: TStringTrimming): TStatus;
    function GetTrimming: TStringTrimming;
    function SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix): TStatus;
    function GetHotkeyPrefix: THotkeyPrefix;

  end;

(**************************************************************************\
*
*   GDI+ Graphics Path class
*
\**************************************************************************)

  TGPGraphicsPath = class(TGdiplusBase)
  protected
    nativePath: GpPath;
    lastResult: TStatus;
    procedure SetNativePath(nativePath: GpPath);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativePath: GpPath); reintroduce; overload;
    constructor Create(fillMode: TFillMode = FillModeAlternate); reintroduce; overload;
    destructor Destroy; override;

    function CloseFigure: TStatus;

    function AddLine(const pt1, pt2: TGPPointF): TStatus; overload;
    function AddLine(x1, y1, x2, y2: Single): TStatus; overload;
    function AddLines(points: PGPPoint; count: Integer): TStatus; overload;

    function AddArc(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus; overload;
    function AddArc(x, y, width, height, startAngle, sweepAngle: Single): TStatus; overload;

    function AddEllipse(rect: TGPRectF): TStatus; overload;
    function AddEllipse(x, y, width, height: Single): TStatus; overload;

    function AddPie(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus; overload;
    function AddPie(x, y, width, height, startAngle, sweepAngle: Single): TStatus; overload;

    function AddPolygon(points: PGPPointF; count: Integer): TStatus; overload;
    function AddPolygon(points: PGPPoint; count: Integer): TStatus; overload;


    function AddCurve(points: PGPPointF; count: Integer): TStatus; overload;
    function AddCurve(points: PGPPoint; count: Integer): TStatus; overload;
    function AddCurve(points: PGPPoint; count: Integer; tension: Single): TStatus; overload;

    function AddBezier(pt1, pt2, pt3, pt4: TGPPoint): TStatus; overload;
    function AddBezier(pt1, pt2, pt3, pt4: TGPPointF): TStatus; overload;
    function AddBezier(x1, y1, x2, y2, x3, y3, x4, y4: Single): TStatus; overload;
  end;

//--------------------------------------------------------------------------
// Path Gradient Brush
//--------------------------------------------------------------------------

  TGPPathGradientBrush = class(TGPBrush)
  public
    {constructor Create(points: PGPPointF; count: Integer;
      wrapMode: TWrapMode = WrapModeClamp); reintroduce; overload; }
    constructor Create(path: TGPGraphicsPath); reintroduce; //overload;
    function GetCenterColor(out Color: TGPColor): TStatus;
    function SetCenterColor(color: TGPColor): TStatus;
    function GetPointCount: Integer;
    function GetSurroundColors(colors: PARGB; var count: Integer): TStatus;
    function SetSurroundColors(colors: PARGB; var count: Integer): TStatus;
    function GetCenterPoint(out point: TGPPointF): TStatus; overload;
    function GetCenterPoint(out point: TGPPoint): TStatus; overload;
    function SetCenterPoint(point: TGPPointF): TStatus; overload;
    function SetCenterPoint(point: TGPPoint): TStatus; overload;
  end;

(**************************************************************************\
*  TGPImage
***************************************************************************)
  TGPImageFormat = (ifUndefined, ifMemoryBMP, ifBMP, ifEMF, ifWMF, ifJPEG,
    ifPNG, ifGIF, ifTIFF, ifEXIF, ifIcon);

  TGPImage = class(TGdiplusBase)
  protected
    nativeImage: GpImage;
    lastResult: TStatus;
    loadStatus: TStatus;
    procedure SetNativeImage(nativeImage: GpImage);
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create(nativeImage: GpImage; status: TStatus); reintroduce; overload;
    constructor Create(filename: WideString; useEmbeddedColorManagement: BOOL = FALSE); reintroduce; overload;
    constructor Create(stream: IStream; useEmbeddedColorManagement: BOOL  = FALSE); reintroduce; overload;
    destructor Destroy; override;
    function Save(filename: WideString; const clsidEncoder: TGUID; encoderParams: PEncoderParameters = nil): TStatus; overload;
    function GetFormat: TGPImageFormat;
    function GetWidth: UINT;
    function GetHeight: UINT;
    function GetHorizontalResolution: Single;
    function GetVerticalResolution: Single;
    function RotateFlip(rotateFlipType: TRotateFlipType): TStatus;
  end;

  TGPBitmap = class(TGPImage)
  public
    constructor Create(nativeBitmap: GpBitmap);  reintroduce; overload;
    constructor Create(stream: IStream; useEmbeddedColorManagement: BOOL = FALSE); reintroduce; overload;
    constructor Create(width, height: Integer; format: TPixelFormat = PixelFormat32bppARGB); reintroduce; overload;
    function FromStream(stream: IStream; useEmbeddedColorManagement: BOOL = FALSE): TGPBitmap;
    function GetPixel(x, y: Integer; out color: TGPColor): TStatus;
    function SetPixel(x, y: Integer; color: TGPColor): TStatus;
    function SetResolution(xdpi, ydpi: Single): TStatus;    
  end;

  TGPImageAttributes = class(TGdiplusBase)
  protected
    nativeImageAttr: GpImageAttributes;
    lastResult: TStatus;
    function SetStatus(status: TStatus): TStatus;
  public
    constructor Create; reintroduce; overload;
    destructor Destroy; override;
    function SetColorKey(colorLow, colorHigh: TGPColor; type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
    function ClearColorKey(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
  end;

(**************************************************************************\
*
*   GDI+ Graphics Object
*
\**************************************************************************)

  TGPGraphics = class(TGdiplusBase)
  protected
    nativeGraphics: GpGraphics;
    lastResult: TStatus;
    procedure SetNativeGraphics(graphics: GpGraphics);
    function SetStatus(status: TStatus): TStatus;
    function GetNativeGraphics: GpGraphics;
  public
    //constructor Create(graphics: GpGraphics); reintroduce; overload;
    constructor Create(hdc: HDC); reintroduce; overload;
    constructor Create(image: TGPImage); reintroduce; overload;
    destructor Destroy; override;
    function FromImage(image: TGPImage): TGPGraphics;    
    procedure Flush(intention: TFlushIntention = FlushIntentionFlush);
    //------------------------------------------------------------------------
    // GDI Interop methods
    //------------------------------------------------------------------------
    // Locks the graphics until ReleaseDC is called
    function GetHDC: HDC;
    procedure ReleaseHDC(hdc: HDC);
    //------------------------------------------------------------------------
    // Rendering modes
    //------------------------------------------------------------------------
    function SetCompositingQuality(compositingQuality: TCompositingQuality): TStatus;
    function GetCompositingQuality: TCompositingQuality;

    function SetTextRenderingHint(newMode: TTextRenderingHint): TStatus;
    function GetTextRenderingHint: TTextRenderingHint;
    function GetSmoothingMode: TSmoothingMode;
    function SetSmoothingMode(smoothingMode: TSmoothingMode): TStatus;
    // DrawPath
    function DrawPath(pen: TGPPen; path: TGPGraphicsPath): TStatus;
    // FillRectangle(s)
    function FillRectangle(brush: TGPBrush; const rect: TGPRectF): TStatus; overload;
    function FillRectangle(brush: TGPBrush; x, y, width, height: Single): TStatus; overload;
    // DrawString
    {$IFNDEF DELPHI_UNICODE}
    function DrawString(string_: string; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus; overload;
    {$ENDIF}
    {$IFDEF DELPHI6_LVL}
    function DrawString(string_: widestring; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus; overload;
    {$ENDIF}
    // MeasureString
    function MeasureString(string_: WideString; length: Integer; font: TGPFont;
      const layoutRect: TGPRectF; stringFormat: TGPStringFormat; out boundingBox: TGPRectF;
      codepointsFitted: PInteger = nil; linesFilled: PInteger = nil): TStatus; overload;
    function GetLastStatus: TStatus;
    // DrawRectangle
    function DrawRectangle(pen: TGPPen; const rect: TGPRectF): TStatus; overload;
    function DrawRectangle(pen: TGPPen; x, y, width, height: Single): TStatus; overload;
    // DrawImage
    //DrawLine
    function DrawLine(pen: TGPPen; x1, y1, x2, y2: Single): TStatus; overload;
    // DrawEllipse
    function DrawEllipse(pen: TGPPen; const rect: TGPRectF): TStatus; overload;
    function DrawEllipse(pen: TGPPen; x, y, width, height: Single): TStatus; overload;
    function DrawEllipse(pen: TGPPen; const rect: TGPRect): TStatus; overload;
    function DrawEllipse(pen: TGPPen; x, y, width, height: Integer): TStatus; overload;
    function DrawImage(image: TGPImage; x, y: Integer): TStatus; overload;
    function DrawImageRect(image: TGPImage; x, y, w, h: Integer): TStatus; overload;
    function DrawImage(image: TGPImage; const destRect: TGPRectF; srcx, srcy,
      srcwidth, srcheight: Single; srcUnit: TUnit;
      imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
      callbackData: Pointer = nil): TStatus; overload;
    // FillPath
    function FillPath(brush: TGPBrush; path: TGPGraphicsPath): TStatus;
    // Clip
    // FillEllipse
    function FillEllipse(brush: TGPBrush; const rect: TGPRectF): TStatus; overload;
    function FillEllipse(brush: TGPBrush; x, y, width, height: Single): TStatus; overload;
    function FillEllipse(brush: TGPBrush; const rect: TGPRect): TStatus; overload;
    function FillEllipse(brush: TGPBrush; x, y, width, height: Integer): TStatus; overload;

    function ExcludeClip(const rect: TGPRectF): TStatus; overload;
    function ExcludeClip(region: TGPRegion): TStatus; overload;
    function SetClip(region: TGPRegion; combineMode: TCombineMode = CombineModeReplace): TStatus;
    function ResetClip: TStatus;
  end;

  function ColorToARGB(Color: TColor): ARGB;

  function GetEncoderQualityParameters(ImageQualityPercentage: integer): TEncoderParameters;


////////////////////////////////////////////////////////////////////////////////

var
   StartupInput: TGDIPlusStartupInput;
   StartupOutput: TGdiplusStartupOutput;
   gdiplusToken: ULONG;



implementation


var
  FWin7: Boolean;

procedure SetWin7(AWin7: Boolean);
begin
  FWin7 := AWin7
end;

function IsWin7: Boolean;
begin
  Result := FWin7;
end;

function ColorToARGB(Color: TColor): ARGB;
var
  c: TColor;
begin
  c := ColorToRGB(Color);
  Result := ARGB( $FF000000 or ((DWORD(c) and $FF) shl 16) or ((DWORD(c) and $FF00) or ((DWORD(c) and $ff0000) shr 16)));
end;


  function GdipAlloc; external WINGDIPDLL name 'GdipAlloc';
  procedure GdipFree; external WINGDIPDLL name 'GdipFree';
  function GdiplusStartup; external WINGDIPDLL name 'GdiplusStartup';
  procedure GdiplusShutdown; external WINGDIPDLL name 'GdiplusShutdown';

  function GdipCreatePath; external WINGDIPDLL name 'GdipCreatePath';
  function GdipDeletePath; external WINGDIPDLL name 'GdipDeletePath';
  //function GdipStartPathFigure; external WINGDIPDLL name 'GdipStartPathFigure';
  function GdipClosePathFigure; external WINGDIPDLL name 'GdipClosePathFigure';
  function GdipAddPathLine; external WINGDIPDLL name 'GdipAddPathLine';
  function GdipAddPathArc; external WINGDIPDLL name 'GdipAddPathArc';
  function GdipAddPathEllipse; external WINGDIPDLL name 'GdipAddPathEllipse';
  function GdipAddPathPie; external WINGDIPDLL name 'GdipAddPathPie';
  function GdipDeleteBrush; external WINGDIPDLL name 'GdipDeleteBrush';
  function GdipCreateSolidFill; external WINGDIPDLL name 'GdipCreateSolidFill';
  function GdipCreateLineBrushFromRect; external WINGDIPDLL name 'GdipCreateLineBrushFromRect';
  function GdipCreateLineBrushFromRectI; external WINGDIPDLL name 'GdipCreateLineBrushFromRectI';
  function GdipCreateLineBrushFromRectWithAngle; external WINGDIPDLL name 'GdipCreateLineBrushFromRectWithAngle';
  function GdipCreatePathGradient; external WINGDIPDLL name 'GdipCreatePathGradient';
  function GdipCreatePathGradientFromPath; external WINGDIPDLL name 'GdipCreatePathGradientFromPath';
  function GdipGetPathGradientCenterColor; external WINGDIPDLL name 'GdipGetPathGradientCenterColor';
  function GdipSetPathGradientCenterColor; external WINGDIPDLL name 'GdipSetPathGradientCenterColor';
  function GdipGetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorsWithCount';
  function GdipSetPathGradientSurroundColorsWithCount; external WINGDIPDLL name 'GdipSetPathGradientSurroundColorsWithCount';
  function GdipGetPathGradientCenterPoint; external WINGDIPDLL name 'GdipGetPathGradientCenterPoint';
  function GdipGetPathGradientCenterPointI; external WINGDIPDLL name 'GdipGetPathGradientCenterPointI';
  function GdipSetPathGradientCenterPoint; external WINGDIPDLL name 'GdipSetPathGradientCenterPoint';
  function GdipSetPathGradientCenterPointI; external WINGDIPDLL name 'GdipSetPathGradientCenterPointI';
  function GdipGetPathGradientPointCount; external WINGDIPDLL name 'GdipGetPathGradientPointCount';
  function GdipGetPathGradientSurroundColorCount; external WINGDIPDLL name 'GdipGetPathGradientSurroundColorCount';
  function GdipCreatePen1; external WINGDIPDLL name 'GdipCreatePen1';
  function GdipDeletePen; external WINGDIPDLL name 'GdipDeletePen';
  function GdipFlush; external WINGDIPDLL name 'GdipFlush';
  function GdipCreateFromHDC; external WINGDIPDLL name 'GdipCreateFromHDC';
  function GdipGetImageGraphicsContext; external WINGDIPDLL name 'GdipGetImageGraphicsContext';
  function GdipDeleteGraphics; external WINGDIPDLL name 'GdipDeleteGraphics';
  function GdipGetDC; external WINGDIPDLL name 'GdipGetDC';
  function GdipReleaseDC; external WINGDIPDLL name 'GdipReleaseDC';
  function GdipSetSmoothingMode; external WINGDIPDLL name 'GdipSetSmoothingMode';
  function GdipGetSmoothingMode; external WINGDIPDLL name 'GdipGetSmoothingMode';
  function GdipSetTextRenderingHint; external WINGDIPDLL name 'GdipSetTextRenderingHint';
  function GdipGetTextRenderingHint; external WINGDIPDLL name 'GdipGetTextRenderingHint';
  function GdipFillEllipse; external WINGDIPDLL name 'GdipFillEllipse';
  function GdipFillEllipseI; external WINGDIPDLL name 'GdipFillEllipseI';
  function GdipDrawPath; external WINGDIPDLL name 'GdipDrawPath';
  function GdipFillRectangle; external WINGDIPDLL name 'GdipFillRectangle';
  function GdipCreateFontFamilyFromName; external WINGDIPDLL name 'GdipCreateFontFamilyFromName';
  function GdipDeleteFontFamily; external WINGDIPDLL name 'GdipDeleteFontFamily';
  function GdipCreateFont; external WINGDIPDLL name 'GdipCreateFont';
  function GdipDeleteFont; external WINGDIPDLL name 'GdipDeleteFont';
  function GdipDrawString; external WINGDIPDLL name 'GdipDrawString';
  function GdipMeasureString; external WINGDIPDLL name 'GdipMeasureString';
  function GdipCreateStringFormat; external WINGDIPDLL name 'GdipCreateStringFormat';
  function GdipDeleteStringFormat; external WINGDIPDLL name 'GdipDeleteStringFormat';
  function GdipCloneStringFormat; external WINGDIPDLL name 'GdipCloneStringFormat';
  function GdipSetStringFormatAlign; external WINGDIPDLL name 'GdipSetStringFormatAlign';
  function GdipGetStringFormatAlign; external WINGDIPDLL name 'GdipGetStringFormatAlign';
  function GdipSetStringFormatLineAlign; external WINGDIPDLL name 'GdipSetStringFormatLineAlign';
  function GdipGetStringFormatLineAlign; external WINGDIPDLL name 'GdipGetStringFormatLineAlign';
  function GdipSetStringFormatTrimming; external WINGDIPDLL name 'GdipSetStringFormatTrimming';
  function GdipGetStringFormatTrimming; external WINGDIPDLL name 'GdipGetStringFormatTrimming';
  function GdipGetImageRawFormat; external WINGDIPDLL name 'GdipGetImageRawFormat';
  function GdipDrawImage; external WINGDIPDLL name 'GdipDrawImage';
  function GdipDrawImageI; external WINGDIPDLL name 'GdipDrawImageI';
  function GdipDrawImageRect; external WINGDIPDLL name 'GdipDrawImageRect';
  function GdipDrawImageRectI; external WINGDIPDLL name 'GdipDrawImageRectI';
  function GdipDrawRectangle; external WINGDIPDLL name 'GdipDrawRectangle';
  function GdipDrawRectangleI; external WINGDIPDLL name 'GdipDrawRectangleI';
  function GdipDrawEllipse; external WINGDIPDLL name 'GdipDrawEllipse';
  function GdipDrawEllipseI; external WINGDIPDLL name 'GdipDrawEllipseI';    
  function GdipDrawLine; external WINGDIPDLL name 'GdipDrawLine';
  function GdipFillPath; external WINGDIPDLL name 'GdipFillPath';
  function GdipGetImageDecodersSize; external WINGDIPDLL name 'GdipGetImageDecodersSize';
  function GdipGetImageDecoders; external WINGDIPDLL name 'GdipGetImageDecoders';
  function GdipGetImageEncodersSize; external WINGDIPDLL name 'GdipGetImageEncodersSize';
  function GdipGetImageEncoders; external WINGDIPDLL name 'GdipGetImageEncoders';
  function GdipSaveImageToFile; external WINGDIPDLL name 'GdipSaveImageToFile';
  function GdipLoadImageFromFileICM; external WINGDIPDLL name 'GdipLoadImageFromFileICM';
  function GdipLoadImageFromFile; external WINGDIPDLL name 'GdipLoadImageFromFile';
  function GdipLoadImageFromStream; external WINGDIPDLL name 'GdipLoadImageFromStream';
  function GdipLoadImageFromStreamICM; external WINGDIPDLL name 'GdipLoadImageFromStreamICM';
  function GdipDisposeImage; external WINGDIPDLL name 'GdipDisposeImage';
  function GdipGetImageWidth; external WINGDIPDLL name 'GdipGetImageWidth';
  function GdipGetImageHeight; external WINGDIPDLL name 'GdipGetImageHeight';
  function GdipGetImageHorizontalResolution; external WINGDIPDLL name 'GdipGetImageHorizontalResolution';
  function GdipGetImageVerticalResolution; external WINGDIPDLL name 'GdipGetImageVerticalResolution';
  function GdipGetPenDashStyle; external WINGDIPDLL name 'GdipGetPenDashStyle';
  function GdipSetPenDashStyle; external WINGDIPDLL name 'GdipSetPenDashStyle';
  function GdipSetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipSetStringFormatHotkeyPrefix';
  function GdipGetStringFormatHotkeyPrefix; external WINGDIPDLL name 'GdipGetStringFormatHotkeyPrefix';
  function GdipSetClipRect; external WINGDIPDLL name 'GdipSetClipRect';
  function GdipSetClipRegion; external WINGDIPDLL name 'GdipSetClipRegion';
  function GdipCreateRegionRect; external WINGDIPDLL name 'GdipCreateRegionRect';
  function GdipCreateRegionPath; external WINGDIPDLL name 'GdipCreateRegionPath';
  function GdipDeleteRegion; external WINGDIPDLL name 'GdipDeleteRegion';
  function GdipCombineRegionPath; external WINGDIPDLL name 'GdipCombineRegionPath';
  function GdipCombineRegionRegion; external WINGDIPDLL name 'GdipCombineRegionRegion';
  function GdipSetCompositingQuality; external WINGDIPDLL name 'GdipSetCompositingQuality';
  function GdipGetCompositingQuality; external WINGDIPDLL name 'GdipGetCompositingQuality';
  function GdipImageRotateFlip; external WINGDIPDLL name 'GdipImageRotateFlip';
  function GdipCreateBitmapFromStreamICM; external WINGDIPDLL name 'GdipCreateBitmapFromStreamICM';
  function GdipCreateBitmapFromStream; external WINGDIPDLL name 'GdipCreateBitmapFromStream';
  function GdipCreateBitmapFromScan0; external WINGDIPDLL name 'GdipCreateBitmapFromScan0';
  function GdipBitmapGetPixel; external WINGDIPDLL name 'GdipBitmapGetPixel';
  function GdipBitmapSetPixel; external WINGDIPDLL name 'GdipBitmapSetPixel';
  function GdipBitmapSetResolution; external WINGDIPDLL name 'GdipBitmapSetResolution';

  function GdipSetPenEndCap; external WINGDIPDLL name 'GdipSetPenEndCap';
  function GdipAddPathLine2I; external WINGDIPDLL name 'GdipAddPathLine2I';
  function GdipCreateImageAttributes; external WINGDIPDLL name 'GdipCreateImageAttributes';
  function GdipDisposeImageAttributes; external WINGDIPDLL name 'GdipDisposeImageAttributes';
  function GdipSetImageAttributesColorKeys; external WINGDIPDLL name 'GdipSetImageAttributesColorKeys';
  function GdipDrawImageRectRect; external WINGDIPDLL name 'GdipDrawImageRectRect';

  function GdipAddPathPolygon; external WINGDIPDLL name 'GdipAddPathPolygon';
  function GdipAddPathPolygonI; external WINGDIPDLL name 'GdipAddPathPolygonI';
  function GdipAddPathCurveI; external WINGDIPDLL name 'GdipAddPathCurveI';
  function GdipAddPathCurve; external WINGDIPDLL name 'GdipAddPathCurve';
  function GdipAddPathCurve2I; external WINGDIPDLL name 'GdipAddPathCurve2I';
  function GdipResetClip; external WINGDIPDLL name 'GdipResetClip';
  function GdipAddPathBezier; external WINGDIPDLL name 'GdipAddPathBezier';
// -----------------------------------------------------------------------------
// TGdiplusBase class
// -----------------------------------------------------------------------------


class function TGdiplusBase.NewInstance: TObject;
var
  p  : pointer;
  sz : ULONG;
begin
  sz := ULONG(InstanceSize);
  p := GdipAlloc(sz);
  if not Assigned(p) then 
  begin
    //GdipAlloc failed --> restart GDI+ and try again
    GdiplusStartup(gdiplusToken, @StartupInput, @StartupOutput);
    p := GdipAlloc(sz);
  end;
  Result := InitInstance(p);
end;

procedure TGdiplusBase.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;


function GetImageEncoders(numEncoders, size: UINT;
   encoders: PImageCodecInfo): TStatus;
begin
  result := GdipGetImageEncoders(numEncoders, size, encoders);
end;

function GetImageEncodersSize(out numEncoders, size: UINT): TStatus;
begin
  result := GdipGetImageEncodersSize(numEncoders, size);
end;

function GetEncoderClsid(format: String; out pClsid: TGUID): integer;
var
  num, size, j: UINT;
  ImageCodecInfo: PImageCodecInfo;
Type
  ArrIMgInf = array of TImageCodecInfo;
begin
  num  := 0; // number of image encoders
  size := 0; // size of the image encoder array in bytes
  result := -1;

  GetImageEncodersSize(num, size);
  if (size = 0) then exit;

  GetMem(ImageCodecInfo, size);
  if(ImageCodecInfo = nil) then exit;

  GetImageEncoders(num, size, ImageCodecInfo);

  for j := 0 to num - 1 do
  begin
    if( ArrIMgInf(ImageCodecInfo)[j].MimeType = format) then
    begin
      pClsid := ArrIMgInf(ImageCodecInfo)[j].Clsid;
      result := j;  // Success
    end;
  end;
  FreeMem(ImageCodecInfo, size);
end;



function GetEncoderQualityParameters(ImageQualityPercentage: integer): TEncoderParameters;
var
  encoderParameters: TEncoderParameters;
  value: integer;
begin
  if ImageQualityPercentage < 0 then
    ImageQualityPercentage := 0;

  if ImageQualityPercentage > 100 then
    ImageQualityPercentage := 100;

  value := ImageQualityPercentage;
  encoderParameters.Count := 1;
  encoderParameters.Parameter[0].Guid := EncoderQuality;
  encoderParameters.Parameter[0].Type_ := EncoderParameterValueTypeLong;
  encoderParameters.Parameter[0].Value := @value;
  encoderParameters.Parameter[0].NumberOfValues := 1;

  result := encoderParameters;
end;


//--------------------------------------------------------------------------
// TGPPoint Util
//--------------------------------------------------------------------------

function MakePoint(X, Y: Integer): TGPPoint;
begin
  result.X := X;
  result.Y := Y;
end;

function MakePoint(X, Y: Single): TGPPointF;
begin
  Result.X := X;
  result.Y := Y;
end;

// -----------------------------------------------------------------------------
// RectF class
// -----------------------------------------------------------------------------

function MakeRect(x, y, width, height: Single): TGPRectF; overload;
begin
  Result.X      := x;
  Result.Y      := y;
  Result.Width  := width;
  Result.Height := height;
end;


//******************************************************************************
(**************************************************************************\
*
*   GDI+ StringFormat class
*
\**************************************************************************)

constructor TGPStringFormat.Create(formatFlags: Integer = 0; language: LANGID = LANG_NEUTRAL);
begin
  nativeFormat := nil;
  lastError := GdipCreateStringFormat(formatFlags, language, nativeFormat);
end;

destructor TGPStringFormat.Destroy;
begin
  GdipDeleteStringFormat(nativeFormat);
end;

function TGPStringFormat.SetAlignment(align: TStringAlignment): TStatus;
begin
  result := SetStatus(GdipSetStringFormatAlign(nativeFormat, align));
end;

function TGPStringFormat.GetAlignment: TStringAlignment;
begin
  SetStatus(GdipGetStringFormatAlign(nativeFormat, result));
end;

function TGPStringFormat.SetLineAlignment(align: TStringAlignment): TStatus;
begin
  result := SetStatus(GdipSetStringFormatLineAlign(nativeFormat, align));
end;

function TGPStringFormat.GetLineAlignment: TStringAlignment;
begin
  SetStatus(GdipGetStringFormatLineAlign(nativeFormat, result));
end;


function TGPStringFormat.SetTrimming(trimming: TStringTrimming): TStatus;
begin
  result := SetStatus(GdipSetStringFormatTrimming(nativeFormat, trimming));
end;

function TGPStringFormat.GetTrimming: TStringTrimming;
begin
  SetStatus(GdipGetStringFormatTrimming(nativeFormat, result));
end;

function TGPStringFormat.SetHotkeyPrefix(hotkeyPrefix: THotkeyPrefix): TStatus;
begin
  result := SetStatus(GdipSetStringFormatHotkeyPrefix(nativeFormat, Integer(hotkeyPrefix)));
end;

function TGPStringFormat.GetHotkeyPrefix: THotkeyPrefix;
var HotkeyPrefix: Integer;
begin
  SetStatus(GdipGetStringFormatHotkeyPrefix(nativeFormat, HotkeyPrefix));
  result := THotkeyPrefix(HotkeyPrefix);
end;


function TGPStringFormat.SetStatus(newStatus: GpStatus): TStatus;
begin
  if (newStatus <> Ok) then lastError := newStatus;
  result := newStatus;
end;

// operator =
procedure TGPStringFormat.Assign(source: TGPStringFormat);
begin
  assert(assigned(source));
  GdipDeleteStringFormat(nativeFormat);
  lastError := GdipCloneStringFormat(source.nativeFormat, nativeFormat);
end;

constructor TGPStringFormat.Create(clonedStringFormat: GpStringFormat; status: TStatus);
begin
  lastError := status;
  nativeFormat := clonedStringFormat;
end;

(**************************************************************************\
*
*   GDI+ Pen class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Pen class
//--------------------------------------------------------------------------

constructor TGPPen.Create(color: TGPColor; width: Single = 1.0);
var unit_: TUnit;
begin
  unit_ := UnitWorld;
  nativePen := nil;
  lastResult := GdipCreatePen1(color, width, unit_, nativePen);
end;

destructor TGPPen.Destroy;
begin
  GdipDeletePen(nativePen);
end;

constructor TGPPen.Create(nativePen: GpPen; status: TStatus);
begin
  lastResult := status;
  SetNativePen(nativePen);
end;

procedure TGPPen.SetNativePen(nativePen: GpPen);
begin
  self.nativePen := nativePen;
end;

function TGPPen.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

function TGPPen.GetDashStyle: TDashStyle;
begin
  SetStatus(GdipGetPenDashStyle(nativePen, result));
end;

function TGPPen.SetDashStyle(dashStyle: TDashStyle): TStatus;
begin
  result := SetStatus(GdipSetPenDashStyle(nativePen, dashStyle));
end;

function TGPPen.SetEndCap(endCap: TLineCap): TStatus;
begin
  result := SetStatus(GdipSetPenEndCap(nativePen, endCap));
end;


(**************************************************************************\
*
*   GDI+ Brush class
*
\**************************************************************************)

//--------------------------------------------------------------------------
// Abstract base class for various brush types
//--------------------------------------------------------------------------

destructor TGPBrush.Destroy;
begin
  GdipDeleteBrush(nativeBrush);
end;

constructor TGPBrush.Create;
begin
  SetStatus(NotImplemented);
end;

constructor TGPBrush.Create(nativeBrush: GpBrush; status: TStatus);
begin
  lastResult := status;
  SetNativeBrush(nativeBrush);
end;

procedure TGPBrush.SetNativeBrush(nativeBrush: GpBrush);
begin
  self.nativeBrush := nativeBrush;
end;

function TGPBrush.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

//--------------------------------------------------------------------------
// Solid Fill Brush Object
//--------------------------------------------------------------------------

constructor TGPSolidBrush.Create(color: TGPColor);
var
  brush: GpSolidFill;
begin
  brush := nil;
  lastResult := GdipCreateSolidFill(color, brush);
  SetNativeBrush(brush);
end;

constructor TGPSolidBrush.Create;
begin
  // hide parent function
end;

//--------------------------------------------------------------------------
// Linear Gradient Brush Object
//--------------------------------------------------------------------------

constructor TGPLinearGradientBrush.Create(rect: TGPRectF; color1, color2: TGPColor; mode: TLinearGradientMode);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRect(@rect, color1,
                  color2, mode, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create(rect: TGPRect; color1, color2: TGPColor; mode: TLinearGradientMode);
var brush: GpLineGradient;
begin
  brush := nil;
  lastResult := GdipCreateLineBrushFromRectI(@rect, color1,
                  color2, mode, WrapModeTile, brush);
  SetNativeBrush(brush);
end;

constructor TGPLinearGradientBrush.Create;
begin
  // hide parent function
end;

(**************************************************************************\
*
*   GDI+ Graphics Object
*
\**************************************************************************)

constructor TGPGraphics.Create(hdc: HDC);
var
  graphics: GpGraphics;
begin
  graphics:= nil;
  lastResult := GdipCreateFromHDC(hdc, graphics);
  SetNativeGraphics(graphics);
end;

destructor TGPGraphics.Destroy;
begin
  GdipDeleteGraphics(nativeGraphics);
end;

procedure TGPGraphics.Flush(intention: TFlushIntention = FlushIntentionFlush);
begin
  GdipFlush(nativeGraphics, intention);
end;

function TGPGraphics.FromImage(image: TGPImage): TGPGraphics;
begin
  Result := TGPGraphics.Create(image);
end;

constructor TGPGraphics.Create(image: TGPImage);
var
  graphics: GpGraphics;
begin
  graphics:= nil;
  if (image <> nil) then
    lastResult := GdipGetImageGraphicsContext(image.nativeImage, graphics);
  SetNativeGraphics(graphics);
end;


//------------------------------------------------------------------------
// GDI Interop methods
//------------------------------------------------------------------------

// Locks the graphics until ReleaseDC is called

function TGPGraphics.GetHDC: HDC;
begin
  SetStatus(GdipGetDC(nativeGraphics, result));
end;

procedure TGPGraphics.ReleaseHDC(hdc: HDC);
begin
  SetStatus(GdipReleaseDC(nativeGraphics, hdc));
end;

function TGPGraphics.SetTextRenderingHint(newMode: TTextRenderingHint): TStatus;
begin
  result := SetStatus(GdipSetTextRenderingHint(nativeGraphics, newMode));
end;

function TGPGraphics.GetTextRenderingHint: TTextRenderingHint;
begin
  SetStatus(GdipGetTextRenderingHint(nativeGraphics, result));
end;

function TGPGraphics.GetSmoothingMode: TSmoothingMode;
var
  smoothingMode: TSmoothingMode;
begin
  smoothingMode := SmoothingModeInvalid;
  SetStatus(GdipGetSmoothingMode(nativeGraphics,  smoothingMode));
  result := smoothingMode;
end;

function TGPGraphics.SetSmoothingMode(smoothingMode: TSmoothingMode): TStatus;
begin
  result := SetStatus(GdipSetSmoothingMode(nativeGraphics, smoothingMode));
end;

function TGPGraphics.DrawPath(pen: TGPPen; path: TGPGraphicsPath): TStatus;
var
  nPen: GpPen;
  nPath: GpPath;
begin
  if Assigned(pen) then
    nPen := pen.nativePen
  else
    nPen  := nil;
  if Assigned(path) then
    nPath := path.nativePath
  else
    nPath := nil;
  Result := SetStatus(GdipDrawPath(nativeGraphics, nPen, nPath));
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; const rect: TGPRectF): TStatus;
begin
  Result := FillRectangle(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillRectangle(brush: TGPBrush; x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipFillRectangle(nativeGraphics, brush.nativeBrush, x, y,
                      width, height));
end;

{$IFNDEF DELPHI_UNICODE}
function TGPGraphics.DrawString( string_: string; length: Integer; font: TGPFont;
  const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
  nBrush: GpBrush;
  wCh: PWidechar;
  i: integer;
begin
  if Assigned(font) then
    nfont := font.nativeFont
  else
    nfont := nil;
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat
  else
    nstringFormat := nil;

  {charset issue}
  i := System.Length(string_);
  GetMem(wCh, i * 2 + 2);
  FillChar(wCh^, i * 2 + 2,0);
  StringToWidechar(string_, wCh, i * 2 + 2);
  {/charset issue}

  if Assigned(brush) then
    nbrush := brush.nativeBrush
  else
    nbrush := nil;
//  Result := SetStatus(GdipDrawString(nativeGraphics, PWideChar(string_),
//        length, nfont, @layoutRect, nstringFormat, nbrush));

  {charset issue}
  Result := SetStatus(GdipDrawString(nativeGraphics, wCh,
        length, nfont, @layoutRect, nstringFormat, nbrush));

  FreeMem(wCh);
  {/charset issue}
end;
{$ENDIF}

{$IFDEF DELPHI6_LVL}
function TGPGraphics.DrawString( string_: widestring; length: Integer; font: TGPFont;
  const layoutRect: TGPRectF; stringFormat: TGPStringFormat; brush: TGPBrush): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
  nBrush: GpBrush;
begin
  if Assigned(font) then
    nfont := font.nativeFont
  else
    nfont := nil;
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat
  else
    nstringFormat := nil;

  if Assigned(brush) then
    nbrush := brush.nativeBrush
  else
    nbrush := nil;

  Result := SetStatus(GdipDrawString(nativeGraphics, PWideChar(string_),
        length, nfont, @layoutRect, nstringFormat, nbrush));
end;
{$ENDIF}

function TGPGraphics.MeasureString(string_: WideString; length: Integer; font: TGPFont;
  const layoutRect: TGPRectF; stringFormat: TGPStringFormat; out boundingBox: TGPRectF;
  codepointsFitted: PInteger = nil; linesFilled: PInteger = nil): TStatus;
var
  nFont: GpFont;
  nStringFormat: GpStringFormat;
begin
  if Assigned(font) then
    nfont := font.nativeFont
  else
    nfont := nil;
  if Assigned(stringFormat) then
    nstringFormat := stringFormat.nativeFormat
  else
    nstringFormat := nil;

  Result := SetStatus(GdipMeasureString(nativeGraphics, PWideChar(string_),
        length, nfont, @layoutRect, nstringFormat, @boundingBox, codepointsFitted,
        linesFilled));
end;

function TGPGraphics.GetLastStatus: TStatus;
begin
  result := lastResult;
  lastResult := Ok;
end;

{
constructor TGPGraphics.Create(graphics: GpGraphics);
begin
  lastResult := Ok;
  SetNativeGraphics(graphics);
end;
}

procedure TGPGraphics.SetNativeGraphics(graphics: GpGraphics);
begin
  self.nativeGraphics := graphics;
end;

function TGPGraphics.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then
    lastResult := status;
  result := status;
end;

function TGPGraphics.GetNativeGraphics: GpGraphics;
begin
  result := self.nativeGraphics;
end;

//------------------------------------------------------------------------------

  constructor TGPRegion.Create(rect: TGPRectF);
  var
    region: GpRegion;
  begin
    region := nil;
    lastResult := GdipCreateRegionRect(@rect, region);
    SetNativeRegion(region);
  end;

  constructor TGPRegion.Create(path: TGPGraphicsPath);
  var
    region: GpRegion;
  begin
    region := nil;
    lastResult := GdipCreateRegionPath(path.nativePath, region);
    SetNativeRegion(region);
  end;

  destructor TGPRegion.Destroy;
  begin
    GdipDeleteRegion(nativeRegion);
  end;

  function TGPRegion.Exclude(path: TGPGraphicsPath): TStatus;
  begin
    result := SetStatus(GdipCombineRegionPath(nativeRegion, path.nativePath, CombineModeExclude));
  end;

  function TGPRegion.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

  procedure TGPRegion.SetNativeRegion(nativeRegion: GpRegion);
  begin
    self.nativeRegion := nativeRegion;
  end;

  function TGPRegion.Union(region: TGPRegion): TStatus;
  begin
    result := SetStatus(GdipCombineRegionRegion(nativeRegion, region.nativeRegion,
      CombineModeUnion));
  end;

(**************************************************************************\
*
*   GDI+ Font Family class
*
\**************************************************************************)

  constructor TGPFontFamily.Create(name: WideString; fontCollection: TGPFontCollection = nil);
  var nfontCollection: GpfontCollection;
  begin
    nativeFamily := nil;
    if assigned(fontCollection) then nfontCollection := fontCollection.nativeFontCollection else nfontCollection := nil;
    lastResult := GdipCreateFontFamilyFromName(PWideChar(name), nfontCollection, nativeFamily);
  end;

  destructor TGPFontFamily.Destroy;
  begin
    GdipDeleteFontFamily (nativeFamily);
  end;

  function TGPFontFamily.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

  constructor TGPFontFamily.Create(nativeOrig: GpFontFamily; status: TStatus);
  begin
    lastResult  := status;
    nativeFamily := nativeOrig;
  end;

(**************************************************************************\
*
*   GDI+ Font class
*
\**************************************************************************)

  constructor TGPFont.Create(family: TGPFontFamily; emSize: Single;
      style: TFontStyle = FontStyleRegular; unit_: TUnit = UnitPoint);
  var
    font: GpFont;
    nFontFamily: GpFontFamily;
  begin
    font := nil;
    if Assigned(Family) then
      nFontFamily := Family.nativeFamily
    else
      nFontFamily := nil;

    lastResult := GdipCreateFont(nFontFamily, emSize, Integer(style), Integer(unit_), font);
    
    SetNativeFont(font);
  end;

  destructor TGPFont.Destroy;
  begin
    GdipDeleteFont(nativeFont);
  end;

  constructor TGPFont.Create(font: GpFont; status: TStatus);
  begin
    lastResult := status;
    SetNativeFont(font);
  end;

  procedure TGPFont.SetNativeFont(Font: GpFont);
  begin
    nativeFont := Font;
  end;

  function TGPFont.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then lastResult := status;
    result := status;
  end;

(**************************************************************************\
*
*   Font collections (Installed and Private)
*
\**************************************************************************)

  constructor TGPFontCollection.Create;
  begin
    nativeFontCollection := nil;
  end;

  destructor TGPFontCollection.Destroy;
  begin
    inherited Destroy;
  end;

  function TGPFontCollection.SetStatus(status: TStatus): TStatus;
  begin
    lastResult := status;
    result := lastResult;
  end;

(**************************************************************************\
*
*   GDI+ Graphics Path class
*
\**************************************************************************)

  constructor TGPGraphicsPath.Create(fillMode: TFillMode = FillModeAlternate);
  begin
    nativePath := nil;
    lastResult := GdipCreatePath(fillMode, nativePath);
  end;

  destructor TGPGraphicsPath.Destroy;
  begin
    GdipDeletePath(nativePath);
  end;

  function TGPGraphicsPath.CloseFigure: TStatus;
  begin
    result := SetStatus(GdipClosePathFigure(nativePath));
  end;

  function TGPGraphicsPath.AddLine(const pt1, pt2: TGPPointF): TStatus;
  begin
    result := AddLine(pt1.X, pt1.Y, pt2.X, pt2.Y);
  end;

  function TGPGraphicsPath.AddLine(x1, y1, x2, y2: Single): TStatus;
  begin
    result := SetStatus(GdipAddPathLine(nativePath, x1, y1,
                                         x2, y2));
  end;

  function TGPGraphicsPath.AddArc(rect: TGPRectF; startAngle, sweepAngle: Single): TStatus;
  begin
    result := AddArc(rect.X, rect.Y, rect.Width, rect.Height,
                  startAngle, sweepAngle);
  end;

  function TGPGraphicsPath.AddArc(x, y, width, height, startAngle, sweepAngle: Single): TStatus;
  begin
    result := SetStatus(GdipAddPathArc(nativePath, x, y, width, height, startAngle, sweepAngle));
  end;

  function TGPGraphicsPath.AddEllipse(rect: TGPRectF): TStatus;
  begin
    result := AddEllipse(rect.X, rect.Y, rect.Width, rect.Height);
  end;

  function TGPGraphicsPath.AddEllipse(x, y, width, height: Single): TStatus;
  begin
    result := SetStatus(GdipAddPathEllipse(nativePath,
                                          x,
                                          y,
                                          width,
                                          height));
  end;

  {
  constructor TGPGraphicsPath.Create(path: TGPGraphicsPath);
  var clonepath: GpPath;
  begin
    clonepath := nil;
    SetStatus(GdipClonePath(path.nativePath, clonepath));
    SetNativePath(clonepath);
  end;
  }
  constructor TGPGraphicsPath.Create(nativePath: GpPath);
  begin
    lastResult := Ok;
    SetNativePath(nativePath);
  end;

  procedure TGPGraphicsPath.SetNativePath(nativePath: GpPath);
  begin
    self.nativePath := nativePath;
  end;

  function TGPGraphicsPath.SetStatus(status: TStatus): TStatus;
  begin
    if (status <> Ok) then LastResult := status;
    result := status;
  end;

//--------------------------------------------------------------------------
// Path Gradient Brush
//--------------------------------------------------------------------------
 {
  constructor TGPPathGradientBrush.Create(points: PGPPointF; count: Integer; wrapMode: TWrapMode = WrapModeClamp);
  var brush: GpPathGradient;
  begin
    brush := nil;
    lastResult := GdipCreatePathGradient(points, count, wrapMode, brush);
    SetNativeBrush(brush);
  end;
 }
  constructor TGPPathGradientBrush.Create(path: TGPGraphicsPath);
  var brush: GpPathGradient;
  begin
    brush := nil;
    lastResult := GdipCreatePathGradientFromPath(path.nativePath, brush);
    SetNativeBrush(brush);
  end;
  
  function TGPPathGradientBrush.GetCenterColor(out Color: TGPColor): TStatus;
  begin
    SetStatus(GdipGetPathGradientCenterColor(GpPathGradient(nativeBrush), Color));
    result := lastResult;
  end;

  function TGPPathGradientBrush.SetCenterColor(color: TGPColor): TStatus;
  begin
    SetStatus(GdipSetPathGradientCenterColor(GpPathGradient(nativeBrush),color));
    result := lastResult;
  end;

  function TGPPathGradientBrush.GetPointCount: Integer;
  begin
    SetStatus(GdipGetPathGradientPointCount(GpPathGradient(nativeBrush), result));
  end;

  function TGPPathGradientBrush.GetSurroundColors(colors: PARGB; var count: Integer): TStatus;
  var
    count1: Integer;
  begin
    if not assigned(colors) then
    begin
      result := SetStatus(InvalidParameter);
      exit;
    end;

    SetStatus(GdipGetPathGradientSurroundColorCount(GpPathGradient(nativeBrush), count1));

    if(lastResult <> Ok) then
    begin
      result := lastResult;
      exit;
    end;

    if((count < count1) or (count1 <= 0)) then
    begin
      result := SetStatus(InsufficientBuffer);
      exit;
    end;

    SetStatus(GdipGetPathGradientSurroundColorsWithCount(GpPathGradient(nativeBrush), colors, count1));
    if(lastResult = Ok) then
      count := count1;

    result := lastResult;
  end;

  function TGPPathGradientBrush.SetSurroundColors(colors: PARGB; var count: Integer): TStatus;
  var
    count1: Integer;
  type
    TDynArrDWORD = array of DWORD;
  begin
    if (colors = nil) then
    begin
      result := SetStatus(InvalidParameter);
      exit;
    end;

    count1 := GetPointCount;

    if((count > count1) or (count1 <= 0)) then
    begin
      result := SetStatus(InvalidParameter);
      exit;
    end;

    count1 := count;

    SetStatus(GdipSetPathGradientSurroundColorsWithCount(
                GpPathGradient(nativeBrush), colors, count1));

    if(lastResult = Ok) then count := count1;
    result := lastResult;
  end;

  function TGPPathGradientBrush.GetCenterPoint(out point: TGPPointF): TStatus;
  begin
    result := SetStatus(GdipGetPathGradientCenterPoint(GpPathGradient(nativeBrush), @point));
  end;

  function TGPPathGradientBrush.GetCenterPoint(out point: TGPPoint): TStatus;
  begin
    result := SetStatus(GdipGetPathGradientCenterPointI(GpPathGradient(nativeBrush), @point));
  end;

  function TGPPathGradientBrush.SetCenterPoint(point: TGPPointF): TStatus;
  begin
    result := SetStatus(GdipSetPathGradientCenterPoint(GpPathGradient(nativeBrush), @point));
  end;

  function TGPPathGradientBrush.SetCenterPoint(point: TGPPoint): TStatus;
  begin
    result := SetStatus(GdipSetPathGradientCenterPointI(GpPathGradient(nativeBrush), @point));
  end;

function TGPGraphics.DrawEllipse(pen: TGPPen; const rect: TGPRectF): TStatus;
begin
  result := DrawEllipse(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipDrawEllipse(nativeGraphics,
                           pen.nativePen,
                           x,
                           y,
                           width,
                           height));
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; const rect: TGPRect): TStatus;
begin
  result := DrawEllipse(pen,
             rect.X,
             rect.Y,
             rect.Width,
             rect.Height);
end;

function TGPGraphics.DrawEllipse(pen: TGPPen; x, y, width, height: Integer): TStatus;
begin
  result := SetStatus(GdipDrawEllipseI(nativeGraphics,
                            pen.nativePen,
                            x,
                            y,
                            width,
                            height));
end;

function TGPGraphics.DrawRectangle(pen: TGPPen; const rect: TGPRectF): TStatus;
begin
  Result := DrawRectangle(pen, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.DrawRectangle(pen: TGPPen; x, y, width, height: Single): TStatus;
begin
  Result := SetStatus(GdipDrawRectangle(nativeGraphics, pen.nativePen, x, y, width, height));
end;

function TGPGraphics.DrawImage(image: TGPImage; x, y: Integer): TStatus;
var
  nImage: GpImage;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  Result := SetStatus(GdipDrawImageI(nativeGraphics, nimage, x, y));
end;

function TGPGraphics.DrawImageRect(image: TGPImage; x, y, w, h: Integer): TStatus;
var
  nImage: GpImage;
begin
  if Assigned(Image) then
    nImage := Image.nativeImage
  else
    nImage := nil;

  Result := SetStatus(GdipDrawImageRect(nativeGraphics, nimage, x, y, w, h));
end;

function TGPGraphics.DrawLine(pen: TGPPen; x1, y1, x2, y2: Single): TStatus;
begin
  result := SetStatus(GdipDrawLine(nativeGraphics,
                        pen.nativePen, x1, y1, x2,
                        y2));
end;


function TGPGraphics.DrawImage(image: TGPImage; const destRect: TGPRectF; srcx, srcy, srcwidth, srcheight: Single;
     srcUnit: TUnit; imageAttributes: TGPImageAttributes = nil; callback: DrawImageAbort = nil;
     callbackData: Pointer = nil): TStatus;
var
  nImage: GpImage;
  nimageAttributes: GpimageAttributes;
begin
  if assigned(Image) then nImage := Image.nativeImage else nImage := nil;
  if assigned(imageAttributes) then nimageAttributes := imageAttributes.nativeImageAttr else nimageAttributes := nil;
  result := SetStatus(GdipDrawImageRectRect(nativeGraphics,
                             nimage,
                             destRect.X,
                             destRect.Y,
                             destRect.Width,
                             destRect.Height,
                             srcx, srcy,
                             srcwidth, srcheight,
                             srcUnit,
                             nimageAttributes,
                             callback,
                             callbackData));
end;

constructor TGPImage.Create(filename: WideString;
                useEmbeddedColorManagement: BOOL = FALSE);
begin
  nativeImage := nil;
  if(useEmbeddedColorManagement) then
  begin
    lastResult := GdipLoadImageFromFileICM(PWideChar(filename), nativeImage);
  end
  else
  begin
    lastResult := GdipLoadImageFromFile(PWideChar(filename), nativeImage);
  end;
end;

constructor TGPImage.Create(stream: IStream;
                useEmbeddedColorManagement: BOOL  = FALSE);
begin
  nativeImage := nil;
  if (useEmbeddedColorManagement) then
    lastResult := GdipLoadImageFromStreamICM(stream, nativeImage)
  else
    lastResult := GdipLoadImageFromStream(stream, nativeImage);
end;

destructor TGPImage.Destroy;
begin
  GdipDisposeImage(nativeImage);
end;

function TGPImage.Save(filename: WideString; const clsidEncoder: TGUID;
               encoderParams: PEncoderParameters = nil): TStatus;
begin
  result := SetStatus(GdipSaveImageToFile(nativeImage,
                                                   PWideChar(filename),
                                                   @clsidEncoder,
                                                   encoderParams));
end;


function TGPImage.GetFormat: TGPImageFormat;
var
  format: TGUID;
begin
  GdipGetImageRawFormat(nativeImage, @format);

  Result := ifUndefined;

  if IsEqualGUID(format, ImageFormatMemoryBMP) then
    Result := ifMemoryBMP;

  if IsEqualGUID(format, ImageFormatBMP) then
    Result := ifBMP;

  if IsEqualGUID(format, ImageFormatEMF) then
    Result := ifEMF;

  if IsEqualGUID(format, ImageFormatWMF) then
    Result := ifWMF;

  if IsEqualGUID(format, ImageFormatJPEG) then
    Result := ifJPEG;

  if IsEqualGUID(format, ImageFormatGIF) then
    Result := ifGIF;

  if IsEqualGUID(format, ImageFormatPNG) then
    Result := ifPNG;

  if IsEqualGUID(format, ImageFormatTIFF) then
    Result := ifTIFF;

  if IsEqualGUID(format, ImageFormatEXIF) then
    Result := ifEXIF;

  if IsEqualGUID(format, ImageFormatIcon) then
    Result := ifIcon;
end;

function TGPImage.GetHeight: UINT;
var
  height: UINT;

begin
  height := 0;
  SetStatus(GdipGetImageHeight(nativeImage, height));
  result := height;
end;

function TGPImage.GetHorizontalResolution: Single;
var
  resolution: Single;
begin
  resolution := 0.0;
  SetStatus(GdipGetImageHorizontalResolution(nativeImage, resolution));
  result := resolution;
end;

function TGPImage.GetVerticalResolution: Single;
var
  resolution: Single;
begin
  resolution := 0.0;
  SetStatus(GdipGetImageVerticalResolution(nativeImage, resolution));
  result := resolution;
end;

function TGPImage.GetWidth: UINT;
var
  width: UINT;
begin
  width := 0;
  SetStatus(GdipGetImageWidth(nativeImage, width));
  result := width;
end;

constructor TGPImage.Create(nativeImage: GpImage; status: TStatus);
begin
  SetNativeImage(nativeImage);
  lastResult := status;
end;

procedure TGPImage.SetNativeImage(nativeImage: GpImage);
begin
  self.nativeImage := nativeImage;
end;

function TGPImage.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;


function TGPGraphicsPath.AddLines(points: PGPPoint; count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathLine2I(nativePath, points, count));
end;

function TGPGraphicsPath.AddPie(rect: TGPRectF; startAngle,
  sweepAngle: Single): TStatus;
begin
  result := AddPie(rect.X, rect.Y, rect.Width, rect.Height, startAngle, sweepAngle);
end;

function TGPGraphicsPath.AddPie(x, y, width, height, startAngle,
  sweepAngle: Single): TStatus;
begin
  result := SetStatus(GdipAddPathPie(nativePath, x, y, width, height, startAngle, sweepAngle));
end;

function TGPGraphicsPath.AddPolygon(points: PGPPointF;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathPolygon(nativePath, points, count));
end;

function TGPGraphicsPath.AddPolygon(points: PGPPoint;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathPolygonI(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPointF;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathCurve(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPoint;
  count: Integer): TStatus;
begin
  result := SetStatus(GdipAddPathCurveI(nativePath, points, count));
end;

function TGPGraphicsPath.AddCurve(points: PGPPoint; count: Integer; tension: Single): TStatus;
begin
  result := SetStatus(GdipAddPathCurve2I(nativePath, points, count, tension));
end;

function TGPGraphicsPath.AddBezier(pt1, pt2, pt3, pt4: TGPPoint): TStatus;
begin
  result := AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

function TGPGraphicsPath.AddBezier(pt1, pt2, pt3, pt4: TGPPointF): TStatus;
begin
  result := AddBezier(pt1.X, pt1.Y, pt2.X, pt2.Y, pt3.X, pt3.Y, pt4.X, pt4.Y);
end;

function TGPGraphicsPath.AddBezier(x1, y1, x2, y2, x3, y3, x4,
  y4: Single): TStatus;
begin
  result := SetStatus(GdipAddPathBezier(nativePath, x1, y1, x2, y2, x3, y3, x4, y4));
end;

//------------------------------------------------------------------------------

function TGPGraphics.FillEllipse(brush: TGPBrush; const rect: TGPRectF): TStatus;
begin
  result := FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; x, y, width, height: Single): TStatus;
begin
  result := SetStatus(GdipFillEllipse(nativeGraphics,
                           brush.nativeBrush, x, y,
                           width, height));
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; const rect: TGPRect): TStatus;
begin
  result := FillEllipse(brush, rect.X, rect.Y, rect.Width, rect.Height);
end;

function TGPGraphics.FillEllipse(brush: TGPBrush; x, y, width, height: Integer): TStatus;
begin
  result := SetStatus(GdipFillEllipseI(nativeGraphics,
                            brush.nativeBrush,
                            x,
                            y,
                            width,
                            height));
end;

function TGPGraphics.FillPath(brush: TGPBrush;
  path: TGPGraphicsPath): TStatus;
begin
  result := SetStatus(GdipFillPath(nativeGraphics, brush.nativeBrush, path.nativePath));
end;

function TGPGraphics.ExcludeClip(const rect: TGPRectF): TStatus;
begin
  result := SetStatus(GdipSetClipRect(nativeGraphics, rect.X, rect.Y, rect.Width, rect.Height, CombineModeExclude));
end;

function TGPGraphics.ExcludeClip(region: TGPRegion): TStatus;
begin
  result := SetStatus(GdipSetClipRegion(nativeGraphics, region.nativeRegion, CombineModeExclude));
end;

function TGPGraphics.SetClip(region: TGPRegion;
  combineMode: TCombineMode): TStatus;
begin
  result := SetStatus(GdipSetClipRegion(nativeGraphics, region.nativeRegion, combineMode));
end;

function TGPGraphics.ResetClip: TStatus;
begin
  result := SetStatus(GdipResetClip(nativeGraphics));
end;

function MakeColor(a, r, g, b: Byte): ARGB; overload;
begin
  result := ((DWORD(b) shl  BlueShift) or
             (DWORD(g) shl GreenShift) or
             (DWORD(r) shl   RedShift) or
             (DWORD(a) shl AlphaShift));
end;

function MakeColor(a: Byte; Color: TColor): ARGB; overload;
var
  rgb: DWORD;
begin
  rgb := ColorToRGB(Color);
  Result := MakeColor(a, (rgb and $FF), (rgb and $FF00) shr 8, (rgb and $FF0000) shr 16);
end;

function MakeColor(r, g, b: Byte): ARGB; overload;
begin
  result := MakeColor(255, r, g, b);
end;

function GetAlpha(color: ARGB): BYTE;
begin
  result := BYTE(color shr AlphaShift);
end;

function GetRed(color: ARGB): BYTE;
begin
  result := BYTE(color shr RedShift);
end;

function GetGreen(color: ARGB): BYTE;
begin
  result := BYTE(color shr GreenShift);
end;

function GetBlue(color: ARGB): BYTE;
begin
  result := BYTE(color shr BlueShift);
end;

function TGPGraphics.GetCompositingQuality: TCompositingQuality;
begin
  SetStatus(GdipGetCompositingQuality(nativeGraphics, result));
end;

function TGPGraphics.SetCompositingQuality(
  compositingQuality: TCompositingQuality): TStatus;
begin
  result := SetStatus(GdipSetCompositingQuality( nativeGraphics, compositingQuality));
end;

function TGPImage.RotateFlip(rotateFlipType: TRotateFlipType): TStatus;
begin
  Result := SetStatus(GdipImageRotateFlip(nativeImage, rotateFlipType));
end;


{ TGPBitmap }

constructor TGPBitmap.Create(stream: IStream; useEmbeddedColorManagement: BOOL);
var
  bitmap: GpBitmap;
begin
  bitmap := nil;
  if(useEmbeddedColorManagement) then
    lastResult := GdipCreateBitmapFromStreamICM(stream, bitmap)
  else
    lastResult := GdipCreateBitmapFromStream(stream, bitmap);
  SetNativeImage(bitmap);
end;

constructor TGPBitmap.Create(nativeBitmap: GpBitmap);
begin
  lastResult := Ok;
  SetNativeImage(nativeBitmap);
end;

constructor TGPBitmap.Create(width, height: Integer; format: TPixelFormat);
var
  bitmap: GpBitmap;
begin
  bitmap := nil;
  lastResult := GdipCreateBitmapFromScan0(width, height, 0, format, nil, bitmap);
  SetNativeImage(bitmap);
end;

function TGPBitmap.FromStream(stream: IStream;
  useEmbeddedColorManagement: BOOL): TGPBitmap;
begin
  Result := TGPBitmap.Create(stream, useEmbeddedColorManagement);
end;

function TGPBitmap.GetPixel(x, y: Integer; out color: TGPColor): TStatus;
begin
  Result := SetStatus(GdipBitmapGetPixel(GpBitmap(nativeImage), x, y, color));
end;

function TGPBitmap.SetPixel(x, y: Integer; color: TGPColor): TStatus;
begin
  Result := SetStatus(GdipBitmapSetPixel(GpBitmap(nativeImage), x, y, color));
end;



function TGPBitmap.SetResolution(xdpi, ydpi: Single): TStatus;
begin
  Result := SetStatus(GdipBitmapSetResolution(GpBitmap(nativeImage), xdpi, ydpi));
end;

{ TGPImageAttributes }

constructor TGPImageAttributes.Create;
begin
  nativeImageAttr := nil;
  lastResult := GdipCreateImageAttributes(nativeImageAttr);
end;

destructor TGPImageAttributes.Destroy;
begin
  GdipDisposeImageAttributes(nativeImageAttr);
  inherited Destroy;
end;

function TGPImageAttributes.SetStatus(status: TStatus): TStatus;
begin
  if (status <> Ok) then lastResult := status;
  result := status;
end;

function TGPImageAttributes.SetColorKey(colorLow, colorHigh: TGPColor;
  type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  Result := SetStatus(GdipSetImageAttributesColorKeys(nativeImageAttr, type_,
    TRUE, colorLow, colorHigh));
end;

function TGPImageAttributes.ClearColorKey(type_: TColorAdjustType = ColorAdjustTypeDefault): TStatus;
begin
  Result := SetStatus(GdipSetImageAttributesColorKeys(nativeImageAttr, type_,
    FALSE, 0, 0));
end;

initialization
begin
  // Initialize StartupInput structure

  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := True;
  StartupInput.SuppressExternalCodecs   := False;
  StartupInput.GdiplusVersion := 1;

  StartupOutput.NotificationHook := nil;
  StartupOutput.NotificationUnhook := nil;

  // Initialize GDI+
  GdiplusStartup(gdiplusToken, @StartupInput, @StartupOutput);

  StartupOutput.NotificationHook(gdiplusToken);
end;

finalization
begin
  // Close GDI +
  //if not IsLibrary then
  begin
    StartupOutput.NotificationUnhook(gdiplusToken);
    GdiplusShutdown(gdiplusToken);
  end;
end;

end.
