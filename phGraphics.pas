//**********************************************************************************************************************
//  $Id: phGraphics.pas,v 1.20 2005-06-05 16:36:55 dale Exp $
//----------------------------------------------------------------------------------------------------------------------
//  PhoA image arranging and searching tool
//  Copyright DK Software, http://www.dk-soft.org/
//**********************************************************************************************************************
unit phGraphics;

interface
uses Windows, SysUtils, Classes, Graphics, GR32, ConsVars, phIntf, phMutableIntf, phNativeIntf;

type
   // ���������� ��� ���������� �������� �����������
  ELoadGraphicAborted = class(EAbort);

   // �������� ����� ������ ��������� ������ (���� -> �����)
  TChannelByteMap = Array[Byte] of Byte;

   //===================================================================================================================
   // ����� ������ �� �������
   //===================================================================================================================

  TColor32Map = class(TObject)
  private
     // Prop storage
    FMapA: TChannelByteMap;
    FMapG: TChannelByteMap;
    FMapR: TChannelByteMap;
    FMapB: TChannelByteMap;
     // ��������� ������ ��������� ����������
    procedure ChannelBuildLinear(var Map: TChannelByteMap);
     // ��������� ������ ����������
    procedure ChannelBuildConstant(var Map: TChannelByteMap; bValue: Byte);
  public
    constructor Create;
     // ��������� ������ ��������� ����������
    procedure BuildLinear;
     // ��������� ����� � ���������� �����
    function  ApplyToColor(c: TColor32): TColor32;
     // Props
     // -- ����� �������
    property MapR: TChannelByteMap read FMapR;
    property MapG: TChannelByteMap read FMapG;
    property MapB: TChannelByteMap read FMapB;
    property MapA: TChannelByteMap read FMapA;
  end;

   //===================================================================================================================
   // �������������� ����������� (����� ���������� ��������������)
   //===================================================================================================================

  TPicTransform = class(TObject)
  private
     // ������� ���������� ���������� ��������������
    FApplyLock: Integer;
     // ��������� ���������� [����������] �������� ��������
    FAppliedRotation: TPicRotation;
     // ��������� ���������� [����������] �������� ���������
    FAppliedFlips: TPicFlips;
     // Prop storage
    FBitmap: TBitmap32;
    FFlips: TPicFlips;
    FRotation: TPicRotation;
    FOnApplied: TNotifyEvent;
     // ������������ ����������� �� ARotation � �������� � ������������ ������� AFlips
    procedure ApplyRelativeTransform(ARotation: TPicRotation; AFlips: TPicFlips);
     // ��������� �������������� � �����������
    procedure ApplyTransform;
     // Prop handlers
    procedure SetFlips(Value: TPicFlips);
    procedure SetRotation(Value: TPicRotation);
  public
    constructor Create(ABitmap: TBitmap32);
     // ���������/������ ���������� ����������
    procedure BeginUpdate;
    procedure EndUpdate;
     // �������������� �������� ��� �������� (�.�. ��������������� �������� ��������� Bitmap)
    procedure InitValues(ARotation: TPicRotation; AFlips: TPicFlips);
     // ��������� �������� �������������� ������������
    procedure ApplyValues(ARotation: TPicRotation; AFlips: TPicFlips);
     // ����������� ���� �� ������ ���������
    procedure ToggleFlip(Flip: TPicFlip);
     // Props
     // -- �����������, � �������� ����������� ��������������
    property Bitmap: TBitmap32 read FBitmap;
     // -- ��������� ����������� ������������ ���������
    property Flips: TPicFlips read FFlips write SetFlips;
     // -- ������� ����������� ������������ ���������
    property Rotation: TPicRotation read FRotation write SetRotation;
     // -- ������� ���������� ��������������
    property OnApplied: TNotifyEvent read FOnApplied write FOnApplied;
  end;

   // ������������ �� Bitmap ����-��������� ���� � alpha-�������
  procedure RenderShadowTemplate(Bitmap: TBitmap32; iRadius: Integer; bOpacity: Byte; Color: TColor);
   // ������ �� Target ���� �� ��������� ShadowTemplate ��� �������������� rObject
  procedure DropShadow(Target, ShadowTemplate: TBitmap32; const rObject, rClipOuter: TRect; iOffsetX, iOffsetY: Integer; Color: TColor);

   // ��������� ���� � ������ ����������� ����� �� ThumbBitmap
  procedure MakeThumbnail(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; out ImageSize, ThumbSize: TSize; ThumbBitmap: TBitmap32);
   // ��������� ����, ������ ����� � ���������� ��� ������ � ���� �������� ������ � ������� JPEG
  function  GetThumbnailData(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; bJPEGQuality: Byte; out ImageSize, ThumbSize: TSize): String;
   // �� ��, �� � ������� 32-bit bitmap
  function  GetBmp32ThumbnailData(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; out ImageSize, ThumbSize: TSize): String;
   // ������������ ����� �� ������� � �������� ��������������. � r ���������� ���������� �������������� ��� ���������
   //   �������������
  procedure PaintThumbnail(const sThumbnailData: String; Rotation: TPicRotation; Flips: TPicFlips; Bitmap32: TBitmap32; var r: TRect); overload;
  procedure PaintThumbnail(Pic: IPhoaPic; Bitmap32: TBitmap32; var r: TRect); overload;
  procedure PaintThumbnail(Pic: IPhoaPic; Bitmap32: TBitmap32); overload;
   // ������������ Bitmap32-������ �� ������� � �������� �������
  procedure PaintBmp32Data(const sBmpData: String; Bitmap32: TBitmap32; const p: TPoint);
   // ������������ ������ ������ �� ������� � �������� �������
  procedure PaintGroupIcon(const sBmpData: String; Bitmap32: TBitmap32; const p: TPoint; bSelected: Boolean; App: IPhotoAlbumApp); overload;
  procedure PaintGroupIcon(const sBmpData: String; DC: HDC; const p: TPoint; bSelected: Boolean; App: IPhotoAlbumApp); overload;

   // ������, ��������� �����������, � ���������� ��������������� � TBitmap32 �����������
  procedure LoadGraphicFromFile(const sFileName: String; Bitmap32: TBitmap32; const DesiredSize: TSize; out FullSize: TSize; const OnProgress: TProgressEvent);

