//**********************************************************************************************************************
//  $Id: phGUIObj.pas,v 1.3 2004-09-19 18:39:14 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phGUIObj;

interface
uses Windows, Messages, SysUtils, Graphics, Classes, Controls, Forms, GR32, phObj, phGraphics, ConsVars;

type  

   //===================================================================================================================
   // TThumbnailViewer - �������� ��������� ������� �����������
   //===================================================================================================================

   // ���������� ��� ��������� ���� 
  TThumbnailViewerPaintInfo = record
    RClip:     TRect;     // ClipRect
    RClient:   TRect;     // ClientRect
    Bitmap:    TBitmap32; // Buffer bitmap object
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
     // ���������� �������� � ��������
    FColCount: Integer;


     // ������ ������ �� ����������� ������, ����������� ������� SetCurrentGroup()
    FPicLinks: TPhoaPicLinks;
     // ������ �������� ���������� �������
    FSelIndexes: TIntegerList;
     // ������ ��������� ������
    FItemIndex: Integer;
     // ��� bmp-����������� �������
    FThumbCache: TList;
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
     // ����� ��� ���������� �������� ���������� ��� Drag'n'Drop
    FLastDragScrollTicks: Cardinal;
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
    FGroupID: Integer;
    FCacheThumbnails: Boolean;
    FDragInsideEnabled: Boolean;
    FThickThumbBorder: Boolean;
    FOnSelectionChange: TNotifyEvent;
    FBorderStyle: TBorderStyle;
    FDragEnabled: Boolean;
    FShowThumbTooltips: Boolean;
    FThumbTooltipProps: TPicProperties;
    FThumbCacheSize: Integer;
    FThumbBackColor: TColor;
    FThumbFontColor: TColor;
    FOnStartViewMode: TNotifyEvent;
    FDisplayMode: TThumbViewerDisplayMode;
    FTopOffset: Integer;
    FThumbnailSize: TSize; //DEPRECATED !!!


     // Painting stage handlers
    procedure Paint_EraseBackground(const Info: TThumbnailViewerPaintInfo);
    procedure Paint_Thumbnails(const Info: TThumbnailViewerPaintInfo);
    procedure Paint_Thumbnail(const Info: TThumbnailViewerPaintInfo; iIndex: Integer; ItemRect: TRect);
    procedure Paint_TransferBuffer(const Info: TThumbnailViewerPaintInfo);
     // Validates the specified offset and returns the correctly ranged offset value
    function  GetValidTopOffset(iOffset: Integer): Integer;
     // ������������ �������� ��������� ����������� �������
    procedure CalcLayout;
     // ���������� ������ ������ �������� ������������� ������
    function  GetFirstVisibleIndex: Integer;


     // ������� ��������� �� ���� ������� � ���������� True, ���� ��� ����
    function  ClearSelection: Boolean;
     // ������ ��� ������� ��������� � ������
    procedure ToggleSelection(Index: Integer);
    procedure AddToSelection(Index: Integer);
    procedure RemoveFromSelection(Index: Integer);
     // ���������� ItemIndex �� ����� �����, �� ������ ���������. ��� bUpdateStreamSelStart=True ����� ���������
     //   FStreamSelStart
    procedure MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart: Boolean);
     // �������� OnSelectionChange
    procedure DoSelectionChange;
     // �������� OnStartViewMode
    procedure DoStartViewMode;
     // ���������� ������ �� ������������ ����� _Pic, ���� �� ���� � ����, ����� ���������� nil
    function  GetCachedThumb(_Pic: TPhoaPic): TBitmap;
     // �������� ����� � ���. ����� ����� ��� ���������� ���������� Bitmap. ������ ���������� ������ � ��� ������, ����
     //   � ���� ��� ������� �����������!
    procedure PutThumbToCache(Pic: TPhoaPic; Bitmap: TBitmap);
     // ������� ������ ���� �� iNumber ����������� ��� ������, ���� ����������� ���������
    procedure LimitCacheSize(iNumber: Integer);
     // ����������� ScrollBar
    procedure UpdateScrollBar;
     // �������� �������� �������� ������� � �������� ItemIndex � idxEnd
    procedure SelectRange(idxStart, idxEnd: Integer);
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
    procedure WMContextMenu(var Msg: TWMContextMenu);           message WM_CONTEXTMENU;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode);             message WM_GETDLGCODE;
    procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd);             message WM_ERASEBKGND;
    procedure WMVScroll(var Msg: TWMVScroll);                   message WM_VSCROLL;
    procedure WMNCPaint(var Msg: TWMNCPaint);                   message WM_NCPAINT;
    procedure CMDrag(var Msg: TCMDrag);                         message CM_DRAG;
    procedure CMInvalidate(var Msg: TMessage);                  message CM_INVALIDATE;
     // Prop handlers
    procedure SetBorderStyle(Value: TBorderStyle);
    function  GetSelCount: Integer;
    procedure SetItemIndex(Value: Integer);
    procedure SetCacheThumbnails(Value: Boolean);
    procedure SetThickThumbBorder(Value: Boolean);
    function  GetSelectedIndexes(Index: Integer): Integer;
    function  GetIDSelected(iID: Integer): Boolean;
    function  GetSelectedPics(Index: Integer): TPhoaPic;
    function  GetDropTargetIndex: Integer;
    function  GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
    procedure SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
    procedure SetShowThumbTooltips(Value: Boolean);
    procedure SetThumbTooltipProps(Value: TPicProperties);
    procedure SetThumbCacheSize(Value: Integer);
    procedure SetThumbBackColor(Value: TColor);
    procedure SetThumbFontColor(Value: TColor);
    procedure SetDisplayMode(Value: TThumbViewerDisplayMode);
    procedure SetTopOffset(Value: Integer);
    procedure SetThumbnailSize(const Value: TSize);
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
     // ��������� ������� ��������� ����������� � ����������:
     //   � SelectedIDs - ������ ID ���������� ����������� (����� ���� nil!)
     //   � iFocusedID  - ID �����������, �������� ������������� ItemIndex (0, ���� ��� ������)
     //   � iTopOffset  - ������� TopOffset
    procedure SaveDisplay(out SelectedIDs: TIntegerList; out iFocusedID, iTopOffset: Integer);
     // ��������������� ��������� �����������; ��������������� ����������� ������������� ������,
     //   ���������� � ���������� ����������� ������ SaveDisplay():
     //     ���� SelectedIDs<>nil, �� ����� �������� ����������� � ��������� ID
     //     ���� iFocusedID>0, ������������� ItemIndex �� ����������� � �������� ID
     //     iTopOffset ����� �������� ������ �������� ������
    procedure RestoreDisplay(SelectedIDs: TIntegerList; iFocusedID, iTopOffset: Integer);
     // ������������� ������ Group ��� ��������� � �������� �������
    procedure ViewGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bRecurse: Boolean);
     // ������� ��������� �� ���� �������
    procedure SelectNone;
     // �������� ��� ������
    procedure SelectAll;
     // ���������� ������ ���������� �����������
    function  GetSelectedPicArray: TPicArray;
     // ���������� ItemIndex � �����, ��� -1, ���� ��� ��� ������
    function  ItemAtPos(ix, iy: Integer): Integer;
     // ���������� ���������� ������ � �������� Index (���� ���� ������ ������ ��� � ������!)
    function  ItemRect(Index: Integer): TRect;
     // ������ ����� � ������� �� ����������
    procedure InvalidateItem(Index: Integer);
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
     // -- ID ������, ������������ � ������ ������ (0, ���� ���)
    property GroupID: Integer read FGroupID;
     // -- True, ���� ����������� � �������� ID ��������
    property IDSelected[iID: Integer]: Boolean read GetIDSelected;
     // -- ������ ���������������� �����������
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
     // -- ���������� ���������� �����������
    property SelCount: Integer read GetSelCount;
     // -- ������� ���������� ����������� � ����� ������ ����������� viewer'� (Index - ������ ����������� �����������,
     //    0..SelCount-1)
    property SelectedIndexes[Index: Integer]: Integer read GetSelectedIndexes;
     // -- ���������� ����������� (Index - ������ ����������� �����������, 0..SelCount-1)
    property SelectedPics[Index: Integer]: TPhoaPic read GetSelectedPics;
     // -- ���� True, ���������� ����������� �������� �������
    property ShowThumbTooltips: Boolean read FShowThumbTooltips write SetShowThumbTooltips;
     // -- ������ ���� �������
    property ThumbCacheSize: Integer read FThumbCacheSize write SetThumbCacheSize;
     // -- ������, ������������ �� �������
    property ThumbCornerDetails[Corner: TThumbCorner]: TThumbCornerDetail read GetThumbCornerDetails write SetThumbCornerDetails;
     // -- ������, ������������ �� ����������� ��������� �������
    property ThumbTooltipProps: TPicProperties read FThumbTooltipProps write SetThumbTooltipProps;

     // -- ������� �������
    property ThumbnailSize: TSize read FThumbnailSize write SetThumbnailSize;
     // -- �������� �������� ���� ���� ������������ ������ ������ �������, � ��������
    property TopOffset: Integer read FTopOffset write SetTopOffset;
  published
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
     // -- ���������� �� ������ ��� ���������
    property CacheThumbnails: Boolean read FCacheThumbnails write SetCacheThumbnails default True;
    property Color default clBtnFace;
    property Constraints;
    property Ctl3D;
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
     // -- ���� True, ����� ������ �������� ����� �����
    property ThickThumbBorder: Boolean read FThickThumbBorder write SetThickThumbBorder default False;
     // -- ���� ���� �������
    property ThumbBackColor: TColor read FThumbBackColor write SetThumbBackColor default clBtnFace;
     // -- ���� ������ �������
    property ThumbFontColor: TColor read FThumbFontColor write SetThumbFontColor default clWindowText;
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

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses Math, Themes, TBX, TBXThemes, phUtils, main;

