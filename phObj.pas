//**********************************************************************************************************************
//  $Id: phObj.pas,v 1.43 2004-10-06 15:28:52 dale Exp $
//===================================================================================================================---
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phObj;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Masks, ConsVars, phPhoa, phIntf, phMutableIntf;

type
   //===================================================================================================================
   // IPhotoAlbumPic - ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPics = interface;

  IPhotoAlbumPic = interface(IPhoaMutablePic)
    ['{AE945E5F-9BF1-4FD0-92C9-92716D7BB631}']
     // �������� ��� ������ �����������
    procedure Assign(SrcPic: IPhotoAlbumPic);
     // ������������� ������ NewList � �������� ���������. ��� bAllocateNewID=True ����� ������������ ����������� �����
     //    ID, ���������� � ������
    procedure PutToList(NewList: IPhotoAlbumPics; bAllocateNewID: Boolean);
     // ������� ����������� �� ������ (����� ����� ��� ������ ������������, ���� �� ���� ������ ��� ������)
    procedure Release;
     // ��������/���������� � ������� Streamer
     //   -- �������� bEx...Relative ������������, ������������ �� �������������� �������������� <-> ����������� ����
     //      � ����� �����������
     //   -- �������� PProps ���������, ����� �������� ��������� � ��������������� (��� ���� ��� ���������� ������,
     //      ��������� � ������������, �.�. � ������, ����������� ������ ��� ������� ppFileName in PProps)
    procedure StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
    procedure StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);
     // ���������� ��������� �������� � �� �������� �� ���������
    procedure CleanupProps(Props: TPicProperties);
     // ���������� �������� ����������� �� ������� Props, ������� ������ ��������� ������.
     //   ���� ������ sNameValSep, �� ������� ����� ������������ �������, �������� ��� �� �������� ���� �������.
     //   sPropSep - �������������� ������ ����� ���������� ����������
    function  GetPropStrs(Props: TPicProperties; const sNameValSep, sPropSep: String): String;
     // Prop handlers
    function  GetKeywordList: TStrings; 
    function  GetList: IPhotoAlbumPics;
    function  GetProps(PicProp: TPicProperty): String;
    function  GetRawData(PProps: TPicProperties): String;
    procedure SetProps(PicProp: TPicProperty; const Value: String);
    procedure SetRawData(PProps: TPicProperties; const Value: String);
     // Props
     // -- �������� ���� �����������
    property KeywordList: TStrings read GetKeywordList; 
     // -- ������-�������� �����������
    property List: IPhotoAlbumPics read GetList;
     // -- �������� ����������� �� �������
    property Props[PicProp: TPicProperty]: String read GetProps write SetProps;
     // -- �������� ������ ����������� (��������, ��������� � PProps)
    property RawData[PProps: TPicProperties]: String read GetRawData write SetRawData;
  end;

   //===================================================================================================================
   // IPhotoAlbumPics - ������������� �� ID ������ ����������� �����������
   //===================================================================================================================

  TPhotoAlbum = class;

  IPhotoAlbumPics = interface(IPhoaMutablePicList)
    ['{AE945E5F-9BF1-4FD0-92C9-92716D7BB632}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ������ ������ ����� ����������� � Src (�������, �������� ������� ������ ��� ������)
    procedure DuplicatePics(PicList: IPhoaPicList);
     // Prop handlers
    function  GetPhoA: TPhotoAlbum;
     // Props
     // -- ����������-��������
    property PhoA: TPhotoAlbum read GetPhoA;
  end;

   //===================================================================================================================
   // ������ Integer'��
   //===================================================================================================================

  TIntegerList = class(TList)
  private
     // Prop storage
    FAllowDuplicates: Boolean;
     // Prop handlers
    function  GetItems(Index: Integer): Integer;
  public
    constructor Create(bAllowDuplicates: Boolean);
     // ���� ����� �� ���� � ������ ��� ��������� ���������, ��������� ��� � ���������� True, ����� ���������� False
    function  Add(i: Integer): Boolean;
     // ���� ����� �� ���� � ������ ��� ��������� ���������, ��������� ��� � ���������� True, ����� ���������� False
    function  Insert(Index, i: Integer): Boolean;
     // ���� ����� ���� � ������, ������� ��� � ���������� ��� ������� ������, ����� ���������� -1
    function  Remove(i: Integer): Integer;
     // ���������� ������ ����� ��� -1, ���� ������ ���
    function  IndexOf(i: Integer): Integer;
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
    FMaxPicID: Integer;
     // IPhoaPicList
    function  IndexOfID(iID: Integer): Integer; stdcall;
    function  IndexOfFileName(pcFileName: PAnsiChar): Integer; stdcall;
    function  GetCount: Integer; stdcall;
    function  GetItemsByID(iID: Integer): IPhoaPic; stdcall;
    function  GetItemsByFileName(pcFileName: PAnsiChar): IPhoaPic; stdcall;
    function  GetItems(Index: Integer): IPhoaPic; stdcall;
    function  GetMaxPicID: Integer; stdcall;
     // IPhoaMutablePicList
    function  Add(Pic: IPhoaPic; bSkipDuplicates: Boolean): Integer; overload; stdcall;
    function  Add(Pic: IPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer; overload; stdcall;
    function  Add(PicList: IPhoaPicList; bSkipDuplicates: Boolean): Integer; overload; stdcall;
    function  Insert(Index: Integer; Pic: IPhoaPic; bSkipDuplicates: Boolean): Boolean; stdcall;
    function  FindID(iID: Integer; var Index: Integer): Boolean; stdcall;
    function  GetSorted: Boolean; stdcall;
    function  Remove(iID: Integer): Integer; stdcall;
    procedure Assign(Source: IPhoaPicList); stdcall;
    procedure Clear; stdcall;
    procedure CustomSort(CompareFunc: TPhoaPicListSortCompareFunc; dwData: Cardinal); stdcall;
    procedure Move(iCurIndex, iNewIndex: Integer); stdcall;
    procedure Delete(Index: Integer); stdcall;
  public
     // �����������. ��� bSorted ������ �������� ������������� �� ID �����������
    constructor Create(bSorted: Boolean);
    destructor Destroy; override;
     // Props (��� ������������� � ��������)
    property Count: Integer read GetCount;
    property ItemsByID[iID: Integer]: IPhoaPic read GetItemsByID;
    property ItemsByFileName[pcFileName: PAnsiChar]: IPhoaPic read GetItemsByFileName;
    property Items[Index: Integer]: IPhoaPic read GetItems; default;
    property MaxPicID: Integer read FMaxPicID;
    property Sorted: Boolean read FSorted;
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
    function  SortComparePics(Pic1, Pic2: IPhoaPic): Integer;
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

  TPhoaGroups = class;
   
  PPhoaGroup = ^TPhoaGroup;
  TPhoaGroup = class(TObject)
  private
     // ID ����������� � ������ ��� �������� �� Streamer-a (���������� ������ ����� �������� StreamerLoad � Loaded)
    FStreamerPicIDs: TIntegerList;
     // Prop storage
    FExpanded: Boolean;
    FText: String;
    FGroups: TPhoaGroups;
    FOwner: TPhoaGroup;
    FPics: IPhoaMutablePicList;
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
     // ���������� ����� �������� �������� ����� �� Streamer-�
    procedure Loaded(PhoA: TPhotoAlbum);
     // ���������� True, ���� ID ����������� ������������ � ������ ������ (��� ����� � ��������� ��� bRecursive=True)
    function  IsPicLinked(iID: Integer; bRecursive: Boolean): Boolean;
     // �������� �������� ������: ������������, Expanded;
     //   ��� bCopyIDs=True       - ����� � ID
     //   ��� bCopyPicIDs=True    - ����� ������ ID �����������;
     //   ��� bCopySubgroups=True - ���������� ��������� �� ��� ��������� �����
    procedure Assign(Src: TPhoaGroup; bCopyIDs, bCopyPics, bCopySubgroups: Boolean);
     // ��������� ����������� �� �������� �����������
    procedure SortPics(Sortings: TPhoaSortings);
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
     // -- ������ �����������, �������� � ������
    property Pics: IPhoaMutablePicList read FPics;
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
  TPhoaPic = class(TInterfacedObject, IPhoaPic, IPhoaMutablePic, IPhotoAlbumPic)
  private
     // Prop storage
    FList: Pointer;
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
    function  IPhoaPic.GetHandle            = IPP_GetHandle;
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
    function  IPP_GetHandle: TPhoaHandle; stdcall;
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
     // IPhoaMutablePic
    function  IPhoaMutablePic.GetID                = IPP_GetID;               
    function  IPhoaMutablePic.GetAuthor            = IPP_GetAuthor;
    function  IPhoaMutablePic.GetDate              = IPP_GetDate;
    function  IPhoaMutablePic.GetTime              = IPP_GetTime;
    function  IPhoaMutablePic.GetDescription       = IPP_GetDescription;
    function  IPhoaMutablePic.GetFileName          = IPP_GetFileName;
    function  IPhoaMutablePic.GetFileSize          = IPP_GetFileSize;
    function  IPhoaMutablePic.GetFilmNumber        = IPP_GetFilmNumber;
    function  IPhoaMutablePic.GetFlips             = IPP_GetFlips;
    function  IPhoaMutablePic.GetFrameNumber       = IPP_GetFrameNumber;
    function  IPhoaMutablePic.GetHandle            = IPP_GetHandle;
    function  IPhoaMutablePic.GetImageSize         = IPP_GetImageSize;
    function  IPhoaMutablePic.GetKeywords          = IPP_GetKeywords;
    function  IPhoaMutablePic.GetMedia             = IPP_GetMedia;
    function  IPhoaMutablePic.GetNotes             = IPP_GetNotes;
    function  IPhoaMutablePic.GetPlace             = IPP_GetPlace;
    function  IPhoaMutablePic.GetPropertyValue     = IPP_GetPropertyValue;
    function  IPhoaMutablePic.GetRotation          = IPP_GetRotation;
    function  IPhoaMutablePic.GetThumbnailSize     = IPP_GetThumbnailSize;
    function  IPhoaMutablePic.GetThumbnailData     = IPP_GetThumbnailData;
    function  IPhoaMutablePic.GetThumbnailDataSize = IPP_GetThumbnailDataSize;
    procedure IPhoaMutablePic.ReloadPicFileData    = IPMP_ReloadPicFileData;
    procedure IPhoaMutablePic.SetFileName          = IPMP_SetFileName;
    procedure IPhoaMutablePic.SetFlips             = IPMP_SetFlips;
    procedure IPhoaMutablePic.SetRotation          = IPMP_SetRotation;
    procedure IPMP_ReloadPicFileData; stdcall;
    procedure IPMP_SetFileName(Value: PAnsiChar); stdcall;
    procedure IPMP_SetFlips(Value: TPicFlips); stdcall;
    procedure IPMP_SetRotation(Value: TPicRotation); stdcall;
     // IPhotoAlbumPic
    procedure IPhotoAlbumPic.ReloadPicFileData    = IPMP_ReloadPicFileData;
    procedure IPhotoAlbumPic.SetFileName          = IPMP_SetFileName;
    procedure IPhotoAlbumPic.SetFlips             = IPMP_SetFlips;
    procedure IPhotoAlbumPic.SetRotation          = IPMP_SetRotation;
    function  IPhotoAlbumPic.GetID                = IPP_GetID;
    function  IPhotoAlbumPic.GetAuthor            = IPP_GetAuthor;
    function  IPhotoAlbumPic.GetDate              = IPP_GetDate;
    function  IPhotoAlbumPic.GetTime              = IPP_GetTime;
    function  IPhotoAlbumPic.GetDescription       = IPP_GetDescription;
    function  IPhotoAlbumPic.GetFileName          = IPP_GetFileName;
    function  IPhotoAlbumPic.GetFileSize          = IPP_GetFileSize;
    function  IPhotoAlbumPic.GetFilmNumber        = IPP_GetFilmNumber;
    function  IPhotoAlbumPic.GetFlips             = IPP_GetFlips;
    function  IPhotoAlbumPic.GetFrameNumber       = IPP_GetFrameNumber;
    function  IPhotoAlbumPic.GetHandle            = IPP_GetHandle;
    function  IPhotoAlbumPic.GetImageSize         = IPP_GetImageSize;
    function  IPhotoAlbumPic.GetKeywords          = IPP_GetKeywords;
    function  IPhotoAlbumPic.GetMedia             = IPP_GetMedia;
    function  IPhotoAlbumPic.GetNotes             = IPP_GetNotes;
    function  IPhotoAlbumPic.GetPlace             = IPP_GetPlace;
    function  IPhotoAlbumPic.GetPropertyValue     = IPP_GetPropertyValue;
    function  IPhotoAlbumPic.GetRotation          = IPP_GetRotation;
    function  IPhotoAlbumPic.GetThumbnailSize     = IPP_GetThumbnailSize;
    function  IPhotoAlbumPic.GetThumbnailData     = IPP_GetThumbnailData;
    function  IPhotoAlbumPic.GetThumbnailDataSize = IPP_GetThumbnailDataSize;
    procedure IPhotoAlbumPic.Assign               = IPAP_Assign;
    function  IPhotoAlbumPic.GetPropStrs          = IPAP_GetPropStrs;
    function  IPhotoAlbumPic.GetKeywordList       = IPAP_GetKeywordList;
    function  IPhotoAlbumPic.GetList              = IPAP_GetList;
    function  IPhotoAlbumPic.GetProps             = IPAP_GetProps;
    procedure IPhotoAlbumPic.SetProps             = IPAP_SetProps;
    function  IPhotoAlbumPic.GetRawData           = IPAP_GetRawData;
    procedure IPhotoAlbumPic.SetRawData           = IPAP_SetRawData;
    procedure IPhotoAlbumPic.PutToList            = IPAP_PutToList;
    procedure IPhotoAlbumPic.Release              = IPAP_Release;
    procedure IPhotoAlbumPic.CleanupProps         = IPAP_CleanupProps;
    procedure IPhotoAlbumPic.StreamerLoad         = IPAP_StreamerLoad;
    procedure IPhotoAlbumPic.StreamerSave         = IPAP_StreamerSave;
    procedure IPAP_Assign(SrcPic: IPhotoAlbumPic);
    function  IPAP_GetPropStrs(Props: TPicProperties; const sNameValSep, sPropSep: String): String;
    function  IPAP_GetKeywordList: TStrings;
    function  IPAP_GetList: IPhotoAlbumPics;
    function  IPAP_GetProps(PicProp: TPicProperty): String;
    procedure IPAP_SetProps(PicProp: TPicProperty; const Value: String);
    function  IPAP_GetRawData(PProps: TPicProperties): String;
    procedure IPAP_SetRawData(PProps: TPicProperties; const Value: String);
    procedure IPAP_PutToList(NewList: IPhotoAlbumPics; bAllocateNewID: Boolean);
    procedure IPAP_Release;
    procedure IPAP_CleanupProps(Props: TPicProperties);
    procedure IPAP_StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
    procedure IPAP_StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);
  public
    constructor Create;
    destructor Destroy; override;
     // Props
     // -- ���������� �������������
    property ID: Integer read FID;
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
     // -- �������� ������ ������
    property ThumbHeight: Integer read FThumbHeight;
     // -- �������� JPEG-������ ������
    property ThumbnailData: String read FThumbnailData;
     // -- �������� ������ ������
    property ThumbWidth: Integer read FThumbWidth;
  end;

   //===================================================================================================================
   // TPhotoAlbumPics - ���������� IPhotoAlbumPics
   //===================================================================================================================

  TPhotoAlbumPics = class(TPhoAMutablePicList, IPhotoAlbumPics)
  private
     // Prop storage
    FPhoA: TPhotoAlbum;
     // IPhotoAlbumPics
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
    procedure DuplicatePics(PicList: IPhoaPicList);
    function  GetPhoA: TPhotoAlbum;
  public
    constructor Create(APhoA: TPhotoAlbum);
  end;

   //===================================================================================================================
   // �������������
   //===================================================================================================================

  TPhoaViews = class;

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
    function  SortComparePics(Pic1, Pic2: IPhoaPic): Integer;
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
    FPics: IPhotoAlbumPics;
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
    property Pics: IPhotoAlbumPics read FPics;
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
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: IPhotoAlbumPic);
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
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: IPhoaPicList; ChangeList: TPicPropertyChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //===================================================================================================================

  TKeywordList = class;

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: IPhoaPicList; Keywords: TKeywordList);
  end;

   //===================================================================================================================
   // �������� ���������� �������������� �����������
   //===================================================================================================================

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips);
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
    procedure RegisterPic(Group: TPhoaGroup; Pic: IPhoaPic);
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sFilename: String); overload;
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pic: IPhoaPic); overload;
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
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
  end;

   //===================================================================================================================
   // �������� ����������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaBaseOp_PicCopy = class(TBaseOperation)
    constructor Create(Pics: IPhoaPicList);
  end;

   //===================================================================================================================
   // �������� ��������/��������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaMultiOp_PicDelete = class(TPhoaMultiOp)
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
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
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation);
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
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; Pics: IPhoaPicList; bCopy: Boolean);
  end;

   //===================================================================================================================
   // �������� �������������� (������������������) ����������� ������ ������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList; idxNew: Integer);
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
  TKeywordIsPicSelectedProc = procedure(Pic: IPhoaPic; out bSelected: Boolean) of object;

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
  SPhObjErrMsg_InvalidSortedPicListMethodCall = 'Cannot invoke %s on sorted TPhoaMutablePicList';
  SPhObjErrMsg_InvalidAddPicID                = 'Invalid picture to add ID (%d)';

  SCmdLineErrMsg_UnknownKey                   = 'Unknown command line key: "%s"';
  SCmdLineErrMsg_DuplicateKey                 = 'Duplicate key "%s" in the command line';
  SCmdLineErrMsg_KeyNameInvalid               = 'Key name invalid in the command line ("%s")';
  SCmdLineErrMsg_DuplicateOpenPhoaValue       = 'Duplicate .phoa file to open specified in the command line';
  SCmdLineErrMsg_DuplicateKeyValue            = 'Duplicate value for key "%s" specified in the command line';
  SCmdLineErrMsg_KeyValueMissing              = 'Value for key "%s" is missing in the command line';

   //===================================================================================================================

   // ��������� � TStrings �����, ������ ����� � ������� �� ����������� �����������
  procedure StringsLoadPFAM(PhoA: TPhotoAlbum; SLPlaces, SLFilmNumbers, SLAuthors, SLMedia: TStrings);

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
          AddStr(SLPlaces,      Place);
          AddStr(SLFilmNumbers, FilmNumber);
          AddStr(SLAuthors,     Author);
          AddStr(SLMedia,       Media);
        end;
    finally
      SLPlaces.EndUpdate;
      SLFilmNumbers.EndUpdate;
      SLAuthors.EndUpdate;
      SLMedia.EndUpdate;
    end;
  end;

   //===================================================================================================================
   // TIntegerList
   //===================================================================================================================

  function TIntegerList.Add(i: Integer): Boolean;
  begin
    Result := FAllowDuplicates or (IndexOf(i)<0);
    if Result then inherited Add(Pointer(i));
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

   //===================================================================================================================
   // TPhoaMutablePicList
   //===================================================================================================================

  function TPhoaMutablePicList.Add(Pic: IPhoaPic; bSkipDuplicates: Boolean): Integer;
  var bDummy: Boolean;
  begin
    Result := Add(Pic, bSkipDuplicates, bDummy);
  end;

  function TPhoaMutablePicList.Add(Pic: IPhoaPic; bSkipDuplicates: Boolean; out bAdded: Boolean): Integer;
  var iID: Integer;
  begin
    iID := Pic.ID;
    if iID<=0 then PhoaException(SPhObjErrMsg_InvalidAddPicID, [iID]);
    if FSorted or bSkipDuplicates then begin
      bAdded := not FindID(iID, Result);
      if bAdded then FList.Insert(Result, Pic);
    end else begin
      bAdded := True;
      Result := FList.Add(Pic);
    end;
    if bAdded and (iID>FMaxPicID) then FMaxPicID := iID;
  end;

  function TPhoaMutablePicList.Add(PicList: IPhoaPicList; bSkipDuplicates: Boolean): Integer;
  var
    bAdded: Boolean;
    i: Integer;
  begin
    Result := 0;
    for i := 0 to PicList.Count-1 do begin
      Add(PicList[i], bSkipDuplicates, bAdded);
      if bAdded then Inc(Result);
    end;
  end;

  procedure TPhoaMutablePicList.Assign(Source: IPhoaPicList);
  var i: Integer;
  begin
    Clear;
    for i := 0 to Source.Count-1 do FList.Add(Source[i]);
    FMaxPicID := Source.MaxPicID;
  end;

  procedure TPhoaMutablePicList.Clear;
  begin
    FList.Clear;
    FMaxPicID := 0;
  end;

  constructor TPhoaMutablePicList.Create(bSorted: Boolean);
  begin
    inherited Create;
    FSorted := bSorted;
    FList := TInterfaceList.Create;
  end;

  procedure TPhoaMutablePicList.CustomSort(CompareFunc: TPhoaPicListSortCompareFunc; dwData: Cardinal);

    procedure QuickSort(iL, iR: Integer);
    var
      i1, i2: Integer;
      p: IPhoaPic;
    begin
      repeat
        i1 := iL;
        i2 := iR;
        p := GetItems((iL+iR) shr 1);
        repeat
          while CompareFunc(GetItems(i1), p, dwData)<0 do Inc(i1);
          while CompareFunc(GetItems(i2), p, dwData)>0 do Dec(i2);
          if i1<=i2 then begin
            FList.Exchange(i1, i2);
            Inc(i1);
            Dec(i2);
          end;
        until i1>i2;
        if iL<i2 then QuickSort(iL, i2);
        iL := i1;
      until i1>=iR;
    end;

  begin
    if FSorted then PhoaException(SPhObjErrMsg_InvalidSortedPicListMethodCall, ['CustomSort']);
    if FList.Count>0 then QuickSort(0, FList.Count-1);
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

  function TPhoaMutablePicList.GetMaxPicID: Integer;
  begin
    Result := FMaxPicID;
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

  function TPhoaMutablePicList.Insert(Index: Integer; Pic: IPhoaPic; bSkipDuplicates: Boolean): Boolean;
  begin
    if FSorted then PhoaException(SPhObjErrMsg_InvalidSortedPicListMethodCall, ['Insert']);
    Result := not bSkipDuplicates or (IndexOfID(Pic.ID)<0);
    if Result then FList.Insert(Index, Pic);
  end;

  procedure TPhoaMutablePicList.Move(iCurIndex, iNewIndex: Integer);
  var Pic: IPhoaPic;
  begin
    if FSorted then PhoaException(SPhObjErrMsg_InvalidSortedPicListMethodCall, ['Move']);
    Pic := GetItems(iCurIndex);
    FList.Delete(iCurIndex);
    FList.Insert(iNewIndex, Pic);
  end;

  function TPhoaMutablePicList.Remove(iID: Integer): Integer;
  begin
    if FindID(iID, Result) then FList.Delete(Result) else Result := -1;
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

  function TPhoaSortings.SortComparePics(Pic1, Pic2: IPhoaPic): Integer;
  var
    i: Integer;
    ps: TPhoaSorting;
  begin
    Result := 0;
    for i := 0 to Count-1 do begin
      ps := GetItems(i);
      case ps.Prop of
        ppID:              Result := Pic1.ID-Pic2.ID;
        ppFileName:        Result := AnsiCompareText(ExtractFileName(Pic1.FileName), ExtractFileName(Pic2.FileName));
        ppFullFileName:    Result := AnsiCompareText(Pic1.FileName, Pic2.FileName);
        ppFilePath:        Result := AnsiCompareText(ExtractFilePath(Pic1.FileName), ExtractFilePath(Pic2.FileName));
        ppFileSize,
          ppFileSizeBytes: Result := Pic1.FileSize-Pic2.FileSize;
        ppPicWidth:        Result := Pic1.ImageSize.cx-Pic2.ImageSize.cx;
        ppPicHeight:       Result := Pic1.ImageSize.cy-Pic2.ImageSize.cy;
        ppPicDims:         Result := (Pic1.ImageSize.cx*Pic1.ImageSize.cy)-(Pic2.ImageSize.cx*Pic2.ImageSize.cy);
        ppFormat:          Result := Byte(TPhoaPic(Pic1.Handle).PicFormat)-Byte(TPhoaPic(Pic2.Handle).PicFormat);
        ppDate:            Result := Pic1.Date-Pic2.Date;
        ppTime:            Result := Pic1.Time-Pic2.Time;
        ppPlace:           Result := AnsiCompareText(Pic1.Place,       Pic2.Place);
        ppFilmNumber:      Result := AnsiCompareText(Pic1.FilmNumber,  Pic2.FilmNumber);
        ppFrameNumber:     Result := AnsiCompareText(Pic1.FrameNumber, Pic2.FrameNumber);
        ppAuthor:          Result := AnsiCompareText(Pic1.Author,      Pic2.Author);
        ppDescription:     Result := AnsiCompareText(Pic1.Description, Pic2.Description);
        ppNotes:           Result := AnsiCompareText(Pic1.Notes,       Pic2.Notes);
        ppMedia:           Result := AnsiCompareText(Pic1.Media,       Pic2.Media);
        ppKeywords:        Result := AnsiCompareText(Pic1.Keywords,    Pic2.Keywords);
        ppRotation:        Result := Ord(Pic1.Rotation)-Ord(Pic2.Rotation);
        ppFlips:           Result := Byte(Pic1.Flips)-Byte(Pic2.Flips);
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

  function PhoaGroupPicSortCompare(Pic1, Pic2: IPhoaPic; dwData: Cardinal): Integer; stdcall;
  begin
    Result := TPhoaSortings(dwData).SortComparePics(Pic1, Pic2);
  end;

  procedure TPhoaGroup.Assign(Src: TPhoaGroup; bCopyIDs, bCopyPics, bCopySubgroups: Boolean);
  var i: Integer;
  begin
    if bCopyIDs then FID := Src.FID;
    FText        := Src.FText;
    FDescription := Src.FDescription;
    FExpanded    := Src.FExpanded;
     // �������� ������ ID �����������
    if bCopyPics then FPics.Assign(Src.FPics);
     // �������� ���������� ������
    if bCopySubgroups then begin
      FGroups.Clear;
      for i := 0 to Src.FGroups.Count-1 do TPhoaGroup.Create(Self, 0).Assign(Src.FGroups[i], bCopyIDs, bCopyPics, True);
    end;
  end;

  constructor TPhoaGroup.Create(_Owner: TPhoaGroup; iID: Integer);
  begin
    inherited Create;
    FGroups := TPhoaGroups.Create(Self);
    FPics   := TPhoaMutablePicList.Create(False);
    Owner   := _Owner;
    FID     := iID;
  end;

  destructor TPhoaGroup.Destroy;
  begin
    Owner := nil;
    FStreamerPicIDs.Free;
    FGroups.Free;
    FPics := nil;
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
      gpPicCount:    Result := IntToStrPositive(FPics.Count);
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
    Result := FPics.IndexOfID(iID)>=0;
    if bRecursive then begin
      i := 0;
      while not Result and (i<FGroups.Count) do begin
        Result := FGroups[i].IsPicLinked(iID, True);
        Inc(i);
      end;
    end;
  end;

  procedure TPhoaGroup.Loaded(PhoA: TPhotoAlbum);
  var
    i: Integer;
    Pic: IPhoaPic;
  begin
     // ���� �������� ������ - ��������� ���������� ID �������, ��� �� ������� (�����, ���� ���������� ������� �������
     //   PhoA ������ 1.1.5)
    if FOwner=nil then FixupIDs;
     // ���������� ID ����������� � ������ �� �����������
    if FStreamerPicIDs<>nil then begin
      for i := 0 to FStreamerPicIDs.Count-1 do begin
        Pic := PhoA.Pics.ItemsByID[FStreamerPicIDs[i]];
        if Pic<>nil then FPics.Add(Pic, False);
      end;
       // ������� ������ ID ����������� ��� ��������
      FreeAndNil(FStreamerPicIDs);
    end;
     // ���������� �������� ��� ���������� �����
    for i := 0 to FGroups.Count-1 do FGroups[i].Loaded(PhoA);
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

  procedure TPhoaGroup.SortPics(Sortings: TPhoaSortings);
  begin
    FPics.CustomSort(PhoaGroupPicSortCompare, Cardinal(Sortings));
  end;

  procedure TPhoaGroup.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i, iPicCount: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
     // ������� ������ ���������� �����
    FGroups.Clear; 
     // ������� ������ �����������
    FPics.Clear;
    FreeAndNil(FStreamerPicIDs);
     // *** Old format
    if not Streamer.Chunked then begin
       // Read group properties
      FText     := Streamer.ReadStringI;
      FExpanded := Streamer.ReadByte<>0;
       // Read picture IDs
      iPicCount := Streamer.ReadInt;
      if iPicCount>0 then begin
        FStreamerPicIDs := TIntegerList.Create(False);
        for i := 0 to iPicCount-1 do FStreamerPicIDs.Add(Streamer.ReadInt);
      end;
       // Read nested groups
      FGroups.StreamerLoad(Streamer);
     // *** New format
    end else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // Group properties
          IPhChunk_Group_ID:          FID          := vValue;
          IPhChunk_Group_Text:        FText        := vValue;
          IPhChunk_Group_Expanded:    FExpanded    := vValue<>Byte(0);
          IPhChunk_Group_Description: FDescription := vValue;
           // Picture IDs
          IPhChunk_GroupPics_Open:
            while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
              case Code of
                 // Picture ID
                IPhChunk_GroupPic_ID: begin
                  if FStreamerPicIDs=nil then FStreamerPicIDs := TIntegerList.Create(False);
                  FStreamerPicIDs.Add(vValue);
                end;
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
     // *** Old format
    if not Streamer.Chunked then begin
       // Write group properties
      Streamer.WriteStringI(FText);
      Streamer.WriteByte   (Byte(FExpanded));
       // Write picture IDs
      Streamer.WriteInt    (FPics.Count);
      for i := 0 to FPics.Count-1 do Streamer.WriteInt(FPics[i].ID);
       // Write nested groups
      FGroups.StreamerSave(Streamer);
     // *** New format
    end else begin
       // Write open-chunk
      Streamer.WriteChunk(IPhChunk_Group_Open);
       // Write group props
      Streamer.WriteChunkInt   (IPhChunk_Group_ID,          FID);
      Streamer.WriteChunkString(IPhChunk_Group_Text,        FText);
      Streamer.WriteChunkByte  (IPhChunk_Group_Expanded,    Byte(FExpanded));
      Streamer.WriteChunkString(IPhChunk_Group_Description, FDescription);
       // Write picture IDs
      Streamer.WriteChunk(IPhChunk_GroupPics_Open);
      for i := 0 to FPics.Count-1 do Streamer.WriteChunkInt(IPhChunk_GroupPic_ID, FPics[i].ID);
      Streamer.WriteChunk(IPhChunk_GroupPics_Close);
       // Write nested groups
      FGroups.StreamerSave(Streamer);
       // Write close-chunk
      Streamer.WriteChunk(IPhChunk_Group_Close);
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
     // *** Old format
    if not Streamer.Chunked then
       // Read nested groups
      for i := 0 to Streamer.ReadInt-1 do TPhoaGroup.Create(FOwner, 0).StreamerLoad(Streamer)
     // *** New format
    else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
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

  constructor TPhoaPic.Create;
  begin
    inherited Create;
    FPicKeywords := TStringList.Create;
    TStringList(FPicKeywords).Sorted     := True;
    TStringList(FPicKeywords).Duplicates := dupIgnore;
    FPicFormat := pfCustom;
  end;

  destructor TPhoaPic.Destroy;
  begin
    FPicKeywords.Free;
    inherited Destroy;
  end;

  procedure TPhoaPic.IPAP_Assign(SrcPic: IPhotoAlbumPic);
  begin
    FID             := SrcPic.ID;
    FPicAuthor      := SrcPic.Author;
    FPicDateTime    := PhoaDateToDate(SrcPic.Date)+PhoaTimeToTime(SrcPic.Time);
    FPicDesc        := SrcPic.Description;
    FPicFileName    := SrcPic.FileName;
    FPicFileSize    := SrcPic.FileSize;
    FPicFilmNumber  := SrcPic.FilmNumber;
