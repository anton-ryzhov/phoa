//**********************************************************************************************************************
//  $Id: Main.pas,v 1.44 2004-10-04 12:44:36 dale Exp $
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
  phIntf, phMutableIntf, phObj, phGUIObj, ConsVars,
  VirtualTrees, TBXDkPanels, ImgList, TB2Item, Placemnt,
  TB2MRU, TBXExtItems, Menus, TBX, ActnList, TBXStatusBars, TBXLists,
  TB2Dock, TB2Toolbar, StdCtrls, DKLang;

type
  TfMain = class(TForm, IPhoaViews)
    alMain: TActionList;
    aNew: TAction;
    aOpen: TAction;
    aSave: TAction;
    aSaveAs: TAction;
    aExit: TAction;
    aAbout: TAction;
    aNewGroup: TAction;
    aNewPic: TAction;
    aDelete: TAction;
    aEdit: TAction;
    aSettings: TAction;
    aView: TAction;
    dkTop: TTBXDock;
    dkBottom: TTBXDock;
    dkLeft: TTBXDock;
    dkRight: TTBXDock;
    tbMain: TTBXToolbar;
    tbMenu: TTBXToolbar;
    smFile: TTBXSubmenuItem;
    iNew: TTBXItem;
    iOpen: TTBXItem;
    iSave: TTBXItem;
    iSaveAs: TTBXItem;
    iFileSep1: TTBXSeparatorItem;
    iExit: TTBXItem;
    smEdit: TTBXSubmenuItem;
    iNewGroup: TTBXItem;
    iNewPic: TTBXItem;
    iDelete: TTBXItem;
    iEditSep2: TTBXSeparatorItem;
    iEdit: TTBXItem;
    iEditSep3: TTBXSeparatorItem;
    iView: TTBXItem;
    smTools: TTBXSubmenuItem;
    iSettings: TTBXItem;
    smHelp: TTBXSubmenuItem;
    iAbout: TTBXItem;
    bNewGroup: TTBXItem;
    bSaveAs: TTBXItem;
    bSave: TTBXItem;
    bNew: TTBXItem;
    tbSep1: TTBXSeparatorItem;
    bDelete: TTBXItem;
    bNewPic: TTBXItem;
    tbSep2: TTBXSeparatorItem;
    bAbout: TTBXItem;
    bSettings: TTBXItem;
    bExit: TTBXItem;
    bView: TTBXItem;
    tbSep3: TTBXSeparatorItem;
    pmGroups: TTBXPopupMenu;
    ipmGroupsDelete: TTBXItem;
    ipmGroupsEdit: TTBXItem;
    ipmGroupsSep1: TTBXSeparatorItem;
    ipmGroupsNewGroup: TTBXItem;
    pmPics: TTBXPopupMenu;
    ipmPicsView: TTBXItem;
    ipmPicsSep1: TTBXSeparatorItem;
    ipmPicsEdit: TTBXItem;
    ipmPicsDelete: TTBXItem;
    ipmPicsSep2: TTBXSeparatorItem;
    ipmPicsNewPic: TTBXItem;
    sbarMain: TTBXStatusBar;
    mruOpen: TTBXMRUList;
    bOpen: TTBXSubmenuItem;
    bOpenMRU: TTBXMRUListItem;
    iFileSep2: TTBXSeparatorItem;
    smFileMRU: TTBXMRUListItem;
    smView: TTBXSubmenuItem;
    iToggleStatusbar: TTBXVisibilityToggleItem;
    iToggleToolbar: TTBXVisibilityToggleItem;
    aHelpContents: TAction;
    iHelpContents: TTBXItem;
    bHelpContents: TTBXItem;
    aStats: TAction;
    bStats: TTBXItem;
    pmView: TTBXPopupMenu;
    aFind: TAction;
    iFind: TTBXItem;
    iToolsSep1: TTBXSeparatorItem;
    aSelectAll: TAction;
    aSelectNone: TAction;
    iSelectNone: TTBXItem;
    iSelectAll: TTBXItem;
    ipmPicsSelectAll: TTBXItem;
    ipmPicsSelectNone: TTBXItem;
    aPicOps: TAction;
    iPicOps: TTBXItem;
    aSortPics: TAction;
    bEdit: TTBXItem;
    iSortPics: TTBXItem;
    tbViewSep1: TTBXSeparatorItem;
    fpMain: TFormPlacement;
    aCut: TAction;
    aCopy: TAction;
    aPaste: TAction;
    iPaste: TTBXItem;
    iCopy: TTBXItem;
    iCut: TTBXItem;
    iEditSep1: TTBXSeparatorItem;
    ipmPicsPaste: TTBXItem;
    ipmPicsCopy: TTBXItem;
    ipmPicsCut: TTBXItem;
    ipmPicsSep3: TTBXSeparatorItem;
    tbSep4: TTBXSeparatorItem;
    bPaste: TTBXItem;
    bCopy: TTBXItem;
    bCut: TTBXItem;
    aUndo: TAction;
    iUndo: TTBXItem;
    iEditSep4: TTBXSeparatorItem;
    bUndo: TTBXSubmenuItem;
    smUndoHistory: TTBXSubmenuItem;
    ilActionsSmall: TTBImageList;
    ilActionsMiddle: TImageList;
    ilActionsLarge: TImageList;
    aPhoaView_New: TAction;
    aPhoaView_Edit: TAction;
    aPhoaView_Delete: TAction;
    aPhoaView_MakeGroup: TAction;
    pmPhoaView: TTBXPopupMenu;
    iPhoaView_SetDefault: TTBXItem;
    iPhoaViewSep1: TTBXSeparatorItem;
    iPhoaViewSep2: TTBXSeparatorItem;
    iPhoaView_New: TTBXItem;
    iPhoaView_Delete: TTBXItem;
    iPhoaView_Edit: TTBXItem;
    iPhoaViewSep3: TTBXSeparatorItem;
    iPhoaView_MakeGroup: TTBXItem;
    gipmPhoaView: TTBGroupItem;
    ulToolbarUndo: TTBXUndoList;
    tbxlToolbarUndo: TTBXLabelItem;
    gismViewViews: TTBGroupItem;
    tbSepHelpWebsite: TTBXSeparatorItem;
    aHelpProductWebsite: TAction;
    iHelpProductWebsite: TTBXItem;
    bFind: TTBXItem;
    gipmPhoaViewViews: TTBGroupItem;
    aFileOperations: TAction;
    ipmGroupsSep2: TTBXSeparatorItem;
    ipmGroupsSortPics: TTBXItem;
    ipmGroupsStats: TTBXItem;
    ipmGroupsPicOps: TTBXItem;
    iFileOperations: TTBXItem;
    ipmPicsFileOperations: TTBXItem;
    ipmGroupsFileOperations: TTBXItem;
    aIniSaveSettings: TAction;
    aIniLoadSettings: TAction;
    iFileSep3: TTBXSeparatorItem;
    iIniLoadSettings: TTBXItem;
    iIniSaveSettings: TTBXItem;
    iToolsSep2: TTBXSeparatorItem;
    giTools_ToolsMenu: TTBGroupItem;
    ipmGroupsSep3: TTBXSeparatorItem;
    giTools_GroupsMenu: TTBGroupItem;
    ipmGroupsNewPic: TTBXItem;
    ipmPicsSep4: TTBXSeparatorItem;
    giTools_PicsMenu: TTBGroupItem;
    aHelpFAQ: TAction;
    iHelpFAQ: TTBXItem;
    dpGroups: TTBXDockablePanel;
    tvGroups: TVirtualStringTree;
    aRemoveSearchResults: TAction;
    iRemoveSearchResults: TTBXItem;
    dklcMain: TDKLanguageController;
    aFlatMode: TAction;
    iFlatMode: TTBXItem;
    aHelpVendorWebsite: TAction;
    aHelpCheckUpdates: TAction;
    smHelpInternet: TTBXSubmenuItem;
    iHelpVendorWebsite: TTBXItem;
    iHelpCheckUpdates: TTBXItem;
    aHelpSupport: TAction;
    iHelpSupport: TTBXItem;
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
    procedure tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: Integer);
    procedure tvGroupsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
    procedure tvGroupsPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    procedure ulToolbarUndoChange(Sender: TObject);
    procedure ulToolbarUndoClick(Sender: TObject);
  private
     // ������� ������
    FPhoA: TPhotoAlbum;
     // ��������������� � ��������� ������ ����������� (� ������ ������ Flat)
    FViewedPics: IPhoaMutablePicList;
     // ���� ����������� ������
    FSearchNode: PVirtualNode;
     // ������ ����������� - ���������� ������
    FSearchResults: TPhoaGroup;
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
     // ���������� �� ����� ���������� �������� ID ��������� ���������� ������
    FSavedGroupID: Integer;
     // ���������� �� ����� ���������� �������� ��������� ����������� Viewer
    FViewerSavedSelectedIDs: TIntegerList;
    FViewerSavedFocusedID: Integer;
    FViewerSavedTopIndex: Integer;
     // Prop storage
    FViewer: TThumbnailViewer;
    FViewIndex: Integer;
     // ��������� ��������� ��������� �����
    procedure ApplyLanguage;
     // ��������� ��������� ��������� ������������
    procedure ApplyTools;
     // ��������� ������������� ���������� ����� �����������. ���������� True, ���� ����� ����������
    function  CheckSave: Boolean;
     // ��������� �������� ����� �� ����������� � tvGroups
    procedure LoadGroupTree;
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
     //   ����� ���������� ������ ������
