//**********************************************************************************************************************
//  $Id: phOps.pas,v 1.27 2007-07-04 18:48:36 dale Exp $
//===================================================================================================================---
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phOps;

interface
uses
  Windows, Messages, SysUtils, Classes, Contnrs,
  TntSysUtils,
  phObj, phPhoa, phIntf, phMutableIntf, phNativeIntf;

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
   // ��������� ���������� �������� PhoA
   //===================================================================================================================

  IPhoaOperationParams = interface(IInterface)
    ['{4AF24473-A666-4373-9BD6-DC0868647DC9}']
     // �������� ������������ �������� ���������. ���� bRequired=True, �� ��������� ������� ��������� � ��� ����������
     //   �������� exception; ��� bRequired=False � ���������� ��������� � Intf ���������� nil. ���� �������� ����,
     //   ����������� ��������� ����������� ����������, ��� ��� ���������� ������� exception
    procedure ObtainValIntf(const sName: AnsiString; GUID: TGUID; out Intf; bRequired: Boolean = True);
     // Prop handlers
    function  GetCount: Integer;
    function  GetNames(Index: Integer): AnsiString;
    function  GetValBool(const sName: AnsiString): Boolean;
    function  GetValByte(const sName: AnsiString): Byte;
    function  GetValInt(const sName: AnsiString): Integer;
    function  GetValStr(const sName: AnsiString): WideString;
    function  GetValues(const sName: AnsiString): Variant;
    function  GetValuesByIndex(Index: Integer): Variant;
    procedure SetValues(const sName: AnsiString; const Value: Variant);
    procedure SetValuesByIndex(Index: Integer; const Value: Variant);
     // Props
     // -- ���������� ����������
    property Count: Integer read GetCount;
     // -- ������������ ���������� �� �������
    property Names[Index: Integer]: AnsiString read GetNames;
     // -- �������������� �������� ���������� � ��������� �� ������������� � ���
    property ValBool[const sName: AnsiString]: Boolean    read GetValBool;
    property ValByte[const sName: AnsiString]: Byte       read GetValByte;
    property ValInt [const sName: AnsiString]: Integer    read GetValInt;
    property ValStr [const sName: AnsiString]: WideString read GetValStr;
     // -- �������� ���������� �� ����� (��� ������������ Unassigned �������� ���������)
    property Values[const sName: AnsiString]: Variant read GetValues write SetValues; default;
     // -- �������� ���������� �� ������� (��� ������������ Unassigned �������� ���������)
    property ValuesByIndex[Index: Integer]: Variant read GetValuesByIndex write SetValuesByIndex;
  end;

   //===================================================================================================================
   // ������ [���������] ��������� ������� �����������
   //===================================================================================================================

  PPicPropertyChange = ^TPicPropertyChange;
  TPicPropertyChange = record
    vNewValue: Variant;
    Prop: TPicProperty;
  end;

  IPhoaPicPropertyChangeList = interface(IInterface)
    ['{13EEEA04-FF5A-42B3-861E-C0C7F5A8A334}']
     // ��������� ����� ������
    function  Add(const vNewValue: Variant; Prop: TPicProperty): Integer;
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
   // ������ [���������] ��������� ������ �����������
   //===================================================================================================================

  PPicFileChange = ^TPicFileChange;
  TPicFileChange = record
    Pic:        IPhotoAlbumPic; // �����������
    wsFileName: WideString;     // ��� ������ �����, ��������������� Pic
  end;

  IPhoaPicFileChangeList = interface(IInterface)
    ['{9B327389-E6BC-4297-845C-563002068720}']
     // ��������� ����� ������
    function  Add(Pic: IPhotoAlbumPic; const wsFileName: WideString): Integer;
     // Prop handlers
    function  GetCount: Integer;
    function  GetItems(Index: Integer): PPicFileChange;
     // Props
     // -- ���������� ��������� � ������
    property Count: Integer read GetCount;
     // -- �������� ������ �� �������
    property Items[Index: Integer]: PPicFileChange read GetItems; default;
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
    pocPicProps,         // ���������� �������� �����������
    pocNonUndoable);     // �������� ��������� �� ������������ ������
  TPhoaOperationChanges = set of TPhoaOperationChange;

   //===================================================================================================================
   // ������� (�����������) �������� �����������, ������������� ������ (������ ������), ������� ����� ���� ��������
   //   Params:
   //     Project: IPhotoAlbumProject - ������
   //===================================================================================================================

  TPhoaOperationClass = class of TPhoaOperation;

  TPhoaOperation = class(TBaseOperation)
  private
     // ������� ������ ������ �������� � Undo-����� ������ ������ (UndoStream)
    FUndoDataPosition: Int64;
     // Prop storage
    FGUIStateUndoDataPosition: Int64;
    FList: TPhoaOperations;
    FOperations: TPhoaOperations;
    FOpGroupID: Integer;
    FOpParentGroupID: Integer;
    FProject: IPhotoAlbumProject;
     // Prop handlers
    function  GetOperations: TPhoaOperations;
    function  GetOpGroup: IPhotoAlbumPicGroup;
    function  GetParentOpGroup: IPhotoAlbumPicGroup;
    procedure SetOpGroup(Value: IPhotoAlbumPicGroup);
    procedure SetParentOpGroup(Value: IPhotoAlbumPicGroup);
  protected
     // Prop storage
    FSavepoint: Boolean;
     // �������� ��������� ���������� ��������, ���������� ��� � ��������. � ������� ������ �� ������ ������
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); virtual;
     // �������� ��������� ������ ���������, �������� ���������. � ������� ������ ���������� ���������� ��������
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); virtual;
     // ������ ����� ��������� �������� ������ OpClass � ��������� � ������ �������� ��������
    procedure AddChild(OpClass: TPhoaOperationClass; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
     // Props
     // -- ���������� ������, ��������������� OpGroupID
    property OpGroup: IPhotoAlbumPicGroup read GetOpGroup write SetOpGroup;
     // -- ���������� ������, ��������������� OpParentGroupID
    property OpParentGroup: IPhotoAlbumPicGroup read GetParentOpGroup write SetParentOpGroup;
  public
    constructor Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges); virtual;
    destructor Destroy; override;
     // ���������, ������������ ���������, �������� ��������� (������� RollbackChanges()), � ������������
     //   ������-��������. � Changes ��������� ����� ������ �������� � �������� ������ ���������
    procedure Undo(var Changes: TPhoaOperationChanges);
     // ������������ ��������
    function Name: WideString;
     // Props
     // -- ������� � Undo-����� ������ � ��������� ����������
    property GUIStateUndoDataPosition: Int64 read FGUIStateUndoDataPosition write FGUIStateUndoDataPosition;
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
  end;

   //===================================================================================================================
   // ������� �������� (������������� ����� ���������� �������� �� ����� ��������)
   //===================================================================================================================

  IPhoaOperationFactory = interface(IInterface)
    ['{BE27C06A-6F28-4A8E-9F41-20350D45D8AC}']
     // ������������ ����� ����� �������� � ������
    procedure RegisterOpClass(const sOpName: AnsiString; OpClass: TPhoaOperationClass);
     // ������������ � ���������� ����� ��������
    function  NewOperation(const sOpName: AnsiString; AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges): TPhoaOperation;
     // Prop handlers
    function  GetClassByName(const sOpName: AnsiString): TPhoaOperationClass;
     // Props
     // -- ���������� ����� �� ����� ��������. ���� ��� ������, �������� Exception
    property ClassByName[const sOpName: AnsiString]: TPhoaOperationClass read GetClassByName;
  end;

   //===================================================================================================================
   // ������ ��������� ��������
   //===================================================================================================================

  TPhoaOperations = class(TObject)
  private
     // ���������� ������
    FList: TList;
     // Prop storage
    FUndoStream: IPhoaUndoDataStream;
     // Prop handlers
    function  GetItems(Index: Integer): TPhoaOperation;
    function  GetCanUndo: Boolean;
    function  GetCount: Integer;
  protected
     // ���������� ���� ����� (������������� ��� ��������� ������� ������������� ��������)
    procedure UndoAll(var Changes: TPhoaOperationChanges);
  public
    constructor Create(AUndoStream: IPhoaUndoDataStream);
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
     // -- ��������� ������ ������
    property UndoStream: IPhoaUndoDataStream read FUndoStream;
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
    function  GetLastOpName: WideString;
    function  GetIsUnmodified: Boolean;
    procedure SetMaxCount(Value: Integer);
  public
    constructor Create;
    function  Add(Item: TPhoaOperation): Integer; override;
    procedure Clear; override;
     // �������������, ��� ������� ��������� ����������� �������� ����������
    procedure SetSavepoint;
     // ������� ���������� ������ ������ � ������������� ��������� ������������������ ������� � bModified
    procedure SetNonUndoable(bModified: Boolean);
     // Props
     // -- ���������� True, ���� ������� ��������� ������ ������ ������������� ����������� ��������� �����������
    property IsUnmodified: Boolean read GetIsUnmodified;
     // -- ���������� ������������ ��������� ��������� ��������
    property LastOpName: WideString read GetLastOpName;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������
   //   Params:
   //     Group:   IPhotoAlbumPicGroup - ������, ������� ���������������
   //     NewText: WideString          - ����� ������������ ������
   //===================================================================================================================

  TPhoaOp_GroupRename = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������� ������
   //   Params:
   //     Group:          IPhotoAlbumPicGroup - ������������� ������
   //     NewText:        WideString          - ����� ������������ ������
   //     NewDescription: WideString          - ����� �������� ������
   //     NewIconData:    TPhoaRawData        - PNG-������ ������ ������
   //===================================================================================================================

  TPhoaOp_GroupEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ������ (����� �������� ����������� ����� �������� �����������)
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ��������� ������
   //===================================================================================================================

  TPhoaOp_GroupDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ������, �������� �� TPhoaOp_GroupDelete, ������� ������ ������ (� �����������) � ��
   //   ��������� � ����������� ������������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ��������� ������
   //===================================================================================================================

  TPhoaOp_InternalGroupDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� �������������� ����������� �� �������
   //   Params:
   //     <none>
   //===================================================================================================================

  TPhoaOp_InternalUnlinkedPicsRemoving = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ����������� �������� �������������� �����������, ������ ����������� ��� ��������:
   //  - TPhoaOp_InternalEditPicFiles
   //  - TPhoaOp_InternalEditPicProps
   //  - TPhoaOp_InternalEditPicKeywords
   //  - TPhoaOp_InternalEditPicToGroupBelonging
   //   Params:
   //     EditFilesOpParams:    IPhoaOperationParams - ��������� ��� �������� �������� ��������� ������� �� ��������
   //                                                  [�������] ������
   //     EditViewOpParams:     IPhoaOperationParams - ��������� ��� �������� �������� ��������� ������� �� ��������
   //                                                  ���������
   //     EditDataOpParams:     IPhoaOperationParams - ��������� ��� �������� �������� ��������� ������� �� ��������
   //                                                  ������
   //     EditKeywordsOpParams: IPhoaOperationParams - ��������� ��� �������� �������� ��������� ������� �� ��������
   //                                                  �������� ����
   //     EditGroupOpParams:    IPhoaOperationParams - ��������� ��� �������� �������� ��������� ������� �� ��������
   //                                                  �������������� ����������� �������
   //===================================================================================================================

  TPhoaOp_PicEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ��������� ������ �����������
   //   Params:
   //     FileChangeList: IPhoaPicFileChangeList - ������ ��������� ��������� ������
   //===================================================================================================================

  TPhoaOp_InternalEditPicFiles = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������������� ������� �����������, ����� �������� ����
   //   Params:
   //     Pics:       IPhotoAlbumPicList         - ������ �����������, ��� �������� ����������
   //     ChangeList: IPhoaPicPropertyChangeList - ������ ��������� ��������� �������
   //===================================================================================================================

  TPhoaOp_InternalEditPicProps = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������������� �������� ���� �����������
   //   Params:
   //     Pics:        IPhotoAlbumPicList     - ������ �����������, ��� �������� ����� ����������
   //     KeywordList: IPhotoAlbumKeywordList - ������ �������� ����, ������� ����� ���������� ������������
   //===================================================================================================================

  TPhoaOp_InternalEditPicKeywords = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ��������� �������������� ����������� �������
   //   Params:
   //     Pics:             IPhotoAlbumPicList      - ������ �����������, ��� �������������� ������� ����������
   //     AddToGroups:      IPhotoAlbumPicGroupList - ������ �����, � ������� ���������� �������� ����������� Pics
   //     RemoveFromGroups: IPhotoAlbumPicGroupList - ������ �����, �� ������� ���������� ������� ����������� Pics
   //===================================================================================================================

  TPhoaOp_InternalEditPicToGroupBelonging = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ���������� �����������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� ����������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ����������� � ������� �����������
   //===================================================================================================================

  TPhoaOp_PicAdd = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� �� ������ ����������� �������
   //   Params:
   //     Pics: IPhotoAlbumPicList - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_InternalPicFromProjectRemoving = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� �������� ����������� (�� ������ �� ID) �� ������. �� ��������� ����� ����������� �����������!
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ������ ��������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_InternalPicFromGroupRemoving = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� (�� ������ �� ID) � ������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� ����������� �����������
   //     Pics:  IPhotoAlbumPicList  - ������ ����������� �����������
   //===================================================================================================================

  TPhoaOp_InternalPicToGroupAdding = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ����������� �� ���� ����� � �����������
   //   Params:
   //     Pics: IPhotoAlbumPicList  - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_PicDeleteFromProject = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ����������� �� ���� ����� � �������� ��������������� ������
   //   Params:
   //     Pics: IPhotoAlbumPicList  - ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_PicDeleteWithFiles = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ������� ���������� ����������� �� ������ ������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ������ ��������� �����������
   //===================================================================================================================

  TPhoaOp_PicPaste = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������������� ������� �������
   //   Params:
   //     NewThWidth:     Integer    - ����� ������ ������
   //     NewThHeight:    Integer    - ����� ������ ������
   //     NewThQuality:   Byte       - ����� �������� ������
   //     NewDescription: WideString - ����� �������� �������
   //===================================================================================================================

  TPhoaOp_ProjectEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // ���������� �������� ���������� ����������� � ����� ������
   //   Params:
   //     Group:    IPhotoAlbumPicGroup       - ������, � ������� ����������� �����������
   //     Sortings: IPhotoAlbumPicSortingList - ������ ����������
   //===================================================================================================================

  TPhoaOp_InternalGroupPicSort = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
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
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //   Params:
   //     Name:             WideString                 - ������������ �������������
   //     FilterExpression: WideString                 - ��������� ������� �����������
   //     Groupings:        IPhotoAlbumPicGroupingList - ������ ����������� �������������
   //     Sortings:         IPhotoAlbumPicSortingList  - ������ ���������� �������������
   //===================================================================================================================

  TPhoaOp_ViewNew = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� ��������� �������������
   //   Params:
   //     View:             IPhotoAlbumView            - ���������� �������������
   //     Name:             WideString                 - ����� ������������ �������������
   //     FilterExpression: WideString                 - ����� ��������� ������� �����������
   //     Groupings:        IPhotoAlbumPicGroupingList - ����� ������ ����������� �������������
   //     Sortings:         IPhotoAlbumPicSortingList  - ����� ������ ���������� �������������
   //       ���� Groupings=nil � Sortings=nil, ������, ��� ������ �������������� �������������
   //===================================================================================================================

  TPhoaOp_ViewEdit = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� �������������
   //   Params:
   //     <none>
   //===================================================================================================================

  TPhoaOp_ViewDelete = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

   //===================================================================================================================
   // �������� �������� ������ ����������� �� �������������
   //   Params:
   //     Group: IPhotoAlbumPicGroup - ������, ���� �������� ����� �������������
   //===================================================================================================================

  TPhoaOp_ViewMakeGroup = class(TPhoaOperation)
  protected
    procedure Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
    procedure RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges); override;
  end;