//!!!    FPicFormat      := SrcPic.PicFormat;
    FPicFrameNumber := SrcPic.FrameNumber;
    FPicKeywords.Assign(SrcPic.KeywordList);
    FPicNotes       := SrcPic.Notes;
    FPicPlace       := SrcPic.Place;
//!!! Rotation? Flips? ...    
    SetString(FThumbnailData, PChar(SrcPic.ThumbnailData), SrcPic.ThumbnailDataSize);
  end;

  procedure TPhoaPic.IPAP_CleanupProps(Props: TPicProperties);
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

  function TPhoaPic.IPAP_GetKeywordList: TStrings;
  begin
    Result := FPicKeywords;
  end;

  function TPhoaPic.IPAP_GetList: IPhotoAlbumPics;
  begin
    Result := IPhotoAlbumPics(FList);
  end;

  function TPhoaPic.IPAP_GetProps(PicProp: TPicProperty): String;
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

  function TPhoaPic.IPAP_GetPropStrs(Props: TPicProperties; const sNameValSep, sPropSep: String): String;
  var
    Prop: TPicProperty;
    sVal: String;
  begin
    Result := '';
    for Prop := Low(Prop) to High(Prop) do
      if Prop in Props then begin
        sVal := IPAP_GetProps(Prop);
        if sVal<>'' then begin
          if sNameValSep<>'' then sVal := PicPropName(Prop)+sNameValSep+sVal;
          AccumulateStr(Result, sPropSep, sVal);
        end;
      end;
  end;

  function TPhoaPic.IPAP_GetRawData(PProps: TPicProperties): String;
  var
    Stream: TStringStream;
    Streamer: TPhoaStreamer;
  begin
     // ��������� ������ ����������� �� ��������� �����
    Stream := TStringStream.Create('');
    try
      Streamer := TPhoaStreamer.Create(Stream, psmWrite, '');
      try
        IPAP_StreamerSave(Streamer, False, PProps);
      finally
        Streamer.Free;
      end;
       // ��������� ����� � ������
      Result := Stream.DataString;
    finally
      Stream.Free;
    end;
  end;

  procedure TPhoaPic.IPAP_PutToList(NewList: IPhotoAlbumPics; bAllocateNewID: Boolean);
  begin
    if FList<>Pointer(NewList) then begin
      if FList<>nil then IPhotoAlbumPics(FList).Remove(Self.ID);
      FList := Pointer(NewList);
      if NewList<>nil then begin
        if bAllocateNewID then FID := NewList.MaxPicID+1;
        NewList.Add(Self, False);
      end;
    end;
  end;

  procedure TPhoaPic.IPAP_Release;
  begin
    IPAP_PutToList(nil, False);
  end;

  procedure TPhoaPic.IPAP_SetProps(PicProp: TPicProperty; const Value: String);
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

  procedure TPhoaPic.IPAP_SetRawData(PProps: TPicProperties; const Value: String);
  var
    Stream: TStringStream;
    Streamer: TPhoaStreamer;
  begin
    Stream := TStringStream.Create(Value);
    try
      Streamer := TPhoaStreamer.Create(Stream, psmRead, '');
      try
        IPAP_StreamerLoad(Streamer, False, PProps);
      finally
        Streamer.Free;
      end;
    finally
      Stream.Free;
    end;
  end;

  procedure TPhoaPic.IPAP_StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
  var
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;

    function XFilename(const s: String): String;
    begin
      if bExpandRelative then Result := ExpandRelativePath(Streamer.BasePath, s) else Result := s;
    end;

  begin
     // *** Old format
    if not Streamer.Chunked then begin
      if ppID          in PProps                  then FID                    := Streamer.ReadInt;
      if ppFileName    in PProps                  then FThumbnailData         := Streamer.ReadStringI;
      if ppFilmNumber  in PProps                  then FPicFilmNumber         := Streamer.ReadStringI;
      if ppDate        in PProps                  then FPicDateTime           := Streamer.ReadInt;
      if ppDescription in PProps                  then FPicDesc               := Streamer.ReadStringI;
      if ppFileName    in PProps                  then FPicFileName           := XFilename(Streamer.ReadStringI);
      if [ppFileSize, ppFileSizeBytes]*PProps<>[] then FPicFileSize           := Streamer.ReadInt;
      if ppFormat      in PProps                  then FPicFormat             := TPixelFormat(Streamer.ReadByte);
      if ppKeywords    in PProps                  then FPicKeywords.CommaText := Streamer.ReadStringI;
      if ppFrameNumber in PProps                  then FPicFrameNumber        := Streamer.ReadStringI;
      if ppPlace       in PProps                  then FPicPlace              := Streamer.ReadStringI;
      if ppFileName    in PProps                  then FThumbWidth            := Streamer.ReadInt;
      if ppFileName    in PProps                  then FThumbHeight           := Streamer.ReadInt;
     // *** New format
    end else begin
       // Revert props to their defaults because they might be not saved due to their emptiness
      IPAP_CleanupProps(PProps);
       // Read chunked data
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
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
          else Streamer.SkipNestedChunks(Code);
        end;
    end;
  end;

  procedure TPhoaPic.IPAP_StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);

    function XFilename: String;
    begin
      if bExtractRelative then Result := ExtractRelativePath(Streamer.BasePath, FPicFileName) else Result := FPicFileName;
    end;

  begin
     // *** Old format
    if not Streamer.Chunked then begin
      if ppID          in PProps                  then Streamer.WriteInt    (FID);
      if ppFileName    in PProps                  then Streamer.WriteStringI(FThumbnailData);
      if ppFilmNumber  in PProps                  then Streamer.WriteStringI(FPicFilmNumber);
      if ppDate        in PProps                  then Streamer.WriteInt    (Trunc(FPicDateTime));
      if ppDescription in PProps                  then Streamer.WriteStringI(FPicDesc);
      if ppFileName    in PProps                  then Streamer.WriteStringI(XFilename);
      if [ppFileSize, ppFileSizeBytes]*PProps<>[] then Streamer.WriteInt    (FPicFileSize);
      if ppFormat      in PProps                  then Streamer.WriteByte   (Byte(FPicFormat));
      if ppKeywords    in PProps                  then Streamer.WriteStringI(FPicKeywords.CommaText);
      if ppFrameNumber in PProps                  then Streamer.WriteStringI(FPicFrameNumber);
      if ppPlace       in PProps                  then Streamer.WriteStringI(FPicPlace);
      if ppFileName    in PProps                  then Streamer.WriteInt    (FThumbWidth);
      if ppFileName    in PProps                  then Streamer.WriteInt    (FThumbHeight);
     // *** New format
    end else begin
      if ppID          in PProps                                                 then Streamer.WriteChunkInt   (IPhChunk_Pic_ID,            FID);
      if ppFileName    in PProps                                                 then Streamer.WriteChunkString(IPhChunk_Pic_ThumbnailData, FThumbnailData);
      if ppFileName    in PProps                                                 then Streamer.WriteChunkWord  (IPhChunk_Pic_ThumbWidth,    FThumbWidth);
      if ppFileName    in PProps                                                 then Streamer.WriteChunkWord  (IPhChunk_Pic_ThumbHeight,   FThumbHeight);
      if ppFileName    in PProps                                                 then Streamer.WriteChunkString(IPhChunk_Pic_PicFileName,   XFilename);
      if ([ppFileSize, ppFileSizeBytes]*PProps<>[]) and (FPicFileSize>0)         then Streamer.WriteChunkInt   (IPhChunk_Pic_PicFileSize,   FPicFileSize);
      if ([ppPicWidth, ppPicDims]*PProps<>[])       and (FPicWidth>0)            then Streamer.WriteChunkInt   (IPhChunk_Pic_PicWidth,      FPicWidth);
      if ([ppPicHeight, ppPicDims]*PProps<>[])      and (FPicHeight>0)           then Streamer.WriteChunkInt   (IPhChunk_Pic_PicHeight,     FPicHeight);
      if (ppFormat      in PProps)                  and (FPicFormat<>pfCustom)   then Streamer.WriteChunkByte  (IPhChunk_Pic_PicFormat,     Byte(FPicFormat));
      if (ppDate        in PProps)                  and (Trunc(FPicDateTime)<>0) then Streamer.WriteChunkInt   (IPhChunk_Pic_Date,          DateToPhoaDate(FPicDateTime));
      if (ppTime        in PProps)                  and (Frac(FPicDateTime)<>0)  then Streamer.WriteChunkInt   (IPhChunk_Pic_Time,          TimeToPhoaTime(FPicDateTime));
      if (ppPlace       in PProps)                  and (FPicPlace<>'')          then Streamer.WriteChunkString(IPhChunk_Pic_Place,         FPicPlace);
      if (ppFilmNumber  in PProps)                  and (FPicFilmNumber<>'')     then Streamer.WriteChunkString(IPhChunk_Pic_FilmNumber,    FPicFilmNumber);
      if (ppFrameNumber in PProps)                  and (FPicFrameNumber<>'')    then Streamer.WriteChunkString(IPhChunk_Pic_FrameNumber,   FPicFrameNumber);
      if (ppAuthor      in PProps)                  and (FPicAuthor<>'')         then Streamer.WriteChunkString(IPhChunk_Pic_Author,        FPicAuthor);
      if (ppMedia       in PProps)                  and (FPicMedia<>'')          then Streamer.WriteChunkString(IPhChunk_Pic_Media,         FPicMedia);
      if (ppDescription in PProps)                  and (FPicDesc<>'')           then Streamer.WriteChunkString(IPhChunk_Pic_Desc,          FPicDesc);
      if (ppNotes       in PProps)                  and (FPicNotes<>'')          then Streamer.WriteChunkString(IPhChunk_Pic_Notes,         FPicNotes);
      if (ppKeywords    in PProps)                  and (FPicKeywords.Count>0)   then Streamer.WriteChunkString(IPhChunk_Pic_Keywords,      FPicKeywords.CommaText);
      if (ppRotation    in PProps)                  and (FPicRotation<>pr0)      then Streamer.WriteChunkByte  (IPhChunk_Pic_Rotation,      Byte(FPicRotation));
      if (ppFlips       in PProps)                  and (FPicFlips<>[])          then Streamer.WriteChunkByte  (IPhChunk_Pic_Flips,         Byte(FPicFlips));
    end;
  end;

  procedure TPhoaPic.IPMP_ReloadPicFileData;
  var PhoA: TPhotoAlbum;
  begin
    Assert(FList<>nil, 'Cannot reload picture file data when a picture isn''t in list');
     // �������� ���������� - ����� ������-��������
    PhoA := IPhotoAlbumPics(FList).PhoA;
     // ��������� ����� � �������� ��� ������
    FThumbnailData := GetThumbnailData(
      FPicFileName,
      PhoA.ThumbnailWidth,
      PhoA.ThumbnailHeight,
      TStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)),
      PhoA.ThumbnailQuality,
      FPicWidth,
      FPicHeight,
      FThumbWidth,
      FThumbHeight);
     // �������� ������ ����� �����������
    FPicFileSize := GetFileSize(FPicFileName, 0); 
  end;

  procedure TPhoaPic.IPMP_SetFileName(Value: PAnsiChar);
  begin
    FPicFileName := Value;
  end;

  procedure TPhoaPic.IPMP_SetFlips(Value: TPicFlips);
  begin
    FPicFlips := Value;
  end;

  procedure TPhoaPic.IPMP_SetRotation(Value: TPicRotation);
  begin
    FPicRotation := Value;
  end;

  function TPhoaPic.IPP_GetAuthor: PAnsiChar;
  begin
    Result := PAnsiChar(FPicAuthor);
  end;

  function TPhoaPic.IPP_GetDate: Integer;
  begin
    if Trunc(FPicDateTime)=0 then Result := 0 else Result := DateToPhoaDate(FPicDateTime);
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

  function TPhoaPic.IPP_GetHandle: TPhoaHandle;
  begin
    Result := TPhoaHandle(Self);
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
    if Prop in PPAllProps then Result := PAnsiChar(IPAP_GetProps(Prop)) else Result := nil;
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

   //===================================================================================================================
   // TPhotoAlbumPics
   //===================================================================================================================

  constructor TPhotoAlbumPics.Create(APhoA: TPhotoAlbum);
  begin
    inherited Create(True);
    FPhoA := APhoA;
  end;

  procedure TPhotoAlbumPics.DuplicatePics(PicList: IPhoaPicList);
  var
    i: Integer;
    Pic: IPhotoAlbumPic;
  begin
    Clear;
    for i := 0 to PicList.Count-1 do begin
       // ������ ��������� �����������
      Pic := TPhoaPic.Create;
       // �������� � ���� ������ ��������� �����������
      Pic.Assign(PicList[i] as IPhotoAlbumPic);
       // ����� ����� (ID ��������) - ������� � ������
      Pic.PutToList(Self, False);
    end;
  end;

  function TPhotoAlbumPics.GetPhoA: TPhotoAlbum;
  begin
    Result := FPhoA;
  end;

  procedure TPhotoAlbumPics.StreamerLoad(Streamer: TPhoaStreamer);
  var
    i: Integer;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;

    procedure LoadPic;
    var Pic: IPhotoAlbumPic;
    begin
      Pic := TPhoaPic.Create;
      Pic.StreamerLoad(Streamer, True, PPAllProps);
      Pic.PutToList(Self, False);
    end;

  begin
    Clear;
     // *** Old format
    if not Streamer.Chunked then
      for i := 0 to Streamer.ReadInt-1 do LoadPic
     // *** New format
    else
      while Streamer.ReadChunkValue(Code, Datatype, vValue, True, True)=rcrOK do
        case Code of
           // Picture
          IPhChunk_Pic_Open: LoadPic;
           // Close-chunk
          IPhChunk_Pics_Close: Break;
           // Ensure unknown nested structures are skipped whole
          else Streamer.SkipNestedChunks(Code);
        end;
  end;

  procedure TPhotoAlbumPics.StreamerSave(Streamer: TPhoaStreamer);
  var i: Integer;
  begin
     // *** Old format
    if not Streamer.Chunked then begin
      Streamer.WriteInt(Count);
      for i := 0 to Count-1 do (Items[i] as IPhotoAlbumPic).StreamerSave(Streamer, True, PPAllProps);
     // *** New format
    end else begin
      Streamer.WriteChunk(IPhChunk_Pics_Open);
      for i := 0 to Count-1 do begin
        Streamer.WriteChunk(IPhChunk_Pic_Open);
        (Items[i] as IPhotoAlbumPic).StreamerSave(Streamer, True, PPAllProps);
        Streamer.WriteChunk(IPhChunk_Pic_Close);
      end;
      Streamer.WriteChunk(IPhChunk_Pics_Close);
    end;
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

  function TPhoaGroupings.SortComparePics(Pic1, Pic2: IPhoaPic): Integer;
  var i: Integer;
  begin
    Result := 0;
    for i := 0 to Count-1 do begin
      case GetItems(i).Prop of
        gbpFilePath:    Result := AnsiCompareText(ExtractFilePath(Pic1.FileName), ExtractFilePath(Pic2.FileName));
        gbpDateByYear:  Result := YearOf(PhoaDateToDate(Pic1.Date))-YearOf(PhoaDateToDate(Pic2.Date));
        gbpDateByMonth: Result := MonthOf(PhoaDateToDate(Pic1.Date))-MonthOf(PhoaDateToDate(Pic2.Date));
        gbpDateByDay:   Result := DayOf(PhoaDateToDate(Pic1.Date))-DayOf(PhoaDateToDate(Pic2.Date));
        gbpTimeHour:    Result := HourOf(PhoaTimeToTime(Pic1.Time))-HourOf(PhoaTimeToTime(Pic2.Time));
        gbpTimeMinute:  Result := MinuteOf(PhoaTimeToTime(Pic1.Time))-MinuteOf(PhoaTimeToTime(Pic2.Time));
        gbpPlace:       Result := AnsiCompareText(Pic1.Place,      Pic2.Place);
        gbpFilmNumber:  Result := AnsiCompareText(Pic1.FilmNumber, Pic2.FilmNumber);
        gbpAuthor:      Result := AnsiCompareText(Pic1.Author,     Pic2.Author);
        gbpMedia:       Result := AnsiCompareText(Pic1.Media,      Pic2.Media);
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
         // Read groupings translating GroupByProperty from old revision 2
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

  function PhoaViewSortCompareFunc(Pic1, Pic2: IPhoaPic; dwData: Cardinal): Integer; stdcall;
  begin
     // ������� ��������� �� ������������
    Result := TPhoaView(dwData).Groupings.SortComparePics(Pic1, Pic2);
     // ����� �� �����������
    if Result=0 then Result := TPhoaView(dwData).Sortings.SortComparePics(Pic1, Pic2);
  end;

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
    Pic: IPhoaPic;
    GroupWithPics: TList;
    bClassified: Boolean;

     // ������ ��������������� ������, ��������� ��� � �������� ����������� � �������� ������
    procedure FillRootGroup;
    var Pics: IPhoaMutablePicList;
    begin
      Pics := TPhoaMutablePicList.Create(False);
      Pics.Add(FList.FPhoA.Pics, False);
      Pics.CustomSort(PhoaViewSortCompareFunc, Cardinal(Self));
      FRootGroup.Pics.Assign(Pics);
    end;

     // ������ ������ �� ���� � �����������
    procedure ProcessFilePathTree(ParentGroup: TPhoaGroup; Pic: IPhoaPic);
    var
      iSlashPos: Integer;
      sDir, sOneDir: String;
      Group, GParent: TPhoaGroup;
    begin
      sDir := ExtractFileDir(Pic.FileName);
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
      Group.Pics.Add(Pic, True);
    end;

     // ������ ������ �� ����������� ���� (one level)
    procedure ProcessDateTree(Prop: TGroupByProperty; ParentGroup: TPhoaGroup; Pic: IPhoaPic);
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
      sDatePart := FormatDateTime(sDatePart, PhoaDateToDate(Pic.Date));
       // �������� ���������� ������ ������� ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      if (Group=nil) or not AnsiSameText(Group.Text, sDatePart) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text     := sDatePart;
        Group.Expanded := True;
      end;
      Group.Pics.Add(Pic, True);
    end;

     // ������ ������ �� ����������� ������� (one level)
    procedure ProcessTimeTree(Prop: TGroupByProperty; ParentGroup: TPhoaGroup; Pic: IPhoaPic);
    var
      sTimePart: String;
      Group: TPhoaGroup;
    begin
       // ������� ������������ ���������� �������
      sTimePart := FormatDateTime(iif(Prop=gbpTimeHour, 'h', 'n'), PhoaTimeToTime(Pic.Time));
       // �������� ���������� ������ ������� ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      if (Group=nil) or not AnsiSameText(Group.Text, sTimePart) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text     := sTimePart;
        Group.Expanded := True;
      end;
      Group.Pics.Add(Pic, True);
    end;

     // ������ ������ �� �������� ���������� �������� (one level)
    procedure ProcessPlainPropTree(PicProp: TPicProperty; ParentGroup: TPhoaGroup; Pic: IPhoaPic);
    var
      Group: TPhoaGroup;
      sPropVal: String;
    begin
       // �������� ���������� ������ ������
      with ParentGroup.Groups do
        if Count=0 then Group := nil else Group := Items[Count-1];
       // ���� ��� ����� ��� ��������� ������ �� ��������� �� ������������, ������ ������ ������
      sPropVal := (Pic as IPhotoAlbumPic).Props[PicProp];
      if (Group=nil) or not AnsiSameText(Group.Text, sPropVal) then begin
        Group := TPhoaGroup.Create(ParentGroup, 0);
        Group.Text := sPropVal;
      end;
       // ��������� ����������� � ������
      Group.Pics.Add(Pic, True);
    end;

     // ������ ������ �� �������� ������ (one level)
    procedure ProcessKeywordTree(ParentGroup: TPhoaGroup; Pic: IPhoaPic);
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
      for ikw := 0 to TPhoaPic(Pic.Handle).PicKeywords.Count-1 do GetKWGroup(TPhoaPic(Pic.Handle).PicKeywords[ikw]).Pics.Add(Pic, True);
    end;

     // ����������� ��������� ���������� ������ ��������, ����������� �����������
    procedure MakeListOfGroupsWithPics(GList: TList; Group: TPhoaGroup);
    var i: Integer;
    begin
      if Group.Pics.Count>0 then GList.Add(Group);
      for i := 0 to Group.Groups.Count-1 do MakeListOfGroupsWithPics(GList, Group.Groups[i]);
    end;

  begin
    StartWait;
    try
       // ������ �������� ��� ������� ���������� ������ �� �������������
      if FRootGroup=nil then FRootGroup := TPhoaGroup.Create(nil, 1) else FRootGroup.Groups.Clear;
       // �������� ������������� �� ������������ ������������� ������ ���� ����������� ����������� � �������� ������
      FillRootGroup;
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
            while iPic<Grp.Pics.Count do begin
              Pic := Grp.Pics[iPic];
               // ���������, ���������������� �� �����������
              case Gpg.Prop of
                gbpFilePath:       bClassified := True;
                gbpDateByYear,
                  gbpDateByMonth,
                  gbpDateByDay:    bClassified := Pic.Date>0;
                gbpTimeHour,
                  gbpTimeMinute:   bClassified := Pic.Time>0;
                gbpPlace:          bClassified := Pic.Place<>'';
                gbpFilmNumber:     bClassified := Pic.FilmNumber<>'';
                gbpAuthor:         bClassified := Pic.Author<>'';
                gbpMedia:          bClassified := Pic.Media<>'';
                else {gbpKeywords} bClassified := Pic.Keywords<>'';
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
                GUnclassified.Pics.Add(Pic, True);
               // ����� - ��������� � ���������� �����������
              end else begin
                Inc(iPic);
                Continue;
              end;
               // ������� ����������� �� ������ ������
              Grp.Pics.Remove(Pic.ID);
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
    FPics             := TPhotoAlbumPics.Create(Self);
    FViews            := TPhoaViews.Create(Self);
    FFileRevision     := IPhFileRevisionNumber;
    FThumbnailQuality := IDefaultThumbQuality;
    FThumbnailHeight  := IDefaultThumbHeight;
    FThumbnailWidth   := IDefaultThumbWidth;
  end;

  destructor TPhotoAlbum.Destroy;
  begin
    FreeAndNil(FRootGroup);
    FPics := nil;
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
    FRootGroup.Pics.Clear;
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
    Pic: IPhotoAlbumPic;
  begin
    i := 0;
    while i<FPics.Count do begin
      Pic := FPics[i] as IPhotoAlbumPic;
      if not FRootGroup.IsPicLinked(Pic.ID, True) then TPhoaOp_InternalPicRemoving.Create(UndoOperations, Self, Pic) else Inc(i);
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
    try
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
    finally
       // ��������� �������� ��� �������� �����
      FRootGroup.Loaded(Self);
    end;
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
    if Group.Pics.Count>0 then begin
      FPicIDs := TIntegerList.Create(False);
      for i := 0 to Group.Pics.Count-1 do FPicIDs.Add(Group.Pics[i].ID);
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
    if FPicIDs<>nil then
      for i := 0 to FPicIDs.Count-1 do g.Pics.Add(PhoA.Pics.ItemsByID[FPicIDs[i]], False);
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

  constructor TPhoaOp_InternalPicRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: IPhotoAlbumPic);
  begin
    inherited Create(List, PhoA);
     // ��������� ������ �����������
    UndoFile.WriteStr(Pic.RawData[PPAllProps]);
     // ��������� ��������
    Pic.Release;
  end;

  procedure TPhoaOp_InternalPicRemoving.RollbackChanges;
  var Pic: IPhotoAlbumPic;
  begin
    inherited RollbackChanges;
     // ������ �����������
    Pic := TPhoaPic.Create;
     // ��������� ������
    Pic.RawData[PPAllProps] := UndoFile.ReadStr;
     // ����� � ������ (ID ��� ��������)
    Pic.PutToList(FPhoA.Pics, False);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicProps
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicProps.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: IPhoaPicList; ChangeList: TPicPropertyChanges);
  var
    iPic, iChg: Integer;
    Pic: IPhotoAlbumPic;
    ChangedProps: TPicProperties;
  begin
    inherited Create(List, PhoA);
     // ��������� ����� ������������ �������
    ChangedProps := ChangeList.ChangedProps;
    UndoFile.WriteInt(PicPropsToInt(ChangedProps));
     // ��������� ���������� �����������
    UndoFile.WriteInt(Pics.Count);
     // ���� �� ������������
    for iPic := 0 to Pics.Count-1 do begin
       // ���������� ������ ������
      Pic := Pics[iPic] as IPhotoAlbumPic;
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
      (FPhoA.Pics.ItemsByID[iPicID] as IPhotoAlbumPic).RawData[ChangedProps] := sPicData;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicKeywords
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicKeywords.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pics: IPhoaPicList; Keywords: TKeywordList);
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
     // ���� �� ������������
    iCnt := Pics.Count;
    for iPic := 0 to iCnt-1 do begin
      Pic := TPhoaPic(Pics[iPic].Handle);
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
      TPhoaPic(FPhoA.Pics.ItemsByID[iPicID].Handle).PicKeywords.CommaText := sKeywords;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_StoreTransform
   //===================================================================================================================

  constructor TPhoaOp_StoreTransform.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips);
  begin
    inherited Create(List, PhoA);
     // ��������� ������� ��������
    UndoFile.WriteInt(Pic.ID);
    UndoFile.WriteByte(Byte(Pic.Rotation));
    UndoFile.WriteByte(Byte(Pic.Flips));
     // ��������� ����� ��������
    Pic.Rotation := NewRotation;
    Pic.Flips    := NewFlips;
  end;

  procedure TPhoaOp_StoreTransform.RollbackChanges;
  var Pic: IPhoaMutablePic;
  begin
    inherited RollbackChanges;
    Pic          := PhoA.Pics.ItemsByID[UndoFile.ReadInt] as IPhoaMutablePic;
    Pic.Rotation := TPicRotation(UndoFile.ReadByte);
    Pic.Flips    := TPicFlips(Byte(UndoFile.ReadByte)); // �������� typecast, �� ����� �� �������������
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicAdd
   //===================================================================================================================

  constructor TPhoaOp_InternalPicAdd.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; const sFilename: String);
  var Pic: IPhotoAlbumPic;
  begin
    inherited Create(List, PhoA);
     // ���� ��� ������������ ����������� � ��� �� ������
    Pic := PhoA.Pics.ItemsByFileName[PChar(sFilename)] as IPhotoAlbumPic;
    FExisting := Pic<>nil;
     // ���� ���� ��� �� �������������, ������ ��������� TPhoaPic
    if not FExisting then begin
      Pic := TPhoaPic.Create;
       // ��������� � ������, ������� ID
      Pic.PutToList(PhoA.Pics, True);
       // ����������� ��� ����� � ������ �����
      Pic.FileName := PChar(sFilename);
      Pic.ReloadPicFileData;
    end;
     // ��������� � ������
    RegisterPic(Group, Pic);
    FAddedPic := TPhoaPic(Pic.Handle);
  end;

  constructor TPhoaOp_InternalPicAdd.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pic: IPhoaPic);
  var PicEx: IPhoaPic;
  begin
    inherited Create(List, PhoA);
     // ���� ��� ������������ ����������� � ��� �� ������
    PicEx := PhoA.Pics.ItemsByFileName[PChar(Pic.FileName)];
    FExisting := PicEx<>nil;
     // ���� ����� ����������� - ������� � ������, ����������� ����� ID. ����� ���������� Pic
    if not FExisting then (Pic as IPhotoAlbumPic).PutToList(PhoA.Pics, True) else Pic := PicEx;
     // ��������� � ������
    RegisterPic(Group, Pic);
  end;

  procedure TPhoaOp_InternalPicAdd.RegisterPic(Group: TPhoaGroup; Pic: IPhoaPic);
  var bAdded: Boolean;
  begin
     // ��������� ����������� � ������, ���� ��� �� ����
    Group.Pics.Add(Pic, True, bAdded);
    if bAdded then begin
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
      OpGroup.Pics.Remove(iPicID);
       // ���� ���� ��������� ����� �����������, ������� � �� �����������
      if not FExisting then (FPhoA.Pics.ItemsByID[iPicID] as IPhotoAlbumPic).Release;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicFromGroupRemove
   //===================================================================================================================

  constructor TPhoaOp_InternalPicFromGroupRemoving.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
  var i, idx: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ���������� ID � �������
    for i := 0 to Pics.Count-1 do begin
       // ���� ���� ����� ID � ������, ���������� � �������
      idx := Group.Pics.IndexOfID(Pics[i].ID);
      if idx>=0 then begin
         // ����� ���� �����������
        UndoFile.WriteBool(True);
         // ����� ID
        UndoFile.WriteInt(Pics[i].ID);
         // ����� ������
        UndoFile.WriteInt(idx);
         // ������� �����������
        Group.Pics.Delete(idx);
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
        g.Pics.Insert(IIs[i+1], PhoA.Pics.ItemsByID[IIs[i]], False);
        Dec(i, 2);
      end;
    finally
      IIs.Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  constructor TPhoaOp_InternalPicToGroupAdding.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
  var
    i: Integer;
    bAdded: Boolean;
    Pic: IPhoaPic;
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
     // ��������� ����������� � ������ � � undo-����
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
      Group.Pics.Add(Pic, True, bAdded);
      if bAdded then begin
        UndoFile.WriteBool(True); // ���� �����������
        UndoFile.WriteInt (Pic.ID);
      end;
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
    while UndoFile.ReadBool do g.Pics.Remove(UndoFile.ReadInt);
  end;

   //===================================================================================================================
   // TPhoaBaseOp_PicCopy
   //===================================================================================================================

  constructor TPhoaBaseOp_PicCopy.Create(Pics: IPhoaPicList);
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
          for i := 0 to Pics.Count-1 do begin
            Streamer.WriteChunk(IPhChunk_Pic_Open);
            (Pics[i] as IPhotoAlbumPic).StreamerSave(Streamer, False, PPAllProps);
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
        for i := 0 to Pics.Count-1 do SL.Add(Pics[i].FileName);
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
      for i := 0 to Pics.Count-1 do s := s+Pics[i].FileName+S_CRLF;
       // �������� ����� � clipboard
      Clipboard.AsText := s;
    end;

     // �������� � ����� ������ bitmap-����� ����������� Pic
    procedure CopyThumbBitmap(Pic: IPhoaPic);
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
      if Pics.Count>0 then begin
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
          if (pcfSingleBitmap in pcfs) and (Pics.Count=1) then CopyThumbBitmap(Pics[0]);
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

  constructor TPhoaMultiOp_PicDelete.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList);
  begin
    inherited Create(List, PhoA);
    OpGroup := Group;
     // ������� ID ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, Group, Pics);
     // ������� ����������� ����������� �� �����������
    PhoA.RemoveUnlinkedPics(FOperations);
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicPaste
   //===================================================================================================================

  constructor TPhoaMultiOp_PicPaste.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup);
  var
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
    Pic: IPhotoAlbumPic;
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
                  Pic := TPhoaPic.Create;
                  Pic.StreamerLoad(Streamer, False, PPAllProps);
                   // ������ �������� �������� ���������� �����������
                  TPhoaOp_InternalPicAdd.Create(FOperations, PhoA, Group, Pic);
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

  constructor TPhoaMultiOp_PicOperation.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation);
  var
    i: Integer;
    IntersectPics: IPhoaMutablePicList;
    Pic: IPhoaPic;
  begin
    inherited Create(List, PhoA);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, TargetGroup, Pics);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, SourceGroup, Pics);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, TargetGroup, Pics);
     // �������� ������ ���������� ����������� � ��������� ������
    if PicOperation=popIntersectTarget then begin
      IntersectPics := TPhoaMutablePicList.Create(False);
      for i := 0 to TargetGroup.Pics.Count-1 do begin
        Pic := TargetGroup.Pics[i];
        if Pics.IndexOfID(Pic.ID)<0 then IntersectPics.Add(Pic, False);
      end;
      if IntersectPics.Count>0 then begin
        TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, TargetGroup, IntersectPics);
        PhoA.RemoveUnlinkedPics(FOperations);
      end;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  constructor TPhoaOp_InternalGroupPicSort.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Sortings: TPhoaSortings);
  var i: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ���������� ������� ���������� ID ����������� � ������
    UndoFile.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoFile.WriteInt(Group.Pics[i].ID);
     // ��������� ����������� � ������
    Group.SortPics(Sortings);
  end;

  procedure TPhoaOp_InternalGroupPicSort.RollbackChanges;
  var i: Integer;
  begin
    inherited RollbackChanges;
     // ��������������� ������ ������� ���������� ID ����������� � ������
    OpGroup.Pics.Clear;
    for i := 0 to UndoFile.ReadInt-1 do OpGroup.Pics.Add(PhoA.Pics.ItemsByID[UndoFile.ReadInt], False);
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

  constructor TPhoaMultiOp_PicDragAndDropToGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; SourceGroup, TargetGroup: TPhoaGroup; Pics: IPhoaPicList; bCopy: Boolean);
  begin
    inherited Create(List, PhoA);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(FOperations, PhoA, TargetGroup, Pics);
    if not bCopy then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, PhoA, SourceGroup, Pics);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  constructor TPhoaOp_PicDragAndDropInsideGroup.Create(List: TPhoaOperations; PhoA: TPhotoAlbum; Group: TPhoaGroup; Pics: IPhoaPicList; idxNew: Integer);
  var i, idxOld: Integer;
  begin
    inherited Create(List, PhoA);
     // ���������� ������
    OpGroup := Group;
     // ��������� ��������
    for i := 0 to Pics.Count-1 do begin
       // -- ����� ������� �����������
      UndoFile.WriteBool(True);
       // -- ���������� �������
      idxOld := Group.Pics.IndexOfID(Pics[i].ID);
      if idxOld<idxNew then Dec(idxNew);
      UndoFile.WriteInt(idxOld);
      UndoFile.WriteInt(idxNew);
       // -- ���������� ����������� �� ����� �����
      Group.Pics.Move(idxOld, idxNew);
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
        g.Pics.Move(Indexes[i+1], Indexes[i]);
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
      Pic := TPhoaPic(PhoA.Pics[ip].Handle);
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
