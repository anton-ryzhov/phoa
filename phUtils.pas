//**********************************************************************************************************************
//  $Id: phUtils.pas,v 1.45 2005-02-05 16:16:52 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phUtils;

interface
uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, StdCtrls, TB2Item, TBX, VirtualTrees, VirtualShellUtilities,
  phIntf, ConsVars, phObj;

   // Exception raising
  procedure PhoaException(const sMsg: String); overload;
  procedure PhoaException(const sMsg: String; const aParams: Array of const); overload;

   // Min/max values
  function  Max(i1, i2: Integer): Integer;
  function  Min(i1, i2: Integer): Integer;
  function  MinS(s1, s2: Single): Single;
  function  MaxS(s1, s2: Single): Single;

   // ����������� Variant � Integer (��� ���� Null �������������� � 0)
  function  VarToInt(const v: Variant): Integer;

  procedure RegLoadHistory(const sSection: String; cb: TComboBox; bSetLastItem: Boolean);
  procedure RegSaveHistory(const sSection: String; cb: TComboBox; bRegisterFirst: Boolean);
  procedure RegisterCBHistory(cb: TComboBox);
   // ���������� Integer(Items.Objects[ItemIndex]) ��� TComboBox, ��� -1, ���� ItemIndex<0
  function  GetCurrentCBObject(ComboBox: TComboBox): Integer;
   // �� ��, ��� ��������� ComboBox �� Objects[]. ���������� True, ���� �������
  function  SetCurrentCBObject(ComboBox: TComboBox; iObj: Integer): Boolean;

   // ������������ ���� TSize
  function  Size(cx, cy: Integer): TSize; 

   // �������������� TRect<->������ ���� '1,2,3,4'
  function  RectToStr(const r: TRect): String;
  function  StrToRect(const s: String; const rDefault: TRect): TRect;
   // "�������������" ���������� � r ���, ��� TopLeft ������ ����� � ����, ��� BottomRight
  function  OrderRect(const r: TRect): TRect;
   // ���������� True, ���� �������������� ������������
  function  RectsOverlap(const r1, r2: TRect): Boolean;
   // ���������� ��������� ����������� ���������������
  function  GetRectIntersection(const r1, r2: TRect): TRect;

   // �������������� ���������/������� �����<->������. FormPositionFromStr ���������� True, ���� ���������� ������ ��
   //   ������ ������ ������� 
  function  FormPositionToStr(const BoundsRect: TRect): String;
  function  FormPositionFromStr(const sBounds: String; Constraints: TSizeConstraints; out BoundsRect: TRect): Boolean;

   // ������ � ��������� ������ � ���� "Name/Size/Style/Color/Charset"
  function  FontToStr(Font: TFont): String;
  procedure FontFromStr(Font: TFont; const sFont: String);

   // ����������� Charset � ������� ��������
  function  CharsetToCP(Charset: TFontCharset): Cardinal;
   // ����������� Ansi-������ � Unicode-������, ��������� ��������� ������� �������� � ��������
  function  AnsiToUnicodeCP(const s: AnsiString; cCodePage: Cardinal): WideString;
  function  UnicodeToAnsiCP(const s: WideString; cCodePage: Cardinal): AnsiString;

   // �������� ��������� �������� sReplaceChars � ������ s �� ������ cReplaceWith � ���������� ���������
  function  ReplaceChars(const s, sReplaceChars: String; cReplaceWith: Char): String;
   // ���������� ������ ����� �� ������ s, ������ �� ����������� ���� ����� �� �������� � sDelimiters. ���� �����������
   //   � ������ ���, ������������ ��� ������
  function  GetFirstWord(const s, sDelimiters: String): String;
   // ��������� � ���������� ������ ����� �� ������ s, ������ �� ����������� ���� ����� �� �������� � sDelimiters. ��
   //   ������ s ����� ������ � ������������ ���������. ���� ����������� � ������ ���, ������������ ��� ������
  function  ExtractFirstWord(var s: String; const sDelimiters: String): String;
   // ��������� � ������ s ������ sAdd. ���� ��� ��� �� ������, ����� ���� ����������� sSeparator
  procedure AccumulateStr(var s: String; const sSeparator, sAdd: String);
   // ������� ��������� ����� � ����� *��� ����� ��������* (��� ��� ������ �������� ������� ��������� � ������)
  function  ReverseCompare(const s1, s2: String): Boolean;
   // ����������� ������������� ���� � ����� � ����������, ��������� ������� ������� sBasePath
  function  ExpandRelativePath(const sBasePath, sRelFileName: String): String;
   // ���������� ������, �������������� ����� �������� ������� ����������� ����� ����� �����. ��������� ������ ���
   //   ����� ��������
  function  LongestCommonPart(const s1, s2: String): String;
   // ���������� ���� � �������� ��������� ������ Windows
  function  GetWindowsTempPath: String;

  function  iif(b: Boolean; const sTrue, sFalse: String): String; overload;
  function  iif(b: Boolean; iTrue, iFalse: Integer): Integer;     overload;
  function  iif(b: Boolean; pTrue, pFalse: Pointer): Pointer;     overload;
  function  iif(b: Boolean; sTrue, sFalse: Single): Single; overload;

   // ����������� ������ ����� � ������������� �����
  function  HumanReadableSize(i64Size: Int64): String; 

   // ��������� ���� ������, ��������������� �� ���� ���� (bTime=False) ��� ����� (bTime=True). � ������ ����� ���������
   //   �������� � dtResult � ���������� True, ����� ���������� ��������� �� ������ � ���������� False. ���� sText -
   //   ������ �����, �� � dtResult ������������ -1
  function  CheckMaskedDateTime(const sText: String; bTime: Boolean; var dtResult: TDateTime): Boolean;
   // �������� ����������� ������� � ������ � ���������� �. ��� bToSystem=False �������� ��������� ����������� ��
   //   AppFormatSettings.TimeSeparator, ��� bToSystem=True �������� AppFormatSettings.TimeSeparator �� ���������
   //   ����������� �������
  function  ChangeTimeSeparator(const sTime: String; bToSystem: Boolean): String;

   // ���������� �������������� �������� ��������� �� � ������������
  function  ConstVal(const sConstName: String): String; overload;
  function  ConstVal(const sConstName: String; const aParams: Array of const): String; overload;
   // ���������� sText, ���� �� ���������� �� ������, �������� �� '@'. ����� - �������� ����� ����� '@' ��� ���
   //   ��������� � ���������� � ��������
  function  ConstValEx(const sText: String): String;

   // �������������� TPicProperties <-> Integer
  function  PicPropsToInt(PicProps: TPicProperties): Integer;
  function  IntToPicProps(i: Integer): TPicProperties;
   // ���������� ������������ �������� �����������
  function  PicPropName(PicProp: TPicProperty): String;
   // �������������� TGroupProperties <-> Integer
  function  GroupPropsToInt(GroupProps: TGroupProperties): Integer;
  function  IntToGroupProps(i: Integer): TGroupProperties;
   // ���������� ������������ �������� ������
  function  GroupPropName(GroupProp: TGroupProperty): String;
   // ���������� ������������ �������� ����������� ��� �����������
  function  GroupByPropName(GBProp: TPicGroupByProperty): String;
   // ���������� ������������ ����������� ������� �����������
  function  PixelFormatName(PFmt: TPhoaPixelFormat): String;
   // ���������� ������������ ������� ��������� ������� �����
  function  FileSizeUnitName(FSUnit: TFileSizeUnit): String;
   // ���������� ������������ �������� ��������� �����
  function  DiskFilePropName(DFProp: TDiskFileProp): String;
   // ���������� �������� �������� ��������� ����� �� ������� TNamespace �����. ���� Namespace=nil, ���������� ������ ������
  function  DiskFilePropValue(DFProp: TDiskFileProp; Namespace: TNamespace): String;
   // ���������� ������������ �������� ��� �������������� ����/������� �����������
  function  DateTimeAutofillPropName(DTAProp: TDateTimeAutofillProp): String;
   // ���������� ����� ���������� �������������� ����/������� �����������
  function  DateTimeFillResultName(DTFResult: TDateTimeFillResult): String;

   // ��������� ��� ��������� �������, ������������ ��� � clWindow ��� clBtnFace ��������������
  procedure EnableWndCtl(Ctl: TWinControl; bEnable: Boolean);

   // ���������� ������ ���������� �����, ��� iDefault, ���� ������ ����� �� ����������
  function  GetFileSize(const sFileName: String; iDefault: Integer): Integer;

   // ��������� � Menu ����� �����
  function  AddTBXMenuItem(Menu: TTBCustomItem; const sCaption: String; iImageIndex, iTag: Integer; const AOnClick: TNotifyEvent): TTBCustomItem;

   // ���������� � �������� ����. ��� bScrollIntoView=True ����������� ������ ���, ����� �� ��� �����. ���������� True,
   //   ���� Node<>nil
  function  ActivateVTNode(Tree: TBaseVirtualTree; Node: PVirtualNode; bScrollIntoView: Boolean = True): Boolean;
   // ���������� ������ ���� � ������ (���� �� ����) � ������������� ��������� ����������� � ����� ������� ����
  procedure ActivateFirstVTNode(Tree: TBaseVirtualTree);
   // ���������� ���� ��������� �������� ������ �� ��������� �������. ���� ��� ������, ���������� nil
  function  GetVTRootNodeByIndex(Tree: TBaseVirtualTree; iIndex: Integer): PVirtualNode;
   // ����������/�������� �������� �������� VirtualTree
  procedure RegSaveVTColumns(const sSection: String; Tree: TVirtualStringTree);
  procedure RegLoadVTColumns(const sSection: String; Tree: TVirtualStringTree);
   // ������������� ����� coVisible ������� �������� bVisible
  procedure SetVTColumnVisible(Column: TVirtualTreeColumn; bVisible: Boolean);
   // ���������� VirtualTrees.TVTHintMode, ��������������q ��������� TGroupTreeHintMode
  function  GTreeHintModeToVTHintMode(GTHM: TGroupTreeHintMode): TVTHintMode;

   // ����������� ������ ��� ��� �����
  function  ShortenFileName(Canvas: TCanvas; iWidth: Integer; const s: String): String;

   // ���������� ��������� ����������� ���� ��� ��������� �����. ���������� True, ���� �������
  function  ShowFileShellContextMenu(const sFileName: String): Boolean;

   // �����/������� ������� HourGlass
  procedure StartWait;
  procedure StopWait;

