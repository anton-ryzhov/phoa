//**********************************************************************************************************************
//  $Id: phOps.pas,v 1.4 2004-10-15 13:49:35 dale Exp $
//===================================================================================================================---
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phOps;

interface
uses
  Windows, Messages, SysUtils, Classes, Contnrs, phObj, phPhoa, phIntf, phMutableIntf, phNativeIntf;

type  
   // ��������� �������� � ������������� (��������� ����� ����� ���� ������ | �������� � �������������)
  TPictureOperation = (
    popMoveToTarget,     // ����������� ���������� ����������� � ��������� ������
    popCopyToTarget,     // ���������� ���������� ����������� � ��������� ������
    popRemoveFromTarget, // ������� ���������� ����������� �� ��������� ������
    popIntersectTarget); // �������� ������ ���������� ����������� � ��������� ������

   // ����� �������� ������ ������ ��� ������ �����������
  TPicClipboardFormat = (
    pcfPhoa,          // ���������� ������ ������ ��������� (wClipbrdPicFormatID)
    pcfHDrop,         // ������ Shell-�������� (�.�. ������)
    pcfPlainList,     // ������� ��������� ������ ����� � ������
    pcfSingleBitmap); // Bitmap-����������� ������ (� ������ ������������� �����������)
  TPicClipboardFormats = set of TPicClipboardFormat;

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

  TPhoaOperations = class;

   // ����� ������������ ��������� ���������
  TPhoaOperationChange  = (
    pocProjectProps,     // ���������� �������� �������
    pocProjectPicList,   // ���������� ���������� ������ ����������� �������
    pocViewList,         // ���������� ���������� ������ �������������
    pocViewIndex,        // ��������� ������ �������� �������������
    pocGroupStructure,   // ���������� ��������� �����
    pocGroupProps,       // ���������� �������� �����
    pocGroupPicList,     // ���������� ���������� ������� ����������� �����
    pocPicProps);        // ���������� �������� �����������
  TPhoaOperationChanges = set of TPhoaOperationChange;

   // ������� (�����������) �������� �����������, ������������� ������ (������ ������), ������� ����� ���� ��������
  TPhoaOperation = class(TBaseOperation)
  private
     // ������� ������ ������ �������� � Undo-����� ������ ������ (UndoFile)
    FUndoDataPosition: Int64;
     // Prop storage
    FList: TPhoaOperations;
    FProject: IPhotoAlbumProject;
    FOpGroupID: Integer;
    FOpParentGroupID: Integer;
    FOperations: TPhoaOperations;
     // Prop handlers
    function  GetOpGroup: IPhotoAlbumPicGroup;
    function  GetParentOpGroup: IPhotoAlbumPicGroup;
    procedure SetOpGroup(Value: IPhotoAlbumPicGroup);
    procedure SetParentOpGroup(Value: IPhotoAlbumPicGroup);
    function  GetUndoFile: TPhoaUndoFile;
    function  GetOperations: TPhoaOperations;
  protected
     // Prop storage
    FSavepoint: Boolean;
     // �������� ��������� ������ ���������, �������� ���������. � ������� ������ ���������� ���������� ��������
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); virtual;
     // Props
     // -- ���������� ������, ��������������� GroupID
    property OpGroup: IPhotoAlbumPicGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� ParentGroupID
    property OpParentGroup: IPhotoAlbumPicGroup read GetParentOpGroup write SetParentOpGroup;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
    destructor Destroy; override;
     // ���������, ������������ ���������, �������� ��������� (������� RollbackChanges()), � ������������
     //   ������-��������. � Changes ��������� ����� ������ �������� � �������� ������ ���������
    procedure Undo(var Changes: TPhoaOperationChanges);
     // ������������ ��������
    function Name: String;
     // Props
     // -- ������ - �������� ��������
    property List: TPhoaOperations read FList;
     // -- ������ ���������� ��������. �������� ��� ������ ���������
    property Operations: TPhoaOperations read GetOperations;
     // -- ID ������, ������� �������� �������� (���� ��������)
    property OpGroupID: Integer read FOpGroupID;
     // -- ID �������� ������, ������� �������� �������� (���� ��������)
    property OpParentGroupID: Integer read FOpParentGroupID;
     // -- ����������
    property Project: IPhotoAlbumProject read FProject;
     // -- ���������, ��� ����� ������ �������� ���� ����������� ���������� �����������, �.�., ���� ��� �������� -
     //    ��������� � ������ ������, �� ��� ��������� �� unmodified-��������� �����������
    property Savepoint: Boolean read FSavepoint;
     // -- ���� ������ ������ (���������� ����� FList)
    property UndoFile: TPhoaUndoFile read GetUndoFile;
  end;

   // ������ ��������� ��������
  TPhoaOperations = class(TObject)
  private
     // ���������� ������
    FList: TList;
     // Prop storage
    FUndoFile: TPhoaUndoFile;
     // Prop handlers
    function  GetItems(Index: Integer): TPhoaOperation;
    function  GetCanUndo: Boolean;
    function  GetCount: Integer;
  protected
     // ���������� ���� ����� (������������� ��� ��������� ������� ������������� ��������)
    procedure UndoAll(var Changes: TPhoaOperationChanges);
  public
    constructor Create(AUndoFile: TPhoaUndoFile);
    destructor Destroy; override;
     // ��������� �������� � ������, ��������� ������ ���������������� ��������
    function  Add(Item: TPhoaOperation): Integer; virtual;
     // ������� �������� �� ������, ��������� ������ ��������, ������� ��� ����� ����� ���������
    function  Remove(Item: TPhoaOperation): Integer; virtual;
     // ������� �������� �� ������ �� �������
    procedure Delete(Index: Integer); virtual;
     // ������� ������
    procedure Clear; virtual;
     // Props
     // -- ���������� True, ���� � ������ ���� �������� ��� ������
    property CanUndo: Boolean read GetCanUndo;
     // -- ���������� �������� � ������
    property Count: Integer read GetCount;
     // -- ��������������� ������ ��������
    property Items[Index: Integer]: TPhoaOperation read GetItems; default;
     // -- ���� ������ ������
    property UndoFile: TPhoaUndoFile read FUndoFile;
  end;

   // ����� ������ PhoA. �������� ������ *���������������* �������� � �������� ����������� ������ ������
  TPhoaUndo = class(TPhoaOperations)
  private
     // True, ���� "������" ��������� ������ ������ ������������� ����������� ��������� �����������
    FSavepointOnEmpty: Boolean;
     // Prop storage
    FMaxCount: Integer;
     // ������������ ���������� �������� � ������ ������ MaxCount
    procedure LimitCount;
     // Prop handlers
    function  GetLastOpName: String;
    function  GetIsUnmodified: Boolean;
    procedure SetMaxCount(Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function  Add(Item: TPhoaOperation): Integer; override;
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
     // -- ������������ ���������� �������� � ������
    property MaxCount: Integer read FMaxCount write SetMaxCount;
  end;

   //*******************************************************************************************************************
   //
   // �������� ��������
   //
   //*******************************************************************************************************************

   //===================================================================================================================
   // �������� �������� ������ ������� � ������� ������ (CurGroup)
   //===================================================================================================================

  TPhoaOp_GroupNew = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; CurGroup: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupRename = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText: String; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� ������� ������
   //===================================================================================================================

  TPhoaOp_GroupEdit = class(TPhoaOp_GroupRename)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText, sNewDescription: String; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������� ������ (����� �������� ����������� ����� �������� �����������)
   //===================================================================================================================

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������� ������, �������� �� TPhoaOp_GroupDelete, ������� ������ ������ (� �����������) � ��
   //   ��������� � ����������� ������������
   //===================================================================================================================

  TPhoaOp_InternalGroupDelete = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������� �������������� ����������� �� �������
   //===================================================================================================================

  TPhoaOp_InternalUnlinkedPicsRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ����������� �������� �������������� �����������, ������ ����������� ��� ��������:
   //  - TPhoaOp_InternalEditPicProps
   //  - TPhoaOp_InternalEditPicKeywords
   //  - TPhoaOp_InternalPicFromGroupRemoving
   //  - TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  TPhoaOp_PicEdit = class(TPhoaOperation)
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
     // Prop handlers
    function  GetItems(Index: Integer): PPicPropertyChange;
    function  GetChangedProps: TPicProperties;
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
   // ���������� �������� �������������� ������� �����������, ����� �������� ����
   //===================================================================================================================

  TPhoaOp_InternalEditPicProps = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; ChangeList: TPicPropertyChanges; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //===================================================================================================================

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; Keywords: TKeywordList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ���������� �������������� �����������
   //===================================================================================================================

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ���������� ���������� ����������� (������������ ��� ��������� ��� �������� TPhoaOp_InternalPicAdd)
   //===================================================================================================================

  TPhoaOp_PicAdd = class(TPhoaOperation)
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (������������ ��� ����� TPhoaOp_PicAdd � TPhoaOp_PicPaste)
   //===================================================================================================================

  TPhoaOp_InternalPicAdd = class(TPhoaOperation)
  private
     // True, ���� ���� ����������� ��� ��� ��������������� � ����������� �� ���������� �����������
    FExisting: Boolean;
     // ������������ ����������� � ������, ���� ��� ��� �� ����, � ���������� ������ ������
    procedure RegisterPic(Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic);
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sFilename: String; out AddedPic: IPhotoAlbumPic; var Changes: TPhoaOperationChanges); overload;
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic; var Changes: TPhoaOperationChanges); overload;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������
   //===================================================================================================================

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ����������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaBaseOp_PicCopy = class(TBaseOperation)
    constructor Create(Pics: IPhotoAlbumPicList; ClipFormats: TPicClipboardFormats);
  end;

   //===================================================================================================================
   // �������� ��������/��������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaOp_PicDelete = class(TPhoaOperation)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ������� ���������� ����������� �� ������ ������
   //===================================================================================================================

  TPhoaOp_PicPaste = class(TPhoaOperation)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� ������� �������
   //===================================================================================================================

  TPhoaOp_ProjectEdit = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const NewThSize: TSize; bNewThQuality: Byte; const sNewDescription: String; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� [���]��������� �������� � �������������
   //===================================================================================================================

  TPhoaOp_PicOperation = class(TPhoaOperation)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� � ����� ������
   //===================================================================================================================

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //===================================================================================================================

  TPhoaOp_PicSort = class(TPhoaOperation)
  private
     // ����������� (��� bRecursive=True) ���������, ��������� �������� ���������� ������
    procedure AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupDragAndDrop = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group, NewParentGroup: IPhotoAlbumPicGroup; iNewIndex: Integer; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� ����������� � ������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropToGroup = class(TPhoaOperation)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; bCopy: Boolean; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������������� (������������������) ����������� ������ ������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; idxNew: Integer; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewNew = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const sName: String; Groupings: IPhotoAlbumPicGroupingList; Sortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� ��������� �������������
   //===================================================================================================================

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
     // ���� NewGroupings=nil � NewSortings=nil, ������, ��� ������ �������������� �������������
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; View: IPhotoAlbumView; const sNewName: String; NewGroupings: IPhotoAlbumPicGroupingList; NewSortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
  end;

   //===================================================================================================================
   // �������� �������� ������ ����������� �� �������������
   //===================================================================================================================

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  protected
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  public
     // Group - ������, ���� �������� ����� �������������
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  end;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Clipbrd,
  VirtualDataObject, GR32,
  phUtils, phGraphics, ConsVars, phSettings;

   // ������ ����������� IPhotoAlbumPicGroupingList � Undo-����
  procedure UndoWriteGroupings(UndoFile: TPhoaUndoFile; Groupings: IPhotoAlbumPicGroupingList);
  var
    i: Integer;
    Grouping: IPhotoAlbumPicGrouping;
  begin
    UndoFile.WriteInt(Groupings.Count);
    for i := 0 to Groupings.Count-1 do begin
      Grouping := Groupings[i];
      UndoFile.WriteByte(Byte(Grouping.Prop));
      UndoFile.WriteBool(Grouping.UnclassifiedInOwnFolder);
    end;
  end;

   // ������ ����������� IPhotoAlbumPicGroupingList �� Undo-�����
  procedure UndoReadGroupings(UndoFile: TPhoaUndoFile; Groupings: IPhotoAlbumPicGroupingList);
  var
    i: Integer;
    Grouping: IPhotoAlbumPicGrouping;
  begin
    Groupings.Clear;
    for i := 0 to UndoFile.ReadInt-1 do begin
      Grouping := NewPhotoAlbumPicGrouping;
      Grouping.Prop                    := TPicGroupByProperty(UndoFile.ReadByte);
      Grouping.UnclassifiedInOwnFolder := UndoFile.ReadBool;
      Groupings.Add(Grouping);
    end;
  end;

   // ������ ����������� IPhotoAlbumPicSortingList � Undo-����
  procedure UndoWriteSortings(UndoFile: TPhoaUndoFile; Sortings: IPhotoAlbumPicSortingList);
  var
    i: Integer;
    Sorting: IPhotoAlbumPicSorting;
  begin
    UndoFile.WriteInt(Sortings.Count);
    for i := 0 to Sortings.Count-1 do begin
      Sorting := Sortings[i];
      UndoFile.WriteByte(Byte(Sorting.Prop));
      UndoFile.WriteByte(Byte(Sorting.Direction));
    end;
  end;

   // ������ ����������� IPhotoAlbumPicSortingList �� Undo-�����
  procedure UndoReadSortings(UndoFile: TPhoaUndoFile; Sortings: IPhotoAlbumPicSortingList);
  var
    i: Integer;
    Sorting: IPhotoAlbumPicSorting;
  begin
    Sortings.Clear;
    for i := 0 to UndoFile.ReadInt-1 do begin
      Sorting := NewPhotoAlbumPicSorting;
      Sorting.Prop      := TPicProperty(UndoFile.ReadByte);
      Sorting.Direction := TPhoaSortDirection(UndoFile.ReadByte);
      Sortings.Add(Sorting);
    end;
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
    Result := StreamReadByte(FStream)<>0;
  end;

  function TPhoaUndoFile.ReadByte: Byte;
  begin
    ReadCheckDatatype(pufdByte);
    Result := StreamReadByte(FStream);
  end;

  procedure TPhoaUndoFile.ReadCheckDatatype(DTRequired: TPhoaUndoFileDatatype);
  var DTActual: TPhoaUndoFileDatatype;
  begin
    Byte(DTActual) := StreamReadByte(FStream);
    if DTActual<>DTRequired then
      raise Exception.CreateFmt(
        'Invalid undo stream datatype; required: %s, actual: %s',
        [GetEnumName(TypeInfo(TPhoaUndoFileDatatype), Byte(DTRequired)), GetEnumName(TypeInfo(TPhoaUndoFileDatatype), Byte(DTActual))]);
  end;

  function TPhoaUndoFile.ReadInt: Integer;
  begin
    ReadCheckDatatype(pufdInt);
    Result := StreamReadInt(FStream);
  end;

  function TPhoaUndoFile.ReadStr: String;
  begin
    ReadCheckDatatype(pufdStr);
    Result := StreamReadStr(FStream);
  end;

  procedure TPhoaUndoFile.WriteBool(b: Boolean);
  begin
    WriteDatatype(pufdBool);
    StreamWriteByte(FStream, Byte(b));
  end;

  procedure TPhoaUndoFile.WriteByte(b: Byte);
  begin
    WriteDatatype(pufdByte);
    StreamWriteByte(FStream, b);
  end;

  procedure TPhoaUndoFile.WriteDatatype(DT: TPhoaUndoFileDatatype);
  begin
    StreamWriteByte(FStream, Byte(DT));
  end;

  procedure TPhoaUndoFile.WriteInt(i: Integer);
  begin
    WriteDatatype(pufdInt);
    StreamWriteInt(FStream, i);
  end;

  procedure TPhoaUndoFile.WriteStr(const s: String);
  begin
    WriteDatatype(pufdStr);
    StreamWriteStr(FStream, s);
  end;

   //===================================================================================================================
   // TPhoaOperation
   //===================================================================================================================

  constructor TPhoaOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
  begin
    FList := AList;
    FList.Add(Self);
    FProject          := AProject;
    FUndoDataPosition := FList.UndoFile.Position;
  end;

  destructor TPhoaOperation.Destroy;
  begin
    FProject := nil;
    FOperations.Free;
    FList.Remove(Self);
    inherited Destroy;
  end;

  function TPhoaOperation.GetOperations: TPhoaOperations;
  begin
    if FOperations=nil then FOperations := TPhoaOperations.Create(List.UndoFile);
    Result := FOperations;
  end;

  function TPhoaOperation.GetOpGroup: IPhotoAlbumPicGroup;
  begin
    Result := FProject.RootGroupX.GroupByIDX[FOpGroupID];
  end;

  function TPhoaOperation.GetParentOpGroup: IPhotoAlbumPicGroup;
  begin
    Result := FProject.RootGroupX.GroupByIDX[FOpParentGroupID];
  end;

  function TPhoaOperation.GetUndoFile: TPhoaUndoFile;
  begin
    Result := FList.UndoFile;
  end;

  function TPhoaOperation.Name: String;
  begin
    Result := ConstVal(ClassName);
  end;

  procedure TPhoaOperation.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
    if FOperations<>nil then FOperations.UndoAll(Changes);
  end;

  procedure TPhoaOperation.SetOpGroup(Value: IPhotoAlbumPicGroup);
  begin
    FOpGroupID := Value.ID;
  end;

  procedure TPhoaOperation.SetParentOpGroup(Value: IPhotoAlbumPicGroup);
  begin
    FOpParentGroupID := Value.ID;
  end;

  procedure TPhoaOperation.Undo(var Changes: TPhoaOperationChanges);
  begin
    try
       // ������������� undo-���� � ����������� �������
      UndoFile.BeginUndo(FUndoDataPosition);
      try
         // ���������� ���������
        RollbackChanges(Changes);
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
    Result := FList.Add(Item);
  end;

  procedure TPhoaOperations.Clear;
  var i: Integer;
  begin
    for i := FList.Count-1 downto 0 do Delete(i);
  end;

  constructor TPhoaOperations.Create(AUndoFile: TPhoaUndoFile);
  begin
    inherited Create;
    FList := TList.Create;
    FUndoFile := AUndoFile;
  end;

  procedure TPhoaOperations.Delete(Index: Integer);
  begin
    GetItems(Index).Free;
  end;

  destructor TPhoaOperations.Destroy;
  begin
    Clear;
    FList.Free;
    inherited Destroy;
  end;

  function TPhoaOperations.GetCanUndo: Boolean;
  begin
    Result := FList.Count>0;
  end;

  function TPhoaOperations.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TPhoaOperations.GetItems(Index: Integer): TPhoaOperation;
  begin
    Result := TPhoaOperation(FList[Index]);
  end;

  function TPhoaOperations.Remove(Item: TPhoaOperation): Integer;
  begin
    Result := FList.Remove(Item);
  end;

  procedure TPhoaOperations.UndoAll(var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
    for i := FList.Count-1 downto 0 do GetItems(i).Undo(Changes);
  end;

   //===================================================================================================================
   // TPhoaUndo
   //===================================================================================================================

  function TPhoaUndo.Add(Item: TPhoaOperation): Integer;
  begin
    Result := inherited Add(Item);
     // ������������ ������ ������
    LimitCount; 
  end;

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
    FMaxCount := MaxInt;
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

  procedure TPhoaUndo.LimitCount;
  var i: Integer;
  begin
    for i := Count-1 downto FMaxCount do Delete(i);
  end;

  procedure TPhoaUndo.SetMaxCount(Value: Integer);
  begin
    if FMaxCount<>Value then begin
      FMaxCount := Value;
      LimitCount;
    end;
  end;

  procedure TPhoaUndo.SetNonUndoable;
  begin
    Clear;
    FSavepointOnEmpty := False;
  end;

  procedure TPhoaUndo.SetSavepoint;
  var i: Integer;
  begin
    for i := 0 to Count-1 do Items[i].FSavepoint := i=Count-1;
    FSavepointOnEmpty := Count=0;
  end;

   //===================================================================================================================
   // TPhoaOp_NewGroup
   //===================================================================================================================

  constructor TPhoaOp_GroupNew.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; CurGroup: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  var g: IPhotoAlbumPicGroup;
  begin
    inherited Create(AList, AProject, Changes);
     // ������ �������� ������
    g := NewPhotoAlbumPicGroup(CurGroup, Project.RootGroupX.MaxGroupID+1);
    g.Text := ConstVal('SDefaultNewGroupName');
    OpParentGroup := CurGroup;
    OpGroup       := g;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_GroupNew.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // ������� ������ ��������
    OpGroup.Owner := nil;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupRename
   //===================================================================================================================

  constructor TPhoaOp_GroupRename.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText: String; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ���������� ������ ������
    OpGroup := Group;
    UndoFile.WriteStr(Group.Text);
     // ��������� ��������
    Group.Text := sNewText;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
  end;

  procedure TPhoaOp_GroupRename.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // �������� ������ � ��������������� �����
    OpGroup.Text := UndoFile.ReadStr;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupEdit
   //===================================================================================================================

  constructor TPhoaOp_GroupEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText, sNewDescription: String; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Group, sNewText, Changes);
     // ���������� ������ ������
    UndoFile.WriteStr(Group.Description);
     // ��������� ��������
    Group.Description := sNewDescription;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
  end;

  procedure TPhoaOp_GroupEdit.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // �������� ������ � ��������������� ��������
    OpGroup.Description := UndoFile.ReadStr;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDelete
   //===================================================================================================================

  constructor TPhoaOp_GroupDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ������� ������ (� ���������)
    TPhoaOp_InternalGroupDelete.Create(Operations, Project, Group, Changes);
     // ������� �������������� �����������
    TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupDelete
   //===================================================================================================================

  constructor TPhoaOp_InternalGroupDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
    inherited Create(AList, AProject, Changes);
     // ���������� ������ ��������� ������
    OpGroup       := Group;
    OpParentGroup := Group.OwnerX;
    UndoFile.WriteStr (Group.Text);
    UndoFile.WriteStr (Group.Description);
    UndoFile.WriteInt (Group.Index);
    UndoFile.WriteBool(Group.Expanded);
     // ���������� ID ����������� � ������� �����������
    UndoFile.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoFile.WriteInt(Group.Pics[i].ID);
    Group.PicsX.Clear;
     // �������� ������� ������
    for i := 0 to Group.Groups.Count-1 do TPhoaOp_InternalGroupDelete.Create(Operations, Project, Group.GroupsX[i], Changes);
     // ������� ������
    Group.Owner := nil;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_InternalGroupDelete.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
  begin
     // ��������������� ������
    g := NewPhotoAlbumPicGroup(OpParentGroup, OpGroupID);
    g.Text        := UndoFile.ReadStr;
    g.Description := UndoFile.ReadStr;
    g.Index       := UndoFile.ReadInt;
    g.Expanded    := UndoFile.ReadBool;
     // ��������������� �����������
    for i := 0 to UndoFile.ReadInt-1 do g.PicsX.Add(Project.Pics.ItemsByID[UndoFile.ReadInt], False);
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
     // ��������������� ��������� ������
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalUnlinkedPicsRemoving
   //===================================================================================================================

  constructor TPhoaOp_InternalUnlinkedPicsRemoving.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Pic: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject, Changes);
     // ���� �� ���� ������������ �����������
    for i := Project.Pics.Count-1 downto 0 do begin
      Pic := Project.PicsX[i];
       // ���� ����������� �� ������� �� � ����� �������
      if not Project.RootGroup.IsPicLinked(Pic.ID, True) then begin
         // ����� ���� �����������
        UndoFile.WriteBool(True);
         // ��������� ������ �����������
        UndoFile.WriteStr(Pic.RawData[PPAllProps]);
         // ������� ����������� �� ������
        Pic.Release;
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_InternalUnlinkedPicsRemoving.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // ������ ������, ���� �� �������� ����-����
    while UndoFile.ReadBool do
       // ������ �����������
      with NewPhotoAlbumPic do begin
         // ��������� ������
        RawData[PPAllProps] := UndoFile.ReadStr;
         // ����� � ������ (ID ��� ��������)
        PutToList(Project.PicsX, False);
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
    inherited RollbackChanges(Changes);
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
    if Action=lnDeleted then Dispose(PPicPropertyChange(Ptr));
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicProps
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicProps.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; ChangeList: TPicPropertyChanges; var Changes: TPhoaOperationChanges);
  var
    iPic, iChg: Integer;
    Pic: IPhotoAlbumPic;
    ChangedProps: TPicProperties;
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ����� ������������ �������
    ChangedProps := ChangeList.ChangedProps;
    UndoFile.WriteInt(PicPropsToInt(ChangedProps));
     // ��������� ���������� �����������
    UndoFile.WriteInt(Pics.Count);
     // ���� �� ������������
    for iPic := 0 to Pics.Count-1 do begin
       // ���������� ������ ������
      Pic := Pics[iPic];
      UndoFile.WriteInt(Pic.ID);
      UndoFile.WriteStr(Pic.RawData[ChangedProps]);
       // ��������� ����� ������
      for iChg := 0 to ChangeList.Count-1 do
        with ChangeList[iChg]^ do Pic.Props[Prop] := sNewValue;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
  end;

  procedure TPhoaOp_InternalEditPicProps.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    i, iPicID: Integer;
    ChangedProps: TPicProperties;
    sPicData: String;
  begin
     // �������� ����� ��������� �������
    ChangedProps := IntToPicProps(UndoFile.ReadInt);
     // ���������� ������ ��������� �����������
    for i := 0 to UndoFile.ReadInt-1 do begin
      iPicID   := UndoFile.ReadInt;
      sPicData := UndoFile.ReadStr;
      Project.PicsX.ItemsByIDX[iPicID].RawData[ChangedProps] := sPicData;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicKeywords
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicKeywords.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; Keywords: TKeywordList; var Changes: TPhoaOperationChanges);
  var
    iPic, iCnt, iKwd, idxKeyword: Integer;
    Pic: IPhotoAlbumPic;
    pkr: PKeywordRec;
    bKWSaved: Boolean;
    PicKeywords: IPhoaMutableKeywordList;

     // ��������� �������� ����� ����������� � FSavedKeywords, ���� ����� ��� �� �������
    procedure SavePicKeywords;
    begin
      if not bKWSaved then begin
        UndoFile.WriteBool(True); // ������� ������ ��������� ����� (� ����������������� ����-�����)
        UndoFile.WriteInt(Pic.ID);
        UndoFile.WriteStr(Pic.Keywords.CommaText);
        bKWSaved := True;
         // ��������� ����� ���������
        Include(Changes, pocPicProps);
      end;
    end;

  begin
    inherited Create(AList, AProject, Changes);
     // ���� �� ������������
    iCnt := Pics.Count;
    for iPic := 0 to iCnt-1 do begin
      Pic := Pics[iPic];
      PicKeywords := Pic.KeywordsM;
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
              idxKeyword := PicKeywords.IndexOf(pkr.sKeyword);
              case pkr.State of
                 // ���� ������ ��. ���� ��� ���� - �������
                ksOff:
                  if idxKeyword>=0 then begin
                    SavePicKeywords;
                    PicKeywords.Delete(idxKeyword);
                  end;
                 // ���� �������� ��. ���� ��� - ���������
                ksOn:
                  if idxKeyword<0 then begin
                    SavePicKeywords;
                    PicKeywords.Add(pkr.sKeyword);
                  end;
              end;
            end;
           // ���������� ������ ��. ���� ���� ����� - ���� ��������
          kcAdd:
            if pkr.State=ksOn then begin
              SavePicKeywords;
              PicKeywords.Add(pkr.sKeyword);
            end;
           // �� ��������. ���� ������ ��� �� ��������� ������������� � �����������, ...
          kcReplace:
            if (pkr.State<>ksOff) or (pkr.iSelCount>0) then begin
               // ... ���� ������ �� � �������, ...
              idxKeyword := PicKeywords.IndexOf(pkr.sOldKeyword);
              if idxKeyword>=0 then begin
                SavePicKeywords;
                PicKeywords.Delete(idxKeyword);
              end;
               // ... ���� ��������� ksOn - ��������� ����� ����, ���� ksGrayed - ��������� ������ � ��, ��� ���� ������
              if (pkr.State=ksOn) or ((pkr.State=ksGrayed) and (idxKeyword>=0)) then begin
                SavePicKeywords;
                PicKeywords.Add(pkr.sKeyword);
              end;
            end;
        end;
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalEditPicKeywords.RollbackChanges(var Changes: TPhoaOperationChanges);
  var iPicID: Integer;
  begin
     // ���������� �� ��������� ������������: ������ ����, ���� �� �������� ����-����
    while UndoFile.ReadBool do begin
      iPicID    := UndoFile.ReadInt;
      Project.PicsX.ItemsByIDX[iPicID].KeywordsM.CommaText := UndoFile.ReadStr;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_StoreTransform
   //===================================================================================================================

  constructor TPhoaOp_StoreTransform.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ������� ��������
    UndoFile.WriteInt(Pic.ID);
    UndoFile.WriteByte(Byte(Pic.Rotation));
    UndoFile.WriteByte(Byte(Pic.Flips));
     // ��������� ����� ��������
    Pic.Rotation := NewRotation;
    Pic.Flips    := NewFlips;
     // ��������� ����� ���������
    Include(Changes, pocPicProps);
  end;

  procedure TPhoaOp_StoreTransform.RollbackChanges(var Changes: TPhoaOperationChanges);
  var Pic: IPhotoAlbumPic;
  begin
    Pic          := Project.PicsX.ItemsByIDX[UndoFile.ReadInt];
    Pic.Rotation := TPicRotation(UndoFile.ReadByte);
    Pic.Flips    := TPicFlips(Byte(UndoFile.ReadByte)); // �������� typecast, �� ����� �� �������������
     // ��������� ����� ���������
    Include(Changes, pocPicProps);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicAdd
   //===================================================================================================================

  constructor TPhoaOp_InternalPicAdd.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sFilename: String; out AddedPic: IPhotoAlbumPic; var Changes: TPhoaOperationChanges);
  var Pic: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject, Changes);
     // ���� ��� ������������ ����������� � ��� �� ������
    Pic := Project.PicsX.ItemsByFileNameX[sFilename];
    FExisting := Pic<>nil;
     // ���� ���� ��� �� �������������, ������ ��������� �����������
    if not FExisting then begin
      Pic := NewPhotoAlbumPic;
       // ��������� � ������, ������� ID
      Pic.PutToList(Project.PicsX, True);
       // ����������� ��� ����� � ������ �����
      Pic.FileName := sFilename;
      Pic.ReloadPicFileData(Project.ThumbnailSize, TPhoaStretchFilter(SettingValueInt(ISettingID_Browse_ViewerStchFilt)), Project.ThumbnailQuality);
       // ��������� ����� ���������
      Include(Changes, pocProjectPicList);
    end;
     // ��������� � ������
    RegisterPic(Group, Pic);
    AddedPic := Pic;
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
  end;

  constructor TPhoaOp_InternalPicAdd.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic; var Changes: TPhoaOperationChanges);
  var PicEx: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject, Changes);
     // ���� ��� ������������ ����������� � ��� �� ������
    PicEx := Project.PicsX.ItemsByFileNameX[Pic.FileName];
    FExisting := PicEx<>nil;
     // ���� ����� ����������� - ������� � ������, ����������� ����� ID. ����� ���������� Pic
    if not FExisting then begin
      Pic.PutToList(Project.PicsX, True);
       // ��������� ����� ���������
      Include(Changes, pocProjectPicList);
    end else
      Pic := PicEx;
     // ��������� � ������
    RegisterPic(Group, Pic);
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
  end;

  procedure TPhoaOp_InternalPicAdd.RegisterPic(Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic);
  var bAdded: Boolean;
  begin
     // ��������� ����������� � ������, ���� ��� �� ����
    Group.PicsX.Add(Pic, True, bAdded);
    if bAdded then begin
       // ��������� ������ ��� ������
      OpGroup := Group;
      UndoFile.WriteInt(Pic.ID);
    end else
      UndoFile.WriteInt(0);
  end;

  procedure TPhoaOp_InternalPicAdd.RollbackChanges(var Changes: TPhoaOperationChanges);
  var iPicID: Integer;
  begin
     // ���� ������� �������� ���� �������
    iPicID := UndoFile.ReadInt;
    if iPicID>0 then begin
       // ������� �� ������
      OpGroup.PicsX.Remove(iPicID);
       // ��������� ����� ���������
      Include(Changes, pocGroupPicList);
       // ���� ���� ��������� ����� �����������, ������� � �� �����������
      if not FExisting then begin
        Project.PicsX.ItemsByIDX[iPicID].Release;
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicFromGroupRemoving
   //===================================================================================================================

  constructor TPhoaOp_InternalPicFromGroupRemoving.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  var i, idx: Integer;
  begin
    inherited Create(AList, AProject, Changes);
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
        Group.PicsX.Delete(idx);
         // ��������� ����� ���������
        Include(Changes, pocGroupPicList);
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalPicFromGroupRemoving.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
    IIs: TIntegerList;
  begin
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
        g.PicsX.Insert(IIs[i+1], Project.Pics.ItemsByID[IIs[i]], False);
        Dec(i, 2);
         // ��������� ����� ���������
        Include(Changes, pocGroupPicList);
      end;
    finally
      IIs.Free;
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  constructor TPhoaOp_InternalPicToGroupAdding.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    bAdded: Boolean;
    Pic: IPhoaPic;
  begin
    inherited Create(AList, AProject, Changes);
    OpGroup := Group;
     // ��������� ����������� � ������ � � undo-����
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
      Group.PicsX.Add(Pic, True, bAdded);
      if bAdded then begin
        UndoFile.WriteBool(True); // ���� �����������
        UndoFile.WriteInt (Pic.ID);
         // ��������� ����� ���������
        Include(Changes, pocGroupPicList);
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_InternalPicToGroupAdding.RollbackChanges(var Changes: TPhoaOperationChanges);
  var g: IPhotoAlbumPicGroup;
  begin
     // ������� ����������� ����������� (��������� ID ����������� ����������� �� �����, ���� �� �������� ����-����)
    g := OpGroup;
    while UndoFile.ReadBool do begin
      g.PicsX.Remove(UndoFile.ReadInt);
       // ��������� ����� ���������
      Include(Changes, pocGroupPicList);
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaBaseOp_PicCopy
   //===================================================================================================================

  constructor TPhoaBaseOp_PicCopy.Create(Pics: IPhotoAlbumPicList; ClipFormats: TPicClipboardFormats);

     // �������� � ����� ������ ������ ����������� PhoA
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
            Pics[i].StreamerSave(Streamer, False, PPAllProps);
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
        with THDrop.Create do
          try
             // �������� ������ ������ � THDrop
            AssignFiles(SL);
             // �������� ����� � clipboard
            SaveToClipboard(True);
          finally
            Free;
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
    var bmp32: TBitmap32;
    begin
       // ������������ �����
      bmp32 := TBitmap32.Create;
      try
        bmp32.SetSize(Pic.ThumbnailSize.cx, Pic.ThumbnailSize.cy);
        PaintThumbnail(Pic, bmp32);
         // �������� bitmap � clipboard
        Clipboard.Assign(bmp32);
      finally
        bmp32.Free;
      end;
    end;

  begin
    StartWait;
    try
      if Pics.Count>0 then begin
        Clipboard.Open;
        try
           // �������� PhoA-������
          if pcfPhoa in ClipFormats then CopyPhoaData;
           // �������� ������� "����"
          if pcfHDrop in ClipFormats then CopyFileObjects;
           // �������� ������ ����� ������
          if pcfPlainList in ClipFormats then CopyFileList;
           // �������� ����������� ������ (� ������ ������������� �����������)
          if (pcfSingleBitmap in ClipFormats) and (Pics.Count=1) then CopyThumbBitmap(Pics[0]);
        finally
          Clipboard.Close;
        end;
      end;
    finally
      StopWait;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicDelete
   //===================================================================================================================

  constructor TPhoaOp_PicDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ������� ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, Group, Pics, Changes);
     // ������� ����������� ����������� �� �����������
    TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicPaste
   //===================================================================================================================

  constructor TPhoaOp_PicPaste.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  var
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
    Pic: IPhotoAlbumPic;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    inherited Create(AList, AProject, Changes);
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
                  Pic := NewPhotoAlbumPic;
                  Pic.StreamerLoad(Streamer, False, PPAllProps);
                   // ������ �������� �������� ���������� �����������
                  TPhoaOp_InternalPicAdd.Create(Operations, Project, Group, Pic, Changes);
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
   // TPhoaOp_ProjectEdit
   //===================================================================================================================

  constructor TPhoaOp_ProjectEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const NewThSize: TSize; bNewThQuality: Byte; const sNewDescription: String; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ������ ��������
    UndoFile.WriteInt (Project.ThumbnailSize.cx);
    UndoFile.WriteInt (Project.ThumbnailSize.cy);
    UndoFile.WriteByte(Project.ThumbnailQuality);
    UndoFile.WriteStr (Project.Description);
     // ��������� ��������
    Project.ThumbnailSize    := NewThSize;
    Project.ThumbnailQuality := bNewThQuality;
    Project.Description      := sNewDescription;
     // ��������� ����� ���������
    Include(Changes, pocProjectProps);
  end;

  procedure TPhoaOp_ProjectEdit.RollbackChanges(var Changes: TPhoaOperationChanges);
  var Sz: TSize;
  begin
     // ��������������� �������� �����������
    Sz.cx   := UndoFile.ReadInt;
    Sz.cy   := UndoFile.ReadInt;
    Project.ThumbnailSize    := Sz;
    Project.ThumbnailQuality := UndoFile.ReadByte;
    Project.Description      := UndoFile.ReadStr;
     // ��������� ����� ���������
    Include(Changes, pocProjectProps);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicOperation
   //===================================================================================================================

  constructor TPhoaOp_PicOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    IntersectPics: IPhoaMutablePicList;
    Pic: IPhoaPic;
  begin
    inherited Create(AList, AProject, Changes);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then TPhoaOp_InternalPicToGroupAdding.Create(Operations, Project, TargetGroup, Pics, Changes);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, SourceGroup, Pics, Changes);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, TargetGroup, Pics, Changes);
     // �������� ������ ���������� ����������� � ��������� ������
    if PicOperation=popIntersectTarget then begin
      IntersectPics := NewPhotoAlbumPicList(False);
      for i := 0 to TargetGroup.Pics.Count-1 do begin
        Pic := TargetGroup.Pics[i];
        if Pics.IndexOfID(Pic.ID)<0 then IntersectPics.Add(Pic, False);
      end;
      if IntersectPics.Count>0 then begin
        TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, TargetGroup, IntersectPics, Changes);
        TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, Changes);
      end;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  constructor TPhoaOp_InternalGroupPicSort.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
    inherited Create(AList, AProject, Changes);
     // ���������� ������
    OpGroup := Group;
     // ���������� ������� ���������� ID ����������� � ������
    UndoFile.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoFile.WriteInt(Group.Pics[i].ID);
     // ��������� ����������� � ������
    Group.PicsX.SortingsSort(Sortings);
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
  end;

  procedure TPhoaOp_InternalGroupPicSort.RollbackChanges(var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
     // ��������������� ������ ������� ���������� ID ����������� � ������
    OpGroup.PicsX.Clear;
    for i := 0 to UndoFile.ReadInt-1 do OpGroup.PicsX.Add(Project.Pics.ItemsByID[UndoFile.ReadInt], False);
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicSort
   //===================================================================================================================

  procedure TPhoaOp_PicSort.AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
     // ��������� ����������� � ������
    TPhoaOp_InternalGroupPicSort.Create(Operations, Project, Group, Sortings, Changes);
     // ��� ������������� ��������� � � ����������
    if bRecursive then
      for i := 0 to Group.Groups.Count-1 do AddGroupSortOp(Group.GroupsX[i], Sortings, True, Changes);
  end;

  constructor TPhoaOp_PicSort.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ����������
    AddGroupSortOp(Group, Sortings, bRecursive, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDragAndDrop
   //===================================================================================================================

  constructor TPhoaOp_GroupDragAndDrop.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group, NewParentGroup: IPhotoAlbumPicGroup; iNewIndex: Integer; var Changes: TPhoaOperationChanges);
  var gOldParent: IPhotoAlbumPicGroup;
  begin
    inherited Create(AList, AProject, Changes);
     // ���������� ������ ������
    gOldParent := Group.OwnerX;
    UndoFile.WriteInt(Group.Index);
     // ���������� ������
    Group.Owner := NewParentGroup;
    if iNewIndex>=0 then Group.Index := iNewIndex; // ������ -1 �������� ���������� ��������� �������
     // ���������� ������ (ID �������� �������� � ID ������)
    OpParentGroup := gOldParent;
    OpGroup       := Group;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_GroupDragAndDrop.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // ��������������� ��������� ������
    with OpGroup do begin
      Owner := OpParentGroup;
      Index := UndoFile.ReadInt;
    end;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropToGroup
   //===================================================================================================================

  constructor TPhoaOp_PicDragAndDropToGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; bCopy: Boolean; var Changes: TPhoaOperationChanges);
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(Operations, Project, TargetGroup, Pics, Changes);
    if not bCopy then TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, SourceGroup, Pics, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  constructor TPhoaOp_PicDragAndDropInsideGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; idxNew: Integer; var Changes: TPhoaOperationChanges);
  var i, idxOld: Integer;
  begin
    inherited Create(AList, AProject, Changes);
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
      Group.PicsX.Move(idxOld, idxNew);
      Inc(idxNew);
       // ��������� ����� ���������
      Include(Changes, pocGroupPicList);
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_PicDragAndDropInsideGroup.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
    Indexes: TIntegerList;
  begin
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
        g.PicsX.Move(Indexes[i+1], Indexes[i]);
        Dec(i, 2);
      end;
    finally
      Indexes.Free;
    end;
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewNew
   //===================================================================================================================

  constructor TPhoaOp_ViewNew.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const sName: String; Groupings: IPhotoAlbumPicGroupingList; Sortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  var
    View: IPhotoAlbumView;
    iNewViewIndex: Integer;
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ���������� ������ �������������
    UndoFile.WriteInt(Project.ViewIndex);
     // ��������� ��������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name := sName;
    View.GroupingsX.Assign(Groupings);
    View.SortingsX.Assign(Sortings);
     // ��������� ����� ������ �������������
    iNewViewIndex := View.Index;
    UndoFile.WriteInt(iNewViewIndex);
     // ����������� ������
    Project.ViewIndex := iNewViewIndex;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
  end;

  procedure TPhoaOp_ViewNew.RollbackChanges(var Changes: TPhoaOperationChanges);
  var iPrevViewIndex, iNewViewIndex: Integer;
  begin
     // �������� ���������� ������
    iPrevViewIndex := UndoFile.ReadInt;
    iNewViewIndex  := UndoFile.ReadInt;
     // ������� �������������
    Project.ViewsX.Delete(iNewViewIndex);
     // ��������������� ������� ��������� �������������
    Project.ViewIndex := iPrevViewIndex;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewEdit
   //===================================================================================================================

  constructor TPhoaOp_ViewEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; View: IPhotoAlbumView; const sNewName: String; NewGroupings: IPhotoAlbumPicGroupingList; NewSortings: IPhotoAlbumPicSortingList; var Changes: TPhoaOperationChanges);
  var bWriteGroupings, bWriteSortings: Boolean;
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ������ ������ � ��������� ���������
    UndoFile.WriteStr(View.Name);
    View.Name := sNewName;
     // ���������� ����� ������ ������������� (����� ���������� �����, �.�. ��� �������� ������� ������������� � ������)
    UndoFile.WriteInt(View.Index);
     // ������ ����������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    bWriteGroupings := (NewGroupings<>nil) and not View.Groupings.IdenticalWith(NewGroupings);
     // ����� ������� ������� �����������
    UndoFile.WriteBool(bWriteGroupings);
    if bWriteGroupings then begin
      UndoWriteGroupings(UndoFile, View.GroupingsX);
      View.GroupingsX.Assign(NewGroupings);
      View.Invalidate;
    end;
     // ������ ���������� ������ � ��������� ������ � ��� ������, ���� ��� �� �������������� � �� �����������
    bWriteSortings := (NewSortings<>nil) and not View.Sortings.IdenticalWith(NewSortings);
     // ����� ������� ������� ����������
    UndoFile.WriteBool(bWriteSortings);
    if bWriteSortings then begin
      UndoWriteSortings(UndoFile, View.SortingsX);
      View.SortingsX.Assign(NewSortings);
      View.Invalidate;
    end;
     // ��������� ������� ������ ������������� (��� ���������� ����� �������������� �������������)
    Project.ViewIndex := View.Index;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
  end;

  procedure TPhoaOp_ViewEdit.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    sViewName: String;
    iViewIndex: Integer;
    View: IPhotoAlbumView;
  begin
     // ��������������� �������������
    sViewName  := UndoFile.ReadStr;
    iViewIndex := UndoFile.ReadInt;
    View := Project.ViewsX[iViewIndex];
    View.Name := sViewName;
    if UndoFile.ReadBool then UndoReadGroupings(UndoFile, View.GroupingsX);
    if UndoFile.ReadBool then UndoReadSortings (UndoFile, View.SortingsX);
    View.Invalidate;
     // ��������� ������� ������ ������������� (��� ���������� ����� �������������� �������������)
    Project.ViewIndex := View.Index;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewDelete
   //===================================================================================================================

  constructor TPhoaOp_ViewDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; var Changes: TPhoaOperationChanges);
  var View: IPhotoAlbumView;
  begin
    inherited Create(AList, AProject, Changes);
     // ��������� ������ ������
    View := Project.CurrentViewX;
    UndoFile.WriteStr(View.Name);
    UndoWriteGroupings(UndoFile, View.GroupingsX);
    UndoWriteSortings (UndoFile, View.SortingsX);
     // ������� �������������
    Project.ViewsX.Delete(Project.ViewIndex);
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
  end;

  procedure TPhoaOp_ViewDelete.RollbackChanges(var Changes: TPhoaOperationChanges);
  var View: IPhotoAlbumView;
  begin
      // ������ �������������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name := UndoFile.ReadStr;
    UndoReadGroupings(UndoFile, View.GroupingsX);
    UndoReadSortings (UndoFile, View.SortingsX);
     // ������������ �������������
    Project.ViewIndex := View.Index;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewMakeGroup
   //===================================================================================================================

  constructor TPhoaOp_ViewMakeGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; var Changes: TPhoaOperationChanges);
  var
    g: IPhotoAlbumPicGroup;
    View: IPhotoAlbumView;
  begin
    inherited Create(AList, AProject, Changes);
    View := Project.CurrentViewX;
     // ������ ������ (���������� � �������� ID)
    g := NewPhotoAlbumPicGroup(Group, 0);
    g.Assign(View.RootGroup, False, True, True);
    g.Text := View.Name;
     // ������������ ������� ��������� ID
    Project.RootGroupX.FixupIDs;
     // ���������� ��������� (��������) ������ 
    OpGroup := g;
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
     // ��������� ����� ���������
    Changes := Changes+[pocViewIndex, pocGroupStructure];
  end;

  procedure TPhoaOp_ViewMakeGroup.RollbackChanges(var Changes: TPhoaOperationChanges);
  begin
     // ������� �������� ������ ����� �������������
    OpGroup.Owner := nil;
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
     // ��������� ����� ���������
    Changes := Changes+[pocViewIndex, pocGroupStructure];
    inherited RollbackChanges(Changes);
  end;

end.
