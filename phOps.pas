//**********************************************************************************************************************
//  $Id: phOps.pas,v 1.8 2004-10-19 07:31:32 dale Exp $
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

   //===================================================================================================================
   // ��������� ���������� �������� PhoA
   //===================================================================================================================

  IPhoaOperationParams = interface(IInterface)
    ['{4AF24473-A666-4373-9BD6-DC0868647DC9}']
     // �������� ������������ �������� ���������. ���� bRequired=True, �� ��������� ������� ��������� � ��� ����������
     //   �������� Exception; ��� bRequired=False � ���������� ��������� � Intf ���������� nil. ���� �������� ����,
     //   ����������� ��������� ����������� ����������, ��� ��� ���������� ������� Exception
    procedure ObtainValIntf(const sName: String; GUID: TGUID; out Intf; bRequired: Boolean = True);
     // Prop handlers
    function  GetCount: Integer;
    function  GetNames(Index: Integer): String;
    function  GetValBool(const sName: String): Boolean;
    function  GetValByte(const sName: String): Byte;
    function  GetValInt(const sName: String): Integer;
    function  GetValStr(const sName: String): String;
    function  GetValues(const sName: String): Variant;
    function  GetValuesByIndex(Index: Integer): Variant;
    procedure SetValues(const sName: String; const Value: Variant);
    procedure SetValuesByIndex(Index: Integer; const Value: Variant);
     // Props
     // -- ���������� ����������
    property Count: Integer read GetCount;
     // -- ������������ ���������� �� �������
    property Names[Index: Integer]: String read GetNames;
     // -- �������������� �������� ���������� � ��������� �� ������������� � ���
    property ValBool[const sName: String]: Boolean                 read GetValBool;
    property ValByte[const sName: String]: Byte                    read GetValByte;
    property ValInt [const sName: String]: Integer                 read GetValInt;
    property ValStr [const sName: String]: String                  read GetValStr;
     // -- �������� ���������� �� ����� (��� ������������ Unassigned �������� ���������)
    property Values[const sName: String]: Variant read GetValues write SetValues; default;
     // -- �������� ���������� �� ������� (��� ������������ Unassigned �������� ���������)
    property ValuesByIndex[Index: Integer]: Variant read GetValuesByIndex write SetValuesByIndex;
  end;

   //===================================================================================================================
   // ������ [���������] ��������� ������� �����������
   //===================================================================================================================

  PPicPropertyChange = ^TPicPropertyChange;
  TPicPropertyChange = record
    sNewValue: String;
    Prop: TPicProperty;
  end;

  IPhoaPicPropertyChangeList = interface(IInterface)
    ['{13EEEA04-FF5A-42B3-861E-C0C7F5A8A334}']
     // ��������� ����� ������
    function  Add(const sNewValue: String; Prop: TPicProperty): Integer;
     // Prop handlers
    function  GetChangedProps: TPicProperties;
    function  GetCount: Integer;
    function  GetItems(Index: Integer): PPicPropertyChange;
     // Props
     // -- ����� ������������ �������
    property ChangedProps: TPicProperties read GetChangedProps;
     // -- ���������� ��������� � ������
    property Count: Integer read GetCount;
     // -- �������� ������ �� �������
    property Items[Index: Integer]: PPicPropertyChange read GetItems; default;
  end;

   //===================================================================================================================
   // ������� ��������, �� ���������� ��������� �����������
   //===================================================================================================================

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

   //===================================================================================================================
   // ������� (�����������) �������� �����������, ������������� ������ (������ ������), ������� ����� ���� ��������
   //   Params:
   //     Project: IPhotoAlbumProject - ������
   //===================================================================================================================

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
     // �������� ��������� ���������� ��������, ���������� ��� � ��������. � ������� ������ �� ������ ������
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); virtual;
     // �������� ��������� ������ ���������, �������� ���������. � ������� ������ ���������� ���������� ��������
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); virtual;
     // Props
     // -- ���������� ������, ��������������� GroupID
    property OpGroup: IPhotoAlbumPicGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� ParentGroupID
    property OpParentGroup: IPhotoAlbumPicGroup read GetParentOpGroup write SetParentOpGroup;
  public
     // ������� ����������� ��� �������� �������� �� ����������
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); virtual;
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

   //===================================================================================================================
   // ������ ��������� ��������
   //===================================================================================================================

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

   //===================================================================================================================
   // ����� ������ PhoA. �������� ������ *���������������* �������� � �������� ����������� ������ ������
   //===================================================================================================================

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
   // �������� �������� ������ ������ ������������ ������
   //   Params:
   //     Group:        IPhotoAlbumPicGroup - ������, � ������� ��������� ������
   //     out NewGroup: IPhotoAlbumPicGroup - ��������� ������
   //===================================================================================================================

  TPhoaOp_GroupNew = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //   Params:
   //     Group:   IPhotoAlbumPicGroup - ������, ������� ���������������
   //     NewText: String              - ����� ������������ ������
   //===================================================================================================================

  TPhoaOp_GroupRename = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������� ������
   //   Params:
   //     Group:          IPhotoAlbumPicGroup - ������������� ������
   //     NewText:        String              - ����� ������������ ������
   //     NewDescription: String              - ����� �������� ������
   //===================================================================================================================

  TPhoaOp_GroupEdit = class(TPhoaOp_GroupRename)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ������ (����� �������� ����������� ����� �������� �����������)
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ��������� ������
   //===================================================================================================================

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ������, �������� �� TPhoaOp_GroupDelete, ������� ������ ������ (� �����������) � ��
   //   ��������� � ����������� ������������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ��������� ������
   //===================================================================================================================

  TPhoaOp_InternalGroupDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� �������������� ����������� �� �������
   //   Params:
   //     <none>
   //===================================================================================================================

  TPhoaOp_InternalUnlinkedPicsRemoving = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ����������� �������� �������������� �����������, ������ ����������� ��� ��������:
   //  - TPhoaOp_InternalEditPicProps
   //  - TPhoaOp_InternalEditPicKeywords
   //  - TPhoaOp_InternalPicFromGroupRemoving
   //  - TPhoaOp_InternalPicToGroupAdding
   //   Params:
   //     <none>
   //===================================================================================================================

  TPhoaOp_PicEdit = class(TPhoaOperation)
  end;

   //===================================================================================================================
   // ���������� �������� �������������� ������� �����������, ����� �������� ����
   //   Params:
   //     Pics:       IPhotoAlbumPicList         - ������ �����������, ��� �������� ����������
   //     ChangeList: IPhoaPicPropertyChangeList - ������ ��������� ��������� �������
   //===================================================================================================================

  TPhoaOp_InternalEditPicProps = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //   Params:
   //     Pics:        IPhotoAlbumPicList     - ������ �����������, ��� �������� ����� ����������
   //     KeywordList: IPhotoAlbumKeywordList - ������ �������� ����, ������� ����� ���������� ������������
   //===================================================================================================================

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ���������� �������������� �����������
   //   Params:
   //     Pic:         IPhotoAlbumPic     - �����������, � �������� ����������� ����� ��������������
   //     NewRotation: Byte(TPicRotation) - typecasted �������
   //     NewFlips:    Byte(TPicFlips)    - typecasted ���������
   //===================================================================================================================

  TPhoaOp_StoreTransform = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� ����������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ����������� � ������� �����������
   //===================================================================================================================

  TPhoaOp_PicAdd = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������. �� ��������� ����� ����������� �����������!
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ������ ��������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� ����������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ����������� �����������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ����������� � ����� ������ ���������� �����������
   //===================================================================================================================

  TPhoaBaseOp_PicCopy = class(TBaseOperation)
    constructor Create(Pics: IPhotoAlbumPicList; ClipFormats: TPicClipboardFormats);
  end;

   //===================================================================================================================
   // �������� ��������/��������� � ����� ������ ���������� �����������  (������� ����������� ����������� ����� ��������
   //   �� �� ������)
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ������ ��������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_PicDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ������� ���������� ����������� �� ������ ������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_PicPaste = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������� �������
   //   Params:
   //     NewThWidth:     Integer - ����� ������ ������
   //     NewThHeight:    Integer - ����� ������ ������
   //     NewThQuality:   Byte    - ����� �������� ������
   //     NewDescription: String  - ����� �������� �������
   //===================================================================================================================

  TPhoaOp_ProjectEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� [���]��������� �������� � �������������
   //   Params:
   //     SourceGroup:  IPhotoAlbumPicGroup     - �������� ������ � �������������
   //     TargetGroup:  IPhotoAlbumPicGroup     - ������� ������
   //     Pics:         IPhoaPicList            - ����������� ��� ��������
   //     PicOperation: Byte(TPictureOperation) - ����������� ��������
   //===================================================================================================================

  TPhoaOp_PicOperation = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� � ����� ������
   //   Params:
   //     Group:    IPhotoAlbumPicGroup       - ������, � ������� ����������� �����������
   //     Sortings: IPhotoAlbumPicSortingList - ������ ����������
   //===================================================================================================================

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //   Params:
   //     Group:     IPhotoAlbumPicGroup       - ������, � ������� ����������� �����������
   //     Sortings:  IPhotoAlbumPicSortingList - ������ ����������
   //     Recursive: Boolean                   - ���� True, ����������� ����������� ����� � � ����������
   //===================================================================================================================

  TPhoaOp_PicSort = class(TPhoaOperation)
  private
     // ����������� (��� bRecursive=True) ���������, ��������� �������� ���������� ������
    procedure AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //   Params:
   //     Group:          IPhotoAlbumPicGroup - ��������������� ������
   //     NewParentGroup: IPhotoAlbumPicGroup - ����� ������������ ������ ��� Group
   //     NewIndex:       Integer             - ����� ������ � ������������ ������
   //===================================================================================================================

  TPhoaOp_GroupDragAndDrop = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ����������� � ������
   //   Params:
   //     SourceGroup:  IPhotoAlbumPicGroup - �������� ������
   //     TargetGroup:  IPhotoAlbumPicGroup - ������� ������
   //     Pics:         IPhotoAlbumPicList  - ��������������� �����������
   //     Copy:         Boolean             - ���� True, ��� �������� �����������; ���� False - �������� �����������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropToGroup = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� (������������������) ����������� ������ ������
   //   Params:
   //     Group:    IPhotoAlbumPicGroup - ������ � �������������
   //     Pics:     IPhotoAlbumPicList  - ��������������� �����������
   //     NewIndex: Integer             - ������ ������� �����������
   //===================================================================================================================

  TPhoaOp_PicDragAndDropInsideGroup = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //   Params:
   //     Name:      String                     - ������������ �������������
   //     Groupings: IPhotoAlbumPicGroupingList - ������ ����������� �������������
   //     Sortings:  IPhotoAlbumPicSortingList  - ������ ���������� �������������
   //===================================================================================================================

  TPhoaOp_ViewNew = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ��������� �������������
   //   Params:
   //     View:      IPhotoAlbumView            - ���������� �������������
   //     Name:      String                     - ����� ������������ �������������
   //     Groupings: IPhotoAlbumPicGroupingList - ����� ������ ����������� �������������
   //     Sortings:  IPhotoAlbumPicSortingList  - ����� ������ ���������� �������������
   //       ���� Groupings=nil � Sortings=nil, ������, ��� ������ �������������� �������������
   //===================================================================================================================

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //   Params:
   //     <none>
   //===================================================================================================================

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ������ ����������� �� �������������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� �������� ����� �������������
   //===================================================================================================================

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(var Changes: TPhoaOperationChanges); override;
  end;

