//**********************************************************************************************************************
//  $Id: Main.pas,v 1.90 2007-06-27 18:29:08 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit Main;

interface

uses
   // GR32 must follow GraphicEx because of naming conflict between stretch filter constants
  Windows, Messages, SysUtils, Variants, Classes, Graphics, GraphicEx, GR32, Controls, Forms, Dialogs,
  ActiveX, XPMan, Registry,
  phIntf, phAppIntf, phMutableIntf, phNativeIntf, phObj, phGUIObj, phOps, ConsVars,
  phFrm, DKLang, ImgList, TB2Item, TB2MRU, TBXExtItems, Menus, TBX,
  ActnList, TBXStatusBars, VirtualTrees, TBXDkPanels, TBXLists, TB2Dock,
  TB2Toolbar;

type
   // ��������� ����������
  TAppState = (
    asInitialized,                // ������������� ��������
    asActionChangePending,        // ��������� ��������� ����������� Actions
    asFileNameChangePending,      // ��������� ��������� ����� �����
    asModifiedChangePending,      // ��������� ��������� ��������� ����������� �������
    asStatusBarInfoChangePending, // ��������� ��������� ��������� ������
    asGroupsPopupToolsValidated,  // ����������� popup-���� ����� ������ �������� �� ����������� ������� ���������� ������������
    asPicsPopupToolsValidated);   // ����������� popup-���� ������ ������ �������� �� ����������� ������� ���������� ������������

  TAppStates = set of TAppState;

  TfMain = class(TPhoaForm, IPhoaApp, IPhoaMutableApp, IPhotoAlbumApp)
    aAbout: TAction;
    aCopy: TAction;
    aCut: TAction;
    aDelete: TAction;
    aDeletePicsFromProject: TAction;
    aDeletePicsWithFiles: TAction;
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
    iDeletePicsFromProject: TTBXItem;
    iDeletePicsWithFiles: TTBXItem;
    iEdit: TTBXItem;
    iEditSep1: TTBXSeparatorItem;
    iEditSep2: TTBXSeparatorItem;
    iEditSep3: TTBXSeparatorItem;
    iEditSep4: TTBXSeparatorItem;
    iEditSep5: TTBXSeparatorItem;
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
    iViewSlideShow: TTBXItem;
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
    procedure aaAbout(Sender: TObject);
    procedure aaCopy(Sender: TObject);
    procedure aaCut(Sender: TObject);
    procedure aaDelete(Sender: TObject);
    procedure aaDeletePicFromProject(Sender: TObject);
    procedure aaDeletePicsWithFiles(Sender: TObject);
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
    procedure aaViewSlideShow(Sender: TObject);
    procedure bUndoPopup(Sender: TTBCustomItem; FromLink: Boolean);
    procedure dklcMainLanguageChanged(Sender: TObject);
    procedure dklcMainLanguageChanging(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure mruOpenClick(Sender: TObject; const Filename: String);
    procedure pmGroupsPopup(Sender: TObject);
    procedure pmPicsPopup(Sender: TObject);
    procedure SetPhoaViewClick(Sender: TObject);
    procedure tvGroupsBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
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
    procedure tvGroupsExpandedCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: WideString);
    procedure tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
    procedure tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure ulToolbarUndoChange(Sender: TObject);
    procedure ulToolbarUndoClick(Sender: TObject);
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
     // ��������� ����������
    FAppState: TAppStates;
     // Prop storage
    FViewer: TThumbnailViewer;
    FAppActionList: IPhoaActionList;
    FAppMenu: IPhoaMenu;
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
    procedure DoLoad(const wsFileName: WideString);
    procedure DoSave(const wsFileName: WideString; iRevisionNumber: Integer);
     // ������������ ��������� ��������� ������
    procedure ProcessCommandLine;
     // �������� ������� ��������� ����������
    procedure StateChanged(EnterStates: TAppStates; LeaveStates: TAppStates = []);
     // ����������� ����������� ������������ ��� ��������� ������������� ������
    procedure DoEnableTools(Item: TTBCustomItem);
     // ��������� �������� ��������
    procedure PerformOperation(const wsOpName: WideString; const aParams: Array of Variant); overload;
    procedure PerformOperation(const wsOpName: WideString; OpParams: IPhoaOperationParams); overload;
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
     // ���������� ��� ���� Node �� tvGroups
    function  GetNodeKind(Node: PVirtualNode): TGroupNodeKind;
     // ���������� ������, ��������������� ���� Node �� tvGroups
    function  GetNodeGroup(Node: PVirtualNode): IPhotoAlbumPicGroup;
     // ������������ ����� ��������� �������� ���� ���������� ��������������� ������ ����������
    procedure ProcessOpChanges(Changes: TPhoaOperationChanges);
     // �� ����������� ��������������� ��������� ����������
    procedure RestoreGUIState(iCurViewIndex, iCurGroupID: Integer; const pGroupOffset: TPoint; ViewerData: IThumbnailViewerDisplayData);
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
    procedure AppActionExecute(Action: TBasicAction; var Handled: Boolean);
    procedure AppHint(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
     // Viewer events
    procedure ViewerSelectionChange(Sender: TObject);
    procedure ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
     // IPhoaApp
    function  IPhoaApp.GetActionList     = IApp_GetActionList;
    function  IPhoaApp.GetCurGroup       = IApp_GetCurGroup;
    function  IPhoaApp.GetFocusedControl = IApp_GetFocusedControl;
    function  IPhoaApp.GetHandle         = IApp_GetHandle;
    function  IPhoaApp.GetMenu           = IApp_GetMenu;
    function  IPhoaApp.GetProject        = IApp_GetProject;
    function  IPhoaApp.GetSelectedPics   = IApp_GetSelectedPics;
    function  IPhoaApp.GetViewedPics     = IApp_GetViewedPics;
    procedure IPhoaApp.SetCurGroup       = IApp_SetCurGroup;
    function  IApp_GetActionList: IPhoaActionList; stdcall;
    function  IApp_GetCurGroup: IPhoaPicGroup; stdcall;
    function  IApp_GetFocusedControl: TPhoaAppFocusedControl; stdcall;
    function  IApp_GetHandle: Cardinal; stdcall;
    function  IApp_GetMenu: IPhoaMenu; stdcall;
    function  IApp_GetProject: IPhoaProject; stdcall;
    function  IApp_GetSelectedPics: IPhoaPicList; stdcall;
    function  IApp_GetViewedPics: IPhoaPicList; stdcall;
    procedure IApp_SetCurGroup(Value: IPhoaPicGroup); stdcall;
     // IPhoaMutableApp
    function  IPhoaMutableApp.GetActionList     = IApp_GetActionList;
    function  IPhoaMutableApp.GetCurGroup       = IApp_GetCurGroup;
    function  IPhoaMutableApp.GetFocusedControl = IApp_GetFocusedControl;
    function  IPhoaMutableApp.GetHandle         = IApp_GetHandle;
    function  IPhoaMutableApp.GetProject        = IApp_GetProject;
    function  IPhoaMutableApp.GetMenu           = IApp_GetMenu;
    function  IPhoaMutableApp.GetSelectedPics   = IApp_GetSelectedPics;
    function  IPhoaMutableApp.GetViewedPics     = IApp_GetViewedPics;
    procedure IPhoaMutableApp.SetCurGroup       = IApp_SetCurGroup;
    function  IPhoaMutableApp.GetCurGroupM      = IApp_GetCurGroupM;
    function  IPhoaMutableApp.GetProjectM       = IApp_GetProjectM;
    function  IPhoaMutableApp.GetSelectedPicsM  = IApp_GetSelectedPicsM;
    function  IPhoaMutableApp.GetViewedPicsM    = IApp_GetViewedPicsM;
    procedure IPhoaMutableApp.SetCurGroupM      = IApp_SetCurGroupM;
    function  IApp_GetCurGroupM: IPhoaMutablePicGroup;
    function  IApp_GetProjectM: IPhoaMutableProject;
    function  IApp_GetSelectedPicsM: IPhoaMutablePicList;
    function  IApp_GetViewedPicsM: IPhoaMutablePicList;
    procedure IApp_SetCurGroupM(Value: IPhoaMutablePicGroup);
     // IPhotoAlbumApp
    function  IPhotoAlbumApp.GetActionList     = IApp_GetActionList;
    function  IPhotoAlbumApp.GetCurGroup       = IApp_GetCurGroup;
    function  IPhotoAlbumApp.GetFocusedControl = IApp_GetFocusedControl;
    function  IPhotoAlbumApp.GetHandle         = IApp_GetHandle;
    function  IPhotoAlbumApp.GetMenu           = IApp_GetMenu;
    function  IPhotoAlbumApp.GetProject        = IApp_GetProject;
    function  IPhotoAlbumApp.GetSelectedPics   = IApp_GetSelectedPics;
    function  IPhotoAlbumApp.GetViewedPics     = IApp_GetViewedPics;
    procedure IPhotoAlbumApp.SetCurGroup       = IApp_SetCurGroup;
    function  IPhotoAlbumApp.GetCurGroupM      = IApp_GetCurGroupM;
    function  IPhotoAlbumApp.GetProjectM       = IApp_GetProjectM;
    function  IPhotoAlbumApp.GetSelectedPicsM  = IApp_GetSelectedPicsM;
    function  IPhotoAlbumApp.GetViewedPicsM    = IApp_GetViewedPicsM;
    procedure IPhotoAlbumApp.SetCurGroupM      = IApp_SetCurGroupM;
    procedure IPhotoAlbumApp.PerformOperation  = IApp_PerformOperation;
    function  IPhotoAlbumApp.GetCurGroupX      = IApp_GetCurGroupX;
    function  IPhotoAlbumApp.GetImageList      = IApp_GetImageList;
    function  IPhotoAlbumApp.GetProjectX       = IApp_GetProjectX;
    function  IPhotoAlbumApp.GetSelectedPicsX  = IApp_GetSelectedPicsX;
    function  IPhotoAlbumApp.GetViewedPicsX    = IApp_GetViewedPicsX;
    procedure IPhotoAlbumApp.SetCurGroupX      = IApp_SetCurGroupX;
    procedure IApp_PerformOperation(const wsOpName: WideString; const aParams: Array of Variant);
    function  IApp_GetCurGroupX: IPhotoAlbumPicGroup;
    function  IApp_GetImageList: TCustomImageList;
    function  IApp_GetProjectX: IPhotoAlbumProject;
    function  IApp_GetSelectedPicsX: IPhotoAlbumPicList;
    function  IApp_GetViewedPicsX: IPhotoAlbumPicList;
    procedure IApp_SetCurGroupX(Value: IPhotoAlbumPicGroup);
     // Message handlers
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
    procedure CMFocusChanged(var Msg: TCMFocusChanged);   message CM_FOCUSCHANGED;
    procedure WMHelp(var Msg: TWMHelp);                   message WM_HELP;
    procedure WMStartViewMode(var Msg: TWMStartViewMode); message WM_STARTVIEWMODE;
     // Prop handlers
    function  GetFileName: WideString;
    function  GetDisplayFileName: WideString;
    function  GetCurGroupID: Integer;
    procedure SetCurGroupID(Value: Integer);
  protected
    function  GetRelativeRegistryKey: WideString; override;
    function  GetSizeable: Boolean; override;
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure SettingsLoad(rif: TRegIniFile); override;
    procedure SettingsSave(rif: TRegIniFile); override;
    procedure UpdateState; override;
  public
    function  IsShortCut(var Message: TWMKey): Boolean; override;
     // ��������� ��������� ���������
    procedure ApplySettings;
     // ��������� Viewer
    procedure RefreshViewer;
     // Props
     // -- ������� ��������� ������ � ������; nil, ���� ���
    property CurGroupX: IPhotoAlbumPicGroup read IApp_GetCurGroupX write IApp_SetCurGroupX;
     // -- ID ������� ��������� ������ � ������; 0, ���� ���
    property CurGroupID: Integer read GetCurGroupID write SetCurGroupID;
     // -- ��� ����� ����������� ��� ����������� (�� ������ ������, � ����� ������ 'untitled.phoa')
    property DisplayFileName: WideString read GetDisplayFileName;
     // -- ��� �������� ����� ����������� (������ ������, ���� ����� ����������)
    property FileName: WideString read GetFileName;
     // -- ������� ��������������� �������
    property FocusedControl: TPhoaAppFocusedControl read IApp_GetFocusedControl;
     // -- ����������� �������
    property Viewer: TThumbnailViewer read FViewer;
  end;

var
  fMain: TfMain;

implementation
{$R *.dfm}
uses
  GraphicStrings, Clipbrd, Math, jpeg, TypInfo, // GraphicStrings => GraphicEx constants
  VirtualDataObject,
  phChmHlp, phUtils, phPhoa,
  udPicProps, udSettings, ufImgView, udSearch, udProjectProps, udAbout, udPicOps, udSortPics, udViewProps, udSelPhoaGroup,
  ufAddFilesWizard, udStats, udFileOpsWizard, phSettings, phValSetting,
  phToolSetting, phMsgBox, udGroupProps, phPluginUsage, phGraphics;

   // ��������� ImageList �� PNG-�������, ���� �� ��� �� ��������
  procedure MakeImagesLoaded(const wsResourceName: WideString; Images: TCustomImageList);
  var
    PNG: TPNGGraphic;
    Bmp: TBitmap;
  begin
    if Images.Count=0 then begin
       // ��������� �������� � PNG
      PNG := TPNGGraphic.Create;
      try
        PNG.LoadFromResourceName(HInstance, wsResourceName {???});
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
    ShowAbout(SettingValueBool(ISettingID_Dlgs_SplashAboutFade));
  end;

  procedure TfMain.aaCopy(Sender: TObject);
  begin
    TPhoaBaseOp_PicCopy.Create(Viewer.SelectedPics, TPicClipboardFormats(Byte(SettingValueInt(ISettingID_Gen_ClipFormats))));
  end;

  procedure TfMain.aaCut(Sender: TObject);
  begin
    TPhoaBaseOp_PicCopy.Create(Viewer.SelectedPics, TPicClipboardFormats(Byte(SettingValueInt(ISettingID_Gen_ClipFormats))));
    PerformOperation('PicDelete', ['Group', CurGroupX, 'Pics', Viewer.SelectedPics]);
  end;

  procedure TfMain.aaDelete(Sender: TObject);
  begin
    if CurGroupX<>nil then
      case FocusedControl of
         // �������� ������
        pafcGroupTree:
          if PhoaConfirm(False, 'SConfirm_DelGroup', ISettingID_Dlgs_ConfmDelGroup) then
            PerformOperation('GroupDelete', ['Group', CurGroupX]);
         // �������� �����������
        pafcThumbViewer:
          if (Viewer.SelectedPics.Count>0) and PhoaConfirm(False, 'SConfirm_DelPics', ISettingID_Dlgs_ConfmDelPics) then
            PerformOperation('PicDelete', ['Group', CurGroupX, 'Pics', Viewer.SelectedPics]);
      end;
  end;

  procedure TfMain.aaDeletePicFromProject(Sender: TObject);
  begin
    if (Viewer.SelectedPics.Count>0) and PhoaConfirm(False, 'SConfirm_DelPicsFromProject', ISettingID_Dlgs_ConfmDelPicsFromPj) then
      PerformOperation('PicDeleteFromProject', ['Pics', Viewer.SelectedPics]);
  end;

  procedure TfMain.aaDeletePicsWithFiles(Sender: TObject);
  begin
    if (Viewer.SelectedPics.Count>0) and (mbrOK in PhoaMsgBox(mbkConfirmWarning, 'SConfirm_DelPicsWithFiles', True, False, [mbbOK, mbbCancel])) then
      PerformOperation('PicDeleteWithFiles', ['Pics', Viewer.SelectedPics]);
  end;

  procedure TfMain.aaEdit(Sender: TObject);
  begin
    case FocusedControl of
       // �������������� �����
      pafcGroupTree:
        case GetNodeKind(tvGroups.FocusedNode) of
          gnkProject:   EditProject (Self, FUndo);
          gnkView:      EditView    (Self, FUndo);
          gnkPhoaGroup: EditPicGroup(Self, FUndo);
        end;
       // �������������� �����������
      pafcThumbViewer: if Viewer.SelectedPics.Count>0 then EditPics(Self, Viewer.SelectedPics, FUndo);
    end;
  end;

  procedure TfMain.aaExit(Sender: TObject);
  begin
    Close;
  end;

  procedure TfMain.aaFileOperations(Sender: TObject);
  var bProjectChanged: Boolean;
  begin
    BeginUpdate;
    try
      if DoFileOperations(Self, bProjectChanged) then begin
         // ������� ����� ������ (������ ����� �����������), �������� ������� ��������� ������������������ �������
        FUndo.SetNonUndoable(not FUndo.IsUnmodified or bProjectChanged);
         // ���� ���������� ���������� �����������, �� ����� ������������� ������������� � ����������� ������ �����
        if bProjectChanged then begin
          FProject.Views.Invalidate;
          LoadGroupTree;
        end;
        StateChanged([asActionChangePending, asModifiedChangePending]);
      end;
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.aaFind(Sender: TObject);
  begin
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
    DKWeb.Open_VerCheck;
  end;

  procedure TfMain.aaHelpContents(Sender: TObject);
  begin
    HtmlHelpShowContents;
  end;

  procedure TfMain.aaHelpFAQ(Sender: TObject);
  begin
    HtmlHelpContext(IDH_info_faq);
  end;

  procedure TfMain.aaHelpProductWebsite(Sender: TObject);
  begin
    DKWeb.Open_ViewInfo;
  end;

  procedure TfMain.aaHelpSupport(Sender: TObject);
  begin
    DKWeb.Open_Support;
  end;

  procedure TfMain.aaHelpVendorWebsite(Sender: TObject);
  begin
    DKWeb.Open_Index;
  end;

  procedure TfMain.aaIniLoadSettings(Sender: TObject);

    procedure DoIniLoad(const wsFileName: WideString);
    begin
       // ��������� ���������
      IniLoadSettings(wsFileName);
       // ��������� ���������
      BeginUpdate;
      try
        ApplySettings;
        ApplyLanguage;
      finally
        EndUpdate;
      end;
    end;

  begin
    with TTntOpenDialog.Create(Self) do
      try
        DefaultExt := SDefaultIniFileExt;
        FileName   := SDefaultIniFileName;
        Filter     := DKLangConstW('SFileFilter_Ini');
        Options    := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
        Title      := DKLangConstW('SDlgTitle_OpenIni');
        if Execute then DoIniLoad(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaIniSaveSettings(Sender: TObject);
  begin
    with TSaveDialog.Create(Self) do
      try
        DefaultExt := SDefaultIniFileExt;
        FileName   := SDefaultIniFileName;
        Filter     := DKLangConstW('SFileFilter_Ini');
        Options    := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];
        Title      := DKLangConstW('SDlgTitle_SaveIni');
        if Execute then IniSaveSettings(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaNew(Sender: TObject);
  begin
    if not CheckSave then Exit;
    BeginUpdate;
    try
       // ������� ���������� ������
      DisplaySearchResults(True, False);
       // �������������� ������
      FProject.New;
      UpdateThumbnailSize;
       // ������� ����� ������
      FUndo.Clear;
      FUndo.SetSavepoint;
      StateChanged([asActionChangePending, asModifiedChangePending]);
       // ��������� ������ �������������
      ReloadViewList;
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.aaNewGroup(Sender: TObject);
  var
    Params: IPhoaOperationParams;
    NewGroup: IPhotoAlbumPicGroup;
  begin
    Params := NewPhoaOperationParams(['Group', CurGroupX]);
    PerformOperation('GroupNew', Params);
     // ������ � ����� �������������� ����� ����������� ������
    Params.ObtainValIntf('NewGroup', IPhotoAlbumPicGroup, NewGroup);
    CurGroupX := NewGroup;
    if tvGroups.FocusedNode<>nil then tvGroups.EditNode(tvGroups.FocusedNode, -1);
  end;

  procedure TfMain.aaNewPic(Sender: TObject);
  begin
    AddFiles(Self, CurGroupX, FUndo, nil);
  end;

  procedure TfMain.aaOpen(Sender: TObject);
  begin
    with TOpenDialog.Create(Self) do
      try
        DefaultExt := SDefaultExt;
        Filter     := DKLangConstW('SFileFilter_OpenPhoa');
        Options    := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];
        Title      := DKLangConstW('SDlgTitle_OpenPhoa');
        if Execute and CheckSave then DoLoad(FileName);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaPaste(Sender: TObject);
  var iCntBefore: Integer;
  begin
    iCntBefore := CurGroupX.Pics.Count;
    PerformOperation('PicPaste', ['Group', CurGroupX]);
    PhoaInfo(False, 'SNotify_Paste', [CurGroupX.Pics.Count-iCntBefore], ISettingID_Dlgs_NotifyPaste);
  end;

  procedure TfMain.aaPhoaView_Delete(Sender: TObject);
  begin
    if PhoaConfirm(False, 'SConfirm_DelView', ISettingID_Dlgs_ConfmDelView) then PerformOperation('ViewDelete', []);
  end;

  procedure TfMain.aaPhoaView_Edit(Sender: TObject);
  begin
    EditView(Self, FUndo);
  end;

  procedure TfMain.aaPhoaView_MakeGroup(Sender: TObject);
  begin
    MakeGroupFromView(Self, FUndo);
  end;

  procedure TfMain.aaPhoaView_New(Sender: TObject);
  begin
    AddView(Self, FUndo);
  end;

  procedure TfMain.aaPicOps(Sender: TObject);
  begin
    DoPicOps(Self, FUndo);
  end;

  procedure TfMain.aaRemoveSearchResults(Sender: TObject);
  begin
    DisplaySearchResults(True, False);
  end;

  procedure TfMain.aaSave(Sender: TObject);
  begin
     // ���� ��� ����� �� ������, ��������� SaveAs. ����� ��������� ���� �����������
    if FileName='' then aSaveAs.Execute else DoSave(FProject.FileName, FProject.FileRevision);
  end;

  procedure TfMain.aaSaveAs(Sender: TObject);
  begin
    with TSaveDialog.Create(Self) do
      try
        DefaultExt  := SDefaultExt;
        Filter      := GetPhoaSaveFilter;
        FilterIndex := ValidRevisionIndex(GetIndexOfRevision(FProject.FileRevision))+1;
        Options     := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];
        Title       := DKLangConstW('SDlgTitle_SavePhoa');
        FileName    := DisplayFileName;
        if Execute then DoSave(FileName, aPhFileRevisions[ValidRevisionIndex(FilterIndex-1)].iNumber);
      finally
        Free;
      end;
  end;

  procedure TfMain.aaSelectAll(Sender: TObject);
  begin
    Viewer.SelectAll;
  end;

  procedure TfMain.aaSelectNone(Sender: TObject);
  begin
    Viewer.ClearSelection;
  end;

  procedure TfMain.aaSettings(Sender: TObject);
  begin
     // � ������� �������� �� ��������� �������� ������ "����� ������"
    if EditSettings(ISettingID_Browse) then ApplySettings;
  end;

  procedure TfMain.aaSortPics(Sender: TObject);
  begin
    DoSortPics(Self, FUndo, CurGroupX=FSearchResults);
  end;

  procedure TfMain.aaStats(Sender: TObject);
  begin
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

  procedure TfMain.AppActionExecute(Action: TBasicAction; var Handled: Boolean);
  begin
    ResetMode;
  end;

  procedure TfMain.AppException(Sender: TObject; E: Exception);
  var ws: WideString;
  begin
     // ��������� �����, ���� � ����� �� ���� ���������� (ripped from Application.ShowException)
    ws := E.Message; {!!! handle Unicode-enabled exceptions }
    if (ws<>'') and (AnsiLastChar(ws)>'.') then ws := ws+'.';
     // ����� ��������� �� ������
    PhoaMsgBox(mbkError, ws, False, False, [mbbOK]);
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
    if asInitialized in FAppState then begin
       // ������������� �������������, �.�. ��� �������� ������������ �������� �����
      FProject.Views.Invalidate;
       // �������������� ������
      tvGroups.ReinitChildren(nil, True);
      tvGroups.Invalidate;
       // ��������� ��������� ����
      StateChanged([asFileNameChangePending]);
    end;
     // ����������� Help-����
    Application.HelpFile := sApplicationPath+DKLangConstW('SHelpFileName');
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
    BeginUpdate;
    try
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
          ThumbFocusRectColor   := SettingValueInt (ISettingID_Browse_ViewerThFocusClr);
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
      StateChanged([asActionChangePending]);
    finally
      EndUpdate;
    end;
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
    StateChanged([asActionChangePending]);
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

  procedure TfMain.DoCreate;
  begin
    inherited DoCreate;
    BeginUpdate;
    try
       // ������ ����������
      FProject       := NewPhotoAlbumProject;
      FAppActionList := TPhoaActionList.Create(alMain);
      FAppMenu       := TPhoaMenuItem.Create(nil, tbMenu.Items, nil, False, True);
       // ����������� Application
      Application.OnActionExecute := AppActionExecute;
      Application.OnHint          := AppHint;
      Application.OnException     := AppException;
      Application.OnIdle          := AppIdle;
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
        tvGroups.NodeDataSize  := SizeOf(TObject);
        tvGroups.RootNodeCount := 1;
         // ������������ ��������� ��������� ������
        ProcessCommandLine;
      finally
        tvGroups.EndSynch;
      end;
    finally
      StateChanged([
        asInitialized, asActionChangePending, asFileNameChangePending, asModifiedChangePending,
        asStatusBarInfoChangePending]);
      EndUpdate;
    end;
  end;

  procedure TfMain.DoDestroy;
  begin
     // Remove self from the clipboard viewer chain
    ChangeClipboardChain(Handle, FHNextClipbrdViewer);
     // Free interfaces and destroy objects
    FAppMenu       := nil;
    FAppActionList := nil;
    FViewer.Free;
    FViewedPics    := nil;
    FSearchResults := nil;
    FProject       := nil;
    FUndo.Free;
    inherited DoDestroy;
  end;

  procedure TfMain.DoEnableTools(Item: TTBCustomItem);
  begin
     // ���� ����� �������� ���������-�����������
    if Item.Count>0 then
       // ������ ������ ������ �� ����������� � ����������� ����������� ������������
      AdjustToolAvailability(RootSetting.Settings[ISettingID_Tools] as TPhoaToolPageSetting, Item, GetSelectedPics);
  end;

  procedure TfMain.DoLoad(const wsFileName: WideString);
  begin
    BeginUpdate;
    try
      tvGroups.BeginSynch;
      try
        tvGroups.BeginUpdate;
        StartWait;
        try
          try
             // ���������� ���������� ������
            DisplaySearchResults(True, False);
             // ��������� ����
            FProject.LoadFromFile(WideExpandUNCFileName(wsFileName));
            UpdateThumbnailSize;
             // ������� ����� ������
            FUndo.Clear;
            FUndo.SetSavepoint;
             // ������������ ���� � ������ MRU
            mruOpen.Add(wsFileName); {!!! Not Unicode-enabled solution }
            StateChanged([asActionChangePending, asFileNameChangePending, asModifiedChangePending]);
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
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.DoSave(const wsFileName: WideString; iRevisionNumber: Integer);
  begin
     // ������������� ������������, ���� �� ��������� � ����� ������ �������
    if (iRevisionNumber<IPhFileRevisionNumber) and not PhoaConfirm(True, 'SConfirm_SavingOldFormatFile', ISettingID_Dlgs_ConfmOldFile) then Exit;
    BeginUpdate;
    try
      StartWait;
      try
        FProject.SaveToFile(wsFileName, SProject_Generator, SProject_Remark, iRevisionNumber);
        FUndo.SetSavepoint;
         // ������������ ��� ����� � ������ MRU
        mruOpen.Add(wsFileName); {!!! Not Unicode-enabled solution }
        StateChanged([asActionChangePending, asFileNameChangePending, asModifiedChangePending]);
      finally
        StopWait;
      end;
    finally
      EndUpdate;
    end;
  end;

  function TfMain.FindGroupNodeByID(iGroupID: Integer): PVirtualNode;
  begin
    if iGroupID=0 then
      Result := nil
    else begin
      Result := tvGroups.GetFirst;
      while (Result<>nil) and (GetNodeGroup(Result).ID<>iGroupID) do Result := tvGroups.GetNext(Result);
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

  function TfMain.GetCurGroupID: Integer;
  var Group: IPhotoAlbumPicGroup;
  begin
    Group := CurGroupX;
    if Group=nil then Result := 0 else Result := Group.ID;
  end;

  function TfMain.GetDisplayFileName: WideString;
  begin
    Result := FileName;
    if Result='' then Result := SDefaultFName;
  end;

  function TfMain.GetFileName: WideString;
  begin
    Result := FProject.FileName;
  end;

  function TfMain.GetNodeGroup(Node: PVirtualNode): IPhotoAlbumPicGroup;
  begin
    Result := PicGroupsVT_GetNodeGroup(tvGroups, Node);
  end;

  function TfMain.GetNodeKind(Node: PVirtualNode): TGroupNodeKind;
  begin
    Result := PicGroupsVT_GetNodeKind(tvGroups, Node, FProject.ViewIndex>=0);
  end;

  function TfMain.GetRelativeRegistryKey: WideString;
  begin
    Result := SRegMainWindow_Root;
  end;

  function TfMain.GetSelectedPics: IPhoaPicList;
  begin
    case FocusedControl of
      pafcGroupTree:   Result := FViewedPics;
      pafcThumbViewer: Result := Viewer.SelectedPics;
      else             Result := nil;
    end;
  end;

  function TfMain.GetSizeable: Boolean;
  begin
    Result := True;
  end;

  function TfMain.IApp_GetActionList: IPhoaActionList;
  begin
    Result := FAppActionList;
  end;

  function TfMain.IApp_GetCurGroup: IPhoaPicGroup;
  begin
    Result := GetNodeGroup(tvGroups.FocusedNode);
  end;

  function TfMain.IApp_GetCurGroupM: IPhoaMutablePicGroup;
  begin
    Result := GetNodeGroup(tvGroups.FocusedNode);
  end;

  function TfMain.IApp_GetCurGroupX: IPhotoAlbumPicGroup;
  begin
    Result := GetNodeGroup(tvGroups.FocusedNode);
  end;

  function TfMain.IApp_GetFocusedControl: TPhoaAppFocusedControl;
  begin
    if      ActiveControl=tvGroups then Result := pafcGroupTree
    else if ActiveControl=FViewer  then Result := pafcThumbViewer
    else                                Result := pafcNone;
  end;

  function TfMain.IApp_GetHandle: Cardinal;
  begin
    Result := Application.Handle;
  end;

  function TfMain.IApp_GetImageList: TCustomImageList;
  begin
    Result := ilActionsSmall;
  end;

  function TfMain.IApp_GetMenu: IPhoaMenu;
  begin
    Result := FAppMenu;
  end;

  function TfMain.IApp_GetProject: IPhoaProject;
  begin
    Result := FProject;
  end;

  function TfMain.IApp_GetProjectM: IPhoaMutableProject;
  begin
    Result := FProject;
  end;

  function TfMain.IApp_GetProjectX: IPhotoAlbumProject;
  begin
    Result := FProject;
  end;

  function TfMain.IApp_GetSelectedPics: IPhoaPicList;
  begin
    Result := FViewer.SelectedPics;
  end;

  function TfMain.IApp_GetSelectedPicsM: IPhoaMutablePicList;
  begin
    Result := FViewer.SelectedPics;
  end;

  function TfMain.IApp_GetSelectedPicsX: IPhotoAlbumPicList;
  begin
    Result := FViewer.SelectedPics;
  end;

  function TfMain.IApp_GetViewedPics: IPhoaPicList;
  begin
    Result := FViewedPics;
  end;

  function TfMain.IApp_GetViewedPicsM: IPhoaMutablePicList;
  begin
    Result := FViewedPics;
  end;

  function TfMain.IApp_GetViewedPicsX: IPhotoAlbumPicList;
  begin
    Result := FViewedPics;
  end;

  procedure TfMain.IApp_PerformOperation(const wsOpName: WideString; const aParams: array of Variant);
  begin
    PerformOperation(wsOpName, aParams);
  end;

  procedure TfMain.IApp_SetCurGroup(Value: IPhoaPicGroup);
  begin
     // ���������������� ������ �� ID
    if Value=nil then CurGroupID := 0 else CurGroupID := Value.ID;
  end;

  procedure TfMain.IApp_SetCurGroupM(Value: IPhoaMutablePicGroup);
  begin
    IApp_SetCurGroup(Value);
  end;

  procedure TfMain.IApp_SetCurGroupX(Value: IPhotoAlbumPicGroup);
  begin
    IApp_SetCurGroup(Value);
  end;

  function TfMain.IsShortCut(var Message: TWMKey): Boolean;
  begin
     // ��������� Shortcuts � �������� �������������� ������ � ������ �����
    if tvGroups.IsEditing then Result := False else Result := inherited IsShortCut(Message);
  end;

  procedure TfMain.LoadGroupTree;
  begin
    ResetMode;
    BeginUpdate;
    try
      tvGroups.BeginUpdate;
      try
        tvGroups.ReinitChildren(nil, True);
        ActivateFirstVTNode(tvGroups);
        StateChanged([asActionChangePending]);
      finally
        tvGroups.EndUpdate;
      end;
      RefreshViewer;
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.mruOpenClick(Sender: TObject; const Filename: String);
  begin
    ResetMode;
    if CheckSave then DoLoad(FileName);
  end;

  procedure TfMain.PerformOperation(const wsOpName: WideString; const aParams: Array of Variant);
  begin
    PerformOperation(wsOpName, NewPhoaOperationParams(aParams));
  end;

  procedure TfMain.PerformOperation(const wsOpName: WideString; OpParams: IPhoaOperationParams);
  var
    Changes: TPhoaOperationChanges;
    ViewerData: IThumbnailViewerDisplayData;
    iCurViewIndex, iCurGroupID: Integer;
    pGroupOffset: TPoint;
    Operation: TPhoaOperation;
    UndoStream: IPhoaUndoDataStream;
  begin
    BeginUpdate;
    try
      StartWait;
      try
         // ��������� ������� ��������� ����������
        iCurViewIndex := FProject.ViewIndex;
        iCurGroupID   := CurGroupID;
        pGroupOffset  := tvGroups.OffsetXY;
        ViewerData    := Viewer.SaveDisplay;
         // ������ (��������� ��������)
        Changes := [];
        try
          Operation := OperationFactory.NewOperation(wsOpName, FUndo, FProject, OpParams, Changes);
           // ���������� ��������� ���������� � Undo-����
          UndoStream := FUndo.UndoStream;
          Operation.GUIStateUndoDataPosition := UndoStream.Position;
          UndoStream.WriteInt(iCurViewIndex);
          UndoStream.WriteInt(iCurGroupID);
          UndoStream.WriteInt(pGroupOffset.x);
          UndoStream.WriteInt(pGroupOffset.y);
          ViewerData.SaveToDataStream(UndoStream);
        finally
           // ������������ ������������� ��������� ���� ��������
          ProcessOpChanges(Changes);
          StateChanged([asActionChangePending, asModifiedChangePending]);
        end;
         // ��������������� ��������� ����������
        RestoreGUIState(iCurViewIndex, iCurGroupID, pGroupOffset, ViewerData);
      finally
        StopWait;
      end;
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.pmGroupsPopup(Sender: TObject);
  begin
    if not (asGroupsPopupToolsValidated in FAppState) then begin
      DoEnableTools(giTools_GroupsMenu);
      StateChanged([asGroupsPopupToolsValidated]);
    end;
  end;

  procedure TfMain.pmPicsPopup(Sender: TObject);
  begin
    if not (asPicsPopupToolsValidated in FAppState) then begin
      DoEnableTools(giTools_PicsMenu);
      StateChanged([asPicsPopupToolsValidated]);
    end;
  end;

  procedure TfMain.ProcessCommandLine;
  var
    wsPhoaFile: WideString;
    CmdLine: TPhoaCommandLine;
    ImgViewInitFlags: TImgViewInitFlags;

     // �������� � �������� �������� �������� �������������, ���� sViewName<>''
    procedure SelectViewByName(const wsViewName: WideString);
    begin
      if wsViewName<>'' then begin
        FProject.ViewIndex := FProject.Views.IndexOfName(wsViewName);
        UpdateViewIndex;
      end
    end;

     // �������� � �������� ������� �������� ������ � ������, ���� sGroupPath<>''
    procedure SelectGroupByPath(const wsGroupPath: WideString);
    begin
      if wsGroupPath<>'' then CurGroupX := FProject.ViewRootGroupX.GroupByPathX[wsGroupPath];
    end;

     // �������� ����������� � �������� ID
    procedure SelectPicByID(iID: Integer);
    begin
      if (iID>0) and (CurGroupX<>nil) then begin
        Viewer.ItemIndex := CurGroupX.Pics.IndexOfID(iID);
        Viewer.ScrollIntoView;
      end;
    end;

  begin
    BeginUpdate;
    try
       // ��������� ��������� ��������� ������
      CmdLine := TPhoaCommandLine.Create;
      try
         // ���� ������ ���� - ��������� ���
        if clkOpenPhoa in CmdLine.Keys then begin
          wsPhoaFile := CmdLine.KeyValues[clkOpenPhoa];
          ShowProgressInfo('SMsg_LoadingPhoa', [WideExtractFileName(wsPhoaFile)]);
          DoLoad(wsPhoaFile);
           // -- ���� ������ ����� ������������ ���������
          if clkFlatMode in CmdLine.Keys then begin
            SetSettingValueBool(ISettingID_Browse_FlatMode, CmdLine.KeyValues[clkFlatMode]<>'0');
            UpdateFlatModeAction;
          end;
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
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.ProcessOpChanges(Changes: TPhoaOperationChanges);
  begin
    BeginUpdate;
    try
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
           // ���������� �������������
          FProject.Views.Invalidate;
           // ���� ������������ �������������, ����������� ������ ����� (����� ����������)
          if FProject.ViewIndex>=0 then LoadGroupTree;
        end;
      end;
       // �� ������������ ������?
      if pocNonUndoable in Changes then FUndo.SetNonUndoable(True);
    finally
      EndUpdate;
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
    BeginUpdate;
    try
      FViewedPics := nil;
       // ���� ���� ������� ������
      if CurGroupX<>nil then
         // �� ����������� �����
        if not SettingValueBool(ISettingID_Browse_FlatMode) then
          FViewedPics := CurGroupX.PicsX
         // ����������� �����
        else begin
           // ������ ��������� [�������������] ������ �����������, ����� ������ ��������� ��� ����������� �����������
          UniquePics := NewPhotoAlbumPicList(True);
           // ������ ������ ����������� ��� ���������
          ViewPics := NewPhotoAlbumPicList(False);
           // ���������� ��������� ������
          RecursivelyAddPics(CurGroupX);
           // ��������� ������
          FViewedPics := ViewPics;
        end;
       // ��������� �����
      FViewer.ReloadPicList(FViewedPics);
      StateChanged([asActionChangePending]);
    finally
      EndUpdate;
    end;
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

  procedure TfMain.RestoreGUIState(iCurViewIndex, iCurGroupID: Integer; const pGroupOffset: TPoint; ViewerData: IThumbnailViewerDisplayData);
  begin
    if iCurViewIndex=FProject.ViewIndex then begin
       // ��������������� ������� ������
      tvGroups.BeginUpdate;
      try
        CurGroupID := iCurGroupID;
        tvGroups.OffsetXY := pGroupOffset;
      finally
        tvGroups.EndUpdate;
      end;
       // ���� ���������� - ��������������� ��������� ������
      if CurGroupID=iCurGroupID then Viewer.RestoreDisplay(ViewerData);
    end;
  end;

  procedure TfMain.SetCurGroupID(Value: Integer);
  var n: PVirtualNode;
  begin
    n := FindGroupNodeByID(Value);
    if n=nil then n := tvGroups.GetFirst;
    ActivateVTNode(tvGroups, n);
  end;

  procedure TfMain.SetPhoaViewClick(Sender: TObject);
  begin
    FProject.ViewIndex := TComponent(Sender).Tag-1;
    UpdateViewIndex;
  end;

  procedure TfMain.SettingsLoad(rif: TRegIniFile);
  begin
    inherited SettingsLoad(rif);
     // Load history
    mruOpen.LoadFromRegIni(rif, SRegOpen_FilesMRU);
     // Load toolbars
    TBRegLoadPositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegMainWindow_Toolbars);
  end;

  procedure TfMain.SettingsSave(rif: TRegIniFile);
  begin
    inherited SettingsSave(rif);
     // Save toolbars
    TBRegSavePositions(Self, HKEY_CURRENT_USER, SRegRoot+'\'+SRegMainWindow_Toolbars);
     // Save history
    mruOpen.SaveToRegIni(rif, SRegOpen_FilesMRU);
  end;

  procedure TfMain.StartViewMode(InitFlags: TImgViewInitFlags);
  var
    iPicIndex: Integer;
    ViewerTool: TPhoaToolSetting;
    wsPicFileName: WideString;

     // �������� ����� ���������� ���� ptkExtViewer, ���������� ��� ������� �����������. ���� �� �����, ���������� nil
    function FindViewerTool(const wsFileName: WideString): TPhoaToolSetting;
    var i: Integer;
    begin
      for i := 0 to RootSetting.Settings[ISettingID_Tools].ChildCount-1 do begin
        Result := RootSetting.Settings[ISettingID_Tools].Children[i] as TPhoaToolSetting;
        if (Result.Kind=ptkExtViewer) and Result.MatchesFile(wsFileName) then Exit;
      end;
      Result := nil;
    end;

  begin
    iPicIndex := Viewer.ItemIndex;
    if (FViewedPics<>nil) and (iPicIndex>=0) then begin
      ResetMode;
       // �������� ����� ������� �����
      wsPicFileName := FViewedPics[iPicIndex].FileName;
      ViewerTool := FindViewerTool(wsPicFileName);
       // ���� ����� - ���������
      if ViewerTool<>nil then
        ViewerTool.Execute(wsPicFileName)
       // ����� ������ � ����� ���������
      else begin
        ViewImage(InitFlags, Self, iPicIndex, FUndo);
        Viewer.ItemIndex := iPicIndex;
      end;
    end;
  end;

  procedure TfMain.StateChanged(EnterStates: TAppStates; LeaveStates: TAppStates = []);
  begin
    FAppState := FAppState+EnterStates-LeaveStates;
    UpdateState;
  end;

  procedure TfMain.ToolItemClick(Sender: TObject);
  begin
     // ������ ������ ������ �� ����������� � ��������� ����������
    (RootSetting.Settings[ISettingID_Tools][TComponent(Sender).Tag] as TPhoaToolSetting).Execute(GetSelectedPics);
  end;

  procedure TfMain.tvGroupsBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  begin
    PicGroupsVT_HandleBeforeCellPaint(Sender, TargetCanvas, Node, Column, CellRect, Self, FProject.ViewIndex>=0);
  end;

  procedure TfMain.tvGroupsBeforeItemErase(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var ItemColor: TColor; var EraseAction: TItemEraseAction);
  begin
    PicGroupsVT_HandleBeforeItemErase(Sender, TargetCanvas, Node, ItemRect, ItemColor, EraseAction, FProject.ViewIndex>=0);
  end;

  procedure TfMain.tvGroupsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    RefreshViewer;
  end;

  procedure TfMain.tvGroupsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var p: TPoint;
  begin
    ResetMode;
    if GetNodeKind(Node) in [gnkProject, gnkView] then begin
      with Sender.GetDisplayRect(Node, -1, False) do p := Sender.ClientToScreen(Point(Left, Bottom));
      pmPhoaView.Popup(p.x, p.y);
    end;
  end;

  procedure TfMain.tvGroupsCollapsing(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
  begin
    PicGroupsVT_HandleCollapsing(Sender, Node, Allowed);
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
    HDFiles: THDrop;
    SLFiles: TStringList;
  begin
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
      PerformOperation('GroupDragAndDrop', ['Group', GetNodeGroup(nSrc), 'NewParentGroup', GetNodeGroup(nTgt), 'NewIndex', iNewIndex]);
      Effect := DROPEFFECT_NONE;
     // �������������� �����������
    end else if Source=Viewer then begin
      bCopy := (ssCtrl in Shift) or (GetNodeKind(nSrc)=gnkSearch);
      gTgt := GetNodeGroup(nTgt);
      iCnt := Viewer.SelectedPics.Count;
      iCntBefore := gTgt.Pics.Count;
      PerformOperation(
        'PicDragAndDropToGroup',
        ['SourceGroup', CurGroupX, 'TargetGroup', gTgt, 'Pics', Viewer.SelectedPics, 'Copy', bCopy]);
      PhoaInfo(
        False,
        iif(bCopy, 'SNotify_DragCopy', 'SNotify_DragMove'),
        [iCnt, gTgt.Pics.Count-iCntBefore, iCnt-(gTgt.Pics.Count-iCntBefore)],
        iif(bCopy, ISettingID_Dlgs_NotifyDragCopy, ISettingID_Dlgs_NotifyDragMove));
     // OLE Drag'n'Drop
    end else if DataObject<>nil then begin
       // ������ ������ THDrop ��� ��������� ������ ������ �� DataObject
      HDFiles := THDrop.Create;
      try
         // ���� ������ ������������� �������
        if HDFiles.LoadFromDataObject(DataObject) then begin
          SLFiles := TStringList.Create;
          try
             // ��������� ������ ������ � SLFiles
            HDFiles.FileNames(SLFiles);
             // ��������� ������ ���������� �����������
            AddFiles(Self, GetNodeGroup(nTgt), FUndo, SLFiles);
          finally
            SLFiles.Free;
          end;
        end;
      finally
        HDFiles.Free;
      end;
    end;
  end;

  procedure TfMain.tvGroupsDragOver(Sender: TBaseVirtualTree; Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer; var Accept: Boolean);
  const aPicCur: Array[Boolean] of TCursor = (crDragMove, crDragCopy);
  var
    nSrc, nTgt: PVirtualNode;
    gnkSrc, gnkTgt: TGroupNodeKind;
    HDFiles: THDrop;
  begin
    nSrc := Sender.FocusedNode;
    nTgt := Sender.DropTargetNode;
    gnkSrc := GetNodeKind(nSrc);
    gnkTgt := GetNodeKind(nTgt);
     // �������������� ������
    if Sender=Source then begin
      Accept := False;
      Effect := DROPEFFECT_MOVE;
      if (nTgt<>nil) and (gnkTgt<>gnkSearch) and (Mode in [dmAbove, dmOnNode, dmBelow]) then begin
        case Mode of
           // ��� ����� - ������ ��������� ��� ������������ � ��� ��������� �� nSrc �����
          dmAbove:  Accept := (gnkTgt<>gnkProject) and ((nSrc.Parent<>nTgt.Parent) or (nSrc.Index<>nTgt.Index-1));
           // �� ���� - ������ ������� � �������� ��������� ����
          dmOnNode: Accept := nSrc.Parent<>nTgt;
           // ��� ����� - ������ ��������� ��� ������������ � ��� ���������� ����� nSrc �����
          dmBelow:  Accept := (gnkTgt<>gnkProject) and ((nSrc.Parent<>nTgt.Parent) or (nSrc.Index<>nTgt.Index+1));
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
     // OLE Drag'n'Drop
    end else if Sender.DragManager.DataObject<>nil then begin
       // ������������� [�����] ����� ������ � ������ ��� ��� ������
      Accept := (Mode=dmOnNode) and (gnkTgt in [gnkProject, gnkPhoaGroup]);
      if Accept then begin
         // �������������� �������������� ������ ������ ��
        HDFiles := THDrop.Create;
        try
          Accept := HDFiles.LoadFromDataObject(Sender.DragManager.DataObject);
          Effect := DROPEFFECT_COPY;
        finally
          HDFiles.Free;
        end;
      end;
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
    Allowed := GetNodeKind(Node) in [gnkView, gnkPhoaGroup];
  end;

  procedure TfMain.tvGroupsExpandedCollapsed(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    PicGroupsVT_HandleExpandedCollapsed(Sender, Node, True);
  end;

  procedure TfMain.tvGroupsFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
  begin
    PicGroupsVT_HandleFreeNode(Sender, Node);
  end;

  procedure TfMain.tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var LineBreakStyle: TVTTooltipLineBreakStyle; var HintText: WideString);
  begin
    PicGroupsVT_HandleGetHint(Sender, Node, Column, LineBreakStyle, HintText, Self, FProject.ViewIndex>=0);
  end;

  procedure TfMain.tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
  begin
    PicGroupsVT_HandleGetImageIndex(Sender, Node, Kind, Column, Ghosted, ImageIndex, FProject.ViewIndex>=0);
  end;

  procedure TfMain.tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  begin
    PicGroupsVT_HandleGetText(Sender, Node, Column, TextType, CellText, FProject.CurrentView);
  end;

  procedure TfMain.tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
    PicGroupsVT_HandleInitNode(Sender, ParentNode, Node, InitialStates, FProject.ViewRootGroupX, FSearchResults, True, True);
  end;

  procedure TfMain.tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
  begin
    case GetNodeKind(Node) of
      gnkView:      PerformOperation('ViewEdit',    ['View', FProject.CurrentViewX, 'Name', PhoaUnicodeToAnsi(NewText), 'FilterExpression', FProject.CurrentViewX.FilterExpression]);
      gnkPhoaGroup: PerformOperation('GroupRename', ['Group', CurGroupX, 'NewText', PhoaUnicodeToAnsi(NewText)]);
    end;
  end;

  procedure TfMain.tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
    PicGroupsVT_HandlePaintText(Sender, TargetCanvas, Node, Column, TextType);
  end;

  procedure TfMain.ulToolbarUndoChange(Sender: TObject);
  begin
    tbxlToolbarUndo.UpdateCaption(DKLangConstW('SUndoOperationCount', [ulToolbarUndo.ItemIndex+1]));
  end;

  procedure TfMain.ulToolbarUndoClick(Sender: TObject);
  begin
    UndoOperations(FUndo.Count-ulToolbarUndo.ItemIndex-1);
  end;

  procedure TfMain.UndoOperations(Index: Integer);
  var
    i, iCurViewIndex, iCurGroupID: Integer;
    Changes: TPhoaOperationChanges;
    Operation: TPhoaOperation;
    UndoStream: IPhoaUndoDataStream;
    ViewerData: IThumbnailViewerDisplayData;
    pGroupOffset: TPoint;
  begin
    ResetMode;
    BeginUpdate;
    try
       // �������� �������� � ��������� ��������� ����������, �� ������ �����
      Operation := FUndo[Index];
      UndoStream := FUndo.UndoStream;
      UndoStream.BeginUndo(Operation.GUIStateUndoDataPosition);
      try
        iCurViewIndex  := UndoStream.ReadInt;
        iCurGroupID    := UndoStream.ReadInt;
        pGroupOffset.x := UndoStream.ReadInt;
        pGroupOffset.y := UndoStream.ReadInt;
        ViewerData := NewThumbnailViewerDisplayData;
        ViewerData.LoadFromDataStream(UndoStream);
      finally
        UndoStream.EndUndo(False);
      end;
       // ������ ���� �� ��������� (� ����� �� ���������� �������), ���������� ���������
      Changes := [];
      for i := FUndo.Count-1 downto Index do FUndo[i].Undo(Changes);
       // ������������ ������������� ��������� ���� ��������
      ProcessOpChanges(Changes);
      StateChanged([asActionChangePending, asModifiedChangePending]);
       // ��������������� ��������� ����������
      RestoreGUIState(iCurViewIndex, iCurGroupID, pGroupOffset, ViewerData);
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.UpdateFlatModeAction;
  begin
    aFlatMode.Checked := SettingValueBool(ISettingID_Browse_FlatMode);
  end;

  procedure TfMain.UpdateState;

     // ����������� ����������� Actions
    procedure Adjust_Actions;
    var
      bGr, bPic, bPics, bPicSel, bView: Boolean;
      FCtl: TPhoaAppFocusedControl;
      gnk: TGroupNodeKind;
    begin
       // ���������� ��������������� �������
      FCtl := FocusedControl;
      bGr  := FCtl=pafcGroupTree;
      bPic := FCtl=pafcThumbViewer;
       // ���������� ������� ���������� ��������
      gnk := GetNodeKind(tvGroups.FocusedNode);
      bPics   := FProject.Pics.Count>0;
      bPicSel := Viewer.SelectedPics.Count>0;
      bView   := FProject.ViewIndex>=0;
       // ����������� Actions/Menus
      aUndo.Caption := DKLangConstW(iif(FUndo.CanUndo, 'SUndoActionTitle', 'SCannotUndo'), [FUndo.LastOpName]);
      aUndo.Enabled                  := FUndo.CanUndo;
      smUndoHistory.Enabled          := FUndo.CanUndo;
      aNewGroup.Enabled              := gnk in [gnkProject, gnkPhoaGroup];
      aNewPic.Enabled                := gnk in [gnkProject, gnkPhoaGroup];
      aDelete.Enabled                := (bGr and (gnk=gnkPhoaGroup)) or (bPic and (gnk in [gnkProject, gnkPhoaGroup]) and bPicSel);
      aDeletePicsFromProject.Enabled := bPic and (gnk<>gnkNone) and bPicSel;
      aDeletePicsWithFiles.Enabled   := bPic and (gnk<>gnkNone) and bPicSel;
      aEdit.Enabled                  := (bGr and (gnk in [gnkProject, gnkPhoaGroup, gnkView])) or (bPic and (gnk in [gnkProject, gnkSearch, gnkPhoaGroup, gnkViewGroup]) and bPicSel {!!!and not bView});
      aCut.Enabled                   := (gnk in [gnkProject, gnkPhoaGroup]) and bPicSel and (wClipbrdPicFormatID<>0);
      aCopy.Enabled                  := bPicSel and (wClipbrdPicFormatID<>0);
      aPaste.Enabled                 := (gnk in [gnkProject, gnkPhoaGroup]) and Clipboard.HasFormat(wClipbrdPicFormatID);
      aSortPics.Enabled              := (gnk in [gnkProject, gnkPhoaGroup, gnkSearch]) and bPics;
      aSelectAll.Enabled             := (gnk<>gnkNone) and (Viewer.SelectedPics.Count<FViewedPics.Count);
      aSelectNone.Enabled            := bPicSel;
      aView.Enabled                  := Viewer.ItemIndex>=0;
      aViewSlideShow.Enabled         := Viewer.ItemIndex>=0;
      aRemoveSearchResults.Enabled   := FSearchNode<>nil;
      aPicOps.Enabled                := (gnk in [gnkProject, gnkPhoaGroup]) and bPicSel;
      aFileOperations.Enabled        := bPics;
      aFind.Enabled                  := bPics;
       // Views                      
      aPhoaView_Delete.Enabled       := bView;
      aPhoaView_Edit.Enabled         := bView;
      aPhoaView_MakeGroup.Enabled    := bView;
       // Drag-and-drop
      Viewer.DragEnabled       := (gnk in [gnkProject, gnkPhoaGroup, gnkSearch]) and SettingValueBool(ISettingID_Browse_ViewerDragDrop) and not bView;
       // -- ����������������� ������ ����� � ������� �����������, ���� �� ����������� ����� ��� � ������� ������ ���
       //    �������� 
      Viewer.DragInsideEnabled := (gnk in [gnkProject, gnkPhoaGroup]) and (not aFlatMode.Checked or (CurGroupX.Groups.Count=0));
    end;

     // ����������� ����������� ������������
    procedure Adjust_Tools;
    begin
       // ����������� ����������� ���� "������"
      DoEnableTools(giTools_ToolsMenu);
       // ���������� ����� ���������� ������������ popup-����
      FAppState := FAppState-[asGroupsPopupToolsValidated, asPicsPopupToolsValidated];
    end;

     // ����������� Caption/Application.Title
    procedure Adjust_Title;
    var ws: WideString;
    begin
      ws := WideFormat('[%s%s] - %s', [WideExtractFileName(DisplayFileName), iif(FUndo.IsUnmodified, '', '*'), DKLangConstW('SAppCaption')]);
      Caption           := ws;
      Application.Title := ws;
    end;

     // ����������� ���������� � ������� ���������
    procedure Adjust_SelInfo;
    begin
      sbarMain.Panels[1].Caption := DKLangConstW('SPicCount',         [FProject.Pics.Count]);
      sbarMain.Panels[2].Caption := DKLangConstW('SSelectedPicCount', [Viewer.SelectedPics.Count]);
    end;

  begin
    inherited UpdateState;
    if not (asInitialized in FAppState) or UpdateLocked or (csDestroying in ComponentState) then Exit;
     // ���� ���� ��������� � ��������� Actions
    if asActionChangePending in FAppState then begin
      Adjust_Actions;
      Adjust_Tools;
      Exclude(FAppState, asActionChangePending);
    end;
     // ���� ���� ��������� ����� �����/��������� "�����������" �������
    if FAppState*[asFileNameChangePending, asModifiedChangePending]<>[] then begin
      Adjust_Title;
      FAppState := FAppState-[asFileNameChangePending, asModifiedChangePending];
    end;
     // ���� ���� ��������� ��������� ������
    if asStatusBarInfoChangePending in FAppState then begin
      Adjust_SelInfo;
      Exclude(FAppState, asStatusBarInfoChangePending);
    end;
  end;

  procedure TfMain.UpdateThumbnailSize;
  begin
    Viewer.ThumbnailSize := FProject.ThumbnailSize;
  end;

  procedure TfMain.UpdateViewIndex;
  var i, iIndex: Integer;
  begin
    BeginUpdate;
    try
      iIndex := FProject.ViewIndex;
       // ����������� ����� � ���� �������������
      iPhoaView_SetDefault.Checked := iIndex<0;
      for i := 0 to gipmPhoaViewViews.Count-1 do gipmPhoaViewViews[i].Checked := i=iIndex;
       // ����������� ������ �����
      LoadGroupTree;
      StateChanged([asActionChangePending]);
    finally
      EndUpdate;
    end;
  end;

  procedure TfMain.ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
  begin
    PerformOperation(
      'PicDragAndDropInsideGroup',
      ['Group', CurGroupX, 'Pics', Viewer.SelectedPics, 'NewIndex', Viewer.DropTargetIndex]);
  end;

  procedure TfMain.ViewerSelectionChange(Sender: TObject);
  begin
    StateChanged([asActionChangePending, asStatusBarInfoChangePending]);
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
    StateChanged([asActionChangePending]);
     // Invoke the next viewer in chain
    if FHNextClipbrdViewer<>0 then SendMessage(FHNextClipbrdViewer, WM_DRAWCLIPBOARD, 0, 0);
  end;

  procedure TfMain.WMHelp(var Msg: TWMHelp);
  begin
     // ���������� ������� Shift/Ctrl/Alt+F1
    if (GetKeyState(VK_SHIFT) or GetKeyState(VK_CONTROL) or GetKeyState(VK_MENU)) and $80=0 then aHelpContents.Execute;
  end;

  procedure TfMain.WMStartViewMode(var Msg: TWMStartViewMode);
  begin
    StartViewMode(Msg.InitFlags);
  end;

end.