implementation
uses
  Forms, TypInfo, Variants, Registry, ShellAPI, DKLang, phSettings, udMsgBox, phPhoa;

type
   //===================================================================================================================
   // TShellContextMenuManager - ����� ��� ��������� ��������� Shell Context Menu
   //===================================================================================================================

  TShellContextMenuManager = class(TCustomForm)
  private
     // ������ TNamespace, ��� �������� ������������ ����. ���������� ������ � ������� ������ ShowMenu()
    FNamespace: TNamespace;
  protected
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create; reintroduce;
     // ���������� ����������� ���� ��� �����. ���������� True, ���� ������
    function  ShowMenu(const sFileName: String): Boolean;
  end;

  constructor TShellContextMenuManager.Create;
  begin
    CreateNew(Application);
  end;

  function TShellContextMenuManager.ShowMenu(const sFileName: String): Boolean;
  begin
    Result := False;
    try
      try
        FNamespace := TNamespace.CreateFromFileName(sFileName);
      except
        PhoaError('SErrFileNotFoundFmt', [sFileName]);
      end;
      if FNamespace<>nil then Result := FNamespace.ShowContextMenu(Self, nil, nil, nil);
    finally
      FreeAndNil(FNamespace);
    end;
  end;

  procedure TShellContextMenuManager.WndProc(var Message: TMessage);
  begin
    inherited WndProc(Message);
    case Message.Msg of
       // �������������� ��������� ���� � Namespace
      WM_MEASUREITEM, WM_DRAWITEM, WM_INITMENUPOPUP, WM_MENUCHAR:
        if FNamespace<>nil then FNamespace.HandleContextMenuMsg(Message.Msg, Message.WParam, Message.LParam, Message.Result);
    end;
  end;

