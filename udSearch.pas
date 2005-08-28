//**********************************************************************************************************************
//  $Id: udSearch.pas,v 1.40 2005-08-28 06:05:23 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit udSearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, Registry, Contnrs,
  phIntf, phMutableIntf, phNativeIntf, phObj, phOps,
  phDlg, ActnList, TBX, Menus, TB2Item, DKLang, TB2Dock, TB2Toolbar,
  VirtualTrees, ComCtrls, StdCtrls, ExtCtrls, ufrExprPicFilter;

type
   // ��� ������
  TPicSearchKind = (pskSimple, pskExpression);

   // ������� �������� �������� ������
  TSimpleSearchCondition = (
    sscInvalid, // "������������ �������"
     // Number conditions
    sscNumberLess, sscNumberLessEqual, sscNumberEqual, sscNumberNotEqual, sscNumberGreaterEqual, sscNumberGreater,
     // String conditions
    sscStrSpecified, sscStrNotSpecified, sscStrStarts, sscStrNotStarts, sscStrEqual, sscStrNotEqual, sscStrEnds,
    sscStrNotEnds, sscStrContains, sscStrNotContains, sscStrMatchesMask, sscStrNotMatchesMask,
     // Date/Time conditions
    sscDateTimeSpecified, sscDateTimeNotSpecified, sscDateTimeLess, sscDateTimeLessEqual, sscDateTimeEqual,
    sscDateTimeNotEqual, sscDateTimeGreaterEqual, sscDateTimeGreater,
     // List conditions
    sscListSpecified, sscListNotSpecified, sscListAny, sscListNone, sscListAll);
  TSimpleSearchConditions = set of TSimpleSearchCondition;

   //===================================================================================================================
   // �������� �������� ������
   //===================================================================================================================

  TSimpleSearchCriterion = class(TObject)
  private
     // ������������� �� ����� ������ �������������� �������� ��������
    FValue_Integer: Integer;
    FValue_Float: Double;
    FValue_String: String;
    FValue_Masks: TPhoaMasks;
    FValue_Keywords: IPhotoAlbumKeywordList;
     // Prop storage
    FPicProperty: TPicProperty;
    FCondition: TSimpleSearchCondition;
    FValue: Variant;
    FDatatype: TPicPropDatatype;
     // ����������� ����, ��������� �� PicProperty
    procedure AdjustPicProperty;
     // Prop handlers
    function  GetAsExpression: String;
    function  GetConditionName: String;
    function  GetDataString: String;
    function  GetPicPropertyName: String;
    function  GetValueStr: String;
    procedure SetCondition(Value: TSimpleSearchCondition);
    procedure SetDataString(const Value: String);
    procedure SetPicProperty(Value: TPicProperty);
    procedure SetValueStr(const sValue: String);
  public
    constructor Create;
     // ���������� True, ���� ����������� �������� ��� ��������
    function  Matches(Pic: IPhoaPic): Boolean;
     // ����������/����������� ������
    procedure InitializeSearch;
    procedure FinalizeSearch;
     // ��������� Strings �������� � ���������� ��������� �������� ��� �������� ���� ������
    procedure ObtainConditionStrings(Strings: TStrings);
     // Props
     // -- ������� �������� � ���� ��������� ������
    property AsExpression: String read GetAsExpression;
     // -- ������� ��������
    property Condition: TSimpleSearchCondition read FCondition write SetCondition;
     // -- ������������ ������� ��������
    property ConditionName: String read GetConditionName;
     // -- ��� ������ �������� � ���� ������
    property DataString: String read GetDataString write SetDataString;
     // -- ��� ������ PicProperty
    property Datatype: TPicPropDatatype read FDatatype;
     // -- �������� �����������, ����������� �� �������
    property PicProperty: TPicProperty read FPicProperty write SetPicProperty;
     // -- ������������ �������� �����������
    property PicPropertyName: String read GetPicPropertyName;
     // -- �������� ��������
    property Value: Variant read FValue write FValue;
     // -- �������� �������� � ���� ������
    property ValueStr: String read GetValueStr write SetValueStr;
  end;

   //===================================================================================================================
   // ������ ��������� ���� TSimpleSearchCriterion
   //===================================================================================================================

  TSimpleSearchCriterionList = class(TObject)
  private
     // ���������� ������
    FList: TObjectList;
     // Prop handlers
    function GetCount: Integer;
    function GetItems(Index: Integer): TSimpleSearchCriterion;
  public
    constructor Create;
    destructor Destroy; override;
    function  Add(Item: TSimpleSearchCriterion): Integer;
    procedure Delete(Index: Integer);
    procedure Clear;
     // ����������/����������� ������
    procedure InitializeSearch;
    procedure FinalizeSearch;
     // ����������/�������� �� �������
    procedure RegLoad(rif: TRegIniFile; const sSection: String);
    procedure RegSave(rif: TRegIniFile; const sSection: String);
     // ���������� True, ���� ����������� �������� ��� ��� ��������
    function  Matches(Pic: IPhoaPic): Boolean;
     // Props
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TSimpleSearchCriterion read GetItems; default;
  end;

   //===================================================================================================================
   // TdSearch
   //===================================================================================================================

  TdSearch = class(TPhoaDialog)
    alMain: TActionList;
    aSimpleConvertToExpression: TAction;
    aSimpleCrDelete: TAction;
    aSimpleReset: TAction;
    bSimpleConvertToExpression: TTBXItem;
    bSimpleCrDelete: TTBXItem;
    bSimpleReset: TTBXItem;
    dklcMain: TDKLanguageController;
    dkSimpleTop: TTBXDock;
    frExprPicFilter: TfrExprPicFilter;
    gbSearch: TGroupBox;
    ipmSimpleDelete: TTBXItem;
    ipmsmSimpleProp: TTBXSubmenuItem;
    pcCriteria: TPageControl;
    pmSimple: TTBXPopupMenu;
    rbAll: TRadioButton;
    rbCurGroup: TRadioButton;
    rbSearchResults: TRadioButton;
    tbSimpleMain: TTBXToolbar;
    tsExpression: TTabSheet;
    tsSimple: TTabSheet;
    tvSimpleCriteria: TVirtualStringTree;
    procedure aaSimpleConvertToExpression(Sender: TObject);
    procedure aaSimpleCrDelete(Sender: TObject);
    procedure aaSimpleReset(Sender: TObject);
    procedure pcCriteriaChange(Sender: TObject);
    procedure pmSimplePopup(Sender: TObject);
    procedure tvSimpleCriteriaBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    procedure tvSimpleCriteriaChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure tvSimpleCriteriaCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure tvSimpleCriteriaEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
    procedure tvSimpleCriteriaFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
    procedure tvSimpleCriteriaGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure tvSimpleCriteriaInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure tvSimpleCriteriaPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  private
     // ������ ��������� �������� ������
    FSimpleCriteria: TSimpleSearchCriterionList;
     // ��������� ������ ����������� ������ (������ �� �����������)
    FLocalResults: IPhoaMutablePicList;
     // ����������
    FApp: IPhotoAlbumApp;
     // ������, � ������� �������� ����������
    FResultsGroup: IPhotoAlbumPicGroup;
    FSearchKind: TPicSearchKind;
     // ��������� tvSimpleCriteria (� ����� �� ��������� FSimpleCriteria)
    procedure SyncSimpleCriteria;
     // ���������� ������ �������� �������� ������ �� ���� tvSimpleCriteria, ��� nil, ���� Node=nil ��� Node
     //   ������������� "�������" ����
    function  GetSimpleCriterion(Node: PVirtualNode): TSimpleSearchCriterion;
     // �������� ��������� ������
    procedure PerformSearch;
     // ������� ����� �� ������ �������� ����������� � pmSimple
    procedure SimpleCrPicPropClick(Sender: TObject);
     // ��������� FSearchKind
    procedure UpdateSearchKind;
  protected
    function  GetRelativeRegistryKey: String; override;
    function  GetSizeable: Boolean; override;
    procedure ButtonClick_OK; override;
    procedure DoCreate; override;
    procedure ExecuteInitialize; override;
    procedure SettingsLoad(rif: TRegIniFile); override;
    procedure SettingsSave(rif: TRegIniFile); override;
    procedure UpdateState; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
     // Props
    property SearchKind: TPicSearchKind read FSearchKind;
  end;

