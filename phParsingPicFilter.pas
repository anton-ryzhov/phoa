//**********************************************************************************************************************
//  $Id: phParsingPicFilter.pas,v 1.1 2004-11-16 14:37:55 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Written by Andrew Dudko
//  Copyright 2002-2004 DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phParsingPicFilter;

interface

uses
  Windows, Classes, SysUtils, phIntf;

type
  EPhoaParseError = class(Exception)
  private
    FErrorPos: Integer;
  public
    constructor Create(iPos: Integer; const sMessage: String);
    constructor CreateFmt(iPos: Integer; const sMessage: String; const Params: Array of const);
    property ErrorPos: Integer read FErrorPos;
  end;

   // ������ - ��������� ������ � ���������� ���������
  IPhoaParsingPicFilter = interface(IInterface)
    ['{8C0A273B-FF72-433D-92C9-99633D69CA49}']
     // ��������� ������ ���������
    procedure ParseExpression(bCheck: Boolean);
     // ��������� �������� ������������ ��������� �� ������������
    procedure CheckExpression;
     // ���������, �� ���� �� ������ ��� ������� ���������, � ���� ����, ���������� Exception
    procedure CheckHasNoErrors;
     // ���������� True, ���� ����������� ������������� ��������� �������
    function  Matches(Pic: IPhoaPic): Boolean;
     // Prop handlers
    function  GetExpression: String;
    function  GetHasErrors: Boolean;
    function  GetParsed: Boolean;
    function  GetParseErrorMsg: String;
    function  GetParseErrorPos: Integer;
    procedure SetExpression(const sValue: String);
     // Props
     // -- ������� ���������
    property Expression: String read GetExpression write SetExpression;
     // -- �������� �� ����������� ��������� ������
    property HasErrors: Boolean read GetHasErrors;
     // -- ��������� �� ������� ���������
    property Parsed: Boolean read GetParsed;
     // -- ������� ������ � ���������
    property ParseErrorPos: Integer read GetParseErrorPos;
     // -- ��������� �� ������ ��� ������� ���������
    property ParseErrorMsg: String read GetParseErrorMsg;
  end;

   // ������ ����� ��������� IPhoaParsingPicFilter
  function  NewPhoaParsingPicFilter: IPhoaParsingPicFilter;

  procedure PhoaParseError(iPos: Integer; const sMsg: String); overload;
  procedure PhoaParseError(iPos: Integer; const sMsg: String; const Params: Array of const); overload;

implementation

uses phPhoa; /////////////////////////////////////////////////////////////////////////////////////////////////////////

