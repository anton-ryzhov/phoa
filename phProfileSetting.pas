//**********************************************************************************************************************
//  $Id: phProfileSetting.pas,v 1.3 2004-10-08 12:13:46 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phProfileSetting;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Registry, IniFiles, VirtualTrees, ActiveX, TB2Item, TBX,
  ConsVars, phSettings, phObj;

type
   //===================================================================================================================
   // TPhoaProfileSetting - ���������, �������������� ����� ������ ������ �������
   //===================================================================================================================

  PPhoaProfileSetting = ^TPhoaProfileSetting;
  TPhoaProfileSetting = class(TPhoaSetting)
  private
     // ��������� ����������� ������
    FModified: Boolean;
     // Prop storage

     // ���������� ��� ������ ��� ����������/�������� ��������
//    function GetStoreSection: String;
     // Prop handlers
  protected
    constructor CreateNew(AOwner: TPhoaSetting); override;
    function  GetModified: Boolean; override;
    procedure SetModified(Value: Boolean); override;
  public
    constructor Create(AOwner: TPhoaSetting; const sName: String);
    procedure AfterConstruction; override;
    procedure Assign(Source: TPhoaSetting); override;
    procedure RegLoad(RegIniFile: TRegIniFile); override;
    procedure RegSave(RegIniFile: TRegIniFile); override;
    procedure IniLoad(IniFile: TIniFile); override;
    procedure IniSave(IniFile: TIniFile); override;
     // Props
  end;

   //===================================================================================================================
   // ����� ������-�������� � ���������
   //===================================================================================================================

  TPhoaProfilePageSetting = class(TPhoaPageSetting)
  private
     // ��������� ����������� ������
    FModified: Boolean;
  protected
    function  GetEditorClass: TWinControlClass; override;
    function  GetModified: Boolean; override;
    procedure SetModified(Value: Boolean); override;
  public
    procedure RegLoad(RegIniFile: TRegIniFile); override;
    procedure RegSave(RegIniFile: TRegIniFile); override;
    procedure IniLoad(IniFile: TIniFile); override;
    procedure IniSave(IniFile: TIniFile); override;
  end;

implementation
uses TypInfo, Menus, phUtils, Main, Forms, VTHeaderPopup;

type
   //===================================================================================================================
   // TPhoaProfileSettingEditor - �������� �������� ������ TPhoaProfileSetting
   //===================================================================================================================

  TPhoaProfileSettingEditor = class(TVirtualStringTree, IPhoaSettingEditor)
  private
     // �������� � ������ ���� (������� ���������)
    FDataOffset: Cardinal;
     // ������ ����
    FItemDelete: TTBXItem;
    FItemEdit: TTBXItem;
    FItemMoveUp: TTBXItem;
    FItemMoveDown: TTBXItem;
     // Prop storage
    FOnSettingChange: TNotifyEvent;
    FRootSetting: TPhoaProfilePageSetting;
     // ��������� ������ ��������, ����������� � ����� ���� FRootSetting
    procedure LoadTree;
     // �������� OnSettingChange
    procedure DoSettingChange;
     // ���������� ��������� TPhoaProfileSetting, ��������� � �����
    function  GetSetting(Node: PVirtualNode): TPhoaProfileSetting;
     // ���������� True, ���� ���� ������������� ��������� ������ ���������
    function  IsSettingNode(Node: PVirtualNode): Boolean;
     // ����������� Header
    procedure SetupHeader;
     // ������ ������� ������ ����� ����� �������
    procedure UpdateMainColumn;
     // ������ PopupMenu
    procedure CreatePopupMenu;
     // ����������� ����������� ������� PopupMenu
    procedure EnablePopupMenuItems;
     // ������� ����
    procedure DeleteProfileClick(Sender: TObject);
    procedure EditProfileClick(Sender: TObject);
    procedure MoveProfileUpClick(Sender: TObject);
    procedure MoveProfileDownClick(Sender: TObject);
     // ������� Header Menu
    procedure HeaderPopupMenuColumnChange(const Sender: TBaseVirtualTree; const Column: TColumnIndex; Visible: Boolean);
     // IPhoaSettingEditor
    procedure InitAndEmbed(ParentCtl: TWinControl; AOnSettingChange: TNotifyEvent);
    function  GetRootSetting: TPhoaPageSetting;
    procedure SetRootSetting(Value: TPhoaPageSetting);
  protected
    procedure DblClick; override;
    procedure DoChecked(Node: PVirtualNode); override;
    procedure DoFocusChange(Node: PVirtualNode; Column: TColumnIndex); override;
    procedure DoInitNode(ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates); override;
    procedure DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var Index: Integer); override;
    procedure DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString); override;
    procedure DoHeaderDragged(Column: TColumnIndex; OldPosition: TColumnPosition); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // TPhoaProfileSetting
   //===================================================================================================================

  procedure TPhoaProfileSetting.AfterConstruction;
  begin
    inherited AfterConstruction;
     // ����� �������� FModified ������ ������ ���� False
    FModified := False;
  end;

  procedure TPhoaProfileSetting.Assign(Source: TPhoaSetting);
  begin
    inherited Assign(Source);
    if Source is TPhoaProfileSetting then begin
    //#ToDo: ��� ��� �������
    end;
  end;

  constructor TPhoaProfileSetting.Create(AOwner: TPhoaSetting; const sName: String);
  begin
    inherited Create(AOwner, 0, sName);
    //#ToDo: ��� ��� �������
  end;

  constructor TPhoaProfileSetting.CreateNew(AOwner: TPhoaSetting);
  begin
    inherited CreateNew(AOwner);
    //#ToDo: ��� ��� �������
  end;

  function TPhoaProfileSetting.GetModified: Boolean;
  begin
    Result := FModified or inherited GetModified;
  end;