const
   // ������ ������� ��������� ��� ����� ������ ������� ����������
  SSCNumberConditions         = [
    sscNumberLess, sscNumberLessEqual, sscNumberEqual, sscNumberNotEqual, sscNumberGreaterEqual, sscNumberGreater];
  SSCStringConditions         = [
    sscStrSpecified, sscStrNotSpecified, sscStrStarts, sscStrNotStarts, sscStrEqual, sscStrNotEqual, sscStrEnds,
    sscStrNotEnds, sscStrContains, sscStrNotContains, sscStrMatchesMask, sscStrNotMatchesMask];
  SSCStringConditions_Pattern = [
    sscStrStarts, sscStrNotStarts, sscStrEqual, sscStrNotEqual, sscStrEnds, sscStrNotEnds, sscStrContains,
    sscStrNotContains];
  SSCStringConditions_Mask    = [sscStrMatchesMask, sscStrNotMatchesMask];
  SSCDateTimeConditions       = [
    sscDateTimeSpecified, sscDateTimeNotSpecified, sscDateTimeLess, sscDateTimeLessEqual, sscDateTimeEqual,
    sscDateTimeNotEqual, sscDateTimeGreaterEqual, sscDateTimeGreater];
  SSCListConditions           = [sscListSpecified, sscListNotSpecified, sscListAny, sscListNone, sscListAll];
   // ����� �������, �� �������������� ��������
  SSCNoValueConditions        = [
    sscInvalid, sscStrSpecified, sscStrNotSpecified, sscDateTimeSpecified, sscDateTimeNotSpecified, sscListSpecified,
    sscListNotSpecified];
   // ������ ������� ��������� � ����������� �� ���� ������ �������� ����������
  aSSConditionsByDatatype: Array[TPicPropDatatype] of TSimpleSearchConditions = (
    SSCStringConditions,   // ppdtString
    SSCNumberConditions,   // ppdtInteger
    SSCNumberConditions,   // ppdtFloat
    SSCDateTimeConditions, // ppdtDate
    SSCDateTimeConditions, // ppdtTime
    [],                    // ppdtBoolean
    SSCListConditions,     // ppdtList
    [],                    // ppdtSize
    [],                    // ppdtPixelFormat
    [],                    // ppdtRotation
    []);                   // ppdtFlips
   // ������� �� ��������� ��� ����� ������ ������� ����������
  aSSDefaultConditionsForDatatype: Array[TPicPropDatatype] of TSimpleSearchCondition = (
    sscStrContains,   // ppdtString
    sscNumberEqual,   // ppdtInteger
    sscNumberEqual,   // ppdtFloat
    sscDateTimeEqual, // ppdtDate
    sscDateTimeEqual, // ppdtTime
    sscInvalid,       // ppdtBoolean
    sscListAny,       // ppdtList
    sscInvalid,       // ppdtSize
    sscInvalid,       // ppdtPixelFormat
    sscInvalid,       // ppdtRotation
    sscInvalid);      // ppdtFlips
   // ��������� ��� ������� (%0:s - ��������; %1:s - ��������)
  aSSConditionExpressions: Array[TSimpleSearchCondition] of String = (
    '',                                  // sscInvalid
    '%0:s<%1:s',                         // sscNumberLess
    '%0:s<=%1:s',                        // sscNumberLessEqual
    '%0:s=%1:s',                         // sscNumberEqual
    '%0:s<>%1:s',                        // sscNumberNotEqual
    '%0:s>=%1:s',                        // sscNumberGreaterEqual
    '%0:s>%1:s',                         // sscNumberGreater
    '%0:s<>''''',                        // sscStrSpecified
    '%0:s=''''',                         // sscStrNotSpecified
    '%0:s startsWith ''%1:s''',          // sscStrStarts
    'not (%0:s startsWith ''%1:s'')',    // sscStrNotStarts
    '%0:s=''%1:s''',                     // sscStrEqual
    '%0:s<>''%1:s''',                    // sscStrNotEqual
    '%0:s endsWith ''%1:s''',            // sscStrEnds
    'not (%0:s endsWith ''%1:s'')',      // sscStrNotEnds
    '%0:s contains ''%1:s''',            // sscStrContains
    'not (%0:s contains ''%1:s'')',      // sscStrNotContains
    '<masks not implemented>',           // sscStrMatchesMask
    '<masks not implemented>',           // sscStrNotMatchesMask
    '%0:s<>''''',                        // sscDateTimeSpecified
    '%0:s=''''',                         // sscDateTimeNotSpecified
    '%0:s<''%1:s''',                     // sscDateTimeLess
    '%0:s<=''%1:s''',                    // sscDateTimeLessEqual
    '%0:s=''%1:s''',                     // sscDateTimeEqual
    '%0:s<>''%1:s''',                    // sscDateTimeNotEqual
    '%0:s>=''%1:s''',                    // sscDateTimeGreaterEqual
    '%0:s>''%1:s''',                     // sscDateTimeGreater
    'not (isEmpty %0:s)',                // sscListSpecified
    'isEmpty %0:s',                      // sscListNotSpecified
    '<list operators not implemented>',  // sscListAny
    '<list operators not implemented>',  // sscListNone
    '<list operators not implemented>'); // sscListAll

   // ������� �������� tvSimpleCriteria
  IColIdx_Simple_Property  = 0;
  IColIdx_Simple_Condition = 1;
  IColIdx_Simple_Value     = 2;

  function DoSearch(AApp: IPhotoAlbumApp; ResultsGroup: IPhotoAlbumPicGroup): Boolean;

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
{$R *.dfm}
uses
  TypInfo, StrUtils, Mask, ToolEdit,
  phPhoa, phUtils, ConsVars, udSelKeywords, phSettings, phMsgBox,
  phParsingPicFilter, Main;

