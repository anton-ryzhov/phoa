//**********************************************************************************************************************
//  $Id: phGUIObj.pas,v 1.37 2005-03-02 17:13:45 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phGUIObj;

interface
uses
  Windows, Messages, Types, SysUtils, Graphics, Classes, Controls, ActnList, Forms,
  GR32, TB2Item, TBX,
  phIntf, phMutableIntf, phAppIntf, phNativeIntf, phObj, phGraphics, ConsVars;

type

   //===================================================================================================================
   // TThumbnailViewer - �������� ��������� ������� �����������
   //===================================================================================================================

  TThumbnailViewerState = (
    tvsLayoutChangePending,     // Layout change pending
    tvsSelectionChangePending); // Selection change pending

  TThumbnailViewerStates = set of TThumbnailViewerState;

   // ���������� � ��������� TThumbnailViewer, ������������ ��� �������� SaveDisplay() � RestoreDisplay()
  IThumbnailViewerDisplayData = interface(IInterface)
    ['{436126B8-5E50-4BAB-83D1-CA83FE19B976}']
     // ����������/�������� �� IPhoaDataStream
    procedure SaveToDataStream(DataStream: IPhoaDataStream);
    procedure LoadFromDataStream(DataStream: IPhoaDataStream);
     // Prop handlers
    function  GetFocusedID: Integer;
    function  GetSelectedIDCount: Integer;
    function  GetSelectedIDs(Index: Integer): Integer;
    function  GetTopOffset: Integer;
     // Props
     // -- ID ���������������� �����������
    property FocusedID: Integer read GetFocusedID;
     // -- ���������� ID ���������� �����������
    property SelectedIDCount: Integer read GetSelectedIDCount;
     // -- ID ���������� ����������� �� �������
    property SelectedIDs[Index: Integer]: Integer read GetSelectedIDs;
     // -- �������� �������� ���� ���� ���������
    property TopOffset: Integer read GetTopOffset;
  end;

   // ���������� ��� ��������� ����
  TThumbnailViewerPaintInfo = record
    RClip:     TRect;     // ClipRect
    RClient:   TRect;     // ClientRect
    Bitmap:    TBitmap32; // Buffer bitmap object
    bFocused:  Boolean;   // True if control has focus
  end;

   // ���������� ��������� ������� ������� ��������������� �������
  TViewerInsertionCoord = record
    iIndex: Integer; // ������ ������, ����� ������� ����� ���������� ����� �������, [0..ItemCount], ��� iIndex=ItemCount
                     //   ������ ������ ���� ��������� ����� ���������� ������
    bLower: Boolean; // ������������, ��� ��������� ��� ��������������� � ����������� ��������� ������� �������, �.�.
                     //   ����� idx ��������� �� �����, ����������� � ������ ������ � ��� ���� �� ����� ������� �����.
                     //   � ����� ������, ���� bLower=True, ������ �������� � ����� ���������� ������, ���� False - �
                     //   ������ ������� (����� �� ������� ������)
  end;

   // ����� ����� �������� ������
  TThumbBackBorderStyle = (tbbsNone, tbbsFlat, tbbsRaised, tbbsSunken, tbbsPlain, tbbsGroove, tbbsXP, tbbsColor);

   // ���� ������
  TThumbCorner = (tcLeftTop, tcRightTop, tcLeftBottom, tcRightBottom);

  TThumbCornerDetail = record
    bDisplay: Boolean;      // True, ���� �������� � ������ ���� ������������
    Prop:     TPicProperty; // �������� ��� �����������
  end;

  TThumbCornerDetails = Array[TThumbCorner] of TThumbCornerDetail;

   // ����� ����������� TThumbnailViewer
  TThumbViewerDisplayMode = (
    tvdmTile,    // ������� - � ���� ����� �� �������
    tvdmDetail); // ��������� - ����� ������, ������ ��������

  TThumbnailViewer = class(TCustomControl)
  private
     // ��������� ������ �����������, ������������ � ��������
    FPicList: IPhoaPicList;
     // �������� ������ ��� ��������� ����������� ���� ��������
    FBuffer: TBitmap32;
     // ������ ������-������ (������ � ���������, ��������� � �.�.)
    FItemSize: TSize;
     // ������ ������ "������������" ���� (���� �������)
    FVRange: Integer;
     // ����� ���������� �������
    FItemCount: Integer;
     // ���������� �������, ������� �������������� � ���� ��������
    FVisibleItems: Integer;
     // ���������� ����� �������, ������� �������������� � ���� ��������
    FVisibleRows: Integer;
     // ���������� �������� � ��������
    FColCount: Integer;
     // ������ ����� ������ ������, ������������� ������� ��������
    FTextLineHeight: Integer;
     // ���� ���������� ���������� ������
    FFontParamsValid: Boolean;
     // ������ ���� ������ (nil, ���� ��� �������� ������������ ����)
    FThumbShadow: TBitmap32;
     // ���������� ������
    FSelectedPics: IPhotoAlbumPicList;
     // ������ ��������� ������
    FItemIndex: Integer;
     // ������ ������, � �������� �������� �������� ��������� (Shift+[�������] ��� Shift+[����])
    FStreamSelStart: Integer;
     // ������ ������, ������� ����� ������� (ItemIndex), ���� ������������ ������ ����� ������ ����, �� ������� ����
    FNoMoveItemIndex: Integer;
     // ���� �������� ����� � Dragging
    FDragPending: Boolean;
     // ���������� ������� ����� ��� Dragging/Marqueing
    FStartPos: TPoint;
     // ������� � ������� ���������� ������� ��������������� �������
    FDragTargetCoord: TViewerInsertionCoord;
    FOldDragTargetCoord: TViewerInsertionCoord;
     // ������� ����������
    FUpdateLock: Integer;
     // ���� ��� ����� ���������� ��������� (marquee)
    FTempDC: HDC;
    FMarqueing: Boolean;
    FMarqueeCur: TPoint;
     // ������, ������������ � ����� �������
    FThumbCornerDetails: TThumbCornerDetails;
     // ������ ������, ��� �������� ��������� ��� ����������� Tooltip
    FLastTooltipIdx: Integer;
     // True, ���� ���� ������ ������ ������� ���� ������ � Ctrl, � ��� � ���������� ���������� ���������� ���������
     //   ����������� ����
    FShellCtxMenuOnMouseUp: Boolean;
     // Props storage
    FDragInsideEnabled: Boolean;
    FOnSelectionChange: TNotifyEvent;
    FBorderStyle: TBorderStyle;
    FDragEnabled: Boolean;
    FShowThumbTooltips: Boolean;
    FThumbTooltipProps: TPicProperties;
    FThumbBackColor: TColor;
    FThumbFontColor: TColor;
    FOnStartViewMode: TNotifyEvent;
    FDisplayMode: TThumbViewerDisplayMode;
    FTopOffset: Integer;
    FThumbnailSize: TSize;
    FThumbBackBorderStyle: TThumbBackBorderStyle;
    FThumbBackBorderColor: TColor;
    FThumbShadowOpacity: Byte;
    FThumbShadowColor: TColor;
    FThumbShadowOffset: TPoint;
    FThumbShadowBlurRadius: Integer;
    FThumbShadowVisible: Boolean;
    FStates: TThumbnailViewerStates;
     // Painting stage handlers
    procedure Paint_EraseBackground(const Info: TThumbnailViewerPaintInfo);
    procedure Paint_Thumbnails(const Info: TThumbnailViewerPaintInfo);
    procedure Paint_Thumbnail(const Info: TThumbnailViewerPaintInfo; iIndex: Integer; ItemRect: TRect; bSelected: Boolean);
    procedure Paint_TransferBuffer(const Info: TThumbnailViewerPaintInfo);
     // Validates the specified offset and returns the correctly ranged offset value
    function  GetValidTopOffset(iOffset: Integer): Integer;
     // ������������ ��������� ������
    procedure CalcFontParams;
     // ���������� FShadowBitmap
    procedure ResetShadow;
     // ������� FShadowBitmap
    procedure PrepareShadow;
     // �������� [����������] �������� ���������� �����������
    procedure LayoutChanged;
     // �������� [����������] ������� ����� ���������
    procedure SelectionChanged;
     // ���������� ������ ������ �������� ������������� ������
    function  GetFirstVisibleIndex: Integer;
     // Invalidates all the selected thumbnails
    procedure InvalidateSelection;
     // ������ ��� ������� ��������� � ������
    procedure ToggleSelection(Index: Integer);
    function  AddToSelection(Index: Integer): Boolean;
    procedure RemoveFromSelection(Index: Integer);
     // ���������� ItemIndex �� ����� �����, �� ������ ���������. ��� bUpdateStreamSelStart=True ����� ���������
     //   FStreamSelStart. ��� bScrollIntoView=True ����� ������������ ����� � ���� ���������
    procedure MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart, bScrollIntoView: Boolean);
     // �������� OnStartViewMode
    procedure DoStartViewMode;
     // ����������� ScrollBar
    procedure UpdateScrollBar;
     // �������� �������� �������� ������� � �������� ItemIndex � idxEnd. ��� bRectangular=False �������� ������ ������
     //   �� �� ��������, ��� bRectangular=True �������� ������������� ����
    procedure SelectRange(idxStart, idxEnd: Integer; bRectangular: Boolean);
     // ������ � ������ ���������� ��������� (marquee)
    procedure PaintMarquee;
    procedure MarqueingStart;
    procedure MarqueingEnd;
     // ������������ ������ ������� ��������������� �������. ���� bInvalidate=True, ����� ��������� ���������� iIndex �
     //   -1 � bLower � False
    procedure DragDrawInsertionPoint(var Coord: TViewerInsertionCoord; bInvalidate: Boolean);
     // ����������� ����������� �������� ������� � ���� Hint
    procedure AdjustTooltip(ix, iy: Integer);
     // Message handlers
    procedure CMDrag(var Msg: TCMDrag);                         message CM_DRAG;
    procedure CMFontChanged(var Msg: TMessage);                 message CM_FONTCHANGED;
    procedure CMInvalidate(var Msg: TMessage);                  message CM_INVALIDATE;
    procedure CMMouseWheel(var Msg: TCMMouseWheel);             message CM_MOUSEWHEEL;
    procedure WMContextMenu(var Msg: TWMContextMenu);           message WM_CONTEXTMENU;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd);             message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode);             message WM_GETDLGCODE;
    procedure WMKillFocus(var Msg: TWMKillFocus);               message WM_KILLFOCUS;
    procedure WMNCPaint(var Msg: TWMNCPaint);                   message WM_NCPAINT;
    procedure WMSetFocus(var Msg: TWMSetFocus);                 message WM_SETFOCUS;
    procedure WMVScroll(var Msg: TWMVScroll);                   message WM_VSCROLL;
    procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
     // Prop handlers
    function  GetDropTargetIndex: Integer;
    function  GetIDSelected(iID: Integer): Boolean;
    function  GetIndexSelected(iIndex: Integer): Boolean;
    function  GetSelectedIndexes(Index: Integer): Integer;
    function  GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetDisplayMode(Value: TThumbViewerDisplayMode);
    procedure SetItemIndex(Value: Integer);
    procedure SetShowThumbTooltips(Value: Boolean);
    procedure SetThumbBackBorderColor(Value: TColor);
    procedure SetThumbBackBorderStyle(Value: TThumbBackBorderStyle);
    procedure SetThumbBackColor(Value: TColor);
    procedure SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
    procedure SetThumbFontColor(Value: TColor);
    procedure SetThumbnailSize(const Value: TSize);
    procedure SetThumbShadowBlurRadius(Value: Integer);
    procedure SetThumbShadowColor(Value: TColor);
    procedure SetThumbShadowOffset(const Value: TPoint);
    procedure SetThumbShadowOpacity(Value: Byte);
    procedure SetThumbShadowVisible(Value: Boolean);
    procedure SetThumbTooltipProps(Value: TPicProperties);
    procedure SetTopOffset(Value: Integer);
    function GetUpdateLocked: Boolean;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Msg: TMessage); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
     // ��������� ������������ ������ �����������
    procedure ReloadPicList(APicList: IPhoaPicList);
     // ������ ������ IThumbnailViewerDisplayData, ��������� � ���� ������� ��������� ����������� � ���������� ���
    function  SaveDisplay: IThumbnailViewerDisplayData;
     // ��������������� ��������� ����������� �� Data; ��������������� ����������� ������������� ������, ���������� �
     //   ���������� ����������� ������ SaveDisplay()
    procedure RestoreDisplay(Data: IThumbnailViewerDisplayData);
     // ������� ��������� �� ���� ������� � ���������� True, ���� ��� ����
    function  ClearSelection: Boolean;
     // �������� ��� ������
    procedure SelectAll;
     // ���������� ItemIndex � �����, ��� -1, ���� ��� ��� ������
    function  ItemAtPos(ix, iy: Integer): Integer;
     // ���������� ���������� ������ � �������� Index. ���� bAllowInvisible=False, �� ���������� ������ �������������,
     //   ���� ����� �� ������������ � ClientRect
    function  ItemRect(Index: Integer; bAllowInvisible: Boolean): TRect;
     // ������ ����� � ������� �� ����������
    procedure InvalidateItem(Index: Integer); overload;
    procedure InvalidateItem(Pic: IPhoaPic); overload;
     // ������������ ����������, ����� ���� ����� ItemIndex
    procedure ScrollIntoView;
     // ���������� �����������
    procedure BeginUpdate;
    procedure EndUpdate;
     // Props
    property DisplayMode: TThumbViewerDisplayMode read FDisplayMode write SetDisplayMode;
     // -- ����, ����������� �������������� �������
    property DragEnabled: Boolean read FDragEnabled write FDragEnabled;
     // -- ����, ����������� ������������ ������� ������ ���� � ������� Drag'n'Drop. ���� ������������ ���������, �
     //    DragEnabled=True, �� ����� ������ "�����������" ������ ������
    property DragInsideEnabled: Boolean read FDragInsideEnabled write FDragInsideEnabled;
     // -- ������ ���������� ����� ������� ��� Drag'n'Drop. -1, ���� �� ���� �����������
    property DropTargetIndex: Integer read GetDropTargetIndex;
     // -- True, ���� ����������� � �������� ID ��������
    property IDSelected[iID: Integer]: Boolean read GetIDSelected;
     // -- True, ���� ����������� � �������� �������� ��������
    property IndexSelected[iIndex: Integer]: Boolean read GetIndexSelected;
     // -- ������ ���������������� �����������
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
     // -- ������� ���������� ����������� � ����� ������ ����������� viewer'� (Index - ������ ����������� �����������,
     //    0..SelCount-1)
    property SelectedIndexes[Index: Integer]: Integer read GetSelectedIndexes;
     // -- ���������� �����������
    property SelectedPics: IPhotoAlbumPicList read FSelectedPics;
     // -- ���� True, ���������� ����������� �������� �������
    property ShowThumbTooltips: Boolean read FShowThumbTooltips write SetShowThumbTooltips;
     // -- ��������� ��������
    property States: TThumbnailViewerStates read FStates;
     // -- ���� ����� ���� ������ ��� ThumbBackBorderStyle=tbbsColor
    property ThumbBackBorderColor: TColor read FThumbBackBorderColor write SetThumbBackBorderColor;
     // -- ����� ����� ���� ������
    property ThumbBackBorderStyle: TThumbBackBorderStyle read FThumbBackBorderStyle write SetThumbBackBorderStyle;
     // -- ���� ���� �������
    property ThumbBackColor: TColor read FThumbBackColor write SetThumbBackColor;
     // -- ���� ������ �������
    property ThumbFontColor: TColor read FThumbFontColor write SetThumbFontColor;
     // -- ������, ������������ �� �������
    property ThumbCornerDetails[Corner: TThumbCorner]: TThumbCornerDetail read GetThumbCornerDetails write SetThumbCornerDetails;
     // -- ��������� ���� ������
     // ---- ������ ��������
    property ThumbShadowBlurRadius: Integer read FThumbShadowBlurRadius write SetThumbShadowBlurRadius;
     // ---- ����
    property ThumbShadowColor: TColor read FThumbShadowColor write SetThumbShadowColor;
     // ---- ��������
    property ThumbShadowOffset: TPoint read FThumbShadowOffset write SetThumbShadowOffset;
     // ---- ��������������
    property ThumbShadowOpacity: Byte read FThumbShadowOpacity write SetThumbShadowOpacity;
     // ---- "���������"
    property ThumbShadowVisible: Boolean read FThumbShadowVisible write SetThumbShadowVisible;
     // -- ������, ������������ �� ����������� ��������� �������
    property ThumbTooltipProps: TPicProperties read FThumbTooltipProps write SetThumbTooltipProps;
     // -- ������� �������
    property ThumbnailSize: TSize read FThumbnailSize write SetThumbnailSize;
     // -- �������� �������� ���� ���� ������������ ������ ������ �������, � ��������
    property TopOffset: Integer read FTopOffset write SetTopOffset;
     // -- True, ���� FUpdateLock>0
    property UpdateLocked: Boolean read GetUpdateLocked;
  published
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color default clBtnFace;
    property Constraints;
    property DragCursor;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
     // -- ������� ��������� ��������� �� viewer'�
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
     // -- �������, ������������ �����, ����� ����� ������ �������� �����������
    property OnStartViewMode: TNotifyEvent read FOnStartViewMode write FOnStartViewMode;
  end;

   //===================================================================================================================
   // ������ ���������, �������������� ����� ����� � ��� ������� (������ ����������� �������� #9, ������ ������
   // ������������� �� ������ ����, ������ - �� �������)
   //===================================================================================================================

  TPhoAHintWindow = class(THintWindow)
    procedure Paint; override;
  end;

   //===================================================================================================================
   // "������" ��� ��������� �������� �����
   //===================================================================================================================

  TSizeGripper = class(TCustomControl)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

   //===================================================================================================================
   // ���������� IPhoaAction (������ ������ TAction)
   //===================================================================================================================

  TPhoaAction = class(TInterfacedObject, IPhoaAction, IPhotoAlbumAction)
  private
     // ������ �� ��������������� Action
    FAction: TCustomAction;
     // ���������� Action
    FExecuteProc: TPhoaActionExecuteProc;
     // True, ���� ������ ������ "�����" (����� �������). ������ �� ����� Action-� �� ����������� � ������ � ���
     //   ����������� ������� ������������� ������������ ����� � FAction 
    FVolatile: Boolean;
     // Prop storage
    FTag: Integer; 
     // IPhoaAction
    function  Execute: LongBool; stdcall;
    function  GetCaption: WideString; stdcall;
    function  GetCategory: WideString; stdcall;
    function  GetEnabled: LongBool; stdcall;
    function  GetHint: WideString; stdcall;
    function  GetName: WideString; stdcall;
    function  GetTag: Integer; stdcall;
    procedure SetCaption(const Value: WideString); stdcall;
    procedure SetCategory(const Value: WideString); stdcall;
    procedure SetEnabled(Value: LongBool); stdcall;
    procedure SetHint(const Value: WideString); stdcall;
    procedure SetTag(Value: Integer); stdcall;
     // IPhotoAlbumAction
    function  GetNativeAction: TCustomAction;
  public
    constructor Create(AAction: TCustomAction; bVolatile: Boolean; AExecuteProc: TPhoaActionExecuteProc);
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // ���������� IPhoaActionList (������ ������ TInterfaceList)
   //===================================================================================================================

  TPhoaActionList = class(TInterfacedObject, IPhoaActionList)
  private
     // ������ ��� ���������� ������ �� "����������" Action-� (����������� ������ � Create)
    FList: IInterfaceList;
     // ������ "���������" Action-��, � ������� ����������� underlaying actions
    FNativeList: TCustomActionList;
     // ���������� OnExecute ��� ����� ����������� Actions
    procedure ActionExecute(Sender: TObject);
     // IPhoaActionList
    function  Add(const sName: WideString; AExecuteProc: TPhoaActionExecuteProc): IPhoaAction; stdcall;
    function  FindName(const sName: WideString): IPhoaAction; stdcall;
    function  GetCount: Integer; stdcall;
    function  GetItems(Index: Integer): IPhoaAction; stdcall;
  public
     // ������ ������, �������� ��� �������� ��� Actions �� NativeList
    constructor Create(ANativeList: TCustomActionList);
  end;

   //===================================================================================================================
   // ���������� IPhoaMenuEntry, IPhoaMenuItem � IPhoaMenu (������ ������ TTBCustomItem)
   //===================================================================================================================

  TPhoaMenuItem = class(TInterfacedObject, IPhoaMenuEntry, IPhoaMenuItem, IPhoaMenu, IPhoaMenuSeparator)
  private
     // ������ �� ��������������� ����� ����
    FItem: TTBCustomItem;
     // ������ ���������� �������
    FSubentries: IInterfaceList;
     // ������ �� Action interface
    FAction: IPhotoAlbumAction;
     // True, ���� ������ ������ "�����" (����� �������). ������ �� ����� ������ ����������� � ������ ����-���������
     //   ������ � ��� ������, ���� ���� ����-�������� ����� Volatile; ��� ����������� ������� �������������
     //   ������������ ����� � FItem
    FVolatile: Boolean;
     // Prop storage
    FOwner: TPhoaMenuItem;
     // IPhoaMenuEntry
    procedure Remove; stdcall;
    function  GetIndex: Integer; stdcall;
    function  GetOwner: IPhoaMenu; stdcall;
    procedure SetIndex(Value: Integer); stdcall;
     // IPhoaMenuItem
    function  GetAction: IPhoaAction; stdcall;
     // IPhoaMenu
    function  AddMenu: IPhoaMenu; stdcall;
    function  AddItem(Action: IPhoaAction): IPhoaMenuItem; stdcall;
    function  AddSeparator: IPhoaMenuSeparator; stdcall;
    function  FindItemByActionName(const sActionName: WideString; bRecursive: LongBool): IPhoaMenuItem; stdcall;
    function  GetCaption: WideString; stdcall;
    function  GetItemByActionName(const sActionName: WideString; bRecursive: LongBool): IPhoaMenuItem; stdcall;
    function  GetSubentryCount: Integer; stdcall;
    function  GetSubentries(Index: Integer): IPhoaMenuEntry; stdcall;
    procedure SetCaption(const Value: WideString); stdcall;
  protected
    procedure AddSubentry(Item: IPhoaMenuEntry);
    procedure RemoveSubentry(Item: IPhoaMenuEntry);
  public
    constructor Create(AOwner: TPhoaMenuItem; AItem: TTBCustomItem; AAction: IPhotoAlbumAction; bVolatile, bRecursive: Boolean);
    destructor Destroy; override;
  end;

   // ������ ����� ��������� IThumbnailViewerDisplayData
  function  NewThumbnailViewerDisplayData: IThumbnailViewerDisplayData; overload;
  function  NewThumbnailViewerDisplayData(SelectedPics: IPhoaPicList; iFocusedID, iTopOffset: Integer): IThumbnailViewerDisplayData; overload;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses Math, Themes, phUtils;

   //===================================================================================================================
   // TThumbnailViewer
   //===================================================================================================================

  function TThumbnailViewer.AddToSelection(Index: Integer): Boolean;
  begin
    if (Index>=0) and (Index<FItemCount) then begin
      FSelectedPics.Add(FPicList[Index], True, Result);
      if Result then begin
        InvalidateItem(Index);
        SelectionChanged;
      end;
    end else
      Result := False;
  end;

  procedure TThumbnailViewer.AdjustTooltip(ix, iy: Integer);
  var idx: Integer;
  begin
     // ����������� Thumbnail Tooltip
    if FShowThumbTooltips and (ThumbTooltipProps<>[]) and (GetKeyState(VK_LBUTTON) and $80=0) then idx := ItemAtPos(ix, iy) else idx := -1;
     // ���� ������ ������, ��� �������� ��������� ��� ����������� Tooltip, ���������
    if idx<>FLastTooltipIdx then begin
       // �������� Tooltip, ���� ����
      Application.CancelHint;
       // ������ �������� (��������� �����, ����� � StatusBar ������ �� ��������)
      if idx<0 then Hint := '' else Hint := GetPicPropStrs(FPicList[idx], FThumbTooltipProps, ':'#9, #13)+'|';
      FLastTooltipIdx := idx;
    end;
  end;

  procedure TThumbnailViewer.BeginUpdate;
  begin
//    if FUpdateLock=0 then Perform(WM_SETREDRAW, 0, 0);
    Inc(FUpdateLock);
  end;

  procedure TThumbnailViewer.CalcFontParams;
  var Cnv: TCanvas;
  begin
     // ������� ������ ������ ������
    Cnv := TCanvas.Create;
    try
      Cnv.Handle := GetDC(0);
      try
        Cnv.Font.Assign(Font);
        FTextLineHeight := Cnv.TextHeight('Wg');
        FFontParamsValid := True;
      finally
        ReleaseDC(0, Cnv.Handle);
        Cnv.Handle := 0;
      end;
    finally
      Cnv.Free;
    end;
  end;

  function TThumbnailViewer.ClearSelection: Boolean;
  begin
     // ���� ���� ���������
    Result := FSelectedPics.Count>0;
    if Result then begin
      InvalidateSelection;
      FSelectedPics.Clear;
      SelectionChanged;
    end;
  end;

  procedure TThumbnailViewer.CMDrag(var Msg: TCMDrag);
  begin
    if Msg.DragMessage in [dmDragDrop, dmDragCancel] then DragDrawInsertionPoint(FOldDragTargetCoord, True);
    inherited;
  end;

  procedure TThumbnailViewer.CMFontChanged(var Msg: TMessage);
  begin
    FFontParamsValid := False;
  end;

  procedure TThumbnailViewer.CMInvalidate(var Msg: TMessage);
  begin
    if HandleAllocated then InvalidateRect(Handle, nil, True);
  end;

  procedure TThumbnailViewer.CMMouseWheel(var Msg: TCMMouseWheel);
  var iAmount: Integer;
  begin
    inherited;
    if Msg.Result=0 then begin
      Msg.Result := 1;
       // ������ ������ * ���������� ������� ���������
      iAmount := FItemSize.cy*(Msg.WheelDelta div WHEEL_DELTA);
       // ���� ����� Ctrl - �������� ����� �� ������� ����� �����
      if ssCtrl in Msg.ShiftState then iAmount := iAmount*FVisibleRows;
       // ��������
      TopOffset := TopOffset-iAmount;
    end;
  end;

  constructor TThumbnailViewer.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle           := [csCaptureMouse, csClickEvents, csOpaque, csDoubleClicks, csReplicatable];
    Width                  := 100;
    Height                 := 100;
    TabStop                := True;
    ParentColor            := False;
    Color                  := clBtnFace;
    FBorderStyle           := bsSingle;
    FColCount              := 1;
    FNoMoveItemIndex       := -1;
    FSelectedPics          := NewPhotoAlbumPicList(True);
    FThumbBackBorderColor  := clGray;
    FThumbBackBorderStyle  := tbbsXP;
    FThumbBackColor        := clBtnFace;
    FThumbFontColor        := clWindowText;
    FThumbnailSize.cx      := 100;
    FThumbnailSize.cy      := 100;
    FThumbShadowBlurRadius := 40;
    FThumbShadowColor      := clBlack;
    FThumbShadowOffset     := Point(7, 7);
    FThumbShadowOpacity    := 140;
    FThumbShadowVisible    := True;
  end;

  procedure TThumbnailViewer.CreateParams(var Params: TCreateParams);
  begin
    inherited CreateParams(Params);
    with Params do begin
      WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
      Style := Style or WS_VSCROLL;
      if FBorderStyle=bsSingle then begin
        Style := Style and not WS_BORDER;
        ExStyle := ExStyle or WS_EX_CLIENTEDGE;
      end;
    end;
  end;

  procedure TThumbnailViewer.CreateWnd;
  var iw, ih: Integer;
  begin
    iw := Width;
    ih := Height;
    inherited CreateWnd;
    SetWindowPos(Handle, 0, Left, Top, iw, ih, SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  procedure TThumbnailViewer.DblClick;
  begin
    DoStartViewMode;
  end;

  destructor TThumbnailViewer.Destroy;
  begin
    FSelectedPics := nil;
    FPicList      := nil;
    FBuffer.Free;
    FThumbShadow.Free;
    FPicList := nil;
    inherited Destroy;
  end;

  procedure TThumbnailViewer.DoStartViewMode;
  begin
    if Assigned(FOnStartViewMode) then FOnStartViewMode(Self);
  end;

  procedure TThumbnailViewer.DragDrawInsertionPoint(var Coord: TViewerInsertionCoord; bInvalidate: Boolean);
  var
    dc: HDC;
    hp, hOld: HPEN;
    p: TPoint;
    r: TRect;
    bLower: Boolean;
  begin
    if Coord.iIndex>=0 then begin
       // ������� ���������� ����������. ���� bLower, �� ����������� ������, ����� ��������
      bLower := (Coord.iIndex mod FColCount=0) and Coord.bLower;
      r := ItemRect(Coord.iIndex-iif(bLower, 1, 0), False);
       // ���� ����� ���� �������-������ �����
      if not IsRectEmpty(r) then begin
        p.x := iif(bLower, r.Right, r.Left);
        p.y := r.Top;
         // ������������
        dc := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
        hp := CreatePen(PS_SOLID, 3, ColorToRGB(Color) xor ColorToRGB(CInsertionPoint));
        hOld := SelectObject(dc, hp);
        SetROP2(dc, R2_XORPEN);
        MoveToEx(dc, p.x,   p.y, nil);
        LineTo  (dc, p.x,   p.y+FItemSize.cy);
        MoveToEx(dc, p.x-3, p.y, nil);
        LineTo  (dc, p.x+3, p.y);
        MoveToEx(dc, p.x-3, p.y+FItemSize.cy, nil);
        LineTo  (dc, p.x+3, p.y+FItemSize.cy);
        SelectObject(dc, hOld);
        DeleteObject(hp);
        ReleaseDC(Handle, dc);
      end;
       // Invalidate coord if needed
      if bInvalidate then begin
        Coord.iIndex := -1;
        Coord.bLower := False;
      end;
    end;
  end;

  procedure TThumbnailViewer.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  var
    iCol, iRow, idxSingleSel: Integer;
    bLower: Boolean;

     // ������������ ������ ������� ����� (bUp=True) ��� ���� (bUp=False)
    procedure DoScroll(bUp: Boolean);
    begin
       // ������� ������ ����� �������
      DragDrawInsertionPoint(FOldDragTargetCoord, True);
       // ������������
      TopOffset := TopOffset+iif(bUp, -20, 20);
      Update;
    end;

  begin
    if (Source=Self) and FDragInsideEnabled then begin
      FDragTargetCoord.iIndex := -1;
      FDragTargetCoord.bLower := False;
       // ���� ������/��������� � ��������
      if PtInRect(ClientRect, Point(x, y)) then begin
         // ���� � ������� ��� ������ ������ ����, ������
        if (y<IDragScrollAreaMargin) or (y>=ClientHeight-IDragScrollAreaMargin) then DoScroll(y<IDragScrollAreaMargin);
         // ���������� ����� �������
        if FItemCount>0 then begin
           // ������� ������� (� �����������)
          iCol := Trunc(x/FItemSize.cx+0.5);
           // ���� ������ �� �������, �������� ����� bLower � ������������� ������ �� ����� � ������ ��������� ������
          bLower := iCol>=FColCount;
          if bLower then iCol := FColCount;
           // ������� ������ (������ ������ � ������ ������)
          iRow := ((y+FTopOffset) div FItemSize.cy)*FColCount;
           // ���� ������ �������� ������
          if iRow<FItemCount then begin
            FDragTargetCoord.iIndex := iRow+iCol;
             // ���� ��������� �� ��������� ����� - ���� �������� bLower
            if FDragTargetCoord.iIndex>=FItemCount then begin
              FDragTargetCoord.iIndex := FItemCount;
              bLower := True;
            end;
            FDragTargetCoord.bLower := bLower;
          end;
        end;
      end;
       // ���� ���������� ��������� ������� - ������������ ���
      if (FDragTargetCoord.iIndex<>FOldDragTargetCoord.iIndex) or (FDragTargetCoord.bLower<>FOldDragTargetCoord.bLower) then begin
        DragDrawInsertionPoint(FOldDragTargetCoord, False);
        DragDrawInsertionPoint(FDragTargetCoord, False);
        FOldDragTargetCoord := FDragTargetCoord;
      end;
       // Drop ��������, ���� ���� ���������� ���������� �������, � ��������������� �� ��� �����, � �� ������������
       //   ����������� ��� ����� ������� �� ��������� � ���������� ����� �����������
      Accept := (FDragTargetCoord.iIndex>=0) and (FSelectedPics.Count<FItemCount);
      if Accept and (FSelectedPics.Count=1) then begin
        idxSingleSel := SelectedIndexes[0];
        Accept := (idxSingleSel<>FDragTargetCoord.iIndex) and (idxSingleSel<>FDragTargetCoord.iIndex-1);
      end;
    end else
      inherited DragOver(Source, X, Y, State, Accept);
  end;

  procedure TThumbnailViewer.EndUpdate;
  begin
    if FUpdateLock>0 then Dec(FUpdateLock);
    if FUpdateLock=0 then begin
//      Perform(WM_SETREDRAW, 1, 0);
      if tvsLayoutChangePending    in FStates then LayoutChanged;
      if tvsSelectionChangePending in FStates then SelectionChanged;
    end;
  end;

  function TThumbnailViewer.GetDropTargetIndex: Integer;
  begin
    Result := FDragTargetCoord.iIndex;
  end;

  function TThumbnailViewer.GetFirstVisibleIndex: Integer;
  begin
    Result := ItemAtPos(0, 0);
  end;

  function TThumbnailViewer.GetIDSelected(iID: Integer): Boolean;
  begin
    Result := FSelectedPics.IndexOfID(iID)>=0;
  end;

  function TThumbnailViewer.GetIndexSelected(iIndex: Integer): Boolean;
  begin
    Result := FSelectedPics.IndexOfID(FPicList[iIndex].ID)>=0;
  end;

  function TThumbnailViewer.GetSelectedIndexes(Index: Integer): Integer;
  begin
    Result := FPicList.IndexOfID(FSelectedPics[Index].ID);
  end;

  function TThumbnailViewer.GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
  begin
    Result := FThumbCornerDetails[Corner];
  end;

  function TThumbnailViewer.GetUpdateLocked: Boolean;
  begin
    Result := FUpdateLock>0;
  end;

  function TThumbnailViewer.GetValidTopOffset(iOffset: Integer): Integer;
  begin
    Result := Max(0, Min(iOffset, FVRange-ClientHeight));
  end;

  procedure TThumbnailViewer.InvalidateItem(Index: Integer);
  var r: TRect;
  begin
    if (Index>=0) and (Index<FItemCount) and HandleAllocated then begin
      r := ItemRect(Index, False);
      if not IsRectEmpty(r) then InvalidateRect(Handle, @r, False);
    end;
  end;

  procedure TThumbnailViewer.InvalidateItem(Pic: IPhoaPic);
  begin
    InvalidateItem(FPicList.IndexOfID(Pic.ID));
  end;

  procedure TThumbnailViewer.InvalidateSelection;
  var i: Integer;
  begin
    for i := 0 to FSelectedPics.Count-1 do InvalidateItem(FSelectedPics[i]);
  end;

  function TThumbnailViewer.ItemAtPos(ix, iy: Integer): Integer;
  var iCol: Integer;
  begin
    Result := -1;
    if FItemCount>0 then begin
      iCol := ix div FItemSize.cx;
      if iCol<FColCount then begin
        Result := ((iy+FTopOffset) div FItemSize.cy)*FColCount+iCol;
        if Result>=FItemCount then Result := -1;
      end;
    end;
  end;

  function TThumbnailViewer.ItemRect(Index: Integer; bAllowInvisible: Boolean): TRect;
  var ix, iy: Integer;
  begin
    FillChar(Result, SizeOf(Result), 0);
    if (Index>=0) and (Index<FItemCount) then begin
      ix := (Index mod FColCount)*FItemSize.cx;
      iy := (Index div FColCount)*FItemSize.cy-FTopOffset;
      if bAllowInvisible or ((iy+FItemSize.cy>0) and (iy<ClientHeight)) then Result := Rect(ix, iy, ix+FItemSize.cx, iy+FItemSize.cy);
    end;
  end;

  procedure TThumbnailViewer.KeyDown(var Key: Word; Shift: TShiftState);

     // ���������� ItemIndex, ������� ������ ��� �� ���� ��� "�������" ������� �� ������� (��� Shift, Ctrl etc). ���
     //   bAllowLRBoundaryCross=False ������� �����-������ �� ����� "�������" ����� ������������ ������/����� �������
     //   ����� ������� (�� ���������/���������� ������)
    function GetItemIndexForKey(bAllowLRBoundaryCross: Boolean): Integer;
    begin
      Result := FItemIndex;
      case Key of
        VK_UP:     Dec(Result, FColCount);
        VK_DOWN:   Inc(Result, FColCount);
        VK_LEFT:   if bAllowLRBoundaryCross or (Result mod FColCount>0) then Dec(Result);
        VK_RIGHT:  if bAllowLRBoundaryCross or (Result mod FColCount<FColCount-1) then Inc(Result);
        VK_HOME:   Result := 0;
        VK_END:    Result := FItemCount-1;
        VK_PRIOR:  Dec(Result, FVisibleItems);
        VK_NEXT:   Inc(Result, FVisibleItems);
      end;
       // ������������ ��������� (���� FItemCount=0, �� ������ � ���� ������ Result ����� -1)
      if Result>=FItemCount then Result := FItemCount-1
      else if Result<0 then Result := 0;
    end;

  begin
    case Key of
       // Enter - ������ � ����� ���������
      VK_RETURN: if Shift=[] then DoStartViewMode;
       // ������ - �������� ���������; Ctrl+������ - ����������� ���������
      VK_SPACE:
        if Shift=[] then AddToSelection(FItemIndex)
        else if Shift=[ssCtrl] then ToggleSelection(FItemIndex);
       // ������� - ������������ ��������
      VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_PRIOR, VK_NEXT: begin
         // ��� ������������� ��� � Shift, �� ��� ��������� ���������
        if (Shift=[]) or ((Shift=[ssShift]) and (FStreamSelStart<0)) then 
          ItemIndex := GetItemIndexForKey(True)
         // ����� Shift - ������ �������� ���������, Shift+Alt - ������������� ���������
        else if (Shift=[ssShift]) or (Shift=[ssShift, ssAlt]) then
          SelectRange(FStreamSelStart, GetItemIndexForKey(not (ssAlt in Shift)), ssAlt in Shift)
         // ����� Ctrl - ������� ������ ItemIndex, �� ����� ���������
        else if Shift=[ssCtrl] then
          MoveItemIndex(GetItemIndexForKey(True), True, True);
      end;
    end;
  end;

  procedure TThumbnailViewer.LayoutChanged;
  var iPrevColCount, iPrevTopOffset: Integer;
  begin
    if not HandleAllocated then Exit;
     // ���� ���������� �������������, ������ ������� ���� ���������
    if FUpdateLock>0 then
      Include(FStates, tvsLayoutChangePending)
     // ����� ������������� ��������� �����������
    else begin
       // ���������� Tooltip/Hint
      FLastTooltipIdx := -1;
      Hint := '';
       // ��������� ������ ���������
      iPrevColCount  := FColCount;
      iPrevTopOffset := FTopOffset;
       // ���� ��������� ������ �� �������, �������������� ��
      if not FFontParamsValid then CalcFontParams;
       // ������� ������� ������ � ���������� ��������
      FItemSize := FThumbnailSize;
      case FDisplayMode of
        tvdmTile: begin
           // -- ���������� ������� �� ����� ������
          Inc(FItemSize.cx, IThumbMarginH*2+IThumbPaddingL+IThumbPaddingR);
          Inc(FItemSize.cy, IThumbMarginV*2+IThumbPaddingT+IThumbPaddingB);
           // -- ���������� ������� �� ������ �����������
          if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(FItemSize.cy, FTextLineHeight);
          if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Inc(FItemSize.cy, FTextLineHeight);
           // ������� ���������� ��������
          FColCount := Max(1, ClientWidth div FItemSize.cx);
        end;
        else {tvdmDetail} begin
          FColCount := 1;
          FItemSize.cx := Max(FThumbnailSize.cx+IThumbPaddingL+IThumbPaddingR, ClientWidth);
          Inc(FItemSize.cy, IThumbMarginV*2+IThumbPaddingT+IThumbPaddingB);
        end;
      end;
       // ��������� ��������
      FVisibleRows  := ClientHeight div FItemSize.cy;
      FVisibleItems := FVisibleRows*FColCount;
      FVRange       := Ceil(FItemCount/FColCount)*FItemSize.cy;
      FTopOffset    := GetValidTopOffset(FTopOffset);
       // ��������� ������������ ������ ��� ������� ���������
      if (tvsLayoutChangePending in FStates) or (FColCount<>iPrevColCount) or (FTopOffset<>iPrevTopOffset) then Invalidate;
      UpdateScrollBar;
       // ��������� ����� ���������
      FStates := FStates-[tvsLayoutChangePending];
    end;
  end;

  procedure TThumbnailViewer.MarqueingEnd;
  var
    i: Integer;
    r, rItem: TRect;
  begin
    ReleaseCapture;
    FMarqueing := False;
     // ������� Marquee
    PaintMarquee;
    ReleaseDC(Handle, FTempDC);
     // ������ ���������
    BeginUpdate;
    try
       // ���� �� ��� ����� Shift, ������� Selection (�������� � ����)
      if GetKeyState(VK_SHIFT) and $80=0 then ClearSelection;
       // Select thumbnails that do intersect with marquee
      r := OrderRect(Rect(FStartPos, FMarqueeCur));
      for i := GetFirstVisibleIndex to FItemCount-1 do begin
        rItem := ItemRect(i, False);
        if IsRectEmpty(rItem) then Break;
        if RectsOverlap(r, rItem) then AddToSelection(i);
      end;
    finally
      EndUpdate;
    end;
  end;

  procedure TThumbnailViewer.MarqueingStart;
  begin
    SetCapture(Handle);
    FTempDC := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
    FMarqueing := True;
    FMarqueeCur := FStartPos;
  end;

  procedure TThumbnailViewer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var idx: Integer;
  begin
    SetFocus;
    if Button=mbMiddle then Exit;
    idx := ItemAtPos(x, y);
    FStartPos := Point(x, y);
     // ���� ����� Alt[+Shift] (�� �� Ctrl+Alt) - �������� ��������� (marqueing)
    if Shift*[ssAlt, ssCtrl]=[ssAlt] then begin
      if Button=mbLeft then MarqueingStart;
     // ���� ����� Ctrl
    end else if Shift*[ssShift, ssCtrl, ssAlt]=[ssCtrl] then begin
       // ���� ����� ������ - ����������� ��������� ������, �� ������� ��������
      if Button=mbLeft then begin
        ToggleSelection(idx);
        MoveItemIndex(idx, True, True);
       // ���� ������ ������ - ������� ����� Shell Context Menu
      end else if Button=mbRight then begin
        BeginUpdate;
        try
          ClearSelection;
          SetItemIndex(idx);
        finally
          EndUpdate;
        end;
        if idx>=0 then begin
          FShellCtxMenuOnMouseUp := True;
          Exit;
        end;
      end;
     // ���� ����� Shift - �������� ������ ������ ������
    end else if Shift*[ssShift, ssCtrl, ssAlt]=[ssShift] then
      if FStreamSelStart>=0 then SelectRange(FStreamSelStart, idx, False) else SetItemIndex(idx)
     // �� ������ ������
    else if Shift*[ssShift, ssCtrl, ssAlt]=[] then begin
      if (idx<0) or not IndexSelected[idx] then begin
        SetItemIndex(idx);
        FNoMoveItemIndex := -1;
      end else if Button=mbLeft then
        FNoMoveItemIndex := idx;
      if Button=mbLeft then
        if idx<0 then MarqueingStart
        else if FDragEnabled and (FSelectedPics.Count>0) then FDragPending := True;
    end;
    inherited MouseDown(Button, Shift, x, y);
  end;

  procedure TThumbnailViewer.MouseMove(Shift: TShiftState; X, Y: Integer);
  begin
     // ����������� Tooltip
    AdjustTooltip(x, y);
     // ���� ������ ����� ���������
    if FMarqueing then begin
      PaintMarquee;
      FMarqueeCur := Point(Min(Max(x, 0), ClientWidth), y);
      PaintMarquee;
     // ��������� �������� Dragging
    end else if FDragPending then begin
      if (FStartPos.x<>x) or (FStartPos.y<>y) then FNoMoveItemIndex := -1;
      if Sqr(FStartPos.x-x)+Sqr(FStartPos.y-y)>9 then begin
        FDragPending := False;
         // �������������� ����������
        FDragTargetCoord.iIndex    := -1;
        FDragTargetCoord.bLower    := False;
        FOldDragTargetCoord.iIndex := -1;
        FOldDragTargetCoord.bLower := False;
         // �������� Dragging
        BeginDrag(True);
      end;
    end;
    inherited MouseMove(Shift, x, y);
  end;

  procedure TThumbnailViewer.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
     // ���� ����� ���������� ���������
    if FMarqueing then
      MarqueingEnd
     // ���� ���� ������ ������ ������ ������ � Ctrl - �������� ��������� ����������� ����
    else if FShellCtxMenuOnMouseUp then begin
      FShellCtxMenuOnMouseUp := False;
      if (ssCtrl in Shift) and (FItemIndex>=0) and (FItemIndex=ItemAtPos(x, y)) then ShowFileShellContextMenu(FPicList[FItemIndex].FileName);
      Exit;
     // ����� ��������� Dragging
    end else begin
      FDragPending := False;
      if FNoMoveItemIndex>=0 then begin
        if not Dragging then ItemIndex := FNoMoveItemIndex;
        FNoMoveItemIndex := -1;
      end;
    end;
    inherited MouseUp(Button, Shift, x, y);
  end;

  procedure TThumbnailViewer.MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart, bScrollIntoView: Boolean);
  begin
    if iNewIndex<>FItemIndex then begin
      InvalidateItem(FItemIndex);
      FItemIndex := iNewIndex;
      InvalidateItem(FItemIndex);
    end;
    if bUpdateStreamSelStart then FStreamSelStart := iNewIndex;
    if bScrollIntoView then ScrollIntoView;
  end;

  procedure TThumbnailViewer.Paint;
  var Info: TThumbnailViewerPaintInfo;
  begin
     // ������ �������� ������, ���� �� ��� �� ������
    if FBuffer=nil then FBuffer := TBitmap32.Create;
     // ������ ��������� ������ ��� ���������
    with Info do begin
      RClip    := Canvas.ClipRect;
      RClient  := ClientRect;
      if IsRectEmpty(RClient) then Exit;
      FBuffer.SetSize(RClient.Right-RClient.Left, RClient.Bottom-RClient.Top);
      Bitmap   := FBuffer;
      bFocused := Focused;
    end;
     // Invoke the painting stages one-by-one
    Paint_EraseBackground(Info);
    Paint_Thumbnails(Info);
    Paint_TransferBuffer(Info);
  end;

  procedure TThumbnailViewer.PaintMarquee;
  var r: TRect;
  begin
    r := OrderRect(Rect(FStartPos, FMarqueeCur));
    if not IsRectEmpty(r) then DrawFocusRect(FTempDC, r);
  end;

  procedure TThumbnailViewer.Paint_EraseBackground(const Info: TThumbnailViewerPaintInfo);
  begin
    Info.Bitmap.FillRectS(Info.RClip, Color32(Color));
  end;

  procedure TThumbnailViewer.Paint_Thumbnail(const Info: TThumbnailViewerPaintInfo; iIndex: Integer; ItemRect: TRect; bSelected: Boolean);
  const aSelectedFontClr: Array[Boolean] of TColor = (clWindowText, clHighlightText);
  var
    Pic: IPhoaPic;
    r, rInner: TRect;

     // ������������ �� ������ ������ ������ ����. ���������� ������ ������������� ������
    function DrawDetail(Corner: TThumbCorner; rText: TRect): Integer;
    var sProp: String;
    begin
      Result := 0;
      if (FThumbCornerDetails[Corner].bDisplay) and (rText.Left<rText.Right) then begin
        sProp := Pic.PropStrValues[FThumbCornerDetails[Corner].Prop];
        if sProp<>'' then begin
          Result := Info.Bitmap.TextWidth(sProp)+2;
          Info.Bitmap.Textout(
            rText,
            iif(Corner in [tcRightTop, tcRightBottom], DT_RIGHT, DT_LEFT) or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_END_ELLIPSIS,
            sProp);
        end;
      end;
    end;

     // ������������ �� ������ ������, ����������� �� ����� �����. �����
    procedure DrawDetailsLR(LeftCorner, RightCorner: TThumbCorner; rText: TRect);
    begin
       // ������ ������ ��������
      Dec(rText.Right, DrawDetail(RightCorner, rText));
       // ������ ����� ��������
      DrawDetail(LeftCorner, rText);
    end;

     // ������������ ����� � �������� ��������������
    procedure DrawThumbnail(const rThumb: TRect);
    var r: TRect;
    begin
       // ������ �����
      r := rThumb;
      PaintThumbnail(Pic, Info.Bitmap, r);
       // ������ ����
      if FThumbShadowVisible then
        DropShadow(Info.Bitmap, FThumbShadow, r, rThumb, FThumbShadowOffset.x, FThumbShadowOffset.y, FThumbShadowColor);
    end;

  begin
     // �������� �����������
    Pic := FPicList[iIndex];
     // ������ �����
    r := ItemRect;
    Info.Bitmap.Font.Assign(Self.Font);
    Info.Bitmap.Font.Color := iif(bSelected, aSelectedFontClr[Info.bFocused], FThumbFontColor);
     // ���������� ���������� ������� ������
    rInner := Rect(ItemRect.Left+IThumbPaddingL, ItemRect.Top+IThumbPaddingT, ItemRect.Right-IThumbPaddingR, ItemRect.Bottom-IThumbPaddingB);
     // ������������ ����������� ������
    r := rInner;
    case FDisplayMode of
      tvdmTile: begin
        if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(r.Top,    FTextLineHeight);
        if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Dec(r.Bottom, FTextLineHeight);
      end;
      tvdmDetail: r.Right := r.Left+FThumbnailSize.cx;
    end;
    DrawThumbnail(r);
     // ������ ��������
    case FDisplayMode of
      tvdmTile: begin
        r := rInner;
        r.Bottom := r.Top+FTextLineHeight;
        DrawDetailsLR(tcLeftTop,    tcRightTop,    r);
        r := rInner;
        r.Top := r.Bottom-FTextLineHeight;
        DrawDetailsLR(tcLeftBottom, tcRightBottom, r);
      end;
      tvdmDetail: ; //#TODO: ������� ��������� �������� � ������ Detail
    end;
  end;

  procedure TThumbnailViewer.Paint_Thumbnails(const Info: TThumbnailViewerPaintInfo);
  var
    rThumb: TRect;
    i, idxStart: Integer;
    bmpNormal, bmpSelected: TBitmap32; // ��������� "��������" ������� �������� � �����������
    bSelected: Boolean;

     // ������������ FocusRect ������, ���� ����� ������������
    procedure DrawThumbFocusRect(iIndex: Integer; const r: TRect);
    begin
      if not Info.bFocused or (i<>FItemIndex) then Exit;
      with Info.Bitmap.Canvas do begin
        SetTextColor(Handle, $ffffff);
        SetBkColor  (Handle, $000000);
        DrawFocusRect(r);
      end;
    end;

     // ���������� ������ � "���������" ������: ����������� ��� �������� (� ����������� �� bSelected); ��������
     //   ��������� ������
    function GetThBackBitmap: TBitmap32;
    const aSelBackClr: Array[Boolean] of TColor = (clBtnShadow,  clHighlight);
    var
      p: ^TBitmap32;
      r: TRect;
      iBorderWidth: Integer;
    begin
      p := iif(bSelected, @bmpSelected, @bmpNormal);
       // ���� �������� �� �������
      if p^=nil then begin
         // ������ ��������
        p^ := TBitmap32.Create;
        r := Rect(0, 0, rThumb.Right-rThumb.Left, rThumb.Bottom-rThumb.Top);
        p^.SetSize(r.Right, r.Bottom);
         // ������ �����
        case FThumbBackBorderStyle of
          tbbsFlat:   p^.FrameRectS(r, Color32(clBtnShadow));
          tbbsRaised: DrawEdge(p^.Canvas.Handle, r, BDR_RAISEDINNER, BF_RECT);
          tbbsSunken: DrawEdge(p^.Canvas.Handle, r, BDR_SUNKENINNER, BF_RECT);
          tbbsPlain:  DrawEdge(p^.Canvas.Handle, r, BDR_RAISEDINNER or BDR_RAISEDOUTER, BF_RECT);
          tbbsGroove: DrawEdge(p^.Canvas.Handle, r, BDR_RAISEDINNER or BDR_SUNKENOUTER, BF_RECT);
          tbbsXP: begin
            p^.FrameRectS(r, Color32($b99d7f));
            p^.FrameRectS(r.Left+1, r.Top+1, r.Right-1, r.Bottom-1, Color32(clWindow));
          end;
          tbbsColor:  p^.FrameRectS(r, Color32(FThumbBackBorderColor));
        end;
         // ������ ���
        if FThumbBackBorderStyle<>tbbsNone then begin
          iBorderWidth := iif(FThumbBackBorderStyle in [tbbsPlain, tbbsGroove, tbbsXP], 2, 1);
          InflateRect(r, -iBorderWidth, -iBorderWidth);
        end;
        p^.FillRectS(r, Color32(iif(bSelected, aSelBackClr[Info.bFocused], FThumbBackColor)));
      end;
      Result := p^;
    end;

  begin
    PrepareShadow;
     // ������������ ������
    idxStart := GetFirstVisibleIndex;
    if idxStart>=0 then begin
      bmpNormal   := nil;
      bmpSelected := nil;
      try
        for i := idxStart to FItemCount-1 do begin
           // ������� ������� ������
          rThumb := ItemRect(i, False);
          if IsRectEmpty(rThumb) then Break;
           // ������ FocusRect
          DrawThumbFocusRect(i, rThumb);
           // ���� ������� ������ ������������ � ClipRect - ������ ���� �����
          InflateRect(rThumb, -IThumbMarginH, -IThumbMarginV);
          if RectsOverlap(rThumb, Info.RClip) then begin
             // ����������, ������� �� �����
            bSelected := IndexSelected[i];
             // ������ "��������"
            GetThBackBitmap.DrawTo(Info.Bitmap, rThumb.Left, rThumb.Top);
             // ������ �����
            Paint_Thumbnail(Info, i, rThumb, bSelected);
          end;
        end;
      finally
        bmpNormal.Free;
        bmpSelected.Free;
      end;
    end;
  end;

  procedure TThumbnailViewer.Paint_TransferBuffer(const Info: TThumbnailViewerPaintInfo);
  begin
    Info.Bitmap.DrawTo(Canvas.Handle, 0, 0);
  end;

  procedure TThumbnailViewer.PrepareShadow;
  begin
    if FThumbShadowVisible and (FThumbShadow=nil) then begin
      FThumbShadow := TBitmap32.Create;
      RenderShadowTemplate(FThumbShadow, FThumbShadowBlurRadius, FThumbShadowOpacity, FThumbShadowColor);
    end;
  end;

  procedure TThumbnailViewer.ReloadPicList(APicList: IPhoaPicList);
  var iItemIdx: Integer;
  begin
    BeginUpdate;
    try
       // ����������� ������ � ������� ���� ����������� ���������� �����������
      FPicList   := APicList;
      FItemCount := FPicList.Count;
      FTopOffset := 0;
      LayoutChanged;
       // ������� ���������
      ClearSelection;
       // �������� ������ ����������� (���� ��� ����)
      AddToSelection(0);
      if FSelectedPics.Count>0 then iItemIdx := 0 else iItemIdx := -1;
      MoveItemIndex(iItemIdx, True, False);
    finally
       // �� ������������� � ���������� �� ����������
      EndUpdate;
    end;
  end;

  procedure TThumbnailViewer.RemoveFromSelection(Index: Integer);
  begin
    if FSelectedPics.Remove(FPicList[Index].ID)>=0 then begin
      InvalidateItem(Index);
      SelectionChanged;
    end;
  end;

  procedure TThumbnailViewer.ResetShadow;
  begin
    if FThumbShadow<>nil then begin
      FreeAndNil(FThumbShadow);
      Invalidate;
    end;
  end;

  procedure TThumbnailViewer.Resize;
  begin
    inherited Resize;
    if FDisplayMode=tvdmDetail then InvalidateRect(Handle, nil, False);
  end;

  procedure TThumbnailViewer.RestoreDisplay(Data: IThumbnailViewerDisplayData);
  var i, iItemIdx: Integer;
  begin
    BeginUpdate;
    try
      ClearSelection;
       // ��������� � ��������� ����������� � ��������� ID
      for i := 0 to Data.SelectedIDCount-1 do AddToSelection(FPicList.IndexOfID(Data.SelectedIDs[i]));
       // ���� ��� ���������, �������� ������ ����������� (���� ��� ����)
      if FSelectedPics.Count=0 then AddToSelection(0);
       // ������� ��������������� �����������
      if Data.FocusedID>0 then iItemIdx := FPicList.IndexOfID(Data.FocusedID) else iItemIdx := -1;
       // ���� ��� � �� �������
      if iItemIdx<0 then
         // ���������� ������ �� ����������, ���� ��� ����
        if FSelectedPics.Count>0 then iItemIdx := SelectedIndexes[0]
         // ����� �������� �������� ����� ������ �����������, ���� ��� ����
        else if FItemCount>0 then iItemIdx := 0;
      TopOffset := Data.TopOffset;
      MoveItemIndex(iItemIdx, True, False);
    finally
      EndUpdate;
    end;
  end;

  function TThumbnailViewer.SaveDisplay: IThumbnailViewerDisplayData;
  var iFocusedID: Integer;
  begin
    if FItemIndex>=0 then iFocusedID := FPicList[FItemIndex].ID else iFocusedID := 0;
    Result := NewThumbnailViewerDisplayData(FSelectedPics, iFocusedID, FTopOffset);
  end;

  procedure TThumbnailViewer.ScrollIntoView;
  var r: TRect;
  begin
     // �������� ������� ������
    r := ItemRect(FItemIndex, True);
    if not IsRectEmpty(r) then
       // ���� ��������������� ����� ���� ���� ���������
      if r.Top<0 then TopOffset := TopOffset+r.Top
       // ���� ��������������� ����� ���� ���� ���������
      else if r.Bottom>ClientHeight then TopOffset := TopOffset+(r.Bottom-ClientHeight);
  end;

  procedure TThumbnailViewer.SelectAll;
  var i: Integer;
  begin
    if FSelectedPics.Count<FItemCount then begin
      BeginUpdate;
      try
        ClearSelection;
        for i := 0 to FItemCount-1 do AddToSelection(i);
      finally
        EndUpdate;
      end;
    end;
  end;

  procedure TThumbnailViewer.SelectionChanged;
  begin
    if not HandleAllocated then Exit;
     // ���� ���������� �������������, ������ ������� ���� ���������
    if FUpdateLock>0 then
      Include(FStates, tvsSelectionChangePending)
     // ����� �������� ������� ����� ���������
    else begin
      if Assigned(FOnSelectionChange) then FOnSelectionChange(Self);
       // ��������� ����� ���������
      FStates := FStates-[tvsSelectionChangePending];
    end;
  end;

  procedure TThumbnailViewer.SelectRange(idxStart, idxEnd: Integer; bRectangular: Boolean);
  var
    i, ix, iy: Integer;
    pStart, pEnd: TPoint;

     // ���������, ��� iMin<=iMax. ����� ������ �� �������� �������
    procedure OrderCoord(var iMin, iMax: Integer);
    var i: Integer;
    begin
      if iMin>iMax then begin
        i    := iMax;
        iMax := iMin;
        iMin := i;
      end;
    end;

  begin
    BeginUpdate;
    try
      ClearSelection;
      MoveItemIndex(idxEnd, False, True);
       // ������������� ���������
      if bRectangular then begin
        pStart := Point(idxStart mod FColCount, idxStart div FColCount);
        pEnd   := Point(idxEnd   mod FColCount, idxEnd   div FColCount);
        OrderCoord(pStart.x, pEnd.x);
        OrderCoord(pStart.y, pEnd.y);
        for iy := pStart.y to pEnd.y do
          for ix := pStart.x to pEnd.x do AddToSelection(iy*FColCount+ix);
       // �������� ���������
      end else begin
        OrderCoord(idxStart, idxEnd);
        for i := idxStart to idxEnd do AddToSelection(i);
      end;
    finally
      EndUpdate;
    end;
  end;

  procedure TThumbnailViewer.SetBorderStyle(Value: TBorderStyle);
  begin
    if FBorderStyle<>Value then begin
      FBorderStyle := Value;
      RecreateWnd;
    end;  
  end;

  procedure TThumbnailViewer.SetDisplayMode(Value: TThumbViewerDisplayMode);
  begin
    if FDisplayMode<>Value then begin
      FDisplayMode := Value;
      LayoutChanged;
    end;
  end;

  procedure TThumbnailViewer.SetItemIndex(Value: Integer);
  begin
     // ���� �������� ������, ��� ��� ���������, � ��� �����, ��� ��������
    if (FItemIndex<>Value) or ((FSelectedPics.Count=0)<>(Value<0)) then begin
      BeginUpdate;
      try
        ClearSelection;
        AddToSelection(Value);
        MoveItemIndex(Value, True, True);
      finally
        EndUpdate;
      end;
    end;
  end;

  procedure TThumbnailViewer.SetShowThumbTooltips(Value: Boolean);
  begin
    if FShowThumbTooltips<>Value then begin
      FShowThumbTooltips := Value;
      FLastTooltipIdx := -1;
      Application.CancelHint;
    end;
  end;

  procedure TThumbnailViewer.SetThumbBackBorderColor(Value: TColor);
  begin
    if FThumbBackBorderColor<>Value then begin
      FThumbBackBorderColor := Value;
      if (FThumbBackBorderStyle=tbbsColor) and (FItemCount>0) then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbBackBorderStyle(Value: TThumbBackBorderStyle);
  begin
    if FThumbBackBorderStyle<>Value then begin
      FThumbBackBorderStyle := Value;
      if FItemCount>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbBackColor(Value: TColor);
  begin
    if FThumbBackColor<>Value then begin
      FThumbBackColor := Value;
      if FItemCount>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
  begin
    FThumbCornerDetails[Corner] := Value;
    LayoutChanged;
  end;

  procedure TThumbnailViewer.SetThumbFontColor(Value: TColor);
  begin
    if FThumbFontColor<>Value then begin
      FThumbFontColor := Value;
      if FItemCount>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbnailSize(const Value: TSize);
  begin
    if (FThumbnailSize.cx<>Value.cx) or (FThumbnailSize.cy<>Value.cy) then begin
      FThumbnailSize := Value;
      LayoutChanged;
    end;
  end;

  procedure TThumbnailViewer.SetThumbShadowBlurRadius(Value: Integer);
  begin
    if FThumbShadowBlurRadius<>Value then begin
      FThumbShadowBlurRadius := Value;
      ResetShadow;
    end;
  end;

  procedure TThumbnailViewer.SetThumbShadowColor(Value: TColor);
  begin
    if FThumbShadowColor<>Value then begin
      FThumbShadowColor := Value;
      ResetShadow;
    end;
  end;

  procedure TThumbnailViewer.SetThumbShadowOffset(const Value: TPoint);
  begin
    if Int64(FThumbShadowOffset)<>Int64(Value) then begin
      FThumbShadowOffset := Value;
      ResetShadow;
    end;
  end;

  procedure TThumbnailViewer.SetThumbShadowOpacity(Value: Byte);
  begin
    if FThumbShadowOpacity<>Value then begin
      FThumbShadowOpacity := Value;
      ResetShadow;
    end;
  end;

  procedure TThumbnailViewer.SetThumbShadowVisible(Value: Boolean);
  begin
    if FThumbShadowVisible<>Value then begin
      FThumbShadowVisible := Value;
      ResetShadow;
    end;
  end;

  procedure TThumbnailViewer.SetThumbTooltipProps(Value: TPicProperties);
  begin
    if FThumbTooltipProps<>Value then begin
      FThumbTooltipProps := Value;
      FLastTooltipIdx := -1;
      Application.CancelHint;
    end;
  end;

  procedure TThumbnailViewer.SetTopOffset(Value: Integer);
  begin
    Value := GetValidTopOffset(Value);
    if FTopOffset<>Value then begin
      ScrollWindowEx(Handle, 0, FTopOffset-Value, nil, nil, 0, nil, SW_INVALIDATE);
      FTopOffset := Value;
      UpdateScrollBar;
       // Invalidate the focused thumbnail for FocusRect to be repainted correctly
      if Focused then InvalidateItem(FItemIndex);
    end;
  end;

  procedure TThumbnailViewer.ToggleSelection(Index: Integer);
  begin
    if Index>=0 then
      if IndexSelected[Index] then RemoveFromSelection(Index) else AddToSelection(Index);
  end;

  procedure TThumbnailViewer.UpdateScrollBar;
  var ScrollInfo: TScrollInfo;
  begin
    with ScrollInfo do begin
      cbSize := SizeOf(ScrollInfo);
      fMask  := SIF_ALL;
      nMin   := 0;
      nMax   := FVRange-1;
      nPage  := ClientHeight;
      nPos   := FTopOffset;
    end;
    SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  end;

  procedure TThumbnailViewer.WMContextMenu(var Msg: TWMContextMenu);
  begin
     // �������� context menu ������ ���� �� ��� ����� Ctrl
    if not FShellCtxMenuOnMouseUp then begin
      if InvalidPoint(Msg.Pos) then Msg.Pos := PointToSmallPoint(ClientToScreen(CenterPoint(ItemRect(FItemIndex, False))));
      inherited;
    end;
  end;

  procedure TThumbnailViewer.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
  begin
    Msg.Result := 1;
  end;

  procedure TThumbnailViewer.WMGetDlgCode(var Msg: TWMGetDlgCode);
  begin
     // Direct arrow-key messages to the control
    Msg.Result := DLGC_WANTARROWS;
  end;

  procedure TThumbnailViewer.WMKillFocus(var Msg: TWMKillFocus);
  begin
     // �������������� ��������� ��� ������ ������
    InvalidateSelection;
     // ��������������� ����� ���� ���� ������������
    InvalidateItem(FItemIndex);
  end;

  procedure TThumbnailViewer.WMNCPaint(var Msg: TWMNCPaint);
  begin
    DefaultHandler(Msg);
    if ThemeServices.ThemesEnabled then ThemeServices.PaintBorder(Self, False);
  end;

  procedure TThumbnailViewer.WMSetFocus(var Msg: TWMSetFocus);
  begin
     // �������������� ��������� ��� ��������� ������
    InvalidateSelection;
     // ��������������� ����� ���� ���� ������������
    InvalidateItem(FItemIndex);
  end;

  procedure TThumbnailViewer.WMVScroll(var Msg: TWMVScroll);
  var iOffset: Integer;

     // �������� 32-������ ������� ��������� (� ��������� ��������� ������ 16-������)
    function GetRealScrollPos: Integer;
    var SI: TScrollInfo;
    begin
      SI.cbSize := SizeOf(TScrollInfo);
      SI.fMask  := SIF_TRACKPOS;
      GetScrollInfo(Handle, SB_VERT, SI);
      Result := SI.nTrackPos;
    end;

  begin
    case Msg.ScrollCode of
      SB_BOTTOM:       iOffset := MaxInt;
      SB_LINEDOWN:     iOffset := FTopOffset+10;
      SB_LINEUP:       iOffset := FTopOffset-10;
      SB_PAGEDOWN:     iOffset := FTopOffset+ClientHeight;
      SB_PAGEUP:       iOffset := FTopOffset-ClientHeight;
      SB_THUMBPOSITION,
        SB_THUMBTRACK: iOffset := GetRealScrollPos;
      SB_TOP:          iOffset := 0;
      else Exit;
    end;
    TopOffset := iOffset;
  end;

  procedure TThumbnailViewer.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
  begin
    inherited;
    LayoutChanged;
  end;

  procedure TThumbnailViewer.WndProc(var Msg: TMessage);
  begin
    case Msg.Msg of
       // ������������� DoubleClick, ����� �� ���� �� ��������� AutoDrag 
      WM_LBUTTONDBLCLK: begin
        DblClick;
        Exit;
      end;
    end;
    inherited WndProc(Msg);
  end;

   //===================================================================================================================
   // TPhoAHintWindow
   //===================================================================================================================

  procedure TPhoAHintWindow.Paint;
  var
    r: TRect;
    s, sLine: String;
  begin
    r := ClientRect;
    InflateRect(r, -2, -2);
    r.Bottom := r.Top+Canvas.TextHeight('Wg');
    Canvas.Font.Color := Screen.HintFont.Color;
     // ���� �� �������
    s := AdjustLineBreaks(Caption, tlbsLF);
    repeat
      sLine := ExtractFirstWord(s, #10);
      if sLine='' then Break;
       // ������ ����� �����
      DrawText(Canvas.Handle, PChar(ExtractFirstWord(sLine, #9)), -1, r, DT_LEFT or DT_NOPREFIX or DT_END_ELLIPSIS);
       // ������ ������ �����
      if sLine<>'' then DrawText(Canvas.Handle, PChar(sLine), -1, r, DT_RIGHT or DT_NOPREFIX or DT_END_ELLIPSIS);
      OffsetRect(r, 0, r.Bottom-r.Top);
    until False;
  end;

   //===================================================================================================================
   // TSizeGripper
   //===================================================================================================================

  constructor TSizeGripper.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle-[csOpaque];
    Anchors := [akRight, akBottom];
    Cursor  := crSizeNWSE;
    Width   := GetSystemMetrics(SM_CXVSCROLL);
    Height  := GetSystemMetrics(SM_CYHSCROLL);
  end;

  procedure TSizeGripper.Paint;
  var
    r: TRect;
    i, iD, iSize: Integer;

    procedure DiagLine(c: TColor);
    begin
      Canvas.Pen.Color := c;
      MoveToEx(Canvas.Handle, r.Right-2-iD, r.Bottom-2, nil);
      LineTo(Canvas.Handle, r.Right-1, r.Bottom-iD-3);
      Inc(iD);
    end;

  begin
    r := ClientRect;
     // ���� ���� ��������, ���������� ���
    if ThemeServices.ThemesEnabled then
      ThemeServices.DrawElement(Canvas.Handle, ThemeServices.GetElementDetails(tsGripper), r)
     // ����� ������ ���� (ripped from TBX)
    else begin
      iD := 0;
      iSize := Min(r.Right-r.Left, r.Bottom-r.Top);
      for i := 1 to 3 do
        case iSize of
          0..8: begin
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          9..11: begin
            DiagLine(clBtnFace);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          12..14: begin
            DiagLine(clBtnShadow);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          else begin
            DiagLine(clBtnFace);
            DiagLine(clBtnShadow);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
        end;
      Canvas.Pen.Color := clBtnFace;
      Canvas.MoveTo(r.Right-iD-1, r.Bottom-1);
      Canvas.LineTo(r.Right-1,    r.Bottom-1);
      Canvas.LineTo(r.Right-1,    r.Bottom-iD-2);
    end;
  end;

  procedure TSizeGripper.SetParent(AParent: TWinControl);
  begin
    inherited SetParent(AParent);
    if AParent<>nil then begin
       // ��������� � ������ ������ ���� ��������
      with AParent.ClientRect do SetBounds(Right-Width, Bottom-Height, Width, Height);
       // ������ �� ���
      SendToBack;
    end;
  end;

  procedure TSizeGripper.WMNCHitTest(var Msg: TWMNCHitTest);
  var p: TPoint;
  begin
    inherited;
    if Msg.Result=HTCLIENT then begin
      p := ScreenToClient(SmallPointToPoint(Msg.Pos));
      if PtInRect(ClientRect, p) then Msg.Result := HTBOTTOMRIGHT;
    end;
  end;

   //===================================================================================================================
   // TThumbnailViewerDisplayData - ���������� IThumbnailViewerDisplayData
   //===================================================================================================================
type
  TThumbnailViewerDisplayData = class(TInterfacedObject, IThumbnailViewerDisplayData)
  private
     // ������ ���������� ID
    FSelIDs: TList;
     // Prop storage
    FFocusedID: Integer;
    FTopOffset: Integer;
     // IThumbnailViewerDisplayData
    procedure SaveToDataStream(DataStream: IPhoaDataStream);
    procedure LoadFromDataStream(DataStream: IPhoaDataStream);
    function  GetFocusedID: Integer;
    function  GetSelectedIDCount: Integer;
    function  GetSelectedIDs(Index: Integer): Integer;
    function  GetTopOffset: Integer;
  public
    constructor Create(SelectedPics: IPhoaPicList; iFocusedID, iTopOffset: Integer); overload;
    destructor Destroy; override;
  end;

  constructor TThumbnailViewerDisplayData.Create(SelectedPics: IPhoaPicList; iFocusedID, iTopOffset: Integer);
  var i: Integer;
  begin
    inherited Create;
     // ������������ ID ���������� �����������, ���� ��� ����
    if (SelectedPics<>nil) and (SelectedPics.Count>0) then begin
      FSelIDs := TList.Create;
      for i := 0 to SelectedPics.Count-1 do FSelIDs.Add(Pointer(SelectedPics[i].ID));
    end;
    FFocusedID := iFocusedID;
    FTopOffset := iTopOffset;
  end;

  destructor TThumbnailViewerDisplayData.Destroy;
  begin
    FSelIDs.Free;
    inherited Destroy;
  end;

  function TThumbnailViewerDisplayData.GetFocusedID: Integer;
  begin
    Result := FFocusedID;
  end;

  function TThumbnailViewerDisplayData.GetSelectedIDCount: Integer;
  begin
    if FSelIDs=nil then Result := 0 else Result := FSelIDs.Count;
  end;

  function TThumbnailViewerDisplayData.GetSelectedIDs(Index: Integer): Integer;
  begin
    Result := Integer(FSelIDs[Index]);
  end;

  function TThumbnailViewerDisplayData.GetTopOffset: Integer;
  begin
    Result := FTopOffset;
  end;

  procedure TThumbnailViewerDisplayData.LoadFromDataStream(DataStream: IPhoaDataStream);
  var i, iCount: Integer;
  begin
     // ������ ��������
    FFocusedID := DataStream.ReadInt;
    FTopOffset := DataStream.ReadInt;
     // ������ SelIDs
    FreeAndNil(FSelIDs);
    iCount := DataStream.ReadInt;
    if iCount>0 then begin
      FSelIDs := TList.Create;
      for i := 0 to iCount-1 do FSelIDs.Add(Pointer(DataStream.ReadInt));
    end;
  end;

  procedure TThumbnailViewerDisplayData.SaveToDataStream(DataStream: IPhoaDataStream);
  var i: Integer;
  begin
     // ����� ��������
    DataStream.WriteInt(FFocusedID);
    DataStream.WriteInt(FTopOffset);
     // ����� SelIDs
    DataStream.WriteInt(GetSelectedIDCount);
    if FSelIDs<>nil then
      for i := 0 to FSelIDs.Count-1 do DataStream.WriteInt(Integer(FSelIDs[i]));
  end;

   //===================================================================================================================
   // TPhoaAction
   //===================================================================================================================

  constructor TPhoaAction.Create(AAction: TCustomAction; bVolatile: Boolean; AExecuteProc: TPhoaActionExecuteProc);
  begin
    inherited Create;
    FAction      := AAction;
    FVolatile    := bVolatile;
    FExecuteProc := AExecuteProc;
     // � Tag ����� ������ �� ����������� ���������
    FAction.Tag := Integer(Self as IPhoaAction); 
  end;

  destructor TPhoaAction.Destroy;
  begin
     // ������� ������ �� ����, ���������� � Tag
    if FAction<>nil then FAction.Tag := 0;
     // ������� Action, ���� �����
    if FVolatile then FAction.Free;  
    inherited Destroy;
  end;

  function TPhoaAction.Execute: LongBool;
  begin
    Result := Assigned(FExecuteProc);
    if Result then FExecuteProc(Self);
  end;

  function TPhoaAction.GetCaption: WideString;
  begin
    Result := PhoaAnsiToUnicode(FAction.Caption);
  end;

  function TPhoaAction.GetCategory: WideString;
  begin
    Result := PhoaAnsiToUnicode(FAction.Category);
  end;

  function TPhoaAction.GetEnabled: LongBool;
  begin
    Result := FAction.Enabled;
  end;

  function TPhoaAction.GetHint: WideString;
  begin
    Result := PhoaAnsiToUnicode(FAction.Hint);
  end;

  function TPhoaAction.GetName: WideString;
  begin
    Result := PhoaAnsiToUnicode(FAction.Name);
  end;

  function TPhoaAction.GetNativeAction: TCustomAction;
  begin
    Result := FAction;
  end;

  function TPhoaAction.GetTag: Integer;
  begin
    Result := FTag;
  end;

  procedure TPhoaAction.SetCaption(const Value: WideString);
  begin
    FAction.Caption := PhoaUnicodeToAnsi(Value);
  end;

  procedure TPhoaAction.SetCategory(const Value: WideString);
  begin
    FAction.Category := PhoaUnicodeToAnsi(Value);
  end;

  procedure TPhoaAction.SetEnabled(Value: LongBool);
  begin
    FAction.Enabled := Value;
  end;

  procedure TPhoaAction.SetHint(const Value: WideString);
  begin
    FAction.Hint := PhoaUnicodeToAnsi(Value);
  end;

  procedure TPhoaAction.SetTag(Value: Integer);
  begin
    FTag := Value;
  end;

   //===================================================================================================================
   // TPhoaActionList
   //===================================================================================================================

  procedure TPhoaActionList.ActionExecute(Sender: TObject);
  var ActionIntf: IPhoaAction;
  begin
     // Sender - ��� TAction. � ��� Tag ����� ������ �� IPhoaAction
    ActionIntf := IPhoaAction(TComponent(Sender).Tag);
    if (ActionIntf<>nil) then ActionIntf.Execute; // ��������� Execute() [����] ������������
  end;

  function TPhoaActionList.Add(const sName: WideString; AExecuteProc: TPhoaActionExecuteProc): IPhoaAction;
  var Action: TAction;
  begin
     // ������ ��������������� Action � NativeList
    Action := TAction.Create(FNativeList.Owner);
     // ������ IPhoaAction
    Result := TPhoaAction.Create(Action, True, AExecuteProc);
     // ����������� Action
    Action.ActionList := FNativeList;
    Action.Name       := PhoaUnicodeToAnsi(sName);
    Action.OnExecute  := ActionExecute;
  end;

  constructor TPhoaActionList.Create(ANativeList: TCustomActionList);
  var
    i: Integer;
    ActionIntf: IPhoaAction;
  begin
    inherited Create;
    FList       := TInterfaceList.Create;
    FNativeList := ANativeList;
     // ��������� ������ �������� Action-�� �� NativeList
    for i := 0 to FNativeList.ActionCount-1 do begin
      ActionIntf := TPhoaAction.Create(FNativeList[i] as TCustomAction, False, nil); // ���������� ����������� Actions �� ���������
       // ��������� ������ �� ���������� Action
      FList.Add(ActionIntf);
    end;
  end;

  function TPhoaActionList.FindName(const sName: WideString): IPhoaAction;
  var
    i: Integer;
    sAnsiName: String;
  begin
    sAnsiName := PhoaUnicodeToAnsi(sName);
    for i := 0 to FNativeList.ActionCount-1 do begin
      Result := IPhoaAction(FNativeList[i].Tag);
      if SameText(Result.Name, sAnsiName) then Exit;
    end;
    Result := nil;
  end;

  function TPhoaActionList.GetCount: Integer;
  begin
    Result := FNativeList.ActionCount;
  end;

  function TPhoaActionList.GetItems(Index: Integer): IPhoaAction;
  begin
    Result := IPhoaAction(FNativeList[Index].Tag);
  end;

   //===================================================================================================================
   // TPhoaMenuItem
   //===================================================================================================================

  function TPhoaMenuItem.AddItem(Action: IPhoaAction): IPhoaMenuItem;
  begin
    Result := TPhoaMenuItem.Create(Self, TTBXItem.Create(FItem.Owner), Action as IPhotoAlbumAction, True, False);
    if FVolatile then AddSubentry(Result);
  end;

  function TPhoaMenuItem.AddMenu: IPhoaMenu;
  begin
    Result := TPhoaMenuItem.Create(Self, TTBXSubmenuItem.Create(FItem.Owner), nil, True, False);
    if FVolatile then AddSubentry(Result);
  end;

  function TPhoaMenuItem.AddSeparator: IPhoaMenuSeparator;
  begin
    Result := TPhoaMenuItem.Create(Self, TTBXSeparatorItem.Create(FItem.Owner), nil, True, False);
    if FVolatile then AddSubentry(Result);
  end;

  procedure TPhoaMenuItem.AddSubentry(Item: IPhoaMenuEntry);
  begin
    if FSubentries=nil then FSubentries := TInterfaceList.Create;
    FSubentries.Add(Item);
  end;

  constructor TPhoaMenuItem.Create(AOwner: TPhoaMenuItem; AItem: TTBCustomItem; AAction: IPhotoAlbumAction; bVolatile, bRecursive: Boolean);
  var i: Integer;
  begin
    inherited Create;
    FOwner    := AOwner;
    FItem     := AItem;
    FAction   := AAction;
    FVolatile := bVolatile;
     // ���� �����, ��������� ����� ���� � ������ ������� ���������
    if (FOwner<>nil) and (FOwner.FItem.IndexOf(FItem)<0) then FOwner.FItem.Add(FItem);
     // ����������� Action ������
    if FAction<>nil then FItem.Action := FAction.NativeAction;
     // ���� �����, ���������� ��������� ��������� ������
    if not bVolatile and bRecursive then
      for i := 0 to AItem.Count-1 do AddSubentry(TPhoaMenuItem.Create(Self, AItem[i], nil, False, True));
  end;

  destructor TPhoaMenuItem.Destroy;
  begin
     // ���������� ������ ����������, ���� ����
    FSubentries := nil; 
     // ���� ��� volatile-�����, ���������� ��������������� �����
    if FVolatile then FItem.Free;  
    inherited Destroy;
  end;

  function TPhoaMenuItem.FindItemByActionName(const sActionName: WideString; bRecursive: LongBool): IPhoaMenuItem;
  var
    i: Integer;
    Menu: IPhoaMenu;
    sAnsiActionName: String;
  begin
    sAnsiActionName := PhoaUnicodeToAnsi(sActionName);
     // ���� ����� Action, ���������� ���������
    if (sAnsiActionName<>'') and (FSubentries<>nil) then
      for i := 0 to FSubentries.Count-1 do begin
         // ���� ��� �����, ���������� Action
        if Supports(FSubentries[i], IPhoaMenuItem, Result) and (Result.Action<>nil) and SameText(Result.Action.Name, sAnsiActionName) then Exit;
         // ���� �������� ��������, ���������� ��������� ����������
        if bRecursive and Supports(Result, IPhoaMenu, Menu) then begin
          Result := Menu.FindItemByActionName(sActionName, True);
          if Result<>nil then Exit;
        end;
      end;
    Result := nil;
  end;

  function TPhoaMenuItem.GetAction: IPhoaAction;
  begin
    if FItem.Action=nil then Result := nil else Result := IPhoaAction(FItem.Action.Tag);
  end;

  function TPhoaMenuItem.GetCaption: WideString;
  begin
    Result := PhoaAnsiToUnicode(FItem.Caption);
  end;

  function TPhoaMenuItem.GetIndex: Integer;
  begin
    if FOwner=nil then Result := -1 else Result := FOwner.FItem.IndexOf(FItem);
  end;

  function TPhoaMenuItem.GetItemByActionName(const sActionName: WideString; bRecursive: LongBool): IPhoaMenuItem;
  begin
    Result := FindItemByActionName(sActionName, bRecursive);
    if Result=nil then PhoaException(SErrMsg_PhoaActionNotFound, [sActionName]);
  end;

  function TPhoaMenuItem.GetOwner: IPhoaMenu;
  begin
    Result := FOwner;
  end;

  function TPhoaMenuItem.GetSubentries(Index: Integer): IPhoaMenuEntry;
  begin
    Result := IPhoaMenuEntry(FSubentries[Index]);
  end;

  function TPhoaMenuItem.GetSubentryCount: Integer;
  begin
    if FSubentries=nil then Result := 0 else Result := FSubentries.Count;
  end;

  procedure TPhoaMenuItem.Remove;
  begin
    if FOwner<>nil then FOwner.RemoveSubentry(Self);
  end;

  procedure TPhoaMenuItem.RemoveSubentry(Item: IPhoaMenuEntry);
  begin
    if FSubentries<>nil then FSubentries.Remove(Item);
  end;

  procedure TPhoaMenuItem.SetCaption(const Value: WideString);
  begin
    FItem.Caption := PhoaUnicodeToAnsi(Value);
  end;

  procedure TPhoaMenuItem.SetIndex(Value: Integer);
  begin
    if FOwner<>nil then FOwner.FItem.Move(FOwner.FItem.IndexOf(FItem), Value);
  end;

   //===================================================================================================================

  function NewThumbnailViewerDisplayData: IThumbnailViewerDisplayData;
  begin
    Result := TThumbnailViewerDisplayData.Create;
  end;

  function NewThumbnailViewerDisplayData(SelectedPics: IPhoaPicList; iFocusedID, iTopOffset: Integer): IThumbnailViewerDisplayData;
  begin
    Result := TThumbnailViewerDisplayData.Create(SelectedPics, iFocusedID, iTopOffset);
  end;

end.