var
   // ���������� ��������� ������� ��������
  OperationFactory: IPhoaOperationFactory;

resourcestring
  SPhoaOpErrMsg_ParamNotFound         = 'Operation parameter named "%s" not found';
  SPhoaOpErrMsg_ParamTypeMismatch     = 'Operation parameter "%s" type mismatch. Expected: "%s", actual: "%s"';
  SPhoaOpErrMsg_CannotObtainParamIntf = 'Operation parameter "%s" doesn''t implement required interface';
  SPhoaOpErrMsg_OperationNotFound     = 'Operation "%s" not found';

   // ������ ��������� IPhoaOperationParams � ��������� ��� ����������� (�������� ���������� ������ ���� � Params
   //   ������: [���1, ��������1, ���2, ��������2, ...])
  function  NewPhoaOperationParams(const Params: Array of Variant): IPhoaOperationParams;
  function  NewPhoaPicPropertyChangeList: IPhoaPicPropertyChangeList;
  function  NewPhoaPicFileChangeList: IPhoaPicFileChangeList;
  function  NewPhoaUndoDataStream: IPhoaUndoDataStream;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses
  TypInfo, TntClipBrd,
  VirtualDataObject, GR32, DKLang,
  phUtils, phGraphics, ConsVars, phSettings, Variants;

   // ������ ����������� IPhotoAlbumPicGroupingList � Undo-����
  procedure UndoWriteGroupings(UndoStream: IPhoaUndoDataStream; Groupings: IPhotoAlbumPicGroupingList);
  var
    i: Integer;
    Grouping: IPhotoAlbumPicGrouping;
  begin
    UndoStream.WriteInt(Groupings.Count);
    for i := 0 to Groupings.Count-1 do begin
      Grouping := Groupings[i];
      UndoStream.WriteByte(Byte(Grouping.Prop));
      UndoStream.WriteBool(Grouping.UnclassifiedInOwnFolder);
    end;
  end;

   // ������ ����������� IPhotoAlbumPicGroupingList �� Undo-�����
  procedure UndoReadGroupings(UndoStream: IPhoaUndoDataStream; Groupings: IPhotoAlbumPicGroupingList);
  var
    i: Integer;
    Grouping: IPhotoAlbumPicGrouping;
  begin
    Groupings.Clear;
    for i := 0 to UndoStream.ReadInt-1 do begin
      Grouping := NewPhotoAlbumPicGrouping;
      Grouping.Prop                    := TPicGroupByProperty(UndoStream.ReadByte);
      Grouping.UnclassifiedInOwnFolder := UndoStream.ReadBool;
      Groupings.Add(Grouping);
    end;
  end;

   // ������ ����������� IPhotoAlbumPicSortingList � Undo-����
  procedure UndoWriteSortings(UndoStream: IPhoaUndoDataStream; Sortings: IPhotoAlbumPicSortingList);
  var
    i: Integer;
    Sorting: IPhotoAlbumPicSorting;
  begin
    UndoStream.WriteInt(Sortings.Count);
    for i := 0 to Sortings.Count-1 do begin
      Sorting := Sortings[i];
      UndoStream.WriteByte(Byte(Sorting.Prop));
      UndoStream.WriteByte(Byte(Sorting.Direction));
    end;
  end;

   // ������ ����������� IPhotoAlbumPicSortingList �� Undo-�����
  procedure UndoReadSortings(UndoStream: IPhoaUndoDataStream; Sortings: IPhotoAlbumPicSortingList);
  var
    i: Integer;
    Sorting: IPhotoAlbumPicSorting;
  begin
    Sortings.Clear;
    for i := 0 to UndoStream.ReadInt-1 do begin
      Sorting := NewPhotoAlbumPicSorting;
      Sorting.Prop      := TPicProperty(UndoStream.ReadByte);
      Sorting.Direction := TPhoaSortDirection(UndoStream.ReadByte);
      Sortings.Add(Sorting);
    end;
  end;

   //===================================================================================================================
   // TPhoaOperationParams
   //===================================================================================================================
