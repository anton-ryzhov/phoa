;***********************************************************************************************************************
;   $Id: phoa.iss,v 1.3 2004-04-17 21:02:23 dale Exp $
;-----------------------------------------------------------------------------------------------------------------------
;   PhoA image arranging and searching tool
;   Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
;***********************************************************************************************************************
[Setup]
  MinVersion           = 4.0,4.0
  AppName              = PhoA
  AppVersion           = 1.1.4 beta
  AppVerName           = PhoA v1.1.4 beta
  AppCopyright         = Copyright �2002-2004 Dmitry Kann
  AppPublisher         = DaleTech
  AppPublisherURL      = http://phoa.narod.ru/
  AppSupportURL        = mailto:phoa@narod.ru
  AppUpdatesURL        = http://phoa.narod.ru/
  AppMutex             = PHOA_RUNNING_MUTEX
  AllowNoIcons         = yes
  ChangesAssociations  = yes
  DisableStartupPrompt = yes
  DefaultDirName       = {pf}\DaleTech\PhoA
  DefaultGroupName     = PhoA (Photo Album)
  OutputDir            = .
  OutputBaseFilename   = phoa-setup-1.1.4beta
  VersionInfoVersion   = 1.1.4
  WizardImageFile      = Setup-Image.bmp
  WizardSmallImageFile = Setup-Small-Image.bmp
  ; -- Compression
  SolidCompression     = yes
  Compression          = lzma

[Languages]
  Name: "en"; MessagesFile: compiler:Default.isl;             LicenseFile: eula-eng.rtf
  Name: "ru"; MessagesFile: compiler:Russian.isl;             LicenseFile: eula-rus.rtf
  Name: "de"; MessagesFile: compiler:Languages\German.isl;    LicenseFile: eula-deu.rtf
  Name: "br"; MessagesFile: compiler:BrazilianPortuguese.isl; LicenseFile: eula-brp.rtf
  Name: "ua"; MessagesFile: compiler:Ukrainian.isl;           LicenseFile: eula-ukr.rtf
  
[Tasks]
  Name: desktopicon;        Description: {cm:CreateDesktopIcon};             GroupDescription: {cm:AdditionalIcons};
  Name: desktopicon\common; Description: {cm:IconsAllUsers};                 GroupDescription: {cm:AdditionalIcons}; Flags: exclusive
  Name: desktopicon\user;   Description: {cm:IconsCurUser};                  GroupDescription: {cm:AdditionalIcons}; Flags: exclusive unchecked
  Name: quicklaunchicon;    Description: {cm:CreateQuickLaunchIcon};         GroupDescription: {cm:AdditionalIcons};
  Name: associate;          Description: {cm:AssocFileExtension,PhoA,.phoa};

[Components]
  Name: main;    Description: {cm:CompMain};        Types: full compact custom; Flags: fixed
  Name: help;    Description: {cm:CompHelp};        Types: full
  Name: help\en; Description: {cm:CompHelpEn};      Types: full
  Name: help\ru; Description: {cm:CompHelpRu};      Types: full
  Name: sample;  Description: {cm:CompSampleAlbum}; Types: full
  Name: api;     Description: {cm:CompPhoaAPI};     Types: full

