;***********************************************************************************************************************
;   $Id: phoa.iss,v 1.15 2004-12-10 13:45:13 dale Exp $
;-----------------------------------------------------------------------------------------------------------------------
;   PhoA image arranging and searching tool
;   Copyright 2002-2004 DK Software, http://www.dk-soft.org/
;***********************************************************************************************************************
[Setup]
  MinVersion             = 4.0,4.0sp6
  AppName                = PhoA
  AppVersion             = 1.1.8 beta
  AppVerName             = PhoA v1.1.8 beta
  AppCopyright           = Copyright �2002-2004 DK Software
  AppPublisher           = DK Software
  AppPublisherURL        = http://www.dk-soft.org/
  AppSupportURL          = http://www.dk-soft.org/forum/
  AppUpdatesURL          = http://www.dk-soft.org/redir.php?action=vercheck&product=phoa&version=117beta
  AppMutex               = PHOA_RUNNING_MUTEX
  AllowNoIcons           = yes
  ChangesAssociations    = yes
  DisableStartupPrompt   = yes
  DefaultDirName         = {pf}\DK Software\PhoA
  DefaultGroupName       = PhoA (Photo Album)
  OutputDir              = .
  OutputBaseFilename     = phoa-setup-1.1.8beta
  VersionInfoVersion     = 1.1.8
  VersionInfoTextVersion = 1.1.8 beta
  WizardImageFile        = SetupImage.bmp
  WizardSmallImageFile   = SetupSmallImage.bmp
  ; -- Compression
  SolidCompression       = yes
  Compression            = lzma

[Languages]
  Name: "en"; MessagesFile: compiler:Default.isl;             LicenseFile: eula-eng.rtf; InfoBeforeFile: ReleaseNotes\ReleaseNotes-1.1.7-beta.en.rtf
  Name: "ru"; MessagesFile: compiler:Languages\Russian.isl;   LicenseFile: eula-rus.rtf; InfoBeforeFile: ReleaseNotes\ReleaseNotes-1.1.7-beta.ru.rtf
  Name: "de"; MessagesFile: compiler:Languages\German.isl;    LicenseFile: eula-eng.rtf; InfoBeforeFile: ReleaseNotes\ReleaseNotes-1.1.7-beta.en.rtf

[Tasks]
  Name: desktopicon;        Description: {cm:CreateDesktopIcon};             GroupDescription: {cm:AdditionalIcons};
  Name: desktopicon\common; Description: {cm:IconsAllUsers};                 GroupDescription: {cm:AdditionalIcons}; Flags: exclusive
  Name: desktopicon\user;   Description: {cm:IconsCurUser};                  GroupDescription: {cm:AdditionalIcons}; Flags: exclusive unchecked
  Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon};         GroupDescription: {cm:AdditionalIcons};
  Name: associate;          Description: {cm:AssocFileExtension,PhoA,.phoa};

[Components]
  Name: main;        Description: {cm:CompMain};        Types: full compact custom; Flags: fixed
  Name: plugins;     Description: {cm:CompPlugins};     Types: full compact
  Name: plugins\ijl; Description: {cm:CompIJL};         Types: full compact
  Name: help;        Description: {cm:CompHelp};        Types: full
  Name: help\en;     Description: {cm:CompHelpEn};      Types: full
  Name: help\ru;     Description: {cm:CompHelpRu};      Types: full
  Name: sample;      Description: {cm:CompSampleAlbum}; Types: full
  Name: api;         Description: {cm:CompPhoaAPI};     Types: full

[Files]
;Application files
  Source: "..\phoa.exe";                DestDir: "{app}";              Components: main
  Source: "..\Plugins\ijl15.dll";       DestDir: "{app}\Plugins";      Components: plugins\ijl
  Source: "..\Language\Russian.lng";    DestDir: "{app}\Language";     Components: main
  Source: "..\phoa-eng.chm";            DestDir: "{app}";              Components: help\en
  Source: "..\phoa-rus.chm";            DestDir: "{app}";              Components: help\ru
;Sample content
  Source: "Sample album\sample.phoa";   DestDir: "{app}\Sample album"; Components: sample
  Source: "Sample album\goldgate.jpg";  DestDir: "{app}\Sample album"; Components: sample
  Source: "Sample album\river.jpg";     DestDir: "{app}\Sample album"; Components: sample
  Source: "Sample album\illusion.png";  DestDir: "{app}\Sample album"; Components: sample
;API file
  Source: "..\phMetadata.pas";          DestDir: "{app}\API";          Components: api
  Source: "..\phPhoa.pas";              DestDir: "{app}\API";          Components: api

[INI]
  Filename: "{app}\phoa.url"; Section: "InternetShortcut"; Key: "URL"; String: "http://www.dk-soft.org/"

[Icons]
  Name: "{group}\PhoA";                       Filename: "{app}\phoa.exe";     Components: main;   Comment: {cm:PhoaDesc}
  Name: "{commondesktop}\PhoA";               Filename: "{app}\phoa.exe";     Components: main;   Comment: {cm:PhoaDesc}; Tasks: desktopicon\common
  Name: "{userdesktop}\PhoA";                 Filename: "{app}\phoa.exe";     Components: main;   Comment: {cm:PhoaDesc}; Tasks: desktopicon\user
  Name: "{code:QuickLaunch|{pf}}\PhoA";       Filename: "{app}\phoa.exe";     Components: main;   Comment: {cm:PhoaDesc}; Tasks: quicklaunchicon
  Name: "{group}\{cm:UninstallProgram,PhoA}"; Filename: "{uninstallexe}";     Components: main;
  Name: "{group}\{cm:ProgramOnTheWeb,PhoA}";  Filename: "{app}\phoa.url";     Components: main;
  Name: "{group}\{cm:SampleAlbum}";           Filename: "{app}\phoa.exe";     Components: sample; Parameters: """{app}\Sample album\sample.phoa"""; IconFilename: "{app}\phoa.exe"; IconIndex: 1
  Name: "{group}\{cm:HelpRu}";                Filename: "{app}\phoa-rus.chm"; Components: help\ru;
  Name: "{group}\{cm:HelpEn}";                Filename: "{app}\phoa-eng.chm"; Components: help\en;

