//*****************************************************************************
//
// PhoA plugin system interface declarations
// The whole code (c)2002-2004 Dmitry Kann, except where otherwise explicitly
// noted
// Home sites:
//   http://devtools.narod.ru/
//   http://phoa.narod.ru/
//
// Contact email: phoa@narod.ru
//
// Target platform: Borland Delphi 7 (but may compile on earlier platforms)
// Target OS:       Windows
// Language:        Object Pascal
//
//*****************************************************************************
unit phIntf;

interface

   //-------------------------------------------------------------------------------------------------------------------
   // List of links to the pictures
   //-------------------------------------------------------------------------------------------------------------------
type
  IPhoaPicLinks = interface(IInterface)
    ['{11D5E0DC-1CC0-471D-83BF-693834372FDA}']
     // Adds a picture to the list. Returns the index of the newly-added item
    function Add(Pic: IPhoaPic): Integer; stdcall;
     // �������� ��� ������ �� ����������� � �����������
    procedure CopyFromPhoa(PhoA: TPhotoAlbum);
     // �������� ��� ������ �� ����������� � ������. ���� Group=nil, ������ ������� ������
    procedure CopyFromGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup);
     // �������� ��� ID ����������� � ������
    procedure CopyToGroup(Group: TPhoaGroup);
     // ���������� ������ ����������� � �������� ID, ��� -1, ���� ��� ������
    function IndexOfID(iID: Integer): Integer;
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
     // ���������� ���������� ������ ������ Group ������������ ���� � ��������
    function  GetAbsoluteIndexOf(Group: TPhoaGroup): Integer;
    function  GetGroupByAbsoluteIndex(AbsIndex: Integer): TPhoaGroup;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    procedure SetOwner(Value: TPhoaGroup);
    function  GetIndex: Integer;
    procedure SetIndex(Value: Integer);
  public
    constructor Create(_Owner: TPhoaGroup);
    destructor Destroy; override;
     // ���������� True, ���� ID ����������� ������������ � ������ ������ (��� ����� � ��������� ��� bRecursive=True)
    function  IsPicLinked(iID: Integer; bRecursive: Boolean): Boolean;
     // �������� �������� ������ (������������, Expanded, ������ ID ����������� � �������� �����)
    procedure Assign(gSource: TPhoaGroup);
     // Props
     // -- True, ���� ��������������� ������ ���� ������ ��������
    property Expanded: Boolean read FExpanded write FExpanded;
     // -- ������ �����, �������� � ������ ������
    property Groups: TPhoaGroups read FGroups;
     // -- ������ ������ � � ��������� (Owner)
    property Index: Integer read GetIndex write SetIndex;
     // -- ������-�������� ������ ������
    property Owner: TPhoaGroup read FOwner write SetOwner;
     // -- ������ ID �����������, �������� � ������
    property PicIDs: TIntegerList read FPicIDs; 
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
    property  Items[Index: Integer]: TPhoaGroup read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // �����������
   //-------------------------------------------------------------------------------------------------------------------

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
    FPicFormat: TPixelFormat;
    FPicFrameNumber: String;
    FPicKeywords: TStrings;
    FPicNotes: String;
    FPicPlace: String;
    FThumbHeight: Integer;
    FThumbnailData: String;
    FThumbWidth: Integer;
    FPicHeight: Integer;
    FPicWidth: Integer;
    FPicMedia: String;
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
    constructor Create(PhoA: TPhotoAlbum; List: TPhoaPics);
    destructor Destroy; override;
     // �������� ��� ������ �����������
    procedure Assign(Src: TPhoaPic);
     // ������ ����� �� ����� � ��������� ������ ����������� � ������
    procedure MakeThumbnail;
     // ������������ ����� ID, ���������� � ������-���������
    procedure IDNeeded;
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
   // ������ �����������, � ������� ����������� �������������� � �������� �����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaPics = class(TList)
  private
    FPhoA: TPhotoAlbum;
    function GetItems(Index: Integer): TPhoaPic;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
  public
    constructor Create(_PhoA: TPhotoAlbum);
    function  Add(Pic: TPhoaPic): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // ���������� ��������� ��������� ID �����������
    function GetFreePicID: Integer;
     // ���������� ����������� �� ��� ID (nil, ���� �� �������)
    function PicByID(_ID: Integer): TPhoaPic;
     // ���������� ����������� �� ��� ����� ����� (nil, ���� �� �������)
    function PicByFileName(const sFileName: String): TPhoaPic;
     // Props
    property Items[Index: Integer]: TPhoaPic read GetItems; default;
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
     // ��������� ������������� �� ������������
    procedure Sort;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Props
    property Items[Index: Integer]: TPhoaView read GetItems; default;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // ����������
   //-------------------------------------------------------------------------------------------------------------------

  TPhoaOperations = class; 

  TPhotoAlbum = class(TObject)
  private
     // ��������� ������������ �������
    FViewer: TThumbnailViewer;
     // Prop storage
    FRootGroup: TPhoaGroup;
    FPics: TPhoaPics;
    FViews: TPhoaViews;
    FFileName: String;
    FDescription: String;
    FThumbnailQuality: Byte;
    FThumbnailWidth: Integer;
    FThumbnailHeight: Integer;
    FFileRevision: Integer;
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    procedure SetFileName(const Value: String);
    procedure SetThumbnailHeight(Value: Integer);
    procedure SetThumbnailWidth(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
     // ������� ��� ���������� ���� �����������
    procedure New(UndoOperations: TPhoaOperations);
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
    property FileName: String read FFileName write SetFileName;
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
  end;

implementation

end.
