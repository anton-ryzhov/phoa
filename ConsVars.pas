//**********************************************************************************************************************
//  $Id: ConsVars.pas,v 1.5 2004-04-18 16:13:35 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit ConsVars;

interface
uses
   // GR32 must follow GraphicEx because of naming conflict between stretch filter constants
  SysUtils, Windows, Messages, Classes, Graphics, Controls, GraphicEx, VirtualTrees;

type
  EPhoaError = class(Exception);

  TPicProperty = (
    ppID, ppFileName, ppFullFileName, ppFilePath, ppFileSize, ppFileSizeBytes, ppPicWidth, ppPicHeight, ppPicDims,
    ppFormat, ppDate, ppTime, ppPlace, ppFilmNumber, ppFrameNumber, ppAuthor, ppDescription, ppNotes, ppMedia,
    ppKeywords);
  TPicProperties = set of TPicProperty;
const
  PPAllProps = [Low(TPicProperty)..High(TPicProperty)];

type
   // ���� ������ ������� �����������
  TPicPropertyDatatype = (ppdInteger, ppdString, ppdPixelFormat, ppdDate, ppdTime, ppdStrings);

   // �������� ��� ��������������� ���������� ����/������� �����������
  TDateTimeAutofillProp = (
    dtapExifDTOriginal,  // EXIF: Original date/time
    dtapExifDTDigitized, // EXIF: Digitized date/time
    dtapExifDateTime,    // EXIF: Date and time
    dtapFilename,        // Extract from filename
    dtapDTFileCreated,   // Date/time file created
    dtapDTFileModified); // Date/time file modified
  TDateTimeAutofillProps = set of TDateTimeAutofillProp;
const
  DTAP_DefaultDateProps: TDateTimeAutofillProps = [
    dtapExifDTOriginal, dtapExifDTDigitized, dtapExifDateTime, dtapFilename, dtapDTFileCreated, dtapDTFileModified];
  DTAP_DefaultTimeProps: TDateTimeAutofillProps = [
    dtapExifDTOriginal, dtapExifDTDigitized, dtapExifDateTime, dtapDTFileCreated, dtapDTFileModified];

type
   // ��������� ������� �������������� ����/������� �����������
  TDateTimeFillResult = (
    dtfrEmpty,     // �������� �������������
    dtfrSpecified, // �������� ���� ���������, � ��������� ��� ���������
    dtfrEXIF,      // ����� �� EXIF-����
    dtfrFilename,  // ����� �� ����� �����
    dtfrCreation,  // ����� �� ������� �������� �����
    dtfrModified); // ����� �� ������� ������ �����

   // ������������ �������� �����
  TDiskFileProp = (
    dfpFileName,            // ��� �����
    dfpFileType,            // ��� �����
    dfpSizeOfFile,          // ������
    dfpSizeOfFileDiskUsage, // ���������� ������ ������ �� �����
    dfpCreationTime,        // ����� ��������
    dfpLastWriteTime,       // ����� ������
    dfpLastAccessTime,      // ����� ���������� �������
    dfpReadOnlyFile,        // ������� ����� ������-���-������
    dfpHidden,              // ������� �������� �����
    dfpArchive,             // �������� �������
    dfpCompressed,          // ������� ������ �����
    dfpSystemFile,          // ������� ���������� �����
    dfpTemporary);          // ������� ���������� �����

  TSortOrder = (soAsc, soDesc);

   // ��������, �� �������� ����������� ����������� ����������� � �������������
  TGroupByProperty = (
    gbpFilePath, gbpDateByYear, gbpDateByMonth, gbpDateByDay, gbpTimeHour, gbpTimeMinute, gbpPlace, gbpFilmNumber,
    gbpAuthor, gbpMedia, gbpKeywords);
  TGroupByProperties = set of TGroupByProperty;
const
   // ��������, �������������� �������� 2
  GBPropsRev2: TGroupByProperties = [
    gbpFilePath, gbpDateByYear, gbpDateByMonth, gbpDateByDay, gbpPlace, gbpFilmNumber, gbpKeywords];