type
   // ������ ���� ������
  PThumbCacheRec = ^TThumbCacheRec;
  TThumbCacheRec = record
    Pic: TPhoaPic;
    Thumb: TBitmap;
  end;

   //===================================================================================================================
   // TThumbnailViewer
   //===================================================================================================================

  procedure TThumbnailViewer.AddToSelection(Index: Integer);
  begin
    if (Index>=0) and (Index<FPicLinks.Count) and FSelIndexes.Add(Index) then InvalidateItem(Index);
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
      if idx<0 then Hint := '' else Hint := FPicLinks[idx].GetPropStrs(FThumbTooltipProps, ':'#9, #13)+'|';
      FLastTooltipIdx := idx;
    end;
  end;

  procedure TThumbnailViewer.BeginUpdate;
  begin
    if FUpdateLock=0 then Perform(WM_SETREDRAW, 0, 0);
    Inc(FUpdateLock);
  end;

  procedure TThumbnailViewer.CalcLayout;
  var
    iPrevItemCount, iPrevColCount, iPrevTopOffset, iLineHeight: Integer;
    dc: HDC;
    PrevDisplayMode: TThumbViewerDisplayMode;
  begin
    if (FUpdateLock>0) or not HandleAllocated then Exit;
    iPrevItemCount  := FItemCount;
    iPrevColCount   := FColCount;
    iPrevTopOffset  := FTopOffset;
    PrevDisplayMode := FDisplayMode;
    FLastTooltipIdx := -1;
    Hint := '';
     // ������� ������� ������ � ���������� ��������
    FItemSize := FThumbnailSize;
    case FDisplayMode of
      tvdmTile: begin
         // -- ���������� ������� �� ����� ������
        Inc(FItemSize.cx, ILThumbMargin+IRThumbMargin);
        Inc(FItemSize.cy, ITThumbMargin+IBThumbMargin);
         // -- ������� ������ ������ ������
        dc := GetDC(0);
        Canvas.Handle := dc;
        Canvas.Font.Assign(Font);
        iLineHeight := Canvas.TextHeight('Wg');
        Canvas.Handle := 0;
        ReleaseDC(0, dc);
         // -- ���������� ������� �� ������ �����������
        if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(FItemSize.cy, iLineHeight);
        if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Inc(FItemSize.cy, iLineHeight);
         // ������� ���������� ��������
        FColCount := Max(1, ClientWidth div FItemSize.cx);
      end;
      else {tvdmDetail} begin
        FColCount := 1;
        FItemSize.cx := ClientWidth;
        Inc(FItemSize.cy, ITThumbMargin+IBThumbMargin);
      end;
    end;
     // ��������� ��������
    FItemCount := FPicLinks.Count;
    FVisibleItems := (ClientHeight div FItemSize.cy)*FColCount;
    FVRange := Ceil(FItemCount/FColCount)*FItemSize.cy;
    FTopOffset := GetValidTopOffset(FTopOffset);
     // ��������� ������������ ������ ��� ������� ���������
    if (FItemCount<>iPrevItemCount) or (FDisplayMode<>PrevDisplayMode) or (FColCount<>iPrevColCount) or (FTopOffset<>iPrevTopOffset) then Invalidate;
    UpdateScrollBar;
  end;

  function TThumbnailViewer.ClearSelection: Boolean;
  var i: Integer;
  begin
     // ���� ���� ���������
    Result := FSelIndexes.Count>0;
    if Result then
       // ���� ���������� �� �����������, invalidate thumbnails selected
      if FUpdateLock=0 then
        for i := FSelIndexes.Count-1 downto 0 do begin
          InvalidateItem(FSelIndexes[i]);
          FSelIndexes.Delete(i);
        end
       // ����� ������ �������
      else
        FSelIndexes.Clear;
  end;

  procedure TThumbnailViewer.CMDrag(var Msg: TCMDrag);
  begin
    if Msg.DragMessage in [dmDragDrop, dmDragCancel] then DragDrawInsertionPoint(FOldDragTargetCoord, True);
    inherited;
  end;

  procedure TThumbnailViewer.CMInvalidate(var Msg: TMessage);
  begin
    if HandleAllocated then InvalidateRect(Handle, nil, True);
  end;

  constructor TThumbnailViewer.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle      := [csCaptureMouse, csClickEvents, csOpaque, csDoubleClicks, csReplicatable];
    Width             := 100;
    Height            := 100;
    TabStop           := True;
    ParentColor       := False;
    Color             := clBtnFace;
    FBorderStyle      := bsSingle;
    FColCount         := 1;
    FCacheThumbnails  := True;
    FNoMoveItemIndex  := -1;
    FPicLinks         := TPhoaPicLinks.Create(False);
    FSelIndexes       := TIntegerList.Create(False);
    FThumbBackColor   := clBtnFace;
    FThumbCache       := TList.Create;
    FThumbnailSize.cx := IDefaultThumbWidth;
    FThumbnailSize.cy := IDefaultThumbHeight;
  end;

  procedure TThumbnailViewer.CreateParams(var Params: TCreateParams);
  begin
    inherited CreateParams(Params);
    with Params do begin
      WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
      Style := Style or WS_VSCROLL;
      if FBorderStyle=bsSingle then
        if NewStyleControls and Ctl3D then begin
          Style := Style and not WS_BORDER;
          ExStyle := ExStyle or WS_EX_CLIENTEDGE;
        end else
          Style := Style or WS_BORDER;
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
    FSelIndexes.Free;
    LimitCacheSize(0);
    FThumbCache.Free;
    FPicLinks.Free;
    FBuffer.Free;
    inherited Destroy;
  end;

  procedure TThumbnailViewer.DoSelectionChange;
  begin
    if (FUpdateLock=0) and Assigned(FOnSelectionChange) then FOnSelectionChange(Self);
  end;

  procedure TThumbnailViewer.DoStartViewMode;
  begin
    if Assigned(FOnStartViewMode) then FOnStartViewMode(Self);
  end;

  procedure TThumbnailViewer.DragDrawInsertionPoint(var Coord: TViewerInsertionCoord; bInvalidate: Boolean);
//  var
//    dc: HDC;
//    hp, hOld: HPEN;
//    idx, ix, iy: Integer;
  begin
//    if Coord.iIndex>=0 then begin
//       // ������� ���������� ����������
//      idx := Coord.iIndex;
//       // ���� �� ���� ���������� �������
//      if idx>=FTopIndex then begin
//        Dec(idx, FTopIndex);
//        ix := (idx mod FColCount)*FItemSize.cx;
//        iy := (idx div FColCount)*FItemSize.cy;
//         // ���� �� ���� ������ ������� ���������� �������
//        if iy<ClientHeight then begin
//           // ���������������?
//          if (ix=0) and Coord.bLower then begin
//            ix := FColCount*FItemSize.cx;
//            Dec(iy, FItemSize.cy);
//          end;
//           // ������������
//          dc := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
//          hp := CreatePen(PS_SOLID, 3, ColorToRGB(Color) xor ColorToRGB(CInsertionPoint));
//          hOld := SelectObject(dc, hp);
//          SetROP2(dc, R2_XORPEN);
//          MoveToEx(dc, ix, iy, nil);
//          LineTo(dc, ix, iy+FItemSize.cy);
//          MoveToEx(dc, ix-3, iy, nil);
//          LineTo(dc, ix+3, iy);
//          MoveToEx(dc, ix-3, iy+FItemSize.cy, nil);
//          LineTo(dc, ix+3, iy+FItemSize.cy);
//          SelectObject(dc, hOld);
//          DeleteObject(hp);
//          ReleaseDC(Handle, dc);
//        end;
//      end;
//       // Invalidate coord if needed
//      if bInvalidate then begin
//        Coord.iIndex := -1;
//        Coord.bLower := False;
//      end;
//    end;
  end;

  procedure TThumbnailViewer.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
//  var
//    iCol, iRow: Integer;
//    bLower: Boolean;
//
//    procedure SpeedAdjust;
//    var cTicks: Cardinal;
//    begin
//      cTicks := GetTickCount;
//       // ������ ��� �� ���
//      if (FLastDragScrollTicks>0) and (cTicks<FLastDragScrollTicks+IDragScrollDelay) then Sleep(FLastDragScrollTicks+IDragScrollDelay-cTicks);
//      FLastDragScrollTicks := cTicks;
//    end;
//
//     // ������������ ������ ������� ����� (bUp=True) ��� ���� (bUp=False)
//    procedure DoScroll(bUp: Boolean);
//    begin
//       // ������������ ��������
//      SpeedAdjust;
//       // ������� ������ ����� �������
//      DragDrawInsertionPoint(FOldDragTargetCoord, True);
//       // ������������
//      SetTopIndex(FTopIndex+iif(bUp, -FColCount, FColCount));
//      Update;
//    end;
//
  begin
//    if (Source=Self) and FDragInsideEnabled then begin
//      FDragTargetCoord.iIndex := -1;
//      FDragTargetCoord.bLower := False;
//       // ���� ������/��������� � ��������
//      if PtInRect(ClientRect, Point(x, y)) then begin
//         // ���� � ������� ��� ������ ������ ����, ������
//        if (y<IDragScrollAreaMargin) or (y>=ClientHeight-IDragScrollAreaMargin) then DoScroll(y<IDragScrollAreaMargin);
//         // ���������� ����� �������
//        if FItemCount>0 then begin
//           // ������� ������� (� �����������)
//          iCol := Round(x/FItemSize.cx);
//           // ���� ������ �� �������, �������� ����� bLower � ������������� ������ �� ����� � ������ ��������� ������
//          bLower := iCol>=FColCount;
//          if bLower then iCol := FColCount;
//           // ������� ������ (������ ������ � ������ ������)
//          iRow := FTopIndex+(y div FItemSize.cy)*FColCount;
//           // ���� ������ �������� ������
//          if iRow<FItemCount then begin
//            FDragTargetCoord.iIndex := iRow+iCol;
//             // ���� ��������� �� ��������� ����� - ���� �������� bLower
//            if FDragTargetCoord.iIndex>=FItemCount then begin
//              FDragTargetCoord.iIndex := FItemCount;
//              bLower := True;
//            end;
//            FDragTargetCoord.bLower := bLower;
//          end;
//        end;
//      end;
//       // ���� ���������� ��������� ������� - ������������ ���
//      if (FDragTargetCoord.iIndex<>FOldDragTargetCoord.iIndex) or (FDragTargetCoord.bLower<>FOldDragTargetCoord.bLower) then begin
//        DragDrawInsertionPoint(FOldDragTargetCoord, False);
//        DragDrawInsertionPoint(FDragTargetCoord, False);
//        FOldDragTargetCoord := FDragTargetCoord;
//      end;
//       // Drop ��������, ���� ���� ���������� ���������� �������, � ��������������� �� ��� �����, � �� ������������
//       //   ����������� ��� ����� ������� �� ��������� � ���������� ����� �����������
//      Accept :=
//        (FDragTargetCoord.iIndex>=0) and
//        (FSelIndexes.Count<FPicLinks.Count) and
//        ((FSelIndexes.Count>1) or ((FSelIndexes[0]<>FDragTargetCoord.iIndex) and (FSelIndexes[0]<>FDragTargetCoord.iIndex-1)));
//    end else
//      inherited DragOver(Source, X, Y, State, Accept);
  end;

  procedure TThumbnailViewer.EndUpdate;
  begin
    if FUpdateLock>0 then Dec(FUpdateLock);
    if FUpdateLock=0 then begin
      Perform(WM_SETREDRAW, 1, 0);
      CalcLayout;
      Refresh;
      DoSelectionChange;
    end;
  end;

  function TThumbnailViewer.GetCachedThumb(_Pic: TPhoaPic): TBitmap;
  var i: Integer;
  begin
    for i := 0 to FThumbCache.Count-1 do
      with PThumbCacheRec(FThumbCache[i])^ do
        if Pic=_Pic then begin
          Result := Thumb;
           // ���������� ����������� � ������ ����
          FThumbCache.Move(i, 0);
          Exit;
        end;
    Result := nil;
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
  var idx: Integer;
  begin
    Result := False;
    idx := FPicLinks.IndexOfID(iID);
    if (idx>=0) and (FSelIndexes.IndexOf(idx)>=0) then Result := True;
  end;

  function TThumbnailViewer.GetSelCount: Integer;
  begin
    Result := FSelIndexes.Count;
  end;

  function TThumbnailViewer.GetSelectedIndexes(Index: Integer): Integer;
  begin
    Result := FSelIndexes[Index];
  end;

  function TThumbnailViewer.GetSelectedPicArray: TPicArray;
  var i: Integer;
  begin
    SetLength(Result, FSelIndexes.Count);
    for i := 0 to FSelIndexes.Count-1 do Result[i] := GetSelectedPics(i);
  end;

  function TThumbnailViewer.GetSelectedPics(Index: Integer): TPhoaPic;
  begin
    Result := FPicLinks[FSelIndexes[Index]];
  end;

  function TThumbnailViewer.GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
  begin
    Result := FThumbCornerDetails[Corner];
  end;

  function TThumbnailViewer.GetValidTopOffset(iOffset: Integer): Integer;
  begin
    Result := Max(0, Min(iOffset, FVRange-ClientHeight));
  end;

  procedure TThumbnailViewer.InvalidateItem(Index: Integer);
  var r: TRect;
  begin
    if (FUpdateLock=0) and HandleAllocated then begin
      r := ItemRect(Index);
      if not IsRectEmpty(r) then InvalidateRect(Handle, @r, False);
    end;
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

  function TThumbnailViewer.ItemRect(Index: Integer): TRect;
  var ix, iy: Integer;
  begin
    FillChar(Result, SizeOf(Result), 0);
    if (Index>=0) and (Index<FItemCount) then begin
      ix := (Index mod FColCount)*FItemSize.cx;
      iy := (Index div FColCount)*FItemSize.cy-FTopOffset;
      if iy<ClientHeight then Result := Rect(ix, iy, ix+FItemSize.cx, iy+FItemSize.cy);
    end;
  end;

  procedure TThumbnailViewer.KeyDown(var Key: Word; Shift: TShiftState);

    procedure SetII(ii: Integer);
    begin
      if (ssShift in Shift) and (FStreamSelStart>=0) then SelectRange(FStreamSelStart, ii) else SetItemIndex(ii);
      ScrollIntoView;
    end;

  begin
    if (Shift=[]) or
       (Shift=[ssShift]) or
       (((Shift=[ssCtrl]) or (Shift=[ssShift, ssCtrl])) and (Key in [VK_PRIOR, VK_NEXT, VK_HOME, VK_END])) then
      case Key of
        VK_UP:     if ItemIndex>=FColCount then           SetII(ItemIndex-FColCount);
        VK_LEFT:   if ItemIndex>0          then           SetII(ItemIndex-1);
        VK_DOWN:   if ItemIndex<FItemCount-FColCount then SetII(ItemIndex+FColCount);
        VK_RIGHT:  if ItemIndex<FItemCount-1 then         SetII(ItemIndex+1);
        VK_HOME:                                         SetII(0);
        VK_END:                                          SetII(FItemCount-1);
        VK_PRIOR:  if (ItemIndex>=FVisibleItems) and not (ssCtrl in Shift) then SetII(ItemIndex-FVisibleItems) else SetII(0);
        VK_NEXT:   if (ItemIndex<FItemCount-FVisibleItems) and not (ssCtrl in Shift) then SetII(ItemIndex+FVisibleItems) else SetII(FItemCount-1);
        VK_RETURN: DoStartViewMode;
      end;
  end;

  procedure TThumbnailViewer.LimitCacheSize(iNumber: Integer);
  var
    i: Integer;
    p: PThumbCacheRec;
  begin
    if not FCacheThumbnails then iNumber := 0;
    for i := FThumbCache.Count-1 downto iNumber do begin
      p := FThumbCache[i];
      p.Thumb.Free;
      Dispose(p);
      FThumbCache.Delete(i);
    end;
  end;

  procedure TThumbnailViewer.MarqueingEnd;
//  var
//    i: Integer;
//    r, rThumb: TRect;
  begin
//    ReleaseCapture;
//    FMarqueing := False;
//    PaintMarquee;
//    ReleaseDC(Handle, FTempDC);
//     // ���� �� ��� ����� Shift, ������� Selection (�������� � ����)
//    if GetKeyState(VK_SHIFT) and $80=0 then ClearSelection;
//     // Select thumbnails that do intersect with marquee
//    r := OrderRect(Rect(FStartPos, FMarqueeCur));
//    i := FTopIndex;
//    while (i<FTopIndex+FVisibleItems+FColCount) and (i<FItemCount) do begin
//      rThumb := ItemRect(i);
//      IntersectRect(rThumb, rThumb, r);
//      if not IsRectEmpty(rThumb) then AddToSelection(i);
//      Inc(i);
//    end;
//    DoSelectionChange;
  end;

  procedure TThumbnailViewer.MarqueingStart;
  begin
//    SetCapture(Handle);
//    FTempDC := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
//    FMarqueing := True;
//    FMarqueeCur := FStartPos;
  end;

  procedure TThumbnailViewer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var idx: Integer;
  begin
    SetFocus;
    idx := ItemAtPos(x, y);
    FStartPos := Point(x, y);
     // ���� ����� Alt - �������� ��������� (marqueing)
    if ssAlt in Shift then begin
      if Button=mbLeft then MarqueingStart;
     // ���� ����� Ctrl
    end else if ssCtrl in Shift then begin
       // ���� ����� ������ - ����������� ��������� ������, �� ������� ��������
      if Button=mbLeft then begin
        ToggleSelection(idx);
        MoveItemIndex(idx, True);
       // ���� ������ ������ - ������� ����� Shell Context Menu
      end else if Button=mbRight then begin
        ClearSelection;
        SetItemIndex(idx);
        if idx>=0 then begin
          FShellCtxMenuOnMouseUp := True;
          Exit;
        end;
      end;
      DoSelectionChange;
     // ���� ����� Shift - �������� ������ ������ ������
    end else if ssShift in Shift then
      if FStreamSelStart>=0 then SelectRange(FStreamSelStart, idx) else SetItemIndex(idx)
     // �� ������ ������
    else begin
      if (idx<0) or (FSelIndexes.IndexOf(idx)<0) then begin
        SetItemIndex(idx);
        FNoMoveItemIndex := -1;
      end else if Button=mbLeft then
        FNoMoveItemIndex := idx;
      if Button=mbLeft then
        if idx<0 then MarqueingStart
        else if FDragEnabled and (FSelIndexes.Count>0) then FDragPending := True;
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
        FLastDragScrollTicks := 0;
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
      if (ssCtrl in Shift) and (FItemIndex>=0) and (FItemIndex=ItemAtPos(x, y)) then ShowFileShellContextMenu(FPicLinks[FItemIndex].PicFileName);
      Exit;
     // ����� ��������� Dragging
    end else begin
      FDragPending := False;
      if FNoMoveItemIndex>=0 then begin
        if not Dragging then SetItemIndex(FNoMoveItemIndex);
        FNoMoveItemIndex := -1;
      end;
    end;
    inherited MouseUp(Button, Shift, x, y);
  end;

  procedure TThumbnailViewer.MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart: Boolean);
  begin
    if iNewIndex<>FItemIndex then begin
      InvalidateItem(FItemIndex);
      FItemIndex := iNewIndex;
      InvalidateItem(FItemIndex);
    end;
    if bUpdateStreamSelStart then FStreamSelStart := iNewIndex;
  end;

  procedure TThumbnailViewer.Paint;
  var
    Info: TThumbnailViewerPaintInfo;
