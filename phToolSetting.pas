//**********************************************************************************************************************
//  $Id: phToolSetting.pas,v 1.13 2004-09-11 17:52:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phToolSetting;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Registry, IniFiles, VirtualTrees, ActiveX, TB2Item, TBX,
  ConsVars, phSettings, phObj;

type
   // ��� �����������
  TPhoaToolKind = (
    ptkSeparator,  // �����-�����������
    ptkDefault,    // ����������, ����������� �������� �� ���������
    ptkOpen,       // ����������, ����������� �������� ����� �����������
    ptkEdit,       // ����������, ����������� �������������� ����� �����������
    ptkPrint,      // ����������, ����������� ������ ����� �����������
    ptkCustom);    // ����������, ���������� ��������� �������
const
  IPhoaToolKindPrefixLen = 3; // ����� �������� �������� ��������� TPhoaToolKind

type
   // ��� ������������ ������� �����������
  TPhoaToolUsage = (
    ptuToolsMenu,          // � ���� "������"
    ptuGroupPopupMenu,     // � popup-���� ������ �����
    ptuThViewerPopupMenu,  // � popup-���� ���� �������
    ptuViewModePopupMenu); // � popup-���� ������ ���������
  TPhoaToolUsages = set of TPhoaToolUsage;

   //===================================================================================================================
   // TPhoaToolSetting - ���������, �������������� ����� ������ �����������
   //===================================================================================================================

  PPhoaToolSetting = ^TPhoaToolSetting;
  TPhoaToolSetting = class(TPhoaSetting)
  private
     // ��������� ����������� ������
    FModified: Boolean;
     // �����, ��������������� ������� Masks. nil, ���� �� �������
    FMaskObj: TPhoaMasks;
     // Prop storage
    FHint: String;
    FKind: TPhoaToolKind;
    FMasks: String;
    FRunCommand: String;
    FRunFolder: String;
    FRunParameters: String;
    FRunShowCommand: Integer;
    FUsages: TPhoaToolUsages;
     // ���������� ��� ������ ��� ����������/�������� ��������
    function GetStoreSection: String;
     // Prop handlers
    procedure SetHint(const Value: String);
    procedure SetKind(Value: TPhoaToolKind);
    procedure SetMasks(const Value: String);
    procedure SetName(const Value: String);
    procedure SetRunCommand(const Value: String);
    procedure SetRunFolder(const Value: String);
    procedure SetRunParameters(const Value: String);
    procedure SetRunShowCommand(Value: Integer);
    procedure SetUsages(Value: TPhoaToolUsages);
  protected
    constructor CreateNew(AOwner: TPhoaSetting); override;
    function  GetModified: Boolean; override;
    procedure SetModified(Value: Boolean); override;
  public
    constructor Create(AOwner: TPhoaSetting; const sName, sHint, sRunCommand, sRunFolder, sRunParameters, sMasks: String;
                       AKind: TPhoaToolKind; iRunShowCommand: Integer; AUsages: TPhoaToolUsages);
    destructor Destroy; override;
    procedure AfterConstruction; override;
    procedure Assign(Source: TPhoaSetting); override;
    procedure RegLoad(RegIniFile: TRegIniFile); override;
    procedure RegSave(RegIniFile: TRegIniFile); override;
    procedure IniLoad(IniFile: TIniFile); override;
    procedure IniSave(IniFile: TIniFile); override;
     // ���������� True, ���� ���������� �������� ���� ������ �� PicLinks
    function  MatchesFiles(PicLinks: TPhoaPicLinks): Boolean;
     // ��������� ���������� ��� �������� �����������
    procedure Execute(PicLinks: TPhoaPicLinks);
     // Props
     // -- ���������. ������������ �� �������� ConstValEx()
    property Hint: String read FHint write SetHint;
     // -- ��� �����������
    property Kind: TPhoaToolKind read FKind write SetKind;
     // -- ������������, ��������� ��� ������. ������������ �� �������� ConstValEx()
    property Name read FName write SetName;
     // -- ������� ������� (��� Kind=ptkCustom)
    property RunCommand: String read FRunCommand write SetRunCommand;
     // -- ������� ������� (��� Kind=ptkCustom)
    property RunFolder: String read FRunFolder write SetRunFolder;
     // -- ��������� ������� (��� Kind=ptkCustom)
    property RunParameters: String read FRunParameters write SetRunParameters;
     // -- ������� ������ ��� ������� (��������� ���� SW_xxx)
    property RunShowCommand: Integer read FRunShowCommand write SetRunShowCommand;
     // -- ����� ������, ��� ������� �������� ����������
    property Masks: String read FMasks write SetMasks;
     // -- ��� ������������ ����� �����������
    property Usages: TPhoaToolUsages read FUsages write SetUsages;
  end;

   //===================================================================================================================
   // ����� ������-�������� � �������������
   //===================================================================================================================

  TPhoaToolPageSetting = class(TPhoaPageSetting)
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

   // �������������� TPhoaToolKind <-> String
  function PhoaToolKindToStr(Kind: TPhoaToolKind): String;
  function PhoaToolKindFromStr(const sKind: String; Default: TPhoaToolKind): TPhoaToolKind;
   // �������������� TPhoaToolUsages <-> String
  function PhoaToolUsagesToStr(Usages: TPhoaToolUsages): String;
  function PhoaToolUsagesFromStr(const sUsages: String): TPhoaToolUsages;
   // ���������� �������� ���� �����������
  function PhoaToolKindName(Kind: TPhoaToolKind): String;

   // ������ ����� ���� ����������� Tool � ��������� ��� � ������ �������� ������� ������ Item
  procedure AddToolItem(Tool: TPhoaToolSetting; Item: TTBCustomItem; AOnClick: TNotifyEvent);
   // ����������� ��������� ������������ �� �� ����������� (������������) � ������ ������ �� �����������
  procedure AdjustToolAvailability(Page: TPhoaToolPageSetting; Item: TTBCustomItem; PicLinks: TPhoaPicLinks);