resourcestring
  SPhoaOpErrMsg_ParamNotFound         = 'Operation parameter named "%s" not found';
  SPhoaOpErrMsg_ParamTypeMismatch     = 'Operation parameter "%s" type mismatch. Expected: "%s", actual: "%s"';
  SPhoaOpErrMsg_CannotObtainParamIntf = 'Operation parameter "%s" doesn''t implement required interface';

   // ������ ��������� IPhoaOperationParams � ��������� ��� ����������� (�������� ���������� ������ ���� � Params
   //   ������: [���1, ��������1, ���2, ��������2, ...])
  function  NewPhoaOperationParams(const Params: Array of Variant): IPhoaOperationParams;

  function  NewPhoaPicPropertyChangeList: IPhoaPicPropertyChangeList;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, Clipbrd,
  VirtualDataObject, GR32,
  phUtils, phGraphics, ConsVars, phSettings, Variants;

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
   // TPhoaOperationParams
   //===================================================================================================================
type
  TPhoaOperationParams = class(TInterfacedObject, IPhoaOperationParams)
  private
     // ��� ������
    FList: TStringList;
     // ������� �������� �� �������
    procedure Delete(iIndex: Integer);
     // ���������� �������� ��������� �� �����. ���� ������ ��������� ���, �������� Exception
    function  GetValueStrict(const sName: String): Variant;
     // ��������� ��� ��������. ��� �������������� �������� Exception
    procedure CheckVarType(const sName: String; const v: Variant; RequiredType: TVarType);
     // IPhoaOperationParams
    procedure ObtainValIntf(const sName: String; GUID: TGUID; out Intf; bRequired: Boolean = True);
    function  GetCount: Integer;
    function  GetNames(Index: Integer): String;
    function  GetValBool(const sName: String): Boolean;
    function  GetValByte(const sName: String): Byte;
    function  GetValInt(const sName: String): Integer;
    function  GetValStr(const sName: String): String;
    function  GetValues(const sName: String): Variant;
    function  GetValuesByIndex(Index: Integer): Variant;
    procedure SetValues(const sName: String; const Value: Variant);
    procedure SetValuesByIndex(Index: Integer; const Value: Variant);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  procedure TPhoaOperationParams.CheckVarType(const sName: String; const v: Variant; RequiredType: TVarType);
  begin
    if VarType(v)<>RequiredType then PhoaException(SPhoaOpErrMsg_ParamTypeMismatch, [sName, VarTypeAsText(RequiredType), VarTypeAsText(VarType(v))]);
  end;

  constructor TPhoaOperationParams.Create;
  begin
    inherited Create;
    FList := TStringList.Create;
    FList.Sorted := True;
  end;

  procedure TPhoaOperationParams.Delete(iIndex: Integer);
  begin
    Dispose(PVariant(FList.Objects[iIndex]));
    FList.Delete(iIndex);
  end;

  destructor TPhoaOperationParams.Destroy;
  var i: Integer;
  begin
     // ������� ������
    for i := FList.Count-1 downto 0 do Delete(i);
    inherited Destroy;
  end;

  function TPhoaOperationParams.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TPhoaOperationParams.GetNames(Index: Integer): String;
  begin
    Result := FList[Index];
  end;

  function TPhoaOperationParams.GetValBool(const sName: String): Boolean;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varBoolean);
    Result := v;
  end;

  function TPhoaOperationParams.GetValByte(const sName: String): Byte;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varByte);
    Result := v;
  end;

  function TPhoaOperationParams.GetValInt(const sName: String): Integer;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varInteger);
    Result := v;
  end;

  function TPhoaOperationParams.GetValStr(const sName: String): String;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varString);
    Result := v;
  end;

  function TPhoaOperationParams.GetValues(const sName: String): Variant;
  var idx: Integer;
  begin
    idx := FList.IndexOf(sName);
    if idx<0 then Result := Unassigned else Result := GetValuesByIndex(idx);
  end;

  function TPhoaOperationParams.GetValuesByIndex(Index: Integer): Variant;
  begin
    Result := PVariant(FList.Objects[Index])^;
  end;

  function TPhoaOperationParams.GetValueStrict(const sName: String): Variant;
  begin
    Result := GetValues(sName);
    if VarIsEmpty(Result) then PhoaException(SPhoaOpErrMsg_ParamNotFound, [sName]);
  end;

  procedure TPhoaOperationParams.ObtainValIntf(const sName: String; GUID: TGUID; out Intf; bRequired: Boolean = True);
  var v: Variant;
  begin
    IInterface(Intf) := nil;
    if bRequired then v := GetValueStrict(sName) else v := GetValues(sName);
    if not VarIsEmpty(v) and not VarSupports(v, GUID, Intf) then PhoaException(SPhoaOpErrMsg_CannotObtainParamIntf, [sName]);
  end;

  procedure TPhoaOperationParams.SetValues(const sName: String; const Value: Variant);
  var
    idx: Integer;
    p: PVariant;
  begin
    idx := FList.IndexOf(sName);
    if idx<0 then begin
      if not VarIsEmpty(Value) then begin
        New(p);
        SetValuesByIndex(FList.AddObject(sName, Pointer(p)), Value);
      end;
    end else
      SetValuesByIndex(idx, Value);
  end;

  procedure TPhoaOperationParams.SetValuesByIndex(Index: Integer; const Value: Variant);
  begin
    if VarIsEmpty(Value) then Delete(Index) else PVariant(FList.Objects[Index])^ := Value;
  end;

   //===================================================================================================================
   // TPhoaPicPropertyChangeList
   //===================================================================================================================
