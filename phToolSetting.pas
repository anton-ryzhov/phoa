//**********************************************************************************************************************
//  $Id: phToolSetting.pas,v 1.1 2004-04-24 18:48:31 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phToolSetting;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Registry, IniFiles, VirtualTrees,
  ConsVars, phSettings;

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
  IPhoaToolKindPrefixLen = 3; // ����� �������� ��������� TPhoaToolKind

type
   // ��� ������������ ������� �����������
  TPhoaToolUsage = (
    ptuToolsMenu,          // � ���� "������"
    ptuGroupPopupMenu,     // � popup-���� ������ �����
    ptuThViewerPopupMenu); // � popup-���� ���� �������
  TPhoaToolUsages = set of TPhoaToolUsage;

   //===================================================================================================================
   // TPhoaToolSetting - ���������, �������������� ����� ������ �����������
   //===================================================================================================================

  PPhoaToolSetting = ^TPhoaToolSetting;
  TPhoaToolSetting = class(TPhoaSetting)
  private
     // Prop storage
    FCaption: String;
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
  protected
    constructor CreateNew(AOwner: TPhoaSetting); override;
  public
    constructor Create(AOwner: TPhoaSetting; const sCaption, sHint, sRunCommand, sRunFolder, sRunParameters, sMasks: String;
                       AKind: TPhoaToolKind; iRunShowCommand: Integer; AUsages: TPhoaToolUsages);
    procedure Assign(Source: TPhoaSetting); override;
    procedure RegLoad(RegIniFile: TRegIniFile); override;
    procedure RegSave(RegIniFile: TRegIniFile); override;
    procedure IniLoad(IniFile: TIniFile); override;
    procedure IniSave(IniFile: TIniFile); override;
     // Props
     // -- ������������ �����������
    property Caption: String read FCaption write FCaption;
     // -- ���������
    property Hint: String read FHint write FHint;
     // -- ��� �����������
    property Kind: TPhoaToolKind read FKind write FKind;
     // -- ������� ������� (��� Kind=ptkCustom)
    property RunCommand: String read FRunCommand write FRunCommand;
     // -- ������� ������� (��� Kind=ptkCustom)
    property RunFolder: String read FRunFolder write FRunFolder;
     // -- ��������� ������� (��� Kind=ptkCustom)
    property RunParameters: String read FRunParameters write FRunParameters;
     // -- ������� ������ ��� ������� (��������� ���� SW_xxx)
    property RunShowCommand: Integer read FRunShowCommand write FRunShowCommand;
     // -- ����� ������, ��� ������� �������� ����������
    property Masks: String read FMasks write FMasks;
     // -- ��� ������������ ����� �����������
    property Usages: TPhoaToolUsages read FUsages write FUsages;
  end;

   //===================================================================================================================
   // ����� ������-�������� � �������������
   //===================================================================================================================

  TPhoaToolPageSetting = class(TPhoaPageSetting)
  protected
    function  GetEditorClass: TWinControlClass; override;
  end;

   // �������������� TPhoaToolKind <-> String
  function PhoaToolKindToStr(Kind: TPhoaToolKind): String;
  function PhoaToolKindFromStr(const sKind: String; Default: TPhoaToolKind): TPhoaToolKind;
   // �������������� TPhoaToolUsages <-> String
  function PhoaToolUsagesToStr(Usages: TPhoaToolUsages): String;
  function PhoaToolUsagesFromStr(const sUsages: String): TPhoaToolUsages;

implementation
uses TypInfo, phUtils, TBX, Main;

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
      iif(ptuThViewerPopupMenu in Usages, 'V', '');
  end;

  function PhoaToolUsagesFromStr(const sUsages: String): TPhoaToolUsages;
  begin
    Result := [];
    if AnsiStrScan(PChar(sUsages), 'M')<>nil then Include(Result, ptuToolsMenu);
    if AnsiStrScan(PChar(sUsages), 'G')<>nil then Include(Result, ptuGroupPopupMenu);
    if AnsiStrScan(PChar(sUsages), 'V')<>nil then Include(Result, ptuThViewerPopupMenu);
  end;