//    function  GetSelectedPicLinks: TPhoaPicLinks;
     // ���������� ���������� ������. ���� bForceRemove=True, ������� ���� �����������, �����, ��� bDoSelectNode=True,
     //   �������� ����
    procedure DisplaySearchResults(bForceRemove, bDoSelectNode: Boolean);
     // ���������� ��� ����
    function  GetNodeKind(Tree: TBaseVirtualTree; Node: PVirtualNode): TGroupNodeKind;
     // Viewer events
    procedure ViewerSelectionChange(Sender: TObject);
    procedure ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
     // Application events
    procedure AppHint(Sender: TObject);
    procedure AppException(Sender: TObject; E: Exception);
    procedure AppIdle(Sender: TObject; var Done: Boolean);
     // ���������� ��� �������� � ��������� �� Index � ��������� ���������� ������� �������� ������ ��������
    procedure UndoOperations(Index: Integer);
     // ���������� �������������� �������� (for internal use only)
    procedure UndoOperation(Op: TPhoaOperation);
     // ������� ������ ��������
    procedure OperationsStatusChange(Sender: TObject);
    procedure OperationsListChange(Sender: TObject);
     // ������� ����� �� ������ �����������
    procedure ToolItemClick(Sender: TObject);
     // ������ � ����� ���������, ������� � �������� �����������. InitFlags ����� ����� �������������
    procedure StartViewMode(InitFlags: TImgViewInitFlags);
     // �������� ��� "������������" ������ � ������������ � �������� ����� ���������
    procedure ResetMode;
     // ������� � ���������� ���� � tvGroups �� ID ������; nil, ���� ��� ������
    function  FindGroupNodeByID(iGroupID: Integer): PVirtualNode;
     // IPhoaViews
    function  GetViewIndex: Integer;
    procedure SetViewIndex(Value: Integer);
    function  GetViews: TPhoaViews;
    procedure LoadViewList(idxSelect: Integer);
     // Message handlers
    procedure WMChangeCBChain(var Msg: TWMChangeCBChain); message WM_CHANGECBCHAIN;
    procedure WMDrawClipboard(var Msg: TWMDrawClipboard); message WM_DRAWCLIPBOARD;
    procedure CMFocusChanged(var Msg: TCMFocusChanged);   message CM_FOCUSCHANGED;
    procedure WMHelp(var Msg: TWMHelp);                   message WM_HELP;
    procedure WMStartViewMode(var Msg: TWMStartViewMode); message WM_STARTVIEWMODE;
     // Property handlers
    procedure SetFileName(const Value: String);
    function  GetFileName: String;
    function  GetDisplayFileName: String;
    function  GetCurGroup: TPhoaGroup;
    procedure SetCurGroup(Value: TPhoaGroup);
    function  GetCurRootGroup: TPhoaGroup;
  public
    function  IsShortCut(var Message: TWMKey): Boolean; override;
     // ������ ���������� ����� ������� ���������� ����� ��������
    procedure BeginOperation;
     // ������ ���������� ����� ���������� ��������. ����� ���������� ������ ��������� ������������ ������
    procedure EndOperation(Operation: TPhoaOperation);
     // ��������� ��������� ���������
    procedure ApplySettings;
     // ��������� Viewer
    procedure RefreshViewer;
     // Props
     // -- ��� �������� ����� ����������� (������ ������, ���� ����� ����������)
    property FileName: String read GetFileName write SetFileName;
     // -- ������� ��������� ������ � ������
    property CurGroup: TPhoaGroup read GetCurGroup write SetCurGroup;
     // -- ������� �������� ������ � ������ (����������� ��� �������������)
    property CurRootGroup: TPhoaGroup read GetCurRootGroup;
     // -- ��� ����� ����������� ��� ����������� (�� ������ ������, � ����� ������ 'untitled.phoa')
    property DisplayFileName: String read GetDisplayFileName;
     // -- ����������� �������
    property Viewer: TThumbnailViewer read FViewer;
     // -- ������ �������� ������������� (-1 ��� ������ ����� �����������)
    property ViewIndex: Integer read GetViewIndex write SetViewIndex;
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
    TPhoaBaseOp_PicCopy.Create(Viewer.GetSelectedPicArray);
  end;

  procedure TfMain.aaCut(Sender: TObject);
  var Operation: TPhoaOperation;
  begin
    TPhoaBaseOp_PicCopy.Create(Viewer.GetSelectedPicArray);
    Operation := nil;
    BeginOperation;
    try
      Operation := TPhoaMultiOp_PicDelete.Create(FUndo, FPhoA, CurGroup, PicArrayToIDArray(Viewer.GetSelectedPicArray));
    finally
      EndOperation(Operation);
    end;
  end;

  procedure TfMain.aaDelete(Sender: TObject);
  var Operation: TPhoaOperation;
  begin
    ResetMode;
    Operation := nil;
    if CurGroup<>nil then
       // �������� ������
      if ActiveControl=tvGroups then begin
        if PhoaConfirm(False, 'SConfirm_DelGroup', ISettingID_Dlgs_ConfmDelGroup) then begin
          BeginOperation;
          try
            Operation := TPhoaOp_GroupDelete.Create(FUndo, FPhoA, CurGroup, True);
          finally
            EndOperation(Operation);
          end;
        end;
       // �������� �����������
      end else if (ActiveControl=Viewer) and (Viewer.SelectedPics.Count>0) and PhoaConfirm(False, 'SConfirm_DelPics', ISettingID_Dlgs_ConfmDelPics) then begin
        BeginOperation;
        try
          Operation := TPhoaMultiOp_PicDelete.Create(FUndo, FPhoA, CurGroup, PicArrayToIDArray(Viewer.GetSelectedPicArray));
        finally
          EndOperation(Operation);
        end;
      end;
  end;

  procedure TfMain.aaEdit(Sender: TObject);
  begin
    ResetMode;
     // �������������� �����
    if ActiveControl=tvGroups then begin
      case GetNodeKind(tvGroups, tvGroups.FocusedNode) of
        gnkPhoA:      EditPhoA(FPhoA, FUndo);
        gnkView:      EditView(FPhoA.Views[ViewIndex], FPhoA, FUndo);
        gnkPhoaGroup: EditPicGroup(FPhoA, CurGroup, FUndo);
      end;
     // �������������� �����������
    end else if (ActiveControl=Viewer) and (Viewer.SelectedPics.Count>0) then
      EditPic(Viewer.GetSelectedPicArray, FPhoA, FUndo);
  end;

  procedure TfMain.aaExit(Sender: TObject);
  begin
    ResetMode;
    Close;
  end;

  procedure TfMain.aaFileOperations(Sender: TObject);
  var
    View: TPhoaView;
    bPhoaChanged: Boolean;
  begin
    ResetMode;
    if ViewIndex>=0 then View := FPhoA.Views[ViewIndex] else View := nil;
    if DoFileOperations(FPhoA, CurGroup, View, PicArrayToIDArray(Viewer.GetSelectedPicArray), ActiveControl=Viewer, bPhoaChanged) then
       // ���� ���������� ���������� �����������
      if bPhoaChanged then begin
         // �������� ������� ��������� ��� ��������� ��� ����������� ������
        FUndo.SetNonUndoable;
         // ������������� �������������
        FPhoA.Views.UnprocessAllViews;
         // ����������� ������ �����
        LoadGroupTree;
       // ����� ������ ���� ������� ����������� ��������� (� �������� �������, �� �� � ����������) - ��������� �����
      end else
        FUndo.Clear;
  end;

  procedure TfMain.aaFind(Sender: TObject);
  begin
    ResetMode;
    if DoSearch(FPhoA, CurGroup, FSearchResults) then DisplaySearchResults(False, True);
  end;

  procedure TfMain.aaFlatMode(Sender: TObject);
  begin
    aFlatMode.Checked := not aFlatMode.Checked;
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
      FUndo.BeginUpdate;
      try
         // ������� ���������� ������
        DisplaySearchResults(True, False);
         // �������������� ���������� � ����� ������
        FPhoA.New(FUndo);
         // ��������� ������ �����������
        LoadViewList(-1);
      finally
        FUndo.EndUpdate;
      end;
    finally
      tvGroups.EndUpdate;
    end;
  end;

  procedure TfMain.aaNewGroup(Sender: TObject);
  var Operation: TPhoaOperation;
  begin
    Operation := nil;
    BeginOperation;
    try
      Operation := TPhoaOp_GroupNew.Create(FUndo, FPhoA, CurGroup);
    finally
      EndOperation(Operation);
    end;
  end;

  procedure TfMain.aaNewPic(Sender: TObject);
  begin
    ResetMode;
    AddFiles(FPhoA, PPhoaGroup(tvGroups.GetNodeData(tvGroups.FocusedNode))^, FUndo);
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
    Operation: TPhoaOperation;
  begin
    iCntBefore := CurGroup.PicIDs.Count;
    Operation := nil;
    BeginOperation;
    try
      Operation := TPhoaMultiOp_PicPaste.Create(FUndo, FPhoA, CurGroup);
    finally
      EndOperation(Operation);
    end;
    PhoaInfo(False, 'SNotify_Paste', [CurGroup.PicIDs.Count-iCntBefore], ISettingID_Dlgs_NotifyPaste);
  end;

  procedure TfMain.aaPhoaView_Delete(Sender: TObject);
  var Operation: TPhoaOperation;
  begin
    ResetMode;
    Operation := nil;
    if PhoaConfirm(False, 'SConfirm_DelView', ISettingID_Dlgs_ConfmDelView) then begin
      BeginOperation;
      try
        Operation := TPhoaOp_ViewDelete.Create(FUndo, Self);
      finally
        EndOperation(Operation);
      end;
    end;
  end;

  procedure TfMain.aaPhoaView_Edit(Sender: TObject);
  begin
    ResetMode;
    EditView(FPhoA.Views[ViewIndex], FPhoA, FUndo);
  end;

  procedure TfMain.aaPhoaView_MakeGroup(Sender: TObject);
  begin
    ResetMode;
    MakeGroupFromView(FPhoA, FUndo, Self);
  end;

  procedure TfMain.aaPhoaView_New(Sender: TObject);
  begin
    ResetMode;
    EditView(nil, FPhoA, FUndo);
  end;

  procedure TfMain.aaPicOps(Sender: TObject);
  begin
    ResetMode;
    DoPicOps(FPhoA, FUndo, CurGroup, PicArrayToIDArray(Viewer.GetSelectedPicArray));
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
    if FileName='' then aSaveAs.Execute else DoSave(FPhoA.FileName, FPhoA.FileRevision);
  end;

  procedure TfMain.aaSaveAs(Sender: TObject);
  begin
    ResetMode;
    with TSaveDialog.Create(Self) do
      try
        DefaultExt  := SDefaultExt;
        Filter      := GetPhoaSaveFilter;
        FilterIndex := ValidRevisionIndex(GetIndexOfRevision(FPhoA.FileRevision))+1;
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
    DoSortPics(FPhoA, CurGroup, FUndo, CurGroup=FSearchResults);
  end;

  procedure TfMain.aaStats(Sender: TObject);
  begin
    ResetMode;
    ShowPhoaStats(FPhoA, CurGroup);
  end;

  procedure TfMain.aaUndo(Sender: TObject);
  begin
    ResetMode;
    UndoOperations(FUndo.Count-1);
  end;

  procedure TfMain.aaView(Sender: TObject);
  begin
    ResetMode;
    StartViewMode([]);
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
      FPhoA.Views.UnprocessAllViews;
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
  var Group: TPhoaGroup;
  begin
    if FOpLockCounter=0 then begin
      ResetMode;
      tvGroups.BeginUpdate;
       // ��������� ID ������� ������
      Group := CurGroup;
      if Group=nil then FSavedGroupID := 0 else FSavedGroupID := Group.ID;
       // ��������� ��������� ����������� Viewer
      FViewer.SaveDisplay(FViewerSavedSelectedIDs, FViewerSavedFocusedID, FViewerSavedTopIndex);
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
    if bForceRemove then FSearchResults.PicIDs.Clear;
     // ���� ���� ����������, ������, ����� ���� ������ �����������
    if FSearchResults.PicIDs.Count>0 then begin
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
//  var PicLinks: TPhoaPicLinks;
  begin
