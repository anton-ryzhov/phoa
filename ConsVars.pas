//**********************************************************************************************************************
//  $Id: ConsVars.pas,v 1.84 2004-12-06 20:22:44 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit ConsVars;

interface
uses
   // GR32 must follow GraphicEx because of naming conflict between stretch filter constants
  Windows, SysUtils, Messages, Classes, Graphics, Controls, GraphicEx, VirtualTrees, TB2Dock, TBX, GR32,
  dkWebUtils, phIntf, phMutableIntf, phNativeIntf, phObj, phOps;

type
   // ����� ����������� ����������� ��������� ��� �������� � ��������
  TGroupTreeHintMode = (
    gthmNone,  // �� ���������� ���������
    gthmTips,  // ���������� tooltips (�.�. ���������� �������, �� ����������� � ����)
    gthmInfo); // ���������� ��������� � ��������� �������

   // ��� ���� � ������ �����
  TGroupNodeKind = (
    gnkNone,       // ��� ����
    gnkProject,    // �������� ���� - ���� �������
    gnkView,       // �������� ���� - ���� �������������
    gnkSearch,     // ���� ����������� ������
    gnkPhoaGroup,  // ���� ������ �����������
    gnkViewGroup); // ���� ������ �������������

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

type
   // ����������������� ����� ������ ���������
  TImgViewInitFlag = (
    ivifForceFullscreen, // ������������� ������ ������������� ����� (����������� � ivifForceWindow)
    ivifForceWindow,     // ������������� ������ ������� ����� (����������� � ivifForceFullscreen)
    ivifSlideShow);      // ������ ����� �������
  TImgViewInitFlags = set of TImgViewInitFlag;

   // ����������� ������ �������
  TSlideShowDirection = (
    ssdBackward, // �����
    ssdRandom,   // ��������
    ssdForward); // �����

   // ��������� ��������� ��� WM_STARTVIEWMODE
  TWMStartViewMode = packed record
    Msg:       Cardinal;
    InitFlags: TImgViewInitFlags;
    Unused:    Array[0..6] of Byte;
    Result:    Longint;
  end;

   // ����� �������� ����������� �������
  TMassCheckMode = (mcmAll, mcmNone, mcmInvert);

   // ��� ���� ��������� (������ �� ���������, ������ � �������� ������)
  TMessageBoxKind = (
    mbkInfo,           // ����������                      - OK
    mbkWarning,        // ��������������                  - OK
    mbkConfirm,        // �������������                   - OK/Cancel
    mbkConfirmWarning, // �������������� � �������������� - OK/Cancel
    mbkError);         // ������                          - OK

   // ������ � ���� ��������� (������� ���������� ������������� ������� �� ��������� � �������)
  TMessageBoxButton = (
    mbbYes,      // ��
    mbbYesToAll, // �� ��� ����
    mbbNo,       // ���
    mbbNoToAll,  // ��� ��� ����
    mbbOK,       // ��
    mbbCancel,   // ������
    mbbHelp);    // �������
  TMessageBoxButtons = set of TMessageBoxButton;

   // ��������� ������ ���� ���������
  TMessageBoxResult = (
    mbrYes,       // ������������ ����� "��"
    mbrNo,        // ������������ ����� "���"
    mbrOK,        // ������������ ����� "��"
    mbrCancel,    // ������������ ����� "������" ��� ������ ����
    mbrYesToAll,  // ������������ ����� "�� ��� ����"
    mbrNoToAll,   // ������������ ����� "��� ��� ����"
    mbrDontShow); // ������������ ������� ������������� "������ �� ����������..."
  TMessageBoxResults = set of TMessageBoxResult;

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

   // ������ ������ ����������� ��� �������� � ������� ����������� �� ������ ������������� ���������� �����
  TFileOpSelPicValidityFilter = (
    fospvfAny,          // ��� �����������
    fospvfValidOnly,    // ������ �����������, ��������� � ������������ ������
    fospvfInvalidOnly); // ������ �����������, ��������� � �������������� ������

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

   // �������� ������� ������� �����������, ������������ �� ���������
  TPicPropsDlgDefaultPage = (
    ppddpLastUsed,  // ��������� ��������������
    ppddpFileProps, // �������� �����
    ppddpMetadata,  // ����������
    ppddpView,      // �������� � ���������
    ppddpData,      // ������
    ppddpKeywords,  // �������� �����
    ppddpGroups);   // ������

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
    procedure PaintThumbnail(Bitmap32: TBitmap32); 
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

   // ��������� �������������� ���������� ��� ��������� ����� ����������� (��� ��������, ������������ ����� �����������)
  IPhoaWizardPage_PreviewInfo = interface(IInterface)
    ['{D9449CC9-8418-4A9E-A5BB-4C43F3B8AE3B}']
     // ���������� �������� ��� ��������� ��������� ���� ���������
    procedure PreviewVisibilityChanged(bVisible: Boolean);
     // Prop handlers
    function  GetCurrentFileName: String;
     // Props
     // -- ��� �������� ������������� �� �������� ����� �����������. ������ ������, ���� ��� �������� �����
    property CurrentFileName: String read GetCurrentFileName;
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
  SAppProductSID                  = 'phoa';
  SAppVersion                     = 'v1.1.7 beta';
  SAppVersionSID                  = '117beta';

  SProject_Generator              = 'PhoA '+SAppVersion;
  SProject_Remark                 = 'Created by PhoA '+SAppVersion+', '+SWeb_MainSite;

   // ���������� � ��� ����� ����������� �� ���������
  SDefaultExt                     = 'phoa';
  SDefaultFName                   = 'untitled.'+SDefaultExt;
   // ���������� � ��� ini-����� ��� ����������/�������� ���������� �� ���������
  SDefaultIniFileExt              = 'ini';
  SDefaultIniFileName             = 'phoa.'+SDefaultIniFileExt;
   // ���������� ����� ��� ���������� ��������� ������
  SDefaultSearchExpressionFileExt = 'txt';
   // ��� ������������ �����
  SPhoaExecutableFileName         = 'phoa.exe';

   // ���� � �������� � ��������� �������
  SRelativeLangFilesPath          = 'Language\';
   // ���������� �������� ������
  SLangFileExt                    = 'lng';

   // ������� ������
  S_CRLF                          = #13#10;

   // ���������� ����� ��������� ������
   //   f        - ������������� ����� ��������� (f- - �� ������������� ����� ���������)
   //   s        - �������� ����� �������� ����� ������� ���������
   //   g<group> - �������� � ������ ������ <group>
   //   w<view>  - ������� � ����� ����������� ������������� <view> (��������� � g)
   //   i<id>    - ���������� ����������� � ID=<id> (��������� � w � g)
  CmdLine_ValidKeys               = ['f', 's', 'g', 'w', 'i'];

  MinInt                          = Low(Integer);

   // ������� ������ � ����� � ��������
   // -- �������: �������������� � ������������                                   |
  IThumbMarginH                   = 2;       //                                MarginV
  IThumbMarginV                   = 2;       //                                   |
   // -- ����������                                         +-------------------------------------------+
  IThumbPaddingL                  = 5;       //             |  Thumbnail          |                     |
  IThumbPaddingR                  = 5;       //             |  background      PaddingT                 |
  IThumbPaddingT                  = 5;       //             |                     |                     |
  IThumbPaddingB                  = 5;       //             |              +-------------+              |
                                             //             |              |             |              |
                                             // - MarginH - | - PaddingL - |  Thumbnail  | - PaddingR - | - MarginH -
                                             //             |              |    image    |              |
                                             //             |              +-------------+              |
                                             //             |                     |                     |
                                             //             |                  PaddingB                 |
                                             //             |                     |                     |
                                             //             +-------------------------------------------+
                                             //                                   |
                                             //                                MarginV
                                             //                                   |

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
  SRegRoot                        = 'Software\DKSoftware\PhoA';

  SRegMainWindow_Root             = 'MainWindow';
    SRegMainWindow_Toolbars       = SRegMainWindow_Root+'\Toolbars';

  SRegViewWindow_Root             = 'ViewWindow';
    SRegViewWindow_Toolbars       = SRegViewWindow_Root+'\Toolbars';

  SRegPrefs_Root                  = 'Preferences';
    SRegPrefs_Tools               = SRegPrefs_Root+'\Tools';
    SRegPrefs_ToolEditor          = SRegPrefs_Root+'\ToolEditor';
    SRegPrefs_Profiles            = SRegPrefs_Root+'\Profiles';
    SRegPrefs_ProfileEditor       = SRegPrefs_Root+'\ProfileEditor';

  SRegOpen_Root                   = 'Open';
    SRegOpen_FilesMRU             = SRegOpen_Root+'\FilesMRU';

  SRegDialogsRoot                 = 'Dialogs';

  SRegSettings_Root               = SRegDialogsRoot+'\SettingsDialog';

  SRegAddFiles_Root               = SRegDialogsRoot+'\AddFilesWizard';
    SRegAddFiles_MaskMRU          = SRegAddFiles_Root+'\FileMaskMRU';

  SRegPicProps_Root               = SRegDialogsRoot+'\PicPropsDialog';

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
    SRegSearch_SimpleCriteria     = 'SimpleCriteria';

  SRegSort_Root                   = SRegDialogsRoot+'\Sort';
    SRegSort_LastSortings         = SRegSort_Root+'\LastSortings';

  SRegStats_Root                  = SRegDialogsRoot+'\Stats';

  SRegWizPagesRoot                = 'WizardPages';
    SRegWizPages_Toolbars         = '\Toolbars';

    SRegWizPage_PicProp_Metadata  = 'PicProp_Metadata';
    SRegWizPage_PicProp_View      = 'PicProp_View';

  SRegPicFilterExprEditor_Root    = 'PicFilterExpressionEditor';
    SRegPFilterExprEditor_OpenMRU = 'OpenMRU';

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

   // ID ������ ����������� ������ 
  IGroupID_SearchResults          = MaxInt;

   // Timer IDs
  ISlideShowTimerID               = $01010101;
  IPicPropsViewTimerID            = $01010101;

   // Image indices (from ilActionsSmall)
  iiNew                           =  0;
  iiOpen                          =  1;
  iiSave                          =  2;
  iiSaveAs                        =  3;
  iiExit                          =  4;
  iiNewGroup                      =  5;
  iiNewPic                        =  6;
  iiDelete                        =  7;
  iiEdit                          =  8;
  iiSearch                        =  9;
  iiAbout                         = 10;
  iiHelp                          = 11;
  iiProps                         = 12;
  iiSelectAll                     = 13;
  iiSelectNone                    = 14;
  iiViewMode                      = 15;
  iiSort                          = 16;
  iiFileOps                       = 17;
  iiPicOps                        = 18;
  iiStats                         = 19;
  iiCut                           = 20;
  iiCopy                          = 21;
  iiPaste                         = 22;
  iiUndo                          = 23;
  iiUndoHistory                   = 24;
  iiZoomIn                        = 25;
  iiZoomOut                       = 26;
  iiZoomFit                       = 27;
  iiZoomActual                    = 28;
  iiRefresh                       = 29;
  iiLeft                          = 30;
  iiFirst                         = 31;
  iiLast                          = 32;
  iiRight                         = 33;
  iiFullScreen                    = 34;
  iiSlideShow                     = 35;
  iiFolder                        = 36;
  iiView                          = 37;
  iiNewView                       = 38;
  iiGroupFromView                 = 39;
  iiInvertSelection               = 40;
  iiKeyword                       = 41;
  iiMetadata                      = 42;
  iiAsterisk                      = 43;
  iiInfo                          = 44;
  iiInfoRelocate                  = 45;
  iiDialog                        = 46;
  iiGlobe                         = 47;
  iiPhoA                          = 48;
  iiNo                            = 49;
  iiFolderSearch                  = 50;
  iiGrouping                      = 51;
  iiSorting                       = 52;
  iiSortAsc                       = 53;
  iiSortDesc                      = 54;
  iiUp                            = 55;
  iiDown                          = 56;
  iiOK                            = 57;
  iiError                         = 58;
  iiTool                          = 59;
  iiPrint                         = 60;
  iiSeparator                     = 61;
  iiAction                        = 62;
  iiSaveSettings                  = 63;
  iiLoadSettings                  = 64;
  iiRemoveSearchResults           = 65;
  iiRotate0                       = 66;
  iiRotate90                      = 67;
  iiRotate180                     = 68;
  iiRotate270                     = 69;
  iiFlipHorz                      = 70;
  iiFlipVert                      = 71;
  iiStoreTransform                = 72;
  iiDKSoftware                    = 73;
  iiProfile                       = 74;
  iiSlideShowForward              = 75;
  iiSlideShowBackward             = 76;
  iiSlideShowRandom               = 77;
  iiSlideShowCyclic               = 78;
  iiFolderOpen                    = 79;
  iiRedo                          = 80;
  iiConvert                       = 81;
  iiSomething                     = 82;

   // Help topics
  IDH_start                       = 00001;
  IDH_general_advantages          = 01010;
  IDH_general_license             = 01020;
  IDH_general_file_formats        = 01040;
  IDH_general_how_it_works        = 01050;
  IDH_general_intro               = 01060;
  IDH_general_major_modes         = 01070;
  IDH_general_pic_data            = 01080;
  IDH_general_requirements        = 01090;
  IDH_general_rev_history         = 01100;
  IDH_general_thumbnails          = 01110;
  IDH_info_cmd_line               = 02010;
  IDH_info_faq                    = 02020;
  IDH_info_file_masks             = 02030;
  IDH_info_filter_expr            = 02035;
  IDH_info_metadata               = 02040;
  IDH_info_pic_prop_autofill      = 02050;
  IDH_info_resampling             = 02060;
  IDH_info_tools                  = 02070;
  IDH_info_transform              = 02080;
  IDH_intf_album_props            = 03010;
  IDH_intf_browse_mode            = 03020;
  IDH_intf_browse_mode_menu       = 03030;
  IDH_intf_browse_mode_menu_edit  = 03040;
  IDH_intf_browse_mode_menu_file  = 03050;
  IDH_intf_browse_mode_menu_help  = 03060;
  IDH_intf_browse_mode_menu_tools = 03070;
  IDH_intf_browse_mode_menu_view  = 03080;
  IDH_intf_browse_mode_tasks      = 03090;
  IDH_intf_browse_mode_views      = 03100;
  IDH_intf_controls               = 03110;
  IDH_intf_ctl_browser_key        = 03120;
  IDH_intf_ctl_browser_mouse      = 03130;
  IDH_intf_ctl_viewer_key         = 03140;
  IDH_intf_ctl_viewer_mouse       = 03150;
  IDH_intf_file_ops               = 03160;
  IDH_intf_file_ops_cdopts        = 03170;
  IDH_intf_file_ops_delopts       = 03180;
  IDH_intf_file_ops_log           = 03190;
  IDH_intf_file_ops_moveopts      = 03200;
  IDH_intf_file_ops_moveopts2     = 03210;
  IDH_intf_file_ops_process       = 03220;
  IDH_intf_file_ops_repropts      = 03230;
  IDH_intf_file_ops_selfolder     = 03240;
  IDH_intf_file_ops_selpics       = 03250;
  IDH_intf_file_ops_seltask       = 03260;
  IDH_intf_file_ops_task_copy     = 03270;
  IDH_intf_file_ops_task_del      = 03280;
  IDH_intf_file_ops_task_move     = 03290;
  IDH_intf_file_ops_task_repfl    = 03300;
  IDH_intf_file_ops_task_rthumb   = 03310;
  IDH_intf_group_props            = 03320;
  IDH_intf_major_modes            = 03330;
  IDH_intf_pic_add                = 03340;
  IDH_intf_pic_add_checkfiles     = 03350;
  IDH_intf_pic_add_log            = 03360;
  IDH_intf_pic_add_process        = 03370;
  IDH_intf_pic_add_selfiles       = 03380;
  IDH_intf_pic_operations         = 03390;
  IDH_intf_pic_props              = 03400;
  IDH_intf_pic_props_data         = 03410;
  IDH_intf_pic_props_fprops       = 03420;
  IDH_intf_pic_props_groups       = 03430;
  IDH_intf_pic_props_keywords     = 03440;
  IDH_intf_pic_props_metadata     = 03450;
  IDH_intf_pic_props_view         = 03460;
  IDH_intf_search                 = 03470;
  IDH_intf_search_datatypes       = 03472;
  IDH_intf_search_expr            = 03474;
  IDH_intf_search_simple          = 03475;
  IDH_intf_select_keywords        = 03480;
  IDH_intf_sel_phoa_group         = 03490;
  IDH_intf_sort_pics              = 03500;
  IDH_intf_stats                  = 03510;
  IDH_intf_tool_props             = 03520;
  IDH_intf_view_mode              = 03530;
  IDH_intf_view_mode_menu         = 03540;
  IDH_intf_view_mode_menu_help    = 03550;
  IDH_intf_view_mode_menu_picture = 03560;
  IDH_intf_view_mode_menu_tools   = 03570;
  IDH_intf_view_mode_menu_view    = 03580;
  IDH_intf_view_mode_menu_zoom    = 03590;
  IDH_intf_view_mode_tasks        = 03600;
  IDH_intf_view_props             = 03610;
  IDH_setup                       = 04010;
  IDH_setup_browse_mode           = 04020;
  IDH_setup_dialogs               = 04030;
  IDH_setup_general               = 04040;
  IDH_setup_storing               = 04050;
  IDH_setup_tools                 = 04060;
  IDH_setup_view_mode             = 04070;

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
  ISettingID_Gen                       = 0001; // �����
  ISettingID_Gen_Intf                  = 0;    // ���������
    ISettingID_Gen_Language            = 0041; // ���� ����������
    ISettingID_Gen_MainFont            = 0042; // ����� ���������
    ISettingID_Gen_Theme               = 0045; // ���� ����������
    ISettingID_Gen_TooltipDisplTime    = 0050; // ����������������� ����������� ����������� ���������, ��
    ISettingID_Gen_OpenMRUCount        = 0061; // ����� ������ ��������� �������� ������
    ISettingID_Gen_LookupPhoaIni       = 0062; // ��������� �� ��������� �� phoa.ini � �������� �������
  ISettingID_Gen_Clipboard             = 0;    // ����� ������
    ISettingID_Gen_ClipFormats         = 0070; // �������, ���������� � ����� ������ ��� �����������
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
  ISettingID_Browse                    = 1001; // ����� ������
  ISettingID_Browse_FlatMode           = 1005; // ����������� ��������
  ISettingID_Browse_GTree              = 1010; // ������� �����
    ISettingID_Browse_GT_Hints         = 1011; // ������� �����: ����������� ���������
    ISettingID_Browse_GT_HintNone      = 1012; // ������� �����: ����������� ���������: �� ����������
    ISettingID_Browse_GT_HintTips      = 1013; // ������� �����: ����������� ���������: ���������� tooltips
    ISettingID_Browse_GT_HintInfo      = 1014; // ������� �����: ����������� ���������: ���������� ��������� ��������
    ISettingID_Browse_GT_HintProps     = 1015; // ������� �����: �������� ��� �����������
  ISettingID_Browse_Viewer             = 0;    // Viewer
    ISettingID_Browse_ViewerBkColor    = 1110; // Viewer: ���� ����
    ISettingID_Browse_ViewerThBColor   = 1111; // Viewer: ���� ���� ������
    ISettingID_Browse_ViewerThFColor   = 1112; // Viewer: ���� ������ ������
    ISettingID_Browse_ViewerDragDrop   = 1113; // Viewer: Drag'n'Drop
    ISettingID_Browse_ViewerTooltips   = 1114; // Viewer: ���������� ����������� �������� �������
    ISettingID_Browse_ViewerTipProps   = 1115; // Viewer: ���������� �� ����������� ���������
    ISettingID_Browse_ViewerThInfo     = 1120; // Viewer: ������, ������������ �� �������
    ISettingID_Browse_ViewerThLTProp   = 1121; // Viewer: Left top corner
    ISettingID_Browse_ViewerThRTProp   = 1122; // Viewer: Right top corner
    ISettingID_Browse_ViewerThLBProp   = 1123; // Viewer: Left bottom corner
    ISettingID_Browse_ViewerThRBProp   = 1124; // Viewer: Right bottom corner
    ISettingID_Browse_ViewerThBordSt   = 1130; // Viewer: ����� ������� ������
    ISettingID_Browse_ViewerThBordCl   = 1131; // Viewer: ���� ������� ������ ��� ����� "�������� ����"
    ISettingID_Browse_ViewerThShadow   = 1134; // Viewer: ���������� ���� ������
    ISettingID_Browse_ViewerThShRadius = 1135; // Viewer: ������ �������� ���� ������
    ISettingID_Browse_ViewerThShOffsX  = 1136; // Viewer: �������� ���� ������ �� �����������
    ISettingID_Browse_ViewerThShOffsY  = 1137; // Viewer: �������� ���� ������ �� ���������
    ISettingID_Browse_ViewerThShColor  = 1138; // Viewer: ���� ���� ������
    ISettingID_Browse_ViewerThShOpact  = 1139; // Viewer: "��������������" ���� ������
    ISettingID_Browse_ViewerStchFilt   = 1150; // Viewer: ����� ����������� �������
  ISettingID_Browse_MaxUndoCount       = 1260; // ����. ���������� �������� � ������ ������
   //===================================================================================================================
  ISettingID_View                      = 2001; // ����� ���������
  ISettingID_View_AlwaysOnTop          = 2010; // ���� ��������� ������ ���� ����
  ISettingID_View_Fullscreen           = 2011; // ������������� �����
  ISettingID_View_KeepCursorOverTB     = 2012; // ������������������� ������ ��� ������� ������������
  ISettingID_View_HideCursor           = 2013; // �������� ��������� ���� � ������������� ������
  ISettingID_View_BkColor              = 2014; // ���� ���� ���� ���������
  ISettingID_View_ShowToolbar          = 2015; // ���������� ������ ������������
  ISettingID_View_PicChange            = 0;    // ����� �����������
    ISettingID_View_FitWindowToPic     = 2020; // ��������� ������ ���� ��� ������ �����������
    ISettingID_View_CenterWindow       = 2021; // ������������ ���� �� ������� �����
    ISettingID_View_ShrinkPicToFit     = 2022; // ������� ����������� �� ������� ����
    ISettingID_View_ZoomPicToFit       = 2023; // ����������� ����������� �� ������� ����
    ISettingID_View_Cyclic             = 2024; // ����������� ��������
    ISettingID_View_Optimizing         = 0;    // ����������� ��������
      ISettingID_View_Predecode        = 2030; // ��������������� ��������� �����������
      ISettingID_View_CacheBehind      = 2031; // ���������� ���������� �����������
  ISettingID_View_ZoomFactor           = 2040; // ��� ��������� ��������
  ISettingID_View_CaptionProps         = 2041; // ���������� � ��������� ����
  ISettingID_View_StchFilt             = 2042; // ����� ����������� �����������
  ISettingID_View_Info                 = 0;    // ������������ ����������
    ISettingID_View_ShowInfo           = 2050; // ���������� �� ����������
    ISettingID_View_InfoPicProps       = 2051; // Info: ������������ ����������
    ISettingID_View_InfoFont           = 2052; // Info: �����
    ISettingID_View_InfoBkColor        = 2053; // Info: ���� ����
    ISettingID_View_InfoBkOpacity      = 2054; // Info: �������������� ���� (0-255)
  ISettingID_View_Slideshow            = 0;    // �������� �������
    ISettingID_View_SlideInterval      = 2060; // Slideshow: �������� ������, ��
    ISettingID_View_SlideDirection     = 2064; // Slideshow: ����������� ���������
      ISettingID_View_SlideDirForward  = 2065; // Slideshow: ����������� ���������: �����
      ISettingID_View_SlideDirBackward = 2066; // Slideshow: ����������� ���������: �����
      ISettingID_View_SlideDirRandom   = 2067; // Slideshow: ����������� ���������: ��������
    ISettingID_View_SlideCyclic        = 2070; // Slideshow: ����������� ��������
   //===================================================================================================================
  ISettingID_Dialogs                   = 3001; // �������
  ISettingID_Dlgs_SplashStartShow      = 3005; // ���������� �������� ��� �������
    ISettingID_Dlgs_SplashStartFade    = 3006; // ������������� ������� ��������
  ISettingID_Dlgs_SplashAboutFade      = 3008; // ������������� ������� ���� "� ���������"
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
    ISettingID_Dlgs_APW_AutofillXfrm   = 3060; // ������������� ��������� �������������� �����������
  ISettingID_Dlgs_PicProps             = 0;    // ���� ������� �����������
    ISettingID_Dlgs_PP_DefaultPage     = 3100; // �������� �� ���������
      ISettingID_Dlgs_PP_Def_LastUsed  = 3101; // �������� �� ���������: ��������� ��������������
      ISettingID_Dlgs_PP_Def_FProps    = 3102; // �������� �� ���������: "�������� �����"
      ISettingID_Dlgs_PP_Def_Metadata  = 3103; // �������� �� ���������: "����������"
      ISettingID_Dlgs_PP_Def_View      = 3104; // �������� �� ���������: "�������� � ���������"
      ISettingID_Dlgs_PP_Def_Data      = 3105; // �������� �� ���������: "������"
      ISettingID_Dlgs_PP_Def_Keywords  = 3106; // �������� �� ���������: "�������� �����"
      ISettingID_Dlgs_PP_Def_Groups    = 3107; // �������� �� ���������: "������"
    ISettingID_Dlgs_PP_ExpFileProps    = 3111; // ����� ���������� �������� ������
    ISettingID_Dlgs_PP_ExpMetadata     = 3112; // ����� ���������� ���������� �����������
  ISettingID_Dlgs_FileOpsWizard        = 0;    // ������ �������� � ������� �����������
    ISettingID_Dlgs_FOW_CfmCopyFiles   = 3120; // ������������� ��� �������� ����������� ������
    ISettingID_Dlgs_FOW_CfmMoveFiles   = 3121; // ������������� ��� �������� ����������� ������
    ISettingID_Dlgs_FOW_CfmDelFiles    = 3122; // ������������� ��� �������� �������� ������
    ISettingID_Dlgs_FOW_CfmRebuildTh   = 3123; // ������������� ��� �������� ����������� �������
    ISettingID_Dlgs_FOW_CfmRepairFLs   = 3124; // ������������� ��� �������� �������������� ������ �� �����
    ISettingID_Dlgs_FOW_LogOnErrOnly   = 3130; // ���������� �������� ������ ��� ������� ������
   //===================================================================================================================
  ISettingID_Profiles                  = 4001; // �������
   //===================================================================================================================
  ISettingID_Tools                     = 5001; // �����������

   //===================================================================================================================
  ISettingID_Hidden                    = 9001; // ��������� ���������
  ISettingID_Hidden_ViewInfoPos        = 9010; // ��������� ��������������� ����� ������ ��������� � 10-�������� ����� ������� ������

   // ������������ ����� ���������� � ������� ����������� � ������� �� �� �������������
  aFileOpConfirmSettingIDs: Array[TFileOperationKind] of Integer = (
    ISettingID_Dlgs_FOW_CfmCopyFiles,
    ISettingID_Dlgs_FOW_CfmMoveFiles,
    ISettingID_Dlgs_FOW_CfmDelFiles,
    ISettingID_Dlgs_FOW_CfmRebuildTh,
    ISettingID_Dlgs_FOW_CfmRepairFLs);

   // ��������� � ������������� ������� ������ ���������. wParam = ����� �������������, TImgViewInitFlags
  WM_STARTVIEWMODE              = WM_USER+$1090;
   // ��������� � ������������� �������� ������ ��������
  WM_PAGEUPDATE                 = WM_USER+$1100;
   // ��������� ��� ��������� �������� - � ������������� �������� � ������ �������� ������� ���������
  WM_EMBEDCONTROL               = WM_USER+$1120;

   // PhoA picture clipboard format name
  SClipbrdPicFormatName         = 'PHOA_INT_PICTURE_BUCKET';