type
   //===================================================================================================================
   // TPhoaToolSettingEditor - �������� �������� ������ TPhoaToolSetting
   //===================================================================================================================

  TPhoaToolSettingEditor = class(TVirtualStringTree, IPhoaSettingEditor)
  private
     // �������� � ������ ���� (������� ���������)
    FDataOffset: Cardinal;
     // Prop storage
    FOnSettingChange: TNotifyEvent;
    FOnDecodeText: TPhoaSettingDecodeTextEvent;
    FRootSetting: TPhoaToolPageSetting;
     // ��������� ������ ��������, ����������� � ����� ���� FRootSetting
    procedure LoadTree;
     // �������� OnSettingChange
    procedure DoSettingChange;
     // ���������� ��������� TPhoaToolSetting, ��������� � �����
    function  GetSetting(Node: PVirtualNode): TPhoaToolSetting;
     // ����������� Header
    procedure SetupHeader;
     // ������ PopupMenu
    procedure CreatePopupMenu;
     // ������� ����
    procedure AddToolClick(Sender: TObject);
    procedure DeleteToolClick(Sender: TObject);
    procedure EditToolClick(Sender: TObject);
     // IPhoaSettingEditor
    procedure InitAndEmbed(ParentCtl: TWinControl; AOnSettingChange: TNotifyEvent; AOnDecodeText: TPhoaSettingDecodeTextEvent);
    function  GetRootSetting: TPhoaPageSetting;
    procedure SetRootSetting(Value: TPhoaPageSetting);
  protected
//    procedure DoAfterCellPaint(TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect); override;
    procedure DoChecked(Node: PVirtualNode); override;
//    procedure DoFocusChange(Node: PVirtualNode; Column: TColumnIndex); override;
    procedure DoInitNode(ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates); override;
    procedure DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString); override;