//    bmp: TBitmap;
//    r, rClip, rThumb: TRect;
//    idx: Integer;
//
//    procedure MakeBufferBitmap;
//    begin
//      if bmp=nil then begin
//        bmp := TBitmap.Create;
//        bmp.Width  := FItemSize.cx;
//        bmp.Height := FItemSize.cy;
//      end;
//    end;

  begin
     // ������ �������� ������, ���� �� ��� �� ������
    if FBuffer=nil then FBuffer := TBitmap32.Create;
     // ������ ��������� ������ ��� ��������� 
    with Info do begin
      RClip   := Canvas.ClipRect;
      RClient := ClientRect;
      if IsRectEmpty(RClient) then Exit;
      FBuffer.SetSize(RClient.Right-RClient.Left, RClient.Bottom-RClient.Top);
      Bitmap := FBuffer;
    end;
     // Invoke the painting stages one-by-one
    Paint_EraseBackground(Info);
    Paint_Thumbnails(Info);
    Paint_TransferBuffer(Info);



(*    rClip := Canvas.ClipRect;
    bmp := nil;
    try
       // ������������ ������
      idx := FTopIndex;
      repeat
         // ������� ������� ������ (������� ��� ������� ������� ������)
        rThumb := ItemRect(idx);
        if IsRectEmpty(rThumb) then Break;
         // ������� ����������� ������ � ClipRect
        IntersectRect(r, rThumb, rClip);
        if not IsRectEmpty(r) then begin
           // ���� ����� ����� ���� - ������ � ����� � ��������� ��� �� �����
          if idx<FItemCount then begin
            MakeBufferBitmap;
            PaintThumb(idx, bmp);
            BitBlt(Canvas.Handle, r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top, bmp.Canvas.Handle, r.Left-rThumb.Left, r.Top-rThumb.Top, SRCCOPY);
           // ����� - ������� ���
          end ;//else
//            with Canvas do begin
//              Brush.Style := bsSolid;
//              Brush.Color := Color;
//              FillRect(r);
//            end;
        end;
        Inc(idx);
      until False;
    finally
      bmp.Free;
    end;
     // ������� ���������������� ������� ������ �� �������
//    IntersectRect(r, Rect(FColCount*FItemSize.cx, 0, ClientWidth, ClientHeight), rClip);
//    if not IsRectEmpty(r) then
//      with Canvas do begin
//        Brush.Style := bsSolid;
//        Brush.Color := Color;
//        FillRect(r);
//      end;*)
  end;

  procedure TThumbnailViewer.PaintMarquee;
  var r: TRect;
  begin
    r := OrderRect(Rect(FStartPos, FMarqueeCur));
    if not IsRectEmpty(r) then DrawFocusRect(FTempDC, r);
  end;

  procedure TThumbnailViewer.Paint_EraseBackground(const Info: TThumbnailViewerPaintInfo);
  begin
    CurrentTheme.PaintBackgnd(Info.Bitmap.Canvas, Info.RClient, Info.RClient, Info.RClip, Color, False, VT_UNKNOWN);
  end;

  procedure TThumbnailViewer.Paint_Thumbnail(const Info: TThumbnailViewerPaintInfo; iIndex: Integer; ItemRect: TRect);
  const                                                                                                             
    aSelectedFontClr: Array[Boolean] of TColor = (clWindowText, clHighlightText);
    aSelectedBackClr: Array[Boolean] of TColor = (clBtnShadow,  clHighlight);
    aEdges: Array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_RAISEDINNER or BDR_RAISEDOUTER);
  var
    Pic: TPhoaPic;
    bSel, bFocused: Boolean;
    iLineHeight: Integer;
    cBack: TColor32;
    r, rInner: TRect;

     // ������������ �� ������ ������ ������ ����. ���������� ������ ������������� ������
    function DrawDetail(Corner: TThumbCorner; rText: TRect): Integer;
    var sProp: String;
    begin
      Result := 0;
      if (FThumbCornerDetails[Corner].bDisplay) and (rText.Left<rText.Right) then begin
        sProp := Pic.Props[FThumbCornerDetails[Corner].Prop];
        if sProp<>'' then begin
          Result := Info.Bitmap.Canvas.TextWidth(sProp)+2;
          DrawText(Info.Bitmap.Canvas.Handle, PChar(sProp), -1, rText, iif(Corner in [tcRightTop, tcRightBottom], DT_RIGHT, DT_LEFT) or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_END_ELLIPSIS);
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
    procedure DoPaintThumbnail(const rThumb: TRect);
    var
      bCacheUsed: Boolean;
      bmpThumb: TBitmap;
      ix, iy: Integer;
    begin
       // ���� ����������� � ����
      bmpThumb := GetCachedThumb(Pic);
      bCacheUsed := bmpThumb<>nil;
      try
         // ���� �� ����� - ������ ��������� ������ � ��������� �� ���� JPEG-����������� ������
        if not bCacheUsed then begin
          bmpThumb := TBitmap.Create;
          Pic.PaintThumbnail(bmpThumb);
        end;
        ix := (rThumb.Left+rThumb.Right-bmpThumb.Width) div 2;
        iy := (rThumb.Top+rThumb.Bottom-bmpThumb.Height) div 2;
         // ������ �����
        BitBlt(
          Info.Bitmap.Canvas.Handle,
          Max(ix, rThumb.Left),
          Max(iy, rThumb.Top),
          Min(bmpThumb.Width, rThumb.Right-rThumb.Left),
          Min(bmpThumb.Height, rThumb.Bottom-rThumb.Top),
          bmpThumb.Canvas.Handle,
          0,
          0,
          SRCCOPY);
         // �������� ����� ��� �������������
        if not bCacheUsed and FCacheThumbnails then begin
          PutThumbToCache(Pic, bmpThumb);
          bCacheUsed := True;
        end;
      finally
        if not bCacheUsed then bmpThumb.Free;
      end;
    end;

  begin
    bSel     := FSelIndexes.IndexOf(iIndex)>=0;
    bFocused := Focused;
     // ���� �����������
    Pic := FPicLinks[iIndex];
     // ������ �����
    r := ItemRect;
