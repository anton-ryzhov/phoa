//**********************************************************************************************************************
//  $Id: phNativeIntf.pas,v 1.11 2005-03-01 21:35:40 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phNativeIntf;

interface

uses Windows, ImgList, ActnList, phIntf, phAppIntf, phMutableIntf, phPhoa;

type

   //===================================================================================================================
   // IPhotoAlbumPic - ����������� �����������
   //===================================================================================================================

  IPhotoAlbumKeywordList = interface;
  IPhotoAlbumPicList     = interface;

  IPhotoAlbumPic = interface(IPhoaMutablePic)
    ['{AE945E5F-9BF1-4FD0-92C9-92716D7BB631}']
     // ��������� ����������� � ������ List. ��� iNewID<0 ��������� ID ����������� ����������, ��� iNewID=0 ������������
     //   ����������� ����� ID, ���������� � List. ��� iNewID>0 ����������� ���� ID �����������
    procedure PutToList(List: IPhoaMutablePicList; iNewID: Integer = -1);
     // ��������/���������� � ������� Streamer
     //   -- �������� bEx...Relative ������������, ������������ �� �������������� �������������� <-> ����������� ����
     //      � ����� �����������
     //   -- �������� PProps ���������, ����� �������� ��������� � ��������������� (��� ���� ��� ���������� ������,
     //      ��������� � ������������, �.�. � ������, ����������� ������ ��� ������� ppFileName in PProps)
    procedure StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
    procedure StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);
     // Prop handlers
    function  GetKeywordsX: IPhotoAlbumKeywordList;
     // Props
     // -- 'Native' version of Keywords
    property KeywordsX: IPhotoAlbumKeywordList read GetKeywordsX;
  end;

   //===================================================================================================================
   // IPhotoAlbumKeywordList - ������ �������� ����
   //===================================================================================================================

   // ��������� ��������� [������] ��������� �����
  TPhoaKeywordChange = (pkcNone, pkcAdd, pkcReplace);
   // ��������� ������ ��������� �����
  TPhoaKeywordState  = (pksOff, pksGrayed, pksOn);

   // �������������� ������ ��������� �����
  PPhoaKeywordData = ^TPhoaKeywordData;
  TPhoaKeywordData = record
    sKeyword:    String;             // �������� �����
    sOldKeyword: String;             // ������� �������� �����, ���� ����� �������� ������������ �� ������
    Change:      TPhoaKeywordChange; // ��������� ��������� [������] ��������� �����
    State:       TPhoaKeywordState;  // ��������� ������ ��������� �����
    iCount:      Integer;            // ���������� ��������� � ���������� (��� ������������, �.�. Change<>kcAdd)
    iSelCount:   Integer;            // ���������� ���������� ����� ��������� ����������� (����������� � PopulateFromPicList ��� �������������� Callback-���������)
  end;

   // Callback-���������, ���������� �� IPhotoAlbumKeywordList.PopulateFromPicList() ��� �����������, �������
   // ����������� ��� ���
  TPhoaKeywordIsPicSelectedProc = procedure(Pic: IPhoaPic; out bSelected: Boolean) of object;

  IPhotoAlbumKeywordList = interface(IPhoaMutableKeywordList)
    ['{B14C063F-43EC-48BA-9724-562A97E5E2C7}']
     // ��������� �����. ��� ��������� ���������� ����� ��� �� �����������, ������ ������������� �������. ����
     //   bSelected=True, ������������� ����� ������� iSelCount
    function  AddEx(const sKeyword: String; bSelected: Boolean): Integer;
     // ��������� ������ �� ������ �������� ���� ����������� �� ������. ���� �������� ��������� IsPicSelCallback,
     //   ����������� ����������� �������� TKeywordRec.iSelCount, � ������������ � iTotalSelCount ������������
     //   TKeywordRec.State
    procedure PopulateFromPicList(Pics: IPhoaPicList; IsPicSelCallback: TPhoaKeywordIsPicSelectedProc; iTotalSelCount: Integer);
     // ��������� ����� ����� � ���������� ������ � ���������� ��� ������ � ������
    function  InsertNew: Integer;
     // Prop handlers
    function  GetKWData(Index: Integer): PPhoaKeywordData;
    function  GetSelectedKeywords: String;
    procedure SetSelectedKeywords(const Value: String);
     // Props
     // -- ������ �������� ���� �� �������
    property KWData[Index: Integer]: PPhoaKeywordData read GetKWData; 
     // -- ���������� ������� ��������� �����. ��� ������������ ����������� ����������� ����
    property SelectedKeywords: String read GetSelectedKeywords write SetSelectedKeywords;
  end;

   //===================================================================================================================
   // IPhotoAlbumPicList - ������������� �� ID ������ ����������� �����������
   //===================================================================================================================

  IPhotoAlbumProject = interface;

  IPhotoAlbumPicList = interface(IPhoaMutablePicList)
    ['{AE945E5F-9BF1-4FD0-92C9-92716D7BB632}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ������ ������ ����� ����������� � Src (�������, �������� ������� ������ ��� ������)
    procedure DuplicatePics(PicList: IPhoaPicList);
     // Prop handlers
    function  GetItemsByIDX(iID: Integer): IPhotoAlbumPic;
    function  GetItemsByFileNameX(const sFileName: String): IPhotoAlbumPic;
    function  GetItemsX(Index: Integer): IPhotoAlbumPic;
     // Props
     // -- 'Native' version of ItemsByID[]
    property ItemsByIDX[iID: Integer]: IPhotoAlbumPic read GetItemsByIDX;
     // -- 'Native' version of ItemsByFileName[]
    property ItemsByFileNameX[const sFileName: String]: IPhotoAlbumPic read GetItemsByFileNameX;
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumPic read GetItemsX; default;
  end;

   //===================================================================================================================
   // IPhotoAlbumPicGroup - ������ ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPicGroupList = interface;

  PPhotoAlbumPicGroup = ^IPhotoAlbumPicGroup;
  IPhotoAlbumPicGroup = interface(IPhoaMutablePicGroup)
    ['{9C951B51-2C66-4C35-B61B-8EDCBEAD8AC0}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ���������� ����� �������� �������� ����� �� Streamer-�
    procedure Loaded(Project: IPhotoAlbumProject);
     // ���������� ������������� ������ � ��� ���������, �������� ID �������, ��� �� �������
    procedure FixupIDs;
     // ����������� ���������, ����������� ID �������, ������� ID=0
    procedure InternalFixupIDs(var iMaxGroupID: Integer);
     // Prop handlers
    function  GetGroupByIDX(iID: Integer): IPhotoAlbumPicGroup;
    function  GetGroupByPathX(const sPath: String): IPhotoAlbumPicGroup;
    function  GetGroupsX: IPhotoAlbumPicGroupList;
    function  GetOwnerX: IPhotoAlbumPicGroup;
    function  GetPicsX: IPhotoAlbumPicList;
    function  GetRootX: IPhotoAlbumPicGroup;
     // Props
     // -- 'Native' version of Groups
    property GroupsX: IPhotoAlbumPicGroupList read GetGroupsX;
     // -- 'Native' version of GroupByID[]
    property GroupByIDX[iID: Integer]: IPhotoAlbumPicGroup read GetGroupByIDX;
     // -- 'Native' version of GroupByPath[]
    property GroupByPathX[const sPath: String]: IPhotoAlbumPicGroup read GetGroupByPathX;
     // -- 'Native' version of Owner
    property OwnerX: IPhotoAlbumPicGroup read GetOwnerX;
     // -- 'Native' version of Pics
    property PicsX: IPhotoAlbumPicList read GetPicsX;
     // -- 'Native' version of Root
    property RootX: IPhotoAlbumPicGroup read GetRootX;
  end;

   //===================================================================================================================
   // IPhotoAlbumPicGroupList - ������ ����� ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPicGroupList = interface(IPhoaMutablePicGroupList)
    ['{5B299022-5911-4154-8307-37170FDD7952}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    function  GetItemsX(Index: Integer): IPhotoAlbumPicGroup;
    function  GetOwnerX: IPhotoAlbumPicGroup;
     // Props
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumPicGroup read GetItemsX; default;
     // -- 'Native' version of Owner
    property OwnerX: IPhotoAlbumPicGroup read GetOwnerX;
  end;

   //===================================================================================================================
   // IPhotoAlbumPicSorting - ���������� �����������
   //===================================================================================================================

  IPhotoAlbumPicSorting = interface(IPhoaMutablePicSorting)
    ['{6010D0DF-0EA5-4461-96DC-956131E4BD34}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
  end;
  
   //===================================================================================================================
   // IPhotoAlbumPicSortingList - ������ ���������� �����������
   //===================================================================================================================

  IPhotoAlbumPicSortingList = interface(IPhoaMutablePicSortingList)
    ['{6010D0DF-0EA5-4461-96DC-956131E4BD35}']
     // ����������/�������� �� �������
    procedure RegSave(const sRoot, sSection: String);
    procedure RegLoad(const sRoot, sSection: String);
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // ���������� ������ ���������� � ��������� �� ���������
    procedure RevertToDefaults;
     // Prop handlers
    function  GetItemsX(Index: Integer): IPhotoAlbumPicSorting;
     // Props
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumPicSorting read GetItemsX; default;
  end;

   //===================================================================================================================
   // IPhotoAlbumPicGrouping - ����������� ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPicGrouping = interface(IPhoaMutablePicGrouping)
    ['{BADBDBE4-C412-4CD6-94F9-3AAEB0102D90}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
  end;

   //===================================================================================================================
   // IPhotoAlbumPicGroupingList - ������ ����������� ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPicGroupingList = interface(IPhoaMutablePicGroupingList)
    ['{BADBDBE4-C412-4CD6-94F9-3AAEB0102D91}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    function  GetItemsX(Index: Integer): IPhotoAlbumPicGrouping;
     // Props
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumPicGrouping read GetItemsX; default;
  end;

   //===================================================================================================================
   // IPhotoAlbumView - ������������� �����������
   //===================================================================================================================

  IPhotoAlbumViewList = interface;

  IPhotoAlbumView = interface(IPhoaMutableView)
    ['{54AF158C-1917-47F8-ABBD-AFDB4C5E64B7}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    function  GetGroupingsX: IPhotoAlbumPicGroupingList;
    function  GetListX: IPhotoAlbumViewList;
    function  GetRootGroupX: IPhotoAlbumPicGroup;
    function  GetSortingsX: IPhotoAlbumPicSortingList;
     // Props
     // -- 'Native' version of Groupings
    property GroupingsX: IPhotoAlbumPicGroupingList read GetGroupingsX;
     // -- 'Native' version of List
    property ListX: IPhotoAlbumViewList read GetListX;
     // -- 'Native' version of RootGroup
    property RootGroupX: IPhotoAlbumPicGroup read GetRootGroupX;
     // -- 'Native' version of Sortings
    property SortingsX: IPhotoAlbumPicSortingList read GetSortingsX;
  end;

   //===================================================================================================================
   // IPhotoAlbumViewList - ������ ������������� �����������
   //===================================================================================================================

  IPhotoAlbumViewList = interface(IPhoaMutableViewList)
    ['{54AF158C-1917-47F8-ABBD-AFDB4C5E64B8}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer);
     // Prop handlers
    function  GetItemsX(Index: Integer): IPhotoAlbumView;
    function  GetPicsX: IPhotoAlbumPicList;
     // Props
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumView read GetItemsX; default;
     // -- 'Native' version of Pics
    property PicsX: IPhotoAlbumPicList read GetPicsX;
  end;

   //===================================================================================================================
   // IPhotoAlbumProject - ������ PhoA
   //===================================================================================================================

  IPhotoAlbumProject = interface(IPhoaMutableProject)
    ['{769DBE0B-D86B-4F89-A557-9A8DA083E508}']
     // ��������/���������� � ������� Streamer
    procedure StreamerLoad(Streamer: TPhoaStreamer);
    procedure StreamerSave(Streamer: TPhoaStreamer; const sGenerator, sRemark: String);
     // Prop handlers
    function  GetCurrentViewX: IPhotoAlbumView;
    function  GetPicsX: IPhotoAlbumPicList;
    function  GetRootGroupX: IPhotoAlbumPicGroup;
    function  GetViewRootGroupX: IPhotoAlbumPicGroup;
    function  GetViewsX: IPhotoAlbumViewList;
     // Props
     // -- 'Native' version of CurrentView
    property CurrentViewX: IPhotoAlbumView read GetCurrentViewX;
     // -- 'Native' version of Pics
    property PicsX: IPhotoAlbumPicList read GetPicsX;
     // -- 'Native' version of RootGroup
    property RootGroupX: IPhotoAlbumPicGroup read GetRootGroupX;
     // -- 'Native' version of ViewRootGroup
    property ViewRootGroupX: IPhotoAlbumPicGroup read GetViewRootGroupX;
     // -- 'Native' version of Views
    property ViewsX: IPhotoAlbumViewList read GetViewsX;
  end;

   //===================================================================================================================
   // IPhotoAlbumAction - native-��������� Action-�
   //===================================================================================================================

  IPhotoAlbumAction = interface(IPhoaAction)
    ['{9E126412-46AA-4961-A966-7333C163AB4C}']
     // ���������� NativeAction
    procedure FreeNativeAction;
     // Prop handlers
    function  GetNativeAction: TCustomAction; 
     // Props
     // -- "���������" Action
    property NativeAction: TCustomAction read GetNativeAction;
  end;

   //===================================================================================================================
   // IPhotoAlbumApp - ��������� ������ ����������
   //===================================================================================================================

  IPhotoAlbumApp = interface(IPhoaMutableApp)
    ['{328D859C-8CDA-494B-B5E8-6AF9AB5E51FD}']
     // ��������� �������� �������� � ��������� �����������
    procedure PerformOperation(const sOpName: String; const aParams: Array of Variant);
     // Prop handlers
    function  GetCurGroupX: IPhotoAlbumPicGroup;
    function  GetImageList: TCustomImageList;
    function  GetProjectX: IPhotoAlbumProject;
    function  GetSelectedPicsX: IPhotoAlbumPicList;
    function  GetViewedPicsX: IPhotoAlbumPicList;
    procedure SetCurGroupX(Value: IPhotoAlbumPicGroup);
     // Props
     // -- 'Native' version of CurGroup
    property CurGroupX: IPhotoAlbumPicGroup read GetCurGroupX write SetCurGroupX;
     // -- ����������� ImageList ����������
    property ImageList: TCustomImageList read GetImageList;
     // -- 'Native' version of Project
    property ProjectX: IPhotoAlbumProject read GetProjectX;
     // -- 'Native' version of SelectedPics
    property SelectedPicsX: IPhotoAlbumPicList read GetSelectedPicsX;
     // -- 'Native' version of ViewedPics
    property ViewedPicsX: IPhotoAlbumPicList read GetViewedPicsX;
  end;

   //===================================================================================================================
   // IPhoaDataStream - ��������� ������ ������
   //===================================================================================================================

  IPhoaDataStream = interface(IInterface)
    ['{2C2E5BCD-F397-4824-B2EC-09F23D47334F}']
     // ������� ���������� ������
    procedure Clear;
     // ������ ��� ������ ������ � �����
    procedure WriteStr (const s: String);
    procedure WriteInt (i: Integer);
    procedure WriteByte(b: Byte);
    procedure WriteBool(b: Boolean);
     // ������ ��� ������ ������ �� ������
    function  ReadStr: String;
    function  ReadInt: Integer;
    function  ReadByte: Byte;
    function  ReadBool: Boolean;
     // Prop handlers
    function  GetPosition: Int64; 
     // Props
     // -- ������� ��������� � ������ ������
    property Position: Int64 read GetPosition;
  end;

   //===================================================================================================================
   // IPhoaUndoDataStream - ��������� ������ ������ ������
   //===================================================================================================================

  IPhoaUndoDataStream = interface(IPhoaDataStream)
    ['{71515E8A-42FC-4763-8EE2-797B0170E497}']
     // ��������� ������/��������� �������� ���������� ������ ������. BeginUndo ������������� ���� � �������� �������,
     //   �, ���� ��� ������ ����� BeginUndo, ���������� ��� �������. EndUndo ��������� ������� ��������� ����������,
     //   �, ���� ��� ��������� ����� EndUndo � bTruncate=True, ������� ���� �� ����������� � ������ ������ BeginUndo
     //   �������
    procedure BeginUndo(i64Position: Int64);
    procedure EndUndo(bTruncate: Boolean);
     // Prop handlers
    function  GetFileName: String; 
     // Props
     // -- ��� ����� ������ (����������)
    property FileName: String read GetFileName;
  end;

implementation

end.