type
  TChars = set of Char;
  
   // ��� ������
  TBracketType = (btOpen, btClose);

   // ��� ���������
  TOperatorKind = (
    okAnd, okOr, okNot, okIn, okStartsWith, okEndsWith, okContains, okIsEmpty, okEQ, okNotEQ, okLT, okLE, okGT, okGE);

   // ��� ����
  TFieldKind = (
    fkID, fkAuthor, fkDate, fkTime, fkDescription,
    fkFileName, fkFileSize, fkFilmNumber, fkFlips, fkFrameNumber,
    fkImageFormat, fkImageWidth, fkImageHeight,
    fkKeywords, fkMedia, fkNotes, fkPlace, fkRotation,
    fkThumbnailWidth, fkThumbnailHeight);

   // ��� ������  
  TDatatype = (dtString, dtInteger, dtFloat, dtDate, dtTime, dtBoolean, dtList);

  IPhoaParsedItem      = interface;
  IPhoaParsedOperand   = interface;
  IPhoaParsedOperator  = interface;
  IPhoaParsedItemsList = interface;
   //===================================================================================================================
   // Not available
   //===================================================================================================================


  IPhoaParsedItem = interface(IInterface)
    ['{947B9A40-35C8-11D9-8FCB-B07033DC0000}']
     // �������� exception "�������� �������"
    procedure OperandExpected;
     // �������� exception "�������� ��������"
    procedure OperatorExpected;
     // �������� exception "������������ ��� ������"
    procedure InvalidDatatype;
     // �������� exception "������������ ��� ���������"
    procedure InvalidOperatorKind;
     // �������� �� ������� ����������
    function  IsOperator: Boolean;
     // ������ � ���������� ��������
    function  AsOperand: IPhoaParsedOperand;
     // ������ � ���������� ���������
    function  AsOperator: IPhoaParsedOperator;
     // Prop handlers
    function  GetPosition: Integer;
    function  GetDescription: String;
     // Props
     // -- �������� ������� � ������
    property Position: Integer read GetPosition;
     // -- �������� �������� (��� �������)
    property Description: String read GetDescription;
  end;

  IPhoaParsedItemsList = interface(IInterfaceList)
    ['{947B9A41-35C8-11D9-8FCB-B07033DC0000}']
     // ��������� ������� � ������� �����, ������ ��� �� ������
    function  Pop: IPhoaParsedItem;
     // ������� ������� �����; nil, ���� ������ ����
    function  Top: IPhoaParsedItem;
     // Prop handlers
    function  GetItems(Index: Integer): IPhoaParsedItem;
    procedure SetItems(Index: Integer; Value: IPhoaParsedItem);
     // Props
     // -- �������� �� �������
    property Items[Index: Integer]: IPhoaParsedItem read GetItems write SetItems; default;
  end;

  IPhoaParsedOperand = interface(IPhoaParsedItem)
     // ���������� ������ �������� ��������
    function  AsBoolean(Pic: IPhoaPic): Boolean;
     // ���������� ��������-���� ��������
    function  AsDate(Pic: IPhoaPic): Integer;
     // ���������� ������������ �������� ��������
    function  AsFloat(Pic: IPhoaPic): Double;
     // ���������� ����� �������� ��������
    function  AsInteger(Pic: IPhoaPic): Integer;
     // ���������� ��������-������
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList;
     // ���������� ��������� �������� ��������
    function  AsString(Pic: IPhoaPic): String;
     // ���������� ��������-����� ��������
    function  AsTime(Pic: IPhoaPic): Integer;
     // Prop handlers
    function  GetDatatype: TDatatype;
     // Props
     // -- �������� ��� ������
    property Datatype: TDatatype read GetDatatype;
  end;

  IPhoaParsedOperator = interface(IPhoaParsedItem)
     // �������� �� ������� ������� ����������
    function  IsUnaryOperator: Boolean;
     // True, ���� ������� �������� ����������� �������
    function  IsOpenBracket: Boolean;
     // True, ���� ������� �������� ����������� �������
    function  IsCloseBracket: Boolean;
     // ��������� �������� ��� ���������� � �����. ���� ��� ����������, ��������� Exception.
    procedure Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic);
     // Prop handlers
    function  GetPriority: Integer;
     // Props
     // -- ��������� ���������
    property Priority: Integer read GetPriority;
  end;

  TPhoaParsedItem = class;
  TPhoaParsedItemsList = class(TInterfaceList, IPhoaParsedItemsList, IPhoaKeywordList)
  protected
     // IPhoaParsedItemList
    function  GetItems(Index: Integer): IPhoaParsedItem;
    procedure SetItems(Index: Integer; Value: IPhoaParsedItem);
    function  Pop: IPhoaParsedItem;
    function  Top: IPhoaParsedItem;
    property  Items[Index: Integer]: IPhoaParsedItem read GetItems write SetItems; default;
     // IPhoaKeywordList
    function  IPhoaKeywordList.IndexOf      = KWL_IndexOf;
    function  IPhoaKeywordList.GetCommaText = KWL_GetCommaText;
    function  IPhoaKeywordList.GetCount     = KWL_GetCount;
    function  IPhoaKeywordList.GetItems     = KWL_GetItems;
    function  KWL_IndexOf(const sKeyword: String): Integer; stdcall;
    function  KWL_GetCommaText: String; stdcall;
    function  KWL_GetCount: Integer; stdcall;
    function  KWL_GetItems(Index: Integer): String; stdcall;
  end;

  TPhoaParsedItem = class(TInterfacedObject, IPhoaParsedItem)
  protected
     // Prop storage
    FPosition: Integer;
     // IPhoaParsedItem
    procedure OperandExpected;
    procedure OperatorExpected;
    procedure InvalidDatatype;
    procedure InvalidOperatorKind;
    function  GetPosition: Integer;
    function  GetDescription: String; virtual; abstract;
    function  IsOperator: Boolean; virtual; abstract;
    function  AsOperand: IPhoaParsedOperand; virtual;
    function  AsOperator: IPhoaParsedOperator; virtual;
    property Description: String read GetDescription;
    property Position: Integer read GetPosition;
  public
    constructor Create(iPos: Integer);
  end;

   // ����������� ������� ����� ��������
  TPhoaParsedOperand = class(TPhoaParsedItem, IPhoaParsedOperand)
  protected
    function  IsOperator: Boolean; override;
    function  AsOperand: IPhoaParsedOperand; override;
     // IPhoaParsedOperand
    function  AsBoolean(Pic: IPhoaPic): Boolean; virtual;
    function  AsString(Pic: IPhoaPic): String; virtual;
    function  AsDate(Pic: IPhoaPic): Integer; virtual;
    function  AsTime(Pic: IPhoaPic): Integer; virtual;
    function  AsInteger(Pic: IPhoaPic): Integer; virtual;
    function  AsFloat(Pic: IPhoaPic): Double; virtual;
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; virtual;
    function  GetDatatype: TDatatype; virtual; abstract;
    property Datatype: TDatatype read GetDatatype;
  end;

   // ����������� ������� ����� ���������
  TPhoaParsedCustomOperator = class(TPhoaParsedItem, IPhoaParsedOperator)
  protected
    function  IsOperator: Boolean; override;
    function  AsOperator: IPhoaParsedOperator; override;
     // IPhoaParsedOperator
    function  IsUnaryOperator: Boolean; virtual;
    function  IsOpenBracket: Boolean; virtual;
    function  IsCloseBracket: Boolean; virtual;
    procedure Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic); virtual; 
    function  GetPriority: Integer; virtual; abstract;
    property Priority: Integer read GetPriority;
  end;

  TPhoaParsedBracket = class(TPhoaParsedCustomOperator)
  protected
     // ��� ������
    FBracketType: TBracketType;
    function  GetDescription: String; override;
    function  GetPriority: Integer; override;
    function  IsOpenBracket: Boolean; override;
    function  IsCloseBracket: Boolean; override;
  public
    constructor Create(cBracket: Char; iPos: Integer);
  end;

  TPhoaParsedOperator = class(TPhoaParsedCustomOperator)
  protected
     // ��� ���������
    FKind: TOperatorKind;
     // ���������� ��� �������� � ������ ���� ���������
    function  CompareValues(Val1, Val2: Integer): Boolean; overload;
    function  CompareValues(const Val1, Val2: Double): Boolean; overload;
    function  CompareValues(const Val1, Val2: String): Boolean; overload;
    function  CompareValues(const Val1, Val2: Boolean): Boolean; overload;
    function  IsUnaryOperator: Boolean; override;
    function  GetDescription: String; override;
    function  GetPriority: Integer; override;
    procedure Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic); override;
     // ��������� �������� ��� ����� String ����������
    function  CompareAsStrings(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
     // ��������� �������� ��� ����� Boolean ����������
    function  CompareAsBoolean(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
     // ��������� �������� ��� ����� Integer ����������
    function  CompareAsInteger(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
     // ��������� �������� ��� ����� Float ����������
    function  CompareAsFloat(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
     // ��������� �������� ��� ����� Date ����������
    function  CompareAsDate(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
     // ��������� �������� ��� ����� Time ����������
    function  CompareAsTime(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  public
    constructor Create(const sKind: String; iPos: Integer);
  end;

  TPhoaParsedLiteral = class(TPhoaParsedOperand)
  protected
     // �������� ��������
    FValue: String;
    function  AsString(Pic: IPhoaPic): String; override;
    function  AsDate(Pic: IPhoaPic): Integer; override;
    function  AsTime(Pic: IPhoaPic): Integer; override;
    function  GetDatatype: TDatatype; override;
    function  GetDescription: String; override;
  public
    constructor Create(const sValue: String; iPos: Integer);
  end;

  TPhoaParsedField = class(TPhoaParsedOperand)
  protected
     // ��� ����
    FKind: TFieldKind;
    function  AsString(Pic: IPhoaPic): String; override;
    function  AsDate(Pic: IPhoaPic): Integer; override;
    function  AsTime(Pic: IPhoaPic): Integer; override;
    function  AsInteger(Pic: IPhoaPic): Integer; override;
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; override;
    function  GetDatatype: TDatatype; override;
    function  GetDescription: String; override;
  public
    constructor Create(const sKind: String; iPos: Integer);
  end;

  TPhoaParsedValue = class(TPhoaParsedOperand)
  protected
     // ��������� ������������� ��������
    FStringValue: String;
     // ������� ��� ������
    FCurrentDatatype: TDatatype;
    function  AsInteger(Pic: IPhoaPic): Integer; override;
    function  AsFloat(Pic: IPhoaPic): Double; override;
    function  GetDatatype: TDatatype; override;
    function  GetDescription: String; override;
  public
    constructor Create(const sStringValue: String; iPos: Integer);
  end;

  TPhoaParsedList = class(TPhoaParsedOperand)
  private
     // Prop storage
    FItemList: IPhoaParsedItemsList;
     // Prop handlers
    function  GetItemList: IPhoaParsedItemsList;
  protected
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; override;
    function  GetDatatype: TDatatype; override;
    function  GetDescription: String; override;
     // Props
     // -- ������ ���������
    property ItemList: IPhoaParsedItemsList read GetItemList;
  end;

  TPhoaParsedBoolean = class(TPhoaParsedOperand)
  protected
     // ��������
    FValue: Boolean;
    function  AsBoolean(Pic: IPhoaPic): Boolean; override;
    function  GetDatatype: TDatatype; override;
    function  GetDescription: String; override;
  public
    constructor Create(bValue: Boolean; iPos: Integer);
  end;

   //===================================================================================================================

const
  CSSpaceChars    = [#9, #10, #12, #13, ' '];
  CSBrackets      = ['(', ')'];
  CSDigits        = ['0'..'9'];
  CSEngChars      = ['a'..'z', 'A'..'Z'];
  CSMathCompChars = ['<', '>', '='];
  CSIDStartChars  = CSEngChars+['_'];
  CSIDChars       = CSIDStartChars+CSDigits;
  CSValueChars    = CSDigits+['.', '-'];

  ASOperatorKinds: Array [TOperatorKind] of String = (
    'AND', 'OR', 'NOT', 'IN', 'STARTSWITH', 'ENDSWITH', 'CONTAINS', 'ISEMPTY',
    '=', '<>', '<', '<=', '>', '>=');
  ASFieldKinds: Array [TFieldKind] of String = (
    'ID', 'AUTHOR', 'DATE', 'TIME', 'DESCRIPTION', 'FILENAME', 'FILESIZE', 'FILMNUMBER', 'FLIPS', 'FRAMENUMBER',
    'IMAGEFORMAT', 'IMAGEWIDTH', 'IMAGEHEIGHT', 'KEYWORDS', 'MEDIA', 'NOTES', 'PLACE', 'ROTATION', 'THUMBNAILWIDTH',
    'THUMBNAILHEIGHT');
  OSUnaryOperators = [okNot, okIsEmpty];
  FKSStringFields  = [fkAuthor, fkDescription, fkFileName, fkFilmNumber, fkFrameNumber, fkMedia, fkNotes, fkPlace];
  FKSIntegerFields = [fkID, fkFileSize, fkImageWidth, fkImageHeight, fkThumbnailWidth, fkThumbnailHeight];
  FKSDateFields    = [fkDate];
  FKSTimeFields    = [fkTime];
  FKSListFields    = [fkKeywords];
   // dtString, dtInteger, dtFloat, dtDate, dtTime, dtBoolean, dtList
  DatatypeCastMap: Array [TDatatype, TDatatype] of TDatatype = (
    (dtString,  dtInteger, dtFloat,   dtDate,    dtTime,    dtString,  dtString),
    (dtInteger, dtInteger, dtFloat,   dtInteger, dtInteger, dtInteger, dtInteger),
    (dtFloat,   dtFloat,   dtFloat,   dtFloat,   dtFloat,   dtFloat,   dtFloat),
    (dtDate,    dtDate,    dtDate,    dtDate,    dtDate,    dtDate,    dtDate),
    (dtTime,    dtTime,    dtTime,    dtTime,    dtTime,    dtTime,    dtTime),
    (dtBoolean, dtBoolean, dtBoolean, dtBoolean, dtBoolean, dtBoolean, dtBoolean),
    (dtList,    dtList,    dtList,    dtList,    dtList,    dtList,    dtList));

var
   // ����������� ��� ������� ��������� �������, ��� DecimalSeparator='.'
  ParserFormatSettings: TFormatSettings;

resourcestring
  SPhoaParseError_NoExpression                = '����������� ���������';
  SPhoaParseError_InvalidExpression           = '������������ ���������';
  SPhoaParseError_InvalidCharacter            = '������������ ������: %s';
  SPhoaParseError_InvalidOperator             = '������������ ��������: %s';
  SPhoaParseError_InvalidOperatorKind         = '������������ ��� ���������';
  SPhoaParseError_InvalidField                = '������������ ����: %s';
  SPhoaParseError_StringLiteralNotTerminated  = '��������� ������� �� ��������';
  SPhoaParseError_ListNotTerminated           = '������ �� ��������';
  SPhoaParseError_ListItemExpected            = '�������� ������� ������';
  SPhoaParseError_SomethingExpected           = '���������: %s';
  SPhoaParseError_DigitExpected               = '��������� �����';
  SPhoaParseError_OperatorExpected            = '�������� ��������';
  SPhoaParseError_OperandExpected             = '�������� �������';
  SPhoaParseError_UnbalancedBrackets          = '���������������� ������';
  SPhoaParseError_StackIsEmpty                = '���� ��������� ����';
  SPhoaParseError_InvalidDatatype             = '������������ ��� ������';

  procedure PhoaParseError(iPos: Integer; const sMsg: String);
  begin
    raise EPhoaParseError.Create(iPos, sMsg);
  end;

  procedure PhoaParseError(iPos: Integer; const sMsg: String; const Params: Array of const);
  begin
    raise EPhoaParseError.CreateFmt(iPos, sMsg, Params);
  end;

   //===================================================================================================================
   // EPhoaParseError
   //===================================================================================================================

  constructor EPhoaParseError.Create(iPos: Integer; const sMessage: String);
  begin
    inherited Create(sMessage);
    FErrorPos := iPos;
  end;

  constructor EPhoaParseError.CreateFmt(iPos: Integer; const sMessage: String; const Params: array of const);
  begin
    inherited CreateFmt(sMessage, Params);
    FErrorPos := iPos;
  end;

   //===================================================================================================================
   // TPhoaParsedItemsList
   //===================================================================================================================

  function TPhoaParsedItemsList.GetItems(Index: Integer): IPhoaParsedItem;
  begin
    Result := IPhoaParsedItem(Get(Index));
  end;

  function TPhoaParsedItemsList.KWL_GetCommaText: String;
  var i: Integer;
  begin
    Result := '';
    for i := 0 to Count-1 do begin
      // !!! ���� ������� CommaText
    end;
  end;

  function TPhoaParsedItemsList.KWL_GetCount: Integer;
  begin
    Result := Count;
  end;

  function TPhoaParsedItemsList.KWL_GetItems(Index: Integer): String;
  begin
    Result := Items[Index].AsOperand.AsString(nil);
  end;

  function TPhoaParsedItemsList.KWL_IndexOf(const sKeyword: String): Integer;
  begin
    for Result := 0 to Count-1 do
      if AnsiCompareText(Items[Result].AsOperand.AsString(nil), sKeyword)=0 then Exit;
    Result := -1;
  end;

  function TPhoaParsedItemsList.Pop: IPhoaParsedItem;
  var iLast: Integer;
  begin
     // �������� ������ ���������� ��������
    iLast := Count-1;
    if iLast<0 then PhoaParseError(0, SPhoaParseError_StackIsEmpty);
     // ���������� ��������� ������� ������
    Result := Items[iLast];
     // ������� ��� �� ������
    Delete(iLast);
  end;

  procedure TPhoaParsedItemsList.SetItems(Index: Integer; Value: IPhoaParsedItem);
  begin
    Put(Index, Value);
  end;

  function TPhoaParsedItemsList.Top: IPhoaParsedItem;
  var iCount: Integer;
  begin
    iCount := Count;
    if iCount=0 then Result := nil else Result := Items[iCount-1];
  end;

   //===================================================================================================================
   // TPhoaParsedItem
   //===================================================================================================================

  function TPhoaParsedItem.AsOperand: IPhoaParsedOperand;
  begin
     // ������� ����� �� ����� ������������ ���� � ���� ��������
    OperandExpected;
  end;

  function TPhoaParsedItem.AsOperator: IPhoaParsedOperator;
  begin
     // ������� ����� �� ����� ������������ ���� � ���� ���������
    OperatorExpected;
  end;

  constructor TPhoaParsedItem.Create(iPos: Integer);
  begin
    inherited Create;
    FPosition := iPos;
  end;

  function TPhoaParsedItem.GetPosition: Integer;
  begin
    Result := FPosition;
  end;

  procedure TPhoaParsedItem.InvalidDatatype;
  begin
    PhoaParseError(Position, SPhoaParseError_InvalidDatatype);
  end;

  procedure TPhoaParsedItem.InvalidOperatorKind;
  begin
    PhoaParseError(Position, SPhoaParseError_InvalidOperatorKind);
  end;

  procedure TPhoaParsedItem.OperandExpected;
  begin
    PhoaParseError(Position, SPhoaParseError_OperandExpected);
  end;

  procedure TPhoaParsedItem.OperatorExpected;
  begin
    PhoaParseError(Position, SPhoaParseError_OperatorExpected);
  end;

   //===================================================================================================================
   // TPhoaParsedOperand
   //===================================================================================================================

  function TPhoaParsedOperand.AsBoolean(Pic: IPhoaPic): Boolean;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := False;
  end;

  function TPhoaParsedOperand.AsDate(Pic: IPhoaPic): Integer;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := 0;
  end;

  function TPhoaParsedOperand.AsFloat(Pic: IPhoaPic): Double;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := 0;
  end;

  function TPhoaParsedOperand.AsInteger(Pic: IPhoaPic): Integer;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := 0;
  end;

  function TPhoaParsedOperand.AsList(Pic: IPhoaPic): IPhoaKeywordList;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
  end;

  function TPhoaParsedOperand.AsOperand: IPhoaParsedOperand;
  begin
    Result := Self;
  end;

  function TPhoaParsedOperand.AsString(Pic: IPhoaPic): String;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
  end;

  function TPhoaParsedOperand.AsTime(Pic: IPhoaPic): Integer;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := 0;
  end;

  function TPhoaParsedOperand.IsOperator: Boolean;
  begin
    Result := False;
  end;

   //===================================================================================================================
   // TPhoaParsedCustomOperator
   //===================================================================================================================

  function TPhoaParsedCustomOperator.AsOperator: IPhoaParsedOperator;
  begin
    Result := Self;
  end;

  procedure TPhoaParsedCustomOperator.Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic);
  begin
    InvalidOperatorKind;
  end;

  function TPhoaParsedCustomOperator.IsCloseBracket: Boolean;
  begin
    Result := False;
  end;

  function TPhoaParsedCustomOperator.IsOpenBracket: Boolean;
  begin
    Result := False;
  end;

  function TPhoaParsedCustomOperator.IsOperator: Boolean;
  begin
    Result := True;
  end;

  function TPhoaParsedCustomOperator.IsUnaryOperator: Boolean;
  begin
    Result := False;
  end;

   //===================================================================================================================
   // TPhoaParsedBracket
   //===================================================================================================================

  constructor TPhoaParsedBracket.Create(cBracket: Char; iPos: Integer);
  begin
    inherited Create(iPos);
    case cBracket of
      '(': FBracketType := btOpen;
      ')': FBracketType := btClose;
      else PhoaParseError(iPos, SPhoaParseError_InvalidCharacter, [cBracket]);
    end;
  end;

  function TPhoaParsedBracket.GetDescription: String;
  begin
    if FBracketType=btOpen then Result := 'open' else Result := 'close';
    Result := Format('[%d] %s bracket', [Position, Result]);
  end;

  function TPhoaParsedBracket.GetPriority: Integer;
  begin
    if IsOpenBracket then Result := 1 else Result := 0;
  end;

  function TPhoaParsedBracket.IsCloseBracket: Boolean;
  begin
    Result := FBracketType=btClose;
  end;

  function TPhoaParsedBracket.IsOpenBracket: Boolean;
  begin
    Result := FBracketType=btOpen;
  end;

   //===================================================================================================================
   // TPhoaParsedLiteral
   //===================================================================================================================

  function TPhoaParsedLiteral.AsDate(Pic: IPhoaPic): Integer;
  begin
    Result := DateToPhoaDate(StrToDate(FValue));
  end;

  function TPhoaParsedLiteral.AsString(Pic: IPhoaPic): String;
  begin
    Result := FValue;
  end;

  function TPhoaParsedLiteral.AsTime(Pic: IPhoaPic): Integer;
  begin
    Result := TimeToPhoaTime(StrToTime(FValue));
  end;

  constructor TPhoaParsedLiteral.Create(const sValue: String; iPos: Integer);
  begin
    inherited Create(iPos);
    FValue := sValue;
  end;

  function TPhoaParsedLiteral.GetDatatype: TDatatype;
  begin
    Result := dtString;
  end;

  function TPhoaParsedLiteral.GetDescription: String;
  begin
    Result := Format('[%d] literal "%s"', [Position, FValue]);
  end;

   //===================================================================================================================
   // TPhoaParsedField
   //===================================================================================================================

  function TPhoaParsedField.AsDate(Pic: IPhoaPic): Integer;
  begin
    Result := 0;
    if FKind in FKSDateFields then begin
      if Pic<>nil then
        case FKind of
          fkDate: Result := Pic.Date;
        end;
    end else
      InvalidDatatype;
  end;

  function TPhoaParsedField.AsInteger(Pic: IPhoaPic): Integer;
  begin
    Result := 0;
    if FKind in FKSIntegerFields then begin
      if Pic<>nil then
        case FKind of
          fkID:              Result := Pic.ID;
          fkFileSize:        Result := Pic.FileSize;
          fkImageWidth:      Result := Pic.ImageSize.cx;
          fkImageHeight:     Result := Pic.ImageSize.cy;
          fkThumbnailWidth:  Result := Pic.ThumbnailSize.cx;
          fkThumbnailHeight: Result := Pic.ThumbnailSize.cy;
        end;
    end else
      InvalidDatatype;
  end;

  function TPhoaParsedField.AsList(Pic: IPhoaPic): IPhoaKeywordList;
  begin
    if FKind in FKSListFields then begin
      if Pic<>nil then
        case FKind of
          fkKeywords: Result := Pic.Keywords;
        end;
    end else
      InvalidDatatype;
  end;

  function TPhoaParsedField.AsString(Pic: IPhoaPic): String;
  begin
    Result := '';
    if FKind in FKSStringFields then begin
      if Pic<>nil then
        case FKind of
          fkAuthor:      Result := Pic.Author;
          fkDescription: Result := Pic.Description;
          fkFileName:    Result := Pic.FileName;
          fkFilmNumber:  Result := Pic.FilmNumber;
          fkFrameNumber: Result := Pic.FrameNumber;
          fkMedia:       Result := Pic.Media;
          fkNotes:       Result := Pic.Notes;
          fkPlace:       Result := Pic.Place;
        end;
    end else
      InvalidDatatype;
  end;

  function TPhoaParsedField.AsTime(Pic: IPhoaPic): Integer;
  begin
    Result := 0;
    if FKind in FKSTimeFields then begin
      if Pic<>nil then
        case FKind of
          fkTime: Result := Pic.Time;
        end;
    end else
      InvalidDatatype;
  end;

  constructor TPhoaParsedField.Create(const sKind: String; iPos: Integer);
  var
    s: String;
    bFind: Boolean;
    fk: TFieldKind;
  begin
    inherited Create(iPos);
    s := UpperCase(sKind);
    bFind := False;
    for fk := Low(TFieldKind) to High(TFieldKind) do
      if ASFieldKinds[fk]=s then begin
        FKind := fk;
        bFind := True;
        Break;
      end;
    if not bFind then PhoaParseError(iPos, SPhoaParseError_InvalidField, [sKind]);
  end;

  function TPhoaParsedField.GetDatatype: TDatatype;
  begin
    if FKind in FKSStringFields then
      Result := dtString
    else if FKind in FKSListFields then
      Result := dtList
    else if FKind in FKSIntegerFields then
      Result := dtInteger
    else if FKind in FKSDateFields then
      Result := dtDate
    else if FKind in FKSTimeFields then
      Result := dtTime
    else begin
      InvalidDatatype;
       // �������� �� ��������������
      Result := dtString;
    end;
  end;

  function TPhoaParsedField.GetDescription: String;
  begin
    Result := Format('[%d] field %s', [Position, ASFieldKinds[FKind]]);
  end;

   //===================================================================================================================
   // TPhoaParsedValue
   //===================================================================================================================

  function TPhoaParsedValue.AsFloat(Pic: IPhoaPic): Double;
  begin
    if not TryStrToFloat(FStringValue, Result, ParserFormatSettings) then InvalidDatatype;
  end;

  function TPhoaParsedValue.AsInteger(Pic: IPhoaPic): Integer;
  begin
    if not TryStrToInt(FStringValue, Result) then InvalidDatatype;
  end;

  constructor TPhoaParsedValue.Create(const sStringValue: String; iPos: Integer);
  begin
    inherited Create(iPos);
    FStringValue := sStringValue;
    if Pos('.', FStringValue)>0 then FCurrentDatatype := dtFloat else FCurrentDatatype := dtInteger; 
  end;

  function TPhoaParsedValue.GetDatatype: TDatatype;
  begin
    Result := FCurrentDatatype;
  end;

  function TPhoaParsedValue.GetDescription: String;
  begin
    Result := Format('[%d] value "%s"', [Position, FStringValue]);
  end;

   //===================================================================================================================
   // TPhoaParsedList
   //===================================================================================================================

  function TPhoaParsedList.AsList(Pic: IPhoaPic): IPhoaKeywordList;
  begin
    Result := ItemList as IPhoaKeywordList;
  end;

  function TPhoaParsedList.GetDatatype: TDatatype;
  begin
    Result := dtList;
  end;

  function TPhoaParsedList.GetDescription: String;
  var
    i: Integer;
    s: String;
  begin
    s := '';
    for i := 0 to ItemList.Count-1 do begin
      if s<>'' then s := s+',';
      s := s+ItemList[i].GetDescription;
    end;
    Result := Format('[%d] list of %d items: (%s)', [Position, ItemList.Count, s]);
  end;

  function TPhoaParsedList.GetItemList: IPhoaParsedItemsList;
  begin
    if FItemList=nil then FItemList := TPhoaParsedItemsList.Create;
    Result := FItemList;
  end;

   //===================================================================================================================
   // TPhoaParsedBoolean
   //===================================================================================================================

  function TPhoaParsedBoolean.AsBoolean(Pic: IPhoaPic): Boolean;
  begin
    Result := FValue;
  end;

  constructor TPhoaParsedBoolean.Create(bValue: Boolean; iPos: Integer);
  begin
    inherited Create(iPos);
    FValue := bValue;
  end;

  function TPhoaParsedBoolean.GetDatatype: TDatatype;
  begin
    Result := dtBoolean;
  end;

  function TPhoaParsedBoolean.GetDescription: String;
  begin
    Result := Format('[%d] boolean "%s"', [Position, BoolToStr(FValue)]);
  end;

   //===================================================================================================================
   // TPhoaParsedOperator
   //===================================================================================================================

  function TPhoaParsedOperator.CompareAsBoolean(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var b1, b2: Boolean;
  begin
    b1 := Op1.AsBoolean(Pic);
    b2 := Op2.AsBoolean(Pic);
    Result := CompareValues(b1, b2);
  end;

  function TPhoaParsedOperator.CompareAsDate(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var i1, i2: Integer;
  begin
    i1 := Op1.AsDate(Pic);
    i2 := Op2.AsDate(Pic);
    Result := CompareValues(i1, i2);
  end;

  function TPhoaParsedOperator.CompareAsFloat(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var d1, d2: Double;
  begin
    d1 := Op1.AsFloat(Pic);
    d2 := Op2.AsFloat(Pic);
    Result := CompareValues(d1, d2);
  end;

  function TPhoaParsedOperator.CompareAsInteger(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var i1, i2: Integer;
  begin
    i1 := Op1.AsInteger(Pic);
    i2 := Op2.AsInteger(Pic);
    Result := CompareValues(i1, i2);
  end;

  function TPhoaParsedOperator.CompareAsStrings(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var s1, s2: String;
  begin
    s1 := Op1.AsString(Pic);
    s2 := Op2.AsString(Pic);
    Result := CompareValues(s1, s2);
  end;

  function TPhoaParsedOperator.CompareAsTime(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var i1, i2: Integer;
  begin
    i1 := Op1.AsTime(Pic);
    i2 := Op2.AsTime(Pic);
    Result := CompareValues(i1, i2);
  end;

  function TPhoaParsedOperator.CompareValues(const Val1, Val2: String): Boolean;
  var s1, s2: String;
  begin
    case FKind of
      okStartsWith, okEndsWith, okContains: begin
        s1 := AnsiUpperCase(Val1);
        s2 := AnsiUpperCase(Val2);
        if FKind=okStartsWith then    Result := Copy(s1, 1, Length(s2))=s2
        else if FKind=okEndsWith then Result := Copy(s1, Length(s1)-Length(s2)+1, Length(s2))=s2
        else                          Result := Pos(s2, s1)>0;
      end;
      okEQ:    Result := AnsiCompareText(Val1, Val2)=0;
      okNotEQ: Result := AnsiCompareText(Val1, Val2)<>0;
      okLT:    Result := AnsiCompareText(Val1, Val2)<0;
      okLE:    Result := AnsiCompareText(Val1, Val2)<=0;
      okGT:    Result := AnsiCompareText(Val1, Val2)>0;
      okGE:    Result := AnsiCompareText(Val1, Val2)>=0;
      else begin
        InvalidDatatype;
         // �������� �� ��������������
        Result := False;
      end;
    end; // case
  end;

  function TPhoaParsedOperator.CompareValues(const Val1, Val2: Double): Boolean;
  begin
    case FKind of
      okEQ:    Result := Val1=Val2;
      okNotEQ: Result := Val1<>Val2;
      okLT:    Result := Val1<Val2;
      okLE:    Result := Val1<=Val2;
      okGT:    Result := Val1>Val2;
      okGE:    Result := Val1>=Val2;
      else begin
        InvalidDatatype;
         // �������� �� ��������������
        Result := False;
      end;
    end; // case
  end;

  function TPhoaParsedOperator.CompareValues(Val1, Val2: Integer): Boolean;
  begin
    case FKind of
      okEQ:    Result := Val1=Val2;
      okNotEQ: Result := Val1<>Val2;
      okLT:    Result := Val1<Val2;
      okLE:    Result := Val1<=Val2;
      okGT:    Result := Val1>Val2;
      okGE:    Result := Val1>=Val2;
      else begin
        InvalidDatatype;
         // �������� �� ��������������
        Result := False;
      end;
    end; // case
  end;

  function TPhoaParsedOperator.CompareValues(const Val1, Val2: Boolean): Boolean;
  begin
    case FKind of
      okAnd:   Result := Val1 and Val2;
      okOr:    Result := Val1 or Val2;
      okEQ:    Result := Val1=Val2;
      okNotEQ: Result := Val1<>Val2;
      okLT:    Result := Val1<Val2;
      okLE:    Result := Val1<=Val2;
      okGT:    Result := Val1>Val2;
      okGE:    Result := Val1>=Val2;
      else begin
        InvalidDatatype;
         // �������� �� ��������������
        Result := False;
      end;
    end; // case
  end;

  constructor TPhoaParsedOperator.Create(const sKind: String; iPos: Integer);
  var
    s: String;
    bFind: Boolean;
    ok: TOperatorKind;
  begin
    inherited Create(iPos);
    s := UpperCase(sKind);
    bFind := False;
    for ok := Low(TOperatorKind) to High(TOperatorKind) do
      if ASOperatorKinds[ok]=s then begin
        FKind := ok;
        bFind := True;
        Break;
      end;
    if not bFind then PhoaParseError(iPos, SPhoaParseError_InvalidOperator, [sKind]);
  end;

  procedure TPhoaParsedOperator.Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic);
  var
    Op1, Op2: IPhoaParsedOperand;
    List: IPhoaKeywordList;
    dt: TDatatype;
    bResult: Boolean;
    s: String;
  begin
    Op2 := Stack.Pop.AsOperand;
    if not IsUnaryOperator then Op1 := Stack.Pop.AsOperand;
     // �������� �� ��������������
    bResult := False;
    case FKind of
      okAnd, okOr:
        bResult := CompareAsBoolean(Op1, Op2, Pic);
      okNot:
        bResult := not Op2.AsBoolean(Pic);
      okStartsWith, okEndsWith, okContains:
        bResult := CompareAsStrings(Op1, Op2, Pic);
      okEQ, okNotEQ, okLT, okLE, okGT, okGE: begin
        if Op1=nil then dt := Op2.Datatype else dt := DatatypeCastMap[Op1.Datatype, Op2.Datatype];
        case dt of
          dtString:  bResult := CompareAsStrings(Op1, Op2, Pic);
          dtBoolean: bResult := CompareAsBoolean(Op1, Op2, Pic);
          dtInteger: bResult := CompareAsInteger(Op1, Op2, Pic);
          dtFloat:   bResult := CompareAsFloat(Op1, Op2, Pic);
          dtDate:    bResult := CompareAsDate(Op1, Op2, Pic);
          dtTime:    bResult := CompareAsTime(Op1, Op2, Pic);
          else Op2.InvalidDatatype;
        end; //case dt
      end;
      okIsEmpty: begin
        List := Op2.AsList(Pic);
        bResult := (List<>nil) and (List.Count=0);
      end;
      okIn: begin
        s := Op1.AsString(Pic);
        List := Op2.AsList(Pic);
        bResult := (List<>nil) and (List.IndexOf(s)>=0);
      end;
      else InvalidOperatorKind;
    end; // case Kind
    Stack.Add(TPhoaParsedBoolean.Create(bResult, Op2.Position) as IPhoaParsedItem);
  end;

  function TPhoaParsedOperator.GetDescription: String;
  begin
    Result := Format('[%d] operator %s', [Position, ASOperatorKinds[FKind]]);
  end;

  function TPhoaParsedOperator.GetPriority: Integer;
  begin
    case FKind of
      okNot, okIsEmpty:
        Result := 4;
      okAnd, okOr:
        Result := 2;
      else
        Result := 3;
    end;
  end;

  function TPhoaParsedOperator.IsUnaryOperator: Boolean;
  begin
    Result := FKind in OSUnaryOperators;
  end;

   //===================================================================================================================
   // TPhoaParsingPicFilter - ���������� IPhoaParsingPicFilter
   //===================================================================================================================
type
  TPhoaParsingPicFilter = class(TInterfacedObject, IPhoaParsingPicFilter)
  private
     // Prop storage
    FExpression: String;
    FHasErrors: Boolean;
    FParsed: Boolean;
    FParseErrorMsg: String;
    FParseErrorPos: Integer;
     // IPhoaParsingPicFilter
    procedure ParseExpression(bCheck: Boolean);
    procedure CheckExpression;
    procedure CheckHasNoErrors;
    function  Matches(Pic: IPhoaPic): Boolean;
    function  GetExpression: String;
    function  GetHasErrors: Boolean;
    function  GetParsed: Boolean;
    function  GetParseErrorMsg: String;
    function  GetParseErrorPos: Integer;
    procedure SetExpression(const sValue: String);
  protected
     // ������ ����������� ���������
    FItems: IPhoaParsedItemsList;
  public
    constructor Create;
  end;

  procedure TPhoaParsingPicFilter.CheckExpression;
  begin
    if not FParsed then
      ParseExpression(True)
    else begin
      CheckHasNoErrors;
       // ���� ��� �� ����� ������� - ������, ��������� �� �������� �������������� ��������
      if FItems.Count=0 then
        PhoaParseError(1, SPhoaParseError_NoExpression)
      else
        Matches(nil);
    end;
  end;

  procedure TPhoaParsingPicFilter.CheckHasNoErrors;
  begin
    if FHasErrors then PhoaParseError(FParseErrorPos, FParseErrorMsg);
  end;

  constructor TPhoaParsingPicFilter.Create;
  begin
    inherited Create;
    FItems := TPhoaParsedItemsList.Create;
  end;

  function TPhoaParsingPicFilter.GetExpression: String;
  begin
    Result := FExpression;
  end;

  function TPhoaParsingPicFilter.GetHasErrors: Boolean;
  begin
    Result := FHasErrors;
  end;

  function TPhoaParsingPicFilter.GetParsed: Boolean;
  begin
    Result := FParsed;
  end;

  function TPhoaParsingPicFilter.GetParseErrorMsg: String;
  begin
    Result := FParseErrorMsg;
  end;

  function TPhoaParsingPicFilter.GetParseErrorPos: Integer;
  begin
    Result := FParseErrorPos;
  end;

  function TPhoaParsingPicFilter.Matches(Pic: IPhoaPic): Boolean;
  var
    Results: IPhoaParsedItemsList;
    i: Integer;
    Item: IPhoaParsedItem;
  begin
     // ��������� ������ ���������, ���� ��� ��� �� ���������
    ParseExpression(False);
     // ������� ���� ����������� ����������
    Results := TPhoaParsedItemsList.Create;
     // ��������������� ���� ��� ����������� ��������
    for i := 0 to FItems.Count-1 do begin
      Item := FItems[i];
       // ��������� ���������
      if Item.IsOperator then Item.AsOperator.Execute(Results, Pic)
       // �������� ���������� � ���� �����������
      else Results.Add(Item);
    end;
     // ������ � ����� ������ ��������� ���� ������ ���������
    Result := Results.Count=1;
    if Result then
      Result := Results.Top.AsOperand.AsBoolean(Pic)
    else
      PhoaParseError(1, SPhoaParseError_InvalidExpression);
  end;

  procedure TPhoaParsingPicFilter.ParseExpression(bCheck: Boolean);
  var
    iLen, iCurrentPos, iItemPos: Integer;
    Item: IPhoaParsedItem;
    Operator: IPhoaParsedOperator;
    OpStack: IPhoaParsedItemsList;
    bAfterOperand: Boolean;

     // ���������, ��� ������� ������ ��������� ����� c; � ��������� ������ ������������ EPhoaParseError
    procedure CheckCurrentChar(c: Char);
    begin
      if FExpression[iCurrentPos]<>c then
        PhoaParseError(iCurrentPos, SPhoaParseError_InvalidCharacter, [c]);
    end;

     // ���������� ���������� ������� � ���������, ������� � ������� �������
    procedure SkipSpaceChars;
    begin
      while (iCurrentPos<=iLen) and (FExpression[iCurrentPos] in CSSpaceChars) do Inc(iCurrentPos);
    end;

     // ��������� �� FExpression � ���������� ������ ��������������, ������� � ������� �������
    function ExtractIdentifierString: String;
    var iStartPos: Integer;
    begin
      iStartPos := iCurrentPos;
      while (iCurrentPos<=iLen) and (FExpression[iCurrentPos] in CSIDChars) do Inc(iCurrentPos);
      Result := Copy(FExpression, iStartPos, iCurrentPos-iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������, ������� � ������� �������
    function ExtractLiteralString: String;
    var
      iStartPos, iTempPos: Integer;
      bOpen: Boolean;
    begin
      CheckCurrentChar('''');
       // ���������� ������ ��������
      iStartPos := iCurrentPos;
      Inc(iCurrentPos);
      iTempPos  := iCurrentPos;
       // "���������" ������� 
      bOpen  := True;
      Result := '';
       // ���������� ������, ���� �� ����� �� ����� ��� ������� �� ����� ������
      while bOpen and (iCurrentPos<=iLen) do begin
         // ���������, �� �������� �� ������� ������ ����������
        if FExpression[iCurrentPos]='''' then begin
           // ���������, ��� �� ������ ��� ������ ���������. ���� ����, �������� ������� ������� ������
          if (iCurrentPos<iLen) and (FExpression[iCurrentPos+1]='''') then
            Inc(iCurrentPos)
           // � ��������� ������ "���������" �������
          else
            bOpen := False;
           // �������� ����� ������ �� ������ �������� �� ������� �������
          Result := Result+Copy(FExpression, iTempPos, iCurrentPos-iTempPos);
           // ���������� ������ ���������� �����
          iTempPos := iCurrentPos+1;
         // ���� ���������� ����������� ������, � ������� ��� "������" - ������, ������� ������� "�� � ��� �������"
        end;
        Inc(iCurrentPos);
      end;
       // ���� ���� ����������, � ������� - ���, ������, ����������� �������� � ����� ������
      if bOpen then PhoaParseError(iStartPos, SPhoaParseError_StringLiteralNotTerminated);
    end;

     // ��������� �� FExpression � ���������� �������� � ���� ������, ������� � ������� �������
    function ExtractValueString: String;
    var
      c: Char;
      bSignValid, bHasDot, bHasDigit: Boolean;
      iStartPos: Integer;
    begin
      iStartPos  := iCurrentPos;
      bSignValid := True;
      bHasDot    := False;
      bHasDigit  := False;
       // ���������� ������, ���� �� ����� �� ����� ��� �� ����� ��������������� ������
      while iCurrentPos<=iLen do begin
        c := FExpression[iCurrentPos];
        if c='-' then begin
          if not bSignValid then Break;
        end else if c='.' then begin
          if not bHasDot then bHasDot := True else Break;
        end else if c in CSDigits then
          bHasDigit := True
        else
          Break;
         // ���� ����������� ������ � ������ �����
        bSignValid := False;
        Inc(iCurrentPos);
      end;
      if not bHasDigit then PhoaParseError(iCurrentPos, SPhoaParseError_DigitExpected);
      Result := Copy(FExpression, iStartPos, iCurrentPos-iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������, ������� � ������� �������.
     //   ���� ������� ��������� ������� �� �������, ������������ EPhoaParseError
    function ExtractItem: IPhoaParsedItem; forward;

     // ��������� �� FExpression � ���������� ��������� �������-����, ������� � ������� �������
    function ExtractField: TPhoaParsedField;
    var iStartPos: Integer;
    begin
      CheckCurrentChar('$');
      iStartPos := iCurrentPos;
      Inc(iCurrentPos);
      Result := TPhoaParsedField.Create(ExtractIdentifierString, iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������-��������, ������� � ������� �������
    function ExtractOperator: TPhoaParsedOperator;
    var iStartPos: Integer;
    begin
      iStartPos := iCurrentPos;
      Result := TPhoaParsedOperator.Create(ExtractIdentifierString, iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������-�������� ���������, ������� � ������� �������
    function ExtractComparison: TPhoaParsedOperator;
    var
      iStartPos: Integer;
      s: String;
      c: Char;
    begin
      iStartPos := iCurrentPos;
      s := '';
      while iCurrentPos<=iLen do begin
        c := FExpression[iCurrentPos];
        if not (c in CSMathCompChars) then Break;
        s := s+c;
        Inc(iCurrentPos);
      end;
      Result := TPhoaParsedOperator.Create(s, iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������-������, ������� � ������� �������
    function ExtractList: TPhoaParsedList;
    var
      iStartPos: Integer;
      c: Char;
      bCloseValid, bSeparatorValid, bItemValid: Boolean;
      Item: IPhoaParsedItem;
    begin
      CheckCurrentChar('[');
       // ������ �������������� ������
      Result := TPhoaParsedList.Create(iCurrentPos);
       // ���������� ��������� ������� � ������
      iStartPos := iCurrentPos;
      try
        Inc(iCurrentPos);
         // ������� ����� ���� ������ ������� ��� ����� ������
        bCloseValid     := True;
        bItemValid      := True;
        bSeparatorValid := False;
        while iCurrentPos<=iLen do begin
           // ����� ������ ��������� ��������� ���������� ���������� �������
          SkipSpaceChars;
           // ��������� ������� ������, �� ����� ������� �������
          c := FExpression[iCurrentPos];
          if c=']' then begin
             // ���� ����� ������ � ������ ������ �����������, �������� ������� �������, ��������� ������ � �������
            if bCloseValid then begin
              Inc(iCurrentPos);
              bCloseValid := False;
              Break;
            end else
              PhoaParseError(iCurrentPos, SPhoaParseError_ListItemExpected);
          end else if c=',' then begin
             // ���� ����������� ������ � ������ ������ �����������, �������� ������� �������
            if bSeparatorValid then begin
              Inc(iCurrentPos);
               // ����� ����������� ����������� ������ ��������� ������� ������
              bCloseValid     := False;
              bItemValid      := True;
              bSeparatorValid := False;
            end else
              PhoaParseError(iCurrentPos, SPhoaParseError_ListItemExpected);
          end else begin
             // ���� ������� ������ � ������ ������ �����������, ��������� ��� � ��������� � ������
            if bItemValid then begin
              Item := ExtractItem;
              if Item<>nil then Result.ItemList.Add(Item);
               // ����� �������� ������ ����������� ������ ����������� ��� ����� ������
              bCloseValid     := True;
              bItemValid      := False;
              bSeparatorValid := True;
            end else
              PhoaParseError(iCurrentPos, SPhoaParseError_SomethingExpected, [', ��� ]']);
          end;
        end;
      except
         // ��� ������������� ������ ���������� ������
        on E: EPhoaParseError do begin
          FreeAndNil(Result);
          raise;
        end;
      end;
       // ���� ���� ����������, � ��������� - ���, ������, ����������� ������ ']' � ����� ������
      if bCloseValid then PhoaParseError(iStartPos, SPhoaParseError_ListNotTerminated);
    end;

    function ExtractItem: IPhoaParsedItem;
    var
      iStartPos: Integer;
      c: Char;
      s: String;
    begin
      iStartPos := iCurrentPos;
      c := FExpression[iCurrentPos];
      case c of
        '''': begin
          s := ExtractLiteralString;
          Result := TPhoaParsedLiteral.Create(s, iStartPos);
        end;
        '[':
          Result := ExtractList;
        '$':
          Result := ExtractField;
        '(', ')': begin
          Inc(iCurrentPos);
          Result := TPhoaParsedBracket.Create(c, iStartPos);
        end;
        else begin
          if c in CSMathCompChars then
            Result := ExtractComparison
          else if c in CSIDStartChars then
            Result := ExtractOperator
          else if c in CSValueChars then begin
            s := ExtractValueString;
            Result := TPhoaParsedValue.Create(s, iStartPos);
          end else begin
            PhoaParseError(iCurrentPos, SPhoaParseError_InvalidCharacter, [c]);
            Result := nil;
          end;
        end;
      end; // case
    end;

     // ��������� �� ����� ���������� ��� ���������, ����� ������, � ����������� >=iPopPriority � �������� � ������
    procedure PopOpStack(iPopPriority: Integer; bPopSamePriority: Boolean);
    var
      Op: IPhoaParsedOperator;
      iOpPriority: Integer;
    begin
      while OpStack.Count>0 do begin
        Op := OpStack.Top.AsOperator;
        if Op.IsOpenBracket then Exit;
        iOpPriority := Op.GetPriority;
        if (iOpPriority<iPopPriority) or (not bPopSamePriority and (iOpPriority=iPopPriority)) then Exit;
        FItems.Add(OpStack.Pop);
      end;
    end;

  begin
    try
       // ���� ��������� ��� ��������� - ������ ��������� �� ������� ������
      if FParsed then begin
        if bCheck then CheckHasNoErrors;
        Exit;
      end;
       // ������� ������
      FItems.Clear;
       // ������ ��������� ���� ����������
      OpStack := TPhoaParsedItemsList.Create;
       // ��������� ������ ������, ���� �� ����� �� �����
      iLen := Length(FExpression);
      iCurrentPos := 1;
      bAfterOperand := False;
      while iCurrentPos<=iLen do begin
         // ���������� ���������� ������� � ������� ������ ���������� ��������
        SkipSpaceChars;
        if iCurrentPos>iLen then Break;
        iItemPos := iCurrentPos;
         // ���� ����� - ��������� � ������ �������
        Item := ExtractItem;
        if Item<>nil then
           // ��������� ������ ���������� � ������ ����������
          if Item.IsOperator then begin
            Operator := Item.AsOperator;
             // ����������� ������ �� ������ ���� ����� ��������
            if Operator.IsOpenBracket then begin
              if bAfterOperand then Operator.OperatorExpected;
            end else begin
               // ������� �������� �� ������ ���� ����� ��������
              if Operator.IsUnaryOperator then begin
                if bAfterOperand then Operator.InvalidOperatorKind;
               // �������� �������� ����� ���� ������ ����� ��������
              end else begin
                if not bAfterOperand then Operator.OperandExpected;
              end;
               // �������� "�����������" �� ����� ��� ��������� � ����������� >= ������
              PopOpStack(Operator.GetPriority, not Operator.IsUnaryOperator);
            end;
             // ���� ��� ����������� ������, ���� �� ������� ����� ���������� ����������� ������
            if Operator.IsCloseBracket then begin
              if (OpStack.Count=0) or not OpStack.Top.AsOperator.IsOpenBracket then
                PhoaParseError(iItemPos, SPhoaParseError_UnbalancedBrackets)
              else
                OpStack.Pop;
              bAfterOperand := True;
             // � ��������� ������ �������� ����� �������� � ����
            end else begin
              OpStack.Add(Item);
              bAfterOperand := False;
            end;
           // �������� �������� � �������������� ������, �������������� ��������, ��� ��� �� ���� ������
          end else begin
            if bAfterOperand then Item.OperatorExpected;
            FItems.Add(Item);
            bAfterOperand := True;
          end;
      end;
       // ��������� �� ������ ������������� ����������
      if not bAfterOperand then PhoaParseError(iCurrentPos, SPhoaParseError_OperandExpected);
       // ��������� �� ����� ��� ���������� ���������, ����� ����������� ������
      PopOpStack(1, True);
      if OpStack.Count>0 then PhoaParseError(iCurrentPos, SPhoaParseError_UnbalancedBrackets);
       // ������
      FParsed := True;
      FHasErrors     := False;
      FParseErrorPos := 0;
      FParseErrorMsg := '';
       // ���������, ����� �� ��������� ���������
      if bCheck then CheckExpression;
    except
      on E: EPhoaParseError do begin
        FHasErrors := True;
        FParseErrorPos := E.ErrorPos;
        FParseErrorMsg := E.Message;
        raise;
      end;
    end;
  end;

  procedure TPhoaParsingPicFilter.SetExpression(const sValue: String);
  begin
    if FExpression<>sValue then begin
      FExpression := sValue;
      FParsed := False;
    end;
  end;

   //===================================================================================================================

  function NewPhoaParsingPicFilter: IPhoaParsingPicFilter;
  begin
    Result := TPhoaParsingPicFilter.Create;
  end;

initialization
   // �������������� ParserFormatSettings
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT, ParserFormatSettings);
  ParserFormatSettings.DecimalSeparator := '.';
end.