//  function TPhoaProfileSetting.GetStoreSection: String;
//  begin
//    Result := Format('%s\Item%.3d', [SRegPrefs_Profiles, Index]);
//  end;

  procedure TPhoaProfileSetting.IniLoad(IniFile: TIniFile);
  begin
    { ������� [����] �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaProfileSetting.IniSave(IniFile: TIniFile);
  begin
    { ������� [����] �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaProfileSetting.RegLoad(RegIniFile: TRegIniFile);
//  var sSection: String;
  begin
//    sSection := GetStoreSection;
//    FName           := RegIniFile.ReadString (sSection, 'Name',       '');
//    FHint           := RegIniFile.ReadString (sSection, 'Hint',       '');
//    FKind           := PhoaToolKindFromStr(
//                       RegIniFile.ReadString (sSection, 'Kind',       ''),
//                       FKind);
//    FMasks          := RegIniFile.ReadString (sSection, 'Masks',      '');
//    FRunCommand     := RegIniFile.ReadString (sSection, 'RunCmd',     '');
//    FRunFolder      := RegIniFile.ReadString (sSection, 'RunFolder',  '');
//    FRunParameters  := RegIniFile.ReadString (sSection, 'RunParams',  '');
//    FRunShowCommand := RegIniFile.ReadInteger(sSection, 'RunShowCmd', SW_SHOWNORMAL);
//    FUsages         := PhoaToolUsagesFromStr(
//                       RegIniFile.ReadString (sSection, 'Usages',     'M'));
    inherited RegLoad(RegIniFile);
  end;

  procedure TPhoaProfileSetting.RegSave(RegIniFile: TRegIniFile);
//  var sSection: String;
  begin
//    sSection := GetStoreSection;
//    RegIniFile.WriteString (sSection, 'Name',       FName);
//    RegIniFile.WriteString (sSection, 'Hint',       FHint);
//    RegIniFile.WriteString (sSection, 'Kind',       PhoaToolKindToStr(FKind));
//    RegIniFile.WriteString (sSection, 'Masks',      FMasks);
//    RegIniFile.WriteString (sSection, 'RunCmd',     FRunCommand);
//    RegIniFile.WriteString (sSection, 'RunFolder',  FRunFolder);
//    RegIniFile.WriteString (sSection, 'RunParams',  FRunParameters);
//    RegIniFile.WriteInteger(sSection, 'RunShowCmd', FRunShowCommand);
//    RegIniFile.WriteString (sSection, 'Usages',     PhoaToolUsagesToStr(FUsages));
    inherited RegSave(RegIniFile);
  end;

  procedure TPhoaProfileSetting.SetModified(Value: Boolean);
  begin
    FModified := Value;
    inherited SetModified(Value);
  end;

   //===================================================================================================================
   // TPhoaProfilePageSetting
   //===================================================================================================================

  function TPhoaProfilePageSetting.GetEditorClass: TWinControlClass;
  begin
    Result := TPhoaProfileSettingEditor;
  end;

  function TPhoaProfilePageSetting.GetModified: Boolean;
  begin
    Result := FModified or inherited GetModified;
  end;

  procedure TPhoaProfilePageSetting.IniLoad(IniFile: TIniFile);
  begin
    { ������� [����] �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaProfilePageSetting.IniSave(IniFile: TIniFile);
  begin
    { ������� [����] �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaProfilePageSetting.RegLoad(RegIniFile: TRegIniFile);
  var i, iCount: Integer;
  begin
     // �������� ���������� �����
    iCount := RegIniFile.ReadInteger(SRegPrefs_Profiles, 'Count', -1);
     // ���� ���������� �� �������������, ��������� �� ��� ����. ����� ��������� �������
    if iCount>=0 then begin
      ClearChildren;
      for i := 0 to iCount-1 do TPhoaProfileSetting.CreateNew(Self).RegLoad(RegIniFile);
    end;
  end;

  procedure TPhoaProfilePageSetting.RegSave(RegIniFile: TRegIniFile);
  begin
     // ������� ������ ��������
    RegIniFile.EraseSection(SRegPrefs_Profiles);
     // ����� ���������� ��������
    RegIniFile.WriteInteger(SRegPrefs_Profiles, 'Count', ChildCount);
     // ��������� ���� �����
    inherited RegSave(RegIniFile);
  end;

  procedure TPhoaProfilePageSetting.SetModified(Value: Boolean);
  begin
    FModified := Value;
    inherited SetModified(Value);
  end;

   //===================================================================================================================
   // TPhoaProfileSettingEditor
   //===================================================================================================================

  constructor TPhoaProfileSettingEditor.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
     // ������ ���� ������ TPhoaProfileSetting
    FDataOffset := AllocateInternalDataArea(SizeOf(Pointer));
    Align    := alClient;
    Images   := fMain.ilActionsSmall;
     // ����������� Header
    SetupHeader;
    with TreeOptions do begin
      AutoOptions      := [toAutoDropExpand, toAutoScroll];
      MiscOptions      := [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toFullRowDrag, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning];
      PaintOptions     := [toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages];
      SelectionOptions := [toFullRowSelect, toRightClickSelect];
    end;
    HintMode := hmTooltip;
     // ��������� �����
    ApplyTreeSettings(Self);
     // ������ popup-menu
    CreatePopupMenu;
  end;

  procedure TPhoaProfileSettingEditor.CreatePopupMenu;
  var pm: TTBXPopupMenu;

    function NewItem(iImgIdx: Integer; const sCaption, sShortcut: String; const ClickEvent: TNotifyEvent; bDefault: Boolean): TTBXItem;
    begin
      Result := TTBXItem.Create(Self);
      Result.ImageIndex := iImgIdx;
      Result.Caption    := sCaption;
      if bDefault then Result.Options := Result.Options+[tboDefault];
      Result.OnClick    := ClickEvent;
      Result.ShortCut   := TextToShortCut(sShortcut);
      pm.Items.Add(Result);
    end;

    procedure NewSeparator;
    begin
      pm.Items.Add(TTBXSeparatorItem.Create(Self));
    end;

  begin
     // ������ ����
    pm := TTBXPopupMenu.Create(Self);
     // ��������� ��������
    FItemDelete   := NewItem(iiDelete, ConstVal('SAction_Delete'),       'Del',       DeleteProfileClick,   False);
    NewSeparator;
    FItemEdit     := NewItem(iiEdit,   ConstVal('SAction_EditEllipsis'), 'Alt+Enter', EditProfileClick,     True);
    NewSeparator;
    FItemMoveUp   := NewItem(iiUp,     ConstVal('SAction_MoveUp'),       'Ctrl+Up',   MoveProfileUpClick,   False);
    FItemMoveDown := NewItem(iiDown,   ConstVal('SAction_MoveDown'),     'Ctrl+Down', MoveProfileDownClick, False);
     // ����������� ImageList
    pm.Images := fMain.ilActionsSmall;
     // ����������� � ������
    PopupMenu := pm;
  end;

  procedure TPhoaProfileSettingEditor.DblClick;
  begin
    inherited DblClick;
    EditProfileClick(nil);
  end;

  procedure TPhoaProfileSettingEditor.DeleteProfileClick(Sender: TObject);
  var n: PVirtualNode;
  begin
    n := FocusedNode;
    if n<>nil then begin
      GetSetting(n).Free;
      DeleteNode(n);
      FRootSetting.Modified := True;
    end;
  end;

  destructor TPhoaProfileSettingEditor.Destroy;
  begin
     // ��������� �������
    RegSaveVTColumns(SRegPrefs_ProfileEditor, Self);
    inherited Destroy;
  end;

  procedure TPhoaProfileSettingEditor.DoChecked(Node: PVirtualNode);
  var p: TPoint;
  begin
    ActivateVTNode(Self, Node);
    with GetDisplayRect(Node, 0, False) do p := ClientToScreen(Point(Left, Bottom));
    PopupMenu.Popup(p.x, p.y);
  end;

  procedure TPhoaProfileSettingEditor.DoFocusChange(Node: PVirtualNode; Column: TColumnIndex);
  begin
    EnablePopupMenuItems;
  end;

  procedure TPhoaProfileSettingEditor.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var Index: Integer);
  begin
    if (Kind in [ikNormal, ikSelected]) and IsSettingNode(Node) then
      case Column of
        1: Index := iiProfile;
      end;
  end;

  procedure TPhoaProfileSettingEditor.DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    s: String;
//    Setting: TPhoaProfileSetting;
  begin
    s := '';
//    Setting := GetSetting(Node);
//    if Setting<>nil then
//      case Column of
//         // �����
//        0: if Setting.Masks='' then s := ConstVal('SAll') else s := Setting.Masks;
//         // ���
//        1: s := PhoaToolKindName(Setting.Kind);
//         // ���
//        2: s := ConstValEx(Setting.Name);
//         // Hint
//        3: s := ConstValEx(Setting.Hint);
//         // ����������
//        4: if Setting.Kind=ptkCustom then s := Setting.RunCommand;
//         // �����
//        5: if Setting.Kind=ptkCustom then s := Setting.RunFolder;
//         // ���������
//        6: if Setting.Kind=ptkCustom then s := Setting.RunParameters;
//      end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TPhoaProfileSettingEditor.DoHeaderDragged(Column: TColumnIndex; OldPosition: TColumnPosition);
  begin
     // ������ ������� ������ ������ �������
    UpdateMainColumn; 
  end;

  procedure TPhoaProfileSettingEditor.DoInitNode(ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
     // ���� ��� �� ��������� "������" �����, ��������� ����� TPhoaProfileSetting � Node.Data
    if IsSettingNode(Node) then PPhoaSetting(PChar(Node)+FDataOffset)^ := FRootSetting[Node.Index];
     // ����������� CheckType � CheckState - ������
    Node.CheckType := ctButton;
  end;

  procedure TPhoaProfileSettingEditor.DoSettingChange;
  begin
    if Assigned(FOnSettingChange) then FOnSettingChange(Self);
  end;

  procedure TPhoaProfileSettingEditor.EditProfileClick(Sender: TObject);
//  var n: PVirtualNode;
  begin
//    n := FocusedNode;
//    if (n<>nil) and EditTool(GetSetting(n), FRootSetting) then begin
//      DoSettingChange;
//      LoadTree;
//    end;
  end;

  procedure TPhoaProfileSettingEditor.EnablePopupMenuItems;
  var
    n: PVirtualNode;
    idx, idxMaxTool: Integer;
  begin
    n := FocusedNode;
    if n=nil then idx := -1 else idx := n.Index;
    idxMaxTool := RootNodeCount-2;
    FItemDelete.Enabled   := (idx>=0) and (idx<=idxMaxTool);
    FItemEdit.Enabled     := (idx>=0) and (idx<=idxMaxTool+1);
    FItemMoveUp.Enabled   := (idx>0)  and (idx<=idxMaxTool);
    FItemMoveDown.Enabled := (idx>=0) and (idx<idxMaxTool);
  end;

  function TPhoaProfileSettingEditor.GetRootSetting: TPhoaPageSetting;
  begin
    Result := FRootSetting;
  end;

  function TPhoaProfileSettingEditor.GetSetting(Node: PVirtualNode): TPhoaProfileSetting;
  begin
    if Node=nil then Result := nil else Result := PPhoaProfileSetting(PChar(Node)+FDataOffset)^;
  end;

  procedure TPhoaProfileSettingEditor.HeaderPopupMenuColumnChange(const Sender: TBaseVirtualTree; const Column: TColumnIndex; Visible: Boolean);
  begin
     // ��� �������/������ �������� ��������� ������� ������� (������ ���� ����� ����� �� �������)
    UpdateMainColumn;
  end;

  procedure TPhoaProfileSettingEditor.InitAndEmbed(ParentCtl: TWinControl; AOnSettingChange: TNotifyEvent);
  begin
     // Preadjust the bounds to eliminate flicker
    BoundsRect       := ParentCtl.ClientRect;
    Parent           := ParentCtl;
    FOnSettingChange := AOnSettingChange;
  end;

  function TPhoaProfileSettingEditor.IsSettingNode(Node: PVirtualNode): Boolean;
  begin
    Result := (Node<>nil) and (Node.Index<RootNodeCount-1);
  end;

  procedure TPhoaProfileSettingEditor.LoadTree;
  begin
    BeginUpdate;
    try
       // ������������� ���������� ������� � �������� �������� (+1 - �� ������ ������ ��� ����������)
      RootNodeCount := FRootSetting.ChildCount+1;
       // �������������� ��� ����
      ReinitChildren(nil, True);
       // ���� ��� ���������, �������� ������ ����
      if FocusedNode=nil then ActivateVTNode(Self, GetFirst);
    finally
      EndUpdate;
    end;
  end;

  procedure TPhoaProfileSettingEditor.MoveProfileDownClick(Sender: TObject);
  begin
    with GetSetting(FocusedNode) do Index := Index+1;
    MoveTo(FocusedNode, GetNextSibling(FocusedNode), amInsertAfter, False);
    EnablePopupMenuItems;
    DoSettingChange;
  end;

  procedure TPhoaProfileSettingEditor.MoveProfileUpClick(Sender: TObject);
  begin
    with GetSetting(FocusedNode) do Index := Index-1;
    MoveTo(FocusedNode, GetPreviousSibling(FocusedNode), amInsertBefore, False);
    EnablePopupMenuItems;
    DoSettingChange;
  end;

  procedure TPhoaProfileSettingEditor.SetRootSetting(Value: TPhoaPageSetting);
  begin
    if FRootSetting<>Value then begin
      FRootSetting := Value as TPhoaProfilePageSetting;
      LoadTree;
    end;
  end;

  procedure TPhoaProfileSettingEditor.SetupHeader;

    procedure AddColumn(const sConst: String; iWidth: Integer; bVisible: Boolean);
    begin
      with Header.Columns.Add do begin
        Text    := ConstVal(sConst);
        Width   := iWidth;
        Options := Options-[coAllowClick];
        if not bVisible then Options := Options-[coVisible];
      end;
    end;

  begin
    AddColumn('SText_Masks',       80,  True);
    AddColumn('SText_Kind',        200, True);
    AddColumn('SText_Name',        150, True);
    AddColumn('SText_Hint',        200, False);
    AddColumn('SText_Application', 250, True);
    AddColumn('SText_Folder',      150, False);
    AddColumn('SText_Params',      150, False);
    Header.Options   := Header.Options+[hoVisible];
    Header.PopupMenu := TVTHeaderPopupMenu.Create(Self);
    TVTHeaderPopupMenu(Header.PopupMenu).OnColumnChange := HeaderPopupMenuColumnChange;
     // ��������������� �������
    RegLoadVTColumns(SRegPrefs_ProfileEditor, Self);
     // ������ ������� ����� �������
    UpdateMainColumn;
  end;

  procedure TPhoaProfileSettingEditor.UpdateMainColumn;
  var i, idx: Integer;
  begin
     // ���������� ������� � ������� ����������� Position, ���� �� ����� �������
    for i := 0 to Header.Columns.Count-1 do begin
      idx := Header.Columns.ColumnFromPosition(i);
      if (idx>=0) and (coVisible in Header.Columns[idx].Options) then begin
        Header.MainColumn := idx;
        Break;
      end;
    end;
  end;

end.