//    if (idx=FItemIndex) and bFocused then DrawFocusRect(r);
    InflateRect(r, -2, -2);
    Info.Bitmap.Font.Assign(Self.Font);
    if bSel then begin
      Info.Bitmap.Font.Color := aSelectedFontClr[bFocused];
      cBack                  := Color32(aSelectedBackClr[bFocused]);
    end else begin
      Info.Bitmap.Font.Color := FThumbFontColor;
      cBack                  := Color32(FThumbBackColor);
    end;
    cBack := SetAlpha(cBack, $70);
    if ThemeServices.ThemesEnabled then begin
      SaveDC(Info.Bitmap.Canvas.Handle);
      try
        ExcludeClipRect(Info.Bitmap.Canvas.Handle, r.Left+2, r.Top+2, r.Right-2, r.Bottom-2);
        ThemeServices.DrawElement(Info.Bitmap.Canvas.Handle, ThemeServices.GetElementDetails(teEditTextNormal), r);
      finally
        RestoreDC(Info.Bitmap.Canvas.Handle, -1);
      end;
      InflateRect(r, -2, -2);
      Info.Bitmap.FillRectTS(r, cBack);
    end else begin
      Info.Bitmap.FillRectTS(r, cBack);
      DrawEdge(Info.Bitmap.Canvas.Handle, r, aEdges[FThickThumbBorder], BF_RECT);
    end;
    iLineHeight := Info.Bitmap.TextHeight('Wg');
     // ������������ ����������� ������
    rInner := ItemRect;
    if FDisplayMode=tvdmTile then begin
      Inc(rInner.Left,   ILThumbMargin);
      Dec(rInner.Right,  IRThumbMargin);
      if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(r.Top,    iLineHeight);
      if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Dec(r.Bottom, iLineHeight);
    end;
    Inc(rInner.Top,    ITThumbMargin);
    Dec(rInner.Bottom, IBThumbMargin);
    DoPaintThumbnail(rInner);
     // ������ ��������
    case FDisplayMode of
      tvdmTile: begin
        r := rInner;
        r.Bottom := r.Top+iLineHeight;
        DrawDetailsLR(tcLeftTop,    tcRightTop,    r);
        r := rInner;
        r.Top := r.Bottom-iLineHeight;
        DrawDetailsLR(tcLeftBottom, tcRightBottom, r);
      end;
      tvdmDetail: {!!!};
    end;
  end;

  procedure TThumbnailViewer.Paint_Thumbnails(const Info: TThumbnailViewerPaintInfo);
  var
    rThumb: TRect;
    i, idxStart: Integer;
  begin
     // ������������ ������
    idxStart := GetFirstVisibleIndex;
    if idxStart>=0 then
      for i := idxStart to FItemCount-1 do begin
         // ������� ������� ������
        rThumb := ItemRect(i);
        if IsRectEmpty(rThumb) then Break;
         // ���� ������� ������ ������������ � ClipRect - ������ ���� �����
        if RectsOverlap(rThumb, Info.RClip) then Paint_Thumbnail(Info, i, rThumb);
      end;;
  end;

  procedure TThumbnailViewer.Paint_TransferBuffer(const Info: TThumbnailViewerPaintInfo);
  begin
    Info.Bitmap.DrawTo(Canvas.Handle, 0, 0);
  end;

  procedure TThumbnailViewer.PutThumbToCache(Pic: TPhoaPic; Bitmap: TBitmap);
  var p: PThumbCacheRec;
  begin
     // ��������� � ���
    New(p);
    p^.Pic   := Pic;
    p^.Thumb := Bitmap;
    FThumbCache.Insert(0, p);
     // ������� ������ ����
    LimitCacheSize(FThumbCacheSize);
  end;

  procedure TThumbnailViewer.RemoveFromSelection(Index: Integer);
  begin
    if FSelIndexes.Remove(Index)>=0 then InvalidateItem(Index);
  end;

  procedure TThumbnailViewer.RestoreDisplay(SelectedIDs: TIntegerList; iFocusedID, iTopOffset: Integer);
  var i, iItemIdx: Integer;
  begin
    ClearSelection;
     // ��������� � ��������� ����������� � ��������� ID
    if SelectedIDs<>nil then
      for i := 0 to SelectedIDs.Count-1 do AddToSelection(FPicLinks.IndexOfID(SelectedIDs[i]));
     // ���� ��� ���������, �������� ������ ����������� (���� ��� ����)
    if FSelIndexes.Count=0 then AddToSelection(0);
     // ������� ��������������� �����������
    if iFocusedID>0 then iItemIdx := FPicLinks.IndexOfID(iFocusedID) else iItemIdx := -1;
     // ���� ��� � �� �������
    if iItemIdx<0 then
       // ���������� ��������� �� ����������, ���� ��� ����
      if FSelIndexes.Count>0 then iItemIdx := FSelIndexes[FSelIndexes.Count-1]
       // ����� �������� �������� ����� ������ �����������, ���� ��� ����
      else if FPicLinks.Count>0 then iItemIdx := 0;
    TopOffset := iTopOffset;
    MoveItemIndex(iItemIdx, True);
    DoSelectionChange;
  end;

  procedure TThumbnailViewer.SaveDisplay(out SelectedIDs: TIntegerList; out iFocusedID, iTopOffset: Integer);
  var i: Integer;
  begin
    iFocusedID := 0;
    if FSelIndexes.Count>0 then begin
      SelectedIDs := TIntegerList.Create(False);
      for i := 0 to FSelIndexes.Count-1 do SelectedIDs.Add(SelectedPics[i].ID);
      if FItemIndex>=0 then iFocusedID := FPicLinks[FItemIndex].ID;
    end else
      SelectedIDs := nil;
    iTopOffset := FTopOffset;
  end;

  procedure TThumbnailViewer.ScrollIntoView;
  begin
