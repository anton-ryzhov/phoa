//**********************************************************************************************************************
//  $Id: phParsingPicFilter.pas,v 1.14 2007-06-30 10:36:20 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Written by Andrew Dudko
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phParsingPicFilter;

interface

uses
  Windows, Classes, SysUtils, TntSysUtils, phIntf;

type
  EPhoaParseError = class(EPhoaWideException)
  private
     // Prop storage
    FErrorPos: Integer;
  public
    constructor Create(iPos: Integer; const wsMessage: WideString);
    constructor CreateFmt(iPos: Integer; const wsMessage: WideString; const Params: Array of const);
     // Props
     // -- ������� ������ � ������ ������������ ���������
    property ErrorPos: Integer read FErrorPos;
  end;

   // ������ - ��������� ������ � ���������� ���������
  IPhoaParsingPicFilter = interface(IInterface)
    ['{8C0A273B-FF72-433D-92C9-99633D69CA49}']
     // ��������� ������ ���������
    procedure ParseExpression(bCheck, bRaiseOnError: Boolean);
     // ��������� �������� ������������ ��������� �� ������������
    procedure CheckExpression;
     // ���������, �� ���� �� ������ ��� ������� ���������, � ���� ����, ���������� Exception
    procedure CheckHasNoErrors;
     // ���������� True, ���� ����������� ������������� ��������� �������
    function  Matches(Pic: IPhoaPic): Boolean;
     // Prop handlers
    function  GetExpression: WideString;
    function  GetHasErrors: Boolean;
    function  GetParsed: Boolean;
    function  GetParseErrorMsg: WideString;
    function  GetParseErrorPos: Integer;
    function  GetParseErrorLocation: TPoint;
    procedure SetExpression(const wsValue: WideString);
     // Props
     // -- ������� ���������
    property Expression: WideString read GetExpression write SetExpression;
     // -- �������� �� ����������� ��������� ������
    property HasErrors: Boolean read GetHasErrors;
     // -- ��������� �� ������� ���������
    property Parsed: Boolean read GetParsed;
     // -- �������� ������� ������ � ���������
    property ParseErrorPos: Integer read GetParseErrorPos;
     // -- ������� ������ � ���������
    property ParseErrorLocation: TPoint read GetParseErrorLocation;
     // -- ��������� �� ������ ��� ������� ���������
    property ParseErrorMsg: WideString read GetParseErrorMsg;
  end;

   // ��� ���������
  TPicFilterOperatorKind = (
    okAnd, okOr, okNot, okIn, okStartsWith, okEndsWith, okContains, okIsEmpty, okEQ, okNotEQ, okLT, okLE, okGT, okGE);

const
   // ������ ����������
  awsPicFilterOperators: Array [TPicFilterOperatorKind] of WideString = (
    'and', 'or', 'not', 'in', 'startsWith', 'endsWith', 'contains', 'isEmpty', '=', '<>', '<', '<=', '>', '>=');

   // ������ ����� ��������� IPhoaParsingPicFilter
  function  NewPhoaParsingPicFilter: IPhoaParsingPicFilter;

  procedure PhoaParseError(iPos: Integer; const wsMsg: WideString); overload;
  procedure PhoaParseError(iPos: Integer; const wsMsg: WideString; const Params: Array of const); overload;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses phPhoa, Variants, phUtils, ConsVars;

type
   // ��� ������
  TBracketType = (btOpen, btClose);

