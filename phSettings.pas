//**********************************************************************************************************************
//  $Id: phSettings.pas,v 1.4 2004-04-22 17:54:00 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phSettings;

interface
uses SysUtils, Windows, Classes, Graphics, Controls, Registry, IniFiles, VirtualTrees, TB2Dock, TBX, GR32, ConsVars;

type
   // Exception ��������
  EPhoaSettingError = class(EPhoaError);

   //===================================================================================================================
   // TPhoaSetting - ������� ����� ���������
   //===================================================================================================================

  PPhoaSetting = ^TPhoaSetting;
  TPhoaSetting = class(TObject)
  private
     // ������ �������� �������
    FChildren: TList;
     // Prop storage
    FOwner: TPhoaSetting;
    FName: String;
    FID: Integer;
     // ���������� / �������� ������ �� ������ �������� �������
    procedure AddSetting(Item: TPhoaSetting);
    procedure RemoveSetting(Item: TPhoaSetting);
    procedure DeleteSetting(Index: Integer);
     // ������� ������ �������� �������
    procedure ClearSettings;
     // ���� ����� �� ID ����� ���� � ����� �����. ���� �� ������, ���������� nil
    function  FindID(iID: Integer): TPhoaSetting;
     // Prop handlers
    function  GetChildCount: Integer;
    function  GetChildren(Index: Integer): TPhoaSetting;
    function  GetSettings(iID: Integer): TPhoaSetting;
  protected
     // "�������" �����������, �� ���������������� �������, ����� Owner (������������ � "����������" ������������� � �
     //   Assign)
    constructor CreateNew(AOwner: TPhoaSetting); virtual;
  public
    constructor Create(AOwner: TPhoaSetting; iID: Integer; const sName: String);
    destructor Destroy; override;
     // ��������/���������� � ������� �������� � ID<>0
    procedure RegLoad(RegIniFile: TRegIniFile);
    procedure RegSave(RegIniFile: TRegIniFile);
     // ��������/���������� � Ini-����� �������� � ID<>0
    procedure IniLoad(IniFile: TIniFile);
    procedure IniSave(IniFile: TIniFile);
     // �������� ��� ��������� (������� ��������� �������� �����) � ���� Source
    procedure Assign(Source: TPhoaSetting); virtual;
     // Props
     // -- ���������� �������� �������
    property ChildCount: Integer read GetChildCount;
     // -- �������� ������ �� �������
    property Children[Index: Integer]: TPhoaSetting read GetChildren; default;
     // -- ID ������
    property ID: Integer read FID;
     // -- ������������ ������. ���� ���������� � '@', �� ��� ��� ��������� �� ������� Settings, ���� � '#' - �� �� fMain
    property Name: String read FName;
     // -- �����-�������� ������� ������
    property Owner: TPhoaSetting read FOwner;
     // -- ������ �� ID
    property Settings[iID: Integer]: TPhoaSetting read GetSettings;
  end;

  TPhoaSettingClass = class of TPhoaSetting;

   //===================================================================================================================
   // ����� ��������� ������ ��������, �������������� ����� ��������
   //===================================================================================================================

  TPhoaPageSetting = class(TPhoaSetting)
  private
     // Prop storage
    FHelpContext: THelpContext;
    FImageIndex: Integer;
  protected
    constructor CreateNew(AOwner: TPhoaSetting); override;
    function  GetEditorClass: TWinControlClass; virtual; abstract;
  public
    constructor Create(AOwner: TPhoaSetting; iID, iImageIndex: Integer; const sName: String; AHelpContext: THelpContext);
    procedure Assign(Source: TPhoaSetting); override;
     // Props
     // -- ����� ����������-��������� ���������
    property EditorClass: TWinControlClass read GetEditorClass;
     // -- HelpContext ID ������
    property HelpContext: THelpContext read FHelpContext;
     // -- ImageIndex ������
    property ImageIndex: Integer read FImageIndex;
  end;

   // ������� ������������� ������ ������
  TPhoaSettingDecodeTextEvent = procedure(const sText: String; out sDecoded: String) of object;

   // ��������� ��������� ��������
  IPhoaSettingEditor = interface(IInterface)
    ['{32018724-F48C-4EC4-B86A-81C5C5A1F75E}']
     // �������������� � ���������� ��������
    procedure InitAndEmbed(ParentCtl: TWinControl; AOnChange: TNotifyEvent; AOnDecodeText: TPhoaSettingDecodeTextEvent);
     // Prop handlers
    function  GetRootSetting: TPhoaPageSetting;
    procedure SetRootSetting(Value: TPhoaPageSetting);
     // Props
     // -- �������� ���� ��������� - ��� ��� ���� ������ ��������������� ����������
    property RootSetting: TPhoaPageSetting read GetRootSetting write SetRootSetting;
  end;

   // ��������� ���������������� ��������� � TVirtualStringTree
  procedure ApplyTreeSettings(Tree: TVirtualStringTree);
   // ��������� ���������������� ��������� � �����/������� ������������
  procedure ApplyToolbarSettings(Dock: TTBXDock);

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses TypInfo, phUtils;