const
  aCheckStates: Array[Boolean] of TCheckState = (csUncheckedNormal, csCheckedNormal);

var
   // ������� �������� ANSI ��� �������� ��������� ������ ���������
  cMainCodePage: Cardinal;
   // PhoA picture clipboard format identifier
  wClipbrdPicFormatID: Word;
   // ���������� ��������� IDKWeb
  DKWeb: IDKWeb;
   // ����������� ��� ��������� ��������� �������
  AppFormatSettings: TFormatSettings;

   // ���������� �������� ����������� Pic �� ������� Props, ������� ������ ��������� ������.
   //   ���� ������ sNameValSep, �� ������� ����� ������������ �������, �������� ��� �� �������� ���� �������.
   //   sPropSep - �������������� ������ ����� ���������� ����������
  function GetPicPropStrs(Pic: IPhoaPic; Props: TPicProperties; const sNameValSep, sPropSep: String): String;
     // ���������� �������� ������ Group �� ������� Props, ������� ������ ��������� ������.
     //   ���� ������ sNameValSep, �� ������� ����� ������������ �������, �������� ��� �� �������� ���� �������.
     //   sPropSep - �������������� ������ ����� ���������� ����������
  function GetPicGroupPropStrs(Group: IPhoaPicGroup; Props: TGroupProperties; const sNameValSep, sPropSep: String): String;

   // ���������� ������ ��� ������� ���������� ����� ����������� �� ������ ������� �������
  function  GetPhoaSaveFilter: String;
   // ���������� ������ � aFileRevisions[], ��������������� ��������� �������, ��� -1, ���� ����� ���
  function  GetIndexOfRevision(iRev: Integer): Integer;
   // ���������� ���������� ������ �������, ���� �� � ���������� ���������; ����� ���������� 0 (������ ����� ������ �������)
  function  ValidRevisionIndex(idxRev: Integer): Integer;

   // ��������� ���������������� ��������� � TVirtualStringTree
  procedure ApplyTreeSettings(Tree: TVirtualStringTree);
   // ��������� ���������������� ��������� � �����/������� ������������
  procedure ApplyToolbarSettings(Dock: TTBXDock);

   // ������ �������� �������� (�� ���������� �� ���������)
  procedure InitSettings;

   // ���������� ������ ��������� ������, �������������� ��������������� ��������� � ������������� ������� ����
  procedure InitLanguages;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Forms,
  TBXThemes, TBXDefaultTheme, TBXOfficeXPTheme, TBXStripesTheme, TBXAluminumTheme,
  DKLang,
  phPhoa, phObjConst, phGUIObj, phUtils, phSettings, phValSetting, phToolSetting, udAbout;

  function GetPicPropStrs(Pic: IPhoaPic; Props: TPicProperties; const sNameValSep, sPropSep: String): String;
  var
    Prop: TPicProperty;
    sVal: String;
  begin
    Result := '';
    for Prop := Low(Prop) to High(Prop) do
      if Prop in Props then begin
        sVal := Pic.PropStrValues[Prop];
        if sVal<>'' then begin
          if sNameValSep<>'' then sVal := PicPropName(Prop)+sNameValSep+sVal;
          AccumulateStr(Result, sPropSep, sVal);
        end;
      end;
  end;

  function GetPicGroupPropStrs(Group: IPhoaPicGroup; Props: TGroupProperties; const sNameValSep, sPropSep: String): String;
  var
    Prop: TGroupProperty;
    sVal: String;
  begin
    Result := '';
    for Prop := Low(Prop) to High(Prop) do
      if Prop in Props then begin
        sVal := Group.Props[Prop];
        if sVal<>'' then begin
          if sNameValSep<>'' then sVal := GroupPropName(Prop)+sNameValSep+sVal;
          AccumulateStr(Result, sPropSep, sVal);
        end;
      end;
  end;
  
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

   //===================================================================================================================
   // Settings
   //===================================================================================================================

  procedure AdjustThemeSetting(Setting: TPhoaListSetting);
  begin
    GetAvailableTBXThemes(Setting.Variants);
  end;

  procedure AddPicPropSettings(Owner: TPhoaIntSetting);
  var Prop: TPicProperty;
  begin
    for Prop := Low(Prop) to High(Prop) do TPhoaMaskBitSetting.Create(Owner, 0, '@'+GetEnumName(TypeInfo(TPicProperty), Byte(Prop)));
  end;

  procedure AdjustPicPropListSettings(Setting: TPhoaListSetting);
  var Prop: TPicProperty;
  begin
    Setting.Variants.AddObject('', Pointer(MaxInt));
    for Prop := Low(Prop) to High(Prop) do
      Setting.Variants.AddObject('@'+GetEnumName(TypeInfo(TPicProperty), Byte(Prop)), Pointer(Prop));
  end;

  procedure AddThumbBorderStyleSettings(Owner: TPhoaIntSetting);
  var BS: TThumbBackBorderStyle;
  begin
    for BS := Low(BS) to High(BS) do TPhoaMutexSetting.Create(Owner, 0, '@'+GetEnumName(TypeInfo(TThumbBackBorderStyle), Byte(BS)));
  end;

  procedure AddGroupPropSettings(Owner: TPhoaIntSetting);
  var Prop: TGroupProperty;
  begin
    for Prop := Low(Prop) to High(Prop) do TPhoaMaskBitSetting.Create(Owner, 0, '@'+GetEnumName(TypeInfo(TGroupProperty), Byte(Prop)));
  end;

  procedure AddPicClipboardFormatSettings(Owner: TPhoaIntSetting);
  var pcf: TPicClipboardFormat;
  begin
    for pcf := Low(pcf) to High(pcf) do TPhoaMaskBitSetting.Create(Owner, 0, '@'+GetEnumName(TypeInfo(TPicClipboardFormat), Byte(pcf)));
  end;

  procedure AdjustTreeCheckStyleSetting(Setting: TPhoaListSetting);
  begin
    with Setting.Variants do begin
      Add('Dark Check');
      Add('Dark Tick');
      Add('Flat');
      Add('Light Check');
      Add('Light Tick');
      Add('Standard');
      Add('Standard Flat');
      Add('XP');
    end;
  end;

  procedure AddStretchFilterSettings(Owner: TPhoaIntSetting);
  begin
    TPhoaMutexIntSetting.Create(Owner, 0, 'Nearest Neighbor',   Byte(sfNearest));
    TPhoaMutexIntSetting.Create(Owner, 0, 'Draft',              Byte(sfDraft));
    TPhoaMutexIntSetting.Create(Owner, 0, 'Linear',             Byte(sfLinear));
    TPhoaMutexIntSetting.Create(Owner, 0, 'Cosine',             Byte(sfCosine));
    TPhoaMutexIntSetting.Create(Owner, 0, 'B-spline (bicubic)', Byte(sfSpline));
    TPhoaMutexIntSetting.Create(Owner, 0, 'Lanczos',            Byte(sfLanczos));
    TPhoaMutexIntSetting.Create(Owner, 0, 'Mitchell',           Byte(sfMitchell));
  end;

  procedure AdjustMagnificationSetting(Setting: TPhoaListSetting);
  var b: Byte;
  begin
    for b := 0 to High(adMagnifications) do Setting.Variants.Add(Format('%d%%', [Trunc((adMagnifications[b]-1)*100)]));
  end;

  procedure AddDateTimeAutofillPropSettings(Owner: TPhoaIntSetting);
  var Prop: TDateTimeAutofillProp;
  begin
    for Prop := Low(Prop) to High(Prop) do TPhoaMaskBitSetting.Create(Owner, 0, '@'+GetEnumName(TypeInfo(TDateTimeAutofillProp), Byte(Prop)));
  end;

  procedure ApplyTreeSettings(Tree: TVirtualStringTree);
  begin
     // Apply options
    with Tree.TreeOptions do begin
       // -- Animation
      if SettingValueBool(ISettingID_Gen_TreeAnimation) then
        AnimationOptions := AnimationOptions+[toAnimatedToggle]
      else
        AnimationOptions := AnimationOptions-[toAnimatedToggle];
       // -- Wheel panning
      if SettingValueBool(ISettingID_Gen_TreeWhPanning) then
        MiscOptions := MiscOptions+[toWheelPanning]
      else
        MiscOptions := MiscOptions-[toWheelPanning];
       // -- Center selection
      if SettingValueBool(ISettingID_Gen_TreeCenterSel) then
        SelectionOptions := SelectionOptions+[toCenterScrollIntoView]
      else
        SelectionOptions := SelectionOptions-[toCenterScrollIntoView];
    end;
    with Tree do begin
       // -- Incremental search
      if SettingValueBool(ISettingID_Gen_TreeIncrSearch) then begin
        IncrementalSearch        := isVisibleOnly;
        IncrementalSearchTimeout := SettingValueInt(ISettingID_Gen_TreeIncrSrchDelay);
      end else
        IncrementalSearch := isNone;
       // -- Button style
      if SettingValueInt(ISettingID_Gen_TreeButtonStyle)=0 then ButtonStyle := bsRectangle else ButtonStyle := bsTriangle;
       // -- Check style
      case SettingValueInt(ISettingID_Gen_TreeCheckStyle) of
        0: CheckImageKind := ckDarkCheck;
        1: CheckImageKind := ckDarkTick;
        2: CheckImageKind := ckFlat;
        3: CheckImageKind := ckLightCheck;
        4: CheckImageKind := ckLightTick;
        5: CheckImageKind := ckSystem;
        6: CheckImageKind := ckSystemFlat;
        7: CheckImageKind := ckXP;
      end;
       // -- Multiselection style
      if SettingValueInt(ISettingID_Gen_TreeSelStyle)=0 then
        DrawSelectionMode := smDottedRectangle
      else
        DrawSelectionMode := smBlendedRectangle;
    end;
  end;