var
   // ��������� TShellContextMenuManager ��� ����������� ����������� ����. �������� ��� ������ ���������
  NS_MenuManager: TShellContextMenuManager = nil;

   //===================================================================================================================

  procedure PhoaException(const sMsg: String);

     function RetAddr: Pointer;
     asm
       mov eax, [ebp+4]
     end;

  begin
    raise EPhoaException.Create(sMsg) at RetAddr;
  end;

  procedure PhoaException(const sMsg: String; const aParams: Array of const);

     function RetAddr: Pointer;
     asm
       mov eax, [ebp+4]
     end;

  begin
    raise EPhoaException.CreateFmt(sMsg, aParams) at RetAddr;
  end;

  function Max(i1, i2: Integer): Integer;
  begin
    if i1>i2 then Result := i1 else Result := i2;
  end;

  function Min(i1, i2: Integer): Integer;
  begin
    if i1<i2 then Result := i1 else Result := i2;
  end;

  function MinS(s1, s2: Single): Single;
  begin
    if s1<s2 then Result := s1 else Result := s2;
  end;

  function MaxS(s1, s2: Single): Single;
  begin
    if s1>s2 then Result := s1 else Result := s2;
  end;

  function VarToInt(const v: Variant): Integer;
  begin
    if VarIsNull(v) then Result := 0 else Result := v;
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // History
   //-------------------------------------------------------------------------------------------------------------------

  procedure RegLoadHistory(const sSection: String; cb: TComboBox; bSetLastItem: Boolean);
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
      cb.Clear;
      for i := 0 to sl.Count-1 do cb.Items.Add(sl.ValueFromIndex[i]);
    finally
      sl.Free;
    end;
    with cb do
      if bSetLastItem and (Items.Count>0) then ItemIndex := 0;
  end;

  procedure RegSaveHistory(const sSection: String; cb: TComboBox; bRegisterFirst: Boolean);
  var i: Integer;
  begin
    if bRegisterFirst then RegisterCBHistory(cb);
    with TRegIniFile.Create(SRegRoot) do
      try
        EraseSection(sSection);
        for i := 0 to cb.Items.Count-1 do WriteString(sSection, 'Item'+IntToStr(i), cb.Items[i]);
      finally
        Free;
      end;
  end;

  procedure RegisterCBHistory(cb: TComboBox);
  var
    idx: Integer;
    s: String;
  begin
    s := Trim(cb.Text);
    if s<>'' then
      with cb.Items do begin
        idx := IndexOf(s);
        if idx>=0 then Delete(idx);
        Insert(0, s);
        while Count>IMaxHistoryEntries do Delete(IMaxHistoryEntries);
      end;
    cb.Text := s;
  end;

  function GetCurrentCBObject(ComboBox: TComboBox): Integer;
  var idx: Integer;
  begin
    idx := ComboBox.ItemIndex;
    if idx<0 then Result := -1 else Result := Integer(ComboBox.Items.Objects[idx]);
  end;

  function SetCurrentCBObject(ComboBox: TComboBox; iObj: Integer): Boolean;
  var idx: Integer;
  begin
    idx := ComboBox.Items.IndexOfObject(Pointer(iObj));
    ComboBox.ItemIndex := idx;
    Result := idx>=0;
  end;

  function Size(cx, cy: Integer): TSize;
  begin
    Result.cx := cx;
    Result.cy := cy;
  end;

  function  RectToStr(const r: TRect): String;
  begin
    Result := Format('%d,%d,%d,%d', [r.Left, r.Top, r.Right, r.Bottom]);
  end;

  function  StrToRect(const s: String; const rDefault: TRect): TRect;
  var ss: String;
  begin
    ss := s;
    try
      Result.Left   := StrToInt(ExtractFirstWord(ss, ','));
      Result.Top    := StrToInt(ExtractFirstWord(ss, ','));
      Result.Right  := StrToInt(ExtractFirstWord(ss, ','));
      Result.Bottom := StrToInt(ExtractFirstWord(ss, ','));
    except
      on EConvertError do Result := rDefault;
    end;
  end;

  function OrderRect(const r: TRect): TRect;
  begin
    if r.Left<r.Right then begin
      Result.Left   := r.Left;
      Result.Right  := r.Right;
    end else begin
      Result.Left   := r.Right;
      Result.Right  := r.Left;
    end;
    if r.Top<r.Bottom then begin
      Result.Top    := r.Top;
      Result.Bottom := r.Bottom;
    end else begin
      Result.Top    := r.Bottom;
      Result.Bottom := r.Top;
    end;
  end;

  function RectsOverlap(const r1, r2: TRect): Boolean;
  begin
    Result := (r1.Right>r2.Left) and (r1.Bottom>r2.Top) and (r2.Right>r1.Left) and (r2.Bottom>r1.Top);
  end;

  function GetRectIntersection(const r1, r2: TRect): TRect;
  begin
    IntersectRect(Result, r1, r2);
  end;
  
  function FormPositionToStr(const BoundsRect: TRect): String;
  begin
    Result := Format('%d,%d,%d,%d', [BoundsRect.Left, BoundsRect.Top, BoundsRect.Right, BoundsRect.Bottom]);
  end;

  function FormPositionFromStr(const sBounds: String; Constraints: TSizeConstraints; out BoundsRect: TRect): Boolean;
  var
    r, rScreen: TRect;
    iw, ih: Integer;
    s: String;

    function ConstrDef(iConstraint, iDefault: Integer): Integer;
    begin
      Result := iif(iConstraint=0, iDefault, iConstraint);
    end;

  begin
    s := sBounds;
    r.Left    := StrToIntDef(ExtractFirstWord(s, ','), MaxInt);
    r.Top     := StrToIntDef(ExtractFirstWord(s, ','), MaxInt);
    r.Right   := StrToIntDef(ExtractFirstWord(s, ','), MaxInt);
    r.Bottom  := StrToIntDef(ExtractFirstWord(s, ','), MaxInt);
     // ���� ��� ���������� ����������
    Result := (r.Left<MaxInt) and (r.Top<MaxInt) and (r.Right<MaxInt) and (r.Bottom<MaxInt);
    if Result then begin
      rScreen := Screen.WorkAreaRect;
       // ���������� ������ ��� �������������
      iw := Min(Min(Max(r.Right-r.Left, ConstrDef(Constraints.MinWidth,  10)), rScreen.Right-rScreen.Left), ConstrDef(Constraints.MaxWidth,  MaxInt));
      ih := Min(Min(Max(r.Bottom-r.Top, ConstrDef(Constraints.MinHeight, 10)), rScreen.Bottom-rScreen.Top), ConstrDef(Constraints.MaxHeight, MaxInt));
       // ������������ �������, ��� ������������� ��������� ���������
      BoundsRect := Bounds(
        Max(rScreen.Left, Min(rScreen.Right-iw,  r.Left)),
        Max(rScreen.Top,  Min(rScreen.Bottom-ih, r.Top)),
        iw,
        ih);
     // ����� ������� BoundsRect
    end else
      FillChar(BoundsRect, SizeOf(BoundsRect), 0);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // Fonts / chars
   //-------------------------------------------------------------------------------------------------------------------

  function FontToStr(Font: TFont): String;
  begin
    with Font do Result := Format('%s/%d/%d/%d/%d', [Name, Size, Byte(Style), Color, Charset]);
  end;

  procedure FontFromStr(Font: TFont; const sFont: String);
  var s: String;
  begin
    s := sFont;
    with Font do begin
      Name    := ExtractFirstWord(s, '/');
      Size    := StrToIntDef(ExtractFirstWord(s, '/'), 10);
      Style   := TFontStyles(Byte(StrToIntDef(ExtractFirstWord(s, '/'), 0)));
      Color   := StrToIntDef(ExtractFirstWord(s, '/'), 0);
      Charset := StrToIntDef(ExtractFirstWord(s, '/'), DEFAULT_CHARSET);
    end;
  end;

  function CharsetToCP(Charset: TFontCharset): Cardinal;
  begin
    case Charset of
      VIETNAMESE_CHARSET,
        ANSI_CHARSET:      Result := 1252; // Windows 3.1 Latin 1 (US, Western Europe) or Vietnam
      SHIFTJIS_CHARSET:    Result := 932;  // Japan
      HANGEUL_CHARSET,
        JOHAB_CHARSET:     Result := 949;  // Korean
      GB2312_CHARSET:      Result := 936;  // Chinese (PRC, Singapore)
      CHINESEBIG5_CHARSET: Result := 950;  // Chinese (Taiwan, Hong Kong)
      HEBREW_CHARSET:      Result := 1255; // Hebrew
      ARABIC_CHARSET:      Result := 1256; // Arabic
      GREEK_CHARSET:       Result := 1253; // Windows 3.1 Greek
      TURKISH_CHARSET:     Result := 1254; // Windows 3.1 Turkish
      THAI_CHARSET:        Result := 874;  // Thai
      EASTEUROPE_CHARSET:  Result := 1250; // Windows 3.1 Eastern European
      RUSSIAN_CHARSET:     Result := 1251; // Windows 3.1 Cyrillic
      BALTIC_CHARSET:      Result := 1257; // Baltic
      SYMBOL_CHARSET:      Result := CP_SYMBOL;
      MAC_CHARSET:         Result := CP_MACCP;
      OEM_CHARSET:         Result := CP_OEMCP;
      else                 Result := CP_ACP;
    end;
  end;

  function AnsiToUnicodeCP(const s: AnsiString; cCodePage: Cardinal): WideString;
  var iLen: Integer;
  begin
    iLen := Length(s);
    SetLength(Result, iLen);
    MultiByteToWideChar(cCodePage, 0, @s[1], iLen, @Result[1], iLen);
  end;

  function UnicodeToAnsiCP(const s: WideString; cCodePage: Cardinal): AnsiString;
  var iLen: Integer;
  begin
    iLen := Length(s);
    SetLength(Result, iLen);
    WideCharToMultiByte(cCodePage, 0, @s[1], iLen, @Result[1], iLen, nil, nil);
  end;

   //-------------------------------------------------------------------------------------------------------------------
   // Misc
   //-------------------------------------------------------------------------------------------------------------------

  function ReplaceChars(const s, sReplaceChars: String; cReplaceWith: Char): String;
  var i: Integer;
  begin
    Result := s;
    for i := 1 to Length(Result) do
      if StrScan(PChar(sReplaceChars), Result[i])<>nil then Result[i] := cReplaceWith;
  end;

  function GetFirstWord(const s, sDelimiters: String): String;
  var i: Integer;
  begin
    i := 1;
    while (i<=Length(s)) and (Pos(s[i], sDelimiters)=0) do Inc(i);
    Result := Copy(s, 1, i-1);
  end;

  function ExtractFirstWord(var s: String; const sDelimiters: String): String;
  begin
    Result := GetFirstWord(s, sDelimiters);
    Delete(s, 1, Length(Result)+1);
  end;

  procedure AccumulateStr(var s: String; const sSeparator, sAdd: String);
  begin
    s := s+iif((s='') or (sAdd=''), '', sSeparator)+sAdd;
  end;

  function ReverseCompare(const s1, s2: String): Boolean;
  const acUpTable: Array[Char] of Char =
    #0#1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17#18#19#20#21#22#23#24#25#26#27#28#29#30#31+
    ' !"#$%&''()*+,-./0123456789:;<=>?'+
    '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_'+
    '`ABCDEFGHIJKLMNOPQRSTUVWXYZ{|}~'#127+
    '��������������������������������'+
    '��������������������������������'+
    '��������������������������������'+
    '��������������������������������';
  var i: Integer;
  begin
    Result := False;
    i := Length(s1);
    if i<>Length(s2) then Exit;
    for i := i downto 1 do
      if acUpTable[s1[i]]<>acUpTable[s2[i]] then Exit;
    Result := True;
  end;

  function ExpandRelativePath(const sBasePath, sRelFileName: String): String;
  var
    i: Integer;
    sOneDir, sRelName: String;
  begin
    if sRelFileName='' then
      Result := ''
    else begin
      sRelName := sRelFileName;
       // ���� ���� �������� � ���� ���� (���������� ����)
      if (Pos(':', sRelName)>0) or (Pos('\\', sRelName)>0) then
        Result := sRelName
       // ����� - ������������� ����
      else begin
         // ���� ���������� �� '\' - ��� � �����
        Result := sBasePath;
        if (Result<>'') and (Result[Length(Result)]='\') then Delete(Result, Length(Result), 1);
        if sRelName[1]='\' then
          Result := Copy(Result, 1, 3)+Copy(sRelName, 2, MaxInt)
         // ����� - � �������� �����
        else begin
          repeat
            i := Pos('\', sRelName);
            if i=0 then Break;
            sOneDir := Copy(sRelName, 1, i);
            Delete(sRelName, 1, i);
            if sOneDir='..\' then begin
              i := LastDelimiter('\', Result);
              if i=0 then PhoaException(ConstVal('SErrInvalidPicFileName'), [sRelFileName]);
              Delete(Result, i, MaxInt);
            end else
              Result := Result+'\'+Copy(sOneDir, 1, Length(sOneDir)-1);
          until False;
          Result := Result+'\'+sRelName;
        end;
      end;
    end;
  end;

  function LongestCommonPart(const s1, s2: String): String;
  var
    sUp1, sUp2: String;
    i: Integer;
  begin
    sUp1 := AnsiUpperCase(s1);
    sUp2 := AnsiUpperCase(s2);
    Result := '';
    i := 1;
    while (i<=Length(sUp1)) and (i<=Length(sUp2)) and (sUp1[i]=sUp2[i]) do begin
      Result := Result+s1[i];
      Inc(i);
    end;
  end;

  function GetWindowsTempPath: String;
  var aBuf: Array[0..MAX_PATH] of Char;
  begin
    GetTempPath(MAX_PATH, aBuf);
    Result := IncludeTrailingPathDelimiter(aBuf);
  end;

  function iif(b: Boolean; const sTrue, sFalse: String): String;
  begin
    if b then Result := sTrue else Result := sFalse;
  end;

  function iif(b: Boolean; iTrue, iFalse: Integer): Integer;
  begin
    if b then Result := iTrue else Result := iFalse;
  end;

  function iif(b: Boolean; pTrue, pFalse: Pointer): Pointer;
  begin
    if b then Result := pTrue else Result := pFalse;
  end;

  function iif(b: Boolean; sTrue, sFalse: Single): Single;
  begin
    if b then Result := sTrue else Result := sFalse;
  end;

  function HumanReadableSize(i64Size: Int64): String;
  begin
    case i64Size of
      0..1023:             Result := ConstVal('SSizeBytes',  [i64Size]);
      1024..1048575:       Result := ConstVal('SSizeKBytes', [i64Size/1024]);
      1048576..1073741823: Result := ConstVal('SSizeMBytes', [i64Size/1048576]);
      else                 Result := ConstVal('SSizeGBytes', [i64Size/1073741824]);
    end;
  end;

  function CheckMaskedDateTime(const sText: String; bTime: Boolean; var dtResult: TDateTime): Boolean;
  begin
    Result := True;
     // ���� �� ������� �� ����� ����� - ������, ����� �� ����
    if LastDelimiter('0123456789', sText)=0 then
      dtResult := -1
    else begin
      if bTime then
        Result := TryStrToTime(ChangeTimeSeparator(sText, False), dtResult, AppFormatSettings)
      else
        Result := TryStrToDate(sText, dtResult, AppFormatSettings);
      if not Result then PhoaError(iif(bTime, 'SNotAValidTime', 'SNotAValidDate'), [sText]);
    end;
  end;

  function ChangeTimeSeparator(const sTime: String; bToSystem: Boolean): String;
  var
    i: Integer;
    cFrom, cTo: Char;
  begin
    Result := sTime;
     // ����������, ��� �� ��� ����� ��������
    if bToSystem then begin
      cFrom := AppFormatSettings.TimeSeparator;
      cTo   := TimeSeparator;
    end else begin
      cFrom := TimeSeparator;
      cTo   := AppFormatSettings.TimeSeparator;
    end;
     // ��������� ��� ������� ������ � �������
    for i := 1 to Length(Result) do
      if Result[i]=cFrom then Result[i] := cTo; 
  end;

  function ConstVal(const sConstName: String): String;
  begin
    Result := LangManager.ConstantValue[sConstName];
  end;

  function ConstVal(const sConstName: String; const aParams: Array of const): String;
  begin
    Result := Format(LangManager.ConstantValue[sConstName], aParams);
  end;

  function ConstValEx(const sText: String): String;
  begin
    Result := sText;
     // ���� ������������ ���������� �� '@' - ��� ���������
    if (Result<>'') and (Result[1]='@') then Result := ConstVal(Copy(Result, 2, MaxInt));
  end;

  function PicPropsToInt(PicProps: TPicProperties): Integer;
  begin
    Result := 0;
    Move(PicProps, Result, SizeOf(PicProps));
  end;

  function IntToPicProps(i: Integer): TPicProperties;
  begin
    Move(i, Result, SizeOf(Result));
  end;

  function PicPropName(PicProp: TPicProperty): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TPicProperty), Byte(PicProp)));
  end;

  function GroupPropsToInt(GroupProps: TGroupProperties): Integer;
  begin
    Result := 0;
    Move(GroupProps, Result, SizeOf(GroupProps));
  end;

  function IntToGroupProps(i: Integer): TGroupProperties;
  begin
    Move(i, Result, SizeOf(Result));
  end;

  function GroupPropName(GroupProp: TGroupProperty): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TGroupProperty), Byte(GroupProp)));
  end;

  function GroupByPropName(GBProp: TPicGroupByProperty): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TPicGroupByProperty), Byte(GBProp)));
  end;

  function PixelFormatName(PFmt: TPhoaPixelFormat): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TPhoaPixelFormat), Byte(PFmt)));
  end;

  function FileSizeUnitName(FSUnit: TFileSizeUnit): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TFileSizeUnit), Byte(FSUnit)));
  end;

  function DiskFilePropName(DFProp: TDiskFileProp): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TDiskFileProp), Byte(DFProp)));
  end;

  function DiskFilePropValue(DFProp: TDiskFileProp; Namespace: TNamespace): String;
  const asBoolPropVals: Array[Boolean] of String = (' ', '�');
  begin
    Result := '';
    if Namespace<>nil then
      with Namespace do
        case DFProp of
          dfpFileName:            Result := FileName;
          dfpFileType:            Result := FileType;
          dfpSizeOfFile:          Result := Format('%s (%s)', [SizeOfFile, SizeOfFileKB]);
          dfpSizeOfFileDiskUsage: Result := SizeOfFileDiskUsage;
          dfpCreationTime:        Result := CreationTime;
          dfpLastWriteTime:       Result := LastWriteTime;
          dfpLastAccessTime:      Result := LastAccessTime;
          dfpReadOnlyFile:        Result := asBoolPropVals[ReadOnlyFile];
          dfpHidden:              Result := asBoolPropVals[Hidden];
          dfpArchive:             Result := asBoolPropVals[Archive];
          dfpCompressed:          Result := asBoolPropVals[Compressed];
          dfpSystemFile:          Result := asBoolPropVals[SystemFile];
          dfpTemporary:           Result := asBoolPropVals[Temporary];
        end;
  end;

  function DateTimeAutofillPropName(DTAProp: TDateTimeAutofillProp): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TDateTimeAutofillProp), Byte(DTAProp)));
  end;

  function DateTimeFillResultName(DTFResult: TDateTimeFillResult): String;
  begin
    Result := ConstVal(GetEnumName(TypeInfo(TDateTimeFillResult), Byte(DTFResult)));
  end;

  procedure EnableWndCtl(Ctl: TWinControl; bEnable: Boolean);
  var pi: PPropInfo;
  begin
    if not (csDestroying in Ctl.ComponentState) then Ctl.HandleNeeded; // Workaround ComboBoxEx's repaint bug
    Ctl.Enabled := bEnable;
    pi := GetPropInfo(Ctl, 'Color', [tkInteger]);
    if pi<>nil then SetOrdProp(Ctl, pi, iif(bEnable, clWindow, clBtnFace));
  end;

  function GetFileSize(const sFileName: String; iDefault: Integer): Integer;
  var
    hF: THandle;
    FindData: TWin32FindData;
  begin
    hF := FindFirstFile(PChar(sFileName), FindData);
    if hF<>INVALID_HANDLE_VALUE then begin
      Windows.FindClose(hF);
      Result := FindData.nFileSizeLow;
    end else
      Result := iDefault;
  end;

  function  AddTBXMenuItem(Menu: TTBCustomItem; const sCaption: String; iImageIndex, iTag: Integer; const AOnClick: TNotifyEvent): TTBCustomItem;
  begin
    Result := TTBXItem.Create(Menu.Owner);
    Result.Caption    := sCaption;
    Result.ImageIndex := iImageIndex;
    Result.Tag        := iTag;
    Result.OnClick    := AOnClick;
    Menu.Add(Result);
  end;

  function ActivateVTNode(Tree: TBaseVirtualTree; Node: PVirtualNode; bScrollIntoView: Boolean = True): Boolean;
  begin
    Result := Node<>nil;
    Tree.BeginUpdate;
    try
      Tree.ClearSelection;
      Tree.FocusedNode := Node;
      if Result then begin
        Tree.Selected[Node] := True;
        if bScrollIntoView then Tree.ScrollIntoView(Node, False, False);
      end;
    finally
      Tree.EndUpdate;
    end;
  end;

  procedure ActivateFirstVTNode(Tree: TBaseVirtualTree);
  begin
    Tree.BeginUpdate;
    try
      ActivateVTNode(Tree, Tree.GetFirst, False);
      Tree.OffsetXY := Point(0, 0);
    finally
      Tree.EndUpdate;
    end;
  end;

  function GetVTRootNodeByIndex(Tree: TBaseVirtualTree; iIndex: Integer): PVirtualNode;
  begin
    if iIndex<0 then
      Result := nil
    else begin
      Result := Tree.GetFirst;
      while (Result<>nil) and (Integer(Result.Index)<iIndex) do Result := Tree.GetNextSibling(Result);
    end;
  end;
  
  procedure RegSaveVTColumns(const sSection: String; Tree: TVirtualStringTree);
  var
    i: Integer;
    c: TVirtualTreeColumn;
  begin
    with TRegIniFile.Create(SRegRoot) do
      try
        for i := 0 to Tree.Header.Columns.Count-1 do begin
          c := Tree.Header.Columns[i];
          WriteString(sSection, 'Column'+IntToStr(i), Format('%d,%d,%d', [c.Position, c.Width, Byte(coVisible in c.Options)]));
        end;
      finally
        Free;
      end;
  end;