//    if FItemIndex>=0 then
//       // ���� ItemIndex ���� ���� ���������
//      if FItemIndex<FTopIndex then SetTopIndex(FItemIndex)
//       // ���� ItemIndex ���� ���� ���������
//      else if FTopIndex+FVisibleItems<=FItemIndex then SetTopIndex(((FItemIndex div FColCount)+1)*FColCount-FVisibleItems);
  end;

  procedure TThumbnailViewer.SelectAll;
  var i: Integer;
  begin
    if FSelIndexes.Count<FItemCount then begin
      ClearSelection;
      for i := 0 to FItemCount-1 do FSelIndexes.Add(i);
      Invalidate;
      DoSelectionChange;
    end;
  end;

  procedure TThumbnailViewer.SelectNone;
  begin
    if ClearSelection then DoSelectionChange;
  end;

  procedure TThumbnailViewer.SelectRange(idxStart, idxEnd: Integer);
  var i: Integer;
  begin
    ClearSelection;
    MoveItemIndex(idxEnd, False);
    if idxStart>idxEnd then begin
      i := idxStart;
      idxStart := idxEnd;
      idxEnd := i;
    end;
    for i := idxStart to idxEnd do AddToSelection(i);
    DoSelectionChange;
  end;

  procedure TThumbnailViewer.SetBorderStyle(Value: TBorderStyle);
  begin
    if FBorderStyle<>Value then begin
      FBorderStyle := Value;
      RecreateWnd;
    end;  
  end;

  procedure TThumbnailViewer.SetCacheThumbnails(Value: Boolean);
  begin
    if FCacheThumbnails<>Value then begin
      FCacheThumbnails := Value;
      LimitCacheSize(FThumbCacheSize);
    end;
  end;

  procedure TThumbnailViewer.SetDisplayMode(Value: TThumbViewerDisplayMode);
  begin
    if FDisplayMode<>Value then begin
      FDisplayMode := Value;
      CalcLayout;
    end;
  end;

  procedure TThumbnailViewer.SetItemIndex(Value: Integer);
  begin
     // ���� �������� ������, ��� ��� ���������, � ��� �����, ��� ��������
    if (FItemIndex<>Value) or ((FSelIndexes.Count=0)<>(Value<0)) then begin
      ClearSelection;
      AddToSelection(Value);
      MoveItemIndex(Value, True);
      DoSelectionChange;
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

  procedure TThumbnailViewer.SetThickThumbBorder(Value: Boolean);
  begin
    if FThickThumbBorder<>Value then begin
      FThickThumbBorder := Value;
      Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbBackColor(Value: TColor);
  begin
    if FThumbBackColor<>Value then begin
      FThumbBackColor := Value;
      if FPicLinks.Count>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbCacheSize(Value: Integer);
  begin
    if FThumbCacheSize<>Value then begin
      FThumbCacheSize := Value;
      LimitCacheSize(Value);
    end;
  end;

  procedure TThumbnailViewer.SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
  begin
    FThumbCornerDetails[Corner] := Value;
    CalcLayout;
  end;

  procedure TThumbnailViewer.SetThumbFontColor(Value: TColor);
  begin
    if FThumbFontColor<>Value then begin
      FThumbFontColor := Value;
      if FPicLinks.Count>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbnailSize(const Value: TSize);
  begin
    if (FThumbnailSize.cx<>Value.cx) or (FThumbnailSize.cy<>Value.cy) then begin
      FThumbnailSize := Value;
      LimitCacheSize(0);
      CalcLayout;
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
      FTopOffset := Value;
      UpdateScrollBar;
      Invalidate;
    end;
  end;

  procedure TThumbnailViewer.ToggleSelection(Index: Integer);
  begin
    if FSelIndexes.IndexOf(Index)>=0 then RemoveFromSelection(Index) else AddToSelection(Index);
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

  procedure TThumbnailViewer.ViewGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bRecurse: Boolean);
  var iItemIdx: Integer;
  begin
    BeginUpdate;
    try
       // ������� ����� GroupID
      if Group=nil then FGroupID := 0 else FGroupID := Group.ID;
       // �������� ������ �� ����������� �� �� IDs �� ������
      FPicLinks.AddFromGroup(PhoA, Group, True, bRecurse);
       // ������� ��� �������
      LimitCacheSize(0);
       // ������� ���������
      ClearSelection;
      FTopOffset := 0;
       // �������� ������ ����������� (���� ��� ����)
      AddToSelection(0);
      if FSelIndexes.Count>0 then iItemIdx := FSelIndexes[0] else iItemIdx := -1;
      MoveItemIndex(iItemIdx, True);
    finally
       // ������������� layout, validate TopIndex, ���������, ���������� �� ��������� ���������
      EndUpdate;
    end;
  end;

  procedure TThumbnailViewer.WMContextMenu(var Msg: TWMContextMenu);
  begin
     // �������� context menu ������ ���� �� ��� ����� Ctrl
    if not FShellCtxMenuOnMouseUp then inherited; 
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

  procedure TThumbnailViewer.WMNCPaint(var Msg: TWMNCPaint);
  begin
    DefaultHandler(Msg);
    if ThemeServices.ThemesEnabled then ThemeServices.PaintBorder(Self, False);
  end;

  procedure TThumbnailViewer.WMVScroll(var Msg: TWMVScroll);
  var iOffset: Integer;
  begin
    case Msg.ScrollCode of
      SB_BOTTOM:       iOffset := MaxInt;
      SB_LINEDOWN:     iOffset := FTopOffset+10;
      SB_LINEUP:       iOffset := FTopOffset-10;
      SB_PAGEDOWN:     iOffset := FTopOffset+ClientHeight;
      SB_PAGEUP:       iOffset := FTopOffset-ClientHeight;
      SB_THUMBPOSITION,
        SB_THUMBTRACK: iOffset := Msg.Pos;
      SB_TOP:          iOffset := 0;
      else Exit;
    end;
    TopOffset := iOffset;
  end;

  procedure TThumbnailViewer.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
  begin
    inherited;
    CalcLayout;
  end;

  procedure TThumbnailViewer.WndProc(var Msg: TMessage);
  var i: Integer;
  begin
    case Msg.Msg of
       // On (un)gaining focus repaint selection
      WM_KILLFOCUS, WM_SETFOCUS: begin
        for i := 0 to FSelIndexes.Count-1 do InvalidateItem(FSelIndexes[i]);
        if (FItemIndex>=0) and (FSelIndexes.IndexOf(FItemIndex)<0) then InvalidateItem(FItemIndex);
      end;
      WM_LBUTTONDBLCLK: begin
        DblClick;
        Exit;
      end;
      WM_MOUSEWHEEL: begin
        if TWMMouseWheel(Msg).WheelDelta>0 then TopOffset := TopOffset-FItemSize.cy else TopOffset := TopOffset+FItemSize.cy;
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

end.
 
