//**********************************************************************************************************************
//  $Id: phObj.pas,v 1.18 2004-06-06 13:29:46 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 Dmitry Kann, http://phoa.narod.ru
//**********************************************************************************************************************
unit phObj;

interface
uses
  SysUtils, Classes, Windows, Messages, Graphics, GR32, Controls, StdCtrls, Forms, Masks, ConsVars, phPhoa;

type
  TPhoaGroup       = class;
  TPhoaGroups      = class;
  TPhotoAlbum      = class;
  TPhoaPic         = class;
  TPhoaPics        = class;
  TPhoaViews       = class;
  TThumbnailViewer = class;

  TPicArray = Array of TPhoaPic;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ Integer'��
   //-------------------------------------------------------------------------------------------------------------------

  TIntegerListSortSompareFunc = function(i1, i2: Integer; pData: Pointer): Integer;

  TIntegerList = class(TList)
  private
    FAllowDuplicates: Boolean;
    function  GetItems(Index: Integer): Integer;
  public
    constructor Create(bAllowDuplicates: Boolean);
     // ���� ����� �� ���� � ������ ��� ��������� ���������, ��������� ��� � ���������� True, ����� ���������� False
    function  Add(i: Integer): Boolean;
     // ��������� ��� ����� �� ������ SourceList (� ������ AllowDuplicates). ���������� ���������� ������� �����������
     //   �����
    function  AddAll(SourceList: TIntegerList): Integer;
     // ���� ����� �� ���� � ������ ��� ��������� ���������, ��������� ��� � ���������� True, ����� ���������� False
    function  Insert(Index, i: Integer): Boolean;
     // ���� ����� ���� � ������, ������� ��� � ���������� ��� ������� ������, ����� ���������� -1
    function  Remove(i: Integer): Integer;
     // ���������� ������ ����� ��� -1, ���� ������ ���
    function  IndexOf(i: Integer): Integer;
     // ��������� ������, ��������� ������� ��������� ���� TIntegerListSortSompareFunc. �������� pData - ������������
     //   ���������, ������������ � ������� ���������
    procedure Sort(CompareFunc: TIntegerListSortSompareFunc; pData: Pointer);
     // Props
     // -- ���� False, ����� ����������� ��������� �� ������� ������ �����, �, ���� ����, �� ���������
    property AllowDuplicates: Boolean read FAllowDuplicates;
     // -- ����� �� �������
    property Items[Index: Integer]: Integer read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ������ �� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaPicLinks = class(TList)
  private
    FSorted: Boolean;
    function GetItems(Index: Integer): TPhoaPic;
  public
     // ��� bSorted=True ������ �������� �������������, ���������� �������� ����� � ���������� ��������� ����������� (�.�.
     //   � �������������� ID)
    constructor Create(bSorted: Boolean);
     // �������� ������ �� ����������� � Src. ���� RestrictLinks=nil, �� �������� ��� �����������, ����� - ������ ��,
     //   ID ������� ���������� � RestrictLinks
    procedure Assign(Src: TPhoaPics; RestrictLinks: TPhoaPicLinks);
     // ��������� ����������� � ������. ��� ������������� ������ ��������� ������������
    function Add(Pic: TPhoaPic): Integer;
     // ���� ����������� �� ID � ���������� True, ���� �����, � � Index - ������� ���������� �����������. ����
     //   ����������� � ����� ID �� �������, ���������� False, � � Index - ������� ����������� � ��������� ������� ID
    function FindID(iID: Integer; var Index: Integer): Boolean;
     // �������� ��� ������ �� ����������� � ������. ��� bReplace=True �������������� ������� ������ (���� Group=nil,
     //   ������ ������� ������)
    procedure AddFromGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bReplace: Boolean);
     // �������� ��� ������ �� ����������� � ������� ID �����������. ��� bReplace=True �������������� ������� ������
    procedure AddFromPicIDs(PhoA: TPhotoAlbum; const aPicIDs: TIDArray; bReplace: Boolean);
     // �������� ��� ������ �� ����������� � �����������
    procedure CopyFromPhoa(PhoA: TPhotoAlbum);
     // �������� ��� ID ����������� � ������
    procedure CopyToGroup(Group: TPhoaGroup);
     // ���������� ������ ����������� � �������� ID, ��� -1, ���� ��� ������
    function IndexOfID(iID: Integer): Integer;
     // ���������� ����������� �� ��� ID (nil, ���� �� �������)
    function PicByID(iID: Integer): TPhoaPic;
     // ���������� ����������� �� ��� ����� ����� (nil, ���� �� �������)
    function PicByFileName(const sFileName: String): TPhoaPic;
     // Props
    property Items[Index: Integer]: TPhoaPic read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ���������� �����������
   //-------------------------------------------------------------------------------------------------------------------

   // ���������� ����������� (���������� � 4 �����)
  TPhoaSorting = packed record
    Prop:    TPicProperty; // �������� ��� ����������
    Order:   TSortOrder;   // ����������� ����������
    wUnused: Word;
  end;

   // ������ ���������� �����������
  TPhoaSortings = class(TList)
  private
    function  GetItems(Index: Integer): TPhoaSorting;
  public
    procedure Add(_Prop: TPicProperty; _Order: TSortOrder);
     // ���� ������ ���������� �� ��������. ���� �� ������, ���������� -1
    function  IndexOf(Prop: TPicProperty): Integer;
     // ���������� ��� ����������� (��� ����������)
    function  SortComparePics(Pic1, Pic2: TPhoaPic): Integer;
     // ���������� True, ���� ���������� ������ ��������� ������ Sortings
    function  IdenticalWith(Sortings: TPhoaSortings): Boolean;
     // ����������� ����������� ���������� � �������� Index
    procedure ToggleOrder(Index: Integer);
     // ������������� �������� ��� ���������� � ������ � �������� Index
    procedure SetProp(Index: Integer; Prop: TPicProperty);
     // ����������/�������� �� �������
    procedure RegSave(const sSection: String);
    procedure RegLoad(const sSection: String);
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ���������� ������ ���������� � ��������� �� ���������
    procedure RevertToDefaults;
     // Props
    property Items[Index: Integer]: TPhoaSorting read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ (���������) �����������
   //-------------------------------------------------------------------------------------------------------------------

  PPhoaGroup = ^TPhoaGroup;
  TPhoaGroup = class(TObject)
  private
     // Prop storage
    FExpanded: Boolean;
    FText: String;
    FGroups: TPhoaGroups;
    FOwner: TPhoaGroup;
    FPicIDs: TIntegerList;
    FID: Integer;
    FDescription: String;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ����������� ���������, ����������� ID �������, ������� ID=0
    procedure InternalFixupIDs(var iFreeID: Integer);
     // Prop handlers
    procedure SetOwner(Value: TPhoaGroup);
    function  GetIndex: Integer;
    procedure SetIndex(Value: Integer);
    function  GetNestedGroupCount: Integer;
    function  GetPath(const sRootName: String): String;
    function  GetGroupByPath(const sPath: String): TPhoaGroup;
    function  GetFreeID: Integer;
    function  GetRoot: TPhoaGroup;
    function  GetGroupByID(iID: Integer): TPhoaGroup;
  public
    constructor Create(_Owner: TPhoaGroup; iID: Integer);
    destructor Destroy; override;
     // ���������� True, ���� ID ����������� ������������ � ������ ������ (��� ����� � ��������� ��� bRecursive=True)
    function  IsPicLinked(iID: Integer; bRecursive: Boolean): Boolean;
     // �������� �������� ������: ������������, Expanded;
     //   ��� bCopyIDs=True       - ����� � ID
     //   ��� bCopyPicIDs=True    - ����� ������ ID �����������;
     //   ��� bCopySubgroups=True - ���������� ��������� �� ��� ��������� �����
    procedure Assign(Src: TPhoaGroup; bCopyIDs, bCopyPicIDs, bCopySubgroups: Boolean);
     // ��������� ����������� �� �������� �����������
    procedure SortPics(Sortings: TPhoaSortings; Pics: TPhoaPics);
     // ���������� ������������� ������ � ��� ���������, �������� ID �������, ��� �� �������
    procedure FixupIDs;
     // Props
     // -- ��������
    property Description: String read FDescription write FDescription;
     // -- True, ���� ��������������� ������ ���� ������ ��������
    property Expanded: Boolean read FExpanded write FExpanded;
     // -- ���������� ��������� ��������� ID, ������� ID ����� ������ � ID ��� � �����
    property FreeID: Integer read GetFreeID;
     // -- ������ �����, �������� � ������ ������
    property Groups: TPhoaGroups read FGroups;
     // -- ���������� ������ �� ID ����� ������ � � �����; nil, ���� ��� �����
    property GroupByID[iID: Integer]: TPhoaGroup read GetGroupByID;
     // -- ���������� ������ �� ��������� ����; nil, ���� ��� ����� (case-insensitive); �������� ����� ����� ����� �
     //    ������ ������� ��������, ���� ���� ���������� � '/', ����������� ���� ������
    property GroupByPath[const sPath: String]: TPhoaGroup read GetGroupByPath;
     // -- ���������� ������������� ������
    property ID: Integer read FID;
     // -- ������ ������ � � ��������� (Owner)
    property Index: Integer read GetIndex write SetIndex;
     // -- ���������� �������� � ������ (������� ��� ���������)
    property NestedGroupCount: Integer read GetNestedGroupCount;
     // -- ������-�������� ������ ������
    property Owner: TPhoaGroup read FOwner write SetOwner;
     // -- ���� ������ � ���� '<sRootName>/������1/������2/.../�������������'
    property Path[const sRootName: String]: String read GetPath;
     // -- ������ ID �����������, �������� � ������
    property PicIDs: TIntegerList read FPicIDs;
     // -- ���������� �������������� ��������� ���� ����� ��������
    property Root: TPhoaGroup read GetRoot;
     // -- ����� (������������) ������
    property Text: String read FText write FText;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ����� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaGroups = class(TList)
  private
    FOwner: TPhoaGroup;
    function GetItems(Index: Integer): TPhoaGroup;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
  public
    constructor Create(_Owner: TPhoaGroup);
    function  Add(Group: TPhoaGroup): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // Props
    property  Items[Index: Integer]: TPhoaGroup read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �����������
   //-------------------------------------------------------------------------------------------------------------------

  PPhoaPic = ^TPhoaPic; 
  TPhoaPic = class(TObject)
  private
     // ����������. ������ �������������� ������ ��� ��������� �������� � �������� �������
    FPhoA: TPhotoAlbum;
     // Prop storage
    FList: TPhoaPics;
    FID: Integer;
    FPicAuthor: String;
    FPicDateTime: TDateTime;
    FPicDesc: String;
    FPicFileName: String;
    FPicFileSize: Integer;
    FPicFilmNumber: String;
    FPicFlips: TPicFlips;
    FPicFormat: TPixelFormat;
    FPicFrameNumber: String;
    FPicHeight: Integer;
    FPicKeywords: TStrings;
    FPicMedia: String;
    FPicNotes: String;
    FPicPlace: String;
    FPicRotation: TPicRotation;
    FPicWidth: Integer;
    FThumbHeight: Integer;
    FThumbnailData: String;
    FThumbWidth: Integer;
     // ��������/���������� � ������� Streamer
     //   -- �������� bEx...Relative ������������, ������������ �� �������������� �������������� <-> ����������� ����
     //      � ����� �����������
     //   -- �������� PProps ���������, ����� �������� ��������� � ��������������� (��� ���� ��� ���������� ������,
     //      ��������� � ������������, �.�. � ������, ����������� ������ ��� ������� ppFileName in PProps)
    procedure StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
    procedure StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);
     // Prop handlers
    procedure SetList(Value: TPhoaPics);
    function  GetRawData(PProps: TPicProperties): String;
    procedure SetRawData(PProps: TPicProperties; const Value: String);
    function  GetProps(PicProp: TPicProperty): String;
    procedure SetProps(PicProp: TPicProperty; const Value: String);
  public
    constructor Create(PhoA: TPhotoAlbum);
    destructor Destroy; override;
     // �������� ��� ������ �����������
    procedure Assign(Src: TPhoaPic);
     // ������ ����� �� ����� � ��������� ������ ����������� � ������
    procedure MakeThumbnail;
     // ������������ ����� ID, ���������� � ������
    procedure IDNeeded(List: TPhoaPics);
     // ������������ ����� �� �������
    procedure PaintThumbnail(Bitmap: TBitmap);
     // ���������� �������� ����������� �� ������� Props, ������� ������ ��������� ������.
     //   ���� ������ sNameValSep, �� ������� ����� ������������ �������, �������� ��� �� �������� ���� �������.
     //   sPropSep - �������������� ������ ����� ���������� ����������
    function  GetPropStrs(Props: TPicProperties; const sNameValSep, sPropSep: String): String;
     // ���������� ��������� �������� � �� �������� �� ���������
    procedure CleanupProps(Props: TPicProperties);
     // Props
     // -- ���������� �������������
    property ID: Integer read FID;
     // -- ������ - �������� ����������� (����� ���� nil)
    property List: TPhoaPics read FList write SetList;
     // -- ����� �����������
    property PicAuthor: String read FPicAuthor write FPicAuthor;
     // -- ���� � ����� �����������
    property PicDateTime: TDateTime read FPicDateTime write FPicDateTime;
     // -- �������� ����������� (��� �����������)
    property PicDesc: String read FPicDesc write FPicDesc;
     // -- ��� ����� �����������
    property PicFileName: String read FPicFileName write FPicFileName;
     // -- ������ ����� �����������
    property PicFileSize: Integer read FPicFileSize write FPicFileSize;
     // -- ����� ��� �������� �����
    property PicFilmNumber: String read FPicFilmNumber write FPicFilmNumber;
     // -- ����� ��������� ����������� ��� ������ ��� �� �����
    property PicFlips: TPicFlips read FPicFlips write FPicFlips;
     // -- ������ ����� �����������
    property PicFormat: TPixelFormat read FPicFormat;
     // -- ����� �����
    property PicFrameNumber: String read FPicFrameNumber write FPicFrameNumber;
     // -- ������ ����������� � ��������
    property PicHeight: Integer read FPicHeight write FPicHeight;
     // -- ������ �������� ����
    property PicKeywords: TStrings read FPicKeywords;
     // -- �������� � ������ �����������
    property PicMedia: String read FPicMedia write FPicMedia;
     // -- ����������
    property PicNotes: String read FPicNotes write FPicNotes;
     // -- ����� �����������
    property PicPlace: String read FPicPlace write FPicPlace;
     // -- ���� �������� ����������� ��� ������ ��� �� �����
    property PicRotation: TPicRotation read FPicRotation write FPicRotation;
     // -- ������ ����������� � ��������
    property PicWidth: Integer read FPicWidth write FPicWidth;
     // -- �������� �� �������
    property Props[PicProp: TPicProperty]: String read GetProps write SetProps;
     // -- �������� ������ ����������� (��������, ��������� � PProps)
    property RawData[PProps: TPicProperties]: String read GetRawData write SetRawData;
     // -- �������� ������ ������
    property ThumbHeight: Integer read FThumbHeight;
     // -- �������� JPEG-������ ������
    property ThumbnailData: String read FThumbnailData;
     // -- �������� ������ ������
    property ThumbWidth: Integer read FThumbWidth;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ �����������, � ������� ����������� �������������� � �������� ����������� (� ������������ ��� ��������)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaPics = class(TPhoaPicLinks)
  private
    FPhoA: TPhotoAlbum;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
  public
    constructor Create(_PhoA: TPhotoAlbum);
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // �������� ����������� � Src. ���� bCopyLinksOnly=True, �������� ������ ������, ����� ������ ����� �����������.
     //   ���� RestrictLinks=nil, �� �������� ��� �����������, ����� - ������ ��, ID ������� ���������� � RestrictLinks
    procedure Assign(Src: TPhoaPics; bCopyLinksOnly: Boolean; RestrictLinks: TPhoaPicLinks);
     // ���������� ��������� ��������� ID �����������
    function GetFreePicID: Integer;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaView = class;

   // ��������������� ������, �������� ������ �� ����������� �����������
  TPhoaViewHelperPics = class(TPhoaPicLinks)
  public
     // ��������� ����������� ��� ������������� (��� ����������� �����������)
    procedure Sort(View: TPhoaView);
  end;

   // ����������� ����������� (���������� � 4 �����)
  TPhoaGrouping = packed record
    Prop: TGroupByProperty; // �������� ��� �����������
    bUnclassified: Boolean; // �������� �� �������������������� ����������� � ��������� ������
    wUnused: Word;
  end;

   // ���������������� ����������� (�� ������� �����)
  TRawPhoaGrouping = packed record
    bProp: Byte;
    bUnclassified: Byte;
    wUnused: Word;
  end;

   // ������ ����������� �����������
  TPhoaGroupings = class(TList)
  private
    function  GetItems(Index: Integer): TPhoaGrouping;
  public
    procedure Add(_Prop: TGroupByProperty; _bUnclassified: Boolean);
     // ���������� True, ���� ���������� ������ ��������� ������ Groupings
    function  IdenticalWith(Groupings: TPhoaGroupings): Boolean;
     // ���������� ��� ����������� (��� ����������)
    function  SortComparePics(Pic1, Pic2: TPhoaPic): Integer;
     // ����������� bUnclassified ����������� � �������� Index
    procedure ToggleUnclassified(Index: Integer);
     // ������������� �������� ��� ����������� � ������ � �������� Index
    procedure SetProp(Index: Integer; Prop: TGroupByProperty);
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Props
    property Items[Index: Integer]: TPhoaGrouping read GetItems; default;
  end;

  TPhoaView = class(TObject)
  private
     // ������-�������� �������������
    FList: TPhoaViews;
     // Prop storage
    FRootGroup: TPhoaGroup;
    FName: String;
    FGroupings: TPhoaGroupings;
    FSortings: TPhoaSortings;
     // Prop handlers
    function  GetRootGroup: TPhoaGroup;
    function  GetIndex: Integer;
  protected
     // �������� ������ ����� �� ��������� �������������
    procedure ProcessGroups;
  public
    constructor Create(List: TPhoaViews);
    destructor Destroy; override;
     // �������� �������� ������������� � Src
    procedure Assign(Src: TPhoaView);
     // �������� ������ ����� �� ��������� �������������
    procedure UnprocessGroups;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Props
     // -- ������ ������������� � ������-���������
    property Index: Integer read GetIndex;
     // -- ������������ �������������
    property Name: String read FName write FName;
     // -- ������ ����������� �����������
    property Groupings: TPhoaGroupings read FGroupings;
     // -- �������� ������ - �������� �� ��������� ������������� ������������� ��� ���������
    property RootGroup: TPhoaGroup read GetRootGroup;
     // -- ������ ���������� �����������
    property Sortings: TPhoaSortings read FSortings;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaViews = class(TList)
  private
    FPhoA: TPhotoAlbum;
    function GetItems(Index: Integer): TPhoaView;
  public
    constructor Create(PhoA: TPhotoAlbum);
    function  Add(View: TPhoaView): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // �������� ������������� � Src (���������� ������������� �� �������� processed groups)
    procedure Assign(Src: TPhoaViews);
     // ��������� ������������� �� ������������
    procedure Sort;
     // ������� ������ ����� �� ���� ��������������
    procedure UnprocessAllViews;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ���������� ������ ������������� �� ��� ����� (case-insensitive); -1, ���� ��� ������
    function  IndexOfName(const sName: String): Integer;  
     // Props
    property Items[Index: Integer]: TPhoaView read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOperations = class;

  TPhotoAlbum = class(TObject)
  private
     // Prop storage
    FRootGroup: TPhoaGroup;
    FPics: TPhoaPics;
    FViews: TPhoaViews;
    FFileName: String;
    FFileRevision: Integer;
    FDescription: String;
    FThumbnailQuality: Byte;
    FThumbnailWidth: Integer;
    FThumbnailHeight: Integer;
    FOnThumbDimensionsChanged: TNotifyEvent;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // �������� OnThumbDimensionsChanged
    procedure ThumbDimensionsChanged; 
     // Prop handlers
    procedure SetThumbnailHeight(Value: Integer);
    procedure SetThumbnailWidth(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
     // ������� ��� ���������� ���� �����������
    procedure New(UndoOperations: TPhoaOperations);
     // �������� ��������� �����������. bCopyRevision - ���������� �� �������
    procedure Assign(Src: TPhotoAlbum; bCopyRevision: Boolean);
     // ��������/���������� � ����
     // -- ��������� ���������� �� �����
    procedure FileLoad(const sFileName: String; UndoOperations: TPhoaOperations);
     // -- ���������� ���������� � ������� ����
    procedure FileSave(UndoOperations: TPhoaOperations);
     // -- ���������� ���������� � ����� ���� (� �������� �������� iRevisionNumber)
    procedure FileSaveTo(const sFileName: String; iRevisionNumber: Integer; UndoOperations: TPhoaOperations);
     // ������� ��� �����������, �� ������� �� ��������� �� ���� �� ����� ����������� � �������� ��������� �����������
     //   � UndoOperations
    procedure RemoveUnlinkedPics(UndoOperations: TPhoaOperations);
     // Props
     // -- ����� �������� �����������
    property Description: String read FDescription write FDescription;
     // -- ��� ����� �����������
    property FileName: String read FFileName write FFileName;
     // -- ������� ������� ����� �����������
    property FileRevision: Integer read FFileRevision;
     // -- ������ ����������� �����������
    property Pics: TPhoaPics read FPics;
     // -- �������� (���������) ������, ��������� ����� �������� �����������
    property RootGroup: TPhoaGroup read FRootGroup;
     // -- ������ ������ � ��������
    property ThumbnailHeight: Integer read FThumbnailHeight write SetThumbnailHeight;
     // -- �������� JPEG-������ (0..100)
    property ThumbnailQuality: Byte read FThumbnailQuality write FThumbnailQuality;
     // -- ������ ������ � ��������
    property ThumbnailWidth: Integer read FThumbnailWidth write SetThumbnailWidth;
     // -- ������ ������������� �����������
    property Views: TPhoaViews read FViews;
     // -- ������� ��������� �������� ������
    property OnThumbDimensionsChanged: TNotifyEvent read FOnThumbDimensionsChanged write FOnThumbDimensionsChanged;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ [���������] ��������� ������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  PPicPropertyChange = ^TPicPropertyChange;
  TPicPropertyChange = record
    sNewValue: String;
    Prop: TPicProperty;
  end;

  TPicPropertyChanges = class(TList)
  private
    function GetItems(Index: Integer): PPicPropertyChange;
    function GetChangedProps: TPicProperties;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    function  Add(const sNewValue: String; Prop: TPicProperty): Integer;
     // Props
     // -- ����� ������������ �������
    property ChangedProps: TPicProperties read GetChangedProps;
     // -- �������� ������ �� �������
    property Items[Index: Integer]: PPicPropertyChange read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ��� ����������/������ ����� �����������, ���������� ��� ������� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaFilerEx = class(TPhoaFiler)
  protected
    procedure ValidateRevision; override;
  end;

   //*******************************************************************************************************************
   //  �������� � �����
   //*******************************************************************************************************************

   // ������� ��������, �� ���������� ��������� �����������

  TBaseOperation = class(TObject)
  end;

   // ������� (�����������) �������� �����������, ������������� ������ (������ ������), ������� ����� ���� ��������

  TPhoaOperation = class(TBaseOperation)
  private
     // Prop storage
    FSavepoint: Boolean;
    FPhoA: TPhotoAlbum;
     // Prop handlers
    function  GetOpGroup: TPhoaGroup;
    function  GetParentOpGroup: TPhoaGroup;
    procedure SetOpGroup(Value: TPhoaGroup);
    procedure SetParentOpGroup(Value: TPhoaGroup);
  protected
     // Prop storage
    FList: TPhoaOperations;
    FOpGroupID: Integer;
    FOpParentGroupID: Integer;
     // Prop handlers
    function GetInvalidationFlags: TUndoInvalidationFlags; virtual;
     // Props
     // -- ���������� ������, ��������������� GroupID
    property OpGroup: TPhoaGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� ParentGroupID
    property OpParentGroup: TPhoaGroup read GetParentOpGroup write SetParentOpGroup;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
    destructor Destroy; override;
    procedure Undo; virtual;
     // ������������ ��������
    function Name: String;
     // Props
     // -- ����� ���������� ���������� ����� ������ ��������
    property InvalidationFlags: TUndoInvalidationFlags read GetInvalidationFlags;
     // -- ID ������, ������� �������� �������� (���� ��������)
    property OpGroupID: Integer read FOpGroupID;
     // -- ID �������� ������, ������� �������� �������� (���� ��������)
    property OpParentGroupID: Integer read FOpParentGroupID;
     // -- ����������
    property PhoA: TPhotoAlbum read FPhoA;
     // -- ���������, ��� ����� ������ �������� ���� ����������� ���������� �����������, �.�., ���� ��� �������� -
     //    ��������� � ������ ������, �� ��� ��������� �� unmodified-��������� �����������
    property Savepoint: Boolean read FSavepoint;
  end;

   // ������ ��������� �������� (����� ������)
  TPhoaOperations = class(TList)
  private
     // True, ���� "������" ��������� ������ ������ ������������� ����������� ��������� �����������
    FSavepointOnEmpty: Boolean;
     // ������� ����������
    FUpdateLock: Integer;
     // Prop storage
    FOnStatusChange: TNotifyEvent;
    FOnOpUndone: TNotifyEvent;
    FOnOpDone: TNotifyEvent;
     // �������� OnStatusChange
    procedure DoStatusChange;
     // Prop handlers
    function  GetItems(Index: Integer): TPhoaOperation;
    function  GetLastOpName: String;
    function  GetCanUndo: Boolean;
    function  GetIsUnmodified: Boolean;
  protected
     // ���������� ���� ����� (������������� ��� ��������� ������� ������������� ��������)
    procedure UndoAll;
  public
    constructor Create;
    function  Add(Item: TPhoaOperation): Integer;
    function  Remove(Item: TPhoaOperation): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // �������������, ��� ������� ��������� ����������� �������� ����������
    procedure SetSavepoint;
     // �������������, ��� ������� ��������� �������� ����������������, �� ����� ����������
    procedure SetNonUndoable;
     // ���������/������ ����������
    procedure BeginUpdate;
    procedure EndUpdate; 
     // Props
     // -- ���������� True, ���� � ������ ���� �������� ��� ������
    property CanUndo: Boolean read GetCanUndo;
     // -- ���������� True, ���� ������� ��������� ������ ������ ������������� ����������� ��������� �����������
    property IsUnmodified: Boolean read GetIsUnmodified;
     // -- ��������������� ������ ��������
    property Items[Index: Integer]: TPhoaOperation read GetItems; default;
     // -- ���������� ������������ ��������� ��������� ��������
    property LastOpName: String read GetLastOpName;
     // -- �������, ����������� ��� ���������� �������� (������, ��� ����������� �������� � ������) 
    property OnOpDone: TNotifyEvent read FOnOpDone write FOnOpDone;
     // -- �������, ����������� ��� ������ �������� 
    property OnOpUndone: TNotifyEvent read FOnOpUndone write FOnOpUndone;
     // -- ������� ����� ��������� (����������� ������ - ���������� ��� ����������/�������� ��������, ��� ��������� SavePoint)
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
  end;

   // ����������� ��������, ��������� �� ���������� ��������. ��� ������ ���������� ��� �������� �����
  TPhoaMultiOp = class(TPhoaOperation)
  protected
     // ��������� ��������
    FOperations: TPhoaOperations;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
    destructor Destroy; override;
    procedure Undo; override;
     // Props
    property Operations: TPhoaOperations read FOperations;
  end;

   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   // �������� ��������
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������� ������ ������� � ������� ������ (CurGroup)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_GroupNew = class(TPhoaOperation)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; CurGroup: TPhoaGroup);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_GroupRename = class(TPhoaOperation)
  private
     // ������ ��� ������
    FOldText: String;
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText: String);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� ������� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_GroupEdit = class(TPhoaOp_GroupRename)
  private
     // ������ �������� ������
    FOldDescription: String;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText, sNewDescription: String);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  private
     // ������ �������� ��������� �����
    FCascadedDeletes: TPhoaOperations;
     // ������ �������� �������������� �����������
    FUnlinkedPicRemoves: TPhoaOperations;
     // ������ ID ����������� ������
    FPicIDs: TIntegerList;
     // ID ������
    FGroupID: Integer;
     // ������������ ������
    FGroupName: String;
     // ������ ������ �� ���������
    FGroupIndex: Integer;
     // True, ���� ���� ��� ��������
    FExpanded: Boolean;
     // ���������� ��������� ������
    procedure InternalUndo(gOwner: TPhoaGroup);
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
     // �������� bPerform ������������, ��������� �� �������� (� ����� ����� �������������� �����������). ������ ����
     //   True ��� ������ ��� ����������� �������� �������� ������. ��� ��������� ����� ����������� ���������� ��� �
     //   ���������� False (����� �������� � ������������ �������������� ����������� ����������� ������ ��������, �����
     //   ���������� ���� ��������� ��������� �����)
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; bPerform: Boolean);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� �������� ��������������� ����������� (������������ � TPhotoAlbum.RemoveUnlinkedPics)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_InternalPicRemoving = class(TPhoaOperation)
  private
     // �������� ���������� �����������
    FPicData: String;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ����������� �������� �������������� �����������, ������ ����������� ��� ��������:
   //  - TPhoaOp_InternalEditPicProps
   //  - TPhoaOp_InternalEditPicKeywords
   //  - TPhoaOp_InternalPicFromGroupRemoving
   //  - TPhoaOp_InternalPicToGroupAdding
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicEdit = class(TPhoaMultiOp)
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� �������������� ������� �����������, ����� �������� ����
   //-------------------------------------------------------------------------------------------------------------------

   // ������, ����������� ��������� �������� �����������
  TInternalPicPropSaveRec = record
    iPicID:   Integer;
    sPicData: String;
  end;

  TPhoaOp_InternalEditPicProps = class(TPhoaOperation)
  private
     // ��������� �������� �����������
    FChangedProps: TPicProperties;
     // ������ ������� �������� �������
    FSavedProps: Array of TInternalPicPropSaveRec;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; ChangeList: TPicPropertyChanges);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� �������������� �������� ���� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TKeywordList = class;

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  private
     // ������ ������� �������� ����, Objects[] - ID �����������
    FSavedKeywords: TStringList;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; Keywords: TKeywordList);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ���������� �������������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  private
     // ID �����������
    FPicID: Integer; 
     // ������� �������� ������� ��������������
    FSavedRotation: TPicRotation;
    FSavedFlips: TPicFlips;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic; NewRotation: TPicRotation; NewFlips: TPicFlips);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ���������� ���������� ����������� (������������ ��� ��������� ��� �������� TPhoaOp_InternalPicAdd)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicAdd = class(TPhoaMultiOp)
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� ���������� ����������� (������������ ��� ����� TPhoaMultiOp_PicAdd � TPhoaMultiOp_PicPaste)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_InternalPicAdd = class(TPhoaOperation)
  private
     // ID �����������
    FPicID: Integer;
     // True, ���� ���� ����������� ��� ��� ��������������� � ����������� �� ���������� �����������
    FExisting: Boolean;
     // Prop storage
    FAddedPic: TPhoaPic;
     // ������������ ����������� � ������, ���� ��� ��� �� ����, � ���������� ������ ������
    procedure RegisterPic(Group: TPhoaGroup; Pic: TPhoaPic);
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sFilename: String); overload;
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pic: TPhoaPic); overload;
    procedure Undo; override;
     // Props
     // -- ��������� ����������� ��� �������� �� �����
    property AddedPic: TPhoaPic read FAddedPic;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  private
     // ������ ID � �������� ����������� � ������ (� ���� ID1, ������1, ID2, ������2, ...)
    FIDsAndIndexes: TIntegerList;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  private
     // ������ ID �����������, ������� ����������� � ������ 
    FAddedIDs: TIntegerList;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ����������� � ����� ������ ���������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaBaseOp_PicCopy = class(TBaseOperation)
    constructor Create(const aPics: TPicArray);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ��������/��������� � ����� ������ ���������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicDelete = class(TPhoaMultiOp)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ������� ���������� ����������� �� ������ ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicPaste = class(TPhoaMultiOp)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� ������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_PhoAEdit = class(TPhoaOperation)
  private
     // ������ ������� ������
    FOldThumbnailWidth, FOldThumbnailHeight: Integer;
     // ������ �������� ������
    FOldThumbnailQuality: Byte;
     // ������ �������� �����������
    FOldDescription: String;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; iNewThWidth, iNewThHeight: Integer; bNewThQuality: Byte; const sNewDescription: String);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� [���]��������� �������� � �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicOperation = class(TPhoaMultiOp)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; const aSelPicIDs: TIDArray; PicOperation: TPictureOperation);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� �������� ���������� ����������� � ����� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  private
     // ������ ������� ������� ���������� ����������� ������
    FOldPicIDs: TIntegerList;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ���������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicSort = class(TPhoaMultiOp)
  private
     // ����������� (��� bRecursive=True) ���������, ��������� �������� ���������� ������
    procedure AddGroupSortOp(Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_GroupDragAndDrop = class(TPhoaOperation)
  private
     // ������� ������ ���� ������ � ��������
    FOldIndex: Integer;
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group, NewParentGroup: TPhoaGroup; iNewIndex: Integer);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� ����������� � ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMultiOp_PicDragAndDropToGroup = class(TPhoaMultiOp)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; aSelPicIDs: TIDArray; bCopy: Boolean);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������������� (������������������) ����������� ������ ������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  private
     // ������ ������ � ����� �������� ����������� � ������ (� ���� old_index1, new_index1, old_index2, new_index2, ...)
    FIndexes: TIntegerList;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray; idxNew: Integer);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ��������������� ��������� ��� ������ �� ������� �������������
   //-------------------------------------------------------------------------------------------------------------------

  IPhoaViews = interface(IInterface)
     // ��������� ������ ������������� � �������� ������������� � �������� idxSelect
    procedure LoadViewList(idxSelect: Integer);
     // Prop handlers
    function  GetViewIndex: Integer;
    procedure SetViewIndex(Value: Integer);
    function  GetViews: TPhoaViews;
     // Props
     // -- ������� ������ �������������
    property ViewIndex: Integer read GetViewIndex write SetViewIndex;
     // -- ������ �������������
    property Views: TPhoaViews read GetViews;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������� �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_ViewNew = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
     // ���������� ������ �������������
    FPrevViewIndex: Integer;
     // ������ ���������� �������������
    FNewViewIndex: Integer;
  public
    constructor Create(List: TPhoaOperations; ViewsIntf: IPhoaViews; const sName: String; Groupings: TPhoaGroupings; Sortings: TPhoaSortings);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� ��������� �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
     // ������� ������ �������������
    FOldName: String;
    FOldGroupings: TPhoaGroupings;
    FOldSortings: TPhoaSortings;
     // ����� ������ �������������
    FNewViewIndex: Integer;
  public
     // ���� NewGroupings=nil � NewSortings=nil, ������, ��� ������ �������������� �������������
    constructor Create(List: TPhoaOperations; View: TPhoaView; ViewsIntf: IPhoaViews; const sNewName: String; NewGroupings: TPhoaGroupings; NewSortings: TPhoaSortings);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������� �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
     // ������� ������ �������������
    FOldName: String;
    FOldGroupings: TPhoaGroupings;
    FOldSortings: TPhoaSortings;
  public
    constructor Create(List: TPhoaOperations; ViewsIntf: IPhoaViews);
    destructor Destroy; override;
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �������� �������� ������ ����������� �� �������������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
  public
     // Group - ������, ���� �������� ����� �������������
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; ViewsIntf: IPhoaViews);
    procedure Undo; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TThumbnailViewer - �������� ��������� ������� �����������
   //-------------------------------------------------------------------------------------------------------------------

   // ���������� ��������� ������� ������� ��������������� �������
  TViewerInsertionCoord = record
    iIndex: Integer; // ������ ������, ����� ������� ����� ���������� ����� �������, [0..ItemCount], ��� iIndex=ItemCount
                     //   ������ ������ ���� ��������� ����� ���������� ������
    bLower: Boolean; // ������������, ��� ��������� ��� ��������������� � ����������� ��������� ������� �������, �.�.
                     //   ����� idx ��������� �� �����, ����������� � ������ ������ � ��� ���� �� ����� ������� �����.
                     //   � ����� ������, ���� bLower=True, ������ �������� � ����� ���������� ������, ���� False - �
                     //   ������ ������� (����� �� ������� ������)
  end;

   // ���� ������
  TThumbCorner = (tcLeftTop, tcRightTop, tcLeftBottom, tcRightBottom);

  TThumbCornerDetail = record
    bDisplay: Boolean;      // True, ���� �������� � ������ ���� ������������
    Prop:     TPicProperty; // �������� ��� �����������
  end;

  TThumbCornerDetails = Array[TThumbCorner] of TThumbCornerDetail;

  TThumbnailViewer = class(TCustomControl)
  private
     // ������ ������ �� ����������� ������, ����������� ������� ViewGroup()
    FPicLinks: TPhoaPicLinks;
     // ���������� �������� � ��������
    FColCount: Integer;
     // ������ �������� ���������� �������
    FSelIndexes: TIntegerList;
     // ������ ������ �������� ������ ������������� ������
    FTopIndex: Integer;
     // ����� ���������� �������
    FItemCount: Integer;
     // ������ ��������� ������
    FItemIndex: Integer;
     // ���������� �������, ������� �������������� � ���� ��������
    FVisibleItems: Integer;
     // ��� bmp-����������� �������
    FThumbCache: TList;
     // ������ � ������ ������ ��� ������������� ������ (� ������ ��������)
    FWCell: Integer;
    FHCell: Integer;
     // ������ ������, � �������� �������� �������� ��������� (Shift+[�������] ��� Shift+[����])
    FStreamSelStart: Integer;
     // ������ ������, ������� ����� ������� (ItemIndex), ���� ������������ ������ ����� ������ ����, �� ������� ����
    FNoMoveItemIndex: Integer;
     // ���� �������� ����� � Dragging
    FDragPending: Boolean;
     // ���������� ������� ����� ��� Dragging/Marqueing
    FStartPos: TPoint;
     // ������� � ������� ���������� ������� ��������������� �������
    FDragTargetCoord: TViewerInsertionCoord;
    FOldDragTargetCoord: TViewerInsertionCoord;
     // ����� ��� ���������� �������� ���������� ��� Drag'n'Drop
    FLastDragScrollTicks: Cardinal;
     // ������� ����������
    FUpdateLock: Integer;
     // ���� ��� ����� ���������� ��������� (marquee)
    FTempDC: HDC;
    FMarqueing: Boolean;
    FMarqueeCur: TPoint;
     // ������, ������������ � ����� �������
    FThumbCornerDetails: TThumbCornerDetails;
     // ������ ������, ��� �������� ��������� ��� ����������� Tooltip
    FLastTooltipIdx: Integer;
     // True, ���� ���� ������ ������ ������� ���� ������ � Ctrl, � ��� � ���������� ���������� ���������� ���������
     //   ����������� ����
    FShellCtxMenuOnMouseUp: Boolean;
     // Props storage
    FPhoA: TPhotoAlbum;
    FGroupID: Integer;
    FCacheThumbnails: Boolean;
    FThickThumbBorder: Boolean;
    FOnSelectionChange: TNotifyEvent;
    FBorderStyle: TBorderStyle;
    FDragEnabled: Boolean;
    FShowThumbTooltips: Boolean;
    FThumbTooltipProps: TPicProperties;
    FThumbCacheSize: Integer;
    FThumbBackColor: TColor;
    FThumbFontColor: TColor;
     // ���������� ���������� ������� � �������
    procedure CalcLayout;
     // ������������ ���� �����
    procedure PaintThumb(idx: Integer; bmp: TBitmap);
     // ������� ��������� �� ���� ������� � ���������� True, ���� ��� ����
    function  ClearSelection: Boolean;
     // ������ ��� ������� ��������� � ������
    procedure ToggleSelection(Index: Integer);
    procedure AddToSelection(Index: Integer);
    procedure RemoveFromSelection(Index: Integer);
     // ���������� ItemIndex �� ����� �����, �� ������ ���������. ��� bUpdateStreamSelStart=True ����� ���������
     //   FStreamSelStart
    procedure MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart: Boolean);
     // �������� ������� OnSelectionChange
    procedure SelectionChange;
     // ���������� ������ �� ������������ ����� _Pic, ���� �� ���� � ����, ����� ���������� nil
    function  GetCachedThumb(_Pic: TPhoaPic): TBitmap;
     // �������� ����� � ���. ����� ����� ��� ���������� ���������� Bitmap. ������ ���������� ������ � ��� ������, ����
     //   � ���� ��� ������� �����������!
    procedure PutThumbToCache(Pic: TPhoaPic; Bitmap: TBitmap);
     // ������� ������ ���� �� iNumber ����������� ��� ������, ���� ����������� ���������
    procedure LimitCacheSize(iNumber: Integer);
     // ���������� ���������� TopIndex �� ������ �������������
    function  GetValidTopIndex(idxOffered: Integer): Integer;
     // ������� ��������� �������� ������ �����������
    procedure PhoaThumbDimensionsChanged(Sender: TObject);
     // ����������� ScrollBar
    procedure UpdateScrollBar;
     // �������� �������� �������� ������� � �������� ItemIndex � idxEnd
    procedure SelectRange(idxStart, idxEnd: Integer);
     // ������ � ������ ���������� ��������� (marquee)
    procedure PaintMarquee;
    procedure MarqueingStart;
    procedure MarqueingEnd;
     // ������������ ������ ������� ��������������� �������. ���� bInvalidate=True, ����� ��������� ���������� iIndex �
     //   -1 � bLower � False
    procedure DragDrawInsertionPoint(var Coord: TViewerInsertionCoord; bInvalidate: Boolean);
     // ����������� ����������� �������� ������� � ���� Hint
    procedure AdjustTooltip(ix, iy: Integer);
     // Message handlers
    procedure WMContextMenu(var Msg: TWMContextMenu);           message WM_CONTEXTMENU;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode);             message WM_GETDLGCODE;
    procedure WMWindowPosChanged(var Msg: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMVScroll(var Msg: TWMVScroll);                   message WM_VSCROLL;
    procedure WMNCPaint(var Msg: TWMNCPaint);                   message WM_NCPAINT;
    procedure CMDrag(var Msg: TCMDrag);                         message CM_DRAG;
     // Prop handlers
    procedure SetBorderStyle(Value: TBorderStyle);
    function  GetSelCount: Integer;
    procedure SetItemIndex(Value: Integer);
    procedure SetTopIndex(Value: Integer);
    procedure SetCacheThumbnails(Value: Boolean);
    procedure SetThickThumbBorder(Value: Boolean);
    function  GetSelectedIndexes(Index: Integer): Integer;
    procedure SetPhoA(Value: TPhotoAlbum);
    function  GetIDSelected(iID: Integer): Boolean;
    function  GetSelectedPics(Index: Integer): TPhoaPic;
    function  GetDropTargetIndex: Integer;
    function  GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
    procedure SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
    procedure SetShowThumbTooltips(Value: Boolean);
    procedure SetThumbTooltipProps(Value: TPicProperties);
    procedure SetThumbCacheSize(Value: Integer);
    procedure SetThumbBackColor(Value: TColor);
    procedure SetThumbFontColor(const Value: TColor);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Msg: TMessage); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
     // ������������� ������ Group ��� ��������� � �������� �������
    procedure SetCurrentGroup(Group: TPhoaGroup);
     // ������� ��������� �� ���� �������
    procedure SelectNone;
     // �������� ��� ������
    procedure SelectAll;
     // ���������� ������ ���������� �����������
    function  GetSelectedPicArray: TPicArray;
     // ���������� ItemIndex � �����, ��� -1, ���� ��� ��� ������
    function  ItemAtPos(ix, iy: Integer): Integer;
     // ���������� ���������� ������ � �������� Index (���� ���� ������ ������ ��� � ������!)
    function  ItemRect(Index: Integer): TRect;
     // ������ ����� � ������� �� ����������
    procedure InvalidateItem(Index: Integer);
     // ������������ ����������, ����� ���� ����� ItemIndex
    procedure ScrollIntoView;
     // ���������� �����������
    procedure BeginUpdate;
    procedure EndUpdate;
     // Props
     // -- ����, ����������� �������������� �������
    property DragEnabled: Boolean read FDragEnabled write FDragEnabled;
     // -- ������ ���������� ����� ������� ��� Drag'n'Drop. -1, ���� �� ���� �����������
    property DropTargetIndex: Integer read GetDropTargetIndex;
     // -- ID ������, ������������ � ������ ������ (0, ���� ���)
    property GroupID: Integer read FGroupID;
     // -- True, ���� ����������� � �������� ID ��������
    property IDSelected[iID: Integer]: Boolean read GetIDSelected;
     // -- ������ ���������������� �����������
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
     // -- ����������, � ������� ������ viewer
    property PhoA: TPhotoAlbum read FPhoA write SetPhoA;
     // -- ���������� ���������� �����������
    property SelCount: Integer read GetSelCount;
     // -- ������� ���������� ����������� � ����� ������ ����������� viewer'� (Index - ������ ����������� �����������,
     //    0..SelCount-1)
    property SelectedIndexes[Index: Integer]: Integer read GetSelectedIndexes;
     // -- ���������� ����������� (Index - ������ ����������� �����������, 0..SelCount-1)
    property SelectedPics[Index: Integer]: TPhoaPic read GetSelectedPics;
     // -- ���� True, ���������� ����������� �������� �������
    property ShowThumbTooltips: Boolean read FShowThumbTooltips write SetShowThumbTooltips;
     // -- ������ ���� �������
    property ThumbCacheSize: Integer read FThumbCacheSize write SetThumbCacheSize;
     // -- ������, ������������ �� �������
    property ThumbCornerDetails[Corner: TThumbCorner]: TThumbCornerDetail read GetThumbCornerDetails write SetThumbCornerDetails;
     // -- ������, ������������ �� ����������� ��������� �������
    property ThumbTooltipProps: TPicProperties read FThumbTooltipProps write SetThumbTooltipProps;
     // -- ������ ������, ������������ � ����� ������� ����
    property TopIndex: Integer read FTopIndex write SetTopIndex;
  published
    property Align;
    property Anchors;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property BiDiMode;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
     // -- ���������� �� ������ ��� ���������
    property CacheThumbnails: Boolean read FCacheThumbnails write SetCacheThumbnails default True;
    property Color default clBtnFace;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property Enabled;
    property Font;
    property ImeMode;
    property ImeName;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
     // -- ���� True, ����� ������ �������� ����� �����
    property ThickThumbBorder: Boolean read FThickThumbBorder write SetThickThumbBorder default False;
     // -- ���� ���� �������
    property ThumbBackColor: TColor read FThumbBackColor write SetThumbBackColor default clBtnFace;
     // -- ���� ������ �������
    property ThumbFontColor: TColor read FThumbFontColor write SetThumbFontColor default clWindowText;
    property Visible;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
     // -- ������� ��������� ��������� �� viewer'�
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange write FOnSelectionChange;
    property OnStartDock;
    property OnStartDrag;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ���������, �������������� ����� ����� � ��� ������� (������ ����������� �������� #9, ������ ������
   // ������������� �� ������ ����, ������ - �� �������)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoAHintWindow = class(THintWindow)
    procedure Paint; override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // "������" ��� ��������� �������� �����
   //-------------------------------------------------------------------------------------------------------------------

  TSizeGripper = class(TCustomControl)
  private
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure Paint; override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ���������� � ����� � ������ ������� ������
   //-------------------------------------------------------------------------------------------------------------------

   // ������ � ������� � �����
  PFileRec = ^TFileRec;
  TFileRec = record
    sName: String;        // ��� �����
    sPath: String;        // ���� � �����
    iSize: Integer;       // ������ ����� � ������
    iIconIndex: Integer;  // ������ ������ �� ���������� ImageList'�, -1 ���� ���
    dModified: TDateTime; // ����/����� ����������� �����
    bChecked: Boolean;    // True, ���� ���� ������� (custom value), �� ��������� False
  end;

   // ����� ���������� ������ ������
  TFileListSortProperty = (flspName, flspPath, flspSize, flspDate);

  TFileList = class(TList)
  private
     // Prop storage
    FSysImageListHandle: THandle;
     // ���������� ��������� ����������
    procedure InternalQuickSort(iL, iR: Integer; Prop: TFileListSortProperty; Order: TSortOrder);
     // Prop handlers
    function GetItems(Index: Integer): PFileRec;
    function GetFiles(Index: Integer): String;
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
     // ��������� ������ � ����� � ������, ���� ������ ����� ��� ���, ����� ��������� ��� ������
     //   ���� _iIconIndex=-1, ��� �������� ���������� ������ � �����
     //   ���� _iIconIndex=-2, ������ ����� ���������� ������� SHGetFileInfo; Handle ���������� ImageList'� � ����
     //     ������ ����� ���������� � SysImageListHandle
    function  Add(const _sName, _sPath: String; _iSize, _iIconIndex: Integer; const _dModified: TDateTime): Integer;
     // ������� ���� � ��������� ������ � ����, ���������� ��� ������� ������ ��� -1, ���� ��� ������ � ������
    function  Remove(const _sName, _sPath: String): Integer;
     // ���������� ������ ����� � ��������� ������ � ����, ��� -1, ���� ��� ������ � ������
    function  IndexOf(const _sName, _sPath: String): Integer;
     // ��������� ������ ������ �� ��������� ��������
    procedure Sort(Prop: TFileListSortProperty; Order: TSortOrder);
     // ��������� � ������ ������ ���������� (bChecked) �����
    procedure DeleteUnchecked;
     // Props
     // -- ������ ���� � ������ �� �������
    property Files[Index: Integer]: String read GetFiles; 
     // -- �������� ������ �� �������
    property Items[Index: Integer]: PFileRec read GetItems; default;
     // -- Handle ���������� ImageList'� ����� ����������� ������ ����� � Add()
    property SysImageListHandle: THandle read FSysImageListHandle;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ �������� ����
   //-------------------------------------------------------------------------------------------------------------------

   // ��������� ��������� [������] ��������� �����
  TKeywordChange = (kcNone, kcAdd, kcReplace);
   // ��������� ������ ��������� �����
  TKeywordState  = (ksOff, ksGrayed, ksOn);

  PKeywordRec = ^TKeywordRec;
  TKeywordRec = record
    sKeyword:    String;         // �������� ����� (�����, ���� ����� �������������)
    sOldKeyword: String;         // ������� �������� �����, ���� ����� �������� ������������ �� ������
    Change:      TKeywordChange; // ��������� ��������� [������] ��������� �����
    State:       TKeywordState;  // ��������� ������ ��������� �����
    iCount:      Integer;        // ���������� ��������� � ���������� (��� ������������, �.�. Change<>kcAdd)
    iSelCount:   Integer;        // ���������� ���������� ����� ��������� ����������� (����������� � PopulateFromPhoA
                                 //   ��� �������������� Callback-���������)
  end;

   // Callback-���������, ���������� �� TKeywordList.PopulateFromPhoA() ��� �����������, ������� �����������, ��� ���
  TKeywordIsPicSelectedProc = procedure(Pic: TPhoaPic; out bSelected: Boolean) of object;

  TKeywordList = class(TList)
  private
     // Prop handlers
    function  GetItems(Index: Integer): PKeywordRec;
    function  GetSelectedKeywords: String;
    procedure SetSelectedKeywords(const Value: String);
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
     // ��������� �����. ��� ��������� ���������� ����� ��� �� �����������, ������ ������������� �������. ����
     //   bSelected=True, ������������� ����� ������� iSelCount
    function  Add(const s: String; bSelected: Boolean): Integer;
     // ���������� ������, ���� ����� �������� ����� (� ������ ����������) ��� ��� ��� ��� ����. ���������� True, ����
     //   ��� ����� ��� ���� � ������, ����� False
    function  FindKeyword(const s: String; out Index: Integer): Boolean;
     // ��������� ������ �� ������ �������� ���� ����������� �� �����������. ���� �������� ��������� IsPicSelCallback,
     //   ����������� ����������� �������� TKeywordRec.iSelCount, � ������������ � iTotalSelCount ������������
     //   TKeywordRec.State
    procedure PopulateFromPhoA(PhoA: TPhotoAlbum; IsPicSelCallback: TKeywordIsPicSelectedProc; iTotalSelCount: Integer);
     // �������� ����� �� �����, �������� ���������� ������ ����� � ������ (���� ��� ���� - ���������� Exception).
     //   ��� ������ ���������� ��� �� ����� ����� � ������ ����������, ��������� ����� ������. ����������� ���������
     //   (TKeywordRec.Change)
    function  Rename(Index: Integer; const sNewKeyword: String): Integer;
     // ��������� ����� ����� � ���������� ������ � ���������� ��� ������ � ������
    function  InsertNew: Integer;
     // Props
     // -- ������ �� �������
    property Items[Index: Integer]: PKeywordRec read GetItems; default;
     // -- ���������� ������� ��������� �����. ��� ������������ ����������� ����������� ����
    property SelectedKeywords: String read GetSelectedKeywords write SetSelectedKeywords;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ����� ��� �������� ��� ������, �������������� ��������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMask = class(TMask)
  private
    FNegative: Boolean;
  public
    constructor Create(const sMask: String; bNegative: Boolean);
     // ���������� True, ���� ��� ����� [��]������������� �����
    function Matches(const sFilename: String): Boolean;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ������ ����� (��� �������� ��� ������)
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaMasks = class(TObject)
  private
    FMasks: TList;
    function GetEmpty: Boolean;
  public
     // ��������� �� ���� ������ �����, ���������� �������� ';'
    constructor Create(const sMasks: String);
    destructor Destroy; override;
     // ���������� True, ���� ��� ����� ������������� ����� �� �����
    function Matches(const sFilename: String): Boolean;
     // Props
     // -- True, ���� ��� �������� �����, � Matches ����� True � ����� ������
    property Empty: Boolean read GetEmpty;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ��������� ������ PhoA
   //-------------------------------------------------------------------------------------------------------------------

  TCmdLineKey = (
    clkOpenPhoa,    // ������� ���������� <��������>
    clkSelectView,  // ������� � ����� ����������� ������������� <��������>
    clkSelectGroup, // �������� � ������ ������ <��������>
    clkSelectPicID, // ���������� ����������� � ID=<��������>
    clkViewMode,    // ������� � ����� ���������
    clkSlideShow,   // �������� ����� �������� ����� ������� ���������
    clkFullScreen); // ������������� ����� ��������� (<��������>=1. ��� <��������>=0 - �� ������������� ����� ���������)
  TCmdLineKeys = set of TCmdLineKey;

   // ����������� ����� � ��������
  TCmdLineKeyValueMode = (
    clkvmNo,        // � ����� �� ������ ��������
    clkvmOptional,  // � ����� ����� ����, � ����� � �� ���� ��������
    clkvmRequired); // � ����� ������ ���� ��������

   // Exception
  EPhoaCommandLineError = class(EPhoaException);

  TPhoaCommandLine = class(TObject)
  private
     // ������ ������/�������� (Strings[] - ��������, Objects[] - �����)
    FKeyValues: TStringList;
     // Prop storage
    FKeys: TCmdLineKeys;
     // ��������� ������� ��������� ������
    procedure ParseCmdLine;
     // ���������� ������ �������� ��� ����� � FKeyValues ��� -1, ���� ��� ������
    function  KeyValIndex(Key: TCmdLineKey): Integer;
     // Prop handlers
    function  GetKeyValues(Key: TCmdLineKey): String;
  public
    constructor Create;
    destructor Destroy; override;
     // Props
     // -- ����� ������, ��������� � ��������� ������
    property Keys: TCmdLineKeys read FKeys;
     // -- �������� ������, ��������� � ��������� ������
    property KeyValues[Key: TCmdLineKey]: String read GetKeyValues;
  end;

   // ��������� ������
const
   aCmdLineKeys: Array[TCmdLineKey] of
     record
       ValueMode: TCmdLineKeyValueMode; // ����������� ����� � ��������
       cChar:     Char;                 // ������ (���) �����
     end = (
     (ValueMode: clkvmOptional; cChar: #0),   // clkOpenPhoa
     (ValueMode: clkvmRequired; cChar: 'w'),  // clkSelectView
     (ValueMode: clkvmRequired; cChar: 'g'),  // clkSelectGroup
     (ValueMode: clkvmRequired; cChar: 'i'),  // clkSelectPicID
     (ValueMode: clkvmNo;       cChar: 'v'),  // clkViewMode
     (ValueMode: clkvmNo;       cChar: 's'),  // clkSlideShow
     (ValueMode: clkvmOptional; cChar: 'f')); // clkFullScreen

resourcestring
  SCmdLineErrMsg_UnknownKey             = 'Unknown command line key: "%s"';
  SCmdLineErrMsg_DuplicateKey           = 'Duplicate key "%s" in the command line';
  SCmdLineErrMsg_KeyNameInvalid         = 'Key name invalid in the command line ("%s")';
  SCmdLineErrMsg_DuplicateOpenPhoaValue = 'Duplicate .phoa file to open specified in the command line';
  SCmdLineErrMsg_DuplicateKeyValue      = 'Duplicate value for key "%s" specified in the command line';
  SCmdLineErrMsg_KeyValueMissing        = 'Value for key "%s" is missing in the command line';

   //-------------------------------------------------------------------------------------------------------------------

   // ��������� � TStrings �����, ������ ����� � ������� �� ����������� �����������
  procedure StringsLoadPFAM(PhoA: TPhotoAlbum; SLPlaces, SLFilmNumbers, SLAuthors, SLMedia: TStrings);

   // ������������ ID �� TPicArray � TIDArray
  function PicArrayToIDArray(const Pics: TPicArray): TIDArray;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Variants, Math, Registry, DateUtils, StrUtils, Clipbrd, ShellAPI, Themes, JPEG, VirtualDataObject,
  phUtils, phSettings, udMsgBox, phGraphics;

type
   // ������ ���� ������
  PThumbCacheRec = ^TThumbCacheRec;
  TThumbCacheRec = record
    Pic: TPhoaPic;
    Thumb: TBitmap;
  end;

  function OrderRect(const r: TRect): TRect;
  begin
    if r.Left<r.Right then begin
      Result.Left   := r.Left;
      Result.Right  := r.Right;
    end else begin
      Result.Left   := r.Right;
      Result.Right  := r.Left;
    end;
    if r.Top<r.Bottom then begin
      Result.Top    := r.Top;
      Result.Bottom := r.Bottom;
    end else begin
      Result.Top    := r.Bottom;
      Result.Bottom := r.Top;
    end;
  end;

  procedure PhoaWriteError;
  begin
    PhoaException(ConstVal('SErrCannotWrite'), []);
  end;

  procedure PhoaReadError;
  begin
    PhoaException(ConstVal('SErrCannotRead'), []);
  end;

   //==========================================================================
   // ������ � ��������
   //==========================================================================

  procedure WriteByte(Stream: TStream; b: Byte);
  begin
    if Stream.Write(b, SizeOf(b))<>SizeOf(b) then PhoaWriteError;
  end;

  procedure WriteInt(Stream: TStream; i: Integer);
  begin
    if Stream.Write(i, SizeOf(i))<>SizeOf(i) then PhoaWriteError;
  end;

  procedure WriteDbl(Stream: TStream; const d: Double);
  begin
    if Stream.Write(d, SizeOf(d))<>SizeOf(d) then PhoaWriteError;
  end;

  procedure WriteStr(Stream: TStream; const s: String);
  var i: Integer;
  begin
    i := Length(s);
    WriteInt(Stream, i);
    if (i>0) and (Stream.Write(s[1], i)<>i) then PhoaWriteError;
  end;

  function ReadByte(Stream: TStream): Byte;
  begin
    if Stream.Read(Result, SizeOf(Result))<>SizeOf(Result) then PhoaReadError;
  end;

  function ReadInt(Stream: TStream): Integer;
  begin
    if Stream.Read(Result, SizeOf(Result))<>SizeOf(Result) then PhoaReadError;
  end;

  function ReadDbl(Stream: TStream): Double;
  begin
    if Stream.Read(Result, SizeOf(Result))<>SizeOf(Result) then PhoaReadError;
  end;

  function ReadStr(Stream: TStream): String;
  var i: Integer;
  begin
    i := ReadInt(Stream);
    SetLength(Result, i);
    if (i>0) and (Stream.Read(Result[1], i)<>i) then PhoaReadError;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // Misc routines
   //-------------------------------------------------------------------------------------------------------------------

  procedure StringsLoadPFAM(PhoA: TPhotoAlbum; SLPlaces, SLFilmNumbers, SLAuthors, SLMedia: TStrings);
  var i: Integer;

    procedure AddStr(SL: TStrings; const s: String);
    begin
      if s<>'' then
        if SL.IndexOf(s)<0 then SL.Add(s);
    end;

  begin
    SLPlaces.BeginUpdate;
    SLFilmNumbers.BeginUpdate;
    SLAuthors.BeginUpdate;
    SLMedia.BeginUpdate;
    try
      SLPlaces.Clear;
      SLFilmNumbers.Clear;
      SLAuthors.Clear;
      SLMedia.Clear;
       // ������ ���� �� ���� ������������
      for i := 0 to PhoA.Pics.Count-1 do
        with PhoA.Pics[i] do begin
          AddStr(SLPlaces,      PicPlace);
          AddStr(SLFilmNumbers, PicFilmNumber);
          AddStr(SLAuthors,     PicAuthor);
          AddStr(SLMedia,       PicMedia);
        end;
    finally
      SLPlaces.EndUpdate;
      SLFilmNumbers.EndUpdate;
      SLAuthors.EndUpdate;
      SLMedia.EndUpdate;
    end;
  end;

  function PicArrayToIDArray(const Pics: TPicArray): TIDArray;
  var i: Integer;
  begin
    SetLength(Result, Length(Pics));
    for i := 0 to High(Pics) do Result[i] := Pics[i].ID;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TIntegerList
   //-------------------------------------------------------------------------------------------------------------------

  function TIntegerList.Add(i: Integer): Boolean;
  begin
    Result := FAllowDuplicates or (IndexOf(i)<0);
    if Result then inherited Add(Pointer(i));
  end;

  function TIntegerList.AddAll(SourceList: TIntegerList): Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to SourceList.Count-1 do
      if Add(SourceList[i]) then Inc(Result);
  end;

  constructor TIntegerList.Create(bAllowDuplicates: Boolean);
  begin
    inherited Create;
    FAllowDuplicates := bAllowDuplicates;
  end;

  function TIntegerList.GetItems(Index: Integer): Integer;
  begin
    Result := Integer(inherited Items[Index]);
  end;

  function TIntegerList.IndexOf(i: Integer): Integer;
  begin
    Result := inherited IndexOf(Pointer(i));
  end;

  function  TIntegerList.Insert(Index, i: Integer): Boolean;
  begin
    Result := FAllowDuplicates or (IndexOf(i)<0);
    if Result then inherited Insert(Index, Pointer(i));
  end;

  function TIntegerList.Remove(i: Integer): Integer;
  begin
    Result := inherited Remove(Pointer(i));
  end;

  procedure TIntegerList.Sort(CompareFunc: TIntegerListSortSompareFunc; pData: Pointer);

    procedure DoSort(iL, iR: Integer);
    var i1, i2, iv: Integer;
    begin
      repeat
        i1 := iL;
        i2 := iR;
        iv := GetItems((iL+iR) shr 1);
        repeat
          while CompareFunc(GetItems(i1), iv, pData)<0 do Inc(i1);
          while CompareFunc(GetItems(i2), iv, pData)>0 do Dec(i2);
          if i1<=i2 then begin
            Exchange(i1, i2);
            Inc(i1);
            Dec(i2);
          end;
        until i1>i2;
        if iL<i2 then DoSort(iL, i2);
        iL := i1;
      until i1>=iR;
    end;

  begin
    if Count>0 then DoSort(0, Count-1);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaPicLinks
   //-------------------------------------------------------------------------------------------------------------------

  function TPhoaPicLinks.Add(Pic: TPhoaPic): Integer;
  begin
    if not FSorted then Result := inherited Add(Pic)
    else if not FindID(Pic.ID, Result) then Insert(Result, Pic);
  end;

  procedure TPhoaPicLinks.AddFromGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bReplace: Boolean);
  var i: Integer;
  begin
    if bReplace then Clear;
     // �������� ������ �� �����������, ������������� ������
    if Group<>nil then
      for i := 0 to Group.PicIDs.Count-1 do Add(PhoA.Pics.PicByID(Group.PicIDs[i]));
  end;

  procedure TPhoaPicLinks.AddFromPicIDs(PhoA: TPhotoAlbum; const aPicIDs: TIDArray; bReplace: Boolean);
  var i: Integer;
  begin
    if bReplace then Clear;
    for i := 0 to High(aPicIDs) do Add(PhoA.Pics.PicByID(aPicIDs[i]));
  end;

  procedure TPhoaPicLinks.Assign(Src: TPhoaPics; RestrictLinks: TPhoaPicLinks);
  var
    i: Integer;
    Pic: TPhoaPic;
  begin
    if RestrictLinks=nil then
      inherited Assign(Src)
    else begin
      Clear;
      for i := 0 to Src.Count-1 do begin
        Pic := Src[i];
        if RestrictLinks.IndexOfID(Pic.ID)>=0 then Add(Pic);
      end;
    end;
  end;

  procedure TPhoaPicLinks.CopyFromPhoa(PhoA: TPhotoAlbum);
  begin
    Assign(PhoA.Pics, nil);
  end;

  procedure TPhoaPicLinks.CopyToGroup(Group: TPhoaGroup);
  var i: Integer;
  begin
    Group.PicIDs.Clear;
    for i := 0 to Count-1 do Group.PicIDs.Add(GetItems(i).ID);
  end;

  constructor TPhoaPicLinks.Create(bSorted: Boolean);
  begin
    inherited Create;
    FSorted := bSorted;
  end;

  function TPhoaPicLinks.FindID(iID: Integer; var Index: Integer): Boolean;
  var i1, i2, i, iCompare: Integer;
  begin
    Result := False;
     // ���� ������ ������������� - ���� � ������� ��������� ������
    if FSorted then begin
      i1 := 0;
      i2 := Count-1;
      while i1<=i2 do begin
        i := (i1+i2) shr 1;
        iCompare := GetItems(i).ID-iID;
        if iCompare<0 then
          i1 := i+1
        else begin
          i2 := i-1;
          if iCompare=0 then begin
            Result := True;
            i1 := i;
          end;
        end;
      end;
      Index := i1;
     // ����� - ���� ������� ��������� 
    end else begin
      for i := 0 to Count-1 do
        if GetItems(i).ID=iID then begin
          Result := True;
          Index := i;
          Exit;
        end;
      Index := Count;
    end;
  end;

  function TPhoaPicLinks.GetItems(Index: Integer): TPhoaPic;
  begin
    Result := TPhoaPic(inherited Items[Index]);
  end;

  function TPhoaPicLinks.IndexOfID(iID: Integer): Integer;
  begin
    if not FindID(iID, Result) then Result := -1;
  end;

  function TPhoaPicLinks.PicByFileName(const sFileName: String): TPhoaPic;
  var i: Integer;
  begin
    for i := 0 to Count-1 do begin
      Result := GetItems(i);
      if ReverseCompare(Result.PicFileName, sFileName) then Exit;
    end;
    Result := nil;
  end;

  function TPhoaPicLinks.PicByID(iID: Integer): TPhoaPic;
  var idx: Integer;
  begin
    if FindID(iID, idx) then Result := GetItems(idx) else Result := nil;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaSortings
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaSortings.Add(_Prop: TPicProperty; _Order: TSortOrder);
  var ps: TPhoaSorting;
  begin
    with ps do begin
      Prop    := _Prop;
      Order   := _Order;
      wUnused := 0;
    end;
    inherited Add(Pointer(ps));
  end;

  function TPhoaSortings.GetItems(Index: Integer): TPhoaSorting;
  begin
    Result := TPhoaSorting(inherited Items[Index]);
  end;

  function TPhoaSortings.IdenticalWith(Sortings: TPhoaSortings): Boolean;
  var i: Integer;
  begin
    Result := Count=Sortings.Count;
    if Result then
      for i := 0 to Count-1 do
        with GetItems(i) do
          if (Prop<>Sortings[i].Prop) or (Order<>Sortings[i].Order) then begin
            Result := False;
            Exit;
          end;
  end;

  function TPhoaSortings.IndexOf(Prop: TPicProperty): Integer;
  begin
    for Result := 0 to Count-1 do
      if GetItems(Result).Prop=Prop then Exit;
    Result := -1;
  end;

  procedure TPhoaSortings.RegLoad(const sSection: String);
  var
    sl: TStringList;
    i: Integer;
  begin
    sl := TStringList.Create;
    try
      with TRegIniFile.Create(SRegRoot) do
        try
          ReadSectionValues(sSection, sl);
        finally
          Free;
        end;
       // ���� ���� �����-�� ����������, ������������ ��
      if sl.Count>0 then begin
        Clear;
        for i := 0 to sl.Count-1 do inherited Add(Pointer(StrToIntDef(sl.ValueFromIndex[i], 0)));
       // ����� ���� �� ��������� 
      end else
        RevertToDefaults;
    finally
      sl.Free;
    end;
  end;

  procedure TPhoaSortings.RegSave(const sSection: String);
  var i: Integer;
  begin
    with TRegIniFile.Create(SRegRoot) do
      try
        EraseSection(sSection);
        for i := 0 to Count-1 do WriteInteger(sSection, 'Item'+IntToStr(i), Integer(inherited Items[i]));
      finally
        Free;
      end;
  end;

  procedure TPhoaSortings.RevertToDefaults;
  begin
    Clear;
    Add(ppDate,        soAsc);
    Add(ppFrameNumber, soAsc);
  end;

  procedure TPhoaSortings.SetProp(Index: Integer; Prop: TPicProperty);
  var ps: TPhoaSorting;
  begin
    ps := GetItems(Index);
    ps.Prop := Prop;
    inherited Items[Index] := Pointer(ps);
  end;

  function TPhoaSortings.SortComparePics(Pic1, Pic2: TPhoaPic): Integer;
  var
    i: Integer;
    ps: TPhoaSorting;
  begin
    Result := 0;
    for i := 0 to Count-1 do begin
      ps := GetItems(i);
      case ps.Prop of
        ppID:              Result := Pic1.ID-Pic2.ID;
        ppFileName:        Result := AnsiCompareText(ExtractFileName(Pic1.PicFileName), ExtractFileName(Pic2.PicFileName));
        ppFullFileName:    Result := AnsiCompareText(Pic1.PicFileName, Pic2.PicFileName);
        ppFilePath:        Result := AnsiCompareText(ExtractFilePath(Pic1.PicFileName), ExtractFilePath(Pic2.PicFileName));
        ppFileSize,
          ppFileSizeBytes: Result := Pic1.PicFileSize-Pic2.PicFileSize;
        ppPicWidth:        Result := Pic1.PicWidth-Pic2.PicWidth;
        ppPicHeight:       Result := Pic1.PicHeight-Pic2.PicHeight;
        ppPicDims:         Result := (Pic1.PicWidth*Pic1.PicHeight)-(Pic2.PicWidth*Pic2.PicHeight);
        ppFormat:          Result := Byte(Pic1.PicFormat)-Byte(Pic2.PicFormat);
        ppDate:            Result := Trunc(Pic1.PicDateTime)-Trunc(Pic2.PicDateTime);
        ppTime:            Result := Sign(Frac(Pic1.PicDateTime)-Frac(Pic2.PicDateTime));
        ppPlace:           Result := AnsiCompareText(Pic1.PicPlace,         Pic2.PicPlace);
        ppFilmNumber:      Result := AnsiCompareText(Pic1.PicFilmNumber,    Pic2.PicFilmNumber);
        ppFrameNumber:     Result := AnsiCompareText(Pic1.PicFrameNumber,   Pic2.PicFrameNumber);
        ppAuthor:          Result := AnsiCompareText(Pic1.PicAuthor,        Pic2.PicAuthor);
        ppDescription:     Result := AnsiCompareText(Pic1.PicDesc,          Pic2.PicDesc);
        ppNotes:           Result := AnsiCompareText(Pic1.PicNotes,         Pic2.PicNotes);
        ppMedia:           Result := AnsiCompareText(Pic1.PicMedia,         Pic2.PicMedia);
        ppKeywords:        Result := AnsiCompareText(Pic1.PicKeywords.Text, Pic2.PicKeywords.Text);
        ppRotation:        Result := Ord(Pic1.PicRotation)-Ord(Pic2.PicRotation);
        ppFlips:           Result := Byte(Pic1.PicFlips)-Byte(Pic2.PicFlips);
      end;
      if Result<>0 then begin
        if ps.Order=soDesc then Result := -Result;
        Break;
      end;
    end;
  end;

  procedure TPhoaSortings.StreamerLoad(Streamer: TPhoaStreamer);
  var
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
    Sorting: TPhoaSorting;
  begin
    Clear;
    with Streamer do
       // *** New format only
      if Chunked then
        while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
          case Code of
             // Sorting
            IPhChunk_ViewSorting_Open: begin
               // Initialize sorting with invalid value
              Sorting.Prop := TPicProperty(255);
              while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
                case Code of
                  IPhChunk_ViewSorting_Prop:  Sorting.Prop  := aXlat_ChunkSortingPropToPicProperty[Integer(vValue)];
                  IPhChunk_ViewSorting_Order: Sorting.Order := TSortOrder(vValue);
                   // Close-chunk
                  IPhChunk_ViewSorting_Close: Break;
                   // Ensure unknown nested structures are skipped whole
                  else Streamer.SkipNestedChunks(Code);
                end;
               // If now Sorting is valid (valid property encountered), add it
              if Sorting.Prop<=High(TPicProperty) then inherited Add(Pointer(Sorting));
            end;
             // Close-chunk
            IPhChunk_ViewSortings_Close: Break;
             // Ensure unknown nested structures are skipped whole
            else Streamer.SkipNestedChunks(Code);
          end;
  end;

  procedure TPhoaSortings.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
    with Streamer do
       // *** New format only
      if Chunked then begin
        WriteChunk(IPhChunk_ViewSortings_Open);
        for i := 0 to Count-1 do begin
          WriteChunk(IPhChunk_ViewSorting_Open);
          WriteChunkWord(IPhChunk_ViewSorting_Prop,  aXlat_PicPropertyToChunkSortingProp[GetItems(i).Prop]);
          WriteChunkByte(IPhChunk_ViewSorting_Order, Byte(GetItems(i).Order));
          WriteChunk(IPhChunk_ViewSorting_Close);
        end;
        WriteChunk(IPhChunk_ViewSortings_Close);
      end;
  end;

  procedure TPhoaSortings.ToggleOrder(Index: Integer);
  var ps: TPhoaSorting;
  begin
    ps := GetItems(Index);
    ps.Order := TSortOrder(1-Byte(ps.Order));
    inherited Items[Index] := Pointer(ps);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaGroup
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaGroup.Assign(Src: TPhoaGroup; bCopyIDs, bCopyPicIDs, bCopySubgroups: Boolean);
  var i: Integer;
  begin
    if bCopyIDs then FID := Src.FID;
    FText     := Src.FText;
    FExpanded := Src.FExpanded;
     // �������� ������ ID �����������
    if bCopyPicIDs then FPicIDs.Assign(Src.FPicIDs);
     // �������� ���������� ������
    if bCopySubgroups then begin
      FGroups.Clear;
      for i := 0 to Src.FGroups.Count-1 do TPhoaGroup.Create(Self, 0).Assign(Src.FGroups[i], bCopyIDs, bCopyPicIDs, True);
    end;
  end;

  constructor TPhoaGroup.Create(_Owner: TPhoaGroup; iID: Integer);
  begin
    inherited Create;
    FGroups := TPhoaGroups.Create(Self);
    FPicIDs := TIntegerList.Create(False);
    Owner   := _Owner;
    FID     := iID;
  end;

  destructor TPhoaGroup.Destroy;
  begin
    Owner := nil;
    FGroups.Free;
    FPicIDs.Free;
    inherited Destroy;
  end;

  procedure TPhoaGroup.FixupIDs;
  var iFreeID: Integer;
  begin
    iFreeID := FreeID;
    InternalFixupIDs(iFreeID);
  end;

  function TPhoaGroup.GetFreeID: Integer;
  var i, iChildFreeID: Integer;
  begin
     // ������������� ��������� ID, ��������� �� �����
    Result := FID+1;
     // ���������� ���� �����, �������� �� ������������ FreeID
    for i := 0 to FGroups.Count-1 do begin
      iChildFreeID := FGroups[i].FreeID;
      if Result<iChildFreeID then Result := iChildFreeID;
    end;
  end;

  function TPhoaGroup.GetGroupByID(iID: Integer): TPhoaGroup;
  var i: Integer;
  begin
    Assert(iID>0, 'Invalid ID passed to TPhoaGroup.GroupByID[]');
    if FID=iID then
      Result := Self
    else begin
      for i := 0 to FGroups.Count-1 do begin
        Result := FGroups[i].GroupByID[iID];
        if Result<>nil then Exit;
      end;
      Result := nil;
    end;
  end;

  function TPhoaGroup.GetGroupByPath(const sPath: String): TPhoaGroup;
  var
    s, sFirst: String;
    i: Integer;
    g: TPhoaGroup;
  begin
    Result := nil;
    s := sPath;
    if s<>'' then begin
       // ������� ������ '/' � ������, ���� �� ����
      if s[1]='/' then Delete(s, 1, 1);
       // �������� ������ ����� ����
      sFirst := ExtractFirstWord(s, '/');
       // ���� ������ � ������, ����������� � ������ ������ ����
      for i := 0 to Groups.Count-1 do begin
        g := Groups[i];
         // �����
        if AnsiSameText(g.Text, sFirst) then begin
           // ���� ���� ��������, ��� �� � ������. ����� ���� �� ������� ���� ����� ����� ������
          if s='' then Result := g else Result := g.GroupByPath[s];
          Break; 
        end;
      end;
    end;
  end;

  function TPhoaGroup.GetIndex: Integer;
  begin
    if FOwner=nil then Result := -1 else Result := FOwner.FGroups.IndexOf(Self);
  end;

  function TPhoaGroup.GetNestedGroupCount: Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to FGroups.Count-1 do begin
      Inc(Result);
      Inc(Result, FGroups[i].NestedGroupCount);
    end;
  end;

  function TPhoaGroup.GetPath(const sRootName: String): String;
  begin
    if FOwner=nil then Result := sRootName else Result := FOwner.Path[sRootName]+'/'+FText;
  end;

  function TPhoaGroup.GetRoot: TPhoaGroup;
  begin
    if FOwner=nil then Result := Self else Result := FOwner.Root;
  end;

  procedure TPhoaGroup.InternalFixupIDs(var iFreeID: Integer);
  var i: Integer;
  begin
     // ��������� ���� ID
    if FID=0 then begin
      FID := iFreeID;
      Inc(iFreeID);
    end;
     // ��������� �� �� ��� ��������
    for i := 0 to FGroups.Count-1 do FGroups[i].InternalFixupIDs(iFreeID);
  end;

  function TPhoaGroup.IsPicLinked(iID: Integer; bRecursive: Boolean): Boolean;
  var i: Integer;
  begin
    Result := FPicIDs.IndexOf(iID)>=0;
    if bRecursive then begin
      i := 0;
      while not Result and (i<FGroups.Count) do begin
        Result := FGroups[i].IsPicLinked(iID, True);
        Inc(i);
      end;
    end;
  end;

  procedure TPhoaGroup.SetIndex(Value: Integer);
  var idxCur: Integer;
  begin
    if FOwner<>nil then begin
      idxCur := GetIndex;
      if idxCur<>Value then FOwner.FGroups.Move(idxCur, Value);
    end;
  end;

  procedure TPhoaGroup.SetOwner(Value: TPhoaGroup);
  begin
    if FOwner<>Value then begin
      if FOwner<>nil then FOwner.Groups.Remove(Self);
      FOwner := Value;
      if FOwner<>nil then FOwner.Groups.Add(Self);
    end;
  end;

type
  PGroupSortRec = ^TGroupSortRec;
  TGroupSortRec = record
    Sortings: TPhoaSortings;
    Pics: TPhoaPics;
  end;

  function GroupPicSortCompare(i1, i2: Integer; pData: Pointer): Integer; near;
  begin
    Result :=
      PGroupSortRec(pData).Sortings.SortComparePics(
        PGroupSortRec(pData).Pics.PicByID(i1),
        PGroupSortRec(pData).Pics.PicByID(i2));
  end;

  procedure TPhoaGroup.SortPics(Sortings: TPhoaSortings; Pics: TPhoaPics);
  var gsr: TGroupSortRec;
  begin
    gsr.Sortings := Sortings;
    gsr.Pics     := Pics;
    FPicIDs.Sort(GroupPicSortCompare, @gsr);
  end;

  procedure TPhoaGroup.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    FPicIDs.Clear;
    with Streamer do
       // *** Old format
      if not Chunked then begin
         // Read group properties
        FText     := ReadStringI;
        FExpanded := ReadByte<>0;
         // Read picture IDs
        for i := 0 to ReadInt-1 do FPicIDs.Add(ReadInt);
         // Read nested groups
        FGroups.StreamerLoad(Streamer);
       // *** New format
      end else
        while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
          case Code of
             // Group properties
            IPhChunk_Group_ID:       FID       := vValue;
            IPhChunk_Group_Text:     FText     := vValue;
            IPhChunk_Group_Expanded: FExpanded := vValue<>Byte(0);
             // Picture IDs
            IPhChunk_GroupPics_Open:
              while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
                case Code of
                   // Picture ID
                  IPhChunk_GroupPic_ID: FPicIDs.Add(vValue);
                   // Close-chunk
                  IPhChunk_GroupPics_Close: Break;
                   // Ensure unknown nested structures are skipped whole
                  else Streamer.SkipNestedChunks(Code);
                end;
             // Nested groups
            IPhChunk_Groups_Open: FGroups.StreamerLoad(Streamer);
             // Close-chunk
            IPhChunk_Group_Close: Break;
             // Ensure unknown nested structures are skipped whole
            else Streamer.SkipNestedChunks(Code);
          end;
  end;

  procedure TPhoaGroup.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
    with Streamer do
       // *** Old format
      if not Chunked then begin
         // Write group properties
        WriteStringI(FText);
        WriteByte   (Byte(FExpanded));
         // Write picture IDs
        WriteInt    (FPicIDs.Count);
        for i := 0 to FPicIDs.Count-1 do WriteInt(FPicIDs[i]);
         // Write nested groups
        FGroups.StreamerSave(Streamer);
       // *** New format
      end else begin
         // Write open-chunk
        WriteChunk(IPhChunk_Group_Open);
         // Write group props
        WriteChunkInt   (IPhChunk_Group_ID,       FID);
        WriteChunkString(IPhChunk_Group_Text,     FText);
        WriteChunkByte  (IPhChunk_Group_Expanded, Byte(FExpanded));
         // Write picture IDs
        WriteChunk(IPhChunk_GroupPics_Open);
        for i := 0 to FPicIDs.Count-1 do WriteChunkInt(IPhChunk_GroupPic_ID, FPicIDs[i]);
        WriteChunk(IPhChunk_GroupPics_Close);
         // Write nested groups
        FGroups.StreamerSave(Streamer);
         // Write close-chunk
        WriteChunk(IPhChunk_Group_Close);
      end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaGroups
   //-------------------------------------------------------------------------------------------------------------------

  function TPhoaGroups.Add(Group: TPhoaGroup): Integer;
  begin
    Result := inherited Add(Group);
  end;

  procedure TPhoaGroups.Clear;
  begin
    while Count>0 do GetItems(0).Free;
    inherited Clear;
  end;

  constructor TPhoaGroups.Create(_Owner: TPhoaGroup);
  begin
    inherited Create;
    FOwner := _Owner;
  end;

  procedure TPhoaGroups.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  function TPhoaGroups.GetItems(Index: Integer): TPhoaGroup;
  begin
    Result := TPhoaGroup(inherited Items[Index]);
  end;

  procedure TPhoaGroups.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    Clear;
    with Streamer do
       // *** Old format
      if not Chunked then
         // Read nested groups
        for i := 0 to ReadInt-1 do TPhoaGroup.Create(FOwner, 0).StreamerLoad(Streamer)
       // *** New format
      else
        while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
          case Code of
             // Nested group
            IPhChunk_Group_Open: TPhoaGroup.Create(FOwner, 0).StreamerLoad(Streamer);
             // Close-chunk
            IPhChunk_Groups_Close: Break;
             // Ensure unknown nested structures are skipped whole
            else Streamer.SkipNestedChunks(Code);
          end;
  end;

  procedure TPhoaGroups.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
    with Streamer do
       // *** Old format
      if not Chunked then begin
         // Write nested groups
        WriteInt(Count);
        for i := 0 to Count-1 do GetItems(i).StreamerSave(Streamer);
       // *** New format
      end else begin
        WriteChunk(IPhChunk_Groups_Open);
         // Write nested groups
        for i := 0 to Count-1 do GetItems(i).StreamerSave(Streamer);
        WriteChunk(IPhChunk_Groups_Close);
      end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaPic
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaPic.Assign(Src: TPhoaPic);
  begin
    FID             := Src.FID;
    FPicAuthor      := Src.FPicAuthor;
    FPicDateTime    := Src.FPicDateTime;
    FPicDesc        := Src.FPicDesc;
    FPicFileName    := Src.FPicFileName;
    FPicFileSize    := Src.FPicFileSize;
    FPicFilmNumber  := Src.FPicFilmNumber;
    FPicFormat      := Src.FPicFormat;
    FPicFrameNumber := Src.FPicFrameNumber;
    FPicKeywords.Assign(Src.FPicKeywords);
    FPicNotes       := Src.FPicNotes;
    FPicPlace       := Src.FPicPlace;
    FThumbnailData  := Src.FThumbnailData;
  end;

  procedure TPhoaPic.CleanupProps(Props: TPicProperties);
  begin
    if [ppFileSize, ppFileSizeBytes]*Props<>[] then FPicFileSize        := 0;
    if [ppPicWidth, ppPicDims]*Props<>[]       then FPicWidth           := 0;
    if [ppPicHeight, ppPicDims]*Props<>[]      then FPicHeight          := 0;
    if ppFormat      in Props                  then FPicFormat          := pfCustom;
    if ppDate        in Props                  then FPicDateTime        := Frac(FPicDateTime);
    if ppTime        in Props                  then FPicDateTime        := Int(FPicDateTime);
    if ppPlace       in Props                  then FPicPlace           := '';
    if ppFilmNumber  in Props                  then FPicFilmNumber      := '';
    if ppFrameNumber in Props                  then FPicFrameNumber     := '';
    if ppAuthor      in Props                  then FPicAuthor          := '';
    if ppMedia       in Props                  then FPicMedia           := '';
    if ppDescription in Props                  then FPicDesc            := '';
    if ppNotes       in Props                  then FPicNotes           := '';
    if ppKeywords    in Props                  then FPicKeywords.Clear; 
    if ppRotation    in Props                  then FPicRotation        := pr0;
    if ppFlips       in Props                  then FPicFlips           := [];
  end;

  constructor TPhoaPic.Create(PhoA: TPhotoAlbum);
  begin
    inherited Create;
    FPhoA := PhoA;
    FPicKeywords := TStringList.Create;
    TStringList(FPicKeywords).Sorted     := True;
    TStringList(FPicKeywords).Duplicates := dupIgnore;
    FPicFormat := pfCustom;
  end;

  destructor TPhoaPic.Destroy;
  begin
    FPicKeywords.Free;
    if FList<>nil then FList.Remove(Self);
    inherited Destroy;
  end;

  function TPhoaPic.GetProps(PicProp: TPicProperty): String;
  begin
    Result := '';
    case PicProp of
      ppID:            Result := IntToStr(FID);
      ppFileName:      Result := ExtractFileName(FPicFileName);
      ppFullFileName:  Result := FPicFileName;
      ppFilePath:      Result := ExtractFileDir(FPicFileName);
      ppFileSize:      Result := HumanReadableSize(FPicFileSize);
      ppFileSizeBytes: Result := IntToStr(FPicFileSize);
      ppPicWidth:      if FPicWidth>0  then Result := IntToStr(FPicWidth);
      ppPicHeight:     if FPicHeight>0 then Result := IntToStr(FPicHeight);
      ppPicDims:       if (FPicWidth>0) and (FPicHeight>0) then Result := Format('%dx%d', [FPicWidth, FPicHeight]);
      ppFormat:        Result := PixelFormatName(FPicFormat);
      ppDate:          if Trunc(FPicDateTime)>0 then Result := DateToStr(FPicDateTime);
      ppTime:          if Frac(FPicDateTime)>0  then Result := TimeToStr(FPicDateTime);
      ppPlace:         Result := FPicPlace;
      ppFilmNumber:    Result := FPicFilmNumber;
      ppFrameNumber:   Result := FPicFrameNumber;
      ppAuthor:        Result := FPicAuthor;
      ppDescription:   Result := FPicDesc;
      ppNotes:         Result := FPicNotes;
      ppMedia:         Result := FPicMedia;
      ppKeywords:      Result := FPicKeywords.CommaText;
      ppRotation:      Result := asPicRotationText[FPicRotation];
      ppFlips:         Result := PicFlipsText(FPicFlips);
    end;
  end;

  function TPhoaPic.GetPropStrs(Props: TPicProperties; const sNameValSep, sPropSep: String): String;
  var
    Prop: TPicProperty;
    sVal: String;
  begin
    Result := '';
    for Prop := Low(Prop) to High(Prop) do
      if Prop in Props then begin
        sVal := GetProps(Prop);
        if sVal<>'' then begin
          if sNameValSep<>'' then sVal := PicPropName(Prop)+sNameValSep+sVal;
          AccumulateStr(Result, sPropSep, sVal);
        end;
      end;
  end;

  function TPhoaPic.GetRawData(PProps: TPicProperties): String;
  var
    Stream: TStringStream;
    Streamer: TPhoaStreamer;
  begin
     // ��������� ������ ����������� �� ��������� �����
    Stream := TStringStream.Create('');
    try
      Streamer := TPhoaStreamer.Create(Stream, psmWrite, '');
      try
        StreamerSave(Streamer, False, PProps);
      finally
        Streamer.Free;
      end;
       // ��������� ����� � ������
      Result := Stream.DataString;
    finally
      Stream.Free;
    end;
  end;

  procedure TPhoaPic.IDNeeded(List: TPhoaPics);
  begin
    if FID=0 then FID := List.GetFreePicID;
  end;

  procedure TPhoaPic.MakeThumbnail;
  var
    b: TBitmap32;
    hF: THandle;
    FindData: TWin32FindData;

     // ������������ ��������������� �������� �� ������ bmp
    procedure StretchGraphic(bmp: TBitmap32);
    var
      sScale: Single;
      bmpFullSize: TBitmap32;
    begin
       // ������, ��������� �������� � ���������� � � Bitmap
      bmpFullSize := LoadGraphicFromFile(FPicFileName);
      try
        bmpFullSize.StretchFilter := TStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt));
        FPicWidth  := bmpFullSize.Width;
        FPicHeight := bmpFullSize.Height;
         // ���������� ������� ������
        if (FPicWidth>0) and (FPicHeight>0) then
          sScale := MinS(MinS(FPhoA.FThumbnailWidth/FPicWidth, FPhoA.FThumbnailHeight/FPicHeight), 1)
        else
          sScale := 1;
         // ������������ �����������
        with bmp do begin
          Width  := Max(Round(FPicWidth*sScale), 1);
          Height := Max(Round(FPicHeight*sScale), 1);
          Draw(Rect(0, 0, Width, Height), Rect(0, 0, FPicWidth, FPicHeight), bmpFullSize);
        end;
      finally
        bmpFullSize.Free;
      end;
    end;

     // ���������� ������ � JPEG � ���������� ��� ������ � ���� �������� ������
    function MakeRawJPEG(bmp32: TBitmap32): String;
    var
      Stream: TStringStream;
      bmp: TBitmap;
    begin
       // ����������� TBitmap32 � TBitmap
      bmp := TBitmap.Create;
      try
        bmp.Width  := bmp32.Width;
        bmp.Height := bmp32.Height;
        bmp.PixelFormat := pf24bit;
        bmp32.DrawTo(bmp.Canvas.Handle, 0, 0);
        with TJPEGImage.Create do
          try
             // �������� �����
            Assign(bmp);
             // �������
            CompressionQuality := FPhoA.FThumbnailQuality;
            Compress;
             // ��������� ����� � �����
            Stream := TStringStream.Create('');
            try
              SaveToStream(Stream);
              Result := Stream.DataString;
            finally
              Stream.Free;
            end;
          finally
            Free;
          end;
      finally
        bmp.Free;
      end;
    end;

  begin
     // ������������ �����������
    b := TBitmap32.Create;
    try
      StretchGraphic(b);
      FThumbWidth  := b.Width;
      FThumbHeight := b.Height;
      FThumbnailData := MakeRawJPEG(b);
       // �������� ������ ����� �����������
      hF := FindFirstFile(PChar(FPicFileName), FindData);
      if hF<>INVALID_HANDLE_VALUE then begin
        FindClose(hF);
        FPicFileSize := FindData.nFileSizeLow;
      end else
        FPicFileSize := 0;
    finally
      b.Free;
    end;
  end;

  procedure TPhoaPic.PaintThumbnail(Bitmap: TBitmap);
  var
    Stream: TStringStream;
    j: TJPEGImage;
    Bmp32: TBitmap32;
    Transform: TPicTransform;
  begin
    if FThumbnailData='' then Exit;
    j := TJPEGImage.Create;
    try
       // ��������� JPEG
      Stream := TStringStream.Create(FThumbnailData);
      try
        j.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
       // ���� ����, ��������� ��������������
      if (FPicRotation<>pr0) or (FPicFlips<>[]) then begin
        Bmp32 := TBitmap32.Create;
        try
          Bmp32.Assign(j);
          Transform := TPicTransform.Create(Bmp32);
          try
            Transform.Rotation := FPicRotation;
            Transform.Flips    := FPicFlips;
          finally
            Transform.Free;
          end;
          Bitmap.Assign(Bmp32);
        finally
          Bmp32.Free;
        end;
       // ����� ������ ������������ ����������� �� �������
      end else
        Bitmap.Assign(j);
    finally
      j.Free;
    end;
  end;

  procedure TPhoaPic.SetList(Value: TPhoaPics);
  begin
    if FList<>Value then begin
      if FList<>nil then FList.Remove(Self);
      FList := Value;
      if FList<>nil then FList.Add(Self);
    end;
  end;

  procedure TPhoaPic.SetProps(PicProp: TPicProperty; const Value: String);
  begin
    case PicProp of
      ppFullFileName: FPicFileName           := Value;
      ppDate:         if Value='' then FPicDateTime := Frac(FPicDateTime) else FPicDateTime := StrToDate(Value)+Frac(FPicDateTime);
      ppTime:         if Value='' then FPicDateTime := Int(FPicDateTime)  else FPicDateTime := StrToTime(Value)+Int(FPicDateTime);
      ppPlace:        FPicPlace              := Value;
      ppFilmNumber:   FPicFilmNumber         := Value;
      ppFrameNumber:  FPicFrameNumber        := Value;
      ppAuthor:       FPicAuthor             := Value;
      ppDescription:  FPicDesc               := Value;
      ppNotes:        FPicNotes              := Value;
      ppMedia:        FPicMedia              := Value;
      ppKeywords:     FPicKeywords.CommaText := Value;
      else            PhoaException('Picture property %s cannot be written', [GetEnumName(TypeInfo(TPicProperty), Byte(PicProp))]);
    end;
  end;

  procedure TPhoaPic.SetRawData(PProps: TPicProperties; const Value: String);
  var
    Stream: TStringStream;
    Streamer: TPhoaStreamer;
  begin
    Stream := TStringStream.Create(Value);
    try
      Streamer := TPhoaStreamer.Create(Stream, psmRead, '');
      try
        StreamerLoad(Streamer, False, PProps);
      finally
        Streamer.Free;
      end;
    finally
      Stream.Free;
    end;
  end;

  procedure TPhoaPic.StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
  var
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;

    function XFilename(const s: String): String;
    begin
      if bExpandRelative then Result := ExpandRelativePath(Streamer.BasePath, s) else Result := s;
    end;

  begin
    with Streamer do
       // *** Old format
      if not Chunked then begin
        if ppID          in PProps                  then FID                    := ReadInt;
        if ppFileName    in PProps                  then FThumbnailData         := ReadStringI;
        if ppFilmNumber  in PProps                  then FPicFilmNumber         := ReadStringI;
        if ppDate        in PProps                  then FPicDateTime           := ReadInt;
        if ppDescription in PProps                  then FPicDesc               := ReadStringI;
        if ppFileName    in PProps                  then FPicFileName           := XFilename(ReadStringI);
        if [ppFileSize, ppFileSizeBytes]*PProps<>[] then FPicFileSize           := ReadInt;
        if ppFormat      in PProps                  then FPicFormat             := TPixelFormat(ReadByte);
        if ppKeywords    in PProps                  then FPicKeywords.CommaText := ReadStringI;
        if ppFrameNumber in PProps                  then FPicFrameNumber        := ReadStringI;
        if ppPlace       in PProps                  then FPicPlace              := ReadStringI;
        if ppFileName    in PProps                  then FThumbWidth            := ReadInt;
        if ppFileName    in PProps                  then FThumbHeight           := ReadInt;
       // *** New format
      end else begin
         // Revert props to their defaults because they might be not saved due to their emptiness
        CleanupProps(PProps);
         // Read chunked data
        while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
          case Code of
             // Picture props
            IPhChunk_Pic_ID:            if ppID          in PProps                  then FID                    := vValue;
            IPhChunk_Pic_ThumbnailData: if ppFileName    in PProps                  then FThumbnailData         := vValue;
            IPhChunk_Pic_ThumbWidth:    if ppFileName    in PProps                  then FThumbWidth            := vValue;
            IPhChunk_Pic_ThumbHeight:   if ppFileName    in PProps                  then FThumbHeight           := vValue;
            IPhChunk_Pic_PicFileName:   if ppFileName    in PProps                  then FPicFileName           := XFilename(vValue);
            IPhChunk_Pic_PicFileSize:   if [ppFileSize, ppFileSizeBytes]*PProps<>[] then FPicFileSize           := vValue;
            IPhChunk_Pic_PicWidth:      if [ppPicWidth, ppPicDims]*PProps<>[]       then FPicWidth              := vValue;
            IPhChunk_Pic_PicHeight:     if [ppPicHeight, ppPicDims]*PProps<>[]      then FPicHeight             := vValue;
            IPhChunk_Pic_PicFormat:     if ppFormat      in PProps                  then Byte(FPicFormat)       := vValue;
            IPhChunk_Pic_Date:          if ppDate        in PProps                  then FPicDateTime           := PhoaDateToDate(vValue)+Frac(FPicDateTime);
            IPhChunk_Pic_Time:          if ppTime        in PProps                  then FPicDateTime           := PhoaTimeToTime(vValue)+Int(FPicDateTime);
            IPhChunk_Pic_Place:         if ppPlace       in PProps                  then FPicPlace              := vValue;
            IPhChunk_Pic_FilmNumber:    if ppFilmNumber  in PProps                  then FPicFilmNumber         := vValue;
            IPhChunk_Pic_FrameNumber:   if ppFrameNumber in PProps                  then FPicFrameNumber        := vValue;
            IPhChunk_Pic_Author:        if ppAuthor      in PProps                  then FPicAuthor             := vValue;
            IPhChunk_Pic_Media:         if ppMedia       in PProps                  then FPicMedia              := vValue;
            IPhChunk_Pic_Desc:          if ppDescription in PProps                  then FPicDesc               := vValue;
            IPhChunk_Pic_Notes:         if ppNotes       in PProps                  then FPicNotes              := vValue;
            IPhChunk_Pic_Keywords:      if ppKeywords    in PProps                  then FPicKeywords.CommaText := vValue;
            IPhChunk_Pic_Rotation:      if ppRotation    in PProps                  then Byte(FPicRotation)     := vValue;
            IPhChunk_Pic_Flips:         if ppFlips       in PProps                  then Byte(FPicFlips)        := vValue;
             // Close-chunk
            IPhChunk_Pic_Close: Break;
             // Ensure unknown nested structures are skipped whole
            else SkipNestedChunks(Code);
          end;
      end;
  end;

  procedure TPhoaPic.StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);

    function XFilename: String;
    begin
      if bExtractRelative then Result := ExtractRelativePath(Streamer.BasePath, FPicFileName) else Result := FPicFileName;
    end;

  begin
    with Streamer do
       // *** Old format
      if not Chunked then begin
        if ppID          in PProps                  then WriteInt    (FID);
        if ppFileName    in PProps                  then WriteStringI(FThumbnailData);
        if ppFilmNumber  in PProps                  then WriteStringI(FPicFilmNumber);
        if ppDate        in PProps                  then WriteInt    (Trunc(FPicDateTime));
        if ppDescription in PProps                  then WriteStringI(FPicDesc);
        if ppFileName    in PProps                  then WriteStringI(XFilename);
        if [ppFileSize, ppFileSizeBytes]*PProps<>[] then WriteInt    (FPicFileSize);
        if ppFormat      in PProps                  then WriteByte   (Byte(FPicFormat));
        if ppKeywords    in PProps                  then WriteStringI(FPicKeywords.CommaText);
        if ppFrameNumber in PProps                  then WriteStringI(FPicFrameNumber);
        if ppPlace       in PProps                  then WriteStringI(FPicPlace);
        if ppFileName    in PProps                  then WriteInt    (FThumbWidth);
        if ppFileName    in PProps                  then WriteInt    (FThumbHeight);
       // *** New format
      end else begin
        if ppID          in PProps                                                 then WriteChunkInt   (IPhChunk_Pic_ID,            FID);
        if ppFileName    in PProps                                                 then WriteChunkString(IPhChunk_Pic_ThumbnailData, FThumbnailData);
        if ppFileName    in PProps                                                 then WriteChunkWord  (IPhChunk_Pic_ThumbWidth,    FThumbWidth);
        if ppFileName    in PProps                                                 then WriteChunkWord  (IPhChunk_Pic_ThumbHeight,   FThumbHeight);
        if ppFileName    in PProps                                                 then WriteChunkString(IPhChunk_Pic_PicFileName,   XFilename);
        if ([ppFileSize, ppFileSizeBytes]*PProps<>[]) and (FPicFileSize>0)         then WriteChunkInt   (IPhChunk_Pic_PicFileSize,   FPicFileSize);
        if ([ppPicWidth, ppPicDims]*PProps<>[])       and (FPicWidth>0)            then WriteChunkInt   (IPhChunk_Pic_PicWidth,      FPicWidth);
        if ([ppPicHeight, ppPicDims]*PProps<>[])      and (FPicHeight>0)           then WriteChunkInt   (IPhChunk_Pic_PicHeight,     FPicHeight);
        if (ppFormat      in PProps)                  and (FPicFormat<>pfCustom)   then WriteChunkByte  (IPhChunk_Pic_PicFormat,     Byte(FPicFormat));
        if (ppDate        in PProps)                  and (Trunc(FPicDateTime)<>0) then WriteChunkInt   (IPhChunk_Pic_Date,          DateToPhoaDate(FPicDateTime));
        if (ppTime        in PProps)                  and (Frac(FPicDateTime)<>0)  then WriteChunkInt   (IPhChunk_Pic_Time,          TimeToPhoaTime(FPicDateTime));
        if (ppPlace       in PProps)                  and (FPicPlace<>'')          then WriteChunkString(IPhChunk_Pic_Place,         FPicPlace);
        if (ppFilmNumber  in PProps)                  and (FPicFilmNumber<>'')     then WriteChunkString(IPhChunk_Pic_FilmNumber,    FPicFilmNumber);
        if (ppFrameNumber in PProps)                  and (FPicFrameNumber<>'')    then WriteChunkString(IPhChunk_Pic_FrameNumber,   FPicFrameNumber);
        if (ppAuthor      in PProps)                  and (FPicAuthor<>'')         then WriteChunkString(IPhChunk_Pic_Author,        FPicAuthor);
        if (ppMedia       in PProps)                  and (FPicMedia<>'')          then WriteChunkString(IPhChunk_Pic_Media,         FPicMedia);
        if (ppDescription in PProps)                  and (FPicDesc<>'')           then WriteChunkString(IPhChunk_Pic_Desc,          FPicDesc);
        if (ppNotes       in PProps)                  and (FPicNotes<>'')          then WriteChunkString(IPhChunk_Pic_Notes,         FPicNotes);
        if (ppKeywords    in PProps)                  and (FPicKeywords.Count>0)   then WriteChunkString(IPhChunk_Pic_Keywords,      FPicKeywords.CommaText);
        if (ppRotation    in PProps)                  and (FPicRotation<>pr0)      then WriteChunkByte  (IPhChunk_Pic_Rotation,      Byte(FPicRotation));
        if (ppFlips       in PProps)                  and (FPicFlips<>[])          then WriteChunkByte  (IPhChunk_Pic_Flips,         Byte(FPicFlips));
      end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaPics
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaPics.Assign(Src: TPhoaPics; bCopyLinksOnly: Boolean; RestrictLinks: TPhoaPicLinks);
  var
    i: Integer;
    Pic, SrcPic: TPhoaPic;
  begin
     // ����������� ������ ����������� ������� ������
    if bCopyLinksOnly then
      inherited Assign(Src, RestrictLinks)
     // ����������� � ��������� ����� ����������� ����������� 
    else begin
      Clear;
      for i := 0 to Src.Count-1 do begin
        SrcPic := Src[i];
        if (RestrictLinks=nil) or (RestrictLinks.IndexOfID(SrcPic.ID)>=0) then begin
          Pic := TPhoaPic.Create(FPhoA);
          try
            Pic.Assign(SrcPic);
            Pic.List := Self;
          except
            Pic.Free;
            raise;
          end;
        end;
      end;
    end;
  end;

  procedure TPhoaPics.Clear;
  var i: Integer;
  begin
    for i := Count-1 downto 0 do Delete(i);
    inherited Clear;
  end;

  constructor TPhoaPics.Create(_PhoA: TPhotoAlbum);
  begin
    inherited Create(True);
    FPhoA := _PhoA;
  end;

  procedure TPhoaPics.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  function TPhoaPics.GetFreePicID: Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to Count-1 do
      with GetItems(i) do
        if ID>Result then Result := ID;
    Inc(Result);
  end;

  procedure TPhoaPics.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
    Pic: TPhoaPic;
  begin
    Clear;
     // *** Old format
    if not Streamer.Chunked then
      for i := 0 to Streamer.ReadInt-1 do begin
        Pic := TPhoaPic.Create(FPhoA);
        try
          Pic.StreamerLoad(Streamer, True, PPAllProps);
          Pic.List := Self;
        except
          Pic.Free;
          raise;
        end;
      end
     // *** New format
    else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // Picture
          IPhChunk_Pic_Open: begin
            Pic := TPhoaPic.Create(FPhoA);
            try
              Pic.StreamerLoad(Streamer, True, PPAllProps);
              Pic.List := Self;
            except
              Pic.Free;
              raise;
            end;
          end;
           // Close-chunk
          IPhChunk_Pics_Close: Break;
           // Ensure unknown nested structures are skipped whole
          else Streamer.SkipNestedChunks(Code);
        end;
  end;

  procedure TPhoaPics.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
     // *** Old format
    if not Streamer.Chunked then begin
      Streamer.WriteInt(Count);
      for i := 0 to Count-1 do GetItems(i).StreamerSave(Streamer, True, PPAllProps);
     // *** New format
    end else begin
      Streamer.WriteChunk(IPhChunk_Pics_Open);
      for i := 0 to Count-1 do begin
        Streamer.WriteChunk(IPhChunk_Pic_Open);
        GetItems(i).StreamerSave(Streamer, True, PPAllProps);
        Streamer.WriteChunk(IPhChunk_Pic_Close);
      end;
      Streamer.WriteChunk(IPhChunk_Pics_Close);
    end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaViewHelperPics
   //-------------------------------------------------------------------------------------------------------------------