const
   // ������������ ������� ���� �����������
  aToolImageIndexes: Array[TPhoaToolKind] of Integer = (
    iiSeparator, // ptkSeparator
    iiOK,        // ptkDefault
    iiOpen,      // ptkOpen
    iiEdit,      // ptkEdit
    iiPrint,     // ptkPrint
    iiAction);   // ptkCustom

implementation
uses TypInfo, ShellAPI, Menus, phUtils, Main, udToolProps, Forms, VTHeaderPopup;

  function PhoaToolKindToStr(Kind: TPhoaToolKind): String;
  begin
    Result := Copy(GetEnumName(TypeInfo(TPhoaToolKind), Byte(Kind)), IPhoaToolKindPrefixLen+1, MaxInt);
  end;

  function PhoaToolKindFromStr(const sKind: String; Default: TPhoaToolKind): TPhoaToolKind;
  begin
    for Result := Low(Result) to High(Result) do
      if AnsiSameText(sKind, PhoaToolKindToStr(Result)) then Exit;
    Result := Default;
  end;

  function PhoaToolUsagesToStr(Usages: TPhoaToolUsages): String;
  begin
    Result :=
      iif(ptuToolsMenu in Usages,         'M', '')+
      iif(ptuGroupPopupMenu in Usages,    'G', '')+
      iif(ptuThViewerPopupMenu in Usages, 'V', '')+
      iif(ptuViewModePopupMenu in Usages, 'W', '');
  end;

  function PhoaToolUsagesFromStr(const sUsages: String): TPhoaToolUsages;
  begin
    Result := [];
    if AnsiStrScan(PChar(sUsages), 'M')<>nil then Include(Result, ptuToolsMenu);
    if AnsiStrScan(PChar(sUsages), 'G')<>nil then Include(Result, ptuGroupPopupMenu);
    if AnsiStrScan(PChar(sUsages), 'V')<>nil then Include(Result, ptuThViewerPopupMenu);
    if AnsiStrScan(PChar(sUsages), 'W')<>nil then Include(Result, ptuViewModePopupMenu);
  end;

  function PhoaToolKindName(Kind: TPhoaToolKind): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TPhoaToolKind), Byte(Kind)));
  end;

  procedure AddToolItem(Tool: TPhoaToolSetting; Item: TTBCustomItem; AOnClick: TNotifyEvent);
  var ti: TTBCustomItem;
  begin
    if Tool.Kind=ptkSeparator then
      ti := TTBXSeparatorItem.Create(Item)
    else begin
      ti := TTBXItem.Create(Item);
      ti.Caption    := ConstValEx(Tool.Name);
      ti.Hint       := ConstValEx(Tool.Hint);
      ti.ImageIndex := aToolImageIndexes[Tool.Kind];
      ti.OnClick    := AOnClick;
    end;
     // Tag ������ ���� = ������� ����������� � ������������ ������, �.�. � �������� (������ ������ �� ����������� ���
     //   �����������, ��������� ������� ������������ �������� ��� ���������������� ����� Assign ������ ��� ��� ������
     //   ������� ��������)
    ti.Tag := Tool.Index;
    Item.Add(ti);
  end;

  procedure AdjustToolAvailability(Page: TPhoaToolPageSetting; Item: TTBCustomItem; PicLinks: TPhoaPicLinks);
  var
    i: Integer;
    ti: TTBCustomItem;
  begin
    for i := 0 to Item.Count-1 do begin
      ti := Item[i];
      ti.Visible := (Page[ti.Tag] as TPhoaToolSetting).MatchesFiles(PicLinks);
    end;
  end;