const
   // ��������� �� �������
  SSettingsErrMsg_InvalidSettingID   = 'Invalid setting ID (%d)';

   // �������� EPhoaSettingError
  procedure PhoaSettingError(const sMsg: String; const aParams: Array of const);

     function RetAddr: Pointer;
     asm
       mov eax, [ebp+4]
     end;

  begin
    raise EPhoaSettingError.CreateFmt(sMsg, aParams) at RetAddr;
  end;

   //===================================================================================================================
   // TPhoaSetting
   //===================================================================================================================

  procedure TPhoaSetting.AddSetting(Item: TPhoaSetting);
  begin
    if FChildren=nil then FChildren := TList.Create;
    FChildren.Add(Item);
  end;

  procedure TPhoaSetting.Assign(Source: TPhoaSetting);
  var
    i: Integer;
    SrcChild: TPhoaSetting;
  begin
     // ������� �����
    ClearSettings;
     // �������� ���������
    FID   := Source.FID;
    FName := Source.FName;
     // ��������� �� �� ��� �����
    for i := 0 to Source.ChildCount-1 do begin
      SrcChild := Source.Children[i];
       // �������� ����������� ����������� CreateNew ���� �� ������, ��� � � SrcChild
      TPhoaSettingClass(SrcChild.ClassType).CreateNew(Self).Assign(SrcChild);
    end;
  end;

  procedure TPhoaSetting.ClearSettings;
  begin
    if FChildren<>nil then begin
      while FChildren.Count>0 do DeleteSetting(FChildren.Count-1);
      FreeAndNil(FChildren);
    end;
  end;

  constructor TPhoaSetting.Create(AOwner: TPhoaSetting; iID: Integer; const sName: String);
  begin
    CreateNew(AOwner);
    FID   := iID;
    FName := sName;
  end;

  constructor TPhoaSetting.CreateNew(AOwner: TPhoaSetting);
  begin
    inherited Create;
    FOwner := AOwner;
    if FOwner<>nil then FOwner.AddSetting(Self);
  end;

  procedure TPhoaSetting.DeleteSetting(Index: Integer);
  begin
    TPhoaSetting(FChildren[Index]).Free;
  end;

  destructor TPhoaSetting.Destroy;
  begin
     // ������� � ���������� ������ �������� �������
    ClearSettings;
    if FOwner<>nil then FOwner.RemoveSetting(Self);
    inherited Destroy;
  end;

  function TPhoaSetting.FindID(iID: Integer): TPhoaSetting;
  var i: Integer;
  begin
    if iID=FID then begin
      Result := Self;
      Exit;
    end else if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do begin
        Result := GetChildren(i).FindID(iID);
        if Result<>nil then Exit;
      end;
    Result := nil;
  end;

  function TPhoaSetting.GetChildCount: Integer;
  begin
    if FChildren=nil then Result := 0 else Result := FChildren.Count;
  end;

  function TPhoaSetting.GetChildren(Index: Integer): TPhoaSetting;
  begin
    Result := TPhoaSetting(FChildren[Index]);
  end;

  function TPhoaSetting.GetSettings(iID: Integer): TPhoaSetting;
  begin
    Result := FindID(iID);
    if Result=nil then PhoaSettingError(SSettingsErrMsg_InvalidSettingID, [iID]);
  end;

  procedure TPhoaSetting.IniLoad(IniFile: TIniFile);
  var
    s: String;
    i: Integer;
  begin
     // �������� ��� ��������
    if FID<>0 then begin
      s := IniFile.ReadString(SRegPrefs, FName, GetValStr);
      if FDatatype=sdtFont then SetValueStr(s) else FData := StrToIntDef(s, FData);
    end;
     // ��������� �� �� ��� �����
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).IniLoad(IniFile);
  end;

  procedure TPhoaSetting.IniSave(IniFile: TIniFile);
  var i: Integer;
  begin
     // ��������� ��� ��������
    if FID<>0 then IniFile.WriteString(SRegPrefs, FName, GetValStr);
     // ��������� �� �� ��� �����
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).IniSave(IniFile);
  end;

  procedure TPhoaSetting.RegLoad(RegIniFile: TRegIniFile);
  var
    s: String;
    i: Integer;
  begin
     // �������� ��� ��������
    if FID<>0 then begin
      s := RegIniFile.ReadString(SRegPrefs, FName, GetValStr);
      if FDatatype=sdtFont then SetValueStr(s) else FData := StrToIntDef(s, FData);
    end;
     // ��������� �� �� ��� �����
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).RegLoad(RegIniFile);
  end;

  procedure TPhoaSetting.RegSave(RegIniFile: TRegIniFile);
  var i: Integer;
  begin
     // ��������� ��� ��������
    if FID<>0 then RegIniFile.WriteString(SRegPrefs, FName, GetValStr);
     // ��������� �� �� ��� �����
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).RegSave(RegIniFile);
  end;

  procedure TPhoaSetting.RemoveSetting(Item: TPhoaSetting);
  begin
    FChildren.Remove(Item);
  end;

   //===================================================================================================================
   // TPhoaPageSetting 
   //===================================================================================================================

  procedure TPhoaPageSetting.Assign(Source: TPhoaSetting);
  begin
    inherited Assign(Source);
    if Source is TPhoaValPageSetting then begin
      FImageIndex  := TPhoaValPageSetting(Source).FImageIndex;
      FHelpContext := TPhoaValPageSetting(Source).FHelpContext;
    end;
  end;

  constructor TPhoaPageSetting.Create(AOwner: TPhoaSetting; iID, iImageIndex: Integer; const sName: String; AHelpContext: THelpContext);
  begin
    inherited Create(AOwner, iID, sName);
    FImageIndex  := iImageIndex;
    FHelpContext := AHelpContext;
  end;

  constructor TPhoaPageSetting.CreateNew(AOwner: TPhoaSetting);
  begin
    inherited CreateNew(AOwner);
    FImageIndex := -1;
  end;

end.