type
   // ����� �������� ����������� �������
  TMassCheckMode = (mcmAll, mcmNone, mcmInvert);

   // ��������� �������� � ������������� (��������� ����� ����� ���� ������ | �������� � �������������)
  TPictureOperation = (
    popMoveToTarget,     // ����������� ���������� ����������� � ��������� ������
    popCopyToTarget,     // ���������� ���������� ����������� � ��������� ������
    popRemoveFromTarget, // ������� ���������� ����������� �� ��������� ������
    popIntersectTarget); // �������� ������ ���������� ����������� � ��������� ������

   // ����� ���������� ���������� �������� ������
  TUndoInvalidationFlag  = (
     // -- ����� �������� ��� ���������� (eXecution)
    uifXReinitParent,        // �������������������� �������� ���� ������ ��������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifXReinitSiblings,      // �������������������� �������� � ����� ������ �������� ���� ������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifXReinitRecursive,     // ��� ����������������� (����� uifXReinitParent � uifXReinitSiblings) ����������� ����������
    uifXEditGroup,           // ������ ���� ������ Op.GroupAbsIdx � ����� �������������� ��� ������. ������ ���� ��������� Op.GroupAbsIdx
    uifXInvalidateNode,      // ������� Invalidate ���� ������. ������ ���� ��������� Op.GroupAbsIdx
    uifXInvalidateTree,      // ������� Invalidate ���� �������� ������ �����
     // -- ����� �������� ��� ������ (Undoing)
    uifUReinitAll,           // �������������������� ��� ���� ������
    uifUReinitParent,        // �������������������� �������� ���� ������ ��������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifUReinitRecursive,     // ��� ����������������� (����� uifUReinitParent � uifUReinitSiblings) ����������� ����������
    uifUInvalidateNode,      // ������� Invalidate ���� ������. ������ ���� ��������� Op.GroupAbsIdx
    uifUInvalidateTree);     // ������� Invalidate ����� �������� ������ �����

  TUndoInvalidationFlags = set of TUndoInvalidationFlag;

  TIDArray = Array of Integer;

   // ����� �������� ������ ������ ��� ������ �����������
  TPicClipboardFormat = (
    pcfPhoa,          // ���������� ������ ������ ��������� (wClipbrdPicFormatID)
    pcfHDrop,         // ������ Shell-�������� (�.�. ������)
    pcfPlainList,     // ������� ��������� ������ ����� � ������
    pcfSingleBitmap); // Bitmap-����������� ������ (� ������ ������������� �����������)
  TPicClipboardFormats = set of TPicClipboardFormat;
const
  DefaultPicClipboardFormats: TPicClipboardFormats = [Low(TPicClipboardFormat)..High(TPicClipboardFormat)];

type
   // ��� ������� ����������� ������ � ����������� (��� ���������� �����������)
  TAddFilePresenceFilter = (
    afpfDontCare,      // ��������� ��������
    afpfNewOnly,       // ������ �����, ����� ��� �����������
    afpfExistingOnly); // ������ �����, �������������� � �����������

   //-------------------------------------------------------------------------------------------------------------------
   // �������� � �������
   //-------------------------------------------------------------------------------------------------------------------

   // ��� �������� � ������� �����������
  TFileOperationKind = (
    fokCopyFiles,        // ���������� ����� ����������� � ��������� �����
    fokMoveFiles,        // ����������� ����� ����������� � ��������� �����
    fokDeleteFiles,      // ������� ����� �����������
    fokRebuildThumbs,    // ����������� ������
    fokRepairFileLinks); // ������������ ����� � ������� �����������, ������������ � ��������� �����

   // ����� ������ ����������� ��� �������� � ������� �����������
  TFileOpSelPicMode = (
    fospmSelPics,    // ��������� �� ������ �����������
    fospmAll,        // ��� ����������� �����������/�������������
    fospmSelGroups); // ����������� �� ��������� �����

   // ����� ���������� ������ ��� �����������/����������� � �������������� �������� � ������� �����������
  TFileOpMoveFileArranging = (
    fomfaPutFlatly,            // �������� ��� ����� � ������������ ������� - ������� ����������
    fomfaMaintainFolderLayout, // ��������� ����� �� ���������, �������� �� �������� ������������ (������������ ��������� �����)
    fomfaMaintainGroupLayout); // ��������� ����� �� ���������, �������� ������������ ����� ����������� (������������ ��������� ������)

   // ��������� ��� ���������� ��������� ����� ��� ����������� � �������������� �������� � ������� �����������
  TFileOpMoveFileNoOriginalMode = (
    fomfnomFail,                 // ������� �������
    fomfnomRelinkIfTargetExists, // ��������� ������, ���� ���� ���������� ����������
    fomfnomRelinkAlways);        // ��������� ������ � ����� ������

   // ����� ���������� ������������ ������ ��� �����������/����������� � �������������� �������� � ������� �����������
  TFileOpMoveFileOverwriteMode = (
    fomfomNever,   // ������� �� ������������ (����������)
    fomfomPrompt,  // ���������� � ������������� ����������
    fomfomAlways); // ������ ������������

   // ����� ������ ������ ��� �������������� ������ �� ����� �����������
  TFileOpRepairMatchFlag = (
    formfName,  // ���������� �� ����� �����
    formfSize); // ���������� �� ������� �����
  TFileOpRepairMatchFlags = set of TFileOpRepairMatchFlag;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� ���������� ������� ��������
   //-------------------------------------------------------------------------------------------------------------------

   // ��������� �������������� ���������� � ��������� (��� ��������, ������������ ��������)
  IPhoaWizardPageHost_Log = interface(IInterface)
    ['{9FA1E911-FFF6-44E6-9A32-D7AB76D759B0}']
     // Prop handlers
    function  GetLog(iPageID: Integer): TStrings;
     // Props
     // -- ������ ����� ���������
    property Log[iPageID: Integer]: TStrings read GetLog;
  end;

   // ��������� �������������� ���������� � ��������� ��������� (��� ��������, ������������ ��������� ��������)
  IPhoaWizardPageHost_Process = interface(IInterface)
    ['{A064413E-80A3-41B0-B6B7-0FA8C9EB76E6}']
     // ������ ��������� ��������� 
    procedure StartProcessing;
     // ������ ��������� ��������� 
    procedure StopProcessing;
     // ������ �������� ����������� ��������������� ������
    procedure PaintThumbnail(Bitmap: TBitmap); 
     // Prop handlers
    function GetCurrentStatus: String;
    function GetProcessingActive: Boolean;
    function GetProgressCur: Integer;
    function GetProgressMax: Integer;
     // Props
     // -- ������� ��������� ��������� (���������)
    property CurrentStatus: String read GetCurrentStatus; 
     // -- True, ���� �������� � ������ ������ �������
    property ProcessingActive: Boolean read GetProcessingActive;
     // -- ������� ��������� ���������
    property ProgressCur: Integer read GetProgressCur;
     // -- ������������ (��������) ��������� ���������
    property ProgressMax: Integer read GetProgressMax;
  end;

  {=====================================================================================================================
    ������ ����� ����������� �� ������ 1.1.1a (Rev 0002-):

    . ������� "PhoA [PhotoAlbum] project file"
    . Int - FileRevision
    . Str - Description
    . Int - ThumbnailQuality
    . Int - ThumbnailWidth
    . Int - ThumbnailHeight
    . ������ (RootGroup)
      ( . Str - Text
        . Byte - Expanded
        . Int - Picture ID count=N
          ( . Int - Pic ID
          ) x N
        . ���������� ������ (Groups)
          ( . Int - Count=N
            . ������
              ( . ) x N
           )
      )
    . ����������� (Pics)
      ( . Int - Count=N
        . �����������
          ( . Int  - ID
            . Str  - ThumbnailData
            . Str  - FilmNumber
            . Int  - PicDate [$0002-]
            . Dbl  - PicDateTime [$0003+]
            . Int  - PicWidth [$0003+]
            . Int  - PicHeight [$0003+]
            . Str  - PicNotes [$0003+]
            . Str  - PicAuthor [$0003+]
            . Str  - PicMedia [$0003+]
            . Str  - PicDesc
            . Str  - PicFileName
            . Int  - PicFileSize
            . Byte - PicFormat
            . Str  - PicKeywords
            . Str  - PicNumber
            . Str  - PicPlace
            . Int  - ThumbWidth
            . Int  - ThumbHeight
          ) x N
      )
    . ������������� (Views) [$0002+]
      ( . Int - Count=N
        . �������������
          ( . Str - Name
            . ����������� (Groupings)
              ( . Int - Count=M
                . �����������
                  ( . Int - Grouping [typecasted to Integer]
                  ) x M
              )
            . ���������� (Sortings) [$0003+]
              ( . Int - Count=M
                . ����������
                  ( . Int - Sorting [typecasted to Integer]
                  ) x M
              )
          ) x N
      )
  =====================================================================================================================}