var
  ViewToSortFor: TPhoaView;

  function PVHelperSortCompare(Item1, Item2: Pointer): Integer;
  begin
     // ������� ��������� �� ������������
    Result := ViewToSortFor.Groupings.SortComparePics(TPhoaPic(Item1), TPhoaPic(Item2));
     // ����� �� �����������
    if Result=0 then Result := ViewToSortFor.Sortings.SortComparePics(TPhoaPic(Item1), TPhoaPic(Item2));
  end;

  procedure TPhoaViewHelperPics.Sort(View: TPhoaView);
  begin
    ViewToSortFor := View;
    inherited Sort(PVHelperSortCompare);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaGroupings
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaGroupings.Add(_Prop: TGroupByProperty; _bUnclassified: Boolean);
  var g: TPhoaGrouping;
  begin
    g.Prop          := _Prop;
    g.bUnclassified := _bUnclassified;
    g.wUnused       := 0;
    inherited Add(Pointer(g));
  end;

  function TPhoaGroupings.GetItems(Index: Integer): TPhoaGrouping;
  begin
    Result := TPhoaGrouping(inherited Items[Index]);
  end;

  function TPhoaGroupings.IdenticalWith(Groupings: TPhoaGroupings): Boolean;
  var i: Integer;
  begin
    Result := Count=Groupings.Count;
    if Result then
      for i := 0 to Count-1 do
        with GetItems(i) do
          if (Prop<>Groupings[i].Prop) or (bUnclassified<>Groupings[i].bUnclassified) then begin
            Result := False;
            Exit;
          end;
  end;

  procedure TPhoaGroupings.SetProp(Index: Integer; Prop: TGroupByProperty);
  var gs: TPhoaGrouping;
  begin
    gs := GetItems(Index);
    gs.Prop := Prop;
    inherited Items[Index] := Pointer(gs);
  end;

  function TPhoaGroupings.SortComparePics(Pic1, Pic2: TPhoaPic): Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to Count-1 do begin
      case GetItems(i).Prop of
        gbpFilePath:    Result := AnsiCompareText(ExtractFilePath(Pic1.PicFileName), ExtractFilePath(Pic2.PicFileName));
        gbpDateByYear:  Result := YearOf(Pic1.PicDateTime)-YearOf(Pic2.PicDateTime);
        gbpDateByMonth: Result := MonthOf(Pic1.PicDateTime)-MonthOf(Pic2.PicDateTime);
        gbpDateByDay:   Result := DayOf(Pic1.PicDateTime)-DayOf(Pic2.PicDateTime);
        gbpTimeHour:    Result := HourOf(Pic1.PicDateTime)-HourOf(Pic2.PicDateTime);
        gbpTimeMinute:  Result := MinuteOf(Pic1.PicDateTime)-MinuteOf(Pic2.PicDateTime);
        gbpPlace:       Result := AnsiCompareText(Pic1.PicPlace,      Pic2.PicPlace);
        gbpFilmNumber:  Result := AnsiCompareText(Pic1.PicFilmNumber, Pic2.PicFilmNumber);
        gbpAuthor:      Result := AnsiCompareText(Pic1.PicAuthor,     Pic2.PicAuthor);
        gbpMedia:       Result := AnsiCompareText(Pic1.PicMedia,      Pic2.PicMedia);
        gbpKeywords:    Result := 0; // �� �������� ������ ���������� �����������
      end;
      if Result<>0 then Break;
    end;
  end;

  procedure TPhoaGroupings.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
    RG: TRawPhoaGrouping;
    G: TPhoaGrouping;
  begin
    Clear;
    with Streamer do
       // *** Old format
      if not Chunked then begin
         // Read groupings translatin GroupByProperty from old revision 2
        for i := 0 to ReadInt-1 do begin
          Integer(RG) := ReadInt;
          RG.bProp := aXlat_GBProp2ToGBProp[RG.bProp];
          inherited Add(Pointer(RG));
        end;
       // *** New format
      end else
        while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
          case Code of
             // Sorting
            IPhChunk_ViewGrouping_Open: begin
               // Initialize Grouping with invalid value
              G.Prop := TGroupByProperty(255);
              while ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
                case Code of
                  IPhChunk_ViewGrouping_Prop:    G.Prop          := aXlat_ChunkGroupingPropToGBProperty[Integer(vValue)];
                  IPhChunk_ViewGrouping_Unclass: G.bUnclassified := vValue<>Byte(0);
                   // Close-chunk
                  IPhChunk_ViewGrouping_Close: Break;
                   // Ensure unknown nested structures are skipped whole
                  else Streamer.SkipNestedChunks(Code);
                end;
               // If now Grouping is valid (valid property encountered), add it
              if G.Prop<=High(TGroupByProperty) then inherited Add(Pointer(G));
            end;
             // Close-chunk
            IPhChunk_ViewGroupings_Close: Break;
             // Ensure unknown nested structures are skipped whole
            else Streamer.SkipNestedChunks(Code);
          end;
  end;

  procedure TPhoaGroupings.StreamerSave(Streamer: TPhoaStreamer);
  var
    i, iCount: Integer;
    RG: TRawPhoaGrouping;
  begin
    with Streamer do
       // *** Old format
      if not Chunked then begin
         // Count groupings of rev. 2 format
        iCount := 0;
        for i := 0 to Count-1 do
          if GetItems(i).Prop in GBPropsRev2 then Inc(iCount);
        WriteInt(iCount);
         // Write groupings (translating GroupByProperty to old revision 2)
        for i := 0 to Count-1 do
          if GetItems(i).Prop in GBPropsRev2 then begin
            RG := TRawPhoaGrouping(GetItems(i));
            RG.bProp := aXlat_GBPropToGBProp2[RG.bProp];
            WriteInt(Integer(RG));
          end;
       // *** New format
      end else begin
        WriteChunk(IPhChunk_ViewGroupings_Open);
        for i := 0 to Count-1 do begin
          WriteChunk(IPhChunk_ViewGrouping_Open);
          WriteChunkWord(IPhChunk_ViewGrouping_Prop,    aXlat_GBPropertyToChunkGroupingProp[GetItems(i).Prop]);
          WriteChunkByte(IPhChunk_ViewGrouping_Unclass, Byte(GetItems(i).bUnclassified));
          WriteChunk(IPhChunk_ViewGrouping_Close);
        end;
        WriteChunk(IPhChunk_ViewGroupings_Close);
      end;
  end;

  procedure TPhoaGroupings.ToggleUnclassified(Index: Integer);
  var g: TPhoaGrouping;
  begin
    g := GetItems(Index);
    g.bUnclassified := not g.bUnclassified;
    inherited Items[Index] := Pointer(g);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaView
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaView.Assign(Src: TPhoaView);
  begin
    UnprocessGroups;
    FName := Src.FName;
    FGroupings.Assign(Src.FGroupings);
    FSortings.Assign(Src.FSortings);
  end;

  constructor TPhoaView.Create(List: TPhoaViews);
  begin
    inherited Create;
    FList := List;
    FList.Add(Self);
    FGroupings := TPhoaGroupings.Create;
    FSortings  := TPhoaSortings.Create;
  end;

  destructor TPhoaView.Destroy;
  begin
    UnprocessGroups;
    FList.Remove(Self);
    FGroupings.Free;
    FSortings.Free;
    inherited Destroy;
  end;

  function TPhoaView.GetIndex: Integer;
  begin
    Result := FList.IndexOf(Self);
  end;

  function TPhoaView.GetRootGroup: TPhoaGroup;
  begin
     // ���� ��� �� ��������� ������, ���������
    if FRootGroup=nil then ProcessGroups;
    Result := FRootGroup;
  end;

  procedure TPhoaView.ProcessGroups;
  var
    iGpg, iGrp, iPic: Integer;
    Gpg: TPhoaGrouping;
    Grp, GUnclassified: TPhoaGroup;
    Pic: TPhoaPic;
    GroupWithPics: TList;
    bClassified: Boolean;

     // ������ ������ �� ���� � �����������
    procedure ProcessFilePathTree(ParentGroup: TPhoaGroup; Pic: TPhoaPic);
    var
      iSlashPos: Integer;
      sDir, sOneDir: String;
      Group, GParent: TPhoaGroup;
    begin
      sDir := ExtractFileDir(Pic.PicFileName);
       // �������� � �����
      Group := ParentGroup;
      repeat
         // �������� ���� (������) ������� �� ����
        iSlashPos := Pos('\', sDir);
        if iSlashPos=0 then iSlashPos := Length(sDir)+1;
        sOneDir := Copy(sDir, 1, iSlashPos-1);
        Delete(sDir, 1, iSlashPos);
         // ���� �������� �������, ��������� ���� � �����
        if (Length(sOneDir)=2) and (sOneDir[2]=':') then sOneDir := sOneDir+'\';
         // �������� ���������� ������ ������� ������
        with Group.Groups do
          if Count=0 then GParent := nil else GParent := Items[Count-1];
         // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
        if (GParent=nil) or not AnsiSameText(GParent.Text, sOneDir) then begin
          GParent := TPhoaGroup.Create(Group, 0);
          GParent.Text     := sOneDir;
          GParent.Expanded := True;
        end;
        Group := GParent;
      until sDir='';
      Group.PicIDs.Add(Pic.ID);
    end;

     // ������ ������ �� ����������� ���� (one level)
    procedure ProcessDateTree(Prop: TGroupByProperty; ParentGroup: TPhoaGroup; Pic: TPhoaPic);
    var
      sDatePart: String;
      Group: TPhoaGroup;
    begin
       // ������� ������������ ���������� ����
      case Prop of
        gbpDateByYear:  sDatePart := 'yyyy';
        gbpDateByMonth: sDatePart := 'mmmm';
        gbpDateByDay:   sDatePart := 'd';
      end;
      sDatePart := FormatDateTime(sDatePart, Pic.PicDateTime);
       // �������� ���������� ������ ������� ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      if (Group=nil) or not AnsiSameText(Group.Text, sDatePart) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text     := sDatePart;
        Group.Expanded := True;
      end;
      Group.PicIDs.Add(Pic.ID);
    end;

     // ������ ������ �� ����������� ������� (one level)
    procedure ProcessTimeTree(Prop: TGroupByProperty; ParentGroup: TPhoaGroup; Pic: TPhoaPic);
    var
      sTimePart: String;
      Group: TPhoaGroup;
    begin
       // ������� ������������ ���������� �������
      sTimePart := FormatDateTime(iif(Prop=gbpTimeHour, 'h', 'n'), Pic.PicDateTime);
       // �������� ���������� ������ ������� ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      if (Group=nil) or not AnsiSameText(Group.Text, sTimePart) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text     := sTimePart;
        Group.Expanded := True;
      end;
      Group.PicIDs.Add(Pic.ID);
    end;

     // ������ ������ �� �������� ���������� �������� (one level)
    procedure ProcessPlainPropTree(PicProp: TPicProperty; ParentGroup: TPhoaGroup; Pic: TPhoaPic);
    var
      Group: TPhoaGroup;
      sPropVal: String;
    begin
       // �������� ���������� ������ ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      sPropVal := Pic.Props[PicProp];
      if (Group=nil) or not AnsiSameText(Group.Text, sPropVal) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text := sPropVal;
      end;
       // ��������� ����������� � ������
      Group.PicIDs.Add(Pic.ID);
    end;

     // ������ ������ �� �������� ������ (one level)
    procedure ProcessKeywordTree(ParentGroup: TPhoaGroup; Pic: TPhoaPic);
    var ikw: Integer;

       // ���� ������ ��� ��������� �����, ���� ��� ����� - ������; ��� ���� ��������� ������������� ������������������
       //   �����
      function GetKWGroup(const sKW: String): TPhoaGroup;
      var
        i, idx: Integer;
        G: TPhoaGroup;
      begin
         // ���� �� �����
        Result := nil;
        idx := -1;
        for i := 0 to ParentGroup.Groups.Count-1 do begin
          G := ParentGroup.Groups[i];
           // ���������� ������ "��� �������� ����"
          if G<>GUnclassified then
            case AnsiCompareText(G.Text, sKW) of
               // ��� �� �������� ������
              Low(Integer)..-1: ;
               // ����� ������������
              0: begin
                Result := G;
                Break;
              end;
               // ���������� ���� - ���� �������
              else begin
                idx := i;
                Break;
              end;
            end;
        end;
         // ������ ������
        if Result=nil then begin
          Result := TPhoaGroup.Create(ParentGroup, 0);
          Result.Text := sKW;
           // ���� �����  �������� ����� ��������� ������� - �����������
          if idx>=0 then Result.Index := idx;
        end;
      end;

    begin
       // ��������� ��� ������� ��������� �����
      for ikw := 0 to Pic.PicKeywords.Count-1 do GetKWGroup(Pic.PicKeywords[ikw]).PicIDs.Add(Pic.ID);
    end;

     // ����������� ��������� ���������� ������ ��������, ����������� �����������
    procedure MakeListOfGroupsWithPics(GList: TList; Group: TPhoaGroup);
    var i: Integer;
    begin
      if Group.PicIDs.Count>0 then GList.Add(Group);
      for i := 0 to Group.Groups.Count-1 do MakeListOfGroupsWithPics(GList, Group.Groups[i]);
    end;

  begin
    StartWait;
    try
       // ������ �������� ��� ������� ���������� ������ �� �������������
      if FRootGroup=nil then FRootGroup := TPhoaGroup.Create(nil, 1) else FRootGroup.Groups.Clear;
       // ������ ��������������� ������, ��������� ��� � �������� ID ����������� � �������� ������
      with TPhoaViewHelperPics.Create(False) do
        try
          CopyFromPhoa(FList.FPhoA);
          Sort(Self);
          CopyToGroup(FRootGroup);
        finally
          Free;
        end;
       // ������ �������� ����� - ��������� ��������������� ��� �����������
      GroupWithPics := TList.Create;
      try
        for iGpg := 0 to FGroupings.Count-1 do begin
          Gpg := FGroupings[iGpg];
           // ������ ������ �����, ���������� �����������
          GroupWithPics.Clear;
          MakeListOfGroupsWithPics(GroupWithPics, FRootGroup);
           // ��������� � ���� ������� �����������
          for iGrp := 0 to GroupWithPics.Count-1 do begin
            Grp := TPhoaGroup(GroupWithPics[iGrp]);
            GUnclassified := nil;
             // ���� �� ���� ������������ ������
            iPic := 0;
            while iPic<Grp.PicIDs.Count do begin
              Pic := FList.FPhoA.Pics.PicByID(Grp.PicIDs[iPic]);
               // ���������, ���������������� �� �����������
              case Gpg.Prop of
                gbpFilePath:       bClassified := True;
                gbpDateByYear,
                  gbpDateByMonth,
                  gbpDateByDay:    bClassified := Trunc(Pic.PicDateTime)<>0;
                gbpTimeHour,
                  gbpTimeMinute:   bClassified := Frac(Pic.PicDateTime)<>0;
                gbpPlace:          bClassified := Pic.PicPlace<>'';
                gbpFilmNumber:     bClassified := Pic.PicFilmNumber<>'';
                gbpAuthor:         bClassified := Pic.PicAuthor<>'';
                gbpMedia:          bClassified := Pic.PicMedia<>'';
                else {gbpKeywords} bClassified := Pic.PicKeywords.Count>0;
              end;
               // ���� ���������������� - �������� � �������� �����
              if bClassified then
                case Gpg.Prop of
                  gbpFilePath:     ProcessFilePathTree(Grp, Pic);
                  gbpDateByYear,
                    gbpDateByMonth,
                    gbpDateByDay:  ProcessDateTree(Gpg.Prop, Grp, Pic);
                  gbpTimeHour,
                    gbpTimeMinute: ProcessTimeTree(Gpg.Prop, Grp, Pic);
                  gbpPlace:        ProcessPlainPropTree(ppPlace,      Grp, Pic);
                  gbpFilmNumber:   ProcessPlainPropTree(ppFilmNumber, Grp, Pic);
                  gbpAuthor:       ProcessPlainPropTree(ppAuthor,     Grp, Pic);
                  gbpMedia:        ProcessPlainPropTree(ppMedia,      Grp, Pic);
                  gbpKeywords:     ProcessKeywordTree(Grp, Pic);
                end
               // ���� �� ���������������� � ����������� ������� ��������� ����� ����������� � ��������� �����, ������
               //   ����� ��� ������������� � �������� ���� ����������� 
              else if Gpg.bUnclassified then begin
                if GUnclassified=nil then begin
                  GUnclassified := TPhoaGroup.Create(Grp, 0);
                  GUnclassified.Index := 0;
                  GUnclassified.Text := ConstVal(asUnclassifiedConsts[Gpg.Prop]);
                end;
                GUnclassified.PicIDs.Add(Pic.ID);
               // ����� - ��������� � ���������� �����������
              end else begin
                Inc(iPic);
                Continue;
              end;
               // ������� ����������� �� ������ ������
              Grp.PicIDs.Remove(Pic.ID);
            end;
          end;
        end;
      finally
        GroupWithPics.Free;
      end;
       // ������������ ������� ���������� ID
      FRootGroup.FixupIDs;
    finally
      StopWait;
    end;
  end;

  procedure TPhoaView.StreamerLoad(Streamer: TPhoaStreamer);
  var
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
     // *** Old format
    if not Streamer.Chunked then begin
       // Read name
      FName := Streamer.ReadStringI;
       // Read groupings
      FGroupings.StreamerLoad(Streamer);
     // *** New format
    end else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // Name
          IPhChunk_View_Name: FName := vValue;
           // Groupings
          IPhChunk_ViewGroupings_Open: FGroupings.StreamerLoad(Streamer);
           // Sortings
          IPhChunk_ViewSortings_Open: FSortings.StreamerLoad(Streamer);
           // Close-chunk
          IPhChunk_View_Close: Break;
           // Ensure unknown nested structures are skipped whole
          else Streamer.SkipNestedChunks(Code);
        end;
  end;

  procedure TPhoaView.StreamerSave(Streamer: TPhoaStreamer);
  begin
     // *** Old format
    if not Streamer.Chunked then begin
       // Write name
      Streamer.WriteStringI(FName);
       // Write groupings
      FGroupings.StreamerSave(Streamer);
     // *** New format
    end else begin
       // Write close-chunk
      Streamer.WriteChunk(IPhChunk_View_Open);
       // Write name
      Streamer.WriteChunkString(IPhChunk_View_Name, FName);
       // Write groupings/sortings
      FGroupings.StreamerSave(Streamer);
      FSortings.StreamerSave(Streamer);
       // Write close-chunk
      Streamer.WriteChunk(IPhChunk_View_Close);
    end;
  end;

  procedure TPhoaView.UnprocessGroups;
  begin
    FreeAndNil(FRootGroup);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaViews
   //-------------------------------------------------------------------------------------------------------------------

  function TPhoaViews.Add(View: TPhoaView): Integer;
  begin
    Result := inherited Add(View);
  end;

  procedure TPhoaViews.Assign(Src: TPhoaViews);
  var i: Integer;
  begin
    Clear;
    for i := 0 to Src.Count-1 do TPhoaView.Create(Self).Assign(Src[i]);
  end;

  procedure TPhoaViews.Clear;
  begin
    while Count>0 do Delete(0);
    inherited Clear;
  end;

  constructor TPhoaViews.Create(PhoA: TPhotoAlbum);
  begin
    inherited Create;
    FPhoA := PhoA;
  end;

  procedure TPhoaViews.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  function TPhoaViews.GetItems(Index: Integer): TPhoaView;
  begin
    Result := TPhoaView(inherited Items[Index]);
  end;

  function PhoaViewsSortCompare(Item1, Item2: Pointer): Integer;
  begin
    Result := AnsiCompareText(TPhoaView(Item1).Name, TPhoaView(Item2).Name);
  end;

  function TPhoaViews.IndexOfName(const sName: String): Integer;
  begin
    for Result := 0 to Count-1 do
      if AnsiSameText(GetItems(Result).Name, sName) then Exit;
    Result := -1;
  end;

  procedure TPhoaViews.Sort;
  begin
    inherited Sort(PhoaViewsSortCompare);
  end;

  procedure TPhoaViews.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    Clear;
     // *** Old format
    if not Streamer.Chunked then
       // Read views
      for i := 0 to Streamer.ReadInt-1 do TPhoaView.Create(Self).StreamerLoad(Streamer)
     // *** New format
    else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // View
          IPhChunk_View_Open: TPhoaView.Create(Self).StreamerLoad(Streamer);
           // Close-chunk
          IPhChunk_Views_Close: Break;
           // Ensure unknown nested structures are skipped whole
          else Streamer.SkipNestedChunks(Code);
        end;
  end;

  procedure TPhoaViews.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
     // *** Old format
    if not Streamer.Chunked then begin
      Streamer.WriteInt(Count);
       // Write views
      for i := 0 to Count-1 do GetItems(i).StreamerSave(Streamer);
     // *** New format
    end else begin
      Streamer.WriteChunk(IPhChunk_Views_Open);
       // Write views
      for i := 0 to Count-1 do GetItems(i).StreamerSave(Streamer);
      Streamer.WriteChunk(IPhChunk_Views_Close);
    end;
  end;

  procedure TPhoaViews.UnprocessAllViews;
  var i: Integer;
  begin
    for i := 0 to Count-1 do GetItems(i).UnprocessGroups;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhotoAlbum
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhotoAlbum.Assign(Src: TPhotoAlbum; bCopyRevision: Boolean);
  begin
    FFileName         := Src.FFileName;
    FDescription      := Src.FDescription;
    FThumbnailQuality := Src.FThumbnailQuality;
    FThumbnailWidth   := Src.FThumbnailWidth;
    FThumbnailHeight  := Src.FThumbnailHeight;
    if bCopyRevision then FFileRevision := Src.FFileRevision;
  end;

  constructor TPhotoAlbum.Create;
  begin
    inherited Create;
    FRootGroup        := TPhoaGroup.Create(nil, 1);
    FRootGroup.FixupIDs;
    FPics             := TPhoaPics.Create(Self);
    FViews            := TPhoaViews.Create(Self);
    FFileRevision     := IPhFileRevisionNumber;
    FThumbnailQuality := IDefaultThumbQuality;
    FThumbnailHeight  := IDefaultThumbHeight;
    FThumbnailWidth   := IDefaultThumbWidth;
  end;

  destructor TPhotoAlbum.Destroy;
  begin
    FreeAndNil(FRootGroup);
    FPics.Free;
    FViews.Free;
    inherited Destroy;
  end;

  procedure TPhotoAlbum.FileLoad(const sFileName: String; UndoOperations: TPhoaOperations);
  var Streamer: TPhoaStreamer;
  begin
    New(UndoOperations);
    try
       // ������ FilerEx � ��������� � ��� �������
      Streamer := TPhoaFilerEx.Create(psmRead, sFileName);
      try
        Streamer.ReadHeader;
        StreamerLoad(Streamer);
         // ��������� ����� ��� ����� � �������
        FFileName     := sFileName;
        FFileRevision := Streamer.RevisionNumber;
      finally
        Streamer.Free;
      end;
    except
      New(UndoOperations);
      raise;
    end;
  end;

  procedure TPhotoAlbum.FileSave(UndoOperations: TPhoaOperations);
  begin
    FileSaveTo(FFileName, FFileRevision, UndoOperations);
  end;

  procedure TPhotoAlbum.FileSaveTo(const sFileName: String; iRevisionNumber: Integer; UndoOperations: TPhoaOperations);
  var Streamer: TPhoaStreamer;
  begin
     // ������������� ������������, ���� �� ��������� � ����� ������ �������
    if (iRevisionNumber<IPhFileRevisionNumber) and not PhoaConfirm(True, 'SConfirm_SavingOldFormatFile', ISettingID_Dlgs_ConfmOldFile) then Exit;
     // ������ FilerEx � ��������� � ��� �������
    Streamer := TPhoaFilerEx.Create(psmWrite, sFileName);
    try
      Streamer.RevisionNumber := iRevisionNumber;
      Streamer.WriteHeader;
      StreamerSave(Streamer);
    finally
      Streamer.Free;
    end;
     // ��������� ����� ��� ����� � �������
    FFileName     := sFileName;
    FFileRevision := iRevisionNumber;
     // Invoke UndoOperations' status change
    if UndoOperations<>nil then UndoOperations.SetSavepoint;
  end;

  procedure TPhotoAlbum.New(UndoOperations: TPhoaOperations);
  begin
    FRootGroup.PicIDs.Clear;
    FRootGroup.Groups.Clear;
    FPics.Clear;
    FViews.Clear;
    FFileRevision     := IPhFileRevisionNumber;
    FDescription      := '';
    FFileName         := '';
    FThumbnailQuality := IDefaultThumbQuality;
    FThumbnailHeight  := IDefaultThumbHeight;
    FThumbnailWidth   := IDefaultThumbWidth;
    if UndoOperations<>nil then begin
      UndoOperations.Clear;
      UndoOperations.SetSavepoint;
    end;
  end;

  procedure TPhotoAlbum.RemoveUnlinkedPics(UndoOperations: TPhoaOperations);
  var
    i: Integer;
    pic: TPhoaPic;
  begin
    i := 0;
    while i<FPics.Count do begin
      pic := FPics[i];
      if not FRootGroup.IsPicLinked(pic.ID, True) then TPhoaOp_InternalPicRemoving.Create(UndoOperations, Self, pic) else Inc(i);
    end;
  end;

  procedure TPhotoAlbum.SetThumbnailHeight(Value: Integer);
  begin
    if FThumbnailHeight<>Value then begin
      FThumbnailHeight := Value;
      ThumbDimensionsChanged;
    end;
  end;

  procedure TPhotoAlbum.SetThumbnailWidth(Value: Integer);
  begin
    if FThumbnailWidth<>Value then begin
      FThumbnailWidth := Value;
      ThumbDimensionsChanged;
    end;
  end;

  procedure TPhotoAlbum.StreamerLoad(Streamer: TPhoaStreamer);
  var
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
     // *** Old format
    if not Streamer.Chunked then begin
       // Read photo album properties
      with Streamer do begin
        FDescription      := ReadStringI;
        FThumbnailQuality := ReadInt;
        FThumbnailWidth   := ReadInt;
        FThumbnailHeight  := ReadInt;
      end;
       // Read groups
      FRootGroup.StreamerLoad(Streamer);
       // Read pictures
      FPics.StreamerLoad(Streamer);
       // If revision 2+, read views
      if Streamer.RevisionNumber>=2 then FViews.StreamerLoad(Streamer);
     // *** New format
    end else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // Photo album properties
          IPhChunk_PhoaDescription:  FDescription      := vValue;
          IPhChunk_PhoaThumbQuality: FThumbnailQuality := vValue;
          IPhChunk_PhoaThumbWidth:   FThumbnailWidth   := vValue;
          IPhChunk_PhoaThumbHeight:  FThumbnailHeight  := vValue;
           // Pictures
          IPhChunk_Pics_Open:        FPics.StreamerLoad(Streamer);
           // Root group
          IPhChunk_Group_Open:       FRootGroup.StreamerLoad(Streamer);
           // Views
          IPhChunk_Views_Open:       FViews.StreamerLoad(Streamer);
           // Ensure unknown nested structures are skipped whole
          else Streamer.SkipNestedChunks(Code);
        end;
     // ��������� ���������� ID �������, ��� �� ������� (�����, ���� ���������� ������� ������� PhoA ������ 1.1.5)
    FRootGroup.FixupIDs; 
  end;

  procedure TPhotoAlbum.StreamerSave(Streamer: TPhoaStreamer);
  begin
     // *** Old format
    if not Streamer.Chunked then begin
       // Write photo album properties
      with Streamer do begin
        WriteStringI(FDescription);
        WriteInt(FThumbnailQuality);
        WriteInt(FThumbnailWidth);
        WriteInt(FThumbnailHeight);
      end;
       // Write groups
      FRootGroup.StreamerSave(Streamer);
       // Write pictures
      FPics.StreamerSave(Streamer);
       // If revision 2+, write views
      if Streamer.RevisionNumber>=2 then FViews.StreamerSave(Streamer);
     // *** New format
    end else begin
      with Streamer do begin
         // Write photo album 'metadata'
        WriteChunkString(IPhChunk_Remark,           Format('Created by PhoA %s, %s', [SAppVersion, ConstVal('SWebsite')]));
         // Write photo album properties
        WriteChunkString(IPhChunk_PhoaGenerator,    'PhoA '+SAppVersion);
        WriteChunkInt   (IPhChunk_PhoaSavedDate,    DateToPhoaDate(Date));
        WriteChunkInt   (IPhChunk_PhoaSavedTime,    TimeToPhoaTime(Time));
        WriteChunkString(IPhChunk_PhoaDescription,  FDescription);
        WriteChunkByte  (IPhChunk_PhoaThumbQuality, FThumbnailQuality);
        WriteChunkWord  (IPhChunk_PhoaThumbWidth,   FThumbnailWidth);
        WriteChunkWord  (IPhChunk_PhoaThumbHeight,  FThumbnailHeight);
      end;
       // Write pictures
      FPics.StreamerSave(Streamer);
       // Write groups
      FRootGroup.StreamerSave(Streamer);
       // Write views
      FViews.StreamerSave(Streamer);
    end;
  end;

  procedure TPhotoAlbum.ThumbDimensionsChanged;
  begin
    if Assigned(FOnThumbDimensionsChanged) then FOnThumbDimensionsChanged(Self);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPicPropertyChanges
   //-------------------------------------------------------------------------------------------------------------------

  function TPicPropertyChanges.Add(const sNewValue: String; Prop: TPicProperty): Integer;
  var p: PPicPropertyChange;
  begin
    New(p);
    Result := inherited Add(p);
    p^.sNewValue := sNewValue;
    p^.Prop      := Prop;
  end;

  function TPicPropertyChanges.GetChangedProps: TPicProperties;
  var i: Integer;
  begin
    Result := [];
    for i := 0 to Count-1 do Include(Result, GetItems(i).Prop);
  end;

  function TPicPropertyChanges.GetItems(Index: Integer): PPicPropertyChange;
  begin
    Result := PPicPropertyChange(inherited Items[Index]);
  end;

  procedure TPicPropertyChanges.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action in [lnExtracted, lnDeleted] then Dispose(PPicPropertyChange(Ptr));
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaFilerEx
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaFilerEx.ValidateRevision;
  begin
     // �� ��������� ���������� ������ ����� ����� �������
    if RevisionNumber>IPhFileRevisionNumber then PhoaException(ConstVal('SErrFileRevHigher'), []);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOperation
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOperation.Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
  begin
    FList := List;
    List.Add(Self);
    FPhoA := PhoA;
  end;

  destructor TPhoaOperation.Destroy;
  begin
    FList.Remove(Self);
    inherited Destroy;
  end;

  function TPhoaOperation.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [];
  end;

  function TPhoaOperation.GetOpGroup: TPhoaGroup;
  begin
    Result := FPhoA.RootGroup.GroupByID[FOpGroupID];
  end;

  function TPhoaOperation.GetParentOpGroup: TPhoaGroup;
  begin
    Result := FPhoA.RootGroup.GroupByID[FOpParentGroupID];
  end;

  function TPhoaOperation.Name: String;
  begin
    Result := ConstVal(ClassName);
  end;

  procedure TPhoaOperation.SetOpGroup(Value: TPhoaGroup);
  begin
    FOpGroupID := Value.ID;
  end;

  procedure TPhoaOperation.SetParentOpGroup(Value: TPhoaGroup);
  begin
    FOpParentGroupID := Value.ID;
  end;

  procedure TPhoaOperation.Undo;
  begin
    Free;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOperations
   //-------------------------------------------------------------------------------------------------------------------

  function TPhoaOperations.Add(Item: TPhoaOperation): Integer;
  begin
    Result := inherited Add(Item);
    DoStatusChange;
    if Assigned(FOnOpDone) then FOnOpDone(Self);
  end;

  procedure TPhoaOperations.BeginUpdate;
  begin
    Inc(FUpdateLock);
  end;

  procedure TPhoaOperations.Clear;
  begin
    BeginUpdate;
    try
      while Count>0 do Delete(0);
      inherited Clear;
    finally
      EndUpdate;
    end;
  end;

  constructor TPhoaOperations.Create;
  begin
    inherited Create;
    FSavepointOnEmpty := True;
  end;

  procedure TPhoaOperations.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  procedure TPhoaOperations.DoStatusChange;
  begin
    if Assigned(FOnStatusChange) then FOnStatusChange(Self);
  end;

  procedure TPhoaOperations.EndUpdate;
  begin
    if FUpdateLock>0 then begin
      Dec(FUpdateLock);
      if FUpdateLock=0 then DoStatusChange;
    end;
  end;

  function TPhoaOperations.GetCanUndo: Boolean;
  begin
    Result := Count>0;
  end;

  function TPhoaOperations.GetIsUnmodified: Boolean;
  begin
    if Count=0 then Result := FSavepointOnEmpty else Result := GetItems(Count-1).FSavepoint;
  end;

  function TPhoaOperations.GetItems(Index: Integer): TPhoaOperation;
  begin
    Result := TPhoaOperation(inherited Items[Index]);
  end;

  function TPhoaOperations.GetLastOpName: String;
  begin
    if Count=0 then Result := '' else Result := GetItems(Count-1).Name;
  end;

  function TPhoaOperations.Remove(Item: TPhoaOperation): Integer;
  begin
    Result := inherited Remove(Item);
    if Result>=0 then begin
      DoStatusChange;
      if Assigned(FOnOpUndone) then FOnOpUndone(Self);
    end;
  end;

  procedure TPhoaOperations.SetNonUndoable;
  begin
    BeginUpdate;
    try
      Clear;
      FSavepointOnEmpty := False;
    finally
      EndUpdate;
    end;
  end;

  procedure TPhoaOperations.SetSavepoint;
  var i: Integer;
  begin
    BeginUpdate;
    try
      for i := 0 to Count-1 do GetItems(i).FSavepoint := i=Count-1;
      FSavepointOnEmpty := Count=0;
    finally
      EndUpdate;
    end;
  end;

  procedure TPhoaOperations.UndoAll;
  var i: Integer;
  begin
    BeginUpdate;
    try
      for i := Count-1 downto 0 do GetItems(i).Undo;
    finally
      EndUpdate;
    end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMultiOp.Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
  begin
    inherited Create(List, PhoA);
    FOperations := TPhoaOperations.Create;
  end;

  destructor TPhoaMultiOp.Destroy;
  begin
    FOperations.Free;
    inherited Destroy;
  end;

  procedure TPhoaMultiOp.Undo;
  begin
    FOperations.UndoAll;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_NewGroup
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_GroupNew.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; CurGroup: TPhoaGroup);
  var g: TPhoaGroup;
  begin
    inherited Create(List, PhoA);
     // ������ �������� ������
    g := TPhoaGroup.Create(CurGroup, PhoA.RootGroup.FreeID);
    g.Text := ConstVal('SDefaultNewGroupName');
    OpParentGroup := CurGroup;
    OpGroup       := g;
  end;

  function TPhoaOp_GroupNew.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReinitParent, uifXEditGroup, // Execution flags
      uifUReinitParent];               // Undo flags
  end;

  procedure TPhoaOp_GroupNew.Undo;
  begin
     // ������� ������ ��������
    OpGroup.Free;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_GroupRename
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_GroupRename.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText: String);
  begin
    inherited Create(List, PhoA);
     // ��������� �������� � ���������� ������ ������
    FOldText := Group.Text;
    Group.Text := sNewText;
    OpGroup := Group;
  end;

  function TPhoaOp_GroupRename.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [uifUInvalidateNode]; // Undo flags
  end;

  procedure TPhoaOp_GroupRename.Undo;
  begin
     // �������� ������ � ��������������� �����
    OpGroup.Text := FOldText;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_GroupEdit
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_GroupEdit.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText, sNewDescription: String);
  begin
    inherited Create(List, PhoA, Group, sNewText);
     // ��������� �������� � ���������� ������ ������
    FOldDescription := Group.Description;
    Group.Description := sNewDescription;
  end;

  procedure TPhoaOp_GroupEdit.Undo;
  begin
     // �������� ������ � ��������������� ��������
    OpGroup.Description := FOldDescription;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_GroupDelete
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_GroupDelete.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; bPerform: Boolean);
  var i: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������ ��������� ������
    OpParentGroup := Group.Owner;
    FGroupID      := Group.ID;
    FGroupName    := Group.Text;
    FGroupIndex   := Group.Index;
    FExpanded     := Group.Expanded;
     // ���������� ���������� (ID �����������)
    if Group.PicIDs.Count>0 then begin
      FPicIDs := TIntegerList.Create(False);
      FPicIDs.Assign(Group.PicIDs);
    end;
     // ���������� ������ �������� ��������� �����
    if Group.Groups.Count>0 then begin
      FCascadedDeletes    := TPhoaOperations.Create;
      for i := 0 to Group.Groups.Count-1 do TPhoaOp_GroupDelete.Create(FCascadedDeletes, PhoA, Group.Groups[i], False);
    end;
     // ��������� ��������
    if bPerform then begin
       // ������� ������
      Group.Free;
       // ������� �������������� �����������
      FUnlinkedPicRemoves := TPhoaOperations.Create;
      PhoA.RemoveUnlinkedPics(FUnlinkedPicRemoves);
    end;
  end;

  destructor TPhoaOp_GroupDelete.Destroy;
  begin
    FCascadedDeletes.Free;
    FUnlinkedPicRemoves.Free;
    FPicIDs.Free;
    inherited Destroy;
  end;

  function TPhoaOp_GroupDelete.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReinitParent, uifXReinitRecursive, // Execution flags
      uifUReinitParent, uifUReinitRecursive]; // Undo flags
  end;

  procedure TPhoaOp_GroupDelete.InternalUndo(gOwner: TPhoaGroup);
  var
    i: Integer;
    g: TPhoaGroup;
  begin
     // ��������������� ������
    g := TPhoaGroup.Create(gOwner, FGroupID);
    g.Text     := FGroupName;
    g.Index    := FGroupIndex;
    g.Expanded := FExpanded;
    if FPicIDs<>nil then g.PicIDs.Assign(FPicIDs);
     // ��������������� �������� �������� ������
    if FCascadedDeletes<>nil then
      for i := 0 to FCascadedDeletes.Count-1 do TPhoaOp_GroupDelete(FCascadedDeletes[i]).InternalUndo(g);
  end;

  procedure TPhoaOp_GroupDelete.Undo;
  begin
     // ��������������� �������� (�����������) �����������
    if FUnlinkedPicRemoves<>nil then FUnlinkedPicRemoves.UndoAll;
     // ��������������� ����� �����/�����
    InternalUndo(OpParentGroup);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalPicRemoving
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalPicRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic);
  begin
    inherited Create(List, PhoA);
     // ��������� ������ �����������
    FPicData := Pic.RawData[PPAllProps];
     // ��������� ��������
    Pic.Free;
  end;

  procedure TPhoaOp_InternalPicRemoving.Undo;
  var Pic: TPhoaPic;
  begin
     // ������ ����������� � ��������� ������
    Pic := TPhoaPic.Create(FPhoA);
    try
      Pic.RawData[PPAllProps] := FPicData;
      Pic.List := FPhoA.Pics; // Assign the List AFTER props have been read because List sorts pics by IDs
    except
      Pic.Free;
      raise;
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalEditPicProps
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalEditPicProps.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; ChangeList: TPicPropertyChanges);
  var
    iPic, iChg: Integer;
    Pic: TPhoaPic;
  begin
    inherited Create(List, PhoA);
     // ��������� ����� ������������ �������
    FChangedProps := ChangeList.ChangedProps;
     // ���� �� ������������
    SetLength(FSavedProps, Length(Pics));
    for iPic := 0 to High(Pics) do begin
       // ���������� ������ ������
      Pic := Pics[iPic];
      FSavedProps[iPic].iPicID   := Pic.ID;
      FSavedProps[iPic].sPicData := Pic.RawData[FChangedProps];
       // ��������� ����� ������
      for iChg := 0 to ChangeList.Count-1 do
        with ChangeList[iChg]^ do Pic.Props[Prop] := sNewValue;
    end;
  end;

  procedure TPhoaOp_InternalEditPicProps.Undo;
  var i: Integer;
  begin
     // ���������� ������ ��������� �����������
    for i := 0 to High(FSavedProps) do
      with FSavedProps[i] do FPhoA.Pics.PicByID(iPicID).RawData[FChangedProps] := sPicData;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalEditPicKeywords
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalEditPicKeywords.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; Keywords: TKeywordList);
  var
    iPic, iCnt, iKwd, idxKeyword: Integer;
    Pic: TPhoaPic;
    pkr: PKeywordRec;
    bKWSaved: Boolean;

     // ��������� �������� ����� ����������� � FSavedKeywords, ���� ����� ��� �� �������
    procedure SavePicKeywords;
    begin
      if not bKWSaved then begin
        FSavedKeywords.AddObject(Pic.PicKeywords.CommaText, Pointer(Pic.ID));
        bKWSaved := True;
      end;
    end;

  begin
    inherited Create(List, PhoA);
    FSavedKeywords := TStringList.Create;
    iCnt := Length(Pics);
     // ���� �� ������������
    for iPic := 0 to iCnt-1 do begin
      Pic := Pics[iPic];
      bKWSaved := False;
       // ���� �� �������� ������
      for iKwd := 0 to Keywords.Count-1 do begin
        pkr := Keywords[iKwd];
        case pkr.Change of
           // �� �� ��������. ��������� ��������� �����
          kcNone:
             // ���� Grayed - ������ ������ �� �����������. ���� �� ��������, � �� �� ���������� �� � ����� �����������
             //   - ������ ������. ���� �������� ���������, � �� ���������� �� ���� ������������ - ������ ������.
             //   ����� ��������� ������� �� � �����������
            if ((pkr.State=ksOff) and (pkr.iSelCount>0)) or ((pkr.State=ksOn) and (pkr.iSelCount<iCnt)) then begin
              idxKeyword := Pic.PicKeywords.IndexOf(pkr.sKeyword);
              case pkr.State of
                 // ���� ������ ��. ���� ��� ���� - �������
                ksOff:
                  if idxKeyword>=0 then begin
                    SavePicKeywords;
                    Pic.PicKeywords.Delete(idxKeyword);
                  end;
                 // ���� �������� ��. ���� ��� - ���������
                ksOn:
                  if idxKeyword<0 then begin
                    SavePicKeywords;
                    Pic.PicKeywords.Add(pkr.sKeyword);
                  end;
              end;
            end;
           // ���������� ������ ��. ���� ���� ����� - ���� ��������
          kcAdd:
            if pkr.State=ksOn then begin
              SavePicKeywords;
              Pic.PicKeywords.Add(pkr.sKeyword);
            end;
           // �� ��������. ���� ������ ��� �� ��������� ������������� � �����������, ...
          kcReplace:
            if (pkr.State<>ksOff) or (pkr.iSelCount>0) then begin
               // ... ���� ������ �� � �������, ...
              idxKeyword := Pic.PicKeywords.IndexOf(pkr.sOldKeyword);
              if idxKeyword>=0 then begin
                SavePicKeywords;
                Pic.PicKeywords.Delete(idxKeyword);
              end;
               // ... ���� ��������� ksOn - ��������� ����� ����, ���� ksGrayed - ��������� ������ � ��, ��� ���� ������
              if (pkr.State=ksOn) or ((pkr.State=ksGrayed) and (idxKeyword>=0)) then begin
                SavePicKeywords;
                Pic.PicKeywords.Add(pkr.sKeyword);
              end;
            end;
        end;
      end;
    end;
  end;

  destructor TPhoaOp_InternalEditPicKeywords.Destroy;
  begin
    FSavedKeywords.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_InternalEditPicKeywords.Undo;
  var i: Integer;
  begin
     // ���������� �� ��������� ������������
    for i := 0 to FSavedKeywords.Count-1 do
      FPhoA.Pics.PicByID(Integer(FSavedKeywords.Objects[i])).PicKeywords.CommaText := FSavedKeywords[i];
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_StoreTransform
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_StoreTransform.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic; NewRotation: TPicRotation; NewFlips: TPicFlips);
  begin
    inherited Create(List, PhoA);
     // ��������� ������� ��������
    FPicID         := Pic.ID;
    FSavedRotation := Pic.PicRotation;
    FSavedFlips    := Pic.PicFlips;
     // ��������� ����� ��������
    Pic.PicRotation := NewRotation;
    Pic.PicFlips    := NewFlips; 
  end;

  procedure TPhoaOp_StoreTransform.Undo;
  var Pic: TPhoaPic;
  begin
    Pic := PhoA.Pics.PicByID(FPicID);
    Pic.PicRotation := FSavedRotation;
    Pic.PicFlips    := FSavedFlips;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalPicAdd
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalPicAdd.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sFilename: String);
  var Pic: TPhoaPic;
  begin
    inherited Create(List, PhoA);
     // ���� ��� ������������ ����������� � ��� �� ������
    Pic := PhoA.Pics.PicByFileName(sFilename);
    FExisting := Pic<>nil;
     // ���� ���� ��� �� �������������, ������ ��������� TPhoaPic
    if not FExisting then begin
      Pic := TPhoaPic.Create(PhoA);
       // �������� ID, ��������� � ������ � ������ �����
      with Pic do
        try
          IDNeeded(PhoA.Pics);
          Pic.List := PhoA.Pics;
          PicFileName := sFilename;
          MakeThumbnail;
        except
          Free;
          raise;
        end;
    end;
     // ��������� � ������
    RegisterPic(Group, Pic);
    FAddedPic := Pic;
  end;

  constructor TPhoaOp_InternalPicAdd.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pic: TPhoaPic);
  var PicEx: TPhoaPic;
  begin
    inherited Create(List, PhoA);
     // ���� ��� ������������ ����������� � ��� �� ������
    PicEx := PhoA.Pics.PicByFileName(Pic.PicFileName);
    FExisting := PicEx<>nil;
     // ���� ��� (����� �����������) - ���������
    if not FExisting then begin
       // ������������ ����� ID
      Pic.FID := 0;
      Pic.IDNeeded(PhoA.Pics);
       // ������� � ������
      Pic.List := PhoA.Pics;
     // ����� ���������� �����
    end else begin
      Pic.Free;
      Pic := PicEx;
    end;
     // ��������� � ������
    RegisterPic(Group, Pic);
  end;

  procedure TPhoaOp_InternalPicAdd.RegisterPic(Group: TPhoaGroup; Pic: TPhoaPic);
  begin
     // ��������� ����������� � ������, ���� ��� �� ����
    if Group.PicIDs.Add(Pic.ID) then begin
       // ��������� ������ ��� ������
      FPicID  := Pic.ID;
      OpGroup := Group;
    end;
  end;

  procedure TPhoaOp_InternalPicAdd.Undo;
  begin
     // ���� ������� �������� ���� �������
    if FPicID>0 then begin
       // ������� �� ������
      OpGroup.PicIDs.Remove(FPicID);
       // ���� ���� ��������� ����� �����������, ������� � �� �����������
      if not FExisting then FPhoA.Pics.PicByID(FPicID).Free;
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_PicFromGroupRemove
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalPicFromGroupRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  var i, idx: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ID � �������
    FIDsAndIndexes := TIntegerList.Create(True);
    for i := 0 to High(aPicIDs) do begin
       // ���� ���� ����� ID � ������, ���������� � �������
      idx := Group.PicIDs.IndexOf(aPicIDs[i]);
      if idx>=0 then begin
        FIDsAndIndexes.Add(aPicIDs[i]);
        FIDsAndIndexes.Add(idx);
        Group.PicIDs.Delete(idx);
      end;
    end;
     // ���������� ������
    OpGroup := Group;
  end;

  destructor TPhoaOp_InternalPicFromGroupRemoving.Destroy;
  begin
    FIDsAndIndexes.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_InternalPicFromGroupRemoving.Undo;
  var
    i: Integer;
    g: TPhoaGroup;
  begin
    g := OpGroup;
     // ��������������� ����������� � �������� �������, ����� ��� ������ �� ���� �����
    i := FIDsAndIndexes.Count-2; // i ��������� �� ID, i+1 - �� ������
    while i>=0 do begin
      g.PicIDs.Insert(FIDsAndIndexes[i+1], FIDsAndIndexes[i]);
      Dec(i, 2);
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalPicToGroupAdding
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalPicToGroupAdding.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  var i: Integer;
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
    FAddedIDs := TIntegerList.Create(False);
     // ��������� ����������� � ������ � � ������
    for i := 0 to High(aPicIDs) do
      if Group.PicIDs.Add(aPicIDs[i]) then FAddedIDs.Add(aPicIDs[i]);
  end;

  destructor TPhoaOp_InternalPicToGroupAdding.Destroy;
  begin
    FAddedIDs.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_InternalPicToGroupAdding.Undo;
  var
    i: Integer;
    g: TPhoaGroup;
  begin
     // ������� ����������� �����������
    g := OpGroup;
    for i := FAddedIDs.Count-1 downto 0 do g.PicIDs.Remove(FAddedIDs[i]);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaBaseOp_PicCopy
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaBaseOp_PicCopy.Create(const aPics: TPicArray);
  var pcfs: TPicClipboardFormats;

     // �������� � ����� ������ ������ TPhoaPic
    procedure CopyPhoaData;
    var
      i: Integer;
      ms: TMemoryStream;
      Streamer: TPhoaStreamer;
      hRec: THandle;
      p: Pointer;
    begin
       // ��������� ������ ����������� �� ��������� �����
      ms := TMemoryStream.Create;
      try
        Streamer := TPhoaStreamer.Create(ms, psmWrite, '');
        try
           // ��������� ������ �����������
          for i := 0 to High(aPics) do begin
            Streamer.WriteChunk(IPhChunk_Pic_Open);
            aPics[i].StreamerSave(Streamer, False, PPAllProps);
            Streamer.WriteChunk(IPhChunk_Pic_Close);
          end;
        finally
          Streamer.Free;
        end;
         // �������� ������ � ��������� �
        hRec := GlobalAlloc(GMEM_MOVEABLE or GMEM_DDESHARE, ms.Size);
        p := GlobalLock(hRec);
        try
           // ������������ ������ � ������
          Move(ms.Memory^, p^, ms.Size);
        finally
          GlobalUnlock(hRec);
        end;
      finally
        ms.Free;
      end;
       // ��������
      Clipboard.SetAsHandle(wClipbrdPicFormatID, hRec);
    end;

     // �������� � ����� ������ ������� "����"
    procedure CopyFileObjects;
    var
      i: Integer;
      HD: THDrop;
      SL: TStringList;
    begin
      SL := TStringList.Create;
      try
         // ��������� ����������
        SL.Sorted := True;
        SL.Duplicates := dupIgnore;
         // ���������� ������ ������ ����� ������ � StringList
        for i := 0 to High(aPics) do SL.Add(aPics[i].PicFileName);
         // ������ ������ THDrop
        HD := THDrop.Create;
        try
           // �������� ������ ������ � THDrop
          HD.AssignFiles(SL);
           // �������� ����� � clipboard (�� ���������� HD.SaveToClipboard, �.�. ���� ����� �������� ���������� �
           //   WinAPI, ��������� ������� ������ �� Clipboard)
          Clipboard.SetAsHandle(CF_HDROP, HD.HDropStruct);
        finally
          HD.Free;
        end;
      finally
        SL.Free;
      end;
    end;

     // �������� � ����� ������ ��������� ������ ����� � ������ �����������
    procedure CopyFileList;
    var
      i: Integer;
      s: String;
    begin
       // ���������� ������ ������ ����� ������
      s := '';
      for i := 0 to High(aPics) do s := s+aPics[i].PicFileName+S_CRLF;
       // �������� ����� � clipboard
      Clipboard.AsText := s;
    end;

     // �������� � ����� ������ bitmap-����� ����������� Pic
    procedure CopyThumbBitmap(Pic: TPhoaPic);
    var
      bmp: TBitmap;
      wFmt: Word;
      hData: THandle;
      hPal: HPALETTE;
    begin
       // ������������ �����
      bmp := TBitmap.Create;
      try
        Pic.PaintThumbnail(bmp);
         // �������� bitmap � clipboard
        bmp.SaveToClipboardFormat(wFmt, hData, hPal);
        Clipboard.SetAsHandle(wFmt, hData);
      finally
        bmp.Free;
      end;
    end;

  begin
    StartWait;
    try
      if High(aPics)>=0 then begin
        pcfs := TPicClipboardFormats(Byte(SettingValueInt(ISettingID_Gen_ClipFormats)));
        Clipboard.Open;
        try
           // �������� PhoA-������
          if pcfPhoa in pcfs then CopyPhoaData;
           // �������� ������� "����"
          if pcfHDrop in pcfs then CopyFileObjects;
           // �������� ������ ����� ������
          if pcfPlainList in pcfs then CopyFileList;
           // �������� ����������� ������ (� ������ ������������� �����������)
          if (pcfSingleBitmap in pcfs) and (High(aPics)=0) then CopyThumbBitmap(aPics[0]);
        finally
          Clipboard.Close;
        end;
      end;
    finally
      StopWait;
    end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp_PicDelete
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMultiOp_PicDelete.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
     // ������� ID ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, Group, aPicIDs);
     // ������� ����������� ����������� �� �����������
    FPhoA.RemoveUnlinkedPics(FOperations);
  end;

  function TPhoaMultiOp_PicDelete.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
     // ������ Invalidate, ����� �������� ������� ���� ������ (static text)
    Result := [
      uifXInvalidateNode,  // Execution flags
      uifUInvalidateNode]; // Undo flags
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp_PicPaste
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMultiOp_PicPaste.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup);
  var
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
    Pic: TPhoaPic;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    inherited Create(List, PhoA);
    StartWait;
    try
      if Clipboard.HasFormat(wClipbrdPicFormatID) then begin
        OpGroup := Group;
         // ������� ��������� �����
        ms := TMemoryStream.Create;
        try
           // �������� ������ �� ������ ������
          hRec := Clipboard.GetAsHandle(wClipbrdPicFormatID);
          ms.Write(GlobalLock(hRec)^, GlobalSize(hRec));
          GlobalUnlock(hRec);
          ms.Position := 0;
           // ������ Streamer
          Streamer := TPhoaStreamer.Create(ms, psmRead, '');
          try
             // ������ ����������� �����������
            while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
              case Code of
                 // Picture
                IPhChunk_Pic_Open: begin
                  Pic := TPhoaPic.Create(FPhoA);
                  try
                    Pic.StreamerLoad(Streamer, False, PPAllProps);
                     // ������ �������� �������� ���������� �����������
                    TPhoaOp_InternalPicAdd.Create(FOperations, PhoA, Group, Pic);
                  except
                    Pic.Free;
                    raise;
                  end;
                end;
                 // Ensure unknown nested structures are skipped whole
                else Streamer.SkipNestedChunks(Code);
              end;
          finally
            Streamer.Free;
          end;
        finally
          ms.Free;
        end;
      end;
    finally
      StopWait;
    end;
  end;

  function TPhoaMultiOp_PicPaste.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
     // ������ Invalidate, ����� �������� ������� ���� ������ (static text)
    Result := [
      uifXInvalidateNode,  // Execution flags
      uifUInvalidateNode]; // Undo flags
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_PhoAEdit
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_PhoAEdit.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; iNewThWidth, iNewThHeight: Integer; bNewThQuality: Byte; const sNewDescription: String);
  begin
    inherited Create(List, PhoA);
    with PhoA do begin
       // ��������� ������ ��������
      FOldThumbnailWidth   := ThumbnailWidth;
      FOldThumbnailHeight  := ThumbnailHeight;
      FOldThumbnailQuality := ThumbnailQuality;
      FOldDescription      := Description;
       // ��������� ��������
      ThumbnailWidth   := iNewThWidth;
      ThumbnailHeight  := iNewThHeight;
      ThumbnailQuality := bNewThQuality;
      Description      := sNewDescription;
    end;
  end;

  procedure TPhoaOp_PhoAEdit.Undo;
  begin
    with FPhoA do begin
      ThumbnailWidth   := FOldThumbnailWidth;
      ThumbnailHeight  := FOldThumbnailHeight;
      ThumbnailQuality := FOldThumbnailQuality;
      Description      := FOldDescription;
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp_PicOperation
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMultiOp_PicOperation.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; const aSelPicIDs: TIDArray; PicOperation: TPictureOperation);
  var
    i, iID: Integer;
    aIDs: TIDArray;
  begin
    inherited Create(List, PhoA);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, TargetGroup, aSelPicIDs);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, SourceGroup, aSelPicIDs);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, TargetGroup, aSelPicIDs);
     // �������� ������ ���������� ����������� � ��������� ������
    if PicOperation=popIntersectTarget then begin
      aIDs := nil;
      for i := 0 to TargetGroup.PicIDs.Count-1 do begin
        iID := TargetGroup.PicIDs[i];
        if not IDInArray(iID, aSelPicIDs) then begin
          SetLength(aIDs, High(aIDs)+2);
          aIDs[High(aIDs)] := iID;
        end;
      end;
      if High(aIDs)>=0 then begin
        TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, TargetGroup, aIDs);
        PhoA.RemoveUnlinkedPics(FOperations);
      end;
    end;
  end;

  function TPhoaMultiOp_PicOperation.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXInvalidateTree,  // Execution flags
      uifUInvalidateTree]; // Undo flags
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_InternalGroupPicSort
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_InternalGroupPicSort.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings);
  begin
    inherited Create(List, PhoA);
     // ���������� ������� ���������� ID ����������� � ������
    FOldPicIDs := TIntegerList.Create(False);
    FOldPicIDs.Assign(Group.PicIDs);
     // ���������� ������
    OpGroup := Group;
     // ��������� ����������� � ������
    Group.SortPics(Sortings, PhoA.Pics); 
  end;

  destructor TPhoaOp_InternalGroupPicSort.Destroy;
  begin
    FOldPicIDs.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_InternalGroupPicSort.Undo;
  begin
     // ��������������� ������ ������� ���������� ID ����������� � ������
    OpGroup.PicIDs.Assign(FOldPicIDs);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp_PicSort
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoaMultiOp_PicSort.AddGroupSortOp(Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  var i: Integer;
  begin
     // ��������� ����������� � ������
    TPhoaOp_InternalGroupPicSort.Create(FOperations, FPhoA, Group, Sortings);
     // ��� ������������� ��������� � � ����������
    if bRecursive then
      for i := 0 to Group.Groups.Count-1 do AddGroupSortOp(Group.Groups[i], Sortings, True);
  end;

  constructor TPhoaMultiOp_PicSort.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  begin
    inherited Create(List, PhoA);
     // ��������� ����������
    AddGroupSortOp(Group, Sortings, bRecursive);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_GroupDragAndDrop
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_GroupDragAndDrop.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group, NewParentGroup: TPhoaGroup; iNewIndex: Integer);
  var gOldParent: TPhoaGroup;
  begin
    inherited Create(List, PhoA);
     // ���������� ������ ������
    gOldParent := Group.Owner;
    FOldIndex := Group.Index;
     // ���������� ������
    Group.Owner := NewParentGroup;
    if iNewIndex>=0 then Group.Index := iNewIndex; // ������ -1 �������� ���������� ��������� �������
     // ���������� ������ (ID �������� �������� � ID ������)
    OpParentGroup := gOldParent;
    OpGroup       := Group;
  end;

  function TPhoaOp_GroupDragAndDrop.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [uifUReinitAll];
  end;

  procedure TPhoaOp_GroupDragAndDrop.Undo;
  begin
     // ��������������� ��������� ������
    with OpGroup do begin
      Owner := OpParentGroup;
      Index := FOldIndex;
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMultiOp_PicDragAndDropToGroup
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMultiOp_PicDragAndDropToGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; aSelPicIDs: TIDArray; bCopy: Boolean);
  begin
    inherited Create(List, PhoA);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, TargetGroup, aSelPicIDs);
    if not bCopy then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, SourceGroup, aSelPicIDs);
  end;

  function TPhoaMultiOp_PicDragAndDropToGroup.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXInvalidateTree,  // Execution flags
      uifUInvalidateTree]; // Undo flags
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_PicDragAndDropInsideGroup
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_PicDragAndDropInsideGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray; idxNew: Integer);
  var i, idxOld: Integer;
  begin
    inherited Create(List, PhoA);
     // ��������� ��������
    FIndexes := TIntegerList.Create(True);
    for i := 0 to High(aPicIDs) do begin
       // -- ���������� �������
      idxOld := Group.PicIDs.IndexOf(aPicIDs[i]);
      if idxOld<idxNew then Dec(idxNew);
      FIndexes.Add(idxOld);
      FIndexes.Add(idxNew);
       // -- ���������� ����������� �� ����� �����
      Group.PicIDs.Move(idxOld, idxNew);
      Inc(idxNew);
    end;
     // ���������� ������
    OpGroup := Group;
  end;

  destructor TPhoaOp_PicDragAndDropInsideGroup.Destroy;
  begin
    FIndexes.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_PicDragAndDropInsideGroup.Undo;
  var
    i: Integer;
    g: TPhoaGroup;
  begin
    g := OpGroup;
     // ��������������� ����������� � �������� �������, ����� ��� ������ �� ���� �����
    i := FIndexes.Count-2; // i ��������� �� idxOld, i+1 - �� idxNew
    while i>=0 do begin
      g.PicIDs.Move(FIndexes[i+1], FIndexes[i]);
      Dec(i, 2);
    end;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_ViewNew
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_ViewNew.Create(List: TPhoaOperations; ViewsIntf: IPhoaViews; const sName: String; Groupings: TPhoaGroupings; Sortings: TPhoaSortings);
  var FView: TPhoaView;
  begin
    inherited Create(List, nil);
    FViewsIntf := ViewsIntf;
    FPrevViewIndex := ViewsIntf.ViewIndex;
     // ��������� ��������
    FView := TPhoaView.Create(ViewsIntf.Views);
    FView.Name := sName;
    FView.Groupings.Assign(Groupings);
    FView.Sortings.Assign(Sortings);
     // ���������� ����� ������ �������������
    FNewViewIndex := ViewsIntf.Views.IndexOf(FView);
     // ����������� ������
    ViewsIntf.LoadViewList(FNewViewIndex);
  end;

  procedure TPhoaOp_ViewNew.Undo;
  begin
     // ������� �������������
    FViewsIntf.Views.Delete(FNewViewIndex);
     // ����������� ������ � ��������������� ������� ��������� �������������
    FViewsIntf.LoadViewList(FPrevViewIndex);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_ViewEdit
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_ViewEdit.Create(List: TPhoaOperations; View: TPhoaView; ViewsIntf: IPhoaViews; const sNewName: String; NewGroupings: TPhoaGroupings; NewSortings: TPhoaSortings);
  begin
    inherited Create(List, nil);
     // ��������� ������ ������ � ��������� ���������
    FViewsIntf := ViewsIntf;
    FOldName := View.Name;
    View.Name := sNewName;
     // -- ������ ����������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    if (NewGroupings<>nil) and not View.Groupings.IdenticalWith(NewGroupings) then begin
      FOldGroupings := TPhoaGroupings.Create;
      FOldGroupings.Assign(View.Groupings);
      View.Groupings.Assign(NewGroupings);
       // -- Invalidate view's groups
      View.UnprocessGroups;
    end;
     // -- ������ ���������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    if (NewSortings<>nil) and not View.Sortings.IdenticalWith(NewSortings) then begin
      FOldSortings := TPhoaSortings.Create;
      FOldSortings.Assign(View.Sortings);
      View.Sortings.Assign(NewSortings);
       // -- Invalidate view's groups
      View.UnprocessGroups;
    end;
     // ����������������� ������
    ViewsIntf.Views.Sort;
     // ���������� ����� ������ �������������
    FNewViewIndex := View.Index;
     // ����������� ������
    ViewsIntf.LoadViewList(FNewViewIndex);
  end;

  destructor TPhoaOp_ViewEdit.Destroy;
  begin
    FOldGroupings.Free;
    FOldSortings.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_ViewEdit.Undo;
  var View: TPhoaView;
  begin
     // ��������������� �������������
    View := FViewsIntf.Views[FNewViewIndex];
    View.Name := FOldName;
    if FOldGroupings<>nil then View.Groupings.Assign(FOldGroupings);
    if FOldSortings<>nil  then View.Sortings.Assign(FOldSortings);
    View.UnprocessGroups;
     // ����������������� ������ (����� ����� ����� �������� �� ��������� ������������� � ������)
    FViewsIntf.Views.Sort;
     // ����������� ������
    FViewsIntf.LoadViewList(View.Index);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_ViewDelete
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_ViewDelete.Create(List: TPhoaOperations; ViewsIntf: IPhoaViews);
  begin
    inherited Create(List, nil);
     // ��������� ������ ������
    FViewsIntf := ViewsIntf;
    with ViewsIntf.Views[ViewsIntf.ViewIndex] do begin
      FOldName := Name;
      FOldGroupings := TPhoaGroupings.Create;
      FOldGroupings.Assign(Groupings);
      FOldSortings  := TPhoaSortings.Create;
      FOldSortings.Assign(Sortings);
    end;
     // ������� �������������
    ViewsIntf.Views.Delete(ViewsIntf.ViewIndex);
     // ����������� ������
    ViewsIntf.LoadViewList(-1);
  end;

  destructor TPhoaOp_ViewDelete.Destroy;
  begin
    FOldGroupings.Free;
    FOldSortings.Free;
    inherited Destroy;
  end;

  procedure TPhoaOp_ViewDelete.Undo;
  var View: TPhoaView;
  begin
     // ������ �������������
    View := TPhoaView.Create(FViewsIntf.Views);
    View.Name := FOldName;
    View.Groupings.Assign(FOldGroupings);
    View.Sortings.Assign(FOldSortings);
     // ����������������� ������
    FViewsIntf.Views.Sort;
     // ����������� ������
    FViewsIntf.LoadViewList(View.Index);
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaOp_ViewMakeGroup
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaOp_ViewMakeGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; ViewsIntf: IPhoaViews);
  var
    g: TPhoaGroup;
    View: TPhoaView;
  begin
    inherited Create(List, PhoA);
    FViewsIntf := ViewsIntf;
    View := ViewsIntf.Views[ViewsIntf.ViewIndex];
     // ������ ������ (���������� � �������� ID)
    g := TPhoaGroup.Create(Group, 0);
    g.Assign(View.RootGroup, False, True, True);
    g.Text := View.Name;
     // ������������ ������� ��������� ID
    PhoA.RootGroup.FixupIDs;
     // ���������� ������� (��������) ������ �� �����������
    OpGroup := g;
     // ��������� ������ �����
    ViewsIntf.ViewIndex := -1;
  end;

  procedure TPhoaOp_ViewMakeGroup.Undo;
  begin
     // ������� �������� ������ ����� �������������
    OpGroup.Free;
     // ��������� ������ �����
    FViewsIntf.ViewIndex := -1;
    inherited Undo;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TThumbnailViewer
   //-------------------------------------------------------------------------------------------------------------------

  procedure TThumbnailViewer.AddToSelection(Index: Integer);
  begin
    if (Index>=0) and (Index<FPicLinks.Count) and FSelIndexes.Add(Index) then InvalidateItem(Index);
  end;

  procedure TThumbnailViewer.AdjustTooltip(ix, iy: Integer);
  var idx: Integer;
  begin
     // ����������� Thumbnail Tooltip
    if FShowThumbTooltips and (ThumbTooltipProps<>[]) and (GetKeyState(VK_LBUTTON) and $80=0) then idx := ItemAtPos(ix, iy) else idx := -1;
     // ���� ������ ������, ��� �������� ��������� ��� ����������� Tooltip, ���������
    if idx<>FLastTooltipIdx then begin
       // �������� Tooltip, ���� ����
      Application.CancelHint;
       // ������ �������� (��������� �����, ����� � StatusBar ������ �� ��������)
      if idx<0 then Hint := '' else Hint := FPicLinks[idx].GetPropStrs(FThumbTooltipProps, ':'#9, #13)+'|';
      FLastTooltipIdx := idx;
    end;
  end;

  procedure TThumbnailViewer.BeginUpdate;
  begin
    if FUpdateLock=0 then Perform(WM_SETREDRAW, 0, 0);
    Inc(FUpdateLock);
  end;

  procedure TThumbnailViewer.CalcLayout;
  var
    iItemCount, iColCount, idxTop, iLineHeight: Integer;
    bChg: Boolean;
    dc: HDC;
  begin
    if FUpdateLock>0 then Exit;
    FLastTooltipIdx := -1;
    Hint := '';
     // ������� ������� ������
    if FPhoA=nil then begin
      FWCell := 0;
      FHCell := 0;
    end else begin
      FWCell := FPhoA.FThumbnailWidth;
      FHCell := FPhoA.FThumbnailHeight;
    end;
     // -- ���������� ������� �� ����� ������
    Inc(FWCell, ILThumbMargin+IRThumbMargin);
    Inc(FHCell, ITThumbMargin+IBThumbMargin);
     // -- ������� ������ ������ ������
    dc := GetDC(0);
    Canvas.Handle := dc;
    Canvas.Font.Assign(Font);
    iLineHeight := Canvas.TextHeight('Wg');
    Canvas.Handle := 0;
    ReleaseDC(0, dc);
     // -- ���������� ������� �� ������ �����������
    if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(FHCell, iLineHeight);
    if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Inc(FHCell, iLineHeight);
     // ������� ���������� ��������
    iItemCount := FPicLinks.Count;
    iColCount  := Max(1, ClientWidth div FWCell);
     // ��������� ������� ���������
    bChg := (FItemCount<>iItemCount) or (FColCount<>iColCount);
    FItemCount := iItemCount;
    FColCount  := iColCount;
    FVisibleItems := (ClientHeight div FHCell)*FColCount;
     // ������������ ����� TopIndex
    idxTop := GetValidTopIndex(FTopIndex);
    if idxTop<>FTopIndex then
      SetTopIndex(idxTop)
    else begin
      if bChg then Invalidate;
      UpdateScrollBar;
    end;
  end;

  function TThumbnailViewer.ClearSelection: Boolean;
  var i: Integer;
  begin
     // ���� ���� ���������
    Result := FSelIndexes.Count>0;
    if Result then
       // ���� ���������� �� �����������, invalidate thumbnails selected
      if FUpdateLock=0 then
        for i := FSelIndexes.Count-1 downto 0 do begin
          InvalidateItem(FSelIndexes[i]);
          FSelIndexes.Delete(i);
        end
       // ����� ������ �������
      else
        FSelIndexes.Clear;
  end;

  procedure TThumbnailViewer.CMDrag(var Msg: TCMDrag);
  begin
    if Msg.DragMessage in [dmDragDrop, dmDragCancel] then DragDrawInsertionPoint(FOldDragTargetCoord, True);
    inherited;
  end;

  constructor TThumbnailViewer.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle     := [csCaptureMouse, csClickEvents, csOpaque, csDoubleClicks, csReplicatable];
    Width            := 100;
    Height           := 100;
    TabStop          := True;
    ParentColor      := False;
    Color            := clBtnFace;
    FBorderStyle     := bsSingle;
    FColCount        := 1;
    FCacheThumbnails := True;
    FNoMoveItemIndex := -1;
    FPicLinks        := TPhoaPicLinks.Create(False);
    FSelIndexes      := TIntegerList.Create(False);
    FThumbBackColor  := clBtnFace;
    FThumbCache      := TList.Create;
  end;

  procedure TThumbnailViewer.CreateParams(var Params: TCreateParams);
  begin
    inherited CreateParams(Params);
    with Params do begin
      WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
      Style := Style or WS_VSCROLL;
      if FBorderStyle=bsSingle then
        if NewStyleControls and Ctl3D then begin
          Style := Style and not WS_BORDER;
          ExStyle := ExStyle or WS_EX_CLIENTEDGE; 
        end else
          Style := Style or WS_BORDER;
    end;
  end;

  procedure TThumbnailViewer.CreateWnd;
  var iw, ih: Integer;
  begin
    iw := Width;
    ih := Height;
    inherited CreateWnd;
    SetWindowPos(Handle, 0, Left, Top, iw, ih, SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  destructor TThumbnailViewer.Destroy;
  begin
    FSelIndexes.Free;
    LimitCacheSize(0);
    FThumbCache.Free;
    FPicLinks.Free;
    inherited Destroy;
  end;

  procedure TThumbnailViewer.DragDrawInsertionPoint(var Coord: TViewerInsertionCoord; bInvalidate: Boolean);
  var
    dc: HDC;
    hp, hOld: HPEN;
    idx, ix, iy: Integer;
  begin
    if Coord.iIndex>=0 then begin
       // ������� ���������� ����������
      idx := Coord.iIndex;
       // ���� �� ���� ���������� �������
      if idx>=FTopIndex then begin
        Dec(idx, FTopIndex);
        ix := (idx mod FColCount)*FWCell;
        iy := (idx div FColCount)*FHCell;
         // ���� �� ���� ������ ������� ���������� �������
        if iy<ClientHeight then begin
           // ���������������?
          if (ix=0) and Coord.bLower then begin
            ix := FColCount*FWCell;
            Dec(iy, FHCell);
          end;
           // ������������
          dc := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
          hp := CreatePen(PS_SOLID, 3, ColorToRGB(Color) xor ColorToRGB(CInsertionPoint));
          hOld := SelectObject(dc, hp);
          SetROP2(dc, R2_XORPEN);
          MoveToEx(dc, ix, iy, nil);
          LineTo(dc, ix, iy+FHCell);
          MoveToEx(dc, ix-3, iy, nil);
          LineTo(dc, ix+3, iy);
          MoveToEx(dc, ix-3, iy+FHCell, nil);
          LineTo(dc, ix+3, iy+FHCell);
          SelectObject(dc, hOld);
          DeleteObject(hp);
          ReleaseDC(Handle, dc);
        end;
      end;
       // Invalidate coord if needed
      if bInvalidate then begin
        Coord.iIndex := -1;
        Coord.bLower := False;
      end;
    end;
  end;

  procedure TThumbnailViewer.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
  var
    iCol, iRow: Integer;
    bLower: Boolean;

    procedure SpeedAdjust;
    var cTicks: Cardinal;
    begin
      cTicks := GetTickCount;
       // ������ ��� �� ���
      if (FLastDragScrollTicks>0) and (cTicks<FLastDragScrollTicks+IDragScrollDelay) then Sleep(FLastDragScrollTicks+IDragScrollDelay-cTicks);
      FLastDragScrollTicks := cTicks;
    end;

     // ������������ ������ ������� ����� (bUp=True) ��� ���� (bUp=False)
    procedure DoScroll(bUp: Boolean);
    begin
       // ������������ ��������
      SpeedAdjust;
       // ������� ������ ����� �������
      DragDrawInsertionPoint(FOldDragTargetCoord, True);
       // ������������
      SetTopIndex(FTopIndex+iif(bUp, -FColCount, FColCount));
      Update;
    end;

  begin
    if Source=Self then begin
      FDragTargetCoord.iIndex := -1;
      FDragTargetCoord.bLower := False;
       // ���� ������/��������� � ��������
      if PtInRect(ClientRect, Point(x, y)) then begin
         // ���� � ������� ��� ������ ������ ����, ������
        if (y<IDragScrollAreaMargin) or (y>=ClientHeight-IDragScrollAreaMargin) then DoScroll(y<IDragScrollAreaMargin);
         // ���������� ����� �������
        if FItemCount>0 then begin
           // ������� ������� (� �����������)
          iCol := Round(x/FWCell);
           // ���� ������ �� �������, �������� ����� bLower � ������������� ������ �� ����� � ������ ��������� ������
          bLower := iCol>=FColCount;
          if bLower then iCol := FColCount;
           // ������� ������ (������ ������ � ������ ������)
          iRow := FTopIndex+(y div FHCell)*FColCount;
           // ���� ������ �������� ������
          if iRow<FItemCount then begin
            FDragTargetCoord.iIndex := iRow+iCol;
             // ���� ��������� �� ��������� ����� - ���� �������� bLower
            if FDragTargetCoord.iIndex>=FItemCount then begin
              FDragTargetCoord.iIndex := FItemCount;
              bLower := True;
            end;
            FDragTargetCoord.bLower := bLower;
          end;
        end;
      end;
       // ���� ���������� ��������� ������� - ������������ ���
      if (FDragTargetCoord.iIndex<>FOldDragTargetCoord.iIndex) or (FDragTargetCoord.bLower<>FOldDragTargetCoord.bLower) then begin
        DragDrawInsertionPoint(FOldDragTargetCoord, False);
        DragDrawInsertionPoint(FDragTargetCoord, False);
        FOldDragTargetCoord := FDragTargetCoord;
      end;
       // Drop ��������, ���� ���� ���������� ���������� �������, � ��������������� �� ��� �����, � �� ������������
       //   ����������� ��� ����� ������� �� ��������� � ���������� ����� �����������
      Accept :=
        (FDragTargetCoord.iIndex>=0) and
        (FSelIndexes.Count<FPicLinks.Count) and
        ((FSelIndexes.Count>1) or ((FSelIndexes[0]<>FDragTargetCoord.iIndex) and (FSelIndexes[0]<>FDragTargetCoord.iIndex-1)));
    end else
      inherited DragOver(Source, X, Y, State, Accept);
  end;

  procedure TThumbnailViewer.EndUpdate;
  begin
    if FUpdateLock>0 then Dec(FUpdateLock);
    if FUpdateLock=0 then begin
      Perform(WM_SETREDRAW, 1, 0);
      CalcLayout;
      Refresh;
    end;
  end;

  function TThumbnailViewer.GetCachedThumb(_Pic: TPhoaPic): TBitmap;
  var i: Integer;
  begin
    for i := 0 to FThumbCache.Count-1 do
      with PThumbCacheRec(FThumbCache[i])^ do
        if Pic=_Pic then begin
          Result := Thumb;
           // ���������� ����������� � ������ ����
          FThumbCache.Move(i, 0);
          Exit;
        end;
    Result := nil;
  end;

  function TThumbnailViewer.GetDropTargetIndex: Integer;
  begin
    Result := FDragTargetCoord.iIndex;
  end;

  function TThumbnailViewer.GetIDSelected(iID: Integer): Boolean;
  var idx: Integer;
  begin
    Result := False;
    idx := FPicLinks.IndexOfID(iID);
    if (idx>=0) and (FSelIndexes.IndexOf(idx)>=0) then Result := True;
  end;

  function TThumbnailViewer.GetSelCount: Integer;
  begin
    Result := FSelIndexes.Count;
  end;

  function TThumbnailViewer.GetSelectedIndexes(Index: Integer): Integer;
  begin
    Result := FSelIndexes[Index];
  end;

  function TThumbnailViewer.GetSelectedPicArray: TPicArray;
  var i: Integer;
  begin
    SetLength(Result, FSelIndexes.Count);
    for i := 0 to FSelIndexes.Count-1 do Result[i] := GetSelectedPics(i);
  end;

  function TThumbnailViewer.GetSelectedPics(Index: Integer): TPhoaPic;
  begin
    Result := FPicLinks[FSelIndexes[Index]];
  end;

  function TThumbnailViewer.GetThumbCornerDetails(Corner: TThumbCorner): TThumbCornerDetail;
  begin
    Result := FThumbCornerDetails[Corner];
  end;

  function TThumbnailViewer.GetValidTopIndex(idxOffered: Integer): Integer;
  begin
     // Round toward beginning of the row
    idxOffered := (idxOffered div FColCount)*FColCount;
     // Determine max. allowed TopIndex
     //                 (����� ����� � ��������)           - (����� ������� �� ������)
    Result := FColCount*(Round(Ceil(FItemCount/FColCount)) - ClientHeight div FHCell);
    if idxOffered<Result then Result := idxOffered;
    if Result<0 then Result := 0;
  end;

  procedure TThumbnailViewer.InvalidateItem(Index: Integer);
  var r: TRect;
  begin
    if (FUpdateLock=0) and HandleAllocated then begin
      r := ItemRect(Index);
      if not IsRectEmpty(r) then InvalidateRect(Handle, @r, False);
    end;
  end;

  function TThumbnailViewer.ItemAtPos(ix, iy: Integer): Integer;
  var iCol: Integer;
  begin
    Result := -1;
    if (FItemCount>0) then begin
      iCol := ix div FWCell;
      if iCol<FColCount then begin
        Result := FTopIndex+(iy div FHCell)*FColCount+iCol;
        if Result>=FItemCount then Result := -1;
      end;
    end;
  end;

  function TThumbnailViewer.ItemRect(Index: Integer): TRect;
  var ix, iy: Integer;
  begin
    FillChar(Result, SizeOf(Result), 0);
    if Index>=FTopIndex then begin
      Dec(Index, FTopIndex);
      ix := (Index mod FColCount)*FWCell;
      iy := (Index div FColCount)*FHCell;
      if iy<ClientHeight then Result := Rect(ix, iy, ix+FWCell, iy+FHCell);
    end;
  end;

  procedure TThumbnailViewer.KeyDown(var Key: Word; Shift: TShiftState);

    procedure SetII(ii: Integer);
    begin
      if (ssShift in Shift) and (FStreamSelStart>=0) then SelectRange(FStreamSelStart, ii) else SetItemIndex(ii);
      ScrollIntoView;
    end;

  begin
    if (Shift=[]) or
       (Shift=[ssShift]) or
       (((Shift=[ssCtrl]) or (Shift=[ssShift, ssCtrl])) and (Key in [VK_PRIOR, VK_NEXT, VK_HOME, VK_END])) then
      case Key of
        VK_UP:    if ItemIndex>=FColCount then           SetII(ItemIndex-FColCount);
        VK_LEFT:  if ItemIndex>0          then           SetII(ItemIndex-1);
        VK_DOWN:  if ItemIndex<FItemCount-FColCount then SetII(ItemIndex+FColCount);
        VK_RIGHT: if ItemIndex<FItemCount-1 then         SetII(ItemIndex+1);
        VK_HOME:                                         SetII(0);
        VK_END:                                          SetII(FItemCount-1);
        VK_PRIOR: if (ItemIndex>=FVisibleItems) and not (ssCtrl in Shift) then SetII(ItemIndex-FVisibleItems) else SetII(0);
        VK_NEXT:  if (ItemIndex<FItemCount-FVisibleItems) and not (ssCtrl in Shift) then SetII(ItemIndex+FVisibleItems) else SetII(FItemCount-1);
      end;
  end;

  procedure TThumbnailViewer.LimitCacheSize(iNumber: Integer);
  var
    i: Integer;
    p: PThumbCacheRec;
  begin
    if not FCacheThumbnails then iNumber := 0;
    for i := FThumbCache.Count-1 downto iNumber do begin
      p := FThumbCache[i];
      p.Thumb.Free;
      Dispose(p);
      FThumbCache.Delete(i);
    end;
  end;

  procedure TThumbnailViewer.MarqueingEnd;
  var
    i: Integer;
    r, rThumb: TRect;
  begin
    ReleaseCapture;
    FMarqueing := False;
    PaintMarquee;
    ReleaseDC(Handle, FTempDC);
     // ���� �� ��� ����� Shift, ������� Selection (�������� � ����)
    if GetKeyState(VK_SHIFT) and $80=0 then ClearSelection;
     // Select thumbnails that do intersect with marquee
    r := OrderRect(Rect(FStartPos, FMarqueeCur));
    i := FTopIndex;
    while (i<FTopIndex+FVisibleItems+FColCount) and (i<FItemCount) do begin
      rThumb := ItemRect(i);
      IntersectRect(rThumb, rThumb, r);
      if not IsRectEmpty(rThumb) then AddToSelection(i);
      Inc(i);
    end;
    SelectionChange;
  end;

  procedure TThumbnailViewer.MarqueingStart;
  begin
    SetCapture(Handle);
    FTempDC := GetDCEx(Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_LOCKWINDOWUPDATE);
    FMarqueing := True;
    FMarqueeCur := FStartPos;
  end;

  procedure TThumbnailViewer.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var idx: Integer;
  begin
    SetFocus;
    idx := ItemAtPos(x, y);
    FStartPos := Point(x, y);
     // ���� ����� Alt - �������� ��������� (marqueing)
    if ssAlt in Shift then begin
      if Button=mbLeft then MarqueingStart;
     // ���� ����� Ctrl
    end else if ssCtrl in Shift then begin
       // ���� ����� ������ - ����������� ��������� ������, �� ������� ��������
      if Button=mbLeft then begin
        ToggleSelection(idx);
        MoveItemIndex(idx, True);
       // ���� ������ ������ - ������� ����� Shell Context Menu
      end else if Button=mbRight then begin
        ClearSelection;
        SetItemIndex(idx);
        if idx>=0 then begin
          FShellCtxMenuOnMouseUp := True;
          Exit;
        end;
      end;
      SelectionChange;
     // ���� ����� Shift - �������� ������ ������ ������
    end else if ssShift in Shift then
      if FStreamSelStart>=0 then SelectRange(FStreamSelStart, idx) else SetItemIndex(idx)
     // �� ������ ������
    else begin
      if (idx<0) or (FSelIndexes.IndexOf(idx)<0) then begin
        SetItemIndex(idx);
        FNoMoveItemIndex := -1;
      end else if Button=mbLeft then
        FNoMoveItemIndex := idx;
      if Button=mbLeft then
        if idx<0 then MarqueingStart
        else if FDragEnabled and (FSelIndexes.Count>0) then FDragPending := True;
    end;
    inherited MouseDown(Button, Shift, x, y);
  end;

  procedure TThumbnailViewer.MouseMove(Shift: TShiftState; X, Y: Integer);
  begin
     // ����������� Tooltip
    AdjustTooltip(x, y);
     // ���� ������ ����� ���������
    if FMarqueing then begin
      PaintMarquee;
      FMarqueeCur := Point(Min(Max(x, 0), ClientWidth), y);
      PaintMarquee;
     // ��������� �������� Dragging
    end else if FDragPending then begin
      if (FStartPos.x<>x) or (FStartPos.y<>y) then FNoMoveItemIndex := -1;
      if Sqr(FStartPos.x-x)+Sqr(FStartPos.y-y)>9 then begin
        FDragPending := False;
         // �������������� ����������
        FDragTargetCoord.iIndex    := -1;
        FDragTargetCoord.bLower    := False;
        FOldDragTargetCoord.iIndex := -1;
        FOldDragTargetCoord.bLower := False;
        FLastDragScrollTicks := 0;
         // �������� Dragging
        BeginDrag(True);
      end;
    end;
    inherited MouseMove(Shift, x, y);
  end;

  procedure TThumbnailViewer.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  begin
     // ���� ����� ���������� ���������
    if FMarqueing then
      MarqueingEnd
     // ���� ���� ������ ������ ������ ������ � Ctrl - �������� ��������� ����������� ���� 
    else if FShellCtxMenuOnMouseUp then begin
      FShellCtxMenuOnMouseUp := False;
      if (ssCtrl in Shift) and (FItemIndex>=0) and (FItemIndex=ItemAtPos(x, y)) then ShowFileShellContextMenu(FPicLinks[FItemIndex].PicFileName);
      Exit;
     // ����� ��������� Dragging
    end else begin
      FDragPending := False;
      if FNoMoveItemIndex>=0 then begin
        if not Dragging then SetItemIndex(FNoMoveItemIndex);
        FNoMoveItemIndex := -1;
      end;
    end;
    inherited MouseUp(Button, Shift, x, y);
  end;

  procedure TThumbnailViewer.MoveItemIndex(iNewIndex: Integer; bUpdateStreamSelStart: Boolean);
  begin
    if iNewIndex<>FItemIndex then begin
      InvalidateItem(FItemIndex);
      FItemIndex := iNewIndex;
      InvalidateItem(FItemIndex);
    end;
    if bUpdateStreamSelStart then FStreamSelStart := iNewIndex;
  end;

  procedure TThumbnailViewer.Paint;
  var
    bmp: TBitmap;
    r, rClip, rThumb: TRect;
    idx: Integer;

    procedure MakeBufferBitmap;
    begin
      if bmp=nil then begin
        bmp := TBitmap.Create;
        bmp.Width  := FWCell;
        bmp.Height := FHCell;
      end;
    end;

  begin
    rClip := Canvas.ClipRect;
    bmp := nil;
    try
       // ������������ ������
      idx := FTopIndex;
      repeat
         // ������� ������� ������ (������� ��� ������� ������� ������)
        rThumb := ItemRect(idx);
        if IsRectEmpty(rThumb) then Break;
         // ������� ����������� ������ � ClipRect
        IntersectRect(r, rThumb, rClip);
        if not IsRectEmpty(r) then begin
           // ���� ����� ����� ���� - ������ � ����� � ��������� ��� �� �����
          if idx<FItemCount then begin
            MakeBufferBitmap;
            PaintThumb(idx, bmp);
            BitBlt(Canvas.Handle, r.Left, r.Top, r.Right-r.Left, r.Bottom-r.Top, bmp.Canvas.Handle, r.Left-rThumb.Left, r.Top-rThumb.Top, SRCCOPY);
           // ����� - ������� ���
          end else
            with Canvas do begin
              Brush.Style := bsSolid;
              Brush.Color := Color;
              FillRect(r);
            end;
        end;
        Inc(idx);
      until False;
    finally
      bmp.Free;
    end;
     // ������� ���������������� ������� ������ �� �������
    IntersectRect(r, Rect(FColCount*FWCell, 0, ClientWidth, ClientHeight), rClip);
    if not IsRectEmpty(r) then
      with Canvas do begin
        Brush.Style := bsSolid;
        Brush.Color := Color;
        FillRect(r);
      end;
  end;

  procedure TThumbnailViewer.PaintMarquee;
  var r: TRect;
  begin
    r := OrderRect(Rect(FStartPos, FMarqueeCur));
    if not IsRectEmpty(r) then DrawFocusRect(FTempDC, r);
  end;

  procedure TThumbnailViewer.PaintThumb(idx: Integer; bmp: TBitmap);
  const
    aSelectedFontClr: Array[Boolean] of TColor = (clWindowText, clHighlightText);
    aSelectedBackClr: Array[Boolean] of TColor = (clBtnShadow,  clHighlight);
    aEdges: Array[Boolean] of Integer = (BDR_RAISEDINNER, BDR_RAISEDINNER or BDR_RAISEDOUTER);
  var
    r: TRect;
    Pic: TPhoaPic;
    bSel, bFocused: Boolean;
    ted: TThemedElementDetails;
    iLineHeight: Integer;

     // ������������ �� ������ ������ ������ ����. ���������� ������ ������������� ������
    function DrawDetail(Corner: TThumbCorner; rText: TRect): Integer;
    var sProp: String;
    begin
      Result := 0;
      if (FThumbCornerDetails[Corner].bDisplay) and (rText.Left<rText.Right) then begin
        sProp := Pic.Props[FThumbCornerDetails[Corner].Prop];
        if sProp<>'' then begin
          Result := bmp.Canvas.TextWidth(sProp)+2;
          DrawText(bmp.Canvas.Handle, PChar(sProp), -1, rText, iif(Corner in [tcRightTop, tcRightBottom], DT_RIGHT, DT_LEFT) or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER or DT_END_ELLIPSIS);
        end;
      end;
    end;

     // ������������ �� ������ ������, ����������� �� ����� �����. �����
    procedure DrawDetailsLR(LeftCorner, RightCorner: TThumbCorner; rText: TRect);
    begin
       // ������ ������ ��������
      Dec(rText.Right, DrawDetail(RightCorner, rText));
       // ������ ����� ��������
      DrawDetail(LeftCorner, rText);
    end;

    procedure DoPaintThumbnail;
    var
      bCacheUsed: Boolean;
      bmpThumb: TBitmap;
      rThumb: TRect;
      ix, iy: Integer;
    begin
       // ������� ������� ������
      rThumb := r;
      if FThumbCornerDetails[tcLeftTop].bDisplay    or FThumbCornerDetails[tcRightTop].bDisplay    then Inc(rThumb.Top,    iLineHeight);
      if FThumbCornerDetails[tcLeftBottom].bDisplay or FThumbCornerDetails[tcRightBottom].bDisplay then Dec(rThumb.Bottom, iLineHeight);
       // ���� ����������� � ����
      bmpThumb := GetCachedThumb(Pic);
      bCacheUsed := bmpThumb<>nil;
      try
         // ���� �� ����� - ������ ��������� ������ � ��������� �� ���� JPEG-����������� ������
        if not bCacheUsed then begin
          bmpThumb := TBitmap.Create;
          Pic.PaintThumbnail(bmpThumb);
        end;
        ix := (rThumb.Left+rThumb.Right-bmpThumb.Width) div 2;
        iy := (rThumb.Top+rThumb.Bottom-bmpThumb.Height) div 2;
         // ������ �����
        BitBlt(
          bmp.Canvas.Handle,
          Max(ix, rThumb.Left),
          Max(iy, rThumb.Top),
          Min(bmpThumb.Width, rThumb.Right-rThumb.Left),
          Min(bmpThumb.Height, rThumb.Bottom-rThumb.Top),
          bmpThumb.Canvas.Handle,
          0,
          0,
          SRCCOPY);
         // �������� ����� ��� �������������
        if not bCacheUsed and FCacheThumbnails then begin
          PutThumbToCache(Pic, bmpThumb);
          bCacheUsed := True;
        end;
      finally
        if not bCacheUsed then bmpThumb.Free;
      end;
    end;

  begin
    r := Rect(0, 0, bmp.Width, bmp.Height);
    bSel     := FSelIndexes.IndexOf(idx)>=0;
    bFocused := Focused;
     // ���� �����������
    Pic := FPicLinks[idx];
    with bmp.Canvas do begin
       // ������� ���
      Brush.Color := Color;
      FillRect(r);
       // ������ �����
      if (idx=FItemIndex) and bFocused then DrawFocusRect(r);
      InflateRect(r, -2, -2);
      Font.Assign(Self.Font);
      if bSel then begin
        Font.Color  := aSelectedFontClr[bFocused];
        Brush.Color := aSelectedBackClr[bFocused]
      end else begin
        Font.Color  := FThumbFontColor;
        Brush.Color := FThumbBackColor;
      end;
      if ThemeServices.ThemesEnabled then begin
        ted := ThemeServices.GetElementDetails(teEditTextNormal);
        ThemeServices.DrawElement(Handle, ted, r);
        InflateRect(r, -2, -2);
        FillRect(r);
      end else begin
        FillRect(r);
        DrawEdge(Handle, r, aEdges[FThickThumbBorder], BF_RECT);
      end;
      iLineHeight := TextHeight('Wg');
    end;
     // ������������ ����������� ������
    r := Rect(ILThumbMargin, ITThumbMargin, FWCell-IRThumbMargin, FHCell-IBThumbMargin);
    DoPaintThumbnail;
     // ������ ��������
    DrawDetailsLR(tcLeftTop,    tcRightTop,    Rect(r.Left, r.Top, r.Right, r.Top+iLineHeight));
    DrawDetailsLR(tcLeftBottom, tcRightBottom, Rect(r.Left, r.Bottom-iLineHeight, r.Right, r.Bottom));
  end;

  procedure TThumbnailViewer.PhoaThumbDimensionsChanged(Sender: TObject);
  begin
    LimitCacheSize(0);
    CalcLayout;
  end;

  procedure TThumbnailViewer.PutThumbToCache(Pic: TPhoaPic; Bitmap: TBitmap);
  var p: PThumbCacheRec;
  begin
     // ��������� � ���
    New(p);
    p^.Pic   := Pic;
    p^.Thumb := Bitmap;
    FThumbCache.Insert(0, p);
     // ������� ������ ����
    LimitCacheSize(FThumbCacheSize);
  end;

  procedure TThumbnailViewer.RemoveFromSelection(Index: Integer);
  begin
    if FSelIndexes.Remove(Index)>=0 then InvalidateItem(Index);
  end;

  procedure TThumbnailViewer.ScrollIntoView;
  begin
    if FItemIndex>=0 then
       // ���� ItemIndex ���� ���� ���������
      if FItemIndex<FTopIndex then SetTopIndex(FItemIndex)
       // ���� ItemIndex ���� ���� ���������
      else if FTopIndex+FVisibleItems<=FItemIndex then SetTopIndex(((FItemIndex div FColCount)+1)*FColCount-FVisibleItems);
  end;

  procedure TThumbnailViewer.SelectAll;
  var i: Integer;
  begin
    if FSelIndexes.Count<FItemCount then begin
      ClearSelection;
      for i := 0 to FItemCount-1 do FSelIndexes.Add(i);
      Invalidate;
      SelectionChange;
    end;
  end;

  procedure TThumbnailViewer.SelectionChange;
  begin
    if Assigned(FOnSelectionChange) then FOnSelectionChange(Self);
  end;

  procedure TThumbnailViewer.SelectNone;
  begin
    if ClearSelection then SelectionChange;
  end;

  procedure TThumbnailViewer.SelectRange(idxStart, idxEnd: Integer);
  var i: Integer;
  begin
    ClearSelection;
    MoveItemIndex(idxEnd, False);
    if idxStart>idxEnd then begin
      i := idxStart;
      idxStart := idxEnd;
      idxEnd := i;
    end;
    for i := idxStart to idxEnd do AddToSelection(i);
    SelectionChange;
  end;

  procedure TThumbnailViewer.SetBorderStyle(Value: TBorderStyle);
  begin
    if FBorderStyle<>Value then begin
      FBorderStyle := Value;
      RecreateWnd;
    end;  
  end;

  procedure TThumbnailViewer.SetCacheThumbnails(Value: Boolean);
  begin
    if FCacheThumbnails<>Value then begin
      FCacheThumbnails := Value;
      LimitCacheSize(FThumbCacheSize);
    end;
  end;

  procedure TThumbnailViewer.SetCurrentGroup(Group: TPhoaGroup);
  var
    i, iPrevGroupID, iFocusedID, iItemIdx: Integer;
    SelectedIDs: TIntegerList;
  begin
    BeginUpdate;
    try
       // ��������� ������� GroupID
      iPrevGroupID := FGroupID;
       // ���� ������ �� ���������� � ���� ���������, ���������� ID ���������� �����������
      iFocusedID := 0;
      if (iPrevGroupID=FGroupID) and (FSelIndexes.Count>0) then begin
        SelectedIDs := TIntegerList.Create(False);
        for i := 0 to FSelIndexes.Count-1 do SelectedIDs.Add(SelectedPics[i].ID);
        if FItemIndex>=0 then iFocusedID := FPicLinks[FItemIndex].ID;
      end else
        SelectedIDs := nil;
      try
         // ������� ����� GroupID
        if Group=nil then FGroupID := 0 else FGroupID := Group.ID;
         // �������� ������ �� ����������� �� �� IDs �� ������
        FPicLinks.AddFromGroup(FPhoA, Group, True);
         // ������� ��� �������
        LimitCacheSize(0);
         // ������� ���������
        ClearSelection;
         // ���� ������ ���������� - �������� � ������
        if iPrevGroupID<>FGroupID then
          FTopIndex := 0
         // ����� - ��������� � ��������� ���������� �����������
        else if SelectedIDs<>nil then
          for i := 0 to SelectedIDs.Count-1 do AddToSelection(FPicLinks.IndexOfID(SelectedIDs[i]));
      finally
        SelectedIDs.Free;
      end;
       // ���� ��� ���������, �������� ������ ����������� (���� ��� ����)
      if FSelIndexes.Count=0 then AddToSelection(0);
       // ������� ��������������� �����������
      if iFocusedID>0 then iItemIdx := FPicLinks.IndexOfID(iFocusedID) else iItemIdx := -1;
       // ���� ��� � �� �������
      if iItemIdx<0 then
         // ���������� ��������� �� ����������, ���� ��� ����
        if FSelIndexes.Count>0 then iItemIdx := FSelIndexes[FSelIndexes.Count-1]
         // ����� �������� �������� ����� ������ �����������, ���� ��� ����
        else if FPicLinks.Count>0 then iItemIdx := 0;
      MoveItemIndex(iItemIdx, True);  
    finally
       // ������������� layout, validate TopIndex, ���������
      EndUpdate;
    end;
     // ����������
    SelectionChange;
  end;

  procedure TThumbnailViewer.SetItemIndex(Value: Integer);
  begin
     // ���� �������� ������, ��� ��� ���������, � ��� �����, ��� ��������
    if (FItemIndex<>Value) or ((FSelIndexes.Count=0)<>(Value<0)) then begin
      ClearSelection;
      AddToSelection(Value);
      MoveItemIndex(Value, True);
      SelectionChange;
    end;
  end;

  procedure TThumbnailViewer.SetPhoA(Value: TPhotoAlbum);
  begin
    if FPhoA<>Value then begin
      if (FPhoA<>nil) then FPhoA.OnThumbDimensionsChanged := nil;
      FPhoA := Value;
      if (FPhoA<>nil) then FPhoA.OnThumbDimensionsChanged := PhoaThumbDimensionsChanged;
      SetCurrentGroup(nil);
    end;
  end;

  procedure TThumbnailViewer.SetShowThumbTooltips(Value: Boolean);
  begin
    if FShowThumbTooltips<>Value then begin
      FShowThumbTooltips := Value;
      FLastTooltipIdx := -1;
      Application.CancelHint;
    end;
  end;

  procedure TThumbnailViewer.SetThickThumbBorder(Value: Boolean);
  begin
    if FThickThumbBorder<>Value then begin
      FThickThumbBorder := Value;
      Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbBackColor(Value: TColor);
  begin
    if FThumbBackColor<>Value then begin
      FThumbBackColor := Value;
      if FPicLinks.Count>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbCacheSize(Value: Integer);
  begin
    if FThumbCacheSize<>Value then begin
      FThumbCacheSize := Value;
      LimitCacheSize(Value);
    end;
  end;

  procedure TThumbnailViewer.SetThumbCornerDetails(Corner: TThumbCorner; const Value: TThumbCornerDetail);
  begin
    FThumbCornerDetails[Corner] := Value;
    CalcLayout;
  end;

  procedure TThumbnailViewer.SetThumbFontColor(const Value: TColor);
  begin
    if FThumbFontColor<>Value then begin
      FThumbFontColor := Value;
      if FPicLinks.Count>0 then Invalidate;
    end;
  end;

  procedure TThumbnailViewer.SetThumbTooltipProps(Value: TPicProperties);
  begin
    if FThumbTooltipProps<>Value then begin
      FThumbTooltipProps := Value;
      FLastTooltipIdx := -1;
      Application.CancelHint;
    end;
  end;

  procedure TThumbnailViewer.SetTopIndex(Value: Integer);
  begin
    Value := GetValidTopIndex(Value);
    if FTopIndex<>Value then begin
      FTopIndex := Value;
      UpdateScrollBar;
      Invalidate;
    end;
  end;

  procedure TThumbnailViewer.ToggleSelection(Index: Integer);
  begin
    if FSelIndexes.IndexOf(Index)>=0 then RemoveFromSelection(Index) else AddToSelection(Index);
  end;

  procedure TThumbnailViewer.UpdateScrollBar;
  var ScrollInfo: TScrollInfo;
  begin
    with ScrollInfo do begin
      cbSize := SizeOf(ScrollInfo);
      fMask  := SIF_ALL;
      nMin   := 0;
      nMax   := GetValidTopIndex(MaxInt)+FVisibleItems-1;
      nPage  := FVisibleItems;
      nPos   := FTopIndex;
    end;
    SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
  end;

  procedure TThumbnailViewer.WMContextMenu(var Msg: TWMContextMenu);
  begin
     // �������� context menu ������ ���� �� ��� ����� Ctrl
    if not FShellCtxMenuOnMouseUp then inherited; 
  end;

  procedure TThumbnailViewer.WMGetDlgCode(var Msg: TWMGetDlgCode);
  begin
     // Direct arrow-key messages to the control
    Msg.Result := DLGC_WANTARROWS;
  end;

  procedure TThumbnailViewer.WMNCPaint(var Msg: TWMNCPaint);
  begin
    DefaultHandler(Msg);
    if ThemeServices.ThemesEnabled then ThemeServices.PaintBorder(Self, False);
  end;

  procedure TThumbnailViewer.WMVScroll(var Msg: TWMVScroll);
  var iTopIdx: Integer;
  begin
    case Msg.ScrollCode of
      SB_BOTTOM:       iTopIdx := MaxInt;
      SB_LINEDOWN:     iTopIdx := FTopIndex+FColCount;
      SB_LINEUP:       iTopIdx := FTopIndex-FColCount;
      SB_PAGEDOWN:     iTopIdx := FTopIndex+FVisibleItems;
      SB_PAGEUP:       iTopIdx := FTopIndex-FVisibleItems;
      SB_THUMBPOSITION,
        SB_THUMBTRACK: iTopIdx := Msg.Pos;
      SB_TOP:          iTopIdx := 0;
      else Exit;
    end;
    SetTopIndex(iTopIdx);
  end;

  procedure TThumbnailViewer.WMWindowPosChanged(var Msg: TWMWindowPosChanged);
  begin
    inherited;
    CalcLayout;
  end;

  procedure TThumbnailViewer.WndProc(var Msg: TMessage);
  var i: Integer;
  begin
    case Msg.Msg of
       // On (un)gaining focus repaint selection
      WM_KILLFOCUS, WM_SETFOCUS: begin
        for i := 0 to FSelIndexes.Count-1 do InvalidateItem(FSelIndexes[i]);
        if (FItemIndex>=0) and (FSelIndexes.IndexOf(FItemIndex)<0) then InvalidateItem(FItemIndex);
      end;
      WM_LBUTTONDBLCLK: begin
        DblClick;
        Exit;
      end;
      WM_MOUSEWHEEL: begin
        if TWMMouseWheel(Msg).WheelDelta>0 then TopIndex := TopIndex-FColCount else TopIndex := TopIndex+FColCount;
        Exit;
      end;
    end;
    inherited WndProc(Msg);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoAHintWindow
   //-------------------------------------------------------------------------------------------------------------------

  procedure TPhoAHintWindow.Paint;
  var
    r: TRect;
    s, sLine: String;
  begin
    r := ClientRect;
    InflateRect(r, -2, -2);
    r.Bottom := r.Top+Canvas.TextHeight('Wg');
    Canvas.Font.Color := Screen.HintFont.Color;
     // ���� �� �������
    s := AdjustLineBreaks(Caption, tlbsLF);
    repeat
      sLine := ExtractFirstWord(s, #10);
      if sLine='' then Break;
       // ������ ����� �����
      DrawText(Canvas.Handle, PChar(ExtractFirstWord(sLine, #9)), -1, r, DT_LEFT or DT_NOPREFIX or DT_END_ELLIPSIS);
       // ������ ������ �����
      if sLine<>'' then DrawText(Canvas.Handle, PChar(sLine), -1, r, DT_RIGHT or DT_NOPREFIX or DT_END_ELLIPSIS);
      OffsetRect(r, 0, r.Bottom-r.Top);
    until False;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TSizeGripper
   //-------------------------------------------------------------------------------------------------------------------

  constructor TSizeGripper.Create(AOwner: TComponent);
  begin
    inherited Create(AOwner);
    ControlStyle := ControlStyle-[csOpaque]; 
    Anchors := [akRight, akBottom];
    Cursor  := crSizeNWSE;
    Width   := GetSystemMetrics(SM_CXVSCROLL);
    Height  := GetSystemMetrics(SM_CYHSCROLL);
  end;

  procedure TSizeGripper.Paint;
  var
    r: TRect;
    i, iD, iSize: Integer;

    procedure DiagLine(c: TColor);
    begin
      Canvas.Pen.Color := c;
      MoveToEx(Canvas.Handle, r.Right-2-iD, r.Bottom-2, nil);
      LineTo(Canvas.Handle, r.Right-1, r.Bottom-iD-3);
      Inc(iD);
    end;

  begin
    r := ClientRect;
     // ���� ���� ��������, ���������� ���
    if ThemeServices.ThemesEnabled then
      ThemeServices.DrawElement(Canvas.Handle, ThemeServices.GetElementDetails(tsGripper), r)
     // ����� ������ ���� (ripped from TBX)
    else begin
      iD := 0;
      iSize := Min(r.Right-r.Left, r.Bottom-r.Top);
      for i := 1 to 3 do
        case iSize of
          0..8: begin
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          9..11: begin
            DiagLine(clBtnFace);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          12..14: begin
            DiagLine(clBtnShadow);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
          else begin
            DiagLine(clBtnFace);
            DiagLine(clBtnShadow);
            DiagLine(clBtnShadow);
            DiagLine(clBtnHighlight);
          end;
        end;
      Canvas.Pen.Color := clBtnFace;
      Canvas.MoveTo(r.Right-iD-1, r.Bottom-1);
      Canvas.LineTo(r.Right-1,    r.Bottom-1);
      Canvas.LineTo(r.Right-1,    r.Bottom-iD-2);
    end;
  end;

  procedure TSizeGripper.SetParent(AParent: TWinControl);
  begin
    inherited SetParent(AParent);
    if AParent<>nil then begin
       // ��������� � ������ ������ ���� ��������
      with AParent.ClientRect do SetBounds(Right-Width, Bottom-Height, Width, Height);
       // ������ �� ���
      SendToBack;
    end;
  end;

  procedure TSizeGripper.WMNCHitTest(var Msg: TWMNCHitTest);
  var p: TPoint;
  begin
    inherited;
    if Msg.Result=HTCLIENT then begin
      p := ScreenToClient(SmallPointToPoint(Msg.Pos));
      if PtInRect(ClientRect, p) then Msg.Result := HTBOTTOMRIGHT;
    end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TFileList
   //-------------------------------------------------------------------------------------------------------------------

  function TFileList.Add(const _sName, _sPath: String; _iSize, _iIconIndex: Integer; const _dModified: TDateTime): Integer;
  var
    p: PFileRec;
    FileInfo: TSHFileInfo;
  begin
     // ���� ����� �� ����
    Result := IndexOf(_sName, _sPath);
     // �� �����, ��������� ������
    if Result<0 then begin
      New(p);
      Result := inherited Add(p);
      p^.sName    := _sName;
      p^.sPath    := _sPath;
      p^.bChecked := True;
     // �����, �������� ��������� 
    end else
      p := GetItems(Result);
     // ��������� ������ ������. ��������, ���� ����
    if _iIconIndex=-2 then begin
      FSysImageListHandle := SHGetFileInfo(PAnsiChar(IncludeTrailingPathDelimiter(_sPath)+_sName), 0, FileInfo, SizeOf(FileInfo), SHGFI_SYSICONINDEX or SHGFI_SMALLICON);
      _iIconIndex := FileInfo.iIcon;
    end;
     // ��������� ������
    with p^ do begin
      iSize      := _iSize;
      iIconIndex := _iIconIndex;
      dModified  := _dModified;
    end;
  end;

  procedure TFileList.DeleteUnchecked;
  var i: Integer;
  begin
    for i := Count-1 downto 0 do
      if not GetItems(i)^.bChecked then Delete(i);
  end;

  function TFileList.GetFiles(Index: Integer): String;
  begin
    with GetItems(Index)^ do Result := sPath+sName;
  end;

  function TFileList.GetItems(Index: Integer): PFileRec;
  begin
    Result := PFileRec(inherited Items[Index]);
  end;

  function TFileList.IndexOf(const _sName, _sPath: String): Integer;
  begin
    for Result := 0 to Count-1 do
      with GetItems(Result)^ do
        if AnsiSameText(sName, _sName) and AnsiSameText(sPath, _sPath) then Exit;
    Result := -1;
  end;

  procedure TFileList.InternalQuickSort(iL, iR: Integer; Prop: TFileListSortProperty; Order: TSortOrder);
  var
    i1, i2: Integer;
    p: PFileRec;

    function DoCompare(p1, p2: PFileRec; Prop: TFileListSortProperty; bFurtherSort: Boolean): Integer;
    begin
      case Prop of
        flspName:       Result := AnsiCompareText(p1.sName, p2.sName);
        flspPath:       Result := AnsiCompareText(p1.sPath, p2.sPath);
        flspSize:       Result := p1.iSize-p2.iSize;
        else {flspDate} Result := Sign(p1.dModified-p2.dModified);
      end;
       // ��� ���������� ������ ��������� �� ����, ��� ��������� ����������� ��������� �� �����
      if bFurtherSort and (Result=0) then
        if Prop=flspName then Result := DoCompare(p1, p2, flspPath, False) else Result := DoCompare(p1, p2, flspName, False);
      if Order=soDesc then Result := -Result;
    end;

  begin
    repeat
      i1 := iL;
      i2 := iR;
      p := GetItems((iL+iR) shr 1);
      repeat
        while DoCompare(GetItems(i1), p, Prop, True)<0 do Inc(i1);
        while DoCompare(GetItems(i2), p, Prop, True)>0 do Dec(i2);
        if i1<=i2 then begin
          Exchange(i1, i2);
          Inc(i1);
          Dec(i2);
        end;
      until i1>i2;
      if iL<i2 then InternalQuickSort(iL, i2, Prop, Order);
      iL := i1;
    until i1>=iR;
  end;

  procedure TFileList.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action in [lnExtracted, lnDeleted] then Dispose(PFileRec(Ptr));
  end;

  function TFileList.Remove(const _sName, _sPath: String): Integer;
  begin
    Result := IndexOf(_sName, _sPath);
    if Result>=0 then Delete(Result);
  end;

  procedure TFileList.Sort(Prop: TFileListSortProperty; Order: TSortOrder);
  begin
    if Count>0 then InternalQuickSort(0, Count-1, Prop, Order);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TKeywordList
   //-------------------------------------------------------------------------------------------------------------------

  function TKeywordList.Add(const s: String; bSelected: Boolean): Integer;
  var p: PKeywordRec;
  begin
     // ���� ����� �����. ���� ����� - ����������� �������
    if FindKeyword(s, Result) then begin
      p := GetItems(Result);
      Inc(p.iCount);
     // ����� ���������
    end else begin
      New(p);
      Insert(Result, p);
      with p^ do begin
        sKeyword  := s;
        Change    := kcNone;
        State     := ksOff;
        iCount    := 1;
        iSelCount := 0;
      end;
    end;
    if bSelected then Inc(p.iSelCount);
  end;

  function TKeywordList.FindKeyword(const s: String; out Index: Integer): Boolean;
  var iR, iL, i: Integer;
  begin
    Result := False;
     // ����� ����������� �������
    iL := 0;
    iR := Count-1;
    while iL<=iR do begin
      i := (iL+iR) div 2;
      case AnsiCompareText(GetItems(i).sKeyword, s) of
        Low(Integer)..-1: iL := i+1;
        1..High(Integer): iR := i-1;
        else begin
          Result := True;
          iL := i;
          Break;
        end;
      end;
    end;
    Index := iL;
  end;

  function TKeywordList.GetItems(Index: Integer): PKeywordRec;
  begin
    Result := PKeywordRec(inherited Items[Index]);
  end;

  function TKeywordList.GetSelectedKeywords: String;
  var i: Integer;
  begin
    Result := '';
    for i := 0 to Count-1 do
      with GetItems(i)^ do
        if State=ksOn then
          if LastDelimiter(' ,"', sKeyword)>0 then
            AccumulateStr(Result, ',', AnsiQuotedStr(sKeyword, '"'))
          else
            AccumulateStr(Result, ',', sKeyword);
  end;

  function TKeywordList.InsertNew: Integer;
  var
    sKWBase, sNewKeyword: String;
    iAttempt: Integer;
    p: PKeywordRec;
  begin
     // ���� ���������� �������� ����� ���� "����� �������� ����� (n)"
    sKWBase := ConstVal('SDefaultNewKeyword');
    iAttempt := 0;
    repeat
      Inc(iAttempt);
      sNewKeyword := Format(iif(iAttempt<2, '%s', '%s (%d)'), [sKWBase, iAttempt]);
    until not FindKeyword(sNewKeyword, Result);
     // ���������
    New(p);
    Insert(Result, p);
    with p^ do begin
      sKeyword  := sNewKeyword;
      Change    := kcAdd;
      State     := ksOn;
      iCount    := 0;
      iSelCount := 0;
    end;
  end;

  procedure TKeywordList.Notify(Ptr: Pointer; Action: TListNotification);
  begin
    if Action in [lnExtracted, lnDeleted] then Dispose(PKeywordRec(Ptr));
  end;

  procedure TKeywordList.PopulateFromPhoA(PhoA: TPhotoAlbum; IsPicSelCallback: TKeywordIsPicSelectedProc; iTotalSelCount: Integer);
  var
    ip, ikw: Integer;
    Pic: TPhoaPic;
    bSelected: Boolean;
  begin
     // ������� ������
    Clear;
     // ���� �� ���� ������������ �����������
    bSelected := False; 
    for ip := 0 to PhoA.Pics.Count-1 do begin
      Pic := PhoA.Pics[ip];
       // ���� �������� callback-���������, �������� � ��� �����������: ������� ����������� ��� ���
      if Assigned(IsPicSelCallback) then IsPicSelCallback(Pic, bSelected);
      for ikw := 0 to Pic.PicKeywords.Count-1 do Add(Pic.PicKeywords[ikw], bSelected);
    end;
     // ���������� ��������� ������
    if Assigned(IsPicSelCallback) and (iTotalSelCount>0) then
      for ikw := 0 to Count-1 do
        with GetItems(ikw)^ do
          if iSelCount=0                   then State := ksOff
          else if iSelCount=iTotalSelCount then State := ksOn
          else                                  State := ksGrayed;
  end;

  function TKeywordList.Rename(Index: Integer; const sNewKeyword: String): Integer;
  var p: PKeywordRec;
  begin
    p := GetItems(Index);
     // ���� ������ ���������, ������ ������
    if p.sKeyword=sNewKeyword then Exit;
     // ���� ����� (��� ����� ��������) ���������, �������� �� ����� �����
    if not AnsiSameText(p.sKeyword, sNewKeyword) then begin
       // ���� ��� ���� ����� � ������, �������� Exception
      if FindKeyword(sNewKeyword, Result) then PhoaException(ConstVal('SErrDuplicateKeyword'), []);
       // ����� �������� �� ����� �����
      if Index<Result then Dec(Result);
      Move(Index, Result);
     // ����� ������� ������� 
    end else
      Result := Index;
     // ����������� Change
    with p^ do begin
      case Change of
         // ������ ��������� - ��������� ������ �������� � ������������� ��������� kcReplace
        kcNone: begin
          sOldKeyword := sKeyword;
          Change := kcReplace;
        end;
         // �� ������ ��������� - ���� ���������� ������ ��������, ������� ���������
        kcReplace:
          if sOldKeyword=sNewKeyword then begin
            Change := kcNone;
            sOldKeyword := '';
          end;
      end;
       // ���������� ����� ��������
      sKeyword := sNewKeyword;
    end;
  end;

  procedure TKeywordList.SetSelectedKeywords(const Value: String);
  var
    SL: TStringList;
    i: Integer;
  begin
    SL := TStringList.Create;
    try
       // ������������ ����� � ���� StringList
      SL.Sorted := True;
      SL.Duplicates := dupIgnore;
      SL.CommaText := Value;
       // ��������� ������� ����
      for i := 0 to Count-1 do
        with GetItems(i)^ do
          if SL.IndexOf(sKeyword)<0 then State := ksOff else State := ksOn;
    finally
      SL.Free;
    end;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMask
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMask.Create(const sMask: String; bNegative: Boolean);
  begin
    inherited Create(sMask);
    FNegative := bNegative;
  end;

  function TPhoaMask.Matches(const sFilename: String): Boolean;
  begin
    Result := inherited Matches(sFilename) xor FNegative;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // TPhoaMasks
   //-------------------------------------------------------------------------------------------------------------------

  constructor TPhoaMasks.Create(const sMasks: String);
  var
    s, sMask: String;
    bNegative: Boolean;
  begin
    inherited Create;
    FMasks := TList.Create;
     // ������ ������ �����
    s := iif(sMasks='*.*', '', sMasks);
    while s<>'' do begin
      sMask := ExtractFirstWord(s, ';');
      if sMask<>'' then begin
         // ���� ����� ���������� � '!' - � �������� �������������
        bNegative := sMask[1]='!';
        if bNegative then Delete(sMask, 1, 1);
        if sMask<>'' then FMasks.Add(TPhoaMask.Create(sMask, bNegative));
      end;
    end;
  end;

  destructor TPhoaMasks.Destroy;
  var i: Integer;
  begin
    for i := 0 to FMasks.Count-1 do TMask(FMasks[i]).Free;
    FMasks.Free;
    inherited Destroy;
  end;

  function TPhoaMasks.GetEmpty: Boolean;
  begin
    Result := FMasks.Count=0;
  end;

  function TPhoaMasks.Matches(const sFilename: String): Boolean;
  var i: Integer;
  begin
     // ���� ����� ��� - ������� ���������� ����� ����
    Result := Empty;
     // ����� ��������� ��� ����� �� ������� - ����� �����-�� �������
    if not Result then
      for i := 0 to FMasks.Count-1 do begin
        Result := TPhoaMask(FMasks[i]).Matches(sFilename);
        if Result then Break;
      end;
  end;

   //===================================================================================================================
   // TPhoaCommandLine
   //===================================================================================================================

  procedure PhoaCommandLineError(const sMsg: String; const aParams: Array of const);
  begin
    raise EPhoaCommandLineError.CreateFmt(sMsg, aParams);
  end;

  constructor TPhoaCommandLine.Create;
  begin
    inherited Create;
    FKeyValues := TStringList.Create;
    ParseCmdLine;
  end;

  destructor TPhoaCommandLine.Destroy;
  begin
    FKeyValues.Free;
    inherited Destroy;
  end;

  function TPhoaCommandLine.GetKeyValues(Key: TCmdLineKey): String;
  var idx: Integer;
  begin
    idx := FKeyValues.IndexOfObject(Pointer(Key));
    if idx<0 then Result := '' else Result := FKeyValues[idx];
  end;

  function TPhoaCommandLine.KeyValIndex(Key: TCmdLineKey): Integer;
  begin
    Result := FKeyValues.IndexOfObject(Pointer(Key));
  end;

  procedure TPhoaCommandLine.ParseCmdLine;
  var
    i: Integer;
    sParam, sPhoaName: String;
    k, kLast: TCmdLineKey;

     // ������� � ���������� TCmdLineKey, ��������������� ������� c (case insensitive). ���� �� �������, ��������
     //   EPhoaCommandLineError
    function GetKeyByChar(c: Char): TCmdLineKey;
    begin
       // Convert to lowercase
      if c in ['A'..'Z'] then Inc(c, Ord('a')-Ord('A'));
       // Iterate through known chars
      for Result := Low(Result) to High(Result) do
        if aCmdLineKeys[Result].cChar=c then Exit;
      Result := clkOpenPhoa; // Satisfy the compiler
      PhoaCommandLineError(SCmdLineErrMsg_UnknownKey, [c]);
    end;

     // ������������� �������� sValue ��� ����� Key. ���� � ����� ����� ��� ���� ��������, ��������
     //   EPhoaCommandLineError
    procedure SetKeyValue(Key: TCmdLineKey; sValue: String);
    begin
       // ���� ����� ����
      if KeyValIndex(Key)>=0 then
        if Key=clkOpenPhoa then
          PhoaCommandLineError(SCmdLineErrMsg_DuplicateOpenPhoaValue, [])
        else
          PhoaCommandLineError(SCmdLineErrMsg_DuplicateKeyValue, [aCmdLineKeys[Key].cChar]);
       // ��� ��� ������
      FKeyValues.AddObject(sValue, Pointer(Key));
    end;

  begin
    FKeys := [];
    FKeyValues.Clear;
    kLast := clkOpenPhoa;
    sPhoaName := '';
     // ���������� ��� ���������
    for i := 1 to ParamCount do begin
      sParam := Trim(ParamStr(i));
      if sParam<>'' then
        case sParam[1] of
           // ����. ��������� ��� ������
          '-':
            if Length(sParam)=2 then begin
              k := GetKeyByChar(sParam[2]);
              if k in FKeys then PhoaCommandLineError(SCmdLineErrMsg_DuplicateKey, [aCmdLineKeys[k].cChar]);
              Include(FKeys, k);
              kLast := k;
            end else
              PhoaCommandLineError(SCmdLineErrMsg_KeyNameInvalid, [sParam]);
           // ��������. ��������� ����������� ����������� ����� � ��������
          else begin
            case aCmdLineKeys[kLast].ValueMode of
               // ��� ��������. �������� �������� ��� ���� ����������� ��� ��������
              clkvmNo: SetKeyValue(clkOpenPhoa, sParam);
               // ���� ��������. ��������� ��� � ������
              else SetKeyValue(kLast, sParam);
            end;
             // ���� �������� ������ � ���� �� ���������, �������� ��� � ����� (�.�. ���� �� �� �����������)
            if kLast=clkOpenPhoa then Include(FKeys, clkOpenPhoa);
             // ���������� ���� � ����� �� ���������
            kLast := clkOpenPhoa;
          end;
        end;
    end;
     // ��������� ������������ �������� ����������
    for k := Low(k) to High(k) do
      if (k in FKeys) and (aCmdLineKeys[k].ValueMode=clkvmRequired) and (KeyValIndex(k)<0) then
        PhoaCommandLineError(SCmdLineErrMsg_KeyValueMissing, [aCmdLineKeys[k].cChar]);
  end;

initialization
  HintWindowClass := TPhoAHintWindow;
end.
