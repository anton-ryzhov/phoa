//**********************************************************************************************************************
//  $Id: Main.pas,v 1.53 2004-10-15 13:49:35 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit Main;

interface

uses
   // GR32 must follow GraphicEx because of naming conflict between stretch filter constants
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GraphicEx, GR32, Controls, Forms, Dialogs,
  ActiveX, XPMan,
  phIntf, phMutableIntf, phNativeIntf, phObj, phGUIObj, phOps,
  ConsVars,
  DKLang, ImgList, TB2Item, Placemnt, TB2MRU, TBXExtItems, Menus,
  TBX, ActnList, TBXStatusBars, VirtualTrees, TBXDkPanels, TBXLists,
  TB2Dock, TB2Toolbar;

type
  TfMain = class(TForm, IPhotoAlbumApp)
    aAbout: TAction;
    aCopy: TAction;
    aCut: TAction;
    aDelete: TAction;
    aEdit: TAction;
    aExit: TAction;
    aFileOperations: TAction;
    aFind: TAction;
    aFlatMode: TAction;
    aHelpCheckUpdates: TAction;
    aHelpContents: TAction;
    aHelpFAQ: TAction;
    aHelpProductWebsite: TAction;
    aHelpSupport: TAction;
    aHelpVendorWebsite: TAction;
    aIniLoadSettings: TAction;
    aIniSaveSettings: TAction;
    alMain: TActionList;
    aNew: TAction;
    aNewGroup: TAction;
    aNewPic: TAction;
    aOpen: TAction;
    aPaste: TAction;
    aPhoaView_Delete: TAction;
    aPhoaView_Edit: TAction;
    aPhoaView_MakeGroup: TAction;
    aPhoaView_New: TAction;
    aPicOps: TAction;
    aRemoveSearchResults: TAction;
    aSave: TAction;
    aSaveAs: TAction;
    aSelectAll: TAction;
    aSelectNone: TAction;
    aSettings: TAction;
    aSortPics: TAction;
    aStats: TAction;
    aUndo: TAction;
    aView: TAction;
    aViewSlideShow: TAction;
    bCopy: TTBXItem;
    bCut: TTBXItem;
    bDelete: TTBXItem;
    bEdit: TTBXItem;
    bExit: TTBXItem;
    bFind: TTBXItem;
    bHelpContents: TTBXItem;
    bNew: TTBXItem;
    bNewGroup: TTBXItem;
    bNewPic: TTBXItem;
    bOpen: TTBXSubmenuItem;
    bOpenMRU: TTBXMRUListItem;
    bPaste: TTBXItem;
    bSave: TTBXItem;
    bSaveAs: TTBXItem;
    bSettings: TTBXItem;
    bStats: TTBXItem;
    bUndo: TTBXSubmenuItem;
    bView: TTBXItem;
    dkBottom: TTBXDock;
    dklcMain: TDKLanguageController;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    dkTop: TTBXDock;
    dpGroups: TTBXDockablePanel;
    fpMain: TFormPlacement;
    gipmPhoaView: TTBGroupItem;
    gipmPhoaViewViews: TTBGroupItem;
    gismViewViews: TTBGroupItem;
    giTools_GroupsMenu: TTBGroupItem;
    giTools_PicsMenu: TTBGroupItem;
    giTools_ToolsMenu: TTBGroupItem;
    iAbout: TTBXItem;
    iCopy: TTBXItem;
    iCut: TTBXItem;
    iDelete: TTBXItem;
    iEdit: TTBXItem;
    iEditSep1: TTBXSeparatorItem;
    iEditSep2: TTBXSeparatorItem;
    iEditSep3: TTBXSeparatorItem;
    iEditSep4: TTBXSeparatorItem;
    iExit: TTBXItem;
    iFileOperations: TTBXItem;
    iFileSep1: TTBXSeparatorItem;
    iFileSep2: TTBXSeparatorItem;
    iFileSep3: TTBXSeparatorItem;
    iFind: TTBXItem;
    iFlatMode: TTBXItem;
    iHelpCheckUpdates: TTBXItem;
    iHelpContents: TTBXItem;
    iHelpFAQ: TTBXItem;
    iHelpProductWebsite: TTBXItem;
    iHelpSupport: TTBXItem;
    iHelpVendorWebsite: TTBXItem;
    iIniLoadSettings: TTBXItem;
    iIniSaveSettings: TTBXItem;
    ilActionsLarge: TImageList;
    ilActionsMiddle: TImageList;
    ilActionsSmall: TTBImageList;
    iNew: TTBXItem;
    iNewGroup: TTBXItem;
    iNewPic: TTBXItem;
    iOpen: TTBXItem;
    iPaste: TTBXItem;
    iPhoaView_Delete: TTBXItem;
    iPhoaView_Edit: TTBXItem;
    iPhoaView_MakeGroup: TTBXItem;
    iPhoaView_New: TTBXItem;
    iPhoaView_SetDefault: TTBXItem;
    iPhoaViewSep1: TTBXSeparatorItem;
    iPhoaViewSep2: TTBXSeparatorItem;
    iPhoaViewSep3: TTBXSeparatorItem;
    iPicOps: TTBXItem;
    ipmGroupsDelete: TTBXItem;
    ipmGroupsEdit: TTBXItem;
    ipmGroupsFileOperations: TTBXItem;
    ipmGroupsNewGroup: TTBXItem;
    ipmGroupsNewPic: TTBXItem;
    ipmGroupsPicOps: TTBXItem;
    ipmGroupsSep1: TTBXSeparatorItem;
    ipmGroupsSep2: TTBXSeparatorItem;
    ipmGroupsSep3: TTBXSeparatorItem;
    ipmGroupsSortPics: TTBXItem;
    ipmGroupsStats: TTBXItem;
    ipmPicsCopy: TTBXItem;
    ipmPicsCut: TTBXItem;
    ipmPicsDelete: TTBXItem;
    ipmPicsEdit: TTBXItem;
    ipmPicsFileOperations: TTBXItem;
    ipmPicsNewPic: TTBXItem;
    ipmPicsPaste: TTBXItem;
    ipmPicsSelectAll: TTBXItem;
    ipmPicsSelectNone: TTBXItem;
    ipmPicsSep1: TTBXSeparatorItem;
    ipmPicsSep2: TTBXSeparatorItem;
    ipmPicsSep3: TTBXSeparatorItem;
    ipmPicsSep4: TTBXSeparatorItem;
    ipmPicsView: TTBXItem;
    iRemoveSearchResults: TTBXItem;
    iSave: TTBXItem;
    iSaveAs: TTBXItem;
    iSelectAll: TTBXItem;
    iSelectNone: TTBXItem;
    iSettings: TTBXItem;
    iSortPics: TTBXItem;
    iToggleStatusbar: TTBXVisibilityToggleItem;
    iToggleToolbar: TTBXVisibilityToggleItem;
    iToolsSep1: TTBXSeparatorItem;
    iToolsSep2: TTBXSeparatorItem;
    iUndo: TTBXItem;
    iView: TTBXItem;
    mruOpen: TTBXMRUList;
    pmGroups: TTBXPopupMenu;
    pmPhoaView: TTBXPopupMenu;
    pmPics: TTBXPopupMenu;
    pmView: TTBXPopupMenu;
    sbarMain: TTBXStatusBar;
    smEdit: TTBXSubmenuItem;
    smFile: TTBXSubmenuItem;
    smFileMRU: TTBXMRUListItem;
    smHelp: TTBXSubmenuItem;
    smHelpInternet: TTBXSubmenuItem;
    smTools: TTBXSubmenuItem;
    smUndoHistory: TTBXSubmenuItem;
    smView: TTBXSubmenuItem;
    tbMain: TTBXToolbar;
    tbMenu: TTBXToolbar;
    tbSep1: TTBXSeparatorItem;
    tbSep2: TTBXSeparatorItem;
    tbSep3: TTBXSeparatorItem;
    tbSep4: TTBXSeparatorItem;
    tbSepHelpWebsite: TTBXSeparatorItem;
    tbViewSep1: TTBXSeparatorItem;
    tbxlToolbarUndo: TTBXLabelItem;
    tvGroups: TVirtualStringTree;
    ulToolbarUndo: TTBXUndoList;
    iEditSep5: TTBXSeparatorItem;
    iViewSlideShow: TTBXItem;
    procedure aaAbout(Sender: TObject);
    procedure aaCopy(Sender: TObject);
    procedure aaCut(Sender: TObject);
    procedure aaDelete(Sender: TObject);
    procedure aaEdit(Sender: TObject);
    procedure aaExit(Sender: TObject);
    procedure aaFileOperations(Sender: TObject);
    procedure aaFind(Sender: TObject);
    procedure aaFlatMode(Sender: TObject);
    procedure aaHelpCheckUpdates(Sender: TObject);
    procedure aaHelpContents(Sender: TObject);
    procedure aaHelpFAQ(Sender: TObject);
    procedure aaHelpProductWebsite(Sender: TObject);
    procedure aaHelpSupport(Sender: TObject);
    procedure aaHelpVendorWebsite(Sender: TObject);
    procedure aaIniLoadSettings(Sender: TObject);
    procedure aaIniSaveSettings(Sender: TObject);
    procedure aaNew(Sender: TObject);
    procedure aaNewGroup(Sender: TObject);
    procedure aaNewPic(Sender: TObject);
    procedure aaOpen(Sender: TObject);
    procedure aaPaste(Sender: TObject);
    procedure aaPhoaView_Delete(Sender: TObject);
    procedure aaPhoaView_Edit(Sender: TObject);
    procedure aaPhoaView_MakeGroup(Sender: TObject);
    procedure aaPhoaView_New(Sender: TObject);
    procedure aaPicOps(Sender: TObject);
    procedure aaRemoveSearchResults(Sender: TObject);
    procedure aaSave(Sender: TObject);
    procedure aaSaveAs(Sender: TObject);
    procedure aaSelectAll(Sender: TObject);
    procedure aaSelectNone(Sender: TObject);
    procedure aaSettings(Sender: TObject);
    procedure aaSortPics(Sender: TObject);
    procedure aaStats(Sender: TObject);
    procedure aaUndo(Sender: TObject);
    procedure aaView(Sender: TObject);
    procedure bUndoPopup(Sender: TTBCustomItem; FromLink: Boolean);
    procedure dklcMainLanguageChanged(Sender: TObject);
    procedure dklcMainLanguageChanging(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure fpMainRestorePlacement(Sender: TObject);
    procedure fpMainSavePlacement(Sender: TObject);
    procedure mruOpenClick(Sender: TObject; const Filename: String);
    procedure pmGroupsPopup(Sender: TObject);
    procedure pmPicsPopup(Sender: TObject);
    procedure SetGroupExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure SetPhoaViewClick(Sender: TObject);
    procedure tvGroupsBeforeItemErase(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var ItemColor: TColor; var EraseAction: TItemEraseAction);
    procedure tvGroupsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
    procedure tvGroupsCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure tvGroupsDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure tvGroupsDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
    procedure tvGroupsDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
    procedure tvGroupsEditCancelled(Sender: TBaseVirtualTree; Column: TColumnIndex);
    procedure tvGroupsEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvGroupsEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
    procedure tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure ulToolbarUndoChange(Sender: TObject);
    procedure ulToolbarUndoClick(Sender: TObject);
    procedure aaViewSlideShow(Sender: TObject);
  private
     // �������� ������
    FProject: IPhotoAlbumProject;
     // ��������������� � ��������� ������ ����������� (� ������ ������ Flat)
    FViewedPics: IPhotoAlbumPicList;
     // ���� ����������� ������
    FSearchNode: PVirtualNode;
     // ������ ����������� - ���������� ������
    FSearchResults: IPhotoAlbumPicGroup;
     // Handle ���� - ���������� ������������ ��������� ����������� clipboard
    FHNextClipbrdViewer: HWND;
     // ���� �������� ��� ������
    FUndo: TPhoaUndo;
     // ����� �������, ������� ��������� ���������� � ���������� ������ �����
    FGroupTreeHintProps: TGroupProperties;
     // �����, ����������� �� ��, ��� ����������� popup-���� ����� � ������ ������ �������� �� ����������� �������
     //   ���������� ������������
    FGroupsPopupToolsValidated: Boolean;
    FPicsPopupToolsValidated: Boolean;
     // ���� ����, ��� ������������� ����� ��������
    FInitialized: Boolean;
     // ������� ������� BeginOperation/EndOperation
    FOpLockCounter: Integer;
     // �������������� ����� ���������, ������������ ���������� ����� �������� BeginOperation/EndOperation
    FOpChanges: TPhoaOperationChanges;
     // ���������� �� ����� ���������� �������� ID ��������� ���������� ������
    FSavedGroupID: Integer;
     // ���������� �� ����� ���������� �������� ��������� ����������� Viewer
    FViewerDisplayData: IThumbnailViewerDisplayData;
     // Prop storage
    FViewer: TThumbnailViewer;
     // ��������� ��������� ��������� �����
    procedure ApplyLanguage;
     // ��������� ��������� ��������� ������������
    procedure ApplyTools;
     // ��������� ������������� ���������� ����� �������. ���������� True, ���� ����� ����������
    function  CheckSave: Boolean;
     // ����������� ������ ������������� �������
    procedure ReloadViewList;
     // ��������� ������ �������� ������������� � ������ �����
    procedure UpdateViewIndex;
     // ��������� �������� ����� �� ������� � tvGroups
    procedure LoadGroupTree;
     // ���������� ��� ��������� ������� ������ �������
    procedure UpdateThumbnailSize;
     // ��������/���������� ����������� � �����
    procedure DoLoad(const sFileName: String);
    procedure DoSave(const sFileName: String; iRevisionNumber: Integer);
     // ������������ ��������� ��������� ������
    procedure ProcessCommandLine;
     // ����������� ������������� Actions � ����������� Caption �����
    procedure EnableActions;
     // ����������� ����������� ������������
    procedure EnableTools;
     // ����������� ����������� ������������ ��� ��������� ������������� ������
    procedure DoEnableTools(Item: TTBCustomItem);
     // ������ ������ �����������:
     //   ���� ������� ������ ����� - �� ���� ����������� ������
     //   ���� ������� ����� - �� ���������� �� ������ �����������
     //   ����� ���������� nil
    function  GetSelectedPics: IPhoaPicList;
     // ���������� ���������� ������. ���� bForceRemove=True, ������� ���� �����������, �����, ��� bDoSelectNode=True,
     //   �������� ����
    procedure DisplaySearchResults(bForceRemove, bDoSelectNode: Boolean);
     // ��������� ��������� aFlatMode
    procedure UpdateFlatModeAction;
     // ���������� ��� ����
    function  GetNodeKind(Tree: TBaseVirtualTree; Node: PVirtualNode): TGroupNodeKind;
     // ������������ ����� ��������� �������� ���� ���������� ��������������� ������ ����������
    procedure ProcessOpChanges(Changes: TPhoaOperationChanges);
     // ���������� ��� �������� � ��������� �� Index � ��������� ���������� ������� �������� ������ ��������
    procedure UndoOperations(Index: Integer);
     // ������� ����� �� ������ �����������
    procedure ToolItemClick(Sender: TObject);
     // ������ � ����� ���������, ������� � �������� �����������. InitFlags ����� ����� �������������
    procedure StartViewMode(InitFlags: TImgViewInitFlags);
     // �������� ��� "������������" ������ � ������������ � �������� ����� ���������
    procedure ResetMode;
     // ������� � ���������� ���� � tvGroups �� ID ������; nil, ���� ��� ������
    function  FindGroupNodeByID(iGroupID: Integer): PVirtualNode;
     // Application events
    procedure AppHint(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
     // Viewer events
    procedure ViewerSelectionChange(Sender: TObject);
    procedure ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
     // IPhotoAlbumApp
    function  IPhotoAlbumApp.GetCurGroup       = GetCurGroup;
    function  IPhotoAlbumApp.GetFocusedControl = GetFocusedControl;
    function  IPhotoAlbumApp.GetImageList      = IApp_GetImageList;
    function  IPhotoAlbumApp.GetProject        = IApp_GetProject;
    function  IPhotoAlbumApp.GetSelectedPics   = IApp_GetSelectedPics;
    function  IPhotoAlbumApp.GetViewedPics     = IApp_GetViewedPics;
    procedure IPhotoAlbumApp.SetCurGroup       = SetCurGroup;
    function  IApp_GetImageList: TCustomImageList;
    function  IApp_GetProject: IPhotoAlbumProject;
    function  IApp_GetSelectedPics: IPhotoAlbumPicList;
    function  IApp_GetViewedPics: IPhotoAlbumPicList;
     // Message handlers
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
    procedure CMFocusChanged(var Msg: TCMFocusChanged);   message CM_FOCUSCHANGED;
    procedure WMHelp(var Msg: TWMHelp);                   message WM_HELP;
    procedure WMStartViewMode(var Msg: TWMStartViewMode); message WM_STARTVIEWMODE;
     // Property handlers
    procedure SetFileName(const Value: String);
    function  GetFileName: String;
    function  GetFocusedControl: TPhoaAppFocusedControl;
    function  GetDisplayFileName: String;
    function  GetCurGroup: IPhotoAlbumPicGroup;
    procedure SetCurGroup(Value: IPhotoAlbumPicGroup);
  public
    function  IsShortCut(var Message: TWMKey): Boolean; override;
     // ������ ���������� ����� ������� ���������� ����� ��������
    procedure BeginOperation;
     // ������ ���������� ����� ���������� ��������. ����� ���������� ������ ��������� ������������ ������ �� ���������
     //   ������ Changes
    procedure EndOperation(Changes: TPhoaOperationChanges);
     // ��������� ��������� ���������
    procedure ApplySettings;
     // ��������� Viewer
    procedure RefreshViewer;
     // Props
     // -- ������� ��������� ������ � ������
    property CurGroup: IPhotoAlbumPicGroup read GetCurGroup write SetCurGroup;
     // -- ��� ����� ����������� ��� ����������� (�� ������ ������, � ����� ������ 'untitled.phoa')
    property DisplayFileName: String read GetDisplayFileName;
     // -- ��� �������� ����� ����������� (������ ������, ���� ����� ����������)
    property FileName: String read GetFileName write SetFileName;
     // -- ������� ��������������� �������
    property FocusedControl: TPhoaAppFocusedControl read GetFocusedControl;
     // -- ����������� �������
    property Viewer: TThumbnailViewer read FViewer;
  end;

var
  fMain: TfMain;

implementation
{$R *.dfm}
uses
  GraphicStrings, Clipbrd, Math, Registry, jpeg, TypInfo, ChmHlp, // GraphicStrings => GraphicEx constants
  phUtils, phPhoa,
  udPicProps, udSettings, ufImgView, udSearch, udPhoAProps, udAbout, udPicOps, udSortPics, udViewProps, udSelPhoaGroup,
  ufAddFilesWizard, udStats, udFileOpsWizard, phSettings, phValSetting,
  phToolSetting, udMsgBox, udGroupProps;

   // ��������� ImageList �� PNG-�������, ���� �� ��� �� ��������
  procedure MakeImagesLoaded(const sResourceName: String; Images: TCustomImageList);
  var
    PNG: TPNGGraphic;
    Bmp: TBitmap;
  begin
    if Images.Count=0 then begin
       // ��������� �������� � PNG
      PNG := TPNGGraphic.Create;
      try
        PNG.LoadFromResourceName(HInstance, sResourceName);
         // �������� � ������
        Bmp := TBitmap.Create;
        try
          Bmp.Assign(PNG);
           // ��������� � ImageList
          Images.AddMasked(Bmp, clFuchsia);
        finally
          Bmp.Free;
        end;
      finally
        PNG.Free;
      end;
    end;
  end;

   //===================================================================================================================
   //  TfMain
   //===================================================================================================================

  procedure TfMain.aaAbout(Sender: TObject);
  begin
    ResetMode;
    ShowAbout(SettingValueBool(ISettingID_Dlgs_SplashAboutFade));
  end;

  procedure TfMain.aaCopy(Sender: TObject);
  begin
    ResetMode;
    TPhoaBaseOp_PicCopy.Create(Viewer.SelectedPics, TPicClipboardFormats(Byte(SettingValueInt(ISettingID_Gen_ClipFormats))));
  end;

  procedure TfMain.aaCut(Sender: TObject);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    TPhoaBaseOp_PicCopy.Create(Viewer.SelectedPics, TPicClipboardFormats(Byte(SettingValueInt(ISettingID_Gen_ClipFormats))));
    BeginOperation;
    try
      TPhoaOp_PicDelete.Create(FUndo, FProject, CurGroup, Viewer.SelectedPics, Changes);
    finally
      EndOperation(Changes);
    end;
  end;

  procedure TfMain.aaDelete(Sender: TObject);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    ResetMode;
    if CurGroup<>nil then
      case FocusedControl of
         // �������� ������
        pafcGroupTree:
          if PhoaConfirm(False, 'SConfirm_DelGroup', ISettingID_Dlgs_ConfmDelGroup) then begin
            BeginOperation;
            try
              TPhoaOp_GroupDelete.Create(FUndo, FProject, CurGroup, Changes);
            finally
              EndOperation(Changes);
            end;
          end;
         // �������� �����������
        pafcThumbViewer:
          if (Viewer.SelectedPics.Count>0) and PhoaConfirm(False, 'SConfirm_DelPics', ISettingID_Dlgs_ConfmDelPics) then begin
            BeginOperation;
            try
              TPhoaOp_PicDelete.Create(FUndo, FProject, CurGroup, Viewer.SelectedPics, Changes);
            finally
              EndOperation(Changes);
            end;
          end;
      end;
  end;

  procedure TfMain.aaEdit(Sender: TObject);
  begin
    ResetMode;
    case FocusedControl of
       // �������������� �����
      pafcGroupTree:
        case GetNodeKind(tvGroups, tvGroups.FocusedNode) of
          gnkPhoA:      EditPhoA    (Self, FUndo);
          gnkView:      EditView    (Self, FUndo);
          gnkPhoaGroup: EditPicGroup(Self, FUndo);
        end;
       // �������������� �����������
      pafcThumbViewer: if Viewer.SelectedPics.Count>0 then EditPics(Self, Viewer.SelectedPics, FUndo);
    end;
  end;

  procedure TfMain.aaExit(Sender: TObject);
  begin
    ResetMode;
    Close;
  end;

  procedure TfMain.aaFileOperations(Sender: TObject);
  var bProjectChanged: Boolean;
  begin
    ResetMode;
    if DoFileOperations(Self, bProjectChanged) then
       // ���� ���������� ���������� �����������
      if bProjectChanged then begin
         // �������� ������� ��������� ��� ��������� ��� ����������� ������
        FUndo.SetNonUndoable;
         // ������������� �������������
        FProject.Views.Invalidate;
         // ����������� ������ �����
        LoadGroupTree;
       // ����� ������ ���� ������� ����������� ��������� (� �������� �������, �� �� � ����������) - ��������� �����
      end else
        FUndo.Clear;
  end;

  procedure TfMain.aaFind(Sender: TObject);
  begin
    ResetMode;
    if DoSearch(Self, FSearchResults) then DisplaySearchResults(False, True);
  end;

  procedure TfMain.aaFlatMode(Sender: TObject);
  begin
    SetSettingValueBool(ISettingID_Browse_FlatMode, not SettingValueBool(ISettingID_Browse_FlatMode));
    UpdateFlatModeAction;
    RefreshViewer;
  end;

  procedure TfMain.aaHelpCheckUpdates(Sender: TObject);
  begin
    ResetMode;
    DKWeb.Open_VerCheck;
  end;

  procedure TfMain.aaHelpContents(Sender: TObject);
  begin
    ResetMode;
    HtmlHelpShowContents;
  end;

  procedure TfMain.aaHelpFAQ(Sender: TObject);
  begin
    ResetMode;
    HtmlHelpContext(IDH_faq);
  end;

  procedure TfMain.aaHelpProductWebsite(Sender: TObject);
  begin
    ResetMode;
    DKWeb.Open_ViewInfo;
  end;

  procedure TfMain.aaHelpSupport(Sender: TObject);
  begin
    ResetMode;
    DKWeb.Open_Support;
  end;

  procedure TfMain.aaHelpVendorWebsite(Sender: TObject);
  begin
    ResetMode;
    DKWeb.Open_Index;
  end;

  procedure TfMain.aaIniLoadSettings(Sender: TObject);

    procedure DoIniLoad(const sFileName: String);
    begin
       // ��������� ���������
      IniLoadSettings(sFileName);
       // ��������� ���������
      ApplySettings;
      ApplyLanguage;
    end;

  begin
    ResetMode;
    with TOpenDialog.Create(Self) do
      try
        DefaultExt := SDefaultIniFileExt;
        FileName   := SDefaultIniFileName;
        Filter     := ConstVal('SFileFilter_Ini');
        Options    := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
        Title      := ConstVal('SDlgTitle_OpenIni');
        if Execute then DoIniLoad(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaIniSaveSettings(Sender: TObject);
  begin
    ResetMode;
    with TSaveDialog.Create(Self) do
      try
        DefaultExt := SDefaultIniFileExt;
        FileName   := SDefaultIniFileName;
        Filter     := ConstVal('SFileFilter_Ini');
        Options    := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];
        Title      := ConstVal('SDlgTitle_SaveIni');
        if Execute then IniSaveSettings(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaNew(Sender: TObject);
  begin
    ResetMode;
    if not CheckSave then Exit;
    tvGroups.BeginUpdate;
    try
       // ������� ���������� ������
      DisplaySearchResults(True, False);
       // �������������� ������
      FProject.New;
      UpdateThumbnailSize;
       // ������� ����� ������
      FUndo.Clear;
      FUndo.SetSavepoint;
       // ��������� ������ �������������
      ReloadViewList;
    finally
      tvGroups.EndUpdate;
    end;
  end;

  procedure TfMain.aaNewGroup(Sender: TObject);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    BeginOperation;
    try
      TPhoaOp_GroupNew.Create(FUndo, FProject, CurGroup, Changes);
    finally
      EndOperation(Changes);
    end;
    //!!! ������� � ����� �������������� ����� ����������� ������
  end;

  procedure TfMain.aaNewPic(Sender: TObject);
  begin
    ResetMode;
    AddFiles(Self, FUndo);
  end;

  procedure TfMain.aaOpen(Sender: TObject);
  begin
    ResetMode;
    with TOpenDialog.Create(Self) do
      try
        DefaultExt := SDefaultExt;
        Filter     := ConstVal('SFileFilter_OpenPhoa');
        Options    := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
        Title      := ConstVal('SDlgTitle_OpenPhoa');
        if Execute and CheckSave then DoLoad(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaPaste(Sender: TObject);
  var
    iCntBefore: Integer;
    Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    iCntBefore := CurGroup.Pics.Count;
    BeginOperation;
    try
      TPhoaOp_PicPaste.Create(FUndo, FProject, CurGroup, Changes);
    finally
      EndOperation(Changes);
    end;
    PhoaInfo(False, 'SNotify_Paste', [CurGroup.Pics.Count-iCntBefore], ISettingID_Dlgs_NotifyPaste);
  end;

  procedure TfMain.aaPhoaView_Delete(Sender: TObject);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    ResetMode;
    if PhoaConfirm(False, 'SConfirm_DelView', ISettingID_Dlgs_ConfmDelView) then begin
      BeginOperation;
      try
        TPhoaOp_ViewDelete.Create(FUndo, FProject, Changes);
      finally
        EndOperation(Changes);
      end;
    end;
  end;

  procedure TfMain.aaPhoaView_Edit(Sender: TObject);
  begin
    ResetMode;
    EditView(Self, FUndo);
  end;

  procedure TfMain.aaPhoaView_MakeGroup(Sender: TObject);
  begin
    ResetMode;
    MakeGroupFromView(Self, FUndo);
  end;

  procedure TfMain.aaPhoaView_New(Sender: TObject);
  begin
    ResetMode;
    AddView(Self, FUndo);
  end;

  procedure TfMain.aaPicOps(Sender: TObject);
  begin
    ResetMode;
    DoPicOps(Self, FUndo);
  end;

  procedure TfMain.aaRemoveSearchResults(Sender: TObject);
  begin
    ResetMode;
    DisplaySearchResults(True, False);
  end;

  procedure TfMain.aaSave(Sender: TObject);
  begin
    ResetMode;
     // ���� ��� ����� �� ������, ��������� SaveAs. ����� ��������� ���� �����������
    if FileName='' then aSaveAs.Execute else DoSave(FProject.FileName, FProject.FileRevision);
  end;

  procedure TfMain.aaSaveAs(Sender: TObject);
  begin
    ResetMode;
    with TSaveDialog.Create(Self) do
      try
        DefaultExt  := SDefaultExt;
        Filter      := GetPhoaSaveFilter;
        FilterIndex := ValidRevisionIndex(GetIndexOfRevision(FProject.FileRevision))+1;
        Options     := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];
        Title       := ConstVal('SDlgTitle_SavePhoa');
        FileName    := DisplayFileName;
        if Execute then DoSave(FileName, aPhFileRevisions[ValidRevisionIndex(FilterIndex-1)].iNumber);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaSelectAll(Sender: TObject);
  begin
    ResetMode;
    Viewer.SelectAll;
  end;

  procedure TfMain.aaSelectNone(Sender: TObject);
  begin
    ResetMode;
    Viewer.ClearSelection;
  end;

  procedure TfMain.aaSettings(Sender: TObject);
  begin
    ResetMode;
     // � ������� �������� �� ��������� �������� ������ "����� ������"
    if EditSettings(ISettingID_Browse) then begin
      ApplySettings;
       // ��������� ������������ Drag'n'Drop � Viewer
      EnableActions;
    end;
  end;

  procedure TfMain.aaSortPics(Sender: TObject);
  begin
    ResetMode;
    DoSortPics(Self, FUndo, CurGroup=FSearchResults);
  end;

  procedure TfMain.aaStats(Sender: TObject);
  begin
    ResetMode;
    ShowProjectStats(Self);
  end;

  procedure TfMain.aaUndo(Sender: TObject);
  begin
    UndoOperations(FUndo.Count-1);
  end;

  procedure TfMain.aaView(Sender: TObject);
  begin
    StartViewMode([]);
  end;

  procedure TfMain.aaViewSlideShow(Sender: TObject);
  begin
    StartViewMode([ivifSlideShow]);
  end;

  procedure TfMain.AppException(Sender: TObject; E: Exception);
  var s: String;
  begin
     // ��������� �����, ���� � ����� �� ���� ���������� (ripped from Application.ShowException)
    s := E.Message;
    if (s<>'') and (AnsiLastChar(s)>'.') then s := s+'.';
     // ����� ��������� �� ������
    PhoaMsgBox(mbkError, s, False, False, [mbbOK]);
  end;

  procedure TfMain.AppHint(Sender: TObject);
  begin
    sbarMain.Panels[0].Caption := Application.Hint;
  end;

  procedure TfMain.AppIdle(Sender: TObject; var Done: Boolean);
  begin
     // ���������� ���� ���������, ���� ��� ����
    HideProgressWnd;
  end;

  procedure TfMain.ApplyLanguage;
  begin
     // ����������� ������ ��������
    if FInitialized then begin
       // ������������� �������������, �.�. ��� �������� ������������ �������� �����
      FProject.Views.Invalidate;
       // �������������� ������
      tvGroups.ReinitChildren(nil, True);
      tvGroups.Invalidate;
       // ��������� ��������� ����
      EnableActions;
    end;
     // ����������� Help-����
    Application.HelpFile := ExtractFilePath(ParamStr(0))+ConstVal('SHelpFileName');
  end;

  procedure TfMain.ApplySettings;

    procedure SetupViewerCorner(Corner: TThumbCorner; iSettingID: Integer);
    var
      i: Integer;
      tcd: TThumbCornerDetail;
    begin
      i := SettingValueInt(iSettingID);
      tcd.bDisplay := (i>=Byte(Low(TPicProperty))) and (i<=Byte(High(TPicProperty)));
      if tcd.bDisplay then tcd.Prop := TPicProperty(i);
      Viewer.ThumbCornerDetails[Corner] := tcd;
    end;

  begin
     // ����������� ���� ����������
    LangManager.LanguageID := SettingValueInt(ISettingID_Gen_Language);
     // ����������� ����
    with (RootSetting.Settings[ISettingID_Gen_Theme] as TPhoaListSetting) do TBXSetTheme(VariantText); 
     // ����������� �������� ����� ���������
    FontFromStr(Font, SettingValueStr(ISettingID_Gen_MainFont));
    ToolbarFont.Assign(Font);
     // ����������� ������� ������� ��������
    cMainCodePage := CharsetToCP(Font.Charset);
     // ����������� ������ ��������� ������������� ������
    mruOpen.MaxItems := SettingValueInt(ISettingID_Gen_OpenMRUCount);
     // ����������� ������������ ���������� �������� � ������ ������
    FUndo.MaxCount := SettingValueInt(ISettingID_Browse_MaxUndoCount); 
     // ����������� ���������
    Application.HintHidePause := SettingValueInt(ISettingID_Gen_TooltipDisplTime);
     // ����������� ����/������ ������������
     // -- �����������������
    ApplyToolbarSettings(dkTop);
    ApplyToolbarSettings(dkLeft);
    ApplyToolbarSettings(dkRight);
    ApplyToolbarSettings(dkBottom);
     // -- ������ ������ �������� ������
    case SettingValueInt(ISettingID_Gen_ToolbarBtnSize) of
      0: tbMain.Images := ilActionsSmall;
      1: begin
        MakeImagesLoaded('PNG_MIDDLE_IMAGES', ilActionsMiddle);
        tbMain.Images := ilActionsMiddle;
      end;
      2: begin
        MakeImagesLoaded('PNG_LARGE_IMAGES', ilActionsLarge);
        tbMain.Images := ilActionsLarge;
      end;
    end;
     // ����������� ������ �����
    ApplyTreeSettings(tvGroups);
    tvGroups.HintMode := GTreeHintModeToVTHintMode(TGroupTreeHintMode(SettingValueInt(ISettingID_Browse_GT_Hints)));
    FGroupTreeHintProps := IntToGroupProps(SettingValueInt(ISettingID_Browse_GT_HintProps));
     // ��������� ����� �����������
    UpdateFlatModeAction; 
     // ����������� Viewer
    with Viewer do begin
      BeginUpdate;
      try
        ThumbBackBorderStyle  := TThumbBackBorderStyle(SettingValueInt(ISettingID_Browse_ViewerThBordSt));
        ThumbBackBorderColor  := SettingValueInt (ISettingID_Browse_ViewerThBordCl);
        Color                 := SettingValueInt (ISettingID_Browse_ViewerBkColor);
        ThumbBackColor        := SettingValueInt (ISettingID_Browse_ViewerThBColor);
        ThumbFontColor        := SettingValueInt (ISettingID_Browse_ViewerThFColor);
        ThumbShadowVisible    := SettingValueBool(ISettingID_Browse_ViewerThShadow);
        ThumbShadowBlurRadius := SettingValueInt(ISettingID_Browse_ViewerThShRadius);
        ThumbShadowOffset     := Point(SettingValueInt(ISettingID_Browse_ViewerThShOffsX), SettingValueInt(ISettingID_Browse_ViewerThShOffsY));
        ThumbShadowColor      := SettingValueInt(ISettingID_Browse_ViewerThShColor);
        ThumbShadowOpacity    := SettingValueInt(ISettingID_Browse_ViewerThShOpact);
        ShowThumbTooltips     := SettingValueBool(ISettingID_Browse_ViewerTooltips);
        ThumbTooltipProps     := IntToPicProps(SettingValueInt(ISettingID_Browse_ViewerTipProps));
        SetupViewerCorner(tcLeftTop,     ISettingID_Browse_ViewerThLTProp);
        SetupViewerCorner(tcRightTop,    ISettingID_Browse_ViewerThRTProp);
        SetupViewerCorner(tcLeftBottom,  ISettingID_Browse_ViewerThLBProp);
        SetupViewerCorner(tcRightBottom, ISettingID_Browse_ViewerThRBProp);
      finally
        EndUpdate;
      end;
    end;
     // ��������� �����������
    if RootSetting.Settings[ISettingID_Tools].Modified then ApplyTools;
     // �������� ��� ��������� ��� �����������
    RootSetting.Modified := False;
  end;

  procedure TfMain.ApplyTools;
  var
    i: Integer;
    Tool: TPhoaToolSetting;
  begin
     // �� �������
    giTools_ToolsMenu.Clear;
    giTools_GroupsMenu.Clear;
    giTools_PicsMenu.Clear;
     // ��������� �����������
    for i := 0 to RootSetting.Settings[ISettingID_Tools].ChildCount-1 do begin
      Tool := RootSetting.Settings[ISettingID_Tools].Children[i] as TPhoaToolSetting;
      if ptuToolsMenu         in Tool.Usages then AddToolItem(Tool, giTools_ToolsMenu,  ToolItemClick);
      if ptuGroupPopupMenu    in Tool.Usages then AddToolItem(Tool, giTools_GroupsMenu, ToolItemClick);
      if ptuThViewerPopupMenu in Tool.Usages then AddToolItem(Tool, giTools_PicsMenu,   ToolItemClick);
    end;
  end;

  procedure TfMain.BeginOperation;
  var Group: IPhotoAlbumPicGroup;
  begin
    if FOpLockCounter=0 then begin
      ResetMode;
       // ���������� ���������� ��������� ��������
      FOpChanges := [];
       // ��������� ID ������� ������
      Group := CurGroup;
      if Group=nil then FSavedGroupID := 0 else FSavedGroupID := Group.ID;
       // ��������� ��������� ����������� Viewer
      FViewerDisplayData := FViewer.SaveDisplay;
    end;
    Inc(FOpLockCounter);
  end;

  procedure TfMain.bUndoPopup(Sender: TTBCustomItem; FromLink: Boolean);
  var i: Integer;
  begin
    ulToolbarUndo.Strings.Clear;
    for i := FUndo.Count-1 downto 0 do ulToolbarUndo.Strings.Add(FUndo[i].Name);
     // Initialize tbxlToolbarUndo.Caption
    ulToolbarUndoChange(nil);
  end;

  function TfMain.CheckSave: Boolean;
  var mbr: TMessageBoxResults;
  begin
    Result := FUndo.IsUnmodified;
    if not Result then begin
      mbr := PhoaMsgBox(mbkConfirm, 'SConfirm_FileNotSaved', [DisplayFileName], True, False, [mbbYes, mbbNo, mbbCancel]);
      if mbrYes in mbr then begin
        aSave.Execute;
        Result := FUndo.IsUnmodified;
      end else if mbrNo in mbr then
        Result := True;
    end;
  end;

  procedure TfMain.CMFocusChanged(var Msg: TCMFocusChanged);
  begin
    EnableActions;
  end;

  procedure TfMain.DisplaySearchResults(bForceRemove, bDoSelectNode: Boolean);
  begin
    if bForceRemove then FSearchResults.PicsX.Clear;
     // ���� ���� ����������, ������, ����� ���� ������ �����������
    if FSearchResults.Pics.Count>0 then begin
      if FSearchNode=nil then FSearchNode := tvGroups.AddChild(nil);
       // ���� ���� �������� ����
      if bDoSelectNode then ActivateVTNode(tvGroups, FSearchNode);
     // ���� ��� ����������� - ������, ����� ��� �� ����
    end else if FSearchNode<>nil then begin
      tvGroups.DeleteNode(FSearchNode);
      FSearchNode := nil;
    end;
  end;

  procedure TfMain.dklcMainLanguageChanged(Sender: TObject);
  begin
    dkTop.EndUpdate;
    dkLeft.EndUpdate;
    dkRight.EndUpdate;
    dkBottom.EndUpdate;
    ApplyLanguage;
  end;

  procedure TfMain.dklcMainLanguageChanging(Sender: TObject);
  begin
    ResetMode;
    dkTop.BeginUpdate;
    dkLeft.BeginUpdate;
    dkRight.BeginUpdate;
    dkBottom.BeginUpdate;
  end;

  procedure TfMain.DoEnableTools(Item: TTBCustomItem);
  begin
     // ���� ����� �������� ���������-�����������
    if Item.Count>0 then
       // ������ ������ ������ �� ����������� � ����������� ����������� ������������
      AdjustToolAvailability(RootSetting.Settings[ISettingID_Tools] as TPhoaToolPageSetting, Item, GetSelectedPics);
  end;

  procedure TfMain.DoLoad(const sFileName: String);
  begin
    tvGroups.BeginSynch;
    try
      tvGroups.BeginUpdate;
      StartWait;
      try
        try
           // ���������� ���������� ������
          DisplaySearchResults(True, False);
           // ��������� ����
          FProject.LoadFromFile(ExpandUNCFileName(sFileName));
          UpdateThumbnailSize;
           // ������� ����� ������
          FUndo.Clear;
          FUndo.SetSavepoint;
           // ������������ ���� � ������ MRU
          mruOpen.Add(sFileName);
        finally
           // ����������� ������ �������������
          ReloadViewList;
        end;
      finally
        StopWait;
        tvGroups.EndUpdate;
      end;
    finally
      tvGroups.EndSynch;
    end;
  end;

  procedure TfMain.DoSave(const sFileName: String; iRevisionNumber: Integer);
  begin
     // ������������� ������������, ���� �� ��������� � ����� ������ �������
    if (iRevisionNumber<IPhFileRevisionNumber) and not PhoaConfirm(True, 'SConfirm_SavingOldFormatFile', ISettingID_Dlgs_ConfmOldFile) then Exit;
    StartWait;
    try
      FProject.SaveToFile(sFileName, SProject_Generator, SProject_Remark, iRevisionNumber);
      FUndo.SetSavepoint;
    finally
      StopWait;
    end;
     // ������������ ��� ����� � ������ MRU
    mruOpen.Add(sFileName);
    EnableActions;
  end;

  procedure TfMain.EnableActions;
  const asUnmod: Array[Boolean] of String[1] = ('*', '');
  var
    bGr, bPic, bPics, bPicSel, bView: Boolean;
    FCtl: TPhoaAppFocusedControl;
    gnk: TGroupNodeKind;
  begin
    if not FInitialized or (csDestroying in ComponentState) or (tsUpdating in tvGroups.TreeStates) or Viewer.UpdateLocked then Exit;
     // ���������� ��������������� �������
    FCtl := FocusedControl;
    bGr  := FCtl=pafcGroupTree;
    bPic := FCtl=pafcThumbViewer;
     // ���������� ������� ���������� ��������
    gnk := GetNodeKind(tvGroups, tvGroups.FocusedNode);
    bPics   := FProject.Pics.Count>0;
    bPicSel := Viewer.SelectedPics.Count>0;
    bView   := FProject.ViewIndex>=0;
     // ����������� Actions/Menus
    aUndo.Caption := ConstVal(iif(FUndo.CanUndo, 'SUndoActionTitle', 'SCannotUndo'), [FUndo.LastOpName]);
    aUndo.Enabled                := FUndo.CanUndo;
    smUndoHistory.Enabled        := FUndo.CanUndo;
    aNewGroup.Enabled            := gnk in [gnkPhoA, gnkPhoaGroup];
    aNewPic.Enabled              := gnk in [gnkPhoA, gnkPhoaGroup];
    aDelete.Enabled              := (bGr and (gnk=gnkPhoaGroup)) or (bPic and (gnk in [gnkPhoA, gnkPhoaGroup]) and bPicSel);
    aEdit.Enabled                := (bGr and (gnk in [gnkPhoA, gnkPhoaGroup, gnkView])) or (bPic and (gnk in [gnkPhoA, gnkPhoaGroup, gnkSearch]) and bPicSel and not bView);
    aCut.Enabled                 := (gnk in [gnkPhoA, gnkPhoaGroup]) and bPicSel and (wClipbrdPicFormatID<>0);
    aCopy.Enabled                := bPicSel and (wClipbrdPicFormatID<>0);
    aPaste.Enabled               := (gnk in [gnkPhoA, gnkPhoaGroup]) and Clipboard.HasFormat(wClipbrdPicFormatID);
    aSortPics.Enabled            := (gnk in [gnkPhoA, gnkPhoaGroup, gnkSearch]) and bPics;
    aSelectAll.Enabled           := (gnk<>gnkNone) and (Viewer.SelectedPics.Count<CurGroup.Pics.Count);
    aSelectNone.Enabled          := bPicSel;
    aView.Enabled                := Viewer.ItemIndex>=0;
    aViewSlideShow.Enabled       := Viewer.ItemIndex>=0;
    aRemoveSearchResults.Enabled := FSearchNode<>nil;
    aPicOps.Enabled              := (gnk in [gnkPhoA, gnkPhoaGroup]) and bPicSel;
    aFileOperations.Enabled      := bPics;
    aFind.Enabled                := bPics;
     // Views
    aPhoaView_Delete.Enabled     := bView;
    aPhoaView_Edit.Enabled       := bView;
    aPhoaView_MakeGroup.Enabled  := bView;
     // Drag-and-drop
    Viewer.DragEnabled       := (gnk in [gnkPhoA, gnkPhoaGroup, gnkSearch]) and SettingValueBool(ISettingID_Browse_ViewerDragDrop);
    Viewer.DragInsideEnabled := gnk in [gnkPhoA, gnkPhoaGroup];
     // �����������
    EnableTools;
     // ����������� Captions
    Caption := Format('[%s%s] - %s', [ExtractFileName(DisplayFileName), asUnmod[FUndo.IsUnmodified], ConstVal('SAppCaption')]);
    Application.Title := Caption;
    sbarMain.Panels[1].Caption := ConstVal('SPicCount',         [FProject.Pics.Count]);
    sbarMain.Panels[2].Caption := ConstVal('SSelectedPicCount', [Viewer.SelectedPics.Count]);
  end;

  procedure TfMain.EnableTools;
  begin
     // ����������� ����������� ���� "������"
    DoEnableTools(giTools_ToolsMenu);
     // ���������� ����� ������������ popup-����
    FGroupsPopupToolsValidated := False;
    FPicsPopupToolsValidated   := False;
  end;

  procedure TfMain.EndOperation(Changes: TPhoaOperationChanges);
  begin
    Assert(FOpLockCounter>0, 'Excessive TfMain.EndOperation() call');
    Dec(FOpLockCounter);
     // ����������� ���������, �������� ���������
    FOpChanges := FOpChanges+Changes;
    if FOpLockCounter=0 then begin
       // ������������ ������������� ��������� ���� ��������
      ProcessOpChanges(FOpChanges);
       // ���� ������ �� ����������, ��������������� ��������� �����������
      if (CurGroup<>nil) and (CurGroup.ID=FSavedGroupID) then FViewer.RestoreDisplay(FViewerDisplayData);
      FViewerDisplayData := nil;
      EnableActions;
    end;
  end;

  function TfMain.FindGroupNodeByID(iGroupID: Integer): PVirtualNode;
  begin
    Result := tvGroups.GetFirst;
    while Result<>nil do begin
      if PPhotoAlbumPicGroup(tvGroups.GetNodeData(Result))^.ID=iGroupID then Exit;
      Result := tvGroups.GetNext(Result);
    end;
  end;

  procedure TfMain.FormActivate(Sender: TObject);
  begin
     // ���� ���� ������ ���������, ������ ������� ���� ������ ����  
    KeepBehindProgressWnd(Handle);
  end;

  procedure TfMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
    ResetMode;
     // ���� ��� ������������ ������ - ��������� ������������� ����������� �������������
    if FUndo.IsUnmodified then
      CanClose := PhoaConfirm(False, 'SConfirm_AppExit', ISettingID_Dlgs_ConfmAppExit)
     // ����� ����������, ��������� �� ������ 
    else
      CanClose := CheckSave;
  end;

  procedure TfMain.FormCreate(Sender: TObject);
  begin
    try
       // ����������� ������ �������
      ShortTimeFormat := 'hh:nn';
      LongTimeFormat  := 'hh:nn:ss';
       // ����������� fpMain
      fpMain.IniFileName := SRegRoot;
      fpMain.IniSection  := SRegMainWindow_Root;
       // ������ ����������
      FProject := NewPhotoAlbumProject;
       // ����������� Application
      Application.OnHint      := AppHint;
      Application.OnException := AppException;
      Application.OnIdle      := AppIdle;
       // ������ ������ - ������ ����������� ������
      FSearchResults := NewPhotoAlbumPicGroup(nil, IGroupID_SearchResults);
       // Create undoable operations list
      FUndo := TPhoaUndo.Create;
       // Create viewer
      FViewer := TThumbnailViewer.Create(Self);
      with FViewer do begin
        Parent            := Self;
        Align             := alClient;
        //#TODO: ���������� DisplayMode := tvdmDetail ��� tvdmTile;
        DragCursor        := crDragMove;
        PopupMenu         := pmPics;
        OnDragDrop        := ViewerDragDrop;
        OnSelectionChange := ViewerSelectionChange;
        OnStartViewMode   := aaView;
      end;
       // Add self to the clipboard viewer chain
      FHNextClipbrdViewer := SetClipboardViewer(Handle);
       // ��������� ���������
      ShowProgressInfo('SMsg_ApplyingSettings', []);
      RootSetting.Modified := True;
      ApplySettings;
      ApplyLanguage;
       // ����������� ������ �����
      tvGroups.BeginSynch;
      try
        tvGroups.NodeDataSize  := SizeOf(Pointer);
        tvGroups.RootNodeCount := 1;
         // ������������ ��������� ��������� ������
        ProcessCommandLine;
      finally
        tvGroups.EndSynch;
      end;
    finally
      FInitialized := True;
    end;
  end;

  procedure TfMain.FormDestroy(Sender: TObject);
  begin
     // Remove self from the clipboard viewer chain
    ChangeClipboardChain(Handle, FHNextClipbrdViewer);
    FViewer.Free;
    FViewerDisplayData := nil;
    FViewedPics        := nil;
    FSearchResults     := nil;
    FProject           := nil;
    FUndo.Free;
  end;

  procedure TfMain.fpMainRestorePlacement(Sender: TObject);
  begin
     // Load history
    mruOpen.LoadFromRegIni(fpMain.RegIniFile, SRegOpen_FilesMRU);
     // Load toolbars
    TBRegLoadPositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegMainWindow_Toolbars);
  end;

  procedure TfMain.fpMainSavePlacement(Sender: TObject);
  begin
     // Save toolbars
    TBRegSavePositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegMainWindow_Toolbars);
     // Save history
    mruOpen.SaveToRegIni(fpMain.RegIniFile, SRegOpen_FilesMRU);
  end;

  function TfMain.GetCurGroup: IPhotoAlbumPicGroup;
  var p: PPhotoAlbumPicGroup;
  begin
    p := tvGroups.GetNodeData(tvGroups.FocusedNode);
    if p=nil then Result := nil else Result := p^;
  end;

  function TfMain.GetDisplayFileName: String;
  begin
    Result := FileName;
    if Result='' then Result := SDefaultFName;
  end;

  function TfMain.GetFileName: String;
  begin
    Result := FProject.FileName;
  end;

  function TfMain.GetFocusedControl: TPhoaAppFocusedControl;
  begin
    if tvGroups.Focused     then Result := pafcGroupTree
    else if FViewer.Focused then Result := pafcThumbViewer
    else                         Result := pafcNone;
  end;

  function TfMain.GetNodeKind(Tree: TBaseVirtualTree; Node: PVirtualNode): TGroupNodeKind;
  var g: IPhotoAlbumPicGroup;
  begin
    Result := gnkNone;
    if Node<>nil then begin
      g := PPhotoAlbumPicGroup(Tree.GetNodeData(Node))^;
      if g.Owner=nil then begin
        if g.ID=IGroupID_SearchResults then Result := gnkSearch
        else if g=FProject.RootGroupX  then Result := gnkPhoA
        else if FProject.ViewIndex>=0  then Result := gnkView;
      end else
        if FProject.ViewIndex>=0 then Result := gnkViewGroup else Result := gnkPhoaGroup;
    end;
  end;

  function TfMain.GetSelectedPics: IPhoaPicList;
  begin
    case FocusedControl of
      pafcGroupTree:   Result := FViewedPics;
      pafcThumbViewer: Result := Viewer.SelectedPics;
      else             Result := nil;
    end;
  end;

  function TfMain.IApp_GetImageList: TCustomImageList;
  begin
    Result := ilActionsSmall;
  end;

  function TfMain.IApp_GetProject: IPhotoAlbumProject;
  begin
    Result := FProject;
  end;

  function TfMain.IApp_GetSelectedPics: IPhotoAlbumPicList;
  begin
    Result := FViewer.SelectedPics;
  end;

  function TfMain.IApp_GetViewedPics: IPhotoAlbumPicList;
  begin
    Result := FViewedPics;
  end;

  function TfMain.IsShortCut(var Message: TWMKey): Boolean;
  begin
     // ��������� Shortcuts � �������� �������������� ������ � ������ �����
    if tvGroups.IsEditing then Result := False else Result := inherited IsShortCut(Message);
  end;

  procedure TfMain.LoadGroupTree;
  begin
    ResetMode;
    tvGroups.BeginUpdate;
    try
      tvGroups.ReinitChildren(nil, True);
      ActivateVTNode(tvGroups, tvGroups.GetFirst);
    finally
      tvGroups.EndUpdate;
    end;
    RefreshViewer;
  end;

  procedure TfMain.mruOpenClick(Sender: TObject; const Filename: String);
  begin
    ResetMode;
    if CheckSave then DoLoad(FileName);
  end;

  procedure TfMain.pmGroupsPopup(Sender: TObject);
  begin
    if not FGroupsPopupToolsValidated then begin
      DoEnableTools(giTools_GroupsMenu);
      FGroupsPopupToolsValidated := True;
    end;
  end;

  procedure TfMain.pmPicsPopup(Sender: TObject);
  begin
    if not FPicsPopupToolsValidated then begin
      DoEnableTools(giTools_PicsMenu);
      FPicsPopupToolsValidated := True;
    end;
  end;

  procedure TfMain.ProcessCommandLine;
  var
    sPhoaFile: String;
    CmdLine: TPhoaCommandLine;
    ImgViewInitFlags: TImgViewInitFlags;

     // �������� � �������� �������� �������� �������������, ���� sViewName<>''
    procedure SelectViewByName(const sViewName: String);
    begin
      if sViewName<>'' then begin
        FProject.ViewIndex := FProject.Views.IndexOfName(sViewName);
        UpdateViewIndex;
      end
    end;

     // �������� � �������� ������� �������� ������ � ������, ���� sGroupPath<>''
    procedure SelectGroupByPath(const sGroupPath: String);
    begin
      if sGroupPath<>'' then CurGroup := FProject.ViewRootGroupX.GroupByPathX[sGroupPath];
    end;

     // �������� ����������� � �������� ID
    procedure SelectPicByID(iID: Integer);
    begin
      if (iID>0) and (CurGroup<>nil) then begin
        Viewer.ItemIndex := CurGroup.Pics.IndexOfID(iID);
        Viewer.ScrollIntoView;
      end;
    end;

  begin
     // ��������� ��������� ��������� ������
    CmdLine := TPhoaCommandLine.Create;
    try
       // ���� ������ ���� - ��������� ���
      if clkOpenPhoa in CmdLine.Keys then begin
        sPhoaFile := CmdLine.KeyValues[clkOpenPhoa];
        ShowProgressInfo('SMsg_LoadingPhoa', [ExtractFileName(sPhoaFile)]);
        DoLoad(sPhoaFile);
         // -- ���� ������� ������������� - �������� ���
        if clkSelectView  in CmdLine.Keys then SelectViewByName(CmdLine.KeyValues[clkSelectView]);
         // -- ���� ������� ������ - ���� � �������� �
        if clkSelectGroup in CmdLine.Keys then SelectGroupByPath(CmdLine.KeyValues[clkSelectGroup]);
         // -- ���� ������ ID ����������� - ���� � �������� ���
        if clkSelectPicID in CmdLine.Keys then SelectPicByID(StrToIntDef(CmdLine.KeyValues[clkSelectPicID], 0));
         // -- ���� ������ ����� ���������, ������� ����������������� �����
        if clkViewMode in CmdLine.Keys then begin
          ImgViewInitFlags := [];
           // ---- �������� �������
          if clkSlideShow   in CmdLine.Keys then Include(ImgViewInitFlags, ivifSlideShow);
           // ---- ������������� �����
          if clkFullScreen  in CmdLine.Keys then
            if CmdLine.KeyValues[clkFullScreen]='0' then
              Include(ImgViewInitFlags, ivifForceWindow)
            else
              Include(ImgViewInitFlags, ivifForceFullscreen);
           // ---- ���������� ���������� ��������� � ������������� ����� � ����� ���������
          PostMessage(Handle, WM_STARTVIEWMODE, Byte(ImgViewInitFlags), 0);
        end;
       // ����� ������ ����� ������
      end else
        aNew.Execute;
    finally
      CmdLine.Free;
    end;
    EnableActions;
  end;

  procedure TfMain.ProcessOpChanges(Changes: TPhoaOperationChanges);
  begin
     // ���������� �������� ������� - ��� ���������� ������ ������� �������
    if pocProjectProps in Changes then UpdateThumbnailSize;
     // ��������� ������ ����������� ������� - ���������� ���������� ������
    if pocProjectPicList in Changes then DisplaySearchResults(True, False);
     // ��������� ������ ������������� - ����������� ���, ��������� ������ ������������� � ����������� ������/Viewer
    if pocViewList in Changes then
      ReloadViewList
     // ��������� ������ ������������� - ��������� ��� � ����������� ������/Viewer
    else if pocViewIndex in Changes then
      UpdateViewIndex
     // ���������� ��������� ����� - ����������� ������ � Viewer
    else if pocGroupStructure in Changes then
      LoadGroupTree
    else begin
       // ��������� ������� ������/������ ����������� - ���� ������ �������� ������ ���� ������
      if [pocGroupProps, pocGroupPicList]*Changes<>[] then tvGroups.InvalidateChildren(nil, True);
       // ��������� ������ ����������� ������ - ����������� Viewer
      if pocGroupPicList in Changes then
        RefreshViewer
       // ���������� ������ �������� �����������
      else if pocPicProps in Changes then begin
         // �������������� Viewer
        FViewer.Invalidate;
         // ���������� ������������� (������������� ������������� �� ��, ��� ������ ��-�� ����������� ��� �����������
         //   ������������� ������! ����� ����� ����������� ����� � ������)
        FProject.Views.Invalidate;
      end;
    end;
  end;

  procedure TfMain.RefreshViewer;
  var UniquePics, ViewPics: IPhotoAlbumPicList;

    procedure RecursivelyAddPics(Group: IPhotoAlbumPicGroup);
    var
      i: Integer;
      bDoAdd: Boolean;
      Pic: IPhoaPic;
    begin
       // ��������� ������ �� ����������� ������
      for i := 0 to Group.Pics.Count-1 do begin
        Pic := Group.Pics[i];
         // ��������� �� ���������
        UniquePics.Add(Pic, True, bDoAdd);
         // ��������� (�� ��������� ��� ���������)
        if bDoAdd then ViewPics.Add(Pic, False);
      end;
       // ��������� �� �� ��� ��������� �����
      for i := 0 to Group.Groups.Count-1 do RecursivelyAddPics(Group.GroupsX[i]);
    end;

  begin
    FViewedPics := nil;
     // ���� ���� ������� ������
    if CurGroup<>nil then
       // �� ����������� �����
      if not SettingValueBool(ISettingID_Browse_FlatMode) then
        FViewedPics := CurGroup.PicsX
       // ����������� �����
      else begin
         // ������ ��������� [�������������] ������ �����������, ����� ������ ��������� ��� ����������� �����������
        UniquePics := NewPhotoAlbumPicList(True);
         // ������ ������ ����������� ��� ���������
        ViewPics := NewPhotoAlbumPicList(False);
         // ���������� ��������� ������
        RecursivelyAddPics(CurGroup);
         // ��������� ������
        FViewedPics := ViewPics;
      end;
     // ��������� �����
    FViewer.ReloadPicList(FViewedPics);
    EnableActions;
  end;

  procedure TfMain.ReloadViewList;
  var
    i: Integer;
    tbi: TTBXItem;
  begin
     // ������� ��� ������ ���������������� �������������
    gipmPhoaViewViews.Clear;
     // ��������� ������ ������������� �����������
    for i := 0 to FProject.Views.Count-1 do begin
      tbi := TTBXItem.Create(Self);
      with tbi do begin
        Caption    := FProject.Views[i].Name;
        ImageIndex := iiView;
        Tag        := i+1; // Tag=0 � ������ iPhoaView_SetDefault ("������ �����������")
        OnClick    := SetPhoaViewClick;
      end;
      gipmPhoaViewViews.Add(tbi);
    end;
     // ��������� ������ �������� �������������
    UpdateViewIndex;
  end;

  procedure TfMain.ResetMode;
  begin
     // ��������� inplace-�������������� ������ ���� � ������ �����
    tvGroups.EndEditNode;
  end;

  procedure TfMain.SetCurGroup(Value: IPhotoAlbumPicGroup);
  var n: PVirtualNode;
  begin
     // ���������� ����, ���� �� �����
    if Value<>nil then begin
      n := tvGroups.GetFirst;
      while (n<>nil) and (PPhotoAlbumPicGroup(tvGroups.GetNodeData(n))^<>Value) do n := tvGroups.GetNext(n);
    end else
      n := nil;
     // ������������
    ActivateVTNode(tvGroups, n);
  end;

  procedure TfMain.SetFileName(const Value: String);
  begin
    FProject.FileName := Value;
  end;

  procedure TfMain.SetGroupExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var p: PPhotoAlbumPicGroup;
  begin
    if tsUpdating in tvGroups.TreeStates then Exit;
    p := Sender.GetNodeData(Node);
    if (p<>nil) then p^.Expanded := Sender.Expanded[Node];
  end;

  procedure TfMain.SetPhoaViewClick(Sender: TObject);
  begin
    FProject.ViewIndex := TComponent(Sender).Tag-1;
    UpdateViewIndex;
  end;

  procedure TfMain.StartViewMode(InitFlags: TImgViewInitFlags);
  var iPicIndex: Integer;
  begin
    iPicIndex := Viewer.ItemIndex;
    if (FViewedPics<>nil) and (iPicIndex>=0) then begin
      ResetMode;
      ViewImage(InitFlags, Self, iPicIndex, FUndo);
      Viewer.ItemIndex := iPicIndex;
    end;
  end;

  procedure TfMain.ToolItemClick(Sender: TObject);
  begin
     // ������ ������ ������ �� ����������� � ��������� ����������
    (RootSetting.Settings[ISettingID_Tools][TComponent(Sender).Tag] as TPhoaToolSetting).Execute(GetSelectedPics);
  end;

  procedure TfMain.tvGroupsBeforeItemErase(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var ItemColor: TColor; var EraseAction: TItemEraseAction);
  begin
    if GetNodeKind(tvGroups, Node) in [gnkPhoA, gnkView] then begin
      ItemColor := clBtnFace;
      EraseAction := eaColor;
    end;
  end;

  procedure TfMain.tvGroupsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    RefreshViewer;
  end;

  procedure TfMain.tvGroupsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var p: TPoint;
  begin
    ResetMode;
    if GetNodeKind(tvGroups, Node) in [gnkPhoA, gnkView] then begin
      with Sender.GetDisplayRect(Node, -1, False) do p := Sender.ClientToScreen(Point(Left, Bottom));
      pmPhoaView.Popup(p.x, p.y);
    end;
  end;

  procedure TfMain.tvGroupsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
  begin
     // ������ ��������� ���� ����������� � ����������� ������
    Allowed := Sender.NodeParent[Node]<>nil;
  end;

  procedure TfMain.tvGroupsCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
  begin
    Sender.NodeHeight[Node] := 20;
    EditLink := TStringEditLink.Create;
  end;

  procedure TfMain.tvGroupsDragAllowed(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
  begin
     // ������������� ����� ������ ��� ����������� ����� � ������ ���� ������
    Allowed := (FProject.ViewIndex<0) and (Sender.NodeParent[Node]<>nil);
  end;

  procedure TfMain.tvGroupsDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  var
    nSrc, nTgt: PVirtualNode;
    gTgt: IPhotoAlbumPicGroup;
    iNewIndex, iCnt, iCntBefore: Integer;
    bCopy: Boolean;
    Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    nSrc := Sender.FocusedNode;
    nTgt := Sender.DropTargetNode;
     // �������������� ������
    if Sender=Source then begin
       // ��������� � �������� � nTgt ������ ��������, � iNewIndex - ����� ������ � ��������, � AM - ����� �����������
      case Mode of
        dmAbove: begin
          iNewIndex := nTgt.Index;
          nTgt := nTgt.Parent;
        end;
        dmBelow: begin
          iNewIndex := nTgt.Index+1;
          nTgt := nTgt.Parent;
        end;
        else {dmOnNode} iNewIndex := -1;
      end;
       // ���� ���������� ����� � ����� ����� ����� ���� �� ��������, ��������� ������ �� 1
      if (Mode in [dmAbove, dmBelow]) and (nTgt=nSrc.Parent) and (iNewIndex>Integer(nSrc.Index)) then Dec(iNewIndex);
       // ����������
      BeginOperation;
      try
        TPhoaOp_GroupDragAndDrop.Create(
          FUndo,
          FProject,
          PPhotoAlbumPicGroup(Sender.GetNodeData(nSrc))^, // Group being dragged
          PPhotoAlbumPicGroup(Sender.GetNodeData(nTgt))^, // New parent group
          iNewIndex,
          Changes);
      finally
        EndOperation(Changes);
      end;
      Effect := DROPEFFECT_NONE;
     // �������������� �����������
    end else if Source=Viewer then begin
      bCopy := (ssCtrl in Shift) or (GetNodeKind(tvGroups, nSrc)=gnkSearch);
      gTgt := PPhotoAlbumPicGroup(Sender.GetNodeData(nTgt))^;
      iCnt := Viewer.SelectedPics.Count;
      iCntBefore := gTgt.Pics.Count;
      BeginOperation;
      try
        TPhoaOp_PicDragAndDropToGroup.Create(FUndo, FProject, CurGroup, gTgt, Viewer.SelectedPics, bCopy, Changes);
      finally
        EndOperation(Changes);
      end;
      PhoaInfo(
        False,
        iif(bCopy, 'SNotify_DragCopy', 'SNotify_DragMove'),
        [iCnt, gTgt.Pics.Count-iCntBefore, iCnt-(gTgt.Pics.Count-iCntBefore)],
        iif(bCopy, ISettingID_Dlgs_NotifyDragCopy, ISettingID_Dlgs_NotifyDragMove));
    end;
  end;

  procedure TfMain.tvGroupsDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
  const aPicCur: Array[Boolean] of TCursor = (crDragMove, crDragCopy);
  var
    nSrc, nTgt: PVirtualNode;
    gnkSrc, gnkTgt: TGroupNodeKind;
  begin
    Accept := False;
    nSrc := Sender.FocusedNode;
    nTgt := Sender.DropTargetNode;
    gnkSrc := GetNodeKind(tvGroups, nSrc);
    gnkTgt := GetNodeKind(tvGroups, nTgt);
     // �������������� ������
    if Sender=Source then begin
      Effect := DROPEFFECT_MOVE;
      if (gnkTgt<>gnkSearch) and (Mode in [dmAbove, dmOnNode, dmBelow]) then begin
        case Mode of
           // ��� ����� - ������ ��������� ��� ������������ � ��� ��������� �� nSrc �����
          dmAbove:  Accept := (gnkTgt<>gnkPhoA) and ((nSrc.Parent<>nTgt.Parent) or (nSrc.Index<>nTgt.Index-1));
           // �� ���� - ������ ������� � �������� ��������� ����
          dmOnNode: Accept := nSrc.Parent<>nTgt;
           // ��� ����� - ������ ��������� ��� ������������ � ��� ���������� ����� nSrc �����
          dmBelow:  Accept := (gnkTgt<>gnkPhoA) and ((nSrc.Parent<>nTgt.Parent) or (nSrc.Index<>nTgt.Index+1));
        end;
         // nTgt �� ����� ���� ������� nSrc
        while Accept and (nTgt<>nil) do begin
          Accept := nSrc<>nTgt;
          nTgt := nTgt.Parent;
        end;
      end;
     // �������������� �����������
    end else if Source=Viewer then begin
      Accept :=
        (Mode=dmOnNode) and
        (Viewer.SelectedPics.Count>0) and
        (nTgt<>nil) and
        (nTgt<>nSrc) and
        (gnkTgt<>gnkSearch);
      if Accept then Viewer.DragCursor := aPicCur[(gnkSrc=gnkSearch) or (ssCtrl in Shift)];
    end;
  end;

  procedure TfMain.tvGroupsEditCancelled(Sender: TBaseVirtualTree; Column: TColumnIndex);
  begin
    Sender.NodeHeight[Sender.FocusedNode] := 16;
  end;

  procedure TfMain.tvGroupsEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  begin
    Sender.NodeHeight[Node] := 16;
  end;

  procedure TfMain.tvGroupsEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
  begin
    Allowed := GetNodeKind(Sender, Node) in [gnkView, gnkPhoaGroup];
  end;

  procedure TfMain.tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    PPhotoAlbumPicGroup(Sender.GetNodeData(Node))^ := nil;
  end;

  procedure TfMain.tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var s: String;
  begin
    case GetNodeKind(Sender, Node) of
      gnkPhoA:      s := FProject.Description;
      gnkPhoaGroup: s := GetPicGroupPropStrs(PPhotoAlbumPicGroup(Sender.GetNodeData(Node))^, FGroupTreeHintProps, ': ', S_CRLF);
      else          s := '';
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfMain.tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  const
    aiImgIdx: Array[TGroupNodeKind] of Integer = (
      -1,             // gnkNone
      iiPhoA,         // gnkPhoA
      iiView,         // gnkView
      iiFolderSearch, // gnkSearch
      iiFolder,       // gnkPhoaGroup
      iiFolder);      // gnkViewGroup
  begin
    if Kind in [ikNormal, ikSelected] then ImageIndex := aiImgIdx[GetNodeKind(Sender, Node)];
  end;

  procedure TfMain.tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    p: PPhotoAlbumPicGroup;
    s: String;
  begin
    p := Sender.GetNodeData(Node);
    s := '';
     // Static text
    case TextType of
      ttNormal:
        case GetNodeKind(Sender, Node) of
          gnkPhoA:        s := ConstVal('SPhotoAlbumNode');
          gnkView:        s := FProject.CurrentView.Name;
          gnkSearch:      s := ConstVal('SSearchResultsNode');
          gnkPhoaGroup,
            gnkViewGroup: s := p^.Text;
        end;
      ttStatic: if p^.Pics.Count>0 then s := Format('(%d)', [p^.Pics.Count]);
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfMain.tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p, pp: PPhotoAlbumPicGroup;
  begin
    p := Sender.GetNodeData(Node);
     // ���� ������� ������
    if ParentNode<>nil then begin
      pp := Sender.GetNodeData(ParentNode);
      p^ := pp^.GroupsX[Node.Index];
     // ���� �����������/�������������
    end else if Node.Index=0 then begin
      p^ := FProject.ViewRootGroupX;
      Node.CheckType := ctButton;
     // ���� ����������� ������
    end else
      p^ := FSearchResults;
    Sender.ChildCount[Node] := p^.Groups.Count;
     // ������������� �������� ���� ��� ���� ������ ���������
    if (ParentNode=nil) or p^.Expanded then Include(InitialStates, ivsExpanded) else Sender.Expanded[Node] := False;
  end;

  procedure TfMain.tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    BeginOperation;
    try
      case GetNodeKind(Sender, Node) of
        gnkView:      TPhoaOp_ViewEdit.Create(FUndo, FProject, FProject.CurrentViewX, UnicodetoAnsiCP(NewText, cMainCodePage), nil, nil, Changes);
        gnkPhoaGroup: TPhoaOp_GroupRename.Create(FUndo, FProject, CurGroup, UnicodetoAnsiCP(NewText, cMainCodePage), Changes);
      end;
    finally
      EndOperation(Changes);
    end;
  end;

  procedure TfMain.tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    if TextType=ttStatic then TargetCanvas.Font.Color := clGrayText
    else if Sender.NodeParent[Node]=nil then TargetCanvas.Font.Style := [fsBold];
  end;

  procedure TfMain.ulToolbarUndoChange(Sender: TObject);
  begin
    tbxlToolbarUndo.UpdateCaption(ConstVal('SUndoOperationCount', [ulToolbarUndo.ItemIndex+1]));
  end;

  procedure TfMain.ulToolbarUndoClick(Sender: TObject);
  begin
    UndoOperations(FUndo.Count-ulToolbarUndo.ItemIndex-1);
  end;

  procedure TfMain.UndoOperations(Index: Integer);
  var
    i: Integer;
    Changes: TPhoaOperationChanges;
  begin
    ResetMode;
     // ������ ���� �� ��������� (� ����� �� ���������� �������), ���������� ���������
    Changes := [];
    for i := FUndo.Count-1 downto Index do FUndo[i].Undo(Changes);
     // ������������ ������������� ��������� ���� ��������
    ProcessOpChanges(Changes);
  end;

  procedure TfMain.UpdateFlatModeAction;
  begin
    aFlatMode.Checked := SettingValueBool(ISettingID_Browse_FlatMode);
  end;

  procedure TfMain.UpdateThumbnailSize;
  begin
    Viewer.ThumbnailSize := FProject.ThumbnailSize;
  end;

  procedure TfMain.UpdateViewIndex;
  var i, iIndex: Integer;
  begin
    iIndex := FProject.ViewIndex;
     // ����������� ����� � ���� �������������
    iPhoaView_SetDefault.Checked := iIndex<0;
    for i := 0 to gipmPhoaViewViews.Count-1 do gipmPhoaViewViews[i].Checked := i=iIndex;
     // ����������� ������ �����
    LoadGroupTree;
  end;

  procedure TfMain.ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
  var Changes: TPhoaOperationChanges;
  begin
    Changes := [];
    BeginOperation;
    try
      TPhoaOp_PicDragAndDropInsideGroup.Create(FUndo, FProject, CurGroup, Viewer.SelectedPics, Viewer.DropTargetIndex, Changes);
    finally
      EndOperation(Changes);
    end;
  end;

  procedure TfMain.ViewerSelectionChange(Sender: TObject);
  begin
    EnableActions;
  end;

  procedure TfMain.WMChangeCBChain(var Msg: TWMChangeCBChain);
  begin
     // ��������� ����������� ���������, �������� Platform SDK
    with Msg do
      if Remove=FHNextClipbrdViewer then begin
        Result := 0;
        FHNextClipbrdViewer := Next;
      end else
        Result := SendMessage(FHNextClipbrdViewer, WM_CHANGECBCHAIN, Remove, Next);
  end;

  procedure TfMain.WMDrawClipboard(var Msg: TWMDrawClipboard);
  begin
    EnableActions;
     // Invoke the next viewer in chain
    if FHNextClipbrdViewer<>0 then SendMessage(FHNextClipbrdViewer, WM_DRAWCLIPBOARD, 0, 0);
  end;

  procedure TfMain.WMHelp(var Msg: TWMHelp);
  begin
     // ���������� ������� Shift/Ctrl/Alt+F1
    if (GetKeyState(VK_SHIFT) or GetKeyState(VK_CONTROL) or GetKeyState(VK_MENU)) and $80=0 then begin
      ResetMode;
      HtmlHelpShowContents;
    end;
  end;

  procedure TfMain.WMStartViewMode(var Msg: TWMStartViewMode);
  begin
    StartViewMode(Msg.InitFlags);
  end;

end.