type
  TVTColumnsCast = class(TVirtualTreeColumns);

  procedure RegLoadVTColumns(const sSection: String; Tree: TVirtualStringTree);
  var
    i: Integer;
    c: TVirtualTreeColumn;
    s: String;
  begin
    with TRegIniFile.Create(SRegRoot) do
      try
        for i := 0 to Tree.Header.Columns.Count-1 do begin
          c := Tree.Header.Columns[i];
          s := ReadString(sSection, 'Column'+IntToStr(i), '');
          c.Position := StrToIntDef(ExtractFirstWord(s, ','), c.Position);
          c.Width    := StrToIntDef(ExtractFirstWord(s, ','), c.Width);
          SetVTColumnVisible(c, StrToIntDef(ExtractFirstWord(s, ','), Byte(coVisible in c.Options))<>0);
        end;
    finally
      Free;
    end;
  end;

  procedure SetVTColumnVisible(Column: TVirtualTreeColumn; bVisible: Boolean);
  begin
    with Column do
      if bVisible then Options := Options+[coVisible] else Options := Options-[coVisible];
  end;

  function GTreeHintModeToVTHintMode(GTHM: TGroupTreeHintMode): TVTHintMode;
  const
    aHM: Array[TGroupTreeHintMode] of TVTHintMode = (
      hmDefault, // gthmNone
      hmTooltip, // gthmTips
      hmHint);   // gthmInfo
  begin
    Result := aHM[GTHM];
  end;

  function ShortenFileName(Canvas: TCanvas; iWidth: Integer; const s: String): String;
  var
    aBuf: Array[0..1024] of Char;
    r: TRect;
  begin
    StrPCopy(aBuf, s);
    r := Rect(0, 0, iWidth, 0);
    DrawText(Canvas.Handle, aBuf, -1, r, DT_LEFT or DT_PATH_ELLIPSIS or DT_MODIFYSTRING);
    Result := aBuf;
  end;

  function ShowFileShellContextMenu(const sFileName: String): Boolean;
  begin
     // ������ ��������� NS_MenuManager, ���� �� ��� �� ������
    if NS_MenuManager=nil then NS_MenuManager := TShellContextMenuManager.Create;
     // ���������� ����
    Result := NS_MenuManager.ShowMenu(sFileName);
  end;

var
  iWaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;

  procedure StartWait;
  begin
    if iWaitCount=0 then begin
      SaveCursor := Screen.Cursor;
      Screen.Cursor := crHourGlass;
    end;
    Inc(iWaitCount);
  end;

  procedure StopWait;
  begin
    if iWaitCount>0 then begin
      Dec(iWaitCount);
      if iWaitCount=0 then Screen.Cursor := SaveCursor;
    end;
  end;

end.

