//**********************************************************************************************************************
//  $Id: ufImgView.pas,v 1.55 2007-06-27 18:29:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufImgView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GraphicEx, GR32, Controls, Forms, Dialogs, Registry,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phGraphics,
  GR32_Layers, 
  TB2Item, TBX, Menus, ActnList, GR32_Image, TB2Dock,
  TB2Toolbar, TB2ExtItems, TBXExtItems, DKLang, phFrm;

const  
   // ������� ��������� �������������
  WM_DECODE_FINISHED = WM_USER + 201;

type
   // �����, ������������ ��������� ����������� � ������� ������
  TDecodeThread = class(TThread)
  private
     // Bitmap, � ������� ������������ ����
    FBitmap: TBitmap32;
     // ������� ���������� ����������� � ������� �� �������������
    FHQueuedEvent: THandle;
     // ���� ������������� �������� �������� ����������� ��� ������ �����������
    FLoadAborted: Boolean;
     // ���������� ������� � FLoadAborted
    FLoadAbortLock: TRTLCriticalSection;
     // �����-��������
    FOwner: TForm;
     // Prop storage
    FQueuedFileName: WideString;
    FHDecodedEvent: THandle;
    FErrorMessage: WideString;
     // ������� ��������� �������� �����������
    procedure LoadProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
     // Prop handlers
    function  GetDecoding: Boolean;
    procedure SetQueuedFileName(const Value: WideString);
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TForm);
    destructor Destroy; override;
     // ���������� � �������� �������������� Bitmap
    function  GetAndReleasePicture: TBitmap32;
    procedure Terminate;
     // Props
     // -- True, ���� ����� ����� ��������������
    property Decoding: Boolean read GetDecoding;
     // -- ����� ��������� �� ������, ���� ����� ������������� Graphic=nil
    property ErrorMessage: WideString read FErrorMessage;
     // -- ������� ���������� �������������
    property HDecodedEvent: THandle read FHDecodedEvent;
     // -- ��� �����, ������� ����������, ��� ����� ���������� �����. ��� ������������ ���� ����������� �������� �
     //    ������� �� �������������, ������������ ������� �������������� �����������
    property QueuedFileName: WideString read FQueuedFileName write SetQueuedFileName;
  end;

   // ����������� ���������������� �����������
  TPredecodeDirection = (
    pddDisabled,  // ���������
    pddForward,   // �����
    pddBackward); // �����

  TfImgView = class(TPhoaForm)
    aClose: TAction;
    aEdit: TAction;
    aFirstPic: TAction;
    aFlipHorz: TAction;
    aFlipVert: TAction;
    aFullScreen: TAction;
    aHelp: TAction;
    aLastPic: TAction;
    alMain: TActionList;
    aNextPic: TAction;
    aPrevPic: TAction;
    aRefresh: TAction;
    aRelocateInfo: TAction;
    aRotate0: TAction;
    aRotate180: TAction;
    aRotate270: TAction;
    aRotate90: TAction;
    aSettings: TAction;
    aShowInfo: TAction;
    aSlideShow: TAction;
    aSlideShowBackward: TAction;
    aSlideShowCyclic: TAction;
    aSlideShowForward: TAction;
    aSlideShowRandom: TAction;
    aStoreTransform: TAction;
    aZoomActual: TAction;
    aZoomFit: TAction;
    aZoomIn: TAction;
    aZoomOut: TAction;
    bClose: TTBXItem;
    bEdit: TTBXItem;
    bFirstPic: TTBXItem;
    bFullScreen: TTBXItem;
    bHelp: TTBXItem;
    bLastPic: TTBXItem;
    bNextPic: TTBXItem;
    bPrevPic: TTBXItem;
    bRefresh: TTBXItem;
    bRelocateInfo: TTBXItem;
    bSettings: TTBXItem;
    bShowInfo: TTBXItem;
    bZoomActual: TTBXItem;
    bZoomFit: TTBXItem;
    bZoomIn: TTBXItem;
    bZoomOut: TTBXItem;
    dkBottom: TTBXDock;
    dklcMain: TDKLanguageController;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    dkTop: TTBXDock;
    eCounter: TTBXEditItem;
    eSlideShowInterval: TTBXSpinEditItem;
    gipmTools: TTBGroupItem;
    iClose: TTBXItem;
    iEdit: TTBXItem;
    iFirstPic: TTBXItem;
    iFlipHorz: TTBXItem;
    iFlipVert: TTBXItem;
    iFullScreen: TTBXItem;
    iHelp: TTBXItem;
    iLastPic: TTBXItem;
    iMain: TImage32;
    iNextPic: TTBXItem;
    ipmClose: TTBXItem;
    ipmFirstPic: TTBXItem;
    ipmLastPic: TTBXItem;
    ipmNextPic: TTBXItem;
    ipmPrevPic: TTBXItem;
    ipmSepClose: TTBXSeparatorItem;
    ipmSepZoom: TTBXSeparatorItem;
    iPrevPic: TTBXItem;
    iRefresh: TTBXItem;
    iRelocateInfo: TTBXItem;
    iRotate0: TTBXItem;
    iRotate180: TTBXItem;
    iRotate270: TTBXItem;
    iRotate90: TTBXItem;
    iSepCustomTools: TTBXSeparatorItem;
    iSepFileClose: TTBXSeparatorItem;
    iSepFileEdit: TTBXSeparatorItem;
    iSepFlipHorz: TTBXSeparatorItem;
    iSepFullScreen: TTBXSeparatorItem;
    iSepSlideShowBackward: TTBXSeparatorItem;
    iSepSlideShowCyclic: TTBXSeparatorItem;
    iSepSlideShowInterval: TTBXSeparatorItem;
    iSepStoreTransform: TTBXSeparatorItem;
    iSettings: TTBXItem;
    iShowInfo: TTBXItem;
    iSlideShow: TTBXItem;
    iSlideShowBackward: TTBXItem;
    iSlideShowCyclic: TTBXItem;
    iSlideShowForward: TTBXItem;
    iSlideShowRandom: TTBXItem;
    iStoreTransform: TTBXItem;
    iToggleMainMenu: TTBXVisibilityToggleItem;
    iToggleMainToolbar: TTBXVisibilityToggleItem;
    iToggleSlideShowToolbar: TTBXVisibilityToggleItem;
    iToggleToolsToolbar: TTBXVisibilityToggleItem;
    iToolsSep: TTBXSeparatorItem;
    iZoomActual: TTBXItem;
    iZoomFit: TTBXItem;
    iZoomIn: TTBXItem;
    iZoomOut: TTBXItem;
    pmMain: TTBXPopupMenu;
    smHelp: TTBXSubmenuItem;
    smPicture: TTBXSubmenuItem;
    smpmView: TTBXSubmenuItem;
    smSlideShow: TTBXSubmenuItem;
    smTools: TTBXSubmenuItem;
    smTransforms: TTBXSubmenuItem;
    smView: TTBXSubmenuItem;
    smZoom: TTBXSubmenuItem;
    tbgiTools: TTBGroupItem;
    tbgiZoom: TTBGroupItem;
    tbMain: TTBXToolbar;
    tbMainSepFullScreen: TTBXSeparatorItem;
    tbMainSepZoomIn: TTBXSeparatorItem;
    tbMenu: TTBXToolbar;
    tbSepClose: TTBXSeparatorItem;
    tbSepCounter: TTBXSeparatorItem;
    tbSepEdit: TTBXSeparatorItem;
    tbSlideShow: TTBXToolbar;
    tbTransforms: TTBXToolbar;
    procedure aaClose(Sender: TObject);
    procedure aaEdit(Sender: TObject);
    procedure aaFirstPic(Sender: TObject);
    procedure aaFlipHorz(Sender: TObject);
    procedure aaFlipVert(Sender: TObject);
    procedure aaFullScreen(Sender: TObject);
    procedure aaHelp(Sender: TObject);
    procedure aaLastPic(Sender: TObject);
    procedure aaNextPic(Sender: TObject);
    procedure aaPrevPic(Sender: TObject);
    procedure aaRefresh(Sender: TObject);
    procedure aaRelocateInfo(Sender: TObject);
    procedure aaRotate0(Sender: TObject);
    procedure aaRotate180(Sender: TObject);
    procedure aaRotate270(Sender: TObject);
    procedure aaRotate90(Sender: TObject);
    procedure aaSettings(Sender: TObject);
    procedure aaShowInfo(Sender: TObject);
    procedure aaSlideShow(Sender: TObject);
    procedure aaSlideShowBackward(Sender: TObject);
    procedure aaSlideShowCyclic(Sender: TObject);
    procedure aaSlideShowForward(Sender: TObject);
    procedure aaSlideShowRandom(Sender: TObject);
    procedure aaStoreTransform(Sender: TObject);
    procedure aaZoomActual(Sender: TObject);
    procedure aaZoomFit(Sender: TObject);
    procedure aaZoomIn(Sender: TObject);
    procedure aaZoomOut(Sender: TObject);
    procedure eSlideShowIntervalValueChange(Sender: TTBXCustomSpinEditItem; const AValue: Extended);
    procedure iMainDblClick(Sender: TObject);
    procedure iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure pmMainPopup(Sender: TObject);
    procedure tbMainVisibleChanged(Sender: TObject);
  private
     // True, ���� ����� ���������������� (��������������� ����� ����� ������)
    FInitialized: Boolean;
     // ����������
    FApp: IPhotoAlbumApp;
     // ������ ��������������� �����������. ����� ��-�� ����, ��� �������� ������ ����� �������� ��-�� ��������������
     //   ������� ����������� (��������, ��� ����������� �������������)
    FPics: IPhotoAlbumPicList;
     // ���������� ����������� � FPics
    FPicCount: Integer;
     // ����������������� �����
    FInitFlags: TImgViewInitFlags;
     // ����� ������� �������� ��������
    FDecodeThread: TDecodeThread;
     // ���� ����������� �������� �����������
    FForegroundLoading: Boolean;
     // ����������� ���������������� �����������
    FPredecodeDirection: TPredecodeDirection;
     // ����, �� ������� �������� ��������
    FDescLayer: TPositionedLayer;
     // ���� ����������� ����������
    FRBLayer: TRubberbandLayer;
     // ������� ������������ �����������
    FPic: IPhotoAlbumPic;
     // ���������� ������������� ������������� �����������, ��� ��� ����� � ��� ��������������
    FCachedBitmap: TBitmap32;
    FCachedBitmapFilename: WideString;
    FCachedRotation: TPicRotation;
    FCachedFlips: TPicFlips;
     // True, ���� ������ ������������� �����
    FCursorHidden: Boolean;
     // ���� � ��������� �������������� �����������
    FTrackDrag: Boolean;
    FTrackX: Integer;
    FTrackY: Integer;
     // ������� ��������������� ��������� �������� ���� (����  >0, �� ������/��������� ���� ���������������
     //   �������������)
    FResizeProcessingLock: Integer;
     // ������������ ��������� ���������
    FAlwaysOnTop: Boolean;
    FBackgroundColor: TColor;
    FCacheBehindPic: Boolean;
    FCaptionProps: TPicProperties;
    FCenterWindow: Boolean;
    FCyclicViewing: Boolean;
    FDoShrinkPic: Boolean;
    FDoZoomPic: Boolean;
    FFitWindowToPic: Boolean;
    FHideCursorInFS: Boolean;
    FInfoBkColor: TColor;
    FInfoBkOpacity: Byte;
    FInfoFont: WideString;
    FInfoProps: TPicProperties;
    FKeepCursorOverTB: Boolean;
    FPredecodePic: Boolean;
    FSlideShowInterval: Integer;
    FStretchFilter: TStretchFilter;
    FViewInfoPos: TRect;
    FZoomFactorChange: Single;
     // ����������� ���������� ������������ �������� ����������� �������� ������� ���������
    FBestFitZoomFactor: Single;
     // True, ���� � ��������� ��� ZoomFactor �������������� ������ BestFitZoomFactor
    FBestFitZoomUsed: Boolean;
     // ������������� ������� ������� (�� �� - ������������� ������������ �������� ����)
    FRectWorkArea: TRect;
     // ���������� ������� ����
    FWClient, FHClient: Integer;
     // ������� ����� ����������� � �������� ��������� ����
    FXGap, FYGap: Integer;
     // ������� ��������� � ����������������� �����������
    FWPic, FHPic: Integer;
    FWScaled, FHScaled: Integer;
     // �������� �����������
    FPicDesc: WideString;
     // ID ������� ������ ������� (0, ���� ������ �� ������)
    FTimerID: Integer;
     // ������ �������� ��� ������ ��������������/����������
    FUndoOperations: TPhoaOperations;
     // True, ���� ������� ����������� �� ������������ ��-�� ������
    FErroneous: Boolean;
     // ���� ����, ��� ��� ������� ����������� �����������
    FDisplayingPic: Boolean;
     // �������������� �����������
    FTransform: TPicTransform;
     // ������� ����� �������
    FColorMap: TColor32Map;
     // Prop storage
    FPicIdx: Integer;
    FShowInfo: Boolean;
    FSlideShow: Boolean;
    FSlideShowCyclic: Boolean;
    FSlideShowDirection: TSlideShowDirection;
     // ����������� ��������� ���� � ��������� ������� ��������� �����������. ��� bUseInitFlags ����� ���������
     //   FInitFlags
    procedure ApplySettings(bUseInitFlags: Boolean);
     // ����������� �����������
    procedure ApplyTools;
     // ����������� ��������� ������� ����
    procedure AdjustCursorVisibility(bForceShow: Boolean);
     // ��������� � ������������ �����������; ������������ ������������ ���������������.
     //   bReload ������������, ����������� �� ����������� �� �����
     //   bApplyTransforms ������������, ��������� �� �������������� � ����������� (��� bReload=True ��������������
     //     ����������� ������)
    procedure DisplayPic(bReload, bApplyTransforms: Boolean);
     // ����������� ������� �����������
    procedure RedisplayPic(bReload, bApplyTransforms: Boolean);
     // ���������� �� DisplayPic. ��������� ����������� � iMain
    procedure DP_LoadImage;
     // ���������� �� DisplayPic. ��������� �������������� � iMain
    procedure DP_ApplyTransforms;
     // ���������� �� DisplayPic. �������������� �������� ����������� (��������� ����, ����� ����������, �������)
    procedure DP_DescribePic;
     // ������ � ������� �� �������� ��������� �����������, ���� �����
    procedure DP_EnqueueNext;
     // ��������� ����������� ��������������� sgNewZoom, ������������ ���� ��� ������������� � bUserResize=False.
     //   bForceDefault   - ���� True, �� ���������� sgNewZoom, � ���������� ���, ������ �� �������� ������ ���������
     //   bPreserveCenter - ���� False, ������������� ������� ��������� � ����� �����������; ���� True, ���������
     //                     ��������� ��� ��
    procedure SetZoom(sgNewZoom: Single; bForceDefault, bUserResize, bPreserveCenter: Boolean);
     // ������� ��������������
    procedure TransformApplied(Sender: TObject);
     // ����������� aShowInfo.Checked
    procedure UpdateShowInfoActions;
     // ����������� �������� Checked ��� Actions ��������������
    procedure UpdateTransformActions;
     // ����������� ��������� Actions ������ �������
    procedure UpdateSlideShowActions;
     // ��������� Cursor ����������� � ������
    procedure UpdateCursor;
     // ���������/��������� Actions
    procedure EnableActions;
     // ���������� ��� ������� ������ ������ �������
    procedure RestartSlideShowTimer;
     // ��������� ���������� ��������/�������������� ����� TOPMOST ���� ���������, ���� �� ����
    procedure TopmostCancel;
    procedure TopmostRestore;
     // ������� ����� �� ������ �����������
    procedure ToolItemClick(Sender: TObject);
     // ������� ���� � ��������
    procedure DescLayerPaint(Sender: TObject; Buffer: TBitmap32);
    procedure RBLayerResizing(Sender: TObject; const OldLocation: TFloatRect; var NewLocation: TFloatRect; DragState: TDragState; Shift: TShiftState);
    procedure BitmapPixelCombine(F: TColor32; var B: TColor32; M: TColor32);
     // ���� ������� ����� ���������� ����������, ��������� ���
    procedure CommitInfoRelocation;
     // ���������/������ ���������� ��������� ��������� ������� ����
    procedure BeginForcedResize;
    procedure EndForcedResize;
     // Message handlers
    procedure WMDecodeFinished(var Msg: TMessage); message WM_DECODE_FINISHED;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
     // Prop handlers
    function  GetFullScreen: Boolean;
    function  GetViewOffset: TPoint;
    function  GetZoomFactor: Single;
    procedure SetFullScreen(Value: Boolean);
    procedure SetPicIdx(Value: Integer);
    procedure SetShowInfo(Value: Boolean);
    procedure SetSlideShow(Value: Boolean);
    procedure SetSlideShowCyclic(Value: Boolean);
    procedure SetSlideShowDirection(Value: TSlideShowDirection);
    procedure SetViewOffset(const Value: TPoint);
  protected
    function  DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function  DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function  GetRelativeRegistryKey: WideString; override;
    function  GetSizeable: Boolean; override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure DoHide; override;
    procedure DoShow; override;
    procedure ExecuteInitialize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure SettingsSave(rif: TRegIniFile); override;
    procedure SettingsLoad(rif: TRegIniFile); override;
  public
     // Props
     // -- True, ���� ������� ����� �������������� ���������
    property FullScreen: Boolean read GetFullScreen write SetFullScreen;
     // -- ������ �������� ����������� � ������
    property PicIdx: Integer read FPicIdx write SetPicIdx;
     // -- True, ���� � ������ ������ ���������� �� ����������� ������������
    property ShowInfo: Boolean read FShowInfo write SetShowInfo;
     // -- True, ���� ������� Slide Show
    property SlideShow: Boolean read FSlideShow write SetSlideShow;
     // -- True, ���� Slide Show ������������ ����������
    property SlideShowCyclic: Boolean read FSlideShowCyclic write SetSlideShowCyclic;
     // -- ����������� ������ �������
    property SlideShowDirection: TSlideShowDirection read FSlideShowDirection write SetSlideShowDirection;
     // -- �������� ������ �������� ���� ���������������� �����������
    property ViewOffset: TPoint read GetViewOffset write SetViewOffset;
     // -- ������� ���������������� �����������
    property ZoomFactor: Single read GetZoomFactor;
  end;

   // ������� � ����� ��������� �����������
   //   AInitFlags      - ����� ������������� ������ ���������
   //   AApp            - ����������
   //   iPicIdx         - ������ ����������� � ������, � �������� �������� ��������. � ���� �� ������������ ������
   //                     ���������� �������������� �����������
   //   AUndoOperations - ����� ������
  procedure ViewImage(AInitFlags: TImgViewInitFlags; AApp: IPhotoAlbumApp; var iPicIdx: Integer; AUndoOperations: TPhoaOperations);