var
   // ������ ���� ����������� ����, ������� �����, �������, ���������
  SLPhoaPlaces:        TStringList;
  SLPhoaFilmNumbers:   TStringList;
  SLPhoaAuthors:       TStringList;
  SLPhoaMedia:         TStringList;
   // ��������� �������������� ��� ������ ���������
  sSearchExpression:   String;

  function DoSearch(AApp: IPhotoAlbumApp; ResultsGroup: IPhotoAlbumPicGroup): Boolean;
  begin
    with TdSearch.Create(Application) do
      try
        FApp          := AApp;
        FResultsGroup := ResultsGroup;
        Result := ExecuteModal(False, True);
      finally
        Free;
      end;
  end;

   // ���������� [��������������] ������������ �������
  function GetSimpleConditionName(c: TSimpleSearchCondition): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TSimpleSearchCondition), Byte(c)));
  end;

   // ���������� ������������ �������� ���� TSimpleSearchCondition � ���� ������
  function SimpleConditionTypeToStr(Condition: TSimpleSearchCondition): String;
  begin
    Result := GetEnumName(TypeInfo(TSimpleSearchCondition), Byte(Condition));
  end;

   // ���������� ������� ���� TSimpleSearchCondition �� ��� ���������� ������������. ���� ������ ������������ ��
   //   �������, ���������� sscInvalid
  function StrToSimpleConditionType(const sCondition: String): TSimpleSearchCondition;
  begin
    Result := TSimpleSearchCondition(GetEnumValue(TypeInfo(TSimpleSearchCondition), sCondition));
    if not (Result in [Low(Result)..High(Result)]) then Result := sscInvalid;
  end;

   //===================================================================================================================
   // TSimpleSearchCriterion
   //===================================================================================================================

  procedure TSimpleSearchCriterion.AdjustPicProperty;
  begin
    FDatatype := aPicPropDatatype[FPicProperty];
    Condition := aSSDefaultConditionsForDatatype[FDatatype];
    Value := Null;
  end;

  constructor TSimpleSearchCriterion.Create;
  begin
    inherited Create;
    FPicProperty := ppID;
    AdjustPicProperty;
  end;

  procedure TSimpleSearchCriterion.FinalizeSearch;
  begin
    FValue_String := ''; // Release memory
    FreeAndNil(FValue_Masks);
    FValue_Keywords := nil;
  end;

  function TSimpleSearchCriterion.GetAsExpression: String;
  begin
    Result := Format(aSSConditionExpressions[FCondition], ['$'+PicPropToStr(FPicProperty, True), ValueStr]);
  end;

  function TSimpleSearchCriterion.GetConditionName: String;
  begin
    Result := GetSimpleConditionName(FCondition);
  end;

  function TSimpleSearchCriterion.GetDataString: String;
  begin
    Result := Format(
      '%s,%s,%s',
      [PicPropToStr(FPicProperty, True), SimpleConditionTypeToStr(FCondition), ValueStr]);
  end;

  function TSimpleSearchCriterion.GetPicPropertyName: String;
  begin
    Result := PicPropName(FPicProperty);
  end;

  function TSimpleSearchCriterion.GetValueStr: String;
  begin
    Result := '';
    if not VarIsNull(FValue) then
      case FDatatype of
        ppdtString,
          ppdtList,
          ppdtInteger,
          ppdtFloat: Result := FValue;
        ppdtDate:    Result := DateToStr(PhoaDateToDate(FValue), AppFormatSettings);
        ppdtTime:    Result := TimeToStr(PhoaTimeToTime(FValue), AppFormatSettings);
      end;
  end;

  procedure TSimpleSearchCriterion.InitializeSearch;
  var bNull: Boolean;
  begin
    bNull := VarIsNull(FValue);
    case FDatatype of
      ppdtString:
        if FCondition in SSCStringConditions_Pattern then
          FValue_String := ValueStr
        else if FCondition in SSCStringConditions_Mask then begin
          FreeAndNil(FValue_Masks);
          if not bNull then FValue_Masks := TPhoaMasks.Create(FValue);
        end;
      ppdtInteger,
        ppdtDate,
        ppdtTime: if bNull then FValue_Integer := 0 else FValue_Integer := FValue;
      ppdtFloat:  if bNull then FValue_Float   := 0 else FValue_Float   := FValue;
      ppdtList:
        if bNull then
          FValue_Keywords := nil
        else begin
          FValue_Keywords := NewPhotoAlbumKeywordList;
          FValue_Keywords.CommaText := FValue;
        end;
    end;
  end;

  function TSimpleSearchCriterion.Matches(Pic: IPhoaPic): Boolean;
  var vProp: Variant;

    procedure InvalidDatatype;
    begin
      PhoaException('Invalid or incompatible condition or datatype');
    end;

    function TestString: Boolean;
    var sProp: String;
    begin
      Result := False;
       // ��������� �� ������� ��� ����� ���������
      sProp := VarToStr(vProp);
      case FCondition of
        sscStrSpecified, sscStrNotSpecified:     Result := sProp<>'';
        sscStrStarts, sscStrNotStarts:           Result := AnsiStartsText(FValue_String, sProp);
        sscStrEqual, sscStrNotEqual:             Result := AnsiSameText(FValue_String, sProp);
        sscStrEnds, sscStrNotEnds:               Result := AnsiEndsText(FValue_String, sProp);
        sscStrContains, sscStrNotContains:       Result := AnsiContainsText(sProp, FValue_String);
        sscStrMatchesMask, sscStrNotMatchesMask: Result := (FValue_Masks=nil) or FValue_Masks.Matches(sProp);
        else InvalidDatatype;
      end;
       // ���� ������������� ������� - ����������� ��������� ���������
      if FCondition in [sscStrNotSpecified, sscStrNotStarts, sscStrNotEqual, sscStrNotEnds, sscStrNotContains, sscStrNotMatchesMask] then
        Result := not Result;
    end;

    function TestInteger: Boolean;
    var iProp: Integer;
    begin
      Result := False;
      if not VarIsNull(vProp) then begin
        iProp := vProp;
        case FCondition of
          sscNumberLess:         Result := iProp< FValue_Integer;
          sscNumberLessEqual:    Result := iProp<=FValue_Integer;
          sscNumberEqual:        Result := iProp= FValue_Integer;
          sscNumberNotEqual:     Result := iProp<>FValue_Integer;
          sscNumberGreaterEqual: Result := iProp>=FValue_Integer;
          sscNumberGreater:      Result := iProp> FValue_Integer;
          else InvalidDatatype;
        end;
      end;
    end;

    function TestFloat: Boolean;
    var dProp: Double;
    begin
      Result := False;
      if not VarIsNull(vProp) then begin
        dProp := vProp;
        case FCondition of
          sscNumberLess:         Result := dProp< FValue_Float;
          sscNumberLessEqual:    Result := dProp<=FValue_Float;
          sscNumberEqual:        Result := dProp= FValue_Float;
          sscNumberNotEqual:     Result := dProp<>FValue_Float;
          sscNumberGreaterEqual: Result := dProp>=FValue_Float;
          sscNumberGreater:      Result := dProp> FValue_Float;
          else InvalidDatatype;
        end;
      end;
    end;

    function TestDateTime: Boolean;
    var iProp: Integer;
    begin
      Result := False;
      if VarIsNull(vProp) then iProp := 0 else iProp := vProp;
      case FCondition of
        sscDateTimeSpecified:    Result := not VarIsNull(vProp);
        sscDateTimeNotSpecified: Result := VarIsNull(vProp);
        sscDateTimeLess:         Result := iProp< FValue_Integer;
        sscDateTimeLessEqual:    Result := iProp<=FValue_Integer;
        sscDateTimeEqual:        Result := iProp= FValue_Integer;
        sscDateTimeNotEqual:     Result := iProp<>FValue_Integer;
        sscDateTimeGreaterEqual: Result := iProp>=FValue_Integer;
        sscDateTimeGreater:      Result := iProp> FValue_Integer;
        else InvalidDatatype;
      end;
    end;

    function TestList: Boolean;
    var
      PicKeywords: IPhoaKeywordList;
      i: Integer;
    begin
      Result := False;
      PicKeywords := Pic.Keywords;
      case FCondition of
        sscListSpecified:    Result := PicKeywords.Count>0;
        sscListNotSpecified: Result := PicKeywords.Count=0;
        sscListAny, sscListNone, sscListAll:
           // ���� ������ (�������� ��������) �� �����
          if (FValue_Keywords=nil) or (FValue_Keywords.Count=0) then
            Result := FCondition=sscListNone
           // ����� ��������� ������ �����
          else begin 
            Result := FCondition in [sscListNone, sscListAll];
            for i := 0 to FValue_Keywords.Count-1 do
              if (PicKeywords.IndexOf(FValue_Keywords[i])>=0) xor (Condition=sscListAll) then begin
                Result := not Result;
                Break;
              end;
          end;
        else InvalidDatatype;
      end;
    end;

  begin
    vProp := Pic.PropValues[FPicProperty];
    Result := False;
    case FDatatype of
      ppdtString:  Result := TestString;
      ppdtInteger: Result := TestInteger;
      ppdtFloat:   Result := TestFloat;
      ppdtDate,
        ppdtTime:  Result := TestDateTime;
      ppdtList:    Result := TestList;
      else InvalidDatatype;
    end;
  end;

  procedure TSimpleSearchCriterion.ObtainConditionStrings(Strings: TStrings);
  var
    c: TSimpleSearchCondition;
    PossibleConditions: TSimpleSearchConditions;
  begin
    Strings.BeginUpdate;
    try
      Strings.Clear;
       // ���������� �������, ������ � Strings ���������� ��� Datatype
      PossibleConditions := aSSConditionsByDatatype[FDatatype];
      for c := Low(c) to High(c) do
        if c in PossibleConditions then Strings.AddObject(GetSimpleConditionName(c), Pointer(c));
    finally
      Strings.EndUpdate;
    end;
  end;

  procedure TSimpleSearchCriterion.SetCondition(Value: TSimpleSearchCondition);
  begin
    if FCondition<>Value then begin
      if not (Value in aSSConditionsByDatatype[FDatatype]) then
        PhoaException(
          'Condition %s is incompatible with datatype %s',
          [GetEnumName(TypeInfo(TSimpleSearchCondition), Byte(Value)),
           GetEnumName(TypeInfo(TPicPropDatatype), Byte(FDatatype))]);
      FCondition := Value;
    end;
  end;

  procedure TSimpleSearchCriterion.SetDataString(const Value: String);
  var
    s: String;
    pp: TPicProperty;
    c: TSimpleSearchCondition;
  begin
    s := Value;
     // ��������� ��������
    pp := StrToPicProp(ExtractFirstWord(s, ','), False);
    if pp in [Low(pp)..High(pp)] then begin
      PicProperty := pp;
       // ��������� �������
      c := StrToSimpleConditionType(ExtractFirstWord(s, ','));
      if (c<>sscInvalid) and (c in aSSConditionsByDatatype[FDatatype]) then begin
        Condition := c;
         // ����������� ��������
        ValueStr := s; 
      end;
    end;
  end;

  procedure TSimpleSearchCriterion.SetPicProperty(Value: TPicProperty);
  begin
    if FPicProperty<>Value then begin
      if aSSConditionsByDatatype[aPicPropDatatype[Value]]=[] then
        PhoaException('Property "%s" isn''t a search property', [PicPropName(Value)]);
      FPicProperty := Value;
      AdjustPicProperty;
    end;
  end;

  procedure TSimpleSearchCriterion.SetValueStr(const sValue: String);
  begin
     // ���� ������ ������, ��� ��� ����/������� �� ������� �� ����� ����� - ������� Null 
    if (sValue='') or ((FDatatype in [ppdtDate, ppdtTime]) and (LastDelimiter('0123456789', sValue)=0)) then
      FValue := Null
     // ����� ����������� �������� � ����������� ����  
    else
      case FDatatype of
        ppdtString,
          ppdtList:  FValue := sValue;
        ppdtInteger: FValue := StrToInt(sValue);
        ppdtFloat:   FValue := StrToFloat(sValue, AppFormatSettings);
        ppdtDate:    FValue := DateToPhoaDate(StrToDate(sValue, AppFormatSettings));
        ppdtTime:    FValue := TimeToPhoaTime(StrToTime(sValue, AppFormatSettings));
      end;
  end;

   //===================================================================================================================
   // TSimpleSearchCriterionList
   //===================================================================================================================

  function TSimpleSearchCriterionList.Add(Item: TSimpleSearchCriterion): Integer;
  begin
    Result := FList.Add(Item);
  end;

  procedure TSimpleSearchCriterionList.Clear;
  begin
    FList.Clear;
  end;

  constructor TSimpleSearchCriterionList.Create;
  begin
    inherited Create;
    FList := TObjectList.Create(True);
  end;

  procedure TSimpleSearchCriterionList.Delete(Index: Integer);
  begin
    FList.Delete(Index);
  end;

  destructor TSimpleSearchCriterionList.Destroy;
  begin
    FList.Free;
    inherited Destroy;
  end;

  procedure TSimpleSearchCriterionList.FinalizeSearch;
  var i: Integer;
  begin
    for i := 0 to FList.Count-1 do TSimpleSearchCriterion(FList[i]).FinalizeSearch;
  end;

  function TSimpleSearchCriterionList.GetCount: Integer;
  begin
    Result := FList.Count;
  end;

  function TSimpleSearchCriterionList.GetItems(Index: Integer): TSimpleSearchCriterion;
  begin
    Result := TSimpleSearchCriterion(FList[Index]);
  end;

  procedure TSimpleSearchCriterionList.InitializeSearch;
  var i: Integer;
  begin
    for i := 0 to FList.Count-1 do TSimpleSearchCriterion(FList[i]).InitializeSearch;
  end;

  function TSimpleSearchCriterionList.Matches(Pic: IPhoaPic): Boolean;
  var i: Integer;
  begin
    Result := True;
    for i := 0 to FList.Count-1 do
      if not TSimpleSearchCriterion(FList[i]).Matches(Pic) then begin
        Result := False;
        Break;
      end;
  end;

  procedure TSimpleSearchCriterionList.RegLoad(rif: TRegIniFile; const sSection: String);
  var
    SL: TStringList;
    Crit: TSimpleSearchCriterion;
    i: Integer;
  begin
    FList.Clear;
     // ��������� ������ ��������� � ������ ����� 
    SL := TStringList.Create;
    try
      rif.ReadSectionValues(sSection, SL);
       // ��������� ������ - ��� ���� �������� ����� ������������� �� �������
      SL.Sorted := True;
      for i := 0 to SL.Count-1 do begin
        Crit := TSimpleSearchCriterion.Create;
        try
          Crit.DataString := SL.ValueFromIndex[i];
          Add(Crit);
        except
          Crit.Free;
        end;
      end;
    finally
      SL.Free;
    end;
  end;

  procedure TSimpleSearchCriterionList.RegSave(rif: TRegIniFile; const sSection: String);
  var i: Integer;
  begin
     // ������� ������
    rif.EraseSection(sSection);
     // ���������� � ����� ������ ���������
    for i := 0 to FList.Count-1 do
      rif.WriteString(sSection, Format('%.8d', [i]), TSimpleSearchCriterion(FList[i]).DataString);
  end;

   //===================================================================================================================
   // VirtualStringTree EditLink ��� ���������� �������
   //===================================================================================================================