[Files]
;Application files
  Source: "..\phoa.exe";                DestDir: "{app}";              Components: main
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
  Filename: "{app}\phoa.url"; Languages: en de br; Section: "InternetShortcut"; Key: "URL"; String: "http://phoa.narod.ru/en/"
  Filename: "{app}\phoa.url"; Languages: ru ua;    Section: "InternetShortcut"; Key: "URL"; String: "http://phoa.narod.ru/"

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
  Root: HKCR; Subkey: ".phoa";                                                                     ValueType: string; ValueData: "phoa.photoalbum";           Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum";                                                           ValueType: string; ValueData: {cm:PhoaFmtName};            Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum\shell\open\command";                                        ValueType: string; ValueData: """{app}\phoa.exe"" ""%1"""; Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCR; Subkey: "phoa.photoalbum\DefaultIcon";                                               ValueType: string; ValueData: """{app}\phoa.exe"",1";      Flags: uninsdeletevalue uninsdeletekeyifempty; Tasks: associate
  Root: HKCU; Subkey: "Software\DaleTech\PhoA\Preferences"; ValueName: "@ISettingID_Gen_Language"; ValueType: string; ValueData: {cm:LangID};                 Flags: uninsdeletevalue uninsdeletekeyifempty

[Run]
  Filename: "{app}\phoa.exe"; Parameters: {code:PhoaStartupParams|}; Description: {cm:LaunchProgram,PhoA}; Flags: nowait postinstall skipifsilent

[UninstallDelete]
  Type: files;      Name: "{app}\phoa.url"
  Type: dirifempty; Name: "{app}"

[Messages]
BeveledLabel=http://phoa.narod.ru

[CustomMessages]
en.CompMain=Main Files
en.CompHelp=Help Files
en.CompHelpEn=English
en.CompHelpRu=Russian
en.CompSampleAlbum=Sample photo album
en.CompPhoaAPI=PhoA API (for developers)

ru.CompMain=�������� �����
ru.CompHelp=����� ���������� �������
ru.CompHelpEn=���������� ����
ru.CompHelpRu=������� ����
ru.CompSampleAlbum=������ �����������
ru.CompPhoaAPI=PhoA API (��� �������������)

de.CompMain=Programmdateien
de.CompHelp=Hilfedateien
de.CompHelpEn=Englisch
de.CompHelpRu=Russisch
de.CompSampleAlbum=Beispiel Fotoalbum
de.CompPhoaAPI=PhoA API (for developers)

br.CompMain=Arquivos principais
br.CompHelp=Arquivos de ajuda
br.CompHelpEn=Ingl�s
br.CompHelpRu=Russo
br.CompSampleAlbum=�lbum exemplo
br.CompPhoaAPI=PhoA API (for developers)

ua.CompMain=������ �����
ua.CompHelp=�����  �������� �������
ua.CompHelpEn=�������� ����
ua.CompHelpRu=������� ����
ua.CompSampleAlbum=������� �����������
ua.CompPhoaAPI=PhoA API (��� ����������)

en.IconsAllUsers=For all users
ru.IconsAllUsers=��� ���� �������������
de.IconsAllUsers=F�r alle Benutzer
br.IconsAllUsers=Para todos os usu�rios
ua.IconsAllUsers=��� ��� ������������

en.IconsCurUser=For the current user only
ru.IconsCurUser=������ ��� �������� ������������
de.IconsCurUser=Nur f�r den aktuellen Benutzer
br.IconsCurUser=Somente para usu�rio atual
ua.IconsCurUser=ҳ���� ��� ��������� �����������

en.PhoaDesc=Picture arranging program
ru.PhoaDesc=��������� ��� ������������� ����������� � ����������� ������������
de.PhoaDesc=Bildverwaltungsprogramm
br.PhoaDesc=Programa para organiza��o de imagens
ua.PhoaDesc=�������� ��� ������������ ��������� � ��������� �����������
  
en.SampleAlbum=Sample photo album
ru.SampleAlbum=������ �����������
de.SampleAlbum=Beispiel Fotoalbum
br.SampleAlbum=�lbum exemplo
ua.SampleAlbum=������� �����������

en.HelpRu=PhoA help (Russian)
ru.HelpRu=������� �� PhoA (�������)
de.HelpRu=PhoA Hilfe (Russich)
br.HelpRu=Ajuda PhoA (Russo)
ua.HelpRu=������ �� PhoA (�������)

en.HelpEn=PhoA help (English)
ru.HelpEn=������� �� PhoA (English)
de.HelpEn=PhoA Hilfe (Englisch)
br.HelpEn=PhoA help (English)
ua.HelpEn=������ �� PhoA (English)

en.PhoaFmtName=PhoA Photo Album
ru.PhoaFmtName=���������� PhoA
de.PhoaFmtName=PhoA Fotoalbum
br.PhoaFmtName=PhoA �lbum
ua.PhoaFmtName=���������� PhoA

en.LangID=1033
ru.LangID=1049
de.LangID=1031
br.LangID=1046
ua.LangID=1058

[Code]

  function QuickLaunch(Default: String): String;
  begin
    Result := ExpandConstant('{userappdata}')+'\Microsoft\Internet Explorer\Quick Launch';
  end;
  
  function PhoaStartupParams(Default: String): String;
  begin
    if ShouldProcessEntry('sample', '')=srYes then Result := '"Sample album\sample.phoa"' else Result := '';
  end;