//    procedure DoPaintText(Node: PVirtualNode; const Canvas: TCanvas; Column: TColumnIndex; TextType: TVSTTextType); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

   //===================================================================================================================
   // TPhoaToolSetting
   //===================================================================================================================

  procedure TPhoaToolSetting.Assign(Source: TPhoaSetting);
  begin
    inherited Assign(Source);
    if Source is TPhoaToolSetting then begin
      FCaption        := TPhoaToolSetting(Source).FCaption;
      FHint           := TPhoaToolSetting(Source).FHint;
      FKind           := TPhoaToolSetting(Source).FKind;
      FMasks          := TPhoaToolSetting(Source).FMasks;
      FRunCommand     := TPhoaToolSetting(Source).FRunCommand;
      FRunFolder      := TPhoaToolSetting(Source).FRunFolder;
      FRunParameters  := TPhoaToolSetting(Source).FRunParameters;
      FRunShowCommand := TPhoaToolSetting(Source).FRunShowCommand;
      FUsages         := TPhoaToolSetting(Source).FUsages;
    end;
  end;

  constructor TPhoaToolSetting.Create(AOwner: TPhoaSetting; const sCaption, sHint, sRunCommand, sRunFolder, sRunParameters, sMasks: String; AKind: TPhoaToolKind; iRunShowCommand: Integer; AUsages: TPhoaToolUsages);
  begin
    inherited Create(AOwner, 0, '');
    FCaption        := sCaption;
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

  function TPhoaToolSetting.GetStoreSection: String;
  begin
    Result := Format('%s\Item%.3d', [SRegPrefTools, Index]);
  end;

  procedure TPhoaToolSetting.IniLoad(IniFile: TIniFile);
  var sSection: String;
  begin
    sSection := GetStoreSection;
    FCaption        := IniFile.ReadString (sSection, 'Caption',    '');
    FHint           := IniFile.ReadString (sSection, 'Hint',       '');
    FKind           := PhoaToolKindFromStr(
                       IniFile.ReadString (sSection, 'Kind',       ''),
                       FKind);
    FMasks          := IniFile.ReadString (sSection, 'Masks',      '');
    FRunCommand     := IniFile.ReadString (sSection, 'RunCmd',     '');
    FRunFolder      := IniFile.ReadString (sSection, 'RunFolder',  '');
    FRunParameters  := IniFile.ReadString (sSection, 'RunParams',  '');
    FRunShowCommand := IniFile.ReadInteger(sSection, 'RunShowCmd', SW_SHOWNORMAL);
    FUsages         := PhoaToolUsagesFromStr(
                       IniFile.ReadString (sSection, 'Usages',     'M'));
    inherited IniLoad(IniFile);
  end;

  procedure TPhoaToolSetting.IniSave(IniFile: TIniFile);
  var sSection: String;
  begin
    sSection := GetStoreSection;
    IniFile.WriteString (sSection, 'Caption',    FCaption);
    IniFile.WriteString (sSection, 'Hint',       FHint);
    IniFile.WriteString (sSection, 'Kind',       PhoaToolKindToStr(FKind));
    IniFile.WriteString (sSection, 'Masks',      FMasks);
    IniFile.WriteString (sSection, 'RunCmd',     FRunCommand);
    IniFile.WriteString (sSection, 'RunFolder',  FRunFolder);
    IniFile.WriteString (sSection, 'RunParams',  FRunParameters);
    IniFile.WriteInteger(sSection, 'RunShowCmd', FRunShowCommand);
    IniFile.WriteString (sSection, 'Usages',     PhoaToolUsagesToStr(FUsages));
    inherited IniSave(IniFile);
  end;

  procedure TPhoaToolSetting.RegLoad(RegIniFile: TRegIniFile);
  var sSection: String;
  begin
    sSection := GetStoreSection;
    FCaption        := RegIniFile.ReadString (sSection, 'Caption',    '');
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
    RegIniFile.WriteString (sSection, 'Caption',    FCaption);
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

   //===================================================================================================================
   // TPhoaToolPageSetting
   //===================================================================================================================

  function TPhoaToolPageSetting.GetEditorClass: TWinControlClass;
  begin
    Result := TPhoaToolSettingEditor;
  end;

   //===================================================================================================================
   // TPhoaToolSettingEditor
   //===================================================================================================================

  procedure TPhoaToolSettingEditor.AddToolClick(Sender: TObject);
  begin
    //
  end;

  constructor TPhoaToolSettingEditor.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
     // ������ ���� ������ TPhoaToolSetting
    FDataOffset := AllocateInternalDataArea(SizeOf(Pointer));
    Align := alClient;
     // ����������� Header
    SetupHeader;
    with TreeOptions do begin
      AutoOptions      := [toAutoDropExpand, toAutoScroll, toAutoTristateTracking, toAutoDeleteMovedNodes];
      MiscOptions      := [toCheckSupport, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toToggleOnDblClick, toWheelPanning];
      PaintOptions     := [toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages];
      SelectionOptions := [toFullRowSelect];
    end;
    HintMode := hmTooltip;
     // ��������� �����
    ApplyTreeSettings(Self);
     // ������ popup-menu
    CreatePopupMenu;
  end;

  procedure TPhoaToolSettingEditor.CreatePopupMenu;
  var pm: TTBXPopupMenu;

    procedure NewItem(iImgIdx: Integer; const sCaption: String; const ClickEvent: TNotifyEvent);
    var itm: TTBXItem;
    begin
      itm := TTBXItem.Create(Self);
      itm.ImageIndex := iImgIdx;
      itm.Caption    := sCaption;
      itm.OnClick    := ClickEvent;
      pm.Items.Add(itm);
    end;

  begin
    pm := TTBXPopupMenu.Create(Self);
    NewItem(iiUp{!!!}, 'Add',        AddToolClick);
    NewItem(iiDelete,  'Delete',     DeleteToolClick);
    pm.Items.Add(TTBXSeparatorItem.Create(Self));
    NewItem(iiEdit,    'Properties', EditToolClick);
    pm.Images := fMain.ilActionsSmall;
    PopupMenu := pm;
  end;

  procedure TPhoaToolSettingEditor.DeleteToolClick(Sender: TObject);
  begin
    //
  end;

  procedure TPhoaToolSettingEditor.DoChecked(Node: PVirtualNode);
  var p: TPoint;
  begin
    with GetDisplayRect(Node, -1, False) do p := ClientToScreen(Point(Left, Bottom));
    PopupMenu.Popup(p.x, p.y);
  end;

  procedure TPhoaToolSettingEditor.DoGetText(Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    s: String;
    Setting: TPhoaToolSetting;
  begin
    s := '';
    Setting := GetSetting(Node);
    case Column of
       // �����
      0: s := Setting.Caption;
       // ���
      1: s := GetEnumName(TypeInfo(TPhoaToolKind), Byte(Setting.Kind));
       // �����
      2: s := Setting.Masks;
       // ����������
      3: if Setting.Kind=ptkCustom then s := Setting.RunCommand;
    end;
    CellText := AnsiToUnicodeCP(s, cMainCodePage);
  end;

  procedure TPhoaToolSettingEditor.DoInitNode(ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
     // ��������� ����� � Node.Data
    PPhoaSetting(PChar(Node)+FDataOffset)^ := FRootSetting[Node.Index];
     // ����������� CheckType � CheckState - ������
    Node.CheckType := ctButton;
  end;

  procedure TPhoaToolSettingEditor.DoSettingChange;
  begin
    if Assigned(FOnSettingChange) then FOnSettingChange(Self);
  end;

  procedure TPhoaToolSettingEditor.EditToolClick(Sender: TObject);
  begin
    //
  end;

  function TPhoaToolSettingEditor.GetRootSetting: TPhoaPageSetting;
  begin
    Result := FRootSetting;
  end;

  function TPhoaToolSettingEditor.GetSetting(Node: PVirtualNode): TPhoaToolSetting;
  begin
    if Node=nil then Result := nil else Result := PPhoaToolSetting(PChar(Node)+FDataOffset)^;
  end;

  procedure TPhoaToolSettingEditor.InitAndEmbed(ParentCtl: TWinControl; AOnSettingChange: TNotifyEvent; AOnDecodeText: TPhoaSettingDecodeTextEvent);
  begin
    Parent           := ParentCtl;
    FOnSettingChange := AOnSettingChange;
    FOnDecodeText    := AOnDecodeText;
  end;

  procedure TPhoaToolSettingEditor.LoadTree;
  begin
    BeginUpdate;
    try
       // ������� ��� ����
      Clear;
       // ������������� ���������� ������� � �������� ��������
      RootNodeCount := FRootSetting.ChildCount;
       // �������������� ��� ����
      ReinitChildren(nil, True);
       // �������� ������ ����
      ActivateVTVNode(Self, GetFirst);
    finally
      EndUpdate;
    end;
  end;

  procedure TPhoaToolSettingEditor.SetRootSetting(Value: TPhoaPageSetting);
  begin
    if FRootSetting<>Value then begin
      FRootSetting := Value as TPhoaToolPageSetting;
      LoadTree;
    end;
  end;

  procedure TPhoaToolSettingEditor.SetupHeader;
  begin
    with Header do begin
      with Columns.Add do begin
        Width := 200;
        Text  := 'Name'{!!!};
      end;
      with Columns.Add do begin
        Width := 100;
        Text  := 'Kind'{!!!};
      end;
      with Columns.Add do begin
        Width := 100;
        Text  := 'Masks'{!!!};
      end;
      Columns.Add.Text := 'Application'{!!!};
      AutoSizeIndex := 3;
      Options       := Options+[hoAutoResize, hoVisible];
    end;
  end;

end.