type
   //===================================================================================================================
   // TPhoaToolSettingEditor - �������� �������� ������ TPhoaToolSetting
   //===================================================================================================================

  TPhoaToolSettingEditor = class(TVirtualStringTree, IPhoaSettingEditor)
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
    FRootSetting: TPhoaToolPageSetting;
     // ��������� ������ ��������, ����������� � ����� ���� FRootSetting
    procedure LoadTree;
     // �������� OnSettingChange
    procedure DoSettingChange;
     // ���������� ��������� TPhoaToolSetting, ��������� � �����
    function  GetSetting(Node: PVirtualNode): TPhoaToolSetting;
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
    procedure DeleteToolClick(Sender: TObject);
    procedure EditToolClick(Sender: TObject);
    procedure MoveToolUpClick(Sender: TObject);
    procedure MoveToolDownClick(Sender: TObject);
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
    function  DoBeforeDrag(Node: PVirtualNode; Column: TColumnIndex): Boolean; override;
    procedure DoDragDrop(Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode); override;
    function  DoDragOver(Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer): Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // TPhoaToolSetting
   //===================================================================================================================

  procedure TPhoaToolSetting.AfterConstruction;
  begin
    inherited AfterConstruction;
     // ����� �������� FModified ������ ������ ���� False
    FModified := False;
  end;

  procedure TPhoaToolSetting.Assign(Source: TPhoaSetting);
  begin
    inherited Assign(Source);
    if Source is TPhoaToolSetting then begin
      FHint           := TPhoaToolSetting(Source).FHint;
      FKind           := TPhoaToolSetting(Source).FKind;
      FMasks          := TPhoaToolSetting(Source).FMasks;
      FModified       := TPhoaToolSetting(Source).FModified;
      FRunCommand     := TPhoaToolSetting(Source).FRunCommand;
      FRunFolder      := TPhoaToolSetting(Source).FRunFolder;
      FRunParameters  := TPhoaToolSetting(Source).FRunParameters;
      FRunShowCommand := TPhoaToolSetting(Source).FRunShowCommand;
      FUsages         := TPhoaToolSetting(Source).FUsages;
    end;
  end;

  constructor TPhoaToolSetting.Create(AOwner: TPhoaSetting; const sName, sHint, sRunCommand, sRunFolder, sRunParameters, sMasks: String; AKind: TPhoaToolKind; iRunShowCommand: Integer; AUsages: TPhoaToolUsages);
  begin
    inherited Create(AOwner, 0, sName);
    FHint           := sHint;
    FRunCommand     := sRunCommand;
    FRunFolder      := sRunFolder;
    FRunParameters  := sRunParameters;
    FMasks          := sMasks;
    FKind           := AKind;
    FRunShowCommand := iRunShowCommand;
    FUsages         := AUsages;
  end;

  constructor TPhoaToolSetting.CreateNew(AOwner: TPhoaSetting);
  begin
    inherited CreateNew(AOwner);
    FKind           := ptkDefault;
    FRunShowCommand := SW_SHOWNORMAL;
    FUsages         := [ptuToolsMenu];
  end;

  destructor TPhoaToolSetting.Destroy;
  begin
    FMaskObj.Free;
    inherited Destroy;
  end;

  procedure TPhoaToolSetting.Execute(PicLinks: TPhoaPicLinks);
  var
    i, iRes: Integer;
    sFileName, sQFileName: String;
  begin
    if FKind<>ptkSeparator then begin
      iRes := 0; // Satisfy the compiler
      for i := 0 to PicLinks.Count-1 do begin
        sFileName  := PicLinks[i].PicFileName;
        sQFileName := AnsiQuotedStr(sFileName, '"');
        case FKind of
          ptkDefault: iRes := ShellExecute(Application.Handle, nil,     PChar(sQFileName), nil, nil, SW_SHOWNORMAL);
          ptkOpen:    iRes := ShellExecute(Application.Handle, 'open',  PChar(sQFileName), nil, nil, SW_SHOWNORMAL);
          ptkEdit:    iRes := ShellExecute(Application.Handle, 'edit',  PChar(sQFileName), nil, nil, SW_SHOWNORMAL);
          ptkPrint:   iRes := ShellExecute(Application.Handle, 'print', PChar(sQFileName), nil, nil, SW_SHOWNORMAL);
          ptkCustom:  iRes := ShellExecute(Application.Handle, nil,     PChar(FRunCommand), PChar(FRunParameters+' '+sQFileName), PChar(FRunFolder), SW_SHOWNORMAL);
        end;
         // ��������� ���������
        if iRes<=32 then PhoaException(ConstVal('SErrExecutingToolFailed'), [FName, sFileName, SysErrorMessage(GetLastError)]);
      end;
    end;
  end;

  function TPhoaToolSetting.GetModified: Boolean;
  begin
    Result := FModified or inherited GetModified;
  end;

  function TPhoaToolSetting.GetStoreSection: String;
  begin
    Result := Format('%s\Item%.3d', [SRegPrefs_Tools, Index]);
  end;

  procedure TPhoaToolSetting.IniLoad(IniFile: TIniFile);
  begin
    { ����������� �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaToolSetting.IniSave(IniFile: TIniFile);
  begin
    { ����������� �� ������������ �������� � Ini-������ }
  end;

  function TPhoaToolSetting.MatchesFiles(PicLinks: TPhoaPicLinks): Boolean;
  var i: Integer;
  begin
     // ���� ��������� ����������� ��� - �� ��������
    if PicLinks.Count=0 then
      Result := False
    else begin
       // ������ �����, ���� �����
      if FMaskObj=nil then FMaskObj := TPhoaMasks.Create(FMasks);
       // ���� ����� ������ - �������� ������
      Result := FMaskObj.Empty;
       // ����� ���������� ��� �����: ������ ��������� ���
      if not Result then begin
        Result := True;
        for i := 0 to PicLinks.Count-1 do
          if not FMaskObj.Matches(PicLinks[i].PicFileName) then begin
            Result := False;
            Break;
          end;
        end;
    end;
  end;

  procedure TPhoaToolSetting.RegLoad(RegIniFile: TRegIniFile);
  var sSection: String;
  begin
    sSection := GetStoreSection;
    FName           := RegIniFile.ReadString (sSection, 'Name',       '');
    FHint           := RegIniFile.ReadString (sSection, 'Hint',       '');
    FKind           := PhoaToolKindFromStr(
                       RegIniFile.ReadString (sSection, 'Kind',       ''),
                       FKind);
    FMasks          := RegIniFile.ReadString (sSection, 'Masks',      '');
    FRunCommand     := RegIniFile.ReadString (sSection, 'RunCmd',     '');
    FRunFolder      := RegIniFile.ReadString (sSection, 'RunFolder',  '');
    FRunParameters  := RegIniFile.ReadString (sSection, 'RunParams',  '');
    FRunShowCommand := RegIniFile.ReadInteger(sSection, 'RunShowCmd', SW_SHOWNORMAL);
    FUsages         := PhoaToolUsagesFromStr(
                       RegIniFile.ReadString (sSection, 'Usages',     'M'));
    inherited RegLoad(RegIniFile);
  end;

  procedure TPhoaToolSetting.RegSave(RegIniFile: TRegIniFile);
  var sSection: String;
  begin
    sSection := GetStoreSection;
    RegIniFile.WriteString (sSection, 'Name',       FName);
    RegIniFile.WriteString (sSection, 'Hint',       FHint);
    RegIniFile.WriteString (sSection, 'Kind',       PhoaToolKindToStr(FKind));
    RegIniFile.WriteString (sSection, 'Masks',      FMasks);
    RegIniFile.WriteString (sSection, 'RunCmd',     FRunCommand);
    RegIniFile.WriteString (sSection, 'RunFolder',  FRunFolder);
    RegIniFile.WriteString (sSection, 'RunParams',  FRunParameters);
    RegIniFile.WriteInteger(sSection, 'RunShowCmd', FRunShowCommand);
    RegIniFile.WriteString (sSection, 'Usages',     PhoaToolUsagesToStr(FUsages));
    inherited RegSave(RegIniFile);
  end;

  procedure TPhoaToolSetting.SetHint(const Value: String);
  begin
    if FHint<>Value then begin
      FHint := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetKind(Value: TPhoaToolKind);
  begin
    if FKind<>Value then begin
      FKind := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetMasks(const Value: String);
  begin
    if FMasks<>Value then begin
      FMasks := Value;
      FreeAndNil(FMaskObj);
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetModified(Value: Boolean);
  begin
    FModified := Value;
    inherited SetModified(Value);
  end;

  procedure TPhoaToolSetting.SetName(const Value: String);
  begin
    if FName<>Value then begin
      FName := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetRunCommand(const Value: String);
  begin
    if FRunCommand<>Value then begin
      FRunCommand := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetRunFolder(const Value: String);
  begin
    if FRunFolder<>Value then begin
      FRunFolder := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetRunParameters(const Value: String);
  begin
    if FRunParameters<>Value then begin
      FRunParameters := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetRunShowCommand(Value: Integer);
  begin
    if FRunShowCommand<>Value then begin
      FRunShowCommand := Value;
      FModified := True;
    end;
  end;

  procedure TPhoaToolSetting.SetUsages(Value: TPhoaToolUsages);
  begin
    if FUsages<>Value then begin
      FUsages := Value;
      FModified := True;
    end;
  end;

   //===================================================================================================================
   // TPhoaToolPageSetting
   //===================================================================================================================

  function TPhoaToolPageSetting.GetEditorClass: TWinControlClass;
  begin
    Result := TPhoaToolSettingEditor;
  end;

  function TPhoaToolPageSetting.GetModified: Boolean;
  begin
    Result := FModified or inherited GetModified;
  end;

  procedure TPhoaToolPageSetting.IniLoad(IniFile: TIniFile);
  begin
    { ����������� �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaToolPageSetting.IniSave(IniFile: TIniFile);
  begin
    { ����������� �� ������������ �������� � Ini-������ }
  end;

  procedure TPhoaToolPageSetting.RegLoad(RegIniFile: TRegIniFile);
  var i, iCount: Integer;
  begin
     // �������� ���������� �����
    iCount := RegIniFile.ReadInteger(SRegPrefs_Tools, 'Count', -1);
     // ���� ���������� �� �������������, ��������� �� ��� ����. ����� ��������� �����������
    if iCount>=0 then begin
      ClearChildren;
      for i := 0 to iCount-1 do TPhoaToolSetting.CreateNew(Self).RegLoad(RegIniFile);
    end;
  end;

  procedure TPhoaToolPageSetting.RegSave(RegIniFile: TRegIniFile);
  begin
     // ������� ������ ������������
    RegIniFile.EraseSection(SRegPrefs_Tools);
     // ����� ���������� ������������
    RegIniFile.WriteInteger(SRegPrefs_Tools, 'Count', ChildCount);
     // ��������� ���� �����
    inherited RegSave(RegIniFile);
  end;

  procedure TPhoaToolPageSetting.SetModified(Value: Boolean);
  begin
    FModified := Value;
    inherited SetModified(Value);
  end;

   //===================================================================================================================
   // TPhoaToolSettingEditor
   //===================================================================================================================

  constructor TPhoaToolSettingEditor.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
     // ������ ���� ������ TPhoaToolSetting
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

  procedure TPhoaToolSettingEditor.CreatePopupMenu;
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
    FItemDelete   := NewItem(iiDelete, ConstVal('SAction_Delete'),       'Del',       DeleteToolClick,   False);
    NewSeparator;
    FItemEdit     := NewItem(iiEdit,   ConstVal('SAction_EditEllipsis'), 'Alt+Enter', EditToolClick,     True);
    NewSeparator;
    FItemMoveUp   := NewItem(iiUp,     ConstVal('SAction_MoveUp'),       'Ctrl+Up',   MoveToolUpClick,   False);
    FItemMoveDown := NewItem(iiDown,   ConstVal('SAction_MoveDown'),     'Ctrl+Down', MoveToolDownClick, False);
     // ����������� ImageList
    pm.Images := fMain.ilActionsSmall;
     // ����������� � ������
    PopupMenu := pm;
  end;

  procedure TPhoaToolSettingEditor.DblClick;
  begin
    inherited DblClick;
    EditToolClick(nil);
  end;

  procedure TPhoaToolSettingEditor.DeleteToolClick(Sender: TObject);
  var n: PVirtualNode;
  begin
    n := FocusedNode;
    if n<>nil then begin
      GetSetting(n).Free;
      DeleteNode(n);
      FRootSetting.Modified := True;
    end;
  end;

  destructor TPhoaToolSettingEditor.Destroy;
  begin
     // ��������� �������
    RegSaveVTColumns(SRegPrefs_ToolEditor, Self);
    inherited Destroy;
  end;

  function TPhoaToolSettingEditor.DoBeforeDrag(Node: PVirtualNode; Column: TColumnIndex): Boolean;
  begin
    Result := IsSettingNode(Node);
  end;

  procedure TPhoaToolSettingEditor.DoChecked(Node: PVirtualNode);
  var p: TPoint;
  begin
    ActivateVTNode(Self, Node);
    with GetDisplayRect(Node, 0, False) do p := ClientToScreen(Point(Left, Bottom));
    PopupMenu.Popup(p.x, p.y);
  end;

  procedure TPhoaToolSettingEditor.DoDragDrop(Source: TObject; DataObject: IDataObject; Formats: TFormatArray; Shift: TShiftState; Pt: TPoint; var Effect: Integer; Mode: TDropMode);
  var
    nSrc, nTgt: PVirtualNode;
    idxNew: Integer;
    am: TVTNodeAttachMode;
  begin
    nSrc := FocusedNode;
    nTgt := DropTargetNode;
    idxNew := nTgt.Index;
    if idxNew>Integer(nSrc.Index) then Dec(idxNew);
    if Mode=dmBelow then begin
      Inc(idxNew);
      am := amInsertAfter;
    end else
      am := amInsertBefore;
    GetSetting(nSrc).Index := idxNew;
    MoveTo(nSrc, nTgt, am, False);
    EnablePopupMenuItems;
    DoSettingChange;
  end;

  function TPhoaToolSettingEditor.DoDragOver(Source: TObject; Shift: TShiftState; State: TDragState; Pt: TPoint; Mode: TDropMode; var Effect: Integer): Boolean;
  var nSrc, nTgt: PVirtualNode;
  begin
    nSrc := FocusedNode;
    nTgt := DropTargetNode;
    Result := (Source=Self) and (nTgt<>nil) and (nSrc<>nTgt);
    if Result then
      case Mode of
        dmAbove: Result := nTgt.Index<>nSrc.Index+1;
        dmBelow: Result := (nTgt.Index<>nSrc.Index-1) and IsSettingNode(nTgt);
        else     Result := False;
      end;
    Effect := DROPEFFECT_MOVE;
  end;

  procedure TPhoaToolSettingEditor.DoFocusChange(Node: PVirtualNode; Column: TColumnIndex);
  begin
    EnablePopupMenuItems;
  end;

  procedure TPhoaToolSettingEditor.DoGetImageIndex(Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var Index: Integer);
  begin
    if (Kind in [ikNormal, ikSelected]) and (Node.Index<RootNodeCount-1) then
      case Column of
        1: Index := aToolImageIndexes[GetSetting(Node).Kind];
      end;
  end;

  procedure TPhoaToolSettingEditor.DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    s: String;
    Setting: TPhoaToolSetting;
  begin
    s := '';
    Setting := GetSetting(Node);
    if Setting<>nil then
      case Column of
         // �����
        0: if Setting.Masks='' then s := ConstVal('SAll') else s := Setting.Masks;
         // ���
        1: s := PhoaToolKindName(Setting.Kind);
         // ���
        2: s := ConstValEx(Setting.Name);
         // Hint
        3: s := ConstValEx(Setting.Hint);
         // ����������
        4: if Setting.Kind=ptkCustom then s := Setting.RunCommand;
         // �����
        5: if Setting.Kind=ptkCustom then s := Setting.RunFolder;
         // ���������
        6: if Setting.Kind=ptkCustom then s := Setting.RunParameters;
      end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TPhoaToolSettingEditor.DoHeaderDragged(Column: TColumnIndex; OldPosition: TColumnPosition);
  begin
     // ������ ������� ������ ������ �������
    UpdateMainColumn; 
  end;

  procedure TPhoaToolSettingEditor.DoInitNode(ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
     // ���� ��� �� ��������� "������" �����, ��������� ����� TPhoaToolSetting � Node.Data
    if Node.Index<RootNodeCount-1 then PPhoaSetting(PChar(Node)+FDataOffset)^ := FRootSetting[Node.Index];
     // ����������� CheckType � CheckState - ������
    Node.CheckType := ctButton;
  end;

  procedure TPhoaToolSettingEditor.DoSettingChange;
  begin
    if Assigned(FOnSettingChange) then FOnSettingChange(Self);
  end;

  procedure TPhoaToolSettingEditor.EditToolClick(Sender: TObject);
  var n: PVirtualNode;
  begin
    n := FocusedNode;
    if (n<>nil) and EditTool(GetSetting(n), FRootSetting) then begin
      DoSettingChange;
      LoadTree;
    end;
  end;

  procedure TPhoaToolSettingEditor.EnablePopupMenuItems;
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

  function TPhoaToolSettingEditor.GetRootSetting: TPhoaPageSetting;
  begin
    Result := FRootSetting;
  end;

  function TPhoaToolSettingEditor.GetSetting(Node: PVirtualNode): TPhoaToolSetting;
  begin
    if Node=nil then Result := nil else Result := PPhoaToolSetting(PChar(Node)+FDataOffset)^;
  end;

  procedure TPhoaToolSettingEditor.HeaderPopupMenuColumnChange(const Sender: TBaseVirtualTree; const Column: TColumnIndex; Visible: Boolean);
  begin
     // ��� �������/������ �������� ��������� ������� ������� (������ ���� ����� ����� �� �������)
    UpdateMainColumn;
  end;

  procedure TPhoaToolSettingEditor.InitAndEmbed(ParentCtl: TWinControl; AOnSettingChange: TNotifyEvent);
  begin
     // Preadjust the bounds to eliminate flicker
    BoundsRect       := ParentCtl.ClientRect;
    Parent           := ParentCtl;
    FOnSettingChange := AOnSettingChange;
  end;

  function TPhoaToolSettingEditor.IsSettingNode(Node: PVirtualNode): Boolean;
  begin
    Result := (Node<>nil) and (Node.Index<RootNodeCount-1);
  end;

  procedure TPhoaToolSettingEditor.LoadTree;
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

  procedure TPhoaToolSettingEditor.MoveToolDownClick(Sender: TObject);
  begin
    with GetSetting(FocusedNode) do Index := Index+1;
    MoveTo(FocusedNode, GetNextSibling(FocusedNode), amInsertAfter, False);
    EnablePopupMenuItems;
    DoSettingChange;
  end;

  procedure TPhoaToolSettingEditor.MoveToolUpClick(Sender: TObject);
  begin
    with GetSetting(FocusedNode) do Index := Index-1;
    MoveTo(FocusedNode, GetPreviousSibling(FocusedNode), amInsertBefore, False);
    EnablePopupMenuItems;
    DoSettingChange;
  end;

  procedure TPhoaToolSettingEditor.SetRootSetting(Value: TPhoaPageSetting);
  begin
    if FRootSetting<>Value then begin
      FRootSetting := Value as TPhoaToolPageSetting;
      LoadTree;
    end;
  end;

  procedure TPhoaToolSettingEditor.SetupHeader;

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
    RegLoadVTColumns(SRegPrefs_ToolEditor, Self);
     // ������ ������� ����� �������
    UpdateMainColumn;
  end;

  procedure TPhoaToolSettingEditor.UpdateMainColumn;
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