const
  BColor_Alpha_Transparent = $00;
  BColor_Alpha_Opaque      = $ff;

implementation
uses JPEG, Math, CommCtrl, GraphicEx, phUtils, phIJLIntf;

  procedure RenderShadowTemplate(Bitmap: TBitmap32; iRadius: Integer; bOpacity: Byte; Color: TColor);
  var
    iSize, ix, iy, iy2: Integer;
    c32: TColor32;
    sAlpha, sCoeff: Single;
    bAlpha: Byte;

     // �������� "�����������" ����������� �� ����������� �/��� ���������
    procedure MirrorQuarter(ixq, iyq: Integer; bHorz, bVert: Boolean);
    var
      ixSrc, iySrc: Integer;
      pSrc, pTgt: PColor32;
    begin
       // ���� �� �������
      for iySrc := iyq to iyq+iRadius-1 do begin
         // ���������� ������ ������� � ������ �����: �������� � �������
        pSrc := Bitmap.PixelPtr[ixq, iySrc];
        pTgt := Bitmap.PixelPtr[iif(bHorz, iSize-ixq, ixq), iif(bVert, iSize-iySrc, iySrc)];
         // ������������ ������� ������ � �����
        for ixSrc := ixq to ixq+iRadius-1 do begin
          pTgt^ := pSrc^;
          Inc(pSrc);
          if bHorz then Dec(pTgt) else Inc(pTgt);
        end;
      end;
    end;

    // +---+---+
    // | 0 | 1 |
    // +---+---+
    // | 2 | 3 |
    // +---+---+

  begin
    iSize := iRadius*2;
    c32 := Color32(Color);
     // ������������� ��������� �������
    Bitmap.SetSize(iSize, iSize);
    Bitmap.DrawMode    := dmBlend;
    Bitmap.MasterAlpha := bOpacity;
     // �������� ������� (3)
    sCoeff := 1/Sqr(iRadius)*Ln(0.013);
    for iy := 0 to iRadius-1 do begin
       // ������� ������� ������� iy
      iy2 := Sqr(iy);
      for ix := 0 to iRadius-1 do begin
        sAlpha := Exp(sCoeff*(Sqr(ix)+iy2)); // ������� �������� �������������� � ��������� 0..1
        if sAlpha<0 then bAlpha := 0 else bAlpha := Trunc(255*sAlpha);
        Bitmap.SetPixelT(iRadius+ix, iRadius+iy, SetAlpha(c32, bAlpha));
      end;
    end;
     // �������� ���� � ��������� ����
    MirrorQuarter(iRadius, iRadius, False, True);  // (1)
    MirrorQuarter(iRadius, iRadius, True,  False); // (2)
    MirrorQuarter(iRadius, iRadius, True,  True);  // (0)
  end;

  procedure DropShadow(Target, ShadowTemplate: TBitmap32; const rObject, rClipOuter: TRect; iOffsetX, iOffsetY: Integer; Color: TColor);
  var
    r, rTotal, rQuarter, rQuarterMargins: TRect;
    iRadius: Integer;
    BMPObject: TBitmap32;

     // ������ ������� ���� ������� � iRadius � ������� � r, ������� � ������������ ���������� iy (������� ���� �
     //   ������� � ������������ ���������� iyTempl)
    procedure DrawHShadow(iy, iyTempl: Integer);
    var
      i: Integer;
      c: TColor32;
    begin
      for i := 0 to iRadius-1 do begin
        c := ShadowTemplate[iRadius, iyTempl];
        Target.HorzLineTS(r.Left, iy, r.Right-1, SetAlpha(c, Trunc(AlphaComponent(c)*Integer(ShadowTemplate.MasterAlpha)/255)));
        Inc(iy);
        Inc(iyTempl);
      end;
    end;

     // ������ ������� ���� ������� � iRadius � ������� � r, ������� � �������������� ���������� ix (������� ���� �
     //   ������� � �������������� ���������� ixTempl)
    procedure DrawVShadow(ix, ixTempl: Integer);
    var
      i: Integer;
      c: TColor32;
    begin
      for i := 0 to iRadius-1 do begin
        c := ShadowTemplate[ixTempl, iRadius];
        Target.VertLineTS(ix, r.Top, r.Bottom-1, SetAlpha(c, Trunc(AlphaComponent(c)*Integer(ShadowTemplate.MasterAlpha)/255)));
        Inc(ix);
        Inc(ixTempl);
      end;
    end;

     // ��������� ������� "�����������" ����, ���� �����. ������ "���������" ������� ������ 0
    procedure CalcQuarterBounds(iSolidSize: Integer; var iLowBound, iHighBound: Integer);
    var iDelta: Integer;
    begin
      if iSolidSize<0 then begin
        iDelta := iSolidSize div 2; // iDelta<=0 !
        Inc(iLowBound,  iDelta);
        Dec(iHighBound, iSolidSize-iDelta); // ��� �����������, ��� � ����� ������� ����� iSolidSize
      end;
    end;

  begin
     // ��������� ������ �� ��������� ������
    BMPObject := TBitmap32.Create;
    try
      BMPObject.SetSize(rObject.Right-rObject.Left, rObject.Bottom-rObject.Top);
      BMPObject.Draw(0, 0, rObject, Target);
       // ��������� �������� ������ ���� �� 1/3 ������� � ������� ���� (������ ������������ �������)
      iRadius := ShadowTemplate.Width div 2;
      r := rObject;
      with r do begin
        Inc(Left,   iOffsetX+iRadius div 3);
        Inc(Top,    iOffsetY+iRadius div 3);
        Inc(Right,  iOffsetX-iRadius div 3);
        Inc(Bottom, iOffsetY-iRadius div 3);
      end;
       // ������ �������� ���� �������
      Target.FillRectTS(r, SetAlpha(Color32(Color), ShadowTemplate.MasterAlpha));
       // ���������� ������� "�����������" (��� >0, ���� ������/������ "���������" ������� ������ 0)
      FillChar(rQuarterMargins, SizeOf(rQuarterMargins), 0);
      CalcQuarterBounds(r.Right-r.Left, rQuarterMargins.Left, rQuarterMargins.Right);
      CalcQuarterBounds(r.Bottom-r.Top, rQuarterMargins.Top,  rQuarterMargins.Bottom);
       // ������� ����� ������� ���� ����
      rTotal := r;
      InflateRect(rTotal, iRadius, iRadius);
       // ������ ���� ����
       // -- Top left
      rQuarter := Rect(0, 0, iRadius, iRadius);
      Dec(rQuarter.Bottom, rQuarterMargins.Bottom);
      Dec(rQuarter.Right,  rQuarterMargins.Right);
      Target.Draw(rTotal.Left, rTotal.Top, rQuarter, ShadowTemplate);
      Inc(rQuarter.Right,  rQuarterMargins.Right);
       // -- Top right
      OffsetRect(rQuarter, iRadius, 0);
      Dec(rQuarter.Left,   rQuarterMargins.Left);
      Target.Draw(rTotal.Right-(rQuarter.Right-rQuarter.Left), rTotal.Top, rQuarter, ShadowTemplate);
      Inc(rQuarter.Left,   rQuarterMargins.Left);
      Inc(rQuarter.Bottom, rQuarterMargins.Bottom);
       // -- Bottom right
      OffsetRect(rQuarter, 0, iRadius);
      Dec(rQuarter.Top,  rQuarterMargins.Top);
      Dec(rQuarter.Left, rQuarterMargins.Left);
      Target.Draw(rTotal.Right-(rQuarter.Right-rQuarter.Left), rTotal.Bottom-(rQuarter.Bottom-rQuarter.Top), rQuarter, ShadowTemplate);
      Inc(rQuarter.Left, rQuarterMargins.Left);
       // -- Bottom left
      OffsetRect(rQuarter, -iRadius, 0);
      Dec(rQuarter.Right, rQuarterMargins.Right);
      Target.Draw(rTotal.Left, rTotal.Bottom-(rQuarter.Bottom-rQuarter.Top), rQuarter, ShadowTemplate);
      Inc(rQuarter.Right, rQuarterMargins.Right);
      Inc(rQuarter.Top,   rQuarterMargins.Top);
       // ������ ������� ���� ����� ������
      if r.Right>r.Left then begin
        DrawHShadow(rTotal.Top,  0);
        DrawHShadow(r.Bottom,    iRadius);
      end;
      if r.Bottom>r.Top then begin
        DrawVShadow(rTotal.Left, 0);
        DrawVShadow(r.Right,     iRadius);
      end;
       // ��������� ����������� ������� �������
      Target.Draw(rObject.Left, rObject.Top, BMPObject);
    finally
      BMPObject.Free;
    end;
  end;

  procedure MakeThumbnail(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; out ImageSize, ThumbSize: TSize; ThumbBitmap: TBitmap32);
  const
     // ������� ������������� TPhoaStretchFilter -> GR32.TStretchFilter
    aPhoaSFtoGR32SF: Array[TPhoaStretchFilter] of GR32.TStretchFilter = (
      GR32.sfNearest, GR32.sfDraft, GR32.sfLinear, GR32.sfCosine, GR32.sfSpline, GR32.sfLanczos, GR32.sfMitchell);
  var
    sScale: Single;
    LargeBitmap: TBitmap32;
  begin
    LargeBitmap := TBitmap32.Create;
    try
      LoadGraphicFromFile(sFileName, LargeBitmap, MaxSize, ImageSize, nil);
      LargeBitmap.StretchFilter := aPhoaSFtoGR32SF[StretchFilter];
       // ���������� ����������� ���������������
      if (ImageSize.cx>0) and (ImageSize.cy>0) then sScale := MinS(MinS(MaxSize.cx/ImageSize.cx, MaxSize.cy/ImageSize.cy), 1) else sScale := 1;
       // ������������ �����������
      ThumbSize.cx := Max(Trunc(ImageSize.cx*sScale), 1);
      ThumbSize.cy := Max(Trunc(ImageSize.cy*sScale), 1);
      ThumbBitmap.SetSize(ThumbSize.cx, ThumbSize.cy);
      LargeBitmap.DrawTo(ThumbBitmap, ThumbBitmap.BoundsRect);
    finally
      LargeBitmap.Free;
    end;
  end;

  function GetThumbnailData(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; bJPEGQuality: Byte; out ImageSize, ThumbSize: TSize): String;
  var
    ThumbBitmap: TBitmap32;
    Stream: TStringStream;
    bmp: TBitmap;
  begin
     // ������������ �����������
    ThumbBitmap := TBitmap32.Create;
    try
       // ��������� ����������� ������ �������� � ThumbBitmap
      MakeThumbnail(sFileName, MaxSize, StretchFilter, ImageSize, ThumbSize, ThumbBitmap);
       // ����������� TBitmap32 � TBitmap
      bmp := TBitmap.Create;
      try
        bmp.Assign(ThumbBitmap);
         // ����������� TBitmap � TJPEGImage
        with TJPEGImage.Create do
          try
             // �������� �����
            Assign(bmp);
             // �������
            CompressionQuality := bJPEGQuality;
            Compress;
             // ��������� ����� � �����
            Stream := TStringStream.Create('');
            try
              SaveToStream(Stream);
              Result := Stream.DataString;
            finally
              Stream.Free;
            end;
          finally
            Free;
          end;
      finally
        bmp.Free;
      end;
    finally
      ThumbBitmap.Free;
    end;
  end;

  function GetBmp32ThumbnailData(const sFileName: String; const MaxSize: TSize; StretchFilter: TPhoaStretchFilter; out ImageSize, ThumbSize: TSize): String;
  var
    ThumbBitmap: TBitmap32;
    Stream: TStringStream;
  begin
     // ������������ �����������
    ThumbBitmap := TBitmap32.Create;
    try
       // ��������� ����������� ������ �������� � ThumbBitmap
      MakeThumbnail(sFileName, MaxSize, StretchFilter, ImageSize, ThumbSize, ThumbBitmap);
       // ��������� ����� � �����
      Stream := TStringStream.Create('');
      try
        ThumbBitmap.SaveToStream(Stream);
        Result := Stream.DataString;
      finally
        Stream.Free;
      end;
    finally
      ThumbBitmap.Free;
    end;
  end;

