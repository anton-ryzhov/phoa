//**********************************************************************************************************************
//  $Id: phOps.pas,v 1.3 2004-10-13 14:29:09 dale Exp $
//===================================================================================================================---
//  PhoA image arranging and searching tool
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phOps;

interface
uses
  Windows, Messages, SysUtils, Classes, phObj, phPhoa, phIntf, phMutableIntf, phNativeIntf;

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

   // ����� ���������� ���������� �������� ������
  TUndoInvalidationFlag  = (
     // -- ����� �������� ��� ���������� (eXecution)
    uifXReloadViews,         // ����������� ������ ������������� (� �������� ������ �������� �������������)
    uifXUpdateViewIndex,     // �������� ������ �������� ������������� (��� ����������)
    uifXReinitParent,        // �������������������� �������� ���� ������ ��������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifXReinitSiblings,      // �������������������� �������� � ����� ������ �������� ���� ������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifXReinitRecursive,     // ��� ����������������� (����� uifXReinitParent � uifXReinitSiblings) ����������� ����������
    uifXEditGroup,           // ������ ���� ������ Op.GroupAbsIdx � ����� �������������� ��� ������. ������ ���� ��������� Op.GroupAbsIdx
    uifXUpdateThumbParams,   // �������� ��������� ������� (����� ����������)
     // -- ����� �������� ��� ������ (Undoing)
    uifUReloadViews,         // ����������� ������ ������������� (� �������� ������ �������� �������������)
    uifUUpdateViewIndex,     // �������� ������ �������� �������������
    uifUReinitAll,           // �������������������� ��� ���� ������
    uifUReinitParent,        // �������������������� �������� ���� ������ ��������. ������ ���� ��������� Op.ParentGroupAbsIdx
    uifUReinitRecursive,     // ��� ����������������� (���� uifUReinitParent) ����������� ����������
    uifUUpdateThumbParams);  // �������� ��������� ������� (����� ����������)

  TUndoInvalidationFlags = set of TUndoInvalidationFlag;

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
     // Prop handlers
    function  GetOpGroup: IPhotoAlbumPicGroup;
    function  GetParentOpGroup: IPhotoAlbumPicGroup;
    procedure SetOpGroup(Value: IPhotoAlbumPicGroup);
    procedure SetParentOpGroup(Value: IPhotoAlbumPicGroup);
    function  GetUndoFile: TPhoaUndoFile;
  protected
     // Prop storage
    FSavepoint: Boolean;
     // Prop handlers
    function  GetInvalidationFlags: TUndoInvalidationFlags; virtual;
     // �������� ��������� ������ ���������, �������� ���������. � ������� ������ �� ������ ������
    procedure RollbackChanges; virtual;
     // Props
     // -- ���������� ������, ��������������� GroupID
    property OpGroup: IPhotoAlbumPicGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� ParentGroupID
    property OpParentGroup: IPhotoAlbumPicGroup read GetParentOpGroup write SetParentOpGroup;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
    destructor Destroy; override;
     // ���������, ������������ ���������, �������� ��������� (������� RollbackChanges()), � ������������
     //   ������-��������
    procedure Undo; 
     // ������������ ��������
    function Name: String;
     // Props
     // -- ����� ���������� ���������� ����� ������ ��������
    property InvalidationFlags: TUndoInvalidationFlags read GetInvalidationFlags;
     // -- ������ - �������� ��������
    property List: TPhoaOperations read FList;
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
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
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
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; CurGroup: IPhotoAlbumPicGroup);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupRename = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText: String);
  end;

   //===================================================================================================================
   // �������� �������������� ������� ������
   //===================================================================================================================

  TPhoaOp_GroupEdit = class(TPhoaOp_GroupRename)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText, sNewDescription: String);
  end;

   //===================================================================================================================
   // �������� �������� ������
   //===================================================================================================================

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  private
     // ������ �������� ��������� �����
    FCascadedDeletes: TPhoaOperations;
     // �������� �������� �������������� �����������
    FUnlinkedPicsRemove: TPhoaOperation;
     // ������ ID ����������� ������
    FPicIDs: TIntegerList;
     // ���������� (���������������� �� ������������� ������� ���������� Owner-�) ��������� ������
    procedure InternalRollback(gOwner: IPhotoAlbumPicGroup);
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
     // �������� bPerform ������������, ��������� �� �������� (� ����� ����� �������������� �����������). ������ ����
     //   True ��� ������ ��� ����������� �������� �������� ������. ��� ��������� ����� ����������� ���������� ��� �
     //   ���������� False (����� �������� � ������������ �������������� ����������� ����������� ������ ��������, �����
     //   ���������� ���� ��������� ��������� �����)
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; bPerform: Boolean);
    destructor Destroy; override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� �������������� ����������� �� �������
   //===================================================================================================================

  TPhoaOp_InternalUnlinkedPicsRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
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
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; ChangeList: TPicPropertyChanges);
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //===================================================================================================================

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; Keywords: TKeywordList);
  end;

   //===================================================================================================================
   // �������� ���������� �������������� �����������
   //===================================================================================================================

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips);
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
     // ������������ ����������� � ������, ���� ��� ��� �� ����, � ���������� ������ ������
    procedure RegisterPic(Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic);
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sFilename: String; out AddedPic: IPhotoAlbumPic); overload;
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic); overload;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������
   //===================================================================================================================

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
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

  TPhoaMultiOp_PicDelete = class(TPhoaMultiOp)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
  end;

   //===================================================================================================================
   // �������� ������� ���������� ����������� �� ������ ������
   //===================================================================================================================

  TPhoaMultiOp_PicPaste = class(TPhoaMultiOp)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup);
  end;

   //===================================================================================================================
   // �������� �������������� ������� �����������
   //===================================================================================================================

  TPhoaOp_PhoAEdit = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const NewThSize: TSize; bNewThQuality: Byte; const sNewDescription: String);
  end;

   //===================================================================================================================
   // �������� [���]��������� �������� � �������������
   //===================================================================================================================

  TPhoaMultiOp_PicOperation = class(TPhoaMultiOp)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation);
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� � ����� ������
   //===================================================================================================================

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList);
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //===================================================================================================================

  TPhoaMultiOp_PicSort = class(TPhoaMultiOp)
  private
     // ����������� (��� bRecursive=True) ���������, ��������� �������� ���������� ������
    procedure AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean);
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean);
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //===================================================================================================================

  TPhoaOp_GroupDragAndDrop = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group, NewParentGroup: IPhotoAlbumPicGroup; iNewIndex: Integer);
  end;

   //===================================================================================================================
   // �������� �������������� ����������� � ������
   //===================================================================================================================

  TPhoaMultiOp_PicDragAndDropToGroup = class(TPhoaMultiOp)
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; bCopy: Boolean);
  end;

   //===================================================================================================================
   // �������� �������������� (������������������) ����������� ������ ������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  protected
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; idxNew: Integer);
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewNew = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const sName: String; Groupings: IPhotoAlbumPicGroupingList; Sortings: IPhotoAlbumPicSortingList);
  end;

   //===================================================================================================================
   // �������� ��������� �������������
   //===================================================================================================================

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
     // ���� NewGroupings=nil � NewSortings=nil, ������, ��� ������ �������������� �������������
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; View: IPhotoAlbumView; const sNewName: String; NewGroupings: IPhotoAlbumPicGroupingList; NewSortings: IPhotoAlbumPicSortingList);
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //===================================================================================================================

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
  end;

   //===================================================================================================================
   // �������� �������� ������ ����������� �� �������������
   //===================================================================================================================

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  protected
    function  GetInvalidationFlags: TUndoInvalidationFlags; override;
    procedure RollbackChanges; override;
  public
     // Group - ������, ���� �������� ����� �������������
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup);
  end;

   // ������/������ ����������� TPhoaGroupings �/�� Undo-�����
  procedure UndoWriteGroupings(UndoFile: TPhoaUndoFile; Groupings: IPhotoAlbumPicGroupingList);
  procedure UndoReadGroupings(UndoFile: TPhoaUndoFile; Groupings: IPhotoAlbumPicGroupingList);
   // ������/������ ����������� TPhoaGroupings �/�� Undo-�����
  procedure UndoWriteSortings(UndoFile: TPhoaUndoFile; Sortings: IPhotoAlbumPicSortingList);
  procedure UndoReadSortings(UndoFile: TPhoaUndoFile; Sortings: IPhotoAlbumPicSortingList);

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Clipbrd,
  VirtualDataObject, GR32,
  phUtils, phGraphics, ConsVars, phSettings;

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

  constructor TPhoaOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
  begin
    FList := AList;
    FList.Add(Self);
    FProject := AProject;
    FUndoDataPosition := FList.UndoFile.Position;
  end;

  destructor TPhoaOperation.Destroy;
  begin
    FProject := nil;
    FList.Remove(Self);
    inherited Destroy;
  end;

  function TPhoaOperation.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [];
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

  procedure TPhoaOperation.RollbackChanges;
  begin
    { does nothing }
  end;

  procedure TPhoaOperation.SetOpGroup(Value: IPhotoAlbumPicGroup);
  begin
    FOpGroupID := Value.ID;
  end;

  procedure TPhoaOperation.SetParentOpGroup(Value: IPhotoAlbumPicGroup);
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

  constructor TPhoaMultiOp.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
  begin
    inherited Create(AList, AProject);
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

  constructor TPhoaOp_GroupNew.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; CurGroup: IPhotoAlbumPicGroup);
  var g: IPhotoAlbumPicGroup;
  begin
    inherited Create(AList, AProject);
     // ������ �������� ������
    g := NewPhotoAlbumPicGroup(CurGroup, Project.RootGroupX.MaxGroupID+1);
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
    OpGroup.Owner := nil;
  end;

   //===================================================================================================================
   // TPhoaOp_GroupRename
   //===================================================================================================================

  constructor TPhoaOp_GroupRename.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText: String);
  begin
    inherited Create(AList, AProject);
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

  constructor TPhoaOp_GroupEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sNewText, sNewDescription: String);
  begin
    inherited Create(AList, AProject, Group, sNewText);
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

  constructor TPhoaOp_GroupDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; bPerform: Boolean);
  var i: Integer;
  begin
    inherited Create(AList, AProject);
     // ���������� ������ ��������� ������
    OpGroup       := Group;
    OpParentGroup := Group.OwnerX;
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
      for i := 0 to Group.Groups.Count-1 do TPhoaOp_GroupDelete.Create(FCascadedDeletes, Project, Group.GroupsX[i], False);
    end;
     // ��������� ��������
    if bPerform then begin
       // ������� ������
      Group.Owner := nil;
       // ������� �������������� �����������
      FUnlinkedPicsRemove := TPhoaOp_InternalUnlinkedPicsRemoving.Create(List, Project);
    end;
  end;

  destructor TPhoaOp_GroupDelete.Destroy;
  begin
    FCascadedDeletes.Free;
    FUnlinkedPicsRemove.Free;
    FPicIDs.Free;
    inherited Destroy;
  end;

  function TPhoaOp_GroupDelete.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReinitParent, uifXReinitRecursive,  // Execution flags
      uifUReinitParent, uifUReinitRecursive]; // Undo flags
  end;

  procedure TPhoaOp_GroupDelete.InternalRollback(gOwner: IPhotoAlbumPicGroup);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
  begin
     // ��������������� ������
    g := NewPhotoAlbumPicGroup(gOwner, OpGroupID);
    g.Text        := UndoFile.ReadStr;
    g.Description := UndoFile.ReadStr;
    g.Index       := UndoFile.ReadInt;
    g.Expanded    := UndoFile.ReadBool;
    if FPicIDs<>nil then
      for i := 0 to FPicIDs.Count-1 do g.PicsX.Add(Project.Pics.ItemsByID[FPicIDs[i]], False);
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
    if FUnlinkedPicsRemove<>nil then FUnlinkedPicsRemove.Undo;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalUnlinkedPicsRemoving
   //===================================================================================================================

  constructor TPhoaOp_InternalUnlinkedPicsRemoving.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
  var
    i: Integer;
    Pic: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject);
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
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_InternalUnlinkedPicsRemoving.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ������ ������, ���� �� �������� ����-����
    while UndoFile.ReadBool do
       // ������ �����������
      with NewPhotoAlbumPic do begin
         // ��������� ������
        RawData[PPAllProps] := UndoFile.ReadStr;
         // ����� � ������ (ID ��� ��������)
        PutToList(Project.PicsX, False);
      end;
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

  constructor TPhoaOp_InternalEditPicProps.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; ChangeList: TPicPropertyChanges);
  var
    iPic, iChg: Integer;
    Pic: IPhotoAlbumPic;
    ChangedProps: TPicProperties;
  begin
    inherited Create(AList, AProject);
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
      Project.PicsX.ItemsByIDX[iPicID].RawData[ChangedProps] := sPicData;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicKeywords
   //===================================================================================================================

  constructor TPhoaOp_InternalEditPicKeywords.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pics: IPhotoAlbumPicList; Keywords: TKeywordList);
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
      end;
    end;

  begin
    inherited Create(AList, AProject);
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

  procedure TPhoaOp_InternalEditPicKeywords.RollbackChanges;
  var iPicID: Integer;
  begin
    inherited RollbackChanges;
     // ���������� �� ��������� ������������: ������ ����, ���� �� �������� ����-����
    while UndoFile.ReadBool do begin
      iPicID    := UndoFile.ReadInt;
      Project.PicsX.ItemsByIDX[iPicID].KeywordsM.CommaText := UndoFile.ReadStr;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_StoreTransform
   //===================================================================================================================

  constructor TPhoaOp_StoreTransform.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Pic: IPhoaMutablePic; NewRotation: TPicRotation; NewFlips: TPicFlips);
  begin
    inherited Create(AList, AProject);
     // ��������� ������� ��������
    UndoFile.WriteInt(Pic.ID);
    UndoFile.WriteByte(Byte(Pic.Rotation));
    UndoFile.WriteByte(Byte(Pic.Flips));
     // ��������� ����� ��������
    Pic.Rotation := NewRotation;
    Pic.Flips    := NewFlips;
  end;

  procedure TPhoaOp_StoreTransform.RollbackChanges;
  var Pic: IPhotoAlbumPic;
  begin
    inherited RollbackChanges;
    Pic          := Project.PicsX.ItemsByIDX[UndoFile.ReadInt];
    Pic.Rotation := TPicRotation(UndoFile.ReadByte);
    Pic.Flips    := TPicFlips(Byte(UndoFile.ReadByte)); // �������� typecast, �� ����� �� �������������
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicAdd
   //===================================================================================================================

  constructor TPhoaOp_InternalPicAdd.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; const sFilename: String; out AddedPic: IPhotoAlbumPic);
  var Pic: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject);
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
    end;
     // ��������� � ������
    RegisterPic(Group, Pic);
    AddedPic := Pic;
  end;

  constructor TPhoaOp_InternalPicAdd.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pic: IPhotoAlbumPic);
  var PicEx: IPhotoAlbumPic;
  begin
    inherited Create(AList, AProject);
     // ���� ��� ������������ ����������� � ��� �� ������
    PicEx := Project.PicsX.ItemsByFileNameX[Pic.FileName];
    FExisting := PicEx<>nil;
     // ���� ����� ����������� - ������� � ������, ����������� ����� ID. ����� ���������� Pic
    if not FExisting then Pic.PutToList(Project.PicsX, True) else Pic := PicEx;
     // ��������� � ������
    RegisterPic(Group, Pic);
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

  procedure TPhoaOp_InternalPicAdd.RollbackChanges;
  var iPicID: Integer;
  begin
    inherited RollbackChanges;
     // ���� ������� �������� ���� �������
    iPicID := UndoFile.ReadInt;
    if iPicID>0 then begin
       // ������� �� ������
      OpGroup.PicsX.Remove(iPicID);
       // ���� ���� ��������� ����� �����������, ������� � �� �����������
      if not FExisting then Project.PicsX.ItemsByIDX[iPicID].Release;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicFromGroupRemove
   //===================================================================================================================

  constructor TPhoaOp_InternalPicFromGroupRemoving.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
  var i, idx: Integer;
  begin
    inherited Create(AList, AProject);
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
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalPicFromGroupRemoving.RollbackChanges;
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
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
        g.PicsX.Insert(IIs[i+1], Project.Pics.ItemsByID[IIs[i]], False);
        Dec(i, 2);
      end;
    finally
      IIs.Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  constructor TPhoaOp_InternalPicToGroupAdding.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
  var
    i: Integer;
    bAdded: Boolean;
    Pic: IPhoaPic;
  begin
    inherited Create(AList, AProject);
    OpGroup := Group;
     // ��������� ����������� � ������ � � undo-����
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
      Group.PicsX.Add(Pic, True, bAdded);
      if bAdded then begin
        UndoFile.WriteBool(True); // ���� �����������
        UndoFile.WriteInt (Pic.ID);
      end;
    end;
     // ����� ����-����
    UndoFile.WriteBool(False); 
  end;

  procedure TPhoaOp_InternalPicToGroupAdding.RollbackChanges;
  var g: IPhotoAlbumPicGroup;
  begin
    inherited RollbackChanges;
     // ������� ����������� ����������� (��������� ID ����������� ����������� �� �����, ���� �� �������� ����-����)
    g := OpGroup;
    while UndoFile.ReadBool do g.PicsX.Remove(UndoFile.ReadInt);
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
   // TPhoaMultiOp_PicDelete
   //===================================================================================================================

  constructor TPhoaMultiOp_PicDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList);
  begin
    inherited Create(AList, AProject);
    OpGroup := Group;
     // ������� ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, Project, Group, Pics);
     // ������� ����������� ����������� �� �����������
    TPhoaOp_InternalUnlinkedPicsRemoving.Create(FOperations, Project);
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicPaste
   //===================================================================================================================

  constructor TPhoaMultiOp_PicPaste.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup);
  var
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
    Pic: IPhotoAlbumPic;
    Code: TPhChunkCode;
    Datatype: TPhChunkDatatype;
    vValue: Variant;
  begin
    inherited Create(AList, AProject);
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
                  TPhoaOp_InternalPicAdd.Create(FOperations, Project, Group, Pic);
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

  constructor TPhoaOp_PhoAEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const NewThSize: TSize; bNewThQuality: Byte; const sNewDescription: String);
  begin
    inherited Create(AList, AProject);
     // ��������� ������ ��������
    UndoFile.WriteInt (Project.ThumbnailSize.cx);
    UndoFile.WriteInt (Project.ThumbnailSize.cy);
    UndoFile.WriteByte(Project.ThumbnailQuality);
    UndoFile.WriteStr (Project.Description);
     // ��������� ��������
    Project.ThumbnailSize    := NewThSize;
    Project.ThumbnailQuality := bNewThQuality;
    Project.Description      := sNewDescription;
  end;

  function TPhoaOp_PhoAEdit.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXUpdateThumbParams,  // Execution flags
      uifUUpdateThumbParams]; // Undo flags
  end;

  procedure TPhoaOp_PhoAEdit.RollbackChanges;
  var Sz: TSize;
  begin
    inherited RollbackChanges;
     // ��������������� �������� �����������
    Sz.cx   := UndoFile.ReadInt;
    Sz.cy   := UndoFile.ReadInt;
    Project.ThumbnailSize    := Sz;
    Project.ThumbnailQuality := UndoFile.ReadByte;
    Project.Description      := UndoFile.ReadStr;
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicOperation
   //===================================================================================================================

  constructor TPhoaMultiOp_PicOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; PicOperation: TPictureOperation);
  var
    i: Integer;
    IntersectPics: IPhoaMutablePicList;
    Pic: IPhoaPic;
  begin
    inherited Create(AList, AProject);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then TPhoaOp_InternalPicToGroupAdding.Create(FOperations, Project, TargetGroup, Pics);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, Project, SourceGroup, Pics);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, Project, TargetGroup, Pics);
     // �������� ������ ���������� ����������� � ��������� ������
    if PicOperation=popIntersectTarget then begin
      IntersectPics := NewPhotoAlbumPicList(False);
      for i := 0 to TargetGroup.Pics.Count-1 do begin
        Pic := TargetGroup.Pics[i];
        if Pics.IndexOfID(Pic.ID)<0 then IntersectPics.Add(Pic, False);
      end;
      if IntersectPics.Count>0 then begin
        TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, Project, TargetGroup, IntersectPics);
        TPhoaOp_InternalUnlinkedPicsRemoving.Create(FOperations, Project);
      end;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  constructor TPhoaOp_InternalGroupPicSort.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList);
  var i: Integer;
  begin
    inherited Create(AList, AProject);
     // ���������� ������
    OpGroup := Group;
     // ���������� ������� ���������� ID ����������� � ������
    UndoFile.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoFile.WriteInt(Group.Pics[i].ID);
     // ��������� ����������� � ������
    Group.PicsX.SortingsSort(Sortings);
  end;

  procedure TPhoaOp_InternalGroupPicSort.RollbackChanges;
  var i: Integer;
  begin
    inherited RollbackChanges;
     // ��������������� ������ ������� ���������� ID ����������� � ������
    OpGroup.PicsX.Clear;
    for i := 0 to UndoFile.ReadInt-1 do OpGroup.PicsX.Add(Project.Pics.ItemsByID[UndoFile.ReadInt], False);
  end;

   //===================================================================================================================
   // TPhoaMultiOp_PicSort
   //===================================================================================================================

  procedure TPhoaMultiOp_PicSort.AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean);
  var i: Integer;
  begin
     // ��������� ����������� � ������
    TPhoaOp_InternalGroupPicSort.Create(FOperations, Project, Group, Sortings);
     // ��� ������������� ��������� � � ����������
    if bRecursive then
      for i := 0 to Group.Groups.Count-1 do AddGroupSortOp(Group.GroupsX[i], Sortings, True);
  end;

  constructor TPhoaMultiOp_PicSort.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean);
  begin
    inherited Create(AList, AProject);
     // ��������� ����������
    AddGroupSortOp(Group, Sortings, bRecursive);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDragAndDrop
   //===================================================================================================================

  constructor TPhoaOp_GroupDragAndDrop.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group, NewParentGroup: IPhotoAlbumPicGroup; iNewIndex: Integer);
  var gOldParent: IPhotoAlbumPicGroup;
  begin
    inherited Create(AList, AProject);
     // ���������� ������ ������
    gOldParent := Group.OwnerX;
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

  constructor TPhoaMultiOp_PicDragAndDropToGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; SourceGroup, TargetGroup: IPhotoAlbumPicGroup; Pics: IPhoaPicList; bCopy: Boolean);
  begin
    inherited Create(AList, AProject);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(FOperations, Project, TargetGroup, Pics);
    if not bCopy then TPhoaOp_InternalPicFromGroupRemoving.Create(FOperations, Project, SourceGroup, Pics);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  constructor TPhoaOp_PicDragAndDropInsideGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup; Pics: IPhoaPicList; idxNew: Integer);
  var i, idxOld: Integer;
  begin
    inherited Create(AList, AProject);
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
    end;
     // ����� ����-����
    UndoFile.WriteBool(False);
  end;

  procedure TPhoaOp_PicDragAndDropInsideGroup.RollbackChanges;
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
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
        g.PicsX.Move(Indexes[i+1], Indexes[i]);
        Dec(i, 2);
      end;
    finally
      Indexes.Free;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_ViewNew
   //===================================================================================================================

  constructor TPhoaOp_ViewNew.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; const sName: String; Groupings: IPhotoAlbumPicGroupingList; Sortings: IPhotoAlbumPicSortingList);
  var
    View: IPhotoAlbumView;
    iNewViewIndex: Integer;
  begin
    inherited Create(AList, AProject);
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
  end;

  function TPhoaOp_ViewNew.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReloadViews, uifXUpdateViewIndex,  // Execution flags
      uifUReloadViews, uifUUpdateViewIndex]; // Undo flags
  end;

  procedure TPhoaOp_ViewNew.RollbackChanges;
  var iPrevViewIndex, iNewViewIndex: Integer;
  begin
    inherited RollbackChanges;
     // �������� ���������� ������
    iPrevViewIndex := UndoFile.ReadInt;
    iNewViewIndex  := UndoFile.ReadInt;
     // ������� �������������
    Project.ViewsX.Delete(iNewViewIndex);
     // ��������������� ������� ��������� �������������
    Project.ViewIndex := iPrevViewIndex;
  end;

   //===================================================================================================================
   // TPhoaOp_ViewEdit
   //===================================================================================================================

  constructor TPhoaOp_ViewEdit.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; View: IPhotoAlbumView; const sNewName: String; NewGroupings: IPhotoAlbumPicGroupingList; NewSortings: IPhotoAlbumPicSortingList);
  var bWriteGroupings, bWriteSortings: Boolean;
  begin
    inherited Create(AList, AProject);
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
  end;

  function TPhoaOp_ViewEdit.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReloadViews, uifXUpdateViewIndex,  // Execution flags
      uifUReloadViews, uifUUpdateViewIndex]; // Undo flags
  end;

  procedure TPhoaOp_ViewEdit.RollbackChanges;
  var
    sViewName: String;
    iViewIndex: Integer;
    View: IPhotoAlbumView;
  begin
    inherited RollbackChanges;
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
  end;

   //===================================================================================================================
   // TPhoaOp_ViewDelete
   //===================================================================================================================

  constructor TPhoaOp_ViewDelete.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject);
  var View: IPhotoAlbumView;
  begin
    inherited Create(AList, AProject);
     // ��������� ������ ������
    View := Project.CurrentViewX;
    UndoFile.WriteStr(View.Name);
    UndoWriteGroupings(UndoFile, View.GroupingsX);
    UndoWriteSortings (UndoFile, View.SortingsX);
     // ������� �������������
    Project.ViewsX.Delete(Project.ViewIndex);
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
  end;

  function TPhoaOp_ViewDelete.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXReloadViews, uifXUpdateViewIndex,  // Execution flags
      uifUReloadViews, uifUUpdateViewIndex]; // Undo flags
  end;

  procedure TPhoaOp_ViewDelete.RollbackChanges;
  var View: IPhotoAlbumView;
  begin
    inherited RollbackChanges;
      // ������ �������������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name := UndoFile.ReadStr;
    UndoReadGroupings(UndoFile, View.GroupingsX);
    UndoReadSortings (UndoFile, View.SortingsX);
     // ������������ �������������
    Project.ViewIndex := View.Index;
  end;

   //===================================================================================================================
   // TPhoaOp_ViewMakeGroup
   //===================================================================================================================

  constructor TPhoaOp_ViewMakeGroup.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Group: IPhotoAlbumPicGroup);
  var
    g: IPhotoAlbumPicGroup;
    View: IPhotoAlbumView;
  begin
    inherited Create(AList, AProject);
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
  end;

  function TPhoaOp_ViewMakeGroup.GetInvalidationFlags: TUndoInvalidationFlags;
  begin
    Result := [
      uifXUpdateViewIndex,  // Execution flags
      uifUUpdateViewIndex]; // Undo flags
  end;

  procedure TPhoaOp_ViewMakeGroup.RollbackChanges;
  begin
    inherited RollbackChanges;
     // ������� �������� ������ ����� �������������
    OpGroup.Owner := nil;
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
  end;

end.