//     // ���� ����� �������� ���������-�����������
//    if Item.Count>0 then begin
//       // ������ ������ ������ �� �����������
//      PicLinks := GetSelectedPicLinks;
//      try
//         // ����������� ����������� ������������
//        AdjustToolAvailability(RootSetting.Settings[ISettingID_Tools] as TPhoaToolPageSetting, Item, PicLinks);
//      finally
//        PicLinks.Free;
//      end;
//    end;
  end;

  procedure TfMain.DoLoad(const sFileName: String);
  begin
    tvGroups.BeginSynch;
    try
      FUndo.BeginUpdate;
      tvGroups.BeginUpdate;
      StartWait;
      try
        try
           // ���������� ���������� ������
          DisplaySearchResults(True, False);
           // ��������� ���� � ������� ����� ������
          FPhoA.LoadFromFile(ExpandUNCFileName(sFileName), FUndo);
           // ������������ ���� � ������ MRU
          mruOpen.Add(sFileName);
        finally
           // ��������� ������ ������������� � �� ��������� �������� "������ �����������"
          LoadViewList(-1);
        end;
      finally
        StopWait;
        tvGroups.EndUpdate;
        FUndo.EndUpdate;
      end;
    finally
      tvGroups.EndSynch;
    end;
  end;

  procedure TfMain.DoSave(const sFileName: String; iRevisionNumber: Integer);
  begin
     // ������������� ������������, ���� �� ��������� � ����� ������ �������
    if (iRevisionNumber<IPhFileRevisionNumber) and not PhoaConfirm(True, 'SConfirm_SavingOldFormatFile', ISettingID_Dlgs_ConfmOldFile) then Exit;
    FUndo.BeginUpdate;
    StartWait;
    try
      FPhoA.SaveToFile(sFileName, iRevisionNumber, FUndo);
    finally
      StopWait;
      FUndo.EndUpdate;
    end;
     // ������������ ��� ����� � ������ MRU
    mruOpen.Add(sFileName);
    EnableActions;
  end;

  procedure TfMain.EnableActions;
  const asUnmod: Array[Boolean] of String[1] = ('*', '');
  var
    bGr, bPic, bPics, bPicSel, bView: Boolean;
    gnk: TGroupNodeKind;
  begin
    if not FInitialized or (csDestroying in ComponentState) then Exit;
    gnk := GetNodeKind(tvGroups, tvGroups.FocusedNode);
    bGr     := ActiveControl=tvGroups;
    bPic    := ActiveControl=Viewer;
    bPics   := FPhoA.Pics.Count>0;
    bPicSel := Viewer.SelectedPics.Count>0;
    bView   := ViewIndex>=0;
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
    aSelectAll.Enabled           := (gnk<>gnkNone) and (Viewer.SelectedPics.Count<CurGroup.PicIDs.Count);
    aSelectNone.Enabled          := bPicSel;
    aView.Enabled                := Viewer.ItemIndex>=0;
    aRemoveSearchResults.Enabled := FSearchNode<>nil;
    aPicOps.Enabled              := (gnk in [gnkPhoA, gnkPhoaGroup]) and bPicSel;
    aFileOperations.Enabled      := bPics;
    aFind.Enabled                := bPics;
     // Views
    aPhoaView_Delete.Enabled    := bView;
    aPhoaView_Edit.Enabled      := bView;
    aPhoaView_MakeGroup.Enabled := bView;
     // Drag-and-drop
    Viewer.DragEnabled       := (gnk in [gnkPhoA, gnkPhoaGroup, gnkSearch]) and SettingValueBool(ISettingID_Browse_ViewerDragDrop);
    Viewer.DragInsideEnabled := gnk in [gnkPhoA, gnkPhoaGroup];
     // �����������
    EnableTools;
     // ����������� Captions
    Caption := Format('[%s%s] - %s', [ExtractFileName(DisplayFileName), asUnmod[FUndo.IsUnmodified], ConstVal('SAppCaption')]);
    Application.Title := Caption;
    sbarMain.Panels[1].Caption := ConstVal('SPicCount', [FPhoA.Pics.Count]);
  end;

  procedure TfMain.EnableTools;
  begin
     // ����������� ����������� ���� "������"
    DoEnableTools(giTools_ToolsMenu);
     // ���������� ����� ������������ popup-����
    FGroupsPopupToolsValidated := False;
    FPicsPopupToolsValidated   := False;
  end;

  procedure TfMain.EndOperation(Operation: TPhoaOperation);
  var
    IFlags: TUndoInvalidationFlags;
    GetOpGroupNode_Cache, GetOpParentGroupNode_Cache: PVirtualNode;
    Group: TPhoaGroup;

     // �������� ���� � tvGroups, ��������������� ������ GroupAbsIdx ��������, ������� ���������
    function GetOpGroupNode: PVirtualNode;
    begin
      if GetOpGroupNode_Cache=nil then GetOpGroupNode_Cache := FindGroupNodeByID(Operation.OpGroupID);
      Result := GetOpGroupNode_Cache;
      Assert(Result<>nil, 'Failed to locate Operation Group Node in TfMain.EndOperation()');
    end;

     // �������� ���� � tvGroups, ��������������� ������ ParentGroupAbsIdx ��������, ������� ���������
    function GetOpParentGroupNode: PVirtualNode;
    begin
      if GetOpParentGroupNode_Cache=nil then GetOpParentGroupNode_Cache := FindGroupNodeByID(Operation.OpParentGroupID);
      Result := GetOpParentGroupNode_Cache;
      Assert(Result<>nil, 'Failed to locate Operation Parent Group Node in TfMain.EndOperation()');
    end;

  begin
    Assert(FOpLockCounter>0, 'Excessive TfMain.EndOperation() call');
    Dec(FOpLockCounter);
    try
       // Operation ����� nil � ������ ��������� ������� ���������� (��� ������ EndOperation() � ������ finally)
      if Operation<>nil then begin
         // Initialize cache
        GetOpGroupNode_Cache       := nil;
        GetOpParentGroupNode_Cache := nil;
         // ������������ ���������, �������� ���������
        IFlags := Operation.InvalidationFlags;
         // -- ����������������� ��������
        if uifXReinitParent in IFlags then tvGroups.ReinitNode(GetOpParentGroupNode, uifXReinitRecursive in IFlags);
         // -- ����������������� �������
        if uifXReinitSiblings in IFlags then tvGroups.ReinitChildren(GetOpParentGroupNode, uifXReinitRecursive in IFlags);
      end;
    finally
      if FOpLockCounter=0 then tvGroups.EndUpdate;
    end;
     // ���������� ���������� ������
    DisplaySearchResults(True, False);
     // �������������� ������ ����, ���������������� ������ ��������: ��������� ����� ������ ���������� �����������
    if uifXEditGroup in IFlags then begin
      tvGroups.Selected[GetOpGroupNode] := True;
      tvGroups.FocusedNode := GetOpGroupNode;
      tvGroups.EditNode(GetOpGroupNode, -1);
    end;
     // ��������� Viewer (����� ��������� ����� ��������� ��-�� �������������� ������ ����)
    if FOpLockCounter=0 then begin
      FViewer.BeginUpdate;
      try
        Group := CurGroup;
        RefreshViewer;
         // ���� ������ �� ����������, ��������������� ��������� �����������
        if (Group<>nil) and (Group.ID=FSavedGroupID) then
          FViewer.RestoreDisplay(FViewerSavedSelectedIDs, FViewerSavedFocusedID, FViewerSavedTopIndex);
      finally
        FViewer.EndUpdate;
        FreeAndNil(FViewerSavedSelectedIDs);
      end;
    end;
  end;

  function TfMain.FindGroupNodeByID(iGroupID: Integer): PVirtualNode;
  begin
    Result := tvGroups.GetFirst;
    while Result<>nil do begin
      if PPhoaGroup(tvGroups.GetNodeData(Result))^.ID=iGroupID then Exit;
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
      ShortTimeFormat := 'hh:nn';
      LongTimeFormat  := 'hh:nn:ss';
       // ����������� fpMain
      fpMain.IniFileName := SRegRoot;
      fpMain.IniSection  := SRegMainWindow_Root;
       // ������ ����������
      FPhoA := TPhotoAlbum.Create;
      FViewedPics := TPhoaMutablePicList.Create(False);
      FViewIndex := -1;
       // ����������� Application
      Application.OnHint      := AppHint;
      Application.OnException := AppException;
      Application.OnIdle      := AppIdle;
       // ������ ������ - ������ ����������� ������
      FSearchResults := TPhoaGroup.Create(nil, IGroupID_SearchResults);
       // Create undoable operations list
      FUndo := TPhoaUndo.Create;
      FUndo.OnStatusChange := OperationsStatusChange;
      FUndo.OnOpDone       := OperationsListChange;
      FUndo.OnOpUndone     := OperationsListChange;
       // Create viewer
      FViewer := TThumbnailViewer.Create(Self);
      with FViewer do begin
        Parent            := Self;
        Align             := alClient;