implementation
{$R *.dfm}
uses
  udSettings, phUtils, udPicProps, phSettings, phToolSetting, Main;

  procedure ViewImage(AInitFlags: TImgViewInitFlags; AApp: IPhotoAlbumApp; var iPicIdx: Integer; AUndoOperations: TPhoaOperations);
  begin
    with TfImgView.Create(Application) do
      try
        FInitFlags      := AInitFlags;
        FApp            := AApp;
        FPicIdx         := iPicIdx;
        FUndoOperations := AUndoOperations;
        if ExecuteModal then iPicIdx := FPicIdx;
      finally
        if FCursorHidden then ShowCursor(True);
        Free;
      end;
  end;

   //===================================================================================================================
   // TDecodeThread
   //===================================================================================================================

  constructor TDecodeThread.Create(AOwner: TForm);
  begin
    inherited Create(True);
    FreeOnTerminate := True;
    Priority        := tpIdle;
    FOwner          := AOwner;
    FHQueuedEvent   := CreateEvent(nil, False, False, nil);
     // ������� ������������� ������ � ���������� ��������� - ��� ��������, ��� ����� ���������� ��������
    FHDecodedEvent  := CreateEvent(nil, True,  True,  nil);
    InitializeCriticalSection(FLoadAbortLock);
    Resume;
  end;

  destructor TDecodeThread.Destroy;
  begin
    FBitmap.Free;
    DeleteCriticalSection(FLoadAbortLock);
    CloseHandle(FHQueuedEvent);
    CloseHandle(FHDecodedEvent);
    inherited Destroy;
  end;

  procedure TDecodeThread.Execute;
  var ImgSize: TSize;
  begin
    while not Terminated do begin
      WaitForSingleObject(FHQueuedEvent, INFINITE);
      if Terminated then Break;
      try
         // ���������� ���� ���������� ��������
        EnterCriticalSection(FLoadAbortLock);
        try
          FLoadAborted := False;
        finally
          LeaveCriticalSection(FLoadAbortLock);
        end;
         // ����������� ������� �����������, ���� ��� ���� (�������� ����������������)
        FreeAndNil(FBitmap);
        FErrorMessage := '';
         // �������� ����� �����������, ������������� ��������� Exceptions
        try
          FBitmap := TBitmap32.Create;
           // �������� ��������� �����������
          if not FLoadAborted then LoadGraphicFromFile(FQueuedFileName, FBitmap, Size(0, 0), ImgSize, LoadProgress);
           // ���� �������� ���� ��������, ���������� �����������
          if FLoadAborted then FreeAndNil(FBitmap);
        except
          on e: Exception do begin
            FreeAndNil(FBitmap);
            FErrorMessage := e.Message;
          end;
        end;
       // ��������� � ����������
      finally
        SetEvent(FHDecodedEvent);
        PostMessage(FOwner.Handle, WM_DECODE_FINISHED, 0, 0);
      end;
    end;
  end;

  function TDecodeThread.GetAndReleasePicture: TBitmap32;
  begin
    Result := FBitmap;
    FBitmap := nil;
  end;

  function TDecodeThread.GetDecoding: Boolean;
  begin
    Result := WaitForSingleObject(FHDecodedEvent, 0)<>WAIT_OBJECT_0;
  end;

  procedure TDecodeThread.LoadProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
  begin
    if FLoadAborted then raise ELoadGraphicAborted.Create('Load graphic aborted');
  end;

  procedure TDecodeThread.SetQueuedFileName(const Value: WideString);
  begin
     // ���� ����� ��� �����, � ��������� ������ ����, ������� ���� ������ ��������
    if (FQueuedFileName<>Value) and Decoding then begin
      EnterCriticalSection(FLoadAbortLock);
      try
        FLoadAborted := True;
      finally
        LeaveCriticalSection(FLoadAbortLock);
      end;
    end;
     // ��� ������������ ������
    WaitForSingleObject(FHDecodedEvent, INFINITE);
     // ���� � ������� �������� ������ ����  
    if FQueuedFileName<>Value then begin
      FErrorMessage := '';
      FQueuedFileName := Value;
       // ���� ��� �� ������ ������� �������
      if FQueuedFileName<>'' then begin
         // ���������� ������� (�������� �����)
        ResetEvent(FHDecodedEvent);
         // �������� �����
        SetEvent(FHQueuedEvent);
      end;
    end;
  end;

  procedure TDecodeThread.Terminate;
  begin
    inherited Terminate;
    SetEvent(FHQueuedEvent);
  end;

   //===================================================================================================================
   // TfImgView
   //===================================================================================================================

  procedure TfImgView.aaClose(Sender: TObject);
  begin
    Close;
  end;

  procedure TfImgView.aaEdit(Sender: TObject);
  var
    Pics: IPhotoAlbumPicList;
    bEdited: Boolean;
  begin
    CommitInfoRelocation;
     // "�������" ���� � topmost-���������
    TopmostCancel;
     // ���������� ������
    AdjustCursorVisibility(True);
     // ����������� �����������
    Pics := NewPhotoAlbumPicList(False);
    Pics.Add(FPic, False);
    bEdited := EditPics(FApp, Pics, FUndoOperations);
     // ���������� topmost-��������� ����
    TopmostRestore;
     // �������� ������
    AdjustCursorVisibility(False);
     // ��������� �������� �����������
    if bEdited then RedisplayPic(False, True);
  end;

  procedure TfImgView.aaFirstPic(Sender: TObject);
  begin
    FPredecodeDirection := pddForward;
    PicIdx := 0;
  end;

  procedure TfImgView.aaFlipHorz(Sender: TObject);
  begin
    FTransform.ToggleFlip(pflHorz);
  end;

  procedure TfImgView.aaFlipVert(Sender: TObject);
  begin
    FTransform.ToggleFlip(pflVert);
  end;

  procedure TfImgView.aaFullScreen(Sender: TObject);
  begin
    CommitInfoRelocation;
     // ����������� �����
    FullScreen := not FullScreen;
     // ����������� ��������� �������
    AdjustCursorVisibility(False);
     // ����������� ��������
    RedisplayPic(False, False);
  end;

  procedure TfImgView.aaHelp(Sender: TObject);
  begin
    CommitInfoRelocation;
    Perform(WM_HELP, 0, 0);
  end;

  procedure TfImgView.aaLastPic(Sender: TObject);
  begin
    FPredecodeDirection := pddBackward;
    PicIdx := FPicCount-1;
  end;

  procedure TfImgView.aaNextPic(Sender: TObject);
  begin
    FPredecodeDirection := pddForward;
    if PicIdx<FPicCount-1 then PicIdx := PicIdx+1
    else if FCyclicViewing then PicIdx := 0;
  end;

  procedure TfImgView.aaPrevPic(Sender: TObject);
  begin
    FPredecodeDirection := pddBackward;
    if PicIdx>0 then PicIdx := PicIdx-1
    else if FCyclicViewing then PicIdx := FPicCount-1;
  end;

  procedure TfImgView.aaRefresh(Sender: TObject);
  begin
    RedisplayPic(True, True);
  end;

  procedure TfImgView.aaRelocateInfo(Sender: TObject);
  var fr: TFloatRect;
  begin
     // ����� ��������� - ������ RBLayer
    if FRBLayer=nil then begin
      FRBLayer := TRubberbandLayer.Create(iMain.Layers);
      FRBLayer.ChildLayer := FDescLayer;
      FRBLayer.OnResizing := RBLayerResizing;
     // ����� ������� - ��������� ������� RBLayer � ���������� ���
    end else begin
      fr := FRBLayer.GetAdjustedLocation;
      FViewInfoPos := Rect(
        Round(fr.Left/FWClient*10000),
        Round(fr.Top/FHClient*10000),
        Round(fr.Right/FWClient*10000),
        Round(fr.Bottom/FHClient*10000));
      SetSettingValueRect(ISettingID_Hidden_ViewInfoPos, FViewInfoPos);
      FreeAndNil(FRBLayer);
    end;
    aRelocateInfo.Checked := Assigned(FRBLayer);
  end;

  procedure TfImgView.aaRotate0(Sender: TObject);
  begin
    FTransform.Rotation := pr0;
  end;

  procedure TfImgView.aaRotate180(Sender: TObject);
  begin
    FTransform.Rotation := pr180;
  end;

  procedure TfImgView.aaRotate270(Sender: TObject);
  begin
    FTransform.Rotation := pr270;
  end;

  procedure TfImgView.aaRotate90(Sender: TObject);
  begin
    FTransform.Rotation := pr90;
  end;

  procedure TfImgView.aaSettings(Sender: TObject);
  var bEdited: Boolean;
  begin
    CommitInfoRelocation;
     // "�������" ���� � topmost-���������
    TopmostCancel;
     // ���������� ������
    AdjustCursorVisibility(True);
     // � ������� �������� �� ��������� �������� ������ "����� ���������"
    bEdited := EditSettings(ISettingID_View);
     // ���������� topmost-��������� ����
    TopmostRestore;
     // ��������� ���������
    if bEdited then begin
      fMain.ApplySettings;
      ApplySettings(False);
      RestartSlideShowTimer;
       // ����������� �����������
      RedisplayPic(False, False); 
    end else
      AdjustCursorVisibility(False);
  end;

  procedure TfImgView.aaShowInfo(Sender: TObject);
  begin
    ShowInfo := not ShowInfo;
  end;

  procedure TfImgView.aaSlideShow(Sender: TObject);
  begin
    SlideShow := not SlideShow;
  end;

  procedure TfImgView.aaSlideShowBackward(Sender: TObject);
  begin
    SlideShowDirection := ssdBackward;
  end;

  procedure TfImgView.aaSlideShowCyclic(Sender: TObject);
  begin
    SlideShowCyclic := not SlideShowCyclic;
  end;

  procedure TfImgView.aaSlideShowForward(Sender: TObject);
  begin
    SlideShowDirection := ssdForward;
  end;

  procedure TfImgView.aaSlideShowRandom(Sender: TObject);
  begin
    SlideShowDirection := ssdRandom;
  end;

  procedure TfImgView.aaStoreTransform(Sender: TObject);
  begin
    FApp.PerformOperation('StoreTransform', ['Pic', FPic, 'NewRotation', Byte(FTransform.Rotation), 'NewFlips', Byte(FTransform.Flips)]);
    EnableActions;
  end;

  procedure TfImgView.aaZoomActual(Sender: TObject);
  begin
    CommitInfoRelocation;
    SetZoom(1.0, False, False, True);
  end;

  procedure TfImgView.aaZoomFit(Sender: TObject);
  begin
    CommitInfoRelocation;
    SetZoom(0.0, False, False, True); // 0 �������� "best fit"
  end;

  procedure TfImgView.aaZoomIn(Sender: TObject);
  begin
    CommitInfoRelocation;
    SetZoom(ZoomFactor*FZoomFactorChange, False, False, True);
  end;

  procedure TfImgView.aaZoomOut(Sender: TObject);
  begin
    CommitInfoRelocation;
    SetZoom(ZoomFactor/FZoomFactorChange, False, False, True);
  end;

  procedure TfImgView.AdjustCursorVisibility(bForceShow: Boolean);
  begin
    if (FHideCursorInFS and FullScreen and not bForceShow)<>FCursorHidden then begin
      FCursorHidden := not FCursorHidden;
      ShowCursor(not FCursorHidden);
    end;
  end;

  procedure TfImgView.ApplySettings(bUseInitFlags: Boolean);
  var bFullScreen: Boolean;
  begin
    BeginForcedResize;
    try
       // �������� �������� ��������
      FBackgroundColor    := SettingValueInt(ISettingID_View_BkColor);
      FZoomFactorChange   := adMagnifications[SettingValueInt(ISettingID_View_ZoomFactor)];
      FCaptionProps       := IntToPicProps(SettingValueInt(ISettingID_View_CaptionProps));
      FDoShrinkPic        := SettingValueBool(ISettingID_View_ShrinkPicToFit);
      FDoZoomPic          := SettingValueBool(ISettingID_View_ZoomPicToFit);
      bFullscreen         := SettingValueBool(ISettingID_View_Fullscreen);
      FAlwaysOnTop        := SettingValueBool(ISettingID_View_AlwaysOnTop);
      FKeepCursorOverTB   := SettingValueBool(ISettingID_View_KeepCursorOverTB);
      FHideCursorInFS     := SettingValueBool(ISettingID_View_HideCursor);
      FFitWindowToPic     := SettingValueBool(ISettingID_View_FitWindowToPic);
      FCenterWindow       := SettingValueBool(ISettingID_View_CenterWindow);
      FCyclicViewing      := SettingValueBool(ISettingID_View_Cyclic);
      FPredecodePic       := SettingValueBool(ISettingID_View_Predecode);
      FCacheBehindPic     := SettingValueBool(ISettingID_View_CacheBehind);
      FStretchFilter      := TStretchFilter(SettingValueInt(ISettingID_View_StchFilt));
      FSlideShowInterval  := SettingValueInt(ISettingID_View_SlideInterval);
      FSlideShowDirection := TSlideShowDirection(SettingValueInt(ISettingID_View_SlideDirection));
      FSlideShowCyclic    := SettingValueBool(ISettingID_View_SlideCyclic);
      FShowInfo           := SettingValueBool(ISettingID_View_ShowInfo);
      FInfoProps          := IntToPicProps(SettingValueInt(ISettingID_View_InfoPicProps));
      FInfoFont           := SettingValueStr(ISettingID_View_InfoFont);
      FInfoBkColor        := SettingValueInt(ISettingID_View_InfoBkColor);
      FInfoBkOpacity      := SettingValueInt(ISettingID_View_InfoBkOpacity);
      FViewInfoPos        := SettingValueRect(ISettingID_Hidden_ViewInfoPos);
       // ����������� ��������� ����
      FontFromStr(Font, SettingValueStr(ISettingID_Gen_MainFont));
      Color               := FBackgroundColor;
       // ����������� ����/������ ������������
       // -- ���������
      tbMain.Visible      := SettingValueBool(ISettingID_View_ShowToolbar);
       // -- �����������������
      ApplyToolbarSettings(dkTop);
      ApplyToolbarSettings(dkLeft);
      ApplyToolbarSettings(dkRight);
      ApplyToolbarSettings(dkBottom);
       // ����������� �����������
      ApplyTools;
       // ����������� ��������� ������� ������
      if bUseInitFlags then bFullscreen := (bFullscreen or (ivifForceFullscreen in FInitFlags)) and not (ivifForceWindow in FInitFlags);
      FullScreen := bFullScreen;
       // ���� ����� �������� ����� ������ �������, ���������� ��� �������������
      if bUseInitFlags and (ivifSlideShow in FInitFlags) then SlideShow := True;
       // ����������� ��������� �������
      AdjustCursorVisibility(False);
       // ��������� actions
      UpdateShowInfoActions;
      UpdateSlideShowActions;
    finally
      EndForcedResize;
    end;
  end;

  procedure TfImgView.ApplyTools;
  var
    i: Integer;
    Tool: TPhoaToolSetting;
  begin
     // �� �������
    gipmTools.Clear;
     // ��������� �����������
    for i := 0 to RootSetting.Settings[ISettingID_Tools].ChildCount-1 do begin
      Tool := RootSetting.Settings[ISettingID_Tools].Children[i] as TPhoaToolSetting;
      if ptuViewModePopupMenu in Tool.Usages then AddToolItem(Tool, gipmTools, ToolItemClick);
    end;
  end;

  procedure TfImgView.BeginForcedResize;
  begin
    Inc(FResizeProcessingLock);
  end;

  procedure TfImgView.BitmapPixelCombine(F: TColor32; var B: TColor32; M: TColor32);
  begin
    B := FColorMap.ApplyToColor(F);
  end;

  procedure TfImgView.CommitInfoRelocation;
  begin
    if FRBLayer<>nil then aRelocateInfo.Execute;
  end;

  procedure TfImgView.DescLayerPaint(Sender: TObject; Buffer: TBitmap32);
  var r: TRect;
  begin
     // ���� ���� ���������� �������� � ��� ����
    if FShowInfo and (FPicDesc<>'') then begin
      r := MakeRect(FDescLayer.GetAdjustedLocation);
      FontFromStr(Buffer.Font, FInfoFont);
      Buffer.FillRectTS(r, (Color32(FInfoBkColor) and $00ffffff) or (Cardinal(FInfoBkOpacity) shl 24));
      Buffer.Textout(r, DT_CENTER or DT_VCENTER or DT_WORDBREAK or DT_NOPREFIX, FPicDesc);
    end;
  end;

  procedure TfImgView.DisplayPic(bReload, bApplyTransforms: Boolean);
  begin
    if FDisplayingPic then Exit;
    CommitInfoRelocation;
    FTrackDrag := False;
    FDisplayingPic := True;
    try
       // ��������� �����������
      if bReload then DP_LoadImage;
       // ��������� �������������� � �����������
      if bReload or bApplyTransforms then DP_ApplyTransforms;
       // ����������� ��������
      DP_DescribePic;
       // ���������� �������� (��� ����������/���������� �������������� ����� ������� ��������� �� ���������)
      SetZoom(0.0, True, False, not (bReload or bApplyTransforms));
       // ������ � ������� ����������/��������� (������� �� ����������� ��������) �����������
      DP_EnqueueNext;
    finally
      FDisplayingPic := False;
    end;
     // ������������� ������
    RestartSlideShowTimer;
  end;

  procedure TfImgView.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
  begin
     // ��� ������� Ctrl ������ ������������ ���������� Shell Context Menu ��� �������� �����
    if GetKeyState(VK_CONTROL) and $80<>0 then begin
      if not FErroneous then ShowFileShellContextMenu(FPic.FileName);
      Handled := True;
    end else
      inherited DoContextPopup(MousePos, Handled);
  end;

  procedure TfImgView.DoCreate;
  begin
    inherited DoCreate;
    HelpContext := IDH_intf_view_mode;
     // ������ ����� ��������
    FDecodeThread := TDecodeThread.Create(Self);
     // ������ ���� ��� ��������� ��������
    FDescLayer := TPositionedLayer.Create(iMain.Layers);
    FDescLayer.OnPaint := DescLayerPaint;
     // ������ ��������������
    FTransform := TPicTransform.Create(iMain.Bitmap);
    FTransform.OnApplied := TransformApplied;
     // ������ ����� ������
    FColorMap := TColor32Map.Create;
     // ������ ������ �����������
    FPics := NewPhotoAlbumPicList(False);
  end;
 
  procedure TfImgView.DoDestroy;
  begin
     // ���������� �������
    FPics := nil;
    FColorMap.Free;
    FTransform.Free;
     // ���������� ������� ����� � ������������� �����������
    FDecodeThread.Terminate;
     // ���������� ������ ��������
    if FTimerID<>0 then KillTimer(Handle, FTimerID);
     // ���������� ���
    FCachedBitmap.Free;
    inherited DoDestroy;
  end;

  procedure TfImgView.DoHide;
  begin
    CommitInfoRelocation;
    inherited DoHide;
  end;

  function TfImgView.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
  begin
    inherited DoMouseWheelDown(Shift, MousePos);
    if ssCtrl in Shift then aZoomOut.Execute else aNextPic.Execute;
    Result := True;
  end;

  function TfImgView.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
  begin
    inherited DoMouseWheelUp(Shift, MousePos);
    if ssCtrl in Shift then aZoomIn.Execute else aPrevPic.Execute;
    Result := True;
  end;

  procedure TfImgView.DoShow;
  begin
    inherited DoShow;
     // ��������� �����������
    if not FInitialized then begin
      RedisplayPic(True, False);
      FInitialized := True;
    end;
  end;

  procedure TfImgView.DP_ApplyTransforms;
  begin
     // ��������� �� ������ �� ���������������
    if not FErroneous then FTransform.ApplyValues(FPic.Rotation, FPic.Flips);
  end;

  procedure TfImgView.DP_DescribePic;
  var wsCaption: WideString;
  begin
     // ����������� Caption / ���������� ��������
   if FErroneous then begin
      wsCaption := '';
      FPicDesc  := '';
    end else begin
      wsCaption := GetPicPropStrs(FPic, FCaptionProps, '', ' - ');
      FPicDesc  := GetPicPropStrs(FPic, FInfoProps,    '', '    ');
    end;
    if wsCaption='' then Caption := DKLangConstW('SImgView_DefaultCaption') else Caption := wsCaption;
     // ����������� �������
    eCounter.Text := WideFormat('%d/%d', [FPicIdx+1, FPicCount]);
  end;

  procedure TfImgView.DP_EnqueueNext;
  var idxNextPic: Integer;
  begin
     // ���� �������� ���������������� 
    if FPredecodePic and (FPredecodeDirection<>pddDisabled) then begin
       // ������� ������ ���������� ����������� � ������ ����������� ��������
      idxNextPic := FPicIdx+iif(FPredecodeDirection=pddBackward, -1, 1);
       // ��������� ������� / ����������� ���������
      if idxNextPic<0 then
        if FCyclicViewing then idxNextPic := FPicCount-1 else idxNextPic := -1
      else if idxNextPic>=FPicCount then
        if FCyclicViewing then idxNextPic := 0 else idxNextPic := -1;
       // ������ ���� � ������� 
      if idxNextPic>=0 then begin
        FDecodeThread.QueuedFileName := FPics[idxNextPic].FileName;
        UpdateCursor;
      end;
    end;
  end;

  procedure TfImgView.DP_LoadImage;
  var
    PrevPic: IPhoaPic;
    PrevRotation: TPicRotation;
    PrevFlips: TPicFlips;
    bmpDecoded, bmpPrevTemp: TBitmap32;
    bPicInCache: Boolean;

     // ������ �� iMain ������ ����������� ��������� �� ������
    procedure PaintError(const wsFileName, wsError: WideString);
    var
      r: TRect;
      wsTitle: WideString;
      Sz: TSize;
    begin
      wsTitle := DKLangConstW('SImgView_ErrorMsg');
      with iMain.Bitmap do begin
         // ������� Bitmap
        Width  := 500;
        Height := 300;
        Clear(FBackgroundColor);
         // ������ ����� 'ERROR'
        Font.Assign(Self.Font);
        Font.Color := $2020c0;
        Font.Size  := 72;
        Font.Style := [fsBold];
        Sz := TextExtent(wsTitle); {??? Unicode support}
        r := Rect((Width-Sz.cx) div 2, (Height-Sz.cy) div 2, (Width+Sz.cx) div 2, (Height+Sz.cy) div 2);
        TextOut(r, DT_LEFT or DT_NOPREFIX, wsTitle); {??? Unicode support}
         // ������ ��� �����
        Font.Color := clRed;
        Font.Size  := 9;
        Font.Style := [];
        TextOut(Rect(0, 0, Width, r.Top), DT_CENTER or DT_NOPREFIX or DT_SINGLELINE or DT_BOTTOM or DT_PATH_ELLIPSIS, sFileName);
         // ������ ����� ������
        TextOut(Rect(0, r.Bottom, Width, Height), DT_CENTER or DT_NOPREFIX or DT_WORDBREAK, sError);
      end;
    end;

  begin
     // ��������� ������� �����������
    PrevPic := FPic;
     // ������� ������� �����������
    FPic := FPics[FPicIdx];
     // ����������, ���� �� ����������� � ����
    bPicInCache := FCachedBitmapFilename=FPic.FileName;
     // ���� ���, �������� [����]������� �������� �����������
    if not bPicInCache then FDecodeThread.QueuedFileName := FPic.FileName;
     // ���� ����������� �� ���������, ��������� ������ ����������� � ��������������
    if not FErroneous and FCacheBehindPic and (PrevPic<>nil) and (PrevPic<>FPic) then begin
      bmpPrevTemp := TBitmap32.Create;
      bmpPrevTemp.Assign(iMain.Bitmap);
      PrevRotation := FTransform.Rotation;
      PrevFlips    := FTransform.Flips;
    end else begin
      bmpPrevTemp  := nil;
      PrevRotation := pr0;;
      PrevFlips    := [];
    end;
     // ���� ����������� �����������, �������� ��� � ��������� ���������� ��������������
    if bPicInCache then begin
      try
        iMain.Bitmap.Assign(FCachedBitmap);
      except
        bmpPrevTemp.Free;
        raise;
      end;
      FTransform.InitValues(FCachedRotation, FCachedFlips);
     // ����� ���������� ������� ��������� ��������������
    end else
      FTransform.InitValues(pr0, []);
     // ����������� ��� � ��������� � ���� ������ ����������� � ��������������
    FCachedBitmap.Free;
    FCachedBitmap   := bmpPrevTemp;
    FCachedRotation := PrevRotation;
    FCachedFlips    := PrevFlips;
    if bmpPrevTemp=nil then FCachedBitmapFilename := '' else FCachedBitmapFilename := PrevPic.FileName;
     // ���� �� ����� �� ����, ���������� ��������� �������� ����������� ������� �������
    if not bPicInCache then begin
      FForegroundLoading := True;
      UpdateCursor;
      try
        WaitForSingleObject(FDecodeThread.HDecodedEvent, INFINITE);
        bmpDecoded := FDecodeThread.GetAndReleasePicture;
         // ���� ����� ������ nil - ������, ��������� ������
        FErroneous := bmpDecoded=nil;
        if FErroneous then
          PaintError(FPic.FileName, FDecodeThread.ErrorMessage)
        else
          try
            iMain.Bitmap.Assign(bmpDecoded);
          finally
            bmpDecoded.Free;
          end;
      finally
        FForegroundLoading := False;
        UpdateCursor;
      end;
    end;
     // ����������� ������ �����������
    iMain.Bitmap.StretchFilter := FStretchFilter;
     //#TODO: ��������� ����� ����� ��� histogram adjustment
    iMain.Bitmap.DrawMode := dmCustom;
    iMain.Bitmap.OnPixelCombine := BitmapPixelCombine;
  end;

  procedure TfImgView.EnableActions;
  var bNoErr: Boolean;
  begin
    bNoErr := not FErroneous;
    aLastPic.Enabled        := FPicIdx<FPicCount-1;
    aFirstPic.Enabled       := FPicIdx>0;
    aNextPic.Enabled        := (FPicCount>1) and (FCyclicViewing or aLastPic.Enabled);
    aPrevPic.Enabled        := (FPicCount>1) and (FCyclicViewing or aFirstPic.Enabled);
    aZoomIn.Enabled         := bNoErr and (ZoomFactor<SMaxPicZoom);
    aZoomOut.Enabled        := bNoErr and (ZoomFactor>SMinPicZoom);
    aZoomFit.Enabled        := bNoErr and (ZoomFactor<>FBestFitZoomFactor);
    aZoomActual.Enabled     := bNoErr and (ZoomFactor<>1.0);
    aRotate90.Enabled       := bNoErr;
    aRotate180.Enabled      := bNoErr;
    aRotate270.Enabled      := bNoErr;
    aFlipHorz.Enabled       := bNoErr;
    aFlipVert.Enabled       := bNoErr;
    aStoreTransform.Enabled := bNoErr and ((FPic.Rotation<>FTransform.Rotation) or (FPic.Flips<>FTransform.Flips));
  end;

  procedure TfImgView.EndForcedResize;
  begin
    if FResizeProcessingLock>0 then begin
       // ���� ���������� ����� �����, ���������� ��� ��������� ��������� �������
      if FResizeProcessingLock=1 then Application.ProcessMessages;
      Dec(FResizeProcessingLock);
    end;
  end;

  procedure TfImgView.eSlideShowIntervalValueChange(Sender: TTBXCustomSpinEditItem; const AValue: Extended);
  begin
    FSlideShowInterval := Trunc(AValue*1000);
    RestartSlideShowTimer;
  end;

  procedure TfImgView.ExecuteInitialize;
  begin
    inherited ExecuteInitialize;
     // �������� ������ ���������� � ���������� 
    FPics.Assign(FApp.ViewedPics);
    FPicCount := FPics.Count;
     // ��������� ���������. ��� ������ �� ����� ����, ������� ������ ��� �� ��� �����������
    ApplySettings(True);
  end;

  function TfImgView.GetFullScreen: Boolean;
  begin
    Result := aFullScreen.Checked;
  end;

  function TfImgView.GetRelativeRegistryKey: WideString;
  begin
    Result := SRegViewWindow_Root;
  end;

  function TfImgView.GetSizeable: Boolean;
  begin
    Result := True;
  end;

  function TfImgView.GetViewOffset: TPoint;
  begin
    Result := Point(Trunc(iMain.OffsetHorz), Trunc(iMain.OffsetVert));
  end;

  function TfImgView.GetZoomFactor: Single;
  begin
    Result := iMain.Scale;
  end;

  procedure TfImgView.iMainDblClick(Sender: TObject);
  begin
    HasUpdates := True;
    aClose.Execute;
  end;

  procedure TfImgView.iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
     // ��� ����� �� RBLayer �������, ����� �� ������ dragging, ��� ����� ������� ��������� ����� ����������
    if (FRBLayer<>nil) and FRBLayer.HitTest(x, y) then Exit;
    CommitInfoRelocation;
    case Button of
      mbLeft:
        if (FWScaled>FWClient) or (FHScaled>FHClient) then begin
          FTrackDrag := True;
          FTrackX := ViewOffset.x-x;
          FTrackY := ViewOffset.y-y;
          UpdateCursor;
        end;
      mbMiddle: aFullScreen.Execute;
    end;
  end;

  procedure TfImgView.iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if FTrackDrag then ViewOffset := Point(x+FTrackX, y+FTrackY);
  end;

  procedure TfImgView.iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
  begin
    if FTrackDrag then begin
      FTrackDrag := False;
       // ���������� ������� ������
      UpdateCursor;
    end;
  end;

  procedure TfImgView.KeyDown(var Key: Word; Shift: TShiftState);
  var
    pTmpOffs: TPoint;
    iStep: Integer;
  begin
    pTmpOffs := ViewOffset;
    iStep := iif(ssCtrl in Shift, IKeyQuickScrollStep, iif(ssShift in Shift, IKeySlowScrollStep, IKeyScrollStep));
    case Key of
      VK_LEFT:  Inc(pTmpOffs.x, iStep);
      VK_RIGHT: Dec(pTmpOffs.x, iStep);
      VK_UP:    Inc(pTmpOffs.y, iStep);
      VK_DOWN:  Dec(pTmpOffs.y, iStep);
      VK_PAUSE: begin
        aSlideShow.Execute;
        Exit;
      end;
      else begin
        inherited KeyDown(Key, Shift);
        Exit;
      end;
    end;
    ViewOffset := pTmpOffs;
  end;

  procedure TfImgView.KeyPress(var Key: Char);
  begin
    case Key of
      #8:  aPrevPic.Execute;
      #13: begin
        HasUpdates := True;
        aClose.Execute;
      end;
      '+': aZoomIn.Execute;
      '-': aZoomOut.Execute;
      '*': aZoomFit.Execute;
      '/': aZoomActual.Execute;
      ' ': aNextPic.Execute;
      else inherited KeyPress(Key);
    end;
  end;

  procedure TfImgView.pmMainPopup(Sender: TObject);
  var Pics: IPhoaMutablePicList;
  begin
     // ����������� ����������� ������������ � pmMain
    if gipmTools.Count>0 then begin
       // ��������� ��������������� �����������
      Pics := NewPhotoAlbumPicList(False);
      if not FErroneous then Pics.Add(FPic, False);
      AdjustToolAvailability(RootSetting.Settings[ISettingID_Tools] as TPhoaToolPageSetting, gipmTools, Pics);
    end;
  end;

  procedure TfImgView.RBLayerResizing(Sender: TObject; const OldLocation: TFloatRect; var NewLocation: TFloatRect; DragState: TDragState; Shift: TShiftState);
  var sw, sh: Single;
  begin
    with NewLocation do begin
      sw := MinS(Right-Left, FWClient);
      sh := MinS(Bottom-Top, FHClient);
      Left   := MinS(MaxS(0, Left), FWClient-sw);
      Top    := MinS(MaxS(0, Top),  FHClient-sh);
      Right  := MaxS(MinS(FWClient, Right),  sw);
      Bottom := MaxS(MinS(FHClient, Bottom), sh);
    end;
  end;

  procedure TfImgView.RedisplayPic(bReload, bApplyTransforms: Boolean);
  begin
     // ������� ������� (����� ����� ����� ���������� ����������� �����)
    if bReload then FDecodeThread.QueuedFileName := '';
     // ����� ���������� �����������
    DisplayPic(bReload, bApplyTransforms);
  end;

  procedure TfImgView.RestartSlideShowTimer;
  begin
    if FTimerID<>0 then KillTimer(Handle, FTimerID);
    if FSlideShow then FTimerID := SetTimer(Handle, ISlideShowTimerID, FSlideShowInterval, nil) else FTimerID := 0;
  end;

  procedure TfImgView.SetFullScreen(Value: Boolean);
  const
    aFS: Array[Boolean] of TFormStyle       = (fsNormal,   fsStayOnTop);
    aWS: Array[Boolean] of TWindowState     = (wsNormal,   wsMaximized);
    aBS: Array[Boolean] of TFormBorderStyle = (bsSizeable, bsNone);
  var
    rSavedBounds: TRect;
    bWasVisible: Boolean;
  begin
    BeginForcedResize;
    try
       // �������� ����
      bWasVisible := Visible;
      Hide;
       // ����������� Action
      aFullScreen.Checked := Value;
       // ��������� ������� ����
      rSavedBounds := BoundsRect;
       // ����������� ����� AlwaysOnTop
      FormStyle    := aFS[FAlwaysOnTop and not Value];
       // ����������� BorderStyle
      BorderStyle  := aBS[Value];
       // ��������������� ��������� ���� (��������� BorderStyle ������ ���)
      BoundsRect   := rSavedBounds;
       // ���������� ����
      if bWasVisible then Show;
       // ����������� ��������� ���� (����� Show, �.�. ����� ���� ����� ������������ WindowState ���������� ������� ���
       //   ��������)
      WindowState  := aWS[Value];
    finally
      EndForcedResize;
    end;
  end;

  procedure TfImgView.SetPicIdx(Value: Integer);
  begin
    if (FPicIdx<>Value) and (Value>=0) and (Value<FPicCount) then begin
      FPicIdx := Value;
      DisplayPic(True, True);
    end;
  end;

  procedure TfImgView.SetShowInfo(Value: Boolean);
  begin
    if FShowInfo<>Value then begin
      CommitInfoRelocation;
      FShowInfo := Value;
       // �������������� ��������
      iMain.Invalidate;
      UpdateShowInfoActions;
    end;
  end;

  procedure TfImgView.SetSlideShow(Value: Boolean);
  begin
    if FSlideShow<>Value then begin
      CommitInfoRelocation;
      FSlideShow := Value;
      if Value then Randomize;
      RestartSlideShowTimer;
      UpdateSlideShowActions;
    end;
  end;

  procedure TfImgView.SetSlideShowCyclic(Value: Boolean);
  begin
    if FSlideShowCyclic<>Value then begin
      FSlideShowCyclic := Value;
      UpdateSlideShowActions;
    end;
  end;

  procedure TfImgView.SetSlideShowDirection(Value: TSlideShowDirection);
  begin
    if FSlideShowDirection<>Value then begin
      FSlideShowDirection := Value;
      UpdateSlideShowActions;
    end;
  end;

  procedure TfImgView.SettingsLoad(rif: TRegIniFile);
  begin
    inherited SettingsLoad(rif);
     // ��������������� ��������� � ��������� ������� ������������
    TBRegLoadPositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegViewWindow_Toolbars);
  end;

  procedure TfImgView.SettingsSave(rif: TRegIniFile);
  begin
    inherited SettingsSave(rif);
     // ��������� ��������� � ��������� ������� ������������
    TBRegSavePositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegViewWindow_Toolbars);
  end;

  procedure TfImgView.SetViewOffset(const Value: TPoint);
  var ix, iy: Integer;
  begin
    CommitInfoRelocation;
    if FWScaled>FWClient then ix := Min(0, Max(Value.x, FWClient-FWScaled)) else ix := (FWClient-FWScaled) div 2;
    if FHScaled>FHClient then iy := Min(0, Max(Value.y, FHClient-FHScaled)) else iy := (FHClient-FHScaled) div 2;
    iMain.OffsetHorz := ix;
    iMain.OffsetVert := iy;
  end;

  procedure TfImgView.SetZoom(sgNewZoom: Single; bForceDefault, bUserResize, bPreserveCenter: Boolean);
  var
    ixWindow, iyWindow, iwWindow, ihWindow: Integer;
    PrevMousePos, p: TPoint;
    sgXRelativeCenter, sgYRelativeCenter: Single;

     // ������������ ������� ������� �������, ������� ���� � FBestFitZoomFactor
    procedure ComputeViewportDimensions;
    var
      MaxViewportSize: TSize;
      CurMonitor: TMonitor;
    begin
       // ���������� ������������ ������� ����. � ������������� ������ ���� ����� �������� ���� ���� �������. � �������
       //   ������ ���� ����� �������� ������ ������� ������� ������ �������� (��������� ������� �� �����������, � ��
       //   ���������� �������� Monitor �����, �.�. ��� ���������� �� ��� �������, ��� ��� �����)
      CurMonitor := Screen.MonitorFromRect(BoundsRect, mdNearest);
      if FullScreen then FRectWorkArea := CurMonitor.BoundsRect else FRectWorkArea := CurMonitor.WorkareaRect;
       // ������� "������" - ������� ����� ��������� ���� � ��������� �����������
      FXGap := Width-iMain.Width;
      FYGap := Height-iMain.Height;
       // �������� ������� ����������� (�� ��������� ������� ��������)
      FWPic := Max(iMain.Bitmap.Width,  1);
      FHPic := Max(iMain.Bitmap.Height, 1);
       // ���������� "���������" ����������� ���������������
       // -- � ������������� ������ ��� ����� ��������� �������� �������� ���� ��� ������� �����������, � ��� ��
       //    ��������� �������� �������������, ������� �� ������������ �������� ������� �������
      if FullScreen or (FFitWindowToPic and not bUserResize) then begin
        MaxViewportSize.cx := FRectWorkArea.Right-FRectWorkArea.Left-FXGap;
        MaxViewportSize.cy := FRectWorkArea.Bottom-FRectWorkArea.Top-FYGap;
       // -- � ��������� ������ ������ ���� ������ ������, ������� �� ���
      end else begin
        MaxViewportSize.cx := iMain.Width;
        MaxViewportSize.cy := iMain.Height;
      end;
       // -- ������������ ����������� - ��� ����������� �������� �� �������� ������������ �� ������ ��� �� ������. �����
       //    ��������� ����� ����������� ������� ���� (Constraints)
      FBestFitZoomFactor := MinS(
        Max(MaxViewportSize.cx, Constraints.MinWidth -FXGap)/FWPic,
        Max(MaxViewportSize.cy, Constraints.MinHeight-FYGap)/FHPic);
    end;

  begin
    iMain.Perform(WM_SETREDRAW, 0, 0);
    try
       // ���������� ������������� ���������� viewport-������ (� ��������� 0..1, ������������ �������� �����������)
      if bPreserveCenter and (FWScaled>0) and (FHScaled>0) then begin
        sgXRelativeCenter := (FWClient/2-ViewOffset.x)/FWScaled;
        sgYRelativeCenter := (FHClient/2-ViewOffset.y)/FHScaled;
      end else begin
        sgXRelativeCenter := 0.5;
        sgYRelativeCenter := 0.5;
      end;
       // ������������� ������� � FBestFitZoomFactor
      ComputeViewportDimensions;
       // ��������� �� ������ �� ������������
      if FErroneous then
        sgNewZoom := 1.0
      else begin
         // ���� ����� ��������������� ������������� �������� �� ���������, ���������� ���������� sgNewZoom � ������������
         //   �����, ������ �� ������� ��������
        if bForceDefault then
          sgNewZoom := iif(((FBestFitZoomFactor<1.0) and FDoShrinkPic) or ((FBestFitZoomFactor>1.0) and FDoZoomPic), 0.0, 1.0);
         // ���� ������� 0, �� ��� ��������, ��� ����� ������������ FBestFitZoomFactor
        if sgNewZoom=0.0 then sgNewZoom := FBestFitZoomFactor;
         // Validate zoom value
        if sgNewZoom>SMaxPicZoom then sgNewZoom := SMaxPicZoom
        else if sgNewZoom<SMinPicZoom then sgNewZoom := SMinPicZoom;
         // ���� ��� �� ��������� �������� �������������, ����������, ���� ��������� BestFitZoom
        if not bUserResize then FBestFitZoomUsed := sgNewZoom=FBestFitZoomFactor;
      end;
       // ��������� ����������� ���������������
      iMain.Scale := sgNewZoom;
       // ������� ������� ����������������� �����������
      FWScaled := Round(FWPic*sgNewZoom);
      FHScaled := Round(FHPic*sgNewZoom);
       // ������� ������� � ��������� ���� (������������� ���� ������ ���� ��� �� ��������� �������� ������������� �
       //   ���� �� ���������������)
      ixWindow := Left;
      iyWindow := Top;
      iwWindow := Width;
      ihWindow := Height;
      if not bUserResize and (FullScreen or (WindowState<>wsMaximized)) then begin
         // ������� ����
        if FullScreen then begin
          iwWindow := FRectWorkArea.Right-FRectWorkArea.Left;
          ihWindow := FRectWorkArea.Bottom-FRectWorkArea.Top;
        end else if FFitWindowToPic then begin
          iwWindow := Max(Min(FWScaled+FXGap, FRectWorkArea.Right-FRectWorkArea.Left), Constraints.MinWidth);
          ihWindow := Max(Min(FHScaled+FYGap, FRectWorkArea.Bottom-FRectWorkArea.Top), Constraints.MinHeight);
        end;
         // ��������� ����
        if FullScreen then begin
          ixWindow := FRectWorkArea.Left;
          iyWindow := FRectWorkArea.Top;
        end else if FCenterWindow then begin
          ixWindow := (FRectWorkArea.Left+FRectWorkArea.Right-iwWindow) div 2;
          iyWindow := (FRectWorkArea.Top+FRectWorkArea.Bottom-ihWindow) div 2;
        end;
         // ���� �����, ��������� ��������� ������� ���� ��� ������� ������������
        PrevMousePos := Point(-1, -1);
        if FKeepCursorOverTB and not FullScreen and Application.Active and tbMain.Visible then begin
          p := tbMain.ScreenToClient(Mouse.CursorPos);
          if (p.x<tbMain.Width) and (p.y<tbMain.Height) then PrevMousePos := p;
        end;
         // �������� ��������� ����
        BeginForcedResize;
        try
          SetBounds(ixWindow, iyWindow, iwWindow, ihWindow);
        finally
          EndForcedResize;
        end;
         // ��������������� ��������� ����
        if (PrevMousePos.x>=0) and (PrevMousePos.y>=0) and (PrevMousePos.x<tbMain.Width) and (PrevMousePos.y<tbMain.Height) then
          Mouse.CursorPos := tbMain.ClientToScreen(PrevMousePos);
      end;
       // ������� ���������� �������
      FWClient := iwWindow-FXGap;
      FHClient := ihWindow-FYGap;
       // ����������� ������
      UpdateCursor;
       // ������� ��������� ��������� �����������
      ViewOffset := Point(Trunc(FWClient/2-sgXRelativeCenter*FWScaled), Trunc(FHClient/2-sgYRelativeCenter*FHScaled));
       // ����������� ��������� ����������
      FDescLayer.Location := FloatRect(
        FWClient/10000*FViewInfoPos.Left,
        FHClient/10000*FViewInfoPos.Top,
        FWClient/10000*FViewInfoPos.Right,
        FHClient/10000*FViewInfoPos.Bottom);
    finally
      iMain.Perform(WM_SETREDRAW, 1, 0);
      iMain.Refresh;
    end;
     // ����������� Actions (ZoomFactor � ������� ������ �������� ������ �� ���)
    EnableActions;
  end;

  procedure TfImgView.tbMainVisibleChanged(Sender: TObject);
  begin
    SetSettingValueBool(ISettingID_View_ShowToolbar, tbMain.Visible);
  end;

  procedure TfImgView.ToolItemClick(Sender: TObject);
  var Pics: IPhoaMutablePicList;
  begin
    if not FErroneous then begin
       // ������ ������ ������ �� �����������
      Pics := NewPhotoAlbumPicList(True);
       // ��������� ��������������� �����������
      Pics.Add(FPic, True);
       // ��������� ����������
      (RootSetting.Settings[ISettingID_Tools][TComponent(Sender).Tag] as TPhoaToolSetting).Execute(Pics);
    end;
  end;

  procedure TfImgView.TopmostCancel;
  begin
    if FAlwaysOnTop then SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;

  procedure TfImgView.TopmostRestore;
  begin
    if FAlwaysOnTop then SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;

  procedure TfImgView.TransformApplied(Sender: TObject);
  begin
    DisplayPic(False, False);
    UpdateTransformActions;
  end;

  procedure TfImgView.UpdateCursor;
  var iCur: TCursor;
  begin
     // ����������� ������ iMain
    if FTrackDrag then iCur := crHandDrag else iCur := aImgViewCursors[(FWScaled>FWClient) or (FHScaled>FHClient)];
    iMain.Cursor := iCur;
     // ����������� ������ Screen
    if FForegroundLoading          then iCur := crHourGlass
    else if FDecodeThread.Decoding then iCur := crAppStart
    else                                iCur := crDefault;
    Screen.Cursor := iCur;
  end;

  procedure TfImgView.UpdateShowInfoActions;
  begin
    aShowInfo.Checked := FShowInfo;
  end;

  procedure TfImgView.UpdateSlideShowActions;
  begin
    aSlideShow.Checked         := FSlideShow;
    aSlideShowForward.Checked  := FSlideShowDirection=ssdForward;
    aSlideShowBackward.Checked := FSlideShowDirection=ssdBackward;
    aSlideShowRandom.Checked   := FSlideShowDirection=ssdRandom;
    aSlideShowCyclic.Checked   := FSlideShowCyclic;
    eSlideShowInterval.Value   := FSlideShowInterval/1000;
  end;

  procedure TfImgView.UpdateTransformActions;
  begin
    aRotate0.Checked   := FTransform.Rotation=pr0;
    aRotate90.Checked  := FTransform.Rotation=pr90;
    aRotate180.Checked := FTransform.Rotation=pr180;
    aRotate270.Checked := FTransform.Rotation=pr270;
    aFlipHorz.Checked  := pflHorz in FTransform.Flips;
    aFlipVert.Checked  := pflVert in FTransform.Flips;
  end;

  procedure TfImgView.WMDecodeFinished(var Msg: TMessage);
  begin
    UpdateCursor;
  end;

  procedure TfImgView.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
  begin
    Msg.Result := -1;
  end;

  procedure TfImgView.WMSize(var Msg: TWMSize);
  begin
    inherited;
     // ���� ��������� �������� ������� �� �������������� ����������������� � �������� ���������� �������� ���� ���
     //   ������� �����������
    if FInitialized and (FResizeProcessingLock=0) then begin
      CommitInfoRelocation;
       // ���� � ��������� ��� ��� ������ BestFitZoom, ��������� ���, ����� ��������� ZoomFactor ��� ���������
      SetZoom(iif(FBestFitZoomUsed, 0.0, ZoomFactor), False, True, True);
    end;
  end;

  procedure TfImgView.WMTimer(var Msg: TWMTimer);
  begin
    case SlideShowDirection of
      ssdForward: begin
        FPredecodeDirection := pddForward;
        if PicIdx<FPicCount-1   then PicIdx := PicIdx+1
        else if SlideShowCyclic then PicIdx := 0
        else SlideShow := False;
      end;
      ssdBackward: begin
        FPredecodeDirection := pddBackward;
        if PicIdx>0             then PicIdx := PicIdx-1
        else if SlideShowCyclic then PicIdx := FPicCount-1
        else SlideShow := False;
      end;
      ssdRandom: begin
        FPredecodeDirection := pddDisabled;
        PicIdx := Random(FPicCount);
      end;
    end;
  end;

end.

