//**********************************************************************************************************************
//  $Id: phKeySetting.pas,v 1.3 2004-09-11 17:52:36 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phKeySetting;

interface
(*
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Registry, IniFiles, VirtualTrees, ConsVars, phSettings, phObj;

type
   //===================================================================================================================
   // TPhoaKeySetting - ���������, �������������� ����� ������ ��������� ������ ��� ������ �������
   //===================================================================================================================

  PPhoaKeySetting = ^TPhoaKeySetting;
  TPhoaKeySetting = class(TPhoaSetting)
  private
     // ��������� ����������� ������
    FModified: Boolean;
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
*)
implementation

end.