//!!!DisplayMode       := tvdmDetail;
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
    FViewedPics := nil;
    FPhoA.Free;
    FSearchResults.Free;
    FViewerSavedSelectedIDs.Free;
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

  function TfMain.GetCurGroup: TPhoaGroup;
  var p: PPhoaGroup;
  begin
    p := tvGroups.GetNodeData(tvGroups.FocusedNode);
    if p=nil then Result := nil else Result := p^;
  end;

  function TfMain.GetCurRootGroup: TPhoaGroup;
  begin
    if ViewIndex<0 then Result := FPhoA.RootGroup else Result := FPhoA.Views[ViewIndex].RootGroup;
  end;

  function TfMain.GetDisplayFileName: String;
  begin
    Result := FileName;
    if Result='' then Result := SDefaultFName;
  end;

  function TfMain.GetFileName: String;
  begin
    Result := FPhoA.FileName;
  end;

  function TfMain.GetNodeKind(Tree: TBaseVirtualTree; Node: PVirtualNode): TGroupNodeKind;
  var g: TPhoaGroup;
  begin
    Result := gnkNone;
    if Node<>nil then begin
      g := PPhoaGroup(Tree.GetNodeData(Node))^;
      if g.Owner=nil then begin
        if g.ID=IGroupID_SearchResults then Result := gnkSearch
        else if g=FPhoA.RootGroup      then Result := gnkPhoA
        else if FViewIndex>=0          then Result := gnkView;
      end else
        if FViewIndex>=0 then Result := gnkViewGroup else Result := gnkPhoaGroup;
    end;
  end;

