//**********************************************************************************************************************
//  $Id: phObj.pas,v 1.40 2004-10-04 12:44:36 dale Exp $
//===================================================================================================================---
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phObj;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Masks, ConsVars, phPhoa, phIntf, phMutableIntf;

type
  TPhoaGroup  = class;
  TPhoaGroups = class;
  TPhotoAlbum = class;
  TPhoaPic    = class;
  TPhoaPics   = class;
  TPhoaViews  = class;

  TPicArray = Array of TPhoaPic;

   //===================================================================================================================
   // ������ Integer'��
   //===================================================================================================================

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

   //===================================================================================================================
   // ������ ����������� ���� IPhoaPic, ����������� ��������� IPhoaMutablePicList
   //===================================================================================================================

  TPhoaMutablePicList = class(TInterfacedObject, IPhoaPicList, IPhoaMutablePicList)
  private
     // ���������� ��� ������
    FList: TInterfaceList;
     // Prop storage
    FSorted: Boolean;
     // IPhoaPicList
    function  IndexOfID(iID: Integer): Integer; stdcall;
    function  IndexOfFileName(pcFileName: PAnsiChar): Integer; stdcall;
    function  GetCount: Integer; stdcall;
    function  GetItemsByID(iID: Integer): IPhoaPic; stdcall;
    function  GetItemsByFileName(pcFileName: PAnsiChar): IPhoaPic; stdcall;
    function  GetItems(Index: Integer): IPhoaPic; stdcall;
     // IPhoaMutablePicList
    function  Add(Pic: IPhoaPic; bSkipDuplicates: Boolean): Integer; overload; stdcall;
    function  Add(Pic: IPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer; overload; stdcall; 
    function  FindID(iID: Integer; var Index: Integer): Boolean; stdcall;
    procedure Clear; stdcall;
    procedure Delete(Index: Integer); stdcall;
    function  Remove(iID: Integer): Integer; stdcall;
    function  GetSorted: Boolean; stdcall;
  public
     // �����������. ��� bSorted ������ �������� ������������� �� ID �����������
    constructor Create(bSorted: Boolean);
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // ������ ������ �� �����������
   //===================================================================================================================

  TPhoaPicLinks = class(TList, IPhoaPicList)
  private
     // Prop storage
    FSorted: Boolean;
     // IInterface
    function  QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function  _AddRef: Integer; stdcall;
    function  _Release: Integer; stdcall;
     // IPhoaPicList
    function  IPhoaPicList.IndexOfID          = IPPL_IndexOfID;
    function  IPhoaPicList.IndexOfFileName    = IPPL_IndexOfFileName;
    function  IPhoaPicList.GetCount           = IPPL_GetCount;
    function  IPhoaPicList.GetItemsByID       = IPPL_GetItemsByID;
    function  IPhoaPicList.GetItemsByFileName = IPPL_GetItemsByFileName;
    function  IPhoaPicList.GetItems           = IPPL_GetItems;
    function  IPPL_IndexOfID(iID: Integer): Integer; stdcall;
    function  IPPL_IndexOfFileName(pcFileName: PAnsiChar): Integer; stdcall;
    function  IPPL_GetCount: Integer; stdcall;
    function  IPPL_GetItemsByID(iID: Integer): IPhoaPic; stdcall;
    function  IPPL_GetItemsByFileName(pcFileName: PAnsiChar): IPhoaPic; stdcall;
    function  IPPL_GetItems(Index: Integer): IPhoaPic; stdcall;
     // Prop handlers
    function  GetItems(Index: Integer): TPhoaPic;
  public
     // ��� bSorted=True ������ �������� �������������, ���������� �������� ����� � ���������� ��������� ����������� (�.�.
     //   � �������������� ID)
    constructor Create(bSorted: Boolean);
     // �������� ������ �� ����������� � Src. ���� RestrictLinks=nil, �� �������� ��� �����������, ����� - ������ ��,
     //   ID ������� ���������� � RestrictLinks
    procedure Assign(Src: TPhoaPics; RestrictLinks: TPhoaPicLinks);
     // ��������� ����������� � ������. ��� bSkipDuplicates=True ��������� ������������. ������ � bAdded ���������� �
     //   bAdded True, ���� ����������� ���� ���������; False, ���� ���������
    function  Add(Pic: TPhoaPic; bSkipDuplicates: Boolean): Integer; overload;
    function  Add(Pic: TPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer; overload;
     // ���� ����������� �� ID � ���������� True, ���� �����, � � Index - ������� ���������� �����������. ����
     //   ����������� � ����� ID �� �������, ���������� False, � � Index - ������� ����������� � ��������� ������� ID
    function  FindID(iID: Integer; var Index: Integer): Boolean;
     // �������� ��� ������ �� ����������� � ������. ��� bReplace=True �������������� ������� ������ (���� Group=nil,
     //   ������ ������� ������). ��� bRecurse ����� ��������� ����������� �� ��������� �����
    procedure AddFromGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bReplace, bRecurse: Boolean);
     // �������� ��� ������ �� ����������� � ������� ID �����������. ��� bReplace=True �������������� ������� ������
    procedure AddFromPicIDs(PhoA: TPhotoAlbum; const aPicIDs: TIDArray; bReplace: Boolean);
     // �������� ��� ������ �� ����������� � �����������
    procedure CopyFromPhoa(PhoA: TPhotoAlbum);
     // �������� ��� ID ����������� � ������
    procedure CopyToGroup(Group: TPhoaGroup);
     // ���������� ������ ����������� � �������� ID, ��� -1, ���� ��� ������
    function  IndexOfID(iID: Integer): Integer;
     // ���������� ������ ����������� �� ��� ����� �����; -1, ���� ��� ������
    function  IndexOfFileName(const sFileName: String): Integer;
     // ���������� ����������� �� ��� ID (nil, ���� �� �������)
    function  PicByID(iID: Integer): TPhoaPic;
     // ���������� ����������� �� ��� ����� ����� (nil, ���� �� �������)
    function  PicByFileName(const sFileName: String): TPhoaPic;
     // Props
     // -- ������ �� �������
    property Items[Index: Integer]: TPhoaPic read GetItems; default;
  end;

   //===================================================================================================================
   // ������ ���������� �����������
   //===================================================================================================================

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

   //===================================================================================================================
   // ������ (���������) �����������
   //===================================================================================================================

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
    function  GetProps(GroupProp: TGroupProperty): String;
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
     // ���������� �������� ������ �� ������� Props, ������� ������ ��������� ������.
     //   ���� ������ sNameValSep, �� ������� ����� ������������ �������, �������� ��� �� �������� ���� �������.
     //   sPropSep - �������������� ������ ����� ���������� ����������
    function  GetPropStrs(Props: TGroupProperties; const sNameValSep, sPropSep: String): String;
     // Props
     // -- ��������
    property Description: String read FDescription write FDescription;
     // -- True, ���� ��������������� ������ ���� ������ ��������
    property Expanded: Boolean read FExpanded write FExpanded;
     // -- ���������� ��������� ��������� ID, ������� ID ����� ������ � ID ���� � �����
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
     // -- �������� �� �������
    property Props[GroupProp: TGroupProperty]: String read GetProps;
     // -- ���������� �������������� ��������� ���� ����� ��������
    property Root: TPhoaGroup read GetRoot;
     // -- ����� (������������) ������
    property Text: String read FText write FText;
  end;

   //===================================================================================================================
   // ������ ����� �����������
   //===================================================================================================================

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

   //===================================================================================================================
   // �����������
   //===================================================================================================================

  PPhoaPic = ^TPhoaPic; 
  TPhoaPic = class(TObject, IPhoaPic)
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
     // IInterface
    function  QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function  _AddRef: Integer; stdcall;
    function  _Release: Integer; stdcall;
     // IPhoaPic
    function  IPhoaPic.GetID                = IPP_GetID;               
    function  IPhoaPic.GetAuthor            = IPP_GetAuthor;
    function  IPhoaPic.GetDate              = IPP_GetDate;
    function  IPhoaPic.GetTime              = IPP_GetTime;
    function  IPhoaPic.GetDescription       = IPP_GetDescription;
    function  IPhoaPic.GetFileName          = IPP_GetFileName;
    function  IPhoaPic.GetFileSize          = IPP_GetFileSize;
    function  IPhoaPic.GetFilmNumber        = IPP_GetFilmNumber;
    function  IPhoaPic.GetFlips             = IPP_GetFlips;
    function  IPhoaPic.GetFrameNumber       = IPP_GetFrameNumber;
    function  IPhoaPic.GetImageSize         = IPP_GetImageSize;
    function  IPhoaPic.GetKeywords          = IPP_GetKeywords;
    function  IPhoaPic.GetMedia             = IPP_GetMedia;
    function  IPhoaPic.GetNotes             = IPP_GetNotes;
    function  IPhoaPic.GetPlace             = IPP_GetPlace;
    function  IPhoaPic.GetPropertyValue     = IPP_GetPropertyValue;
    function  IPhoaPic.GetRotation          = IPP_GetRotation;
    function  IPhoaPic.GetThumbnailSize     = IPP_GetThumbnailSize;
    function  IPhoaPic.GetThumbnailData     = IPP_GetThumbnailData;
    function  IPhoaPic.GetThumbnailDataSize = IPP_GetThumbnailDataSize;
    function  IPP_GetID: Integer; stdcall;
    function  IPP_GetAuthor: PAnsiChar; stdcall;
    function  IPP_GetDate: Integer; stdcall;
    function  IPP_GetTime: Integer; stdcall;
    function  IPP_GetDescription: PAnsiChar; stdcall;
    function  IPP_GetFileName: PAnsiChar; stdcall;
    function  IPP_GetFileSize: Integer; stdcall;
    function  IPP_GetFilmNumber: PAnsiChar; stdcall;
    function  IPP_GetFlips: TPicFlips; stdcall;
    function  IPP_GetFrameNumber: PAnsiChar; stdcall;
    function  IPP_GetImageSize: TSize; stdcall;
    function  IPP_GetKeywords: PAnsiChar; stdcall;
    function  IPP_GetMedia: PAnsiChar; stdcall;
    function  IPP_GetNotes: PAnsiChar; stdcall;
    function  IPP_GetPlace: PAnsiChar; stdcall;
    function  IPP_GetPropertyValue(pcPropName: PAnsiChar): PAnsiChar; stdcall;
    function  IPP_GetRotation: TPicRotation; stdcall;
    function  IPP_GetThumbnailSize: TSize; stdcall;
    function  IPP_GetThumbnailData: Pointer; stdcall;
    function  IPP_GetThumbnailDataSize: Integer; stdcall;
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
     // ������������ ����� ID, ���������� � ������
    procedure IDNeeded(List: TPhoaPics);
     // ������������� ����� � ��������� ��������� ������, ����������� � ����� �����������
    procedure ReloadPicFileData;
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
    property PicFileSize: Integer read FPicFileSize;
     // -- ����� ��� �������� �����
    property PicFilmNumber: String read FPicFilmNumber write FPicFilmNumber;
     // -- ����� ��������� ����������� ��� ������ ��� �� �����
    property PicFlips: TPicFlips read FPicFlips write FPicFlips;
     // -- ������ ����� �����������
    property PicFormat: TPixelFormat read FPicFormat;
     // -- ����� �����
    property PicFrameNumber: String read FPicFrameNumber write FPicFrameNumber;
     // -- ������ ����������� � ��������
    property PicHeight: Integer read FPicHeight;
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
    property PicWidth: Integer read FPicWidth;
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

   //===================================================================================================================
   // ������ �����������, � ������� ����������� �������������� � �������� ����������� (� ������������ ��� ��������)
   //===================================================================================================================

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

   //===================================================================================================================
   // �������������
   //===================================================================================================================

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

   //===================================================================================================================
   // ������ �������������
   //===================================================================================================================

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

   //===================================================================================================================
   // ����������
   //===================================================================================================================

  TPhoaOperations = class;
  TPhoaUndo       = class;

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
    procedure New(Undo: TPhoaUndo);
     // �������� ��������� �����������. bCopyRevision - ���������� �� �������
    procedure Assign(Src: TPhotoAlbum; bCopyRevision: Boolean);
     // ��������/���������� � ����
    procedure LoadFromFile(const sFileName: String; Undo: TPhoaUndo);
    procedure SaveToFile(const sFileName: String; iRevisionNumber: Integer; Undo: TPhoaUndo);
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

   //===================================================================================================================
   // ������ [���������] ��������� ������� �����������
   //===================================================================================================================

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

   //===================================================================================================================
   // ������ ��� ����������/������ ����� �����������, ���������� ��� ������� ������
   //===================================================================================================================

  TPhoaFilerEx = class(TPhoaFiler)
  protected
    procedure ValidateRevision; override;
  end;

   //*******************************************************************************************************************
   //  �������� � �����
   //*******************************************************************************************************************

   //===================================================================================================================
   // ���� ������ PhoA (����������� �� �������� �����)
   //===================================================================================================================
   // ������ �����:
   //    <������1><���1><������2><���2>...
   //    ������� � ������ ������ ����������� *�� ��������� ������ ������*

   // ��� ������, ����������� � �����
  TPhoaUndoFileDatatype = (pufdStr, pufdInt, pufdByte, pufdBool);

  TPhoaUndoFile = class(TObject)
  private
     // �������� ����� ������ ������
    FStream: TFileStream;
     // ������� ����������� ������� BeginUndo/EndUndo
    FUndoCounter: Integer;
     // ���������, ����������� � ������ ������ BeginUndo
    FUndoPosition: Int64;
     // Prop storage
    FFileName: String;
     // ������ �����, ���� �� ��� �� ������
    procedure CreateStream;
     // ���������� � ����� ��� ������
    procedure WriteDatatype(DT: TPhoaUndoFileDatatype);
     // ��������� �� ����� ���� ���� ������ � ��������� ��� �� ������������ DTRequired. ���� �� ���������, ��������
     //   Exception
    procedure ReadCheckDatatype(DTRequired: TPhoaUndoFileDatatype);
     // Prop handlers
    function  GetPosition: Int64;
  public
    constructor Create;
    destructor Destroy; override;
     // ���������� ����� � ���� 
    procedure Clear;
     // ������ ��� ������/������ ������ �� �����
    procedure WriteStr (const s: String);
    procedure WriteInt (i: Integer);
    procedure WriteByte(b: Byte);
    procedure WriteBool(b: Boolean);
    function  ReadStr: String;
    function  ReadInt: Integer;
    function  ReadByte: Byte;
    function  ReadBool: Boolean;
     // ��������� ������/��������� �������� ���������� ������ ������. BeginUndo ������������� ���� � �������� �������,
     //   �, ���� ��� ������ ����� BeginUndo, ���������� ��� �������. EndUndo ��������� ������� ��������� ����������,
     //   �, ���� ��� ��������� ����� EndUndo, ������� ���� �� ����������� � ������ ������ BeginUndo �������
    procedure BeginUndo(i64Position: Int64);
    procedure EndUndo;
     // Props
     // -- ��� ����� ������ (����������)
    property FileName: String read FFileName;
     // -- ������� ��������� � ������ ������. ������ ����� ��� ������ ���������
    property Position: Int64 read GetPosition; 
  end;

   // ������� ��������, �� ���������� ��������� �����������

  TBaseOperation = class(TObject)
  end;

   // ������� (�����������) �������� �����������, ������������� ������ (������ ������), ������� ����� ���� ��������

  TPhoaOperation = class(TBaseOperation)
  private
     // ������� ������ ������ �������� � Undo-����� ������ ������ (UndoFile)
    FUndoDataPosition: Int64;
     // Prop storage
    FPhoA: TPhotoAlbum;
     // Prop handlers
    function  GetOpGroup: TPhoaGroup;
    function  GetParentOpGroup: TPhoaGroup;
    procedure SetOpGroup(Value: TPhoaGroup);
    procedure SetParentOpGroup(Value: TPhoaGroup);
    function  GetUndoFile: TPhoaUndoFile;
  protected
     // Prop storage
    FList: TPhoaOperations;
    FOpGroupID: Integer;
    FOpParentGroupID: Integer;
    FSavepoint: Boolean;
     // Prop handlers
    function GetInvalidationFlags: TUndoInvalidationFlags; virtual;
     // �������� ��������� ������ ���������, �������� ���������. � ������� ������ �� ������ ������ 
    procedure RollbackChanges; virtual;
     // Props
     // -- ���������� ������, ��������������� GroupID
    property OpGroup: TPhoaGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� ParentGroupID
    property OpParentGroup: TPhoaGroup read GetParentOpGroup write SetParentOpGroup;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
    destructor Destroy; override;
     // ���������, ������������ ���������, �������� ��������� (������� RollbackChanges()), � ������������
     //   ������-��������
    procedure Undo; 
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
     // -- ���� ������ ������ (���������� ����� FList)
    property UndoFile: TPhoaUndoFile read GetUndoFile;
  end;

   // ������ ��������� ��������
  TPhoaOperations = class(TList)
  private
     // ������� ����������
    FUpdateLock: Integer;
     // Prop storage
    FUndoFile: TPhoaUndoFile;
    FOnStatusChange: TNotifyEvent;
    FOnOpUndone: TNotifyEvent;
    FOnOpDone: TNotifyEvent;
     // Prop handlers
    function  GetItems(Index: Integer): TPhoaOperation;
    function  GetCanUndo: Boolean;
  protected
     // �������� OnStatusChange
    procedure DoStatusChange;
     // ���������� ���� ����� (������������� ��� ��������� ������� ������������� ��������)
    procedure UndoAll;
  public
    constructor Create(AUndoFile: TPhoaUndoFile);
    function  Add(Item: TPhoaOperation): Integer;
    function  Remove(Item: TPhoaOperation): Integer;
    procedure Delete(Index: Integer);
    procedure Clear; override;
     // ���������/������ ����������
    procedure BeginUpdate;
    procedure EndUpdate;
     // Props
     // -- ���������� True, ���� � ������ ���� �������� ��� ������
    property CanUndo: Boolean read GetCanUndo;
     // -- ��������������� ������ ��������
    property Items[Index: Integer]: TPhoaOperation read GetItems; default;
     // -- ���� ������ ������
    property UndoFile: TPhoaUndoFile read FUndoFile;
     // -- �������, ����������� ��� ���������� �������� (������, ��� ����������� �������� � ������)
    property OnOpDone: TNotifyEvent read FOnOpDone write FOnOpDone;
     // -- �������, ����������� ��� ������ ��������
    property OnOpUndone: TNotifyEvent read FOnOpUndone write FOnOpUndone;
     // -- ������� ����� ��������� (����������� ������ - ���������� ��� ����������/�������� ��������, ��� ��������� SavePoint)
    property OnStatusChange: TNotifyEvent read FOnStatusChange write FOnStatusChange;
  end;

   // ����� ������ PhoA. �������� ������ *���������������* �������� � �������� ����������� ������ ������ 
  TPhoaUndo = class(TPhoaOperations)
  private
     // True, ���� "������" ��������� ������ ������ ������������� ����������� ��������� �����������
    FSavepointOnEmpty: Boolean;
     // Prop handlers
    function  GetLastOpName: String;
    function  GetIsUnmodified: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
     // �������������, ��� ������� ��������� ����������� �������� ����������
    procedure SetSavepoint;
     // �������������, ��� ������� ��������� �������� ����������������, �� ����� ����������
    procedure SetNonUndoable;
     // Props
     // -- ���������� True, ���� ������� ��������� ������ ������ ������������� ����������� ��������� �����������
    property IsUnmodified: Boolean read GetIsUnmodified;
     // -- ���������� ������������ ��������� ��������� ��������
    property LastOpName: String read GetLastOpName;
  end;

   // ����������� ��������, ��������� �� ���������� ��������. ��� ������ ���������� ��� �������� �����
  TPhoaMultiOp = class(TPhoaOperation)
  protected
     // ��������� ��������
    FOperations: TPhoaOperations;
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
    destructor Destroy; override;
     // Props
    property Operations: TPhoaOperations read FOperations;
  end;

   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   // �������� ��������
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

   //===================================================================================================================
   // �������� �������� ������ ������� � ������� ������ (CurGroup)
   //===================================================================================================================

  TPhoaOp_GroupNew = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; CurGroup: TPhoaGroup);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupRename = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText: String);
  end;

   //===================================================================================================================
   // �������� �������������� ������� ������
   //===================================================================================================================

  TPhoaOp_GroupEdit = class(TPhoaOp_GroupRename)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText, sNewDescription: String);
  end;

   //===================================================================================================================
   // �������� �������� ������
   //===================================================================================================================

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  private
     // ������ �������� ��������� �����
    FCascadedDeletes: TPhoaOperations;
     // ������ �������� �������������� �����������
    FUnlinkedPicRemoves: TPhoaOperations;
     // ������ ID ����������� ������
    FPicIDs: TIntegerList;
     // ���������� (���������������� �� ������������� ������� ���������� Owner-�) ��������� ������
    procedure InternalRollback(gOwner: TPhoaGroup);
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
     // �������� bPerform ������������, ��������� �� �������� (� ����� ����� �������������� �����������). ������ ����
     //   True ��� ������ ��� ����������� �������� �������� ������. ��� ��������� ����� ����������� ���������� ��� �
     //   ���������� False (����� �������� � ������������ �������������� ����������� ����������� ������ ��������, �����
     //   ���������� ���� ��������� ��������� �����)
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; bPerform: Boolean);
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ��������������� ����������� (������������ � TPhotoAlbum.RemoveUnlinkedPics)
   //===================================================================================================================

  TPhoaOp_InternalPicRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic);
  end;

   //===================================================================================================================
   // ����������� �������� �������������� �����������, ������ ����������� ��� ��������:
   //  - TPhoaOp_InternalEditPicProps
   //  - TPhoaOp_InternalEditPicKeywords
   //  - TPhoaOp_InternalPicFromGroupRemoving
   //  - TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  TPhoaMultiOp_PicEdit = class(TPhoaMultiOp)
  end;

   //===================================================================================================================
   // ���������� �������� �������������� ������� �����������, ����� �������� ����
   //===================================================================================================================

  TPhoaOp_InternalEditPicProps = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; ChangeList: TPicPropertyChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //===================================================================================================================

  TKeywordList = class;

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; Keywords: TKeywordList);
  end;

   //===================================================================================================================
   // �������� ���������� �������������� �����������
   //===================================================================================================================

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic; NewRotation: TPicRotation; NewFlips: TPicFlips);
  end;

   //===================================================================================================================
   // �������� ���������� ���������� ����������� (������������ ��� ��������� ��� �������� TPhoaOp_InternalPicAdd)
   //===================================================================================================================

  TPhoaMultiOp_PicAdd = class(TPhoaMultiOp)
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (������������ ��� ����� TPhoaMultiOp_PicAdd � TPhoaMultiOp_PicPaste)
   //===================================================================================================================

  TPhoaOp_InternalPicAdd = class(TPhoaOperation)
  private
     // True, ���� ���� ����������� ��� ��� ��������������� � ����������� �� ���������� �����������
    FExisting: Boolean;
     // Prop storage
    FAddedPic: TPhoaPic;
     // ������������ ����������� � ������, ���� ��� ��� �� ����, � ���������� ������ ������
    procedure RegisterPic(Group: TPhoaGroup; Pic: TPhoaPic);
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sFilename: String); overload;
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pic: TPhoaPic); overload;
     // Props
     // -- ��������� ����������� ��� �������� �� �����
    property AddedPic: TPhoaPic read FAddedPic;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������
   //===================================================================================================================

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  end;

   //===================================================================================================================
   // �������� ����������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaBaseOp_PicCopy = class(TBaseOperation)
    constructor Create(const aPics: TPicArray);
  end;

   //===================================================================================================================
   // �������� ��������/��������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaMultiOp_PicDelete = class(TPhoaMultiOp)
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  end;

   //===================================================================================================================
   // �������� ������� ���������� ����������� �� ������ ������
   //===================================================================================================================

  TPhoaMultiOp_PicPaste = class(TPhoaMultiOp)
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup);
  end;

   //===================================================================================================================
   // �������� �������������� ������� �����������
   //===================================================================================================================

  TPhoaOp_PhoAEdit = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; iNewThWidth, iNewThHeight: Integer; bNewThQuality: Byte; const sNewDescription: String);
  end;

   //===================================================================================================================
   // �������� [���]��������� �������� � �������������
   //===================================================================================================================

  TPhoaMultiOp_PicOperation = class(TPhoaMultiOp)
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; const aSelPicIDs: TIDArray; PicOperation: TPictureOperation);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� � ����� ������
   //===================================================================================================================

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings);
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //===================================================================================================================

  TPhoaMultiOp_PicSort = class(TPhoaMultiOp)
  private
     // ����������� (��� bRecursive=True) ���������, ��������� �������� ���������� ������
    procedure AddGroupSortOp(Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings; bRecursive: Boolean);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupDragAndDrop = class(TPhoaOperation)
  protected
    function GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group, NewParentGroup: TPhoaGroup; iNewIndex: Integer);
  end;

   //===================================================================================================================
   // �������� �������������� ����������� � ������
   //===================================================================================================================

  TPhoaMultiOp_PicDragAndDropToGroup = class(TPhoaMultiOp)
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; aSelPicIDs: TIDArray; bCopy: Boolean);
  end;

   //===================================================================================================================
   // �������� �������������� (������������������) ����������� ������ ������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray; idxNew: Integer);
  end;

   //===================================================================================================================
   // ��������������� ��������� ��� ������ �� ������� �������������
   //===================================================================================================================

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

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewNew = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; ViewsIntf: IPhoaViews; const sName: String; Groupings: TPhoaGroupings; Sortings: TPhoaSortings);
  end;

   //===================================================================================================================
   // �������� ��������� �������������
   //===================================================================================================================

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
  protected
    procedure RollbackChanges; override;
  public
     // ���� NewGroupings=nil � NewSortings=nil, ������, ��� ������ �������������� �������������
    constructor Create(List: TPhoaOperations; View: TPhoaView; ViewsIntf: IPhoaViews; const sNewName: String; NewGroupings: TPhoaGroupings; NewSortings: TPhoaSortings);
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; ViewsIntf: IPhoaViews);
  end;

   //===================================================================================================================
   // �������� �������� ������ ����������� �� �������������
   //===================================================================================================================

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  private
     // ��������� ������ �������������
    FViewsIntf: IPhoaViews;
  protected
    procedure RollbackChanges; override;
  public
     // Group - ������, ���� �������� ����� �������������
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; ViewsIntf: IPhoaViews);
  end;

   //===================================================================================================================
   // ���������� � ����� � ������ ������� ������
   //===================================================================================================================

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

   //===================================================================================================================
   // ������ �������� ����
   //===================================================================================================================

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

   //===================================================================================================================
   // ����� ��� �������� ��� ������, �������������� ��������
   //===================================================================================================================

  TPhoaMask = class(TMask)
  private
    FNegative: Boolean;
  public
    constructor Create(const sMask: String; bNegative: Boolean);
     // ���������� True, ���� ��� ����� [��]������������� �����
    function Matches(const sFilename: String): Boolean;
  end;

   //===================================================================================================================
   // ������ ����� (��� �������� ��� ������)
   //===================================================================================================================

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

   //===================================================================================================================
   // ��������� ������ PhoA
   //===================================================================================================================

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

   //===================================================================================================================

   // ��������� � TStrings �����, ������ ����� � ������� �� ����������� �����������
  procedure StringsLoadPFAM(PhoA: TPhotoAlbum; SLPlaces, SLFilmNumbers, SLAuthors, SLMedia: TStrings);

   // ������������ ID �� TPicArray � TIDArray
  function PicArrayToIDArray(const Pics: TPicArray): TIDArray;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Math, Registry, DateUtils, Clipbrd, ShellAPI, Themes,
  VirtualDataObject, GR32,
  phUtils, phSettings, phGraphics;

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

   //===================================================================================================================
   // Misc routines
   //===================================================================================================================

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

   //===================================================================================================================
   // TIntegerList
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaMutablePicList
   //===================================================================================================================

  function TPhoaMutablePicList.Add(Pic: IPhoaPic; bSkipDuplicates: Boolean): Integer;
  var bDummy: Boolean;
  begin
    Result := Add(Pic, bSkipDuplicates, bDummy);
  end;

  function TPhoaMutablePicList.Add(Pic: IPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer;
  begin
    if FSorted or bSkipDuplicates then begin
      bAdded := not FindID(Pic.ID, Result);
      if bAdded then FList.Insert(Result, Pic);
    end else begin
      bAdded := True;
      Result := FList.Add(Pic);
    end;
  end;

  procedure TPhoaMutablePicList.Clear;
  begin
    FList.Clear;
  end;

  constructor TPhoaMutablePicList.Create(bSorted: Boolean);
  begin
    inherited Create;
    FSorted := bSorted;
    FList := TInterfaceList.Create;
  end;

  procedure TPhoaMutablePicList.Delete(Index: Integer);
  begin
    FList.Delete(Index);
  end;

  destructor TPhoaMutablePicList.Destroy;
  begin
    FList.Free;
    inherited Destroy;
  end;

  function TPhoaMutablePicList.FindID(iID: Integer; var Index: Integer): Boolean;
  var i1, i2, i, iCompare: Integer;
  begin
    Result := False;
     // ���� ������ ������������� - ���� � ������� ��������� ������
    if FSorted then begin
      i1 := 0;
      i2 := FList.Count-1;
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
      for i := 0 to FList.Count-1 do
        if GetItems(i).ID=iID then begin
          Result := True;
          Index := i;
          Exit;
        end;
      Index := FList.Count;
    end;
  end;

  function TPhoaMutablePicList.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TPhoaMutablePicList.GetItems(Index: Integer): IPhoaPic;
  begin
    Result := IPhoaPic(FList[Index]);
  end;

  function TPhoaMutablePicList.GetItemsByFileName(pcFileName: PAnsiChar): IPhoaPic;
  var idx: Integer;
  begin
    idx := IndexOfFileName(pcFileName);
    if idx<0 then Result := nil else Result := GetItems(idx);
  end;

  function TPhoaMutablePicList.GetItemsByID(iID: Integer): IPhoaPic;
  var idx: Integer;
  begin
    idx := IndexOfID(iID);
    if idx<0 then Result := nil else Result := GetItems(idx);
  end;

  function TPhoaMutablePicList.GetSorted: Boolean;
  begin
    Result := FSorted;
  end;

  function TPhoaMutablePicList.IndexOfFileName(pcFileName: PAnsiChar): Integer;
  var sFileName: String;
  begin
    sFileName := pcFileName;
    for Result := 0 to FList.Count-1 do
      if ReverseCompare(GetItems(Result).FileName, sFileName) then Exit;
    Result := -1;
  end;

  function TPhoaMutablePicList.IndexOfID(iID: Integer): Integer;
  begin
    if not FindID(iID, Result) then Result := -1;
  end;

  function TPhoaMutablePicList.Remove(iID: Integer): Integer;
  begin
    if FindID(iID, Result) then FList.Delete(Result) else Result := -1;
  end;

   //===================================================================================================================
   // TPhoaPicLinks
   //===================================================================================================================

  function TPhoaPicLinks.Add(Pic: TPhoaPic; bSkipDuplicates: Boolean): Integer;
  var bDummy: Boolean;
  begin
    Result := Add(Pic, bSkipDuplicates, bDummy);
  end;

  function TPhoaPicLinks.Add(Pic: TPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer;
  begin
    if FSorted or bSkipDuplicates then begin
      bAdded := not FindID(Pic.ID, Result);
      if bAdded then Insert(Result, Pic);
    end else begin
      bAdded := True;
      Result := inherited Add(Pic);
    end;
  end;

  procedure TPhoaPicLinks.AddFromGroup(PhoA: TPhotoAlbum; Group: TPhoaGroup; bReplace, bRecurse: Boolean);
  var i: Integer;
  begin
    if bReplace then Clear;
     // �������� ������ �� �����������, ������������� ������
    if Group<>nil then begin
       // ���� �� ����������� ����������, �� ��������� �� ���������, �.�. ������ �� ����� ��������� ����������� ������
      for i := 0 to Group.PicIDs.Count-1 do Add(PhoA.Pics.PicByID(Group.PicIDs[i]), bRecurse);
       // ���� ����������� ���������� - ��������� �� �� ��� ��������� �����
      if bRecurse then
        for i := 0 to Group.Groups.Count-1 do AddFromGroup(PhoA, Group.Groups[i], False, True);
    end;
  end;

  procedure TPhoaPicLinks.AddFromPicIDs(PhoA: TPhotoAlbum; const aPicIDs: TIDArray; bReplace: Boolean);
  var i: Integer;
  begin
    if bReplace then Clear;
    for i := 0 to High(aPicIDs) do Add(PhoA.Pics.PicByID(aPicIDs[i]), True);
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
        if RestrictLinks.IndexOfID(Pic.ID)>=0 then Add(Pic, False);
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

  function TPhoaPicLinks.IndexOfFileName(const sFileName: String): Integer;
  begin
    for Result := 0 to Count-1 do
      if ReverseCompare(GetItems(Result).PicFileName, sFileName) then Exit;
    Result := -1;
  end;

  function TPhoaPicLinks.IndexOfID(iID: Integer): Integer;
  begin
    if not FindID(iID, Result) then Result := -1;
  end;

  function TPhoaPicLinks.IPPL_GetCount: Integer;
  begin
    Result := Count;
  end;

  function TPhoaPicLinks.IPPL_GetItems(Index: Integer): IPhoaPic;
  begin
    Result := Items[Index];
  end;

  function TPhoaPicLinks.IPPL_GetItemsByFileName(pcFileName: PAnsiChar): IPhoaPic;
  begin
    Result := PicByFileName(pcFileName);
  end;

  function TPhoaPicLinks.IPPL_GetItemsByID(iID: Integer): IPhoaPic;
  begin
    Result := PicByID(iID);
  end;

  function TPhoaPicLinks.IPPL_IndexOfFileName(pcFileName: PAnsiChar): Integer;
  begin
    Result := IndexOfFileName(pcFileName);
  end;

  function TPhoaPicLinks.IPPL_IndexOfID(iID: Integer): Integer;
  begin
    Result := IndexOfID(iID);
  end;

  function TPhoaPicLinks.PicByFileName(const sFileName: String): TPhoaPic;
  var idx: Integer;
  begin
    idx := IndexOfFileName(sFileName);
    if idx<0 then Result := nil else Result := GetItems(idx);
  end;

  function TPhoaPicLinks.PicByID(iID: Integer): TPhoaPic;
  var idx: Integer;
  begin
    if FindID(iID, idx) then Result := GetItems(idx) else Result := nil;
  end;

  function TPhoaPicLinks.QueryInterface(const IID: TGUID; out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
  end;

  function TPhoaPicLinks._AddRef: Integer;
  begin
     // No refcounting applicable
    Result := -1;
  end;

  function TPhoaPicLinks._Release: Integer;
  begin
     // No refcounting applicable
    Result := -1;
  end;

   //===================================================================================================================
   // TPhoaSortings
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaGroup
   //===================================================================================================================

  procedure TPhoaGroup.Assign(Src: TPhoaGroup; bCopyIDs, bCopyPicIDs, bCopySubgroups: Boolean);
  var i: Integer;
  begin
    if bCopyIDs then FID := Src.FID;
    FText        := Src.FText;
    FDescription := Src.FDescription;
    FExpanded    := Src.FExpanded;
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

  function TPhoaGroup.GetProps(GroupProp: TGroupProperty): String;

    function IntToStrPositive(i: Integer): String;
    begin
      if i>0 then Result := IntToStr(i) else Result := '';
    end;

  begin
    Result := '';
    case GroupProp of
      gpID:          Result := IntToStr(FID);
      gpText:        Result := FText;
      gpDescription: Result := FDescription;
      gpPicCount:    Result := IntToStrPositive(FPicIDs.Count);
      gpGroupCount:  Result := IntToStrPositive(NestedGroupCount);
    end;
  end;

  function TPhoaGroup.GetPropStrs(Props: TGroupProperties; const sNameValSep, sPropSep: String): String;
  var
    Prop: TGroupProperty;
    sVal: String;
  begin
    Result := '';
    for Prop := Low(Prop) to High(Prop) do
      if Prop in Props then begin
        sVal := GetProps(Prop);
        if sVal<>'' then begin
          if sNameValSep<>'' then sVal := GroupPropName(Prop)+sNameValSep+sVal;
          AccumulateStr(Result, sPropSep, sVal);
        end;
      end;
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
            IPhChunk_Group_ID:          FID          := vValue;
            IPhChunk_Group_Text:        FText        := vValue;
            IPhChunk_Group_Expanded:    FExpanded    := vValue<>Byte(0);
            IPhChunk_Group_Description: FDescription := vValue;
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
        WriteChunkInt   (IPhChunk_Group_ID,          FID);
        WriteChunkString(IPhChunk_Group_Text,        FText);
        WriteChunkByte  (IPhChunk_Group_Expanded,    Byte(FExpanded));
        WriteChunkString(IPhChunk_Group_Description, FDescription);
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

   //===================================================================================================================
   // TPhoaGroups
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaPic
   //===================================================================================================================

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
      ppTime:          if Frac(FPicDateTime)>0  then Result := TimeToStrX(FPicDateTime);
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

  function TPhoaPic.IPP_GetAuthor: PAnsiChar;
  begin
    Result := PAnsiChar(FPicAuthor);
  end;

  function TPhoaPic.IPP_GetDate: Integer;
  begin
    Result := DateToPhoaDate(FPicDateTime);
  end;

  function TPhoaPic.IPP_GetDescription: PAnsiChar;
  begin
    Result := PAnsiChar(FPicDesc);
  end;

  function TPhoaPic.IPP_GetFileName: PAnsiChar;
  begin
    Result := PAnsiChar(FPicFileName);
  end;

  function TPhoaPic.IPP_GetFileSize: Integer;
  begin
    Result := FPicFileSize;
  end;

  function TPhoaPic.IPP_GetFilmNumber: PAnsiChar;
  begin
    Result := PAnsiChar(FPicFilmNumber);
  end;

  function TPhoaPic.IPP_GetFlips: TPicFlips;
  begin
    Result := FPicFlips;
  end;

  function TPhoaPic.IPP_GetFrameNumber: PAnsiChar;
  begin
    Result := PAnsiChar(FPicFrameNumber);
  end;

  function TPhoaPic.IPP_GetID: Integer;
  begin
    Result := FID;
  end;

  function TPhoaPic.IPP_GetImageSize: TSize;
  begin
    Result.cx := FPicWidth;
    Result.cy := FPicHeight;
  end;

  function TPhoaPic.IPP_GetKeywords: PAnsiChar;
  begin
    Result := PAnsiChar(FPicKeywords.CommaText);
  end;

  function TPhoaPic.IPP_GetMedia: PAnsiChar;
  begin
    Result := PAnsiChar(FPicMedia);
  end;

  function TPhoaPic.IPP_GetNotes: PAnsiChar;
  begin
    Result := PAnsiChar(FPicNotes);
  end;

  function TPhoaPic.IPP_GetPlace: PAnsiChar;
  begin
    Result := PAnsiChar(FPicPlace);
  end;

  function TPhoaPic.IPP_GetPropertyValue(pcPropName: PAnsiChar): PAnsiChar;
  var Prop: TPicProperty;
  begin
    Prop := PropNameToPicProperty(pcPropName);
    if Prop in PPAllProps then Result := PAnsiChar(Props[Prop]) else Result := nil;
  end;

  function TPhoaPic.IPP_GetRotation: TPicRotation;
  begin
    Result := FPicRotation;
  end;

  function TPhoaPic.IPP_GetThumbnailData: Pointer;
  begin
    Result := Pointer(FThumbnailData);
  end;

  function TPhoaPic.IPP_GetThumbnailDataSize: Integer;
  begin
    Result := Length(FThumbnailData);
  end;

  function TPhoaPic.IPP_GetThumbnailSize: TSize;
  begin
    Result.cx := FThumbWidth;
    Result.cy := FThumbHeight;
  end;

  function TPhoaPic.IPP_GetTime: Integer;
  begin
    Result := TimeToPhoaTime(FPicDateTime);
  end;

  function TPhoaPic.QueryInterface(const IID: TGUID; out Obj): HResult;
  begin
    if GetInterface(IID, Obj) then Result := S_OK else Result := E_NOINTERFACE;
  end;

  procedure TPhoaPic.ReloadPicFileData;
  begin
    FThumbnailData := GetThumbnailData(
      FPicFileName,
      FPhoA.FThumbnailWidth,
      FPhoA.FThumbnailHeight,
      TStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)),
      FPhoA.FThumbnailQuality,
      FPicWidth,
      FPicHeight,
      FThumbWidth,
      FThumbHeight);
  end;

  procedure TPhoaPic.SetList(Value: TPhoaPics);
  begin
    if FList<>Value then begin
      if FList<>nil then FList.Remove(Self);
      FList := Value;
      if FList<>nil then FList.Add(Self, False);
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

  function TPhoaPic._AddRef: Integer;
  begin
     // No refcounting applicable
    Result := -1;
  end;

  function TPhoaPic._Release: Integer;
  begin
     // No refcounting applicable
    Result := -1;
  end;

   //===================================================================================================================
   // TPhoaPics
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaViewHelperPics
   //===================================================================================================================
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

   //===================================================================================================================
   // TPhoaGroupings
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaView
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaViews
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhotoAlbum
   //===================================================================================================================

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

  procedure TPhotoAlbum.LoadFromFile(const sFileName: String; Undo: TPhoaUndo);
  var Streamer: TPhoaStreamer;
  begin
    New(Undo);
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
      New(Undo);
      raise;
    end;
  end;

  procedure TPhotoAlbum.New(Undo: TPhoaUndo);
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
    if Undo<>nil then begin
      Undo.Clear;
      Undo.SetSavepoint;
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

  procedure TPhotoAlbum.SaveToFile(const sFileName: String; iRevisionNumber: Integer; Undo: TPhoaUndo);
  var Streamer: TPhoaStreamer;
  begin
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
    if Undo<>nil then Undo.SetSavepoint;
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
        WriteChunkString(IPhChunk_Remark,           Format('Created by PhoA %s, %s', [SAppVersion, DKWeb.MainSiteURI]));
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

   //===================================================================================================================
   // TPicPropertyChanges
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaFilerEx
   //===================================================================================================================

  procedure TPhoaFilerEx.ValidateRevision;
  begin
     // �� ��������� ���������� ������ ����� ����� �������
    if RevisionNumber>IPhFileRevisionNumber then PhoaException(ConstVal('SErrFileRevHigher'), []);
  end;

   //===================================================================================================================
   // TPhoaUndoFile
   //===================================================================================================================

  procedure TPhoaUndoFile.BeginUndo(i64Position: Int64);
  begin
    if FUndoCounter=0 then FUndoPosition := i64Position;
    FStream.Position := i64Position;
    Inc(FUndoCounter);
  end;

  procedure TPhoaUndoFile.Clear;
  begin
    if FStream<>nil then begin
      FreeAndNil(FStream);
      SysUtils.DeleteFile(FFileName);
    end;
  end;

  constructor TPhoaUndoFile.Create;
  begin
    inherited Create;
     // ���������� ��� �����
    FFileName := Format('%sphoa_undo_%.8x.tmp', [GetWindowsTempPath, GetCurrentProcessId]);
  end;

  procedure TPhoaUndoFile.CreateStream;
  begin
    if FStream=nil then FStream := TFileStream.Create(FFileName, fmCreate);
  end;

  destructor TPhoaUndoFile.Destroy;
  begin
     // ���������� ����� � ����
    Clear;
    inherited Destroy;
  end;

  procedure TPhoaUndoFile.EndUndo;
  begin
    Assert(FUndoCounter>0, 'Excessive TPhoaUndoFile.EndUndo() call');
    Dec(FUndoCounter);
     // ������� ��������� � ���� - ������������� � ����������� ������� � ������� ����
    if FUndoCounter=0 then begin
      FStream.Position := FUndoPosition;
      FStream.Size     := FUndoPosition;
    end;
  end;

  function TPhoaUndoFile.GetPosition: Int64;
  begin
    CreateStream;
    Result := FStream.Position;
  end;

  function TPhoaUndoFile.ReadBool: Boolean;
  begin
    ReadCheckDatatype(pufdBool);
    Result := phObj.ReadByte(FStream)<>0;
  end;

  function TPhoaUndoFile.ReadByte: Byte;
  begin
    ReadCheckDatatype(pufdByte);
    Result := phObj.ReadByte(FStream);
  end;

  procedure TPhoaUndoFile.ReadCheckDatatype(DTRequired: TPhoaUndoFileDatatype);
  var DTActual: TPhoaUndoFileDatatype;
  begin
    Byte(DTActual) := phObj.ReadByte(FStream);
    if DTActual<>DTRequired then
      raise Exception.CreateFmt(
        'Invalid undo stream datatype; required: %s, actual: %s',
        [GetEnumName(TypeInfo(TPhoaUndoFileDatatype), Byte(DTRequired)), GetEnumName(TypeInfo(TPhoaUndoFileDatatype), Byte(DTActual))]);
  end;

  function TPhoaUndoFile.ReadInt: Integer;
  begin
    ReadCheckDatatype(pufdInt);
    Result := phObj.ReadInt(FStream);
  end;

  function TPhoaUndoFile.ReadStr: String;
  begin
    ReadCheckDatatype(pufdStr);
    Result := phObj.ReadStr(FStream);
  end;

  procedure TPhoaUndoFile.WriteBool(b: Boolean);
  begin
    WriteDatatype(pufdBool);
    phObj.WriteByte(FStream, Byte(b));
  end;

  procedure TPhoaUndoFile.WriteByte(b: Byte);
  begin
    WriteDatatype(pufdByte);
    phObj.WriteByte(FStream, b);
  end;

  procedure TPhoaUndoFile.WriteDatatype(DT: TPhoaUndoFileDatatype);
  begin
    phObj.WriteByte(FStream, Byte(DT));
  end;

  procedure TPhoaUndoFile.WriteInt(i: Integer);
  begin
    WriteDatatype(pufdInt);
    phObj.WriteInt(FStream, i);
  end;

  procedure TPhoaUndoFile.WriteStr(const s: String);
  begin
    WriteDatatype(pufdStr);
    phObj.WriteStr(FStream, s);
  end;

   //===================================================================================================================
   // TPhoaOperation
   //===================================================================================================================

  constructor TPhoaOperation.Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
  begin
    FList := List;
    List.Add(Self);
    FPhoA := PhoA;
    FUndoDataPosition := FList.UndoFile.Position;
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

  function TPhoaOperation.GetUndoFile: TPhoaUndoFile;
  begin
    Result := FList.UndoFile;
  end;

  function TPhoaOperation.Name: String;
  begin
    Result := ConstVal(ClassName);
  end;

  procedure TPhoaOperation.RollbackChanges;
  begin
    { does nothing }
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
    try
       // ������������� undo-���� � ����������� �������
      UndoFile.BeginUndo(FUndoDataPosition);
      try
         // ���������� ���������
        RollbackChanges;
      finally
         // ���������� ������� � undo-����� �� �����
        UndoFile.EndUndo;
      end;
    finally
       // ���������� ������
      Destroy;
    end;
  end;

   //===================================================================================================================
   // TPhoaOperations
   //===================================================================================================================

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

  constructor TPhoaOperations.Create(AUndoFile: TPhoaUndoFile);
  begin
    inherited Create;
    FUndoFile := AUndoFile;
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

  function TPhoaOperations.GetItems(Index: Integer): TPhoaOperation;
  begin
    Result := TPhoaOperation(inherited Items[Index]);
  end;

  function TPhoaOperations.Remove(Item: TPhoaOperation): Integer;
  begin
    Result := inherited Remove(Item);
    if Result>=0 then begin
      DoStatusChange;
      if Assigned(FOnOpUndone) then FOnOpUndone(Self);
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

   //===================================================================================================================
   // TPhoaUndo
   //===================================================================================================================

  procedure TPhoaUndo.Clear;
  begin
    inherited Clear;
     // �������� ����
    UndoFile.Clear;
  end;

  constructor TPhoaUndo.Create;
  begin
    inherited Create(TPhoaUndoFile.Create);
    FSavepointOnEmpty := True;
  end;

  destructor TPhoaUndo.Destroy;
  var UFile: TPhoaUndoFile;
  begin
    UFile := UndoFile;
    inherited Destroy;
     // ���������� ���� ������ 
    UFile.Free;
  end;

  function TPhoaUndo.GetIsUnmodified: Boolean;
  begin
    if Count=0 then Result := FSavepointOnEmpty else Result := GetItems(Count-1).FSavepoint;
  end;

  function TPhoaUndo.GetLastOpName: String;
  begin
    if Count=0 then Result := '' else Result := GetItems(Count-1).Name;
  end;

  procedure TPhoaUndo.SetNonUndoable;
  begin
    BeginUpdate;
    try
      Clear;
      FSavepointOnEmpty := False;
    finally
      EndUpdate;
    end;
  end;

  procedure TPhoaUndo.SetSavepoint;
  var i: Integer;
  begin
    BeginUpdate;
    try
      for i := 0 to Count-1 do Items[i].FSavepoint := i=Count-1;
      FSavepointOnEmpty := Count=0;
    finally
      EndUpdate;
    end;
  end;

   //===================================================================================================================
   // TPhoaMultiOp
   //===================================================================================================================

  constructor TPhoaMultiOp.Create(List: TPhoaOperations; PhoA: TPhotoAlbum);
  begin
    inherited Create(List, PhoA);
    FOperations := TPhoaOperations.Create(List.UndoFile);
  end;

  destructor TPhoaMultiOp.Destroy;
  begin
    FOperations.Free;
    inherited Destroy;
  end;

  procedure TPhoaMultiOp.RollbackChanges;
  begin
    inherited RollbackChanges;
    FOperations.UndoAll;
  end;

   //===================================================================================================================
   // TPhoaOp_NewGroup
   //===================================================================================================================

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

  procedure TPhoaOp_GroupNew.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ������� ������ ��������
    OpGroup.Free;
  end;

   //===================================================================================================================
   // TPhoaOp_GroupRename
   //===================================================================================================================

  constructor TPhoaOp_GroupRename.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText: String);
  begin
    inherited Create(List, PhoA);
     // ���������� ������ ������
    OpGroup := Group;
    UndoFile.WriteStr(Group.Text);
     // ��������� ��������
    Group.Text := sNewText;
  end;

  procedure TPhoaOp_GroupRename.RollbackChanges;
  begin
    inherited RollbackChanges;
     // �������� ������ � ��������������� �����
    OpGroup.Text := UndoFile.ReadStr;
  end;

   //===================================================================================================================
   // TPhoaOp_GroupEdit
   //===================================================================================================================

  constructor TPhoaOp_GroupEdit.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sNewText, sNewDescription: String);
  begin
    inherited Create(List, PhoA, Group, sNewText);
     // ���������� ������ ������
    UndoFile.WriteStr(Group.Description);
     // ��������� ��������
    Group.Description := sNewDescription;
  end;

  procedure TPhoaOp_GroupEdit.RollbackChanges;
  begin
    inherited RollbackChanges;
     // �������� ������ � ��������������� ��������
    OpGroup.Description := UndoFile.ReadStr;
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDelete
   //===================================================================================================================

  constructor TPhoaOp_GroupDelete.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; bPerform: Boolean);
  var i: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������ ��������� ������
    OpGroup       := Group;
    OpParentGroup := Group.Owner;
    UndoFile.WriteStr (Group.Text);
    UndoFile.WriteStr (Group.Description);
    UndoFile.WriteInt (Group.Index);
    UndoFile.WriteBool(Group.Expanded);
     // ���������� ���������� (ID �����������)
    if Group.PicIDs.Count>0 then begin
      FPicIDs := TIntegerList.Create(False);
      FPicIDs.Assign(Group.PicIDs);
    end;
     // ���������� ������ �������� ��������� �����
    if Group.Groups.Count>0 then begin
      FCascadedDeletes := TPhoaOperations.Create(List.UndoFile);
      for i := 0 to Group.Groups.Count-1 do TPhoaOp_GroupDelete.Create(FCascadedDeletes, PhoA, Group.Groups[i], False);
    end;
     // ��������� ��������
    if bPerform then begin
       // ������� ������
      Group.Free;
       // ������� �������������� �����������
      FUnlinkedPicRemoves := TPhoaOperations.Create(List.UndoFile);
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
      uifXReinitParent, uifXReinitRecursive,  // Execution flags
      uifUReinitParent, uifUReinitRecursive]; // Undo flags
  end;

  procedure TPhoaOp_GroupDelete.InternalRollback(gOwner: TPhoaGroup);
  var
    i: Integer;
    g: TPhoaGroup;
  begin
     // ��������������� ������
    g := TPhoaGroup.Create(gOwner, OpGroupID);
    g.Text        := UndoFile.ReadStr;
    g.Description := UndoFile.ReadStr;
    g.Index       := UndoFile.ReadInt;
    g.Expanded    := UndoFile.ReadBool;
    if FPicIDs<>nil then g.PicIDs.Assign(FPicIDs);
     // ��������������� �������� �������� ������
    if FCascadedDeletes<>nil then
      for i := 0 to FCascadedDeletes.Count-1 do TPhoaOp_GroupDelete(FCascadedDeletes[i]).InternalRollback(g);
  end;

  procedure TPhoaOp_GroupDelete.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ��������������� ����� �����/�����
    InternalRollback(OpParentGroup);
     // ��������������� �������� (�����������) �����������
    if FUnlinkedPicRemoves<>nil then FUnlinkedPicRemoves.UndoAll;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicRemoving
   //===================================================================================================================

  constructor TPhoaOp_InternalPicRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic);
  begin
    inherited Create(List, PhoA);
     // ��������� ������ �����������
    UndoFile.WriteStr(Pic.RawData[PPAllProps]);
     // ��������� ��������
    Pic.Free;
  end;

  procedure TPhoaOp_InternalPicRemoving.RollbackChanges;
  var Pic: TPhoaPic;
  begin
    inherited RollbackChanges;
     // ������ ����������� � ��������� ������
    Pic := TPhoaPic.Create(FPhoA);
    try
      Pic.RawData[PPAllProps] := UndoFile.ReadStr;
      Pic.List := FPhoA.Pics; // Assign the List AFTER props have been read because List sorts pics by IDs
    except
      Pic.Free;
      raise;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicProps
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicProps.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: TPicArray; ChangeList: TPicPropertyChanges);
  var
    iPic, iChg: Integer;
    Pic: TPhoaPic;
    ChangedProps: TPicProperties;
  begin
    inherited Create(List, PhoA);
     // ��������� ����� ������������ �������
    ChangedProps := ChangeList.ChangedProps;
    UndoFile.WriteInt(PicPropsToInt(ChangedProps));
     // ��������� ���������� �����������
    UndoFile.WriteInt(Length(Pics));
     // ���� �� ������������
    for iPic := 0 to High(Pics) do begin
       // ���������� ������ ������
      Pic := Pics[iPic];
      UndoFile.WriteInt(Pic.ID);
      UndoFile.WriteStr(Pic.RawData[ChangedProps]);
       // ��������� ����� ������
      for iChg := 0 to ChangeList.Count-1 do
        with ChangeList[iChg]^ do Pic.Props[Prop] := sNewValue;
    end;
  end;

  procedure TPhoaOp_InternalEditPicProps.RollbackChanges;
  var
    i, iPicID: Integer;
    ChangedProps: TPicProperties;
    sPicData: String;
  begin
    inherited RollbackChanges;
     // �������� ����� ��������� �������
    ChangedProps := IntToPicProps(UndoFile.ReadInt);
     // ���������� ������ ��������� �����������
    for i := 0 to UndoFile.ReadInt-1 do begin
      iPicID   := UndoFile.ReadInt;
      sPicData := UndoFile.ReadStr;
      FPhoA.Pics.PicByID(iPicID).RawData[ChangedProps] := sPicData;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicKeywords
   //===================================================================================================================

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
        UndoFile.WriteBool(True); // ������� ������ ��������� ����� (� ����������������� ����-�����)
        UndoFile.WriteInt(Pic.ID);
        UndoFile.WriteStr(Pic.PicKeywords.CommaText);
        bKWSaved := True;
      end;
    end;

  begin
    inherited Create(List, PhoA);
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
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalEditPicKeywords.RollbackChanges;
  var
    iPicID: Integer;
    sKeywords: String;
  begin
    inherited RollbackChanges;
     // ���������� �� ��������� ������������: ������ ����, ���� �� �������� ����-����
    while UndoFile.ReadBool do begin
      iPicID    := UndoFile.ReadInt;
      sKeywords := UndoFile.ReadStr;
      FPhoA.Pics.PicByID(iPicID).PicKeywords.CommaText := sKeywords;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_StoreTransform
   //===================================================================================================================

  constructor TPhoaOp_StoreTransform.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: TPhoaPic; NewRotation: TPicRotation; NewFlips: TPicFlips);
  begin
    inherited Create(List, PhoA);
     // ��������� ������� ��������
    UndoFile.WriteInt(Pic.ID);
    UndoFile.WriteByte(Byte(Pic.PicRotation));
    UndoFile.WriteByte(Byte(Pic.PicFlips));
     // ��������� ����� ��������
    Pic.PicRotation := NewRotation;
    Pic.PicFlips    := NewFlips; 
  end;

  procedure TPhoaOp_StoreTransform.RollbackChanges;
  var Pic: TPhoaPic;
  begin
    inherited RollbackChanges;
    Pic             := PhoA.Pics.PicByID(UndoFile.ReadInt);
    Pic.PicRotation := TPicRotation     (UndoFile.ReadByte);
    Pic.PicFlips    := TPicFlips   (Byte(UndoFile.ReadByte)); // �������� typecast, �� ����� �� �������������
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicAdd
   //===================================================================================================================

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
          ReloadPicFileData;
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
      OpGroup := Group;
      UndoFile.WriteInt(Pic.ID);
    end else
      UndoFile.WriteInt(0);
  end;

  procedure TPhoaOp_InternalPicAdd.RollbackChanges;
  var iPicID: Integer;
  begin
    inherited RollbackChanges;
     // ���� ������� �������� ���� �������
    iPicID := UndoFile.ReadInt;
    if iPicID>0 then begin
       // ������� �� ������
      OpGroup.PicIDs.Remove(iPicID);
       // ���� ���� ��������� ����� �����������, ������� � �� �����������
      if not FExisting then FPhoA.Pics.PicByID(iPicID).Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicFromGroupRemove
   //===================================================================================================================

  constructor TPhoaOp_InternalPicFromGroupRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  var i, idx: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ���������� ID � �������
    for i := 0 to High(aPicIDs) do begin
       // ���� ���� ����� ID � ������, ���������� � �������
      idx := Group.PicIDs.IndexOf(aPicIDs[i]);
      if idx>=0 then begin
         // ����� ���� �����������
        UndoFile.WriteBool(True);
         // ����� ID
        UndoFile.WriteInt(aPicIDs[i]);
         // ����� ������
        UndoFile.WriteInt(idx);
         // ������� �����������
        Group.PicIDs.Delete(idx);
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalPicFromGroupRemoving.RollbackChanges;
  var
    i: Integer;
    g: TPhoaGroup;
    IIs: TIntegerList;
  begin
    inherited RollbackChanges;
    g := OpGroup;
     // ��������� ID � ������� �� ��������� ������
    IIs := TIntegerList.Create(True);
    try
      while UndoFile.ReadBool do begin
        IIs.Add(UndoFile.ReadInt);
        IIs.Add(UndoFile.ReadInt);
      end;
       // ��������������� ����������� � �������� �������, ����� ��� ������ �� ���� �����
      i := IIs.Count-2; // i ��������� �� ID, i+1 - �� ������
      while i>=0 do begin
        g.PicIDs.Insert(IIs[i+1], IIs[i]);
        Dec(i, 2);
      end;
    finally
      IIs.Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  constructor TPhoaOp_InternalPicToGroupAdding.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  var i: Integer;
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
     // ��������� ����������� � ������ � � undo-����
    for i := 0 to High(aPicIDs) do
      if Group.PicIDs.Add(aPicIDs[i]) then begin
        UndoFile.WriteBool(True); // ���� �����������
        UndoFile.WriteInt (aPicIDs[i]);
      end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalPicToGroupAdding.RollbackChanges;
  var g: TPhoaGroup;
  begin
    inherited RollbackChanges;
     // ������� ����������� ����������� (��������� ID ����������� ����������� �� �����, ���� �� �������� ����-����)
    g := OpGroup;
    while UndoFile.ReadBool do g.PicIDs.Remove(UndoFile.ReadInt);
  end;

   //===================================================================================================================
   // TPhoaBaseOp_PicCopy
   //===================================================================================================================

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
//!!!!!    var
//      bmp: TBitmap;
//      wFmt: Word;
//      hData: THandle;
//      hPal: HPALETTE;
    begin
