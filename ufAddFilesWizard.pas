//**********************************************************************************************************************
//  $Id: ufAddFilesWizard.pas,v 1.27 2004-11-24 11:42:17 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ufAddFilesWizard;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Registry,
  GR32, GraphicEx,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps, ConsVars, phWizard, phGraphics,
  Placemnt, StdCtrls, ExtCtrls, phWizForm, DKLang, GR32_Image, TB2Dock,
  TBXDkPanels;

type
  TAddFilesThread = class;

  TfAddFilesWizard = class(TPhoaWizardForm, IPhoaWizardPageHost_Log, IPhoaWizardPageHost_Process)
    dklcMain: TDKLanguageController;
    pProcess: TPanel;
    dpPreview: TTBXDockablePanel;
    iPreview: TImage32;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure dpPreviewResize(Sender: TObject);
    procedure dpPreviewVisibleChanged(Sender: TObject);
  private
     // �����, ����������� �����
    FAddFilesThread: TAddFilesThread;
     // True, ���� ������� ������� ���������� ������
    FProcessingFiles: Boolean;
     // ���� ����, ��� ���������� ������ ����� ��������
    FFileProcessingInterrupted: Boolean;
     // ������� ����� ������
    FUndoOperations: TPhoaOperations;
     // ������ ����������� ��� ���������� � ������
    FPics: IPhotoAlbumPicList;
     // �������� ����������
    FLog: TStrings;
     // �������� ���������� ����������� ������
    FInitialFileCount: Integer;
     // ��������� ����������� ����������� (nil, ���� ���)
    FLastProcessedPic: IPhoaPic;
     // ������� ������� �����������
    FCountFailed: Integer;
     // ��������� ��������� ID �����������
    FFreePicID: Integer;
     // ������, � ������� ����������� �����������
    FGroup: IPhotoAlbumPicGroup;
     // ���� ��������������� ���������� ��������� ���� ���������
    FUpdatingPreviewVisibility: Boolean;
     // Prop storage
    FAddList: TStrings;
    FApp: IPhotoAlbumApp;
    FDefaultPath: String;
    FFileList: TFileList;
    FFilter_DateFrom: TDateTime;
    FFilter_DateTo: TDateTime;
    FFilter_Masks: String;
    FFilter_Presence: TAddFilePresenceFilter;
    FFilter_TimeFrom: TDateTime;
    FFilter_TimeTo: TDateTime;
    FRecurseFolders: Boolean;
    FShowAdvancedOptions: Boolean;
    FShowPreview: Boolean;
     // ��������� � FFileList ������ ������ (�����), ����� ������� ����������� � FAddList. ���������� True, ���� �
     //   ������ ����� ���� �� ���� ����. ��� bRecurse=True ��������������� �������� �����; bUseFilter ������ �� ��,
     //   ������������ �� �������� ������� Filter_xxx ��� �������� ������
    function  LoadFileList(bRecurse, bUseFilter: Boolean): Boolean;
     // ��������� ���������� � ���������� ������
    procedure UpdateProgressInfo;
     // ���������� �������, ����������� �����, ��� ����������� � ���, ��� ���� ���������
    procedure ThreadFileProcessed;
     // ���������� ������ � ��������
    procedure LogSuccess(const s: String; const aParams: Array of const);
    procedure LogFailure(const s: String; const aParams: Array of const);
     // ��������� ��������� ���� ��������� � �������� UpdatePreview
    procedure UpdatePreviewVisibility;
     // ��������� �������, ������������ ��� ���������
    procedure UpdatePreviewScale;
     // IPhoaWizardPageHost_Log
    function  LogPage_GetLog(iPageID: Integer): TStrings;
    function  IPhoaWizardPageHost_Log.GetLog = LogPage_GetLog;
     // IPhoaWizardPageHost_Process
    procedure ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
    function  ProcPage_GetCurrentStatus: String;
    function  ProcPage_GetProcessingActive: Boolean;
    function  ProcPage_GetProgressCur: Integer;
    function  ProcPage_GetProgressMax: Integer;
    procedure IPhoaWizardPageHost_Process.StartProcessing     = StartFileProcessing;
    procedure IPhoaWizardPageHost_Process.StopProcessing      = InterruptFileProcessing;
    procedure IPhoaWizardPageHost_Process.PaintThumbnail      = ProcPage_PaintThumbnail;
    function  IPhoaWizardPageHost_Process.GetCurrentStatus    = ProcPage_GetCurrentStatus;
    function  IPhoaWizardPageHost_Process.GetProcessingActive = ProcPage_GetProcessingActive;
    function  IPhoaWizardPageHost_Process.GetProgressCur      = ProcPage_GetProgressCur;
    function  IPhoaWizardPageHost_Process.GetProgressMax      = ProcPage_GetProgressMax;
     // Prop handlers
    procedure SetShowPreview(Value: Boolean);
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
     // ��������� ���� ��� ���������
    procedure UpdatePreview;
     // ��������� ���������� ������
    procedure StartFileProcessing;
     // ��������� ���������� ������
    procedure InterruptFileProcessing;
     // Props
     // -- ������ ������/����� ��� ���������� � FileList
    property AddList: TStrings read FAddList;
     // -- ����������
    property App: IPhotoAlbumApp read FApp;
     // -- ����� ��� ����������, ���������� �� ���������
    property DefaultPath: String read FDefaultPath write FDefaultPath;
     // -- ������ ������
    property FileList: TFileList read FFileList;
     // -- ������: ���� ����������� ����� "�" �������
    property Filter_DateFrom: TDateTime read FFilter_DateFrom write FFilter_DateFrom;
     // -- ������: ���� ����������� ����� "��" �������
    property Filter_DateTo: TDateTime read FFilter_DateTo write FFilter_DateTo;
     // -- ������: ����� ������
    property Filter_Masks: String read FFilter_Masks write FFilter_Masks;
     // -- ������: ����������� ������ � �����������
    property Filter_Presence: TAddFilePresenceFilter read FFilter_Presence write FFilter_Presence;
     // -- ������: ����� ����������� ����� "�" �������
    property Filter_TimeFrom: TDateTime read FFilter_TimeFrom write FFilter_TimeFrom;
     // -- ������: ����� ����������� ����� "��" �������
    property Filter_TimeTo: TDateTime read FFilter_TimeTo write FFilter_TimeTo;
     // -- True, ���� ������� �������� ��������� �����
    property RecurseFolders: Boolean read FRecurseFolders write FRecurseFolders;
     // -- True, ���� �������� ����������� ����� �������
    property ShowAdvancedOptions: Boolean read FShowAdvancedOptions write FShowAdvancedOptions;
     // -- True, ���� ������������ ���� ���������������� ���������
    property ShowPreview: Boolean read FShowPreview write SetShowPreview;
  end;

  TAddFilesThread = class(TThread)
  private
     // �����-�������� ������
    FWizard: TfAddFilesWizard;
     // ������������ �������� Autofill-�������
    FDateAutofillProps: TDateTimeAutofillProps;
    FReplaceDate: Boolean;
    FTimeAutofillProps: TDateTimeAutofillProps;
    FReplaceTime: Boolean;
    FAutofillXForm: Boolean;
     // ��������� �������������� �������
    FDateFillResult: TDateTimeFillResult;
    FTimeFillResult: TDateTimeFillResult;
    FXFormFilled: Boolean;
     // Prop storage
    FAddedPic: IPhotoAlbumPic;
     // ���������� �������������� ������� �����������
    procedure AutofillPicProps(Pic: IPhotoAlbumPic);
  protected
    procedure Execute; override;
  public
    constructor Create(Wizard: TfAddFilesWizard);
     // Props
     // -- ��������� ����������� ����������� (nil, ���� ��� ��� ���� ������)
    property AddedPic: IPhotoAlbumPic read FAddedPic;
  end;

   // ���������� ������ ���������� ������ �����������. ���������� True, ���� ���-�� � ����������� ���� ��������. ����
   //   FileList<>nil, �� ���������� �������� ������ ������ � ����� ��������� ��������� �����/�����
  function AddFiles(AApp: IPhotoAlbumApp; AGroup: IPhotoAlbumPicGroup; AUndoOperations: TPhoaOperations; AAddList: TStrings): Boolean;

