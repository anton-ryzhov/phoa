//**********************************************************************************************************************
//  $Id: phSettings.pas,v 1.7 2004-04-24 18:48:31 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phSettings;

interface
uses SysUtils, Windows, Classes, Graphics, Controls, Registry, IniFiles, ConsVars;

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
    function  GetIndex: Integer;
    procedure SetIndex(Value: Integer);
  protected
     // "�������" �����������, �� ���������������� �������, ����� Owner (������������ � "����������" ������������� � �
     //   Assign)
    constructor CreateNew(AOwner: TPhoaSetting); virtual;
  public
    constructor Create(AOwner: TPhoaSetting; iID: Integer; const sName: String);
    destructor Destroy; override;
     // ��������/���������� � ������� �������� � ID<>0. � ������� ������ �� ������ ������, ����� ��������� �������
     //   ������� �������� ��������
    procedure RegLoad(RegIniFile: TRegIniFile); virtual;
    procedure RegSave(RegIniFile: TRegIniFile); virtual;
     // ��������/���������� � Ini-����� �������� � ID<>0. � ������� ������ �� ������ ������, ����� ��������� �������
     //   ������� �������� ��������
    procedure IniLoad(IniFile: TIniFile); virtual;
    procedure IniSave(IniFile: TIniFile); virtual;
     // �������� ��� ��������� (������� ��������� �������� �����) � ���� Source
    procedure Assign(Source: TPhoaSetting); virtual;
     // Props
     // -- ���������� �������� �������
    property ChildCount: Integer read GetChildCount;
     // -- �������� ������ �� �������
    property Children[Index: Integer]: TPhoaSetting read GetChildren; default;
     // -- ID ������
    property ID: Integer read FID;
     // -- ������ ��������� ������ ��������
    property Index: Integer read GetIndex write SetIndex;
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

var
   // �������� ����� ���������
  RootSetting: TPhoaSetting;

   // �������/��������� ��� ������� � ��������� ��������
  function  SettingValueInt (iID: Integer): Integer;
  function  SettingValueBool(iID: Integer): Boolean;
  function  SettingValueStr (iID: Integer): String;
  procedure SetSettingValueInt (iID, iValue: Integer);
  procedure SetSettingValueBool(iID: Integer; bValue: Boolean);
  procedure SetSettingValueStr (iID: Integer; const sValue: String);

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses TypInfo, phUtils, phValSetting;

const
   // ��������� �� �������
  SSettingsErrMsg_InvalidSettingID   = 'Invalid setting ID (%d)';
  SSettingsErrMsg_InvalidSettingType = 'Cannot access setting (ID=%d) as type %s';

   // �������� EPhoaSettingError
  procedure PhoaSettingError(const sMsg: String; const aParams: Array of const);

     function RetAddr: Pointer;
     asm
       mov eax, [ebp+4]
     end;

  begin
    raise EPhoaSettingError.CreateFmt(sMsg, aParams) at RetAddr;
  end;

  function SettingValueInt(iID: Integer): Integer;
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaIntSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['Integer']);
    Result := TPhoaIntSetting(Setting).Value;
  end;

  function SettingValueBool(iID: Integer): Boolean;
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaBoolSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['Bool']);
    Result := TPhoaBoolSetting(Setting).Value;
  end;

  function SettingValueStr(iID: Integer): String;
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaStrSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['String']);
    Result := TPhoaStrSetting(Setting).Value;
  end;

  procedure SetSettingValueInt(iID, iValue: Integer);
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaIntSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['Integer']);
    TPhoaIntSetting(Setting).Value := iValue;
  end;

  procedure SetSettingValueBool(iID: Integer; bValue: Boolean);
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaBoolSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['Bool']);
    TPhoaBoolSetting(Setting).Value := bValue;
  end;

  procedure SetSettingValueStr(iID: Integer; const sValue: String);
  var Setting: TPhoaSetting;
  begin
    Setting := RootSetting.Settings[iID];
    if not (Setting is TPhoaStrSetting) then PhoaSettingError(SSettingsErrMsg_InvalidSettingType, ['String']);
    TPhoaStrSetting(Setting).Value := sValue;
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

  function TPhoaSetting.GetIndex: Integer;
  begin
    if FOwner=nil then Result := 0 else Result := FOwner.FChildren.IndexOf(Self);
  end;

  function TPhoaSetting.GetSettings(iID: Integer): TPhoaSetting;
  begin
    Result := FindID(iID);
    if Result=nil then PhoaSettingError(SSettingsErrMsg_InvalidSettingID, [iID]);
  end;

  procedure TPhoaSetting.IniLoad(IniFile: TIniFile);
  var i: Integer;
  begin
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).IniLoad(IniFile);
  end;

  procedure TPhoaSetting.IniSave(IniFile: TIniFile);
  var i: Integer;
  begin
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).IniSave(IniFile);
  end;

  procedure TPhoaSetting.RegLoad(RegIniFile: TRegIniFile);
  var i: Integer;
  begin
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).RegLoad(RegIniFile);
  end;

  procedure TPhoaSetting.RegSave(RegIniFile: TRegIniFile);
  var i: Integer;
  begin
    if FChildren<>nil then
      for i := 0 to FChildren.Count-1 do GetChildren(i).RegSave(RegIniFile);
  end;

  procedure TPhoaSetting.RemoveSetting(Item: TPhoaSetting);
  begin
    FChildren.Remove(Item);
  end;

  procedure TPhoaSetting.SetIndex(Value: Integer);
  begin
    if FOwner<>nil then FOwner.FChildren.Move(GetIndex, Value);
  end;

   //===================================================================================================================
   // TPhoaPageSetting
   //===================================================================================================================

  procedure TPhoaPageSetting.Assign(Source: TPhoaSetting);
  begin
    inherited Assign(Source);
    if Source is TPhoaPageSetting then begin
      FImageIndex  := TPhoaPageSetting(Source).FImageIndex;
      FHelpContext := TPhoaPageSetting(Source).FHelpContext;
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
