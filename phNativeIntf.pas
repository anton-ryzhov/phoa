//**********************************************************************************************************************
//  $Id: phNativeIntf.pas,v 1.1 2004-10-12 12:38:09 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phNativeIntf;

interface

uses Windows, phIntf, phMutableIntf, phPhoa;

type
   //===================================================================================================================
   // IPhotoAlbumPic - ����������� �����������
   //===================================================================================================================

  IPhotoAlbumPicList = interface;

  IPhotoAlbumPic = interface(IPhoaMutablePic)
    ['{AE945E5F-9BF1-4FD0-92C9-92716D7BB631}']
     // ������������� ������ NewList � �������� ���������. ��� bAllocateNewID=True ����� ������������ ����������� �����
     //    ID, ���������� � ������
    procedure PutToList(NewList: IPhotoAlbumPicList; bAllocateNewID: Boolean);
     // ������� ����������� �� ������ (����� ����� ��� ������ ������������, ���� �� ���� ������ ��� ������)
    procedure Release;
     // ��������/���������� � ������� Streamer
     //   -- �������� bEx...Relative ������������, ������������ �� �������������� �������������� <-> ����������� ����
     //      � ����� �����������
     //   -- �������� PProps ���������, ����� �������� ��������� � ��������������� (��� ���� ��� ���������� ������,
     //      ��������� � ������������, �.�. � ������, ����������� ������ ��� ������� ppFileName in PProps)
    procedure StreamerLoad(Streamer: TPhoaStreamer; bExpandRelative: Boolean; PProps: TPicProperties);
    procedure StreamerSave(Streamer: TPhoaStreamer; bExtractRelative: Boolean; PProps: TPicProperties);
     // Prop handlers
    function  GetList: IPhotoAlbumPicList;
     // Props
     // -- ������-�������� �����������
    property List: IPhotoAlbumPicList read GetList;
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
    function  GetProject: IPhotoAlbumProject;
     // Props
     // -- 'Native' version of ItemsByID[]
    property ItemsByIDX[iID: Integer]: IPhotoAlbumPic read GetItemsByIDX;
     // -- 'Native' version of ItemsByFileName[]
    property ItemsByFileNameX[const sFileName: String]: IPhotoAlbumPic read GetItemsByFileNameX;
     // -- 'Native' version of Items[]
    property ItemsX[Index: Integer]: IPhotoAlbumPic read GetItemsX; default;
     // -- ������-��������
    property Project: IPhotoAlbumProject read GetProject;
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
    function  GetPicsX: IPhotoAlbumPicList;
    function  GetRootGroupX: IPhotoAlbumPicGroup;
    function  GetViewsX: IPhotoAlbumViewList;
     // Props
     // -- 'Native' version of Pics
    property PicsX: IPhotoAlbumPicList read GetPicsX;
     // -- 'Native' version of RootGroup
    property RootGroupX: IPhotoAlbumPicGroup read GetRootGroupX;
     // -- 'Native' version of Views
    property ViewsX: IPhotoAlbumViewList read GetViewsX;
  end;

implementation

end.
 