implementation
{$R *.dfm}
uses
  phUtils, phMetadata, Main, VirtualShellUtilities,
  ufrWzPage_Log, ufrWzPage_Processing, ufrWzPageAddFiles_SelFiles, ufrWzPageAddFiles_CheckFiles,
  phPhoa, phSettings, udMsgBox;

  function AddFiles(AApp: IPhotoAlbumApp; AGroup: IPhotoAlbumPicGroup; AUndoOperations: TPhoaOperations; AAddList: TStrings): Boolean;
  var bShowWizard: Boolean;
  begin
    with TfAddFilesWizard.Create(Application) do
      try
        FApp            := AApp;
        FGroup          := AGroup; 
        FUndoOperations := AUndoOperations;
         // ���� ����� ������ ������, ��������� ����� � ��������� ������������� ����������� �������
        if AAddList<>nil then begin
          FAddList.Assign(AAddList);
          bShowWizard := LoadFileList(True, False);
        end else
          bShowWizard := True;
        Result := bShowWizard and Execute;
      finally
        Free;
      end;
  end;

   //===================================================================================================================
   // TAddFilesThread
   //===================================================================================================================

  procedure TAddFilesThread.AutofillPicProps(Pic: IPhotoAlbumPic);
  type
     // ������ � ��������� ���������������
    TTransformRec = record
      Rotation: TPicRotation; // ��������� �������
      Flips:    TPicFlips;    // ��������� ���������
    end;
  const
     // ������ ��������� �������������� � ����������� �� �������� Exif-���� Orientation ($0112)
    aExifOrientXforms: Array[1..8] of TTransformRec = (
      (Rotation: pr0;   Flips: []),         // 1=Portrait (Top Left)
      (Rotation: pr0;   Flips: [pflHorz]),  // 2=Portrait (Top Right)
      (Rotation: pr180; Flips: []),         // 3=Portrait (Bottom Right)
      (Rotation: pr180; Flips: [pflHorz]),  // 4=Portrait (Bottom Left)
      (Rotation: pr90;  Flips: [pflHorz]),  // 5=Landscape (Left Top)
      (Rotation: pr270; Flips: []),         // 6=Landscape (Right Top)
      (Rotation: pr270; Flips: [pflHorz]),  // 7=Landscape (Right Bottom)
      (Rotation: pr90;  Flips: []));        // 8=Landscape (Left Bottom)
  var
    Metadata: TImageMetadata;
    Namespace: TNamespace;

     // �������� ��������� ���� ����������� �� EXIF-����. ���������� True, ���� �������
    function FillExifDate(iTag: Integer): Boolean;
    var
      idx: Integer;
      s: String;
    begin
      Result := False;
       // ���� �������� ����
      idx := Metadata.EXIFData.IndexOfObject(Pointer(iTag));
       // ���� �����
      if idx>=0 then begin
        s := Metadata.EXIFData[idx];
         // �������� ������������� � ����
        try
          Pic.Date := DateToPhoaDate(EncodeDate(StrToInt(Copy(s, 1, 4)), StrToInt(Copy(s, 6, 2)), StrToInt(Copy(s, 9, 2))));
          Result := True;
        except
           // �� �����
          on EConvertError do ;
        end;
      end;
    end;

     // �������� ��������� ����� ����������� �� EXIF-����. ���������� True, ���� �������
    function FillExifTime(iTag: Integer): Boolean;
    var
      idx: Integer;
      s: String;
    begin
      Result := False;
       // ���� �������� ����
      idx := Metadata.EXIFData.IndexOfObject(Pointer(iTag));
       // ���� �����
      if idx>=0 then begin
        s := Metadata.EXIFData[idx];
         // �������� ������������� � ����
        try
          Pic.Time := TimeToPhoaTime(EncodeTime(StrToInt(Copy(s, 12, 2)), StrToInt(Copy(s, 15, 2)), StrToInt(Copy(s, 18, 2)), 0));
          Result := True;
        except
           // �� �����
          on EConvertError do ;
        end;
      end;
    end;

     // �������� ��������� ���� �����������, �������� � �� ����� ����� �����������. ���������� True, ���� �������
    function FillDateFromFilename: Boolean;
    var
      s: String;
      wy, wm, wd: Word;
    begin
      Result := False;
      s := ExtractFileName(Pic.FileName);
      wy := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      wm := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      wd := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      try
        Pic.Date := DateToPhoaDate(EncodeDate(wy, wm, wd));
        Result := True;
      except
        on EConvertError do { nothing };
      end;
    end;

     // �������� ��������� ����� �����������, �������� ��� �� ����� ����� �����������. ���������� True, ���� �������
    function FillTimeFromFilename: Boolean;
    var
      s: String;
      bh, bm, bs: Word;
      t: TDateTime;
    begin
      Result := False;
      s := ExtractFileName(Pic.FileName);
       // ������� �����, ���������� �� ����
      ExtractFirstWord(s, ' ');
       // ��������� ���������� �������
      bh := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      bm := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      bs := StrToIntDef(ExtractFirstWord(s, '-,.'), 0);
      try
        t := EncodeTime(bh, bm, bs, 0);
        if t>0 then begin
          Pic.Time := TimeToPhoaTime(t);
          Result := True;
        end;
      except
        on EConvertError do { nothing };
      end;
    end;

     // �������� ��������� ���� ����������� �� TDateTime. ���������� True, ���� �������
    function FillDate(const Date: TDateTime): Boolean;
    begin
      Result := Date<>0;
      if Result then Pic.Date := DateToPhoaDate(Date);
    end;

     // �������� ��������� ����� ����������� �� TDateTime. ���������� True, ���� �������
    function FillTime(const Time: TDateTime): Boolean;
    begin
      Result := Time<>0;
      if Result then Pic.Time := TimeToPhoaTime(Time);
    end;

     // ���������� True, ���� ���������� ��������� �������� � ������ ��� ������� � ����� ���������� ��������
    function NeedFill(CurResult: TDateTimeFillResult; bOverwrite: Boolean): Boolean;
    begin
      Result := (CurResult=dtfrEmpty) or ((CurResult=dtfrSpecified) and bOverwrite);
    end;

     // �������� ��������� �������������� ����������� �� ����������
    procedure FillExifTransforms;
    var
      idx: Integer;
      bOrient: Byte;
    begin
       // ���� �������� ����
      idx := Metadata.EXIFData.IndexOfObject(Pointer(EXIF_TAG_ORIENTATION));
       // ���� �����
      if idx>=0 then begin
         // ����������� (��������: ������ ������ � ORIENTATION - ��� ����� [1..8]) 
        bOrient := StrToIntDef(Copy(Metadata.EXIFData[idx], 1, 1), 0);
        if bOrient in [Low(aExifOrientXforms)..High(aExifOrientXforms)] then begin
          Pic.Rotation := aExifOrientXforms[bOrient].Rotation;
          Pic.Flips    := aExifOrientXforms[bOrient].Flips;
          FXformFilled := True;
        end;
      end;
    end;

  begin
    if Pic.Date=0 then FDateFillResult := dtfrEmpty else FDateFillResult := dtfrSpecified;
    if Pic.Time=0 then FTimeFillResult := dtfrEmpty else FTimeFillResult := dtfrSpecified;
    FXFormFilled := False;
     // ���� �����, ������ ������ ����������
    if (NeedFill(FDateFillResult, FReplaceDate) and ([dtapExifDTOriginal, dtapExifDTDigitized, dtapExifDateTime]*FDateAutofillProps<>[])) or
       (NeedFill(FTimeFillResult, FReplaceTime) and ([dtapExifDTOriginal, dtapExifDTDigitized, dtapExifDateTime]*FTimeAutofillProps<>[])) or
       FAutofillXForm then begin
      Metadata := TImageMetadata.Create(Pic.FileName);
      try
        if Metadata.StatusCode=IMS_OK then begin
           // ����
          if NeedFill(FDateFillResult, FReplaceDate) and (dtapExifDTOriginal  in FDateAutofillProps) and FillExifDate(EXIF_TAG_DATETIME_ORIGINAL)  then FDateFillResult := dtfrEXIF;
          if NeedFill(FDateFillResult, FReplaceDate) and (dtapExifDTDigitized in FDateAutofillProps) and FillExifDate(EXIF_TAG_DATETIME_DIGITIZED) then FDateFillResult := dtfrEXIF;
          if NeedFill(FDateFillResult, FReplaceDate) and (dtapExifDateTime    in FDateAutofillProps) and FillExifDate(EXIF_TAG_DATETIME)           then FDateFillResult := dtfrEXIF;
           // �����
          if NeedFill(FTimeFillResult, FReplaceTime) and (dtapExifDTOriginal  in FTimeAutofillProps) and FillExifTime(EXIF_TAG_DATETIME_ORIGINAL)  then FTimeFillResult := dtfrEXIF;
          if NeedFill(FTimeFillResult, FReplaceTime) and (dtapExifDTDigitized in FTimeAutofillProps) and FillExifTime(EXIF_TAG_DATETIME_DIGITIZED) then FTimeFillResult := dtfrEXIF;
          if NeedFill(FTimeFillResult, FReplaceTime) and (dtapExifDateTime    in FTimeAutofillProps) and FillExifTime(EXIF_TAG_DATETIME)           then FTimeFillResult := dtfrEXIF;
           // ��������������
          if FAutofillXForm then FillExifTransforms;
        end;
      finally
        Metadata.Free;
      end;
    end;
     // ��������� ����/����� �� ����� �����
    if NeedFill(FDateFillResult, FReplaceDate) and (dtapFilename in FDateAutofillProps) and FillDateFromFilename then FDateFillResult := dtfrFilename;
    if NeedFill(FTimeFillResult, FReplaceTime) and (dtapFilename in FTimeAutofillProps) and FillTimeFromFilename then FTimeFillResult := dtfrFilename;
     // ���� �����, ������ TNamespace
    if (NeedFill(FDateFillResult, FReplaceDate) and ([dtapDTFileCreated, dtapDTFileModified]*FDateAutofillProps<>[])) or
       (NeedFill(FTimeFillResult, FReplaceTime) and ([dtapDTFileCreated, dtapDTFileModified]*FTimeAutofillProps<>[])) then begin
      try
        Namespace := TNamespace.CreateFromFileName(Pic.FileName);
        try
           // ����
          if NeedFill(FDateFillResult, FReplaceDate) and (dtapDTFileCreated  in FDateAutofillProps) and FillDate(Int(Namespace.CreationDateTime))   then FDateFillResult := dtfrCreation;
          if NeedFill(FDateFillResult, FReplaceDate) and (dtapDTFileModified in FDateAutofillProps) and FillDate(Int(Namespace.LastWriteDateTime))  then FDateFillResult := dtfrModified;
           // �����
          if NeedFill(FTimeFillResult, FReplaceTime) and (dtapDTFileCreated  in FTimeAutofillProps) and FillTime(Frac(Namespace.CreationDateTime))  then FTimeFillResult := dtfrCreation;
          if NeedFill(FTimeFillResult, FReplaceTime) and (dtapDTFileModified in FTimeAutofillProps) and FillTime(Frac(Namespace.LastWriteDateTime)) then FTimeFillResult := dtfrModified;
        finally
          Namespace.Free;
        end;
      except
        on EVSTInvalidFileName do {ignore}
      end;
    end;
  end;

  constructor TAddFilesThread.Create(Wizard: TfAddFilesWizard);
  begin
    inherited Create(True);
    FWizard := Wizard;
    FreeOnTerminate := True;
     // �������� �������� Autofill-�������
    FDateAutofillProps := TDateTimeAutofillProps(Byte(SettingValueInt(ISettingID_Dlgs_APW_AutofillDate)));
    FReplaceDate       := SettingValueBool(ISettingID_Dlgs_APW_ReplaceDate);
    FTimeAutofillProps := TDateTimeAutofillProps(Byte(SettingValueInt(ISettingID_Dlgs_APW_AutofillTime)));
    FReplaceTime       := SettingValueBool(ISettingID_Dlgs_APW_ReplaceTime);
    FAutofillXForm     := SettingValueBool(ISettingID_Dlgs_APW_AutofillXfrm);
    Resume;
  end;

  procedure TAddFilesThread.Execute;
  var sFileName: String;
  begin
    try
      while not Terminated do
        with FWizard do begin
          try
            sFileName := FileList.Files[0];
             // ���� ����������� �� ����� �����
            FAddedPic := App.Project.PicsX.ItemsByFileNameX[sFileName];
             // ���� �� ����� - ������ ����� � ���������� �����
            if FAddedPic=nil then begin
              FAddedPic := NewPhotoAlbumPic;
              FAddedPic.FileName := sFileName;
              FAddedPic.ReloadPicFileData(
                App.Project.ThumbnailSize,
                TPhoaStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)),
                App.Project.ThumbnailQuality);
            end;
             // ���������� �������������� ������� �����������
            AutofillPicProps(FAddedPic);
             // ����� � ��������
            LogSuccess(
              'SLogEntry_AddingOK',
              [sFileName,
               DateTimeFillResultName(FDateFillResult),
               DateTimeFillResultName(FTimeFillResult),
               ConstVal(iif(FXformFilled, 'STransformFilledFromExif', 'SNone'))]);
          except
            on e: Exception do begin
              FAddedPic := nil;
              LogFailure('SLogEntry_AddingError', [FileList.Files[0], e.Message]);
            end;
          end;
           // ������������ ���������
          Synchronize(ThreadFileProcessed);
        end;
    finally
      FAddedPic := nil;
    end;
  end;

   //===================================================================================================================
   // TfAddFilesWizard
   //===================================================================================================================

  constructor TfAddFilesWizard.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    FAddList := TStringList.Create;
    FFileList  := TFileList.Create;
  end;

  destructor TfAddFilesWizard.Destroy;
  begin
    FAddList.Free;
    FFileList.Free;
    inherited Destroy;
  end;

  procedure TfAddFilesWizard.dpPreviewResize(Sender: TObject);
  begin
     // ��������� ������� ���������������� �����������
    UpdatePreviewScale;
  end;

  procedure TfAddFilesWizard.dpPreviewVisibleChanged(Sender: TObject);
  var PreviewInfoIntf: IPhoaWizardPage_PreviewInfo;
  begin
    if FUpdatingPreviewVisibility then Exit;
    if not dpPreview.Visible then FShowPreview := False;
    if Supports(Controller.VisiblePage, IPhoaWizardPage_PreviewInfo, PreviewInfoIntf) then
      PreviewInfoIntf.PreviewVisibilityChanged(FShowPreview);
  end;

  procedure TfAddFilesWizard.FinalizeWizard;
  begin
    FLog.Free;
     // ���� ���� ����������� �����������, ��������� ��������
    if (FPics<>nil) and (FPics.Count>0) then FApp.PerformOperation('PicAdd', ['Group', FGroup, 'Pics', FPics]);
    inherited FinalizeWizard;
  end;

  procedure TfAddFilesWizard.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  begin
     // ������ ��������� ������, ���� ����������� �����
    CanClose := not FProcessingFiles;
  end;

  function TfAddFilesWizard.GetFormRegistrySection: String;
  begin
    Result := SRegAddFiles_Root;
  end;

  function TfAddFilesWizard.GetNextPageID: Integer;
  begin
    case CurPageID of
       // ���� ���� ���������� �������� ������� ������ - ��������� � �������� ������� ������
      IWzAddFilesPageID_SelFiles:   Result := iif(SettingValueBool(ISettingID_Dlgs_APW_SkipChkPage), IWzAddFilesPageID_Processing, IWzAddFilesPageID_CheckFiles);
      IWzAddFilesPageID_CheckFiles: Result := IWzAddFilesPageID_Processing;
      IWzAddFilesPageID_Processing: Result := IWzAddFilesPageID_Log;
      else                          Result := 0;
    end;
  end;

  procedure TfAddFilesWizard.InitializeWizard;
  var iPageID: Integer;
  begin
    inherited InitializeWizard;
    FPics       := NewPhotoAlbumPicList(False);
    FFreePicID  := FApp.Project.PicsX.MaxPicID+1;
     // ����������� ���� ���������
    dpPreview.Floating := True;
     // ������ ��������
    Controller.CreatePage(TfrWzPageAddFiles_SelFiles,   IWzAddFilesPageID_SelFiles,   IDH_intf_pic_add_selfiles,   ConstVal('SWzPageAddFiles_SelFiles'));
    Controller.CreatePage(TfrWzPageAddFiles_CheckFiles, IWzAddFilesPageID_CheckFiles, IDH_intf_pic_add_checkfiles, ConstVal('SWzPageAddFiles_CheckFiles'));
    Controller.CreatePage(TfrWzPage_Processing,         IWzAddFilesPageID_Processing, IDH_intf_pic_add_process,    ConstVal('SWzPageAddFiles_Processing'));
    Controller.CreatePage(TfrWzPage_Log,                IWzAddFilesPageID_Log,        IDH_intf_pic_add_log,        ConstVal('SWzPageAddFiles_Log'));
     // ���� ���������� ������ ������ �� ����, ���������� �������� ������ ������
    if FFileList.Count>0 then
      iPageID := iif(SettingValueBool(ISettingID_Dlgs_APW_SkipChkPage), IWzAddFilesPageID_Processing, IWzAddFilesPageID_CheckFiles)
      // ����� ���������� �������� ������ ������
    else
      iPageID := IWzAddFilesPageID_SelFiles;
    Controller.SetVisiblePageID(iPageID, pcmForced);
  end;

  procedure TfAddFilesWizard.InterruptFileProcessing;
  begin
    FFileProcessingInterrupted := True;
  end;

  function TfAddFilesWizard.IsBtnBackEnabled: Boolean;
  begin
     // �� �������� ��������� �������� ���, �� �������� ������ ��������� ����� ������ ���� ��� ���� �����
    Result :=
      inherited IsBtnBackEnabled and
      (CurPageID<>IWzAddFilesPageID_Processing) and
      ((CurPageID<>IWzAddFilesPageID_Log) or (FFileList.Count>0));
  end;

  function TfAddFilesWizard.IsBtnCancelEnabled: Boolean;
  begin
    Result := inherited IsBtnCancelEnabled and ((CurPageID<>IWzAddFilesPageID_Processing) or not FProcessingFiles);
  end;

  function TfAddFilesWizard.IsBtnNextEnabled: Boolean;
  begin
    Result := inherited IsBtnNextEnabled;
    if Result then
      case CurPageID of
         // �� �������� ��������� ������ ����� ���� ������ ��� ������������� �������� � ������� ������� ���������
        IWzAddFilesPageID_Processing: Result := not FProcessingFiles and (FLog<>nil);
      end;
  end;

  function TfAddFilesWizard.LoadFileList(bRecurse, bUseFilter: Boolean): Boolean;
  var Masks: TPhoaMasks;

     // ��������� ���� � ������ �� ��� SearchRec. ���� bUseFilter=True, �������������� ��������� ��� ������������ �������
    procedure AddFile(const sPath: String; SRec: TSearchRec); overload;
    var
      d: TDateTime;
      bMatches: Boolean;
    begin
       // ���������, ��� ���������� ��������� ����
      if FileFormatList.GraphicFromExtension(ExtractFileExt(SRec.Name))=nil then Exit;
      d := FileDateToDateTime(SRec.Time);
       // ���� ������ ��������
      if not bUseFilter or not FShowAdvancedOptions then
        bMatches := True
      else begin
         // ��������� ���� ��������� �����
        bMatches :=
          ((FFilter_DateFrom<0) or (Int(d) >=FFilter_DateFrom)) and
          ((FFilter_DateTo<0)   or (Int(d) <=FFilter_DateTo))   and
          ((FFilter_TimeFrom<0) or (Frac(d)>=FFilter_TimeFrom)) and
          ((FFilter_TimeTo<0)   or (Frac(d)<=FFilter_TimeTo));
         // ��������� ������������ �����
        if bMatches then bMatches := Masks.Matches(SRec.Name);
         // ��������� ����������� � �����������
        if bMatches and (FFilter_Presence<>afpfDontCare) then
          bMatches := (FApp.Project.Pics.IndexOfFileName(sPath+SRec.Name)>=0) = (FFilter_Presence=afpfExistingOnly);
      end;
       // ���� ��� �������� �������������
      if bMatches then FFileList.Add(SRec.Name, sPath, SRec.Size, -2, d);
    end;

    procedure AddFolder(const sPath: String);
    var
      sr: TSearchRec;
      iRes: Integer;
    begin
       // ��������� ���������� � ��������
      pProcess.Caption := ConstVal('SMsg_ProcessingSomething', [sPath]);
      pProcess.Update;
       // ��������� �������
      iRes := FindFirst(sPath+'*.*', faAnyFile, sr);
      try
        while iRes=0 do begin
          if sr.Name[1]<>'.' then
             // ���� ������� - ���������� ���������
            if sr.Attr and faDirectory<>0 then begin
              if bRecurse then AddFolder(sPath+sr.Name+'\');
             // ���� ���� - ��������� � ������
            end else
              AddFile(sPath, sr);
          iRes := FindNext(sr);
        end;
      finally
        FindClose(sr);
      end;
    end;

     // ��������� � FFileList �����/����� �� FAddList
    procedure ProcessAddList;
    var
      i, iRes: Integer;
      sName: String;
      sr: TSearchRec;
    begin
       // ������� ������������ ������ ������
      FFileList.Clear;
       // ������������ ������ ��������� ������/�����
      for i := 0 to FAddList.Count-1 do begin
        sName := FAddList[i];
        iRes := FindFirst(sName, faAnyFile, sr);
        try
          if iRes=0 then
             // ����
            if sr.Attr and faDirectory=0 then
              AddFile(ExtractFilePath(sName), sr)
             // �������
            else
              AddFolder(IncludeTrailingPathDelimiter(sName));
        finally
          FindClose(sr);
        end;
      end;
    end;

  begin
     // ���������� ������ ��������
    StartWait;
    pProcess.Show;
    try
       // ���� �����, ������ ������ �����
      if FShowAdvancedOptions and (FFilter_Masks<>'') then Masks := TPhoaMasks.Create(FFilter_Masks) else Masks := nil;
      try
         // ������������ �����/�����
        ProcessAddList;
      finally
        Masks.Free;
      end;
     // �������� ������ ��������
    finally
      pProcess.Hide;
      StopWait;
    end;
    Result := FFileList.Count>0;
    if not Result then PhoaInfo(False, 'SNoFilesSelected');
  end;

  procedure TfAddFilesWizard.LogFailure(const s: String; const aParams: array of const);
  begin
    FLog.Add('[!] '+ConstVal(s, aParams));
  end;

  function TfAddFilesWizard.LogPage_GetLog(iPageID: Integer): TStrings;
  begin
    Result := FLog;
  end;

  procedure TfAddFilesWizard.LogSuccess(const s: String; const aParams: array of const);
  begin
    FLog.Add('[+] '+ConstVal(s, aParams));
  end;

  procedure TfAddFilesWizard.PageChanged(ChangeMethod: TPageChangeMethod; iPrevPageID: Integer);
  begin
    inherited PageChanged(ChangeMethod, iPrevPageID);
     // ��������� ���� ���������
    UpdatePreviewVisibility;
     // �� �������� ��������� ��������� ��������� ������
    if (ChangeMethod in [pcmNextBtn, pcmForced]) and (CurPageID=IWzAddFilesPageID_Processing) then StartFileProcessing;
  end;

  function TfAddFilesWizard.PageChanging(ChangeMethod: TPageChangeMethod; var iNewPageID: Integer): Boolean;
  begin
    Result := inherited PageChanging(ChangeMethod, iNewPageID);
     // ����� �������� ������ ������/����� ��������� ������ ������
    if Result and (ChangeMethod=pcmNextBtn) and (CurPageID=IWzAddFilesPageID_SelFiles) then
      Result := LoadFileList(FRecurseFolders, True);
  end;

  function TfAddFilesWizard.ProcPage_GetCurrentStatus: String;
  begin
     // ���� ������� �������, ���������� ��������
    if FProcessingFiles then
      Result := ConstVal('SWzAddFiles_Processing', [ProcPage_GetProgressCur+1, FInitialFileCount, FCountFailed, FFileList.Files[0]])
     // ����� ����� ���������� � ����������� �����������
    else
      Result := ConstVal('SWzAddFiles_Paused', [FPics.Count, FCountFailed]);
  end;

  function TfAddFilesWizard.ProcPage_GetProcessingActive: Boolean;
  begin
    Result := FProcessingFiles;
  end;

  function TfAddFilesWizard.ProcPage_GetProgressCur: Integer;
  begin
    Result := FInitialFileCount-FFileList.Count;
  end;

  function TfAddFilesWizard.ProcPage_GetProgressMax: Integer;
  begin
    Result := FInitialFileCount;
  end;

  procedure TfAddFilesWizard.ProcPage_PaintThumbnail(Bitmap32: TBitmap32);
  begin
    if FLastProcessedPic<>nil then PaintThumbnail(FLastProcessedPic, Bitmap32);
  end;

  procedure TfAddFilesWizard.SetShowPreview(Value: Boolean);
  begin
    if FShowPreview<>Value then begin
      FShowPreview := Value;
      UpdatePreviewVisibility;
    end;
  end;

  procedure TfAddFilesWizard.SettingsRestore(rif: TRegIniFile);
  begin
    inherited SettingsRestore(rif);
    FDefaultPath             := rif.ReadString ('', 'DefaultFolder',       '');
    FRecurseFolders          := rif.ReadBool   ('', 'RecurseFolders',      True);
    FShowAdvancedOptions     := rif.ReadBool   ('', 'ShowAdvancedOptions', False);
    FFilter_Presence         := TAddFilePresenceFilter(
                                rif.ReadInteger('', 'FilterPresence',      0));
    FFilter_Masks            := rif.ReadString ('', 'FilterMasks',         '*.*');
    FFilter_DateFrom         := rif.ReadInteger('', 'FilterDateFrom',      -1);
    FFilter_DateTo           := rif.ReadInteger('', 'FilterDateTo',        -1);
    FFilter_TimeFrom         := StrToTimeDef(
                                rif.ReadString ('', 'FilterTimeFrom',      ''), -1, AppFormatSettings);
    FFilter_TimeTo           := StrToTimeDef(
                                rif.ReadString ('', 'FilterTimeTo',        ''), -1, AppFormatSettings);
    FShowPreview             := rif.ReadBool   ('', 'ShowPreview',         False);
    dpPreview.FloatingPosition := Point(
                                rif.ReadInteger('', 'PreviewLeft',         Left+100),
                                rif.ReadInteger('', 'PreviewTop',          Top+100));
    dpPreview.FloatingWidth  := rif.ReadInteger('', 'PreviewWidth',        150);
    dpPreview.FloatingHeight := rif.ReadInteger('', 'PreviewHeight',       200);
  end;

  procedure TfAddFilesWizard.SettingsStore(rif: TRegIniFile);

    procedure PutDate(const d: TDateTime; const sValueName: String);
    begin
      if d>0 then rif.WriteInteger('', sValueName, Trunc(d)) else rif.DeleteValue(sValueName);
    end;

    procedure PutTime(const t: TDateTime; const sValueName: String);
    begin
      if t>=0 then rif.WriteString('', sValueName, FormatDateTime('hh:nn', t)) else rif.DeleteValue(sValueName);
    end;

  begin
    inherited SettingsStore(rif);
    rif.WriteString ('', 'DefaultFolder',       FDefaultPath);
    rif.WriteBool   ('', 'RecurseFolders',      FRecurseFolders);
    rif.WriteBool   ('', 'ShowAdvancedOptions', FShowAdvancedOptions);
    rif.WriteInteger('', 'FilterPresence',      Byte(FFilter_Presence));
    rif.WriteString ('', 'FilterMasks',         FFilter_Masks);
    PutDate(FFilter_DateFrom, 'FilterDateFrom');
    PutDate(FFilter_DateTo,   'FilterDateTo');
    PutTime(FFilter_TimeFrom, 'FilterTimeFrom');
    PutTime(FFilter_TimeTo,   'FilterTimeTo');
    rif.WriteBool   ('', 'ShowPreview',         FShowPreview);   
    rif.WriteInteger('', 'PreviewLeft',         dpPreview.FloatingPosition.x);
    rif.WriteInteger('', 'PreviewTop',          dpPreview.FloatingPosition.y);
    rif.WriteInteger('', 'PreviewWidth',        dpPreview.FloatingWidth);
    rif.WriteInteger('', 'PreviewHeight',       dpPreview.FloatingHeight);
  end;

  procedure TfAddFilesWizard.StartFileProcessing;
  begin
    FProcessingFiles := True;
     // ������ ��������
    if FLog=nil then FLog := TStringList.Create;
     // ������� ������������ �����
    FFileList.DeleteUnchecked;
     // ���������� �������� ���������� ������
    FInitialFileCount := FFileList.Count;
    FLastProcessedPic := nil;
     // ��������� �������� ���������
    UpdateProgressInfo;
     // ��������� �����
    FFileProcessingInterrupted := False;
    FAddFilesThread := TAddFilesThread.Create(Self);
  end;

  procedure TfAddFilesWizard.ThreadFileProcessed;
  var iPicID: Integer;
  begin
     // ���������, ��� ��������� ����������. ������ - ��� ����� ��� ��������
    if FAddFilesThread.AddedPic=nil then
      Inc(FCountFailed)
    else begin
       // ���� ����� ����������� - ������������ ����� ID
      iPicID := FAddFilesThread.AddedPic.ID;
      if iPicID=0 then begin
        iPicID := FFreePicID;
        Inc(FFreePicID);
      end;
      FAddFilesThread.AddedPic.PutToList(FPics, iPicID);
       // ��������� ������ �������
      HasUpdates := True;
    end;
     // ������� ������������ ����
    FFileList.Delete(0);
    FLastProcessedPic := FAddFilesThread.AddedPic;
     // ���� ��������� ���� ������, ��������� �����
    if (FFileList.Count=0) or FFileProcessingInterrupted then begin
      FProcessingFiles := False;
      FAddFilesThread.Terminate;
      FAddFilesThread := nil;
      FLastProcessedPic := nil;
       // ���� ������ ����, ��������� ����� �������/���������� ��������
      if FFileList.Count=0 then
        if (FCountFailed=0) and SettingValueBool(ISettingID_Dlgs_APW_LogOnErrOnly) then
          ModalResult := mrOK
        else
          Controller.SetVisiblePageID(IWzAddFilesPageID_Log, pcmNextBtn);
    end;
     // ���������� �������� ���������
    UpdateProgressInfo;
  end;

  procedure TfAddFilesWizard.UpdatePreview;
  var
    bLoaded: Boolean;
    sFile: String;
    PreviewInfoIntf: IPhoaWizardPage_PreviewInfo;
  begin
    bLoaded := False;
     // ���� ���� ��������� ������������, �������� ���������� ��������� ���������� ��� ��������� � ��� �������� �����
    if dpPreview.Visible and Supports(Controller.VisiblePage, IPhoaWizardPage_PreviewInfo, PreviewInfoIntf) then begin
      sFile := PreviewInfoIntf.CurrentFileName;
       // ���� ���� �����, ��������� �����������
      if sFile<>'' then
        try
          LoadGraphicFromFile(sFile, iPreview.Bitmap, iPreview.Width, iPreview.Height, nil);
          bLoaded := True;
        except
        end;
    end;
     // ���� ��������� ����������� �� ���� ���������, ������� Bitmap
    if not bLoaded then iPreview.Bitmap := nil;
     // ��������� �������
    if dpPreview.Visible then UpdatePreviewScale;
  end;

  procedure TfAddFilesWizard.UpdatePreviewScale;
  var sScale: Single;
  begin
    if iPreview.Bitmap.Empty then
      sScale := 1
    else
      sScale := MinS(1, MinS(iPreview.Width/iPreview.Bitmap.Width, iPreview.Height/iPreview.Bitmap.Height));
    iPreview.Scale := sScale;
  end;

  procedure TfAddFilesWizard.UpdatePreviewVisibility;
  begin
     // ���� ��������� ������ ��� ���������� ShowPreview �� ���������, �������������� ���������
     //   IPhoaWizardPage_PreviewInfo
    FUpdatingPreviewVisibility := True;
    try
      dpPreview.Visible := FShowPreview and Supports(Controller.VisiblePage, IPhoaWizardPage_PreviewInfo);
    finally
      FUpdatingPreviewVisibility := False;
    end;
     // ��������� ��� ������� �����������
    UpdatePreview;
  end;

  procedure TfAddFilesWizard.UpdateProgressInfo;
  begin
    Controller.ItemsByID[IWzAddFilesPageID_Processing].Perform(WM_PAGEUPDATE, 0, 0);
    UpdateButtons;
  end;

end.