//       // ������������ �����
//      bmp := TBitmap.Create;
//      try
//        Pic.PaintThumbnail(bmp);
//         // �������� bitmap � clipboard
//        bmp.SaveToClipboardFormat(wFmt, hData, hPal);
//        Clipboard.SetAsHandle(wFmt, hData);
//      finally
//        bmp.Free;
//      end;
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

   //===================================================================================================================
   // TPhoaMultiOp_PicDelete
   //===================================================================================================================

  constructor TPhoaMultiOp_PicDelete.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray);
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
     // ������� ID ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, Group, aPicIDs);
     // ������� ����������� ����������� �� �����������
    FPhoA.RemoveUnlinkedPics(FOperations);
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicPaste
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaOp_PhoAEdit
   //===================================================================================================================

  constructor TPhoaOp_PhoAEdit.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; iNewThWidth, iNewThHeight: Integer; bNewThQuality: Byte; const sNewDescription: String);
  begin
    inherited Create(List, PhoA);
    with PhoA do begin
       // ��������� ������ ��������
      UndoFile.WriteInt (ThumbnailWidth);
      UndoFile.WriteInt (ThumbnailHeight);
      UndoFile.WriteByte(ThumbnailQuality);
      UndoFile.WriteStr (Description);
       // ��������� ��������
      ThumbnailWidth   := iNewThWidth;
      ThumbnailHeight  := iNewThHeight;
      ThumbnailQuality := bNewThQuality;
      Description      := sNewDescription;
    end;
  end;

  procedure TPhoaOp_PhoAEdit.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ��������������� �������� ����������� 
    FPhoA.ThumbnailWidth   := UndoFile.ReadInt;
    FPhoA.ThumbnailHeight  := UndoFile.ReadInt;
    FPhoA.ThumbnailQuality := UndoFile.ReadByte;
    FPhoA.Description      := UndoFile.ReadStr;
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicOperation
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  constructor TPhoaOp_InternalGroupPicSort.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings);
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ���������� ������� ���������� ID ����������� � ������
    UndoWriteIntList(UndoFile, Group.PicIDs);
     // ��������� ����������� � ������
    Group.SortPics(Sortings, PhoA.Pics);
  end;

  procedure TPhoaOp_InternalGroupPicSort.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ��������������� ������ ������� ���������� ID ����������� � ������
    UndoReadIntList(UndoFile, OpGroup.PicIDs);
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicSort
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaOp_GroupDragAndDrop
   //===================================================================================================================

  constructor TPhoaOp_GroupDragAndDrop.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group, NewParentGroup: TPhoaGroup; iNewIndex: Integer);
  var gOldParent: TPhoaGroup;
  begin
    inherited Create(List, PhoA);
     // ���������� ������ ������
    gOldParent := Group.Owner;
    UndoFile.WriteInt(Group.Index);
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

  procedure TPhoaOp_GroupDragAndDrop.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ��������������� ��������� ������
    with OpGroup do begin
      Owner := OpParentGroup;
      Index := UndoFile.ReadInt;
    end;
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicDragAndDropToGroup
   //===================================================================================================================

  constructor TPhoaMultiOp_PicDragAndDropToGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; aSelPicIDs: TIDArray; bCopy: Boolean);
  begin
    inherited Create(List, PhoA);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, TargetGroup, aSelPicIDs);
    if not bCopy then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, SourceGroup, aSelPicIDs);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  constructor TPhoaOp_PicDragAndDropInsideGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const aPicIDs: TIDArray; idxNew: Integer);
  var i, idxOld: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ��������� ��������
    for i := 0 to High(aPicIDs) do begin
       // -- ����� ������� �����������
      UndoFile.WriteBool(True);
       // -- ���������� �������
      idxOld := Group.PicIDs.IndexOf(aPicIDs[i]);
      if idxOld<idxNew then Dec(idxNew);
      UndoFile.WriteInt(idxOld);
      UndoFile.WriteInt(idxNew);
       // -- ���������� ����������� �� ����� �����
      Group.PicIDs.Move(idxOld, idxNew);
      Inc(idxNew);
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_PicDragAndDropInsideGroup.RollbackChanges;
  var
    i: Integer;
    g: TPhoaGroup;
    Indexes: TIntegerList;
  begin
    inherited RollbackChanges;
    g := OpGroup;
     // ��������� ������� �� ����� �� ��������� ������
    Indexes := TIntegerList.Create(True);
    try
      while UndoFile.ReadBool do begin
        Indexes.Add(UndoFile.ReadInt);
        Indexes.Add(UndoFile.ReadInt);
      end;
       // ��������������� ����������� � �������� �������, ����� ��� ������ �� ���� �����
      i := Indexes.Count-2; // i ��������� �� ������ ������, i+1 - �� �����
      while i>=0 do begin
        g.PicIDs.Move(Indexes[i+1], Indexes[i]);
        Dec(i, 2);
      end;
    finally
      Indexes.Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_ViewNew
   //===================================================================================================================

  constructor TPhoaOp_ViewNew.Create(List: TPhoaOperations; ViewsIntf: IPhoaViews; const sName: String; Groupings: TPhoaGroupings; Sortings: TPhoaSortings);
  var
    FView: TPhoaView;
    iNewViewIndex: Integer;
  begin
    inherited Create(List, nil);
    FViewsIntf := ViewsIntf;
     // ��������� ���������� ������ �������������
    UndoFile.WriteInt(ViewsIntf.ViewIndex);
     // ��������� ��������
    FView := TPhoaView.Create(ViewsIntf.Views);
    FView.Name := sName;
    FView.Groupings.Assign(Groupings);
    FView.Sortings.Assign(Sortings);
     // ��������� ����� ������ �������������
    iNewViewIndex := ViewsIntf.Views.IndexOf(FView);
    UndoFile.WriteInt(iNewViewIndex);
     // ����������� ������
    ViewsIntf.LoadViewList(iNewViewIndex);
  end;

  procedure TPhoaOp_ViewNew.RollbackChanges;
  var iPrevViewIndex, iNewViewIndex: Integer;
  begin
    inherited RollbackChanges;
     // �������� ���������� ������
    iPrevViewIndex := UndoFile.ReadInt;
    iNewViewIndex  := UndoFile.ReadInt;
     // ������� �������������
    FViewsIntf.Views.Delete(iNewViewIndex);
     // ����������� ������ � ��������������� ������� ��������� �������������
    FViewsIntf.LoadViewList(iPrevViewIndex);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewEdit
   //===================================================================================================================

  constructor TPhoaOp_ViewEdit.Create(List: TPhoaOperations; View: TPhoaView; ViewsIntf: IPhoaViews; const sNewName: String; NewGroupings: TPhoaGroupings; NewSortings: TPhoaSortings);
  var bWriteGroupings, bWriteSortings: Boolean;
  begin
    inherited Create(List, nil);
     // ��������� ������ ������ � ��������� ���������
    FViewsIntf := ViewsIntf;
    UndoFile.WriteStr(View.Name);
    View.Name := sNewName;
     // ����������������� ������
    ViewsIntf.Views.Sort;
     // ���������� ����� ������ �������������
    UndoFile.WriteInt(View.Index);
     // -- ������ ����������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    bWriteGroupings := (NewGroupings<>nil) and not View.Groupings.IdenticalWith(NewGroupings);
    UndoFile.WriteBool(bWriteGroupings); // ������� ������� �����������
    if bWriteGroupings then begin
      UndoWriteGroupings(UndoFile, View.Groupings);
      View.Groupings.Assign(NewGroupings);
       // -- Invalidate view's groups
      View.UnprocessGroups;
    end;
     // -- ������ ���������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    bWriteSortings := (NewSortings<>nil) and not View.Sortings.IdenticalWith(NewSortings);
    UndoFile.WriteBool(bWriteSortings); // ������� ������� ����������
    if bWriteSortings then begin
      UndoWriteSortings(UndoFile, View.Sortings);
      View.Sortings.Assign(NewSortings);
       // -- Invalidate view's groups
      View.UnprocessGroups;
    end;
     // ����������� ������
    ViewsIntf.LoadViewList(View.Index);
  end;

  procedure TPhoaOp_ViewEdit.RollbackChanges;
  var
    sViewName: String;
    iViewIndex: Integer;
    View: TPhoaView;
  begin
    inherited RollbackChanges;
     // ��������������� �������������
    sViewName  := UndoFile.ReadStr;
    iViewIndex := UndoFile.ReadInt;
    View := FViewsIntf.Views[iViewIndex];
    View.Name := sViewName;
    if UndoFile.ReadBool then UndoReadGroupings(UndoFile, View.Groupings);
    if UndoFile.ReadBool then UndoReadSortings(UndoFile,  View.Sortings);
    View.UnprocessGroups;
     // ����������������� ������ (����� ����� ����� �������� �� ��������� ������������� � ������)
    FViewsIntf.Views.Sort;
     // ����������� ������
    FViewsIntf.LoadViewList(View.Index);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewDelete
   //===================================================================================================================

  constructor TPhoaOp_ViewDelete.Create(List: TPhoaOperations; ViewsIntf: IPhoaViews);
  begin
    inherited Create(List, nil);
     // ��������� ������ ������
    FViewsIntf := ViewsIntf;
    with ViewsIntf.Views[ViewsIntf.ViewIndex] do begin
      UndoFile.WriteStr(Name);
      UndoWriteGroupings(UndoFile, Groupings);
      UndoWriteSortings (UndoFile, Sortings);
    end;
     // ������� �������������
    ViewsIntf.Views.Delete(ViewsIntf.ViewIndex);
     // ����������� ������
    ViewsIntf.LoadViewList(-1);
  end;

  procedure TPhoaOp_ViewDelete.RollbackChanges;
  var View: TPhoaView;
  begin
    inherited RollbackChanges;
     // ������ �������������
    View := TPhoaView.Create(FViewsIntf.Views);
    View.Name := UndoFile.ReadStr;
    UndoReadGroupings(UndoFile, View.Groupings);
    UndoReadSortings (UndoFile, View.Sortings);
     // ����������������� ������
    FViewsIntf.Views.Sort;
     // ����������� ������
    FViewsIntf.LoadViewList(View.Index);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewMakeGroup
   //===================================================================================================================

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

  procedure TPhoaOp_ViewMakeGroup.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ������� �������� ������ ����� �������������
    OpGroup.Free;
     // ��������� ������ �����
    FViewsIntf.ViewIndex := -1;
  end;

   //===================================================================================================================
   // TFileList
   //===================================================================================================================

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

   //===================================================================================================================
   // TKeywordList
   //===================================================================================================================

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

   //===================================================================================================================
   // TPhoaMask
   //===================================================================================================================

  constructor TPhoaMask.Create(const sMask: String; bNegative: Boolean);
  begin
    inherited Create(sMask);
    FNegative := bNegative;
  end;

  function TPhoaMask.Matches(const sFilename: String): Boolean;
  begin
    Result := inherited Matches(sFilename) xor FNegative;
  end;

   //===================================================================================================================
   // TPhoaMasks
   //===================================================================================================================

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

end.