const
   // ������ ���������
  SAppVersion                     = 'v1.1.4 beta';
   // ���������� � ��� ����� ����������� �� ���������
  SDefaultExt                     = 'phoa';
  SDefaultFName                   = 'untitled.'+SDefaultExt;
   // ��� ini-����� ��� ����������/�������� ���������� �� ���������
  SDefaultIniFileExt              = 'ini';
  SDefaultIniFileName             = 'phoa.'+SDefaultIniFileExt;
   // ��� ������������ �����
  SPhoaExecutableFileName         = 'phoa.exe';

   // ������� ������
  S_CRLF                          = #13#10;

   // ������� � �������� ������ �� ���������
  IDefaultThumbWidth              = 150;
  IDefaultThumbHeight             = 150;
  IDefaultThumbQuality            = 40;

   // ������� ������ � ����� � ��������
  ILThumbMargin                   = 5;
  IRThumbMargin                   = 5;
  ITThumbMargin                   = 5;
  IBThumbMargin                   = 5;

   // ������������ �-�� ������� � ������� �����
  IMaxHistoryEntries              = 20;

   // ������� �������� ������������ ��������������� �����������. Typed constants to avoid rounding mismatches
  SMaxPicZoom: Single             = 8.0;
  SMinPicZoom: Single             = 0.1;

   // ��� ��������� ����������� ��������� �� ���������, � ��������
  IKeyScrollStep                  = 50;  // [Arrow Keys]
  IKeySlowScrollStep              = 5;   // [Shift]+[Arrow Keys]
  IKeyQuickScrollStep             = 200; // [Ctrl]+[Arrow Keys]

   // ����� ������� ��� ���������� ��������
  SRegRoot                        = 'Software\DaleTech\PhoA';
  SRegPrefs                       = 'Preferences';
  SRegToolbars                    = SRegRoot+'\Toolbars';
  SRegOpen_Root                   = 'Open';
  SRegOpen_FilesMRU               = SRegOpen_Root+'\FilesMRU';

  SRegDialogsRoot                 = 'Dialogs';

  SRegAddFiles_Root               = SRegDialogsRoot+'\AddFilesWizard';
    SRegAddFiles_MaskMRU          = SRegAddFiles_Root+'\FileMaskMRU';

  SRegPicProps_Root               = SRegDialogsRoot+'\PicPropsDialog';
    SRegPicProps_Toolbars         = SRegRoot+'\'+SRegPicProps_Root+'\Toolbars';

  SRegCopyToFolder_Root           = SRegDialogsRoot+'\CopyToFolder';

  SRegFileOps_Root                = SRegDialogsRoot+'\FileOpsWizard';

  SRegSearch_Root                 = SRegDialogsRoot+'\Search';
    SRegSearch_IDMRU              = SRegSearch_Root+'\IDMRU';
    SRegSearch_FMaskMRU           = SRegSearch_Root+'\FileMaskMRU';
    SRegSearch_FPathMRU           = SRegSearch_Root+'\FilePathMRU';
    SRegSearch_FSizeMRU           = SRegSearch_Root+'\FileSizeMRU';
    SRegSearch_PWidthMRU          = SRegSearch_Root+'\PicWidthMRU';
    SRegSearch_PHeightMRU         = SRegSearch_Root+'\PicHeightMRU';
    SRegSearch_FrNumberMRU        = SRegSearch_Root+'\FrameNumberMRU';
    SRegSearch_DescMRU            = SRegSearch_Root+'\DescMRU';
    SRegSearch_NotesMRU           = SRegSearch_Root+'\NotesMRU';

  SRegSort_Root                   = SRegDialogsRoot+'\Sort';
    SRegSort_LastSortings         = SRegSort_Root+'\LastSortings';

   // ������������ � ���� � ����� �������
  SInvalidPathChars               = '\/:*?"<>|';

   // ������ ��������
  crHand                          = 2100;
  crHandDrag                      = 2101;
  crDragMove                      = 2102;
  crDragCopy                      = 2103;

   // ��������� Drag'n'Drop ��� TThumbnailViewer
   // -- ���� ����� ������� ��� Drag'n'drop
  CInsertionPoint                 = clHighlight;
   // -- ���������� � �������� �� ������� ���� �� ���� ���������� �������, ��� ������� ���������� ��������� �����������
  IDragScrollAreaMargin           = 30;
   // -- �������� � ��, � ������� ������� �������������� ���� ������ �������
  IDragScrollDelay                = 400;

   // ����� ��������� ��������� ��������
  adMagnifications: Array[0..6] of Double = (1.10, 1.25, 1.33, 1.50, 1.75, 2, 3);
   // ������� ��� ��������� �����������
  aImgViewCursors: Array[Boolean] of TCursor = (crDefault, crHand);

   // ������������ �������� � �������������� ����� ��� �������������������� ����������� � ����������� �� ���� �����������
  asUnclassifiedConsts: Array[TGroupByProperty] of String[24] = (
    '',                         // gbpFilePath - ������ �� ������
    'SUnclassified_Date',       // gbpDateByYear
    'SUnclassified_Date',       // gbpDateByMonth
    'SUnclassified_Date',       // gbpDateByDay
    'SUnclassified_Time',       // gbpTimeHour
    'SUnclassified_Time',       // gbpTimeMinute
    'SUnclassified_Place',      // gbpPlace
    'SUnclassified_FilmNumber', // gbpFilmNumber
    'SUnclassified_Author',     // gbpAuthor
    'SUnclassified_Media',      // gbpMedia
    'SUnclassified_Keywords');  // gbpKeywords

   // Timer IDs
  ISlideShowTimerID               = $01010101;
  IPicPropsViewTimerID            = $01010101;

   // Image indices
  iiPhoA                          =  0;
  iiFolder                        =  1;
  iiNo                            =  2;
  iiSearch                        =  3;
  iiView                          =  4;
  iiGrouping                      =  5;
  iiSorting                       =  6;
  iiSortAsc                       =  7;
  iiSortDesc                      =  8;
  iiDelete                        =  9;
  iiUp                            = 10;
  iiDown                          = 11;
  iiOK                            = 12;
  iiError                         = 13;

   // ImageIndices (from ilActionsSmall)
  iiA_NewGroup                    =  5;
  iiA_Edit                        =  8;
  iiA_Props                       = 12;
  iiA_ViewMode                    = 15;
  iiA_View                        = 37;
  iiA_Keyword                     = 41;
  iiA_Asterisk                    = 43;
  iiA_Dialog                      = 46;

   // Help topics
  IDH_start                       = 00001;
  IDH_intf_album_props            = 00060;
  IDH_intf_browse_mode_menu       = 00070;
  IDH_intf_browse_mode_tasks      = 00080;
  IDH_intf_browse_mode_views      = 00090;
  IDH_intf_browse_mode            = 00100;
  IDH_intf_key_mouse_controls     = 00110;
  IDH_intf_major_modes            = 00120;
  IDH_intf_pic_add                = 00130;
  IDH_intf_pic_add_checkfiles     = 00131;
  IDH_intf_pic_add_log            = 00132;
  IDH_intf_pic_add_process        = 00133;
  IDH_intf_pic_add_selfiles       = 00134;
  IDH_intf_pic_operations         = 00140;
  IDH_intf_pic_props_data         = 00150;
  IDH_intf_pic_props_fprops       = 00160;
  IDH_intf_pic_props_groups       = 00170;
  IDH_intf_pic_props_keywords     = 00180;
  IDH_intf_pic_props_metadata     = 00190;
  IDH_intf_pic_props_view         = 00200;
  IDH_intf_pic_props              = 00210;
  IDH_intf_search                 = 00230;
  IDH_intf_sel_phoa_group         = 00240;
  IDH_intf_select_keywords        = 00250;
  IDH_intf_sort_pics              = 00260;
  IDH_intf_stats                  = 00270;
  IDH_intf_view_mode_tasks        = 00280;
  IDH_intf_view_mode              = 00290;
  IDH_intf_view_props             = 00300;
  IDH_intf_file_ops               = 00400;
  IDH_intf_file_ops_cdopts        = 00410;
  IDH_intf_file_ops_delopts       = 00420;
  IDH_intf_file_ops_log           = 00430;
  IDH_intf_file_ops_moveopts      = 00440;
  IDH_intf_file_ops_process       = 00450;
  IDH_intf_file_ops_repropts      = 00460;
  IDH_intf_file_ops_selfolder     = 00470;
  IDH_intf_file_ops_selpics       = 00480;
  IDH_intf_file_ops_seltask       = 00490;
  IDH_intf_file_ops_task_copy     = 00600;
  IDH_intf_file_ops_task_del      = 00610;
  IDH_intf_file_ops_task_move     = 00620;
  IDH_intf_file_ops_task_repfl    = 00630;
  IDH_intf_file_ops_task_rthumb   = 00640;
  IDH_setup                       = 00700;
  IDH_setup_dialogs               = 00710;
  IDH_setup_general               = 00720;
  IDH_setup_view_mode             = 00730;
  IDH_setup_browse_mode           = 00740;
  IDH_advantages                  = 01010;
  IDH_eula_eng                    = 01020;
  IDH_eula_rus                    = 01030;
  IDH_file_formats                = 01040;
  IDH_how_it_works                = 01050;
  IDH_intro                       = 01060;
  IDH_major_modes                 = 01070;
  IDH_pic_data                    = 01080;
  IDH_pic_prop_autofill           = 01090;
  IDH_requirements                = 01100;
  IDH_rev_history                 = 01110;
  IDH_theory_metadata             = 01120;
  IDH_theory_resampling           = 01130;
  IDH_thumbnails                  = 01140;

   // ID ������� ������� ���������� ������
  IWzAddFilesPageID_SelFiles      = 1;
  IWzAddFilesPageID_CheckFiles    = 2;
  IWzAddFilesPageID_Processing    = 3;
  IWzAddFilesPageID_Log           = 4;

   // ID ������� ������� �������� � ������� �����������
  IWzFileOpsPageID_SelTask        = 1;
  IWzFileOpsPageID_SelPics        = 2;
  IWzFileOpsPageID_SelFolder      = 3;
  IWzFileOpsPageID_MoveOptions    = 4;
  IWzFileOpsPageID_MoveOptions2   = 5;
  IWzFileOpsPageID_CDOptions      = 6;
  IWzFileOpsPageID_DelOptions     = 7;
  IWzFileOpsPageID_RepairOptions  = 8;
  IWzFileOpsPageID_RepairSelLinks = 9;
  IWzFileOpsPageID_Processing     = 10;
  IWzFileOpsPageID_Log            = 11;

   // ID ������� ������� ������� ������
  IDlgPicPropsPageID_FileProps    = 1;
  IDlgPicPropsPageID_Metadata     = 2;
  IDlgPicPropsPageID_View         = 3;
  IDlgPicPropsPageID_Data         = 4;
  IDlgPicPropsPageID_Keywords     = 5;
  IDlgPicPropsPageID_Groups       = 6;

   // ID ������� ���������
   //===================================================================================================================
  ISettingID_Gen                       = 0;    // �����
  ISettingID_Gen_Intf                  = 0;    // ���������
    ISettingID_Gen_Language            = 0001; // ���� ����������
    ISettingID_Gen_MainFont            = 0002; // ����� ���������
    ISettingID_Gen_TooltipDisplTime    = 0010; // ����������������� ����������� ����������� ���������, ��
    ISettingID_Gen_OpenMRUCount        = 0011; // ����� ������ ��������� �������� ������
    ISettingID_Gen_LookupPhoaIni       = 0012; // ��������� �� ��������� �� phoa.ini � �������� �������
  ISettingID_Gen_Clipboard             = 0;    // ����� ������
    ISettingID_Gen_ClipFormats         = 0030; // �������, ���������� � ����� ������ ��� �����������
  ISettingID_Gen_Toolbars              = 0;    // ������ ������������
    ISettingID_Gen_ToolbarBtnSize      = 0100; // ������ ������ �������� ������
    ISettingID_Gen_ToolbarBSz16        = 0;    // ������ (16x16)
    ISettingID_Gen_ToolbarBSz24        = 0;    // ������� (24x24)
    ISettingID_Gen_ToolbarBSz32        = 0;    // ������� (32x32)
    ISettingID_Gen_ToolbarDragStyle    = 0110; // �������������� �������
    ISettingID_Gen_ToolbarDrgNone      = 0;    // ���������
    ISettingID_Gen_ToolbarDrgOneDock   = 0;    // ������ ������ ����
    ISettingID_Gen_ToolbarDrgNoFloat   = 0;    // ������ ���� ��� ����� ������
    ISettingID_Gen_ToolbarDrgFree      = 0;    // � ����� � ��� �����
  ISettingID_Gen_Tree                  = 0;    // �������/������
    ISettingID_Gen_TreeAnimation       = 0201; // �������� ������������/��������������
    ISettingID_Gen_TreeWhPanning       = 0202; // ��������������� �������� ������� ������ ����
    ISettingID_Gen_TreeCenterSel       = 0203; // ������������� ���������
    ISettingID_Gen_TreeIncrSearch      = 0204; // ����� ��� ������ ������
    ISettingID_Gen_TreeIncrSrchDelay   = 0205; // �������� ��� ������ ��� ������
    ISettingID_Gen_TreeButtonStyle     = 0206; // ��� ������ ������������/��������������
    ISettingID_Gen_TreeBS_Rectangle    = 0207; // �����������
    ISettingID_Gen_TreeBS_Triangle     = 0208; // ������������
    ISettingID_Gen_TreeCheckStyle      = 0209; // ��� �������������� � ����� (�� ��-XP-��������)
    ISettingID_Gen_TreeSelStyle        = 0220; // ��� ����� ���������
    ISettingID_Gen_TreeSelDotted       = 0;    // �������
    ISettingID_Gen_TreeSelBlended      = 0;    // ��������� �������������
   //===================================================================================================================
  ISettingID_Browse                    = 0;    // ����� ������
  ISettingID_Browse_Viewer             = 0;    // Viewer
    ISettingID_Browse_ViewerBkColor    = 1000; // Viewer: ���� ����
    ISettingID_Browse_ViewerThBColor   = 1001; // Viewer: ���� ���� ������
    ISettingID_Browse_ViewerThFColor   = 1002; // Viewer: ���� ������ ������
    ISettingID_Browse_ViewerDragDrop   = 1003; // Viewer: Drag'n'Drop
    ISettingID_Browse_ViewerTooltips   = 1004; // Viewer: ���������� ����������� �������� �������
    ISettingID_Browse_ViewerTipProps   = 1005; // Viewer: ���������� �� ����������� ���������
    ISettingID_Browse_ViewerThInfo     = 1010; // Viewer: ������, ������������ �� �������
    ISettingID_Browse_ViewerThLTProp   = 1011; // Viewer: Left top corner
    ISettingID_Browse_ViewerThRTProp   = 1012; // Viewer: Right top corner
    ISettingID_Browse_ViewerThLBProp   = 1013; // Viewer: Left bottom corner
    ISettingID_Browse_ViewerThRBProp   = 1014; // Viewer: Right bottom corner
    ISettingID_Browse_ViewerThBorder   = 1020; // Viewer: ׸���� ������� ������
    ISettingID_Browse_ViewerCacheThs   = 1030; // Viewer: ���������� ������ ��� ���������
    ISettingID_Browse_ViewerCacheSze   = 1031; // Viewer: ������ ���� �������
    ISettingID_Browse_ViewerStchFilt   = 1040; // Viewer: ����� ����������� �������
    ISettingID_Browse_MaxUndoCount     = 1050; // ����. ���������� �������� � ������ ������
   //===================================================================================================================
  ISettingID_View                      = 0;    // ����� ���������
  ISettingID_View_AlwaysOnTop          = 2000; // ���� ��������� ������ ���� ����
  ISettingID_View_Fullscreen           = 2001; // ������������� �����
  ISettingID_View_KeepCursorOverTB     = 2002; // ������������������� ������ ��� ������� ������������ 
  ISettingID_View_HideCursor           = 2003; // �������� ��������� ���� � ������������� ������
  ISettingID_View_BkColor              = 2004; // ���� ���� ���� ���������
  ISettingID_View_ShowToolbar          = 2005; // ���������� ������ ������������
  ISettingID_View_PicChange            = 0;    // ����� �����������
    ISettingID_View_FitWindowToPic     = 2010; // ��������� ������ ���� ��� ������ �����������
    ISettingID_View_CenterWindow       = 2011; // ������������ ���� �� ������� �����
    ISettingID_View_ShrinkPicToFit     = 2012; // ������� ����������� �� ������� ����
    ISettingID_View_ZoomPicToFit       = 2013; // ����������� ����������� �� ������� ����
    ISettingID_View_Cyclic             = 2014; // ����������� ��������
    ISettingID_View_Optimizing         = 0;    // ����������� ��������
      ISettingID_View_Predecode        = 2020; // ��������������� ��������� �����������
      ISettingID_View_CacheBehind      = 2021; // ���������� ���������� �����������
  ISettingID_View_ZoomFactor           = 2030; // ��� ��������� ��������
  ISettingID_View_CaptionProps         = 2031; // ���������� � ��������� ����
  ISettingID_View_StchFilt             = 2032; // ����� ����������� �����������
  ISettingID_View_Info                 = 0;    // ������������ ����������
    ISettingID_View_ShowInfo           = 2040; // ���������� �� ����������
    ISettingID_View_InfoPicProps       = 2041; // Info: ������������ ����������
    ISettingID_View_InfoFont           = 2042; // Info: �����
    ISettingID_View_InfoBkColor        = 2043; // Info: ���� ����
    ISettingID_View_InfoBkOpacity      = 2044; // Info: �������������� ���� (0-255)
  ISettingID_View_Slideshow            = 0;    // �������� �������
    ISettingID_View_SlideInterval      = 2050; // Slideshow: �������� ������, ��
    ISettingID_View_SlideCyclic        = 2051; // Slideshow: ����������� ��������
   //===================================================================================================================
  ISettingID_Dialogs                   = 0;    // �������
  ISettingID_Dlgs_Confms               = 0;    // �������������
    ISettingID_Dlgs_ConfmDelGroup      = 3010; // �������������: ����� ��������� ������
    ISettingID_Dlgs_ConfmDelPics       = 3011; // �������������: ����� ��������� �����������
    ISettingID_Dlgs_ConfmDelView       = 3012; // �������������: ����� ��������� �������������
    ISettingID_Dlgs_ConfmOldFile       = 3013; // �������������: ����� ����������� ����� ���������� ������
    ISettingID_Dlgs_ConfmAppExit       = 3014; // �������������: ����� ������� (��� ���������� �����������)
  ISettingID_Dlgs_Notifies             = 0;    // �����������
    ISettingID_Dlgs_NotifyDragCopy     = 3030; // �����������: ����� ����������� ����������� ����� Drag'n'Drop
    ISettingID_Dlgs_NotifyDragMove     = 3031; // �����������: ����� ����������� ����������� ����� Drag'n'Drop
    ISettingID_Dlgs_NotifyPaste        = 3032; // �����������: ����� ������� ����������� �� ������ ������
  ISettingID_Dlgs_AddPicWizard         = 0;    // ������ ���������� �����������
    ISettingID_Dlgs_APW_ShowHidden     = 3050; // ���������� ������� ����� � �����
    ISettingID_Dlgs_APW_SkipChkPage    = 3051; // ���������� �������� ������� ������
    ISettingID_Dlgs_APW_LogOnErrOnly   = 3052; // ���������� �������� ������ ��� ������� ������
    ISettingID_Dlgs_APW_AutofillDate   = 3053; // ������������� ��������� ���� ����������� �� �������:
    ISettingID_Dlgs_APW_ReplaceDate    = 3054; // ������������ ����, ���� ��� ��� �������
    ISettingID_Dlgs_APW_AutofillTime   = 3055; // ������������� ��������� ����� ����������� �� �������:
    ISettingID_Dlgs_APW_ReplaceTime    = 3056; // ������������ �����, ���� ��� ��� �������
  ISettingID_Dlgs_PicProps             = 0;    // ���� ������� �����������
    ISettingID_Dlgs_PP_ExpFileProps    = 3101; // ����� ���������� �������� ������
    ISettingID_Dlgs_PP_ExpMetadata     = 3102; // ����� ���������� ���������� �����������
  ISettingID_Dlgs_FileOpsWizard        = 0;    // ������ �������� � ������� �����������
    ISettingID_Dlgs_FOW_CfmCopyFiles   = 3120; // ������������� ��� �������� ����������� ������
    ISettingID_Dlgs_FOW_CfmMoveFiles   = 3121; // ������������� ��� �������� ����������� ������
    ISettingID_Dlgs_FOW_CfmDelFiles    = 3122; // ������������� ��� �������� �������� ������
    ISettingID_Dlgs_FOW_CfmRebuildTh   = 3123; // ������������� ��� �������� ����������� �������
    ISettingID_Dlgs_FOW_CfmRepairFLs   = 3124; // ������������� ��� �������� �������������� ������ �� �����
    ISettingID_Dlgs_FOW_LogOnErrOnly   = 3130; // ���������� �������� ������ ��� ������� ������

   // ������������ ����� ���������� � ������� ����������� � ������� �� �� �������������
  aFileOpConfirmSettingIDs: Array[TFileOperationKind] of Integer = (
    ISettingID_Dlgs_FOW_CfmCopyFiles,
    ISettingID_Dlgs_FOW_CfmMoveFiles,
    ISettingID_Dlgs_FOW_CfmDelFiles,
    ISettingID_Dlgs_FOW_CfmRebuildTh,
    ISettingID_Dlgs_FOW_CfmRepairFLs);

   // ��������� � ������������� �������� ������ ��������
  WM_PAGEUPDATE                 = WM_USER+$1100;

   // PhoA picture clipboard format name
  SClipbrdPicFormatName         = 'PHOA_INT_PICTURE_BUCKET';

