//**********************************************************************************************************************
//  $Id: phFrm.pas,v 1.2 2005-08-15 11:25:11 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Registry;

type
  TPhoaForm = class(TForm)
  private
     // ������� ���������� ����������
    FLockCounter: Integer;
     // Prop storage
    FHasUpdates: Boolean;
    FModified: Boolean;
     // ���� ���������, ������ � ���������� TRegIniFile ��� ����������/�������� ��������; ����� ���������� nil
    function  CreateRegIni: TRegIniFile;
     // Message handlers
    procedure WMHelp(var Msg: TWMHelp); message WM_HELP;
     // Prop handlers
    function  GetRegistryKey: String;
    procedure SetHasUpdates(Value: Boolean);
    procedure SetModified(Value: Boolean);
  protected
    procedure DoCreate; override;
    procedure DoDestroy; override;
    procedure DoHide; override;
    procedure DoShow; override;
    procedure Loaded; override;
     // �������������/����������� ����� ��/����� ���������� ������
    procedure ExecuteInitialize; virtual;
    procedure ExecuteFinalize; virtual;
     // ���������� ��� ��������� ������� �����
    procedure UpdateState; virtual;
     // ��������� ������/������ ��������� �������� �� �������. ����� �������������� ��������� ��� ���������� �
     //   �������������� ����������� ��������
    procedure SettingsInitialSave(rif: TRegIniFile); virtual;
    procedure SettingsInitialLoad(rif: TRegIniFile); virtual;
     // ��������� ������/������ �������� �� �������, ���������� ��������������� ����� ������� � ����� �������
    procedure SettingsSave(rif: TRegIniFile); virtual;
    procedure SettingsLoad(rif: TRegIniFile); virtual;
     // Prop handlers
    function  GetDataValid: Boolean; virtual;
    function  GetRelativeRegistryKey: String; virtual;
    function  GetSizeable: Boolean; virtual;
  public
     // �������� ���������� �����. ���������� HasUpdates
    function  ExecuteModal: Boolean;
     // ���������/������ ���������� ��������� Modified
    procedure BeginUpdate;
    procedure EndUpdate;
     // True, ���� FLockCounter>0
    function  UpdateLocked: Boolean;
     // �������� ���������� ������� ������� (���������� ��� FLockCounter>0)
    procedure StateChanged;
     // Props
     // -- ���� True, ������ � ������� ���������. � ������� ������ ������ ���������� True
    property DataValid: Boolean read GetDataValid;
     // -- True, ���� ����� ��������� �����-�� ���������
    property HasUpdates: Boolean read FHasUpdates write SetHasUpdates;
     // -- True, ���� � ����� ������������ ������� �����-�� ������
    property Modified: Boolean read FModified write SetModified;
     // -- ���� ������� ��� ���������� ��������
    property RegistryKey: String read GetRegistryKey;
     // -- ���� ������� ��� ���������� �������� ������������ ��������� ����� ����������. ���� ������ ������, ����������
     //    �������� �� ���������
    property RelativeRegistryKey: String read GetRelativeRegistryKey;
     // -- True, ���� ������ ����� ����������� ������. � ������� ������ ������ ���������� False
    property Sizeable: Boolean read GetSizeable;
  end;