[Registry]
  Root: HKCR; Subkey: ".phoa";                                                                       ValueType: string; ValueData: "phoa.photoalbum";           Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum";                                                             ValueType: string; ValueData: {cm:PhoaFmtName};            Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum\shell\open\command";                                          ValueType: string; ValueData: """{app}\phoa.exe"" ""%1"""; Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum\DefaultIcon";                                                 ValueType: string; ValueData: """{app}\phoa.exe"",1";      Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCU; Subkey: "Software\DKSoftware\PhoA\Preferences"; ValueName: "@ISettingID_Gen_Language"; ValueType: string; ValueData: {cm:LangID};                 Flags: uninsdeletevalue uninsdeletekeyifempty

[Run]
  Filename: "{app}\phoa.exe"; Parameters: {code:PhoaStartupParams|}; Description: {cm:LaunchProgram,PhoA}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
  Type: files;      Name: "{app}\phoa.url"
  Type: dirifempty; Name: "{app}"

[Messages]
BeveledLabel=DK Software

[CustomMessages]
#include "SetupMessages.txt"

[Code]

var
  sPriorVersion: String;
  
const
  sReg_InstalledInfo = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\PhoA_is1';
  sReg_Root          = 'Software\DKSoftware\PhoA';
  sReg_Preferences   = sReg_Root+'\Preferences';

   // ���������� ����� ������ �������������� ��������, ��� '', ���� ������� �� ����������
  function  GetInstalledVersion: String;
  begin
    if not RegQueryStringValue(HKLM, sReg_InstalledInfo, 'DisplayVersion', Result) and
       not RegQueryStringValue(HKCU, sReg_InstalledInfo, 'DisplayVersion', Result) then Result := '';
  end;

   // ���������� ���� � �������� ������ QuickLaunch
  function  QuickLaunch(Default: String): String;
  begin
    Result := ExpandConstant('{userappdata}')+'\Microsoft\Internet Explorer\Quick Launch';
  end;
  
  function  PhoaStartupParams(Default: String): String;
  begin
    if IsComponentSelected('sample') then Result := '"Sample album\sample.phoa"' else Result := '';
  end;
  
   // ���������� �������� Integer-��������� � ������ sValueName; -1, ���� ��� ����� ��� �������� ��������� ����
  function  GetPreferenceValueInt(const sValueName: String): Integer;
  var sVal: String;
  begin
     // �������� �������� �������� � ��������� ��� � Integer
    if RegQueryStringValue(HKCU, sReg_Preferences, sValueName, sVal) then Result := StrToIntDef(sVal, -1) else Result := -1;
  end;
  
   // ������������� �������� Integer-��������� � ������ sValueName
  procedure SetPreferenceValueInt(const sValueName: String; iValue: Integer);
  begin
    RegWriteStringValue(HKCU, sReg_Preferences, sValueName, IntToStr(iValue));
  end;

   // ����������� �������� ������� ���� "�������� �����������" �� ������� PhoA 1.1.6 beta � ������ 1.1.7 beta
  procedure Convert116to117Prop(const sValueName: String);
  var iProp: Integer;
  begin
     // �������� �������� ��������
    iProp := GetPreferenceValueInt(sValueName);
     // � 1.1.7 beta �������� 9..n ����� 12..n+3, �������� ��
    if iProp>=9 then begin
      iProp := iProp+3;
      SetPreferenceValueInt(sValueName, iProp);
    end;
  end;

   // ����������� �������� ������� ���� "����� ������� �����������" �� ������� PhoA 1.1.6 beta � ������ 1.1.7 beta
  procedure Convert116to117Props(const sValueName: String);
  var iProp: Integer;
  begin
     // �������� �������� ��������
    iProp := GetPreferenceValueInt(sValueName);
     // � 1.1.7 beta �������� 9..n ����� 12..n+3, �������� ���� 9..n �� 3 �����
    if iProp>0 then begin
      iProp := (iProp and $01ff) or ((iProp and $fffffe00) shl 3);
      SetPreferenceValueInt(sValueName, iProp);
    end;
  end;

   //== Events =========================================================================================================

  function InitializeSetup(): Boolean;
  begin
    Result := True;
     // ���������� ������ �������������� ��������
    sPriorVersion := GetInstalledVersion;
  end;

  procedure CurStepChanged(CurStep: TSetupStep);
  begin
     // ����� �����������, ���� ���� ����������� ������ 1.1.6 beta, ������������ �������� ����������� PhoA 1.1.6 beta �
     //   �������� ����������� 1.1.7 beta
    if (CurStep=ssPostInstall) and (sPriorVersion='1.1.6 beta') then begin
      Convert116to117Prop('@ISettingID_Browse_ViewerThLBProp');
      Convert116to117Prop('@ISettingID_Browse_ViewerThLTProp');
      Convert116to117Prop('@ISettingID_Browse_ViewerThRBProp');
      Convert116to117Prop('@ISettingID_Browse_ViewerThRTProp');
      Convert116to117Props('@ISettingID_Browse_ViewerTipProps');
      Convert116to117Props('@ISettingID_View_CaptionProps');
      Convert116to117Props('@ISettingID_View_InfoPicProps');
    end;
  end;