const
  CSSpaceChars    = [WideChar(#9), WideChar(#10), WideChar(#12), WideChar(#13), WideChar(' ')];
  CSBrackets      = [WideChar('('), WideChar(')')];
  CSDigits        = [WideChar('0')..WideChar('9')];
  CSEngChars      = [WideChar('a')..WideChar('z'), WideChar('A')..WideChar('Z')];
  CSMathCompChars = [WideChar('<'), WideChar('>'), WideChar('=')];
  CSIDStartChars  = CSEngChars+[WideChar('_')];
  CSIDChars       = CSIDStartChars+CSDigits;
  CSValueChars    = CSDigits+[WideChar('.'), WideChar('-')];

  OSUnaryOperators = [okNot, okIsEmpty];
  
   // ������ ��� �����������, � �������� ������ ���� ������ ������������ ��������
   // ppdtString, ppdtInteger, ppdtFloat, ppdtDate, ppdtTime, ppdtBoolean, ppdtList, ppdtSize, ppdtPixelFormat, ppdtRotation, ppdtFlips
  DatatypeCastMap: Array [TPicPropDatatype, TPicPropDatatype] of TPicPropDatatype = (
    (ppdtString,      ppdtInteger,     ppdtFloat,       ppdtDate,        ppdtTime,        ppdtString,      ppdtString,      ppdtString,      ppdtString,      ppdtString,      ppdtString),
    (ppdtInteger,     ppdtInteger,     ppdtFloat,       ppdtInteger,     ppdtInteger,     ppdtInteger,     ppdtInteger,     ppdtInteger,     ppdtInteger,     ppdtInteger,     ppdtInteger),
    (ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat,       ppdtFloat),
    (ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate,        ppdtDate),
    (ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime,        ppdtTime),
    (ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean,     ppdtBoolean),
    (ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList,        ppdtList),
    (ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize,        ppdtSize),
    (ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat, ppdtPixelFormat),
    (ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation,    ppdtRotation),
    (ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips,       ppdtFlips));

var
   // ����������� ��� ������� ��������� �������, ��� DecimalSeparator='.'
  ParserFormatSettings: TFormatSettings;

resourcestring
  SPhoaParseError_NoExpression                = 'Missing expression';
  SPhoaParseError_InvalidExpression           = 'Invalid expression';
  SPhoaParseError_InvalidCharacter            = 'Invalid character: "%s"';
  SPhoaParseError_InvalidOperator             = 'Invalid operator: "%s"';
  SPhoaParseError_InvalidOperatorKind         = 'Invalid operator kind';
  SPhoaParseError_InvalidProperty             = 'Invalid picture property: "%s"';
  SPhoaParseError_StringLiteralNotTerminated  = 'Unterminated string literal';
  SPhoaParseError_ListNotTerminated           = 'Unterminated list';
  SPhoaParseError_ListItemExpected            = 'List item expected';
  SPhoaParseError_SomethingExpected           = 'Expected: %s';
  SPhoaParseError_DigitExpected               = 'Digit expected';
  SPhoaParseError_OperatorExpected            = 'Operator expected';
  SPhoaParseError_OperandExpected             = 'Operand expected';
  SPhoaParseError_UnbalancedBrackets          = 'Unbalanced brackets';
  SPhoaParseError_StackIsEmpty                = 'Element stack is empty';
  SPhoaParseError_InvalidDatatype             = 'Invalid datatype';
  SPhoaParseError_CommentBlockNotTerminated   = 'Unterminated comment block';

  procedure PhoaParseError(iPos: Integer; const wsMsg: WideString);
  begin
    raise EPhoaParseError.Create(iPos, wsMsg);
  end;

  procedure PhoaParseError(iPos: Integer; const wsMsg: WideString; const Params: Array of const);
  begin
    raise EPhoaParseError.CreateFmt(iPos, wsMsg, Params);
  end;

   //===================================================================================================================
   // IPhoaParsedItem
   //===================================================================================================================
type
  IPhoaParsedItem      = interface;
  IPhoaParsedOperand   = interface;
  IPhoaParsedOperator  = interface;
  IPhoaParsedItemsList = interface;

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
    function  GetDescription: WideString;
     // Props
     // -- �������� ������� � ������
    property Position: Integer read GetPosition;
     // -- �������� �������� (��� �������)
    property Description: WideString read GetDescription;
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
     // ���������� ��������-����� ��������
    function  AsTime(Pic: IPhoaPic): Integer;
     // ���������� ��������� �������� ��������
    function  AsWideString(Pic: IPhoaPic): WideString;
     // Prop handlers
    function  GetDatatype: TPicPropDatatype;
     // Props
     // -- �������� ��� ������
    property Datatype: TPicPropDatatype read GetDatatype;
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
    function  Pop: IPhoaParsedItem;
    function  Top: IPhoaParsedItem;
    procedure SetItems(Index: Integer; Value: IPhoaParsedItem);
     // IPhoaKeywordList
    function  IPhoaKeywordList.IndexOf       = KWL_IndexOf;
    function  IPhoaKeywordList.GetCommaText  = KWL_GetCommaText;
    function  IPhoaKeywordList.GetCount      = KWL_GetCount;
    function  IPhoaKeywordList.GetItems      = KWL_GetItems;
    function  KWL_IndexOf(const wsKeyword: WideString): Integer; stdcall;
    function  KWL_GetCommaText: WideString; stdcall;
    function  KWL_GetCount: Integer; stdcall;
    function  KWL_GetItems(Index: Integer): WideString; stdcall;
     // Props
    property  Items[Index: Integer]: IPhoaParsedItem read GetItems write SetItems; default;
  end;

  TPhoaParsedItem = class(TInterfacedObject, IPhoaParsedItem)
  protected
     // Prop storage
    FPosition: Integer;
     // IPhoaParsedItem
    function  AsOperand: IPhoaParsedOperand; virtual;
    function  AsOperator: IPhoaParsedOperator; virtual;
    function  GetDescription: WideString; virtual; abstract;
    function  GetPosition: Integer;
    function  IsOperator: Boolean; virtual; abstract;
    procedure InvalidDatatype;
    procedure InvalidOperatorKind;
    procedure OperandExpected;
    procedure OperatorExpected;
     // Props
    property Description: WideString read GetDescription;
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
    function  AsDate(Pic: IPhoaPic): Integer; virtual;
    function  AsFloat(Pic: IPhoaPic): Double; virtual;
    function  AsInteger(Pic: IPhoaPic): Integer; virtual;
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; virtual;
    function  AsTime(Pic: IPhoaPic): Integer; virtual;
    function  AsWideString(Pic: IPhoaPic): WideString; virtual;
    function  GetDatatype: TPicPropDatatype; virtual; abstract;
     // Props
    property Datatype: TPicPropDatatype read GetDatatype;
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
    function  GetDescription: WideString; override;
    function  GetPriority: Integer; override;
    function  IsOpenBracket: Boolean; override;
    function  IsCloseBracket: Boolean; override;
  public
    constructor Create(wcBracket: WideChar; iPos: Integer);
  end;

  TPhoaParsedOperator = class(TPhoaParsedCustomOperator)
  protected
     // ��� ���������
    FKind: TPicFilterOperatorKind;
    function  IsUnaryOperator: Boolean; override;
    function  GetDescription: WideString; override;
    function  GetPriority: Integer; override;
    procedure Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic); override;
     // ���������� ��� �������� � ������ ���� ���������
    function  CompareValues(Val1, Val2: Integer): Boolean; overload;
    function  CompareValues(const Val1, Val2: Double): Boolean; overload;
    function  CompareValues(const Val1, Val2: WideString): Boolean; overload;
    function  CompareValues(Val1, Val2: Boolean): Boolean; overload;
     // ��������� �������� ��� ����� WideString ����������
    function  CompareAsWideStrings(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
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
    constructor Create(const wsKind: WideString; iPos: Integer);
  end;

  TPhoaParsedLiteral = class(TPhoaParsedOperand)
  protected
     // �������� ��������
    FValue: WideString;
    function  AsDate(Pic: IPhoaPic): Integer; override;
    function  AsTime(Pic: IPhoaPic): Integer; override;
    function  AsWideString(Pic: IPhoaPic): WideString; override;
    function  GetDatatype: TPicPropDatatype; override;
    function  GetDescription: WideString; override;
  public
    constructor Create(const wsValue: WideString; iPos: Integer);
  end;

  TPhoaParsedPicProp = class(TPhoaParsedOperand)
  protected
     // �������� �����������
    FProp: TPicProperty;
    function  AsDate(Pic: IPhoaPic): Integer; override;
    function  AsInteger(Pic: IPhoaPic): Integer; override;
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; override;
    function  AsTime(Pic: IPhoaPic): Integer; override;
    function  AsWideString(Pic: IPhoaPic): WideString; override;
    function  GetDatatype: TPicPropDatatype; override;
    function  GetDescription: WideString; override;
  public
    constructor Create(const wsPropName: WideString; iPos: Integer);
  end;

  TPhoaParsedValue = class(TPhoaParsedOperand)
  protected
     // ��������� ������������� ��������
    FWideStringValue: WideString;
     // ������� ��� ������
    FCurrentDatatype: TPicPropDatatype;
    function  AsInteger(Pic: IPhoaPic): Integer; override;
    function  AsFloat(Pic: IPhoaPic): Double; override;
    function  GetDatatype: TPicPropDatatype; override;
    function  GetDescription: WideString; override;
  public
    constructor Create(const wsWideStringValue: WideString; iPos: Integer);
  end;

  TPhoaParsedList = class(TPhoaParsedOperand)
  private
     // Prop storage
    FItemList: IPhoaParsedItemsList;
     // Prop handlers
    function  GetItemList: IPhoaParsedItemsList;
  protected
    function  AsList(Pic: IPhoaPic): IPhoaKeywordList; override;
    function  GetDatatype: TPicPropDatatype; override;
    function  GetDescription: WideString; override;
     // Props
     // -- ������ ���������
    property ItemList: IPhoaParsedItemsList read GetItemList;
  end;

  TPhoaParsedBoolean = class(TPhoaParsedOperand)
  protected
     // ��������
    FValue: Boolean;
    function  AsBoolean(Pic: IPhoaPic): Boolean; override;
    function  GetDatatype: TPicPropDatatype; override;
    function  GetDescription: WideString; override;
  public
    constructor Create(bValue: Boolean; iPos: Integer);
  end;

   //===================================================================================================================
   // EPhoaParseError
   //===================================================================================================================

  constructor EPhoaParseError.Create(iPos: Integer; const wsMessage: WideString);
  begin
    inherited Create(wsMessage);
    FErrorPos := iPos;
  end;

  constructor EPhoaParseError.CreateFmt(iPos: Integer; const wsMessage: WideString; const Params: array of const);
  begin
    inherited CreateFmt(wsMessage, Params);
    FErrorPos := iPos;
  end;

   //===================================================================================================================
   // TPhoaParsedItemsList
   //===================================================================================================================

  function TPhoaParsedItemsList.GetItems(Index: Integer): IPhoaParsedItem;
  begin
    Result := IPhoaParsedItem(Get(Index));
  end;

  function TPhoaParsedItemsList.KWL_GetCommaText: WideString;
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

  function TPhoaParsedItemsList.KWL_GetItems(Index: Integer): WideString;
  begin
    Result := Items[Index].AsOperand.AsWideString(nil);
  end;

  function TPhoaParsedItemsList.KWL_IndexOf(const wsKeyword: WideString): Integer;
  begin
    for Result := 0 to Count-1 do
      if WideCompareText(Items[Result].AsOperand.AsWideString(nil), wsKeyword)=0 then Exit;
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

  function TPhoaParsedOperand.AsTime(Pic: IPhoaPic): Integer;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
     // �������� �� ��������������
    Result := 0;
  end;

  function TPhoaParsedOperand.AsWideString(Pic: IPhoaPic): WideString;
  begin
     // ������� ����� �� ����� ���������� �������������� ��������
    InvalidDatatype;
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

  constructor TPhoaParsedBracket.Create(wcBracket: WideChar; iPos: Integer);
  begin
    inherited Create(iPos);
    case wcBracket of
      '(': FBracketType := btOpen;
      ')': FBracketType := btClose;
      else PhoaParseError(iPos, SPhoaParseError_InvalidCharacter, [wcBracket]);
    end;
  end;

  function TPhoaParsedBracket.GetDescription: WideString;
  begin
    if FBracketType=btOpen then Result := 'open' else Result := 'close';
    Result := WideFormat('[%d] %s bracket', [Position, Result]);
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
    Result := DateToPhoaDate(StrToDate(FValue, AppFormatSettings));
  end;

  function TPhoaParsedLiteral.AsTime(Pic: IPhoaPic): Integer;
  begin
    Result := TimeToPhoaTime(StrToTime(FValue, AppFormatSettings));
  end;

  function TPhoaParsedLiteral.AsWideString(Pic: IPhoaPic): WideString;
  begin
    Result := FValue;
  end;

  constructor TPhoaParsedLiteral.Create(const wsValue: WideString; iPos: Integer);
  begin
    inherited Create(iPos);
    FValue := wsValue;
  end;

  function TPhoaParsedLiteral.GetDatatype: TPicPropDatatype;
  begin
    Result := ppdtString;
  end;

  function TPhoaParsedLiteral.GetDescription: WideString;
  begin
    Result := WideFormat('[%d] literal "%s"', [Position, FValue]);
  end;

   //===================================================================================================================
   // TPhoaParsedPicProp
   //===================================================================================================================

  function TPhoaParsedPicProp.AsDate(Pic: IPhoaPic): Integer;
  var v: Variant;
  begin
    if Datatype<>ppdtDate then InvalidDatatype;
    Result := 0;
    if Pic<>nil then begin
      v := Pic.PropValues[FProp];
      if not VarIsNull(v) then Result := v;
    end;
  end;

  function TPhoaParsedPicProp.AsInteger(Pic: IPhoaPic): Integer;
  begin
    if Datatype<>ppdtInteger then InvalidDatatype;
    if Pic=nil then Result := 0 else Result := Pic.PropValues[FProp];
  end;

  function TPhoaParsedPicProp.AsList(Pic: IPhoaPic): IPhoaKeywordList;
  begin
    if Datatype<>ppdtList then InvalidDatatype;
    if (Pic=nil) or not VarSupports(Pic.PropValues[FProp], IPhoaKeywordList, Result) then Result := nil;
  end;

  function TPhoaParsedPicProp.AsWideString(Pic: IPhoaPic): WideString;
  begin
    if Datatype<>ppdtString then InvalidDatatype;
    if Pic=nil then Result := '' else Result := Pic.PropStrValues[FProp];
  end;

  function TPhoaParsedPicProp.AsTime(Pic: IPhoaPic): Integer;
  begin
    if Datatype<>ppdtTime then InvalidDatatype;
    if Pic=nil then Result := 0 else Result := Pic.PropValues[FProp];
  end;

  constructor TPhoaParsedPicProp.Create(const wsPropName: WideString; iPos: Integer);
  begin
    inherited Create(iPos);
    FProp := StrToPicProp(wsPropName, False);
    if not (FProp in [Low(FProp)..High(FProp)]) then PhoaParseError(iPos, SPhoaParseError_InvalidProperty, [wsPropName]);
  end;

  function TPhoaParsedPicProp.GetDatatype: TPicPropDatatype;
  begin
    Result := aPicPropDatatype[FProp];
  end;

  function TPhoaParsedPicProp.GetDescription: WideString;
  begin
    Result := WideFormat('[%d] property %s', [Position, PicPropToStr(FProp, True)]);
  end;

   //===================================================================================================================
   // TPhoaParsedValue
   //===================================================================================================================

  function TPhoaParsedValue.AsFloat(Pic: IPhoaPic): Double;
  begin
    if not TryStrToFloat(FWideStringValue, Result, ParserFormatSettings) then InvalidDatatype;
  end;

  function TPhoaParsedValue.AsInteger(Pic: IPhoaPic): Integer;
  begin
    if not TryStrToInt(FWideStringValue, Result) then InvalidDatatype;
  end;

  constructor TPhoaParsedValue.Create(const wsWideStringValue: WideString; iPos: Integer);
  begin
    inherited Create(iPos);
    FWideStringValue := wsWideStringValue;
    if Pos('.', FWideStringValue)>0 then FCurrentDatatype := ppdtFloat else FCurrentDatatype := ppdtInteger; 
  end;

  function TPhoaParsedValue.GetDatatype: TPicPropDatatype;
  begin
    Result := FCurrentDatatype;
  end;

  function TPhoaParsedValue.GetDescription: WideString;
  begin
    Result := WideFormat('[%d] value "%s"', [Position, FWideStringValue]);
  end;

   //===================================================================================================================
   // TPhoaParsedList
   //===================================================================================================================

  function TPhoaParsedList.AsList(Pic: IPhoaPic): IPhoaKeywordList;
  begin
    Result := ItemList as IPhoaKeywordList;
  end;

  function TPhoaParsedList.GetDatatype: TPicPropDatatype;
  begin
    Result := ppdtList;
  end;

  function TPhoaParsedList.GetDescription: WideString;
  var
    i: Integer;
    ws: WideString;
  begin
    ws := '';
    for i := 0 to ItemList.Count-1 do begin
      if ws<>'' then ws := ws+',';
      ws := ws+ItemList[i].GetDescription;
    end;
    Result := WideFormat('[%d] list of %d items: (%s)', [Position, ItemList.Count, ws]);
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

  function TPhoaParsedBoolean.GetDatatype: TPicPropDatatype;
  begin
    Result := ppdtBoolean;
  end;

  function TPhoaParsedBoolean.GetDescription: WideString;
  begin
    Result := WideFormat('[%d] boolean "%s"', [Position, BoolToStr(FValue)]);
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

  function TPhoaParsedOperator.CompareAsWideStrings(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var ws1, ws2: WideString;
  begin
    ws1 := Op1.AsWideString(Pic);
    ws2 := Op2.AsWideString(Pic);
    Result := CompareValues(ws1, ws2);
  end;

  function TPhoaParsedOperator.CompareAsTime(Op1, Op2: IPhoaParsedOperand; Pic: IPhoaPic): Boolean;
  var i1, i2: Integer;
  begin
    i1 := Op1.AsTime(Pic);
    i2 := Op2.AsTime(Pic);
    Result := CompareValues(i1, i2);
  end;

  function TPhoaParsedOperator.CompareValues(const Val1, Val2: WideString): Boolean;
  var ws1, ws2: WideString;
  begin
    case FKind of
      okStartsWith, okEndsWith, okContains: begin
        ws1 := WideUpperCase(Val1);
        ws2 := WideUpperCase(Val2);
        if FKind=okStartsWith then    Result := Copy(ws1, 1, Length(ws2))=ws2
        else if FKind=okEndsWith then Result := Copy(ws1, Length(ws1)-Length(ws2)+1, Length(ws2))=ws2
        else                          Result := Pos(ws2, ws1)>0;
      end;
      okEQ:    Result := WideSameText(Val1, Val2);
      okNotEQ: Result := not WideSameText(Val1, Val2);
      okLT:    Result := WideCompareText(Val1, Val2)<0;
      okLE:    Result := WideCompareText(Val1, Val2)<=0;
      okGT:    Result := WideCompareText(Val1, Val2)>0;
      okGE:    Result := WideCompareText(Val1, Val2)>=0;
      else begin
        InvalidDatatype;
         // �������� �� ��������������
        Result := False;
      end;
    end;
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
    end;
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
    end;
  end;

  function TPhoaParsedOperator.CompareValues(Val1, Val2: Boolean): Boolean;
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
    end; 
  end;

  constructor TPhoaParsedOperator.Create(const wsKind: WideString; iPos: Integer);
  var
    ws: WideString;
    bFind: Boolean;
    ok: TPicFilterOperatorKind;
  begin
    inherited Create(iPos);
    ws := WideUpperCase(wsKind);
    bFind := False;
    for ok := Low(ok) to High(ok) do
      if WideSameText(awsPicFilterOperators[ok], ws) then begin
        FKind := ok;
        bFind := True;
        Break;
      end;
    if not bFind then PhoaParseError(iPos, SPhoaParseError_InvalidOperator, [wsKind]);
  end;

  procedure TPhoaParsedOperator.Execute(Stack: IPhoaParsedItemsList; Pic: IPhoaPic);
  var
    Op1, Op2: IPhoaParsedOperand;
    List: IPhoaKeywordList;
    dt: TPicPropDatatype;
    bResult: Boolean;
    ws: WideString;
  begin
    Op2 := Stack.Pop.AsOperand;
    if not IsUnaryOperator then Op1 := Stack.Pop.AsOperand;
     // �������� �� ��������������
    bResult := False;
    case FKind of
      okAnd,
        okOr:       bResult := CompareAsBoolean(Op1, Op2, Pic);
      okNot:        bResult := not Op2.AsBoolean(Pic);
      okStartsWith,
        okEndsWith,
        okContains: bResult := CompareAsWideStrings(Op1, Op2, Pic);
      okEQ, okNotEQ, okLT, okLE, okGT, okGE: begin
        if Op1=nil then dt := Op2.Datatype else dt := DatatypeCastMap[Op1.Datatype, Op2.Datatype];
        case dt of
          ppdtString:  bResult := CompareAsWideStrings(Op1, Op2, Pic);
          ppdtBoolean: bResult := CompareAsBoolean(Op1, Op2, Pic);
          ppdtInteger: bResult := CompareAsInteger(Op1, Op2, Pic);
          ppdtFloat:   bResult := CompareAsFloat(Op1, Op2, Pic);
          ppdtDate:    bResult := CompareAsDate(Op1, Op2, Pic);
          ppdtTime:    bResult := CompareAsTime(Op1, Op2, Pic);
          else Op2.InvalidDatatype;
        end;
      end;
      okIsEmpty: begin
        List := Op2.AsList(Pic);
        bResult := (List<>nil) and (List.Count=0);
      end;
      okIn: begin
        ws := Op1.AsWideString(Pic);
        List := Op2.AsList(Pic);
        bResult := (List<>nil) and (List.IndexOf(ws)>=0);
      end;
      else InvalidOperatorKind;
    end;
    Stack.Add(TPhoaParsedBoolean.Create(bResult, Op2.Position) as IPhoaParsedItem);
  end;

  function TPhoaParsedOperator.GetDescription: WideString;
  begin
    Result := WideFormat('[%d] operator %s', [Position, awsPicFilterOperators[FKind]]);
  end;

  function TPhoaParsedOperator.GetPriority: Integer;
  begin
    case FKind of
      okNot, okIsEmpty: Result := 4;
      okAnd, okOr:      Result := 2;
      else              Result := 3;
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
    FExpression: WideString;
    FHasErrors: Boolean;
    FParsed: Boolean;
    FParseErrorMsg: WideString;
    FParseErrorPos: Integer;
     // IPhoaParsingPicFilter
    function  GetExpression: WideString;
    function  GetHasErrors: Boolean;
    function  GetParsed: Boolean;
    function  GetParseErrorLocation: TPoint;
    function  GetParseErrorMsg: WideString;
    function  GetParseErrorPos: Integer;
    function  Matches(Pic: IPhoaPic): Boolean;
    procedure CheckExpression;
    procedure CheckHasNoErrors;
    procedure ParseExpression(bCheck, bRaiseOnError: Boolean);
    procedure SetExpression(const wsValue: WideString);
  protected
     // ������ ����������� ���������
    FItems: IPhoaParsedItemsList;
  public
    constructor Create;
  end;

  procedure TPhoaParsingPicFilter.CheckExpression;
  begin
    if not FParsed then
      ParseExpression(True, True)
    else begin
      CheckHasNoErrors;
       // ���� ��� �� ����� ������� - ������, ��������� �� �������� �������������� ��������
      if FItems.Count=0 then PhoaParseError(1, SPhoaParseError_NoExpression) else Matches(nil);
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

  function TPhoaParsingPicFilter.GetExpression: WideString;
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

  function TPhoaParsingPicFilter.GetParseErrorLocation: TPoint;
  var
    i, iLen: Integer;
    wc, wcLast: WideChar;
  begin
    Result.x := 1;
    Result.y := 1;
    i := 1;
    iLen := Length(FExpression);
    wcLast := #0;
    while (i<FParseErrorPos) and (i<=iLen) do begin
      wc := FExpression[i];
      case wc of
         // ���� ��������� ������� ������
        #10, #13: begin
          if ((wcLast<>#10) and (wcLast<>#13)) or (wc=wcLast) then begin
            Result.x := 1;
            Inc(Result.y);
          end;
        end;
         // ����� ����������� �������������� ����������
        else Inc(Result.x);
      end;
      wcLast := wc;
      Inc(i);
    end;
  end;

  function TPhoaParsingPicFilter.GetParseErrorMsg: WideString;
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
    ParseExpression(False, True);
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

  procedure TPhoaParsingPicFilter.ParseExpression(bCheck, bRaiseOnError: Boolean);
  var
    iLen, iCurrentPos, iItemPos: Integer;
    Item: IPhoaParsedItem;
    Operator: IPhoaParsedOperator;
    OpStack: IPhoaParsedItemsList;
    bAfterOperand: Boolean;

     // ���������, ��� ������� ������ ��������� ����� wc; � ��������� ������ ������������ EPhoaParseError
    procedure CheckCurrentChar(wc: WideChar);
    begin
      if FExpression[iCurrentPos]<>wc then PhoaParseError(iCurrentPos, SPhoaParseError_InvalidCharacter, [wc]);
    end;

     // ���������� ���������� ������� � ���������, ������� � ������� �������
    procedure SkipSpaceChars;
    begin
      while (iCurrentPos<=iLen) and (FExpression[iCurrentPos] in CSSpaceChars) do Inc(iCurrentPos);
    end;

     // ���������� ����������� �� ����� ������
    procedure SkipSingleLineComment;
    begin
       // ��������� ��� ������� "/"
      CheckCurrentChar('/');
      Inc(iCurrentPos);
      CheckCurrentChar('/');
      Inc(iCurrentPos);
       // ���������� ��� ������� �� ����� ������
      while (iCurrentPos<=iLen) and not (FExpression[iCurrentPos] in [WideChar(#10), WideChar(#13)]) do Inc(iCurrentPos);
    end;

     // ���������� ������������� �����������
    procedure SkipMultiLineComment;
    var iStartPos: Integer;
    begin
      CheckCurrentChar('{');
       // ���������� ������ �����������
      iStartPos := iCurrentPos;
       // ���������� ������� �� ����� ������, ���� �� �������� "}"
      repeat
        Inc(iCurrentPos);
      until (iCurrentPos>iLen) or (FExpression[iCurrentPos]='}');
       // ���� "}" �� ����������, ������, ���� ������������ �� ������
      if iCurrentPos>iLen then PhoaParseError(iStartPos, SPhoaParseError_CommentBlockNotTerminated);
       // ��������� � ���������� �������
      Inc(iCurrentPos);
    end;

     // ��������� �� FExpression � ���������� ������ ��������������, ������� � ������� �������
    function ExtractIdentifierString: WideString;
    var iStartPos: Integer;
    begin
      iStartPos := iCurrentPos;
      while (iCurrentPos<=iLen) and (FExpression[iCurrentPos] in CSIDChars) do Inc(iCurrentPos);
      Result := Copy(FExpression, iStartPos, iCurrentPos-iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������, ������� � ������� �������
    function ExtractLiteralString: WideString;
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
    function ExtractValueString: WideString;
    var
      wc: WideChar;
      bSignValid, bHasDot, bHasDigit: Boolean;
      iStartPos: Integer;
    begin
      iStartPos  := iCurrentPos;
      bSignValid := True;
      bHasDot    := False;
      bHasDigit  := False;
       // ���������� ������, ���� �� ����� �� ����� ��� �� ����� ��������������� ������
      while iCurrentPos<=iLen do begin
        wc := FExpression[iCurrentPos];
        if wc='-' then begin
          if not bSignValid then Break;
        end else if wc='.' then begin
          if not bHasDot then bHasDot := True else Break;
        end else if wc in CSDigits then
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
    function ExtractField: TPhoaParsedPicProp;
    var iStartPos: Integer;
    begin
      CheckCurrentChar('$');
      iStartPos := iCurrentPos;
      Inc(iCurrentPos);
      Result := TPhoaParsedPicProp.Create(ExtractIdentifierString, iStartPos);
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
      ws: WideString;
      wc: WideChar;
    begin
      iStartPos := iCurrentPos;
      ws := '';
      while iCurrentPos<=iLen do begin
        wc := FExpression[iCurrentPos];
        if not (wc in CSMathCompChars) then Break;
        ws := ws+wc;
        Inc(iCurrentPos);
      end;
      Result := TPhoaParsedOperator.Create(ws, iStartPos);
    end;

     // ��������� �� FExpression � ���������� ��������� �������-������, ������� � ������� �������
    function ExtractList: TPhoaParsedList;
    var
      iStartPos: Integer;
      wc: WideChar;
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
          wc := FExpression[iCurrentPos];
          case wc of
            ']': begin
               // ���� ����� ������ � ������ ������ �����������, �������� ������� �������, ��������� ������ � �������
              if bCloseValid then begin
                Inc(iCurrentPos);
                bCloseValid := False;
                Break;
              end else
                PhoaParseError(iCurrentPos, SPhoaParseError_ListItemExpected);
            end;
            ',': begin
               // ���� ����������� ������ � ������ ������ �����������, �������� ������� �������
              if bSeparatorValid then begin
                Inc(iCurrentPos);
                 // ����� ����������� ����������� ������ ��������� ������� ������
                bCloseValid     := False;
                bItemValid      := True;
                bSeparatorValid := False;
              end else
                PhoaParseError(iCurrentPos, SPhoaParseError_ListItemExpected);
            end;
            else begin
               // ���� ������� ������ � ������ ������ �����������, ��������� ��� � ��������� � ������
              if bItemValid then begin
                Item := ExtractItem;
                if Item<>nil then Result.ItemList.Add(Item);
                 // ����� �������� ������ ����������� ������ ����������� ��� ����� ������
                bCloseValid     := True;
                bItemValid      := False;
                bSeparatorValid := True;
              end else
                PhoaParseError(iCurrentPos, SPhoaParseError_SomethingExpected, [', or ]']);
            end;
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
      wc: WideChar;
      ws: WideString;
    begin
      iStartPos := iCurrentPos;
      wc := FExpression[iCurrentPos];
      case wc of
        '''': begin
          ws := ExtractLiteralString;
          Result := TPhoaParsedLiteral.Create(ws, iStartPos);
        end;
        '[':
          Result := ExtractList;
        '$':
          Result := ExtractField;
        '(', ')': begin
          Inc(iCurrentPos);
          Result := TPhoaParsedBracket.Create(wc, iStartPos);
        end;
        '{':
          SkipMultiLineComment;
        else begin
          if (wc='/') and (iCurrentPos<iLen) and (FExpression[iCurrentPos+1]='/') then
            SkipSingleLineComment
          else if wc in CSMathCompChars then
            Result := ExtractComparison
          else if wc in CSIDStartChars then
            Result := ExtractOperator
          else if wc in CSValueChars then begin
            ws := ExtractValueString;
            Result := TPhoaParsedValue.Create(ws, iStartPos);
          end else
            PhoaParseError(iCurrentPos, SPhoaParseError_InvalidCharacter, [wc]);
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
        if bRaiseOnError then raise;
      end;
    end;
  end;

  procedure TPhoaParsingPicFilter.SetExpression(const wsValue: WideString);
  var ws: WideString;
  begin
    ws := TntAdjustLineBreaks(wsValue);
    if FExpression<>ws then begin
      FExpression := ws;
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