type
  TPhoaPicPropertyChangeList = class(TInterfacedObject, IPhoaPicPropertyChangeList)
  private
     // ���������� ������
    FList: TList;
     // ������� ������� �� ������
    procedure Delete(Index: Integer);
     // IPhoaPicPropertyChangeList
    function  Add(const sNewValue: String; Prop: TPicProperty): Integer;
    function  GetChangedProps: TPicProperties;
    function  GetCount: Integer;
    function  GetItems(Index: Integer): PPicPropertyChange;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  function TPhoaPicPropertyChangeList.Add(const sNewValue: String; Prop: TPicProperty): Integer;
  var p: PPicPropertyChange;
  begin
    New(p);
    Result := FList.Add(p);
    p^.sNewValue := sNewValue;
    p^.Prop      := Prop;
  end;

  constructor TPhoaPicPropertyChangeList.Create;
  begin
    inherited Create;
    FList := TList.Create;
  end;

  procedure TPhoaPicPropertyChangeList.Delete(Index: Integer);
  begin
    Dispose(GetItems(Index));
    FList.Delete(Index);
  end;

  destructor TPhoaPicPropertyChangeList.Destroy;
  var i: Integer;
  begin
    for i := FList.Count-1 downto 0 do Delete(i);
    FList.Free;
    inherited Destroy;
  end;

  function TPhoaPicPropertyChangeList.GetChangedProps: TPicProperties;
  var i: Integer;
  begin
    Result := [];
    for i := 0 to FList.Count-1 do Include(Result, GetItems(i).Prop);
  end;

  function TPhoaPicPropertyChangeList.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TPhoaPicPropertyChangeList.GetItems(Index: Integer): PPicPropertyChange;
  begin
    Result := FList[Index];
  end;

   //===================================================================================================================
   // TPhoaOperation
   //===================================================================================================================

  constructor TPhoaOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    inherited Create;
    FProject := AProject;
     // �������������� � ������ ��������
    FList := AList;
    FList.Add(Self);
     // ���������� ������� Undo-������
    FUndoDataPosition := FList.UndoFile.Position;
     // ��������� ��������
    Perform(Params, Changes); 
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

  procedure TPhoaOperation.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    { does nothing }
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

  procedure TPhoaOp_GroupNew.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var Group, NewGroup: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
     // ������ �������� ������
    NewGroup := NewPhotoAlbumPicGroup(Group, Project.RootGroupX.MaxGroupID+1);
    NewGroup.Text := ConstVal('SDefaultNewGroupName');
    OpParentGroup := Group;
    OpGroup       := NewGroup;
     // ���������� ����� Params ��������� ������
    Params['NewGroup'] := NewGroup;
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

  procedure TPhoaOp_GroupRename.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, Changes);
     // ���������� ������ ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    OpGroup := Group;
    UndoFile.WriteStr(Group.Text);
     // ��������� ��������
    Group.Text := Params.ValStr['NewText'];
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

  procedure TPhoaOp_GroupEdit.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, Changes);
     // ���������� ������ ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    UndoFile.WriteStr(Group.Description);
     // ��������� ��������
    Group.Description := Params.ValStr['NewDescription'];
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

  procedure TPhoaOp_GroupDelete.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, Changes);
     // ������� ������ (� ���������)
    TPhoaOp_InternalGroupDelete.Create(Operations, Project, Params, Changes);
     // ������� �������������� �����������
    TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, Params, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupDelete
   //===================================================================================================================

  procedure TPhoaOp_InternalGroupDelete.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, Changes);
     // ���������� ������ ��������� ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    OpGroup       := Group;
    OpParentGroup := Group.OwnerX;
    UndoFile.WriteStr (Group.Text);
    UndoFile.WriteStr (Group.Description);
    UndoFile.WriteInt (Group.Index);
    UndoFile.WriteBool(Group.Expanded);
     // ���������� ID ����������� � ������� ����������� �� ������
    UndoFile.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoFile.WriteInt(Group.Pics[i].ID);
    Group.PicsX.Clear;
     // �������� ������� ������
    for i := Group.Groups.Count-1 downto 0 do
      TPhoaOp_InternalGroupDelete.Create(
        Operations,
        Project, 
        NewPhoaOperationParams(['Group', Group.GroupsX[i]]),
        Changes);
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

  procedure TPhoaOp_InternalUnlinkedPicsRemoving.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Pic: IPhotoAlbumPic;
  begin
    inherited Perform(Params, Changes);
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
   // TPhoaOp_InternalEditPicProps
   //===================================================================================================================

  procedure TPhoaOp_InternalEditPicProps.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    ChangeList: IPhoaPicPropertyChangeList;
    iPic, iChg: Integer;
    Pic: IPhotoAlbumPic;
    ChangedProps: TPicProperties;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics',       IPhotoAlbumPicList,         Pics);
    Params.ObtainValIntf('ChangeList', IPhoaPicPropertyChangeList, ChangeList);
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

  procedure TPhoaOp_InternalEditPicKeywords.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    KeywordList: IPhotoAlbumKeywordList;
    iPic, iCnt, iKwd, idxKeyword: Integer;
    Pic: IPhotoAlbumPic;
    sKeyword: String;
    pkd: PPhoaKeywordData;
    bKWSaved: Boolean;
    PicKeywords: IPhotoAlbumKeywordList;

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
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics',        IPhotoAlbumPicList,     Pics);
    Params.ObtainValIntf('KeywordList', IPhotoAlbumKeywordList, KeywordList);
     // ���� �� ������������
    iCnt := Pics.Count;
    for iPic := 0 to iCnt-1 do begin
      Pic := Pics[iPic];
      PicKeywords := Pic.KeywordsX;
      bKWSaved := False;
       // ���� �� �������� ������
      for iKwd := 0 to KeywordList.Count-1 do begin
        sKeyword := KeywordList[iKwd];
        pkd := KeywordList.KWData[iKwd];
        case pkd.Change of
           // �� �� ��������. ��������� ��������� �����
          pkcNone:
             // ���� Grayed - ������ ������ �� �����������. ���� �� ��������, � �� �� ���������� �� � ����� �����������
             //   - ������ ������. ���� �������� ���������, � �� ���������� �� ���� ������������ - ������ ������.
             //   ����� ��������� ������� �� � �����������
            if ((pkd.State=pksOff) and (pkd.iSelCount>0)) or ((pkd.State=pksOn) and (pkd.iSelCount<iCnt)) then begin
              idxKeyword := PicKeywords.IndexOf(sKeyword);
              case pkd.State of
                 // ���� ������ ��. ���� ��� ���� - �������
                pksOff:
                  if idxKeyword>=0 then begin
                    SavePicKeywords;
                    PicKeywords.Delete(idxKeyword);
                  end;
                 // ���� �������� ��. ���� ��� - ���������
                pksOn:
                  if idxKeyword<0 then begin
                    SavePicKeywords;
                    PicKeywords.Add(sKeyword);
                  end;
              end;
            end;
           // ���������� ������ ��. ���� ���� ����� - ���� ��������
          pkcAdd:
            if pkd.State=pksOn then begin
              SavePicKeywords;
              PicKeywords.Add(sKeyword);
            end;
           // �� ��������. ���� ������ ��� �� ��������� ������������� � �����������, ...
          pkcReplace:
            if (pkd.State<>pksOff) or (pkd.iSelCount>0) then begin
               // ... ���� ������ �� � �������, ...
              idxKeyword := PicKeywords.IndexOf(pkd.sOldKeyword);
              if idxKeyword>=0 then begin
                SavePicKeywords;
                PicKeywords.Delete(idxKeyword);
              end;
               // ... ���� ��������� pksOn - ��������� ����� ����, ���� pksGrayed - ��������� ������ � ��, ��� ���� ������
              if (pkd.State=pksOn) or ((pkd.State=pksGrayed) and (idxKeyword>=0)) then begin
                SavePicKeywords;
                PicKeywords.Add(sKeyword);
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

  procedure TPhoaOp_StoreTransform.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var Pic: IPhotoAlbumPic;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pic', IPhotoAlbumPic, Pic);
     // ��������� ������� ��������
    UndoFile.WriteInt(Pic.ID);
    UndoFile.WriteByte(Byte(Pic.Rotation));
    UndoFile.WriteByte(Byte(Pic.Flips));
     // ��������� ����� ��������
    Pic.Rotation := TPicRotation(Params.ValByte['NewRotation']);
    Pic.Flips    := TPicFlips   (Params.ValByte['NewFlips']);
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
   // TPhoaOp_PicAdd
   //===================================================================================================================

  procedure TPhoaOp_PicAdd.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    NewPics: IPhotoAlbumPicList;
    Group: IPhotoAlbumPicGroup;
    Pic, PicEx: IPhotoAlbumPic;
    bExisting, bAddedToGroup: Boolean;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('NewPics', IPhotoAlbumPicList,  NewPics);
    Params.ObtainValIntf('Group',   IPhotoAlbumPicGroup, Group);
     // ��������� ������ ��� ������
    OpGroup := Group;
     // ���������� ��� ����� �����������
    UndoFile.WriteInt(NewPics.Count);
    for i := 0 to NewPics.Count-1 do begin
      Pic := NewPics[i];
       // ���� ��� ������������ ����������� � ��� �� ������
      PicEx := Project.PicsX.ItemsByFileNameX[Pic.FileName];
      bExisting := PicEx<>nil;
       // ���� ���� ����� ����������� - ���������� Pic
      if bExisting then
        Pic := PicEx
       // ����� ������� � ������, ����������� ����� ID
      else begin
        Pic.PutToList(Project.PicsX, True);
        Include(Changes, pocProjectPicList);
      end;
       // ��������� ����������� � ������, ���� ��� ��� �� ����
      Group.PicsX.Add(Pic, True, bAddedToGroup);
      if bAddedToGroup then Include(Changes, pocGroupPicList);
       // ��������� ID �����������, ���� �������������, ���� ���������� � ������
      UndoFile.WriteInt(Pic.ID);
      UndoFile.WriteBool(bExisting);
      UndoFile.WriteBool(bAddedToGroup);
    end;
  end;

  procedure TPhoaOp_PicAdd.RollbackChanges(var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    i, iPicID: Integer;
    bExisting, bAddedToGroup: Boolean;
  begin
     // �������� ������, ���� ��������� �����������
    Group := OpGroup;
     // ��������� ������ �� ������� �����������
    for i := 0 to UndoFile.ReadInt-1 do begin
      iPicID        := UndoFile.ReadInt;
      bExisting     := UndoFile.ReadBool;
      bAddedToGroup := UndoFile.ReadBool;
       // ���� ���� ��������� � ������ - �������
      if bAddedToGroup then begin
        Group.PicsX.Remove(iPicID);
        Include(Changes, pocGroupPicList);
      end;
       // ���� ���� ��������� ����� �����������, ������� � �� ������ �������
      if not bExisting then begin
        Project.PicsX.ItemsByIDX[iPicID].Release;
        Include(Changes, pocProjectPicList);
      end;
    end;
    inherited RollbackChanges(Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicFromGroupRemoving
   //===================================================================================================================

  procedure TPhoaOp_InternalPicFromGroupRemoving.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics:  IPhotoAlbumPicList;
    i, idx: Integer;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
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

  procedure TPhoaOp_InternalPicToGroupAdding.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics:  IPhotoAlbumPicList;
    i: Integer;
    bAdded: Boolean;
    Pic: IPhoaPic;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
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

  procedure TPhoaOp_PicDelete.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, Changes);
     // ������� ����������� �� ������
    TPhoaOp_InternalPicFromGroupRemoving.Create(Operations, Project, Params, Changes);
     // ������� ����������� ����������� �� �����������
    TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, Params, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicPaste
   //===================================================================================================================

  procedure TPhoaOp_PicPaste.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    PastedPics: IPhotoAlbumPicList;
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
  begin
    inherited Perform(Params, Changes);
    if Clipboard.HasFormat(wClipbrdPicFormatID) then begin
       // �������� ���������
      Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
      OpGroup := Group;
       // ������ ������ ����������� ��� �������
      PastedPics := NewPhotoAlbumPicList(False);
       // ������ ��������� �����
      ms := TMemoryStream.Create;
      try
         // �������� ������ �� ������ ������
        hRec := Clipboard.GetAsHandle(wClipbrdPicFormatID);
        ms.Write(GlobalLock(hRec)^, GlobalSize(hRec));
        GlobalUnlock(hRec);
        ms.Position := 0;
         // ������ Streamer � ��������� �����������
        Streamer := TPhoaStreamer.Create(ms, psmRead, '');
        try
          PastedPics.StreamerLoad(Streamer);
        finally
          Streamer.Free;
        end;
      finally
        ms.Free;
      end;
       // ������ �������� �������� ���������� �����������
      TPhoaOp_PicAdd.Create(Operations, Project, NewPhoaOperationParams(['Group', Group, 'Pics', PastedPics]), Changes);
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_ProjectEdit
   //===================================================================================================================

  procedure TPhoaOp_ProjectEdit.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, Changes);
     // ��������� ������ ��������
    UndoFile.WriteInt (Project.ThumbnailSize.cx);
    UndoFile.WriteInt (Project.ThumbnailSize.cy);
    UndoFile.WriteByte(Project.ThumbnailQuality);
    UndoFile.WriteStr (Project.Description);
     // ��������� ��������
    Project.ThumbnailSize    := Size(Params.ValInt['NewThWidth'], Params.ValInt['NewThHeight']);
    Project.ThumbnailQuality := Params.ValByte['NewThQuality'];
    Project.Description      := Params.ValStr ['NewDescription'];
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

  procedure TPhoaOp_PicOperation.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    SourceGroup, TargetGroup: IPhotoAlbumPicGroup;
    Pics: IPhoaPicList;
    i: Integer;
    IntersectPics: IPhoaMutablePicList;
    Pic: IPhoaPic;
    PicOperation: TPictureOperation;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('SourceGroup', IPhotoAlbumPicGroup, SourceGroup);
    Params.ObtainValIntf('TargetGroup', IPhotoAlbumPicGroup, TargetGroup);
    Params.ObtainValIntf('Pics',        IPhoaPicList,        Pics);
    PicOperation := TPictureOperation(Params.ValByte['PicOperation']);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then
      TPhoaOp_InternalPicToGroupAdding.Create(
        Operations,
        Project,
        NewPhoaOperationParams(['Group', TargetGroup, 'Pics', Pics]),
        Changes);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then
      TPhoaOp_InternalPicFromGroupRemoving.Create(
        Operations,
        Project,
        NewPhoaOperationParams(['Group', SourceGroup,'Pics', Pics]),
        Changes);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then
      TPhoaOp_InternalPicFromGroupRemoving.Create(
        Operations,
        Project,
        NewPhoaOperationParams(['Group', TargetGroup, 'Pics', Pics]),
        Changes);
     // �������� ������ ���������� ����������� � ��������� ������
    if PicOperation=popIntersectTarget then begin
      IntersectPics := NewPhotoAlbumPicList(False);
      for i := 0 to TargetGroup.Pics.Count-1 do begin
        Pic := TargetGroup.Pics[i];
        if Pics.IndexOfID(Pic.ID)<0 then IntersectPics.Add(Pic, False);
      end;
      if IntersectPics.Count>0 then begin
        TPhoaOp_InternalPicFromGroupRemoving.Create(
          Operations,
          Project,
          NewPhoaOperationParams(['Group', TargetGroup, 'Pics', IntersectPics]),
          Changes);
        TPhoaOp_InternalUnlinkedPicsRemoving.Create(Operations, Project, nil, Changes);
      end;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  procedure TPhoaOp_InternalGroupPicSort.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Sortings: IPhotoAlbumPicSortingList;
    i: Integer;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',    IPhotoAlbumPicGroup,       Group);
    Params.ObtainValIntf('Sortings', IPhotoAlbumPicSortingList, Sortings);
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
    TPhoaOp_InternalGroupPicSort.Create(Operations, Project, NewPhoaOperationParams(['Group', Group, 'Sortings', Sortings]), Changes);
     // ��� ������������� ��������� � � ����������
    if bRecursive then
      for i := 0 to Group.Groups.Count-1 do AddGroupSortOp(Group.GroupsX[i], Sortings, True, Changes);
  end;

  procedure TPhoaOp_PicSort.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Sortings: IPhotoAlbumPicSortingList;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',    IPhotoAlbumPicGroup,       Group);
    Params.ObtainValIntf('Sortings', IPhotoAlbumPicSortingList, Sortings);
     // ��������� ����������
    AddGroupSortOp(Group, Sortings, Params.ValBool['Recursive'], Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDragAndDrop
   //===================================================================================================================

  procedure TPhoaOp_GroupDragAndDrop.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group, NewParentGroup, gOldParent: IPhotoAlbumPicGroup;
    iNewIndex: Integer;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',          IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('NewParentGroup', IPhotoAlbumPicGroup, NewParentGroup);
    iNewIndex := Params.ValInt['NewIndex'];
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

  procedure TPhoaOp_PicDragAndDropToGroup.Perform( Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    SourceGroup, TargetGroup: IPhotoAlbumPicGroup;
    Pics: IPhoaPicList;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('SourceGroup', IPhotoAlbumPicGroup, SourceGroup);
    Params.ObtainValIntf('TargetGroup', IPhotoAlbumPicGroup, TargetGroup);
    Params.ObtainValIntf('Pics',        IPhotoAlbumPicList,  Pics);
     // ��������� ��������
    TPhoaOp_InternalPicToGroupAdding.Create(
      Operations,
      Project,
      NewPhoaOperationParams(['Group', TargetGroup, 'Pics', Pics]),
      Changes);
    if not Params.ValBool['Copy'] then
      TPhoaOp_InternalPicFromGroupRemoving.Create(
        Operations,
        Project,
        NewPhoaOperationParams(['Group', SourceGroup, 'Pics', Pics]),
        Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  procedure TPhoaOp_PicDragAndDropInsideGroup.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics: IPhoaPicList;
    i, idxOld, iNewIndex: Integer;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
    iNewIndex := Params.ValInt['NewIndex'];
     // ���������� ������
    OpGroup := Group;
     // ��������� ��������
    for i := 0 to Pics.Count-1 do begin
       // -- ����� ������� �����������
      UndoFile.WriteBool(True);
       // -- ���������� �������
      idxOld := Group.Pics.IndexOfID(Pics[i].ID);
      if idxOld<iNewIndex then Dec(iNewIndex);
      UndoFile.WriteInt(idxOld);
      UndoFile.WriteInt(iNewIndex);
       // -- ���������� ����������� �� ����� �����
      Group.PicsX.Move(idxOld, iNewIndex);
      Inc(iNewIndex);
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

  procedure TPhoaOp_ViewNew.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Groupings: IPhotoAlbumPicGroupingList;
    Sortings: IPhotoAlbumPicSortingList;
    View: IPhotoAlbumView;
    iNewViewIndex: Integer;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Groupings', IPhotoAlbumPicGroupingList, Groupings);
    Params.ObtainValIntf('Sortings',  IPhotoAlbumPicSortingList,  Sortings);
     // ��������� ���������� ������� ������ ������������� �������
    UndoFile.WriteInt(Project.ViewIndex);
     // ��������� ��������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name := Params.ValStr['Name'];
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

  procedure TPhoaOp_ViewEdit.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    View: IPhotoAlbumView;
    Groupings: IPhotoAlbumPicGroupingList;
    Sortings: IPhotoAlbumPicSortingList;
    bWriteGroupings, bWriteSortings: Boolean;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('View',      IPhotoAlbumView,            View);
    Params.ObtainValIntf('Groupings', IPhotoAlbumPicGroupingList, Groupings, False);
    Params.ObtainValIntf('Sortings',  IPhotoAlbumPicSortingList,  Sortings,  False);
     // ��������� ������ ������ � ��������� ���������
    UndoFile.WriteStr(View.Name);
    View.Name := Params.ValStr['Name'];
     // ���������� ����� ������ ������������� (����� ���������� �����, �.�. ��� �������� ������� ������������� � ������)
    UndoFile.WriteInt(View.Index);
     // ������ ����������� ������ � ���������, ���� �� ����
    bWriteGroupings := Groupings<>nil;
    UndoFile.WriteBool(bWriteGroupings); // ������� ������� �����������
    if bWriteGroupings then begin
      UndoWriteGroupings(UndoFile, View.GroupingsX);
      View.GroupingsX.Assign(Groupings);
      View.Invalidate;
    end;
     // ������ ���������� ������ � ���������, ���� �� ����
    bWriteSortings := Sortings<>nil;
    UndoFile.WriteBool(bWriteSortings); // ������� ������� ����������
    if bWriteSortings then begin
      UndoWriteSortings(UndoFile, View.SortingsX);
      View.SortingsX.Assign(Sortings);
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

  procedure TPhoaOp_ViewDelete.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var View: IPhotoAlbumView;
  begin
    inherited Perform(Params, Changes);
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

  procedure TPhoaOp_ViewMakeGroup.Perform(Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  var
    Group, ViewGroup: IPhotoAlbumPicGroup;
    View: IPhotoAlbumView;
  begin
    inherited Perform(Params, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
     // �������� �������������
    View := Project.CurrentViewX;
     // ������ ������ (���������� � �������� ID)
    ViewGroup := NewPhotoAlbumPicGroup(Group, 0);
    ViewGroup.Assign(View.RootGroup, False, True, True);
    ViewGroup.Text := View.Name;
     // ������������ ������� ��������� ID
    Project.RootGroupX.FixupIDs;
     // ���������� ��������� (��������) ������
    OpGroup := ViewGroup;
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

   //===================================================================================================================

  function NewPhoaOperationParams(const Params: Array of Variant): IPhoaOperationParams;
  var i, idxParam: Integer;
  begin
    Result := TPhoaOperationParams.Create;
    if Length(Params)>0 then
      for i := 0 to High(Params) div 2 do begin
        idxParam := i*2;
        Result[Params[idxParam]] := Params[idxParam+1];
      end;
  end;

  function NewPhoaPicPropertyChangeList: IPhoaPicPropertyChangeList;
  begin
    Result := TPhoaPicPropertyChangeList.Create;
  end;

end.