//!!!  function TfMain.GetSelectedPicLinks: TPhoaPicLinks;
//  begin
//    Result := TPhoaPicLinks.Create(True);
//    try
//       // ���� ������� ������ - ���������� ������ ������ �� ����������� ������� ������
//      if tvGroups.Focused then begin
//        if CurGroup<>nil then Result.AddFromGroup(FPhoA, CurGroup, False, False);
//       // ���� ������� ����� - ���������� ������ ������ �� ���������� ����������� ������
//      end else if Viewer.Focused then
//        Result.AddFromPicIDs(FPhoA, PicArrayToIDArray(Viewer.GetSelectedPicArray), False);
//    except
//      Result.Free;
//      raise;
//    end;
//  end;

  function TfMain.GetViewIndex: Integer;
  begin
    Result := FViewIndex;
  end;

  function TfMain.GetViews: TPhoaViews;
  begin
    Result := FPhoA.Views;
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

  procedure TfMain.LoadViewList(idxSelect: Integer);
  var
    i: Integer;
    tbi: TTBXItem;
  begin
     // ������� ��� ������ ���������������� �������������
    gipmPhoaViewViews.Clear;
     // ��������� ������ ������������� �����������
    for i := 0 to FPhoA.Views.Count-1 do begin
      tbi := TTBXItem.Create(Self);
      with tbi do begin
        Caption    := FPhoA.Views[i].Name;
        ImageIndex := iiView;
        Tag        := i+1; // Tag=0 � ������ iPhoaView_SetDefault ("������ �����������")
        OnClick    := SetPhoaViewClick;
      end;
      gipmPhoaViewViews.Add(tbi);
    end;
     // ���������� ������� �������������
    SetViewIndex(idxSelect);
  end;

  procedure TfMain.mruOpenClick(Sender: TObject; const Filename: String);
  begin
    ResetMode;
    if CheckSave then DoLoad(FileName);
  end;

  procedure TfMain.OperationsListChange(Sender: TObject);
  var i: Integer;
  begin
     // Invalidate all views except current
    for i := 0 to FPhoA.Views.Count-1 do
      if i<>ViewIndex then FPhoA.Views[i].UnprocessGroups;
  end;

  procedure TfMain.OperationsStatusChange(Sender: TObject);
  var iMaxCnt: Integer;
  begin
    if tsUpdating in tvGroups.TreeStates then Exit;
     // ������������ ���������� �������� � ������
    iMaxCnt := SettingValueInt(ISettingID_Browse_MaxUndoCount);
    with FUndo do
      while Count>iMaxCnt do Delete(0);
    EnableActions;
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
    var idx: Integer;
    begin
      if sViewName<>'' then begin
        idx := FPhoA.Views.IndexOfName(sViewName);
        if idx>=0 then ViewIndex := idx;
      end;
    end;

     // �������� � �������� ������� �������� ������ � ������, ���� sGroupPath<>''
    procedure SelectGroupByPath(const sGroupPath: String);
    begin
      if sGroupPath<>'' then CurGroup := CurRootGroup.GroupByPath[sGroupPath];
    end;

     // �������� ����������� � �������� ID
    procedure SelectPicByID(iID: Integer);
    begin
      if (iID>0) and (CurGroup<>nil) then begin
        Viewer.ItemIndex := CurGroup.PicIDs.IndexOf(iID);
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
       // ����� ��������� ������ ������������� � �������� "������ �����������"
      end else
        LoadViewList(-1);
    finally
      CmdLine.Free;
    end;
    EnableActions;
  end;

  procedure TfMain.RefreshViewer;
  var
    UniquePics: IPhoaMutablePicList;
    bRecurse: Boolean;

    procedure DoAddPics(Group: TPhoaGroup);
    var
      i, iID: Integer;
      bDoAdd: Boolean;
      Pic: IPhoaPic;
    begin
       // ��������� ������ �� ����������� ������
      for i := 0 to Group.PicIDs.Count-1 do begin
        iID := Group.PicIDs[i];
         // ��������� �� ���������, ���� ����
        Pic := FPhoA.Pics.PicByID(iID);
        if UniquePics=nil then bDoAdd := True else UniquePics.Add(Pic, True, bDoAdd);
         // ���������
        if bDoAdd then FViewedPics.Add(Pic, False);
      end;
       // ���� ����������� ���������� - ��������� �� �� ��� ��������� �����
      if bRecurse then
        for i := 0 to Group.Groups.Count-1 do DoAddPics(Group.Groups[i]);
    end;

  begin
    FViewedPics.Clear;
     // ���� ���� ������� ������
    if CurGroup<>nil then begin
       // ���� �� ����������� ����������, �� ��������� �� ���������, �.�. ������ �� ����� ��������� ����������� ������.
       //   ����� ������ ��������� [�������������] ������ �����������, ����� ������ ��������� ��� ����������� �����������
      bRecurse := aFlatMode.Checked;
      if bRecurse then UniquePics := TPhoaMutablePicList.Create(True) else UniquePics := nil;
      DoAddPics(CurGroup);
    end;
     // ��������� �����
    FViewer.ReloadPicList(FViewedPics);
  end;

  procedure TfMain.ResetMode;
  begin
     // ��������� inplace-�������������� ������ ���� � ������ �����
    tvGroups.EndEditNode;
  end;

  procedure TfMain.SetCurGroup(Value: TPhoaGroup);
  var n: PVirtualNode;
  begin
     // ���������� ����, ���� �� �����
    if Value<>nil then begin
      n := tvGroups.GetFirst;
      while (n<>nil) and (PPhoaGroup(tvGroups.GetNodeData(n))^<>Value) do n := tvGroups.GetNext(n);
    end else
      n := nil;
     // ������������
    ActivateVTNode(tvGroups, n);
  end;

  procedure TfMain.SetFileName(const Value: String);
  begin
    FPhoA.FileName := Value;
  end;

  procedure TfMain.SetGroupExpanded(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var p: PPhoaGroup;
  begin
    if tsUpdating in tvGroups.TreeStates then Exit;
    p := Sender.GetNodeData(Node);
    if (p<>nil) then p^.Expanded := Sender.Expanded[Node];
  end;

  procedure TfMain.SetPhoaViewClick(Sender: TObject);
  begin
    ViewIndex := TComponent(Sender).Tag-1;
  end;

  procedure TfMain.SetViewIndex(Value: Integer);
  var i: Integer;
  begin
    FViewIndex := Value;
     // ����������� ����� � ���� �������������
    iPhoaView_SetDefault.Checked := Value<0;
    for i := 0 to gipmPhoaViewViews.Count-1 do gipmPhoaViewViews[i].Checked := i=Value;
     // ����������� ������ �����
    LoadGroupTree;
  end;

  procedure TfMain.StartViewMode(InitFlags: TImgViewInitFlags);
  var iPicIndex: Integer;
  begin
    iPicIndex := Viewer.ItemIndex;
    if (CurGroup<>nil) and (iPicIndex>=0) then begin
      ViewImage(InitFlags, CurGroup, FPhoA, iPicIndex, FUndo, ViewIndex<0);
      Viewer.ItemIndex := iPicIndex;
    end;
  end;

  procedure TfMain.ToolItemClick(Sender: TObject);
//!!!  var PicLinks: TPhoaPicLinks;
  begin
//     // ������ ������ ������ �� �����������
//    PicLinks := GetSelectedPicLinks;
//    try
//       // ��������� ����������
//      (RootSetting.Settings[ISettingID_Tools][TComponent(Sender).Tag] as TPhoaToolSetting).Execute(PicLinks);
//    finally
//      PicLinks.Free;
//    end;
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
    Allowed := (ViewIndex<0) and (Sender.NodeParent[Node]<>nil);
  end;

  procedure TfMain.tvGroupsDragDrop(Sender: TBaseVirtualTree; Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  var
    nSrc, nTgt: PVirtualNode;
    gTgt: TPhoaGroup;
    AM: TVTNodeAttachMode;
    iNewIndex, iCnt, iCntBefore: Integer;
    bCopy: Boolean;
    Operation: TPhoaOperation;
  begin
    Operation := nil;
    nSrc := Sender.FocusedNode;
    nTgt := Sender.DropTargetNode;
     // �������������� ������
    if Sender=Source then begin
       // ��������� � �������� � nTgt ������ ��������, � iNewIndex - ����� ������ � ��������, � AM - ����� �����������
      case Mode of
        dmAbove: begin
          iNewIndex := nTgt.Index;
          nTgt := nTgt.Parent;
          AM := amInsertBefore;
        end;
        dmBelow: begin
          iNewIndex := nTgt.Index+1;
          nTgt := nTgt.Parent;
          AM := amInsertAfter;
        end;
        else {dmOnNode} begin
          iNewIndex := -1;
          AM := amAddChildLast;
        end;
      end;
       // ���� ���������� ����� � ����� ����� ����� ���� �� ��������, ��������� ������ �� 1
      if (Mode in [dmAbove, dmBelow]) and (nTgt=nSrc.Parent) and (iNewIndex>Integer(nSrc.Index)) then Dec(iNewIndex);
       // ����������
      BeginOperation;
      try
        Operation := TPhoaOp_GroupDragAndDrop.Create(
          FUndo,
          FPhoA,
          PPhoaGroup(Sender.GetNodeData(nSrc))^, // Group being dragged
          PPhoaGroup(Sender.GetNodeData(nTgt))^, // New parent group
          iNewIndex);
      finally
        EndOperation(Operation);
      end;
      Sender.MoveTo(nSrc, Sender.DropTargetNode, AM, False);
      Sender.FullyVisible[nSrc] := True;
      Effect := DROPEFFECT_NONE;
     // �������������� �����������
    end else if Source=Viewer then begin
      bCopy := (GetKeyState(VK_CONTROL) and $80<>0) or (GetNodeKind(tvGroups, nSrc)=gnkSearch);
      gTgt := PPhoaGroup(Sender.GetNodeData(nTgt))^;
      iCnt := Viewer.SelectedPics.Count;
      iCntBefore := gTgt.PicIDs.Count;
      BeginOperation;
      try
        Operation := TPhoaMultiOp_PicDragAndDropToGroup.Create(FUndo, FPhoA, CurGroup, gTgt, PicArrayToIDArray(Viewer.GetSelectedPicArray), bCopy);
      finally
        EndOperation(Operation);
      end;
      PhoaInfo(
        False,
        iif(bCopy, 'SNotify_DragCopy', 'SNotify_DragMove'),
        [iCnt, gTgt.PicIDs.Count-iCntBefore, iCnt-(gTgt.PicIDs.Count-iCntBefore)],
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

  procedure TfMain.tvGroupsGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var s: String;
  begin
    case GetNodeKind(Sender, Node) of
      gnkPhoA:      s := FPhoA.Description;
      gnkPhoaGroup: s := PPhoaGroup(Sender.GetNodeData(Node))^.GetPropStrs(FGroupTreeHintProps, ': ', S_CRLF);
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
    p: PPhoaGroup;
    s: String;
  begin
    p := Sender.GetNodeData(Node);
    s := '';
     // Static text
    case TextType of
      ttNormal:
        case GetNodeKind(Sender, Node) of
          gnkPhoA:        s := ConstVal('SPhotoAlbumNode');
          gnkView:        s := FPhoA.Views[ViewIndex].Name;
          gnkSearch:      s := ConstVal('SSearchResultsNode');
          gnkPhoaGroup,
            gnkViewGroup: s := p^.Text;
        end;
      ttStatic: if p^.PicIDs.Count>0 then s := Format('(%d)', [p^.PicIDs.Count]);
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TfMain.tvGroupsInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  var p, pp: PPhoaGroup;
  begin
    p := Sender.GetNodeData(Node);
     // ���� ������� ������
    if ParentNode<>nil then begin
      pp := Sender.GetNodeData(ParentNode);
      p^ := pp^.Groups[Node.Index];
     // ���� �����������/�������������
    end else if Node.Index=0 then begin
      p^ := CurRootGroup;
      Node.CheckType := ctButton;
     // ���� ����������� ������
    end else
      p^ := FSearchResults;
    Sender.ChildCount[Node] := p^.Groups.Count;
     // ������������� �������� ���� ��� ���� ������ ���������
    if (ParentNode=nil) or p^.Expanded then Include(InitialStates, ivsExpanded) else Sender.Expanded[Node] := False;
  end;

  procedure TfMain.tvGroupsNewText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);
  var Operation: TPhoaOperation;
  begin
    Operation := nil;
    BeginOperation;
    try
      case GetNodeKind(Sender, Node) of
        gnkView:      Operation := TPhoaOp_ViewEdit.Create(FUndo, FPhoA.Views[ViewIndex], Self, UnicodetoAnsiCP(NewText, cMainCodePage), nil, nil);
        gnkPhoaGroup: Operation := TPhoaOp_GroupRename.Create(FUndo, FPhoA, CurGroup, UnicodetoAnsiCP(NewText, cMainCodePage));
      end;
    finally
      EndOperation(Operation);
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

  procedure TfMain.UndoOperation(Op: TPhoaOperation);
  var
    IFlags: TUndoInvalidationFlags;
    OpParentGroupNode: PVirtualNode;
  begin
     // �������� ������ �� ����������� ������� ��������
    IFlags := Op.InvalidationFlags;
    OpParentGroupNode := nil;
    if uifUReinitParent in IFlags then OpParentGroupNode := FindGroupNodeByID(Op.OpParentGroupID);
     // ���������� (� ����������) ��������
    Op.Undo;
     // ��������� ����� ��������� ����������
     // -- ����������������� ����� ������
    if uifUReinitAll    in IFlags then tvGroups.ReinitChildren(nil, True);
     // -- ����������������� ��������
    if uifUReinitParent in IFlags then tvGroups.ReinitNode(OpParentGroupNode, uifUReinitRecursive in IFlags);
  end;

  procedure TfMain.UndoOperations(Index: Integer);
  var i: Integer;
  begin
    ResetMode;
    tvGroups.BeginUpdate;
    try
       // ������ ���� � ����� �� ���������� �������
      for i := FUndo.Count-1 downto Index do UndoOperation(FUndo[i]);
       // ���������� ���������� ������
      DisplaySearchResults(True, False);
    finally
      tvGroups.EndUpdate;
    end;
    RefreshViewer;
  end;

  procedure TfMain.ViewerDragDrop(Sender, Source: TObject; X, Y: Integer);
  var Operation: TPhoaOperation;
  begin
    Operation := nil;
    BeginOperation;
    try
      Operation := TPhoaOp_PicDragAndDropInsideGroup.Create(
        FUndo,
        FPhoA,
        CurGroup,
        PicArrayToIDArray(Viewer.GetSelectedPicArray),
        Viewer.DropTargetIndex);
    finally
      EndOperation(Operation);
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
    ResetMode;
    HtmlHelpShowContents;
  end;

  procedure TfMain.WMStartViewMode(var Msg: TWMStartViewMode);
  begin
    StartViewMode(Msg.InitFlags);
  end;

end.