var
   // �������� ���������� ��� ���������. Not thread-safe!
  _JPGBuffer: TJPEGImage  = nil;
  _BMPBuffer: TBitmap32   = nil;

  procedure PaintThumbnail(const sThumbnailData: String; Rotation: TPicRotation; Flips: TPicFlips; Bitmap32: TBitmap32; var r: TRect);
  var
    Stream: TStringStream;
    Transform: TPicTransform;
    iw, ih: Integer;
    rSrc: TRect;
  begin
    if sThumbnailData='' then
      FillChar(r, SizeOf(r), 0)
    else begin
       // ������ �������� �����������
      if _JPGBuffer=nil then _JPGBuffer := TJPEGImage.Create;
      if _BMPBuffer=nil then _BMPBuffer := TBitmap32.Create;
       // ��������� JPEG-����������� ������
      Stream := TStringStream.Create(sThumbnailData);
      try
        _JPGBuffer.LoadFromStream(Stream);
      finally
        Stream.Free;
      end;
       // ���������� �����
      _BMPBuffer.Assign(_JPGBuffer);
       // ��������� ��������������, ���� ��� ����
      if (Rotation<>pr0) or (Flips<>[]) then begin
        Transform := TPicTransform.Create(_BMPBuffer);
        try
          Transform.Rotation := Rotation;
          Transform.Flips    := Flips;
        finally
          Transform.Free;
        end;
      end;
       // ���������� ������� ���������
      iw := Min(_BMPBuffer.Width,  r.Right-r.Left);
      ih := Min(_BMPBuffer.Height, r.Bottom-r.Top);
       // ���������� ������� ��� ��������� ������
      rSrc := Bounds(Max(0, (_BMPBuffer.Width-iw) div 2),  Max(0, (_BMPBuffer.Height-ih) div 2), iw, ih);
      r    := Bounds(r.Left+Max(0, (r.Right-r.Left-iw) div 2), r.Top+Max(0, (r.Bottom-r.Top-ih) div 2),  iw, ih);
       // ������������ ����������� �� �������
      Bitmap32.Draw(r.Left, r.Top, rSrc, _BMPBuffer);
    end;
  end;

  procedure PaintThumbnail(Pic: IPhoaPic; Bitmap32: TBitmap32; var r: TRect);
  begin
    PaintThumbnail(Pic.ThumbnailData, Pic.Rotation, Pic.Flips, Bitmap32, r);
  end;

  procedure PaintThumbnail(Pic: IPhoaPic; Bitmap32: TBitmap32);
  var r: TRect;
  begin
    r := Bitmap32.BoundsRect;
    PaintThumbnail(Pic, Bitmap32, r);
  end;

  procedure PaintBmp32Data(const sBmpData: String; Bitmap32: TBitmap32; const p: TPoint);
  var Stream: TStringStream;
  begin
     // ������ �������� �����������
    if _BMPBuffer=nil then _BMPBuffer := TBitmap32.Create;
     // ��������� ������
    Stream := TStringStream.Create(sBmpData);
    try
      _BMPBuffer.LoadFromStream(Stream);
    finally
      Stream.Free;
    end;
     // ������ �������� �� Bitmap32
    Bitmap32.Draw(p.x, p.y, _BMPBuffer);
  end;

  procedure PaintGroupIcon(const sBmpData: String; Bitmap32: TBitmap32; const p: TPoint; bSelected: Boolean; App: IPhotoAlbumApp);
  var i: Integer;
  begin
    Bitmap32.SetSize(16, 16);
     // ���� ��� ������ - ������ ������ �����
    if sBmpData='' then begin
       // ������ ������ ����� �� ���� ����� clFuchsia
      Bitmap32.DrawMode := dmOpaque;
      ImageList_DrawEx(App.ImageList.Handle, iif(bSelected, iiFolderOpen, iiFolder), Bitmap32.Canvas.Handle, 0, 0, 0, 0, clFuchsia, CLR_NONE, ILD_NORMAL);
      Bitmap32.ResetAlpha;
       // �������� clFuchsia ���������� ������
      Bitmap32.DrawMode := dmBlend;
      for i := 0 to 16*16-1 do
        if Bitmap32.Bits[i]=clFuchsia32 then Bitmap32.Bits[i] := 0;
     // ����� ������ �������� ������
    end else begin
      Bitmap32.DrawMode := dmBlend;
      PaintBmp32Data(sBmpData, Bitmap32, p);
    end;
  end;

  procedure PaintGroupIcon(const sBmpData: String; DC: HDC; const p: TPoint; bSelected: Boolean; App: IPhotoAlbumApp);
  begin
     // ������ �������� �����������
    if _BMPBuffer=nil then _BMPBuffer := TBitmap32.Create;
     // ������ ������ �� �������� �������
    PaintGroupIcon(sBmpData, _BMPBuffer, p, bSelected, App);
     // ��������� �������� ������ �� DC
    _BMPBuffer.DrawTo(DC, p.x, p.y);
  end;

  procedure LoadGraphicFromFile(const sFileName: String; Bitmap32: TBitmap32; const DesiredSize: TSize; out FullSize: TSize; const OnProgress: TProgressEvent);
  var
    sExt: String;
    GClass: TGraphicClass;
    Graphic: TGraphic;
  begin
    sExt := ExtractFileExt(sFileName);
     // ���� IJL ��������, JPEG ������ � � ������� (����� 300% faster) 
    if bIJL_Available and (SameText(sExt, '.JPG') or SameText(sExt, '.JPEG')) then begin
      try
        phIJLIntf.LoadJPEGFromFile(Bitmap32, sFileName, DesiredSize, FullSize);
      except
        on e: Exception do PhoaException(ConstVal('SErrCannotLoadPicture', [sFileName, e.Message]));
      end;
     // ��������� - � ������� GraphicEx
    end else begin
      GClass := FileFormatList.GraphicFromExtension(sExt);
      if GClass=nil then PhoaException(ConstVal('SErrUnknownPicFileExtension', [sFileName]));
      Graphic := GClass.Create;
      try
        Graphic.OnProgress := OnProgress;
         // ��������� �����������
        try
          Graphic.LoadFromFile(sFileName);
        except
          on e: Exception do begin
            FreeAndNil(Graphic);
            if not (e is ELoadGraphicAborted) then PhoaException(ConstVal('SErrCannotLoadPicture', [sFileName, e.Message]));
          end;
        end;
         // ��������������� � TBitmap32
        if Graphic<>nil then
          try
            Bitmap32.Assign(Graphic);
            FullSize.cx := Bitmap32.Width;
            FullSize.cy := Bitmap32.Height;
          except
            on e: Exception do
              if not (e is ELoadGraphicAborted) then PhoaException(ConstVal('SErrCannotDecodePicture', [sFileName, e.Message]));
          end;
      finally
        Graphic.Free;
      end;
    end;
  end;

   //===================================================================================================================
   // TColor32Map
   //===================================================================================================================

  function TColor32Map.ApplyToColor(c: TColor32): TColor32;
  asm
     // EAX = Self
     // EDX = C
     // out: EAX
    mov ebx, edx
    xor edx, edx
     // Put B value
    mov dl, bl
    mov dl, byte ptr [eax+FMapB+edx]
    mov byte ptr [Result+0], dl
     // Put G value
    mov dl, bh
    mov dl, byte ptr [eax+FMapG+edx]
    mov byte ptr [Result+1], dl
     // Put R value
    bswap ebx
    mov dl, bh
    mov dl, byte ptr [eax+FMapR+edx]
    mov byte ptr [Result+2], dl
     // Put A value
    mov dl, bl
    mov dl, byte ptr [eax+FMapA+edx]
    mov byte ptr [Result+3], dl
  end;

  procedure TColor32Map.BuildLinear;
  begin
     // ��������� �������� ������� ��������� ����������
    ChannelBuildLinear(FMapR);
    ChannelBuildLinear(FMapG);
    ChannelBuildLinear(FMapB);
     // �����-����� ������ ������������
    ChannelBuildConstant(FMapA, BColor_Alpha_Opaque);
  end;

  procedure TColor32Map.ChannelBuildConstant(var Map: TChannelByteMap; bValue: Byte);
  begin
    FillChar(Map, SizeOf(Map), bValue);
  end;

  procedure TColor32Map.ChannelBuildLinear(var Map: TChannelByteMap);
  var b: Byte;
  begin
    for b := Low(b) to High(b) do Map[b] := b;
  end;

  constructor TColor32Map.Create;
  begin
    inherited Create;
    BuildLinear;
  end;

   //===================================================================================================================
   // TPicTransform
   //===================================================================================================================

  procedure TPicTransform.ApplyRelativeTransform(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
     // ������� �� 180� � ��� ����� ���� �������� �����������
    if (FBitmap<>nil) and ((ARotation<>pr180) or (AFlips<>[pflHorz, pflVert])) then begin
      case ARotation of
        pr90:  FBitmap.Rotate90;
        pr180: FBitmap.Rotate180;
        pr270: FBitmap.Rotate270;
      end;
      if pflHorz in AFlips then FBitmap.FlipHorz;
      if pflVert in AFlips then FBitmap.FlipVert;
    end;
  end;

  procedure TPicTransform.ApplyTransform;
  var
    fl: TPicFlip;
    NewRotation: TPicRotation;
    NewFlips: TPicFlips;
  begin
    if FBitmap<>nil then begin
       // ��������� ������� � �������� � ����� � � NewRotation
      NewRotation := FRotation;
      if NewRotation<FAppliedRotation then Inc(NewRotation, Byte(Succ(High(NewRotation))));
      Dec(NewRotation, Byte(FAppliedRotation));
       // -- ���� ���� ���� �� ������, ������� � ��������������� �������
      if (FAppliedFlips<>[]) and (FAppliedFlips<>[pflHorz, pflVert]) then Byte(NewRotation) := Byte(Succ(High(NewRotation)))-Byte(NewRotation);
       // ��������� ������� � ���������� � ����� � � NewFlips
      NewFlips := FFlips;
      for fl := Low(fl) to High(fl) do
        if (fl in FAppliedFlips)=(fl in NewFlips) then Exclude(NewFlips, fl) else Include(NewFlips, fl);
       // ��������� ������� � ���������������
      ApplyRelativeTransform(NewRotation, NewFlips);
    end;
     // ��������� ������� �������� ��� ��������� ����������
    FAppliedRotation := FRotation;
    FAppliedFlips    := FFlips;
     // �������� ������� OnApplied
    if Assigned(FOnApplied) then FOnApplied(Self); 
  end;

  procedure TPicTransform.ApplyValues(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
    if (FRotation<>ARotation) or (FFlips<>AFlips) then begin
      FRotation := ARotation;
      FFlips    := AFlips;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.BeginUpdate;
  begin
    Inc(FApplyLock);
  end;

  constructor TPicTransform.Create(ABitmap: TBitmap32);
  begin
    inherited Create;
    FBitmap   := ABitmap;
  end;

  procedure TPicTransform.EndUpdate;
  begin
    if FApplyLock>0 then begin
      Dec(FApplyLock);
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.InitValues(ARotation: TPicRotation; AFlips: TPicFlips);
  begin
    FRotation        := ARotation;
    FAppliedRotation := ARotation;
    FFlips           := AFlips;
    FAppliedFlips    := AFlips;
  end;

  procedure TPicTransform.SetFlips(Value: TPicFlips);
  begin
    if FFlips<>Value then begin
      FFlips := Value;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.SetRotation(Value: TPicRotation);
  begin
    if FRotation<>Value then begin
      FRotation := Value;
      if FApplyLock=0 then ApplyTransform;
    end;
  end;

  procedure TPicTransform.ToggleFlip(Flip: TPicFlip);
  begin
    if Flip in FFlips then Exclude(FFlips, Flip) else Include(FFlips, Flip);
    if FApplyLock=0 then ApplyTransform;
  end;

initialization
finalization
  _JPGBuffer.Free;
  _BMPBuffer.Free;
end.
