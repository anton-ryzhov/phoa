//**********************************************************************************************************************
//  $Id: ufImgView.pas,v 1.38 2004-10-15 13:49:35 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufImgView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GraphicEx, GR32, Controls, Forms, Dialogs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phGraphics,
  GR32_Layers, 
  TB2Item, TBX, Menus, ActnList, GR32_Image, TB2Dock,
  TB2Toolbar, TB2ExtItems, TBXExtItems, DKLang;

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
    FQueuedFileName: String;
    FHDecodedEvent: THandle;
    FErrorMessage: String;
     // ������� ��������� �������� �����������
    procedure LoadProgress(Sender: TObject; Stage: TProgressStage; PercentDone: Byte; RedrawNow: Boolean; const R: TRect; const Msg: string);
     // Prop handlers
    procedure SetQueuedFileName(const Value: String);
    function  GetDecoding: Boolean;
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
    property ErrorMessage: String read FErrorMessage;
     // -- ������� ���������� �������������
    property HDecodedEvent: THandle read FHDecodedEvent;
     // -- ��� �����, ������� ����������, ��� ����� ���������� �����. ��� ������������ ���� ����������� �������� �
     //    ������� �� �������������, ������������ ������� �������������� �����������
    property QueuedFileName: String read FQueuedFileName write SetQueuedFileName;
  end;

   // ����������� ���������������� �����������
  TPredecodeDirection = (
    pddDisabled,  // ���������
    pddForward,   // �����
    pddBackward); // �����

  TfImgView = class(TForm)
    alMain: TActionList;
    aNextPic: TAction;
    aPrevPic: TAction;
    aFirstPic: TAction;
    aLastPic: TAction;
    aRefresh: TAction;
    aClose: TAction;
    aSettings: TAction;
    aZoomIn: TAction;
    aZoomOut: TAction;
    aZoomActual: TAction;
    aZoomFit: TAction;
    pmMain: TTBXPopupMenu;
    ipmNextPic: TTBXItem;
    ipmPrevPic: TTBXItem;
    ipmLastPic: TTBXItem;
    ipmFirstPic: TTBXItem;
    ipmSepZoom: TTBXSeparatorItem;
    ipmSepClose: TTBXSeparatorItem;
    ipmClose: TTBXItem;
    aFullScreen: TAction;
    aHelp: TAction;
    aEdit: TAction;
    aSlideShow: TAction;
    iMain: TImage32;
    aRelocateInfo: TAction;
    dkTop: TTBXDock;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    dkBottom: TTBXDock;
    tbMain: TTBXToolbar;
    bFirstPic: TTBXItem;
    bPrevPic: TTBXItem;
    bNextPic: TTBXItem;
    bLastPic: TTBXItem;
    tbMainSepZoomIn: TTBXSeparatorItem;
    bZoomIn: TTBXItem;
    bZoomOut: TTBXItem;
    bZoomActual: TTBXItem;
    bZoomFit: TTBXItem;
    tbMainSepFullScreen: TTBXSeparatorItem;
    tbSepEdit: TTBXSeparatorItem;
    bEdit: TTBXItem;
    bFullScreen: TTBXItem;
    bRefresh: TTBXItem;
    bRelocateInfo: TTBXItem;
    bSettings: TTBXItem;
    bHelp: TTBXItem;
    tbSepClose: TTBXSeparatorItem;
    bClose: TTBXItem;
    tbSepCounter: TTBXSeparatorItem;
    eCounter: TTBXEditItem;
    aShowInfo: TAction;
    bShowInfo: TTBXItem;
    iSepCustomTools: TTBXSeparatorItem;
    tbTools: TTBXToolbar;
    aStoreTransform: TAction;
    aRotate0: TAction;
    aRotate90: TAction;
    aRotate180: TAction;
    aRotate270: TAction;
    aFlipHorz: TAction;
    aFlipVert: TAction;
    dklcMain: TDKLanguageController;
    tbSlideShow: TTBXToolbar;
    aSlideShowForward: TAction;
    aSlideShowBackward: TAction;
    aSlideShowRandom: TAction;
    aSlideShowCyclic: TAction;
    tbMenu: TTBXToolbar;
    smHelp: TTBXSubmenuItem;
    smTools: TTBXSubmenuItem;
    smZoom: TTBXSubmenuItem;
    smView: TTBXSubmenuItem;
    smPicture: TTBXSubmenuItem;
    iClose: TTBXItem;
    iSepFileClose: TTBXSeparatorItem;
    iEdit: TTBXItem;
    iLastPic: TTBXItem;
    iNextPic: TTBXItem;
    iPrevPic: TTBXItem;
    iFirstPic: TTBXItem;
    TBXSeparatorItem1: TTBXSeparatorItem;
    iZoomFit: TTBXItem;
    iZoomActual: TTBXItem;
    iZoomOut: TTBXItem;
    iZoomIn: TTBXItem;
    smSlideShow: TTBXSubmenuItem;
    iSlideShow: TTBXItem;
    iSepSlideShowBackward: TTBXSeparatorItem;
    iSlideShowBackward: TTBXItem;
    iSlideShowRandom: TTBXItem;
    iSlideShowForward: TTBXItem;
    iSepSlideShowCyclic: TTBXSeparatorItem;
    iSlideShowCyclic: TTBXItem;
    smTransforms: TTBXSubmenuItem;
    iRotate0: TTBXItem;
    iRotate90: TTBXItem;
    iRotate180: TTBXItem;
    iRotate270: TTBXItem;
    iSepFlipHorz: TTBXSeparatorItem;
    iFlipHorz: TTBXItem;
    iFlipVert: TTBXItem;
    iSepStoreTransform: TTBXSeparatorItem;
    iStoreTransform: TTBXItem;
    iFullScreen: TTBXItem;
    iRefresh: TTBXItem;
    iShowInfo: TTBXItem;
    iRelocateInfo: TTBXItem;
    iSepFullScreen: TTBXSeparatorItem;
    iToggleMainToolbar: TTBXVisibilityToggleItem;
    iToggleToolsToolbar: TTBXVisibilityToggleItem;
    iToggleSlideShowToolbar: TTBXVisibilityToggleItem;
    iSettings: TTBXItem;
    tbgiZoom: TTBGroupItem;
    tbgiTools: TTBGroupItem;
    tbgiVew: TTBGroupItem;
    iHelp: TTBXItem;
    gipmTools: TTBGroupItem;
    iToolsSep: TTBXSeparatorItem;
    iToggleMainMenu: TTBXVisibilityToggleItem;
    eSlideShowInterval: TTBXSpinEditItem;
    iSepSlideShowInterval: TTBXSeparatorItem;
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
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainResize(Sender: TObject);
    procedure pmMainPopup(Sender: TObject);
    procedure tbMainVisibleChanged(Sender: TObject);
    procedure eSlideShowIntervalValueChange(Sender: TTBXCustomSpinEditItem; const AValue: Extended);
  private
     // ����������
    FApp: IPhotoAlbumApp;
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
    FCachedBitmapFilename: String;
    FCachedRotation: TPicRotation;
    FCachedFlips: TPicFlips;
     // True, ���� ������ ������������� �����
    FCursorHidden: Boolean;
     // ���� � ��������� �������������� �����������
    FTrackDrag: Boolean;
    FTrackX: Integer;
    FTrackY: Integer;
     // True, ���� ���� ������ ������ ������� ���� ������ � Ctrl, � ��� � ���������� ���������� ���������� ���������
     //   ����������� ����
    FShellCtxMenuOnMouseUp: Boolean;
     // ���� ��������������� ��������� �������� ����
    FForcedResize: Boolean;
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
    FInfoFont: String;
    FInfoProps: TPicProperties;
    FKeepCursorOverTB: Boolean;
    FPredecodePic: Boolean;
    FSlideShowInterval: Integer;
    FStretchFilter: TStretchFilter;
    FViewInfoPos: TRect;
    FZoomFactorChange: Single;
     // ������������ ����������/���������� �����������
    FDefaultZoomFactor: Single;
    FBestFitZoomFactor: Single;
     // True, ���� � ��������� ��� ZoomFactor �������������� ������ BestFitZoomFactor
    FBestFitZoomUsed: Boolean;
     // ������������ ������� ���� � ������� �����������
    FWMaxWindow, FHMaxWindow, FWMaxView, FHMaxView: Integer;
     // ���������� ������� ����
    FWClient, FHClient: Integer;
     // ������� ����� ����������� � �������� ��������� ����
    FXGap, FYGap: Integer;
     // ������� ��������� � ����������������� �����������
    FWPic, FHPic: Integer;
    FWScaled, FHScaled: Integer;
     // �������� �����������
    FPicDesc: String;
     // ID ������� ������ ������� (0, ���� ������ �� ������)
    FTimerID: Integer;
     // ������ �������� ��� ������ ��������������/����������
    FUndoOperations: TPhoaOperations;
     // True, ���� ������� ����������� �� ������������ ��-�� ������
    FErroneous: Boolean;
     // ���� ���������� ���������� �����������
    FDisplayLock: Integer;
     // ���� ����, ��� ��� ������� ����������� �����������
    FDisplayingPic: Boolean;
     // �������������� �����������
    FTransform: TPicTransform;
     // ������� ����� �������
    FColorMap: TColor32Map;
     // Prop storage
    FFullScreen: Boolean;
    FPicIdx: Integer;
    FShowInfo: Boolean;
    FSlideShow: Boolean;
    FSlideShowDirection: TSlideShowDirection;
    FSlideShowCyclic: Boolean;
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
     // ���������/������ ���������� ���������� �����������
    procedure RedisplayLock;
    procedure RedisplayUnlock(bReload, bApplyTransforms: Boolean);
     // ���������� �� DisplayPic. ��������� ����������� � iMain
    procedure DP_LoadImage;
     // ���������� �� DisplayPic. ��������� �������������� � iMain
    procedure DP_ApplyTransforms;
     // ���������� �� DisplayPic. ������������ ��������� (�������) �����������
    procedure DP_ComputeDimensions;
     // ���������� �� DisplayPic. �������������� �������� ����������� (��������� ����, ����� ����������, �������)
    procedure DP_DescribePic;
     // ������ � ������� �� �������� ��������� �����������, ���� �����
    procedure DP_EnqueueNext;
     // ��������� ����������� ��������������� sNewZoom, ������������ ���� ��� ������������� � bCanResize=True
    procedure ApplyZoom(sNewZoom: Single; bCanResize: Boolean);
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
    procedure PaintDescLayer(Sender: TObject; Buffer: TBitmap32);
    procedure RBLayerResizing(Sender: TObject; const OldLocation: TFloatRect; var NewLocation: TFloatRect; DragState: TDragState; Shift: TShiftState);
    procedure BitmapPixelCombine(F: TColor32; var B: TColor32; M: TColor32);
     // ���� ������� ����� ���������� ����������, ��������� ���
    procedure CommitInfoRelocation;
     // Message handlers
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
    procedure WMDecodeFinished(var Msg: TMessage); message WM_DECODE_FINISHED;
     // Prop handlers
    function  GetViewOffset: TPoint;
    function  GetZoomFactor: Single;
    procedure SetFullScreen(Value: Boolean);
    procedure SetPicIdx(Value: Integer);
    procedure SetShowInfo(Value: Boolean);
    procedure SetSlideShow(Value: Boolean);
    procedure SetViewOffset(const Value: TPoint);
    procedure SetZoomFactor(Value: Single);
    procedure SetSlideShowCyclic(Value: Boolean);
    procedure SetSlideShowDirection(Value: TSlideShowDirection);
  protected
     // ���� True, �� �� ������ �� ViewImage iPicIdx ��������������� ������ ������� ���������� ��������������
     //   �����������
    FReturnUpdatedPicIdx: Boolean;
  public
     // Props
     // -- True, ���� � ��������� ������ ������������� �����
    property FullScreen: Boolean read FFullScreen write SetFullScreen;
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
    property ZoomFactor: Single read GetZoomFactor write SetZoomFactor;
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
  Types, ChmHlp, udSettings, phUtils, udPicProps, phSettings, phToolSetting, Main;

  procedure ViewImage(AInitFlags: TImgViewInitFlags; AApp: IPhotoAlbumApp; var iPicIdx: Integer; AUndoOperations: TPhoaOperations);
  begin
    with TfImgView.Create(Application) do
      try
        FInitFlags      := AInitFlags;
        FApp            := AApp;
        FPicCount       := FApp.ViewedPics.Count;
        FPicIdx         := iPicIdx;
        FUndoOperations := AUndoOperations;
        aEdit.Enabled   := FApp.Project.ViewIndex<0;
        ApplySettings(True);
        ShowModal;
        if FReturnUpdatedPicIdx then iPicIdx := FPicIdx;
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
          if not FLoadAborted then LoadGraphicFromFile(FQueuedFileName, FBitmap, LoadProgress);
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

  procedure TDecodeThread.SetQueuedFileName(const Value: String);
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
    FullScreen := not FullScreen;
  end;

  procedure TfImgView.aaHelp(Sender: TObject);
  begin
    CommitInfoRelocation;
    HtmlHelpContext(HelpContext);
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
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    fMain.BeginOperation;
    try
      TPhoaOp_StoreTransform.Create(FUndoOperations, FApp.Project, FPic, FTransform.Rotation, FTransform.Flips, Changes);
    finally
      fMain.EndOperation(Changes);
    end;
    EnableActions;
  end;

  procedure TfImgView.aaZoomActual(Sender: TObject);
  begin
    ZoomFactor := 1.0;
  end;

  procedure TfImgView.aaZoomFit(Sender: TObject);
  begin
    ZoomFactor := FBestFitZoomFactor;
  end;

  procedure TfImgView.aaZoomIn(Sender: TObject);
  begin
    ZoomFactor := ZoomFactor*FZoomFactorChange;
  end;

  procedure TfImgView.aaZoomOut(Sender: TObject);
  begin
    ZoomFactor := ZoomFactor/FZoomFactorChange;
  end;

  procedure TfImgView.AdjustCursorVisibility(bForceShow: Boolean);
  begin
    if (FHideCursorInFS and FFullScreen and not bForceShow)<>FCursorHidden then begin
      FCursorHidden := not FCursorHidden;
      ShowCursor(not FCursorHidden);
    end;
  end;

  procedure TfImgView.ApplySettings(bUseInitFlags: Boolean);
  var bFullscreen: Boolean;
  begin
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
    RedisplayLock;
    try
      FullScreen := bFullscreen;
    finally
       // ���� ����� ��������� �����������
      RedisplayUnlock(True, True);
    end;
     // ���� ����� �������� ����� ������ �������, ���������� ��� �������������
    if bUseInitFlags and (ivifSlideShow in FInitFlags) then SlideShow := True;
     // ��������� actions
    UpdateShowInfoActions;
    UpdateSlideShowActions;
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

  procedure TfImgView.ApplyZoom(sNewZoom: Single; bCanResize: Boolean);
  var
    ixWindow, iyWindow, iwWindow, ihWindow: Integer;
    PrevMousePos, p: TPoint;
  begin
     // ��������� �� ������ �� ������������
    if FErroneous then sNewZoom := 1
     // Verify zoom value
    else if sNewZoom>SMaxPicZoom then sNewZoom := SMaxPicZoom
    else if sNewZoom<SMinPicZoom then sNewZoom := SMinPicZoom;
     // ��������� ����������� ���������������
    iMain.Scale := sNewZoom;
     // ������� ������� ����������������� �����������
    FWScaled := Round(FWPic*sNewZoom);
    FHScaled := Round(FHPic*sNewZoom);
     // ������� ������� � ��������� ����
    ixWindow := Left;
    iyWindow := Top;
    iwWindow := Width;
    ihWindow := Height;
    if bCanResize then begin
      if FFullScreen then begin
        iwWindow := Screen.Width;
        ihWindow := Screen.Height;
      end else if FFitWindowToPic then begin
        iwWindow := Max(Min(FWScaled+FXGap, FWMaxWindow), Constraints.MinWidth);
        ihWindow := Max(Min(FHScaled+FYGap, FHMaxWindow), Constraints.MinHeight);
      end;
      if FFullScreen then begin
        ixWindow := 0;
        iyWindow := 0;
      end else if FCenterWindow then begin
        ixWindow := (Screen.WorkAreaWidth-iwWindow) div 2;
        iyWindow := (Screen.WorkAreaHeight-ihWindow) div 2;
      end;
       // ���� �����, ��������� ��������� ������� ���� ��� ������� ������������
      PrevMousePos := Point(-1, -1);
      if FKeepCursorOverTB and not FFullScreen and Application.Active and tbMain.Visible then begin
        p := tbMain.ScreenToClient(Mouse.CursorPos);
        if (p.x<tbMain.Width) and (p.y<tbMain.Height) then PrevMousePos := p;
      end;
       // �������� ��������� ����
      FForcedResize := True;
      try
        SetBounds(ixWindow, iyWindow, iwWindow, ihWindow);
      finally
        FForcedResize := False;
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
    ViewOffset := Point((FWClient-FWScaled) div 2, (FHClient-FHScaled) div 2);
     // ����������� ��������� ����������
    FDescLayer.Location := FloatRect(
      FWClient/10000*FViewInfoPos.Left,
      FHClient/10000*FViewInfoPos.Top,
      FWClient/10000*FViewInfoPos.Right,
      FHClient/10000*FViewInfoPos.Bottom);
     // ����������� Actions (ZoomFactor � ������� ������ �������� ������ �� ���)
    EnableActions;
  end;

  procedure TfImgView.BitmapPixelCombine(F: TColor32; var B: TColor32; M: TColor32);
  begin
    B := FColorMap.ApplyToColor(F);
  end;

  procedure TfImgView.CommitInfoRelocation;
  begin
    if FRBLayer<>nil then aRelocateInfo.Execute;
  end;

  procedure TfImgView.DisplayPic(bReload, bApplyTransforms: Boolean);
  begin
    if FDisplayingPic or (FDisplayLock>0) then Exit;
    CommitInfoRelocation;
    FTrackDrag := False;
    FDisplayingPic := True;
    try
       // ��������� �����������
      if bReload then DP_LoadImage;
       // ��������� �������������� � �����������
      if bReload or bApplyTransforms then DP_ApplyTransforms;
       // ������������ ������� ���� � �����������
      DP_ComputeDimensions;
       // ����������� ��������
      DP_DescribePic;
       // ���������� ��������
      ApplyZoom(FDefaultZoomFactor, True);
       // ������ � ������� ����������/��������� (������� �� ����������� ��������) �����������
      DP_EnqueueNext;
    finally
      FDisplayingPic := False;
    end;
     // ������������� ������
    RestartSlideShowTimer;
  end;

  procedure TfImgView.DP_ApplyTransforms;
  begin
     // ��������� �� ������ �� ���������������
    if not FErroneous then FTransform.ApplyValues(FPic.Rotation, FPic.Flips);
  end;

  procedure TfImgView.DP_ComputeDimensions;
  begin
     // ���������� ������������ ������� ����
    if FFullScreen then begin
      FXGap := ClientWidth-iMain.Width;
      FYGap := ClientHeight-iMain.Height;
      FWMaxWindow := Screen.Width;
      FHMaxWindow := Screen.Height;
    end else begin
      FXGap := Width-iMain.Width;
      FYGap := Height-iMain.Height;
      FWMaxWindow := Screen.WorkAreaWidth;
      FHMaxWindow := Screen.WorkAreaHeight;
    end;
     // �������� ������� ����������� (�� ��������� ������� ��������)
    FWPic := Max(iMain.Bitmap.Width,  1);
    FHPic := Max(iMain.Bitmap.Height, 1);
    FWMaxView := FWMaxWindow-FXGap;
    FHMaxView := FHMaxWindow-FYGap;
     // ���������� ������������ ���������������
    FBestFitZoomFactor := MinS(FWMaxView/FWPic, FHMaxView/FHPic);
    if ((FBestFitZoomFactor<1.0) and FDoShrinkPic) or ((FBestFitZoomFactor>1.0) and FDoZoomPic) then
      FDefaultZoomFactor := FBestFitZoomFactor
    else
      FDefaultZoomFactor := 1.0;
  end;

  procedure TfImgView.DP_DescribePic;
  var sCaption: String;
  begin
     // ����������� Caption / ���������� ��������
   if FErroneous then begin
      sCaption := '';
      FPicDesc := '';
    end else begin
      sCaption := GetPicPropStrs(FPic, FCaptionProps, '', ' - ');
      FPicDesc := GetPicPropStrs(FPic, FInfoProps,    '', '    ');
    end;
    if sCaption='' then Caption := ConstVal('SImgView_DefaultCaption') else Caption := sCaption;
     // ����������� �������
    eCounter.Text := Format('%d/%d', [FPicIdx+1, FPicCount]);
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
        FDecodeThread.QueuedFileName := FApp.ViewedPics[idxNextPic].FileName;
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
    procedure PaintError(const sFileName, sError: String);
    var
      r: TRect;
      sTitle: String;
      Sz: TSize;
    begin
      sTitle := ConstVal('SImgView_ErrorMsg');
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
        Sz := TextExtent(sTitle);
        r := Rect((Width-Sz.cx) div 2, (Height-Sz.cy) div 2, (Width+Sz.cx) div 2, (Height+Sz.cy) div 2);
        TextOut(r, DT_LEFT or DT_NOPREFIX, sTitle);
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
    FPic := FApp.ViewedPics[FPicIdx];
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

  procedure TfImgView.eSlideShowIntervalValueChange(Sender: TTBXCustomSpinEditItem; const AValue: Extended);
  begin
    FSlideShowInterval := Trunc(AValue*1000);
    RestartSlideShowTimer;
  end;

  procedure TfImgView.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
    CommitInfoRelocation;
  end;

  procedure TfImgView.FormContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
  begin
    Handled := FShellCtxMenuOnMouseUp;
  end;

  procedure TfImgView.FormCreate(Sender: TObject);
  begin
    HelpContext := IDH_intf_view_mode;
     // ������ ����� ��������
    FDecodeThread := TDecodeThread.Create(Self);
     // ������ ���� ��� ��������� ��������
    FDescLayer := TPositionedLayer.Create(iMain.Layers);
    FDescLayer.OnPaint := PaintDescLayer;
     // ������ ��������������
    FTransform := TPicTransform.Create(iMain.Bitmap);
    FTransform.OnApplied := TransformApplied;
     // ������ ����� ������
    FColorMap := TColor32Map.Create;
     // ��������������� ��������� � ��������� ������� ������������
    TBRegLoadPositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegViewWindow_Toolbars);
  end;

  procedure TfImgView.FormDestroy(Sender: TObject);
  begin
     // ��������� ��������� � ��������� ������� ������������
    TBRegSavePositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegViewWindow_Toolbars);
     // ���������� �������
    FColorMap.Free;
    FTransform.Free;
     // ���������� ������� ����� � ������������� �����������
    FDecodeThread.Terminate;
     // ���������� ������ ��������
    if FTimerID<>0 then KillTimer(Handle, FTimerID);
     // ���������� ���
    FCachedBitmap.Free;
  end;

  procedure TfImgView.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
      else Exit;
    end;
    ViewOffset := pTmpOffs;
  end;

  procedure TfImgView.FormKeyPress(Sender: TObject; var Key: Char);
  begin
    case Key of
      #8:  aPrevPic.Execute;
      #13: begin
        FReturnUpdatedPicIdx := True;
        aClose.Execute;
      end;
      '+': aZoomIn.Execute;
      '-': aZoomOut.Execute;
      '*': aZoomFit.Execute;
      '/': aZoomActual.Execute;
      ' ': aNextPic.Execute;
    end;
  end;

  procedure TfImgView.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  begin
    if ssCtrl in Shift then aZoomOut.Execute else aNextPic.Execute;
    Handled := True;
  end;

  procedure TfImgView.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
  begin
    if ssCtrl in Shift then aZoomIn.Execute else aPrevPic.Execute;
    Handled := True;
  end;

  function TfImgView.GetViewOffset: TPoint;
  begin
    Result := Point(Trunc(iMain.OffsetHorz), Trunc(iMain.OffsetVert));
  end;

  function TfImgView.GetZoomFactor: Single;
  begin
    Result := iMain.Scale;
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
      mbRight: if not FErroneous and (ssCtrl in Shift) then FShellCtxMenuOnMouseUp := True;
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
    end else if FShellCtxMenuOnMouseUp then begin
      if not FErroneous and (Button=mbRight) and (ssCtrl in Shift) then ShowFileShellContextMenu(FPic.FileName, Self);
      FShellCtxMenuOnMouseUp := False;
    end;
  end;

  procedure TfImgView.iMainResize(Sender: TObject);
  begin
     // ���� ��������� �������� ������� �� �������������� ����������������� � �������� ���������� �������� ���� ���
     //   ������� �����������. ���� � ��������� ��� ��� ������ BestFitZoom, ��������� ���, ����� ��������� ZoomFactor
     //   ��� ���������
    if not FForcedResize then ApplyZoom(iif(FBestFitZoomUsed, FBestFitZoomFactor, ZoomFactor), False);
  end;

  procedure TfImgView.PaintDescLayer(Sender: TObject; Buffer: TBitmap32);
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

  procedure TfImgView.RedisplayLock;
  begin
    Inc(FDisplayLock);
  end;

  procedure TfImgView.RedisplayPic(bReload, bApplyTransforms: Boolean);
  begin
     // ������� ������� (����� ����� ����� ���������� ����������� �����)
    if bReload then FDecodeThread.QueuedFileName := '';
     // ����� ���������� �����������
    DisplayPic(bReload, bApplyTransforms);
  end;

  procedure TfImgView.RedisplayUnlock(bReload, bApplyTransforms: Boolean);
  begin
    if FDisplayLock>0 then begin
      Dec(FDisplayLock);
      if FDisplayLock=0 then RedisplayPic(bReload, bApplyTransforms);
    end;
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
  begin
    FFullScreen := Value;
    aFullScreen.Checked := Value;
    FormStyle   := aFS[FAlwaysOnTop and not Value];
    BorderStyle := aBS[Value];
    WindowState := aWS[Value];
     // ����������� ��������� �������
    AdjustCursorVisibility(False);
     // ����������� ��������
    RedisplayPic(False, False);
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

  procedure TfImgView.SetViewOffset(const Value: TPoint);
  var ix, iy: Integer;
  begin
    CommitInfoRelocation;
    if FWScaled>FWClient then ix := Min(0, Max(Value.x, FWClient-FWScaled)) else ix := (FWClient-FWScaled) div 2;
    if FHScaled>FHClient then iy := Min(0, Max(Value.y, FHClient-FHScaled)) else iy := (FHClient-FHScaled) div 2;
    iMain.OffsetHorz := ix;
    iMain.OffsetVert := iy;
  end;

  procedure TfImgView.SetZoomFactor(Value: Single);
  begin
    CommitInfoRelocation;
     // ����������, ���� ��������� BestFitZoom
    FBestFitZoomUsed := Value=FBestFitZoomFactor;
     // ��������� ����� ����������� ���������������
    ApplyZoom(Value, True);
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

  procedure TfImgView.WMHelp(var Msg: TWMHelp);
  begin
    HtmlHelpContext(HelpContext);
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

