//**********************************************************************************************************************
//  $Id: udFileOpsWizard.pas,v 1.29 2005-02-12 15:36:37 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udFileOpsWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Registry,
  GraphicEx, GR32,
  phWizard, phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phGraphics,
  Placemnt, StdCtrls, ExtCtrls, phWizForm, DKLang;

type
   // Exception
  EFileOpError = class(Exception);

  TFileOpThread = class;

   // ������ ����� � ������ �� ���������� �����������
  PFileLink = ^TFileLink; 
  TFileLink = class(TObject)
  private
     // Prop storage
    FFileName: String;
    FFilePath: String;
    FFileSize: Integer;
    FPics: IPhoaMutablePicList;
    FFileTime: TDateTime;
  public
    constructor Create(const sFileName, sFilePath: String; iFileSize: Integer; const dFileTime: TDateTime);
     // Props
     // -- ��� �����
    property FileName: String read FFileName;
     // -- ���� � �����
    property FilePath: String read FFilePath;
     // -- ������ �����
    property FileSize: Integer read FFileSize;
     // -- ����/����� ����������� �����
    property FileTime: TDateTime read FFileTime;
     // -- ������ ������ �� �����������, ��� ������� ���� �������� ���������� ��������� ������
    property Pics: IPhoaMutablePicList read FPics; 
  end;

   // ������ �������� TFileLink
  TFileLinks = class(TList)
  private
    function GetItems(Index: Integer): TFileLink;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
     // ��������� ����� ������ ����� � ���������� ������ �� ����
    function Add(const sFileName, sFilePath: String; iFileSize: Integer; const dFileTime: TDateTime): TFileLink;
     // Props
     // -- ����� �� �������
    property Items[Index: Integer]: TFileLink read GetItems; default;
  end;

   // ����� ������� �������� ��������
  TdFileOpsWizard = class(TPhoaWizardForm, IPhoaWizardPageHost_Log, IPhoaWizardPageHost_Process)
    dklcMain: TDKLanguageController;
  private
     // ������� ����� (����������� ��������)
    FFileOpThread: TFileOpThread;
     // �������� ��������
    FLog: TStrings;
     // ���� ����, ��� ������������ ���������
    FProcessing: Boolean;
     // ���� ���������� ���������
    FProcessingInterrupted: Boolean;
     // ����������� ���������� �����������
    FInitialPicCount: Integer;
     // ������� ������� ������������ ������/�����������
    FCountSucceeded: Integer;
     // ������� ������
    FCountErrors: Integer;
     // True, ���� � ������ ������ ������� ����� ��� � ���� �������
    FSelPicsByDefault: Boolean;
     // Prop storage
    FApp: IPhotoAlbumApp;
    FCDOpt_CopyExecutable: Boolean;
    FCDOpt_CopyIniSettings: Boolean;
    FCDOpt_CreateAutorun: Boolean;
    FCDOpt_CreatePhoa: Boolean;
    FCDOpt_IncludeViews: Boolean;
    FCDOpt_MediaLabel: String;
    FCDOpt_PhoaDesc: String;
    FCDOpt_PhoaFileName: String;
    FDelFile_DeleteToRecycleBin: Boolean;
    FDestinationFolder: String;
    FExportedProject: IPhotoAlbumProject;
    FFileOpKind: TFileOperationKind;
    FMoveFile_AllowDuplicating: Boolean;
    FMoveFile_Arranging: TFileOpMoveFileArranging;
    FMoveFile_BaseGroup: IPhotoAlbumPicGroup;
    FMoveFile_BasePath: String;
    FMoveFile_DeleteOriginal: Boolean;
    FMoveFile_DeleteToRecycleBin: Boolean;
    FMoveFile_FileNameFormat: String;
    FMoveFile_NoOriginalMode: TFileOpMoveFileNoOriginalMode;
    FMoveFile_OverwriteMode: TFileOpMoveFileOverwriteMode;
    FMoveFile_RenameFiles: Boolean;
    FMoveFile_ReplaceChar: Char;
    FMoveFile_UseCDOptions: Boolean;
    FProjectChanged: Boolean;
    FRepair_DeleteUnmatchedPics: Boolean;
    FRepair_FileLinks: TFileLinks;
    FRepair_LookSubfolders: Boolean;
    FRepair_MatchFlags: TFileOpRepairMatchFlags;
    FRepair_RelinkFilesInUse: Boolean;
    FSelectedGroups: IPhotoAlbumPicGroupList;
    FSelectedPics: IPhotoAlbumPicList;
    FSelPicMode: TFileOpSelPicMode;
    FSelPicValidityFilter: TFileOpSelPicValidityFilter;
     // �������� ����������� ��� �������� � FSelectedPics - �� ��������� ���������� ������ � ��������� �����
    procedure DoSelectPictures;
     // �������� ��������� ��������
    procedure StartProcessing;
     // ��������� ��������� ��������
    procedure InterruptProcessing;
     // ������ �������������� ����������
    procedure CreateExportedPhoa;
     // ����������� ��������� ��������� (���������� ������ ����� ��������� ���� �����������)
    procedure FinalizeProcessing;
     // ��������� ���������� � ��������� ��������
    procedure UpdateProgressInfo;
     // ���������� �������, �������������� �����������, ��� ����������� � ���, ��� ����������� ����������
    procedure ThreadPicProcessed;
     // ���������� ������ � ��������
    procedure LogSuccess(const s: String; const aParams: Array of const);
    procedure LogFailure(const s: String; const aParams: Array of const);
     // ���������� ������ ������-���������� ��� �������������� ������
    procedure Repair_SelectFiles;
     // IPhoaWizardPageHost_Log
    function  LogPage_GetLog(iPageID: Integer): TStrings;
    function  IPhoaWizardPageHost_Log.GetLog = LogPage_GetLog;
     // IPhoaWizardPageHost_Process
    procedure ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
    function  ProcPage_GetCurrentStatus: String;
    function  ProcPage_GetProcessingActive: Boolean;
    function  ProcPage_GetProgressCur: Integer;
    function  ProcPage_GetProgressMax: Integer;
    procedure IPhoaWizardPageHost_Process.StartProcessing     = StartProcessing;
    procedure IPhoaWizardPageHost_Process.StopProcessing      = InterruptProcessing;
    procedure IPhoaWizardPageHost_Process.PaintThumbnail      = ProcPage_PaintThumbnail;
    function  IPhoaWizardPageHost_Process.GetCurrentStatus    = ProcPage_GetCurrentStatus;
    function  IPhoaWizardPageHost_Process.GetProcessingActive = ProcPage_GetProcessingActive;
    function  IPhoaWizardPageHost_Process.GetProgressCur      = ProcPage_GetProgressCur;
    function  IPhoaWizardPageHost_Process.GetProgressMax      = ProcPage_GetProgressMax;
  protected
    procedure InitializeWizard; override;
    procedure FinalizeWizard; override;
    function  IsBtnBackEnabled: Boolean; override;
    function  IsBtnNextEnabled: Boolean; override;
    function  IsBtnCancelEnabled: Boolean; override;
    function  GetNextPageID: Integer; override;
    function  GetFormRegistrySection: String; override;
    procedure SettingsStore(rif: TRegIniFile); override;
    procedure SettingsRestore(rif: TRegIniFile); override;
    function  PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean; override;
    procedure PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer); override;
  public
     // Props
     // -- ����������
    property App: IPhotoAlbumApp read FApp;
     // -- �������� CD/DVD: True, ���� ����� ��������� ���������� �� ���������� �����������
    property CDOpt_CreatePhoa: Boolean read FCDOpt_CreatePhoa write FCDOpt_CreatePhoa;
     // -- �������� CD/DVD: ������������� ��� ����� �����������
    property CDOpt_PhoaFileName: String read FCDOpt_PhoaFileName write FCDOpt_PhoaFileName;
     // -- �������� CD/DVD: �������� �����������
    property CDOpt_PhoaDesc: String read FCDOpt_PhoaDesc write FCDOpt_PhoaDesc;
     // -- �������� CD/DVD: True, ���� ����� �������� ��������� ������������� � ����������� ����������
    property CDOpt_IncludeViews: Boolean read FCDOpt_IncludeViews write FCDOpt_IncludeViews;
     // -- �������� CD/DVD: True, ���� ����� ����� ����������� ����������� ����
    property CDOpt_CopyExecutable: Boolean read FCDOpt_CopyExecutable write FCDOpt_CopyExecutable;
     // -- �������� CD/DVD: True, ���� ����� ��������� ������� ��������� � phoa.ini
    property CDOpt_CopyIniSettings: Boolean read FCDOpt_CopyIniSettings write FCDOpt_CopyIniSettings;
     // -- �������� CD/DVD: True, ���� ����� ������� ���� autorun.inf
    property CDOpt_CreateAutorun: Boolean read FCDOpt_CreateAutorun write FCDOpt_CreateAutorun;
     // -- �������� CD/DVD: ����� �������� ��� autorun.inf
    property CDOpt_MediaLabel: String read FCDOpt_MediaLabel write FCDOpt_MediaLabel;
     // -- ��������: ���� True, ������� ����� � �������, ����� - ������� ������
    property DelFile_DeleteToRecycleBin: Boolean read FDelFile_DeleteToRecycleBin write FDelFile_DeleteToRecycleBin;
     // -- ����� ����������, � ������� ������������ ��������
    property DestinationFolder: String read FDestinationFolder write FDestinationFolder;
     // -- ������, ��������������� ��� �������� � �������� �����������/����������� ������
    property ExportedProject: IPhotoAlbumProject read FExportedProject;
     // -- ��������� �������� � ������� �����������
    property FileOpKind: TFileOperationKind read FFileOpKind write FFileOpKind;
     // -- �����������/�����������: ����� ���������� ������
    property MoveFile_Arranging: TFileOpMoveFileArranging read FMoveFile_Arranging write FMoveFile_Arranging;
     // -- �����������/�����������: ����, ������������ �������� ��������� ����� � ������� (���
     //    MoveFileArranging=fomfaMaintainFolderLayout)
    property MoveFile_BasePath: String read FMoveFile_BasePath write FMoveFile_BasePath;
     // -- �����������/�����������: ������, ������������ ������� ��������� ����� � ������� (���
     //    MoveFileArranging=fomfaMaintainGroupLayout)
    property MoveFile_BaseGroup: IPhotoAlbumPicGroup read FMoveFile_BaseGroup write FMoveFile_BaseGroup;
     // -- �����������/�����������: ���� True, ������ ��������� ������, ������� �� � �����, ��������������� ������� (���
     //    MoveFileArranging=fomfaMaintainGroupLayout)
    property MoveFile_AllowDuplicating: Boolean read FMoveFile_AllowDuplicating write FMoveFile_AllowDuplicating;
     // -- �����������/�����������: ���� True, ��������������� �����, ��������� �������� MoveFile_FileNameFormat
    property MoveFile_RenameFiles: Boolean read FMoveFile_RenameFiles write FMoveFile_RenameFiles;
     // -- �����������/�����������: ������ ����� �����, ������������ ��� ���������������� ������ ���
     //    MoveFile_RenameFiles=True
    property MoveFile_FileNameFormat: String read FMoveFile_FileNameFormat write FMoveFile_FileNameFormat;
     // -- �����������/�����������: ��������� ��� ���������� ��������� ����� ��� �����������
    property MoveFile_NoOriginalMode: TFileOpMoveFileNoOriginalMode read FMoveFile_NoOriginalMode write FMoveFile_NoOriginalMode;
     // -- �����������/�����������: ����� ���������� ������������ ������
    property MoveFile_OverwriteMode: TFileOpMoveFileOverwriteMode read FMoveFile_OverwriteMode write FMoveFile_OverwriteMode;
     // -- �����������/�����������: ������, �� ������� �������� ������������ ��� ����/����� ������ �������
    property MoveFile_ReplaceChar: Char read FMoveFile_ReplaceChar write FMoveFile_ReplaceChar;
     // -- �����������/�����������: ���� True, ������� ������������ ����
    property MoveFile_DeleteOriginal: Boolean read FMoveFile_DeleteOriginal write FMoveFile_DeleteOriginal;
     // -- �����������/�����������: ���� True, ������� ������������ ���� � �������, ����� - ������� ������
    property MoveFile_DeleteToRecycleBin: Boolean read FMoveFile_DeleteToRecycleBin write FMoveFile_DeleteToRecycleBin;
     // -- �����������/�����������: ���� True, ���������� � ������������ ����� �������� CD/DVD
    property MoveFile_UseCDOptions: Boolean read FMoveFile_UseCDOptions write FMoveFile_UseCDOptions;
     // -- True, ���� �������� ������ ��������� � ������
    property ProjectChanged: Boolean read FProjectChanged;
     // -- �������������� ������: ����� ������ ���������� ��� ��������������
    property Repair_MatchFlags: TFileOpRepairMatchFlags read FRepair_MatchFlags write FRepair_MatchFlags;
     // -- �������������� ������: ���� True, ������������� ��������� � ����� ���������� ����� � ������� ����������� �����
    property Repair_LookSubfolders: Boolean read FRepair_LookSubfolders write FRepair_LookSubfolders;
     // -- �������������� ������: ���� True, ������������ ������ �������������� ������, ���������� ��� �������������
     //    �����������, �� ������������ �����������, � ������� ����������� �������. ���� False, ���������� ���
     //    ������������ �����
    property Repair_RelinkFilesInUse: Boolean read FRepair_RelinkFilesInUse write FRepair_RelinkFilesInUse;
     // -- �������������� ������: ���� True, ������� �����������, ������� ��� � �� ���� ������� ���������������� �����
    property Repair_DeleteUnmatchedPics: Boolean read FRepair_DeleteUnmatchedPics write FRepair_DeleteUnmatchedPics;
     // -- �������������� ������: ������ ��������� ������ � ������ �� �����������
    property Repair_FileLinks: TFileLinks read FRepair_FileLinks;
     // -- ��������� ������ (������ �� ������ ������ ��� SelPicMode=fospmSelGroups)
    property SelectedGroups: IPhotoAlbumPicGroupList read FSelectedGroups;
     // -- ���������� ��� �������� �����������
    property SelectedPics: IPhotoAlbumPicList read FSelectedPics;
     // -- ����� ������ �����������
    property SelPicMode: TFileOpSelPicMode read FSelPicMode write FSelPicMode;
     // -- ������ ������ ����������� �� ������� ���������������� �����
    property SelPicValidityFilter: TFileOpSelPicValidityFilter read FSelPicValidityFilter write FSelPicValidityFilter;
  end;

   // �����-���������� �������� ��������
  TFileOpThread = class(TThread)
  private
     // �����-�������� ������
    FWizard: TdFileOpsWizard;
     // Prop storage
    FErrorOccured: Boolean;
    FChangesMade: Boolean;
     // ���� ��� AskOverwrite()
    FOverwriteFileName: String;
    FOverwriteResults: TMessageBoxResults;
     // ���������, ����������� �������� ��� ���������� �����������
    procedure DoCopyMovePic(Pic: IPhotoAlbumPic);
    procedure DoDelPicAndFile(Pic: IPhotoAlbumPic);
    procedure DoRebuildThumb(Pic: IPhotoAlbumPic);
    procedure DoRepairFileLink(Pic: IPhotoAlbumPic);
     // ��������� �������� �����
    procedure DoDeleteFile(const sFileName: String; bDelToRecycleBin: Boolean);
     // ������� ����������� �� ����������� (����� ������ �� ���� �� �����)
    procedure DoDeletePic(Pic: IPhotoAlbumPic);
     // ��������� ������ �� ���� (�������������� �������� ������������ �����)
    procedure DoUpdateFileLink(Pic: IPhotoAlbumPic; const sNewFileName: String);
     // ���������� ����������� ���������� ����� (���������� � Synchronize())
    procedure AskOverwrite;
  protected
    procedure Execute; override;
  public
    constructor Create(Wizard: TdFileOpsWizard);
     // Props
     // -- True, ���� ��������� �������� ������ ��������� � ����������
    property ChangesMade: Boolean read FChangesMade;
     // -- True, ���� ��������� ������ ��� ���������� ��������
    property ErrorOccured: Boolean read FErrorOccured;
  end;

   // ���������� ������ �������� � ������� �����������. ���������� True, ���� ���-�� � ����������� ���� ��������
   //   AApp - ����������
  function DoFileOperations(AApp: IPhotoAlbumApp; out bProjectChanged: Boolean): Boolean;