type
  TPicPropEditMoveDirection = (emdNone, emdEnter, emdLeft, emdRight, emdUp, emdDown);

  TSimpleCriterionEditLink = class(TInterfacedObject, IVTEditLink)
  private
     // ������������� ��������
    FCriterion: TSimpleSearchCriterion; 
     // One of the property editor classes
    FWControl: TWinControl;
     // A back reference to the tree calling
    FTree: TVirtualStringTree;
     // The node being edited
    FNode: PVirtualNode;
     // The column of the node being edited
    FColumn: Integer;
     // Used to capture some important messages regardless of the type of control we use
    FOldWControlWndProc: TWndMethod;
     // ���� ���������� �������� ��������������
    FEndingEditing: Boolean;
     // ���� ������� ��������� ��������������, ������������ �� ����� ������ ����������� ���� ������ �������� ����
    FPreserveEndEdit: Boolean;
     // ���������� ������� ��������� ��������
    procedure WControlWindowProc(var Msg: TMessage);
     // ����������� ������� ��������
    procedure WKeywordButtonClick(Sender: TObject);
    procedure WControlExit(Sender: TObject);
    procedure WControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
     // ����������� ��������� VK_xxx � TPicPropEditMoveDirection
    function  VirtualKeyToDirection(VKey: Word): TPicPropEditMoveDirection;
     // ����������� �������������� (�������) � �������� ��������� � ������ ��� Direction<>emdNone, ���������� True, ����
     //   �������
    function  MoveSelection(Direction: TPicPropEditMoveDirection): Boolean;
  public
    constructor Create(ACriterion: TSimpleSearchCriterion);
    destructor Destroy; override;
     // IVTEditLink
    function  BeginEdit: Boolean; stdcall;
    function  CancelEdit: Boolean; stdcall;
    function  EndEdit: Boolean; stdcall;
    function  GetBounds: TRect; stdcall;
    function  PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;
  end;

  function TSimpleCriterionEditLink.BeginEdit: Boolean;
  begin
    Result := True;
    FWControl.Show;
    FWControl.SetFocus;
     // Set a window procedure hook (aka subclassing) to get notified about important messages
    FOldWControlWndProc := FWControl.WindowProc;
    FWControl.WindowProc := WControlWindowProc;
  end;

  function TSimpleCriterionEditLink.CancelEdit: Boolean;
  begin
    Result := True;
     // Restore the edit's window proc
    FWControl.WindowProc := FOldWControlWndProc;
    FWControl.Hide;
  end;

  constructor TSimpleCriterionEditLink.Create(ACriterion: TSimpleSearchCriterion);
  begin
    inherited Create;
    FCriterion := ACriterion;
  end;

  destructor TSimpleCriterionEditLink.Destroy;
  begin
    FWControl.Free;
    inherited Destroy;
  end;

  function TSimpleCriterionEditLink.EndEdit: Boolean;
  var s: String;
  begin
    FEndingEditing := True;
    Result := True;
     // Restore the edit's window proc
    FWControl.WindowProc := FOldWControlWndProc;
     // ������������� �������
    if FColumn=1 then
      FCriterion.Condition := TSimpleSearchCondition(GetCurrentCBObject(FWControl as TComboBox))
     // ������������� ��������
    else begin
      case FCriterion.PicProperty of
        ppDate:     s := (FWControl as TDateEdit).Text;
        ppTime:     s := ChangeTimeSeparator((FWControl as TMaskEdit).Text, False);
        ppKeywords: s := (FWControl as TComboEdit).Text;
        else begin
          s := (FWControl as TComboBox).Text;
           // ��������� ������� �����
          if not (FCriterion.PicProperty in [ppPlace, ppFilmNumber, ppAuthor, ppMedia]) then
            RegSaveHistory(
              Format(SRegSearch_PropMRUFormat, [GetEnumName(TypeInfo(TPicProperty), Integer(FCriterion.PicProperty))]),
              TComboBox(FWControl),
              True);
        end;
      end;
      FCriterion.ValueStr := s;
    end;
    FTree.Invalidate; // ������� ����� ������ �� ����������� ��������� ��������
    FWControl.Hide;
  end;

  function TSimpleCriterionEditLink.GetBounds: TRect;
  begin
    Result := FWControl.BoundsRect;
  end;

  function TSimpleCriterionEditLink.MoveSelection(Direction: TPicPropEditMoveDirection): Boolean;
  var
    n: PVirtualNode;
    iCaretPos, iCol: Integer;
  begin
    Result := False;
    if FEndingEditing or FPreserveEndEdit then Exit;
     // ComboBox
    if FWControl is TComboBox then
      with TComboBox(FWControl) do begin
         // ���� ComboBox �������, ������ �� �������
        if (Direction<>emdNone) and DroppedDown then Exit;
         // �������� ��������� ��� ��������, ���� DropDownList, ������ �������� ��� ������ ����� ��� ����
        Result := (Style=csDropDownList) or (Direction in [emdNone, emdEnter, emdUp, emdDown]);
        iCaretPos := LongRec(Perform(CB_GETEDITSEL, 0, 0)).Hi;
      end
     // ������ �������� (EDITs)
    else begin
       // ��� DateEdit: ���� ������� Popup, ������ �� �������
      if (Direction<>emdNone) and (FWControl is TDateEdit) and TDateEdit(FWControl).PopupVisible then Exit;
       // �������� ��������� ��� ��������, ���� ������ �������� ��� ������ ����� ��� ����
      Result := Direction in [emdNone, emdEnter, emdUp, emdDown];
      iCaretPos := LongRec(FWControl.Perform(EM_GETSEL, 0, 0)).Hi;
       // � TCustomMaskEdit ��� ������� ����� ������ ���� ��������� � 1 ������ ������
      if (FWControl is TCustomMaskEdit) and (TMaskEdit(FWControl).EditMask<>'') then Dec(iCaretPos);
    end;
     // ���� ����� ����� ��� ������ - ��������� � ��� ������, ���� ������ � ���������������� ���� ������
    if not Result then
      case Direction of
        emdLeft:  Result := iCaretPos=0;
        emdRight: Result := iCaretPos=FWControl.Perform(WM_GETTEXTLENGTH, 0, 0);
      end;
     // �������� ���������
    if Result then
      with FTree do begin
        n := FocusedNode;
        iCol := FocusedColumn;
         // ���������� ���� (������) � �������, ���� ������� ���������
        case Direction of
          emdLeft:  Dec(iCol);
          emdRight: Inc(iCol);
          emdUp:    n := GetPrevious(n);
          emdDown:  n := GetNext(n);
        end;
         // ���� �� � ���������� �������� - �������
        if (n<>nil) and (iCol>=0) and (iCol<Header.Columns.Count) then begin
          FEndingEditing := True;
          EndEditNode;
          if CanFocus then SetFocus;
          FocusedNode   := n;
          FocusedColumn := iCol;
          Selected[n] := True;
        end;
      end;
  end;

  function TSimpleCriterionEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;

     // ������ ����� ���������. ���� bCondition=True, �� ��� ������ ������� ��������, ����� ��� ����� ��������
    function NewCombobox(bCondition: Boolean): TComboBox;
    begin
      Result := TComboBox.Create(nil);
      with Result do begin
        Visible       := False;
        Parent        := Tree;
        DropDownCount := 16;
        OnExit        := WControlExit;
        OnKeyDown     := WControlKeyDown;
        if bCondition then begin
          Style       := csDropDownList;
          FCriterion.ObtainConditionStrings(Items);
          SetCurrentCBObject(Result, Byte(FCriterion.Condition));
        end else begin
           // ��������� ������ ��������� ��������� ��� �������
          case FCriterion.PicProperty of
            ppPlace:      Items.Assign(SLPhoaPlaces);
            ppFilmNumber: Items.Assign(SLPhoaFilmNumbers);
            ppAuthor:     Items.Assign(SLPhoaAuthors);
            ppMedia:      Items.Assign(SLPhoaMedia);
            else
              RegLoadHistory(
                Format(SRegSearch_PropMRUFormat, [GetEnumName(TypeInfo(TPicProperty), Integer(FCriterion.PicProperty))]),
                Result,
                False);
          end;
          Text := FCriterion.ValueStr;
        end;
      end;
    end;

     // ������ ����� DateEdit
    function NewDateEdit: TDateEdit;
    begin
      Result := TDateEdit.Create(nil);
      with Result do begin
        Visible    := False;
        Parent     := Tree;
        BlanksChar := '_';
        Text       := FCriterion.ValueStr;
        OnExit     := WControlExit;
        OnKeyDown  := WControlKeyDown;
        if Date=0 then Clear;
      end;
    end;

     // ������ ����� MaskEdit ��� ����� �������
    function NewTimeEdit: TMaskEdit;
    begin
      Result := TMaskEdit.Create(nil);
      with Result do begin
        Visible    := False;
        Parent     := Tree;
        EditMask   := '!99:99:99;1;_';
        MaxLength  := 8;
        Text       := ChangeTimeSeparator(FCriterion.ValueStr, True);
        OnExit     := WControlExit;
        OnKeyDown  := WControlKeyDown;
      end;
    end;

     // ������ ����� ComboEdit ��� ����� �������� ����
    function NewKeywordEdit: TComboEdit;
    begin
      Result := TComboEdit.Create(nil);
      with Result do begin
        Visible       := False;
        Parent        := Tree;
        GlyphKind     := gkEllipsis;
        Text          := FCriterion.ValueStr;
        OnButtonClick := WKeywordButtonClick;
        OnExit        := WControlExit;
        OnKeyDown     := WControlKeyDown;
      end
    end;

  begin
    FTree := Tree as TVirtualStringTree;
    FNode := Node;
    FColumn := Column;
     // Determine what edit type actually is needed
    FreeAndNil(FWControl);
    case Column of
       // *** ������ � �������� ��������
      1: FWControl := NewCombobox(True);
       // *** ������ �� ��������� ��������
      2:
        case FCriterion.Datatype of
          ppdtString,
            ppdtInteger,
            ppdtFloat: FWControl := NewCombobox(False);
          ppdtDate:    FWControl := NewDateEdit;
          ppdtTime:    FWControl := NewTimeEdit;
          ppdtList:    FWControl := NewKeywordEdit;
        end;
    end;
    Result := FWControl<>nil;
  end;

  procedure TSimpleCriterionEditLink.ProcessMessage(var Message: TMessage);
  begin
    FWControl.WindowProc(Message);
  end;

  procedure TSimpleCriterionEditLink.SetBounds(R: TRect);
  begin
    FTree.Header.Columns.GetColumnBounds(FColumn, R.Left, R.Right);
    FWControl.BoundsRect := R;
  end;

  function TSimpleCriterionEditLink.VirtualKeyToDirection(VKey: Word): TPicPropEditMoveDirection;
  begin
    case VKey of
      VK_LEFT:   Result := emdLeft;
      VK_RIGHT:  Result := emdRight;
      VK_UP:     Result := emdUp;
      VK_DOWN:   Result := emdDown;
      VK_RETURN: Result := emdEnter;
      else       Result := emdNone;
    end;
  end;

  procedure TSimpleCriterionEditLink.WControlExit(Sender: TObject);
  begin
    MoveSelection(emdNone);
  end;

  procedure TSimpleCriterionEditLink.WControlKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  begin
    if Shift=[] then
      case Key of
        VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_RETURN: if MoveSelection(VirtualKeyToDirection(Key)) then Key := 0;
      end;
  end;

  procedure TSimpleCriterionEditLink.WControlWindowProc(var Msg: TMessage);
  begin
    case Msg.Msg of
      WM_GETDLGCODE: begin
        FOldWControlWndProc(Msg);
        Msg.Result := Msg.Result or DLGC_WANTALLKEYS;
        Exit;
      end;
      WM_KEYDOWN:
        if ((GetKeyState(VK_SHIFT) or GetKeyState(VK_CONTROL) or GetKeyState(VK_MENU)) and $80=0) then
          case Msg.WParam of
            VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_RETURN: if MoveSelection(VirtualKeyToDirection(Msg.WParam)) then Exit;
          end;
      WM_KILLFOCUS: begin
        MoveSelection(emdNone);
        Exit;
      end;
    end;
    FOldWControlWndProc(Msg);
  end;

  procedure TSimpleCriterionEditLink.WKeywordButtonClick(Sender: TObject);
  var s: String;
  begin
    FPreserveEndEdit := True;
    try
      s := (Sender as TComboEdit).Text;
      if SelectPhoaKeywords((FTree.Owner as TdSearch).FApp.ProjectX, s) then TComboEdit(Sender).Text := s;
    finally
      FPreserveEndEdit := False;
    end;
  end;

   //===================================================================================================================
   // TfSearch
   //===================================================================================================================

  procedure TdSearch.aaSimpleConvertToExpression(Sender: TObject);
  var
    s: String;
    i: Integer;
  begin
    BeginUpdate;
    try
      s := '';
      for i := 0 to FSimpleCriteria.Count-1 do
        AccumulateStr(s, ' and'+S_CRLF, FSimpleCriteria[i].AsExpression);
      frExprPicFilter.Expression := s;
      pcCriteria.ActivePage := tsExpression;
      UpdateSearchKind;
    finally
      EndUpdate;
    end;
  end;

  procedure TdSearch.aaSimpleCrDelete(Sender: TObject);
  begin
    BeginUpdate;
    try
      tvSimpleCriteria.EndEditNode;
      FSimpleCriteria.Delete(tvSimpleCriteria.FocusedNode.Index);
      SyncSimpleCriteria;
    finally
      EndUpdate;
    end;
  end;

  procedure TdSearch.aaSimpleReset(Sender: TObject);
  begin
    FSimpleCriteria.Clear;
    SyncSimpleCriteria;
  end;

  procedure TdSearch.ButtonClick_OK;
  begin
    PerformSearch;
    if FLocalResults.Count=0 then
      PhoaInfo(False, 'SPicsNotFound')
    else begin
       // Fill search results
      FResultsGroup.PicsX.Assign(FLocalResults);
      inherited ButtonClick_OK;
    end;
  end;

  constructor TdSearch.Create(AOwner: TComponent);

    function NewSL: TStringList;
    begin
      Result := TStringList.Create;
      Result.Sorted     := True;
      Result.Duplicates := dupIgnore;
    end;

  begin
    inherited Create(AOwner);
    FSimpleCriteria   := TSimpleSearchCriterionList.Create;
    FLocalResults     := NewPhotoAlbumPicList(False);
     // ������ ������ ����, ������� �����, �������
    SLPhoaPlaces      := NewSL;
    SLPhoaFilmNumbers := NewSL;
    SLPhoaAuthors     := NewSL;
    SLPhoaMedia       := NewSL;
  end;

  destructor TdSearch.Destroy;
  begin
    FLocalResults := nil;
    FSimpleCriteria.Free;
    SLPhoaPlaces.Free;
    SLPhoaFilmNumbers.Free;
    SLPhoaAuthors.Free;
    SLPhoaMedia.Free;
    inherited Destroy;
  end;

  procedure TdSearch.DoCreate;

     // ������ � pmSimple ������ ������ �������� �����������
    procedure CreateSimpleCrPicPropItems;
    var pp: TPicProperty;
    begin
      for pp := Low(pp) to High(pp) do
         // ���� ��� ������ �������� ������������ �����
        if aSSConditionsByDatatype[aPicPropDatatype[pp]]<>[] then
          AddTBXMenuItem(ipmsmSimpleProp, PicPropName(pp), -1, Byte(pp), SimpleCrPicPropClick);
    end;

  begin
    inherited DoCreate;
    HelpContext := IDH_intf_search;
     // ������ � pmSimple ������ ������ �������� �����������
    CreateSimpleCrPicPropItems;
  end;

  procedure TdSearch.ExecuteInitialize;
  begin
    inherited ExecuteInitialize;
     // ��������� ������ ����, ������� �����, �������
    StringsLoadPFAM(FApp.Project, SLPhoaPlaces, SLPhoaFilmNumbers, SLPhoaAuthors, SLPhoaMedia);
     // ����������� ��������
    rbCurGroup.Enabled      := (FApp.CurGroup<>nil) and (FApp.CurGroup.Pics.Count>0);
    rbSearchResults.Enabled := FResultsGroup.Pics.Count>0;
     // �������������� ������ / pmSimple
    ApplyTreeSettings(tvSimpleCriteria);
     // ����� �� ���������
    frExprPicFilter.Expression := sSearchExpression; 
  end;

  function TdSearch.GetRelativeRegistryKey: String;
  begin
    Result := SRegSearch_Root;
  end;

  function TdSearch.GetSimpleCriterion(Node: PVirtualNode): TSimpleSearchCriterion;
  begin
    if (Node=nil) or (Integer(Node.Index)>=FSimpleCriteria.Count) then
      Result := nil
    else
      Result := FSimpleCriteria[Node.Index];
  end;

  function TdSearch.GetSizeable: Boolean;
  begin
    Result := True;
  end;

  procedure TdSearch.pcCriteriaChange(Sender: TObject);
  begin
    UpdateSearchKind;
    case SearchKind of
      pskSimple:     tvSimpleCriteria.SetFocus;
      pskExpression: frExprPicFilter.FocusEditor;
    end;
    StateChanged;
  end;

  procedure TdSearch.PerformSearch;
  type TSearchArea = (saAll, saCurGroup, saResults);
  var
    i, iSrchCount: Integer;
    SearchArea: TSearchArea;
    Pic: IPhotoAlbumPic;
    PicFilter: IPhoaParsingPicFilter;

     // ���������� True, ���� ����������� �������� ��� ��������� ��������
    function Matches(Pic: IPhotoAlbumPic): Boolean;
    begin
      case SearchKind of
         // ������� �����
        pskSimple: Result := FSimpleCriteria.Matches(Pic);
         // ����� �� ���������
        pskExpression:
          try
            Result := PicFilter.Matches(Pic);
          except
            on e: EPhoaParseError do begin
              frExprPicFilter.CaretPos := PicFilter.ParseErrorLocation;
              frExprPicFilter.FocusEditor;
              raise;
            end;
          end;
        else Result := False;          
      end;
    end;

     // �������������� �����
    procedure InitializeSearch;
    begin
      case SearchKind of
         // ������� �����
        pskSimple: FSimpleCriteria.InitializeSearch;
         // ����� �� ���������
        pskExpression: begin
          sSearchExpression := frExprPicFilter.Expression;
          PicFilter := NewPhoaParsingPicFilter;
          PicFilter.Expression := sSearchExpression;
        end;
      end;
    end;

     // ������������ �����
    procedure FinalizeSearch;
    begin
      case SearchKind of
         // ������� �����
        pskSimple: FSimpleCriteria.FinalizeSearch;
         // ����� �� ���������
        pskExpression: PicFilter := nil;
      end;
    end;

  begin
    StartWait;
    try
       // �������������� �����
      try
        InitializeSearch;
         // ����������� ������� ������
        if rbAll.Checked then begin
          SearchArea := saAll;
          iSrchCount := FApp.Project.Pics.Count;
        end else if rbCurGroup.Checked then begin
          SearchArea := saCurGroup;
          iSrchCount := FApp.CurGroup.Pics.Count;
        end else begin
          SearchArea := saResults;
          iSrchCount := FResultsGroup.Pics.Count;
        end;
         // ����
        FLocalResults.Clear;
        for i := 0 to iSrchCount-1 do begin
          case SearchArea of
            saAll:      Pic := FApp.ProjectX.PicsX[i];
            saCurGroup: Pic := FApp.CurGroupX.PicsX[i];
            else        Pic := FResultsGroup.PicsX[i];
          end;
          if Matches(Pic) then FLocalResults.Add(Pic, True);
        end;
      finally
        FinalizeSearch;
      end;
    finally
      StopWait;
    end;
  end;

  procedure TdSearch.pmSimplePopup(Sender: TObject);
  var
    i: Integer;
    Crit: TSimpleSearchCriterion;
  begin
     // ������ ������� �� ������, ��������������� �������� �������� ��������
    Crit := GetSimpleCriterion(tvSimpleCriteria.FocusedNode);
    if Crit<>nil then
      for i := 0 to ipmsmSimpleProp.Count-1 do
        with ipmsmSimpleProp[i] do Checked := TPicProperty(Tag)=Crit.PicProperty;
  end;

  procedure TdSearch.SettingsLoad(rif: TRegIniFile);
  begin
    inherited SettingsLoad(rif);
    pcCriteria.ActivePageIndex := rif.ReadInteger('', 'LastCriteriaPageIndex', 0);
     // ��������� ������ ���������
    FSimpleCriteria.RegLoad(rif, SRegSearch_SimpleCriteria);
    SyncSimpleCriteria;
    ActivateFirstVTNode(tvSimpleCriteria);
     // ��������� ���������
    UpdateSearchKind;
  end;

  procedure TdSearch.SettingsSave(rif: TRegIniFile);
  begin
    inherited SettingsSave(rif);
    rif.WriteInteger('', 'LastCriteriaPageIndex', pcCriteria.ActivePageIndex);
    if ModalResult=mrOK then FSimpleCriteria.RegSave(rif, SRegSearch_SimpleCriteria);
  end;

  procedure TdSearch.SimpleCrPicPropClick(Sender: TObject);
  var
    n: PVirtualNode;
    Crit: TSimpleSearchCriterion;
  begin
     // �������� ������� ��������
    n := tvSimpleCriteria.FocusedNode;
    Crit := GetSimpleCriterion(n);
     // ���� nil - ������, pmSimple ������� ���� ��� ����������� ������. ������ ����� ��������
    if Crit=nil then begin
      Crit := TSimpleSearchCriterion.Create;
      FSimpleCriteria.Add(Crit);
    end;
     // ������������� �������� ��������
    Crit.PicProperty := TPicProperty(TComponent(Sender).Tag);
     // ��������� ������
    SyncSimpleCriteria;
  end;

  procedure TdSearch.SyncSimpleCriteria;
  begin
    tvSimpleCriteria.RootNodeCount := FSimpleCriteria.Count+1; // ��������� ����������� "������" ������
    tvSimpleCriteria.Invalidate;
    StateChanged;
  end;

  procedure TdSearch.tvSimpleCriteriaBeforeCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  var Crit: TSimpleSearchCriterion;
  begin
    if (Column=IColIdx_Simple_Value) and ((Sender.FocusedNode<>Node) or (Sender.FocusedColumn<>Column)) then begin
      Crit := GetSimpleCriterion(Node);
       // ����������� ����� ������ �������� ��� �������, �� ����������� � ��������
      if (Crit<>nil) and (Crit.Condition in SSCNoValueConditions) then
        with TargetCanvas do begin
          Brush.Color := clBtnFace;
          FillRect(CellRect);
        end;
    end;
  end;

  procedure TdSearch.tvSimpleCriteriaChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  var p: TPoint;
  begin
    ActivateVTNode(Sender, Node);
    StateChanged;
    with Sender.GetDisplayRect(Node, -1, False) do p := Sender.ClientToScreen(Point(Left, Bottom));
    pmSimple.Popup(p.x, p.y);
  end;

  procedure TdSearch.tvSimpleCriteriaCreateEditor(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
  begin
    EditLink := TSimpleCriterionEditLink.Create(GetSimpleCriterion(Node));
  end;

  procedure TdSearch.tvSimpleCriteriaEditing(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
  var Crit: TSimpleSearchCriterion;
  begin
    Crit := GetSimpleCriterion(Node);
    Allowed :=
       // �� � �������� �������������
      not UpdateLocked and
       // �� ����������� ������
      (Crit<>nil) and
       // �������� ���� � ������� ��� � �������� ��� ��������������� �������
      ((Column=IColIdx_Simple_Condition) or ((Column=IColIdx_Simple_Value) and not (Crit.Condition in SSCNoValueConditions)));
  end;

  procedure TdSearch.tvSimpleCriteriaFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
  begin
    StateChanged;
     // ����������� ������, � ������� ������
    Sender.EditNode(Node, Column);
  end;

  procedure TdSearch.tvSimpleCriteriaGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
  var
    Crit: TSimpleSearchCriterion;
    s: String;
  begin
    s := '';
    Crit := GetSimpleCriterion(Node);
     // ����������� "������" ������
    if Crit=nil then begin
      if Column=IColIdx_Simple_Property then s := ConstVal('SMsg_SelectSearchPicProp');
     // ������ ��������
    end else
      case Column of
        IColIdx_Simple_Property:  s := Crit.PicPropertyName;
        IColIdx_Simple_Condition: s := Crit.ConditionName;
        IColIdx_Simple_Value:     if not (Crit.Condition in SSCNoValueConditions) then s := Crit.ValueStr;
      end;
    CellText := PhoaAnsiToUnicode(s);
  end;

  procedure TdSearch.tvSimpleCriteriaInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
  begin
     // � ������� ���� ���� ������
    Node.CheckType := ctButton;
  end;

  procedure TdSearch.tvSimpleCriteriaPaintText(Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
  begin
     // ����� ����������� ������ ������ �����
    if GetSimpleCriterion(Node)=nil then TargetCanvas.Font.Color := clGrayText;
  end;

  procedure TdSearch.UpdateSearchKind;
  begin
    if pcCriteria.ActivePage=tsSimple then FSearchKind := pskSimple else FSearchKind := pskExpression;
  end;

  procedure TdSearch.UpdateState;
  var bSSimple, bCrExist: Boolean;
  begin
    inherited UpdateState;
    bSSimple  := SearchKind=pskSimple;
    bCrExist  := FSimpleCriteria.Count>0;
    aSimpleReset.Enabled               := bSSimple and bCrExist;
    aSimpleCrDelete.Enabled            := bSSimple and (GetSimpleCriterion(tvSimpleCriteria.FocusedNode)<>nil);
    aSimpleConvertToExpression.Enabled := bSSimple and bCrExist;
  end;

end.