type
  PPhoaOperationParam = ^TPhoaOperationParam;
  TPhoaOperationParam = record
    sName:  AnsiString; // ������������ ���������
    vValue: Variant;    // �������� ���������
  end;

  TPhoaOperationParams = class(TInterfacedObject, IPhoaOperationParams)
  private
     // ������ ����������
    FParams: Array of TPhoaOperationParam;
     // ������� �������� �� �������
    procedure Delete(iIndex: Integer);
     // ���������� �������� ��������� �� �����. ���� ������ ��������� ���, �������� Exception
    function  GetValueStrict(const sName: AnsiString): Variant;
     // ��������� ��� ��������. ��� �������������� �������� Exception
    procedure CheckVarType(const sName: AnsiString; const v: Variant; RequiredType: TVarType);
     // ���������� ������ ������ �� ����� ���������, ��� -1, ���� ��� �����
    function  IndexOfName(const sName: AnsiString): Integer;
     // IPhoaOperationParams
    procedure ObtainValIntf(const sName: AnsiString; GUID: TGUID; out Intf; bRequired: Boolean = True);
    function  GetCount: Integer;
    function  GetNames(Index: Integer): AnsiString;
    function  GetValBool(const sName: AnsiString): Boolean;
    function  GetValByte(const sName: AnsiString): Byte;
    function  GetValInt(const sName: AnsiString): Integer;
    function  GetValStr(const sName: AnsiString): WideString;
    function  GetValues(const sName: AnsiString): Variant;
    function  GetValuesByIndex(Index: Integer): Variant;
    procedure SetValues(const sName: AnsiString; const Value: Variant);
    procedure SetValuesByIndex(Index: Integer; const Value: Variant);
  public
    destructor Destroy; override;
  end;

  procedure TPhoaOperationParams.CheckVarType(const sName: AnsiString; const v: Variant; RequiredType: TVarType);
  begin
    if VarType(v)<>RequiredType then PhoaException(SPhoaOpErrMsg_ParamTypeMismatch, [sName, VarTypeAsText(RequiredType), VarTypeAsText(VarType(v))]);
  end;

  procedure TPhoaOperationParams.Delete(iIndex: Integer);
  var iNewCount: Integer;
  begin
    iNewCount := High(FParams);
     // ������������ ��������� �������
    Finalize(FParams[iIndex]);
     // �������� ��������
    Move(FParams[iIndex+1], FParams[iIndex], SizeOf(TPhoaOperationParam)*(iNewCount-iIndex));
     // �������� ��������� �������, ����� ��� "�� ��������������"
    FillChar(FParams[iNewCount], SizeOf(TPhoaOperationParam), 0);
     // ������� ������ ����������
    SetLength(FParams, iNewCount); 
  end;

  destructor TPhoaOperationParams.Destroy;
  begin
     // ������� ������
    FParams := nil;
    inherited Destroy;
  end;

  function TPhoaOperationParams.GetCount: Integer;
  begin
    Result := Length(FParams);
  end;

  function TPhoaOperationParams.GetNames(Index: Integer): AnsiString;
  begin
    Result := FParams[Index].sName;
  end;

  function TPhoaOperationParams.GetValBool(const sName: AnsiString): Boolean;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varBoolean);
    Result := v;
  end;

  function TPhoaOperationParams.GetValByte(const sName: AnsiString): Byte;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varByte);
    Result := v;
  end;

  function TPhoaOperationParams.GetValInt(const sName: AnsiString): Integer;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varInteger);
    Result := v;
  end;

  function TPhoaOperationParams.GetValStr(const sName: AnsiString): WideString;
  var v: Variant;
  begin
    v := GetValueStrict(sName);
    CheckVarType(sName, v, varOleStr);
    Result := v;
  end;

  function TPhoaOperationParams.GetValues(const sName: AnsiString): Variant;
  var idx: Integer;
  begin
    idx := IndexOfName(sName);
    if idx<0 then Result := Unassigned else Result := FParams[idx].vValue;
  end;

  function TPhoaOperationParams.GetValuesByIndex(Index: Integer): Variant;
  begin
    Result := FParams[Index].vValue;
  end;

  function TPhoaOperationParams.GetValueStrict(const sName: AnsiString): Variant;
  var idx: Integer;
  begin
    idx := IndexOfName(sName);
    if idx<0 then PhoaException(SPhoaOpErrMsg_ParamNotFound, [sName]);
    Result := FParams[idx].vValue;
  end;

  function TPhoaOperationParams.IndexOfName(const sName: AnsiString): Integer;
  begin
    for Result := 0 to High(FParams) do
       // ��� ��������� ����������, ��������� ��-Ansi-������, �.�. ��������� �� ������ ��������� ������������ �������� 
      if SameText(FParams[Result].sName, sName) then Exit;
    Result := -1;
  end;

  procedure TPhoaOperationParams.ObtainValIntf(const sName: AnsiString; GUID: TGUID; out Intf; bRequired: Boolean = True);
  var v: Variant;
  begin
    IInterface(Intf) := nil;
    if bRequired then v := GetValueStrict(sName) else v := GetValues(sName);
    if not VarIsEmpty(v) and not VarSupports(v, GUID, Intf) then PhoaException(SPhoaOpErrMsg_CannotObtainParamIntf, [sName]);
  end;

  procedure TPhoaOperationParams.SetValues(const sName: AnsiString; const Value: Variant);
  var idx: Integer;
  begin
    idx := IndexOfName(sName);
    if idx<0 then begin
      if not VarIsEmpty(Value) then begin
        idx := Length(FParams);
        SetLength(FParams, idx+1);
        FParams[idx].sName  := sName;
        FParams[idx].vValue := Value;
      end;
    end else
      SetValuesByIndex(idx, Value);
  end;

  procedure TPhoaOperationParams.SetValuesByIndex(Index: Integer; const Value: Variant);
  begin
    if VarIsEmpty(Value) then Delete(Index) else FParams[Index].vValue := Value;
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
    function  Add(const vNewValue: Variant; Prop: TPicProperty): Integer;
    function  GetChangedProps: TPicProperties;
    function  GetCount: Integer;
    function  GetItems(Index: Integer): PPicPropertyChange;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  function TPhoaPicPropertyChangeList.Add(const vNewValue: Variant; Prop: TPicProperty): Integer;
  var p: PPicPropertyChange;
  begin
    New(p);
    Result := FList.Add(p);
    p.vNewValue := vNewValue;
    p.Prop      := Prop;
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
   // TPhoaPicFileChangeList
   //===================================================================================================================