implementation
{$R *.dfm}
uses
  ShellAPI,
  phUtils, ufrWzPage_Log,
  ufrWzPage_Processing, ufrWzPageFileOps_SelTask, ufrWzPageFileOps_SelPics, ufrWzPageFileOps_SelFolder,
  ufrWzPageFileOps_MoveOptions, ufrWzPageFileOps_DelOptions, ufrWzPageFileOps_RepairOptions,
  Main, ufrWzPageFileOps_CDOptions, ufrWzPageFileOps_RepairSelLinks,
  ufrWzPageFileOps_MoveOptions2, phSettings, udMsgBox;

  function DoFileOperations(AApp: IPhotoAlbumApp; out bProjectChanged: Boolean): Boolean;
  begin
    with TdFileOpsWizard.Create(Application) do
      try
        FApp := AApp;
        FSelPicsByDefault := FApp.FocusedControl=pafcThumbViewer;
        Result := Execute;
        bProjectChanged := ProjectChanged;
      finally
        Free;
      end;
  end;

   // Exception raising
  procedure FileOpError(const sConstName: String; const aParams: Array of const);
  begin
    raise EFileOpError.Create(ConstVal(sConstName, aParams));
  end;

   //===================================================================================================================
   // TFileLink
   //===================================================================================================================

  constructor TFileLink.Create(const sFileName, sFilePath: String; iFileSize: Integer; const dFileTime: TDateTime);
  begin
    inherited Create;
    FFileName := sFileName;
    FFilePath := sFilePath;
    FFileSize := iFileSize;
    FFileTime := dFileTime;
    FPics     := NewPhotoAlbumPicList(True);
  end;

   //===================================================================================================================
   // TFileLinks
   //===================================================================================================================

  function TFileLinks.Add(const sFileName, sFilePath: String; iFileSize: Integer; const dFileTime: TDateTime): TFileLink;
  begin
    Result := TFileLink.Create(sFileName, sFilePath, iFileSize, dFileTime);
    inherited Add(Result);
  end;

  function TFileLinks.GetItems(Index: Integer): TFileLink;
  begin
    Result := TFileLink(Get(Index));
  end;

  procedure TFileLinks.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action=lnDeleted then TFileLink(Ptr).Free;
  end;

   //===================================================================================================================
   // TFileOpThread
   //===================================================================================================================

  procedure TFileOpThread.AskOverwrite;
  begin
    FOverwriteResults := PhoaMsgBox(mbkConfirmWarning, 'SConfirm_FileOverwrite', [FOverwriteFileName], True, False, [mbbYes, mbbYesToAll, mbbNo, mbbNoToAll, mbbCancel]);
  end;

  constructor TFileOpThread.Create(Wizard: TdFileOpsWizard);
  begin
    inherited Create(True);
    FWizard := Wizard;
    FreeOnTerminate := True;
    Resume;
  end;

  procedure TFileOpThread.DoCopyMovePic(Pic: IPhotoAlbumPic);
  var
    sSrcFileName, sSrcPath, sSrcFullFileName, sDestPath, sTargetPath, sTargetFileName: String;
    SLRelTargetPaths: TStringList;
    i: Integer;

     // ��������� ������������� ���� � ����������� � SLRelTargetPaths, ���� ������ ������� � ��� ������������ � ������
     //   Group. ���������� �������� ���� ��� ��������� �����
    procedure AddPathIfPicInGroup(Group: IPhotoAlbumPicGroup);
    var
      i: Integer;
      g: IPhotoAlbumPicGroup;
      sRelPath: String;
      bGroupSelected: Boolean;
    begin
       // ��������� ����������� ������
      case FWizard.SelPicMode of
        fospmSelPics:         bGroupSelected := Group.ID=FWizard.App.CurGroup.ID;
        fospmAll:             bGroupSelected := True;
        else {fospmSelGroups} bGroupSelected := FWizard.SelectedGroups.IndexOfID(Group.ID)>=0;
      end;
       // ���� ������ �������, ���� ����������� � ������
      if bGroupSelected and (Group.Pics.IndexOfID(Pic.ID)>=0) then begin
         // ��������� ���� ����������� ������������ MoveFile_BaseGroup
        g := Group;
        sRelPath := '';
        while (g<>nil) and (g<>FWizard.MoveFile_BaseGroup) do begin
          sRelPath := ReplaceChars(g.Text, SInvalidPathChars, FWizard.MoveFile_ReplaceChar)+'\'+sRelPath;
          g := g.OwnerX;
        end;
         // ��������� ���� � ������
        SLRelTargetPaths.Add(sRelPath);
         // ���� ������������ ������ �� �����������, ��������� �����
        if not FWizard.MoveFile_AllowDuplicating then Exit;
      end;
       // ��������� �� �� ��� ��������� �����
      for i := 0 to Group.Groups.Count-1 do begin
        AddPathIfPicInGroup(Group.GroupsX[i]);
         // ���� ������������ ������ �� �����������, ��������� ����� ��� ������� [���� �� �����] ������ ����
        if not FWizard.MoveFile_AllowDuplicating and (SLRelTargetPaths.Count>0) then Exit;
      end;
    end;

     // ���������� ����������������� � ������������ � FWizard.MoveFile_FileNameFormat ��� ����� ���������� ���
     //   ��������������� �����������
    function GetFormattedTargetFileName: String;
    var
      s: String;
      i1, i2: Integer;
      PProp: TPicProperty;
    begin
      Result := '';
      s := FWizard.MoveFile_FileNameFormat;
      repeat
         // ���� �������� ������ � ������
        i1 := Pos('{', s);
        i2 := Pos('}', s);
         // �������� ������ �����������
        if (i1=0) and (i2=0) then Break;
         // ��������� � ���������� ������ ������, �� ���������� �������� ������
        Result := Result+Copy(s, 1, Min(i1, i2)-1);
         // �������� ��� �������� �����������, ������������ ����� �������� ������
        if (i1<>0) and (i2<>0) and (i1<i2-1) then begin
          PProp := StrToPicProp(Copy(s, i1+1, i2-i1-1), True);
           // ��������� � ���������� �������� �������� ��� ��������������� �����������
          Result := Result+Pic.PropStrValues[PProp];
        end;
         // ������� ������������ ����� ������ �� s
        Delete(s, 1, Max(i1, i2));
      until s='';
       // ��������� � ���������� ������� ������ (�� ���������� �������� ������) � ���������� ��������� �����
      Result := Result+s+ExtractFileExt(sSrcFileName);
       // �������� ������������ ������� � ����� �����
      Result := ReplaceChars(Result, SInvalidPathChars, FWizard.MoveFile_ReplaceChar);
    end;

     // �������� ���� � ���� sTargetPath
    procedure PerformCopying(const sTargetPath: String);
    var sTargetDir, sTargetFullFileName: String;
    begin
      sTargetDir := ExcludeTrailingPathDelimiter(sTargetPath);
       // ���������, ��� �������� � ������� ���� ������
      if AnsiSameText(sSrcPath, sTargetPath) then FileOpError('SErrSrcAndDestFoldersAreSame', [sTargetDir, sSrcFileName]);
       // �������� ������� ������� ����������
      if not ForceDirectories(sTargetDir) then FileOpError('SErrCannotCreateFolder', [sTargetDir]);
       // ��������� ���������� �����
      sTargetFullFileName := sTargetPath+sTargetFileName;
      case FWizard.MoveFile_OverwriteMode of
        fomfomNever: if FileExists(sTargetFullFileName) then FileOpError('SErrTargetFileExists', [sTargetFullFileName]);
        fomfomPrompt:
          if FileExists(sTargetFullFileName) then begin
            FOverwriteFileName := sTargetFullFileName;
            Synchronize(AskOverwrite);
             // "��"
            if mbrYes in FOverwriteResults then
              { do nothing }
             // "�� ��� ����"
            else if mbrYesToAll in FOverwriteResults then
              FWizard.MoveFile_OverwriteMode := fomfomAlways
             // "���"
            else if mbrNo in FOverwriteResults then
              FileOpError('SLogEntry_UserDeniedFileOverwrite', [sTargetFullFileName])
             // "��� ��� ����"
            else if mbrNoToAll in FOverwriteResults then begin
              FWizard.MoveFile_OverwriteMode := fomfomNever;
              FileOpError('SErrTargetFileExists', [sTargetFullFileName]);
             // "������"
            end else begin
              FWizard.InterruptProcessing;
              FileOpError('SLogEntry_UserAbort', []);
            end;
          end;
      end;
       // �������� ����
      if not CopyFile(PChar(sSrcFullFileName), PChar(sTargetFullFileName), False) then RaiseLastOSError;
       // ������������� �����
      FWizard.LogSuccess('SLogEntry_FileCopiedOK', [sSrcFullFileName, sTargetFullFileName]);
    end;

  begin
     // �������� ���/���� ��������� �����
    sSrcFullFileName := Pic.FileName;
    sSrcFileName     := ExtractFileName(sSrcFullFileName);
    sSrcPath         := ExtractFilePath(sSrcFullFileName);
    sDestPath        := IncludeTrailingPathDelimiter(FWizard.DestinationFolder);
    sTargetPath      := '';
    sTargetFileName  := GetFormattedTargetFileName;
    case FWizard.MoveFile_Arranging of
       // ��� � ���� ������� - ������� ����������
      fomfaPutFlatly: begin
        sTargetPath := sDestPath;
        PerformCopying(sTargetPath);
      end;
       // ����������� � �������, �������� ������������ ������������ �������� MoveFile_BasePath
      fomfaMaintainFolderLayout: begin
         // �������� ����� ����, ������������ ������� �������� ����� ����. ������� ':' �� ������, ���� ���� �������� ���
         //   �����
        sTargetPath := StringReplace(Copy(sSrcPath, Length(FWizard.MoveFile_BasePath)+1, MaxInt), ':', '', [rfReplaceAll]);
         // ������� ��� '\' � ������ (� ������ UNC-����, ��� MoveFile_BasePath ��� '\' � �����)
        while (sTargetPath<>'') and (sTargetPath[1]='\') do Delete(sTargetPath, 1, 1);
        sTargetPath := sDestPath+sTargetPath;
        PerformCopying(sTargetPath);
      end;
       // ����������� � �������, �������� ������������ ����� ������������ ������ MoveFile_BaseGroup
      else {fomfaMaintainGroupLayout} begin
        SLRelTargetPaths := TStringList.Create;
        try
          SLRelTargetPaths.Sorted     := True;
          SLRelTargetPaths.Duplicates := dupIgnore;
           // ��������� SLRelTargetPaths ������ ����������
          AddPathIfPicInGroup(FWizard.App.Project.ViewRootGroupX);
           // ���� ���-�� ���� (�� ����, ������ ���� ������)
          if SLRelTargetPaths.Count=0 then FileOpError('SErrNoTargetPathDetermined', [Pic.FileName]);
          sTargetPath := sDestPath+SLRelTargetPaths[0];
          for i := 0 to iif(FWizard.MoveFile_AllowDuplicating, SLRelTargetPaths.Count-1, 0) do PerformCopying(sDestPath+SLRelTargetPaths[i]);
        finally
          SLRelTargetPaths.Free;
        end;
      end;
    end;
     // ���� ����� - �����������
    if FWizard.FileOpKind=fokMoveFiles then begin
       // ���������� ������
      DoUpdateFileLink(Pic, sTargetPath+sTargetFileName);
       // ������� �������� ����
      if FWizard.MoveFile_DeleteOriginal then DoDeleteFile(sSrcFullFileName, FWizard.MoveFile_DeleteToRecycleBin);
    end;
     // ���� ������� ����� �������� �����������, ���������� ������ �� ���� � ��������������� �����������
    if FWizard.ExportedProject<>nil then FWizard.ExportedProject.PicsX.ItemsByIDX[Pic.ID].FileName := sTargetPath+sTargetFileName;
  end;

  procedure TFileOpThread.DoDeleteFile(const sFileName: String; bDelToRecycleBin: Boolean);
  var SFOS: TSHFileOpStruct;
  begin
     // ��������� ������� �����. ���� ��� ��� - �������, �������, �� �����
    if not FileExists(sFileName) then
      FWizard.LogSuccess('SLogEntry_SkipInsteadOfDelFile', [sFileName])
     // ����� ������� ����
    else
       // -- � �������
      if bDelToRecycleBin then begin
        SFOS.Wnd    := FWizard.Handle;
        SFOS.wFunc  := FO_DELETE;
        SFOS.pFrom  := PChar(sFileName+#0);
        SFOS.pTo    := #0;
        SFOS.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
        if SHFileOperation(SFOS)=0 then
          FWizard.LogSuccess('SLogEntry_FileRecycledOK', [sFileName])
        else
          FileOpError('SLogEntry_FileRecyclingError', [sFileName]);
       // -- ������
      end else
        if DeleteFile(sFileName) then
          FWizard.LogSuccess('SLogEntry_FileDeletedOK', [sFileName])
        else
          FileOpError('SLogEntry_FileDeletingError', [sFileName]);
  end;

  procedure TFileOpThread.DoDeletePic(Pic: IPhotoAlbumPic);

     // ���������� ������� ����������� �� ������ Group � � ��������
    procedure DelID(Group: IPhotoAlbumPicGroup; iID: Integer);
    var i: Integer;
    begin
      Group.PicsX.Remove(iID);
      for i := 0 to Group.Groups.Count-1 do DelID(Group.GroupsX[i], iID);
    end;

  begin
    FChangesMade := True;
     // ������� ��� ������ �� �����������
    DelID(FWizard.App.Project.RootGroupX, Pic.ID);
     // ������� ����������� �� �������
    FWizard.App.Project.PicsX.Remove(Pic.ID);
  end;

  procedure TFileOpThread.DoDelPicAndFile(Pic: IPhotoAlbumPic);
  var sFileName: String;
  begin
     // ������� ����
    sFileName := Pic.FileName;
    DoDeleteFile(sFileName, FWizard.DelFile_DeleteToRecycleBin);
     // ������� �����������
    DoDeletePic(Pic);
     // ������������� �����
    FWizard.LogSuccess('SLogEntry_PicDeletedOK', [sFileName]);
  end;

  procedure TFileOpThread.DoRebuildThumb(Pic: IPhotoAlbumPic);
  var iPrevThumbSize, iPrevFileSize: Integer;
  begin
     // ���������� ������� ������� ������ � �����
    iPrevThumbSize := Length(Pic.ThumbnailData);
    iPrevFileSize  := Pic.FileSize;
     // ������������� �����
    Pic.ReloadPicFileData(
      FWizard.App.Project.ThumbnailSize,
      TPhoaStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)),
      FWizard.App.Project.ThumbnailQuality);
     // ������������� �����
    FWizard.LogSuccess(
      'SLogEntry_ThumbRebuiltOK',
      [Pic.FileName, iPrevThumbSize, Length(Pic.ThumbnailData), iPrevFileSize, Pic.FileSize]);
    FChangesMade := True;
  end;

  procedure TFileOpThread.DoRepairFileLink(Pic: IPhotoAlbumPic);
  begin
    //#ToDo3: �������� repair routine
  end;

  procedure TFileOpThread.DoUpdateFileLink(Pic: IPhotoAlbumPic; const sNewFileName: String);
  var sPrevFileName: String;
  begin
     // ���������, ����� �� ��������� ����
    if not AnsiSameText(Pic.FileName, sNewFileName) and (FWizard.App.Project.Pics.IndexOfFileName(sNewFileName)>=0) then
      FileOpError('SLogEntry_PicRelinkingError', [sNewFileName]);
     // ���������� (���� ��� ���������� ������, �.�. ������� ����� ����������)
    sPrevFileName := Pic.FileName;
    if sPrevFileName<>sNewFileName then begin
      Pic.FileName := sNewFileName;
      FWizard.LogSuccess('SLogEntry_PicRelinkedOK', [sPrevFileName, sNewFileName]);
      FChangesMade := True;
    end;
  end;

  procedure TFileOpThread.Execute;
  var
    Pic: IPhotoAlbumPic;
    sFileName: String;
  begin
    while not Terminated do begin
       // ������������ �����������
      Pic := FWizard.SelectedPics[0];
      sFileName := Pic.FileName;
      FErrorOccured := False;
      FChangesMade := False;
      try
        case FWizard.FileOpKind of
          fokCopyFiles,
            fokMoveFiles:     DoCopyMovePic(Pic);
          fokDeleteFiles:     DoDelPicAndFile(Pic);
          fokRebuildThumbs:   DoRebuildThumb(Pic);
          fokRepairFileLinks: DoRepairFileLink(Pic);
        end;
      except
        on e: Exception do begin
          FErrorOccured := True;
          FWizard.LogFailure('SLogEntry_FileOpError', [sFileName, e.Message]);
        end;
      end;
       // ������������ ���������
      Synchronize(FWizard.ThreadPicProcessed);
    end;
  end;

   //===================================================================================================================
   // TdFileOpsWizard
   //===================================================================================================================

  procedure TdFileOpsWizard.CreateExportedPhoa;
   // ������� ����������� ������ (�� �������; �������; �� �������, �� ������� ���� �� � ��������)
  type TGroupSelection = (gsNotSelected, gsSelected, gsChildSelected);

     // ���������� ����������� ������ � ������� (������ ��� ������ SelPicMode=fospmSelGroups)
    function GetGroupSelection(Group: IPhoaPicGroup): TGroupSelection;
    var i: Integer;
    begin
      if FSelectedGroups.IndexOfID(Group.ID)>=0 then
        Result := gsSelected
      else begin
        Result := gsNotSelected;
        for i := 0 to Group.Groups.Count-1 do
          if GetGroupSelection(Group.Groups[i])<>gsNotSelected then begin
            Result := gsChildSelected;
            Break;
          end;
      end;
    end;

     // ���������� ��������� ��������� ������ � ����������� (������ ��� ������ SelPicMode=fospmSelGroups)
    procedure AddGroup(TgtGroup, OwnerGroup, SrcGroup: IPhotoAlbumPicGroup; bUseTgtGroup: Boolean);
    var
      GS: TGroupSelection;
      i: Integer;
    begin
      GS := GetGroupSelection(SrcGroup);
       // ���� ������ ��� ��������� ������� - ��������� ������ � ��������
      if GS<>gsNotSelected then begin
         // ���� ��� �� �������� ������, ������ �����. target-������
        if not bUseTgtGroup then TgtGroup := NewPhotoAlbumPicGroup(OwnerGroup, 0);
         // �������� �������� �������� ������. ���� ������� ���� ������, ��������� � �� � ����������� �������� ������
        TgtGroup.Assign(SrcGroup, True, GS=gsSelected, False);
         // ��������� �� �� ��� ���� ��������
        for i := 0 to SrcGroup.Groups.Count-1 do AddGroup(nil, TgtGroup, SrcGroup.GroupsX[i], False);
      end;
    end;

     // ��������� ��������� ������ � ����������
    procedure AddSingleGroup(TgtGroup, SrcGroup: IPhotoAlbumPicGroup; bUseTgtAsOwnerGroup: Boolean);
    begin
       // ���� ��� �� �������� ������, ������ �����. target-������
      if bUseTgtAsOwnerGroup then TgtGroup := NewPhotoAlbumPicGroup(TgtGroup, 0);
       // �������� �������� �������� ������
      TgtGroup.Assign(SrcGroup, True, False, False);
       // ��������� ��������� �����������
      TgtGroup.PicsX.Add(FSelectedPics, True);
    end;

  begin
     // ������ ����������
    FExportedProject := NewPhotoAlbumProject;
     // �������� ���������
    FExportedProject.Assign(FApp.Project, False);
     // ����������� �����
    FExportedProject.Description := FCDOpt_PhoaDesc;
    FExportedProject.FileName    := IncludeTrailingPathDelimiter(FDestinationFolder)+FCDOpt_PhoaFileName;
     // �������� �����������
    FExportedProject.PicsX.DuplicatePics(FSelectedPics);
     // �������� ������ � ����������� � ���
    case SelPicMode of
      fospmSelPics:   AddSingleGroup(FExportedProject.RootGroupX, FApp.CurGroup, FApp.CurGroup<>FApp.Project.RootGroup);
      fospmAll:       FExportedProject.RootGroupX.Assign(FApp.Project.RootGroupX, True, True, True);
      fospmSelGroups: AddGroup(FExportedProject.RootGroupX, nil, FApp.Project.RootGroupX, True);
    end;
     // �������� �������������
    if FCDOpt_IncludeViews then FExportedProject.ViewsX.Assign(FApp.Project.Views);
  end;

  procedure TdFileOpsWizard.DoSelectPictures;
  var i: Integer;
  begin
     // ��������� �����������
    FSelectedPics := NewPhotoAlbumPicList(True);
    case SelPicMode of
      fospmSelPics:   FSelectedPics.Assign(FApp.SelectedPics);
      fospmAll:       FSelectedPics.Assign(FApp.Project.Pics);
      fospmSelGroups: for i := 0 to FSelectedGroups.Count-1 do FSelectedPics.Add(FSelectedGroups[i].Pics, True);
      else            FSelectedPics := nil;
    end;
     // ������� [��]������������
    if FSelPicValidityFilter<>fospvfAny then
      for i := FSelectedPics.Count-1 downto 0 do
        if FileExists(FSelectedPics[i].FileName)<>(FSelPicValidityFilter=fospvfValidOnly) then FSelectedPics.Delete(i);
  end;

  procedure TdFileOpsWizard.FinalizeProcessing;
  var
    sDestPath: String;
    fs: TFileStream;

    procedure FSWriteLine(const s: String; const aParams: Array of const);
    var sf: String;
    begin
      sf := Format(s, aParams)+S_CRLF;
      fs.Write(sf[1], Length(sf));
    end;

  begin
     // ��������� ������ �� ���������� CD/DVD, ���� �����
    if (FFileOpKind in [fokCopyFiles, fokMoveFiles]) and FMoveFile_UseCDOptions then begin
      sDestPath := IncludeTrailingPathDelimiter(FDestinationFolder);
       // ���� ���� ����������, ��������� ��� � ����
      if FExportedProject<>nil then
        try
          FExportedProject.SaveToFile(FExportedProject.FileName, SProject_Generator, SProject_Remark, FExportedProject.FileRevision);
          LogSuccess('SLogEntry_PhoaSavedOK', [FExportedProject.FileName]);
        except
          on e: Exception do LogFailure('SLogEntry_PhoaSaveError', [FExportedProject.FileName, e.Message]);
        end;
       // �������� ���������
      if FCDOpt_CopyExecutable then begin
        if CopyFile(
            PChar(ParamStr(0)),
            PChar(sDestPath+SPhoaExecutableFileName),
            False) then
          LogSuccess('SLogEntry_ExecutableCopiedOK', [FDestinationFolder])
        else
          LogFailure('SLogEntry_ExecutableCopyingError', [FDestinationFolder, SysErrorMessage(GetLastError)]);
         // ���������� ������� ��������� � phoa.ini
        if FCDOpt_CopyIniSettings then IniSaveSettings(sDestPath+SDefaultIniFileName);
      end;
       // ������ autorun.inf
      if (FExportedProject<>nil) and FCDOpt_CreateAutorun then
        try
          fs := TFileStream.Create(sDestPath+'autorun.inf', fmCreate);
          try
            FSWriteLine(
              '[autorun]'+S_CRLF+
              'open=%s "%s"'+S_CRLF+
              'icon=%0:s,1',
              [SPhoaExecutableFileName, FCDOpt_PhoaFileName]);
            if FCDOpt_MediaLabel<>'' then FSWriteLine('label=%s', [FCDOpt_MediaLabel]);
          finally
            fs.Free;
          end;
          LogSuccess('SLogEntry_AutorunCreatedOK', []);
        except
          on e: Exception do LogFailure('SLogEntry_AutorunCreationError', [e.Message]);
        end;
    end;
     // ��������� ����� �������/���������� ��������
    if (FCountErrors=0) and SettingValueBool(ISettingID_Dlgs_FOW_LogOnErrOnly) then
      ModalResult := mrOK
    else
      Controller.SetVisiblePageID(IWzFileOpsPageID_Log, pcmNextBtn);
  end;

  procedure TdFileOpsWizard.FinalizeWizard;
  begin
    FRepair_FileLinks.Free;
    FExportedProject := nil;
    FSelectedPics    := nil;
    FSelectedGroups  := nil;
    FLog.Free;
    inherited FinalizeWizard;
  end;

  function TdFileOpsWizard.GetFormRegistrySection: String;
  begin
    Result := SRegFileOps_Root;
  end;

  function TdFileOpsWizard.GetNextPageID: Integer;
  begin
    Result := 0;
    case CurPageID of
      IWzFileOpsPageID_SelTask:          Result := IWzFileOpsPageID_SelPics;
      IWzFileOpsPageID_SelPics:
        case FFileOpKind of
          fokCopyFiles,
            fokMoveFiles,
            fokRepairFileLinks:          Result := IWzFileOpsPageID_SelFolder;
          fokDeleteFiles:                Result := IWzFileOpsPageID_DelOptions;
          fokRebuildThumbs:              Result := IWzFileOpsPageID_Processing;
        end;
      IWzFileOpsPageID_SelFolder:
        case FFileOpKind of
          fokCopyFiles,
            fokMoveFiles:                Result := IWzFileOpsPageID_MoveOptions;
          fokRepairFileLinks:            Result := IWzFileOpsPageID_RepairOptions;
        end;
      IWzFileOpsPageID_MoveOptions:      Result := IWzFileOpsPageID_MoveOptions2;
      IWzFileOpsPageID_MoveOptions2:     Result := iif(FMoveFile_UseCDOptions, IWzFileOpsPageID_CDOptions, IWzFileOpsPageID_Processing);
      IWzFileOpsPageID_RepairOptions:    Result := IWzFileOpsPageID_RepairSelLinks;
      IWzFileOpsPageID_CDOptions,
        IWzFileOpsPageID_DelOptions,
        IWzFileOpsPageID_RepairSelLinks: Result := IWzFileOpsPageID_Processing;
      IWzFileOpsPageID_Processing:       Result := IWzFileOpsPageID_Log;
    end;
  end;

  procedure TdFileOpsWizard.InitializeWizard;
  var sOptPageTitle: String;
  begin
    inherited InitializeWizard;
    FSelectedGroups := NewPhotoAlbumPicGroupList(nil);
     // ���� �� ������ ������� ������, ������� � � ������
    if FApp.CurGroup<>nil then FSelectedGroups.Add(FApp.CurGroup);
     // ����������� ����� ������ ����������� �� ���������
    if FSelPicsByDefault and (FApp.SelectedPics.Count>0) then FSelPicMode := fospmSelPics
    else if FSelectedGroups.Count>0 then                      FSelPicMode := fospmSelGroups
    else                                                      FSelPicMode := fospmAll;
     // �������������� �����
    FCDOpt_CopyExecutable        := True;
    FCDOpt_IncludeViews          := True;
    FCDOpt_CreatePhoa            := True;
    FCDOpt_CreateAutorun         := True;
    FCDOpt_CopyIniSettings       := True;
    FCDOpt_MediaLabel            := ConstVal('SPhotoAlbumNode');
    FCDOpt_PhoaDesc              := FApp.Project.Description;
    FCDOpt_PhoaFileName          := ExtractFileName(FApp.Project.FileName);
    FMoveFile_ReplaceChar        := '_';
    FMoveFile_FileNameFormat     := 'Image_{ID}';
    FMoveFile_DeleteToRecycleBin := True;
    FMoveFile_OverwriteMode      := fomfomPrompt;
    FMoveFile_UseCDOptions       := True;
    FDelFile_DeleteToRecycleBin  := True;
    FRepair_MatchFlags           := [formfName, formfSize];
    FRepair_LookSubfolders       := True;
     // ������ �������� � ���������� ������ ��������
    sOptPageTitle := ConstVal('SWzPageFileOps_Options');
    Controller.CreatePage(TfrWzPageFileOps_SelTask,        IWzFileOpsPageID_SelTask,        IDH_intf_file_ops_seltask,   ConstVal('SWzPageFileOps_SelTask'));
    Controller.CreatePage(TfrWzPageFileOps_SelPics,        IWzFileOpsPageID_SelPics,        IDH_intf_file_ops_selpics,   ConstVal('SWzPageFileOps_SelPics'));
    Controller.CreatePage(TfrWzPageFileOps_SelFolder,      IWzFileOpsPageID_SelFolder,      IDH_intf_file_ops_selfolder, ConstVal('SWzPageFileOps_SelFolder'));
    Controller.CreatePage(TfrWzPageFileOps_MoveOptions,    IWzFileOpsPageID_MoveOptions,    IDH_intf_file_ops_moveopts,  sOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_MoveOptions2,   IWzFileOpsPageID_MoveOptions2,   IDH_intf_file_ops_moveopts2, sOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_CDOptions,      IWzFileOpsPageID_CDOptions,      IDH_intf_file_ops_cdopts,    sOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_DelOptions,     IWzFileOpsPageID_DelOptions,     IDH_intf_file_ops_delopts,   sOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_RepairOptions,  IWzFileOpsPageID_RepairOptions,  IDH_intf_file_ops_repropts,  sOptPageTitle);
    Controller.CreatePage(TfrWzPageFileOps_RepairSelLinks, IWzFileOpsPageID_RepairSelLinks, 0{#ToDo3: ������� HelpTopic}, ConstVal('SWzPageFileOps_RepairSelLinks'));                        
    Controller.CreatePage(TfrWzPage_Processing,            IWzFileOpsPageID_Processing,     IDH_intf_file_ops_process,   ConstVal('SWzPageFileOps_Processing'));
    Controller.CreatePage(TfrWzPage_Log,                   IWzFileOpsPageID_Log,            IDH_intf_file_ops_log,       ConstVal('SWzPageFileOps_Log'));
    Controller.SetVisiblePageID(IWzFileOpsPageID_SelTask, pcmForced);
  end;

  procedure TdFileOpsWizard.InterruptProcessing;
  begin
    FProcessingInterrupted := True;
  end;

  function TdFileOpsWizard.IsBtnBackEnabled: Boolean;
  begin
     // �� �������� ��������� �������� ���, �� �������� ������ ��������� ����� ������ ���� ��� ���� �����
    Result :=
      inherited IsBtnBackEnabled and
      (CurPageID<>IWzFileOpsPageID_Processing) and
      ((CurPageID<>IWzFileOpsPageID_Log) or (FSelectedPics.Count>0));
  end;

  function TdFileOpsWizard.IsBtnCancelEnabled: Boolean;
  begin
    Result :=
      inherited IsBtnCancelEnabled and
      ((CurPageID<>IWzFileOpsPageID_Processing) or not FProcessing);
  end;

  function TdFileOpsWizard.IsBtnNextEnabled: Boolean;
  begin
    Result := inherited IsBtnNextEnabled;
    if Result then
      case CurPageID of
         // �� �������� ��������� ������ ����� ���� ������ ��� ������������� �������� � ������� ������� ���������
        IWzFileOpsPageID_Processing: Result := not FProcessing and (FLog<>nil);
      end;
  end;

  procedure TdFileOpsWizard.LogFailure(const s: String; const aParams: array of const);
  begin
    Inc(FCountErrors);
    FLog.Add('[!] '+ConstVal(s, aParams));
  end;

  function TdFileOpsWizard.LogPage_GetLog(iPageID: Integer): TStrings;
  begin
    Result := FLog;
  end;

  procedure TdFileOpsWizard.LogSuccess(const s: String; const aParams: array of const);
  begin
    FLog.Add('[+] '+ConstVal(s, aParams));
  end;

  procedure TdFileOpsWizard.PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
  begin
    inherited PageChanged(ChangeMethod, iPrevPageID);
    if (ChangeMethod=pcmNextBtn) and (CurPageID=IWzFileOpsPageID_Processing) then StartProcessing;
  end;

  function TdFileOpsWizard.PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
  begin
    Result := inherited PageChanging(ChangeMethod, iNewPageID);
    if Result and (ChangeMethod=pcmNextBtn) then begin
      case iNewPageID of
         // ��� ��������� �� �������� ������ ����������� ����������� ������, ������ ������� ���������
        IWzFileOpsPageID_SelPics: FSelectedPics := nil;
         // ��� ��������� �� �������� ����� �������������� ������ ����������� ������, ������ ������� �����
        IWzFileOpsPageID_RepairOptions: FreeAndNil(FRepair_FileLinks);
         // ��� ��������� �� �������� ������ ������ ������� ���������� ������� ������
        IWzFileOpsPageID_RepairSelLinks: Repair_SelectFiles;
         // ����� ������� ��������� ��������� ������������� �������������
        IWzFileOpsPageID_Processing: Result := PhoaConfirm(True, 'SConfirm_PerformFileOperation', aFileOpConfirmSettingIDs[FFileOpKind]);
      end;
      if Result then
        case CurPageID of
           // ����� ������ ������ ����������� ����� �� ���������
          IWzFileOpsPageID_SelTask: if FFileOpKind=fokRepairFileLinks then FSelPicValidityFilter := fospvfInvalidOnly;
           // ��� ����� �� �������� ������ ����������� ������ ������ �����������
          IWzFileOpsPageID_SelPics: DoSelectPictures;
           // ��� ����� �� �������� ����� �������������� ������ ������ ������ ������
          IWzFileOpsPageID_RepairOptions: Repair_SelectFiles;
        end;
    end;
  end;

  function TdFileOpsWizard.ProcPage_GetCurrentStatus: String;
  begin
     // ���� ������� �������, ���������� ��������
    if FProcessing then
      Result := ConstVal('SWzFileOps_Processing', [ProcPage_GetProgressCur+1, FInitialPicCount, FCountErrors, FSelectedPics[0].FileName])
     // ����� ����� ���������� � ����������� �����������
    else
      Result := ConstVal('SWzFileOps_Paused', [FCountSucceeded, FCountErrors]);
  end;

  function TdFileOpsWizard.ProcPage_GetProcessingActive: Boolean;
  begin
    Result := FProcessing;
  end;

  function TdFileOpsWizard.ProcPage_GetProgressCur: Integer;
  begin
    Result := FInitialPicCount-FSelectedPics.Count;
  end;

  function TdFileOpsWizard.ProcPage_GetProgressMax: Integer;
  begin
    Result := FInitialPicCount;
  end;

  procedure TdFileOpsWizard.ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
  begin
    if FSelectedPics.Count>0 then PaintThumbnail(FSelectedPics[0], Bitmap32);
  end;

  procedure TdFileOpsWizard.Repair_SelectFiles;

     // ��������� ������ ����� � FRepair_FileLinks � ������� � ���� ������ �� �����������, ������� �� �������� ��
     //   ������� �������� ���������
    procedure AddFile(const sPath: String; const SRec: TSearchRec);
    var
      FL: TFileLink;
      i: Integer;
      bMatches: Boolean;
      Pic: IPhoaPic;
    begin
      FL := nil;
       // ���������� ��� �����������, ������� ����������
      for i := 0 to FSelectedPics.Count-1 do begin
        Pic := FSelectedPics[i];
         // ��������� ���������� - ������� �� �������, ����� �� ����� ����� (��� �������)
        bMatches := True;
        if bMatches and (formfSize in FRepair_MatchFlags) then bMatches := SRec.Size=Pic.FileSize;
        if bMatches and (formfName in FRepair_MatchFlags) then bMatches := AnsiSameText(SRec.Name, ExtractFileName(Pic.FileName));
         // ��������� ����������� �� "���������" ������ ������������
        if bMatches and not FRepair_RelinkFilesInUse      then bMatches := FApp.Project.Pics.IndexOfFileName(sPath+SRec.Name)<0;
         // ���� ��������
        if bMatches then begin
           // ������ ����, ���� �� ��� �� ������
          if FL=nil then FL := FRepair_FileLinks.Add(SRec.Name, sPath, SRec.Size, FileDateToDateTime(SRec.Time));
           // ��������� ��� ������
          FL.Pics.Add(Pic, True);
        end;
      end;
    end;

     // ���������� ��������� ������� sPath
    procedure AddFolder(const sPath: String; bRecurse: Boolean);
    var
      sr: TSearchRec;
      iRes: Integer;
    begin
      iRes := FindFirst(sPath+'*.*', faAnyFile, sr);
      try
        while iRes=0 do begin
          if sr.Name[1]<>'.' then
             // ���� ������� - ���������� ���������
            if sr.Attr and faDirectory<>0 then begin
              if bRecurse then AddFolder(sPath+sr.Name+'\', True);
             // ���� ���� � ���������� ��������� ���� - ��������� � ������
            end else if FileFormatList.GraphicFromExtension(ExtractFileExt(sr.Name))<>nil then
              AddFile(sPath, sr);
          iRes := FindNext(sr);
        end;
      finally
        FindClose(sr);
      end;
    end;

  begin
     // ������ ��� ������� ������ ������
    if FRepair_FileLinks=nil then FRepair_FileLinks := TFileLinks.Create else FRepair_FileLinks.Clear;
     // ���������� ��������� �����/�����
    AddFolder(IncludeTrailingPathDelimiter(FDestinationFolder), FRepair_LookSubfolders);
  end;

  procedure TdFileOpsWizard.SettingsRestore(rif: TRegIniFile);
  begin
    inherited SettingsRestore(rif);
    FDestinationFolder := rif.ReadString('', 'DestinationFolder', '');
  end;

  procedure TdFileOpsWizard.SettingsStore(rif: TRegIniFile);
  begin
    inherited SettingsStore(rif);
    rif.WriteString ('', 'DestinationFolder', FDestinationFolder);
  end;

  procedure TdFileOpsWizard.StartProcessing;
  begin
    FProcessing := True;
     // ������ ��������
    if FLog=nil then FLog := TStringList.Create;
     // ������ �������������� ����������
    if (FExportedProject=nil) and (FFileOpKind in [fokCopyFiles, fokMoveFiles]) and FMoveFile_UseCDOptions and FCDOpt_CreatePhoa then CreateExportedPhoa;
     // ���������� �������� ���������� ������
    FInitialPicCount := FSelectedPics.Count;
     // ��������� �������� ���������
    UpdateProgressInfo;
     // ��������� �����
    FProcessingInterrupted := False;
    FFileOpThread := TFileOpThread.Create(Self);
  end;

  procedure TdFileOpsWizard.ThreadPicProcessed;
  begin
     // ���������, ��� ��������� ��������
    if not FFileOpThread.ErrorOccured then Inc(FCountSucceeded);
     // ��������� ������ �������
    HasUpdates := True;
    if FFileOpThread.ChangesMade then FProjectChanged := True;
     // ������� ������������ �����������
    FSelectedPics.Delete(0);
     // ���� ��������� ���� ������, ��������� �����
    if (FSelectedPics.Count=0) or FProcessingInterrupted then begin
      FProcessing := False;
      FFileOpThread.Terminate;
      FFileOpThread := nil;
       // ���� ������ ����, ��������� ���������
      if FSelectedPics.Count=0 then FinalizeProcessing;
    end;
     // ���������� �������� ���������
    UpdateProgressInfo;
  end;

  procedure TdFileOpsWizard.UpdateProgressInfo;
  begin
    Controller.ItemsByID[IWzFileOpsPageID_Processing].Perform(WM_PAGEUPDATE, 0, 0);
    UpdateButtons;
  end;

end.

