//**********************************************************************************************************************
//  $Id: ufImgView.pas,v 1.6 2004-04-23 19:26:30 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit ufImgView;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GraphicEx, GR32, Controls, Forms, Dialogs, ConsVars, phObj, GR32_Layers,
  DTLangTools, TB2Item, TBX, Menus, ActnList, GR32_Image, TB2Dock,
  TB2Toolbar, TB2ExtItems, TBXExtItems;

type
   // �����, ������������ ��������� ����������� � ������� ������
  TDecodeThread = class(TThread)
  private
     // Bitmap, � ������� ������������ ����
    FBitmap: TBitmap32;
     // ������� ���������� ����������� � ������� �� �������������
    FHQueuedEvent: THandle;
     // Prop storage
    FQueuedFileName: String;
    FHDecodedEvent: THandle;
    FErrorMessage: String;
    procedure SetQueuedFileName(const Value: String);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
     // ���������� � �������� �������������� Bitmap
    function  GetAndReleasePicture: TBitmap32;
    procedure Terminate;
     // Props
     // -- ����� ��������� �� ������, ���� ����� ������������� Graphic=nil
    property ErrorMessage: String read FErrorMessage;
     // -- ������� ���������� �������������
    property HDecodedEvent: THandle read FHDecodedEvent;
     // -- ��� �����, ������� ����������, ��� ����� ���������� �����. ��� ������������ ���� ����������� �������� �
     //    ������� �� �������������, ������������ ������� �������������� �����������
    property QueuedFileName: String read FQueuedFileName write SetQueuedFileName;
  end;

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
    ipmSep1: TTBXSeparatorItem;
    ipmZoomIn: TTBXItem;
    ipmZoomOut: TTBXItem;
    ipmZoomActual: TTBXItem;
    ipmZoomFit: TTBXItem;
    ipmSep2: TTBXSeparatorItem;
    ipmRefresh: TTBXItem;
    ipmSettings: TTBXItem;
    ipmSep4: TTBXSeparatorItem;
    ipmClose: TTBXItem;
    aFullScreen: TAction;
    ipmFullScreen: TTBXItem;
    aHelp: TAction;
    ipmHelp: TTBXItem;
    aEdit: TAction;
    ipmEdit: TTBXItem;
    dtlsMain: TDTLanguageSwitcher;
    aSlideShow: TAction;
    ipmSep3: TTBXSeparatorItem;
    iSlideShow: TTBXItem;
    iMain: TImage32;
    aRelocateInfo: TAction;
    ipmRelocateInfo: TTBXItem;
    dkTop: TTBXDock;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    dkBottom: TTBXDock;
    tbMain: TTBXToolbar;
    bFirstPic: TTBXItem;
    bPrevPic: TTBXItem;
    bNextPic: TTBXItem;
    bLastPic: TTBXItem;
    tbSepZoomIn: TTBXSeparatorItem;
    bZoomIn: TTBXItem;
    bZoomOut: TTBXItem;
    bZoomActual: TTBXItem;
    bZoomFit: TTBXItem;
    tbSepSlideShow: TTBXSeparatorItem;
    bSlideShow: TTBXItem;
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
    ipmShowInfo: TTBXItem;
    bShowInfo: TTBXItem;
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure aaNextPic(Sender: TObject);
    procedure aaPrevPic(Sender: TObject);
    procedure aaRefresh(Sender: TObject);
    procedure aaClose(Sender: TObject);
    procedure aaSettings(Sender: TObject);
    procedure aaFirstPic(Sender: TObject);
    procedure aaLastPic(Sender: TObject);
    procedure aaZoomFit(Sender: TObject);
    procedure aaZoomIn(Sender: TObject);
    procedure aaZoomOut(Sender: TObject);
    procedure aaZoomActual(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure aaFullScreen(Sender: TObject);
    procedure aaHelp(Sender: TObject);
    procedure aaEdit(Sender: TObject);
    procedure aaSlideShow(Sender: TObject);
    procedure iMainMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure iMainMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure FormCreate(Sender: TObject);
    procedure aaRelocateInfo(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure tbMainVisibleChanged(Sender: TObject);
    procedure iMainResize(Sender: TObject);
    procedure aaShowInfo(Sender: TObject);
  private
    FGroup: TPhoaGroup;
    FPhoA: TPhotoAlbum;
     // ����� ������� �������� ��������
    FDecodeThread: TDecodeThread;
     // True, ���� ��������� ����� �������� ���� � ����������� "�����" (������������ ��� ����������������)
    FLastPicChangeBackwards: Boolean;
     // ����, �� ������� �������� ��������
    FDescLayer: TPositionedLayer;
     // ���� ����������� ����������
    FRBLayer: TRubberbandLayer;
     // ������� ������������ �����������
    FPic: TPhoaPic;
     // ���������� ������������� ������������� ����������� � ��� ��� ����� (������������ ��� bViewCacheBehind=True)
    FCachedBitmap: TBitmap32;
    FCachedBitmapFilename: String;
     // True, ���� ������ ������������� �����
    FCursorHidden: Boolean;
     // ������ ��� iMain (crHand ��� crDefault)
    FImageCursor: TCursor;
     // ���� � ��������� �������������� �����������
    FTrackDrag: Boolean;
    FTrackX: Integer;
    FTrackY: Integer;
     // ���� ��������������� ��������� �������� ����
    FForcedResize: Boolean;
     // ������������ ��������� ���������
    FBackgroundColor: TColor;
    FZoomFactorChange: Single;
    FCaptionProps: TPicProperties;
    FDoShrinkPic: Boolean;
    FDoZoomPic: Boolean;
    FDefaultFullscreen: Boolean;
    FAlwaysOnTop: Boolean;
    FKeepCursorOverTB: Boolean;
    FHideCursorInFS: Boolean;
    FFitWindowToPic: Boolean;
    FCenterWindow: Boolean;
    FCyclicViewing: Boolean;
    FPredecodePic: Boolean;
    FCacheBehindPic: Boolean;
    FStretchFilter: TStretchFilter;
    FSlideInterval: Integer;
    FSlideCyclic: Boolean;
    FDefaultShowInfo: Boolean;
    FInfoProps: TPicProperties;
    FInfoFont: String;
    FInfoBkColor: TColor;
    FInfoBkOpacity: Byte;
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
     // Prop storage
    FFullScreen: Boolean;
    FPicIdx: Integer;
    FShowInfo: Boolean;
    FSlideShow: Boolean;
     // ����������� ��������� ���� � ��������� ������� ��������� �����������
    procedure ApplySettings;
     // ����������� ��������� ������� ����
    procedure AdjustCursorVisibility(bForceShow: Boolean);
     // ��������� � ������������ �����������; ������������ ������������ ���������������
    procedure DisplayPic(bReload: Boolean);
     // ����������� ������� �����������
    procedure RedisplayPic(bReload: Boolean);
     // ���������/������ ���������� ���������� �����������
    procedure RedisplayLock;
    procedure RedisplayUnlock(bReload: Boolean);
     // ���������� �� DisplayPic. ��������� ����������� � iMain
    procedure DP_LoadImage;
     // ���������� �� DisplayPic. ������������ ��������� (�������) �����������
    procedure DP_ComputeDimensions;
     // ���������� �� DisplayPic. �������������� �������� ����������� (��������� ����, ����� ����������, �������)
    procedure DP_DescribePic;
     // ������ � ������� �� �������� ��������� �����������, ���� �����
    procedure DP_EnqueueNext;
     // ��������� ����������� ��������������� sNewZoom, ������������ ���� ��� ������������� � bCanResize=True
    procedure ApplyZoom(sNewZoom: Single; bCanResize: Boolean);
     // ���������/��������� Actions
    procedure EnableActions;
     // ���������� ��� ������� ������ ������ �������
    procedure RestartShowTimer;
     // ��������� ���������� ��������/�������������� ����� TOPMOST ���� ���������, ���� �� ����
    procedure TopmostCancel;
    procedure TopmostRestore;
     // ������� ����
    procedure PaintDescLayer(Sender: TObject; Buffer: TBitmap32);
    procedure RBLayerResizing(Sender: TObject; const OldLocation: TFloatRect; var NewLocation: TFloatRect; DragState: TDragState; Shift: TShiftState);
     // ���� ������� ����� ���������� ����������, ��������� ���
    procedure CommitInfoRelocation;
     // Message handlers
    procedure WMTimer(var Msg: TWMTimer); message WM_TIMER;
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
     // Prop handlers
    procedure SetPicIdx(Value: Integer);
    function  GetZoomFactor: Single;
    procedure SetZoomFactor(Value: Single);
    function  GetViewOffset: TPoint;
    procedure SetViewOffset(const Value: TPoint);
    procedure SetFullScreen(Value: Boolean);
    procedure SetSlideShow(Value: Boolean);
    procedure SetShowInfo(Value: Boolean);
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
     // -- �������� ������ �������� ���� ���������������� �����������
    property ViewOffset: TPoint read GetViewOffset write SetViewOffset;
     // -- ������� ���������������� �����������
    property ZoomFactor: Single read GetZoomFactor write SetZoomFactor;
  end;

   // ������� � ����� ��������� �����������
   //   Group          - ������, � ������� ������������� �����������
   //   PhoA           - ����������
   //   iPicIdx        - ������ ����������� � ������, � �������� �������� ��������
   //   UndoOperations - ����� ������
   //   bPhGroups      - True, ���� ������������ ������ ����� ����������� (�� �������������)
  procedure ViewImage(Group: TPhoaGroup; PhoA: TPhotoAlbum; iPicIdx: Integer; UndoOperations: TPhoaOperations; bPhGroups: Boolean);

implementation
{$R *.dfm}
uses udSettings, Types, phUtils, ChmHlp, udPicProps, Main, phSettings;

  procedure ViewImage(Group: TPhoaGroup; PhoA: TPhotoAlbum; iPicIdx: Integer; UndoOperations: TPhoaOperations; bPhGroups: Boolean);
  begin
    with TfImgView.Create(Application) do
      try
        FGroup          := Group;
        FPhoA           := PhoA;
        FPicIdx         := iPicIdx;
        FUndoOperations := UndoOperations;
        aEdit.Enabled   := bPhGroups;
        ApplySettings;
        ShowModal;
      finally
        if FCursorHidden then ShowCursor(True);
        Free;
      end;
  end;

   //===================================================================================================================
   // TDecodeThread
   //===================================================================================================================

  constructor TDecodeThread.Create;
  begin
    inherited Create(True);
    FreeOnTerminate := True;
    Priority := tpLowest;
    FHQueuedEvent  := CreateEvent(nil, False, False, nil);
     // ������� ������������� ������ � ���������� ��������� - ��� ��������, ��� ����� ���������� ��������
    FHDecodedEvent := CreateEvent(nil, True,  True,  nil);
    Resume;
  end;

  destructor TDecodeThread.Destroy;
  begin
    FBitmap.Free;
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
         // ����������� ������� �����������, ���� ��� ���� (�������� ����������������)
        FreeAndNil(FBitmap);
         // �������� ����� �����������, ������������� ��������� Exceptions
        try
          FBitmap := LoadGraphicFromFile(FQueuedFileName);
        except
          on e: Exception do FErrorMessage := e.Message;
        end;
       // ��������� � ����������
      finally
        SetEvent(FHDecodedEvent);
      end;
    end;
  end;

  function TDecodeThread.GetAndReleasePicture: TBitmap32;
  begin
    Result := FBitmap;
    FBitmap := nil;
  end;

  procedure TDecodeThread.SetQueuedFileName(const Value: String);
  begin
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
    Arr: TPicArray;
    bEdited: Boolean;
  begin
    CommitInfoRelocation;
     // "�������" ���� � topmost-��������� 
    TopmostCancel;
     // ���������� ������
    AdjustCursorVisibility(True);
     // ����������� �����������
    SetLength(Arr, 1);
    Arr[0] := FPic;
    bEdited := EditPic(Arr, FPhoA, FUndoOperations);
     // ���������� topmost-��������� ����
    TopmostRestore;
     // �������� ������
    AdjustCursorVisibility(False);
     // ��������� �������� �����������
    if bEdited then RedisplayPic(False);
  end;

  procedure TfImgView.aaFirstPic(Sender: TObject);
  begin
    FLastPicChangeBackwards := False;
    PicIdx := 0;
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
    FLastPicChangeBackwards := True;
    PicIdx := FGroup.PicIDs.Count-1;
  end;

  procedure TfImgView.aaNextPic(Sender: TObject);
  begin
    FLastPicChangeBackwards := False;
    if PicIdx<FGroup.PicIDs.Count-1 then PicIdx := PicIdx+1
    else if FCyclicViewing then PicIdx := 0;
  end;

  procedure TfImgView.aaPrevPic(Sender: TObject);
  begin
    FLastPicChangeBackwards := True;
    if PicIdx>0 then PicIdx := PicIdx-1
    else if FCyclicViewing then PicIdx := FGroup.PicIDs.Count-1;
  end;

  procedure TfImgView.aaRefresh(Sender: TObject);
  begin
    RedisplayPic(True);
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
      ViewInfoPos := Rect(
        Round(fr.Left/FWClient*10000),
        Round(fr.Top/FHClient*10000),
        Round(fr.Right/FWClient*10000),
        Round(fr.Bottom/FHClient*10000));
      FreeAndNil(FRBLayer);
    end;
    aRelocateInfo.Checked := Assigned(FRBLayer);
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
      ApplySettings;
      RestartShowTimer;
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

  procedure TfImgView.ApplySettings;
  begin
     // �������� �������� ��������
    FBackgroundColor   := SettingValueInt(ISettingID_View_BkColor);
    FZoomFactorChange  := adMagnifications[SettingValueInt(ISettingID_View_ZoomFactor)];
    FCaptionProps      := IntToPicProps(SettingValueInt(ISettingID_View_CaptionProps));
    FDoShrinkPic       := SettingValueBool(ISettingID_View_ShrinkPicToFit);
    FDoZoomPic         := SettingValueBool(ISettingID_View_ZoomPicToFit);
    FDefaultFullscreen := SettingValueBool(ISettingID_View_Fullscreen);
    FAlwaysOnTop       := SettingValueBool(ISettingID_View_AlwaysOnTop);
    FKeepCursorOverTB  := SettingValueBool(ISettingID_View_KeepCursorOverTB);
    FHideCursorInFS    := SettingValueBool(ISettingID_View_HideCursor);
    FFitWindowToPic    := SettingValueBool(ISettingID_View_FitWindowToPic);
    FCenterWindow      := SettingValueBool(ISettingID_View_CenterWindow);
    FCyclicViewing     := SettingValueBool(ISettingID_View_Cyclic);
    FPredecodePic      := SettingValueBool(ISettingID_View_Predecode);
    FCacheBehindPic    := SettingValueBool(ISettingID_View_CacheBehind);
    FStretchFilter     := TStretchFilter(SettingValueInt(ISettingID_View_StchFilt));
    FSlideInterval     := SettingValueInt(ISettingID_View_SlideInterval);
    FSlideCyclic       := SettingValueBool(ISettingID_View_SlideCyclic);
    FDefaultShowInfo   := SettingValueBool(ISettingID_View_ShowInfo);
    FShowInfo          := FDefaultShowInfo;
    FInfoProps         := IntToPicProps(SettingValueInt(ISettingID_View_InfoPicProps));
    FInfoFont          := SettingValueStr(ISettingID_View_InfoFont);
    FInfoBkColor       := SettingValueInt(ISettingID_View_InfoBkColor);
    FInfoBkOpacity     := SettingValueInt(ISettingID_View_InfoBkOpacity);
     // ����������� ��������� ����
    FontFromStr(Font, SettingValueStr(ISettingID_Gen_MainFont));
    Color              := FBackgroundColor;
     // ����������� ����/������ ������������
     // -- ���������
    tbMain.Visible     := SettingValueBool(ISettingID_View_ShowToolbar);
     // -- �����������������
    ApplyToolbarSettings(dkTop);
    ApplyToolbarSettings(dkLeft);
    ApplyToolbarSettings(dkRight);
    ApplyToolbarSettings(dkBottom);
     // ����������� ��������� ������� ������
    RedisplayLock;
    try
      ShowInfo   := FDefaultShowInfo;
      FullScreen := FDefaultFullscreen;
    finally
       // ���� ����� ��������� �����������
      RedisplayUnlock(True);
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
    FImageCursor := aImgViewCursors[(FWScaled>FWClient) or (FHScaled>FHClient)];
    iMain.Cursor := FImageCursor;
     // ������� ��������� ��������� �����������
    ViewOffset := Point((FWClient-FWScaled) div 2, (FHClient-FHScaled) div 2);
     // ����������� ��������� ����������
    FDescLayer.Location := FloatRect(
      FWClient/10000*ViewInfoPos.Left,
      FHClient/10000*ViewInfoPos.Top,
      FWClient/10000*ViewInfoPos.Right,
      FHClient/10000*ViewInfoPos.Bottom);
     // ����������� Actions (ZoomFactor � ������� ������ �������� ������ �� ���)
    EnableActions;
  end;

  procedure TfImgView.CommitInfoRelocation;
  begin
    if FRBLayer<>nil then aRelocateInfo.Execute;
  end;

  procedure TfImgView.DisplayPic(bReload: Boolean);
  begin
    if FDisplayLock>0 then Exit;
    CommitInfoRelocation;
    FTrackDrag := False;
     // ��������� �����������
    if bReload then DP_LoadImage;
     // ������������ ������� ���� � �����������
    DP_ComputeDimensions;
     // ����������� ��������
    DP_DescribePic;
     // ���������� ��������
    ApplyZoom(FDefaultZoomFactor, True);
     // ������ � ������� ����������/��������� (������� �� ����������� ��������) �����������
    DP_EnqueueNext;
     // ������������� ������
    RestartShowTimer;
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
    FPicDesc := '';
     // ����������� Caption / ���������� ��������
    if FErroneous then
      sCaption := ''
    else begin
      sCaption := FPic.GetPropStrs(FCaptionProps, '', ' - ');
      if FShowInfo then FPicDesc := FPic.GetPropStrs(FInfoProps, '', '    ');
    end;
    if sCaption='' then Caption := dtlsMain.Consts['SDefaultCaption'] else Caption := sCaption;
     // ����������� �������
    eCounter.Text := Format('%d/%d', [FPicIdx+1, FGroup.PicIDs.Count]);
  end;

  procedure TfImgView.DP_EnqueueNext;
  var idxNextPic: Integer;
  begin
     // ���� �������� ���������������� 
    if FPredecodePic then begin
       // ������� ������ ���������� ����������� � ������ ����������� ��������
      idxNextPic := FPicIdx+iif(FLastPicChangeBackwards, -1, 1);
       // ��������� ������� / ����������� ���������
      if idxNextPic<0 then
        if FCyclicViewing then idxNextPic := FGroup.PicIDs.Count-1 else idxNextPic := -1
      else if idxNextPic>=FGroup.PicIDs.Count then
        if FCyclicViewing then idxNextPic := 0 else idxNextPic := -1;
       // ������ ���� � ������� 
      if idxNextPic>=0 then FDecodeThread.QueuedFileName := FPhoA.Pics.PicByID(FGroup.PicIDs[idxNextPic]).PicFileName;
    end;
  end;

  procedure TfImgView.DP_LoadImage;
  var
    FPrevPic: TPhoaPic;
    bmpDecoded, bmpPrevTemp: TBitmap32;
    bPicInCache: Boolean;

     // ������ �� iMain ������ ����������� ��������� �� ������
    procedure PaintError(const sFileName, sError: String);
    var
      r: TRect;
      sTitle: String;
      Sz: TSize;
    begin
      sTitle := dtlsMain.Consts['SError'];
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
    FPrevPic := FPic;
     // ������� ������� �����������
    FPic := FPhoA.Pics.PicByID(FGroup.PicIDs[FPicIdx]);
     // ����������, ���� �� ����������� � ���� 
    bPicInCache := FCachedBitmapFilename=FPic.PicFileName;
     // ���� ���, �������� [����]������� �������� �����������
    if not bPicInCache then FDecodeThread.QueuedFileName := FPic.PicFileName;
     // ���� ����������� �� ���������, ��������� ������ �����������
    if not FErroneous and FCacheBehindPic and (FPrevPic<>nil) and (FPrevPic<>FPic) then begin
      bmpPrevTemp := TBitmap32.Create;
      bmpPrevTemp.Assign(iMain.Bitmap);
    end else
      bmpPrevTemp := nil;
     // ���� ����������� �����������, �������� ���
    if bPicInCache then
      try
        iMain.Bitmap.Assign(FCachedBitmap);
      except
        bmpPrevTemp.Free;
        raise;
      end;
     // ����������� ��� � ��������� � ���� ������ �����������
    FCachedBitmap.Free;
    FCachedBitmap := bmpPrevTemp;
    if bmpPrevTemp=nil then FCachedBitmapFilename := '' else FCachedBitmapFilename := FPrevPic.PicFileName;
     // ���� �� ����� �� ����, ���������� ��������� �������� ����������� ������� �������
    if not bPicInCache then begin
      StartWait;
      try
        WaitForSingleObject(FDecodeThread.HDecodedEvent, INFINITE);
        bmpDecoded := FDecodeThread.GetAndReleasePicture;
         // ���� ����� ������ nil - ������, ��������� ������
        FErroneous := bmpDecoded=nil;
        if FErroneous then
          PaintError(FPic.PicFileName, FDecodeThread.ErrorMessage)
        else
          try
            iMain.Bitmap.Assign(bmpDecoded);
          finally
            bmpDecoded.Free;
          end;
      finally
        StopWait;
      end;
    end;
     // ����������� ������ �����������
    iMain.Bitmap.StretchFilter := FStretchFilter;
  end;

  procedure TfImgView.EnableActions;
  var iCnt: Integer;
  begin
    iCnt := FGroup.PicIDs.Count;
    aLastPic.Enabled    := FPicIdx<iCnt-1;
    aFirstPic.Enabled   := FPicIdx>0;
    aNextPic.Enabled    := (iCnt>1) and (FCyclicViewing or aLastPic.Enabled);
    aPrevPic.Enabled    := (iCnt>1) and (FCyclicViewing or aFirstPic.Enabled);
    aZoomIn.Enabled     := not FErroneous and (ZoomFactor<SMaxPicZoom);
    aZoomOut.Enabled    := not FErroneous and (ZoomFactor>SMinPicZoom);
    aZoomFit.Enabled    := not FErroneous and (ZoomFactor<>FBestFitZoomFactor);
    aZoomActual.Enabled := not FErroneous and (ZoomFactor<>1.0);
  end;

  procedure TfImgView.FormClose(Sender: TObject; var Action: TCloseAction);
  begin
    CommitInfoRelocation;
  end;

  procedure TfImgView.FormCreate(Sender: TObject);
  begin
    HelpContext := IDH_intf_view_mode;
    FDecodeThread := TDecodeThread.Create;
    FDescLayer := TPositionedLayer.Create(iMain.Layers);
    FDescLayer.OnPaint := PaintDescLayer;
  end;

  procedure TfImgView.FormDestroy(Sender: TObject);
  begin
    FDecodeThread.Terminate;
    if FTimerID<>0 then KillTimer(Handle, FTimerID);
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
      #13: aClose.Execute;
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
          iMain.Cursor := crHandDrag;
          FTrackX := ViewOffset.x-x;
          FTrackY := ViewOffset.y-y;
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
      iMain.Cursor := FImageCursor;
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
     // ���� ���� ��������
    if FPicDesc<>'' then begin
      r := MakeRect(FDescLayer.GetAdjustedLocation);
      FontFromStr(Buffer.Font, FInfoFont);
      Buffer.FillRectTS(r, (Color32(FInfoBkColor) and $00ffffff) or (Cardinal(FInfoBkOpacity) shl 24));
      Buffer.Textout(r, DT_CENTER or DT_VCENTER or DT_WORDBREAK or DT_NOPREFIX, FPicDesc);
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

  procedure TfImgView.RedisplayPic(bReload: Boolean);
  begin
     // ������� ������� (����� ����� ����� ���������� ����������� �����)
    if bReload then FDecodeThread.QueuedFileName := '';
     // ����� ���������� �����������
    DisplayPic(bReload);
  end;

  procedure TfImgView.RedisplayUnlock(bReload: Boolean);
  begin
    if FDisplayLock>0 then begin
      Dec(FDisplayLock);
      if FDisplayLock=0 then RedisplayPic(bReload);
    end;
  end;

  procedure TfImgView.RestartShowTimer;
  begin
    if FTimerID<>0 then KillTimer(Handle, FTimerID);
    if FSlideShow then FTimerID := SetTimer(Handle, ISlideShowTimerID, FSlideInterval, nil) else FTimerID := 0;
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
    RedisplayPic(False);
  end;

  procedure TfImgView.SetPicIdx(Value: Integer);
  begin
    if (FPicIdx<>Value) and (Value>=0) and (Value<FGroup.PicIDs.Count) then begin
      FPicIdx := Value;
      DisplayPic(True);
    end;
  end;

  procedure TfImgView.SetShowInfo(Value: Boolean);
  begin
    if FShowInfo<>Value then begin
      CommitInfoRelocation;
      FShowInfo := Value;
       // �������������� ��������
      RedisplayPic(False);
    end;
    aShowInfo.Checked := Value;
  end;

  procedure TfImgView.SetSlideShow(Value: Boolean);
  begin
    if FSlideShow<>Value then begin
      CommitInfoRelocation;
      FSlideShow := Value;
      RestartShowTimer;
    end;
    aSlideShow.Checked := Value;
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

  procedure TfImgView.TopmostCancel;
  begin
    if FAlwaysOnTop then SetWindowPos(Handle, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;

  procedure TfImgView.TopmostRestore;
  begin
    if FAlwaysOnTop then SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  end;

  procedure TfImgView.WMHelp(var Msg: TWMHelp);
  begin
    HtmlHelpContext(HelpContext);
  end;

  procedure TfImgView.WMTimer(var Msg: TWMTimer);
  begin
    FLastPicChangeBackwards := False;
    if PicIdx<FGroup.PicIDs.Count-1 then PicIdx := PicIdx+1
    else if FSlideCyclic then PicIdx := 0
    else SlideShow := False;
  end;

end.