type
  TPhoaPicFileChangeList = class(TInterfacedObject, IPhoaPicFileChangeList)
  private
     // ���������� ������
    FList: TList;
     // ������� ������� �� ������
    procedure Delete(Index: Integer);
     // IPhoaPicFileChangeList
    function  Add(Pic: IPhotoAlbumPic; const wsFileName: WideString): Integer;
    function  GetCount: Integer;
    function  GetItems(Index: Integer): PPicFileChange;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  function TPhoaPicFileChangeList.Add(Pic: IPhotoAlbumPic; const wsFileName: WideString): Integer;
  var p: PPicFileChange;
  begin
    New(p);
    Result := FList.Add(p);
    p.Pic        := Pic;
    p.wsFileName := wsFileName;
  end;

  constructor TPhoaPicFileChangeList.Create;
  begin
    inherited Create;
    FList := TList.Create;
  end;

  procedure TPhoaPicFileChangeList.Delete(Index: Integer);
  begin
    Dispose(GetItems(Index));
    FList.Delete(Index);
  end;

  destructor TPhoaPicFileChangeList.Destroy;
  var i: Integer;
  begin
    for i := FList.Count-1 downto 0 do Delete(i);
    FList.Free;
    inherited Destroy;
  end;

  function TPhoaPicFileChangeList.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TPhoaPicFileChangeList.GetItems(Index: Integer): PPicFileChange;
  begin
    Result := FList[Index];
  end;

   //===================================================================================================================
   // TPhoaOperation
   //===================================================================================================================

  procedure TPhoaOperation.AddChild(OpClass: TPhoaOperationClass; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    OpClass.Create(Operations, Project, Params, Changes);
  end;

  constructor TPhoaOperation.Create(AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges);
  begin
    inherited Create;
    FProject := AProject;
     // �������������� � ������ ��������
    FList := AList;
    FList.Add(Self);
     // ���������� ������� Undo-������
    FUndoDataPosition := FList.UndoStream.Position;
     // ��������� ��������
    Perform(Params, FList.UndoStream, Changes); 
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
    if FOperations=nil then FOperations := TPhoaOperations.Create(List.UndoStream);
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

  function TPhoaOperation.Name: WideString;
  begin
    Result := DKLangConstW(ClassName);
  end;

  procedure TPhoaOperation.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
    { does nothing }
  end;

  procedure TPhoaOperation.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
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
  var UndoStream: IPhoaUndoDataStream;
  begin
    try
       // ������������� undo-���� � ����������� �������
      UndoStream := FList.UndoStream; 
      UndoStream.BeginUndo(FUndoDataPosition);
      try
         // ���������� ���������
        RollbackChanges(UndoStream, Changes);
      finally
         // ���������� ������� � undo-����� �� �����
        UndoStream.EndUndo(True);
      end;
    finally
       // ���������� ������
      Destroy;
    end;
  end;

   //===================================================================================================================
   // TPhoaOperationFactory - ���������� IPhoaOperationFactory
   //===================================================================================================================
type
  TPhoaOperationFactory = class(TInterfacedObject, IPhoaOperationFactory)
  private
     // ������ ������������������ �������
    FClasses: TStringList;
     // IPhoaOperationFactory
    function  GetClassByName(const sOpName: AnsiString): TPhoaOperationClass;
    function  NewOperation(const sOpName: AnsiString; AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges): TPhoaOperation;
    procedure RegisterOpClass(const sOpName: AnsiString; OpClass: TPhoaOperationClass);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  constructor TPhoaOperationFactory.Create;
  begin
    inherited Create;
    FClasses := TStringList.Create;
    FClasses.Sorted     := True;
    FClasses.Duplicates := dupError;
  end;

  destructor TPhoaOperationFactory.Destroy;
  begin
    FClasses.Free;
    inherited Destroy;
  end;

  function TPhoaOperationFactory.GetClassByName(const sOpName: AnsiString): TPhoaOperationClass;
  var idx: Integer;
  begin
    Result := nil; // Satisfy the compiler
    idx := FClasses.IndexOf(sOpName);
    if idx<0 then PhoaException(SPhoaOpErrMsg_OperationNotFound, [sOpName]) else Result := TPhoaOperationClass(FClasses.Objects[idx]);
  end;

  function TPhoaOperationFactory.NewOperation(const sOpName: AnsiString; AList: TPhoaOperations; AProject: IPhotoAlbumProject; Params: IPhoaOperationParams; var Changes: TPhoaOperationChanges): TPhoaOperation;
  begin
    Result := GetClassByName(sOpName).Create(AList, AProject, Params, Changes);
  end;

  procedure TPhoaOperationFactory.RegisterOpClass(const sOpName: AnsiString; OpClass: TPhoaOperationClass);
  begin
    FClasses.AddObject(sOpName, Pointer(OpClass));
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

  constructor TPhoaOperations.Create(AUndoStream: IPhoaUndoDataStream);
  begin
    inherited Create;
    FList := TList.Create;
    FUndoStream := AUndoStream;
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
    UndoStream.Clear;
  end;

  constructor TPhoaUndo.Create;
  begin
    inherited Create(NewPhoaUndoDataStream);
    FSavepointOnEmpty := True;
    FMaxCount := MaxInt;
  end;

  function TPhoaUndo.GetIsUnmodified: Boolean;
  begin
    if Count=0 then Result := FSavepointOnEmpty else Result := GetItems(Count-1).FSavepoint;
  end;

  function TPhoaUndo.GetLastOpName: WideString;
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

  procedure TPhoaUndo.SetNonUndoable(bModified: Boolean);
  begin
    Clear;
    FSavepointOnEmpty := not bModified;
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

  procedure TPhoaOp_GroupNew.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Group, NewGroup: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
     // ������ �������� ������
    NewGroup := NewPhotoAlbumPicGroup(Group, Project.RootGroupX.MaxGroupID+1);
    NewGroup.Text := DKLangConstW('SDefaultNewGroupName');
    OpParentGroup := Group;
    OpGroup       := NewGroup;
     // ���������� ����� Params ��������� ������
    Params['NewGroup'] := NewGroup;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_GroupNew.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // ������� ������ ��������
    OpGroup.Owner := nil;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupRename
   //===================================================================================================================

  procedure TPhoaOp_GroupRename.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ���������� ������ ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    OpGroup := Group;
    UndoStream.WriteWStr(Group.Text);
     // ��������� ��������
    Group.Text := Params.ValStr['NewText'];
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
  end;

  procedure TPhoaOp_GroupRename.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // �������� ������ � ��������������� �����
    OpGroup.Text := UndoStream.ReadWStr;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupEdit
   //===================================================================================================================

  procedure TPhoaOp_GroupEdit.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ���������� ������ ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    OpGroup := Group;
    UndoStream.WriteWStr(Group.Text);
    UndoStream.WriteWStr(Group.Description);
    UndoStream.WriteRaw (Group.IconData);
     // ��������� ��������
    Group.Text        := Params.ValStr['NewText'];
    Group.Description := Params.ValStr['NewDescription'];
    Group.IconData    := Params.ValStr['NewIconData'];
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
  end;

  procedure TPhoaOp_GroupEdit.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Group: IPhotoAlbumPicGroup;
  begin
     // �������� ������
    Group := OpGroup;
     // ��������������� ��������
    Group.Text        := UndoStream.ReadWStr;
    Group.Description := UndoStream.ReadWStr;
    Group.IconData    := UndoStream.ReadRaw;
     // ��������� ����� ���������
    Include(Changes, pocGroupProps);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDelete
   //===================================================================================================================

  procedure TPhoaOp_GroupDelete.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ������� ������ (� ���������)
    AddChild(TPhoaOp_InternalGroupDelete, Params, Changes);
     // ������� �������������� �����������
    AddChild(TPhoaOp_InternalUnlinkedPicsRemoving, Params, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupDelete
   //===================================================================================================================

  procedure TPhoaOp_InternalGroupDelete.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Group: IPhotoAlbumPicGroup;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ���������� ������ ��������� ������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    OpGroup       := Group;
    OpParentGroup := Group.OwnerX;
    UndoStream.WriteWStr(Group.Text);
    UndoStream.WriteWStr(Group.Description);
    UndoStream.WriteInt (Group.Index);
    UndoStream.WriteBool(Group.Expanded);
    UndoStream.WriteRaw (Group.IconData);
     // ���������� ID ����������� � ������� ����������� �� ������
    UndoStream.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoStream.WriteInt(Group.Pics[i].ID);
    Group.PicsX.Clear;
     // �������� ������� ������
    for i := Group.Groups.Count-1 downto 0 do
      AddChild(TPhoaOp_InternalGroupDelete, NewPhoaOperationParams(['Group', Group.GroupsX[i]]), Changes);
     // ������� ������
    Group.Owner := nil;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_InternalGroupDelete.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
  begin
     // ��������������� ������
    g := NewPhotoAlbumPicGroup(OpParentGroup, OpGroupID);
    g.Text        := UndoStream.ReadWStr;
    g.Description := UndoStream.ReadWStr;
    g.Index       := UndoStream.ReadInt;
    g.Expanded    := UndoStream.ReadBool;
    g.IconData    := UndoStream.ReadRaw;
     // ��������������� �����������
    for i := 0 to UndoStream.ReadInt-1 do g.PicsX.Add(Project.Pics.ItemsByID[UndoStream.ReadInt], False);
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
     // ��������������� ��������� ������
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalUnlinkedPicsRemoving
   //===================================================================================================================

  procedure TPhoaOp_InternalUnlinkedPicsRemoving.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Pic: IPhotoAlbumPic;
    UsedPics: IPhotoAlbumPicList;

     // ���������� ��������� � UsedPics ��� ����������� ������ � ��������� �����
    procedure AddGroupPics(Group: IPhotoAlbumPicGroup);
    var i: Integer;
    begin
      UsedPics.Add(Group.Pics, True);
      for i := 0 to Group.Groups.Count-1 do AddGroupPics(Group.GroupsX[i]);
    end;

  begin
    inherited Perform(Params, UndoStream, Changes);
     // ���������� ������ ������������ �����������
    UsedPics := NewPhotoAlbumPicList(True);
    AddGroupPics(Project.RootGroupX);
     // ���� �� ���� ������������ �����������
    for i := Project.Pics.Count-1 downto 0 do begin
      Pic := Project.PicsX[i];
       // ���� ����������� �� ������� �� � ����� �������
      if UsedPics.IndexOfID(Pic.ID)<0 then begin
         // ����� ���� �����������
        UndoStream.WriteBool(True);
         // ��������� ������ �����������
        UndoStream.WriteRaw(Pic.RawData[PPAllProps]);
         // ������� ����������� �� ������
        Project.PicsX.Delete(i);
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_InternalUnlinkedPicsRemoving.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // ������ ������, ���� �� �������� ����-����
    while UndoStream.ReadBool do
       // ������ �����������
      with NewPhotoAlbumPic do begin
         // ��������� ������
        RawData[PPAllProps] := UndoStream.ReadRaw;
         // ����� � ������ (ID ��� ��������)
        PutToList(Project.PicsX);
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicEdit
   //===================================================================================================================

  procedure TPhoaOp_PicEdit.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);

     // ��������� �������� ������ OpClass � �����������, ����������� �� ������������ ��������� � ������ sOpParamName,
     //   ���� �� ������
    procedure PerformIfSpecified(const sOpParamName: AnsiString; OpClass: TPhoaOperationClass);
    var OpParams: IPhoaOperationParams;
    begin
      Params.ObtainValIntf(sOpParamName, IPhoaOperationParams, OpParams, False);
      if OpParams<>nil then AddChild(OpClass, OpParams, Changes);
    end;

  begin
    inherited Perform(Params, UndoStream, Changes);
     // ��������� ��������� �������� ��������
    PerformIfSpecified('EditFilesOpParams',    TPhoaOp_InternalEditPicFiles);
    PerformIfSpecified('EditViewOpParams',     TPhoaOp_InternalEditPicProps);
    PerformIfSpecified('EditDataOpParams',     TPhoaOp_InternalEditPicProps);
    PerformIfSpecified('EditKeywordsOpParams', TPhoaOp_InternalEditPicKeywords);
    PerformIfSpecified('EditGroupOpParams',    TPhoaOp_InternalEditPicToGroupBelonging);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicFiles
   //===================================================================================================================

  procedure TPhoaOp_InternalEditPicFiles.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    FileChangeList: IPhoaPicFileChangeList;
    Pic: IPhotoAlbumPic;
    i: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('FileChangeList', IPhoaPicFileChangeList, FileChangeList);
     // ����� ���������� ���������
    UndoStream.WriteInt(FileChangeList.Count);
     // ���� �� ������ ��������� ���������
    for i := 0 to FileChangeList.Count-1 do begin
      Pic := FileChangeList[i].Pic;
       // ��������� ID � ������� ���� �����������
      UndoStream.WriteInt (Pic.ID);
      UndoStream.WriteWStr(Pic.FileName);
       // ��������� ����� ����
      Pic.FileName := FileChangeList[i].wsFileName;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
  end;

  procedure TPhoaOp_InternalEditPicFiles.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var i, iPicID: Integer;
  begin
     // ���������� ����� ������ ��������� ������������ �������
    for i := 0 to UndoStream.ReadInt-1 do begin
      iPicID   := UndoStream.ReadInt;
      Project.PicsX.ItemsByIDX[iPicID].FileName := UndoStream.ReadWStr;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicProps
   //===================================================================================================================

  procedure TPhoaOp_InternalEditPicProps.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    ChangeList: IPhoaPicPropertyChangeList;
    iPic, iChg: Integer;
    Pic: IPhotoAlbumPic;
    ChangedProps: TPicProperties;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics',       IPhotoAlbumPicList,         Pics);
    Params.ObtainValIntf('ChangeList', IPhoaPicPropertyChangeList, ChangeList);
     // ��������� ����� ������������ �������
    ChangedProps := ChangeList.ChangedProps;
    UndoStream.WriteInt(PicPropsToInt(ChangedProps));
     // ��������� ���������� �����������
    UndoStream.WriteInt(Pics.Count);
     // ���� �� ������������
    for iPic := 0 to Pics.Count-1 do begin
       // ���������� ������ ������
      Pic := Pics[iPic];
      UndoStream.WriteInt(Pic.ID);
      UndoStream.WriteRaw(Pic.RawData[ChangedProps]);
       // ��������� ����� ������
      for iChg := 0 to ChangeList.Count-1 do
        with ChangeList[iChg]^ do Pic.PropValues[Prop] := vNewValue;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
  end;

  procedure TPhoaOp_InternalEditPicProps.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i, iPicID: Integer;
    ChangedProps: TPicProperties;
    PicData: TPhoaRawData;
  begin
     // �������� ����� ��������� �������
    ChangedProps := IntToPicProps(UndoStream.ReadInt);
     // ���������� ������ ��������� �����������
    for i := 0 to UndoStream.ReadInt-1 do begin
      iPicID  := UndoStream.ReadInt;
      PicData := UndoStream.ReadRaw;
      Project.PicsX.ItemsByIDX[iPicID].RawData[ChangedProps] := PicData;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicKeywords
   //===================================================================================================================

  procedure TPhoaOp_InternalEditPicKeywords.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    KeywordList: IPhotoAlbumKeywordList;
    iPic, iCnt, iKwd, idxKeyword: Integer;
    Pic: IPhotoAlbumPic;
    wsKeyword: WideString;
    pkd: PPhoaKeywordData;
    bKWSaved: Boolean;
    PicKeywords: IPhotoAlbumKeywordList;

     // ��������� �������� ����� ����������� � FSavedKeywords, ���� ����� ��� �� �������
    procedure SavePicKeywords;
    begin
      if not bKWSaved then begin
        UndoStream.WriteBool(True); // ������� ������ ��������� ����� (� ����������������� ����-�����)
        UndoStream.WriteInt (Pic.ID);
        UndoStream.WriteWStr(Pic.Keywords.CommaText);
        bKWSaved := True;
         // ��������� ����� ���������
        Include(Changes, pocPicProps);
      end;
    end;

  begin
    inherited Perform(Params, UndoStream, Changes);
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
        wsKeyword := KeywordList[iKwd];
        pkd := KeywordList.KWData[iKwd];
        case pkd.Change of
           // �� �� ��������. ��������� ��������� �����
          pkcNone:
             // ���� Grayed - ������ ������ �� �����������. ���� �� ��������, � �� �� ���������� �� � ����� �����������
             //   - ������ ������. ���� �������� ���������, � �� ���������� �� ���� ������������ - ������ ������.
             //   ����� ��������� ������� �� � �����������
            if ((pkd.State=pksOff) and (pkd.iSelCount>0)) or ((pkd.State=pksOn) and (pkd.iSelCount<iCnt)) then begin
              idxKeyword := PicKeywords.IndexOf(wsKeyword);
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
                    PicKeywords.Add(wsKeyword);
                  end;
              end;
            end;
           // ���������� ������ ��. ���� ���� ����� - ���� ��������
          pkcAdd:
            if pkd.State=pksOn then begin
              SavePicKeywords;
              PicKeywords.Add(wsKeyword);
            end;
           // �� ��������. ���� ������ ��� �� ��������� ������������� � �����������, ...
          pkcReplace:
            if (pkd.State<>pksOff) or (pkd.iSelCount>0) then begin
               // ... ���� ������ �� � �������, ...
              idxKeyword := PicKeywords.IndexOf(pkd.wsOldKeyword);
              if idxKeyword>=0 then begin
                SavePicKeywords;
                PicKeywords.Delete(idxKeyword);
              end;
               // ... ���� ��������� pksOn - ��������� ����� ����, ���� pksGrayed - ��������� ������ � ��, ��� ���� ������
              if (pkd.State=pksOn) or ((pkd.State=pksGrayed) and (idxKeyword>=0)) then begin
                SavePicKeywords;
                PicKeywords.Add(wsKeyword);
              end;
            end;
        end;
      end;
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_InternalEditPicKeywords.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var iPicID: Integer;
  begin
     // ���������� �� ��������� ������������: ������ ����, ���� �� �������� ����-����
    while UndoStream.ReadBool do begin
      iPicID    := UndoStream.ReadInt;
      Project.PicsX.ItemsByIDX[iPicID].KeywordsM.CommaText := UndoStream.ReadWStr;
       // ��������� ����� ���������
      Include(Changes, pocPicProps);
    end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalEditPicToGroupBelonging
   //===================================================================================================================

  procedure TPhoaOp_InternalEditPicToGroupBelonging.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    AddToGroups, RemoveFromGroups: IPhotoAlbumPicGroupList;
    i: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics',             IPhotoAlbumPicList,      Pics);
    Params.ObtainValIntf('AddToGroups',      IPhotoAlbumPicGroupList, AddToGroups);
    Params.ObtainValIntf('RemoveFromGroups', IPhotoAlbumPicGroupList, RemoveFromGroups);
     // ������������ ����������
    for i := 0 to AddToGroups.Count-1 do
      AddChild(
        TPhoaOp_InternalPicToGroupAdding,
        NewPhoaOperationParams(['Group', AddToGroups[i], 'Pics', Pics]),
        Changes);
     // ������������ ��������
    for i := 0 to RemoveFromGroups.Count-1 do
      AddChild(
        TPhoaOp_InternalPicFromGroupRemoving,
        NewPhoaOperationParams(['Group', RemoveFromGroups[i], 'Pics', Pics]),
        Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_StoreTransform
   //===================================================================================================================

  procedure TPhoaOp_StoreTransform.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Pic: IPhotoAlbumPic;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pic', IPhotoAlbumPic, Pic);
     // ��������� ������� ��������
    UndoStream.WriteInt(Pic.ID);
    UndoStream.WriteByte(Byte(Pic.Rotation));
    UndoStream.WriteByte(Byte(Pic.Flips));
     // ��������� ����� ��������
    Pic.Rotation := TPicRotation(Params.ValByte['NewRotation']);
    Pic.Flips    := TPicFlips   (Params.ValByte['NewFlips']);
     // ��������� ����� ���������
    Include(Changes, pocPicProps);
  end;

  procedure TPhoaOp_StoreTransform.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Pic: IPhotoAlbumPic;
  begin
    Pic          := Project.PicsX.ItemsByIDX[UndoStream.ReadInt];
    Pic.Rotation := TPicRotation(UndoStream.ReadByte);
    Pic.Flips    := TPicFlips(Byte(UndoStream.ReadByte)); // �������� typecast, �� ����� �� �������������
     // ��������� ����� ���������
    Include(Changes, pocPicProps);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicAdd
   //===================================================================================================================

  procedure TPhoaOp_PicAdd.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Pics: IPhotoAlbumPicList;
    Group: IPhotoAlbumPicGroup;
    Pic, PicEx: IPhotoAlbumPic;
    bExisting, bAddedToGroup: Boolean;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
     // ��������� ������ ��� ������
    OpGroup := Group;
     // ���������� ��� ����� �����������
    UndoStream.WriteInt(Pics.Count);
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
       // ���� ��� ������������ ����������� � ��� �� ������
      PicEx := Project.PicsX.ItemsByFileNameX[Pic.FileName];
      bExisting := PicEx<>nil;
       // ���� ���� ����� ����������� - ���������� Pic
      if bExisting then
        Pic := PicEx
       // ����� ������� � ������, ����������� ����� ID
      else begin
        Pic.PutToList(Project.PicsX, 0);
        Include(Changes, pocProjectPicList);
      end;
       // ��������� ����������� � ������, ���� ��� ��� �� ����
      Group.PicsX.Add(Pic, True, bAddedToGroup);
      if bAddedToGroup then Include(Changes, pocGroupPicList);
       // ��������� ID �����������, ���� �������������, ���� ���������� � ������
      UndoStream.WriteInt(Pic.ID);
      UndoStream.WriteBool(bExisting);
      UndoStream.WriteBool(bAddedToGroup);
    end;
  end;

  procedure TPhoaOp_PicAdd.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    i, iPicID: Integer;
    bExisting, bAddedToGroup: Boolean;
  begin
     // �������� ������, ���� ��������� �����������
    Group := OpGroup;
     // ��������� ������ �� ������� �����������
    for i := 0 to UndoStream.ReadInt-1 do begin
      iPicID        := UndoStream.ReadInt;
      bExisting     := UndoStream.ReadBool;
      bAddedToGroup := UndoStream.ReadBool;
       // ���� ���� ��������� � ������ - �������
      if bAddedToGroup then begin
        Group.PicsX.Remove(iPicID);
        Include(Changes, pocGroupPicList);
      end;
       // ���� ���� ��������� ����� �����������, ������� � �� ������ �������
      if not bExisting then begin
        Project.PicsX.Remove(iPicID);
        Include(Changes, pocProjectPicList);
      end;
    end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicFromProjectRemoving
   //===================================================================================================================

  procedure TPhoaOp_InternalPicFromProjectRemoving.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Pics: IPhotoAlbumPicList;
    Pic: IPhotoAlbumPic;
    i: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics', IPhotoAlbumPicList, Pics);
     // ������� ����������� �� �����������
    for i := 0 to Pics.Count-1 do begin
       // ����� ���� �����������
      UndoStream.WriteBool(True);
       // ��������� ������ �����������
      Pic := Pics[i];
      UndoStream.WriteRaw(Pic.RawData[PPAllProps]);
       // ������� ����������� �� ������
      Project.PicsX.Remove(Pic.ID);
       // ��������� ����� ���������
      Include(Changes, pocProjectPicList);
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_InternalPicFromProjectRemoving.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // ������ ������, ���� �� �������� ����-����
    while UndoStream.ReadBool do
       // ������ �����������
      with NewPhotoAlbumPic do begin
         // ��������� ������
        RawData[PPAllProps] := UndoStream.ReadRaw;
         // ����� � ������ (ID ��� ��������)
        PutToList(Project.PicsX);
         // ��������� ����� ���������
        Include(Changes, pocProjectPicList);
      end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicFromGroupRemoving
   //===================================================================================================================

  procedure TPhoaOp_InternalPicFromGroupRemoving.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics:  IPhotoAlbumPicList;
    i, idx: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
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
        UndoStream.WriteBool(True);
         // ����� ID
        UndoStream.WriteInt(Pics[i].ID);
         // ����� ������
        UndoStream.WriteInt(idx);
         // ������� �����������
        Group.PicsX.Delete(idx);
         // ��������� ����� ���������
        Include(Changes, pocGroupPicList);
      end;
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_InternalPicFromGroupRemoving.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
    IIs: TIntegerList;
  begin
    g := OpGroup;
     // ��������� ID � ������� �� ��������� ������
    IIs := TIntegerList.Create(True);
    try
      while UndoStream.ReadBool do begin
        IIs.Add(UndoStream.ReadInt);
        IIs.Add(UndoStream.ReadInt);
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
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_InternalPicToGroupAdding
   //===================================================================================================================

  procedure TPhoaOp_InternalPicToGroupAdding.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics:  IPhotoAlbumPicList;
    i: Integer;
    bAdded: Boolean;
    Pic: IPhoaPic;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
    OpGroup := Group;
     // ��������� ����������� � ������ � � undo-����
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
      Group.PicsX.Add(Pic, True, bAdded);
      if bAdded then begin
        UndoStream.WriteBool(True); // ���� �����������
        UndoStream.WriteInt (Pic.ID);
         // ��������� ����� ���������
        Include(Changes, pocGroupPicList);
      end;
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_InternalPicToGroupAdding.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var g: IPhotoAlbumPicGroup;
  begin
     // ������� ����������� ����������� (��������� ID ����������� ����������� �� �����, ���� �� �������� ����-����)
    g := OpGroup;
    while UndoStream.ReadBool do begin
      g.PicsX.Remove(UndoStream.ReadInt);
       // ��������� ����� ���������
      Include(Changes, pocGroupPicList);
    end;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaBaseOp_PicCopy
   //===================================================================================================================

  constructor TPhoaBaseOp_PicCopy.Create(Pics: IPhotoAlbumPicList; ClipFormats: TPicClipboardFormats);

     // �������� � ����� ������ ������ ����������� PhoA
    procedure CopyPhoaData;
    var
      i, iSize: Integer;
      ms: TMemoryStream;
      Streamer: TPhoaStreamer;
      hRec: THandle;
      p: PByte;
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
        iSize := ms.Size;
         // �������� ������
        hRec := GlobalAlloc(GMEM_MOVEABLE, iSize+SizeOf(iSize));
        if hRec=0 then RaiseLastOSError;
         // ��������� ������, ������� ���������
        p := GlobalLock(hRec);
        if p=nil then RaiseLastOSError;
        try
           // ����� ������ �����
          Move(iSize, p^, SizeOf(iSize));
          Inc(p, SizeOf(iSize));
           // ������������ ������ � ������
          Move(ms.Memory^, p^, iSize);
        finally
          GlobalUnlock(hRec);
        end;
      finally
        ms.Free;
      end;
       // ��������
      TntClipboard.SetAsHandle(wClipbrdPicFormatID, hRec);
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
      ws: WideString;
    begin
       // ���������� ������ ������ ����� ������
      ws := '';
      for i := 0 to Pics.Count-1 do ws := ws+Pics[i].FileName+S_CRLF;
       // �������� ����� � clipboard
      TntClipboard.AsWideText := ws;
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
        TntClipboard.Assign(bmp32);
      finally
        bmp32.Free;
      end;
    end;

  begin
    StartWait;
    try
      if Pics.Count>0 then begin
        TntClipboard.Open;
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
          TntClipboard.Close;
        end;
      end;
    finally
      StopWait;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicDelete
   //===================================================================================================================

  procedure TPhoaOp_PicDelete.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ������� ����������� �� ������
    AddChild(TPhoaOp_InternalPicFromGroupRemoving, Params, Changes);
     // ������� ����������� ����������� �� �����������
    AddChild(TPhoaOp_InternalUnlinkedPicsRemoving, nil, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDeleteFromProject
   //===================================================================================================================

  procedure TPhoaOp_PicDeleteFromProject.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream;var Changes: TPhoaOperationChanges);

     // ����������� ��������� �������� ����������� �� ������ Group
    procedure DoDeletePics(Group: IPhotoAlbumPicGroup);
    var i: Integer;
    begin
       // ������� ����������� �� ������
      Params.Values['Group'] := Group;
      AddChild(TPhoaOp_InternalPicFromGroupRemoving, Params, Changes);
       // ���������� �������� ��� ��������
      for i := 0 to Group.GroupsX.Count-1 do DoDeletePics(Group.GroupsX[i]);
    end;

  begin
    inherited Perform(Params, UndoStream, Changes);
     // ������� ����������� �� �����
    DoDeletePics(Project.RootGroupX);
     // ������� ����������� �� �����������
    AddChild(TPhoaOp_InternalPicFromProjectRemoving, Params, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDeleteWithFiles
   //===================================================================================================================

  procedure TPhoaOp_PicDeleteWithFiles.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    Pics: IPhotoAlbumPicList;
    Pic: IPhotoAlbumPic;

     // ������� ����������� �� ������ Group � ���� � ��������
    procedure DoDeletePic(iPicID: Integer; Group: IPhotoAlbumPicGroup);
    var i: Integer;
    begin
       // ������� ����������� �� ������
      Group.PicsX.Remove(iPicID);
       // ��������� �� �� ��� ��������
      for i := 0 to Group.GroupsX.Count-1 do DoDeletePic(iPicID, Group.GroupsX[i]);
    end;

  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Pics', IPhotoAlbumPicList, Pics);
     // ���� �� ������������
    for i := 0 to Pics.Count-1 do begin
      Pic := Pics[i];
       // ������� ����
      if not DeleteFile(Pic.FileName) then PhoaExceptionConst('SErrCannotDeleteFile', [Pic.FileName, WideSysErrorMessage(GetLastError)]);
       // ������� ����������� �� ���� �����
      DoDeletePic(Pic.ID, Project.RootGroupX);
       // ������� ����������� �� ������ ����������� �������
      Project.PicsX.Remove(Pic.ID);
       // ��������� ����� ���������
      Changes := Changes+[pocGroupPicList, pocProjectPicList, pocNonUndoable];
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_PicPaste
   //===================================================================================================================

  procedure TPhoaOp_PicPaste.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    PastedPics: IPhotoAlbumPicList;
    hRec: THandle;
    ms: TMemoryStream;
    Streamer: TPhoaStreamer;
    p: PByte;
    iSize: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
    if TntClipboard.HasFormat(wClipbrdPicFormatID) then begin
       // �������� ���������
      Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
      OpGroup := Group;
       // ������ ������ ����������� ��� �������
      PastedPics := NewPhotoAlbumPicList(False);
       // ������ ��������� �����
      ms := TMemoryStream.Create;
      try
        TntClipboard.Open;
        try
           // �������� Handle ����� ������ �� ������ ������
          hRec := TntClipboard.GetAsHandle(wClipbrdPicFormatID);
          if hRec=0 then RaiseLastOSError;
           // �������� ������ ������ �� ������ ������
          p := GlobalLock(hRec);
          if p=nil then RaiseLastOSError;
          try
            Move(p^, iSize, SizeOf(iSize));
            Inc(p, SizeOf(iSize));
             // �������� ������ �� ������ ������
            ms.Write(p^, iSize);
          finally
            GlobalUnlock(hRec);
          end;
        finally
          TntClipboard.Close;
        end;
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
      AddChild(TPhoaOp_PicAdd, NewPhoaOperationParams(['Group', Group, 'Pics', PastedPics]), Changes);
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_ProjectEdit
   //===================================================================================================================

  procedure TPhoaOp_ProjectEdit.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ��������� ������ ��������
    UndoStream.WriteInt (Project.ThumbnailSize.cx);
    UndoStream.WriteInt (Project.ThumbnailSize.cy);
    UndoStream.WriteByte(Project.ThumbnailQuality);
    UndoStream.WriteWStr(Project.Description);
     // ��������� ��������
    Project.ThumbnailSize    := MakeSize(Params.ValInt['NewThWidth'], Params.ValInt['NewThHeight']);
    Project.ThumbnailQuality := Params.ValByte['NewThQuality'];
    Project.Description      := Params.ValStr ['NewDescription'];
     // ��������� ����� ���������
    Include(Changes, pocProjectProps);
  end;

  procedure TPhoaOp_ProjectEdit.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var Sz: TSize;
  begin
     // ��������������� �������� �����������
    Sz.cx   := UndoStream.ReadInt;
    Sz.cy   := UndoStream.ReadInt;
    Project.ThumbnailSize    := Sz;
    Project.ThumbnailQuality := UndoStream.ReadByte;
    Project.Description      := UndoStream.ReadWStr;
     // ��������� ����� ���������
    Include(Changes, pocProjectProps);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicOperation
   //===================================================================================================================

  procedure TPhoaOp_PicOperation.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    SourceGroup, TargetGroup: IPhotoAlbumPicGroup;
    Pics: IPhoaPicList;
    i: Integer;
    IntersectPics: IPhoaMutablePicList;
    Pic: IPhoaPic;
    PicOperation: TPictureOperation;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('SourceGroup', IPhotoAlbumPicGroup, SourceGroup);
    Params.ObtainValIntf('TargetGroup', IPhotoAlbumPicGroup, TargetGroup);
    Params.ObtainValIntf('Pics',        IPhoaPicList,        Pics);
    PicOperation := TPictureOperation(Params.ValByte['PicOperation']);
     // �����������/�����������: �������� ���������� �����������
    if PicOperation in [popMoveToTarget, popCopyToTarget] then
      AddChild(
        TPhoaOp_InternalPicToGroupAdding,
        NewPhoaOperationParams(['Group', TargetGroup, 'Pics', Pics]),
        Changes);
     // ���� ����������� - ������� ���������� ����������� �� �������� ������
    if PicOperation=popMoveToTarget then
      AddChild(
        TPhoaOp_InternalPicFromGroupRemoving,
        NewPhoaOperationParams(['Group', SourceGroup,'Pics', Pics]),
        Changes);
     // �������� ���������� ����������� �� ��������� ������
    if PicOperation=popRemoveFromTarget then
      AddChild(
        TPhoaOp_InternalPicFromGroupRemoving,
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
        AddChild(
          TPhoaOp_InternalPicFromGroupRemoving,
          NewPhoaOperationParams(['Group', TargetGroup, 'Pics', IntersectPics]),
          Changes);
        AddChild(TPhoaOp_InternalUnlinkedPicsRemoving, nil, Changes);
      end;
    end;
  end;

   //===================================================================================================================
   // TPhoaOp_InternalGroupPicSort
   //===================================================================================================================

  procedure TPhoaOp_InternalGroupPicSort.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Sortings: IPhotoAlbumPicSortingList;
    i: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',    IPhotoAlbumPicGroup,       Group);
    Params.ObtainValIntf('Sortings', IPhotoAlbumPicSortingList, Sortings);
     // ���������� ������
    OpGroup := Group;
     // ���������� ������� ���������� ID ����������� � ������
    UndoStream.WriteInt(Group.Pics.Count);
    for i := 0 to Group.Pics.Count-1 do UndoStream.WriteInt(Group.Pics[i].ID);
     // ��������� ����������� � ������
    Group.PicsX.SortingsSort(Sortings);
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
  end;

  procedure TPhoaOp_InternalGroupPicSort.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
     // ��������������� ������ ������� ���������� ID ����������� � ������
    OpGroup.PicsX.Clear;
    for i := 0 to UndoStream.ReadInt-1 do OpGroup.PicsX.Add(Project.Pics.ItemsByID[UndoStream.ReadInt], False);
     // ��������� ����� ���������
    Include(Changes, pocGroupPicList);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicSort
   //===================================================================================================================

  procedure TPhoaOp_PicSort.AddGroupSortOp(Group: IPhotoAlbumPicGroup; Sortings: IPhotoAlbumPicSortingList; bRecursive: Boolean; var Changes: TPhoaOperationChanges);
  var i: Integer;
  begin
     // ��������� ����������� � ������
    AddChild(TPhoaOp_InternalGroupPicSort, NewPhoaOperationParams(['Group', Group, 'Sortings', Sortings]), Changes);
     // ��� ������������� ��������� � � ����������
    if bRecursive then
      for i := 0 to Group.Groups.Count-1 do AddGroupSortOp(Group.GroupsX[i], Sortings, True, Changes);
  end;

  procedure TPhoaOp_PicSort.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Sortings: IPhotoAlbumPicSortingList;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',    IPhotoAlbumPicGroup,       Group);
    Params.ObtainValIntf('Sortings', IPhotoAlbumPicSortingList, Sortings);
     // ��������� ����������
    AddGroupSortOp(Group, Sortings, Params.ValBool['Recursive'], Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_GroupDragAndDrop
   //===================================================================================================================

  procedure TPhoaOp_GroupDragAndDrop.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group, NewParentGroup, gOldParent: IPhotoAlbumPicGroup;
    iNewIndex: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group',          IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('NewParentGroup', IPhotoAlbumPicGroup, NewParentGroup);
    iNewIndex := Params.ValInt['NewIndex'];
     // ���������� ������ ������
    gOldParent := Group.OwnerX;
    UndoStream.WriteInt(Group.Index);
     // ���������� ������
    Group.Owner := NewParentGroup;
    if iNewIndex>=0 then Group.Index := iNewIndex; // ������ -1 �������� ���������� ��������� �������
     // ���������� ������ (ID �������� �������� � ID ������)
    OpParentGroup := gOldParent;
    OpGroup       := Group;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
  end;

  procedure TPhoaOp_GroupDragAndDrop.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // ��������������� ��������� ������
    with OpGroup do begin
      Owner := OpParentGroup;
      Index := UndoStream.ReadInt;
    end;
     // ��������� ����� ���������
    Include(Changes, pocGroupStructure);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropToGroup
   //===================================================================================================================

  procedure TPhoaOp_PicDragAndDropToGroup.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    SourceGroup, TargetGroup: IPhotoAlbumPicGroup;
    Pics: IPhotoAlbumPicList;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('SourceGroup', IPhotoAlbumPicGroup, SourceGroup);
    Params.ObtainValIntf('TargetGroup', IPhotoAlbumPicGroup, TargetGroup);
    Params.ObtainValIntf('Pics',        IPhotoAlbumPicList,  Pics);
     // ��������� ��������
    AddChild(TPhoaOp_InternalPicToGroupAdding, NewPhoaOperationParams(['Group', TargetGroup, 'Pics', Pics]), Changes);
    if not Params.ValBool['Copy'] then
      AddChild(TPhoaOp_InternalPicFromGroupRemoving, NewPhoaOperationParams(['Group', SourceGroup, 'Pics', Pics]), Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_PicDragAndDropInsideGroup
   //===================================================================================================================

  procedure TPhoaOp_PicDragAndDropInsideGroup.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group: IPhotoAlbumPicGroup;
    Pics: IPhoaPicList;
    i, idxOld, iNewIndex: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Group', IPhotoAlbumPicGroup, Group);
    Params.ObtainValIntf('Pics',  IPhotoAlbumPicList,  Pics);
    iNewIndex := Params.ValInt['NewIndex'];
     // ���������� ������
    OpGroup := Group;
     // ��������� ��������
    for i := 0 to Pics.Count-1 do begin
       // -- ����� ������� �����������
      UndoStream.WriteBool(True);
       // -- ���������� �������
      idxOld := Group.Pics.IndexOfID(Pics[i].ID);
      if idxOld<iNewIndex then Dec(iNewIndex);
      UndoStream.WriteInt(idxOld);
      UndoStream.WriteInt(iNewIndex);
       // -- ���������� ����������� �� ����� �����
      Group.PicsX.Move(idxOld, iNewIndex);
      Inc(iNewIndex);
       // ��������� ����� ���������
      Include(Changes, pocGroupPicList);
    end;
     // ����� ����-����
    UndoStream.WriteBool(False);
  end;

  procedure TPhoaOp_PicDragAndDropInsideGroup.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    i: Integer;
    g: IPhotoAlbumPicGroup;
    Indexes: TIntegerList;
  begin
    g := OpGroup;
     // ��������� ������� �� ����� �� ��������� ������
    Indexes := TIntegerList.Create(True);
    try
      while UndoStream.ReadBool do begin
        Indexes.Add(UndoStream.ReadInt);
        Indexes.Add(UndoStream.ReadInt);
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
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewNew
   //===================================================================================================================

  procedure TPhoaOp_ViewNew.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Groupings: IPhotoAlbumPicGroupingList;
    Sortings: IPhotoAlbumPicSortingList;
    View: IPhotoAlbumView;
    iNewViewIndex: Integer;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('Groupings', IPhotoAlbumPicGroupingList, Groupings);
    Params.ObtainValIntf('Sortings',  IPhotoAlbumPicSortingList,  Sortings);
     // ��������� ���������� ������� ������ ������������� �������
    UndoStream.WriteInt(Project.ViewIndex);
     // ��������� ��������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name             := Params.ValStr['Name'];
    View.FilterExpression := Params.ValStr['FilterExpression'];
    View.GroupingsX.Assign(Groupings);
    View.SortingsX.Assign(Sortings);
     // ��������� ����� ������ �������������
    iNewViewIndex := View.Index;
    UndoStream.WriteInt(iNewViewIndex);
     // ����������� ������
    Project.ViewIndex := iNewViewIndex;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
  end;

  procedure TPhoaOp_ViewNew.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var iPrevViewIndex, iNewViewIndex: Integer;
  begin
     // �������� ���������� ������
    iPrevViewIndex := UndoStream.ReadInt;
    iNewViewIndex  := UndoStream.ReadInt;
     // ������� �������������
    Project.ViewsX.Delete(iNewViewIndex);
     // ��������������� ������� ��������� �������������
    Project.ViewIndex := iPrevViewIndex;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewEdit
   //===================================================================================================================

  procedure TPhoaOp_ViewEdit.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    View: IPhotoAlbumView;
    Groupings: IPhotoAlbumPicGroupingList;
    Sortings: IPhotoAlbumPicSortingList;
    bWriteGroupings, bWriteSortings: Boolean;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // �������� ���������
    Params.ObtainValIntf('View',      IPhotoAlbumView,            View);
    Params.ObtainValIntf('Groupings', IPhotoAlbumPicGroupingList, Groupings, False);
    Params.ObtainValIntf('Sortings',  IPhotoAlbumPicSortingList,  Sortings,  False);
     // ��������� ������ ������ � ��������� ���������
    UndoStream.WriteWStr(View.Name);
    UndoStream.WriteWStr(View.FilterExpression);
    View.Name             := Params.ValStr['Name'];
    View.FilterExpression := Params.ValStr['FilterExpression'];
     // ���������� ����� ������ ������������� (����� ���������� �����, �.�. ��� �������� ������� ������������� � ������)
    UndoStream.WriteInt(View.Index);
     // ������ ����������� ������ � ���������, ���� �� ����
    bWriteGroupings := Groupings<>nil;
    UndoStream.WriteBool(bWriteGroupings); // ������� ������� �����������
    if bWriteGroupings then begin
      UndoWriteGroupings(UndoStream, View.GroupingsX);
      View.GroupingsX.Assign(Groupings);
      View.Invalidate;
    end;
     // ������ ���������� ������ � ���������, ���� �� ����
    bWriteSortings := Sortings<>nil;
    UndoStream.WriteBool(bWriteSortings); // ������� ������� ����������
    if bWriteSortings then begin
      UndoWriteSortings(UndoStream, View.SortingsX);
      View.SortingsX.Assign(Sortings);
      View.Invalidate;
    end;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
     // ��������� ������� ������ ������������� (��� ���������� ����� �������������� �������������)
    Project.ViewIndex := View.Index;
  end;

  procedure TPhoaOp_ViewEdit.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    wsViewName, wsFilterExpression: WideString;
    iViewIndex: Integer;
    View: IPhotoAlbumView;
  begin
     // ��������������� �������������
    wsViewName         := UndoStream.ReadWStr;
    wsFilterExpression := UndoStream.ReadWStr;
    iViewIndex         := UndoStream.ReadInt;
    View := Project.ViewsX[iViewIndex];
    View.Name             := wsViewName;
    View.FilterExpression := wsFilterExpression;
    if UndoStream.ReadBool then UndoReadGroupings(UndoStream, View.GroupingsX);
    if UndoStream.ReadBool then UndoReadSortings (UndoStream, View.SortingsX);
    View.Invalidate;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
     // ��������� ������� ������ ������������� (��� ���������� ����� �������������� �������������)
    Project.ViewIndex := View.Index;
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewDelete
   //===================================================================================================================

  procedure TPhoaOp_ViewDelete.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var View: IPhotoAlbumView;
  begin
    inherited Perform(Params, UndoStream, Changes);
     // ��������� ������ ������
    View := Project.CurrentViewX;
    UndoStream.WriteWStr(View.Name);
    UndoWriteGroupings(UndoStream, View.GroupingsX);
    UndoWriteSortings (UndoStream, View.SortingsX);
     // ������� �������������
    Project.ViewsX.Delete(Project.ViewIndex);
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
  end;

  procedure TPhoaOp_ViewDelete.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var View: IPhotoAlbumView;
  begin
      // ������ �������������
    View := NewPhotoAlbumView(Project.ViewsX);
    View.Name := UndoStream.ReadWStr;
    UndoReadGroupings(UndoStream, View.GroupingsX);
    UndoReadSortings (UndoStream, View.SortingsX);
     // ������������ �������������
    Project.ViewIndex := View.Index;
     // ��������� ����� ���������
    Include(Changes, pocViewList);
    inherited RollbackChanges(UndoStream, Changes);
  end;

   //===================================================================================================================
   // TPhoaOp_ViewMakeGroup
   //===================================================================================================================

  procedure TPhoaOp_ViewMakeGroup.Perform(Params: IPhoaOperationParams; UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  var
    Group, ViewGroup: IPhotoAlbumPicGroup;
    View: IPhotoAlbumView;
  begin
    inherited Perform(Params, UndoStream, Changes);
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

  procedure TPhoaOp_ViewMakeGroup.RollbackChanges(UndoStream: IPhoaUndoDataStream; var Changes: TPhoaOperationChanges);
  begin
     // ������� �������� ������ ����� �������������
    OpGroup.Owner := nil;
     // ������������� ����� ����������� �����
    Project.ViewIndex := -1;
     // ��������� ����� ���������
    Changes := Changes+[pocViewIndex, pocGroupStructure];
    inherited RollbackChanges(UndoStream, Changes);
  end;

type  
   //===================================================================================================================
   // TPhoaUndoDataStream - ���������� IPhoaUndoDataStream, ���� ������ PhoA (����������� �� �������� �����)
   //===================================================================================================================
   // ������ �����:
   //    <������1><���1><������2><���2>...
   //    ������� � ������ ������ ����������� *�� ��������� ������ ������*

   // ��� ������, ����������� � �����
  TPhoaUndoDataStreamDatatype = (pudsdWideStr, pudsdInt, pudsdByte, pudsdBool, pudsdRaw);

  TPhoaUndoDataStream = class(TInterfacedObject, IPhoaDataStream, IPhoaUndoDataStream)
  private
     // �������� ����� ������ ������
    FStream: TFileStream;
     // ������� ����������� ������� BeginUndo/EndUndo
    FUndoCounter: Integer;
     // ���������, ����������� � ������ ������ BeginUndo
    FUndoPosition: Int64;
     // Prop storage
    FFileName: WideString;
     // ������ �����, ���� �� ��� �� ������
    procedure CreateStream;
     // ���������� � ����� ��� ������
    procedure WriteDatatype(DT: TPhoaUndoDataStreamDatatype);
     // ��������� �� ����� ���� ���� ������ � ��������� ��� �� ������������ DTRequired. ���� �� ���������, ��������
     //   Exception
    procedure ReadCheckDatatype(DTRequired: TPhoaUndoDataStreamDatatype);
     // IPhoaDataStream
    function  GetPosition: Int64;
    function  ReadBool: Boolean;
    function  ReadByte: Byte;
    function  ReadInt: Integer;
    function  ReadRaw:  TPhoaRawData;
    function  ReadWStr: WideString;
    procedure Clear;
    procedure WriteBool(b: Boolean);
    procedure WriteByte(b: Byte);
    procedure WriteInt (i: Integer);
    procedure WriteRaw (const Data: TPhoaRawData);
    procedure WriteWStr (const ws: WideString);
     // IPhoaUndoDataStream
    function  GetFileName: WideString;
    procedure BeginUndo(i64Position: Int64);
    procedure EndUndo(bTruncate: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
  end;

  procedure TPhoaUndoDataStream.BeginUndo(i64Position: Int64);
  begin
    if FUndoCounter=0 then FUndoPosition := i64Position;
    FStream.Position := i64Position;
    Inc(FUndoCounter);
  end;

  procedure TPhoaUndoDataStream.Clear;
  begin
    if FStream<>nil then begin
      FreeAndNil(FStream);
      SysUtils.DeleteFile(FFileName);
    end;
  end;

  constructor TPhoaUndoDataStream.Create;
  begin
    inherited Create;
     // ���������� ��� �����
    FFileName := Format('%sphoa_undo_%.8x.tmp', [GetWindowsTempPath, GetCurrentProcessId]);
  end;

  procedure TPhoaUndoDataStream.CreateStream;
  begin
    if FStream=nil then FStream := TFileStream.Create(FFileName, fmCreate);
  end;

  destructor TPhoaUndoDataStream.Destroy;
  begin
     // ���������� ����� � ����
    Clear;
    inherited Destroy;
  end;

  procedure TPhoaUndoDataStream.EndUndo(bTruncate: Boolean);
  begin
    Assert(FUndoCounter>0, 'Excessive TPhoaUndoDataStream.EndUndo() call');
    Dec(FUndoCounter);
     // ������� ��������� � ����. ���� ����, ������������� � ����������� ������� � ������� ����
    if (FUndoCounter=0) and bTruncate then begin
      FStream.Position := FUndoPosition;
      FStream.Size     := FUndoPosition;
    end;
  end;

  function TPhoaUndoDataStream.GetFileName: WideString;
  begin
    Result := FFileName;
  end;

  function TPhoaUndoDataStream.GetPosition: Int64;
  begin
    CreateStream;
    Result := FStream.Position;
  end;

  function TPhoaUndoDataStream.ReadBool: Boolean;
  begin
    ReadCheckDatatype(pudsdBool);
    Result := StreamReadByte(FStream)<>0;
  end;

  function TPhoaUndoDataStream.ReadByte: Byte;
  begin
    ReadCheckDatatype(pudsdByte);
    Result := StreamReadByte(FStream);
  end;

  procedure TPhoaUndoDataStream.ReadCheckDatatype(DTRequired: TPhoaUndoDataStreamDatatype);
  var DTActual: TPhoaUndoDataStreamDatatype;
  begin
    if FStream=nil then raise Exception.Create('Attempt of reading before writing to undo file');
    Byte(DTActual) := StreamReadByte(FStream);
    if DTActual<>DTRequired then
      raise Exception.CreateFmt(
        'Invalid undo stream datatype; required: %s, actual: %s',
        [GetEnumName(TypeInfo(TPhoaUndoDataStreamDatatype), Byte(DTRequired)), GetEnumName(TypeInfo(TPhoaUndoDataStreamDatatype), Byte(DTActual))]);
  end;

  function TPhoaUndoDataStream.ReadInt: Integer;
  begin
    ReadCheckDatatype(pudsdInt);
    Result := StreamReadInt(FStream);
  end;

  function TPhoaUndoDataStream.ReadRaw: TPhoaRawData;
  begin
    ReadCheckDatatype(pudsdRaw);
    Result := StreamReadRaw(FStream);
  end;

  function TPhoaUndoDataStream.ReadWStr: WideString;
  begin
    ReadCheckDatatype(pudsdWideStr);
    Result := StreamReadWStr(FStream);
  end;

  procedure TPhoaUndoDataStream.WriteBool(b: Boolean);
  begin
    CreateStream;
    WriteDatatype(pudsdBool);
    StreamWriteByte(FStream, Byte(b));
  end;

  procedure TPhoaUndoDataStream.WriteByte(b: Byte);
  begin
    CreateStream;
    WriteDatatype(pudsdByte);
    StreamWriteByte(FStream, b);
  end;

  procedure TPhoaUndoDataStream.WriteDatatype(DT: TPhoaUndoDataStreamDatatype);
  begin
    CreateStream;
    StreamWriteByte(FStream, Byte(DT));
  end;

  procedure TPhoaUndoDataStream.WriteInt(i: Integer);
  begin
    CreateStream;
    WriteDatatype(pudsdInt);
    StreamWriteInt(FStream, i);
  end;

  procedure TPhoaUndoDataStream.WriteRaw(const Data: TPhoaRawData);
  begin
    CreateStream;
    WriteDatatype(pudsdRaw);
    StreamWriteRaw(FStream, Data);
  end;

  procedure TPhoaUndoDataStream.WriteWStr(const ws: WideString);
  begin
    CreateStream;
    WriteDatatype(pudsdWideStr);
    StreamWriteWStr(FStream, ws);
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

  function NewPhoaPicFileChangeList: IPhoaPicFileChangeList;
  begin
    Result := TPhoaPicFileChangeList.Create;
  end;

  function  NewPhoaUndoDataStream: IPhoaUndoDataStream;
  begin
    Result := TPhoaUndoDataStream.Create;
  end;

initialization
  OperationFactory := TPhoaOperationFactory.Create;
  with OperationFactory do begin
    RegisterOpClass('GroupDelete',                     TPhoaOp_GroupDelete);
    RegisterOpClass('GroupDragAndDrop',                TPhoaOp_GroupDragAndDrop);
    RegisterOpClass('GroupEdit',                       TPhoaOp_GroupEdit);
    RegisterOpClass('GroupNew',                        TPhoaOp_GroupNew);
    RegisterOpClass('GroupRename',                     TPhoaOp_GroupRename);
    RegisterOpClass('InternalEditPicFiles',            TPhoaOp_InternalEditPicFiles);
    RegisterOpClass('InternalEditPicKeywords',         TPhoaOp_InternalEditPicKeywords);
    RegisterOpClass('InternalEditPicProps',            TPhoaOp_InternalEditPicProps);
    RegisterOpClass('InternalEditPicToGroupBelonging', TPhoaOp_InternalEditPicToGroupBelonging);
    RegisterOpClass('InternalGroupDelete',             TPhoaOp_InternalGroupDelete);
    RegisterOpClass('InternalGroupPicSort',            TPhoaOp_InternalGroupPicSort);
    RegisterOpClass('InternalPicFromGroupRemoving',    TPhoaOp_InternalPicFromGroupRemoving);
    RegisterOpClass('InternalPicToGroupAdding',        TPhoaOp_InternalPicToGroupAdding);
    RegisterOpClass('InternalUnlinkedPicsRemoving',    TPhoaOp_InternalUnlinkedPicsRemoving);
    RegisterOpClass('PicAdd',                          TPhoaOp_PicAdd);
    RegisterOpClass('PicDelete',                       TPhoaOp_PicDelete);
    RegisterOpClass('PicDeleteFromProject',            TPhoaOp_PicDeleteFromProject);
    RegisterOpClass('PicDeleteWithFiles',              TPhoaOp_PicDeleteWithFiles);
    RegisterOpClass('PicDragAndDropInsideGroup',       TPhoaOp_PicDragAndDropInsideGroup);
    RegisterOpClass('PicDragAndDropToGroup',           TPhoaOp_PicDragAndDropToGroup);
    RegisterOpClass('PicEdit',                         TPhoaOp_PicEdit);
    RegisterOpClass('PicOperation',                    TPhoaOp_PicOperation);
    RegisterOpClass('PicPaste',                        TPhoaOp_PicPaste);
    RegisterOpClass('PicSort',                         TPhoaOp_PicSort);
    RegisterOpClass('ProjectEdit',                     TPhoaOp_ProjectEdit);
    RegisterOpClass('StoreTransform',                  TPhoaOp_StoreTransform);
    RegisterOpClass('ViewDelete',                      TPhoaOp_ViewDelete);
    RegisterOpClass('ViewEdit',                        TPhoaOp_ViewEdit);
    RegisterOpClass('ViewMakeGroup',                   TPhoaOp_ViewMakeGroup);
    RegisterOpClass('ViewNew',                         TPhoaOp_ViewNew);
  end;
finalization
  OperationFactory := nil;
end.