type
  TTBDockWndCast = class(TTBCustomDockableWindow);

  procedure ApplyToolbarSettings(Dock: TTBXDock);
  var i, iMode: Integer;
  begin
    iMode := SettingValueInt(ISettingID_Gen_ToolbarDragStyle);
     // ����������� ��� ���
    Dock.AllowDrag := iMode>0;
     // ����������� ������ � ����
    if iMode>0 then
      for i := 0 to Dock.ToolbarCount-1 do
        with TTBDockWndCast(Dock.Toolbars[i]) do
          case iMode of
            1: DockMode := dmCannotFloatOrChangeDocks;
            2: DockMode := dmCannotFloat;
            3: DockMode := dmCanFloat;
          end;
  end;

   //===================================================================================================================

  {$HINTS OFF} // Do not hint abount var not used
  procedure InitSettings;
  var Lvl1, Lvl2, Lvl3, Lvl4: TPhoaSetting;
  begin
     //== ����� ========================================================================================================
    Lvl1 := TPhoaValPageSetting.Create(RootSetting, ISettingID_Gen, iiProps, '@ISettingID_Gen', IDH_setup_general);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Gen_Intf,                '@ISettingID_Gen_Intf');
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_Language,            '@ISettingID_Gen_Language',            $409 {=1033, English-US}, MinInt, MaxInt);
        Lvl3 := TPhoaFontSetting.Create      (Lvl2, ISettingID_Gen_MainFont,            '@ISettingID_Gen_MainFont',            'Tahoma/8/0/0/1');
        Lvl3 := TPhoaListSetting.Create      (Lvl2, ISettingID_Gen_Theme,               '@ISettingID_Gen_Theme',               0 {Default?}, lsvtIndexString);
        AdjustThemeSetting(Lvl3 as TPhoaListSetting);                                                                          
        Lvl3 := TPhoaIntEntrySetting.Create  (Lvl2, ISettingID_Gen_TooltipDisplTime,    '@ISettingID_Gen_TooltipDisplTime',    5000, 100, MaxInt);
        Lvl3 := TPhoaIntEntrySetting.Create  (Lvl2, ISettingID_Gen_OpenMRUCount,        '@ISettingID_Gen_OpenMRUCount',        10, 0, 15);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Gen_LookupPhoaIni,       '@ISettingID_Gen_LookupPhoaIni',       True);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Gen_Clipboard,           '@ISettingID_Gen_Clipboard');          
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_ClipFormats,         '@ISettingID_Gen_ClipFormats',         Byte(DefaultPicClipboardFormats), MinInt, MaxInt);
        AddPicClipboardFormatSettings(lvl3 as TPhoaIntSetting);                                                                
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Gen_Toolbars,            '@ISettingID_Gen_Toolbars');           
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_ToolbarBtnSize,      '@ISettingID_Gen_ToolbarBtnSize',      0, 0, 2);
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarBSz16,        '@ISettingID_Gen_ToolbarBSz16');       
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarBSz24,        '@ISettingID_Gen_ToolbarBSz24');       
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarBSz32,        '@ISettingID_Gen_ToolbarBSz32');       
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_ToolbarDragStyle,    '@ISettingID_Gen_ToolbarDragStyle',    3, 0, 3);
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarDrgNone,      '@ISettingID_Gen_ToolbarDrgNone');
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarDrgOneDock,   '@ISettingID_Gen_ToolbarDrgOneDock');  
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarDrgNoFloat,   '@ISettingID_Gen_ToolbarDrgNoFloat');  
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_ToolbarDrgFree,      '@ISettingID_Gen_ToolbarDrgFree');     
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Gen_Tree,                '@ISettingID_Gen_Tree');               
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Gen_TreeAnimation,       '@ISettingID_Gen_TreeAnimation',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Gen_TreeWhPanning,       '@ISettingID_Gen_TreeWhPanning',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Gen_TreeCenterSel,       '@ISettingID_Gen_TreeCenterSel',       False);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Gen_TreeIncrSearch,      '@ISettingID_Gen_TreeIncrSearch',      True);
          Lvl4 := TPhoaIntEntrySetting.Create(Lvl3, ISettingID_Gen_TreeIncrSrchDelay,   '@ISettingID_Gen_TreeIncrSrchDelay',   1000, 100, 10000);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_TreeButtonStyle,     '@ISettingID_Gen_TreeButtonStyle',     0, 0, 1);
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_TreeBS_Rectangle,    '@ISettingID_Gen_TreeBS_Rectangle');   
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_TreeBS_Triangle,     '@ISettingID_Gen_TreeBS_Triangle');    
        Lvl3 := TPhoaListSetting.Create      (Lvl2, ISettingID_Gen_TreeCheckStyle,      '@ISettingID_Gen_TreeCheckStyle',      7 {XP}, lsvtIndex);
        AdjustTreeCheckStyleSetting(Lvl3 as TPhoaListSetting);                                                                 
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Gen_TreeSelStyle,        '@ISettingID_Gen_TreeSelStyle',        1, 0, 1);
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_TreeSelDotted,       '@ISettingID_Gen_TreeSelDotted');      
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Gen_TreeSelBlended,      '@ISettingID_Gen_TreeSelBlended');
     //== ����� ������ =================================================================================================
    Lvl1 := TPhoaValPageSetting.Create(RootSetting, ISettingID_Browse, iiFolder, '@ISettingID_Browse', IDH_setup_browse_mode);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_Browse_FlatMode,         '@ISettingID_Browse_FlatMode',         False);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Browse_GTree,            '@ISettingID_Browse_GTree');
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Browse_GT_Hints,         '@ISettingID_Browse_GT_Hints',         1 {gthmTips}, 0, 2);
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Browse_GT_HintNone,      '@ISettingID_Browse_GT_HintNone');     
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Browse_GT_HintTips,      '@ISettingID_Browse_GT_HintTips');     
          Lvl4 := TPhoaMutexSetting.Create   (Lvl3, ISettingID_Browse_GT_HintInfo,      '@ISettingID_Browse_GT_HintInfo');     
          Lvl4 := TPhoaIntSetting.Create     (Lvl3, ISettingID_Browse_GT_HintProps,     '@ISettingID_Browse_GT_HintProps',     GroupPropsToInt([gpDescription]), MinInt, MaxInt);
          AddGroupPropSettings(Lvl4 as TPhoaIntSetting);                                                                       
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Browse_Viewer,           '@ISettingID_Browse_Viewer');          
        Lvl3 := TPhoaColorSetting.Create     (Lvl2, ISettingID_Browse_ViewerBkColor,    '@ISettingID_Browse_ViewerBkColor',    $d7d7d7);
        Lvl3 := TPhoaColorSetting.Create     (Lvl2, ISettingID_Browse_ViewerThBColor,   '@ISettingID_Browse_ViewerThBColor',   clBtnFace);
        Lvl3 := TPhoaColorSetting.Create     (Lvl2, ISettingID_Browse_ViewerThFColor,   '@ISettingID_Browse_ViewerThFColor',   clWindowText);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Browse_ViewerDragDrop,   '@ISettingID_Browse_ViewerDragDrop',   True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Browse_ViewerTooltips,   '@ISettingID_Browse_ViewerTooltips',   True);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Browse_ViewerTipProps,   '@ISettingID_Browse_ViewerTipProps',   PicPropsToInt([ppFileName, ppFileSize, ppPicDims, ppDate, ppTime, ppPlace, ppFilmNumber, ppFrameNumber, ppAuthor, ppDescription, ppMedia]), MinInt, MaxInt);
        AddPicPropSettings(Lvl3 as TPhoaIntSetting);                                                                           
        Lvl3 := TPhoaSetting.Create          (Lvl2, ISettingID_Browse_ViewerThInfo,     '@ISettingID_Browse_ViewerThInfo');    
          Lvl4 := TPhoaListSetting.Create    (Lvl3, ISettingID_Browse_ViewerThLTProp,   '@ISettingID_Browse_ViewerThLTProp',   MaxInt, lsvtObject);
          AdjustPicPropListSettings(Lvl4 as TPhoaListSetting);                                                                 
          Lvl4 := TPhoaListSetting.Create    (Lvl3, ISettingID_Browse_ViewerThRTProp,   '@ISettingID_Browse_ViewerThRTProp',   MaxInt, lsvtObject);
          AdjustPicPropListSettings(Lvl4 as TPhoaListSetting);                                                                 
          Lvl4 := TPhoaListSetting.Create    (Lvl3, ISettingID_Browse_ViewerThLBProp,   '@ISettingID_Browse_ViewerThLBProp',   Byte(ppPlace), lsvtObject);
          AdjustPicPropListSettings(Lvl4 as TPhoaListSetting);                                                                 
          Lvl4 := TPhoaListSetting.Create    (Lvl3, ISettingID_Browse_ViewerThRBProp,   '@ISettingID_Browse_ViewerThRBProp',   Byte(ppDate), lsvtObject);
          AdjustPicPropListSettings(Lvl4 as TPhoaListSetting);                                                                 
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Browse_ViewerThBordSt,   '@ISettingID_Browse_ViewerThBordSt',   Byte(tbbsXP), Byte(Low(TThumbBackBorderStyle)), Byte(High(TThumbBackBorderStyle)));
        AddThumbBorderStyleSettings(Lvl3 as TPhoaIntSetting);
        Lvl3 := TPhoaColorSetting.Create     (Lvl2, ISettingID_Browse_ViewerThBordCl,   '@ISettingID_Browse_ViewerThBordCl',   clBtnShadow);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Browse_ViewerThShadow,   '@ISettingID_Browse_ViewerThShadow',   True);
          Lvl4 := TPhoaIntEntrySetting.Create(Lvl3, ISettingID_Browse_ViewerThShRadius, '@ISettingID_Browse_ViewerThShRadius', 40, 1, 200);
          Lvl4 := TPhoaIntEntrySetting.Create(Lvl3, ISettingID_Browse_ViewerThShOffsX,  '@ISettingID_Browse_ViewerThShOffsX',  7, -1000, 1000);
          Lvl4 := TPhoaIntEntrySetting.Create(Lvl3, ISettingID_Browse_ViewerThShOffsY,  '@ISettingID_Browse_ViewerThShOffsY',  7, -1000, 1000);
          Lvl4 := TPhoaColorSetting.Create   (Lvl3, ISettingID_Browse_ViewerThShColor,  '@ISettingID_Browse_ViewerThShColor',  clBlack);
          Lvl4 := TPhoaIntEntrySetting.Create(Lvl3, ISettingID_Browse_ViewerThShOpact,  '@ISettingID_Browse_ViewerThShOpact',  140, 0, 255);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Browse_ViewerStchFilt,   '@ISettingID_Browse_ViewerStchFilt',   Byte(sfNearest), Byte(Low(TStretchFilter)), Byte(High(TStretchFilter)));
        AddStretchFilterSettings(Lvl3 as TPhoaIntSetting);                                                                     
      Lvl2 := TPhoaIntEntrySetting.Create    (Lvl1, ISettingID_Browse_MaxUndoCount,     '@ISettingID_Browse_MaxUndoCount',     100, 1, MaxInt);
     //== ����� ��������� ==============================================================================================       
    Lvl1 := TPhoaValPageSetting.Create(RootSetting, ISettingID_View, iiViewMode, '@ISettingID_View', IDH_setup_view_mode);     
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_View_AlwaysOnTop,        '@ISettingID_View_AlwaysOnTop',        False);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_View_Fullscreen,         '@ISettingID_View_Fullscreen',         False);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_View_KeepCursorOverTB,   '@ISettingID_View_KeepCursorOverTB',   True);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_View_HideCursor,         '@ISettingID_View_HideCursor',         False);
      Lvl2 := TPhoaColorSetting.Create       (Lvl1, ISettingID_View_BkColor,            '@ISettingID_View_BkColor',            $000000);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_View_ShowToolbar,        '@ISettingID_View_ShowToolbar',        True);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_View_PicChange,          '@ISettingID_View_PicChange');         
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_FitWindowToPic,     '@ISettingID_View_FitWindowToPic',     True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_CenterWindow,       '@ISettingID_View_CenterWindow',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_ShrinkPicToFit,     '@ISettingID_View_ShrinkPicToFit',     True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_ZoomPicToFit,       '@ISettingID_View_ZoomPicToFit',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_Cyclic,             '@ISettingID_View_Cyclic',             False);
        Lvl3 := TPhoaSetting.Create          (Lvl2, ISettingID_View_Optimizing,         '@ISettingID_View_Optimizing');        
          Lvl4 := TPhoaBoolSetting.Create    (Lvl3, ISettingID_View_Predecode,          '@ISettingID_View_Predecode',          True);
          Lvl4 := TPhoaBoolSetting.Create    (Lvl3, ISettingID_View_CacheBehind,        '@ISettingID_View_CacheBehind',        True);
      Lvl2 := TPhoaListSetting.Create        (Lvl1, ISettingID_View_ZoomFactor,         '@ISettingID_View_ZoomFactor',         3 {=50%}, lsvtIndex);
      AdjustMagnificationSetting(Lvl2 as TPhoaListSetting);
      Lvl2 := TPhoaIntSetting.Create         (Lvl1, ISettingID_View_CaptionProps,       '@ISettingID_View_CaptionProps',       PicPropsToInt([ppFileName]), MinInt, MaxInt);
      AddPicPropSettings(Lvl2 as TPhoaIntSetting);
      Lvl2 := TPhoaIntSetting.Create         (Lvl1, ISettingID_View_StchFilt,           '@ISettingID_View_StchFilt',           Byte(sfNearest), Byte(Low(TStretchFilter)), Byte(High(TStretchFilter)));
      AddStretchFilterSettings(Lvl2 as TPhoaIntSetting);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_View_Info,               '@ISettingID_View_Info');
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_ShowInfo,           '@ISettingID_View_ShowInfo',           True);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_View_InfoPicProps,       '@ISettingID_View_InfoPicProps',       PicPropsToInt([ppDate, ppTime, ppPlace, ppDescription]), MinInt, MaxInt);
        AddPicPropSettings(Lvl3 as TPhoaIntSetting);
        Lvl3 := TPhoaFontSetting.Create      (Lvl2, ISettingID_View_InfoFont,           '@ISettingID_View_InfoFont',           'Arial/14/0/16777215/1');
        Lvl3 := TPhoaColorSetting.Create     (Lvl2, ISettingID_View_InfoBkColor,        '@ISettingID_View_InfoBkColor',        $000000);
        Lvl3 := TPhoaIntEntrySetting.Create  (Lvl2, ISettingID_View_InfoBkOpacity,      '@ISettingID_View_InfoBkOpacity',      $40, 0, 255);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_View_Slideshow,          '@ISettingID_View_Slideshow');
        Lvl3 := TPhoaIntEntrySetting.Create  (Lvl2, ISettingID_View_SlideInterval,      '@ISettingID_View_SlideInterval',      5000, 0, 600*1000);

        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_View_SlideDirection,     '@ISettingID_View_SlideDirection',     Byte(ssdForward), Byte(Low(TSlideShowDirection)), Byte(High(TSlideShowDirection)));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_View_SlideDirBackward,   '@ISettingID_View_SlideDirBackward',   Byte(ssdBackward));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_View_SlideDirRandom,     '@ISettingID_View_SlideDirRandom',     Byte(ssdRandom));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_View_SlideDirForward,    '@ISettingID_View_SlideDirForward',    Byte(ssdForward));
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_View_SlideCyclic,        '@ISettingID_View_SlideCyclic',        True);
     //== ������� ======================================================================================================       
    Lvl1 := TPhoaValPageSetting.Create(RootSetting, ISettingID_Dialogs, iiDialog, '@ISettingID_Dialogs', IDH_setup_dialogs);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_Dlgs_SplashStartShow,    '@ISettingID_Dlgs_SplashStartShow',    True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_SplashStartFade,    '@ISettingID_Dlgs_SplashStartFade',    True);
      Lvl2 := TPhoaBoolSetting.Create        (Lvl1, ISettingID_Dlgs_SplashAboutFade,    '@ISettingID_Dlgs_SplashAboutFade',    True);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Dlgs_Confms,             '@ISettingID_Dlgs_Confms');            
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_ConfmDelGroup,      '@ISettingID_Dlgs_ConfmDelGroup',      True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_ConfmDelPics,       '@ISettingID_Dlgs_ConfmDelPics',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_ConfmDelView,       '@ISettingID_Dlgs_ConfmDelView',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_ConfmOldFile,       '@ISettingID_Dlgs_ConfmOldFile',       True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_ConfmAppExit,       '@ISettingID_Dlgs_ConfmAppExit',       False);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Dlgs_Notifies,           '@ISettingID_Dlgs_Notifies');          
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_NotifyDragCopy,     '@ISettingID_Dlgs_NotifyDragCopy',     True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_NotifyDragMove,     '@ISettingID_Dlgs_NotifyDragMove',     True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_NotifyPaste,        '@ISettingID_Dlgs_NotifyPaste',        True);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Dlgs_AddPicWizard,       '@ISettingID_Dlgs_AddPicWizard');      
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_ShowHidden,     '@ISettingID_Dlgs_APW_ShowHidden',     False);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_SkipChkPage,    '@ISettingID_Dlgs_APW_SkipChkPage',    False);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_LogOnErrOnly,   '@ISettingID_Dlgs_APW_LogOnErrOnly',   True);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Dlgs_APW_AutofillDate,   '@ISettingID_Dlgs_APW_AutofillDate',   Byte(DTAP_DefaultDateProps), MinInt, MaxInt);
        AddDateTimeAutofillPropSettings(Lvl3 as TPhoaIntSetting);                                                              
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_ReplaceDate,    '@ISettingID_Dlgs_APW_ReplaceDate',    False);
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Dlgs_APW_AutofillTime,   '@ISettingID_Dlgs_APW_AutofillTime',   Byte(DTAP_DefaultTimeProps), MinInt, MaxInt);
        AddDateTimeAutofillPropSettings(Lvl3 as TPhoaIntSetting);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_ReplaceTime,    '@ISettingID_Dlgs_APW_ReplaceTime',    False);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_APW_AutofillXfrm,   '@ISettingID_Dlgs_APW_AutofillXfrm',   False);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Dlgs_PicProps,           '@ISettingID_Dlgs_PicProps');
        Lvl3 := TPhoaIntSetting.Create       (Lvl2, ISettingID_Dlgs_PP_DefaultPage,     '@ISettingID_Dlgs_PP_DefaultPage',     Byte(ppddpData), Byte(Low(TPicPropsDlgDefaultPage)), Byte(High(TPicPropsDlgDefaultPage)));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_LastUsed,    '@ISettingID_Dlgs_PP_Def_LastUsed',    Byte(ppddpLastUsed));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_FProps,      '@ISettingID_Dlgs_PP_Def_FProps',      Byte(ppddpFileProps));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_Metadata,    '@ISettingID_Dlgs_PP_Def_Metadata',    Byte(ppddpMetadata));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_View,        '@ISettingID_Dlgs_PP_Def_View',        Byte(ppddpView));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_Data,        '@ISettingID_Dlgs_PP_Def_Data',        Byte(ppddpData));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_Keywords,    '@ISettingID_Dlgs_PP_Def_Keywords',    Byte(ppddpKeywords));
          Lvl4 := TPhoaMutexIntSetting.Create(Lvl3, ISettingID_Dlgs_PP_Def_Groups,      '@ISettingID_Dlgs_PP_Def_Groups',      Byte(ppddpGroups));
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_PP_ExpFileProps,    '@ISettingID_Dlgs_PP_ExpFileProps',    False);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_PP_ExpMetadata ,    '@ISettingID_Dlgs_PP_ExpMetadata',     False);
      Lvl2 := TPhoaSetting.Create            (Lvl1, ISettingID_Dlgs_FileOpsWizard,      '@ISettingID_Dlgs_FileOpsWizard');     
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_CfmCopyFiles,   '@ISettingID_Dlgs_FOW_CfmCopyFiles',   True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_CfmMoveFiles,   '@ISettingID_Dlgs_FOW_CfmMoveFiles',   True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_CfmDelFiles,    '@ISettingID_Dlgs_FOW_CfmDelFiles',    True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_CfmRebuildTh,   '@ISettingID_Dlgs_FOW_CfmRebuildTh',   True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_CfmRepairFLs,   '@ISettingID_Dlgs_FOW_CfmRepairFLs',   True);
        Lvl3 := TPhoaBoolSetting.Create      (Lvl2, ISettingID_Dlgs_FOW_LogOnErrOnly,   '@ISettingID_Dlgs_FOW_LogOnErrOnly',   True);
     //== ����������� ==================================================================================================
    Lvl1 := TPhoaToolPageSetting.Create(RootSetting, ISettingID_Tools, iiTool, '@ISettingID_Tools', IDH_setup_tools);
      Lvl2 := TPhoaToolSetting.Create(Lvl1, '@SAction_Open',  '@SActionHint_OpenPics',  '', '', '', '', ptkOpen,  SW_SHOWNORMAL, [ptuToolsMenu]);
      Lvl2 := TPhoaToolSetting.Create(Lvl1, '@SAction_Print', '@SActionHint_PrintPics', '', '', '', '', ptkPrint, SW_SHOWNORMAL, [ptuToolsMenu]);
     //== (������� ���������) ==========================================================================================
    Lvl1 := TPhoaInvisiblePageSetting.Create(RootSetting, ISettingID_Hidden);
      Lvl2 := TPhoaRectSetting.Create        (Lvl1, ISettingID_Hidden_ViewInfoPos,      '@ISettingID_Hidden_ViewInfoPos',      Rect(90, 9400, 9910, 9880));
  end;
  {$HINTS ON}

  procedure InitLanguages;
  var LangSetting: TPhoaSetting;

     // ��������� � ��������� ������ ������ ����� ����������
    procedure LoadLanguageSettings;
    var i: Integer;
    begin
       // ������ ������ ������ ��������� ������
      for i := 0 to LangManager.LanguageCount-1 do
        TPhoaMutexIntSetting.Create(LangSetting, 0, LangManager.LanguageNames[i], LangManager.LanguageIDs[i]);
    end;

  begin
     // ��������� �������� �����
    ShowProgressInfo('SMsg_ScanningLanguages', []);
    LangManager.ScanForLangFiles(ExtractFilePath(ParamStr(0))+SRelativeLangFilesPath, '*.'+SLangFileExt, False);
     // ������� ����� ������ "���� ����������"
    LangSetting := RootSetting.Settings[ISettingID_Gen_Language];
     // ��������� ��������� ������ �����
    LoadLanguageSettings;
     // ����������� ���� ����������
    ShowProgressInfo('SMsg_ApplyingLanguage', []);
    LangManager.LanguageID := (LangSetting as TPhoaIntSetting).Value;
     // ������������� ��������� �����
    TPhoaIntSetting(LangSetting).Value := LangManager.LanguageID;
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
   // �������������� AppFormatSettings
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT, AppFormatSettings);
  AppFormatSettings.ShortTimeFormat := 'hh:nn';
  AppFormatSettings.LongTimeFormat  := 'hh:nn:ss';
  AppFormatSettings.TimeSeparator   := ':';
   // ��������� HintWindowClass
  HintWindowClass := TPhoAHintWindow;
   // ������ ���������
  RootSetting := TPhoaSetting.Create(nil, 0, '');
   // ������ ���������� ��������� IDKWeb
  DKWeb := DKCreateDKWeb(SAppProductSID, SAppVersionSID);
finalization
  DKWeb := nil;
  RootSetting.Free;
end.