const
  aCheckStates: Array[Boolean] of TCheckState = (csUncheckedNormal, csCheckedNormal);

   // ������� �������������
   // TPicProperty <-> Chunked sorting prop
  aXlat_PicPropertyToChunkSortingProp: Array[TPicProperty] of Word = (
     0,  // ppID
     1,  // ppFileName
     2,  // ppFullFileName
     3,  // ppFilePath
     4,  // ppFileSize
     5,  // ppFileSizeBytes
     6,  // ppPicWidth
     7,  // ppPicHeight
     8,  // ppPicDims
     9,  // ppFormat
    10,  // ppDate
    11,  // ppTime
    12,  // ppPlace
    13,  // ppFilmNumber
    14,  // ppFrameNumber
    15,  // ppAuthor
    16,  // ppDescription
    17,  // ppNotes
    18,  // ppMedia
    19); // ppKeywords
  aXlat_ChunkSortingPropToPicProperty: Array[0..19] of TPicProperty = (
    ppID,            //  0  ID
    ppFileName,      //  1  Picture filename
    ppFullFileName,  //  2  Picture filename with path
    ppFilePath,      //  3  Picture file path
    ppFileSize,      //  4  Picture file size
    ppFileSizeBytes, //  5  Picture file size in bytes
    ppPicWidth,      //  6  Image width
    ppPicHeight,     //  7  Image height
    ppPicDims,       //  8  Image dimensions
    ppFormat,        //  9  Pixel format
    ppDate,          // 10  Date
    ppTime,          // 11  Time
    ppPlace,         // 12  Place
    ppFilmNumber,    // 13  Film number
    ppFrameNumber,   // 14  Frame number
    ppAuthor,        // 15  Author
    ppDescription,   // 16  Description
    ppNotes,         // 17  Notes
    ppMedia,         // 18  Media
    ppKeywords);     // 19  Keywords (keywords are alw

   // TGroupByProperty <-> Chunked sorting prop
  aXlat_GBPropertyToChunkGroupingProp: Array[TGroupByProperty] of Word = (
     0,  // gbpFilePath
     1,  // gbpDateByYear
     2,  // gbpDateByMonth
     3,  // gbpDateByDay
     4,  // gbpTimeHour
     5,  // gbpTimeMinute
     6,  // gbpPlace
     7,  // gbpFilmNumber
     8,  // gbpAuthor
     9,  // gbpMedia
    10); // gbpKeywords
  aXlat_ChunkGroupingPropToGBProperty: Array[0..10] of TGroupByProperty = (
   gbpFilePath,    //  0  Picture file path
   gbpDateByYear,  //  1  Date year
   gbpDateByMonth, //  2  Date month
   gbpDateByDay,   //  3  Date day
   gbpTimeHour,    //  4  Time hour
   gbpTimeMinute,  //  5  Time minute
   gbpPlace,       //  6  Place
   gbpFilmNumber,  //  7  Film number
   gbpAuthor,      //  8  Author
   gbpMedia,       //  9  Media name/code
   gbpKeywords);   // 10  Keywords

  B_LowGBP  = Byte(Low(TGroupByProperty));
  B_HighGBP = Byte(High(TGroupByProperty));

   // TGroupByProperty ������ 2 <-> Byte
  aXlat_GBPropToGBProp2: Array[B_LowGBP..B_HighGBP] of Byte = (
    0,   // gbpFilePath
    1,   // gbpDateByYear
    2,   // gbpDateByMonth
    3,   // gbpDateByDay
    255, // gbpTimeHour
    255, // gbpTimeMinute
    4,   // gbpPlace
    5,   // gbpFilmNumber
    255, // gbpAuthor
    255, // gbpMedia
    6);  // gbpKeywords
  aXlat_GBProp2ToGBProp: Array[0..6] of Byte = (
   Byte(gbpFilePath),      // 0  Picture file path
   Byte(gbpDateByYear),    // 1  Date year
   Byte(gbpDateByMonth),   // 2  Date month
   Byte(gbpDateByDay),     // 3  Date day
   Byte(gbpPlace),         // 4  Place
   Byte(gbpFilmNumber),    // 5  Film number
   Byte(gbpKeywords));     // 6  Keywords