implementation
{$R *.dfm}
uses phChmHlp, phUtils, phSettings, ConsVars;

  procedure TPhoaForm.BeginUpdate;
  begin
    Inc(FLockCounter);
  end;

  function TPhoaForm.CreateRegIni: TRegIniFile;
  var sKey: String;
  begin
    sKey := RegistryKey;
    if sKey='' then Result := nil else Result := TRegIniFile.Create(sKey);
  end;

  procedure TPhoaForm.DoCreate;
  var rif: TRegIniFile;
  begin
    inherited DoCreate;
     // ���� �����, ������ ����� Sizeable
    if Sizeable then begin
       // ������������ ������� ������� � �������� �����������
      Constraints.MinWidth  := Width;
      Constraints.MinHeight := Height;
    end else begin
      BorderStyle := bsDialog;
      BorderIcons := [biSystemMenu];
      Position    := poScreenCenter;
    end;
     // ����������� �����
    FontFromStr(Font, SettingValueStr(ISettingID_Gen_MainFont));
     // ��������� ��������� ���������, ���� ���������
    rif := CreateRegIni;
    if rif<>nil then
      try
        SettingsInitialLoad(rif);
      finally
        rif.Free;
      end;
  end;

  procedure TPhoaForm.DoDestroy;
  var rif: TRegIniFile;
  begin
     // ��������� ��������� ���������, ���� ���������
    rif := CreateRegIni;
    if rif<>nil then
      try
        SettingsInitialSave(rif);
      finally
        rif.Free;
      end;
    inherited DoDestroy;
  end;

  procedure TPhoaForm.DoHide;
  var rif: TRegIniFile;
  begin
     // ��������� ���������, ���� ���������
    rif := CreateRegIni;
    if rif<>nil then
      try
        SettingsSave(rif);
      finally
        rif.Free;
      end;
    inherited DoHide;
  end;

  procedure TPhoaForm.DoShow;
  var rif: TRegIniFile;
  begin
    inherited DoShow;
     // ��������� ���������, ���� ���������
    rif := CreateRegIni;
    if rif<>nil then
      try
        SettingsLoad(rif);
      finally
        rif.Free;
      end;
     // ���������� ���� ����������� 
    Modified := False;
  end;

  procedure TPhoaForm.EndUpdate;
  begin
    if FLockCounter>0 then Dec(FLockCounter);
    if FLockCounter=0 then UpdateState;
  end;

  procedure TPhoaForm.ExecuteFinalize;
  begin
    { does nothing }
  end;

  procedure TPhoaForm.ExecuteInitialize;
  begin
    { does nothing }
  end;

  function TPhoaForm.ExecuteModal: Boolean;
  begin
     // �������������� �����
    BeginUpdate;
    try
      ExecuteInitialize;
    finally
      EndUpdate;
    end;
     // ����� ������
    try
      ShowModal;
    finally
       // ������������ �����
      ExecuteFinalize;
    end;
    Result := HasUpdates;
  end;

  function TPhoaForm.GetDataValid: Boolean;
  begin
    Result := True;
  end;

  function TPhoaForm.GetRegistryKey: String;
  var sRelativeKey: String;
  begin
    sRelativeKey := RelativeRegistryKey;
    if sRelativeKey='' then Result := '' else Result := SRegRoot+'\'+sRelativeKey;
  end;

  function TPhoaForm.GetRelativeRegistryKey: String;
  begin
    Result := '';
  end;

  function TPhoaForm.GetSizeable: Boolean;
  begin
    Result := False;
  end;

  procedure TPhoaForm.Loaded;
  begin
    inherited Loaded;
{???}    AutoScroll := False;
  end;

  procedure TPhoaForm.SetHasUpdates(Value: Boolean);
  begin
    FHasUpdates := Value;
    StateChanged;
  end;

  procedure TPhoaForm.SetModified(Value: Boolean);
  begin
    FModified := Value;
    StateChanged;
  end;

  procedure TPhoaForm.SettingsInitialLoad(rif: TRegIniFile);
  begin
    { does nothing }
  end;

  procedure TPhoaForm.SettingsInitialSave(rif: TRegIniFile);
  begin
    { does nothing }
  end;

  procedure TPhoaForm.SettingsLoad(rif: TRegIniFile);
  begin
     // ���� ������ ����� ����� ������, ��������������� ������� �����
    if Sizeable then FormPositionFromStr(Self, rif.ReadString('', 'Position', ''));
  end;

  procedure TPhoaForm.SettingsSave(rif: TRegIniFile);
  begin
     // ���� ������ ����� ����� ������, ��������� � �������
    if Sizeable then rif.WriteString('', 'Position', FormPositionToStr(Self));
  end;

  procedure TPhoaForm.StateChanged;
  begin
    if FLockCounter=0 then UpdateState;
  end;

  function TPhoaForm.UpdateLocked: Boolean;
  begin
    Result := FLockCounter>0;
  end;

  procedure TPhoaForm.UpdateState;
  begin
    { does nothing }
  end;

  procedure TPhoaForm.WMHelp(var Msg: TWMHelp);
  begin
    HtmlHelpContext(HelpContext);
  end;

end.