var
  cMainCodePage: Cardinal;    // ������� �������� ANSI ��� �������� ��������� ������ ���������
  wClipbrdPicFormatID: Word;  // PhoA picture clipboard format identifier
   // Misc settings
  ViewInfoPos: TRect;         // ������� ���������� ��� ��������� � 10-�������� ����� ������� ������ [90, 9400, 9910, 9880]

   // ���������� ������ ��� ������� ���������� ����� ����������� �� ������ ������� �������
  function  GetPhoaSaveFilter: String;
   // ���������� ������ � aFileRevisions[], ��������������� ��������� �������, ��� -1, ���� ����� ���
  function  GetIndexOfRevision(iRev: Integer): Integer;
   // ���������� ���������� ������ �������, ���� �� � ���������� ���������; ����� ���������� 0 (������ ����� ������ �������)
  function  ValidRevisionIndex(idxRev: Integer): Integer;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses Forms, phPhoa, phUtils;

  function GetPhoaSaveFilter: String;
  var i: Integer;
  begin
    Result := '';
    for i := 0 to High(aPhFileRevisions) do AccumulateStr(Result, '|', Format('%s photo album|*.%s', [aPhFileRevisions[i].sName, SDefaultExt]));
  end;

  function GetIndexOfRevision(iRev: Integer): Integer;
  begin
    for Result := 0 to High(aPhFileRevisions) do
      if aPhFileRevisions[Result].iNumber=iRev then Exit;
    Result := -1;
  end;

  function ValidRevisionIndex(idxRev: Integer): Integer;
  begin
    Result := iif((idxRev>=0) and (idxRev<=High(aPhFileRevisions)), idxRev, 0);
  end;

initialization
   // ������ �������
  with Screen do begin
    Cursors[crHand]     := LoadCursor(HInstance, 'CRHAND');
    Cursors[crHandDrag] := LoadCursor(HInstance, 'CRHANDDRAG');
    Cursors[crDragMove] := LoadCursor(HInstance, 'CRDRAGMOVE');
    Cursors[crDragCopy] := LoadCursor(HInstance, 'CRDRAGCOPY');
  end;
   // ������������ ������ ������ ������
  wClipbrdPicFormatID := RegisterClipboardFormat(SClipbrdPicFormatName);
end.

